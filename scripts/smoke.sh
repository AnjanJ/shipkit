#!/bin/sh
# Shipkit smoke test — verifies the platform behaviour this plugin depends on, for real.
#
# The 2.7.0 audit found that documented behaviour and actual behaviour disagree (plugin rules/
# and knowledge/ do not load; agents/ is scanned recursively; a SessionStart hook's context
# contribution is capped at ~10,000 chars per command). The lint checks our files; this script
# checks Claude Code. Run it before tagging a release, after the lint:
#
#     ./scripts/lint.sh && ./scripts/smoke.sh
#
# Needs: a logged-in `claude` CLI, git, python3 (only to generate padding). Uses --model haiku.
# Makes a scratch copy of this working tree under mktemp; never touches the repo or ~/.claude
# except that the session hook writes ~/.claude/shipkit/plugin-root (which it always does).
# Exit status: 0 if every check passes, 1 otherwise. Set SMOKE_KEEP=1 to keep the scratch dir.

ROOT=$(cd "$(dirname "$0")/.." && pwd)
# Since 3.0 the repo is a marketplace of plugins; the smoke test exercises the CORE plugin
# (it owns the hook, the rules, the stacks and the install scripts).
CORE="$ROOT/plugins/shipkit"
command -v claude >/dev/null 2>&1 || { echo "smoke: `claude` not on PATH" >&2; exit 1; }

WORK=$(mktemp -d) || exit 1
[ -n "$SMOKE_KEEP" ] || trap 'rm -rf "$WORK"' EXIT
COPY="$WORK/plugin"; PROJ="$WORK/proj"
mkdir -p "$COPY" "$PROJ"
# copy the working tree without .git (rsync if present, tar otherwise)
if command -v rsync >/dev/null 2>&1; then
  rsync -a --exclude .git "$CORE/" "$COPY/"
else
  (cd "$CORE" && tar cf - --exclude .git .) | (cd "$COPY" && tar xf -)
fi
(cd "$PROJ" && git init -q && git -c user.email=s@s -c user.name=smoke commit -q --allow-empty -m init)

fail=0
pass() { echo "PASS  $1"; }
failc() { echo "FAIL  $1 — $2"; fail=1; }
ask() {  # ask <plugin-dir> <prompt>  → last line of the model's reply, run inside $PROJ
  (cd "$PROJ" && claude --plugin-dir "$1" --model haiku -p "$2 Do not use tools." 2>/dev/null | tail -20)
}
CW_Q='Reply with ONLY every codeword of the form ZEBRA-<digits> that appears anywhere in your context, comma-separated, or exactly NONE.'

# 1. rules-inject: a codeword appended to a rule is visible in a fresh session
printf '\n\nSmoke codeword: ZEBRA-1001.\n' >> "$COPY/rules/decisions.md"
rm -rf "$PROJ/.claude"
out=$(ask "$COPY" "$CW_Q")
case "$out" in *ZEBRA-1001*) pass "rules-inject (always-on rule reaches a fresh session via the hook)";;
  *) failc "rules-inject" "codeword not seen: $out";; esac

# 2. rules-skip: with .claude/rules/shipkit present the hook does not inject
mkdir -p "$PROJ/.claude/rules/shipkit"
out=$(ask "$COPY" "$CW_Q")
case "$out" in *ZEBRA-1001*) failc "rules-skip" "hook injected although .claude/rules/shipkit exists";;
  *) pass "rules-skip (no double-inject when rules are installed as files)";; esac
rm -rf "$PROJ/.claude"

# 3. plugin-root: the root line is in context and names the scratch copy
out=$(ask "$COPY" 'If a line of the form "shipkit: plugin root is <path>" is in your context, reply with just the path; else NONE.')
case "$out" in *"$COPY"*) pass "plugin-root (hook publishes the plugin root)";;
  *) failc "plugin-root" "got: $out";; esac

# 4. agents: exactly the agents defined under agents/*.md, nothing else
expected=$(ls "$CORE"/agents/*.md | sed 's#.*/##; s/\.md$//' | sort | tr '\n' ' ')
out=$(ask "$COPY" 'List the exact names of every agent type available to you that starts with "shipkit:", one per line, nothing else.')
got=$(printf '%s\n' "$out" | grep -o 'shipkit:[a-z-]*' | sed 's/shipkit://' | sort -u | tr '\n' ' ')
if [ "$got" = "$expected" ]; then pass "agents (registered set = $expected)"; else failc "agents" "expected [$expected] got [$got]"; fi

# 5. kb-skills: the workflows plugin's knowledge base registers as a skill
out=$(ask "$ROOT/plugins/shipkit-workflows" 'List the exact names of every skill available to you whose name contains "standards", one per line, or NONE.')
case "$out" in *code-review-standards*) pass "kb-skills (knowledge base registered in shipkit-workflows)";;
  *) failc "kb-skills" "got: $out";; esac

# 5b. namespaces: the two plugins register under distinct prefixes, no collision.
# Ask about two SPECIFIC skills rather than asking for an enumeration — a small model
# listing "every skill" truncates unreliably and produced false failures here.
out=$(cd "$PROJ" && claude --plugin-dir "$COPY" --plugin-dir "$ROOT/plugins/shipkit-workflows" --model haiku -p 'Answer with exactly two words separated by a comma: whether a skill named "shipkit:map" is available (YES or NO), then whether a skill named "shipkit-workflows:tdd" is available (YES or NO). Do not use tools.' 2>/dev/null | tail -5)
case "$out" in
  *YES*YES*) pass "namespaces (both plugins register under distinct prefixes)";;
  *) failc "namespaces" "expected YES,YES — got: $out";;
