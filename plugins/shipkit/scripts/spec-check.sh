#!/bin/sh
# Shipkit spec-check: does every requirement in a spec have a task, and — once the spec is
# shipped — a test that cites it?
#
#   spec-check.sh <project-dir> [slug] [--as-shipped]
#
#   no slug        every spec under .shipkit/specs/
#   --as-shipped   ask an OPEN spec for what a shipped one owes — a cited test for every
#                  requirement that is not excused. Changes no file. It is how the ship gate
#                  asks "would this pass if it shipped now?" before the status is changed.
#
# Reads the spec files as plain text and prints one line per finding:
#
#   MISSING-TASK <slug> REQ-N   tasks.md never mentions the requirement
#   MISSING-TEST <slug> REQ-N   the spec is shipped and no file cites "<slug>/REQ-N"
#   PENDING-TEST <slug> REQ-N   the spec is OPEN and no file cites it yet — information, not a
#                               gap: the test is owed at ship time (both 4.0.0 gates failed
#                               their first run on exactly this, unseen until the gate ran)
#   WAIVED <slug> REQ-N         the requirement ends with [untested: <reason>]
#   SKIPPED <slug> (<status>)   the spec is a draft or was dropped; nothing is checked
#   MISSING-FIELD <slug> <task> <field>   a task lacks Files, Test, After or Done-when
#   BAD-AFTER <slug> <task> <name>        a task's After names a task that does not exist
#   CONFLICT <slug> <a> <b> <file>        tasks a and b both list the file, and b (the later
#                                         one) does not come after a
#   CYCLE <slug> <task>                   the task's After lines lead back to itself
#
# How a spec is read:
#   - Status comes from a "> Status: draft|open|shipped|dropped" line in spec.md. A spec with
#     no such line is treated as open — which is every spec written before 3.3.
#   - A requirement is any line containing **REQ-N. Its text runs to the next requirement,
#     blank line or heading, so an [untested: …] excuse may sit on a wrapped line.
#   - A test cites a requirement by containing "<slug>/REQ-N" anywhere — a comment or a test
#     name. The slug is needed because every spec has its own REQ-1. Citations under .shipkit/,
#     under docs/, or in any *.md file do not count: prose is not a test.
#   - Only a shipped spec is asked for tests. An open one still owes them, and is told so by a
#     PENDING-TEST line per uncited requirement (exit status unchanged; --as-shipped turns
#     them into MISSING-TEST).
#   - The three task-format checks apply only to an OPEN spec that carries a Status line —
#     that is, a spec written in the 3.3 format. A task is a line "- [ ] **T3** …" followed by
#     indented "- Files:", "- Test:", "- After:", "- Done when:" lines. Files and After are
#     comma-separated; After may be "none". The sharing rule: of two tasks that list the same
#     file, the later one must come after the earlier one — named on its After line, or
#     reached through a chain of After lines (T3 after T2, T2 after T1). It is what makes it
#     safe to hand tasks to agents working at the same time.
#
# This checks that a citation EXISTS, not that the cited test passes or proves the requirement.
#
# Exit status: 0 no MISSING-, BAD-AFTER, CONFLICT or CYCLE line; 1 at least one; 64 wrong usage.
# POSIX sh + awk + git. No bash-only syntax, no python. Spec: .shipkit/specs/spec-contract/.

usage() {
  echo "usage: spec-check.sh <project-dir> [slug] [--as-shipped]" >&2
  exit 64
}
AS_SHIPPED=0
PROJ=""
ONLY=""
for arg in "$@"; do
  case "$arg" in
    --as-shipped) AS_SHIPPED=1 ;;
    -*) usage ;;
    *) if [ -z "$PROJ" ]; then PROJ=$arg; elif [ -z "$ONLY" ]; then ONLY=$arg; else usage; fi ;;
  esac
