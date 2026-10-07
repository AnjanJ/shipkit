#!/bin/sh
# Shipkit evals: put ONE rule under test into an eval run's workspace.
#
#   with-rule.sh <rule> [--repo <path>]     run from the workspace, after the fixture is in place
#
# <rule> is a file name without .md: a core rule (rules/<rule>.md → .claude/rules/shipkit/<rule>.md)
# or a stack rule (stacks/<stack>/.claude/rules/<rule>.md → .claude/rules/shipkit/<stack>/<rule>.md).
# The file lands exactly as install-rules.sh / install-stack.sh would write it (no rule file
# carries a placeholder to substitute), the installation manifest records it with the plugin
# version, and the
# marker .claude/rules/shipkit/.eval-rule names it for the session hook.
#
# Why a marker and a hook: the eval sandbox sets CLAUDE_CODE_DISABLE_CLAUDE_MDS=1 and loads no
# file under the workspace's .claude/ and no CLAUDE.md (nonce-tested 2026-10-07; documented
# under "How runs are isolated"). The one thing that reaches the model is the plugin's own
# SessionStart hook, so `inject-rule.sh --eval-rule` prints the marked file — only under the
# eval tool's CLAUDE_CODE_EVAL_CONFINED=1. The measurement is of the rule's text, delivered
# always-on, not of path-scoped loading. Only this one file is installed: writing the three
# always-on rules to disk would stop the hook injecting them, and nothing else on disk loads.
#
# Arms (read when this script is run by hand; the eval tool forwards no environment to a
# scaffold, so an eval ARM is a scratch copy of the plugin with the default below edited):
#   SHIPKIT_EVAL_NO_RULE=1        install nothing — the "without" arm
#   SHIPKIT_EVAL_RULE_REF=<ref>   install the file's text at that git ref of this repository
#                                 (git -C <repo> show <ref>:plugins/shipkit/<path>) — the
#                                 pre-trim arm uses v3.7.0. <repo> defaults to the plugin
#                                 root's grandparent; pass --repo when the plugin is a copy.
: "${SHIPKIT_EVAL_NO_RULE:=}"
: "${SHIPKIT_EVAL_RULE_REF:=}"

die() { echo "with-rule: $*" >&2; exit 1; }
NAME="$1"; [ -n "$NAME" ] || die "usage: with-rule.sh <rule> [--repo <path>]"
shift
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
REPO="$ROOT/../.."
[ "$1" = "--repo" ] && { REPO="$2"; shift 2; }

[ "$SHIPKIT_EVAL_NO_RULE" = "1" ] && exit 0

if [ -f "$ROOT/rules/$NAME.md" ]; then
  SRC="rules/$NAME.md"; REL=".claude/rules/shipkit/$NAME.md"; STACK=""
else
  for d in "$ROOT"/stacks/*/; do
    [ -f "$d.claude/rules/$NAME.md" ] || continue
    STACK=$(basename "$d"); SRC="stacks/$STACK/.claude/rules/$NAME.md"
    REL=".claude/rules/shipkit/$STACK/$NAME.md"
  done
  [ -n "${SRC:-}" ] || die "no rule named '$NAME' under $ROOT/rules or $ROOT/stacks/*/.claude/rules"
fi

mkdir -p "$(dirname "$REL")" || die "cannot create $(dirname "$REL")"
if [ -n "$SHIPKIT_EVAL_RULE_REF" ]; then
  git -C "$REPO" show "$SHIPKIT_EVAL_RULE_REF:plugins/shipkit/$SRC" > "$REL" \
    || die "git show $SHIPKIT_EVAL_RULE_REF:plugins/shipkit/$SRC failed in $REPO"
else
  cp "$ROOT/$SRC" "$REL" || die "cannot copy $SRC"
fi

. "$ROOT/scripts/lib-rules-sha.sh" || die "cannot load lib-rules-sha.sh"
. "$ROOT/scripts/lib-manifest.sh"  || die "cannot load lib-manifest.sh"
manifest_begin || die "cannot start the manifest"
manifest_add . "$REL" || die "cannot record $REL"
manifest_commit . "$(plugin_version "$ROOT")" "$STACK" || die "cannot write the manifest"
printf '%s\n' "$REL" > .claude/rules/shipkit/.eval-rule
echo "with-rule: installed $REL${SHIPKIT_EVAL_RULE_REF:+ (text at $SHIPKIT_EVAL_RULE_REF)}"