esac

# 6. hook-cap: 9,500 chars of hook output is seen; 11,000 is not (informational if it now is)
mkhook() {  # mkhook <dir> <chars> <codeword>
  mkdir -p "$1/.claude-plugin" "$1/hooks" "$1/scripts"
  printf '{"name":"smoke%s","version":"0.0.1","description":"smoke"}\n' "$3" > "$1/.claude-plugin/plugin.json"
  printf '{"hooks":{"SessionStart":[{"matcher":"","hooks":[{"type":"command","command":"${CLAUDE_PLUGIN_ROOT}/scripts/h.sh","timeout":5}]}]}}\n' > "$1/hooks/hooks.json"
  python3 -c "import sys; n=int(sys.argv[1]); cw=sys.argv[2]; tail='codeword '+cw+' end.\n'; b=''; i=1
while len(b)+len(tail) < n: b += 'line %d: padding padding padding padding padding padding padding padding pad.\n' % i; i+=1
sys.stdout.write(b+tail)" "$2" "$3" > "$1/scripts/payload.txt"
  printf '#!/bin/sh\ncat "$(dirname "$0")/payload.txt"\n' > "$1/scripts/h.sh"; chmod +x "$1/scripts/h.sh"
}
mkhook "$WORK/cap-ok" 9500 ZEBRA-9500; mkhook "$WORK/cap-over" 11000 ZEBRA-11000
out=$(ask "$WORK/cap-ok" "$CW_Q")
case "$out" in *ZEBRA-9500*) pass "hook-cap (9.5K of hook output still reaches context)";;
  *) failc "hook-cap" "9.5K hook output no longer reaches context — the per-hook cap shrank; split the rules further";; esac
out=$(ask "$WORK/cap-over" "$CW_Q")
case "$out" in *ZEBRA-11000*) echo "INFO  hook-cap: 11K of hook output now reaches context — the cap was raised; inject-rule.sh could be simplified";;
  *) pass "hook-cap (11K is still cut, as assumed)";; esac

# 7. install-scripts: deterministic installs produce the expected tree with no placeholders
IP="$WORK/install-proj"; mkdir -p "$IP"; printf '# demo\n' > "$IP/CLAUDE.md"
if sh "$COPY/scripts/install-rules.sh" "$COPY" "$IP" >/dev/null \
   && sh "$COPY/scripts/install-stack.sh" "$COPY" rails "$IP" TEST_COMMAND="bundle exec rspec" TEST_FRAMEWORK=RSpec DATABASE=PostgreSQL RAILS_ARCHITECTURE=MVC API_MODE=no FRONTEND=Hotwire >/dev/null; then
  nrules=$(ls "$IP"/.claude/rules/shipkit/*.md | wc -l | tr -d ' ')
  left=$(grep -rl '{{[A-Z_]*}}' "$IP/CLAUDE.md" "$IP/.claude" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$nrules" -eq "$(ls "$CORE"/rules/*.md | wc -l | tr -d ' ')" ] && [ -f "$IP/.claude/rules/shipkit/.installed" ] \
     && [ -f "$IP/.claude/rules/shipkit/rails/rails.md" ] && [ -f "$IP/.claude/skills/new-feature/SKILL.md" ] \
     && grep -q 'bundle exec rspec' "$IP/.claude/skills/new-feature/SKILL.md" && [ "$left" -eq 0 ] \
     && grep -q 'shipkit:stack:rails' "$IP/CLAUDE.md"; then
    pass "install-scripts ($nrules rules, rails stack, stamp written, 0 placeholders)"
  else
    failc "install-scripts" "tree mismatch (rules=$nrules leftovers=$left)"
  fi
  # a missing key must fail loudly — and leave no trace (no half-appended CLAUDE.md section)
  if sh "$COPY/scripts/install-stack.sh" "$COPY" python "$IP" TEST_COMMAND=pytest >/dev/null 2>&1; then
    failc "install-scripts" "install-stack.sh succeeded with placeholders uncovered"
  elif grep -q 'shipkit:stack:python' "$IP/CLAUDE.md" || [ -d "$IP/.claude/rules/shipkit/python" ] \
       || grep -rq '{{[A-Z_]*}}' "$IP/CLAUDE.md" "$IP/.claude" 2>/dev/null; then
    failc "install-scripts" "a failed install-stack.sh run left files or placeholders behind"
  else pass "install-scripts (uncovered placeholder → non-zero exit, nothing written)"; fi
else
  failc "install-scripts" "install-rules.sh / install-stack.sh returned non-zero"
fi

# 8. stale-nudge: the hook notices installed rules older than the plugin (no claude needed)
sed 's/^sha=.*/sha=deadbeef/' "$IP/.claude/rules/shipkit/.installed" > "$IP/.installed.tmp" && mv "$IP/.installed.tmp" "$IP/.claude/rules/shipkit/.installed"
out=$(cd "$IP" && git init -q 2>/dev/null; CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh")
case "$out" in *"installed rules are from"*) pass "stale-nudge (hook flags outdated installed rules)";;
  *) failc "stale-nudge" "no nudge printed: $out";; esac
rm -f "$IP/.claude/rules/shipkit/.installed"
out=$(cd "$IP" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh")
case "$out" in *"no version stamp"*) pass "stale-nudge (unstamped 2.8-era install is flagged)";;
  *) failc "stale-nudge" "unstamped install not flagged: $out";; esac

echo
if [ "$fail" -eq 0 ]; then echo "smoke: all checks passed"; else echo "smoke: FAILURES above"; fi
exit $fail