done
[ -n "$PROJ" ] || usage
[ -d "$PROJ" ] || { echo "spec-check: no such directory: $PROJ" >&2; exit 64; }
SPECS="$PROJ/.shipkit/specs"
if [ -n "$ONLY" ] && [ ! -f "$SPECS/$ONLY/spec.md" ]; then
  echo "spec-check: no spec at .shipkit/specs/$ONLY/spec.md" >&2
  exit 64
fi

TMP=$(mktemp "${TMPDIR:-/tmp}/shipkit.XXXXXX") || exit 1  # a template: bare mktemp ignores TMPDIR on macOS
CITES="$TMP.cites"
trap 'rm -f "$TMP" "$CITES"' EXIT

# spec_status <spec.md> → draft | open | shipped | dropped  (anything else, or no line: open)
spec_status() {
  _s=$(sed -n 's/^> *Status: *\([a-z]*\).*/\1/p' "$1" | sed -n 1p)
  case "$_s" in
    draft|open|shipped|dropped) echo "$_s" ;;
    *) echo open ;;
  esac
}

# task_findings <slug> <tasks.md> → MISSING-FIELD / BAD-AFTER / CONFLICT / CYCLE lines
task_findings() {
  awk -v slug="$1" '
    function trim(s) { gsub(/`/, "", s); sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function field(name, key,   v) {
      v = $0; sub(/^[ \t]+- [A-Za-z ]+:/, "", v); val[id, key] = trim(v); has[id, key] = 1
    }
    /^- \[[ xX]\] \*\*[A-Za-z0-9_-]+\*\*/ {
      match($0, /\*\*[A-Za-z0-9_-]+\*\*/); id = substr($0, RSTART + 2, RLENGTH - 4)
      nt++; ids[nt] = id; known[id] = 1; next
    }
    id == "" { next }
    /^[ \t]+- Files:/     { field("Files", "Files"); next }
    /^[ \t]+- Test:/      { field("Test", "Test"); next }
    /^[ \t]+- After:/     { field("After", "After"); next }
    /^[ \t]+- Done when:/ { field("Done when", "Done-when"); next }
    END {
      nf = split("Files Test After Done-when", fields, " ")
      for (i = 1; i <= nt; i++) {
        t = ids[i]
        for (k = 1; k <= nf; k++)
          if (!has[t, fields[k]]) print "MISSING-FIELD", slug, t, fields[k]
        n = split(val[t, "After"], a, ",")
        for (k = 1; k <= n; k++) {
          x = trim(a[k])
          if (x == "" || x == "none") continue
          if (x in known) dep[t, x] = 1; else print "BAD-AFTER", slug, t, x
        }
      }
      # "Comes after" follows chains: close dep[] over itself (tasks are few; n^3 is nothing).
      for (k = 1; k <= nt; k++)
        for (i = 1; i <= nt; i++)
          if (dep[ids[i], ids[k]])
            for (j = 1; j <= nt; j++)
              if (dep[ids[k], ids[j]]) dep[ids[i], ids[j]] = 1
      for (i = 1; i <= nt; i++)
        if (dep[ids[i], ids[i]]) print "CYCLE", slug, ids[i]
      for (i = 1; i <= nt; i++)
        for (j = i + 1; j <= nt; j++) {
          a1 = ids[i]; b1 = ids[j]
          if (dep[b1, a1]) continue
          na = split(val[a1, "Files"], fa, ","); nb = split(val[b1, "Files"], fb, ",")
          for (p = 1; p <= na; p++)
            for (q = 1; q <= nb; q++) {
              f = trim(fa[p])
              if (f != "" && f == trim(fb[q])) print "CONFLICT", slug, a1, b1, f
            }
        }
    }
  ' "$2"
}

# spec_reqs <spec.md> <tasks.md> → one line per requirement, in order:
#   "<N> R T"  required, mentioned in tasks.md      "<N> R -"  required, not mentioned
#   "<N> W T"  waived (and mentioned)               "<N> W -"  waived, not mentioned
# One awk over both files, rather than a grep per requirement: the briefing runs this on
# every session start, and fifty specs must come back in well under a second.
spec_reqs() {
  awk '
    function flush() { if (n != "" && !(n in seen)) { seen[n] = 1; order[++count] = n; kind[n] = (w ? "W" : "R") } n = ""; w = 0 }
    FNR == 1 { file++ }
    file == 1 && (/^[ \t]*$/ || /^#/) { flush(); next }
    file == 1 && /\*\*REQ-[0-9]+/ { flush(); match($0, /\*\*REQ-[0-9]+/); n = substr($0, RSTART + 6, RLENGTH - 6) }
    file == 1 && n != "" && /\[untested:/ { w = 1 }
    file == 2 { t = $0; while (match(t, /REQ-[0-9]+/)) { mentioned[substr(t, RSTART + 4, RLENGTH - 4)] = 1; t = substr(t, RSTART + RLENGTH) } }
    END { flush(); for (i = 1; i <= count; i++) print order[i], kind[order[i]], (order[i] in mentioned ? "T" : "-") }
  ' "$1" "$2"
}

# collect_cites → every "<slug>/REQ-N" that appears in a file that counts as a test, one per
# line, in $CITES. ONE git grep per run: the briefing runs this script at every session start,
# and a grep per requirement made fifty open specs take 2.7 s (smoke check 30's limit is 1 s).
collect_cites() {
  _pat='[A-Za-z0-9._-]+/REQ-[0-9]+'
  if git -C "$PROJ" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$PROJ" grep -h -I -o --untracked -E -e "$_pat" -- . \
      ':(exclude).shipkit' ':(exclude)docs' ':(exclude)*.md' 2>/dev/null
  else
    (cd "$PROJ" && git grep -h -I -o --no-index -E -e "$_pat" -- . \
      ':(exclude).shipkit' ':(exclude)docs' ':(exclude)*.md' 2>/dev/null)
  fi | sort -u > "$CITES"
}
collect_cites

# cited <slug> <N> → exit 0 if a file that counts as a test cites <slug>/REQ-N (whole token:
# alpha/REQ-1 is not satisfied by alpha/REQ-10 or beta/REQ-1)
cited() {
  grep -q -x -F "$1/REQ-$2" "$CITES"
}

gaps=0
checked=0
for spec in "$SPECS"/*/spec.md; do
  [ -f "$spec" ] || continue
  dir=${spec%/spec.md}
  slug=${dir##*/}
  [ -z "$ONLY" ] || [ "$slug" = "$ONLY" ] || continue
  status=$(spec_status "$spec")
  case "$status" in
    draft|dropped) echo "SKIPPED $slug ($status)"; continue ;;
  esac
  checked=$((checked + 1))
  if [ -f "$dir/tasks.md" ]; then spec_reqs "$spec" "$dir/tasks.md" > "$TMP"; else spec_reqs "$spec" /dev/null > "$TMP"; fi
  while read -r n kind mentioned; do
    [ -n "$n" ] || continue
    if [ "$kind" = W ]; then
      echo "WAIVED $slug REQ-$n"
      continue
    fi
    if [ "$mentioned" != T ]; then
      echo "MISSING-TASK $slug REQ-$n"
      gaps=$((gaps + 1))
    fi
    if cited "$slug" "$n"; then
      :
    elif [ "$status" = shipped ] || [ "$AS_SHIPPED" -eq 1 ]; then
      echo "MISSING-TEST $slug REQ-$n"
      gaps=$((gaps + 1))
    else
      echo "PENDING-TEST $slug REQ-$n"   # real-run/REQ-1: open spec, shown not enforced
    fi
  done < "$TMP"
  if [ "$status" = open ] && grep -q '^> *Status:' "$spec" && [ -f "$dir/tasks.md" ]; then
    task_findings "$slug" "$dir/tasks.md" > "$TMP"
    if [ -s "$TMP" ]; then
      cat "$TMP"
      gaps=$((gaps + $(wc -l < "$TMP" | tr -d ' ')))
    fi
  fi
done

echo "spec-check: $checked spec(s) checked, $gaps gap(s)"
[ "$gaps" -eq 0 ] || exit 1
exit 0
