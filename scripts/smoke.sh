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

# 2. rules-skip: a rule INSTALLED AS A FILE is not ALSO injected by the hook.
#
# This needs TWO codewords. The plugin's decisions.md carries ZEBRA-1001 (appended above); the
# project's installed copy gets ZEBRA-2002 stamped into it after install. Both reach context as
# plain text, so a single codeword cannot say WHICH path delivered it — verified directly:
# with inject-rule.sh deleted outright, ZEBRA-1001 still arrived, because Claude Code had loaded
# the project's own rule file. Two codewords make the assertion precise:
#
#   sees ZEBRA-2002 (disk copy) and NOT ZEBRA-1001 (hook copy)  ->  hook correctly silent
#
# The earlier version built an empty .claude/rules/shipkit/ with mkdir and passed only because
# 3.0's inject-rule.sh tested `[ -d ]` — the directory's mere existence suppressed injection.
# That directory-only test IS review finding 2: an interrupted install left the rule absent from
# disk AND from context, silently. An empty directory is an INCOMPLETE install, not an installed
# one, so the fixture installs for real.
sh "$COPY/scripts/install-rules.sh" "$COPY" "$PROJ" >/dev/null 2>&1
sed 's/ZEBRA-1001/ZEBRA-2002/' "$PROJ/.claude/rules/shipkit/decisions.md" > "$PROJ/.dec.tmp" \
  && mv "$PROJ/.dec.tmp" "$PROJ/.claude/rules/shipkit/decisions.md"
out=$(ask "$COPY" "$CW_Q")
case "$out" in
  *ZEBRA-1001*) failc "rules-skip" "hook injected the plugin's copy although the rule is installed: $out";;
  *ZEBRA-2002*) pass "rules-skip (installed rule loads from disk; hook does not double-inject)";;
  *) failc "rules-skip" "neither codeword reached context — the installed rule did not load: $out";;
esac

# 2b. ...and a rule MISSING from an otherwise-complete install IS still injected, so the
# Cites: install-lifecycle/REQ-5
# always-on fallback cannot be silently disabled (finding 2, the other half of the contract).
# Deleting the disk copy removes ZEBRA-2002, so seeing ZEBRA-1001 proves the hook stepped in.
rm -f "$PROJ/.claude/rules/shipkit/decisions.md"
out=$(ask "$COPY" "$CW_Q")
case "$out" in
  *ZEBRA-1001*) pass "rules-fallback (a rule deleted from disk is re-injected, not lost)";;
  *) failc "rules-fallback" "a rule missing from disk was not injected: $out";;
esac
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

# 5. workflows-skills: the workflows plugin's skills register (the knowledge base this check
# used to look for was cut in 4.0; `humanize` is the skill with the most distinctive name)
out=$(ask "$ROOT/plugins/shipkit-workflows" 'List the exact names of every skill available to you whose name contains "humanize", one per line, or NONE.')
case "$out" in *humanize*) pass "workflows-skills (a shipkit-workflows skill is registered)";;
  *) failc "workflows-skills" "got: $out";; esac

# 5b. namespaces: the two plugins register under distinct prefixes, no collision.
#
# Ask about ONE skill per invocation. Asking both in a single two-part question returns
# "YES, NO" on haiku — deterministically, 4 runs out of 4, with BOTH plugins registered
# correctly. Asked separately the same model answers YES for each. So the combined form was
# not flaky, it was systematically wrong: the second half of a two-part membership question
# gets dropped. An earlier PASS on that prompt was the unreliable reading, not this one.
#
# NOTE: this is still model self-report, which the 3.0.0 review rightly called out as the weak
# part of this check — it cannot see registration metadata directly. Treat a failure here as
# "investigate", not "proven broken": confirm against `--plugin-dir` registration before
# concluding anything, the way the isolated probe did.
ns_ok=1
for pair in "shipkit:map" "shipkit-workflows:tdd"; do
  out=$(cd "$PROJ" && claude --plugin-dir "$COPY" --plugin-dir "$ROOT/plugins/shipkit-workflows" \
    --model haiku -p "Is a skill named \"$pair\" available to you? Reply with exactly YES or NO. Do not use tools." 2>/dev/null | tail -3)
  case "$out" in
    *YES*) ;;
    *) failc "namespaces" "skill '$pair' not reported as available — got: $out"; ns_ok=0;;
  esac
done
[ "$ns_ok" -eq 1 ] && pass "namespaces (both plugins register under distinct prefixes)"

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
# Cites: install-lifecycle/REQ-5 install-lifecycle/REQ-6
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
# Cites: install-lifecycle/REQ-7
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
# Cites: install-lifecycle/REQ-9 install-lifecycle/REQ-10 (and install-lifecycle/REQ-8, by the
# manifest-overlays assertion at the end of this check)
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
# Cites: install-lifecycle/REQ-11
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
# Cites: install-lifecycle/REQ-12
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

# 9b. a skill the user wrote under an overlay's name is not overwritten, and not claimed.
# .claude/skills/ is shared; `new-feature` is a name a user plausibly already has. Reuses $PY
# and $pyargs from check 9 — its new-feature skill is shipkit's, so that one must still refresh.
UP="$WORK/user-skill"; mkdir -p "$UP/.claude/skills/new-feature"
printf 'MY-OWN-SKILL\n' > "$UP/.claude/skills/new-feature/SKILL.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$UP" >/dev/null
# shellcheck disable=SC2086
sh "$COPY/scripts/install-stack.sh" "$COPY" python "$UP" TEST_COMMAND=pytest $pyargs >/dev/null 2>&1
mine=$(count 'MY-OWN-SKILL' "$UP/.claude/skills/new-feature/SKILL.md")
owned=$(count 'skills/new-feature/SKILL.md' "$UP/.claude/rules/shipkit/.installed")
# shellcheck disable=SC2086
SHIPKIT_OVERWRITE_SKILLS=1 sh "$COPY/scripts/install-stack.sh" "$COPY" python "$UP" TEST_COMMAND=pytest $pyargs >/dev/null 2>&1
forced=$(count 'MY-OWN-SKILL' "$UP/.claude/skills/new-feature/SKILL.md")
if [ "$mine" -eq 1 ] && [ "$owned" -eq 0 ] && [ "$forced" -eq 0 ] && [ "$sk" -gt 0 ]; then
  pass "skill-collision (user's same-named skill kept and unowned; replaced only on request)"
else failc "skill-collision" "kept=$mine owned=$owned after-force=$forced own-refresh=$sk (want 1 0 0 >0)"; fi

# 9c. an edit INSIDE the managed CLAUDE.md block is not overwritten without asking (REQ-10).
# Cites: install-lifecycle/REQ-10
# Check 9 proved an untouched section refreshes; here the user has written inside the markers,
# so a rerun with a new value must leave the block alone, print the diff, and replace it only
# when told to. Mutates $PY, so it runs after 9b.
awk 'index($0,"<!-- /shipkit:stack:python -->"){print "USER-EDIT-INSIDE"} {print}' \
  "$PY/CLAUDE.md" > "$PY/CLAUDE.md.new" && mv "$PY/CLAUDE.md.new" "$PY/CLAUDE.md"
# shellcheck disable=SC2086
err=$(sh "$COPY/scripts/install-stack.sh" "$COPY" python "$PY" TEST_COMMAND="poetry run pytest" $pyargs 2>&1 >/dev/null)
kept=$(count 'USER-EDIT-INSIDE' "$PY/CLAUDE.md")
early=$(count 'poetry run pytest' "$PY/CLAUDE.md")
case "$err" in *"-USER-EDIT-INSIDE"*SHIPKIT_REFRESH_CLAUDE_MD*) diffed=1;; *) diffed=0;; esac
# shellcheck disable=SC2086
SHIPKIT_REFRESH_CLAUDE_MD=1 sh "$COPY/scripts/install-stack.sh" "$COPY" python "$PY" TEST_COMMAND="poetry run pytest" $pyargs >/dev/null 2>&1
gone=$(count 'USER-EDIT-INSIDE' "$PY/CLAUDE.md")
late=$(count 'poetry run pytest' "$PY/CLAUDE.md")
a=$(count 'PROSE-AFTER' "$PY/CLAUDE.md")
if [ "$kept" -eq 1 ] && [ "$early" -eq 0 ] && [ "$diffed" -eq 1 ] \
   && [ "$gone" -eq 0 ] && [ "$late" -gt 0 ] && [ "$a" -eq 1 ]; then
  pass "claude-md-edit (in-block edit kept and diffed; replaced only on request)"
else
  failc "claude-md-edit" "kept=$kept early=$early diffed=$diffed gone=$gone late=$late after=$a (want 1 0 1 0 >0 1)"
fi

