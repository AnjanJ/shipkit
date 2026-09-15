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
# The manifest records the INSTALLED file's digest, so drift is simulated by editing an
# installed rule — not by tampering with a `sha=` line, which no longer exists (the pre-3.1
# stamp had one; a v1 manifest does not, so that tamper silently asserted nothing).
(cd "$IP" && git init -q 2>/dev/null)
printf '\ndrift\n' >> "$IP/.claude/rules/shipkit/decisions.md"
out=$(cd "$IP" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh")
case "$out" in *"run /shipkit:setup to refresh"*) pass "stale-nudge (hook flags a drifted installed rule)";;
  *) failc "stale-nudge" "no nudge printed: $out";; esac
sh "$COPY/scripts/install-rules.sh" "$COPY" "$IP" >/dev/null   # back to a clean install

# 8b. incomplete-install: a deleted rule is reported BY NAME and re-injected (review finding 2).
# In 3.0 this was the silent failure: absent from disk AND suppressed from context.
rm -f "$IP/.claude/rules/shipkit/shipkit.md"
out=$(cd "$IP" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh")
case "$out" in *"missing .claude/rules/shipkit/shipkit.md"*) pass "incomplete-install (missing rule named)";;
  *) failc "incomplete-install" "missing rule not reported: $out";; esac
