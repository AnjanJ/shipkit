#!/bin/sh
# Shipkit SessionStart hook. Plain stdout of a SessionStart hook is added to Claude's
# context (verified on Claude Code 2.1.270; capped at ~10,000 characters per hook
# command), so every line printed here is read by Claude at the start of the session.
# Silent on every failure mode; always exits 0 — a session-start hook must never break
# a session.
#
# Two jobs (the always-on rules are injected by sibling hook commands running
# scripts/inject-rule.sh, one per rule, to stay under the per-command cap):
#
#   1. PLUGIN ROOT. Print `shipkit: plugin root is <path>` and persist the path to
#      ~/.claude/shipkit/plugin-root. Plugin skills have no other way to learn where
#      the plugin lives: ${CLAUDE_PLUGIN_ROOT} is only set for hooks. /shipkit:setup
#      and /shipkit:map read it to find stacks/, rules/ and templates.
#
#   2. FRESHNESS NUDGES. One line when PROJECT_MAP.md is >= $SHIPKIT_MAP_STALE_COMMITS
#      commits behind HEAD (default 20) or a dependency manifest changed since it was
#      built; one line per accepted spec >= $SHIPKIT_SPEC_STALE_COMMITS (default 15)
#      commits stale, capped at 3. Silent when fresh.

# --- 1. Plugin root ----------------------------------------------------------------
ROOT="${CLAUDE_PLUGIN_ROOT:-}"
if [ -z "$ROOT" ]; then
  # Fallback: this script lives at <root>/scripts/session-start.sh
  ROOT=$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)
fi
if [ -n "$ROOT" ] && [ -d "$ROOT/rules" ]; then
  echo "shipkit: plugin root is $ROOT"
  if mkdir -p "$HOME/.claude/shipkit" 2>/dev/null; then
    printf '%s\n' "$ROOT" > "$HOME/.claude/shipkit/plugin-root" 2>/dev/null || true
  fi
fi

# --- 1b. Installed rules older than the plugin? -----------------------------------------
# /shipkit:setup (install-rules.sh) stamps .claude/rules/shipkit/.installed with the plugin
# version and a digest of the rules as shipped. If the plugin's rules have changed since, the
# project's copies are stale — nudge once. A directory without a stamp is a 2.8-era install.
if [ -n "$ROOT" ] && [ -d .claude/rules/shipkit ] && [ -f "$ROOT/scripts/lib-rules-sha.sh" ]; then
  if . "$ROOT/scripts/lib-rules-sha.sh" 2>/dev/null; then
    cur=$(rules_sha "$ROOT/rules" 2>/dev/null)
    ver=$(plugin_version "$ROOT")
    if [ -f .claude/rules/shipkit/.installed ]; then
      isha=$(sed -n 's/^sha=//p' .claude/rules/shipkit/.installed 2>/dev/null | head -1)
      iver=$(sed -n 's/^version=//p' .claude/rules/shipkit/.installed 2>/dev/null | head -1)
      if [ -n "$cur" ] && [ "$isha" != "$cur" ]; then
        echo "shipkit: installed rules are from shipkit ${iver:-?} and the plugin is ${ver:-?} — run /shipkit:setup to refresh .claude/rules/shipkit/."
      fi
    else
      echo "shipkit: installed rules have no version stamp (installed by shipkit ≤ 2.8) and the plugin is ${ver:-?} — run /shipkit:setup to refresh .claude/rules/shipkit/."
    fi
  fi
fi

# --- 2. Freshness nudges (git only) -------------------------------------------------
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

THRESHOLD="${SHIPKIT_MAP_STALE_COMMITS:-20}"

# Extract the SHA from a stamp line. Tolerates backticks or none, and short or full
# SHAs: `> Map generated at commit `abc1234` on main.` / `... commit abc1234 on main.`
stamp_sha() {
  # $1 = phrase ("generated at commit" / "accepted at commit"), $2 = file
  grep -m1 -oE "$1[^0-9a-f]*[0-9a-f]{7,40}" "$2" 2>/dev/null | grep -oE '[0-9a-f]{7,40}$'
}

# Map drift — skipped (not fatal) if there is no map, no stamp, or the stamp is
# unreachable; the spec-drift check below still runs.
MAP=""
for candidate in PROJECT_MAP.md docs/PROJECT_MAP.md; do
  if [ -f "$candidate" ]; then MAP="$candidate"; break; fi
done

