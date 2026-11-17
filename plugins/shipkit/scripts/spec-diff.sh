#!/bin/sh
# Shipkit spec-diff: which requirements of a spec did this branch change?
#
#   spec-diff.sh <project-dir> <slug> [base-ref]
#
# The spec is the check a branch is judged by, and a branch can edit it: reword a requirement to
# match what was built, or excuse it from having a test. Such an edit is often right (the
# goldfish found a gap, an escape added a requirement), so this script blocks nothing. It says
# what changed, for the ship report to quote and the owner to see.
#
# It compares the requirements in .shipkit/specs/<slug>/spec.md as they are in the working tree
# with a baseline, and prints one line for each difference:
#
#   REQ-CHANGED <slug> REQ-N    the requirement's words differ from the baseline's
#   WAIVER-ADDED <slug> REQ-N   it has an [untested: …] waiver now and had none (printed beside
#                               its REQ-CHANGED line)
#   REQ-ADDED <slug> REQ-N      it is in the working tree's spec and not in the baseline
#   REQ-REMOVED <slug> REQ-N    it is in the baseline and not in the working tree's spec
#   NO-BASELINE <slug>          there is nothing to compare with (see below); exit 0
#
# then, when there was a baseline, a summary line: "spec-diff: N requirement(s) differ from
# <commit>".
#
# The baseline, in this order:
#   1. spec.md at the base ref, when the file exists there;
#   2. otherwise spec.md at the first commit after the base ref in which its "> Status:" line
#      reads open — the spec as it was accepted, for a spec written on its own branch;
#   3. otherwise none: NO-BASELINE.
# The commit named on the spec's "accepted at commit" stamp is not used. The stamp is written
# before the spec is committed, so that commit does not hold the spec
# (docs/design/field-notes-5.2.md §7: the stamp read 179f99d, the spec first appeared in 8f2dbb4).
#
# <base-ref> is the commit the branch's work started from. When none is given it is the merge
# base of HEAD and main (or master), as the ship gate's default is.
#
# How a requirement is read — as brief.sh reads it: from a line holding **REQ-N to the next
# requirement, blank line or heading. Its words are compared after its lines are joined and
# every run of spaces and tabs is made one space, so the same words wrapped or spaced another
# way are not a change. A number that appears twice is read once, at its first place.
#
# Exit status: 0 nothing differs, or NO-BASELINE; 1 at least one REQ- or WAIVER- line; 64 wrong
# usage, an unknown spec or an unknown base ref.
# Changes no file and writes none. POSIX sh, awk and git; nothing else is run.
# Spec: .shipkit/specs/honest-evidence/ (REQ-21 to REQ-29).

usage() {
  echo "usage: spec-diff.sh <project-dir> <slug> [base-ref]" >&2
  exit 64
}
[ $# -ge 2 ] && [ $# -le 3 ] || usage
PROJ=$1; SLUG=$2; BASE=${3:-}
[ -d "$PROJ" ] || { echo "spec-diff: no such directory: $PROJ" >&2; exit 64; }
# The slug goes into a git command that awk runs, so it may hold only what a folder name does.
case "$SLUG" in
  ""|*[!A-Za-z0-9._-]*) echo "spec-diff: not a spec name: $SLUG" >&2; exit 64 ;;
esac
cd "$PROJ" || exit 64
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "spec-diff: $PROJ is not a git repository" >&2; exit 64; }
SPEC=".shipkit/specs/$SLUG/spec.md"
[ -f "$SPEC" ] || { echo "spec-diff: no spec at $SPEC" >&2; exit 64; }

if [ -z "$BASE" ]; then
  for b in main master; do
    if git rev-parse --verify --quiet "$b^{commit}" >/dev/null 2>&1; then
      BASE=$(git merge-base HEAD "$b" 2>/dev/null)
      break
    fi
  done
  [ -n "$BASE" ] || {
    echo "spec-diff: no base ref given, and no main or master to take one from" >&2; exit 64; }
fi
BASE_SHA=$(git rev-parse --verify --quiet "$BASE^{commit}" 2>/dev/null) || {
  echo "spec-diff: git does not know the base ref '$BASE'" >&2; exit 64; }

# The baseline commit: the base ref if it holds the spec, else the first commit after it in
# which the spec's Status reads open. "./" makes the path relative to this directory, so a
# project that is a folder inside a larger repository is read right.
REF=""
if git cat-file -e "$BASE_SHA:./$SPEC" 2>/dev/null; then
  REF=$BASE_SHA
else
  for c in $(git rev-list --reverse "$BASE_SHA"..HEAD -- "$SPEC" 2>/dev/null); do
    if git show "$c:./$SPEC" 2>/dev/null | awk '/^> *Status: *open/ { f = 1 } END { exit !f }'; then
      REF=$c
      break
    fi
  done
fi
if [ -z "$REF" ]; then
  echo "NO-BASELINE $SLUG"
  exit 0
fi
SHORT=$(git rev-parse --short "$REF")

# One awk reads both sides: the baseline through `git show`, the working tree's file as its
# input. REF is a full commit id and SLUG was checked above, so the command holds no character
# a shell would read as its own.
awk -v slug="$SLUG" -v cmd="git show $REF:./$SPEC" -v ref="$SHORT" '
  function norm(t) { gsub(/[ \t]+/, " ", t); sub(/^ /, "", t); sub(/ $/, "", t); return t }
  function take(line, side,   n) {   # one line of a spec, for side "b" (baseline) or "n" (now)
    if (line ~ /^[ \t]*$/ || line ~ /^#/) { cur[side] = ""; return }
    if (match(line, /\*\*REQ-[0-9]+/)) {
      n = substr(line, RSTART + 6, RLENGTH - 6)
      if ((side, n) in have) { cur[side] = ""; return }   # a number met again: its first place stands
      have[side, n] = 1; nums[n] = 1; cur[side] = n
    }
    if (cur[side] != "") txt[side, cur[side]] = txt[side, cur[side]] " " line
  }
  BEGIN { while ((cmd | getline line) > 0) take(line, "b"); close(cmd) }
  { take($0, "n") }
  END {
    k = 0
    for (n in nums) list[++k] = n + 0
    for (i = 2; i <= k; i++) {   # put the few numbers in order, by insertion
      v = list[i]
      for (j = i - 1; j >= 1 && list[j] > v; j--) list[j + 1] = list[j]
      list[j + 1] = v
    }
    d = 0
    for (i = 1; i <= k; i++) {
      n = list[i]
      inb = ((("b", n) in have) ? 1 : 0); inn = ((("n", n) in have) ? 1 : 0)
      if (inb && inn) {
        b = norm(txt["b", n]); w = norm(txt["n", n])
        if (b != w) {
          print "REQ-CHANGED " slug " REQ-" n; d++
          if (index(w, "[untested:") > 0 && index(b, "[untested:") == 0) print "WAIVER-ADDED " slug " REQ-" n
        }
      } else if (inn) { print "REQ-ADDED " slug " REQ-" n; d++ }
      else { print "REQ-REMOVED " slug " REQ-" n; d++ }
    }
    print "spec-diff: " d " requirement(s) differ from " ref
    exit (d > 0 ? 1 : 0)
  }' "$SPEC"