n=$(cd "$IP" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/inject-rule.sh" shipkit | wc -c | tr -d ' ')
if [ "$n" -gt 100 ]; then pass "incomplete-install (deleted rule falls back to injection, $n bytes)"
else failc "incomplete-install" "deleted rule was not re-injected ($n bytes)"; fi
n=$(cd "$IP" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/inject-rule.sh" decisions | wc -c | tr -d ' ')
if [ "$n" -eq 0 ]; then pass "incomplete-install (an installed rule is still not double-injected)"
else failc "incomplete-install" "double-inject of an installed rule ($n bytes)"; fi
sh "$COPY/scripts/install-rules.sh" "$COPY" "$IP" >/dev/null

# 8c. reconciliation: a rule upstream no longer ships is removed on reinstall (finding 3).
cp "$COPY/rules/monorepo.md" "$WORK/monorepo.md.bak"
rm -f "$COPY/rules/monorepo.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$IP" >/dev/null
if [ -f "$IP/.claude/rules/shipkit/monorepo.md" ]; then
  failc "reconcile" "an obsolete installed rule survived the reinstall"
else pass "reconcile (rule dropped upstream is removed from the project)"; fi
cp "$WORK/monorepo.md.bak" "$COPY/rules/monorepo.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$IP" >/dev/null

# 8d. legacy stamp owns nothing: a pre-3.1 install must never trigger a deletion (DR-2).
printf 'custom\n' > "$IP/.claude/rules/shipkit/hand-written.md"
printf 'version=3.0.0\nsha=deadbeef\n' > "$IP/.claude/rules/shipkit/.installed"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$IP" >/dev/null
if [ -f "$IP/.claude/rules/shipkit/hand-written.md" ]; then
  pass "legacy-stamp (upgrading a pre-3.1 install deletes nothing)"
else failc "legacy-stamp" "upgrading a legacy stamp deleted a file shipkit never owned"; fi
rm -f "$IP/.claude/rules/shipkit/hand-written.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$IP" >/dev/null

# 8e. unstamped 2.8-era install is still flagged
rm -f "$IP/.claude/rules/shipkit/.installed"
out=$(cd "$IP" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh")
case "$out" in *"no version stamp"*) pass "stale-nudge (unstamped 2.8-era install is flagged)";;
  *) failc "stale-nudge" "unstamped install not flagged: $out";; esac
sh "$COPY/scripts/install-rules.sh" "$COPY" "$IP" >/dev/null

# 9. CLAUDE.md stack section refreshes in place, preserving content outside it (finding 3a).
PY="$WORK/py-proj"; mkdir -p "$PY"
printf '# demo\n\nPROSE-BEFORE\n' > "$PY/CLAUDE.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$PY" >/dev/null
pyargs="API_STYLE=REST ASYNC_MODE=no ORM=SQLAlchemy PYTHON_FRAMEWORK=FastAPI TEST_FRAMEWORK=pytest"
# shellcheck disable=SC2086
sh "$COPY/scripts/install-stack.sh" "$COPY" python "$PY" TEST_COMMAND=pytest $pyargs >/dev/null 2>&1
printf '\nPROSE-AFTER\n' >> "$PY/CLAUDE.md"
# shellcheck disable=SC2086
sh "$COPY/scripts/install-stack.sh" "$COPY" python "$PY" TEST_COMMAND="uv run pytest" $pyargs >/dev/null 2>&1
# NOTE: `x=$(grep -c … || echo 0)` yields "0\n0" when grep matches nothing — grep -c already
# prints 0 before the fallback fires — and the arithmetic test then fails on a two-line value.
# Count with a plain grep -c and normalise a missing file to 0 separately.
count() {
  # `grep -c` prints 0 AND exits 1 when there is no match, so `grep -c … || echo 0` emits
  # "0\n0" and every arithmetic test on it dies. Keep the fallback on the missing-file
  # branch only, and swallow grep's exit status.
  if [ -f "$2" ]; then grep -c "$1" "$2" 2>/dev/null || true; else echo 0; fi
}
cm=$(count 'uv run pytest' "$PY/CLAUDE.md")
sk=$(count 'uv run pytest' "$PY/.claude/skills/new-feature/SKILL.md")
b=$(count 'PROSE-BEFORE' "$PY/CLAUDE.md")
a=$(count 'PROSE-AFTER' "$PY/CLAUDE.md")
if [ "$cm" -gt 0 ] && [ "$sk" -gt 0 ] && [ "$b" -eq 1 ] && [ "$a" -eq 1 ]; then
  pass "claude-md-refresh (rerun updates the section; prose outside it survives)"
else
  failc "claude-md-refresh" "CLAUDE.md=$cm skill=$sk before=$b after=$a (want >0 >0 1 1)"
fi
# the overlay's files are under manifest management, and a rules reinstall must not eat them
ov=$(count 'rules/shipkit/python/\|skills/new-feature' "$PY/.claude/rules/shipkit/.installed")
sh "$COPY/scripts/install-rules.sh" "$COPY" "$PY" >/dev/null
ov2=$(find "$PY/.claude/rules/shipkit/python" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
if [ "$ov" -gt 0 ] && [ "$ov2" -gt 0 ]; then
  pass "manifest-overlays ($ov overlay entries tracked; survive a rules reinstall)"
else failc "manifest-overlays" "overlay entries=$ov, overlay rules on disk after reinstall=$ov2"; fi

# 10. freshness: a lockfile-only dependency bump is noticed (finding 6).
FP="$WORK/fresh"; mkdir -p "$FP"
(cd "$FP" && git init -q && printf 'x\n' > mix.lock \
  && git add -A && git -c user.email=s@s -c user.name=s commit -q -m init)
base=$(cd "$FP" && git rev-parse HEAD)
printf '# Map\n\n> Map generated at commit `%s` on main.\n' "$base" > "$FP/PROJECT_MAP.md"
(cd "$FP" && git add -A && git -c user.email=s@s -c user.name=s commit -q -m map \
  && printf 'x2\n' > mix.lock && git add -A && git -c user.email=s@s -c user.name=s commit -q -m bump)
out=$(cd "$FP" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh")
case "$out" in *"dependencies changed"*) pass "freshness (lockfile-only bump is noticed)";;
  *) failc "freshness" "lockfile bump not reported: $out";; esac

# 11. spec staleness: the most-stale spec always shows, and the total is reported (finding 6).
SP="$WORK/specs"; mkdir -p "$SP"
(cd "$SP" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
i=1; while [ "$i" -le 40 ]; do
  (cd "$SP" && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m "c$i"); i=$((i + 1))
done
for pair in "worst 40" "mid 30" "near 20" "edge 16"; do
  nm=${pair% *}; back=${pair#* }
  mkdir -p "$SP/.shipkit/specs/$nm"
  sha=$(cd "$SP" && git rev-parse --short "HEAD~$back")
  printf '# %s\n\n> Spec accepted at commit `%s` on main.\n' "$nm" "$sha" > "$SP/.shipkit/specs/$nm/spec.md"
done
out=$(cd "$SP" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh")
nlines=$(printf '%s\n' "$out" | grep -c 'commits behind HEAD')
case "$out" in
  *"worst/spec.md is 40 commits"*)
    if [ "$nlines" -eq 3 ] && printf '%s\n' "$out" | grep -q 'of 4 stale specs shown'; then
      pass "spec-staleness (worst spec always shown, capped at 3, total reported)"
    else failc "spec-staleness" "lines=$nlines, expected 3 + a total line: $out"; fi ;;
  *) failc "spec-staleness" "the most-stale spec was not reported: $out";;
esac

# 17. unsetup surgical removal (spec: .shipkit/specs/unsetup-safety/, DR-1).
# These define the contract for scripts/unsetup-remove.sh BEFORE it is written: removal is
# driven by the installation manifest, so it takes out what shipkit owns and nothing else.
# Every check builds a scratch project and asserts on the SURVIVORS — the destructive path
# is never run against anything real.
UNSETUP="$COPY/scripts/unsetup-remove.sh"

# Build a realistic project: core rules + an overlay + files shipkit must never touch.
mkproj() {  # mkproj <dir>
  _p="$1"; mkdir -p "$_p"; printf '# demo\n' > "$_p/CLAUDE.md"
  sh "$COPY/scripts/install-rules.sh" "$COPY" "$_p" >/dev/null 2>&1
  # shellcheck disable=SC2086
  sh "$COPY/scripts/install-stack.sh" "$COPY" python "$_p" TEST_COMMAND=pytest \
    API_STYLE=REST ASYNC_MODE=no ORM=SQLAlchemy PYTHON_FRAMEWORK=FastAPI \
    TEST_FRAMEWORK=pytest >/dev/null 2>&1
  mkdir -p "$_p/.claude/agents" "$_p/.shipkit/decisions"
  printf 'another tool\n'  > "$_p/.claude/agents/my-agent.md"
  printf '{"x":1}\n'       > "$_p/.claude/settings.local.json"
  printf '# decision\n'    > "$_p/.shipkit/decisions/0001-x.md"
}

if [ ! -f "$UNSETUP" ]; then
  failc "unsetup-remove" "scripts/unsetup-remove.sh does not exist (fixtures written first, by design)"
else
  # 17a. owned files go; unowned files under .claude/ stay (REQ-1, REQ-3).
  UP="$WORK/unset-a"; mkproj "$UP"
  sh "$UNSETUP" "$UP" --yes >/dev/null 2>&1
  survivors=$(find "$UP/.claude" -type f 2>/dev/null | sed "s#^$UP/##" | sort | tr '\n' ' ')
  gone=0
  [ -f "$UP/.claude/rules/shipkit/shipkit.md" ] && gone=1
  [ -f "$UP/.claude/rules/shipkit/python/python.md" ] && gone=1
  [ -f "$UP/.claude/skills/new-feature/SKILL.md" ] && gone=1
  kept=1
  [ -f "$UP/.claude/agents/my-agent.md" ] || kept=0
  [ -f "$UP/.claude/settings.local.json" ] || kept=0
  if [ "$gone" -eq 0 ] && [ "$kept" -eq 1 ]; then
    pass "unsetup-remove (owned files removed, foreign files under .claude/ survive)"
  else
    failc "unsetup-remove" "gone=$gone kept=$kept survivors=[$survivors]"
  fi
  # the manifest cannot own itself, so removal must take it out explicitly — otherwise the
  # session hook warns about an incomplete install forever, against an orphan manifest.
  if [ -f "$UP/.claude/rules/shipkit/.installed" ]; then
    failc "unsetup-remove" "the manifest itself was left behind"
  else pass "unsetup-remove (manifest removed last, no orphan left)"; fi
  # empty dirs shipkit emptied are pruned; dirs holding foreign files are not
  if [ -d "$UP/.claude/rules/shipkit" ]; then
    failc "unsetup-remove" ".claude/rules/shipkit/ left behind empty"
  elif [ ! -d "$UP/.claude/agents" ]; then
    failc "unsetup-remove" "pruned .claude/agents/, which holds a foreign file"
  else pass "unsetup-remove (empty dirs pruned, populated ones kept)"; fi

  # 17b. .shipkit/ is the user's work product and is never touched (REQ-4).
  if [ -f "$UP/.shipkit/decisions/0001-x.md" ]; then
    pass "unsetup-remove (.shipkit/ untouched)"
  else failc "unsetup-remove" ".shipkit/ was modified or removed"; fi

  # 17c. a modified owned file is reported and NOT removed without consent (REQ-2).
  UP2="$WORK/unset-b"; mkproj "$UP2"
  printf '\nUSER EDIT\n' >> "$UP2/.claude/rules/shipkit/testing.md"
  out=$(sh "$UNSETUP" "$UP2" --yes 2>&1)
  if [ -f "$UP2/.claude/rules/shipkit/testing.md" ] \
     && printf '%s\n' "$out" | grep -q 'testing.md'; then
    pass "unsetup-remove (locally modified owned file is reported and kept)"
  else
    failc "unsetup-remove" "a modified owned file was removed without consent"
  fi
  # ...and --force removes it, since the user then asked explicitly
  sh "$UNSETUP" "$UP2" --yes --force >/dev/null 2>&1
  if [ -f "$UP2/.claude/rules/shipkit/testing.md" ]; then
    failc "unsetup-remove" "--force did not remove the modified file"
  else pass "unsetup-remove (--force removes a modified file on explicit request)"; fi

  # 17d. a pre-3.1 legacy stamp owns nothing: refuse, exit non-zero, remove NOTHING (REQ-5).
  UP3="$WORK/unset-c"; mkproj "$UP3"
  printf 'version=3.0.0\nsha=deadbeef\n' > "$UP3/.claude/rules/shipkit/.installed"
  before=$(find "$UP3/.claude" -type f | wc -l | tr -d ' ')
  out=$(sh "$UNSETUP" "$UP3" --yes 2>&1); rc=$?
  after=$(find "$UP3/.claude" -type f | wc -l | tr -d ' ')
  if [ "$rc" -ne 0 ] && [ "$before" -eq "$after" ] \
     && printf '%s\n' "$out" | grep -qi 'cannot prove\|legacy\|pre-3.1'; then
    pass "unsetup-remove (legacy stamp: refuses, removes nothing, says why)"
  else
    failc "unsetup-remove" "legacy stamp: rc=$rc files $before->$after (expected non-zero, unchanged)"
  fi

  # 17e. dry run is the DEFAULT: without --yes it reports and changes nothing (REQ-7).
  UP4="$WORK/unset-d"; mkproj "$UP4"
  before=$(find "$UP4/.claude" -type f | wc -l | tr -d ' ')
  out=$(sh "$UNSETUP" "$UP4" 2>&1)
  after=$(find "$UP4/.claude" -type f | wc -l | tr -d ' ')
  if [ "$before" -eq "$after" ] && printf '%s\n' "$out" | grep -q 'shipkit.md'; then
    pass "unsetup-remove (dry run by default: lists the removal set, changes nothing)"
  else
    failc "unsetup-remove" "dry run changed files ($before->$after) or printed no path list"
  fi
fi

echo
if [ "$fail" -eq 0 ]; then echo "smoke: all checks passed"; else echo "smoke: FAILURES above"; fi
exit $fail
