#!/bin/sh
# Shipkit spec-check: does every requirement in a spec have a task, and — once the spec is
# shipped — a test that cites it?
#
#   spec-check.sh <project-dir> [slug]     # no slug: every spec under .shipkit/specs/
#
# Reads the spec files as plain text and prints one line per finding:
#
#   MISSING-TASK <slug> REQ-N   tasks.md never mentions the requirement
#   MISSING-TEST <slug> REQ-N   the spec is shipped and no file cites "<slug>/REQ-N"
#   WAIVED <slug> REQ-N         the requirement ends with [untested: <reason>]
#   SKIPPED <slug> (<status>)   the spec is a draft or was dropped; nothing is checked
#
# How a spec is read:
#   - Status comes from a "> Status: draft|open|shipped|dropped" line in spec.md. A spec with
#     no such line is treated as open — which is every spec written before 3.3.
#   - A requirement is any line containing **REQ-N. Its text runs to the next requirement,
#     blank line or heading, so an [untested: …] excuse may sit on a wrapped line.
#   - A test cites a requirement by containing "<slug>/REQ-N" anywhere — a comment or a test
#     name. The slug is needed because every spec has its own REQ-1. Citations under .shipkit/,
#     under docs/, or in any *.md file do not count: prose is not a test.
#   - Only a shipped spec is asked for tests. An open one still owes them.
#
# This checks that a citation EXISTS, not that the cited test passes or proves the requirement.
#
# Exit status: 0 no MISSING- line; 1 at least one; 64 wrong usage.
# POSIX sh + awk + git. No bash-only syntax, no python. Spec: .shipkit/specs/spec-contract/.

usage() {
  echo "usage: spec-check.sh <project-dir> [slug]" >&2
  exit 64
}
[ $# -ge 1 ] && [ $# -le 2 ] || usage
PROJ=$1
ONLY=${2:-}
[ -d "$PROJ" ] || { echo "spec-check: no such directory: $PROJ" >&2; exit 64; }
SPECS="$PROJ/.shipkit/specs"
if [ -n "$ONLY" ] && [ ! -f "$SPECS/$ONLY/spec.md" ]; then
  echo "spec-check: no spec at .shipkit/specs/$ONLY/spec.md" >&2
  exit 64
fi

TMP=$(mktemp) || exit 1
trap 'rm -f "$TMP"' EXIT

# spec_status <spec.md> → draft | open | shipped | dropped  (anything else, or no line: open)
spec_status() {
  _s=$(sed -n 's/^> *Status: *\([a-z]*\).*/\1/p' "$1" | sed -n 1p)
  case "$_s" in
    draft|open|shipped|dropped) echo "$_s" ;;
    *) echo open ;;
  esac
}

# spec_reqs <spec.md> → one line per requirement, in order: "<N> R" (required) or "<N> W" (waived)
spec_reqs() {
  awk '
    function flush() { if (n != "" && !(n in seen)) { seen[n] = 1; print n, (w ? "W" : "R") } n = ""; w = 0 }
    /^[ \t]*$/ || /^#/ { flush(); next }
    /\*\*REQ-[0-9]+/ { flush(); match($0, /\*\*REQ-[0-9]+/); n = substr($0, RSTART + 6, RLENGTH - 6) }
    n != "" && /\[untested:/ { w = 1 }
    END { flush() }
  ' "$1"
}

# cited <slug> <N> → exit 0 if a file that counts as a test cites <slug>/REQ-N
cited() {
  _pat="$(printf '%s' "$1" | sed 's/[.[\*^$]/\\&/g')/REQ-$2([^0-9]|\$)"
  if git -C "$PROJ" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$PROJ" grep -q -I --untracked -E -e "$_pat" -- . \
      ':(exclude).shipkit' ':(exclude)docs' ':(exclude)*.md' 2>/dev/null
  else
    (cd "$PROJ" && git grep -q -I --no-index -E -e "$_pat" -- . \
      ':(exclude).shipkit' ':(exclude)docs' ':(exclude)*.md' 2>/dev/null)
  fi
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
  spec_reqs "$spec" > "$TMP"
  while read -r n kind; do
    [ -n "$n" ] || continue
    if [ "$kind" = W ]; then
      echo "WAIVED $slug REQ-$n"
      continue
    fi
    if ! grep -Eq "REQ-$n([^0-9]|\$)" "$dir/tasks.md" 2>/dev/null; then
      echo "MISSING-TASK $slug REQ-$n"
      gaps=$((gaps + 1))
    fi
    if [ "$status" = shipped ] && ! cited "$slug" "$n"; then
      echo "MISSING-TEST $slug REQ-$n"
      gaps=$((gaps + 1))
    fi
  done < "$TMP"
done

echo "spec-check: $checked spec(s) checked, $gaps gap(s)"
[ "$gaps" -eq 0 ] || exit 1
exit 0
