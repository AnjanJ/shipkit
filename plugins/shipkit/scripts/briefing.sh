#!/bin/sh
# Shipkit briefing: a few lines at session start saying where things stand. Called last by
# session-start.sh, so every line reaches Claude's context. Run from the project root.
#
# What it prints, at most eight lines and 800 bytes, each starting "shipkit: ":
#   <slug>: N of M tasks done, next T4 — <title>     one per open spec, at most three
#   spec-check: N gap(s) — run spec-check.sh         only when spec-check.sh finds a gap
#   top goal: <first goal in .shipkit/product.md>    only when the product file exists
#   last handoff (<date>, N commits ago): <the "Next step" line of .shipkit/state.md>
#                                                     only when a handoff exists
#   digest: newest is N days old — run portfolio-digest.sh
#                                                     only when $SHIPKIT_HOME/digests/ holds a
#                                                     digest and the newest is over seven days old
#
# Prints nothing when .shipkit/ does not exist. Never exits non-zero and never prints to
# stderr: a session-start hook must not break a session, and a tasks.md it cannot read is a
# line left out, not an error. No model, no network. POSIX sh + awk + git.
# Spec: .shipkit/specs/briefing-and-handoff/ (the digest line: decisions-and-digest/).

[ -d .shipkit ] || exit 0
HERE=$(cd "$(dirname "$0")" 2>/dev/null && pwd) || exit 0
SHIPKIT_HOME=${SHIPKIT_HOME:-$HOME/.claude/shipkit}
MAXLINES=8
MAXBYTES=800

{
  # 1. open specs, at most three, in name order
  n=0
  for spec in .shipkit/specs/*/spec.md; do
    [ -f "$spec" ] || continue
    [ "$n" -lt 3 ] || break
    case "$(sed -n 's/^> *Status: *\([a-z]*\).*/\1/p' "$spec" 2>/dev/null | sed -n 1p)" in
      shipped|dropped|draft) continue ;;
    esac
    dir=${spec%/spec.md}; slug=${dir##*/}
    [ -f "$dir/tasks.md" ] || continue
    line=$(awk -v slug="$slug" '
      /^- \[[xX]\] \*\*[A-Za-z0-9_-]+\*\*/ { done++; total++; next }
      /^- \[ \] \*\*[A-Za-z0-9_-]+\*\*/ {
        total++
        if (next_id == "") {
          match($0, /\*\*[A-Za-z0-9_-]+\*\*/); next_id = substr($0, RSTART + 2, RLENGTH - 4)
          t = substr($0, RSTART + RLENGTH); p = index(t, "→"); if (p) t = substr(t, 1, p - 1)
          sub(/^[ \t]+/, "", t); sub(/[ \t]+$/, "", t); next_title = t
        }
      }
      END {
        if (total == 0) exit
        if (next_id == "") printf "shipkit: %s: %d of %d tasks done, all ticked\n", slug, done, total
        else printf "shipkit: %s: %d of %d tasks done, next %s — %s\n", slug, done, total, next_id, next_title
      }' "$dir/tasks.md" 2>/dev/null)
    [ -n "$line" ] || continue
    printf '%s\n' "$line"
    n=$((n + 1))
  done

  # 2. gaps, from spec-check.sh's last line ("spec-check: N spec(s) checked, G gap(s)")
  if [ -f "$HERE/spec-check.sh" ]; then
    gaps=$(sh "$HERE/spec-check.sh" . 2>/dev/null | sed -n 's/^spec-check: .* checked, \([0-9]*\) gap(s)$/\1/p' | sed -n 1p)
    case "$gaps" in
      ''|0) ;;
      *) echo "shipkit: spec-check: $gaps gap(s) — run spec-check.sh" ;;
    esac
  fi

  # 3. the top goal
  if [ -f .shipkit/product.md ]; then
    goal=$(awk '/^## /{on=($0 ~ /^## Goals this quarter/); next} on && /^(- |[0-9]+\. )/{sub(/^(- |[0-9]+\. )/, ""); print; exit}' .shipkit/product.md 2>/dev/null)
    [ -n "$goal" ] && echo "shipkit: top goal: $goal"
  fi

  # 4. the last handoff
  if [ -f .shipkit/state.md ]; then
    hdate=$(sed -n 's/^> *Written \([0-9-]*\) at commit .*/\1/p' .shipkit/state.md 2>/dev/null | sed -n 1p)
    hsha=$(sed -n 's/^> *Written [0-9-]* at commit `\{0,1\}\([0-9a-f]*\)`\{0,1\}.*/\1/p' .shipkit/state.md 2>/dev/null | sed -n 1p)
    hnext=$(awk '/^## /{on=($0 ~ /^## Next step/); next} on && NF {print; exit}' .shipkit/state.md 2>/dev/null)
    if [ -n "$hnext" ]; then
      ago=""
      if [ -n "$hsha" ] && git cat-file -e "$hsha^{commit}" 2>/dev/null; then
        c=$(git rev-list --count "$hsha"..HEAD 2>/dev/null) && ago=", $c commits ago"
      fi
      echo "shipkit: last handoff (${hdate:-undated}$ago): $hnext"
    fi
  fi

  # 5. the digest, when there is one and it is old. Age comes from the newest file's name,
  # <YYYY-MM-DD>.md, by days-from-civil arithmetic: no date(1) flags, which differ by platform.
  newest=$(ls "$SHIPKIT_HOME/digests"/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md 2>/dev/null | sed 's|.*/||; s|\.md$||' | sort | tail -1)
  if [ -n "$newest" ]; then
    age=$(printf '%s\n%s\n' "$newest" "$(date +%Y-%m-%d)" | awk -F- '
      function dn(y, m, d,   era, yoe, doy, doe) {
        if (m <= 2) { y--; m += 12 }
        era = int(y / 400); yoe = y - era * 400
        doy = int((153 * (m - 3) + 2) / 5) + d - 1
        doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
        return era * 146097 + doe - 719468 }
      NF == 3 { n[NR] = dn($1 + 0, $2 + 0, $3 + 0) } END { if (NR == 2) print n[2] - n[1] }')
    case "$age" in
      ''|*[!0-9]*) ;;
      *) [ "$age" -gt 7 ] && echo "shipkit: digest: newest is $age days old — run portfolio-digest.sh (or /shipkit:ask --all digest)" ;;
    esac
  fi
} 2>/dev/null | awk -v maxl="$MAXLINES" -v maxb="$MAXBYTES" '
  # Keep every line short (this is read in every session) and stop at the limits.
  { if (length($0) > 160) $0 = substr($0, 1, 157) "…"
    if (NR > maxl || bytes + length($0) + 1 > maxb) exit
    bytes += length($0) + 1; print }' 2>/dev/null
exit 0
