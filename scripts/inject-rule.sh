#!/bin/sh
# Shipkit SessionStart hook: inject ONE always-on rule into the session's context.
#
#   inject-rule.sh <rule-name>      # e.g. inject-rule.sh shipkit  → prints rules/shipkit.md
#
# Why one rule per hook command: Claude Code adds a SessionStart hook's plain stdout to
# Claude's context, but only up to ~10,000 characters per hook command — anything larger is
# persisted to a file with a 2 KB preview, which is useless as a rule. Each hook command is
# capped separately, so hooks.json lists this script once per always-on rule (shipkit,
# spec-driven, decisions), each comfortably under the cap. The lint enforces the size.
#
# Skipped when the project has the rules installed as files under .claude/rules/shipkit/
# (what /shipkit:setup does) — those load from disk and must not be injected twice.
# Silent on every failure; always exits 0.

NAME="$1"
[ -n "$NAME" ] || exit 0
[ -d .claude/rules/shipkit ] && exit 0

ROOT="${CLAUDE_PLUGIN_ROOT:-}"
if [ -z "$ROOT" ]; then
  ROOT=$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)
fi
FILE="$ROOT/rules/$NAME.md"
[ -f "$FILE" ] || exit 0

echo "## Shipkit always-on rule: $NAME"
echo "(Injected by the shipkit session hook because this project has no .claude/rules/shipkit/."
echo "Run /shipkit:setup to install all shipkit rules as files, including the path-scoped ones"
echo "the hook cannot inject. Treat the rule below as always-on for this session.)"
echo ""
cat "$FILE" 2>/dev/null || true
exit 0
