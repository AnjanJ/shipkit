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

MAP=""
for candidate in PROJECT_MAP.md docs/PROJECT_MAP.md; do
  if [ -f "$candidate" ]; then MAP="$candidate"; break; fi
done
[ -n "$MAP" ] || exit 0

# Stamp written by the archivist: > Map generated at commit `abc1234` on main.
SHA=$(grep -m1 -oE 'generated at commit .[0-9a-f]{7,40}' "$MAP" 2>/dev/null | grep -oE '[0-9a-f]{7,40}')
[ -n "$SHA" ] || exit 0
git cat-file -e "$SHA^{commit}" 2>/dev/null || exit 0

COUNT=$(git rev-list --count "$SHA"..HEAD 2>/dev/null) || exit 0
[ -n "$COUNT" ] || exit 0
[ "$COUNT" -gt 0 ] || exit 0

if [ "$COUNT" -ge "$THRESHOLD" ]; then
  echo "shipkit: $MAP is $COUNT commits behind HEAD — run /shipkit:map refresh so the elders stay accurate."
  exit 0
fi

MANIFEST=$(git diff --name-only "$SHA"..HEAD 2>/dev/null \
  | grep -m1 -E '(^|/)(Gemfile|Gemfile\.lock|mix\.exs|package\.json|go\.mod|pyproject\.toml|requirements\.txt|Cargo\.toml|composer\.json|build\.gradle|pom\.xml)$')
if [ -n "$MANIFEST" ]; then
  echo "shipkit: dependencies changed since $MAP was built ($MANIFEST) — consider /shipkit:map refresh."
fi
exit 0
