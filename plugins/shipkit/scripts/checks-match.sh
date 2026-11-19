#!/bin/sh
# Shipkit checks-match: which of a project's checks does this diff trigger?
#
#   checks-match.sh <project-dir> <base-ref>
#   checks-match.sh --lint <project-dir>
#
# .shipkit/checks.md holds what past misses taught: one item for each, with a trigger that can
# be read from a diff, the thing to check, and the miss it came from.
#
#   ## C1: A refund is sent once
#   Trigger: path app/refunds.py, app/billing/*
#   Check: Every call to gateway.refund passes an idempotency key.
#   From: .shipkit/escapes/0001-double-refund.md, .shipkit/escapes/0004-refund-retried.md
#
# An item starts at its "## C<n>: <title>" line and runs to the next one. A trigger is one of
#
#   path <glob>[, <glob>]…   met when a file that `git diff --name-only <base>...HEAD` names
#                            matches a glob. A glob is matched against the whole path as a shell
#                            `case` pattern, so * also matches /
#   added <pattern>          met when a line the diff adds matches the pattern, an extended
#                            regular expression as awk reads it. A removed line never meets it
#
# For each item whose trigger is met, in the file's order, four lines are printed:
# "TRIGGERED C<n>: <title>", then the item's Trigger:, Check: and From: lines as written.
#
# The file is read from the base ref (`git show <base>:.shipkit/checks.md`), never from the
# working tree: a change does not judge itself. An item added on a branch takes effect after it
# merges, and a branch cannot delete the item that would catch it. No checks file at the base:
# nothing is printed.
#
# --lint reads the working tree's file, the one being written, and prints
# "BAD-ITEM C<n> <reason>" for an item with no Trigger:, Check: or From: line, a trigger of
# neither kind, or a source that does not exist. A source is each comma-separated entry of
# From:, and its first word is a path from the project's root.
#
# This script blocks nothing: it prints what to look at. It changes no file.
# Exit status: 0, whether or not an item is printed; with --lint, 1 when a BAD-ITEM line is
# printed; 64 on wrong usage or a base ref git does not know. POSIX sh + awk + git.
# Spec: .shipkit/specs/misses-to-checks/ (REQ-25 to REQ-31).

usage() { echo "usage: checks-match.sh <project-dir> <base-ref> | --lint <project-dir>" >&2; exit 64; }
US=$(printf '\037')

# items: a checks file on standard input → one line an item: its id, its title and its three
# lines as written, separated by the unit separator. A line the item lacks is empty.
items() {
  awk '
    function flush() { if (id != "") printf "%s\037%s\037%s\037%s\037%s\n", id, title, trig, chk, frm }
    /^## C[0-9]+: / {
      flush(); id = $2; sub(/:$/, "", id)
      title = $0; sub(/^## C[0-9]+: */, "", title); trig = chk = frm = ""; next
    }
    id != "" && trig == "" && /^Trigger:/ { trig = $0; next }
    id != "" && chk == "" && /^Check:/ { chk = $0; next }
    id != "" && frm == "" && /^From:/ { frm = $0; next }
    END { flush() }'
}
trim() { _t=$1; _t=${_t#"${_t%%[! ]*}"}; _t=${_t%"${_t##*[! ]}"}; printf '%s' "$_t"; }

if [ "${1:-}" = --lint ]; then
  [ $# -eq 2 ] && [ -d "$2" ] || usage
  [ -f "$2/.shipkit/checks.md" ] || exit 0
  out=$(items < "$2/.shipkit/checks.md"); bad=0
  while IFS="$US" read -r id title trig chk frm; do
    [ -n "$id" ] || continue
    [ -n "$trig" ] || { echo "BAD-ITEM $id has no Trigger: line"; bad=1; }
    [ -n "$chk" ] || { echo "BAD-ITEM $id has no Check: line"; bad=1; }
    [ -n "$frm" ] || { echo "BAD-ITEM $id has no From: line"; bad=1; }
    if [ -n "$trig" ]; then
      case "$(trim "${trig#Trigger:}")" in
        "path "?*|"added "?*) ;;
        *) echo "BAD-ITEM $id has a trigger that is neither \`path <glob>\` nor \`added <pattern>\`"; bad=1 ;;
      esac
    fi
    if [ -n "$frm" ]; then
      srcs=$(trim "${frm#From:}")
      [ -n "$srcs" ] || { echo "BAD-ITEM $id names no source on its From: line"; bad=1; }
      old_ifs=$IFS; IFS=,; set -f
      for src in $srcs; do
        IFS=$old_ifs; src=$(trim "$src"); src=${src%% *}
        [ -z "$src" ] || [ -e "$2/$src" ] || { echo "BAD-ITEM $id names a source that does not exist: $src"; bad=1; }
      done
      set +f; IFS=$old_ifs
    fi
  done <<EOF
$out
EOF
  exit "$bad"
fi

[ $# -eq 2 ] && [ -d "$1" ] || usage
proj=$1; base=$2
git -C "$proj" rev-parse --verify --quiet "$base^{commit}" >/dev/null 2>&1 \
  || { echo "checks-match: git does not know the base ref $base" >&2; exit 64; }
git -C "$proj" cat-file -e "$base:.shipkit/checks.md" 2>/dev/null || exit 0
out=$(git -C "$proj" show "$base:.shipkit/checks.md" | items)
names=$(git -C "$proj" diff --name-only "$base...HEAD" 2>/dev/null)
# The lines the diff adds: inside a hunk, a line that starts with +, without the +.
added=$(git -C "$proj" diff -U0 "$base...HEAD" 2>/dev/null \
  | awk '/^diff --git / { hunk = 0; next } /^@@/ { hunk = 1; next } hunk && /^\+/ { print substr($0, 2) }')

met_path() {  # met_path <globs> → 0 when a changed file matches one of them
  old_ifs=$IFS; IFS=,; set -f
  for glob in $1; do
    IFS=$old_ifs; glob=$(trim "$glob")
    [ -n "$glob" ] || continue
    while IFS= read -r file; do
      # shellcheck disable=SC2254
      case "$file" in $glob) set +f; return 0 ;; esac
    done <<EOF
$names
EOF
  done
  set +f; IFS=$old_ifs; return 1
}
met_added() {  # met_added <pattern> → 0 when an added line matches it
  [ -n "$added" ] || return 1
  printf '%s\n' "$added" | PAT="$1" awk 'BEGIN { pat = ENVIRON["PAT"] } $0 ~ pat { found = 1; exit } END { exit !found }' 2>/dev/null
}

while IFS="$US" read -r id title trig chk frm; do
  [ -n "$id" ] || continue
  rest=$(trim "${trig#Trigger:}")
  case "$rest" in
    "path "?*) met_path "${rest#path }" || continue ;;
    "added "?*) met_added "$(trim "${rest#added }")" || continue ;;
    *) continue ;;
  esac
  printf 'TRIGGERED %s: %s\n%s\n%s\n%s\n' "$id" "$title" "$trig" "$chk" "$frm"
done <<EOF
$out
EOF
exit 0