# 11b. spec staleness on a zero-padded day of year. `date +%j` prints "008", which shell
# arithmetic reads as invalid octal; the rotation then aborted the hook with exit 1 and a
# stderr error on 36 days of the year. A stub `date` pins the day so this runs any day.
FAKEBIN="$WORK/fakebin"; mkdir -p "$FAKEBIN"
printf '#!/bin/sh\necho 008\n' > "$FAKEBIN/date"; chmod +x "$FAKEBIN/date"
out=$(cd "$SP" && PATH="$FAKEBIN:$PATH" CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh" 2>&1)
rc=$?
nlines=$(printf '%s\n' "$out" | grep -c 'commits behind HEAD')
if [ "$rc" -eq 0 ] && [ "$nlines" -eq 3 ]; then
  pass "spec-staleness (zero-padded day of year: hook exits 0, all 3 slots shown)"
else failc "spec-staleness-octal" "rc=$rc lines=$nlines: $out"; fi

# 17. unsetup surgical removal (spec: .shipkit/specs/unsetup-safety/, DR-1).
# Cites: unsetup-safety/REQ-1 unsetup-safety/REQ-2 unsetup-safety/REQ-3 unsetup-safety/REQ-4
# unsetup-safety/REQ-5 unsetup-safety/REQ-7 (17a to 17e below name the requirement each proves)
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
  [ -f "$UP/.claude/rules/shipkit/python/pyproject.md" ] && gone=1
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

# 18. commit guard (spec: .shipkit/specs/measure-and-slim/, REQ-21..REQ-26).
# Cites: measure-and-slim/REQ-21 measure-and-slim/REQ-22 measure-and-slim/REQ-23
# measure-and-slim/REQ-24 measure-and-slim/REQ-25 measure-and-slim/REQ-26
# guard-commit.sh is a PreToolUse hook on Bash: it reads the hook's JSON on stdin and exits 2
# (which blocks the call) when a `git commit` would include a secret-looking staged file.
# Called directly with sample JSON — no claude needed. The JSON carries the project as `cwd`,
# and the checks run from $WORK, so a pass also proves the guard looks at the project the hook
# names and not at whatever directory it happens to start in.
GUARD="$COPY/scripts/guard-commit.sh"
GP="$WORK/guard"; mkdir -p "$GP"
(cd "$GP" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
guard() {  # guard <command> [cwd]  → prints the exit status; stderr lands in $WORK/guard.err
  printf '{"hook_event_name":"PreToolUse","cwd":"%s","tool_name":"Bash","tool_input":{"command":"%s"}}' \
    "${2:-$GP}" "$1" | (cd "$WORK" && sh "$GUARD" 2>"$WORK/guard.err"); echo $?
}
if [ ! -f "$GUARD" ]; then
  failc "guard-commit" "scripts/guard-commit.sh does not exist (checks written first, by design)"
else
  if sh -n "$GUARD" 2>/dev/null; then pass "guard-commit (POSIX sh: sh -n is clean)"
  else failc "guard-commit" "sh -n reports a syntax error"; fi
  printf 'x\n' > "$GP/app.py"; (cd "$GP" && git add app.py)
  rc=$(guard "git commit -m wip")
  if [ "$rc" -eq 0 ]; then pass "guard-commit (clean commit → exit 0)"
  else failc "guard-commit" "clean commit: exit $rc, want 0"; fi
  printf 'KEY=1\n' > "$GP/.env"; (cd "$GP" && git add -f .env)
  rc=$(guard "git commit -m wip")
  if [ "$rc" -eq 2 ] && grep -q '\.env' "$WORK/guard.err" \
     && grep -q 'unstage these or ask the owner' "$WORK/guard.err"; then
    pass "guard-commit (staged .env → exit 2, file named, told what to do)"
  else failc "guard-commit" "staged .env: exit $rc, stderr: $(cat "$WORK/guard.err")"; fi
  # the same staged .env must not block a command that is not a commit
  rc=$(guard "ls -la")
  if [ "$rc" -eq 0 ]; then pass "guard-commit (a command that is not a commit → exit 0)"
  else failc "guard-commit" "non-commit command: exit $rc, want 0"; fi
  (cd "$GP" && git rm -q --cached .env && printf 'KEY=\n' > .env.example && git add -f .env.example)
  rc=$(guard "git commit -m wip")
  if [ "$rc" -eq 0 ]; then pass "guard-commit (staged .env.example → exit 0)"
  else failc "guard-commit" ".env.example: exit $rc, want 0"; fi
  # a secret in a subdirectory is matched on its file name, not its path
  mkdir -p "$GP/config"; printf 'k\n' > "$GP/config/server.key"; (cd "$GP" && git add -f config/server.key)
  rc=$(guard "git add -u && git commit -m wip")
  if [ "$rc" -eq 2 ] && grep -q 'config/server.key' "$WORK/guard.err"; then
    pass "guard-commit (nested *.key in a chained commit → exit 2)"
  else failc "guard-commit" "nested key: exit $rc, stderr: $(cat "$WORK/guard.err")"; fi
  # a broken guard must never block a session: not a repository, and no input at all
  mkdir -p "$WORK/not-a-repo"
  rc=$(guard "git commit -m wip" "$WORK/not-a-repo")
  rc2=$( (cd "$WORK/not-a-repo" && sh "$GUARD" </dev/null 2>/dev/null); echo $?)
  if [ "$rc" -eq 0 ] && [ "$rc2" -eq 0 ]; then pass "guard-commit (internal error → exit 0, never blocks)"
  else failc "guard-commit" "error paths: not-a-repo exit $rc, empty stdin exit $rc2, want 0 0"; fi
fi

# 19. spec-check, part one: requirements, tasks and tests (spec: .shipkit/specs/spec-contract/).
# spec-check.sh reads a spec as plain text and prints one line per gap. Every check builds a
# scratch project; no claude needed. Cites: spec-contract/REQ-1 spec-contract/REQ-2
# spec-contract/REQ-3 spec-contract/REQ-4 spec-contract/REQ-5 spec-contract/REQ-6
# spec-contract/REQ-7 spec-contract/REQ-8 spec-contract/REQ-9 spec-contract/REQ-10
SC="$COPY/scripts/spec-check.sh"
scspec() {  # scspec <proj> <slug> <status|none> → a spec with REQ-1 and REQ-2, each with a task and a cited test
  _d="$1/.shipkit/specs/$2"; mkdir -p "$_d" "$1/tests"
  [ -d "$1/.git" ] || (cd "$1" && git init -q)
  { printf '# Spec: %s\n\n> Spec accepted at commit `abc1234` on main.\n' "$2"
    [ "$3" = none ] || printf '> Status: %s\n' "$3"
    printf '\n## Requirements\n\n- **REQ-1.** When a happens, the system shall do b.\n'
    printf -- '- **REQ-2.** When c happens, the system shall do d.\n'; } > "$_d/spec.md"
  printf -- '- [ ] **T1** do b → REQ-1\n- [ ] **T2** do d → REQ-2\n' > "$_d/tasks.md"
  printf '# %s/REQ-1\n# %s/REQ-2\n' "$2" "$2" > "$1/tests/test_$2.py"
}
sc() {  # sc <proj> [slug] → output in $WORK/sc.out, prints the exit status
  sh "$SC" "$@" > "$WORK/sc.out" 2>&1; echo $?
}
if [ ! -f "$SC" ]; then
  failc "spec-check" "scripts/spec-check.sh does not exist (checks written first, by design)"
else
  if sh -n "$SC" 2>/dev/null; then pass "spec-check (POSIX sh: sh -n is clean)"
  else failc "spec-check" "sh -n reports a syntax error"; fi

  # a. a complete shipped spec has nothing to report
  P="$WORK/sc-a"; scspec "$P" demo shipped
  rc=$(sc "$P")
  if [ "$rc" -eq 0 ] && ! grep -q 'MISSING-' "$WORK/sc.out"; then pass "spec-check (complete shipped spec → exit 0)"
  else failc "spec-check" "complete spec: exit $rc: $(cat "$WORK/sc.out")"; fi

  # b. a requirement no task mentions
  P="$WORK/sc-b"; scspec "$P" demo open
  printf -- '- [ ] **T1** do b → REQ-1\n' > "$P/.shipkit/specs/demo/tasks.md"
  rc=$(sc "$P")
  if [ "$rc" -eq 1 ] && grep -q '^MISSING-TASK demo REQ-2$' "$WORK/sc.out" \
     && ! grep -q 'MISSING-TASK demo REQ-1$' "$WORK/sc.out"; then pass "spec-check (requirement with no task → MISSING-TASK, exit 1)"
  else failc "spec-check" "no task: exit $rc: $(cat "$WORK/sc.out")"; fi

  # c. a shipped spec with an uncited requirement; a citation in docs/ or a .md file does not count
  P="$WORK/sc-c"; scspec "$P" demo shipped
  printf '# demo/REQ-1\n' > "$P/tests/test_demo.py"
  mkdir -p "$P/docs"; printf 'demo/REQ-2\n' > "$P/docs/notes.txt"; printf 'demo/REQ-2\n' > "$P/README.md"
  rc=$(sc "$P")
  if [ "$rc" -eq 1 ] && grep -q '^MISSING-TEST demo REQ-2$' "$WORK/sc.out" \
     && ! grep -q 'MISSING-TEST demo REQ-1$' "$WORK/sc.out"; then pass "spec-check (shipped, uncited requirement → MISSING-TEST, exit 1)"
  else failc "spec-check" "uncited: exit $rc: $(cat "$WORK/sc.out")"; fi
  # ...and the same gap in an OPEN spec is not yet an error: tests are owed at ship time
  sed 's/^> Status: shipped/> Status: open/' "$P/.shipkit/specs/demo/spec.md" > "$WORK/sc.tmp" && mv "$WORK/sc.tmp" "$P/.shipkit/specs/demo/spec.md"
  rc=$(sc "$P")   # exit status not asserted: these one-line tasks are pre-3.3 format (section 20)
  if ! grep -q 'MISSING-TEST\|MISSING-TASK' "$WORK/sc.out"; then pass "spec-check (open spec is not asked for tests yet)"
  else failc "spec-check" "open spec asked for tests: exit $rc: $(cat "$WORK/sc.out")"; fi

  # d. an excused requirement — the excuse sits on a wrapped continuation line
  P="$WORK/sc-d"; scspec "$P" demo shipped
  printf '# demo/REQ-1\n' > "$P/tests/test_demo.py"
  printf '  It is prose only. [untested: verified by reading]\n' >> "$P/.shipkit/specs/demo/spec.md"
  rc=$(sc "$P")
  if [ "$rc" -eq 0 ] && grep -q '^WAIVED demo REQ-2$' "$WORK/sc.out" && ! grep -q 'MISSING-' "$WORK/sc.out"; then
    pass "spec-check ([untested: …] requirement → WAIVED, exit 0)"
  else failc "spec-check" "waived: exit $rc: $(cat "$WORK/sc.out")"; fi

  # e. dropped and draft specs are skipped, gaps and all
  P="$WORK/sc-e"; scspec "$P" gone dropped; scspec "$P" early draft
  : > "$P/.shipkit/specs/gone/tasks.md"; : > "$P/.shipkit/specs/early/tasks.md"; rm -f "$P"/tests/*.py
  rc=$(sc "$P")
  if [ "$rc" -eq 0 ] && grep -q '^SKIPPED gone (dropped)$' "$WORK/sc.out" \
     && grep -q '^SKIPPED early (draft)$' "$WORK/sc.out" && ! grep -q 'MISSING-' "$WORK/sc.out"; then
    pass "spec-check (dropped and draft specs with gaps → SKIPPED, exit 0)"
  else failc "spec-check" "skipped: exit $rc: $(cat "$WORK/sc.out")"; fi

  # f. two specs that both have REQ-1 do not satisfy each other; a slug limits the run to one spec
  P="$WORK/sc-f"; scspec "$P" alpha shipped; scspec "$P" beta shipped
  rm -f "$P/tests/test_beta.py"
  rc=$(sc "$P"); out=$(cat "$WORK/sc.out"); rc2=$(sc "$P" alpha)
  if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q '^MISSING-TEST beta REQ-1$' \
     && ! printf '%s\n' "$out" | grep -q 'MISSING-TEST alpha' && [ "$rc2" -eq 0 ]; then
    pass "spec-check (alpha/REQ-1 does not satisfy beta/REQ-1; a slug checks one spec)"
  else failc "spec-check" "two specs: exit $rc / alpha-only exit $rc2: $out"; fi

  # g. REQ-1 is not satisfied by a citation of REQ-10
  P="$WORK/sc-g"; scspec "$P" demo shipped
  printf -- '- **REQ-10.** When e happens, the system shall do f.\n' >> "$P/.shipkit/specs/demo/spec.md"
  printf -- '- [ ] **T3** do f → REQ-10\n' >> "$P/.shipkit/specs/demo/tasks.md"
  printf '# demo/REQ-10\n# demo/REQ-2\n' > "$P/tests/test_demo.py"
  rc=$(sc "$P")
  if [ "$rc" -eq 1 ] && grep -q '^MISSING-TEST demo REQ-1$' "$WORK/sc.out" && ! grep -q 'REQ-10' "$WORK/sc.out"; then
    pass "spec-check (a citation of REQ-10 does not satisfy REQ-1)"
  else failc "spec-check" "REQ-1 vs REQ-10: exit $rc: $(cat "$WORK/sc.out")"; fi

  # h. no Status line means open: tasks are checked, tests are not
  P="$WORK/sc-h"; scspec "$P" demo none
  printf -- '- [ ] **T1** do b → REQ-1\n' > "$P/.shipkit/specs/demo/tasks.md"; rm -f "$P"/tests/*.py
  rc=$(sc "$P")
  if [ "$rc" -eq 1 ] && grep -q '^MISSING-TASK demo REQ-2$' "$WORK/sc.out" && ! grep -q 'MISSING-TEST' "$WORK/sc.out"; then
    pass "spec-check (no Status line is treated as open)"
  else failc "spec-check" "no status: exit $rc: $(cat "$WORK/sc.out")"; fi

  # i. wrong usage
  rc=$(sc); rc2=$(sc "$WORK/no-such-project"); rc3=$(sc "$WORK/sc-a" no-such-spec)
  if [ "$rc" -eq 64 ] && [ "$rc2" -eq 64 ] && [ "$rc3" -eq 64 ]; then pass "spec-check (wrong usage → exit 64)"
  else failc "spec-check" "usage: no args $rc, missing dir $rc2, unknown slug $rc3 (want 64 64 64)"; fi
fi

# 20. spec-check, part two: the task format (spec: .shipkit/specs/spec-contract/).
# For an OPEN spec that carries a Status line, every task needs Files / Test / After /
# Done when, After must name real tasks, two tasks sharing a file must be ordered by After
# (directly or through a chain), and After lines must not form a cycle. Reuses scspec and sc
# from section 19. Cites: spec-contract/REQ-11 spec-contract/REQ-12 spec-contract/REQ-13
# spec-contract/REQ-14 spec-contract/REQ-27
sctasks() {  # sctasks <proj> <slug> <after-of-T2> → tasks.md in the 3.3 format; T1 and T2 share one file
  printf -- '- [ ] **T1** do b → REQ-1\n  - Files: app/a.py, tests/test_a.py\n  - Test: tests/test_a.py::test_b\n  - After: none\n  - Done when: `pytest` → all pass\n- [ ] **T2** do d → REQ-2\n  - Files: app/c.py, tests/test_a.py\n  - Test: tests/test_a.py::test_d\n  - After: %s\n  - Done when: `pytest` → all pass\n' "$3" \
    > "$1/.shipkit/specs/$2/tasks.md"
}
if [ ! -f "$SC" ]; then
  failc "spec-check-tasks" "scripts/spec-check.sh does not exist"
else
  # a. a well-formed open spec
  P="$WORK/st-a"; scspec "$P" demo open; sctasks "$P" demo T1
  rc=$(sc "$P")
  if [ "$rc" -eq 0 ] && ! grep -Eq 'MISSING-|BAD-AFTER|CONFLICT' "$WORK/sc.out"; then pass "spec-check-tasks (well-formed tasks → exit 0)"
  else failc "spec-check-tasks" "well-formed: exit $rc: $(cat "$WORK/sc.out")"; fi

  # b. a task missing fields
  P="$WORK/st-b"; scspec "$P" demo open; sctasks "$P" demo T1
  grep -v 'test_d\|Done when' "$P/.shipkit/specs/demo/tasks.md" > "$WORK/sc.tmp" \
    && mv "$WORK/sc.tmp" "$P/.shipkit/specs/demo/tasks.md"
  rc=$(sc "$P")
  if [ "$rc" -eq 1 ] && grep -q '^MISSING-FIELD demo T2 Test$' "$WORK/sc.out" \
     && grep -q '^MISSING-FIELD demo T2 Done-when$' "$WORK/sc.out" \
     && grep -q '^MISSING-FIELD demo T1 Done-when$' "$WORK/sc.out" \
     && ! grep -q 'MISSING-FIELD demo T1 Test' "$WORK/sc.out"; then
    pass "spec-check-tasks (task without Test / Done when → MISSING-FIELD, exit 1)"
  else failc "spec-check-tasks" "missing field: exit $rc: $(cat "$WORK/sc.out")"; fi

  # c. After names a task that does not exist
  P="$WORK/st-c"; scspec "$P" demo open; sctasks "$P" demo "T1, T9"
  rc=$(sc "$P")
  if [ "$rc" -eq 1 ] && grep -q '^BAD-AFTER demo T2 T9$' "$WORK/sc.out" && ! grep -q 'CONFLICT' "$WORK/sc.out"; then
    pass "spec-check-tasks (After names an unknown task → BAD-AFTER, exit 1)"
  else failc "spec-check-tasks" "bad after: exit $rc: $(cat "$WORK/sc.out")"; fi

  # d. the sharing rule: two tasks list the same file and the later one does not name the earlier
  P="$WORK/st-d"; scspec "$P" demo open; sctasks "$P" demo none
  rc=$(sc "$P")
  if [ "$rc" -eq 1 ] && grep -q '^CONFLICT demo T1 T2 tests/test_a.py$' "$WORK/sc.out"; then
    pass "spec-check-tasks (shared file without After → CONFLICT, exit 1)"
  else failc "spec-check-tasks" "conflict: exit $rc: $(cat "$WORK/sc.out")"; fi

  # d2. ...but a chain is enough: T3 shares the file with T1 and names only T2, which names T1
  P="$WORK/st-d2"; scspec "$P" demo open; sctasks "$P" demo T1
  printf -- '- [ ] **T3** do more → REQ-2\n  - Files: tests/test_a.py\n  - Test: tests/test_a.py::test_e\n  - After: T2\n  - Done when: `pytest` → all pass\n' \
    >> "$P/.shipkit/specs/demo/tasks.md"
  rc=$(sc "$P")
  if [ "$rc" -eq 0 ] && ! grep -q 'CONFLICT' "$WORK/sc.out"; then
    pass "spec-check-tasks (shared file ordered through a chain of After lines → exit 0)"
  else failc "spec-check-tasks" "chain: exit $rc: $(cat "$WORK/sc.out")"; fi

  # d3. After lines that form a cycle cannot be scheduled at all
  P="$WORK/st-d3"; scspec "$P" demo open; sctasks "$P" demo T1
  sed 's/  - After: none/  - After: T2/' "$P/.shipkit/specs/demo/tasks.md" > "$WORK/sc.tmp" \
    && mv "$WORK/sc.tmp" "$P/.shipkit/specs/demo/tasks.md"
  rc=$(sc "$P")
  if [ "$rc" -eq 1 ] && grep -q '^CYCLE demo T1$' "$WORK/sc.out" && grep -q '^CYCLE demo T2$' "$WORK/sc.out"; then
    pass "spec-check-tasks (After lines in a cycle → CYCLE, exit 1)"
  else failc "spec-check-tasks" "cycle: exit $rc: $(cat "$WORK/sc.out")"; fi

  # e. a pre-3.3 spec — no Status line, one-line tasks — is left alone
  P="$WORK/st-e"; scspec "$P" demo none
  rc=$(sc "$P")
  if [ "$rc" -eq 0 ] && ! grep -Eq 'MISSING-|BAD-AFTER|CONFLICT' "$WORK/sc.out"; then
    pass "spec-check-tasks (old task format with no Status line → exit 0)"
  else failc "spec-check-tasks" "old format: exit $rc: $(cat "$WORK/sc.out")"; fi
fi

# 21. spec drift is measured on the spec's own files, and only for open specs
# (spec: .shipkit/specs/spec-contract/). A spec with neither a Status nor a Paths line must
# behave exactly as in 3.2.0 — that is what checks 11 and 11b above assert, unchanged.
# Cites: spec-contract/REQ-15 spec-contract/REQ-16 spec-contract/REQ-17 spec-contract/REQ-18
DP="$WORK/drift"; mkdir -p "$DP/a" "$DP/b"
dcommit() {  # dcommit <dir> <n> → n commits, each touching only <dir>/f
  _i=1; while [ "$_i" -le "$2" ]; do
    printf '%s\n' "$_i" >> "$DP/$1/f"
    (cd "$DP" && git add "$1/f" && git -c user.email=s@s -c user.name=s commit -q -m "$1 $_i"); _i=$((_i + 1))
  done
}
dspec() {  # dspec <slug> <status|none> <paths|none> → a spec stamped at the current HEAD
  mkdir -p "$DP/.shipkit/specs/$1"
  { printf '# %s\n\n> Spec accepted at commit `%s` on main.\n' "$1" "$(cd "$DP" && git rev-parse --short HEAD)"
    [ "$2" = none ] || printf '> Status: %s\n' "$2"
    [ "$3" = none ] || printf '> Paths: %s\n' "$3"; } > "$DP/.shipkit/specs/$1/spec.md"
}
dhook() { (cd "$DP" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh" 2>&1); }
(cd "$DP" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
dspec done-one shipped none; dspec gone-one dropped none; dspec early-one draft none
dspec scoped open "a/, docs/"
dcommit b 20
out=$(dhook)
case "$out" in
  *done-one*|*gone-one*|*early-one*) failc "spec-drift-paths" "a shipped, dropped or draft spec was reported: $out";;
  *) pass "spec-drift-paths (shipped, dropped and draft specs 20 commits old → silent)";;
esac
case "$out" in
  *scoped*) failc "spec-drift-paths" "20 commits outside the spec's Paths were counted: $out";;
  *) pass "spec-drift-paths (open spec, 20 commits that touch only other paths → silent)";;
esac
dcommit a 20
out=$(dhook)
n=$(printf '%s\n' "$out" | grep -c 'scoped')
case "$out" in
  *"scoped/spec.md: 20 commits have touched its paths since it was accepted"*)
    if [ "$n" -eq 1 ]; then pass "spec-drift-paths (20 commits inside its Paths → one line, counting only those)"
    else failc "spec-drift-paths" "expected one line for the spec, got $n: $out"; fi ;;
  *) failc "spec-drift-paths" "the scoped spec was not reported with its own count: $out";;
esac
# an open spec with a Status line but no Paths still counts every commit, in the 3.2.0 wording
dspec whole open none
dcommit b 15
out=$(dhook)
case "$out" in
  *"whole/spec.md is 15 commits behind HEAD"*) pass "spec-drift-paths (open spec with no Paths → counted as before)";;
  *) failc "spec-drift-paths" "open spec with no Paths was not counted on the whole repository: $out";;
esac

# 22. spec-new-format: a spec that /shipkit:spec writes passes spec-check
# (spec: .shipkit/specs/spec-contract/). Cites: spec-contract/REQ-21 spec-contract/REQ-22
# Plugin evals have no custom-code graders (they cannot run a script on what a run wrote), so
# this lives here. It is the one check in this file that asks a model to do real work: it runs
# the skill headless in a copy of the eval fixture, then runs spec-check.sh on the result
# ITSELF — the model's own claim that the check passed is not what is asserted. Uses sonnet,
# not haiku: the skill is a three-phase interview and the cheaper model does not finish it
# reliably. Takes a few minutes.
NF="$WORK/newfmt"; mkdir -p "$NF"; cp -R "$COPY/evals/fixtures/sample-app/." "$NF/"
(cd "$NF" && git init -q && git add -A && git -c user.email=s@s -c user.name=s commit -q -m init)
(cd "$NF" && claude --plugin-dir "$COPY" --model sonnet \
  --allowedTools Read Glob Grep Write Edit Bash Skill Agent \
  -p "/shipkit:spec refunds
Feature: add refunds to the billing module. A charged order can be refunded in full or in part through the payment gateway; a refund larger than the original charge is rejected.
This run is not interactive and you cannot ask me anything. Treat every approval gate as approved, make reasonable assumptions and note them in the spec, and do all three questions now: write spec.md, design.md and tasks.md, set the status and paths as the skill says for an accepted spec, and run the spec check as the skill says. Do not implement the feature." \
  </dev/null >"$WORK/newfmt.out" 2>&1)
nf_out=$(sh "$COPY/scripts/spec-check.sh" "$NF" refunds 2>&1); nf_rc=$?
nf_spec="$NF/.shipkit/specs/refunds/spec.md"; nf_tasks="$NF/.shipkit/specs/refunds/tasks.md"
nf_fields=0; [ -f "$nf_tasks" ] && nf_fields=$(grep -c '^ *- Files:' "$nf_tasks")
if [ "$nf_rc" -eq 0 ] && grep -q '^> Status: open' "$nf_spec" 2>/dev/null \
   && grep -q '^> Paths: .' "$nf_spec" 2>/dev/null && [ "$nf_fields" -gt 0 ]; then
  pass "spec-new-format (/shipkit:spec wrote an open spec with paths; $nf_fields tasks in the new format; spec-check exits 0)"
else
  failc "spec-new-format" "spec-check exit $nf_rc, tasks with Files: $nf_fields — $nf_out — model said: $(tail -5 "$WORK/newfmt.out")"
fi
# the always-on rule tells every session how a test cites a requirement, inside the budget
# (the same byte assertion is what proves product-intake-brief/REQ-28 after S3-T6's sentence)
if grep -q 'REQ-N' "$COPY/rules/spec-driven.md" && grep -q '/REQ-N' "$COPY/rules/spec-driven.md" \
   && [ "$(cat "$CORE/rules/shipkit.md" "$CORE/rules/spec-driven.md" "$CORE/rules/decisions.md" | wc -c | tr -d ' ')" -le 3000 ]; then
  pass "spec-new-format (the spec-driven rule names the <feature>/REQ-N citation; rules within 3,000 bytes)"
else failc "spec-new-format" "the citation sentence is missing from the rule, or the always-on rules exceed 3,000 bytes"; fi

# 23. product-file: /shipkit:product writes the product file in its fixed shape
# (spec: .shipkit/specs/product-intake-brief/). Cites: product-intake-brief/REQ-1
# product-intake-brief/REQ-2
# Like check 22 this asks a model (sonnet) to do real work: the skill runs headless in a copy
# of the eval fixture with its answers given up front — FOUR goals on purpose, one with no
# metric — and the file it writes is then read here, not taken on the model's word.
PF="$WORK/product"; mkdir -p "$PF"; cp -R "$COPY/evals/fixtures/sample-app/." "$PF/"
(cd "$PF" && git init -q && git add -A && git -c user.email=s@s -c user.name=s commit -q -m init)
(cd "$PF" && claude --plugin-dir "$COPY" --model sonnet \
  --allowedTools Read Glob Grep Write Edit Skill \
  -p "/shipkit:product
This run is not interactive and you cannot ask me anything, so here are my answers.
Users: owners of small online shops who take card payments.
Goals for this quarter, in my order of importance: (1) cut failed charges to under 2 percent of all charges by 2026-12-31; (2) ship refunds, with 95 percent of refunds needing no manual step, by 2026-11-15; (3) make order totals correct to the cent in every region, zero tax rounding complaints, by 2026-12-15; (4) make the app faster.
Non-goals: no multi-currency support; no storefront or cart.
Metrics that matter: charge failure rate, refunds per week.
Constraints: Python standard library only; one maintainer.
Now: the retry job. Next: refunds. Later: a proper database." \
  </dev/null >"$WORK/product.out" 2>&1)
pf="$PF/.shipkit/product.md"
if [ -f "$pf" ]; then
  heads=$(grep '^## ' "$pf" | sed 's/^## //; s/[[:space:]]*$//' | tr '\n' '|')
  goals=$(awk '/^## /{on=($0 ~ /^## Goals this quarter/)} on && /^(- |[0-9]+\. )/{n++} END{print n+0}' "$pf")
  plines=$(wc -l < "$pf" | tr -d ' ')
else heads=""; goals=0; plines=0; fi
if [ "$heads" = "One line|Users|Goals this quarter|Non-goals|Metrics that matter|Constraints|Now / Next / Later|" ] \
   && [ "$goals" -ge 1 ] && [ "$goals" -le 3 ] && [ "$plines" -le 60 ]; then
  pass "product-file (seven headings in order; $goals goals from four offered; $plines lines)"
else
  failc "product-file" "headings=[$heads] goals=$goals lines=$plines — model said: $(tail -4 "$WORK/product.out")"
fi

# 24. registry-columns: the registry template and eve know the product columns and studio.md
# (spec: .shipkit/specs/product-intake-brief/). No claude needed — these are the files a
# session reads. Cites: product-intake-brief/REQ-8 product-intake-brief/REQ-10
rc_head=$(grep -m1 '^| Project | Path ' "$COPY/skills/map/SKILL.md")
case "$rc_head" in
  *"| Product | Top Goal |"*) pass "registry-columns (registry template has Product and Top Goal)";;
  *) failc "registry-columns" "the template header lacks the two columns: $rc_head";;
esac
if grep -q 'studio\.md' "$COPY/agents/eve.md" && grep -q '`Product`' "$COPY/agents/eve.md" \
   && grep -q '`Top Goal`' "$COPY/agents/eve.md"; then
  pass "registry-columns (eve names studio.md and both columns)"
else failc "registry-columns" "agents/eve.md does not name studio.md, Product and Top Goal"; fi

# 25. brief: a task becomes a brief, built by a script from the spec, with no model
# (spec: .shipkit/specs/product-intake-brief/). Cites: product-intake-brief/REQ-18
# product-intake-brief/REQ-19 product-intake-brief/REQ-20 product-intake-brief/REQ-21
# product-intake-brief/REQ-22 product-intake-brief/REQ-23
BRIEF="$COPY/scripts/brief.sh"
BP="$WORK/brief"; mkdir -p "$BP/.shipkit/specs/refunds" "$BP/.shipkit/specs/old"
(cd "$BP" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
cat > "$BP/.shipkit/specs/refunds/spec.md" <<'SPEC'
# Spec: Refunds

> Spec accepted at commit `abc1234` on main.
> Status: open
> Paths: app/billing/

## Purpose
A charged order can be refunded through the gateway.
Shop owners ask for this weekly.

## Requirements (EARS)
- **REQ-1.** When a refund is requested, the system shall call the gateway.
- **REQ-2.** If the refund is larger than the original charge, then the system shall
  reject it with a clear error and leave the order unchanged.
- **REQ-3.** The README shall describe refunds. [untested: prose]

## Out of scope
- Refunds in a second currency.
SPEC
cat > "$BP/.shipkit/specs/refunds/design.md" <<'SPEC'
# Design: Refunds

## Decision: Keep a ledger of refunds on the order   (→ REQ-2)

**Decision.** We chose a ledger.

## Decision: Old ledger idea   (→ REQ-2)

> **Superseded on 2026-10-05** by the decision above.

## Decision: Describe refunds in one README section   (→ REQ-3)

**Decision.** One section.
SPEC
cat > "$BP/.shipkit/specs/refunds/tasks.md" <<'SPEC'
# Tasks: Refunds

- [ ] **T1** Refund a charge in full → REQ-1
  - Files: app/billing/refunds.py, tests/test_refunds.py
  - Test: tests/test_refunds.py::test_full_refund
  - After: none
  - Done when: `pytest tests/test_refunds.py` → all pass
- [ ] **T2** Record each refund on the order → REQ-1
  - Files: app/billing/refunds.py, tests/test_refunds.py
  - Test: tests/test_refunds.py::test_refund_is_recorded
  - After: T1
  - Done when: `pytest tests/test_refunds.py` → all pass
- [ ] **T3** Reject refunds larger than the charge
      → REQ-2
  - Files: app/billing/refunds.py, tests/test_refunds.py
  - Test: tests/test_refunds.py::test_refund_over_charge_is_rejected
  - After: T2
  - Done when: `pytest tests/test_refunds.py` → all pass
SPEC
printf '# Spec: Old\n\n## Purpose\nOld.\n\n## Requirements\n- **REQ-1.** The system shall x.\n' > "$BP/.shipkit/specs/old/spec.md"
printf -- '- [ ] **T1** do x → REQ-1\n' > "$BP/.shipkit/specs/old/tasks.md"
if [ ! -f "$BRIEF" ]; then
  failc "brief" "scripts/brief.sh does not exist (checks written first, by design)"
else
  if sh -n "$BRIEF" 2>/dev/null; then pass "brief (POSIX sh: sh -n is clean)"
  else failc "brief" "sh -n reports a syntax error"; fi
  out=$(sh "$BRIEF" "$BP" refunds T3 2>"$WORK/brief.err"); rc=$?
  heads=$(printf '%s\n' "$out" | grep '^#' | sed 's/^# Brief:.*/# Brief/' | tr '\n' '|')
  want='# Brief|## Goal|## Requirement|## You may edit|## Prove it with|## Already done|## Decisions that bind you|## Not in scope|## Report back in exactly this form|'
  if [ "$rc" -eq 0 ] && [ "$heads" = "$want" ] \
     && printf '%s\n' "$out" | grep -q '^# Brief: refunds / T3 — Reject refunds larger than the charge$'; then
    pass "brief (valid task → title and the eight headings, in order)"
  else failc "brief" "exit $rc, headings [$heads], stderr: $(cat "$WORK/brief.err")"; fi
  if printf '%s\n' "$out" | grep -qF -- '- **REQ-2.** If the refund is larger than the original charge, then the system shall' \
     && printf '%s\n' "$out" | grep -qF '  reject it with a clear error and leave the order unchanged.' \
     && ! printf '%s\n' "$out" | grep -q 'REQ-1\.'; then
    pass "brief (the cited requirement is copied word for word, wrapped line and all; others are left out)"
  else failc "brief" "requirement text not copied exactly: $out"; fi
  if printf '%s\n' "$out" | grep -q '^- T1 ' && printf '%s\n' "$out" | grep -q '^- T2 '; then
    pass "brief (Already done lists T2 and, through the chain, T1)"
  else failc "brief" "predecessors missing: $out"; fi
  if printf '%s\n' "$out" | grep -q 'Keep a ledger of refunds on the order' \
     && ! printf '%s\n' "$out" | grep -q 'Old ledger idea\|one README section' \
     && printf '%s\n' "$out" | grep -q 'app/billing/refunds.py' \
     && printf '%s\n' "$out" | grep -q 'test_refund_over_charge_is_rejected' \
     && printf '%s\n' "$out" | grep -q 'Refunds in a second currency' \
     && printf '%s\n' "$out" | grep -q 'Shop owners ask for this weekly' \
     && printf '%s\n' "$out" | grep -q '^RESULT: done | blocked$'; then
    pass "brief (goal, files, test, binding decision, scope and report form all present; superseded decision left out)"
  else failc "brief" "a section is wrong: $out"; fi
  sh "$BRIEF" "$BP" refunds T9 >/dev/null 2>"$WORK/brief.err"; rc=$?
  if [ "$rc" -eq 1 ] && grep -q 'T9' "$WORK/brief.err" && grep -q 'refunds' "$WORK/brief.err"; then
    pass "brief (unknown task → exit 1, naming the task and the spec)"
  else failc "brief" "unknown task: exit $rc: $(cat "$WORK/brief.err")"; fi
  sh "$BRIEF" "$BP" old T1 >/dev/null 2>"$WORK/brief.err"; rc=$?
  if [ "$rc" -eq 1 ] && grep -q '3\.3 task format' "$WORK/brief.err"; then
    pass "brief (task with no Files line → exit 1, says the spec must be in the 3.3 task format)"
  else failc "brief" "old format: exit $rc: $(cat "$WORK/brief.err")"; fi
fi

# 26. brief-verify: did the work stay inside the files the task was allowed to change?
# (spec: .shipkit/specs/product-intake-brief/). Reuses the refunds spec from section 25.
# Cites: product-intake-brief/REQ-24 product-intake-brief/REQ-25 product-intake-brief/REQ-26
BV="$COPY/scripts/brief-verify.sh"
if [ ! -f "$BV" ]; then
  failc "brief-verify" "scripts/brief-verify.sh does not exist (checks written first, by design)"
else
  if sh -n "$BV" 2>/dev/null; then pass "brief-verify (POSIX sh: sh -n is clean)"
  else failc "brief-verify" "sh -n reports a syntax error"; fi
  mkdir -p "$BP/app/billing" "$BP/tests"
  (cd "$BP" && git add -A && git -c user.email=s@s -c user.name=s commit -q -m spec)
  bv_base=$(cd "$BP" && git rev-parse HEAD)
  # a. only allowed files: one committed, one left uncommitted, plus the task's own tick box
  printf 'x\n' > "$BP/app/billing/refunds.py"
  (cd "$BP" && git add app/billing/refunds.py && git -c user.email=s@s -c user.name=s commit -q -m work)
  printf 'y\n' > "$BP/tests/test_refunds.py"
  sed 's/- \[ \] \*\*T3\*\*/- [x] **T3**/' "$BP/.shipkit/specs/refunds/tasks.md" > "$WORK/bv.tmp" && mv "$WORK/bv.tmp" "$BP/.shipkit/specs/refunds/tasks.md"
  out=$(sh "$BV" "$BP" refunds T3 "$bv_base" 2>&1); rc=$?
  if [ "$rc" -eq 0 ] && ! printf '%s\n' "$out" | grep -q '^OUTSIDE'; then
    pass "brief-verify (only allowed files changed, committed and not → exit 0)"
  else failc "brief-verify" "allowed only: exit $rc: $out"; fi
  # b. one extra tracked file
  printf 'z\n' >> "$BP/.shipkit/specs/refunds/spec.md"
  out=$(sh "$BV" "$BP" refunds T3 "$bv_base" 2>&1); rc=$?
  if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q '^OUTSIDE .shipkit/specs/refunds/spec.md$' \
     && ! printf '%s\n' "$out" | grep -q 'OUTSIDE app/billing/refunds.py'; then
    pass "brief-verify (a changed file outside the list → OUTSIDE, exit 1)"
  else failc "brief-verify" "extra file: exit $rc: $out"; fi
  (cd "$BP" && git checkout -q -- .shipkit/specs/refunds/spec.md)
  # c. a new untracked file outside the list
  printf 'n\n' > "$BP/app/notes.txt"
  out=$(sh "$BV" "$BP" refunds T3 "$bv_base" 2>&1); rc=$?
  if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q '^OUTSIDE app/notes.txt$'; then
    pass "brief-verify (a new untracked file outside the list → OUTSIDE, exit 1)"
  else failc "brief-verify" "untracked: exit $rc: $out"; fi
  rm -f "$BP/app/notes.txt"
  # d. wrong usage and an unknown task
  sh "$BV" "$BP" refunds T3 >/dev/null 2>&1; rc=$?
  sh "$BV" "$BP" refunds T9 "$bv_base" >/dev/null 2>&1; rc2=$?
  sh "$BV" "$BP" refunds T3 no-such-ref >/dev/null 2>&1; rc3=$?
  if [ "$rc" -eq 64 ] && [ "$rc2" -eq 1 ] && [ "$rc3" -eq 64 ]; then pass "brief-verify (missing argument or bad ref → 64; unknown task → 1)"
  else failc "brief-verify" "usage: missing arg $rc, unknown task $rc2, bad ref $rc3 (want 64 1 64)"; fi
fi

# 27. reviewer-tools: the reviewer agent can read and run git, and cannot change anything or
# start another agent (spec: .shipkit/specs/review-and-ship/). Read from the file a session
# loads. Cites: review-and-ship/REQ-7
rv="$COPY/agents/reviewer.md"
rv_tools=$(sed -n 's/^tools: *//p' "$rv" 2>/dev/null | tr -d ' ')
rv_deny=$(sed -n 's/^disallowedTools: *//p' "$rv" 2>/dev/null | tr -d ' ')
if [ "$rv_tools" = "Read,Glob,Grep,Bash" ] && [ "$rv_deny" = "Edit,Write,Agent" ]; then
  pass "reviewer-tools (tools = Read, Glob, Grep, Bash; Edit, Write and Agent denied)"
else failc "reviewer-tools" "tools=[$rv_tools] disallowedTools=[$rv_deny]"; fi

# 28. spec-check --as-shipped: an open spec is asked for what a shipped one owes, and no file
# changes (spec: .shipkit/specs/review-and-ship/). Reuses scspec and sc from section 19.
# Cites: review-and-ship/REQ-9
P="$WORK/as-shipped"; scspec "$P" demo open
printf '# demo/REQ-1\n' > "$P/tests/test_demo.py"
as_before=$(cat "$P/.shipkit/specs/demo/spec.md")
sh "$SC" "$P" demo > "$WORK/sc.out" 2>&1
if grep -q 'MISSING-TEST' "$WORK/sc.out"; then failc "as-shipped" "an open spec was asked for tests without the flag: $(cat "$WORK/sc.out")"
else
  rc=$(sc "$P" demo --as-shipped)
  if [ "$rc" -eq 1 ] && grep -q '^MISSING-TEST demo REQ-2$' "$WORK/sc.out" \
     && [ "$as_before" = "$(cat "$P/.shipkit/specs/demo/spec.md")" ]; then
    pass "as-shipped (open spec + --as-shipped → MISSING-TEST, exit 1, spec.md untouched)"
  else failc "as-shipped" "exit $rc: $(cat "$WORK/sc.out")"; fi
fi

# 29. ship-gate: /shipkit:ship says READY for a complete feature and NOT READY, naming step 3,
# when one task is unticked — and changes nothing but its report
# (spec: .shipkit/specs/review-and-ship/). Cites: review-and-ship/REQ-12 review-and-ship/REQ-13
# review-and-ship/REQ-14
# Asks a model (sonnet) to do real work, twice, and each run starts the reviewer agent: a few
# minutes. The feature is the one the reviewer/all-met eval case builds. What is asserted is
# the report file and `git status`, read here — not the model's summary.
SG="$WORK/ship"; mkdir -p "$SG"
(cd "$SG" && bash "$COPY/evals/reviewer/all-met/fixture.sh" >/dev/null 2>&1)
# No .gitignore on purpose: the gate's own test run leaves __pycache__/ behind, and a gate that
# then called the tree dirty would fail every Python project on its own step 2.
shiprun() {
  (cd "$SG" && claude --plugin-dir "$COPY" --model sonnet \
    --allowedTools Read Glob Grep Bash Write Skill Agent \
    -p "/shipkit:ship refunds base
This run is not interactive and you cannot ask me anything. The project's test command is: python3 -m unittest discover -s tests
Do not change the spec's Status line." </dev/null >"$WORK/ship.out" 2>&1)
}
shiprun
sg_report=$(ls "$SG"/.shipkit/releases/*-refunds.md 2>/dev/null | sed -n 1p)
sg_first=""; [ -n "$sg_report" ] && sg_first=$(sed -n 1p "$sg_report")
sg_dirty=$(cd "$SG" && git status --porcelain | grep -v '\.shipkit/releases/' | grep -v '__pycache__')
if [ "$sg_first" = "READY" ] && [ -z "$sg_dirty" ]; then
  pass "ship-gate (complete feature → report starts READY; nothing else in the tree changed)"
else
  failc "ship-gate" "first line [$sg_first], other changes [$sg_dirty] — model said: $(tail -6 "$WORK/ship.out")"
fi
# the same feature with one task unticked
rm -rf "$SG/.shipkit/releases"
sed 's/^- \[x\] \*\*T2\*\*/- [ ] **T2**/' "$SG/.shipkit/specs/refunds/tasks.md" > "$WORK/sg.tmp" \
  && mv "$WORK/sg.tmp" "$SG/.shipkit/specs/refunds/tasks.md"
(cd "$SG" && git add .shipkit/specs/refunds/tasks.md && git -c user.email=s@s -c user.name=s commit -q -m "untick T2")
shiprun
sg_report=$(ls "$SG"/.shipkit/releases/*-refunds.md 2>/dev/null | sed -n 1p)
sg_first=""; [ -n "$sg_report" ] && sg_first=$(sed -n 1p "$sg_report")
if [ "$sg_first" = "NOT READY" ] && grep -Eq '^\| *3 *\|.*\| *FAIL *\|' "$sg_report"; then
  pass "ship-gate (one task unticked → report starts NOT READY and step 3 is FAIL)"
else
  failc "ship-gate" "first line [$sg_first]; step 3 row: $(grep -E '^\| *3 *\|' "$sg_report" 2>/dev/null) — model said: $(tail -6 "$WORK/ship.out")"
fi

# 30. briefing: a few lines at session start saying where things stand
# (spec: .shipkit/specs/briefing-and-handoff/). No claude needed. Cites: briefing-and-handoff/REQ-1
# briefing-and-handoff/REQ-2 briefing-and-handoff/REQ-3 briefing-and-handoff/REQ-4
# briefing-and-handoff/REQ-5 briefing-and-handoff/REQ-6 briefing-and-handoff/REQ-7
# briefing-and-handoff/REQ-8 briefing-and-handoff/REQ-9
BRF="$COPY/scripts/briefing.sh"
brief() { (cd "$1" && sh "$BRF" 2>"$WORK/brief.err"); echo "rc=$?" >> "$WORK/brief.err"; }
bspec() {  # bspec <proj> <slug> <status|none> <done> <total> → an open spec with N ticked tasks of M
  _d="$1/.shipkit/specs/$2"; mkdir -p "$_d"
  { printf '# Spec: %s\n\n> Spec accepted at commit `abc1234` on main.\n' "$2"; [ "$3" = none ] || printf '> Status: %s\n' "$3"
    printf '\n## Requirements\n\n- **REQ-1.** The system shall x.\n'; } > "$_d/spec.md"
  _i=1; : > "$_d/tasks.md"
  while [ "$_i" -le "$5" ]; do
    if [ "$_i" -le "$4" ]; then _b='x'; else _b=' '; fi
    if [ "$_i" -eq 1 ]; then _a=none; else _a="T$((_i - 1))"; fi
    printf -- '- [%s] **T%s** Do step %s → REQ-1\n  - Files: a.py\n  - Test: t\n  - After: %s\n  - Done when: x\n' "$_b" "$_i" "$_i" "$_a" >> "$_d/tasks.md"
    _i=$((_i + 1))
  done
}
if [ ! -f "$BRF" ]; then
  failc "briefing" "scripts/briefing.sh does not exist (checks written first, by design)"
else
  if sh -n "$BRF" 2>/dev/null; then pass "briefing (POSIX sh: sh -n is clean)"
  else failc "briefing" "sh -n reports a syntax error"; fi
  # a. no .shipkit/ at all → nothing
  BA="$WORK/brief-a"; mkdir -p "$BA"; (cd "$BA" && git init -q)
  out=$(brief "$BA")
  if [ -z "$out" ] && grep -q '^rc=0$' "$WORK/brief.err"; then pass "briefing (no .shipkit/ → prints nothing, exit 0)"
  else failc "briefing" "no .shipkit/: [$out] $(cat "$WORK/brief.err")"; fi
  # b. two open specs, one shipped, a product file and a handoff two commits old
  BB="$WORK/brief-b"; mkdir -p "$BB"
  (cd "$BB" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
  bspec "$BB" alpha open 1 3; bspec "$BB" beta none 0 2; bspec "$BB" done-one shipped 2 2
  printf '# alpha/REQ-1\n' > "$BB/t.py"; printf '# beta/REQ-1\n' >> "$BB/t.py"; printf '# done-one/REQ-1\n' >> "$BB/t.py"
  mkdir -p "$BB/.shipkit"
  printf '# Product: demo\n\n> Product reviewed on 2026-10-01.\n\n## One line\nx\n\n## Users\n- y\n\n## Goals this quarter\n- Cut failed charges — metric: share that fail; target: under 2%%; by: 2026-12-31\n- Second goal\n\n## Non-goals\n- z\n' > "$BB/.shipkit/product.md"
  hsha=$(cd "$BB" && git rev-parse --short HEAD)
  printf '# Handoff\n\n> Written 2026-10-01 at commit `%s` on main.\n\n## In flight\n- alpha T2\n\n## Done this session\n- T1\n\n## Next step\nFinish alpha T2 and run its test.\n\n## Open questions\n- none\n\n## Do not forget\n- x\n' "$hsha" > "$BB/.shipkit/state.md"
  (cd "$BB" && git add -A && git -c user.email=s@s -c user.name=s commit -q -m one && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m two)
  out=$(brief "$BB")
  if printf '%s\n' "$out" | grep -q '^shipkit: alpha: 1 of 3 tasks done, next T2 — Do step 2$' \
     && printf '%s\n' "$out" | grep -q '^shipkit: beta: 0 of 2 tasks done, next T1 — Do step 1$' \
     && ! printf '%s\n' "$out" | grep -q 'done-one' \
     && printf '%s\n' "$out" | grep -q '^shipkit: top goal: Cut failed charges — metric: share that fail; target: under 2%; by: 2026-12-31$' \
     && printf '%s\n' "$out" | grep -q '^shipkit: last handoff (2026-10-01, 2 commits ago): Finish alpha T2 and run its test\.$' \
     && ! printf '%s\n' "$out" | grep -q 'spec-check:' \
     && [ "$(printf '%s\n' "$out" | grep -vc '^shipkit: ')" -eq 0 ]; then
    pass "briefing (open specs with progress and next task, top goal, last handoff; shipped spec silent; no gap line)"
  else failc "briefing" "lines: $out $(cat "$WORK/brief.err")"; fi
  # ...and a gap makes the spec-check line appear
  : > "$BB/.shipkit/specs/alpha/tasks.md"
  out=$(brief "$BB")
  if printf '%s\n' "$out" | grep -q '^shipkit: spec-check: 1 gap(s) — run spec-check.sh$'; then
    pass "briefing (a spec-check gap → one gap line)"
  else failc "briefing" "no gap line: $out"; fi
  # c. fifty open specs: at most eight lines, at most 800 bytes, under a second
  BC="$WORK/brief-c"; mkdir -p "$BC"; (cd "$BC" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
  i=1; while [ "$i" -le 50 ]; do bspec "$BC" "spec-$i-with-a-rather-long-name-to-fill-the-line" open 1 4; i=$((i + 1)); done
  bt=$(python3 -c "import subprocess,sys,time; a=time.time(); subprocess.run(['sh','$BRF'],cwd='$BC',stdout=open('$WORK/brief50.out','w'),stderr=subprocess.DEVNULL); print(round(time.time()-a,2))")
  bl=$(grep -c . "$WORK/brief50.out"); bb=$(wc -c < "$WORK/brief50.out" | tr -d ' ')
  if [ "$bl" -le 8 ] && [ "$bb" -le 800 ] && [ "$(printf '%s' "$bt" | cut -d. -f1)" -eq 0 ]; then
    pass "briefing (50 open specs → $bl lines, $bb bytes, ${bt}s)"
  else failc "briefing" "50 specs: $bl lines, $bb bytes, ${bt}s (want ≤8, ≤800, <1)"; fi
  # d. a tasks.md that is not a task list, and a state.md with no Next step: no error, exit 0
  BD="$WORK/brief-d"; mkdir -p "$BD/.shipkit/specs/odd"; (cd "$BD" && git init -q)
  printf '# Spec: odd\n\n- **REQ-1.** x\n' > "$BD/.shipkit/specs/odd/spec.md"
  head -c 300 /dev/urandom > "$BD/.shipkit/specs/odd/tasks.md"
  printf 'not a handoff\n' > "$BD/.shipkit/state.md"
  out=$(brief "$BD")
  if grep -q '^rc=0$' "$WORK/brief.err" && [ "$(grep -vc '^rc=' "$WORK/brief.err")" -eq 0 ]; then
    pass "briefing (unreadable tasks.md and state.md → exit 0, nothing on stderr)"
  else failc "briefing" "broken input: $(cat "$WORK/brief.err")"; fi
  # e. the session hook prints the briefing last
  out=$(cd "$BB" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh" 2>/dev/null)
  last=$(printf '%s\n' "$out" | tail -1)
  case "$last" in
    "shipkit: last handoff"*|"shipkit: top goal"*|"shipkit: spec-check"*|"shipkit: alpha"*|"shipkit: beta"*)
      pass "briefing (session-start.sh prints it last)";;
    *) failc "briefing" "the hook's last line is not from the briefing: $last";;
  esac
fi

# 31. handoff-file: /shipkit:handoff writes the note in its fixed shape
# (spec: .shipkit/specs/briefing-and-handoff/). Cites: briefing-and-handoff/REQ-10
# A model (sonnet) does the work, headless, in a copy of the eval fixture with the session's
# facts given in the request and one file left uncommitted; the note it writes is read here.
HF="$WORK/handoff"; mkdir -p "$HF"; cp -R "$COPY/evals/fixtures/sample-app/." "$HF/"
(cd "$HF" && git init -q && git add -A && git -c user.email=s@s -c user.name=s commit -q -m init)
mkdir -p "$HF/.shipkit/specs/refunds"
printf '# Spec: Refunds\n\n> Spec accepted at commit `abc1234` on master.\n> Status: open\n\n## Requirements\n\n- **REQ-1.** The system shall refund.\n' > "$HF/.shipkit/specs/refunds/spec.md"
printf -- '- [x] **T1** Refund through the gateway → REQ-1\n  - Files: app/refunds.py\n  - Test: tests/test_refunds.py\n  - After: none\n  - Done when: tests pass\n- [ ] **T2** Reject a refund above the charge → REQ-1\n  - Files: app/refunds.py\n  - Test: tests/test_refunds.py\n  - After: T1\n  - Done when: tests pass\n' > "$HF/.shipkit/specs/refunds/tasks.md"
(cd "$HF" && git add -A && git -c user.email=s@s -c user.name=s commit -q -m spec)
printf '"""Refunds — in progress."""\n' > "$HF/app/refunds.py"
(cd "$HF" && claude --plugin-dir "$COPY" --model sonnet \
  --allowedTools Read Glob Grep Bash Write Skill \
  -p "/shipkit:handoff
This run is not interactive and you cannot ask me anything. This session: finished T1 of the refunds spec (committed as 'spec' — pretend). Started T2 in app/refunds.py, which is uncommitted and half done: the amount check is written, the test is not. The next thing to do is write the failing test for T2 in tests/test_refunds.py. Open question for the owner: should partial refunds be allowed at all? Trap found: python3 -m unittest must be run from the project root or imports fail." \
  </dev/null >"$WORK/handoff.out" 2>&1)
hf="$HF/.shipkit/state.md"
if [ -f "$hf" ]; then
  hf_heads=$(grep '^## ' "$hf" | sed 's/^## //; s/[[:space:]]*$//' | tr '\n' '|')
  hf_next=$(awk '/^## /{on=($0 ~ /^## Next step/); next} on && NF{n++} END{print n+0}' "$hf")
  hf_lines=$(wc -l < "$hf" | tr -d ' ')
  hf_written=$(grep -c '^> Written [0-9-]* at commit' "$hf")
else hf_heads=""; hf_next=0; hf_lines=0; hf_written=0; fi
hf_dirty=$(cd "$HF" && git status --porcelain | grep -v 'app/refunds.py\|\.shipkit/state.md\|__pycache__')
if [ "$hf_heads" = "In flight|Done this session|Next step|Open questions|Do not forget|" ] \
   && [ "$hf_next" -eq 1 ] && [ "$hf_lines" -le 30 ] && [ "$hf_written" -eq 1 ] && [ -z "$hf_dirty" ] \
   && sed -n 1p "$hf" | grep -q '^# Handoff'; then
  pass "handoff-file (title, Written line, five headings in order, one-line Next step, $hf_lines lines, nothing else touched)"
else
  failc "handoff-file" "headings=[$hf_heads] next-lines=$hf_next lines=$hf_lines written=$hf_written dirty=[$hf_dirty] — model said: $(tail -4 "$WORK/handoff.out")"
fi

# 32. handoff-loop: a fresh session in the project from check 31 is asked what to do next,
# and answers from the note's Next step, which the briefing put in its context
# (spec: .shipkit/specs/briefing-and-handoff/). Cites: briefing-and-handoff/REQ-14
if [ -f "$hf" ]; then
  hl_next=$(awk '/^## /{on=($0 ~ /^## Next step/); next} on && NF{print; exit}' "$hf")
  hl_out=$(cd "$HF" && claude --plugin-dir "$COPY" --model haiku \
    -p "What should I do next in this project? Answer in one or two sentences from what is already in your context. Do not use tools." </dev/null 2>/dev/null | tail -6)
  case "$hl_out" in
    *T2*test*|*test*T2*) pass "handoff-loop (a new session answers 'what next?' with the handoff's next step)";;
    *) failc "handoff-loop" "next step was [$hl_next]; the reply was: $hl_out";;
  esac
else
  failc "handoff-loop" "no state.md from check 31 to read"
fi

# 33. compact-reminder: after a compaction the session hook says so; at any other start it
# does not (spec: .shipkit/specs/briefing-and-handoff/). The hook's JSON comes on stdin.
# Cites: briefing-and-handoff/REQ-15
cr_line='shipkit: context was just compacted — run /shipkit:handoff if work is in flight.'
cr_a=$(cd "$BB" && printf '{"session_id":"x","cwd":"%s","hook_event_name":"SessionStart","source":"compact"}\n' "$BB" | CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh" 2>/dev/null)
cr_b=$(cd "$BB" && printf '{"session_id":"x","cwd":"%s","hook_event_name":"SessionStart","source":"startup"}\n' "$BB" | CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh" 2>/dev/null)
cr_c=$(cd "$BB" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh" </dev/null 2>/dev/null)
if printf '%s\n' "$cr_a" | grep -qF "$cr_line" && ! printf '%s\n' "$cr_b" | grep -qF "$cr_line" \
   && ! printf '%s\n' "$cr_c" | grep -qF "$cr_line" && printf '%s\n' "$cr_c" | grep -q '^shipkit: plugin root'; then
  pass "compact-reminder (source compact → the line; startup or no input → no line, hook still runs)"
else failc "compact-reminder" "compact: [$cr_a] startup: [$cr_b] none: [$cr_c]"; fi

# 34. fired-if-template: the decision-record template shows the optional Fired-if line in
# both forms — a command that exits 0 once the condition has come true, and `manual` — and
# the three always-on rules still fit the budget (spec: .shipkit/specs/decisions-and-digest/).
# No claude needed. Cites: decisions-and-digest/REQ-1 decisions-and-digest/REQ-3
ft_ref="$COPY/skills/spec/reference.md"
ft_cmd=$(grep -c '^\*\*Fired-if\.\*\* `test ' "$ft_ref")
ft_man=$(grep -c '^\*\*Fired-if\.\*\* manual$' "$ft_ref")
ft_after=$(awk '/^\*\*Falsifiability\.\*\*/{f=NR} /^\*\*Fired-if\.\*\* `test /{if (f && NR > f && NR - f <= 3) ok=1} END{print ok+0}' "$ft_ref")
if [ "$ft_cmd" -ge 1 ] && [ "$ft_man" -ge 1 ] && [ "$ft_after" -eq 1 ]; then
  pass "fired-if-template (reference.md shows a command form after a Falsifiability line, and the manual form)"
else failc "fired-if-template" "command-form lines: $ft_cmd, manual-form lines: $ft_man, command after a clause: $ft_after"; fi
# measured on $CORE, not $COPY: check 1 appended a codeword to the copy's decisions.md
ft_bytes=$(cat "$CORE/rules/shipkit.md" "$CORE/rules/spec-driven.md" "$CORE/rules/decisions.md" | wc -c | tr -d ' ')
if [ "$ft_bytes" -le 3000 ]; then pass "fired-if-template (the three always-on rules total $ft_bytes bytes, at most 3000)"
else failc "fired-if-template" "the three always-on rules total $ft_bytes bytes, over 3000"; fi

# 35. decision-check: Fired-if commands are listed by default and run only with --run; exit 0
# from a command is FIRED, 1 is HOLDS, above 1 is ERROR, `manual` is MANUAL with the clause;
# the script exits 1 only when something FIRED; no hook names it
# (spec: .shipkit/specs/decisions-and-digest/). No claude needed. Cites: decisions-and-digest/REQ-4
# decisions-and-digest/REQ-5 decisions-and-digest/REQ-6 decisions-and-digest/REQ-7
# decisions-and-digest/REQ-8 decisions-and-digest/REQ-9
DCS="$COPY/scripts/decision-check.sh"
dcrec() {  # dcrec <file> <title> <clause> <fired-if payload> → one standalone decision record
  printf '# %s\n\n**Context.** c\n\n**Alternatives.**\n1. a\n2. b\n\n**Case for a.** x\n\n**Case against a.** y\n\n**Decision.** We chose a.\n**Falsifiability.** We would reverse this if %s.\n**Fired-if.** %s\n' "$2" "$3" "$4" > "$1"
}
if [ ! -f "$DCS" ]; then
  failc "decision-check" "scripts/decision-check.sh does not exist (checks written first, by design)"
else
  if sh -n "$DCS" 2>/dev/null; then pass "decision-check (POSIX sh: sh -n is clean)"
  else failc "decision-check" "sh -n reports a syntax error"; fi
  if grep -q 'read them before\|read the commands before\|before using --run\|before `--run`' "$DCS" \
     && sed -n 1,40p "$DCS" | grep -q 'come from the repository'; then
    pass "decision-check (the header says the commands come from the repository and to read them before --run)"
  else failc "decision-check" "the header comment lacks the warning about untrusted repositories"; fi
  DC="$WORK/dc"; mkdir -p "$DC/.shipkit/decisions" "$DC/.shipkit/specs/demo"
  (cd "$DC" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
  dcrec "$DC/.shipkit/decisions/0001-fired.md" "Fired one" "the marker exists" '`touch dc-marker`'
  dcrec "$DC/.shipkit/decisions/0002-holds.md" "Holds one" "a file called never appears" '`test -f never`'
  dcrec "$DC/.shipkit/decisions/0003-manual.md" "Manual one" "the routes file passes 500 lines" 'manual'
  printf '# Design: demo\n\n## Decision: Exit three   (→ REQ-1)\n\n**Context.** c\n\n**Decision.** We chose a.\n**Falsifiability.** We would reverse this if the tool breaks.\n**Fired-if.** `sh -c "exit 3"`\n\n## Decision: No line here   (→ REQ-2)\n\n**Decision.** We chose b.\n**Falsifiability.** We would reverse this if the sky falls.\n' > "$DC/.shipkit/specs/demo/design.md"
  # a. no flag: every command and its record listed, nothing run, exit 0
  out=$(sh "$DCS" "$DC" 2>"$WORK/dc.err"); rc=$?
  if [ "$rc" -eq 0 ] && [ ! -e "$DC/dc-marker" ] \
     && printf '%s\n' "$out" | grep -q '0001-fired\.md.*touch dc-marker' \
     && printf '%s\n' "$out" | grep -q '0002-holds\.md.*test -f never' \
     && printf '%s\n' "$out" | grep -q '0003-manual\.md.*manual' \
     && printf '%s\n' "$out" | grep -q 'demo/design\.md.*Exit three.*exit 3' \
     && ! printf '%s\n' "$out" | grep -q 'No line here' \
     && ! printf '%s\n' "$out" | grep -q '^FIRED\|^HOLDS'; then
    pass "decision-check (no flag → four commands listed with their records, none run, exit 0)"
  else failc "decision-check" "list: rc=$rc marker=$([ -e "$DC/dc-marker" ] && echo yes || echo no) out: $out $(cat "$WORK/dc.err")"; fi
  # b. --run: FIRED / HOLDS / MANUAL with the clause / ERROR with the exit status; exit 1
  out=$(cd "$WORK" && sh "$DCS" "$DC" --run 2>"$WORK/dc.err"); rc=$?
  if [ "$rc" -eq 1 ] && [ -e "$DC/dc-marker" ] \
     && printf '%s\n' "$out" | grep -q '^FIRED .*0001-fired\.md' \
     && printf '%s\n' "$out" | grep -q '^HOLDS .*0002-holds\.md' \
     && printf '%s\n' "$out" | grep -q '^MANUAL .*0003-manual\.md.*the routes file passes 500 lines' \
     && printf '%s\n' "$out" | grep -q '^ERROR .*demo/design\.md.*Exit three.*exit 3'; then
    pass "decision-check (--run → FIRED, HOLDS, MANUAL with the clause, ERROR (exit 3); the command ran from the project; exit 1)"
  else failc "decision-check" "run: rc=$rc marker=$([ -e "$DC/dc-marker" ] && echo yes || echo no) out: $out $(cat "$WORK/dc.err")"; fi
  # c. nothing fired → exit 0, even with an ERROR and a MANUAL
  rm -f "$DC/.shipkit/decisions/0001-fired.md"
  out=$(sh "$DCS" "$DC" --run 2>/dev/null); rc=$?
  if [ "$rc" -eq 0 ] && ! printf '%s\n' "$out" | grep -q '^FIRED'; then
    pass "decision-check (--run with nothing fired → exit 0)"
  else failc "decision-check" "nothing fired: rc=$rc out: $out"; fi
  # d. a project with no records at all → exit 0 and no finding lines
  DN="$WORK/dc-none"; mkdir -p "$DN"
  out=$(sh "$DCS" "$DN" --run 2>/dev/null); rc=$?
  if [ "$rc" -eq 0 ] && ! printf '%s\n' "$out" | grep -q '^FIRED\|^HOLDS\|^MANUAL\|^ERROR'; then
    pass "decision-check (no .shipkit/ → exit 0, nothing found)"
  else failc "decision-check" "no records: rc=$rc out: $out"; fi
  # e. no hook calls it
  if ! grep -rq 'decision-check' "$COPY/hooks" && ! grep -q 'decision-check' "$COPY/scripts/session-start.sh"; then
    pass "decision-check (no hook and not the session hook names decision-check)"
  else failc "decision-check" "a hook names decision-check: $(grep -rn 'decision-check' "$COPY/hooks" "$COPY/scripts/session-start.sh")"; fi
fi

# 36. portfolio-digest: one page across every registered project, written under
# $SHIPKIT_HOME/digests/<date>.md from the files already on disk, with no model; a project whose
# path is missing gets one line and the script goes on; decision commands run only with
# --run-checks (spec: .shipkit/specs/decisions-and-digest/). No claude needed, and nothing is
# written under ~/.claude: SHIPKIT_HOME points at a scratch directory. Cites:
# decisions-and-digest/REQ-12 decisions-and-digest/REQ-13 decisions-and-digest/REQ-14
# decisions-and-digest/REQ-15
PDS="$COPY/scripts/portfolio-digest.sh"
if [ ! -f "$PDS" ]; then
  failc "portfolio-digest" "scripts/portfolio-digest.sh does not exist (checks written first, by design)"
else
  if sh -n "$PDS" 2>/dev/null; then pass "portfolio-digest (POSIX sh: sh -n is clean)"
  else failc "portfolio-digest" "sh -n reports a syntax error"; fi
  PH="$WORK/shipkit-home"; mkdir -p "$PH"
  # proj-a: a product file, an open spec, a Fired-if decision, an escape today, a map two
  # commits old, one uncommitted file, no upstream
  PA="$WORK/pd-a"; mkdir -p "$PA/.shipkit/decisions" "$PA/.shipkit/escapes"
  (cd "$PA" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
  bspec "$PA" alpha open 1 3; bspec "$PA" done-one shipped 2 2
  printf '# alpha/REQ-1\n# done-one/REQ-1\n' > "$PA/t.py"
  printf '# Product: a\n\n> Product reviewed on 2026-10-01.\n\n## One line\nx\n\n## Users\n- y\n\n## Goals this quarter\n- Cut failed charges — metric: share that fail; target: under 2%%; by: 2026-12-31\n\n## Non-goals\n- z\n' > "$PA/.shipkit/product.md"
  dcrec "$PA/.shipkit/decisions/0001-fired.md" "Fired one" "the marker exists" '`touch pd-marker`'
  dcrec "$PA/.shipkit/decisions/0002-manual.md" "Manual one" "users pass 1000" 'manual'
  printf '# Escape 0001: over-refund\n\n> Recorded on %s.\n\n## What happened\nx\n\n## Cause\n`requirement missing` — y\n' "$(date +%Y-%m-%d)" > "$PA/.shipkit/escapes/0001-over-refund.md"
  printf '# Escape 0002: old one\n\n> Recorded on 2020-01-01.\n\n## Cause\n`no spec` — y\n' > "$PA/.shipkit/escapes/0002-old.md"
  printf '# Project map\n\n> Map generated at commit `%s` on main. Refresh with `/shipkit:map`.\n' "$(cd "$PA" && git rev-parse --short HEAD)" > "$PA/PROJECT_MAP.md"
  (cd "$PA" && git add -A && git -c user.email=s@s -c user.name=s commit -q -m one && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m two)
  printf 'wip\n' > "$PA/wip.txt"
  # proj-b: a bare project with no .shipkit/, registered with a ~ path
  PB="$WORK/pd-b"; mkdir -p "$PB"; (cd "$PB" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
  printf '# Shipkit Project Registry\n> Portfolio index for `eve`.\n\n| Project | Path | Map | Mapped At | Stack | Deploys To | Active Specs | Product | Top Goal | Summary |\n|---|---|---|---|---|---|---|---|---|---|\n| proj-a | %s | PROJECT_MAP.md | abc1234 | Python | — | alpha | a | Cut failed charges | first |\n| proj-b | ~/pd-b | — | ? | ? | ? | — | ? | ? | second |\n| proj-gone | %s/nowhere | — | ? | ? | ? | — | ? | ? | missing |\n' "$PA" "$WORK" > "$PH/project-registry.md"
  pd_file="$PH/digests/$(date +%Y-%m-%d).md"
  pd_own="$HOME/.claude/shipkit/digests/$(date +%Y-%m-%d).md"; pd_own_before=$([ -e "$pd_own" ] && echo yes || echo no)
  pd_section() { awk -v p="## $1" '$0 ~ "^## " {on=(index($0, p)==1)} on' "$pd_file"; }
  # a. default: the file, three sections, path not found, the seven lines, nothing run
  pd_out=$(cd "$WORK" && HOME="$WORK" SHIPKIT_HOME="$PH" sh "$PDS" 2>"$WORK/pd.err"); rc=$?
  if [ "$rc" -eq 0 ] && [ -f "$pd_file" ] && [ "$(grep -c '^## ' "$pd_file")" -eq 3 ] \
     && [ ! -e "$PA/pd-marker" ] && [ ! -e "$WORK/pd-marker" ] \
     && pd_section proj-gone | grep -q '^path not found$' \
     && [ "$(pd_section proj-a | grep -c '^- ')" -eq 7 ] && [ "$(pd_section proj-b | grep -c '^- ')" -eq 7 ] \
     && printf '%s\n' "$pd_out" | grep -q "digests/$(date +%Y-%m-%d)\.md"; then
    pass "portfolio-digest (two projects and a missing path → one file, three sections, 'path not found', seven lines each, no command run, exit 0)"
  else failc "portfolio-digest" "rc=$rc file=$([ -f "$pd_file" ] && echo yes || echo no) sections=$(grep -c '^## ' "$pd_file" 2>/dev/null) marker=$([ -e "$PA/pd-marker" ] && echo yes || echo no) out: $pd_out $(cat "$WORK/pd.err"; cat "$pd_file" 2>/dev/null)"; fi
  # b. each line says what its file says
  sa=$(pd_section proj-a); sb=$(pd_section proj-b)
  if printf '%s\n' "$sa" | grep -q '^- Top goal: Cut failed charges.*reviewed on 2026-10-01' \
     && printf '%s\n' "$sa" | grep -q '^- Open specs: alpha 1 of 3 tasks done, next T2' \
     && ! printf '%s\n' "$sa" | grep -q 'done-one' \
     && printf '%s\n' "$sa" | grep -q '^- Spec gaps: 0' \
     && printf '%s\n' "$sa" | grep -q '^- Decisions: .*not run' && printf '%s\n' "$sa" | grep -q '^- Decisions: .*1 manual' \
     && printf '%s\n' "$sa" | grep -q '^- Escapes (30 days): 1 — requirement missing 1$' \
     && printf '%s\n' "$sa" | grep -q '^- Map: 2 commits old' \
     && printf '%s\n' "$sa" | grep -q '^- Git: 1 uncommitted file(s), no upstream' \
     && printf '%s\n' "$sb" | grep -q '^- Top goal: no product file' \
     && printf '%s\n' "$sb" | grep -q '^- Open specs: none' \
     && printf '%s\n' "$sb" | grep -q '^- Escapes (30 days): none' \
     && printf '%s\n' "$sb" | grep -q '^- Map: no map'; then
    pass "portfolio-digest (goal and review date, open spec progress, gaps, decisions, escapes by cause within 30 days, map age, git state; a ~ path expands)"
  else failc "portfolio-digest" "lines: $sa $sb"; fi
  # c. --run-checks runs the decision commands and reports what fired; still exit 0
  pd_out=$(cd "$WORK" && HOME="$WORK" SHIPKIT_HOME="$PH" sh "$PDS" --run-checks 2>"$WORK/pd.err"); rc=$?
  if [ "$rc" -eq 0 ] && [ -e "$PA/pd-marker" ] && pd_section proj-a | grep -q '^- Decisions: 1 fired, 0 hold, 1 manual, 0 error(s)'; then
    pass "portfolio-digest (--run-checks → the command ran from the project; 'Decisions: 1 fired …'; exit 0)"
  else failc "portfolio-digest" "run-checks: rc=$rc marker=$([ -e "$PA/pd-marker" ] && echo yes || echo no) $(pd_section proj-a | grep '^- Decisions') $(cat "$WORK/pd.err")"; fi
  # d. an explicit registry file, and a missing one
  pd_out=$(cd "$WORK" && SHIPKIT_HOME="$PH" sh "$PDS" "$PH/no-such-registry.md" 2>&1); rc=$?
  if [ "$rc" -ne 0 ] && [ ! -d "$PH/digests/nowhere" ]; then pass "portfolio-digest (a missing registry → non-zero exit and a message: $pd_out)"
  else failc "portfolio-digest" "missing registry: rc=$rc out: $pd_out"; fi
  if [ "$pd_own_before" = yes ] || [ ! -e "$pd_own" ]; then
    pass "portfolio-digest (nothing written under ~/.claude/shipkit/digests)"
  else failc "portfolio-digest" "a digest appeared under ~/.claude/shipkit/digests"; fi
fi

# 37. digest-old: the briefing says when the newest digest is more than seven days old, and
# says nothing about digests when there is none or when it is recent
# (spec: .shipkit/specs/decisions-and-digest/). No claude needed; SHIPKIT_HOME points at a
# scratch directory. Cites: decisions-and-digest/REQ-17
DO="$WORK/digest-old"; mkdir -p "$DO/.shipkit/specs/alpha" "$DO/home/digests"
(cd "$DO" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
bspec "$DO" alpha open 1 2
do_old=$(python3 -c 'import datetime; print((datetime.date.today() - datetime.timedelta(days=8)).isoformat())')
do_recent=$(python3 -c 'import datetime; print((datetime.date.today() - datetime.timedelta(days=6)).isoformat())')
printf '# Shipkit digest — %s\n' "$do_old" > "$DO/home/digests/$do_old.md"
do_a=$(cd "$DO" && SHIPKIT_HOME="$DO/home" sh "$BRF" 2>/dev/null)
printf '# Shipkit digest — %s\n' "$do_recent" > "$DO/home/digests/$do_recent.md"
do_b=$(cd "$DO" && SHIPKIT_HOME="$DO/home" sh "$BRF" 2>/dev/null)
rm -f "$DO/home/digests/"*.md
do_c=$(cd "$DO" && SHIPKIT_HOME="$DO/home" sh "$BRF" 2>/dev/null)
do_d=$(cd "$DO" && SHIPKIT_HOME="$DO/no-such-home" sh "$BRF" 2>/dev/null)
if printf '%s\n' "$do_a" | grep -q '^shipkit: digest: newest is 8 days old — run portfolio-digest.sh' \
   && ! printf '%s\n' "$do_b" | grep -q 'digest' \
   && ! printf '%s\n' "$do_c" | grep -q 'digest' && ! printf '%s\n' "$do_d" | grep -q 'digest' \
   && printf '%s\n' "$do_a" | grep -q '^shipkit: alpha: 1 of 2 tasks done'; then
  pass "digest-old (newest digest 8 days old → one line; 6 days old, none, or no home → no digest line)"
else failc "digest-old" "old: [$do_a] recent: [$do_b] none: [$do_c] no home: [$do_d]"; fi

# 38. ledger-gen: the XL eval fixture is GENERATED, never committed (spec: .shipkit/specs/
# map-on-trial/). generate.py writes a 200-file service with a 25-commit history into an empty
# directory; two runs must be byte-identical outside .git so both arms of the map comparison
# see the same code. No claude needed. Cites: map-on-trial/REQ-1 map-on-trial/REQ-2
# map-on-trial/REQ-3 map-on-trial/REQ-4 map-on-trial/REQ-6
GEN="$COPY/evals/fixtures/ledger-gen/generate.py"
if [ ! -f "$GEN" ]; then
  failc "ledger-gen" "evals/fixtures/ledger-gen/generate.py does not exist (check written first, by design)"
else
  LG_A="$WORK/xl-a"; LG_B="$WORK/xl-b"; LG_N="$WORK/xl-nomap"; mkdir -p "$LG_A" "$LG_B" "$LG_N"
  (cd "$LG_A" && python3 "$GEN" >/dev/null 2>&1) && (cd "$LG_B" && python3 "$GEN" >/dev/null 2>&1) \
    && (cd "$LG_N" && python3 "$GEN" --no-map >/dev/null 2>&1) || failc "ledger-gen" "generate.py exited non-zero"
  lg_files=$(cd "$LG_A" && find . -type f -not -path './.git/*' | wc -l | tr -d ' ')
  lg_commits=$(git -C "$LG_A" rev-list --count HEAD 2>/dev/null || echo 0)
  lg_commits_n=$(git -C "$LG_N" rev-list --count HEAD 2>/dev/null || echo 0)
  if [ "$lg_files" -ge 200 ] && [ "$lg_commits" -ge 25 ]; then
    pass "ledger-gen ($lg_files files, $lg_commits commits — at least 200 and 25)"
  else failc "ledger-gen" "$lg_files files, $lg_commits commits; want >= 200 and >= 25"; fi
  if lg_diff=$(diff -r -x .git "$LG_A" "$LG_B") && [ -z "$lg_diff" ]; then
    pass "ledger-gen (two runs are byte-identical outside .git)"
  else failc "ledger-gen" "two runs differ: $(printf '%s' "$lg_diff" | head -3)"; fi
  lg_redis=$(cd "$LG_A" && grep -rli redis . --exclude-dir=.git | sort | tr '\n' ' ')
  if [ "$lg_redis" = "./PROJECT_MAP.md " ]; then pass "ledger-gen (Redis is named only in PROJECT_MAP.md — the planted drift)"
  else failc "ledger-gen" "Redis named in: [$lg_redis], want only ./PROJECT_MAP.md"; fi
  if ! (cd "$LG_A" && grep -rliw --exclude-dir=.git -e sendgrid -e postmark -e mailgun -e sparkpost -e mandrill -e mailchimp -e 'amazon ses' -e smtp2go -e resend . | grep -q .); then
    pass "ledger-gen (no email provider is named anywhere — the planted gap)"
  else failc "ledger-gen" "an email provider is named: $(cd "$LG_A" && grep -rliw --exclude-dir=.git -e sendgrid -e postmark -e mailgun -e sparkpost -e mandrill -e mailchimp -e 'amazon ses' -e smtp2go -e resend . | head -3 | tr '\n' ' ')"; fi
  if [ ! -e "$LG_N/PROJECT_MAP.md" ] && [ -e "$LG_A/PROJECT_MAP.md" ] && [ "$lg_commits_n" = "$lg_commits" ] \
     && lg_ndiff=$(diff -r -x .git -x PROJECT_MAP.md "$LG_A" "$LG_N") && [ -z "$lg_ndiff" ]; then
    pass "ledger-gen (--no-map: no PROJECT_MAP.md, same $lg_commits commits, same tree otherwise)"
  else failc "ledger-gen" "--no-map: map present=$([ -e "$LG_N/PROJECT_MAP.md" ] && echo yes || echo no), commits $lg_commits_n vs $lg_commits, diff: $(printf '%s' "$lg_ndiff" | head -2)"; fi
  lg_bytes=$(wc -c < "$GEN" | tr -d ' ')
  if [ "$lg_bytes" -le 16384 ] && python3 - "$GEN" <<'EOF'
import ast, sys
names = set()
for n in ast.walk(ast.parse(open(sys.argv[1]).read())):
    if isinstance(n, ast.Import): names |= {a.name.split('.')[0] for a in n.names}
    elif isinstance(n, ast.ImportFrom) and n.level == 0: names.add(n.module.split('.')[0])
bad = names - set(sys.stdlib_module_names)
if bad: print("non-stdlib imports:", sorted(bad))
sys.exit(1 if bad else 0)
EOF
  then pass "ledger-gen ($lg_bytes bytes, at most 16384; standard-library imports only)"
  else failc "ledger-gen" "$lg_bytes bytes (limit 16384) or a non-stdlib import (see above)"; fi
fi

# 39. xl-scaffold: each grandfather-xl case builds the XL fixture through the generator, and
# SHIPKIT_EVAL_NO_MAP=1 builds it without a map. The eval tool does NOT pass the caller's
# environment to a scaffold (checked 2026-10-07 with a nonce: the briefing printed
# "probe-unset"), so the no-map ARM runs from a scratch copy whose scaffolds pass --no-map;
# the variable is for running a scaffold by hand, which is what this check does.
# Cites: map-on-trial/REQ-8 map-on-trial/REQ-9
XL="$COPY/evals/grandfather-xl"
xl_ok=1; xl_why=""
for c in lookup explain drift gap history; do
  if [ ! -f "$XL/$c/fixture.sh" ] || [ ! -f "$XL/$c/case.yaml" ] || [ ! -f "$XL/$c/prompt.md" ]; then
    xl_ok=0; xl_why="$xl_why $c:missing-files"; continue
  fi
  grep -q 'generate.py' "$XL/$c/fixture.sh" || { xl_ok=0; xl_why="$xl_why $c:no-generator"; }
  grep -q '^/shipkit:ask ' "$XL/$c/prompt.md" || { xl_ok=0; xl_why="$xl_why $c:prompt-not-ask"; }
  XD="$WORK/xl-case-$c"; mkdir -p "$XD"
  (cd "$XD" && bash "$XL/$c/fixture.sh" >/dev/null 2>&1) || { xl_ok=0; xl_why="$xl_why $c:scaffold-failed"; continue; }
  [ -f "$XD/PROJECT_MAP.md" ] && [ "$(git -C "$XD" rev-list --count HEAD 2>/dev/null)" -ge 25 ] \
    || { xl_ok=0; xl_why="$xl_why $c:no-map-or-history"; }
done
XN="$WORK/xl-case-nomap"; mkdir -p "$XN"
if [ -f "$XL/history/fixture.sh" ]; then
  (cd "$XN" && SHIPKIT_EVAL_NO_MAP=1 bash "$XL/history/fixture.sh" >/dev/null 2>&1)
  [ ! -e "$XN/PROJECT_MAP.md" ] && [ -f "$XN/app/orders/store.py" ] || { xl_ok=0; xl_why="$xl_why nomap:map-present-or-no-tree"; }
fi
if [ "$xl_ok" -eq 1 ]; then pass "xl-scaffold (five cases scaffold the XL fixture with a map; SHIPKIT_EVAL_NO_MAP=1 → without)"
else failc "xl-scaffold" "$xl_why"; fi

# 40. trace-tools: scripts/trace-tools.sh reads an eval output directory's aggregate-result.json
# and prints one line per run with the counts the map comparison reads — from the trace, never
# the summary. A synthetic two-run trace with known numbers: run 1 has three tool calls (one
# Agent, one by the subagent, one split across two rows of the same message, which must not
# double-count), run 2 has one. Cites: map-on-trial/REQ-10 map-on-trial/REQ-11
TT="$ROOT/scripts/trace-tools.sh"
TD="$WORK/tt"; mkdir -p "$TD/r1/out" "$TD/r2/out"
tt_asst() {  # tt_asst <msg-id> <parent-or-null> <input> <cache_create> <cache_read> <content-json>
  printf '{"type":"assistant","parent_tool_use_id":%s,"message":{"id":"%s","usage":{"input_tokens":%s,"cache_creation_input_tokens":%s,"cache_read_input_tokens":%s},"content":%s}}\n' "$2" "$1" "$3" "$4" "$5" "$6"
}
{
  printf '{"type":"system","subtype":"init"}\n'
  tt_asst m1 null 10 100 1000 '[{"type":"text","text":"x"}]'
  tt_asst m1 null 10 100 1000 '[{"type":"tool_use","id":"t1","name":"Agent","input":{}}]'
  tt_asst m2 '"t1"' 5 50 500 '[{"type":"tool_use","id":"t2","name":"Grep","input":{}}]'
  tt_asst m3 null 20 0 2000 '[{"type":"tool_use","id":"t3","name":"Read","input":{}}]'
  printf '{"type":"result","subtype":"success","total_cost_usd":0.5,"num_turns":3}\n'
} > "$TD/r1/out/trace.jsonl"
{
  tt_asst m9 null 1 2 3 '[{"type":"tool_use","id":"t9","name":"Glob","input":{}}]'
  printf '{"type":"result","subtype":"success","total_cost_usd":0.25,"num_turns":1}\n'
} > "$TD/r2/out/trace.jsonl"
printf '{"cases":[{"name":"grandfather-xl-lookup","arms":{"with":[{"passed":true,"tracePath":"%s"},{"passed":false,"tracePath":"%s"}]}}]}\n' \
  "$TD/r1/out/trace.jsonl" "$TD/r2/out/trace.jsonl" > "$TD/aggregate-result.json"
if [ ! -f "$TT" ]; then
  failc "trace-tools" "scripts/trace-tools.sh does not exist (check written first, by design)"
else
  if sh -n "$TT" 2>/dev/null; then pass "trace-tools (POSIX sh: sh -n is clean)"; else failc "trace-tools" "sh -n reports a syntax error"; fi
  tt_out=$(sh "$TT" "$TD" 2>&1); tt_rc=$?
  tt_l1=$(printf '%s\n' "$tt_out" | grep '^grandfather-xl-lookup[[:space:]]*with[[:space:]]*1[[:space:]]')
  tt_l2=$(printf '%s\n' "$tt_out" | grep '^grandfather-xl-lookup[[:space:]]*with[[:space:]]*2[[:space:]]')
  tt_grep=$(grep -o '"type":"tool_use"' "$TD/r1/out/trace.jsonl" | wc -l | tr -d ' ')
  # fields: case arm run passed tools tools_main agent in_tokens in_tokens_main cost
  if [ "$tt_rc" -eq 0 ] && printf '%s\n' "$tt_l1" | awk -v g="$tt_grep" '{ok = ($4=="pass" && $5==g && $5==3 && $6==2 && $7==1 && $8==3685 && $9==3130 && $10=="0.5000")} END{exit ok?0:1}' \
     && printf '%s\n' "$tt_l2" | awk '{ok = ($4=="fail" && $5==1 && $6==1 && $7==0 && $8==6 && $9==6 && $10=="0.2500")} END{exit ok?0:1}' \
     && [ "$(printf '%s\n' "$tt_out" | grep -c '^grandfather-xl-lookup')" -eq 2 ]; then
    pass "trace-tools (one line per run; tool calls = $tt_grep tool_use blocks, main/subagent split, tokens deduped per message, cost)"
  else failc "trace-tools" "exit $tt_rc, grep says $tt_grep; output: $(printf '%s' "$tt_out" | head -4 | tr '\n' '|')"; fi
fi

# 41. no-map-silent: the map is optional since 4.1.0 (decision 0001). In a project with no
# PROJECT_MAP.md and one open spec, the session hook prints the briefing and says nothing
# about a map — no nag, no "build one". The nag itself stays and still fires on a STALE map
# (check 3). No claude needed. Cites: map-on-trial/REQ-16
NMS="$WORK/no-map-silent"; mkdir -p "$NMS/.shipkit/specs/beta"
(cd "$NMS" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
bspec "$NMS" beta open 1 3
nms_out=$(cd "$NMS" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh" </dev/null 2>/dev/null)
# only the hook's own lines (^shipkit:) — the injected rule bodies legitimately mention the map
nms_lines=$(printf '%s\n' "$nms_out" | grep '^shipkit:')
if printf '%s\n' "$nms_lines" | grep -q '^shipkit: beta: 1 of 3 tasks done' \
   && ! printf '%s\n' "$nms_lines" | grep -qi 'PROJECT_MAP\|/shipkit:map\| map'; then
  pass "no-map-silent (no map + an open spec → the briefing line, not one hook line about a map)"
else failc "no-map-silent" "$(printf '%s' "$nms_lines" | head -6 | tr '\n' '|')"; fi

# 42. lint-negative: the two lint checks of 4.1.0 still FIRE. A copy of the working tree with
# a 60 KB file under evals/ and one "build the map first" line in the README must fail the lint
# with exactly those two errors (the gate's reviewer asked for a repeatable red, not a
# one-time one). No claude needed. Cites: map-on-trial/REQ-7 map-on-trial/REQ-15
LN="$WORK/lint-neg"; mkdir -p "$LN"
# only the repo-root .git and .claude (agent worktrees) are skipped; the overlays' .claude/ must copy
if command -v rsync >/dev/null 2>&1; then rsync -a --exclude /.git --exclude /.claude "$ROOT/" "$LN/"
else (cd "$ROOT" && tar cf - --exclude ./.git --exclude ./.claude .) | (cd "$LN" && tar xf -); fi
ln_clean=$(python3 "$LN/scripts/lint.py" 2>&1 | tail -1)
head -c 61440 /dev/zero | tr '\0' 'x' > "$LN/plugins/shipkit/evals/fixtures/oversize.txt"
printf '\nStart by building the map: run /shipkit:map first.\n' >> "$LN/README.md"
ln_out=$(python3 "$LN/scripts/lint.py" 2>&1)
if printf '%s\n' "$ln_clean" | grep -q '^lint: 0 error(s)' \
   && printf '%s\n' "$ln_out" | grep -q 'evals: [0-9,]* bytes; the limit is 131,072' \
   && printf '%s\n' "$ln_out" | grep -q 'README.md: line [0-9]*: presents the map as required or the first step' \
   && printf '%s\n' "$ln_out" | grep -q '^lint: 2 error(s)'; then
  pass "lint-negative (a 60 KB eval file and a 'build the map first' line → exactly those two lint errors; the clean copy → 0)"
else failc "lint-negative" "clean: [$ln_clean] doctored: $(printf '%s' "$ln_out" | grep 'ERROR\|^lint:' | tr '\n' '|')"; fi

# 43. with-rule: evals/lib/with-rule.sh <rule> installs ONE rule file into a workspace the way
# the installer would — a core rule at .claude/rules/shipkit/<rule>.md, a stack rule under
# .claude/rules/shipkit/<stack>/ — writes the manifest with the plugin version, and the marker
# .eval-rule that the hook reads (check 44). SHIPKIT_EVAL_NO_RULE=1 installs nothing;
# SHIPKIT_EVAL_RULE_REF=v3.7.0 installs the tag's text (git show, from this repository). The
# eval tool forwards no environment to a scaffold, so an ARM is selected by a scratch copy
# whose with-rule.sh sets the variable's default; the variables are for running by hand.
# Cites: rule-evals/REQ-1 rule-evals/REQ-2 rule-evals/REQ-3 rule-evals/REQ-4
WR="$COPY/evals/lib/with-rule.sh"
if [ ! -f "$WR" ]; then
  failc "with-rule" "evals/lib/with-rule.sh does not exist (check written first, by design)"
else
  wr_ok=1; wr_why=""
  sh -n "$WR" 2>/dev/null || { wr_ok=0; wr_why="$wr_why sh-n"; }
  W1="$WORK/wr-core"; mkdir -p "$W1"
  (cd "$W1" && git init -q && sh "$WR" dependencies --repo "$ROOT" >/dev/null 2>&1) || { wr_ok=0; wr_why="$wr_why core:exit"; }
  cmp -s "$W1/.claude/rules/shipkit/dependencies.md" "$COPY/rules/dependencies.md" || { wr_ok=0; wr_why="$wr_why core:content"; }
  [ "$(ls "$W1/.claude/rules/shipkit/" 2>/dev/null | grep -c '\.md$')" -eq 1 ] || { wr_ok=0; wr_why="$wr_why core:extra-files"; }
  grep -q "^version=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$COPY/.claude-plugin/plugin.json" | head -1)\$" "$W1/.claude/rules/shipkit/.installed" 2>/dev/null || { wr_ok=0; wr_why="$wr_why core:manifest-version"; }
  grep -q '	\.claude/rules/shipkit/dependencies\.md$' "$W1/.claude/rules/shipkit/.installed" 2>/dev/null || { wr_ok=0; wr_why="$wr_why core:manifest-path"; }
  [ "$(cat "$W1/.claude/rules/shipkit/.eval-rule" 2>/dev/null)" = ".claude/rules/shipkit/dependencies.md" ] || { wr_ok=0; wr_why="$wr_why core:marker"; }
  W2="$WORK/wr-stack"; mkdir -p "$W2"
  (cd "$W2" && git init -q && sh "$WR" gemfile --repo "$ROOT" >/dev/null 2>&1) || { wr_ok=0; wr_why="$wr_why stack:exit"; }
  cmp -s "$W2/.claude/rules/shipkit/rails/gemfile.md" "$COPY/stacks/rails/.claude/rules/gemfile.md" || { wr_ok=0; wr_why="$wr_why stack:content"; }
  grep -q '	\.claude/rules/shipkit/rails/gemfile\.md$' "$W2/.claude/rules/shipkit/.installed" 2>/dev/null || { wr_ok=0; wr_why="$wr_why stack:manifest"; }
  [ "$(cat "$W2/.claude/rules/shipkit/.eval-rule" 2>/dev/null)" = ".claude/rules/shipkit/rails/gemfile.md" ] || { wr_ok=0; wr_why="$wr_why stack:marker"; }
  W3="$WORK/wr-none"; mkdir -p "$W3"
  (cd "$W3" && git init -q && SHIPKIT_EVAL_NO_RULE=1 sh "$WR" dependencies --repo "$ROOT" >/dev/null 2>&1) || { wr_ok=0; wr_why="$wr_why none:exit"; }
  [ ! -e "$W3/.claude/rules" ] || { wr_ok=0; wr_why="$wr_why none:installed-something"; }
  W4="$WORK/wr-ref"; mkdir -p "$W4"
  (cd "$W4" && git init -q && SHIPKIT_EVAL_RULE_REF=v3.7.0 sh "$WR" dependencies --repo "$ROOT" >/dev/null 2>&1) || { wr_ok=0; wr_why="$wr_why ref:exit"; }
  git -C "$ROOT" show v3.7.0:plugins/shipkit/rules/dependencies.md > "$WORK/wr-ref-expected.md" 2>/dev/null
  cmp -s "$W4/.claude/rules/shipkit/dependencies.md" "$WORK/wr-ref-expected.md" || { wr_ok=0; wr_why="$wr_why ref:content"; }
  cmp -s "$W4/.claude/rules/shipkit/dependencies.md" "$COPY/rules/dependencies.md" && { wr_ok=0; wr_why="$wr_why ref:same-as-head"; }
  if [ "$wr_ok" -eq 1 ]; then pass "with-rule (one rule file as the installer writes it, manifest + marker; NO_RULE=1 → nothing; RULE_REF=v3.7.0 → the tag's text)"
  else failc "with-rule" "$wr_why"; fi
fi

# 44. eval-inject: the eval sandbox loads NOTHING from the workspace's .claude/ or CLAUDE.md
# (CLAUDE_CODE_DISABLE_CLAUDE_MDS=1; nonce-tested 2026-10-07; documented under "How runs are
# isolated"), so the rule under test reaches the model through the plugin's own hook:
# `inject-rule.sh --eval-rule` prints the file named by .claude/rules/shipkit/.eval-rule, and
# ONLY when the eval tool's own CLAUDE_CODE_EVAL_CONFINED=1 is set — a real project never
# takes the branch. Cites: rule-evals/REQ-21 rule-evals/REQ-22
EI="$COPY/scripts/inject-rule.sh"
EP="$WORK/ei"; mkdir -p "$EP/.claude/rules/shipkit"
printf 'Eval codeword: ZEBRA-4343.\n' > "$EP/.claude/rules/shipkit/migrations.md"
printf '.claude/rules/shipkit/migrations.md\n' > "$EP/.claude/rules/shipkit/.eval-rule"
ei_on=$(cd "$EP" && CLAUDE_CODE_EVAL_CONFINED=1 CLAUDE_PLUGIN_ROOT="$COPY" sh "$EI" --eval-rule 2>/dev/null)
ei_noenv=$(cd "$EP" && env -u CLAUDE_CODE_EVAL_CONFINED CLAUDE_PLUGIN_ROOT="$COPY" sh "$EI" --eval-rule 2>/dev/null)
rm -f "$EP/.claude/rules/shipkit/.eval-rule"
ei_nomark=$(cd "$EP" && CLAUDE_CODE_EVAL_CONFINED=1 CLAUDE_PLUGIN_ROOT="$COPY" sh "$EI" --eval-rule 2>/dev/null)
if printf '%s\n' "$ei_on" | grep -q 'ZEBRA-4343' && [ -z "$ei_noenv" ] && [ -z "$ei_nomark" ] \
   && grep -q -- 'inject-rule.sh\\" --eval-rule' "$COPY/hooks/hooks.json"; then
  pass "eval-inject (hook prints the marked rule only under CLAUDE_CODE_EVAL_CONFINED=1 with a marker; hooks.json carries the command)"
else failc "eval-inject" "on=[$(printf '%s' "$ei_on" | head -c 60)] noenv=[$(printf '%s' "$ei_noenv" | head -c 40)] nomark=[$(printf '%s' "$ei_nomark" | head -c 40)] hook=$(grep -c 'eval-rule' "$COPY/hooks/hooks.json")"; fi

# 45. stack-gen: evals/fixtures/stack-gen.sh <stack> writes the smallest project whose files
# match the stack's rule globs — nothing is run, the model edits and the grader reads. For
# each of the nine stacks with rules, every rule FILE has at least one generated file matching
# one of its `paths:` globs. Three shapes serve core rules sample-app cannot exercise: `static`
# (ui-ux.md), `monorepo` (monorepo.md), `rails` (migrations.md via db/migrate/).
# Cites: rule-evals/REQ-5 rule-evals/REQ-6
SG="$COPY/evals/fixtures/stack-gen.sh"
if [ ! -f "$SG" ]; then
  failc "stack-gen" "evals/fixtures/stack-gen.sh does not exist (check written first, by design)"
else
  sg_ok=1; sg_why=""
  sh -n "$SG" 2>/dev/null || { sg_ok=0; sg_why="$sg_why sh-n"; }
  [ "$(wc -c < "$SG")" -le 15360 ] || { sg_ok=0; sg_why="$sg_why size>15K"; }
  sg_match() {  # sg_match <dir> <rule-file...> → exit 0 when every rule file has a matching file
    python3 - "$@" <<'PY'
import sys, re, os
root = sys.argv[1]; rules = sys.argv[2:]
files = []
for d, _, fs in os.walk(root):
    for f in fs:
        rel = os.path.relpath(os.path.join(d, f), root)
        if not rel.startswith('.git'): files.append(rel)
def rx(g):
    out = ''; i = 0
    while i < len(g):
        if g.startswith('**/', i): out += '(?:.*/)?'; i += 3
        elif g.startswith('**', i): out += '.*'; i += 2
        elif g[i] == '*': out += '[^/]*'; i += 1
        elif g[i] == '?': out += '[^/]'; i += 1
        else: out += re.escape(g[i]); i += 1
    return re.compile('^' + out + '$')
bad = []
for r in rules:
    txt = open(r).read()
    m = re.match(r'---\n(.*?)\n---', txt, re.S)
    if not m: continue
    globs = re.findall(r'^\s*-\s*"([^"]+)"', m.group(1), re.M)
    if not any(rx(g).match(f) for g in globs for f in files): bad.append(os.path.basename(r))
if bad: print('no match for: ' + ' '.join(bad)); sys.exit(1)
PY
  }
  for st in elixir go hotwire liveview ml oban python rails react; do
    D="$WORK/sg-$st"; mkdir -p "$D"
    (cd "$D" && sh "$SG" "$st" >/dev/null 2>&1) || { sg_ok=0; sg_why="$sg_why $st:exit"; continue; }
    n=$(find "$D" -type f | wc -l | tr -d ' ')
    [ "$n" -ge 3 ] || { sg_ok=0; sg_why="$sg_why $st:$n-files"; }
    out=$(sg_match "$D" "$COPY"/stacks/$st/.claude/rules/*.md) || { sg_ok=0; sg_why="$sg_why $st:$out"; }
  done
  D="$WORK/sg-static"; mkdir -p "$D"; (cd "$D" && sh "$SG" static >/dev/null 2>&1) || { sg_ok=0; sg_why="$sg_why static:exit"; }
  out=$(sg_match "$D" "$COPY/rules/ui-ux.md") || { sg_ok=0; sg_why="$sg_why static:$out"; }
  D="$WORK/sg-monorepo"; mkdir -p "$D"; (cd "$D" && sh "$SG" monorepo >/dev/null 2>&1) || { sg_ok=0; sg_why="$sg_why monorepo:exit"; }
  out=$(sg_match "$D" "$COPY/rules/monorepo.md") || { sg_ok=0; sg_why="$sg_why monorepo:$out"; }
  out=$(sg_match "$WORK/sg-rails" "$COPY/rules/migrations.md") || { sg_ok=0; sg_why="$sg_why rails-migrations:$out"; }
  (cd "$WORK/sg-go" && sh "$SG" nosuchstack >/dev/null 2>&1) && { sg_ok=0; sg_why="$sg_why unknown-stack-exit-0"; }
  if [ "$sg_ok" -eq 1 ]; then pass "stack-gen (nine stacks match every rule file's globs; static → ui-ux, monorepo → monorepo, rails → migrations; ≤ 15 KB)"
  else failc "stack-gen" "$sg_why"; fi
fi

# 46. evals-group: scripts/evals.sh --group <name> runs only the cases named <name>-* (every
# case is named after its folder: rules-trivial, scoped-dependencies, stacks-gemfile); with
# no flag it still runs everything (B7). A stub `claude` on PATH echoes the arguments.
# Cites: rule-evals/REQ-7 rule-evals/REQ-8
EG="$WORK/eg-bin"; mkdir -p "$EG"
printf '#!/bin/sh\necho "$@"\n' > "$EG/claude"; chmod +x "$EG/claude"
eg_group=$(PATH="$EG:$PATH" sh "$ROOT/scripts/evals.sh" --group stacks 2>&1)
eg_all=$(PATH="$EG:$PATH" sh "$ROOT/scripts/evals.sh" 2>&1)
eg_case=$(PATH="$EG:$PATH" sh "$ROOT/scripts/evals.sh" --case hello 2>&1)
if printf '%s\n' "$eg_group" | grep -q -- '--case stacks-\*' && ! printf '%s\n' "$eg_group" | grep -q -- '--group' \
   && ! printf '%s\n' "$eg_all" | grep -q -- '--case' && printf '%s\n' "$eg_all" | grep -q -- '--scaffold' \
   && printf '%s\n' "$eg_case" | grep -q -- '--case hello'; then
  pass "evals-group (--group stacks → --case 'stacks-*'; no flag → every case; --case still passes through)"
else failc "evals-group" "group=[$(printf '%s' "$eg_group" | head -c 120)] all=[$(printf '%s' "$eg_all" | head -c 80)]"; fi

echo
if [ "$fail" -eq 0 ]; then echo "smoke: all checks passed"; else echo "smoke: FAILURES above"; fi
exit $fail
