#!/bin/sh
# Shipkit context cost: what a session in ONE project pays for shipkit before a word is typed.
#
#   scripts/context-cost.sh <project-dir>        # rows on stdout; exit 0
#
# Rows (name, bytes, then a note), tab-separated, one per line:
#   hook              the session hook's output in that directory: session-start.sh plus the
#                     four inject-rule.sh commands hooks.json lists, run for real with
#                     CLAUDE_PLUGIN_ROOT, under a scratch HOME so nothing in ~/.claude moves
#   skills-core       the `description:` lines of plugins/shipkit's skills (every session)
#   skills-workflows  the same for plugins/shipkit-workflows (sibling of the core root)
#   agents            the `description:` lines of both plugins' agents
#   overlay-skills    the skills setup installed into <project>/.claude/skills/ (from the
#                     manifest .claude/rules/shipkit/.installed), whole files — listed every
#                     session on that project
#   overlay-appends   the stack sections between <!-- shipkit:stack:X --> markers in the
#                     project's CLAUDE.md (loaded every session on that project)
#   rules-always-on   rules/shipkit.md + spec-driven.md + decisions.md as shipped
#
# A description's bytes are the text after `description:` plus its newline, as the listing
# carries it. No model call. The plugin root is CLAUDE_PLUGIN_ROOT or this repository's
# plugins/shipkit. POSIX sh + awk. The thinning plan's rule 20 instrument
# (docs/plans/thinning-sprint-plan.md §0; docs/design/context-cost.md holds the baseline).
# Spec: .shipkit/specs/always-on/ (REQ-1, REQ-2).

set -u
PROJ="${1:-}"
[ -n "$PROJ" ] && [ -d "$PROJ" ] || { echo "usage: context-cost.sh <project-dir>" >&2; exit 64; }
PROJ=$(cd "$PROJ" && pwd)
ROOT="${CLAUDE_PLUGIN_ROOT:-}"
[ -n "$ROOT" ] || ROOT=$(cd "$(dirname "$0")/../plugins/shipkit" 2>/dev/null && pwd)
[ -f "$ROOT/.claude-plugin/plugin.json" ] || { echo "context-cost: no plugin at $ROOT" >&2; exit 1; }
WF="$(dirname "$ROOT")/shipkit-workflows"
VER=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$ROOT/.claude-plugin/plugin.json" | head -1)

bytes() { cat "$@" 2>/dev/null | wc -c | tr -d ' '; }
desc_bytes() {  # desc_bytes <file>...  → bytes of each file's first frontmatter description line
  for f in "$@"; do
    [ -f "$f" ] && awk 'NR == 1 && $0 != "---" { exit } NR > 1 && /^---/ { exit }
      /^description:/ { sub(/^description:[ \t]*/, ""); print; exit }' "$f"
  done | wc -c | tr -d ' '
}
count() { n=0; for f in "$@"; do [ -f "$f" ] && n=$((n + 1)); done; echo "$n"; }

# hook: the real scripts, in the project, under a scratch HOME (session-start.sh writes
# plugin-root.dev there, never in the owner's)
SCR=$(mktemp -d 2>/dev/null || mktemp -d -t shipkit-cc)
trap 'rm -rf "$SCR"' EXIT
mkdir -p "$SCR/home/.claude"
hook_out=$(cd "$PROJ" && HOME="$SCR/home" CLAUDE_CONFIG_DIR="$SCR/home/.claude" CLAUDE_PLUGIN_ROOT="$ROOT" sh -c '
  sh "$CLAUDE_PLUGIN_ROOT/scripts/session-start.sh" </dev/null
  for r in shipkit spec-driven decisions --eval-rule; do sh "$CLAUDE_PLUGIN_ROOT/scripts/inject-rule.sh" "$r" </dev/null; done' 2>/dev/null)
hook_b=$(printf '%s\n' "$hook_out" | wc -c | tr -d ' ')
hook_rules=$(printf '%s\n' "$hook_out" | grep -c '^## Shipkit always-on rule:')

core_n=$(count "$ROOT"/skills/*/SKILL.md); core_b=$(desc_bytes "$ROOT"/skills/*/SKILL.md)
if [ -d "$WF/skills" ]; then wf_n=$(count "$WF"/skills/*/SKILL.md); wf_b=$(desc_bytes "$WF"/skills/*/SKILL.md); wf_note="plugins/shipkit-workflows"
else wf_n=0; wf_b=0; wf_note="no shipkit-workflows beside $ROOT"; fi
ag_n=$(count "$ROOT"/agents/*.md "$WF"/agents/*.md); ag_b=$(desc_bytes "$ROOT"/agents/*.md "$WF"/agents/*.md)

# overlay skills: the manifest names every file setup installed; those under .claude/skills/
ov_n=0; ov_b=0; MAN="$PROJ/.claude/rules/shipkit/.installed"
if [ -f "$MAN" ]; then
  ov_files=$(awk -F'\t' '$2 ~ /^\.claude\/skills\// { print $2 }' "$MAN")
  for f in $ov_files; do
    [ -f "$PROJ/$f" ] || continue
    ov_b=$((ov_b + $(bytes "$PROJ/$f")))
    case "$f" in */SKILL.md) ov_n=$((ov_n + 1)) ;; esac
  done
fi
# overlay appends: the stack sections in CLAUDE.md, markers included
ap_n=0; ap_b=0
if [ -f "$PROJ/CLAUDE.md" ]; then
  ap_n=$(grep -c '^<!-- shipkit:stack:[a-z-]* -->' "$PROJ/CLAUDE.md")
  ap_b=$(awk '/^<!-- shipkit:stack:[a-z-]+ -->/ { on = 1 } on { print } /^<!-- \/shipkit:stack:[a-z-]+ -->/ { on = 0 }' "$PROJ/CLAUDE.md" | wc -c | tr -d ' ')
fi
rules_b=$(bytes "$ROOT/rules/shipkit.md" "$ROOT/rules/spec-driven.md" "$ROOT/rules/decisions.md")

printf 'context-cost\t%s\tproject %s; plugin %s (%s)\n' "$(date +%Y-%m-%d)" "$PROJ" "$ROOT" "${VER:-?}"
printf 'hook\t%s\tsession hook output here: %s rule(s) injected\n' "$hook_b" "$hook_rules"
printf 'skills-core\t%s\t%s skill description(s), plugins/shipkit\n' "$core_b" "$core_n"
printf 'skills-workflows\t%s\t%s skill description(s), %s\n' "$wf_b" "$wf_n" "$wf_note"
printf 'agents\t%s\t%s agent description(s), both plugins\n' "$ag_b" "$ag_n"
printf 'overlay-skills\t%s\t%s skill(s) setup installed under .claude/skills/ (whole files)\n' "$ov_b" "$ov_n"
printf 'overlay-appends\t%s\t%s stack section(s) in CLAUDE.md\n' "$ap_b" "$ap_n"
printf 'rules-always-on\t%s\tshipkit.md + spec-driven.md + decisions.md as shipped\n' "$rules_b"
exit 0
