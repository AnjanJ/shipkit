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

# `inject-rule.sh --eval-rule`: the rule a shipkit EVAL CASE is measuring. `claude plugin eval`
# loads nothing from the workspace's .claude/ or CLAUDE.md (it sets
# CLAUDE_CODE_DISABLE_CLAUDE_MDS=1; documented under "How runs are isolated"), so a rule a
# scaffold installed would never reach the model. The scaffold (evals/lib/with-rule.sh) leaves
# a marker naming the file; this prints it — only under the eval tool's own
# CLAUDE_CODE_EVAL_CONFINED=1, so a real project never takes this branch, marker or not.
if [ "$NAME" = "--eval-rule" ]; then
  [ "${CLAUDE_CODE_EVAL_CONFINED:-}" = "1" ] || exit 0
  MARK=".claude/rules/shipkit/.eval-rule"
  [ -f "$MARK" ] || exit 0
  REL=$(head -1 "$MARK" 2>/dev/null)
  case "$REL" in .claude/rules/shipkit/*.md) ;; *) exit 0 ;; esac
  [ -f "$REL" ] || exit 0
  echo "## Shipkit rule in force for this session: $REL"
  echo "(Installed by this project's setup. Treat it as in force for every file its paths: line"
  echo "names, or for every file if it has no paths: line.)"
  echo ""
  cat "$REL" 2>/dev/null || true
  exit 0
fi

# Skip injection only when THIS rule is actually installed as a file. Testing the directory
# alone (what 3.0 did) meant an interrupted install or a deleted rule suppressed injection
# too: the rule was then absent from disk AND from context, with nothing to notice it. The
# fallback must key on the specific file it is standing in for. See
# .shipkit/specs/install-lifecycle/design.md DR-3.
[ -f ".claude/rules/shipkit/$NAME.md" ] && exit 0

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