if [ -n "$MAP" ]; then
  SHA=$(stamp_sha 'generated at commit' "$MAP")
  if [ -n "$SHA" ] && git cat-file -e "$SHA^{commit}" 2>/dev/null; then
    COUNT=$(git rev-list --count "$SHA"..HEAD 2>/dev/null)
    if [ -n "$COUNT" ] && [ "$COUNT" -gt 0 ]; then
      if [ "$COUNT" -ge "$THRESHOLD" ]; then
        echo "shipkit: $MAP is $COUNT commits behind HEAD — run /shipkit:map refresh so the elders stay accurate."
      else
        # Lockfiles count as much as manifests: a dependency bump often touches only the
        # lockfile (mix.lock, package-lock.json), which is precisely when the map's recorded
        # versions go stale.
        MANIFEST=$(git diff --name-only "$SHA"..HEAD 2>/dev/null \
          | grep -m1 -E '(^|/)(Gemfile|Gemfile\.lock|mix\.exs|mix\.lock|package\.json|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|bun\.lockb|go\.mod|go\.sum|pyproject\.toml|uv\.lock|poetry\.lock|Pipfile|Pipfile\.lock|importmap\.rb|requirements\.txt|Cargo\.toml|Cargo\.lock|composer\.json|composer\.lock|build\.gradle|pom\.xml)$')
        if [ -n "$MANIFEST" ]; then
          echo "shipkit: dependencies changed since $MAP was built ($MANIFEST) — consider /shipkit:map refresh."
        fi
      fi
    fi
  fi
fi

# Spec drift — an accepted spec whose code has moved on since acceptance. Each spec.md
# is stamped by /shipkit:spec: > Spec accepted at commit `abc1234` on main.
SPEC_THRESHOLD="${SHIPKIT_SPEC_STALE_COMMITS:-15}"
SPEC_CAP=3
if [ -d .shipkit/specs ]; then
  # Collect every stale spec first, then report. Reporting inside the scan (capped at 3, in
  # glob order) permanently starved specs 4..n: with N equally-stale specs the same first
  # three were printed every session and the rest were never seen. Sort most-stale-first,
  # then rotate the starting offset per run so the tail is reachable, and always print the
  # total so an omission is visible rather than silent.
  # Sort by staleness descending, then by path, so equal-staleness ordering is stable
  # rather than glob-dependent.
  STALE=$(for spec in .shipkit/specs/*/spec.md; do
    [ -f "$spec" ] || continue
    s_sha=$(stamp_sha 'accepted at commit' "$spec")
    [ -n "$s_sha" ] || continue
    git cat-file -e "$s_sha^{commit}" 2>/dev/null || continue
    s_count=$(git rev-list --count "$s_sha"..HEAD 2>/dev/null) || continue
    [ -n "$s_count" ] || continue
    [ "$s_count" -ge "$SPEC_THRESHOLD" ] && printf '%s\t%s\n' "$s_count" "$spec"
  done | sort -t"$(printf '\t')" -k1,1rn -k2,2)

  if [ -n "$STALE" ]; then
    total=$(printf '%s\n' "$STALE" | wc -l | tr -d ' ')
    # Line 1 (the MOST stale spec) is always shown — rotating the worst offender out of
    # view would trade one starvation bug for another. Only the remaining slots rotate,
    # over lines 2..total, so the tail is still reachable across sessions.
    show_line() {
      line=$(printf '%s\n' "$STALE" | sed -n "$1p")
      [ -n "$line" ] || return 0
      c=${line%%"$(printf '\t')"*}
      s=${line#*"$(printf '\t')"}
      [ -n "$s" ] && echo "shipkit: $s is $c commits behind HEAD — the code may have drifted from the spec."
    }
    # Index the sorted list in the PARENT shell: `… | while read` runs the loop in a
    # subshell, where the counter never escapes and `break` cannot stop the parent.
    show_line 1
    if [ "$total" -gt 1 ]; then
      rest=$(( total - 1 ))                      # rotatable lines: 2..total
      slots=$(( SPEC_CAP - 1 ))
      [ "$rest" -lt "$slots" ] && slots="$rest"
      if [ "$rest" -le "$slots" ]; then
        offset=0
      else
        # Rotate between sessions (stable within one) so lines 2..total all surface.
        offset=$(( $(date +%j 2>/dev/null || echo 0) % rest ))
      fi
      k=0
      while [ "$k" -lt "$slots" ]; do
        show_line $(( (offset + k) % rest + 2 ))
        k=$((k + 1))
      done
    fi
    if [ "$total" -gt "$SPEC_CAP" ]; then
      echo "shipkit: ($SPEC_CAP of $total stale specs shown — run /shipkit:spec to review, or set SHIPKIT_SPEC_STALE_COMMITS higher.)"
    fi
  fi
fi
exit 0
