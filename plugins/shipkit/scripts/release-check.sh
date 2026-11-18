#!/bin/sh
# Shipkit release-check: is each shipped spec's READY report still about the code that shipped?
#
#   release-check.sh <project-dir> [--enforce]
#
# A ship report names the commit it checked, on its "> Checked on <date> at commit `<sha>`"
# line, and nothing read that line again: work could land after the gate and before the spec
# was called shipped. For each spec whose spec.md says "> Status: shipped", in name order, this
# script reads the newest report for it whose first line is exactly READY (the newest is the
# latest date in the file's name, .shipkit/releases/<YYYY-MM-DD>-<slug>.md), and prints:
#
#   NO-REPORT <slug>                the spec has no READY report
#   ORPHAN-REPORT <slug>            the report's commit is not in HEAD's history, or cannot be
#                                   found at all (a report made on an abandoned branch)
#   CHANGED-AFTER-GATE <slug> <n>   n commits touched the spec's "> Paths:" after the report's
#                                   commit and before the spec's shipping commit: the first commit
#                                   in which "> Status: shipped" appears. The shipping commit is
#                                   not counted (it adds the report and bumps versions: the release
#                                   routine), nor is any commit after it (a later sprint's). A
#                                   spec with no Paths line gets no count.
#
# then "release-check: <s> shipped spec(s), <f> finding(s)".
#
# Observe mode: it exits 0 whatever it prints. With --enforce it exits 1 when it printed a
# finding. A new check prints before it fails anything (the verifier plan's rule 29); the
# record that says when --enforce is turned on in CI is in
# .shipkit/specs/gate-as-software/design.md, fourth record.
#
# Needs the full history (a shallow clone cannot see the commits it counts). Exit 2 on usage or
# when the directory is not a git repository.
# POSIX sh + awk + git. No model, no network. Spec: .shipkit/specs/gate-as-software/
# (REQ-24 to REQ-30).

usage() { echo "usage: release-check.sh <project-dir> [--enforce]" >&2; exit 2; }

ENFORCE=0
case $# in
  1) ;;
  2) [ "$2" = --enforce ] || usage; ENFORCE=1 ;;
  *) usage ;;
esac
cd "$1" 2>/dev/null || { echo "release-check: no such directory: $1" >&2; exit 2; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo "release-check: not a git repository: $1" >&2; exit 2; }

shipped=0; found=0
for spec in .shipkit/specs/*/spec.md; do
  [ -f "$spec" ] || continue
  status=$(sed -n 's/^> *Status: *\([a-z]*\).*/\1/p' "$spec" | sed -n 1p)
  [ "$status" = shipped ] || continue
  dir=${spec%/spec.md}; slug=${dir##*/}
  shipped=$((shipped + 1))

  # the newest READY report: names sort by date, so the last one that starts READY
  report=""
  for r in .shipkit/releases/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-"$slug".md; do
    [ -f "$r" ] || continue
    [ "$(sed -n 1p "$r")" = READY ] && report=$r
  done
  if [ -z "$report" ]; then echo "NO-REPORT $slug"; found=$((found + 1)); continue; fi

  rsha=$(sed -n 's/^> *Checked on .* at commit `\([^`]*\)`.*/\1/p' "$report" | sed -n 1p)
  rfull=""
  [ -n "$rsha" ] && rfull=$(git rev-parse --verify -q "$rsha^{commit}" 2>/dev/null)
  if [ -z "$rfull" ] || ! git merge-base --is-ancestor "$rfull" HEAD 2>/dev/null; then
    echo "ORPHAN-REPORT $slug"; found=$((found + 1)); continue
  fi

  # Paths, read as the session hook reads them ([[:space:]]: gate-as-software/REQ-1)
  paths=$(sed -n 's/^> *Paths: *//p' "$spec" | sed -n 1p | tr ',' '\n' \
    | sed 's/`//g; s/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$')
  [ -n "$paths" ] || continue
  ship=$(git log --format=%H -G'^> *Status: *shipped' -- "$spec" 2>/dev/null | tail -1)
  [ -n "$ship" ] || continue
  n=$(printf '%s\n' "$paths" | xargs git rev-list --count "$rfull..$ship^" -- 2>/dev/null)
  case "$n" in ''|0|*[!0-9]*) ;; *) echo "CHANGED-AFTER-GATE $slug $n"; found=$((found + 1)) ;; esac
done

echo "release-check: $shipped shipped spec(s), $found finding(s)"
[ "$ENFORCE" -eq 1 ] && [ "$found" -gt 0 ] && exit 1
exit 0
