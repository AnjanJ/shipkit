#!/bin/sh
# Shipkit portfolio digest: one page across every registered project, from files already on
# disk. No model, no network. Run it by hand, from cron or launchd (GUIDE.md shows how), or
# through `/shipkit:ask --all digest`, which hands the page to eve.
#
#   portfolio-digest.sh [registry-file] [--run-checks]
#
#   registry-file   default $SHIPKIT_HOME/project-registry.md; SHIPKIT_HOME defaults to
#                   ~/.claude/shipkit. The digest is written to $SHIPKIT_HOME/digests/<date>.md.
#   --run-checks    also RUN each project's Fired-if commands (decision-check.sh --run). They
#                   come from the project's own repository; without the flag they are only
#                   counted, never run.
#
# One section per project in the registry, each with exactly these seven lines:
#   - Top goal: <first goal> (product reviewed on <date>)      .shipkit/product.md
#   - Open specs: <slug> N of M tasks done, next Tk; ...       each open spec's tasks.md
#   - Spec gaps: N                                             spec-check.sh
#   - Decisions: ...                                           decision-check.sh
#   - Escapes (30 days): N — <cause> n, ...                    .shipkit/escapes/
#   - Map: N commits old                                       the map's stamp
#   - Git: N uncommitted file(s), N unpushed commit(s)         git status, git log @{u}..
# A project whose path does not exist gets one line, "path not found", and the script goes on.
#
# Exit 0 when every project was written (a fired decision does not change it — the page is
# the place to read that); 1 if the digest could not be written; 64 on wrong usage.
# POSIX sh + awk + git. Spec: .shipkit/specs/decisions-and-digest/.

usage() {
  echo "usage: portfolio-digest.sh [registry-file] [--run-checks]" >&2
  exit 64
}
HERE=$(cd "$(dirname "$0")" && pwd) || exit 1
SHIPKIT_HOME=${SHIPKIT_HOME:-$HOME/.claude/shipkit}
RUN=0
REG=""
for arg in "$@"; do
  case "$arg" in
    --run-checks) RUN=1 ;;
    -*) usage ;;
    *) if [ -z "$REG" ]; then REG=$arg; else usage; fi ;;
  esac
done
[ -n "$REG" ] || REG="$SHIPKIT_HOME/project-registry.md"
[ -f "$REG" ] || { echo "portfolio-digest: no registry at $REG (run /shipkit:map --register <path> first)" >&2; exit 1; }

TODAY=$(date +%Y-%m-%d)
OUT_DIR="$SHIPKIT_HOME/digests"
OUT="$OUT_DIR/$TODAY.md"
mkdir -p "$OUT_DIR" || { echo "portfolio-digest: cannot create $OUT_DIR" >&2; exit 1; }
TMP=$(mktemp "${TMPDIR:-/tmp}/shipkit.XXXXXX") || exit 1  # a template: bare mktemp ignores TMPDIR on macOS
trap 'rm -f "$TMP"' EXIT

# The registry is a Markdown table. Columns are found by their header names, so a registry
# written before the Product and Top Goal columns existed still reads. Output: name TAB path.
awk -F'|' '
  function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
  /^\|/ && !hdr {
    for (i = 1; i <= NF; i++) { h = trim($i); if (h == "Project") pc = i; if (h == "Path") pp = i }
    if (pc && pp) hdr = 1
    next
  }
  hdr && /^\|[ \t]*-/ { next }
  hdr && /^\|/ { n = trim($pc); p = trim($pp); if (n != "" && p != "") printf "%s\t%s\n", n, p }
' "$REG" > "$TMP"

# days since 1970-01-01 for a YYYY-MM-DD, so "the last 30 days" needs no date(1) flags, which
# differ between BSD and GNU. Standard days-from-civil arithmetic.
day_number() {
  printf '%s\n' "$1" | awk -F- 'NF == 3 {
    y = $1 + 0; m = $2 + 0; d = $3 + 0
    if (m <= 2) { y--; m += 12 }
    era = int(y / 400); yoe = y - era * 400
    doy = int((153 * (m - 3) + 2) / 5) + d - 1
    doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
    print era * 146097 + doe - 719468 }'
}
TODAY_N=$(day_number "$TODAY")

