#!/bin/sh
# Shipkit decision-check: which decision records say their reversal condition has come true?
#
#   decision-check.sh <project-dir> [--run]
#
# A decision record may end with one optional line after its falsifiability clause:
#
#   **Fired-if.** `<command>`     a shell command that exits 0 once the condition has come true
#   **Fired-if.** manual          the condition cannot be measured from the repository
#
# The script looks in .shipkit/decisions/*.md and .shipkit/specs/*/design.md.
#
# Without --run (the default) it LISTS: one line per Fired-if line, the record and its command,
# and runs nothing. Exit 0.
#
# With --run it runs each command from the project directory with `sh -c` and prints one line
# per decision:
#   FIRED  <record>: <command>              exit 0 — the condition has come true
#   HOLDS  <record>: <command>              exit 1 — it still holds
#   MANUAL <record>: <the clause's text>    the line says manual; a person has to look
#   ERROR  <record>: <command> (exit N)     exit above 1 — the command itself failed
# then a summary line. Exit 1 if anything FIRED, else 0 (an ERROR or a MANUAL is not a
# firing). 64 on wrong usage.
#
# SAFETY — read this before --run. The commands come from the repository you point this at,
# not from shipkit: a record is a text file anyone with a commit can write. Run without --run
# first and read the commands before using --run in a repository you do not trust. This script
# is never called from any hook, and the default is to list, not run; the elders run it with
# --run only for a project in your own registry, and the ship gate on the project it is run in.
#
# <record> is the file's path relative to the project, and for a design.md the decision's
# title too: ".shipkit/specs/refunds/design.md (Exit status 0 means fired)".
# POSIX sh + awk. No model, no network. Spec: .shipkit/specs/decisions-and-digest/.

usage() {
  echo "usage: decision-check.sh <project-dir> [--run]" >&2
  exit 64
}
RUN=0
PROJ=""
for arg in "$@"; do
  case "$arg" in
    --run) RUN=1 ;;
    -*) usage ;;
    *) if [ -z "$PROJ" ]; then PROJ=$arg; else usage; fi ;;
  esac
done
[ -n "$PROJ" ] || usage
[ -d "$PROJ" ] || { echo "decision-check: no such directory: $PROJ" >&2; exit 64; }
cd "$PROJ" || exit 64

TMP=$(mktemp "${TMPDIR:-/tmp}/shipkit.XXXXXX") || exit 1  # a template: bare mktemp ignores TMPDIR on macOS
trap 'rm -f "$TMP"' EXIT

# The files that may hold records. Globs that match nothing are dropped, not passed to awk.
set --
for f in .shipkit/decisions/*.md .shipkit/specs/*/design.md; do
  [ -f "$f" ] && set -- "$@" "$f"
done

# One line per Fired-if line, tab-separated: record, kind (cmd|manual), payload, clause.
# The record is the path, plus the nearest "## Decision:" title above the line when there is
# one (a design.md holds several). The clause is the Falsifiability sentence, which may wrap.
if [ "$#" -gt 0 ]; then
  awk '
    BEGIN { OFS = "\t" }
    FNR == 1 { title = ""; clause = ""; inclause = 0 }
    /^## Decision:/ {
      t = substr($0, 13); sub(/[ \t]*\(→.*$/, "", t); sub(/^[ \t]+/, "", t); sub(/[ \t]+$/, "", t)
      title = t; clause = ""; inclause = 0
    }
    /^\*\*Falsifiability\.\*\*/ { clause = $0; sub(/^\*\*Falsifiability\.\*\*[ \t]*/, "", clause); inclause = 1; next }
    inclause && (/^[ \t]*$/ || /^\*\*/ || /^#/) { inclause = 0 }
    inclause { c = $0; sub(/^[ \t]+/, "", c); sub(/[ \t]+$/, "", c); clause = clause " " c }
    /^\*\*Fired-if\.\*\*/ {
      p = $0; sub(/^\*\*Fired-if\.\*\*[ \t]*/, "", p); sub(/[ \t]+$/, "", p)
      if (p ~ /^`.*`$/) { p = substr(p, 2, length(p) - 2); kind = "cmd" }
      else if (tolower(p) ~ /^manual\.?$/) { kind = "manual"; p = "manual" }
      else kind = "cmd"
      rec = FILENAME; if (title != "") rec = rec " (" title ")"
      gsub(/\t/, " ", p); gsub(/\t/, " ", clause)
      print rec, kind, p, clause
    }
  ' "$@" > "$TMP"
fi

total=0; fired=0; holds=0; manual=0; errors=0
TAB=$(printf '\t')
while IFS="$TAB" read -r rec kind payload clause; do
  [ -n "$rec" ] || continue
  total=$((total + 1))
  if [ "$RUN" -eq 0 ]; then
    echo "$rec: $payload"
    continue
  fi
  if [ "$kind" = manual ]; then
    manual=$((manual + 1))
    echo "MANUAL $rec: $clause"
    continue
  fi
  # The command runs here, from the project directory, and only because --run was given.
  sh -c "$payload" </dev/null >/dev/null 2>&1
  rc=$?
  case "$rc" in
    0) fired=$((fired + 1)); echo "FIRED  $rec: $payload" ;;
    1) holds=$((holds + 1)); echo "HOLDS  $rec: $payload" ;;
    *) errors=$((errors + 1)); echo "ERROR  $rec: $payload (exit $rc)" ;;
  esac
done < "$TMP"

if [ "$RUN" -eq 0 ]; then
  echo "decision-check: $total decision(s) listed, nothing run (add --run to run the commands)"
  exit 0
fi
echo "decision-check: $total decision(s), $fired fired, $holds hold, $manual manual, $errors error(s)"
[ "$fired" -eq 0 ] || exit 1
exit 0
