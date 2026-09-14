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
        MANIFEST=$(git diff --name-only "$SHA"..HEAD 2>/dev/null \
          | grep -m1 -E '(^|/)(Gemfile|Gemfile\.lock|mix\.exs|package\.json|go\.mod|pyproject\.toml|requirements\.txt|Cargo\.toml|composer\.json|build\.gradle|pom\.xml)$')
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
if [ -d .shipkit/specs ]; then
  printed=0
  for spec in .shipkit/specs/*/spec.md; do
    [ -f "$spec" ] || continue
    [ "$printed" -ge 3 ] && break
    s_sha=$(stamp_sha 'accepted at commit' "$spec")
    [ -n "$s_sha" ] || continue
    git cat-file -e "$s_sha^{commit}" 2>/dev/null || continue
    s_count=$(git rev-list --count "$s_sha"..HEAD 2>/dev/null) || continue
    [ -n "$s_count" ] || continue
    if [ "$s_count" -ge "$SPEC_THRESHOLD" ]; then
      echo "shipkit: $spec is $s_count commits behind HEAD — the code may have drifted from the spec."
      printed=$((printed + 1))
    fi
  done
fi
exit 0