# write_project <name> <path>  → the section, on stdout
write_project() {
  name=$1; path=$2
  case "$path" in "~"|"~/"*) path="$HOME${path#\~}" ;; esac
  printf '## %s — %s\n\n' "$name" "$path"
  if [ ! -d "$path" ]; then
    printf 'path not found\n\n'
    return
  fi
  (
    cd "$path" || exit 0
    # 1. top goal and review date
    goal=""; rdate=""
    if [ -f .shipkit/product.md ]; then
      goal=$(awk '/^## /{on=($0 ~ /^## Goals this quarter/); next} on && /^(- |[0-9]+\. )/{sub(/^(- |[0-9]+\. )/, ""); print; exit}' .shipkit/product.md 2>/dev/null)
      rdate=$(sed -n 's/^> *Product reviewed on \([0-9-]*\).*/\1/p' .shipkit/product.md 2>/dev/null | sed -n 1p)
      [ -n "$goal" ] || goal="no goal set"
      printf -- '- Top goal: %s (product reviewed on %s)\n' "$goal" "${rdate:-an unknown date}"
    else
      printf -- '- Top goal: no product file\n'
    fi
    # 2. open specs and task progress
    specs=""
    for spec in .shipkit/specs/*/spec.md; do
      [ -f "$spec" ] || continue
      case "$(sed -n 's/^> *Status: *\([a-z]*\).*/\1/p' "$spec" 2>/dev/null | sed -n 1p)" in
        shipped|dropped|draft) continue ;;
      esac
      dir=${spec%/spec.md}; slug=${dir##*/}
      if [ -f "$dir/tasks.md" ]; then
        prog=$(awk '
          /^- \[[xX]\] \*\*[A-Za-z0-9_-]+\*\*/ { done++; total++; next }
          /^- \[ \] \*\*[A-Za-z0-9_-]+\*\*/ { total++; if (nxt == "") { match($0, /\*\*[A-Za-z0-9_-]+\*\*/); nxt = substr($0, RSTART + 2, RLENGTH - 4) } }
          END { if (total == 0) print "no tasks"; else if (nxt == "") printf "%d of %d tasks done, all ticked", done, total; else printf "%d of %d tasks done, next %s", done, total, nxt }' "$dir/tasks.md" 2>/dev/null)
      else prog="no tasks.md"; fi
      specs="${specs:+$specs; }$slug $prog"
    done
    printf -- '- Open specs: %s\n' "${specs:-none}"
    # 3. spec gaps
    if [ -f "$HERE/spec-check.sh" ] && [ -d .shipkit/specs ]; then
      gaps=$(sh "$HERE/spec-check.sh" . 2>/dev/null | sed -n 's/^spec-check: .* checked, \([0-9]*\) gap(s)$/\1/p' | sed -n 1p)
      printf -- '- Spec gaps: %s\n' "${gaps:-unknown}"
    else
      printf -- '- Spec gaps: 0\n'
    fi
    # 4. decisions — commands run only with --run-checks
    if [ -f "$HERE/decision-check.sh" ]; then
      if [ "$RUN" -eq 1 ]; then
        dsum=$(sh "$HERE/decision-check.sh" . --run 2>/dev/null | sed -n 's/^decision-check: [0-9]* decision(s), //p' | sed -n 1p)
        printf -- '- Decisions: %s\n' "${dsum:-none with a Fired-if line}"
      else
        dlist=$(sh "$HERE/decision-check.sh" . 2>/dev/null)
        dn=$(printf '%s\n' "$dlist" | sed -n 's/^decision-check: \([0-9]*\) decision(s) listed.*/\1/p' | sed -n 1p)
        dm=$(printf '%s\n' "$dlist" | grep -c ': manual$')
        if [ "${dn:-0}" -eq 0 ]; then printf -- '- Decisions: none with a Fired-if line\n'
        else printf -- '- Decisions: %s with a Fired-if line, %s manual; commands not run (add --run-checks)\n' "$dn" "$dm"; fi
      fi
    else
      printf -- '- Decisions: decision-check.sh not found\n'
    fi
    # 5. escapes in the last 30 days, by cause
    esc=""; en=0
    for e in .shipkit/escapes/*.md; do
      [ -f "$e" ] || continue
      edate=$(sed -n 's/^> *Recorded on \([0-9-]*\).*/\1/p' "$e" 2>/dev/null | sed -n 1p)
      [ -n "$edate" ] || continue
      en_d=$(day_number "$edate")
      [ -n "$en_d" ] && [ $((TODAY_N - en_d)) -le 30 ] && [ $((TODAY_N - en_d)) -ge 0 ] || continue
      cause=$(awk '/^## /{on=($0 ~ /^## Cause/); next} on && NF {print; exit}' "$e" 2>/dev/null | sed -n 's/^`\([^`]*\)`.*/\1/p')
      en=$((en + 1)); esc="$esc${cause:-unknown}
"
    done
    if [ "$en" -eq 0 ]; then printf -- '- Escapes (30 days): none\n'
    else
      bycause=$(printf '%s' "$esc" | sort | uniq -c | awk '{c=$1; $1=""; sub(/^ /, ""); printf "%s%s %d", (n++ ? ", " : ""), $0, c}')
      printf -- '- Escapes (30 days): %s — %s\n' "$en" "$bycause"
    fi
    # 6. map age in commits
    map=""
    for c in PROJECT_MAP.md docs/PROJECT_MAP.md; do [ -f "$c" ] && { map=$c; break; }; done
    if [ -z "$map" ]; then printf -- '- Map: no map\n'
    else
      msha=$(grep -m1 -oE 'generated at commit[^0-9a-f]*[0-9a-f]{7,40}' "$map" 2>/dev/null | grep -oE '[0-9a-f]{7,40}$')
      if [ -n "$msha" ] && git cat-file -e "$msha^{commit}" 2>/dev/null; then
        printf -- '- Map: %s commits old\n' "$(git rev-list --count "$msha"..HEAD 2>/dev/null || echo '?')"
      else printf -- '- Map: %s, no readable stamp\n' "$map"; fi
    fi
    # 7. uncommitted files and unpushed commits
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      unc=$(git status --porcelain 2>/dev/null | grep -c .)
      if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
        unp="$(git rev-list --count '@{u}..HEAD' 2>/dev/null || echo '?') unpushed commit(s)"
      else unp="no upstream"; fi
      printf -- '- Git: %s uncommitted file(s), %s\n' "$unc" "$unp"
    else
      printf -- '- Git: not a git repository\n'
    fi
    printf '\n'
  )
}

count=$(grep -c . "$TMP")
{
  printf '# Shipkit digest — %s\n\n' "$TODAY"
  if [ "$RUN" -eq 1 ]; then ran="Fired-if commands were run (--run-checks)."
  else ran="Fired-if commands were not run (add --run-checks)."; fi
  printf '> Written %s from %s; %s project(s). %s\n\n' "$TODAY" "$REG" "$count" "$ran"
  TAB=$(printf '\t')
  while IFS="$TAB" read -r name path; do
    [ -n "$name" ] || continue
    write_project "$name" "$path"
  done < "$TMP"
} > "$OUT" || { echo "portfolio-digest: could not write $OUT" >&2; exit 1; }
echo "portfolio-digest: wrote $OUT ($count project(s))"
exit 0
