#!/bin/sh
# Shipkit SessionStart hook: remind when PROJECT_MAP.md has drifted from HEAD.
#
# A stale map makes grandfather/eve confidently wrong; this closes the loop the
# manual `/shipkit:map refresh` workflow leaves open. Prints ONE line when the
# map is >= $SHIPKIT_MAP_STALE_COMMITS commits behind (default 20), or when a
# dependency manifest changed since the map was built. Silent otherwise, and
# silent on every failure mode (no repo, no map, no stamp) — a freshness nudge
# must never break a session. Always exits 0.

THRESHOLD="${SHIPKIT_MAP_STALE_COMMITS:-20}"

git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# --- Map drift ------------------------------------------------------------------------
# Skipped (not fatal) if there is no map, no stamp, or the stamp is unreachable — the
# spec-drift check below still runs. A missing map is not an error, just nothing to nudge.
MAP=""
for candidate in PROJECT_MAP.md docs/PROJECT_MAP.md; do
  if [ -f "$candidate" ]; then MAP="$candidate"; break; fi
done

if [ -n "$MAP" ]; then
  # Stamp written by the archivist: > Map generated at commit `abc1234` on main.
  SHA=$(grep -m1 -oE 'generated at commit .[0-9a-f]{7,40}' "$MAP" 2>/dev/null | grep -oE '[0-9a-f]{7,40}')
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

# --- Spec drift: an accepted spec whose code has moved on since acceptance ------------
# Each spec.md is stamped by /shipkit:spec: > Spec accepted at commit `abc1234` on main.
# If HEAD is >= $SHIPKIT_SPEC_STALE_COMMITS (default 15) commits past a spec's accepted
# SHA, the code likely drifted from the spec — nudge once per drifted spec (cap 3 lines).
# Same contract as above: silent on every failure, never fatal.
SPEC_THRESHOLD="${SHIPKIT_SPEC_STALE_COMMITS:-15}"
if [ -d .shipkit/specs ]; then
  printed=0
  for spec in .shipkit/specs/*/spec.md; do
    [ -f "$spec" ] || continue
    [ "$printed" -ge 3 ] && break
    s_sha=$(grep -m1 -oE 'accepted at commit .[0-9a-f]{7,40}' "$spec" 2>/dev/null | grep -oE '[0-9a-f]{7,40}')
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
