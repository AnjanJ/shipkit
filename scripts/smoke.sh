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
# except that the session hook writes ~/.claude/shipkit/plugin-root.dev (a scratch copy is not
# an installed root, 4.12.0) and plugin-root only while none exists: the runner saves both
# before the first session and restores it on exit, on every exit path; a session
# started during a run reads the scratch root only through plugin-root.dev (harness-debts/REQ-7).
# Exit status: 0 if every check passes, 1 otherwise. Set SMOKE_KEEP=1 to keep the scratch dir.
# Set SMOKE_TIMING=report to print check 30's fifty-spec time without failing on it (CI does).

ROOT=$(cd "$(dirname "$0")/.." && pwd)
# Since 3.0 the repo is a marketplace of plugins; the smoke test exercises the CORE plugin
# (it owns the hook, the rules, the stacks and the install scripts).
CORE="$ROOT/plugins/shipkit"

# Arguments (spec: .shipkit/specs/honest-evidence/; check 97 holds them):
#   --no-model          leave out every check that starts a model; `claude` is not needed
#   --only <n>[,<n>]    of the checks that start a model, run only these and the ones they need;
#                       every check that needs no model still runs
#   --list              print RUN or SKIP for each numbered check, as the other arguments decide,
#                       and run nothing
# A wrong argument, a number --only does not take, or --no-model with --only: usage, exit 64.
MODEL_CHECKS="1 2 3 4 5 5b 6 22 23 29 31 32 50 54 64"   # the numbered checks that start `claude`
NEEDS="32:31"   # <check>:<the check whose model session wrote a file it reads>
usage() { echo "usage: smoke.sh [--no-model | --only <n>[,<n>]] [--list]" >&2; exit 64; }
NO_MODEL=0; ONLY=""; LIST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --no-model) NO_MODEL=1 ;;
    --only) [ $# -ge 2 ] || usage; ONLY=$2; shift ;;
    --list) LIST=1 ;;
    *) usage ;;
  esac
  shift
done
[ "$NO_MODEL" -eq 1 ] && [ -n "$ONLY" ] && usage
ONLY_SET=""
for o in $(printf '%s' "$ONLY" | tr ',' ' '); do
  case " $MODEL_CHECKS " in
    *" $o "*) ONLY_SET="$ONLY_SET $o" ;;
    *) echo "smoke: --only takes the checks that start a model: $MODEL_CHECKS" >&2; exit 64 ;;
  esac
  for need in $NEEDS; do [ "${need%%:*}" = "$o" ] && ONLY_SET="$ONLY_SET ${need#*:}"; done
done

# The registry: every numbered check's label and one short name, in the file's order. --list
# and the SKIP lines print from it; check 97 fails if a "# <label>. " header has no line here.
registry() { cat <<'EOF'
1 rules-inject
2 rules-skip
3 plugin-root
4 agents
5 workflows-skills
5b namespaces
6 hook-cap
7 install-scripts
8 stale-nudge
8b incomplete-install
8c reconciliation
8d legacy-stamp
8e unstamped
9 stack-section
10 freshness
11 spec-staleness
9b user-skill
9c managed-block
11b staleness-day
17 unsetup
18 commit-guard
19 spec-check-reqs
20 spec-check-tasks
21 spec-drift
22 spec-new-format
23 product-file
24 registry-columns
25 brief
26 brief-verify
27 reviewer-tools
28 as-shipped
29 ship-gate
30 briefing
31 handoff-file
32 handoff-loop
33 compact-reminder
34 fired-if-template
35 decision-check
36 portfolio-digest
37 digest-old
38 ledger-gen
39 xl-scaffold
40 trace-tools
41 no-map-silent
42 lint-negative
43 with-rule
44 eval-inject
45 stack-gen
46 evals-group
47 rule-cases
48 pending-test
49 pre33-specs
50 headless-questions
51 version-and-goal
52 fired-if-early
53 shipkit-allowed
54 scoped-loading
55 spec-check-draft
56 plugin-root-restore
57 dotfile-paragraph
58 cuts-recorded
59 portfolio-gen
60 heading-seen
61 same-named
62 plugin-root-installed
63 context-cost
64 opt-out
65 skills-merged
66 agents-four
67 skills-flag
68 appends-trimmed
69 skills-cut
70 report-shapes
71 brief-cites
72 stack-skill-allowed
73 reviewer-skills
74 ship-capture
75 setup-rule-count
76 ship-retry
77 reviewer-fixture
78 map-read-grep
79 django-only
80 stamp-dates
81 section-clean
82 fired-if-tracked
83 superseded-report
84 walk-sentence
85 ship-write-path
86 elixir-app
87 stray-status
88 setup-files
89 reviewer-marks
90 pinned-toolchain
91 git-grep
92 wait-probe
93 stale-nesting
94 goldfish-agent
95 spec-goldfish-step
96 goldfish-fixture
97 smoke-args
98 ci-smoke-job
99 evidence-line
100 tests-line
101 skipped-cite
102 spec-diff
103 spec-edited
104 text-label
105 timing-switch
106 test-command
107 ship-check
108 release-check
109 judge
110 eval-ledger
111 ledger-backfill
112 briefing-cost
113 evals-for-diff
114 eval-room
115 ledger-fired-if
116 holdout-kept-out
117 grader-both-ways
118 reviewer-trees
119 checks-match
120 escape-second
121 briefing-commands
122 kind-fixtures
123 kind-reader
124 prop
125 prop-ci
126 red-check
127 brief-escapes
128 verify-run
129 verify-run-ten
130 verify-skills
131 commit-gate
132 commit-gate-hook
133 trim-audit
EOF
}
is_model() { case " $MODEL_CHECKS " in *" $1 "*) return 0 ;; esac; return 1; }
runs_model() {  # runs_model <label> → 0 when this check that starts a model is to run
  [ "$NO_MODEL" -eq 1 ] && return 1
  [ -z "$ONLY_SET" ] && return 0
  case " $ONLY_SET " in *" $1 "*) return 0 ;; esac
  return 1
}
if [ "$LIST" -eq 1 ]; then
  registry | while read -r lab name; do
    if is_model "$lab" && ! runs_model "$lab"; then echo "SKIP $lab $name"; else echo "RUN $lab $name"; fi
  done
  exit 0
fi
if [ "$NO_MODEL" -eq 0 ]; then
  command -v claude >/dev/null 2>&1 || { echo "smoke: \`claude\` not on PATH (--no-model runs the checks that need none)" >&2; exit 1; }
fi

WORK=$(mktemp -d) || exit 1
# ~/.claude/shipkit/plugin-root: a session below writes it only while it is absent (4.12.0;
# until 4.11.0 every one rewrote it) and plugin-root.dev every time; save both now, put both
# back on exit (harness-debts/REQ-6). Functions, so check 56 can test them; the .dev path is
# derived from PR_FILE so a check that points PR_FILE at a scratch HOME covers both.
PR_FILE="$HOME/.claude/shipkit/plugin-root"
pr_save() {
  if [ -f "$PR_FILE" ]; then PR_SAVED=$(cat "$PR_FILE"); PR_HAD=1; else PR_SAVED=""; PR_HAD=0; fi
  if [ -f "$PR_FILE.dev" ]; then PRD_SAVED=$(cat "$PR_FILE.dev"); PRD_HAD=1; else PRD_SAVED=""; PRD_HAD=0; fi
}
pr_restore() {
  if [ "$PR_HAD" = 1 ]; then mkdir -p "${PR_FILE%/*}" && printf '%s\n' "$PR_SAVED" > "$PR_FILE"; else rm -f "$PR_FILE"; fi
  if [ "$PRD_HAD" = 1 ]; then mkdir -p "${PR_FILE%/*}" && printf '%s\n' "$PRD_SAVED" > "$PR_FILE.dev"; else rm -f "$PR_FILE.dev"; fi
}
pr_save
trap 'pr_restore; [ -n "$SMOKE_KEEP" ] || rm -rf "$WORK"' EXIT
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
# Counts are kept in a file, one letter a line, so a pass inside a subshell is still counted.
COUNTS="$WORK/.counts"; : > "$COUNTS"
pass() { echo "PASS  $1"; echo p >> "$COUNTS"; }
# passt: a pass whose assertion only read the wording of a skill, an agent or a rule. It shows
# the words are there, not that a model follows them (honest-evidence/REQ-32, check 104).
passt() { echo "PASS  [text] $1"; echo p >> "$COUNTS"; echo t >> "$COUNTS"; }
failc() { echo "FAIL  $1 — $2"; fail=1; echo f >> "$COUNTS"; }
model_check() {  # model_check <label> → 0: run this check's model part; 1: skipped, and said so
  if runs_model "$1"; then return 0; fi
  echo "SKIP  [model] $1 $(registry | awk -v l="$1" '$1 == l { print $2 }')"; echo s >> "$COUNTS"
  return 1
}
summary_lines() {  # summary_lines <passed> <text-only> <skipped> <failed> → the suite's last two lines
  echo "smoke: $1 passed ($2 text-only), $3 skipped (model), $4 failed"
  if [ "$4" -gt 0 ]; then echo "smoke: FAILURES above"
  elif [ "$3" -gt 0 ]; then echo "smoke: all checks run passed; $3 skipped (model)"
  else echo "smoke: all checks passed"; fi
}
# Under --no-model a stand-in `claude` goes first on the PATH and writes down every call. The
# suite's last assertion reads that file: it must be empty (honest-evidence/REQ-1).
if [ "$NO_MODEL" -eq 1 ]; then
  mkdir -p "$WORK/stub"
  printf '#!/bin/sh\nprintf "%%s\\n" "$*" >> "%s"\nexit 97\n' "$WORK/claude-calls.log" > "$WORK/stub/claude"
  chmod +x "$WORK/stub/claude"
  PATH="$WORK/stub:$PATH"; export PATH
fi
ask() {  # ask <plugin-dir> <prompt>  → last line of the model's reply, run inside $PROJ
  (cd "$PROJ" && claude --plugin-dir "$1" --model haiku -p "$2 Do not use tools." 2>/dev/null | tail -20)
}
CW_Q='Reply with ONLY every codeword of the form ZEBRA-<digits> that appears anywhere in your context, comma-separated, or exactly NONE.'

# 1. rules-inject: a codeword appended to a rule is visible in a fresh session.
# $PROJ has opted in (an empty .shipkit/): since 5.0.0 the hook injects spec-driven and
# decisions only where a project has .shipkit/ or installed rules (W1; check 64 is the
# other state). Cites: always-on/REQ-5
printf '\n\nSmoke codeword: ZEBRA-1001.\n' >> "$COPY/rules/decisions.md"
rm -rf "$PROJ/.claude"; mkdir -p "$PROJ/.shipkit"
if model_check 1; then
out=$(ask "$COPY" "$CW_Q")
case "$out" in *ZEBRA-1001*) pass "rules-inject (always-on rule reaches a fresh session via the hook)";;
  *) failc "rules-inject" "codeword not seen: $out";; esac
fi  # /model_check 1

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
if model_check 2; then
out=$(ask "$COPY" "$CW_Q")
case "$out" in
  *ZEBRA-1001*) failc "rules-skip" "hook injected the plugin's copy although the rule is installed: $out";;
  *ZEBRA-2002*) pass "rules-skip (installed rule loads from disk; hook does not double-inject)";;
  *) failc "rules-skip" "neither codeword reached context — the installed rule did not load: $out";;
esac
fi  # /model_check 2

rm -rf "$PROJ/.claude"

# 3. plugin-root: the root line is in context and names the scratch copy
if model_check 3; then
out=$(ask "$COPY" 'If a line of the form "shipkit: plugin root is <path>" is in your context, reply with just the path; else NONE.')
case "$out" in *"$COPY"*) pass "plugin-root (hook publishes the plugin root)";;
  *) failc "plugin-root" "got: $out";; esac
fi  # /model_check 3

# 4. agents: exactly the agents defined under agents/*.md, nothing else
expected=$(ls "$CORE"/agents/*.md | sed 's#.*/##; s/\.md$//' | sort | tr '\n' ' ')
if model_check 4; then
out=$(ask "$COPY" 'List the exact names of every agent type available to you that starts with "shipkit:", one per line, nothing else.')
got=$(printf '%s\n' "$out" | grep -o 'shipkit:[a-z-]*' | sed 's/shipkit://' | sort -u | tr '\n' ' ')
if [ "$got" = "$expected" ]; then pass "agents (registered set = $expected)"; else failc "agents" "expected [$expected] got [$got]"; fi
fi  # /model_check 4

# 5. workflows-skills: the workflows plugin's skills register (the knowledge base this check
# used to look for was cut in 4.0; `humanize` is the skill with the most distinctive name)
if model_check 5; then
out=$(ask "$ROOT/plugins/shipkit-workflows" 'List the exact names of every skill available to you whose name contains "humanize", one per line, or NONE.')
case "$out" in *humanize*) pass "workflows-skills (a shipkit-workflows skill is registered)";;
  *) failc "workflows-skills" "got: $out";; esac
fi  # /model_check 5

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
if model_check 5b; then
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
fi  # /model_check 5b

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
if model_check 6; then
out=$(ask "$WORK/cap-ok" "$CW_Q")
case "$out" in *ZEBRA-9500*) pass "hook-cap (9.5K of hook output still reaches context)";;
  *) failc "hook-cap" "9.5K hook output no longer reaches context — the per-hook cap shrank; split the rules further";; esac
out=$(ask "$WORK/cap-over" "$CW_Q")
case "$out" in *ZEBRA-11000*) echo "INFO  hook-cap: 11K of hook output now reaches context — the cap was raised; inject-rule.sh could be simplified";;
  *) pass "hook-cap (11K is still cut, as assumed)";; esac
fi  # /model_check 6

# 7. install-scripts: deterministic installs produce the expected tree with no placeholders
IP="$WORK/install-proj"; mkdir -p "$IP"; printf '# demo\n' > "$IP/CLAUDE.md"
if sh "$COPY/scripts/install-rules.sh" "$COPY" "$IP" >/dev/null \
   && sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" rails "$IP" TEST_COMMAND="bundle exec rspec" TEST_FRAMEWORK=RSpec DATABASE=PostgreSQL RAILS_ARCHITECTURE=MVC API_MODE=no FRONTEND=Hotwire >/dev/null; then
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
sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" python "$PY" TEST_COMMAND=pytest $pyargs >/dev/null 2>&1
printf '\nPROSE-AFTER\n' >> "$PY/CLAUDE.md"
# shellcheck disable=SC2086
sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" python "$PY" TEST_COMMAND="uv run pytest" $pyargs >/dev/null 2>&1
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
sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" python "$UP" TEST_COMMAND=pytest $pyargs >/dev/null 2>&1
mine=$(count 'MY-OWN-SKILL' "$UP/.claude/skills/new-feature/SKILL.md")
owned=$(count 'skills/new-feature/SKILL.md' "$UP/.claude/rules/shipkit/.installed")
# shellcheck disable=SC2086
SHIPKIT_OVERWRITE_SKILLS=1 sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" python "$UP" TEST_COMMAND=pytest $pyargs >/dev/null 2>&1
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
err=$(sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" python "$PY" TEST_COMMAND="poetry run pytest" $pyargs 2>&1 >/dev/null)
kept=$(count 'USER-EDIT-INSIDE' "$PY/CLAUDE.md")
early=$(count 'poetry run pytest' "$PY/CLAUDE.md")
case "$err" in *"-USER-EDIT-INSIDE"*SHIPKIT_REFRESH_CLAUDE_MD*) diffed=1;; *) diffed=0;; esac
# shellcheck disable=SC2086
SHIPKIT_REFRESH_CLAUDE_MD=1 sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" python "$PY" TEST_COMMAND="poetry run pytest" $pyargs >/dev/null 2>&1
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
  sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" python "$_p" TEST_COMMAND=pytest \
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
  # Cites: running-the-change/REQ-35. The hook docs do not promise compact JSON, and their
  # example is indented: the same call, indented, must still look at the project it names.
  rc=$(printf '{\n  "hook_event_name": "PreToolUse",\n  "cwd": "%s",\n  "tool_name": "Bash",\n  "tool_input": {\n    "command": "git commit -m wip"\n  }\n}\n' "$GP" \
    | (cd "$WORK" && sh "$GUARD" 2>"$WORK/guard.err"); echo $?)
  if [ "$rc" -eq 2 ] && grep -q 'config/server.key' "$WORK/guard.err"; then
    pass "guard-commit (indented hook JSON names the project → exit 2)"
  else failc "guard-commit" "indented JSON: exit $rc, want 2 naming config/server.key"; fi
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
# ...and an entry that starts or ends with the letter t is read as it is written. BSD sed reads
# [ \t] as a space, a backslash or the letter t, so the hook trimmed tests/ to ests/ and
# notes.txt to notes.tx, and counted commits on paths that do not exist (found in Sprint 29).
# Cites: gate-as-software/REQ-1 spec-contract/REQ-16
mkdir -p "$DP/tests"; dspec tpaths open "tests/, notes.txt"
dcommit tests 19
printf 'n\n' >> "$DP/notes.txt"; (cd "$DP" && git add notes.txt && git -c user.email=s@s -c user.name=s commit -q -m notes)
out=$(dhook)
case "$out" in
  *"tpaths/spec.md: 20 commits have touched its paths since it was accepted"*)
    pass "spec-drift-paths (Paths entries that start and end with t → counted as written, 20 commits)";;
  *) failc "spec-drift-paths" "Paths 'tests/, notes.txt': the 20 commits that touch them were not counted: $out";;
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
if model_check 22; then
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
fi  # /model_check 22
# the always-on rule tells every session how a test cites a requirement, inside the budget
# (the same byte assertion is what proves product-intake-brief/REQ-28 after S3-T6's sentence)
if grep -q 'REQ-N' "$COPY/rules/spec-driven.md" && grep -q '/REQ-N' "$COPY/rules/spec-driven.md" \
   && [ "$(cat "$CORE/rules/shipkit.md" "$CORE/rules/spec-driven.md" "$CORE/rules/decisions.md" | wc -c | tr -d ' ')" -le 3000 ]; then
  passt "spec-new-format (the spec-driven rule names the <feature>/REQ-N citation; rules within 3,000 bytes)"
else failc "spec-new-format" "the citation sentence is missing from the rule, or the always-on rules exceed 3,000 bytes"; fi

# 23. product-file: /shipkit:product writes the product file in its fixed shape
# (spec: .shipkit/specs/product-intake-brief/). Cites: product-intake-brief/REQ-1
# product-intake-brief/REQ-2
# Like check 22 this asks a model (sonnet) to do real work: the skill runs headless in a copy
# of the eval fixture with its answers given up front — FOUR goals on purpose, one with no
# metric — and the file it writes is then read here, not taken on the model's word.
PF="$WORK/product"; mkdir -p "$PF"; cp -R "$COPY/evals/fixtures/sample-app/." "$PF/"
(cd "$PF" && git init -q && git add -A && git -c user.email=s@s -c user.name=s commit -q -m init)
if model_check 23; then
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
fi  # /model_check 23

# 24. registry-columns: the registry template and eve know the product columns and studio.md
# (spec: .shipkit/specs/product-intake-brief/). No claude needed — these are the files a
# session reads. Cites: product-intake-brief/REQ-8 product-intake-brief/REQ-10
rc_head=$(grep -m1 '^| Project | Path ' "$COPY/skills/map/SKILL.md")
case "$rc_head" in
  *"| Product | Top Goal |"*) passt "registry-columns (registry template has Product and Top Goal)";;
  *) failc "registry-columns" "the template header lacks the two columns: $rc_head";;
esac
if grep -q 'studio\.md' "$COPY/agents/eve.md" && grep -q '`Product`' "$COPY/agents/eve.md" \
   && grep -q '`Top Goal`' "$COPY/agents/eve.md"; then
  passt "registry-columns (eve names studio.md and both columns)"
else failc "registry-columns" "agents/eve.md does not name studio.md, Product and Top Goal"; fi

# 25. brief: a task becomes a brief, built by a script from the spec, with no model
# (spec: .shipkit/specs/product-intake-brief/). Cites: product-intake-brief/REQ-18
# product-intake-brief/REQ-19 product-intake-brief/REQ-20 product-intake-brief/REQ-21
# product-intake-brief/REQ-22 product-intake-brief/REQ-23 decisions-bind/REQ-1 decisions-bind/REQ-2
# decisions-bind/REQ-3 decisions-bind/REQ-14
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
     && printf '%s\n' "$out" | grep -q 'Describe refunds in one README section' \
     && ! printf '%s\n' "$out" | grep -q 'Old ledger idea' \
     && printf '%s\n' "$out" | grep -q 'app/billing/refunds.py' \
     && printf '%s\n' "$out" | grep -q 'test_refund_over_charge_is_rejected' \
     && printf '%s\n' "$out" | grep -q 'Refunds in a second currency' \
     && printf '%s\n' "$out" | grep -q 'Shop owners ask for this weekly' \
     && printf '%s\n' "$out" | grep -q '^RESULT: done | blocked$'; then
    pass "brief (goal, files, test, every live decision, scope and report form all present; superseded decision left out)"
  else failc "brief" "a section is wrong: $out"; fi
  # The tree is dirty here (the spec files are untracked until check 26 commits them): one
  # stderr line says how many files already differ from HEAD, and the brief on stdout is the
  # same one a clean tree prints (compared in check 26). A project that is not a repository
  # gets no line. Cites: run-debts/REQ-5
  bp_dirty=$(cd "$BP" && git status --short -uall | grep -c .)
  printf '%s\n' "$out" > "$WORK/brief.dirty.out"
  if [ "$bp_dirty" -gt 0 ] && [ "$(grep -c 'already differ from HEAD' "$WORK/brief.err")" -eq 1 ] \
     && grep -q "^brief: $bp_dirty file(s) already differ from HEAD; brief-verify will count them\$" "$WORK/brief.err" \
     && ! printf '%s\n' "$out" | grep -q 'already differ'; then
    pass "brief (a dirty tree at hand-over → one stderr line with the count, $bp_dirty here; nothing on stdout)"
  else failc "brief" "dirty tree ($bp_dirty files): stderr [$(cat "$WORK/brief.err")]"; fi
  BNR="$WORK/brief-norepo"; mkdir -p "$BNR" && cp -R "$BP/.shipkit" "$BNR/"
  out=$(sh "$BRIEF" "$BNR" refunds T3 2>"$WORK/brief.err"); rc=$?
  if [ "$rc" -eq 0 ] && ! grep -q 'differ' "$WORK/brief.err" && [ "$out" = "$(cat "$WORK/brief.dirty.out")" ]; then
    pass "brief (not a git repository → no line, the same brief)"
  else failc "brief" "no repo: exit $rc, stderr [$(cat "$WORK/brief.err")]"; fi
  # A list of decisions reads as a list of work unless the brief says otherwise: 9 of 10 runs of
  # brief/binds built later tasks' work inside T1 "to follow the binding decisions".
  if printf '%s\n' "$out" | grep -q '^These limit how you do this task\. They are not extra work: build only what your requirements ask, and contradict none of them\.$'; then
    pass "brief (above the list: a decision limits how the task is done and is not extra work)"
  else failc "brief" "the sentence above the list is missing: $out"; fi
  # No live decision says so, whether design.md holds only a superseded record or does not exist.
  BND="$WORK/brief-nodecision"; mkdir -p "$BND" && cp -R "$BP/.shipkit" "$BND/"
  printf '## Decision: Gone   (→ REQ-2)\n\n> **Superseded on 2026-10-05** by nothing.\n' > "$BND/.shipkit/specs/refunds/design.md"
  bnd_superseded=$(sh "$BRIEF" "$BND" refunds T3 2>/dev/null)
  rm "$BND/.shipkit/specs/refunds/design.md"
  bnd_absent=$(sh "$BRIEF" "$BND" refunds T3 2>/dev/null)
  if printf '%s\n' "$bnd_superseded" | grep -q '^None recorded for this feature\.$' \
     && ! printf '%s\n' "$bnd_superseded" | grep -q 'Gone\|These limit' \
     && printf '%s\n' "$bnd_absent" | grep -q '^None recorded for this feature\.$'; then
    pass "brief (no live decision, or no design.md → says none is recorded for this feature)"
  else failc "brief" "no live decision: [$bnd_superseded]"; fi
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
  # the tree is clean now: brief.sh prints no line, and the same brief as on the dirty tree
  # (check 25). Cites: run-debts/REQ-5
  out=$(sh "$BRIEF" "$BP" refunds T3 2>"$WORK/brief.err"); rc=$?
  if [ "$rc" -eq 0 ] && [ ! -s "$WORK/brief.err" ] && [ "$out" = "$(cat "$WORK/brief.dirty.out")" ]; then
    pass "brief (a clean tree at hand-over → nothing on stderr; the brief is byte-identical to the dirty tree's)"
  else failc "brief" "clean tree: exit $rc, stderr [$(cat "$WORK/brief.err")], stdout differs: $(printf '%s\n' "$out" | diff - "$WORK/brief.dirty.out" | head -3)"; fi
  # a. only allowed files: one committed, one left uncommitted, plus the task's own tick box
  printf 'x\n' > "$BP/app/billing/refunds.py"
  (cd "$BP" && git add app/billing/refunds.py && git -c user.email=s@s -c user.name=s commit -q -m work)
  printf 'y\n' > "$BP/tests/test_refunds.py"
  sed 's/- \[ \] \*\*T3\*\*/- [x] **T3**/' "$BP/.shipkit/specs/refunds/tasks.md" > "$WORK/bv.tmp" && mv "$WORK/bv.tmp" "$BP/.shipkit/specs/refunds/tasks.md"
  out=$(sh "$BV" "$BP" refunds T3 "$bv_base" 2>&1); rc=$?
  if [ "$rc" -eq 0 ] && ! printf '%s\n' "$out" | grep -q '^OUTSIDE'; then
    pass "brief-verify (only allowed files changed, committed and not → exit 0)"
  else failc "brief-verify" "allowed only: exit $rc: $out"; fi
  # b. one extra tracked file — another spec's spec.md (since 4.5.0 the spec's OWN folder is
  # allowed, check 53; another spec's folder is still outside)
  printf 'z\n' >> "$BP/.shipkit/specs/old/spec.md"
  out=$(sh "$BV" "$BP" refunds T3 "$bv_base" 2>&1); rc=$?
  if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q '^OUTSIDE .shipkit/specs/old/spec.md$' \
     && ! printf '%s\n' "$out" | grep -q 'OUTSIDE app/billing/refunds.py'; then
    pass "brief-verify (a changed tracked file outside the list → OUTSIDE, exit 1)"
  else failc "brief-verify" "extra file: exit $rc: $out"; fi
  (cd "$BP" && git checkout -q -- .shipkit/specs/old/spec.md)
  # c. a new untracked file outside the list
  printf 'n\n' > "$BP/app/notes.txt"
  out=$(sh "$BV" "$BP" refunds T3 "$bv_base" 2>&1); rc=$?
  if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q '^OUTSIDE app/notes.txt$'; then
    pass "brief-verify (a new untracked file outside the list → OUTSIDE, exit 1)"
  else failc "brief-verify" "untracked: exit $rc: $out"; fi
  rm -f "$BP/app/notes.txt"
  # c2. setup's own directories are never OUTSIDE; CLAUDE.md and .gitignore still are (the
  # second real run's gate called all four "beyond the spec", field-notes-4.9.md §9.4).
  # Cites: run-debts/REQ-6
  mkdir -p "$BP/.claude/rules/shipkit" "$BP/.shipkit-baseline"
  printf 'r\n' > "$BP/.claude/rules/shipkit/testing.md"; printf 'b\n' > "$BP/.shipkit-baseline/CLAUDE.md"
  printf 'c\n' > "$BP/CLAUDE.md"; printf '.shipkit-backup-*/\n' > "$BP/.gitignore"
  out=$(sh "$BV" "$BP" refunds T3 "$bv_base" 2>&1); rc=$?
  if [ "$rc" -eq 1 ] && [ "$(printf '%s\n' "$out" | grep -c '^OUTSIDE')" -eq 2 ] \
     && printf '%s\n' "$out" | grep -q '^OUTSIDE CLAUDE.md$' && printf '%s\n' "$out" | grep -q '^OUTSIDE .gitignore$'; then
    pass "brief-verify (setup's .claude/rules/shipkit/ and .shipkit-baseline/ → not OUTSIDE; CLAUDE.md and .gitignore → OUTSIDE still)"
  else failc "brief-verify" "setup files: exit $rc: $out"; fi
  rm -rf "$BP/.claude" "$BP/.shipkit-baseline" "$BP/CLAUDE.md" "$BP/.gitignore"
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
  passt "reviewer-tools (tools = Read, Glob, Grep, Bash; Edit, Write and Agent denied)"
else failc "reviewer-tools" "tools=[$rv_tools] disallowedTools=[$rv_deny]"; fi
# A MET citation's line number is the working tree's, as `grep -n` prints it — never a position
# inside a diff hunk: the second real run's reviewer cited accounts.ex:18-23 for a function at
# line 605 (field-notes-4.9.md §9.1). Cites: run-debts/REQ-8
rv_met=$(awk '/^3\. \*\*One verdict for every requirement/ { on = 1 } /^4\. / { on = 0 } on' "$rv")
if printf '%s\n' "$rv_met" | grep -q 'grep -n' && printf '%s\n' "$rv_met" | grep -qi 'working tree' \
   && printf '%s\n' "$rv_met" | grep -qi 'diff'; then
  pass "reviewer-tools (a MET citation's path:line is the working tree's, as grep -n prints it, never a diff position)"
else failc "reviewer-tools" "agents/reviewer.md step 3 does not say where a line number comes from"; fi

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
# The gate ends with rm -f "${TMPDIR:-/tmp}"/shipkit-ship-*.out. Run in the caller's TMPDIR, the
# nested gate deleted the scratch files of a gate running at the same time: the spec-goldfish
# gate lost its test output, review and status capture that way (2026-11-08). A scratch file of
# that name in the caller's TMPDIR must still be there after the runs, so the nested gate gets
# its own TMPDIR, and its own scratch files are looked for there.
SG_SENT="${TMPDIR:-/tmp}/shipkit-ship-smoke-sentinel-$$.out"; : > "$SG_SENT"
SG_TMP="$WORK/ship-tmp"; mkdir -p "$SG_TMP"
# No .gitignore on purpose: the gate's own test run leaves __pycache__/ behind, and a gate that
# then called the tree dirty would fail every Python project on its own step 2.
if model_check 29; then
shiprun() {
  (cd "$SG" && TMPDIR="$SG_TMP" claude --plugin-dir "$COPY" --model sonnet \
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
# The reviewer's reply is pasted, not condensed: step 4 writes it to shipkit-ship-review.out
# and pastes from the file, as step 2 does for tests (gate-blind-spots REQ-9 asked for the
# reply pasted; 4.7.0's and 4.9.0's gates summarised it). The report's review block holds the
# reviewer's heading, one row per requirement of the fixture's spec, the count line and the
# verdict line, as the agent's fixed shape prints them. Cites: run-debts/REQ-9
sg_rev=$(awk '/^### 4\. / { on = 1; next } /^### 5\. / { on = 0 } on' "$sg_report" 2>/dev/null)
sg_miss=""
printf '%s\n' "$sg_rev" | grep -q '^## Review: refunds against' || sg_miss="$sg_miss [## Review: heading]"
for r in 1 2 3; do printf '%s\n' "$sg_rev" | grep -Eq "^\| *REQ-$r( \(waived\))? *\|" || sg_miss="$sg_miss [REQ-$r row]"; done
printf '%s\n' "$sg_rev" | grep -q '^Requirements: [0-9]* MET' || sg_miss="$sg_miss [Requirements: count line]"
printf '%s\n' "$sg_rev" | grep -q '^VERDICT: PASS$' || sg_miss="$sg_miss [VERDICT line]"
grep -q 'shipkit-ship-review.out' "$COPY/skills/ship/SKILL.md" || sg_miss="$sg_miss [SKILL.md names no review file]"
[ -z "$(ls "$SG_TMP"/shipkit-ship-*.out 2>/dev/null)" ] || sg_miss="$sg_miss [scratch files left: $(ls "$SG_TMP"/shipkit-ship-*.out | tr '\n' ' ')]"
[ -f "$SG_SENT" ] || sg_miss="$sg_miss [the nested gate deleted a scratch file in the caller's TMPDIR]"
if [ -z "$sg_miss" ]; then
  pass "ship-gate (step 4 pastes the reviewer's reply from shipkit-ship-review.out: heading, three REQ rows, count line and verdict line verbatim; no scratch file left)"
else failc "ship-gate" "the review block is condensed or the file is not named:$sg_miss"; fi
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
fi  # /model_check 29
rm -f "$SG_SENT"

# 30. briefing: a few lines at session start saying where things stand
# (spec: .shipkit/specs/briefing-and-handoff/). No claude needed. Cites: briefing-and-handoff/REQ-1
# briefing-and-handoff/REQ-2 briefing-and-handoff/REQ-3 briefing-and-handoff/REQ-4
# briefing-and-handoff/REQ-5 briefing-and-handoff/REQ-6 briefing-and-handoff/REQ-7
# briefing-and-handoff/REQ-8 briefing-and-handoff/REQ-9
BRF="$COPY/scripts/briefing.sh"
brief() { (cd "$1" && sh "$BRF" 2>"$WORK/brief.err"); echo "rc=$?" >> "$WORK/brief.err"; }
# brief50_verdict <lines> <bytes> <cpu seconds> <runs> → the one PASS or FAIL line of part c
# below, the fifty-spec briefing. Check 105 runs it on given numbers. With SMOKE_TIMING=report
# a time of a second or more is printed and not failed: the limit was set on the owner's
# machine and a shared CI runner is slower (honest-evidence/design.md, seventh record). The
# line and byte limits are held either way.
brief50_verdict() {
  if [ "$1" -le 8 ] && [ "$2" -le 800 ] && [ "$(printf '%s' "$3" | cut -d. -f1)" -eq 0 ]; then
    pass "briefing (50 open specs → $1 lines, $2 bytes, ${3}s of CPU, best of $4 run(s))"
  elif [ "$1" -le 8 ] && [ "$2" -le 800 ] && [ "${SMOKE_TIMING:-}" = report ]; then
    pass "briefing (50 open specs → $1 lines, $2 bytes; ${3}s of CPU, best of $4 run(s), is over the 1 s limit: reported, not enforced, SMOKE_TIMING=report)"
  else failc "briefing" "50 specs: $1 lines, $2 bytes, ${3}s of CPU, best of $4 run(s) (want ≤8, ≤800, <1)"; fi
}
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
  printf '# Handoff\n\n> Written 2026-10-01 at commit `%s` on main.\n\n## In flight\n- alpha T2\n\n## Done this session\n- T1\n\n## Next step\nFinish alpha T2 and run its test.\n\n## Blocked on\nThe owner'"'"'s answer on REQ-11.\n\n## Open questions\n- none\n\n## Do not forget\n- x\n' "$hsha" > "$BB/.shipkit/state.md"
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
  # ...the handoff skill documents the heading that fixture carries, as the one conditional
  # sixth heading (run-wounds/REQ-15), and the briefing's handoff line above did not pick it up
  if grep -q '`## Blocked on`' "$COPY/skills/handoff/SKILL.md" \
     && grep -q 'Only when the next step cannot start' "$COPY/skills/handoff/SKILL.md"; then
    passt "briefing (handoff skill: a Blocked on heading only when the next step cannot start; the Next step line still stands alone)"
  else failc "briefing" "handoff/SKILL.md does not document the conditional Blocked on heading"; fi
  # ...and a gap makes the spec-check line appear
  : > "$BB/.shipkit/specs/alpha/tasks.md"
  out=$(brief "$BB")
  if printf '%s\n' "$out" | grep -q '^shipkit: spec-check: 1 gap(s) — run spec-check.sh$'; then
    pass "briefing (a spec-check gap → one gap line)"
  else failc "briefing" "no gap line: $out"; fi
  # c. fifty open specs: at most eight lines, at most 800 bytes, under a second. The time is the
  # briefing's own CPU time (user and system, its children's too), not the wall clock: on a busy
  # machine the wall clock measures the machine. It read 1.02 s at the 5.1.0 release, 1.01 s at
  # Sprint 23's merge and 1.0 s on all three tries at Sprint 29's first model-free run, with the
  # owner at work in another window; alone, the same fixture then took 0.81 to 0.90 s on the
  # clock and 0.72 to 0.82 s of CPU. Still the best of up to three runs, stopping at the first
  # under a second: a briefing that is really slow is slow on all three.
  BC="$WORK/brief-c"; mkdir -p "$BC"; (cd "$BC" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
  i=1; while [ "$i" -le 50 ]; do bspec "$BC" "spec-$i-with-a-rather-long-name-to-fill-the-line" open 1 4; i=$((i + 1)); done
  bt=9; bt_n=0
  while [ "$bt_n" -lt 3 ] && [ "$(printf '%s' "$bt" | cut -d. -f1)" -ne 0 ]; do
    bt_n=$((bt_n + 1))
    bt_one=$(python3 -c "import os,subprocess; a=os.times(); subprocess.run(['sh','$BRF'],cwd='$BC',stdout=open('$WORK/brief50.out','w'),stderr=subprocess.DEVNULL); b=os.times(); print(round((b.children_user-a.children_user)+(b.children_system-a.children_system),2))")
    bt=$(awk -v a="$bt" -v b="$bt_one" 'BEGIN { m = (b + 0 < a + 0) ? b : a; print m }')
  done
  bl=$(grep -c . "$WORK/brief50.out"); bb=$(wc -c < "$WORK/brief50.out" | tr -d ' ')
  brief50_verdict "$bl" "$bb" "$bt" "$bt_n"
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
if model_check 31; then
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
fi  # /model_check 31

# 32. handoff-loop: a fresh session in the project from check 31 is asked what to do next,
# and answers from the note's Next step, which the briefing put in its context
# (spec: .shipkit/specs/briefing-and-handoff/). Cites: briefing-and-handoff/REQ-14
if model_check 32; then
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
fi  # /model_check 32

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
  passt "fired-if-template (reference.md shows a command form after a Falsifiability line, and the manual form)"
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
  # e. no hook calls it — code lines only; a comment that names the script is not a call
  # (4.12.0: session-start.sh's installed-root comment names decision-check.sh as a reader of
  # plugin-root, and this check read the mention as an invocation). The filter is a function
  # because bash 3.2 reads a '#' inside "$(...)" as a comment.
  code_lines() { grep -v '^[[:space:]]*#' "$1"; }
  if ! grep -rq 'decision-check' "$COPY/hooks" && ! code_lines "$COPY/scripts/session-start.sh" | grep -q 'decision-check'; then
    pass "decision-check (no hook and no code line of the session hook names decision-check)"
  else failc "decision-check" "a hook calls decision-check: $(grep -rn 'decision-check' "$COPY/hooks"; code_lines "$COPY/scripts/session-start.sh" | grep -n 'decision-check')"; fi
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
# --wip: the same history with every commit message "wip" — same files, same tree hash per
# commit, only the messages differ (the map is untracked, so it does not enter any tree).
# A "wip" log is where a map's Evolution section would earn its place (second-traps/REQ-12).
XW="$WORK/xl-wip"; mkdir -p "$XW"
(cd "$XW" && python3 "$COPY/evals/fixtures/ledger-gen/generate.py" --wip >/dev/null 2>&1)
xw_trees=$(git -C "$XW" log --format=%T 2>/dev/null); xn_trees=$(git -C "$WORK/xl-case-history" log --format=%T 2>/dev/null)
xw_msgs=$(git -C "$XW" log --format=%s%n%b 2>/dev/null | grep -v '^$' | sort -u | tr '\n' '|')
if [ -n "$xw_trees" ] && [ "$xw_trees" = "$xn_trees" ] && [ "$xw_msgs" = "wip|" ] && [ -f "$XW/PROJECT_MAP.md" ]; then
  pass "xl-scaffold (--wip: $(printf '%s\n' "$xw_trees" | wc -l | tr -d ' ') commits with the same tree hashes, every message \"wip\", the map still written)"
else failc "xl-scaffold" "--wip: trees equal=$([ "$xw_trees" = "$xn_trees" ] && echo yes || echo no) messages=[$xw_msgs] map=$([ -f "$XW/PROJECT_MAP.md" ] && echo yes || echo no)"; fi

# 40. trace-tools: scripts/trace-tools.sh reads an eval output directory's aggregate-result.json
# and prints one line per run with the counts the map comparison reads — from the trace, never
# the summary. A synthetic two-run trace with known numbers: run 1 has three tool calls (one
# Agent, one by the subagent, one split across two rows of the same message, which must not
# double-count), run 2 has one. Since 4.7.0 run 1's subagent Grep has the map's path and its
# last message also holds a Bash `cat PROJECT_MAP.md`, so map_read and map_shell read 1 1 for
# run 1 and 0 0 for run 2 — the two columns the elder's read rate is counted from (4.6's rates
# were Read only; a Grep on the map's path and a shell read were both missed).
# Cites: map-on-trial/REQ-10 map-on-trial/REQ-11 harness-debts/REQ-8 harness-debts/REQ-9
TT="$ROOT/scripts/trace-tools.sh"
TD="$WORK/tt"; mkdir -p "$TD/r1/out" "$TD/r2/out"
tt_asst() {  # tt_asst <msg-id> <parent-or-null> <input> <cache_create> <cache_read> <content-json>
  printf '{"type":"assistant","parent_tool_use_id":%s,"message":{"id":"%s","usage":{"input_tokens":%s,"cache_creation_input_tokens":%s,"cache_read_input_tokens":%s},"content":%s}}\n' "$2" "$1" "$3" "$4" "$5" "$6"
}
{
  printf '{"type":"system","subtype":"init"}\n'
  tt_asst m1 null 10 100 1000 '[{"type":"text","text":"x"}]'
  tt_asst m1 null 10 100 1000 '[{"type":"tool_use","id":"t1","name":"Agent","input":{}}]'
  tt_asst m2 '"t1"' 5 50 500 '[{"type":"tool_use","id":"t2","name":"Grep","input":{"pattern":"orders","path":"/w/PROJECT_MAP.md"}}]'
  tt_asst m3 null 20 0 2000 '[{"type":"tool_use","id":"t3","name":"Read","input":{"file_path":"/w/app.py"}},{"type":"tool_use","id":"t4","name":"Bash","input":{"command":"cat PROJECT_MAP.md | head"}}]'
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
  # fields: case arm run passed tools tools_main agent in_tokens in_tokens_main cost map_read map_shell
  if [ "$tt_rc" -eq 0 ] && printf '%s\n' "$tt_l1" | awk -v g="$tt_grep" '{ok = ($4=="pass" && $5==g && $5==4 && $6==3 && $7==1 && $8==3685 && $9==3130 && $10=="0.5000" && $11==1 && $12==1)} END{exit ok?0:1}' \
     && printf '%s\n' "$tt_l2" | awk '{ok = ($4=="fail" && $5==1 && $6==1 && $7==0 && $8==6 && $9==6 && $10=="0.2500" && $11==0 && $12==0)} END{exit ok?0:1}' \
     && [ "$(printf '%s\n' "$tt_out" | grep -c '^grandfather-xl-lookup')" -eq 2 ]; then
    pass "trace-tools (one line per run; tool calls = $tt_grep tool_use blocks, main/subagent split, tokens deduped per message, cost; map_read counts a Grep on the map, map_shell a shell cat)"
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
# second-traps/REQ-1 portfolio-run/REQ-1 always-on/REQ-20 (the limit is 204,800 since 5.0.0, W10;
# 196,608 from 4.9.0; 163,840 from 4.6.0)
LN="$WORK/lint-neg"; mkdir -p "$LN"
# only the repo-root .git and .claude (agent worktrees) are skipped; the overlays' .claude/ must copy
if command -v rsync >/dev/null 2>&1; then rsync -a --exclude /.git --exclude /.claude "$ROOT/" "$LN/"
else (cd "$ROOT" && tar cf - --exclude ./.git --exclude ./.claude .) | (cd "$LN" && tar xf -); fi
ln_clean=$(python3 "$LN/scripts/lint.py" 2>&1 | tail -1)
head -c 61440 /dev/zero | tr '\0' 'x' > "$LN/plugins/shipkit/evals/fixtures/oversize.txt"
printf '\nStart by building the map: run /shipkit:map first.\n' >> "$LN/README.md"
ln_out=$(python3 "$LN/scripts/lint.py" 2>&1)
if printf '%s\n' "$ln_clean" | grep -q '^lint: 0 error(s)' \
   && printf '%s\n' "$ln_out" | grep -q 'evals: [0-9,]* bytes; the limit is 204,800' \
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

# 47. rule-cases: every rule case (evals/scoped/*, evals/stacks/*, evals/trap2/*) has the four files, exactly
# one scored grader, a description naming the rule file it probes, a scaffold that calls
# lib/with-rule.sh for that rule, and a case name equal to <group>-<folder>. Each scaffold is
# run in a scratch directory and must leave the rule and the marker in place.
# Cites: rule-evals/REQ-10 rule-evals/REQ-11 rule-evals/REQ-12 second-traps/REQ-4
RC_EXPECT="scoped/dependencies scoped/migrations scoped/monorepo scoped/testing scoped/ui-ux stacks/mix-deps stacks/go-mod stacks/hotwire stacks/liveview stacks/data stacks/experiments stacks/notebooks stacks/jobs stacks/pyproject stacks/gemfile stacks/rails stacks/package-json stacks/react trap2/migrations trap2/monorepo trap2/testing trap2/ui-ux trap2/mix-deps trap2/go-mod trap2/hotwire trap2/liveview trap2/data trap2/experiments trap2/notebooks trap2/pyproject trap2/gemfile trap2/rails trap2/package-json trap2/react"
rc_ok=1; rc_why=""
for c in $RC_EXPECT; do
  CD="$COPY/evals/$c"; g=${c%%/*}; n=${c##*/}
  if [ ! -f "$CD/prompt.md" ] || [ ! -f "$CD/case.yaml" ] || [ ! -f "$CD/fixture.sh" ]; then
    rc_ok=0; rc_why="$rc_why $c:missing-files"; continue
  fi
  [ "$(ls "$CD/graders/" 2>/dev/null | grep -c '\.md$')" -eq 1 ] || { rc_ok=0; rc_why="$rc_why $c:graders!=1"; }
  grep -q "^name: $g-$n\$" "$CD/case.yaml" || { rc_ok=0; rc_why="$rc_why $c:name"; }
  rule=$(sed -n 's/.*with-rule\.sh" \([a-z-]*\).*/\1/p' "$CD/fixture.sh" | head -1)
  [ -n "$rule" ] || { rc_ok=0; rc_why="$rc_why $c:no-with-rule"; continue; }
  grep '^description:' "$CD/prompt.md" | grep -q "$rule\.md" || { rc_ok=0; rc_why="$rc_why $c:description-lacks-$rule.md"; }
  RD="$WORK/rc-$g-$n"; mkdir -p "$RD"
  (cd "$RD" && bash "$CD/fixture.sh" >/dev/null 2>&1) || { rc_ok=0; rc_why="$rc_why $c:scaffold-failed"; continue; }
  rel=$(cat "$RD/.claude/rules/shipkit/.eval-rule" 2>/dev/null)
  [ -n "$rel" ] && [ -f "$RD/$rel" ] && [ "$(basename "$rel")" = "$rule.md" ] || { rc_ok=0; rc_why="$rc_why $c:rule-not-installed"; }
  [ "$(git -C "$RD" rev-list --count HEAD 2>/dev/null)" -ge 1 ] || { rc_ok=0; rc_why="$rc_why $c:no-commit"; }
done
if [ "$rc_ok" -eq 1 ]; then pass "rule-cases ($(echo $RC_EXPECT | wc -w | tr -d ' ') cases: four files, one grader, description names the rule, scaffold installs it)"
else failc "rule-cases" "$rc_why"; fi

# 48. pending-test: an OPEN spec's uncited requirements are shown, not enforced, before the gate.
# Both 4.0.0 gates failed their first run on requirements no test cited; the plain run never
# asked an open spec for tests (check 19c), and --as-shipped (the gate's step 1) was not run
# first. Now the plain run prints an information line PENDING-TEST <slug> REQ-N per uncited,
# unexcused requirement of an open spec; the exit status is unchanged; an excused requirement
# stays WAIVED; --as-shipped and a shipped spec print MISSING-TEST as before, never PENDING.
# Reuses scspec/sc from check 19. Cites: real-run/REQ-1 real-run/REQ-2 real-run/REQ-3
P="$WORK/sc-pt"; scspec "$P" demo open
printf -- '- **REQ-3.** The README shall say so. [untested: prose]\n' >> "$P/.shipkit/specs/demo/spec.md"
{ for t in 1 2 3; do
    printf -- '- [ ] **T%s** step %s → REQ-%s\n  - Files: app/f%s.py\n  - Test: tests/test_demo.py\n  - After: none\n  - Done when: `true`\n' "$t" "$t" "$t" "$t"
  done; } > "$P/.shipkit/specs/demo/tasks.md"
printf '# demo/REQ-2\n' > "$P/tests/test_demo.py"
rc=$(sc "$P"); out_plain=$(cat "$WORK/sc.out")
rc2=$(sc "$P" demo --as-shipped); out_ship=$(cat "$WORK/sc.out")
sed 's/^> Status: open/> Status: shipped/' "$P/.shipkit/specs/demo/spec.md" > "$WORK/sc.tmp" && mv "$WORK/sc.tmp" "$P/.shipkit/specs/demo/spec.md"
rc3=$(sc "$P"); out_shipped=$(cat "$WORK/sc.out")
if [ "$rc" -eq 0 ] && printf '%s\n' "$out_plain" | grep -q '^PENDING-TEST demo REQ-1$' \
   && ! printf '%s\n' "$out_plain" | grep -q 'PENDING-TEST demo REQ-2' \
   && ! printf '%s\n' "$out_plain" | grep -q 'PENDING-TEST demo REQ-3' \
   && printf '%s\n' "$out_plain" | grep -q '^WAIVED demo REQ-3$' \
   && ! printf '%s\n' "$out_plain" | grep -q 'MISSING-' \
   && printf '%s\n' "$out_plain" | grep -q '0 gap(s)$'; then
  pass "pending-test (open spec, plain run → PENDING-TEST for the uncited requirement only; WAIVED kept; exit 0, 0 gaps)"
else failc "pending-test" "plain: exit $rc: $out_plain"; fi
if [ "$rc2" -eq 1 ] && printf '%s\n' "$out_ship" | grep -q '^MISSING-TEST demo REQ-1$' \
   && ! printf '%s\n' "$out_ship" | grep -q 'PENDING-TEST' \
   && [ "$rc3" -eq 1 ] && printf '%s\n' "$out_shipped" | grep -q '^MISSING-TEST demo REQ-1$' \
   && ! printf '%s\n' "$out_shipped" | grep -q 'PENDING-TEST'; then
  pass "pending-test (--as-shipped and a shipped spec → MISSING-TEST, exit 1, no PENDING line)"
else failc "pending-test" "as-shipped: exit $rc2: $out_ship / shipped: exit $rc3: $out_shipped"; fi

# 49. pre33-specs: a spec with NO Status line and EVERY task ticked predates 3.3 and is shipped
# in all but name. The briefing prints no progress line for it and the hook no drift line; one
# briefing line counts the specs with no Status line and gives the fix. A no-Status spec with an
# unticked task is still reported as open. spec-check.sh is not touched (spec-contract/REQ-7).
# Reuses bspec/brief from check 30. Cites: run-wounds/REQ-1 run-wounds/REQ-2 run-wounds/REQ-3
# run-wounds/REQ-4
P33="$WORK/pre33"; mkdir -p "$P33"
(cd "$P33" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
p33sha=$(cd "$P33" && git rev-parse --short HEAD)
bspec "$P33" old-a none 2 2; bspec "$P33" old-b none 3 3; bspec "$P33" old-c none 1 1
bspec "$P33" gamma none 0 2; bspec "$P33" delta open 2 2
for s in old-a old-b old-c gamma delta; do
  sed "s/abc1234/$p33sha/" "$P33/.shipkit/specs/$s/spec.md" > "$WORK/p33.tmp" && mv "$WORK/p33.tmp" "$P33/.shipkit/specs/$s/spec.md"
done
(cd "$P33" && git add -A && git -c user.email=s@s -c user.name=s commit -q -m specs \
  && i=0 && while [ "$i" -lt 16 ]; do git -c user.email=s@s -c user.name=s commit -q --allow-empty -m "c$i"; i=$((i + 1)); done)
out=$(brief "$P33")
if ! printf '%s\n' "$out" | grep -q 'old-[abc]' \
   && printf '%s\n' "$out" | grep -q '^shipkit: gamma: 0 of 2 tasks done, next T1 — Do step 1$' \
   && printf '%s\n' "$out" | grep -q '^shipkit: delta: 2 of 2 tasks done, all ticked$' \
   && printf '%s\n' "$out" | grep -q '^shipkit: 4 specs predate 3.3' \
   && printf '%s\n' "$out" | grep '^shipkit: 4 specs predate 3.3' | grep -q 'Status: shipped'; then
  pass "pre33-specs (briefing: all-ticked no-Status specs silent; unticked one still open; one line counts 4 and names the fix)"
else failc "pre33-specs" "briefing: $out"; fi
hook=$(cd "$P33" && CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh" 2>/dev/null)
if ! printf '%s\n' "$hook" | grep 'behind HEAD' | grep -q 'old-[abc]' \
   && printf '%s\n' "$hook" | grep 'behind HEAD' | grep -q 'gamma\|delta'; then
  pass "pre33-specs (hook: no drift line for all-ticked no-Status specs; still one for the open ones)"
else failc "pre33-specs" "hook drift lines: $(printf '%s\n' "$hook" | grep 'behind HEAD\|stale')"; fi

# 50. headless-questions: a run that cannot ask leaves its questions on disk, not in the reply.
# Like checks 22 and 23 this asks sonnet to do real work, twice: /shipkit:intake with nobody to
# answer must still write intake.md with its questions marked unanswered (run-wounds/REQ-9);
# /shipkit:product with no answers given must write product.md with an "Open questions for the
# owner" block under the review line, keeping the seven-heading shape check 23 holds
# (run-wounds/REQ-11). The files are read here; the model's word is not.
HQ="$WORK/hq-intake"; mkdir -p "$HQ"
(cd "$HQ" && bash "$COPY/evals/intake/limit/fixture.sh" >/dev/null 2>&1)
if model_check 50; then
(cd "$HQ" && claude --plugin-dir "$COPY" --model sonnet \
  --allowedTools Read Glob Grep Write Edit Bash Skill Agent \
  -p "/shipkit:intake Add refunds.
This run is not interactive and you cannot ask me anything, and I have given no answers." \
  </dev/null >"$WORK/hq-intake.out" 2>&1)
hq_file=$(find "$HQ/.shipkit/specs" -name intake.md 2>/dev/null | head -1)
if [ -n "$hq_file" ] && grep -q '^## Answers' "$hq_file" && grep -qi 'unanswered' "$hq_file"; then
  pass "headless-questions (intake with nobody to answer wrote $(printf '%s' "$hq_file" | sed "s|$HQ/||") with its questions marked unanswered)"
else failc "headless-questions" "intake.md: [${hq_file:-none}] — model said: $(tail -3 "$WORK/hq-intake.out")"; fi
HP="$WORK/hq-product"; mkdir -p "$HP"; cp -R "$COPY/evals/fixtures/sample-app/." "$HP/"
(cd "$HP" && git init -q && git add -A && git -c user.email=s@s -c user.name=s commit -q -m init)
(cd "$HP" && claude --plugin-dir "$COPY" --model sonnet \
  --allowedTools Read Glob Grep Write Edit Skill \
  -p "/shipkit:product
This run is not interactive and you cannot ask me anything, and I have given no answers." \
  </dev/null >"$WORK/hq-product.out" 2>&1)
hp="$HP/.shipkit/product.md"
hp_heads=$([ -f "$hp" ] && grep '^## ' "$hp" | sed 's/^## //; s/[[:space:]]*$//' | tr '\n' '|')
if [ -f "$hp" ] && grep -q '^> Open questions for the owner' "$hp" \
   && [ "$hp_heads" = "One line|Users|Goals this quarter|Non-goals|Metrics that matter|Constraints|Now / Next / Later|" ]; then
  pass "headless-questions (product with no answers wrote the open-questions block; seven headings kept)"
else failc "headless-questions" "product.md block missing or shape changed: heads=[$hp_heads] — model said: $(tail -3 "$WORK/hq-product.out")"; fi
fi  # /model_check 50

# 51. version-and-goal: two lines the real run wanted. (a) Claude Code keeps each installed
# version at ~/.claude/plugins/cache/shipkit/shipkit/<ver>/ and a session keeps the root it
# started with: a HIGHER version directory beside the running root → the hook prints one line
# naming both and "restart"; run from the highest, or beside only older or non-version
# directories (3.1.0 sits beside 4.2.0 today), no line. 4.10.0 beside 4.3.0 catches a string
# compare. (b) a top goal whose metric, target and date are all "none set" prints the goal and
# "(no metric set)", none of the three fields. No claude needed. Cites: run-wounds/REQ-12
# run-wounds/REQ-13 run-wounds/REQ-14
VC="$WORK/cache/shipkit/shipkit"; mkdir -p "$VC/3.1.0" "$VC/notes"
cp -R "$COPY" "$VC/4.3.0"; cp -R "$COPY" "$VC/4.10.0"
VP="$WORK/ver-proj"; mkdir -p "$VP"
vrun() { (cd "$VP" && CLAUDE_PLUGIN_ROOT="$VC/$1" sh "$VC/$1/scripts/session-start.sh" </dev/null 2>/dev/null); }
out=$(vrun 4.3.0)
if [ "$(printf '%s\n' "$out" | grep -c 'restart')" -eq 1 ] \
   && printf '%s\n' "$out" | grep -q '^shipkit: 4\.10\.0 is installed; this session runs 4\.3\.0 — restart'; then
  pass "version-and-goal (hook run from 4.3.0 beside 4.10.0: one line naming both and restart)"
else failc "version-and-goal" "run from 4.3.0: $(printf '%s\n' "$out" | grep 'restart\|installed' | head -2)"; fi
out=$(vrun 4.10.0)
if printf '%s\n' "$out" | grep -q '^shipkit: plugin root is ' && ! printf '%s\n' "$out" | grep -q 'restart\|is installed'; then
  pass "version-and-goal (hook run from the highest version, 3.1.0 and a non-version dir beside it: no line)"
else failc "version-and-goal" "run from 4.10.0: $(printf '%s\n' "$out" | grep 'restart\|installed' | head -2)"; fi
out=$(cd "$ROOT" && sh plugins/shipkit/scripts/session-start.sh </dev/null 2>/dev/null)
if ! printf '%s\n' "$out" | grep -q 'restart to use'; then pass "version-and-goal (hook run from this repository: no version line)"
else failc "version-and-goal" "repository run: $(printf '%s\n' "$out" | grep 'restart to use')"; fi
VG="$WORK/ver-goal"; mkdir -p "$VG/.shipkit"
printf '# Product: demo\n\n> Product reviewed on 2026-10-01.\n\n## One line\nx\n\n## Users\n- y\n\n## Goals this quarter\n- Ship refunds — metric: none set; target: none set; by: none set\n- Second — metric: m; target: t; by: 2026-12-31\n\n## Non-goals\n- z\n' > "$VG/.shipkit/product.md"
out=$(cd "$VG" && sh "$COPY/scripts/briefing.sh" 2>/dev/null)
if printf '%s\n' "$out" | grep -q '^shipkit: top goal: Ship refunds (no metric set)$' && ! printf '%s\n' "$out" | grep -q 'metric:'; then
  pass "version-and-goal (top goal with three none-set fields → \"(no metric set)\", no fields)"
else failc "version-and-goal" "goal line: $(printf '%s\n' "$out" | grep 'top goal')"; fi
out=$(cd "$VG" && printf '# Product: demo\n\n## Goals this quarter\n- Ship refunds — metric: none set; target: 2%%; by: 2026-12-31\n' > .shipkit/product.md && sh "$COPY/scripts/briefing.sh" 2>/dev/null)
if printf '%s\n' "$out" | grep -q '^shipkit: top goal: Ship refunds — metric: none set; target: 2%; by: 2026-12-31$'; then
  pass "version-and-goal (a goal with one field set keeps all three)"
else failc "version-and-goal" "partial goal: $(printf '%s\n' "$out" | grep 'top goal')"; fi

# 52. fired-if-early: a Fired-if written before the code it measures exists. On the real run
# `test "$(grep -c . lib/…/health_report.rb)" -lt 40` errored (exit 2) with nothing said about
# why, and the fix `manual <!-- was … -->` was run as a command (field notes §6, §7). Now: the
# ERROR line carries the exit code AND the first line of stderr (naming the file); a trailing
# HTML comment after the command is stripped before the run; once the file exists and is short
# the same line is FIRED (the day-one firing the spec skill is told to catch); the summary
# line's words are unchanged. The spec skill says to run decision-check on its own output and
# the reference says a command must exit 1 on the tree the record is written against. Reuses
# dcrec/DCS from check 35. No claude needed. Cites: gate-blind-spots/REQ-1
# gate-blind-spots/REQ-2 gate-blind-spots/REQ-3 gate-blind-spots/REQ-4
FE="$WORK/fired-early"; mkdir -p "$FE/.shipkit/specs/hc" "$FE/lib"
(cd "$FE" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
fe_cmd='test "$(grep -c . lib/health_report.rb)" -lt 40'
printf '# Design: hc\n\n## Decision: Query object   (→ REQ-1)\n\n**Context.** c\n\n**Decision.** We chose a.\n**Falsifiability.** We would reverse this if the query object stays under 40 lines.\n**Fired-if.** `%s`\n\n## Decision: With comment   (→ REQ-2)\n\n**Decision.** We chose b.\n**Falsifiability.** We would reverse this if the same.\n**Fired-if.** `%s` <!-- was manual -->\n\n## Decision: Manual with comment   (→ REQ-3)\n\n**Decision.** We chose c.\n**Falsifiability.** We would reverse this if the moon falls.\n**Fired-if.** manual <!-- was a line count -->\n' "$fe_cmd" "$fe_cmd" > "$FE/.shipkit/specs/hc/design.md"
out=$(sh "$DCS" "$FE" --run 2>"$WORK/fe.err"); rc=$?
if [ "$rc" -eq 0 ] \
   && printf '%s\n' "$out" | grep -q '^ERROR .*Query object.*(exit 2): .*health_report\.rb.*No such file' \
   && printf '%s\n' "$out" | grep -q '^ERROR .*With comment.*(exit 2): .*health_report\.rb' \
   && ! printf '%s\n' "$out" | grep -q '<!--' \
   && printf '%s\n' "$out" | grep -q '^MANUAL .*Manual with comment.*the moon falls' \
   && printf '%s\n' "$out" | grep -q '^decision-check: 3 decision(s), 0 fired, 0 hold, 1 manual, 2 error(s)$'; then
  pass "fired-if-early (missing file → ERROR with exit 2 and stderr naming the file; trailing comment stripped from a command and from manual; summary words unchanged)"
else failc "fired-if-early" "rc=$rc out: $out $(cat "$WORK/fe.err")"; fi
i=0; while [ "$i" -lt 10 ]; do echo "line $i" >> "$FE/lib/health_report.rb"; i=$((i + 1)); done
out=$(sh "$DCS" "$FE" --run 2>/dev/null); rc=$?
if [ "$rc" -eq 1 ] && [ "$(printf '%s\n' "$out" | grep -c '^FIRED .*health_report')" -eq 2 ] \
   && printf '%s\n' "$out" | grep -q '^decision-check: 3 decision(s), 2 fired, 0 hold, 1 manual, 0 error(s)$'; then
  pass "fired-if-early (the file exists with 10 lines → both FIRED, exit 1: the day-one firing)"
else failc "fired-if-early" "after touch: rc=$rc out: $out"; fi
if grep -q 'decision-check.sh" \. --run' "$COPY/skills/spec/SKILL.md" \
   && grep -qi 'FIRED.*ERROR\|ERROR.*FIRED' "$COPY/skills/spec/SKILL.md" \
   && grep -q 'exit 1 on the tree' "$COPY/skills/spec/reference.md"; then
  passt "fired-if-early (the spec skill runs decision-check --run on its own design.md and treats FIRED or ERROR as a defect; the reference says a command exits 1 on the tree it is written against)"
else failc "fired-if-early" "spec skill or reference lacks the decision-check sentence"; fi

# 53. shipkit-allowed: the files shipkit's own loop writes are never "outside the spec". On the
# real run brief-verify called the spec's own intake.md/spec.md/design.md OUTSIDE before they
# were committed and the reviewer called .shipkit/product.md outside the Paths line (field
# notes §7, §8). Now everything under .shipkit/ is allowed except another spec's folder — for
# brief-verify by code, for the reviewer by its step 4. Reuses BP/BV/bv_base from checks 25
# and 26. No claude needed. Cites: gate-blind-spots/REQ-5 gate-blind-spots/REQ-6
# gate-blind-spots/REQ-7
mkdir -p "$BP/.shipkit/releases" "$BP/.shipkit/decisions"
printf '# Product: x\n' > "$BP/.shipkit/product.md"
printf 'READY\n' > "$BP/.shipkit/releases/2026-10-08-refunds.md"
printf '# Handoff\n' > "$BP/.shipkit/state.md"
printf '# Decision\n' > "$BP/.shipkit/decisions/0001-x.md"
printf '\nnote\n' >> "$BP/.shipkit/specs/refunds/design.md"
out=$(sh "$BV" "$BP" refunds T3 "$bv_base" 2>&1); rc=$?
if [ "$rc" -eq 0 ] && ! printf '%s\n' "$out" | grep -q '^OUTSIDE' \
   && printf '%s\n' "$out" | grep -q 'all inside the Files'; then
  pass "shipkit-allowed (product.md, a release report, state.md, a decision record and the spec's own design.md → exit 0, nothing OUTSIDE)"
else failc "shipkit-allowed" "shipkit files: exit $rc: $out"; fi
mkdir -p "$BP/.shipkit/specs/other"; printf '# Spec: other\n' > "$BP/.shipkit/specs/other/spec.md"
out=$(sh "$BV" "$BP" refunds T3 "$bv_base" 2>&1); rc=$?
if [ "$rc" -eq 1 ] && [ "$(printf '%s\n' "$out" | grep -c '^OUTSIDE')" -eq 1 ] \
   && printf '%s\n' "$out" | grep -q '^OUTSIDE .shipkit/specs/other/spec.md$'; then
  pass "shipkit-allowed (a write into another spec's folder → the one OUTSIDE line, exit 1)"
else failc "shipkit-allowed" "other spec: exit $rc: $out"; fi
rm -rf "$BP/.shipkit/specs/other" "$BP/.shipkit/releases" "$BP/.shipkit/decisions" "$BP/.shipkit/product.md" "$BP/.shipkit/state.md"
(cd "$BP" && git checkout -q -- .shipkit/specs/refunds/design.md)
if sed -n 1,30p "$BV" | grep -q 'another spec' \
   && grep -q 'another spec' "$COPY/agents/reviewer.md" \
   && grep -A3 'Changes beyond the spec\.\*\*' "$COPY/agents/reviewer.md" | grep -q 'under `\.shipkit/`'; then
  pass "shipkit-allowed (brief-verify's header and the reviewer's step 4 both say: under .shipkit/ only another spec's folder counts)"
else failc "shipkit-allowed" "the header or the reviewer's step 4 does not say what is allowed"; fi
# setup's files, in both places (run-debts T3). Cites: run-debts/REQ-6 run-debts/REQ-7
sa_step4=$(awk '/^4\. \*\*Changes beyond the spec/ { on = 1 } /^5\. / { on = 0 } on' "$COPY/agents/reviewer.md")
if sed -n 1,40p "$BV" | grep -q '\.claude/rules/shipkit/' && sed -n 1,40p "$BV" | grep -q '\.shipkit-baseline/' \
   && printf '%s\n' "$sa_step4" | grep -q '\.claude/rules/shipkit/' && printf '%s\n' "$sa_step4" | grep -q '\.shipkit-baseline/' \
   && printf '%s\n' "$sa_step4" | grep -q 'CLAUDE\.md' && printf '%s\n' "$sa_step4" | grep -q '\.gitignore'; then
  pass "shipkit-allowed (brief-verify's header and the reviewer's step 4 both name setup's two directories as allowed, CLAUDE.md and .gitignore as reported)"
else failc "shipkit-allowed" "setup's directories are not named in both places"; fi

# 54. scoped-loading: does a path-scoped rule under .claude/rules/shipkit/ load in a normal
# headless session when a matching file is named, and stay out when a non-matching one is?
# Every rule eval delivers its text always-on through the hook (the sandbox loads no .claude/
# file), so until now nothing measured whether the `paths:` globs fire at all (ROADMAP
# "measured by nothing"). Two forms are tried, in order: the prompt names the file and no tool
# runs; the prompt has the model Read the file. The PASS line says which form fired. Rules are
# installed by install-rules.sh (dependencies.md, nonce ZEBRA-5401) and one stack rule copied
# in as install-stack.sh would (rails/gemfile.md, ZEBRA-5402). haiku, four to eight short runs.
# The evals README states the result under "How a case gets the fixture". Cites:
# second-traps/REQ-3
SL="$WORK/scoped-load"; mkdir -p "$SL"
(cd "$SL" && git init -q && printf '[project]\nname = "demo"\n' > pyproject.toml && printf '# Demo\n' > README.md \
  && printf 'source "https://rubygems.org"\n' > Gemfile && git add -A && git -c user.email=s@s -c user.name=s commit -q -m init)
sh "$COPY/scripts/install-rules.sh" "$COPY" "$SL" >/dev/null 2>&1
printf '\n\nSmoke codeword: ZEBRA-5401.\n' >> "$SL/.claude/rules/shipkit/dependencies.md"
cp "$COPY/stacks/rails/.claude/rules/gemfile.md" "$SL/.claude/rules/shipkit/gemfile.md"
printf '\n\nSmoke codeword: ZEBRA-5402.\n' >> "$SL/.claude/rules/shipkit/gemfile.md"
if model_check 54; then
slask() {  # slask <file> <named|read> → the model's last lines
  if [ "$2" = read ]; then
    (cd "$SL" && claude --plugin-dir "$COPY" --model haiku --allowedTools Read -p "Read the file $1 in this directory. Then: $CW_Q" 2>/dev/null | tail -5)
  else
    (cd "$SL" && claude --plugin-dir "$COPY" --model haiku -p "I am about to edit $1 in this directory. $CW_Q Do not use tools." 2>/dev/null | tail -5)
  fi
}
sl_form=""; sl_py=""; sl_gem=""; sl_readme=""
for form in named read; do
  sl_py=$(slask pyproject.toml "$form"); sl_gem=$(slask Gemfile "$form")
  case "$sl_py" in *ZEBRA-5401*) case "$sl_gem" in *ZEBRA-5402*) sl_form="$form";; esac;; esac
  [ -n "$sl_form" ] && break
done
if [ -n "$sl_form" ]; then
  sl_readme=$(slask README.md "$sl_form")
  case "$sl_readme" in
    *ZEBRA-540*) failc "scoped-loading" "form '$sl_form': the rules loaded for README.md too — the globs did not scope: $sl_readme";;
    *) pass "scoped-loading (path-scoped rules load when the prompt $( [ "$sl_form" = read ] && echo 'has the file read' || echo 'names the file' ) — pyproject.toml → dependencies.md, Gemfile → gemfile.md — and not for README.md)";;
  esac
else
  failc "scoped-loading" "neither form loaded both rules — named: py[$(printf '%s' "$sl_py" | tail -1)] gem[$(printf '%s' "$sl_gem" | tail -1)]"
fi
fi  # /model_check 54
if sed -n '/^## How a case gets the fixture/,/^## Cases/p' "$COPY/evals/README.md" | grep -q 'check 54' \
   && sed -n '/^## How a case gets the fixture/,/^## Cases/p' "$COPY/evals/README.md" | grep -qi 'path-scoped'; then
  pass "scoped-loading (the evals README states the measured result and names check 54)"
else failc "scoped-loading" "evals/README.md has no path-scoped loading paragraph naming check 54"; fi

# 55. spec-check-draft: a DRAFT spec can be checked with --as-open — read as open for the run
# (the task-format checks, MISSING-TASK, PENDING-TEST), no file changed — so the spec skill
# never flips a Status line to get a check (the real run did; field notes §6). Without the
# flag a draft is still SKIPPED; open, shipped and dropped specs print the same with the flag
# as without. Reuses scspec, sctasks and sc. No claude needed. Cites: harness-debts/REQ-1
# harness-debts/REQ-2 harness-debts/REQ-3
# a. a draft whose T2 has no Files line: SKIPPED without the flag, MISSING-FIELD with it
P="$WORK/ao-a"; scspec "$P" demo draft; sctasks "$P" demo T1
grep -v 'Files: app/c.py' "$P/.shipkit/specs/demo/tasks.md" > "$WORK/sc.tmp" && mv "$WORK/sc.tmp" "$P/.shipkit/specs/demo/tasks.md"
ao_before=$(cat "$P/.shipkit/specs/demo/spec.md")
rc=$(sc "$P" demo)
if [ "$rc" -eq 0 ] && grep -q '^SKIPPED demo (draft)$' "$WORK/sc.out"; then
  rc=$(sc "$P" demo --as-open)
  if [ "$rc" -eq 1 ] && grep -q '^MISSING-FIELD demo T2 Files$' "$WORK/sc.out" && ! grep -q 'SKIPPED' "$WORK/sc.out" \
     && grep -q '^PENDING-TEST\|^MISSING-TASK\|^MISSING-FIELD' "$WORK/sc.out" && ! grep -q 'MISSING-TEST' "$WORK/sc.out" \
     && [ "$ao_before" = "$(cat "$P/.shipkit/specs/demo/spec.md")" ]; then
    pass "spec-check-draft (draft + --as-open → MISSING-FIELD, exit 1, no MISSING-TEST, spec.md untouched; without the flag → SKIPPED)"
  else failc "spec-check-draft" "with the flag: exit $rc: $(cat "$WORK/sc.out" | tr '\n' '|')"; fi
else failc "spec-check-draft" "without the flag a draft should be SKIPPED, exit 0: exit $rc: $(cat "$WORK/sc.out" | tr '\n' '|')"; fi
# b. a draft whose tasks.md never names REQ-2 → MISSING-TASK with the flag
P="$WORK/ao-b"; scspec "$P" demo draft; sctasks "$P" demo T1
sed -i '' 's/→ REQ-2/→ REQ-1/' "$P/.shipkit/specs/demo/tasks.md"
rc=$(sc "$P" demo --as-open)
if [ "$rc" -eq 1 ] && grep -q '^MISSING-TASK demo REQ-2$' "$WORK/sc.out"; then pass "spec-check-draft (draft with an unnamed requirement + --as-open → MISSING-TASK)"
else failc "spec-check-draft" "missing task: exit $rc: $(cat "$WORK/sc.out" | tr '\n' '|')"; fi
# c. shipped and dropped specs: the flag changes nothing
P="$WORK/ao-c"; scspec "$P" demo shipped
rc1=$(sc "$P" demo); ao_plain=$(cat "$WORK/sc.out")
rc2=$(sc "$P" demo --as-open); ao_flag=$(cat "$WORK/sc.out")
P="$WORK/ao-d"; scspec "$P" demo dropped
rc3=$(sc "$P" demo --as-open)
if [ "$rc1" = "$rc2" ] && [ "$ao_plain" = "$ao_flag" ] && [ "$rc3" -eq 0 ] && grep -q '^SKIPPED demo (dropped)$' "$WORK/sc.out"; then
  pass "spec-check-draft (shipped + --as-open → same output as without; dropped → still SKIPPED)"
else failc "spec-check-draft" "shipped $rc1/$rc2 [$ao_plain] vs [$ao_flag]; dropped $rc3: $(cat "$WORK/sc.out" | tr '\n' '|')"; fi
# d. the spec skill asks for the flag on a draft and never flips the status (prose, REQ-3)
if grep -q -- '--as-open' "$COPY/skills/spec/SKILL.md" && ! grep -qi 'set the status to `open` for one run\|set .*Status.* to .*open.* for one run' "$COPY/skills/spec/SKILL.md"; then
  passt "spec-check-draft (the spec skill runs spec-check --as-open on the draft; no status flip in its text)"
else failc "spec-check-draft" "skills/spec/SKILL.md does not name --as-open, or still flips the status"; fi

# 56. plugin-root-restore: until 4.11.0 the session hook rewrote ~/.claude/shipkit/plugin-root
# on every start, so by the end of this suite it named the scratch copy — restored by luck of
# ordering or by hand until 4.7.0 (since 4.12.0 a scratch copy writes plugin-root.dev instead,
# check 62; the runner still restores both). The runner now saves it (pr_save) before the first session and puts
# it back (pr_restore) from its EXIT trap, on every exit path. Tested here in a subshell with
# HOME pointed at a scratch directory: a sentinel overwritten is restored; an absent file
# overwritten is absent again. The trap line and the header sentence are grepped from the
# script itself. No claude needed. Cites: harness-debts/REQ-6 harness-debts/REQ-7
if command -v pr_save >/dev/null 2>&1 && command -v pr_restore >/dev/null 2>&1; then
  pr_rc=$(
    HOME="$WORK/prhome"; mkdir -p "$HOME/.claude/shipkit"; PR_FILE="$HOME/.claude/shipkit/plugin-root"
    printf 'sentinel\n' > "$PR_FILE"; pr_save; printf '%s\n' "$WORK/plugin" > "$PR_FILE"; pr_restore
    [ "$(cat "$PR_FILE")" = sentinel ] || { echo 1; exit; }
    rm "$PR_FILE"; pr_save; printf '%s\n' "$WORK/plugin" > "$PR_FILE"; pr_restore
    [ ! -f "$PR_FILE" ] || { echo 2; exit; }
    echo 0
  )
  case "$pr_rc" in
    0) pass "plugin-root-restore (a sentinel overwritten is restored; an absent file is absent again)";;
    1) failc "plugin-root-restore" "the sentinel was not restored";;
    *) failc "plugin-root-restore" "an absent plugin-root was left behind";;
  esac
else failc "plugin-root-restore" "pr_save / pr_restore are not defined (check written first, by design)"; fi
if grep -q "^trap 'pr_restore" "$ROOT/scripts/smoke.sh" \
   && sed -n '1,20p' "$ROOT/scripts/smoke.sh" | grep -q 'restores it on exit' \
   && sed -n '1,20p' "$ROOT/scripts/smoke.sh" | grep -q 'started during a run'; then
  pass "plugin-root-restore (the restore is on the EXIT trap; the header says so and names the mid-run window)"
else failc "plugin-root-restore" "no trap 'pr_restore…' EXIT line, or the header does not say it restores on exit / that a session started during a run reads a scratch root"; fi

# 57. dotfile-paragraph: the evals README tells a case author what the sandbox will refuse —
# a file whose NAME is on Claude Code's protected list (.pre-commit-config.yaml is), not "a
# dotfile at the workspace root" as 4.6.0 read it: two probe runs wrote .editorconfig at the
# root and under config/ (S14-T5, 2026-10-09). The paragraph sits under "How a case gets the
# fixture". No claude needed. Cites: harness-debts/REQ-10
dp=$(sed -n '/^## How a case gets the fixture/,/^## Cases/p' "$COPY/evals/README.md" | sed -n '/^### What a case cannot ask for/,/^## Cases/p')
if [ -n "$dp" ] && printf '%s\n' "$dp" | grep -q 'protected' && printf '%s\n' "$dp" | grep -q 'workspace root' \
   && printf '%s\n' "$dp" | grep -q 'pre-commit-config.yaml' && printf '%s\n' "$dp" | grep -q 'config/.editorconfig'; then
  pass "dotfile-paragraph (the evals README says what a case cannot ask for: a protected file name, with the root and subdirectory probes)"
else failc "dotfile-paragraph" "evals/README.md has no 'What a case cannot ask for' paragraph under 'How a case gets the fixture' naming the protected list, the workspace root, .pre-commit-config.yaml and config/.editorconfig"; fi

# 58. cuts-recorded: the fourteen lines cut in 4.8.0 (measured-cuts, plan E1) and migrations'
# two cut in 4.11.0 on haiku are out of their eight files, the four files kept still carry theirs, and the evals README names the
# cut files and the watch rule (a case below 2 of 3 in a release run returns its line). Each
# line is identified by a phrase only it carries. No claude needed. Cites: measured-cuts/REQ-1
# measured-cuts/REQ-3 measured-cuts/REQ-4 graders-and-eve/REQ-10 (the kept list below agrees with
# the measured-cuts record's 4.11.0 note: the five files on haiku, docs/design/eval-results-4.11.md §5)
cr_fail=""
cr_gone() {  # cr_gone <file> <phrase> — the phrase must be absent
  grep -qF -- "$2" "$COPY/$1" && cr_fail="$cr_fail [$1 still has: $2]"; :
}
cr_kept() {  # cr_kept <file> <phrase> — the phrase must be present
  grep -qF -- "$2" "$COPY/$1" || cr_fail="$cr_fail [$1 lost: $2]"; :
}
cr_gone rules/ui-ux.md "Semantic structure first"; cr_gone rules/ui-ux.md "Every control has an accessible name"
cr_gone stacks/hotwire/.claude/rules/hotwire.md "Turbo Frames** for a scoped region"; cr_gone stacks/hotwire/.claude/rules/hotwire.md "document.querySelector"
cr_gone stacks/liveview/.claude/rules/liveview.md "runs twice"; cr_gone stacks/liveview/.claude/rules/liveview.md "URL-derived state"
cr_gone stacks/elixir/.claude/rules/mix-deps.md "pessimistic constraint"; cr_gone stacks/elixir/.claude/rules/mix-deps.md "only: [:dev, :test]"
cr_gone stacks/ml/.claude/rules/notebooks.md "Notebooks are for exploration"; cr_gone stacks/ml/.claude/rules/notebooks.md "Clear outputs before committing"
cr_gone stacks/python/.claude/rules/pyproject.md "Flexible constraints"; cr_gone stacks/python/.claude/rules/pyproject.md "Detect the package manager"
cr_gone stacks/react/.claude/rules/react.md "Inertia props are the API contract"; cr_gone stacks/react/.claude/rules/react.md "Routing stays in Rails"
cr_gone rules/migrations.md "backfill in batches"; cr_gone rules/migrations.md "CONCURRENTLY"   # cut in 4.11.0 on haiku (graders-and-eve/REQ-10)
cr_kept rules/monorepo.md "consumes it"; cr_kept rules/monorepo.md -- "--filter"
cr_kept rules/testing.md "factories, fixtures and helpers"; cr_kept rules/testing.md "second runner"
cr_kept stacks/react/.claude/rules/package-json.md "frozen-lockfile"; cr_kept stacks/react/.claude/rules/package-json.md "Detect the package manager"
cr_kept stacks/rails/.claude/rules/rails.md "update_column"
if [ -z "$cr_fail" ]; then passt "cuts-recorded (the sixteen measured lines are out of their eight files; the four kept files still carry theirs)"
else failc "cuts-recorded" "$cr_fail"; fi
cr_sec=$(sed -n '/^## The cuts (4.8.0)/,/^## /p' "$COPY/evals/README.md")
if [ -n "$cr_sec" ] && for f in ui-ux hotwire liveview mix-deps notebooks pyproject react; do printf '%s\n' "$cr_sec" | grep -q "\`$f\`" || exit 1; done \
   && printf '%s\n' "$cr_sec" | grep -q 'below 2 of 3' && printf '%s\n' "$cr_sec" | grep -qi 'returns'; then
  pass "cuts-recorded (the evals README names the seven cut files and the watch rule)"
else failc "cuts-recorded" "evals/README.md has no 'The cuts (4.8.0)' section naming the seven files and the rule 'below 2 of 3 … returns'"; fi
# the intake's step 4 (measured-cuts/REQ-5, 4.8.0): an assumption a file answers names the file
# and line; a question with several parts counts as several. Prose, as check 15 reads the README.
in4=$(sed -n '/^## 4\. Ask at most four questions/,/^## 5\./p' "$COPY/skills/intake/SKILL.md")
if printf '%s\n' "$in4" | grep -q 'file and line that answers' && printf '%s\n' "$in4" | grep -q 'several parts'; then
  passt "cuts-recorded (the intake's step 4: an assumption names its file and line; a question's parts count)"
else failc "cuts-recorded" "skills/intake/SKILL.md step 4 lacks 'file and line that answers' or 'several parts'"; fi

# 59. portfolio-gen: the portfolio fixture is GENERATED, never committed (spec: .shipkit/specs/
# portfolio-run/). generate.py [--maps 3|1|0] writes three projects (shopfront, pulse, insight)
# under projects/, a registry under shipkit-home/, and a PROJECT_MAP.md for the first N of them;
# the maps are untracked so every arm shares one history. Two generations give the same HEAD
# tree per project; --maps 1 leaves pulse and insight unmapped and the registry says —; the
# three signals grep as FACTS-PORTFOLIO.md says; the vacuum-lock reason lives in pulse's map and
# nowhere else. No claude needed. Cites: portfolio-run/REQ-2 portfolio-run/REQ-3
# portfolio-run/REQ-4 portfolio-run/REQ-5
PG="$COPY/evals/fixtures/portfolio-gen/generate.py"
if [ ! -f "$PG" ]; then
  failc "portfolio-gen" "evals/fixtures/portfolio-gen/generate.py does not exist (check written first, by design)"
else
  PG_A="$WORK/pf-a"; PG_B="$WORK/pf-b"; PG_1="$WORK/pf-1"; PG_0="$WORK/pf-0"; mkdir -p "$PG_A" "$PG_B" "$PG_1" "$PG_0"
  (cd "$PG_A" && python3 "$PG" --maps 3 >/dev/null 2>&1) && (cd "$PG_B" && python3 "$PG" >/dev/null 2>&1) \
    && (cd "$PG_1" && python3 "$PG" --maps 1 >/dev/null 2>&1) && (cd "$PG_0" && python3 "$PG" --maps 0 >/dev/null 2>&1) \
    || failc "portfolio-gen" "generate.py exited non-zero"
  pg_fail=""
  for p in shopfront pulse insight; do
    pg_ta=$(git -C "$PG_A/projects/$p" rev-parse 'HEAD^{tree}' 2>/dev/null); pg_tb=$(git -C "$PG_B/projects/$p" rev-parse 'HEAD^{tree}' 2>/dev/null)
    pg_t1=$(git -C "$PG_1/projects/$p" rev-parse 'HEAD^{tree}' 2>/dev/null); pg_t0=$(git -C "$PG_0/projects/$p" rev-parse 'HEAD^{tree}' 2>/dev/null)
    if [ -z "$pg_ta" ] || [ "$pg_ta" != "$pg_tb" ] || [ "$pg_ta" != "$pg_t1" ] || [ "$pg_ta" != "$pg_t0" ]; then pg_fail="$pg_fail [$p: HEAD trees differ or missing]"; fi
    pg_n=$(cd "$PG_A/projects/$p" && find . -type f -not -path './.git/*' -not -name PROJECT_MAP.md | wc -l | tr -d ' ')
    [ "$pg_n" -ge 20 ] || pg_fail="$pg_fail [$p: $pg_n files, want >= 20]"
    pg_msgs=$(git -C "$PG_A/projects/$p" log --format=%s 2>/dev/null | sort -u | tr '\n' ',')
    [ "$pg_msgs" = "wip," ] || pg_fail="$pg_fail [$p: commit subjects: $pg_msgs]"
  done
  if [ -z "$pg_fail" ]; then pass "portfolio-gen (three projects, 20+ files each, every commit 'wip'; each HEAD tree identical across four generations)"
  else failc "portfolio-gen" "$pg_fail"; fi
  # --maps N maps the first N of shopfront, pulse, insight; the registry's Map column says so
  pg_col() { grep "^| $2 " "$1" 2>/dev/null | awk -F'|' '{gsub(/^ +| +$/, "", $4); print $4}'; }   # pg_col <registry> <project> → the Map cell
  pg_rA="$PG_A/shipkit-home/project-registry.md"; pg_r1="$PG_1/shipkit-home/project-registry.md"; pg_r0="$PG_0/shipkit-home/project-registry.md"
  if [ -f "$PG_1/projects/shopfront/PROJECT_MAP.md" ] && [ ! -e "$PG_1/projects/pulse/PROJECT_MAP.md" ] && [ ! -e "$PG_1/projects/insight/PROJECT_MAP.md" ] \
     && [ "$(pg_col "$pg_r1" shopfront)" = "PROJECT_MAP.md" ] && [ "$(pg_col "$pg_r1" pulse)" = "—" ] && [ "$(pg_col "$pg_r1" insight)" = "—" ] \
     && [ "$(pg_col "$pg_rA" pulse)" = "PROJECT_MAP.md" ] && [ -f "$PG_A/projects/insight/PROJECT_MAP.md" ] \
     && [ ! -e "$PG_0/projects/shopfront/PROJECT_MAP.md" ] && [ "$(pg_col "$pg_r0" shopfront)" = "—" ] && [ "$(pg_col "$pg_r0" insight)" = "—" ]; then
    pass "portfolio-gen (--maps 1 maps shopfront only and the registry says — for pulse and insight; --maps 3 maps all, --maps 0 none)"
  else failc "portfolio-gen" "Map cells: --maps 1 → [$(pg_col "$pg_r1" shopfront)|$(pg_col "$pg_r1" pulse)|$(pg_col "$pg_r1" insight)], --maps 0 → [$(pg_col "$pg_r0" shopfront)]"; fi
  # the three signals, as FACTS-PORTFOLIO.md lists them
  pg_sig=""
  grep -q 'sidekiq' "$PG_A/projects/shopfront/Gemfile" 2>/dev/null || pg_sig="$pg_sig [shopfront Gemfile: no sidekiq]"
  grep -q "gem .stripe." "$PG_A/projects/shopfront/Gemfile" 2>/dev/null || pg_sig="$pg_sig [shopfront Gemfile: no stripe]"
  [ -f "$PG_A/projects/shopfront/config/deploy.yml" ] || pg_sig="$pg_sig [shopfront: no config/deploy.yml]"
  grep -q ':oban' "$PG_A/projects/pulse/mix.exs" 2>/dev/null || pg_sig="$pg_sig [pulse mix.exs: no oban]"
  grep -q ':stripity_stripe' "$PG_A/projects/pulse/mix.exs" 2>/dev/null || pg_sig="$pg_sig [pulse mix.exs: no stripity_stripe]"
  [ -f "$PG_A/projects/pulse/fly.toml" ] || pg_sig="$pg_sig [pulse: no fly.toml]"
  grep -q 'celery' "$PG_A/projects/insight/pyproject.toml" 2>/dev/null || pg_sig="$pg_sig [insight pyproject.toml: no celery]"
  { [ -f "$PG_A/projects/insight/Dockerfile" ] && [ -f "$PG_A/projects/insight/render.yaml" ]; } || pg_sig="$pg_sig [insight: Dockerfile or render.yaml missing]"
  pg_pay=$(cd "$PG_A/projects/insight" 2>/dev/null && grep -rliw --exclude-dir=.git -e stripe -e paddle -e braintree -e lemonsqueezy -e paypal . | tr '\n' ' ')
  [ -z "$pg_pay" ] || pg_sig="$pg_sig [insight names a payment provider: $pg_pay]"
  if [ -z "$pg_sig" ]; then pass "portfolio-gen (sidekiq+stripe+deploy.yml; oban+stripity_stripe+fly.toml; celery+Dockerfile+render.yaml; insight names no payment provider)"
  else failc "portfolio-gen" "$pg_sig"; fi
  # the why: the vacuum-lock reason is in pulse's map and nowhere else — no file under projects/, no commit body, nothing in the no-map arm
  pg_vac=$(cd "$PG_A" && grep -rli vacuum . --exclude-dir=.git | sort | tr '\n' ' ')
  pg_vac_log=$(for p in shopfront pulse insight; do git -C "$PG_A/projects/$p" log --format=%B 2>/dev/null | grep -ci vacuum; done | tr '\n' ' ')
  if [ "$pg_vac" = "./projects/pulse/PROJECT_MAP.md " ] && [ "$pg_vac_log" = "0 0 0 " ] \
     && grep -qi 'cookie' "$PG_A/projects/pulse/PROJECT_MAP.md" && grep -q '2025-03-14' "$PG_A/projects/pulse/PROJECT_MAP.md" \
     && ! (cd "$PG_0" && grep -rqi vacuum . --exclude-dir=.git); then
    pass "portfolio-gen (the vacuum-lock reason and its date are in pulse's map only; no file, no commit body, nothing in the no-map arm)"
  else failc "portfolio-gen" "vacuum named in: [$pg_vac]; in commit bodies: [$pg_vac_log]"; fi
  # FACTS-PORTFOLIO.md lists every graded fact
  PF="$COPY/evals/fixtures/FACTS-PORTFOLIO.md"
  if [ -f "$PF" ] && grep -q 'sidekiq' "$PF" && grep -q 'oban' "$PF" && grep -q 'celery' "$PF" && grep -q 'stripity_stripe' "$PF" \
     && grep -qi 'vacuum' "$PF" && grep -q '2025-03-14' "$PF" && grep -q 'config/deploy.yml' "$PF" && grep -q 'render.yaml' "$PF"; then
    pass "portfolio-gen (FACTS-PORTFOLIO.md names the three job libraries, the Stripe manifests, the deploy files, the vacuum reason and its date)"
  else failc "portfolio-gen" "evals/fixtures/FACTS-PORTFOLIO.md is missing or misses a graded fact"; fi
fi

# 60. heading-seen: install-stack.sh looks for the section's heading before it appends (spec:
# .shipkit/specs/run-debts/; field-notes-4.9.md §2.1: office_bestie had its own
# `## Elixir-Specific`, setup added a second). A CLAUDE.md that already has the stack's first
# `## ` heading outside shipkit's markers gets the section under its marker as before, the
# sha recorded, and ONE stderr line naming the heading and /shipkit:setup rules; one without
# gets the heading once and no line; on a re-run the heading inside shipkit's own block is
# shipkit's and is not counted. The setup skill relays the line, shows the diff and edits
# neither section. No claude needed. Cites: run-debts/REQ-1 run-debts/REQ-2
hs_args="TEST_COMMAND=pytest API_STYLE=REST ASYNC_MODE=no ORM=SQLAlchemy PYTHON_FRAMEWORK=FastAPI TEST_FRAMEWORK=pytest"
HS="$WORK/heading-seen"; mkdir -p "$HS"
printf '# demo\n\n## Python-Specific\n\nRun `uv run pytest -x` here.\n' > "$HS/CLAUDE.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$HS" >/dev/null
# shellcheck disable=SC2086
hs_err=$(sh "$COPY/scripts/install-stack.sh" "$COPY" python "$HS" $hs_args 2>&1 >/dev/null); hs_rc=$?
hs_n=$(grep -c '^## Python-Specific$' "$HS/CLAUDE.md")
hs_lines=$(printf '%s\n' "$hs_err" | grep -c 'already has "## Python-Specific"')
if [ "$hs_rc" -eq 0 ] && [ "$hs_n" -eq 2 ] && [ "$hs_lines" -eq 1 ] \
   && grep -q '<!-- shipkit:stack:python -->' "$HS/CLAUDE.md" && grep -q '<!-- /shipkit:stack:python -->' "$HS/CLAUDE.md" \
   && [ -s "$HS/.claude/rules/shipkit/.section-python.sha" ] \
   && grep -q 'uv run pytest -x' "$HS/CLAUDE.md" \
   && printf '%s\n' "$hs_err" | grep 'already has' | grep -q '/shipkit:setup rules'; then
  pass "heading-seen (heading present → both sections, the project's untouched, marker and sha intact, one stderr line naming the heading and /shipkit:setup rules)"
else failc "heading-seen" "exit $hs_rc, headings $hs_n, lines $hs_lines, stderr: $hs_err"; fi
HS2="$WORK/heading-absent"; mkdir -p "$HS2"
printf '# demo\n' > "$HS2/CLAUDE.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$HS2" >/dev/null
# shellcheck disable=SC2086
hs2_err=$(sh "$COPY/scripts/install-stack.sh" "$COPY" python "$HS2" $hs_args 2>&1 >/dev/null)
# shellcheck disable=SC2086
hs2_rerun=$(sh "$COPY/scripts/install-stack.sh" "$COPY" python "$HS2" $hs_args 2>&1 >/dev/null)
hs2_n=$(grep -c '^## Python-Specific$' "$HS2/CLAUDE.md")
if [ "$hs2_n" -eq 1 ] && ! printf '%s\n%s\n' "$hs2_err" "$hs2_rerun" | grep -q 'already has'; then
  pass "heading-seen (heading absent → one heading, no line; a re-run sees the heading in its own block as shipkit's, no line)"
else failc "heading-seen" "headings $hs2_n; first run: $hs2_err; re-run: $hs2_rerun"; fi
if grep -q 'already has' "$COPY/skills/setup/SKILL.md" \
   && grep -A4 'already has' "$COPY/skills/setup/SKILL.md" | grep -q 'setup rules' \
   && grep -A4 'already has' "$COPY/skills/setup/SKILL.md" | grep -qi 'diff' \
   && grep -A4 'already has' "$COPY/skills/setup/SKILL.md" | grep -qi 'neither'; then
  passt "heading-seen (the setup skill relays the line, shows the diff, names /shipkit:setup rules and edits neither section)"
else failc "heading-seen" "skills/setup/SKILL.md does not say what to do with the installer's heading line"; fi

# 61. same-named: setup names a rule file of the same name beside its own directory, and leaves
# a tracked backup where it is (spec: .shipkit/specs/run-debts/; field-notes-4.9.md §2.2,
# §2.3: office_bestie kept dependencies.md, migrations.md and testing.md at .claude/rules/
# beside shipkit's three, unnamed; its tracked old backup was nested and became fourteen
# deletions). install-rules.sh prints ONE line naming every top-level .claude/rules/*.md whose
# basename it installs, and changes none of them; none → no line. The setup skill's backup
# phase asks `git ls-files --error-unmatch` and leaves a tracked backup at the root, named in
# the reply. No claude needed. Cites: run-debts/REQ-3 run-debts/REQ-4
SN="$WORK/same-named"; mkdir -p "$SN/.claude/rules"
printf '# My testing rule\nKEEP-ME-TESTING\n' > "$SN/.claude/rules/testing.md"
printf '# My migrations rule\nKEEP-ME-MIGRATIONS\n' > "$SN/.claude/rules/migrations.md"
printf '# Not a shipkit name\n' > "$SN/.claude/rules/house-style.md"
sn_out=$(sh "$COPY/scripts/install-rules.sh" "$COPY" "$SN" 2>&1); sn_rc=$?
sn_lines=$(printf '%s\n' "$sn_out" | grep -c 'same paths')
if [ "$sn_rc" -eq 0 ] && [ "$sn_lines" -eq 1 ] \
   && printf '%s\n' "$sn_out" | grep 'same paths' | grep -q 'migrations.md' \
   && printf '%s\n' "$sn_out" | grep 'same paths' | grep -q 'testing.md' \
   && ! printf '%s\n' "$sn_out" | grep 'same paths' | grep -q 'house-style' \
   && grep -q 'KEEP-ME-TESTING' "$SN/.claude/rules/testing.md" && grep -q 'KEEP-ME-MIGRATIONS' "$SN/.claude/rules/migrations.md" \
   && [ -f "$SN/.claude/rules/house-style.md" ] && [ -f "$SN/.claude/rules/shipkit/testing.md" ]; then
  pass "same-named (two same-named rules beside shipkit's → one line naming both, not the third; all three untouched; shipkit's own installed)"
else failc "same-named" "exit $sn_rc, lines $sn_lines: $sn_out"; fi
SN2="$WORK/same-named-none"; mkdir -p "$SN2/.claude/rules"
printf '# Not a shipkit name\n' > "$SN2/.claude/rules/house-style.md"
sn2_out=$(sh "$COPY/scripts/install-rules.sh" "$COPY" "$SN2" 2>&1)
sn2_re=$(sh "$COPY/scripts/install-rules.sh" "$COPY" "$SN2" 2>&1)
if ! printf '%s\n%s\n' "$sn2_out" "$sn2_re" | grep -q 'same paths'; then
  pass "same-named (no same-named rule → no line, on the first run and a re-run)"
else failc "same-named" "a line with no match: $sn2_out / $sn2_re"; fi
if grep -q 'git ls-files --error-unmatch' "$COPY/skills/setup/SKILL.md" \
   && grep -A6 'git ls-files --error-unmatch' "$COPY/skills/setup/SKILL.md" | grep -qi 'tracked' \
   && grep -A6 'git ls-files --error-unmatch' "$COPY/skills/setup/SKILL.md" | grep -qi 'leave it\|left in place\|left as is\|left where it is'; then
  passt "same-named (the setup skill's backup phase asks git whether the old backup is tracked and leaves a tracked one at the root)"
else failc "same-named" "skills/setup/SKILL.md's backup phase does not ask git before nesting the old backup"; fi

# 62. plugin-root-installed: the session hook writes ~/.claude/shipkit/plugin-root only from a
# root under the plugin cache (the installed plugin); any other root — a --plugin-dir checkout,
# an eval sandbox, a smoke copy — writes plugin-root.dev, and plugin-root only while none exists.
# So a dev session no longer leaves the owner's path naming a checkout or a removed scratch
# directory, which is what the second-run plan's E15 wanted a SessionEnd hook to undo: nothing
# overwritten, nothing to put back. Also: the version is printed on its own line, read from the
# root's plugin.json. Run directly with HOME and CLAUDE_CONFIG_DIR at a scratch directory; no
# claude needed. Cites: third-run/REQ-1 third-run/REQ-2 third-run/REQ-3
PI="$WORK/pihome"; PIC="$PI/.claude/plugins/cache/shipkit/shipkit/9.9.9"
mkdir -p "$PI/.claude/shipkit" "${PIC%/*}"; cp -R "$COPY" "$PIC"
pirun() { (cd "$PROJ" && HOME="$PI" CLAUDE_CONFIG_DIR="$PI/.claude" CLAUDE_PLUGIN_ROOT="$1" sh "$1/scripts/session-start.sh" </dev/null 2>/dev/null); }
pi_root() { cat "$PI/.claude/shipkit/plugin-root" 2>/dev/null; }
pi_dev()  { cat "$PI/.claude/shipkit/plugin-root.dev" 2>/dev/null; }
pi_out=$(pirun "$COPY")
if [ "$(pi_root)" = "$COPY" ] && [ "$(pi_dev)" = "$COPY" ]; then
  pass "plugin-root-installed (a checkout root with no file yet writes plugin-root and plugin-root.dev)"
else failc "plugin-root-installed" "first run from a checkout: plugin-root='$(pi_root)' dev='$(pi_dev)'"; fi
pirun "$PIC" >/dev/null
if [ "$(pi_root)" = "$PIC" ]; then pass "plugin-root-installed (a cache root writes plugin-root)"
else failc "plugin-root-installed" "run from the cache: plugin-root='$(pi_root)'"; fi
pirun "$COPY" >/dev/null
if [ "$(pi_root)" = "$PIC" ] && [ "$(pi_dev)" = "$COPY" ]; then
  pass "plugin-root-installed (a checkout root after a cache root leaves plugin-root alone and writes plugin-root.dev)"
else failc "plugin-root-installed" "checkout after cache: plugin-root='$(pi_root)' dev='$(pi_dev)'"; fi
pi_ver=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$COPY/.claude-plugin/plugin.json" | head -1)
if [ -n "$pi_ver" ] && printf '%s\n' "$pi_out" | grep -qx "shipkit: version $pi_ver" \
   && printf '%s\n' "$pi_out" | grep -qx "shipkit: plugin root is $COPY"; then
  pass "plugin-root-installed (the version is its own line, from plugin.json; the root line is unchanged)"
else failc "plugin-root-installed" "no 'shipkit: version $pi_ver' line, or the root line changed: $(printf '%s\n' "$pi_out" | head -2)"; fi
if ! [ -f "$COPY/scripts/session-end.sh" ] && ! grep -q 'SessionEnd' "$COPY/hooks/hooks.json"; then
  pass "plugin-root-installed (no SessionEnd hook: nothing overwritten, nothing to put back)"
else failc "plugin-root-installed" "a SessionEnd hook or session-end.sh exists; the start hook's rule makes it redundant"; fi

# 63. context-cost: scripts/context-cost.sh prints what a session pays for shipkit in a given
# project — the hook's output bytes there (the real hook, run with CLAUDE_PLUGIN_ROOT under a
# scratch HOME), skill and agent description bytes per plugin, the overlay skills and CLAUDE.md
# stack sections setup installed in that project, the always-on rules' bytes — with no model
# call. Run on a bare project and again after install-rules.sh + install-stack.sh python; the
# hook row must equal wc -c of the hook's own output. Cites: always-on/REQ-1 always-on/REQ-2
CC="$ROOT/scripts/context-cost.sh"; CCP="$WORK/ccproj"; mkdir -p "$CCP"
(cd "$CCP" && git init -q && git -c user.email=s@s -c user.name=smoke commit -q --allow-empty -m init)
cc_row() { printf '%s\n' "$1" | awk -v k="$2" '$1 == k { print $2; exit }'; }
if [ ! -f "$CC" ]; then
  failc "context-cost" "scripts/context-cost.sh does not exist (check written first, by design)"
else
  cc_before=$(CLAUDE_PLUGIN_ROOT="$COPY" sh "$CC" "$CCP" 2>/dev/null); rc=$?
  cc_hook=$(cd "$CCP" && HOME="$WORK/cchome" CLAUDE_CONFIG_DIR="$WORK/cchome/.claude" CLAUDE_PLUGIN_ROOT="$COPY" sh -c 'mkdir -p "$HOME/.claude"; sh "$CLAUDE_PLUGIN_ROOT/scripts/session-start.sh"; for r in shipkit spec-driven decisions --eval-rule; do sh "$CLAUDE_PLUGIN_ROOT/scripts/inject-rule.sh" $r; done' 2>/dev/null | wc -c | tr -d ' ')
  if [ "$rc" -eq 0 ] && [ "$(cc_row "$cc_before" hook)" = "$cc_hook" ] && [ "$cc_hook" -gt 100 ]; then
    pass "context-cost (the hook row equals wc -c of the hook's own output on a bare project: $cc_hook bytes)"
  else failc "context-cost" "bare project: rc=$rc hook row='$(cc_row "$cc_before" hook)' measured=$cc_hook"; fi
  for k in skills-core skills-workflows agents overlay-skills overlay-appends rules-always-on; do
    v=$(cc_row "$cc_before" "$k")
    case "$v" in ''|*[!0-9]*) failc "context-cost" "row '$k' missing or not a number: '$v'"; cc_rows=bad ;; esac
  done
  [ "${cc_rows:-ok}" = ok ] && pass "context-cost (every row present and numeric on a bare project)"
  if [ "$(cc_row "$cc_before" overlay-skills)" = 0 ] && [ "$(cc_row "$cc_before" overlay-appends)" = 0 ] \
     && [ "$(cc_row "$cc_before" skills-core)" -gt 1000 ] && [ "$(cc_row "$cc_before" rules-always-on)" -gt 1000 ]; then
    pass "context-cost (a bare project has no overlay skills or appends; the plugin's own rows are non-zero)"
  else failc "context-cost" "bare project rows: $(printf '%s\n' "$cc_before" | tr '\n' ';')"; fi
  (cd "$CCP" && sh "$COPY/scripts/install-rules.sh" "$COPY" . >/dev/null 2>&1 \
     && sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" python . TEST_COMMAND=pytest PYTHON_FRAMEWORK=FastAPI API_STYLE=REST ASYNC_MODE=no TEST_FRAMEWORK=pytest ORM=none >/dev/null 2>&1) || true
  cc_after=$(CLAUDE_PLUGIN_ROOT="$COPY" sh "$CC" "$CCP" 2>/dev/null)
  if [ "$(cc_row "$cc_after" overlay-appends)" -gt 0 ] && [ "$(cc_row "$cc_after" overlay-skills)" -gt 0 ] \
     && [ "$(cc_row "$cc_after" hook)" -lt "$(cc_row "$cc_before" hook)" ]; then
    pass "context-cost (after setup: the python append and its skill are counted; the hook row drops because the installed rules are not injected)"
  else failc "context-cost" "after setup: $(printf '%s\n' "$cc_after" | tr '\n' ';')"; fi
fi

# 64. opt-out: on a project with neither .shipkit/ nor .claude/rules/shipkit/, the hook injects
# shipkit.md and NOT spec-driven.md or decisions.md, and prints exactly one opt-in line naming
# /shipkit:product and /shipkit:setup; under CLAUDE_CODE_EVAL_CONFINED=1 all three are injected
# whatever the directory holds, so the rules eval cases keep measuring the rules. Two codewords
# (one per rule file) through a haiku session for the injection; the hook run directly for the
# line count and the confined branch. Cites: always-on/REQ-4 always-on/REQ-6 always-on/REQ-7
OO="$WORK/optout"; mkdir -p "$OO"
(cd "$OO" && git init -q && git -c user.email=s@s -c user.name=smoke commit -q --allow-empty -m init)
printf '\n\nSmoke codeword: ZEBRA-3003.\n' >> "$COPY/rules/shipkit.md"
printf '\n\nSmoke codeword: ZEBRA-4004.\n' >> "$COPY/rules/spec-driven.md"
oo_hook() { (cd "$OO" && HOME="$WORK/oohome" CLAUDE_CONFIG_DIR="$WORK/oohome/.claude" CLAUDE_PLUGIN_ROOT="$COPY" sh -c 'mkdir -p "$HOME/.claude"; sh "$CLAUDE_PLUGIN_ROOT/scripts/session-start.sh"; for r in shipkit spec-driven decisions --eval-rule; do sh "$CLAUDE_PLUGIN_ROOT/scripts/inject-rule.sh" $r; done' </dev/null 2>/dev/null); }
oo_out=$(oo_hook)
oo_optin=$(printf '%s\n' "$oo_out" | grep -c '^shipkit: run /shipkit:product or /shipkit:setup')
oo_rules=$(printf '%s\n' "$oo_out" | grep '^## Shipkit always-on rule:' | sed 's/.*: //' | tr '\n' ' ')
if [ "$oo_optin" -eq 1 ] && [ "$oo_rules" = "shipkit " ]; then
  pass "opt-out (the hook on a bare project: one opt-in line, shipkit.md injected, the two loop rules not)"
else failc "opt-out" "bare project: opt-in lines=$oo_optin injected='$oo_rules'"; fi
if model_check 64; then
out=$(cd "$OO" && claude --plugin-dir "$COPY" --model haiku -p "$CW_Q Do not use tools." 2>/dev/null | tail -20)
case "$out" in
  *ZEBRA-4004*) failc "opt-out" "spec-driven.md reached a session on a project that never opted in: $out";;
  *ZEBRA-3003*) pass "opt-out (a fresh session on a bare project sees shipkit.md's codeword and not spec-driven.md's)";;
  *) failc "opt-out" "shipkit.md's codeword did not reach the session: $out";;
esac
fi  # /model_check 64
oo_conf=$(cd "$OO" && CLAUDE_CODE_EVAL_CONFINED=1 CLAUDE_PLUGIN_ROOT="$COPY" sh -c 'for r in shipkit spec-driven decisions; do sh "$CLAUDE_PLUGIN_ROOT/scripts/inject-rule.sh" $r; done' </dev/null 2>/dev/null | grep -c '^## Shipkit always-on rule:')
if [ "$oo_conf" -eq 3 ]; then pass "opt-out (under CLAUDE_CODE_EVAL_CONFINED=1 all three rules are injected in a bare directory)"
else failc "opt-out" "confined: $oo_conf of 3 rules injected"; fi
mkdir -p "$OO/.shipkit"; oo_in=$(oo_hook | grep -c '^## Shipkit always-on rule:')
if [ "$oo_in" -eq 3 ]; then pass "opt-out (an empty .shipkit/ opts the project in: three rules injected)"
else failc "opt-out" "with .shipkit/: $oo_in of 3 rules injected"; fi

# 65. skills-merged: ten core skills (thinning plan W3). walkthrough and explain-system are
# modes of ask (--walk, --system) whose bodies are ask's reference files; unsetup,
# update-rules, context-audit and connect-memory are setup subcommands (remove, rules, audit,
# memory) whose bodies are setup's reference files; commit lives in shipkit-workflows. No stub
# directory remains (rule 21); each dispatch line names a reference file that exists and opens
# with the moved skill's heading; context-cost counts 10. No claude needed.
# Cites: always-on/REQ-10 always-on/REQ-11 always-on/REQ-12 always-on/REQ-13 always-on/REQ-14
sm_old=""; for d in walkthrough explain-system unsetup update-rules context-audit connect-memory commit; do [ -e "$COPY/skills/$d" ] && sm_old="$sm_old $d"; done
if [ -z "$sm_old" ] && [ -f "$ROOT/plugins/shipkit-workflows/skills/commit/SKILL.md" ]; then
  pass "skills-merged (no directory under skills/ for the seven old names; commit is in shipkit-workflows)"
else failc "skills-merged" "old directories left:$sm_old; workflows commit: $([ -f "$ROOT/plugins/shipkit-workflows/skills/commit/SKILL.md" ] && echo yes || echo no)"; fi
sm_ok=1; sm_why=""
for pair in "ask:--walk:walk.md:# /shipkit:ask --walk" "ask:--system:system.md:# /shipkit:ask --system" "setup:remove:remove.md:# /shipkit:setup remove" "setup:rules:rules.md:# /shipkit:setup rules" "setup:audit:audit.md:# /shipkit:setup audit" "setup:memory:memory.md:# /shipkit:setup memory"; do
  sk=${pair%%:*}; rest=${pair#*:}; arg=${rest%%:*}; rest=${rest#*:}; ref=${rest%%:*}; head1=${rest#*:}
  grep -q -- "$arg" "$COPY/skills/$sk/SKILL.md" || { sm_ok=0; sm_why="$sm_why $sk-lacks-$arg"; }
  grep -q -- "$ref" "$COPY/skills/$sk/SKILL.md" || { sm_ok=0; sm_why="$sm_why $sk-does-not-name-$ref"; }
  [ -f "$COPY/skills/$sk/$ref" ] || { sm_ok=0; sm_why="$sm_why $ref-missing"; }
  [ -f "$COPY/skills/$sk/$ref" ] && ! grep -q -- "^$head1" "$COPY/skills/$sk/$ref" && { sm_ok=0; sm_why="$sm_why $ref-heading"; }
done
if [ "$sm_ok" -eq 1 ]; then passt "skills-merged (ask dispatches --walk and --system, setup dispatches remove/rules/audit/memory, each to a reference file that opens with its heading)"
else failc "skills-merged" "dispatch:$sm_why"; fi
sm_n=$(CLAUDE_PLUGIN_ROOT="$COPY" sh "$ROOT/scripts/context-cost.sh" "$PROJ" 2>/dev/null | awk '$1 == "skills-core" { print $3 }')
sm_b=$(CLAUDE_PLUGIN_ROOT="$COPY" sh "$ROOT/scripts/context-cost.sh" "$PROJ" 2>/dev/null | awk '$1 == "skills-core" { print $2 }')
if [ "$sm_n" = "10" ] && [ "${sm_b:-99999}" -le 2950 ]; then pass "skills-merged (context-cost counts 10 core skills; descriptions $sm_b bytes, ceiling 2950)"
else failc "skills-merged" "context-cost counts $sm_n core skills ($sm_b bytes, ceiling 2950)"; fi

# 66. agents-four: four agents across the two plugins (thinning plan W4), five since spec-goldfish
# added `goldfish` (four core + test-analyzer, at most 1,075 bytes; Cites: spec-goldfish/REQ-16). tracer is
# grandfather's trace mode; the archivist's body is the map skill's forked body
# (skills/map/archivist.md, map runs with context: fork); codebase-explorer is dropped for
# Claude Code's built-in Explore agent (the check-first showed Explore callable from a session
# with the plugin, headless). No skill names a removed agent; context-cost counts 4 agents
# under 1,000 bytes. No claude needed.
# Cites: always-on/REQ-16 always-on/REQ-17 always-on/REQ-18 always-on/REQ-19
af_left=""; for a in tracer archivist codebase-explorer; do [ -e "$COPY/agents/$a.md" ] && af_left="$af_left $a"; done
if [ -z "$af_left" ]; then pass "agents-four (no tracer.md, archivist.md or codebase-explorer.md under agents/)"
else failc "agents-four" "agent files left:$af_left"; fi
if grep -q '^## Trace mode' "$COPY/agents/grandfather.md" && grep -q 'grandfather' "$COPY/skills/ask/SKILL.md"; then
  passt "agents-four (grandfather carries a Trace mode section and ask --walk hands it the brief)"
else failc "agents-four" "grandfather.md lacks '## Trace mode' or ask does not name grandfather for --walk"; fi
if grep -q '^context: fork' "$COPY/skills/map/SKILL.md" && grep -q 'archivist.md' "$COPY/skills/map/SKILL.md" \
   && [ -f "$COPY/skills/map/archivist.md" ] && grep -q '^# The archivist' "$COPY/skills/map/archivist.md"; then
  passt "agents-four (map runs forked and carries the archivist's body as archivist.md)"
else failc "agents-four" "map: fork=$(grep -c '^context: fork' "$COPY/skills/map/SKILL.md") names-archivist.md=$(grep -c 'archivist.md' "$COPY/skills/map/SKILL.md") file=$([ -f "$COPY/skills/map/archivist.md" ] && echo yes || echo no)"; fi
af_names=$(grep -rl 'codebase-explorer' "$COPY/skills" "$COPY/agents" "$ROOT/plugins/shipkit-workflows/skills" 2>/dev/null | tr '\n' ' ')
if [ -z "$af_names" ]; then passt "agents-four (no skill or agent names codebase-explorer; Explore is the built-in)"
else failc "agents-four" "codebase-explorer still named in: $af_names"; fi
# the smoke copy has no shipkit-workflows beside it, so context-cost counts the core's four;
# test-analyzer's description is added from the checkout for the ≤ 1,075 ceiling (plan §0's 1,000,
# raised by spec-goldfish for the goldfish's one line; docs/design/context-cost.md says so)
af_row=$(CLAUDE_PLUGIN_ROOT="$COPY" sh "$ROOT/scripts/context-cost.sh" "$PROJ" 2>/dev/null | awk -F'\t' '$1 == "agents" { print $2 " " $3 }')
af_b=${af_row%% *}; af_n=$(printf '%s' "$af_row" | awk '{print $2}')
af_wf=$(awk '/^description:/ { sub(/^description:[ \t]*/, ""); print; exit }' "$ROOT/plugins/shipkit-workflows/agents/test-analyzer.md" | wc -c | tr -d ' ')
af_doc=$(grep '^| `agents`' "$ROOT/docs/design/context-cost.md" | grep -c '1,075')
if [ "$af_n" = "4" ] && [ $((af_b + af_wf)) -le 1075 ] && [ "$af_doc" -ge 1 ]; then pass "agents-four (four core agents + test-analyzer: $((af_b + af_wf)) bytes of descriptions, at most 1,075, the ceiling context-cost.md gives)"
else failc "agents-four" "context-cost agents: $af_row (+ test-analyzer $af_wf); context-cost.md agents row names 1,075: $af_doc"; fi

# 67. skills-flag: an overlay's skills install only on --with-skills (thinning plan W6). A Rails
# install without the flag writes the rules and the CLAUDE.md section, copies no skill, records
# no skill in the manifest, and says how many it skipped; with the flag (before the positional
# arguments, the contract unchanged) the four skills and their manifest rows as before;
# unsetup-remove.sh removes exactly the installed set in each case; the setup skill asks once,
# names the count, and takes "no skills" when non-interactive. No claude needed.
# Cites: overlays-and-eve/REQ-1 overlays-and-eve/REQ-2 overlays-and-eve/REQ-3 overlays-and-eve/REQ-4
sf_args='TEST_COMMAND="bundle exec rspec" TEST_FRAMEWORK=RSpec DATABASE=PostgreSQL RAILS_ARCHITECTURE=MVC API_MODE=no FRONTEND=Hotwire'
SF="$WORK/skills-flag-off"; mkdir -p "$SF"; printf '# demo\n' > "$SF/CLAUDE.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$SF" >/dev/null 2>&1
sf_err=$(eval sh "$COPY/scripts/install-stack.sh" "$COPY" rails "$SF" $sf_args 2>&1 >/dev/null); sf_rc=$?
sf_skills=$(ls -d "$SF"/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
sf_man=$(grep -c "$(printf '\t')\.claude/skills/" "$SF/.claude/rules/shipkit/.installed" 2>/dev/null)
if [ "$sf_rc" -eq 0 ] && [ "$sf_skills" -eq 0 ] && [ "${sf_man:-0}" -eq 0 ] && [ -f "$SF/.claude/rules/shipkit/rails/rails.md" ] \
   && grep -q 'shipkit:stack:rails' "$SF/CLAUDE.md" && printf '%s\n' "$sf_err" | grep -q '4 skill.*--with-skills'; then
  pass "skills-flag (without the flag: rules and the section, no skill copied or recorded, one line names the 4 skipped and the flag)"
else failc "skills-flag" "without the flag: rc=$sf_rc skills=$sf_skills manifest-skill-rows=${sf_man:-0} stderr: $(printf '%s' "$sf_err" | tr '\n' '|' | cut -c1-200)"; fi
SF2="$WORK/skills-flag-on"; mkdir -p "$SF2"; printf '# demo\n' > "$SF2/CLAUDE.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$SF2" >/dev/null 2>&1
eval sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" rails "$SF2" $sf_args >/dev/null 2>&1; sf2_rc=$?
sf2_skills=$(ls -d "$SF2"/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
sf2_man=$(grep -c "$(printf '\t')\.claude/skills/" "$SF2/.claude/rules/shipkit/.installed" 2>/dev/null)
if [ "$sf2_rc" -eq 0 ] && [ "$sf2_skills" -eq 4 ] && [ "${sf2_man:-0}" -ge 4 ] && grep -q 'bundle exec rspec' "$SF2/.claude/skills/new-feature/SKILL.md"; then
  pass "skills-flag (--with-skills before the positional arguments: the four skills installed and recorded, placeholders filled)"
else failc "skills-flag" "with the flag: rc=$sf2_rc skills=$sf2_skills manifest-skill-rows=${sf2_man:-0}"; fi
sh "$COPY/scripts/unsetup-remove.sh" "$SF" --yes >/dev/null 2>&1; sh "$COPY/scripts/unsetup-remove.sh" "$SF2" --yes >/dev/null 2>&1
if [ ! -d "$SF/.claude/rules/shipkit" ] && [ ! -d "$SF2/.claude/rules/shipkit" ] && [ ! -d "$SF2/.claude/skills/new-feature" ] && [ -f "$SF/CLAUDE.md" ]; then
  pass "skills-flag (unsetup removes exactly what each install recorded: rules in both, the skills only where installed)"
else failc "skills-flag (unsetup)" "off: rules=$([ -d "$SF/.claude/rules/shipkit" ] && echo left || echo gone); on: rules=$([ -d "$SF2/.claude/rules/shipkit" ] && echo left || echo gone) skills=$([ -d "$SF2/.claude/skills/new-feature" ] && echo left || echo gone)"; fi
if grep -q -- '--with-skills' "$COPY/skills/setup/SKILL.md" && grep -qi 'listed in every session' "$COPY/skills/setup/SKILL.md" \
   && grep -qi 'non-interactive' "$COPY/skills/setup/SKILL.md"; then
  passt "skills-flag (the setup skill asks once about the overlay's skills, says they are listed every session, and defaults to none when non-interactive)"
else failc "skills-flag" "skills/setup/SKILL.md does not describe the --with-skills question"; fi

# 68. appends-trimmed: the overlay CLAUDE.md appends carry only the lines the W7 audit kept
# (docs/design/trim-audit-overlays.md, the owner's yes per group, 2026-10-30): no generic "or"
# Key Paths table, no "Ruff or flake8" style line, no Django block in the python append (its
# five lines live in stacks/python/.claude/rules/django.md, path-scoped); rails.md and react.md
# carry paths: so they load only on a matching edit. Each append at or under its post-trim
# size. No claude needed. Cites: overlays-and-eve/REQ-6 overlays-and-eve/REQ-7
at_fail=""
at_gone() { grep -qF -- "$2" "$COPY/stacks/$1/CLAUDE.md.append" && at_fail="$at_fail [$1 still has: $2]"; :; }
at_gone python 'Django Gotchas'; at_gone python 'Ruff (`ruff check .`) or flake8'; at_gone python '`src/` or `app/`'; at_gone python 'alembic upgrade head'
at_gone rails 'Prefer scopes over class methods'; at_gone rails 'db:seed'; at_gone react '`src/screens/`'; at_gone react 'Prettier'
at_gone elixir 'mix test.watch'; at_gone elixir 'Pipe operator'; at_gone go 'goose up'; at_gone go 'No getters'; at_gone static '`css/` or `styles/`'
for pair in python:1100 rails:1420 react:900 elixir:1220 go:1270 static:420; do
  st=${pair%%:*}; cap=${pair#*:}; b=$(wc -c < "$COPY/stacks/$st/CLAUDE.md.append" | tr -d ' ')
  [ "$b" -le "$cap" ] || at_fail="$at_fail [$st append $b bytes, cap $cap]"
done
if [ -z "$at_fail" ]; then passt "appends-trimmed (the six big appends carry only the kept lines, each at or under its post-trim size)"
else failc "appends-trimmed" "$at_fail"; fi
if [ -f "$COPY/stacks/python/.claude/rules/django.md" ] && sed -n '1,8p' "$COPY/stacks/python/.claude/rules/django.md" | grep -q '^paths:' \
   && grep -q 'select_related' "$COPY/stacks/python/.claude/rules/django.md" && grep -q 'post_save' "$COPY/stacks/python/.claude/rules/django.md"; then
  passt "appends-trimmed (the five Django lines live in a path-scoped stacks/python/.claude/rules/django.md)"
else failc "appends-trimmed" "stacks/python/.claude/rules/django.md missing, unscoped, or without the Django lines"; fi
if sed -n '1,8p' "$COPY/stacks/rails/.claude/rules/rails.md" | grep -q '^paths:' && grep -q 'app/\*\*/\*.rb' "$COPY/stacks/rails/.claude/rules/rails.md" \
   && sed -n '1,8p' "$COPY/stacks/react/.claude/rules/react.md" | grep -q '^paths:' && grep -q 'app/frontend' "$COPY/stacks/react/.claude/rules/react.md"; then
  passt "appends-trimmed (rails.md and react.md carry paths: and load only on a matching edit)"
else failc "appends-trimmed" "rails.md or react.md lacks paths: (rails: $(sed -n '1,3p' "$COPY/stacks/rails/.claude/rules/rails.md" | tr '\n' '|'))"; fi

# 69. skills-cut: two Rails overlay skills the W8 audit found said by the loop or the rules are
# gone (deploy-check, safety-check — the owner's yes, 2026-10-30); release carries their two
# unique lines (brakeman, asset compilation) in its Phase 1; --with-skills rails installs the
# four that remain and the setup text names four. Decision 0004 is a five-part record that
# decision-check lists; 0003 is marked amended, not deleted. No claude needed.
# Cites: overlays-and-eve/REQ-9 overlays-and-eve/REQ-10
sc_fail=""
for d in deploy-check safety-check; do [ -e "$COPY/stacks/rails/.claude/skills/$d" ] && sc_fail="$sc_fail [$d still shipped]"; done
grep -qi 'brakeman' "$COPY/stacks/rails/.claude/skills/release/SKILL.md" || sc_fail="$sc_fail [release lacks brakeman]"
grep -qi 'assets:precompile\|asset compilation\|assets compile' "$COPY/stacks/rails/.claude/skills/release/SKILL.md" || sc_fail="$sc_fail [release lacks the asset line]"
SC="$WORK/skills-cut"; mkdir -p "$SC"; printf '# demo\n' > "$SC/CLAUDE.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$SC" >/dev/null 2>&1
sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" rails "$SC" TEST_COMMAND="bundle exec rspec" TEST_FRAMEWORK=RSpec DATABASE=PostgreSQL RAILS_ARCHITECTURE=MVC API_MODE=no FRONTEND=Hotwire >/dev/null 2>&1
sc_n=$(ls -d "$SC"/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
[ "$sc_n" -eq 4 ] || sc_fail="$sc_fail [with-skills rails installed $sc_n skills, expected 4]"
grep -q 'ships 4 skills' "$COPY/skills/setup/SKILL.md" || sc_fail="$sc_fail [setup text does not say 4 skills]"
if [ -z "$sc_fail" ]; then pass "skills-cut (deploy-check and safety-check gone; release carries brakeman and the asset line; --with-skills rails installs 4; setup says 4)"
else failc "skills-cut" "$sc_fail"; fi
if [ -f "$ROOT/.shipkit/decisions/0004-overlay-skills-flag.md" ] && grep -q '^\*\*Falsifiability\.\*\*' "$ROOT/.shipkit/decisions/0004-overlay-skills-flag.md" \
   && grep -q '^\*\*Fired-if\.\*\*' "$ROOT/.shipkit/decisions/0004-overlay-skills-flag.md" \
   && grep -qi 'amended by 0004\|amended on' "$ROOT/.shipkit/decisions/0003-overlay-skills-home.md"; then
  pass "skills-cut (decision 0004 is a five-part record with its clauses; 0003 is marked amended, not deleted)"
else failc "skills-cut" "0004 missing or without Falsifiability/Fired-if, or 0003 not marked amended"; fi

# 70. report-shapes: eve's prompt by the W9 audit (the owner's yes, 2026-10-30). The matrix and
# consolidation shapes left agents/eve.md for skills/ask/reports.md, which ask reads only on those
# two routes: in ask's SKILL.md they would load into the main session on every /shipkit:ask, the
# grandfather questions too. eve.md stays within the measured size and keeps what the audit put out
# of scope (step 0, step 4's sentence, the digest shape). No claude needed.
# Cites: overlays-and-eve/REQ-12 overlays-and-eve/REQ-13
rs_fail=""; rs_e="$COPY/agents/eve.md"; rs_s="$COPY/skills/ask/SKILL.md"; rs_r="$COPY/skills/ask/reports.md"
[ -f "$rs_r" ] || rs_fail="$rs_fail [reports.md missing]"
for rs_t in 'version installed | declared constraint' 'consolidation cost'; do
  grep -qF "$rs_t" "$rs_r" 2>/dev/null || rs_fail="$rs_fail [reports.md lacks: $rs_t]"
  grep -qF "$rs_t" "$rs_e" && rs_fail="$rs_fail [eve.md still carries: $rs_t]"
  grep -qF "$rs_t" "$rs_s" && rs_fail="$rs_fail [SKILL.md carries: $rs_t]"
done
for rs_q in matrix consolidate; do
  grep -A3 -- "^  - \`--all $rs_q" "$rs_s" | grep -qF 'reports.md' || rs_fail="$rs_fail [ask's $rs_q route does not read reports.md]"
done
for rs_t in 'Good questions for you' 'cheat-sheet'; do grep -qF "$rs_t" "$rs_e" && rs_fail="$rs_fail [eve.md still carries: $rs_t]"; done
for rs_t in '### 0. Triage' 'offer no motives of your own' '### Attention digest'; do grep -qF "$rs_t" "$rs_e" || rs_fail="$rs_fail [eve.md lost: $rs_t]"; done
rs_b=$(wc -c < "$rs_e" | tr -d ' ')
[ "$rs_b" -le 12067 ] || rs_fail="$rs_fail [eve.md is $rs_b bytes, ceiling 12067]"
if [ -z "$rs_fail" ]; then passt "report-shapes (the matrix and consolidation shapes are in ask's reports.md, read on those two routes only; eve.md $rs_b bytes, ceiling 12067)"
else failc "report-shapes" "$rs_fail"; fi

# 71. brief-cites: the brief says how a test cites its requirement, with the spec's own slug. The
# 4.12 run's agent wrote tests that cited nothing, and REQ-2 and REQ-3 stayed PENDING-TEST after
# the build (field-notes-4.12.md §8.1). No claude needed.
# Cites: run-again/REQ-1
BC="$WORK/brief-cites"; mkdir -p "$BC/.shipkit/specs/refunds" "$BC/app"
(cd "$BC" && git init -q && printf 'x = 1\n' > app/refunds.py)
cat > "$BC/.shipkit/specs/refunds/spec.md" <<'SPEC'
# Spec: Refunds

> Spec accepted at commit `abc1234` on main.
> Status: open
> Paths: app/

## Purpose
A charged order can be refunded through the gateway.

## Requirements (EARS)
- **REQ-1.** When a refund is requested, the system shall call the gateway.

## Out of scope
Partial refunds.
SPEC
cat > "$BC/.shipkit/specs/refunds/tasks.md" <<'TASKS'
# Tasks: Refunds

- [ ] **T1** The refund call → REQ-1
  - Files: app/refunds.py
  - Test: tests/test_refunds.py fails first
  - After: none
  - Done when: `pytest` exits 0
TASKS
(cd "$BC" && git add -A && git -c user.email=s@s -c user.name=s commit -q -m init)
bc_prove=$(sh "$COPY/scripts/brief.sh" "$BC" refunds T1 2>/dev/null | awk '/^## Prove it with/ { on = 1; next } /^## / { on = 0 } on')
if printf '%s\n' "$bc_prove" | grep -qF 'refunds/REQ-N'; then pass "brief-cites (Prove it with says each test cites refunds/REQ-N, the spec's own slug)"
else failc "brief-cites" "Prove it with: $bc_prove"; fi

# 72. stack-skill-allowed: a skill setup installed is not the agent's change, by the manifest and
# not by the directory: .claude/skills/ is also where a project keeps its own skills, and those
# are still reported (field-notes-4.12.md §9.2; run-again's design). No manifest, nothing changes.
# Cites: run-again/REQ-2
BS="$WORK/stack-skill"; mkdir -p "$BS"; (cd "$BC" && tar cf - .) | (cd "$BS" && tar xf -)
bs_base=$(git -C "$BS" rev-parse HEAD)
mkdir -p "$BS/.claude/rules/shipkit" "$BS/.claude/skills/new-feature" "$BS/.claude/skills/own"
printf 'x = 2\n' > "$BS/app/refunds.py"
printf -- '---\nname: new-feature\n---\n' > "$BS/.claude/skills/new-feature/SKILL.md"
printf '#shipkit-manifest v1\nversion=9.9.9\nstacks=python\nabc\t.claude/skills/new-feature/SKILL.md\n' > "$BS/.claude/rules/shipkit/.installed"
bs_out=$(sh "$COPY/scripts/brief-verify.sh" "$BS" refunds T1 "$bs_base" 2>&1); bs_rc=$?
if [ "$bs_rc" -eq 0 ] && ! printf '%s\n' "$bs_out" | grep -q '^OUTSIDE'; then pass "stack-skill-allowed (a skill the manifest lists → not OUTSIDE, exit 0)"
else failc "stack-skill-allowed" "listed skill: exit $bs_rc: $bs_out"; fi
printf -- '---\nname: own\n---\n' > "$BS/.claude/skills/own/SKILL.md"
bs_out=$(sh "$COPY/scripts/brief-verify.sh" "$BS" refunds T1 "$bs_base" 2>&1); bs_rc=$?
if [ "$bs_rc" -eq 1 ] && [ "$(printf '%s\n' "$bs_out" | grep -c '^OUTSIDE')" -eq 1 ] && printf '%s\n' "$bs_out" | grep -qx 'OUTSIDE .claude/skills/own/SKILL.md'; then
  pass "stack-skill-allowed (the project's own skill, not in the manifest → OUTSIDE, exit 1)"
else failc "stack-skill-allowed" "own skill: exit $bs_rc: $bs_out"; fi
rm -f "$BS/.claude/rules/shipkit/.installed" "$BS/.claude/skills/own/SKILL.md"
bs_out=$(sh "$COPY/scripts/brief-verify.sh" "$BS" refunds T1 "$bs_base" 2>&1); bs_rc=$?
if [ "$bs_rc" -eq 1 ] && printf '%s\n' "$bs_out" | grep -qx 'OUTSIDE .claude/skills/new-feature/SKILL.md'; then
  pass "stack-skill-allowed (no manifest → the skill is OUTSIDE, as before)"
else failc "stack-skill-allowed" "no manifest: exit $bs_rc: $bs_out"; fi

# 73. reviewer-skills: the reviewer's step 4 reads a stack skill as brief-verify does, by the
# manifest, and still lists a skill the manifest does not name. The agent's text, no claude needed.
# Cites: run-again/REQ-3
rv_step=$(awk '/^4\. \*\*Changes beyond the spec\.\*\*/ { on = 1 } /^5\. / { on = 0 } on' "$COPY/agents/reviewer.md")
rv_fail=""
printf '%s\n' "$rv_step" | grep -qF '.claude/rules/shipkit/.installed' || rv_fail="$rv_fail [step 4 does not name the manifest]"
printf '%s\n' "$rv_step" | grep -qF '.claude/skills/' || rv_fail="$rv_fail [step 4 does not name .claude/skills/]"
printf '%s\n' "$rv_step" | grep -qiF "project's own" || rv_fail="$rv_fail [step 4 does not say the project's own skill is listed]"
if [ -z "$rv_fail" ]; then passt "reviewer-skills (step 4 reads a stack skill by the manifest; a project's own skill is still listed)"
else failc "reviewer-skills" "$rv_fail"; fi

# 74. ship-capture: the gate's pre-step capture has a named home inside its own cleanup. The 4.12
# gate kept it at /tmp/ship-pre-status.txt and left it there (field-notes-4.12.md §9.3). The
# skill's text, no claude needed; check 29 runs the gate and sees no scratch file left.
# Cites: run-again/REQ-4
sc_ship="$COPY/skills/ship/SKILL.md"; sc_fail=""
grep -qF 'git status --porcelain > "${TMPDIR:-/tmp}/shipkit-ship-status.out"' "$sc_ship" || sc_fail="$sc_fail [the pre-step does not write shipkit-ship-status.out]"
grep -E '^\| 7 \|' "$sc_ship" | grep -qF 'shipkit-ship-status.out' || sc_fail="$sc_fail [step 7 does not read it]"
grep -qF 'rm -f "${TMPDIR:-/tmp}"/shipkit-ship-*.out' "$sc_ship" || sc_fail="$sc_fail [the cleanup no longer covers *.out]"
grep -qF 'and keep its output' "$sc_ship" && sc_fail="$sc_fail [the old unnamed capture is still there]"
if [ -z "$sc_fail" ]; then passt "ship-capture (the pre-step writes shipkit-ship-status.out, step 7 reads it, the cleanup's pattern covers it)"
else failc "ship-capture" "$sc_fail"; fi

# 75. setup-rule-count: setup's word for how many rules it copies matches the files it copies, so
# the next rule added or cut fails here rather than in a user's reply (field-notes-4.12.md §2.1).
# Cites: run-again/REQ-5
sr_n=$(ls "$COPY"/rules/*.md | wc -l | tr -d ' ')
case "$sr_n" in 6) sr_w=six ;; 7) sr_w=seven ;; 8) sr_w=eight ;; 9) sr_w=nine ;; 10) sr_w=ten ;; *) sr_w="$sr_n" ;; esac
if grep -qF "copies all $sr_w rules" "$COPY/skills/setup/SKILL.md"; then passt "setup-rule-count (setup says all $sr_w rules; $sr_n files under rules/)"
else failc "setup-rule-count" "$sr_n files under rules/, setup says: $(grep -oE 'copies all [a-z0-9]+ rules' "$COPY/skills/setup/SKILL.md")"; fi

# 76. ship-retry: a reply with no verdict line is not a review. The reviewer's last call can be
# SubagentHandback {"message": "placeholder"}, which ends it with the review unsent (3 of 74 gate
# sessions; field-notes-5.0.md §9.1), so the gate starts it once more, and a second miss is still
# FAIL: never a READY on no review. The skill's text, no claude needed; the path itself was forced
# once with a reviewer that only replies placeholder (run-again's design).
# Cites: run-again/REQ-15
sy_step=$(awk '/^- \*\*Step 4 — the reviewer/ { on = 1 } /^- \*\*Step 5 — / { on = 0 } on' "$COPY/skills/ship/SKILL.md")
sy_fail=""
printf '%s\n' "$sy_step" | grep -qF 'no `VERDICT:` line' || sy_fail="$sy_fail [step 4 does not name a reply with no verdict line]"
printf '%s\n' "$sy_step" | grep -qF 'start the reviewer once more' || sy_fail="$sy_fail [step 4 does not start it once more]"
printf '%s\n' "$sy_step" | grep -qF 'a second reply with no verdict line' || sy_fail="$sy_fail [step 4 does not say a second miss is FAIL]"
if [ -z "$sy_fail" ]; then passt "ship-retry (a reply with no verdict line starts the reviewer once more; a second miss is FAIL)"
else failc "ship-retry" "$sy_fail"; fi

# 77. reviewer-fixture: every reviewer case builds its workspace from one script, so a new case
# costs a few lines and not 4.9 KB, and the evals ceiling holds without a fourth raise (decision
# 'The ceiling stays', G9). reviewer-decisions: a contradicted decision fails the review, and the
# text says so; it used to say "the ship gate weighs them", and the gate has no such step. The
# text, no claude needed. Cites: decisions-bind/REQ-12 decisions-bind/REQ-13
rf_fail=""
[ -f "$COPY/evals/lib/review-fixture.sh" ] || rf_fail=" [evals/lib/review-fixture.sh is missing]"
# A held-out reviewer case lives under evals/holdout/ and builds from the same script
# (misses-to-checks/REQ-41).
for rf_case in "$COPY"/evals/reviewer/*/ "$COPY"/evals/holdout/reviewer-*/; do
  [ -d "$rf_case" ] || continue
  grep -q 'lib/review-fixture\.sh' "$rf_case/fixture.sh" || rf_fail="$rf_fail [$(basename "$(dirname "$rf_case")")/$(basename "$rf_case") builds its own]"
done
if [ -z "$rf_fail" ]; then pass "reviewer-fixture (every reviewer case, held-out ones too, uses evals/lib/review-fixture.sh)"
else failc "reviewer-fixture" "$rf_fail"; fi
rd_fail=""
for rd_want in '`contradicted`. Otherwise it is' '`not built`' 'turned down'; do
  grep -qF "$rd_want" "$COPY/agents/reviewer.md" || rd_fail="$rd_fail [no: $rd_want]"
done
grep -q 'gate weighs' "$COPY/agents/reviewer.md" && rd_fail="$rd_fail [still says the gate weighs them]"
if [ -z "$rd_fail" ]; then passt "reviewer-decisions (two states named; a contradicted decision fails the verdict; no claim about the gate)"
else failc "reviewer-decisions" "$rd_fail"; fi

# 78. map-read-grep: map_read used to read a tool's input path only, so a repo-wide Grep landing on
# the map did not register, and eve/why read 2 of 3 on a run whose reply cites the map. A trace's
# Grep result holds the paths ("Found 1 file\napp/x.rb", or "app/x.rb:5:…" in content mode; read on
# 2026-10-31 from readable-numbers T1's kept traces), so a result line's path counts. A line of
# another file that only mentions the map does not, and nor does any other tool's result. Stored
# two-line traces, no claude needed. Cites: readable-numbers/REQ-7 readable-numbers/REQ-8
MR="$WORK/mr"; mkdir -p "$MR"
mr_trace() {  # mr_trace <name> <tool> <tool_result content, as JSON>
  { printf '{"type":"assistant","parent_tool_use_id":null,"message":{"id":"m1","content":[{"type":"tool_use","id":"t1","name":"%s","input":{"pattern":"VACUUM"}}]}}\n' "$2"
    printf '{"type":"user","parent_tool_use_id":null,"message":{"content":[{"type":"tool_result","tool_use_id":"t1","content":%s}]}}\n' "$3"
  } > "$MR/$1.jsonl"
}
mr_fail=""
mr_want() {  # mr_want <name> <map_read map_shell>
  mr_got=$(sh "$ROOT/scripts/trace-tools.sh" "$MR/$1.jsonl" 2>&1 | awk 'NR==2 { print $11, $12 }')
  [ "$mr_got" = "$2" ] || mr_fail="$mr_fail [$1: wanted $2, read $mr_got]"
}
mr_trace files Grep '"Found 2 files\nprojects/pulse/PROJECT_MAP.md\nprojects/pulse/mix.exs"'
mr_trace content Grep '"projects/pulse/PROJECT_MAP.md:41:the nightly VACUUM FULL"'
mr_trace blocks Grep '[{"type":"text","text":"Found 1 file\nprojects/pulse/PROJECT_MAP.md"}]'
mr_trace other Grep '"Found 1 file\napp/orders.py"'
mr_trace mention Grep '"README.md:3:see PROJECT_MAP.md for the VACUUM note"'
mr_trace none Grep '"No matches found"'
mr_trace notgrep Read '"Found 1 file\nprojects/pulse/PROJECT_MAP.md"'
for mr_case in files content blocks; do mr_want "$mr_case" "1 0"; done
for mr_case in other mention none notgrep; do mr_want "$mr_case" "0 0"; done
if [ -z "$mr_fail" ]; then pass "map-read-grep (a Grep listing the map counts, whatever its path; a line naming it from another file, and any other tool's result, do not; map_shell unchanged)"
else failc "map-read-grep" "$mr_fail"; fi

# 79. django-only: django.md's paths match any models.py, so a FastAPI project loaded Django advice
# on every read of one, and setup said it loaded on Django files only. It installs only where the
# framework names Django, and that is a glob, so `Django 5.2` from a model keeps a real project its
# rule. A framework setup could not detect reads as not Django. No claude needed.
# Cites: fourth-project/REQ-1 fourth-project/REQ-2 fourth-project/REQ-3
dj_fail=""; dj_n=0
dj_install() {  # dj_install <framework> → a fresh project with the python overlay; sets DJ
  dj_n=$((dj_n + 1)); DJ="$WORK/django-$dj_n"; mkdir -p "$DJ"
  sh "$COPY/scripts/install-rules.sh" "$COPY" "$DJ" >/dev/null 2>&1
  sh "$COPY/scripts/install-stack.sh" "$COPY" python "$DJ" TEST_COMMAND=pytest API_STYLE=REST \
    ASYNC_MODE=no ORM=x PYTHON_FRAMEWORK="$1" TEST_FRAMEWORK=pytest >/dev/null 2>&1 \
    || dj_fail="$dj_fail [$1: install failed]"
  [ -f "$DJ/.claude/rules/shipkit/python/pyproject.md" ] || dj_fail="$dj_fail [$1: no pyproject.md]"
}
for dj_fw in Django django 'Django 5.2'; do
  dj_install "$dj_fw"
  [ -f "$DJ/.claude/rules/shipkit/python/django.md" ] || dj_fail="$dj_fail [$dj_fw: no django.md]"
  grep -q 'python/django.md' "$DJ/.claude/rules/shipkit/.installed" || dj_fail="$dj_fail [$dj_fw: not in the manifest]"
done
for dj_fw in FastAPI Flask None 'TODO: which framework'; do
  dj_install "$dj_fw"
  [ ! -f "$DJ/.claude/rules/shipkit/python/django.md" ] || dj_fail="$dj_fail [$dj_fw: django.md installed]"
  ! grep -q 'python/django.md' "$DJ/.claude/rules/shipkit/.installed" || dj_fail="$dj_fail [$dj_fw: in the manifest]"
done
grep -q 'loads on Django files only' "$COPY/skills/setup/SKILL.md" && dj_fail="$dj_fail [setup keeps the parenthesis]"
grep -q 'django.md. on a Django project' "$COPY/skills/setup/SKILL.md" || dj_fail="$dj_fail [setup does not say when it installs]"
if [ -z "$dj_fail" ]; then pass "django-only (django.md and its manifest row on Django, django and Django 5.2; neither on FastAPI, Flask, None or a TODO; pyproject.md on all; setup says so)"
else failc "django-only" "$dj_fail"; fi

# 80. stamp-dates: six stamp lines in five skills held a literal date with no source named, and a
# real intake was stamped 2026-10-05 on 2026-10-31 (field-notes-5.0.md §4.1). Each now holds
# <YYYY-MM-DD> and its file names `date +%F`. This reads the templates: what a model does with them
# is read on a real run (fourth-project T2). No claude needed.
# Cites: fourth-project/REQ-4 fourth-project/REQ-5
sd_fail=""
sd_hits=$(grep -rlE '^[[:space:]]*> .*20[0-9]{2}-[0-9]{2}-[0-9]{2}' "$COPY/skills" | sed "s#^$COPY/##" | tr '\n' ' ')
[ -z "$sd_hits" ] || sd_fail="$sd_fail [a literal date on a stamp line: $sd_hits]"
while IFS='|' read -r sd_file sd_line; do
  grep -qF "$sd_line" "$COPY/skills/$sd_file" || sd_fail="$sd_fail [$sd_file: no '$sd_line']"
  grep -qF 'date +%F' "$COPY/skills/$sd_file" || sd_fail="$sd_fail [$sd_file: no date +%F]"
done <<'SDEOF'
escape/SKILL.md|> Recorded on <YYYY-MM-DD>.
handoff/SKILL.md|> Written <YYYY-MM-DD> at commit
product/SKILL.md|> Studio reviewed on <YYYY-MM-DD>.
product/reference.md|> Product reviewed on <YYYY-MM-DD>.
intake/SKILL.md|> Intake taken on <YYYY-MM-DD>.
ship/reference.md|> Checked on <YYYY-MM-DD> at commit
SDEOF
if [ -z "$sd_fail" ]; then passt "stamp-dates (no literal date on a stamp line in any skill; all six hold <YYYY-MM-DD>, and each file names date +%F)"
else failc "stamp-dates" "$sd_fail"; fi

# 81. section-clean: a filled section kept every template comment, the alternatives the project did
# not pick (`<!-- Django / FastAPI / Flask / None -->`) among them, in a file every session loads,
# and told a sync project to use an async ORM (field-notes-5.0.md §2.2). Comments go as the template
# is read, so no value and neither marker can be touched, and the sources keep them for setup's
# TODO hints. The sha is taken from the section as written: a re-run reads "already current", a
# changed value refreshes without an "edited" warning, and an unedited section from 5.0.0, comments
# and all, refreshes at the next setup. No claude needed.
# Cites: fourth-project/REQ-6 fourth-project/REQ-7 fourth-project/REQ-8 fourth-project/REQ-9
sc2_fail=""
sc2_inner() {  # sc2_inner <stack> <CLAUDE.md> → the lines between that stack's markers
  awk -v s="<!-- shipkit:stack:$1 -->" -v e="<!-- /shipkit:stack:$1 -->" \
    'index($0,s){on=1; next} index($0,e){on=0; next} on' "$2"
}
sc2_n=0
for sc2_src in "$COPY"/stacks/*/CLAUDE.md.append; do
  sc2_st=$(basename "$(dirname "$sc2_src")"); sc2_n=$((sc2_n + 1))
  sc2_d="$WORK/section-$sc2_st"; mkdir -p "$sc2_d"
  # shellcheck disable=SC2046
  sh "$COPY/scripts/install-stack.sh" "$COPY" "$sc2_st" "$sc2_d" \
    $(grep -rho '{{[A-Z_][A-Z0-9_]*}}' "$COPY/stacks/$sc2_st" | sed 's/[{}]//g' | sort -u | sed 's/$/=x/') >/dev/null 2>&1 \
    || sc2_fail="$sc2_fail [$sc2_st: install failed]"
  sc2_inner "$sc2_st" "$sc2_d/CLAUDE.md" | grep -q '<!--' && sc2_fail="$sc2_fail [$sc2_st: a comment survived]"
  grep -qF "<!-- shipkit:stack:$sc2_st -->" "$sc2_d/CLAUDE.md" && grep -qF "<!-- /shipkit:stack:$sc2_st -->" "$sc2_d/CLAUDE.md" \
    || sc2_fail="$sc2_fail [$sc2_st: a marker went]"
  sc2_inner "$sc2_st" "$sc2_d/CLAUDE.md" | grep -q '[^[:space:]]' || sc2_fail="$sc2_fail [$sc2_st: the section is empty]"
done
[ "$sc2_n" -ge 10 ] || sc2_fail="$sc2_fail [only $sc2_n stacks read]"
grep -qF '<!-- Django / FastAPI / Flask / None -->' "$COPY/stacks/python/CLAUDE.md.append" \
  || sc2_fail="$sc2_fail [the source lost its comment]"
sc2_py() {  # sc2_py <dir> <ASYNC_MODE> [TEST_COMMAND] → install python there
  mkdir -p "$1"
  sh "$COPY/scripts/install-stack.sh" "$COPY" python "$1" TEST_COMMAND="${3:-pytest}" API_STYLE=REST \
    ASYNC_MODE="$2" ORM=x PYTHON_FRAMEWORK=FastAPI TEST_FRAMEWORK=pytest 2>&1
}
for sc2_async in no No; do
  sc2_d="$WORK/section-sync-$sc2_async"; sc2_py "$sc2_d" "$sc2_async" >/dev/null
  grep -q 'Async DB:' "$sc2_d/CLAUDE.md" && sc2_fail="$sc2_fail [ASYNC_MODE=$sc2_async keeps Async DB]"
  grep -q '^- \*\*Async:\*\* [Nn]o$' "$sc2_d/CLAUDE.md" || sc2_fail="$sc2_fail [ASYNC_MODE=$sc2_async: no clean Async line]"
done
sc2_d="$WORK/section-async"; sc2_py "$sc2_d" yes >/dev/null
grep -q 'Async DB:' "$sc2_d/CLAUDE.md" || sc2_fail="$sc2_fail [ASYNC_MODE=yes lost Async DB]"
sc2_d="$WORK/section-todo"; sc2_py "$sc2_d" 'TODO: async or not' >/dev/null
grep -q 'Async DB:' "$sc2_d/CLAUDE.md" || sc2_fail="$sc2_fail [a TODO lost Async DB]"
# The sha, read three ways. A sync project, so it holds after both cuts.
sc2_d="$WORK/section-sha"; sc2_py "$sc2_d" no >/dev/null
sc2_shaf="$sc2_d/.claude/rules/shipkit/.section-python.sha"
sc2_inner python "$sc2_d/CLAUDE.md" > "$WORK/section-inner"
[ "$(. "$COPY/scripts/lib-manifest.sh"; file_sha "$WORK/section-inner")" = "$(cat "$sc2_shaf" 2>/dev/null)" ] \
  || sc2_fail="$sc2_fail [the sha is not of the section as written]"
cp "$sc2_d/CLAUDE.md" "$WORK/section-before"
sc2_out=$(sc2_py "$sc2_d" no)
printf '%s\n' "$sc2_out" | grep -q 'already current' || sc2_fail="$sc2_fail [a re-run did not read current]"
cmp -s "$sc2_d/CLAUDE.md" "$WORK/section-before" || sc2_fail="$sc2_fail [a re-run changed CLAUDE.md]"
sc2_out=$(sc2_py "$sc2_d" no 'uv run pytest')
printf '%s\n' "$sc2_out" | grep -q 'section was edited' && sc2_fail="$sc2_fail [a changed value read as edited]"
grep -q 'uv run pytest' "$sc2_d/CLAUDE.md" || sc2_fail="$sc2_fail [a changed value did not refresh]"
# As a project set up on 5.0.0: its section holds the comments, and its sha is of that text.
sc2_d="$WORK/section-old"; sc2_py "$sc2_d" no >/dev/null
awk '{ if ($0 == "- **Async:** no") print "- **Async:** no <!-- yes/no -->"; else print }' "$sc2_d/CLAUDE.md" > "$WORK/section-oldmd"
cat "$WORK/section-oldmd" > "$sc2_d/CLAUDE.md"
sc2_inner python "$sc2_d/CLAUDE.md" > "$WORK/section-oldinner"
(. "$COPY/scripts/lib-manifest.sh"; file_sha "$WORK/section-oldinner") > "$sc2_d/.claude/rules/shipkit/.section-python.sha"
sc2_out=$(sc2_py "$sc2_d" no)
sc2_inner python "$sc2_d/CLAUDE.md" | grep -q '<!--' && sc2_fail="$sc2_fail [a 5.0.0 section kept its comment: $(printf '%s' "$sc2_out" | tr '\n' '|' | cut -c1-120)]"
if [ -z "$sc2_fail" ]; then pass "section-clean (no comment between the markers in any of $sc2_n stacks, markers and sources kept; no Async DB on no or No, kept on yes and a TODO; the sha is of what was written: a re-run is current, a new value refreshes, a 5.0.0 section loses its comments)"
else failc "section-clean" "$sc2_fail"; fi

# 82. fired-if-tracked: a model-written `grep -rl expires_at src` fired on __pycache__/*.pyc after
# the first pytest, because decision-check.sh runs over untracked files too. The line is taught in
# spec/reference.md, and decide/SKILL.md sends its reader there, so one sentence serves both. Read
# from that section only: a `git grep` elsewhere in the file would not be where the writer looks.
# No claude needed. Cites: fourth-project/REQ-10
fi_sec=$(awk '/^### The `Fired-if` line/ { on = 1; next } on && /^##/ { on = 0 } on' "$COPY/skills/spec/reference.md")
if printf '%s\n' "$fi_sec" | grep -q 'tracked files' && printf '%s\n' "$fi_sec" | grep -q 'git grep'; then
  passt "fired-if-tracked (the Fired-if section says a command reads tracked files, and names git grep)"
else failc "fired-if-tracked" "spec/reference.md's Fired-if section does not say tracked files and git grep"; fi

# 83. superseded-report: a report's name carries the gate's date, so a re-run on a later day wrote
# 2026-11-05-fourth-project.md beside the first run's untracked NOT READY report of 2026-11-04, and
# nothing said so. The report section tells the gate to name such a file as superseded and to
# leave it, since the gate changes no file but its report (review-and-ship/REQ-14). Read from that
# section only, its lines joined so a wrap cannot hide a phrase. No claude needed.
# Cites: review-and-ship/REQ-20
sr_sec=$(awk '/^## The report/ { on = 1; next } on && /^## / { on = 0 } on' "$COPY/skills/ship/SKILL.md" | tr '\n' ' ')
if printf '%s\n' "$sr_sec" | grep -q 'earlier date' && printf '%s\n' "$sr_sec" | grep -q 'supersede' \
   && printf '%s\n' "$sr_sec" | grep -q 'leave it'; then
  passt "superseded-report (the report section names an earlier day's untracked report as superseded and leaves it)"
else failc "superseded-report" "ship/SKILL.md's report section does not name an earlier day's report as superseded and leave it"; fi

# 84. walk-sentence: the comment that opens walk.md, which ask hands to grandfather whole, read
# "The agent It cannot ask the user anything mid-run", an edit 7595cb5 left half done
# (field-notes-5.1.md §10.1). Read from the comment only. No claude needed.
# Cites: gate-on-setup/REQ-1
ws_head=$(awk '{ print } /-->/ { exit }' "$COPY/skills/ask/walk.md" | tr '\n' ' ' | tr -s ' ')
if printf '%s\n' "$ws_head" | grep -qF 'The agent cannot ask the user anything mid-run and cannot write files' \
   && ! printf '%s\n' "$ws_head" | grep -qF 'The agent It'; then
  passt "walk-sentence (walk.md's opening comment says the agent cannot ask or write, in one sentence)"
else failc "walk-sentence" "walk.md's opening comment still reads: $(printf '%s\n' "$ws_head" | grep -o 'The agent[^.]*\.' | head -1)"; fi

# 85. ship-write-path: step 4 gave the Write tool "${TMPDIR:-/tmp}/shipkit-ship-review.out", and
# Write takes a literal path, so the 5.1 gate wrote /tmp/… while every Bash step used $TMPDIR
# (field-notes-5.1.md §9.4). The gate prints the path first and gives Write what it printed; the
# table's row 4 names no path for it to copy. Read from step 4 and row 4, lines joined so a wrap
# cannot hide a phrase. No claude needed. Cites: gate-on-setup/REQ-2
sw_ship="$COPY/skills/ship/SKILL.md"; sw_fail=""
sw_step=$(awk '/^- \*\*Step 4 — the reviewer/ { on = 1 } /^- \*\*Step 5 — / { on = 0 } on' "$sw_ship" | tr '\n' ' ' | tr -s ' ')
printf '%s\n' "$sw_step" | grep -qF "printf '%s\n' \"\${TMPDIR:-/tmp}/shipkit-ship-review.out\"" || sw_fail="$sw_fail [step 4 does not print the path first]"
printf '%s\n' "$sw_step" | grep -qF 'to the path it printed' || sw_fail="$sw_fail [step 4 does not give Write the printed path]"
printf '%s\n' "$sw_step" | grep -qF 'unchanged, to `"${TMPDIR' && sw_fail="$sw_fail [step 4 still gives Write \${TMPDIR}]"
grep -E '^\| 4 \|' "$sw_ship" | grep -qF '${TMPDIR' && sw_fail="$sw_fail [row 4 still names \${TMPDIR} for the reply]"
if [ -z "$sw_fail" ]; then passt "ship-write-path (step 4 prints the review file's path, then gives Write the path it printed)"
else failc "ship-write-path" "$sw_fail"; fi

# 86. elixir-app: the elixir section's Key Paths wrote `lib/<app>/` into a project's CLAUDE.md,
# beside a LiveView section naming test/office_bestie_web/live (field-notes-5.1.md §2.2). They
# take APP_NAME, the app: key of mix.exs: missing, the install fails naming it, as for every
# placeholder; given, no <app> is left. Lint check 9 holds setup's table row. No claude needed.
# Cites: gate-on-setup/REQ-3 gate-on-setup/REQ-4
EA="$WORK/elixir-app"; ea_fail=""; mkdir -p "$EA"; printf '# demo\n' > "$EA/CLAUDE.md"
sh "$COPY/scripts/install-rules.sh" "$COPY" "$EA" >/dev/null 2>&1 || ea_fail="$ea_fail [install-rules failed]"
ea_err=$(sh "$COPY/scripts/install-stack.sh" "$COPY" elixir "$EA" ELIXIR_FRAMEWORK=Phoenix ELIXIR_FRONTEND=LiveView 2>&1 >/dev/null); ea_rc=$?
[ "$ea_rc" -eq 2 ] || ea_fail="$ea_fail [no APP_NAME: exit $ea_rc, not 2]"
printf '%s\n' "$ea_err" | grep -q 'APP_NAME' || ea_fail="$ea_fail [no APP_NAME: the error does not name it]"
grep -q 'shipkit:stack:elixir' "$EA/CLAUDE.md" && ea_fail="$ea_fail [no APP_NAME: a section was written anyway]"
sh "$COPY/scripts/install-stack.sh" "$COPY" elixir "$EA" ELIXIR_FRAMEWORK=Phoenix ELIXIR_FRONTEND=LiveView APP_NAME=my_app TEST_COMMAND="mix test" >/dev/null 2>&1 \
  || ea_fail="$ea_fail [with APP_NAME: exit $?]"
grep -qF '`lib/my_app/`' "$EA/CLAUDE.md" && grep -qF '`lib/my_app_web/live/`' "$EA/CLAUDE.md" \
  || ea_fail="$ea_fail [with APP_NAME: lib/my_app/ not written]"
grep -qF '<app>' "$EA/CLAUDE.md" && ea_fail="$ea_fail [with APP_NAME: <app> still in CLAUDE.md]"
if [ -z "$ea_fail" ]; then pass "elixir-app (no APP_NAME → exit 2 naming it, nothing written; APP_NAME=my_app → lib/my_app/, no <app>)"
else failc "elixir-app" "$ea_fail"; fi

# 87. stray-status: the 5.1 spec skill's model wrote `> Status: draft` in design.md as well as in
# spec.md; the stamp set spec.md to open, design.md kept draft, and no script looked
# (field-notes-5.1.md §6.1, §7.3). Only spec.md carries a Status line: spec-check names one
# elsewhere as STRAY-STATUS and exits 1, and the spec skill's two lists of gaps name it. No
# claude needed. Cites: gate-on-setup/REQ-5 gate-on-setup/REQ-6
SS="$WORK/stray-status"; ss_fail=""; mkdir -p "$SS/.shipkit/specs/s"
(cd "$SS" && git init -q)
printf '# Spec: s\n\n> Status: open\n\n- **REQ-1.** The thing shall work. [untested: a fixture]\n' > "$SS/.shipkit/specs/s/spec.md"
printf '# Tasks: s\n\n- [ ] **T1** Build it → REQ-1\n  - Files: a.txt\n  - Test: none\n  - After: none\n  - Done when: it works\n' > "$SS/.shipkit/specs/s/tasks.md"
printf '# Design: s\n\n> Status: draft\n' > "$SS/.shipkit/specs/s/design.md"
ss_out=$(sh "$COPY/scripts/spec-check.sh" "$SS" s 2>&1); ss_rc=$?
{ [ "$ss_rc" -eq 1 ] && printf '%s\n' "$ss_out" | grep -qx 'STRAY-STATUS s design.md'; } || ss_fail="$ss_fail [design.md: exit $ss_rc: $ss_out]"
printf '# Design: s\n' > "$SS/.shipkit/specs/s/design.md"; printf '> Status: open\n' >> "$SS/.shipkit/specs/s/tasks.md"
ss_out=$(sh "$COPY/scripts/spec-check.sh" "$SS" s 2>&1); ss_rc=$?
{ [ "$ss_rc" -eq 1 ] && printf '%s\n' "$ss_out" | grep -qx 'STRAY-STATUS s tasks.md'; } || ss_fail="$ss_fail [tasks.md: exit $ss_rc: $ss_out]"
sed -i.bak '/^> Status:/d' "$SS/.shipkit/specs/s/tasks.md"
ss_out=$(sh "$COPY/scripts/spec-check.sh" "$SS" s 2>&1); ss_rc=$?
{ [ "$ss_rc" -eq 0 ] && ! printf '%s\n' "$ss_out" | grep -q 'STRAY-STATUS'; } || ss_fail="$ss_fail [none: exit $ss_rc: $ss_out]"
grep -q 'STRAY-STATUS' "$COPY/skills/spec/SKILL.md" || ss_fail="$ss_fail [spec/SKILL.md does not name it]"
grep -q 'STRAY-STATUS' "$COPY/skills/spec/reference.md" || ss_fail="$ss_fail [spec/reference.md does not name it]"
if [ -z "$ss_fail" ]; then pass "stray-status (a Status line in design.md or tasks.md → STRAY-STATUS, exit 1; none → exit 0; both spec skill lists name it)"
else failc "stray-status" "$ss_fail"; fi

# 88. setup-files: a first spec after setup listed CLAUDE.md and .gitignore as beyond the spec on
# three real runs in a row, with nothing in them but setup's (field-notes-4.12.md:379,
# field-notes-5.0.md:203, field-notes-5.1.md §9.1). Setup ends by recording each file's git blob
# id; a file that still matches is setup's, for brief-verify by code and for the reviewer by its
# step 4. One more line, or no record, and the file is reported as before. The fixture is
# linkshort's shape: setup created CLAUDE.md, and wrote five .gitignore lines. No claude needed.
# Cites: gate-on-setup/REQ-7 gate-on-setup/REQ-8 gate-on-setup/REQ-9 gate-on-setup/REQ-10
# gate-on-setup/REQ-11 gate-on-setup/REQ-12
SFS="$COPY/scripts/setup-files.sh"; BV="$COPY/scripts/brief-verify.sh"; SF="$WORK/setup-files"; sf_fail=""
mkdir -p "$SF/.shipkit/specs/s" "$SF/app"
printf '# Spec: s\n\n> Status: open\n> Paths: app/\n\n- **REQ-1.** It shall work.\n' > "$SF/.shipkit/specs/s/spec.md"
printf '# Tasks: s\n\n- [ ] **T1** Build it → REQ-1\n  - Files: app/x.txt\n  - Test: t\n  - After: none\n  - Done when: d\n' > "$SF/.shipkit/specs/s/tasks.md"
(cd "$SF" && git init -q && git add -A && git -c user.email=s@s -c user.name=s commit -q -m base)
sf_base=$(cd "$SF" && git rev-parse HEAD)
sf_setup() {  # what setup leaves: a new CLAUDE.md with a stack section, five .gitignore lines
  printf '# Project\n\nA demo.\n\n<!-- shipkit:stack:elixir -->\n## Elixir-Specific\n<!-- /shipkit:stack:elixir -->\n' > "$SF/CLAUDE.md"
  printf '.shipkit-baseline/\n.shipkit-backup-*/\n.shipkit-recovery-*/\n.shipkit/state.md\n.claude/settings.local.json\n' > "$SF/.gitignore"
  mkdir -p "$SF/.claude/rules/shipkit"
}
sf_setup
if [ ! -f "$SFS" ]; then sf_fail="$sf_fail [scripts/setup-files.sh does not exist]"
else
  [ -x "$SFS" ] || sf_fail="$sf_fail [setup-files.sh is not executable]"
  sh -n "$SFS" 2>/dev/null || sf_fail="$sf_fail [sh -n reports a syntax error]"
  sf_out=$(sh "$SFS" "$SF" check 2>&1); sf_rc=$?
  { [ "$sf_rc" -eq 0 ] && [ -z "$sf_out" ]; } || sf_fail="$sf_fail [check with no record: exit $sf_rc: $sf_out]"
  sh "$SFS" "$SF" record >/dev/null 2>&1 || sf_fail="$sf_fail [record: exit $?]"
  sf_rec="$SF/.claude/rules/shipkit/.setup-files"
  { [ "$(grep -cE '^[0-9a-f]{40,64} (CLAUDE\.md|\.gitignore)$' "$sf_rec" 2>/dev/null)" -eq 2 ] \
    && grep -q " CLAUDE.md$" "$sf_rec" && [ "$(cd "$SF" && git hash-object CLAUDE.md) CLAUDE.md" = "$(grep ' CLAUDE.md$' "$sf_rec")" ]; } \
    || sf_fail="$sf_fail [record: .setup-files is not two '<blob id> <path>' lines: $(cat "$sf_rec" 2>/dev/null)]"
  sf_out=$(sh "$SFS" "$SF" check 2>&1)
  [ "$(printf '%s\n' "$sf_out" | sort | tr '\n' ' ')" = ".gitignore CLAUDE.md " ] || sf_fail="$sf_fail [check after record: $sf_out]"
fi
printf 'x\n' > "$SF/app/x.txt"
sf_out=$(sh "$BV" "$SF" s T1 "$sf_base" 2>&1); sf_rc=$?
{ [ "$sf_rc" -eq 0 ] && ! printf '%s\n' "$sf_out" | grep -q '^OUTSIDE'; } || sf_fail="$sf_fail [as setup left them: exit $sf_rc: $sf_out]"
printf 'mine\n' >> "$SF/CLAUDE.md"; printf 'tmp/\n' >> "$SF/.gitignore"
sf_out=$(sh "$BV" "$SF" s T1 "$sf_base" 2>&1); sf_rc=$?
{ [ "$sf_rc" -eq 1 ] && printf '%s\n' "$sf_out" | grep -qx 'OUTSIDE CLAUDE.md' && printf '%s\n' "$sf_out" | grep -qx 'OUTSIDE .gitignore'; } \
  || sf_fail="$sf_fail [one more line in each: exit $sf_rc: $sf_out]"
sf_setup; rm -f "$SF/.claude/rules/shipkit/.setup-files"
sf_out=$(sh "$BV" "$SF" s T1 "$sf_base" 2>&1); sf_rc=$?
{ [ "$sf_rc" -eq 1 ] && [ "$(printf '%s\n' "$sf_out" | grep -c '^OUTSIDE')" -eq 2 ]; } || sf_fail="$sf_fail [no record: exit $sf_rc: $sf_out]"
sf_step4=$(awk '/^4\. \*\*Changes beyond the spec/ { on = 1 } /^5\. / { on = 0 } on' "$COPY/agents/reviewer.md" | tr '\n' ' ')
{ printf '%s\n' "$sf_step4" | grep -qF '.claude/rules/shipkit/.setup-files' && printf '%s\n' "$sf_step4" | grep -qF 'git hash-object'; } \
  || sf_fail="$sf_fail [the reviewer's step 4 does not read .setup-files with git hash-object]"
sf_p7=$(awk '/^## Phase 7/ { on = 1; next } on && /^## / { on = 0 } on' "$COPY/skills/setup/SKILL.md")
printf '%s\n' "$sf_p7" | grep -qF 'scripts/setup-files.sh" . record' || sf_fail="$sf_fail [setup's Phase 7 does not run setup-files.sh record]"
SU="$WORK/setup-files-un"; mkdir -p "$SU"
if sh "$COPY/scripts/install-rules.sh" "$COPY" "$SU" >/dev/null 2>&1 && printf '# p\n' > "$SU/CLAUDE.md" \
   && sh "$SFS" "$SU" record >/dev/null 2>&1 && [ -f "$SU/.claude/rules/shipkit/.setup-files" ]; then
  sh "$COPY/scripts/unsetup-remove.sh" "$SU" --yes >/dev/null 2>&1
  { [ ! -e "$SU/.claude/rules/shipkit/.setup-files" ] && [ ! -d "$SU/.claude/rules/shipkit" ]; } \
    || sf_fail="$sf_fail [unsetup-remove left .setup-files or the directory]"
else sf_fail="$sf_fail [could not install and record for the unsetup fixture]"; fi
if [ -z "$sf_fail" ]; then pass "setup-files (recorded and unchanged → not OUTSIDE; one more line, or no record → OUTSIDE; the reviewer, setup and unsetup follow)"
else failc "setup-files" "$sf_fail"; fi


# 89. reviewer-marks: the 5.1 reviewer marked a decision `not built` "for the workspace path" and
# named, in the same line, the fallback that does exist (field-notes-5.1.md §9.2): two marks, and
# the code fit neither. A third, `partly built`, names each part; it changes no verdict, and a part
# that does what the record turned down still makes the decision `contradicted`. The text is read
# with its lines joined, so a rewrap does not break it. No claude needed.
# Cites: gate-on-setup/REQ-14 gate-on-setup/REQ-15
rm_flat=$(tr '\n' ' ' < "$COPY/agents/reviewer.md" | tr -s ' ')
rm_step5=$(printf '%s' "$rm_flat" | sed -n 's/.*5\. \*\*Decisions not followed\.\*\*\(.*\)## What you do not do.*/\1/p')
rm_fail=""
[ -n "$rm_step5" ] || rm_fail=" [no step 5]"
for rm_want in '**`contradicted`**' '**`partly built`**' '**`not built`**' 'the file it would be in' \
  'A part that does what the record turned down makes the decision `contradicted`'; do
  case "$rm_step5" in *"$rm_want"*) ;; *) rm_fail="$rm_fail [step 5, no: $rm_want]" ;; esac
done
for rm_want in '`contradicted`, `partly built` or `not built`' \
  'decisions marked `not built` or `partly built` are reported and do not change the verdict'; do
  case "$rm_flat" in *"$rm_want"*) ;; *) rm_fail="$rm_fail [no: $rm_want]" ;; esac
done
if [ -z "$rm_fail" ]; then passt "reviewer-marks (three marks; a turned-down part is contradicted; partly built keeps the verdict)"
else failc "reviewer-marks" "$rm_fail"; fi


# 90. pinned-toolchain: office_bestie pins Elixir and Erlang in .tool-versions, and in a headless
# shell nothing activates mise, so the 5.1 runner typed `mise exec --` by hand at every step
# (field-notes-5.1.md). Setup now writes it into the test command when the project pins with mise
# and mise is on the PATH, after any VAR=value words; otherwise the command as detected. The elixir
# and go sections said `mix test` and `go test ./...` whatever setup detected, so they take
# TEST_COMMAND: missing, the install fails naming it; given, each section names it. No claude
# needed. Cites: users-machine/REQ-1 users-machine/REQ-2 users-machine/REQ-3
pt_fail=""
pt_flat=$(tr '\n' ' ' < "$COPY/skills/setup/SKILL.md" | tr -s ' ')
for pt_want in '`.tool-versions`, `mise.toml` or `.mise.toml`' 'command -v mise' 'mise exec --' \
  'after any leading `VAR=value` words' '`MIX_ENV=test mise exec -- mix test`' 'Otherwise write the test command as detected'; do
  case "$pt_flat" in *"$pt_want"*) ;; *) pt_fail="$pt_fail [setup, no: $pt_want]" ;; esac
done
PT="$WORK/pinned"; mkdir -p "$PT/ex" "$PT/ex2" "$PT/go" "$PT/go2"
for pt_d in ex ex2 go go2; do printf '# demo\n' > "$PT/$pt_d/CLAUDE.md"; done
pt_ex="ELIXIR_FRAMEWORK=Phoenix ELIXIR_FRONTEND=LiveView APP_NAME=my_app"
pt_go="GO_FRAMEWORK=Chi MODULE_PATH=example.com/demo DB_LIBRARY=sqlx API_STYLE=REST"
# shellcheck disable=SC2086
pt_err=$(sh "$COPY/scripts/install-stack.sh" "$COPY" elixir "$PT/ex" $pt_ex 2>&1 >/dev/null); pt_rc=$?
[ "$pt_rc" -eq 2 ] && printf '%s\n' "$pt_err" | grep -q 'TEST_COMMAND' || pt_fail="$pt_fail [elixir, no TEST_COMMAND: exit $pt_rc, not 2 naming it]"
# shellcheck disable=SC2086
sh "$COPY/scripts/install-stack.sh" "$COPY" elixir "$PT/ex2" $pt_ex TEST_COMMAND='MIX_ENV=test mise exec -- mix test' >/dev/null 2>&1 \
  || pt_fail="$pt_fail [elixir, with TEST_COMMAND: install failed]"
grep -qF -- '- **Run all:** `MIX_ENV=test mise exec -- mix test`' "$PT/ex2/CLAUDE.md" \
  && grep -qF -- '- **Run specific:** `MIX_ENV=test mise exec -- mix test <path>`' "$PT/ex2/CLAUDE.md" \
  || pt_fail="$pt_fail [elixir: the section does not name TEST_COMMAND on both lines]"
grep -qF '`mix test' "$PT/ex2/CLAUDE.md" && pt_fail="$pt_fail [elixir: a bare mix test is left]"
# shellcheck disable=SC2086
pt_err=$(sh "$COPY/scripts/install-stack.sh" "$COPY" go "$PT/go" $pt_go 2>&1 >/dev/null); pt_rc=$?
[ "$pt_rc" -eq 2 ] && printf '%s\n' "$pt_err" | grep -q 'TEST_COMMAND' || pt_fail="$pt_fail [go, no TEST_COMMAND: exit $pt_rc, not 2 naming it]"
# shellcheck disable=SC2086
sh "$COPY/scripts/install-stack.sh" "$COPY" go "$PT/go2" $pt_go TEST_COMMAND='mise exec -- go test ./...' >/dev/null 2>&1 \
  || pt_fail="$pt_fail [go, with TEST_COMMAND: install failed]"
grep -qF -- '- **Run all:** `mise exec -- go test ./...`' "$PT/go2/CLAUDE.md" || pt_fail="$pt_fail [go: Run all does not name TEST_COMMAND]"
if [ -z "$pt_fail" ]; then pass "pinned-toolchain (setup prefixes mise exec -- after VAR=value on a pinned project; elixir and go take TEST_COMMAND)"
else failc "pinned-toolchain" "$pt_fail"; fi

# 91. git-grep: the fourth-project reviewer's `grep -n "198,837\|198837" ROADMAP.md` printed
# nothing for a line that is there, twice: Claude Code's shell held the owner's alias of grep to
# another program (eval-history.md, "Release run 5.1.0"). `git grep` is git's own, so no alias,
# function or PATH order changes it, and `-E` reads the same on every machine where `\|` does
# not. Plain git grep reads tracked files only: on an untracked tasks.md with an unticked line it
# exits 1, which step 3 reads as PASS, so step 3 adds --untracked and is run here on one. A code
# span is read with fence lines dropped and lines joined. No claude needed.
# Cites: users-machine/REQ-4 users-machine/REQ-5 users-machine/REQ-6
gg_fail=""
gg_rv=$(tr '\n' ' ' < "$COPY/agents/reviewer.md" | tr -s ' ')
gg_sk=$(tr '\n' ' ' < "$COPY/skills/ship/SKILL.md" | tr -s ' ')
for gg_want in '`git grep -n`' '`-E` for alternation' 'never write `\|`'; do
  case "$gg_rv" in *"$gg_want"*) ;; *) gg_fail="$gg_fail [reviewer, no: $gg_want]" ;; esac
  case "$gg_sk" in *"$gg_want"*) ;; *) gg_fail="$gg_fail [ship, no: $gg_want]" ;; esac
done
gg_cmd=$(sed -n 's/^| 3 | Tasks ticked | `\([^`]*\)`.*/\1/p' "$COPY/skills/ship/SKILL.md")
gg_cmd=${gg_cmd%%; echo*}
case "$gg_cmd" in "git grep -n --untracked "*) ;; *) gg_fail="$gg_fail [step 3 is not git grep -n --untracked: $gg_cmd]" ;; esac
gg_run=$(printf '%s' "$gg_cmd" | sed 's/<slug>/demo/g')
GG="$WORK/gitgrep"; mkdir -p "$GG/.shipkit/specs/demo"
(cd "$GG" && git init -q && git -c user.email=s@s -c user.name=smoke commit -q --allow-empty -m init)
printf -- '- [x] **T1** done\n- [ ] **T2** open\n' > "$GG/.shipkit/specs/demo/tasks.md"
(cd "$GG" && git grep -n '^- \[ \]' .shipkit/specs/demo/tasks.md >/dev/null 2>&1); gg_rc=$?
[ "$gg_rc" -eq 1 ] || gg_fail="$gg_fail [fixture: plain git grep on the untracked file exits $gg_rc, not 1]"
(cd "$GG" && sh -c "$gg_run" >/dev/null 2>&1); gg_rc=$?
[ "$gg_rc" -eq 0 ] || gg_fail="$gg_fail [step 3 on an untracked tasks.md with an unticked line: exit $gg_rc, not 0]"
printf -- '- [x] **T1** done\n- [x] **T2** done\n' > "$GG/.shipkit/specs/demo/tasks.md"
(cd "$GG" && sh -c "$gg_run" >/dev/null 2>&1); gg_rc=$?
[ "$gg_rc" -eq 1 ] || gg_fail="$gg_fail [step 3 on an untracked tasks.md, all ticked: exit $gg_rc, not 1]"
for gg_f in agents/reviewer.md skills/ship/SKILL.md skills/ship/reference.md; do
  gg_txt=$(grep -v '^ *```' "$COPY/$gg_f" | tr '\n' ' ' | tr -s ' ')
  printf '%s' "$gg_txt" | sed 's/git grep//g' | grep -qwE 'grep|egrep|fgrep' \
    && gg_fail="$gg_fail [$gg_f: names grep without git]"
  gg_spans=$(printf '%s' "$gg_txt" | grep -oE '`[^`]*`')
  printf '%s\n' "$gg_spans" | grep -qE '^`[( ]*(rg|ack|ag|find|grep|egrep|fgrep)( |`)' \
    && gg_fail="$gg_fail [$gg_f: a search command but git grep]"
  printf '%s\n' "$gg_spans" | grep -vxF '`\|`' | grep -qF '\|' \
    && gg_fail="$gg_fail [$gg_f: a \\| in a command]"
done
if [ -z "$gg_fail" ]; then passt "git-grep (the gate searches with git grep -n, -E, never \\|; step 3 reads an untracked tasks.md)"
else failc "git-grep" "$gg_fail"; fi

# 92. wait-probe: the 5.1 intake's file was on disk at 00:19:34 and its session ended at 00:23:52,
# held open by two Monitor watches on an agent that had already finished; the JSON result's
# duration_ms said 2,023 (field-notes-5.1.md §4). wait-probe.sh scaffolds a small fixture, and reads
# the wait from a stored transcript: the last write of intake.md (Write, Edit, or a Bash redirect,
# as the 5.1 run wrote it) to the transcript's last timestamp; Monitor calls, and `sleep` in a Bash
# command only (a Monitor's own loop sleeps too); each call once by its id, since a transcript
# repeats some. A fake claude first on the PATH shows neither mode calls a model.
# Cites: users-machine/REQ-7 users-machine/REQ-8
WP="$WORK/wait-probe"; mkdir -p "$WP/bin" "$WP/tx"; wp_fail=""; wp_tab=$(printf '\t')
wp_sh="$ROOT/scripts/wait-probe.sh"
printf '#!/bin/sh\ntouch "%s/claude-called"\nexit 1\n' "$WP" > "$WP/bin/claude"; chmod +x "$WP/bin/claude"
PATH="$WP/bin:$PATH" sh "$wp_sh" --scaffold "$WP/fix" >/dev/null 2>&1; wp_rc=$?
[ "$wp_rc" -eq 0 ] || wp_fail="$wp_fail [--scaffold: exit $wp_rc]"
wp_n=$(git -C "$WP/fix" ls-files 2>/dev/null | wc -l | tr -d ' ')
[ "${wp_n:-0}" -ge 8 ] && [ "${wp_n:-0}" -le 16 ] || wp_fail="$wp_fail [fixture: ${wp_n:-0} tracked files, not 8 to 16]"
git -C "$WP/fix" rev-parse -q --verify HEAD >/dev/null 2>&1 && [ -z "$(git -C "$WP/fix" status --porcelain 2>/dev/null)" ] \
  || wp_fail="$wp_fail [fixture: not a clean commit]"
[ -f "$WP/fix/.shipkit/product.md" ] || wp_fail="$wp_fail [fixture: no .shipkit/product.md]"
[ -e "$WP/fix/.shipkit/specs" ] && wp_fail="$wp_fail [fixture: already holds a spec]"
PATH="$WP/bin:$PATH" sh "$wp_sh" --scaffold "$WP/fix" >/dev/null 2>&1; wp_rc=$?
[ "$wp_rc" -eq 2 ] || wp_fail="$wp_fail [--scaffold into a non-empty directory: exit $wp_rc, not 2]"
cat > "$WP/tx/waited.jsonl" <<'WPEOF'
{"type":"user","timestamp":"2026-11-05T10:00:00.000Z","message":{"role":"user","content":"/shipkit:intake demo"}}
{"type":"assistant","timestamp":"2026-11-05T10:00:05.000Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"ag1","name":"Agent","input":{"subagent_type":"shipkit:grandfather","run_in_background":true}}]}}
{"type":"user","timestamp":"2026-11-05T10:00:06.000Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"ag1","content":"started"}]}}
{"type":"assistant","timestamp":"2026-11-05T10:00:07.000Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"sl1","name":"Bash","input":{"command":"sleep 90"}}]}}
{"type":"user","timestamp":"2026-11-05T10:00:08.000Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"sl1","content":"Blocked: use Monitor"}]}}
{"type":"assistant","timestamp":"2026-11-05T10:00:09.000Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"mo1","name":"Monitor","input":{"command":"until [ -s out ]; do sleep 5; done"}}]}}
{"type":"api-request-blob","hash":"h1","message":{"content":[{"type":"tool_use","id":"mo1","name":"Monitor","input":{"command":"until [ -s out ]; do sleep 5; done"}}]}}
{"type":"user","timestamp":"2026-11-05T10:00:10.000Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"mo1","content":"Monitor started"}]}}
{"type":"assistant","timestamp":"2026-11-05T10:00:11.000Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"mo2","name":"Monitor","input":{"command":"until grep -q end_turn out; do sleep 5; done"}}]}}
{"type":"user","timestamp":"2026-11-05T10:00:12.000Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"mo2","content":"Monitor started"}]}}
{"type":"assistant","timestamp":"2026-11-05T10:00:50.000Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"wr1","name":"Write","input":{"file_path":"/tmp/p/.shipkit/specs/demo/intake.md","content":"# Intake"}}]}}
{"type":"user","timestamp":"2026-11-05T10:01:00.000Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"wr1","content":"ok"}]}}
{"type":"assistant","timestamp":"2026-11-05T10:01:02.000Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"rd1","name":"Read","input":{"file_path":"/tmp/p/.shipkit/specs/demo/intake.md"}}]}}
{"type":"user","timestamp":"2026-11-05T10:01:03.000Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"rd1","content":"# Intake"}]}}
{"type":"assistant","timestamp":"2026-11-05T10:05:00.000Z","message":{"role":"assistant","content":[{"type":"text","text":"The second wait timed out."}]}}
{"type":"cost-state","totalCostUSD":0.49}
WPEOF
cat > "$WP/tx/quick.jsonl" <<'WPEOF'
{"type":"user","timestamp":"2026-11-05T11:00:00.000Z","message":{"role":"user","content":"/shipkit:intake demo"}}
{"type":"assistant","timestamp":"2026-11-05T11:00:01.000Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"b1","name":"Bash","input":{"command":"d=$(date +%F); cat > .shipkit/specs/demo/intake.md <<'EOF'\n# Intake\nEOF"}}]}}
{"type":"user","timestamp":"2026-11-05T11:00:10.000Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"b1","content":""}]}}
{"type":"assistant","timestamp":"2026-11-05T11:00:11.000Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"b2","name":"Bash","input":{"command":"cat .shipkit/specs/demo/intake.md 2>&1 > /dev/null"}}]}}
{"type":"user","timestamp":"2026-11-05T11:00:12.000Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"b2","content":""}]}}
{"type":"assistant","timestamp":"2026-11-05T11:00:15.000Z","message":{"role":"assistant","content":[{"type":"text","text":"Intake written."}]}}
WPEOF
wp_out=$(PATH="$WP/bin:$PATH" sh "$wp_sh" --read "$WP/tx/waited.jsonl" "$WP/tx/quick.jsonl" 2>&1); wp_rc=$?
[ "$wp_rc" -eq 0 ] || wp_fail="$wp_fail [--read: exit $wp_rc]"
printf '%s\n' "$wp_out" | grep -qxF "waited.jsonl${wp_tab}240${wp_tab}2${wp_tab}1${wp_tab}yes" \
  || wp_fail="$wp_fail [--read, the waited run: not 240 s, 2 Monitor, 1 sleep, background yes]"
printf '%s\n' "$wp_out" | grep -qxF "quick.jsonl${wp_tab}5${wp_tab}0${wp_tab}0${wp_tab}none" \
  || wp_fail="$wp_fail [--read, the quick run: not 5 s, 0 Monitor, 0 sleep, no agent]"
[ -e "$WP/claude-called" ] && wp_fail="$wp_fail [a model was called]"
if [ -z "$wp_fail" ]; then pass "wait-probe (scaffolds a clean fixture with no model call; reads idle seconds, Monitor and sleep calls from a transcript)"
else failc "wait-probe" "$wp_fail$(printf ' [output: %s]' "$wp_out" | tr '\n\t' '| ')"; fi

# 93. stale-nesting: ROADMAP.md, lint.py and the ship skill said a subagent cannot start a
# subagent; on Claude Code 2.1.319 it can (a nonce probe, 2026-11-08), and decision 0006 keeps the
# rule that the main session starts every agent. None of the three says the platform forbids it,
# each cites 0006 where it gave the reason, and lint still fails a forked skill that starts an
# agent by name: a copy of the tree whose forked map skill gains one such line → exactly one
# error, naming 0006; the clean copy → 0. Cites: spec-goldfish/REQ-17
SN="$WORK/stale-nesting"; mkdir -p "$SN"; sn_fail=""
sn_files="ROADMAP.md scripts/lint.py plugins/shipkit/skills/ship/SKILL.md"
for f in $sn_files; do
  grep -n -i -E 'cannot spawn subagents|subagent cannot spawn|an agent cannot start an agent' "$ROOT/$f" >/dev/null 2>&1 \
    && sn_fail="$sn_fail [$f still says the platform forbids it]"
  grep -q '0006' "$ROOT/$f" 2>/dev/null || sn_fail="$sn_fail [$f does not cite decision 0006]"
done
if command -v rsync >/dev/null 2>&1; then rsync -a --exclude /.git --exclude /.claude "$ROOT/" "$SN/"
else (cd "$ROOT" && tar cf - --exclude ./.git --exclude ./.claude .) | (cd "$SN" && tar xf -); fi
sn_clean=$(python3 "$SN/scripts/lint.py" 2>&1 | tail -1)
printf '%s\n' "$sn_clean" | grep -q '^lint: 0 error(s)' || sn_fail="$sn_fail [clean copy: $sn_clean]"
printf '\nFor the hard part, start the `shipkit:reviewer` agent on the slug.\n' >> "$SN/plugins/shipkit/skills/map/SKILL.md"
sn_out=$(python3 "$SN/scripts/lint.py" 2>&1)
printf '%s\n' "$sn_out" | grep -q '^lint: 1 error(s)' || sn_fail="$sn_fail [doctored copy: not exactly 1 error]"
printf '%s\n' "$sn_out" | grep 'ERROR' | grep 'map/SKILL.md' | grep -q '0006' \
  || sn_fail="$sn_fail [doctored copy: no error on map/SKILL.md naming 0006]"
if [ -z "$sn_fail" ]; then pass "stale-nesting (no file says a subagent cannot start one; each cites 0006; lint fails a forked skill that starts an agent, naming 0006)"
else failc "stale-nesting" "$sn_fail $(printf '%s' "$sn_out" | grep 'ERROR\|^lint:' | tr '\n' '|')"; fi

# 94. goldfish-agent: the agent /shipkit:spec starts before its design gate reads a spec as the
# implementer will, from the files alone. Its file fixes what no prompt can change: sonnet, read
# tools only, no Edit, Write or Agent; a one-line description naming /shipkit:spec. The body names
# what it reads and what it does not (intake.md, tasks.md), ignores anything but the slug, stops on
# a missing slug or spec, gives one TESTABLE or UNCLEAR row per requirement, lists undefined terms
# and unstated assumptions ("None." when empty) under the test-author rule, and ends on one of two
# verdict lines. No claude needed; the behaviour is the evals' (goldfish-gap, goldfish-clean).
# Cites: spec-goldfish/REQ-1 spec-goldfish/REQ-2 spec-goldfish/REQ-3 spec-goldfish/REQ-4
# spec-goldfish/REQ-5 spec-goldfish/REQ-6 spec-goldfish/REQ-7. REQ-21: the test-author rule comes
# before the procedure, names an input the requirement does not mention and behaviour beyond what
# it asks as not counting, and every assumption says what its test must guess.
# Cites: spec-goldfish/REQ-21
gf="$COPY/agents/goldfish.md"; gf_fail=""
if [ ! -f "$gf" ]; then gf_fail=" [agents/goldfish.md does not exist]"
else
  for gf_line in 'name: goldfish' 'model: sonnet' 'tools: Read, Glob, Grep, Bash' 'disallowedTools: Edit, Write, Agent'; do
    awk 'NR > 1 && /^---$/ { exit } { print }' "$gf" | grep -qxF "$gf_line" || gf_fail="$gf_fail [frontmatter lacks: $gf_line]"
  done
  gf_desc=$(awk '/^description:/ { sub(/^description:[ \t]*/, ""); print; exit }' "$gf")
  [ "$(printf '%s\n' "$gf_desc" | wc -c | tr -d ' ')" -le 100 ] || gf_fail="$gf_fail [description over 100 bytes]"
  printf '%s' "$gf_desc" | grep -qF '/shipkit:spec' || gf_fail="$gf_fail [description does not name /shipkit:spec]"
  gf_flat=$(awk 'NR > 1 && /^---$/ { on = 1; next } on' "$gf" | tr '\n' ' ' | tr -s ' ')
  for gf_want in '.shipkit/specs/<slug>/spec.md' '.shipkit/specs/<slug>/design.md' 'No other file under `.shipkit/specs/<slug>/`' \
                 '`intake.md`' '`tasks.md`' 'ignore it' 'say which and stop' '`TESTABLE`' '`UNCLEAR`' \
                 '## Undefined terms' '## Unstated assumptions' '"None."' 'without guessing' \
                 'VERDICT: SELF-CONTAINED' 'VERDICT: GAPS' 'Nothing comes after the verdict line.'; do
    printf '%s' "$gf_flat" | grep -qF -- "$gf_want" || gf_fail="$gf_fail [body lacks: $gf_want]"
  done
  for gf_want in 'An input the requirement does not mention.' 'checking more than the requirement asks' \
                 'cannot be written without' 'the test must guess: <what>'; do
    printf '%s' "$gf_flat" | grep -qF -- "$gf_want" || gf_fail="$gf_fail [body lacks: $gf_want]"
  done
  gf_rule=$(grep -n '^## What counts' "$gf" | cut -d: -f1 | sed -n 1p); gf_proc=$(grep -n '^## Procedure' "$gf" | cut -d: -f1 | sed -n 1p)
  [ -n "$gf_rule" ] && [ -n "$gf_proc" ] && [ "$gf_rule" -lt "$gf_proc" ] \
    || gf_fail="$gf_fail [the test-author rule does not come before ## Procedure]"
fi
if [ -z "$gf_fail" ]; then passt "goldfish-agent (sonnet, read-only, no Agent; reads spec and design only, ignores all but the slug; TESTABLE/UNCLEAR rows, terms, assumptions, two verdicts)"
else failc "goldfish-agent" "$gf_fail"; fi

# 95. spec-goldfish-step: /shipkit:spec has the main session start the goldfish after design.md and
# before the Plan Mode gate, with the slug alone; the reply goes to a file and is pasted whole; a
# reply with no verdict gets one more start; every finding is fixed, contested with a path:line, or
# escalated, and knowledge outside the files is never contested; an accepted gap and a skip are
# written under ## Goldfish in spec.md, in the forms reference.md's template shows; two reads at
# most; GAPS does not stop the gate. No claude needed. Cites: spec-goldfish/REQ-8
# spec-goldfish/REQ-9 spec-goldfish/REQ-10 spec-goldfish/REQ-11 spec-goldfish/REQ-12
# spec-goldfish/REQ-13 spec-goldfish/REQ-14 spec-goldfish/REQ-15
sg_fail=""; sg_sk="$COPY/skills/spec/SKILL.md"; sg_ref="$COPY/skills/spec/reference.md"
sg_q2=$(awk '/^### Q2/ { on = 1 } /^### Q3/ { on = 0 } on' "$sg_sk" | tr '\n' ' ' | tr -s ' ')
for sg_want in 'shipkit:goldfish' 'only the slug' 'shipkit-spec-goldfish.out' 'whole and unchanged' \
               'no `VERDICT:` line' 'once more' 'the read failed' '`fixed`' '`contested`' '`escalated`' \
               'path:line' 'never `contested`' 'Goldfish: GAPS accepted by owner — ' 'never more than two' \
               '`GAPS` does not stop' '"no goldfish"' "Goldfish: skipped on the owner's word"; do
  printf '%s' "$sg_q2" | grep -qF -- "$sg_want" || sg_fail="$sg_fail [Q2 lacks: $sg_want]"
done
sg_at_gf=$(printf '%s' "$sg_q2" | awk '{ print index($0, "shipkit:goldfish") }')
sg_at_gate=$(printf '%s' "$sg_q2" | awk '{ print index($0, "native Plan Mode") }')
sg_at_des=$(printf '%s' "$sg_q2" | awk '{ print index($0, "references the requirement(s)") }')
[ "${sg_at_gf:-0}" -gt "${sg_at_des:-0}" ] && [ "${sg_at_gf:-0}" -lt "${sg_at_gate:-0}" ] \
  || sg_fail="$sg_fail [the goldfish step is not between the design records and the Plan Mode gate: $sg_at_des/$sg_at_gf/$sg_at_gate]"
sg_tpl=$(awk '/^### `spec.md`/ { on = 1 } /^### `design.md`/ { on = 0 } on' "$sg_ref")
printf '%s\n' "$sg_tpl" | grep -qx '## Goldfish' || sg_fail="$sg_fail [reference.md's spec.md template has no ## Goldfish]"
printf '%s\n' "$sg_tpl" | grep -qF 'Goldfish: GAPS accepted by owner — ' || sg_fail="$sg_fail [template lacks the accepted-gap line]"
printf '%s\n' "$sg_tpl" | grep -qF "Goldfish: skipped on the owner's word" || sg_fail="$sg_fail [template lacks the skip line]"
if [ -z "$sg_fail" ]; then passt "spec-goldfish-step (Q2 starts shipkit:goldfish with the slug before the Plan Mode gate; reply to a file, whole; dispositions; two reads at most; advisory; template shows ## Goldfish)"
else failc "spec-goldfish-step" "$sg_fail"; fi

# 96. goldfish-fixture: the two goldfish eval cases share evals/goldfish/spec-fixture.sh. `gap` writes
# a refunds spec and design on the sample app (no tasks.md, no code) whose one requirement says "the
# grace window" and nothing in the tree defines it; `clean` writes the same requirement with the
# days stated. Each grader's pattern takes a reply of its kind and refuses the other; the agent's
# own file never says the planted term; evals.sh cites both cases. No claude needed.
# Cites: spec-goldfish/REQ-18 spec-goldfish/REQ-19 spec-goldfish/REQ-22
GX="$WORK/goldfish-fixture"; gx_fail=""; gx_dir="$COPY/evals/goldfish"
for gx_v in gap clean; do
  mkdir -p "$GX/$gx_v"
  (cd "$GX/$gx_v" && bash "$gx_dir/spec-fixture.sh" "$gx_v" >/dev/null 2>&1) || gx_fail="$gx_fail [$gx_v: the fixture failed]"
  gx_s="$GX/$gx_v/.shipkit/specs/refunds"
  [ -f "$gx_s/spec.md" ] && [ -f "$gx_s/design.md" ] || gx_fail="$gx_fail [$gx_v: no spec.md or design.md]"
  [ -e "$gx_s/tasks.md" ] || [ -e "$GX/$gx_v/app/refunds.py" ] && gx_fail="$gx_fail [$gx_v: tasks.md or code present]"
  for gx_f in case.yaml fixture.sh prompt.md; do [ -f "$gx_dir/$gx_v/$gx_f" ] || gx_fail="$gx_fail [$gx_v: no $gx_f]"; done
done
gx_n=$(grep -ril 'grace window' "$GX/gap" 2>/dev/null | wc -l | tr -d ' ')
gx_l=$(grep -i 'grace window' "$GX/gap/.shipkit/specs/refunds/spec.md" 2>/dev/null | grep -c 'REQ-')
[ "$gx_n" = "1" ] && [ "$gx_l" = "1" ] || gx_fail="$gx_fail [gap: 'grace window' in $gx_n file(s), $gx_l requirement line(s); want 1 and 1]"
grep -rqi 'grace window' "$GX/clean" && gx_fail="$gx_fail [clean: says 'grace window']"
grep -q '30 days' "$GX/clean/.shipkit/specs/refunds/spec.md" 2>/dev/null || gx_fail="$gx_fail [clean: no '30 days']"
grep -qi 'grace window' "$COPY/agents/goldfish.md" && gx_fail="$gx_fail [agents/goldfish.md names the planted term]"
gx_tail='
Requirements: 2 TESTABLE, 1 UNCLEAR.
VERDICT: GAPS'
gx_rows='| REQ-1 | TESTABLE | first call returns it |
| REQ-3 | UNCLEAR | the grace window has no length |

## Unstated assumptions'
gx_gaps="$gx_rows
- None.
$gx_tail"
gx_ok="$gx_rows
- the window is counted in days — REQ-3 — the test must guess: the unit
$gx_tail"
gx_selfc=$(printf '| REQ-3 | TESTABLE | 31 days late raises |\n\nVERDICT: SELF-CONTAINED')
gx_re() { python3 -c 'import re,sys; p=re.search(r"^pattern: '"'"'(.*)'"'"'$", open(sys.argv[1]).read(), re.M).group(1); sys.exit(0 if re.search(p, sys.argv[2]) else 1)' "$1" "$2" 2>/dev/null; }
gx_g="$gx_dir/gap/graders/names-term-and-gaps.md"
gx_re "$gx_g" "$gx_gaps" || gx_fail="$gx_fail [gap grader refuses a GAPS reply naming the term]"
gx_re "$gx_g" "$gx_ok" || gx_fail="$gx_fail [gap grader refuses an assumptions list naming only the unit]"
gx_re "$gx_g" "$gx_selfc" && gx_fail="$gx_fail [gap grader takes a SELF-CONTAINED reply]"
# REQ-22: the same grader refuses an assumptions list naming a zero or negative amount or which
# check runs first (a row above the list may say "first")
for gx_bad in '- A zero `amount_cents` is allowed — REQ-2' '- Negative amounts are rejected — REQ-1' \
              '- Which check runs first when REQ-2 and REQ-3 both hold — REQ-2, REQ-3'; do
  gx_re "$gx_g" "$gx_rows
$gx_bad
$gx_tail" && gx_fail="$gx_fail [gap grader takes: $gx_bad]"
done
for gx_g in "$gx_dir"/clean/graders/*.md; do
  gx_re "$gx_g" "$gx_selfc" || gx_fail="$gx_fail [clean grader refuses a SELF-CONTAINED reply]"
  gx_re "$gx_g" "$gx_gaps" && gx_fail="$gx_fail [clean grader takes a GAPS reply]"
done
ls "$gx_dir"/gap/graders/*.md "$gx_dir"/clean/graders/*.md >/dev/null 2>&1 || gx_fail="$gx_fail [a case has no grader]"
grep -q 'spec-goldfish/REQ-18' "$ROOT/scripts/evals.sh" && grep -q 'spec-goldfish/REQ-19' "$ROOT/scripts/evals.sh" \
  && grep -q 'spec-goldfish/REQ-22' "$ROOT/scripts/evals.sh" \
  || gx_fail="$gx_fail [evals.sh does not cite spec-goldfish/REQ-18, REQ-19 and REQ-22]"
if [ -z "$gx_fail" ]; then pass "goldfish-fixture (gap plants one undefined term in one requirement, clean states 30 days; no tasks or code; each grader takes its reply and refuses the other)"
else failc "goldfish-fixture" "$gx_fail"; fi

# 97. smoke-args: the suite's own arguments. --list prints what would run and runs nothing;
# --no-model leaves out the fifteen checks that start a model; --only names some of them and
# takes the ones they need with it; a wrong argument is a usage error. Every form run below
# stops before the first check, so nothing here starts a model. Then the script reads itself:
# a numbered check that starts claude is one of MODEL_CHECKS and does it inside its
# model_check guard, the assertions that need no model sit outside that guard, and every
# numbered check has a line in the registry. No claude needed.
# Cites: honest-evidence/REQ-1 honest-evidence/REQ-2 honest-evidence/REQ-3 honest-evidence/REQ-4
# honest-evidence/REQ-5 honest-evidence/REQ-6 honest-evidence/REQ-7 honest-evidence/REQ-8
# honest-evidence/REQ-9 honest-evidence/REQ-10 honest-evidence/REQ-40
SELF="$ROOT/scripts/smoke.sh"
sa_fail=""
sa_n=$(registry | grep -c .)
sa_all=$(sh "$SELF" --list 2>&1); sa_rc=$?
[ "$sa_rc" -eq 0 ] || sa_fail="$sa_fail [--list exits $sa_rc]"
[ "$(printf '%s\n' "$sa_all" | grep -c '^RUN ')" -eq "$sa_n" ] || sa_fail="$sa_fail [--list alone: not every check is RUN]"
[ "$(printf '%s\n' "$sa_all" | grep -c .)" -eq "$sa_n" ] || sa_fail="$sa_fail [--list prints more than one line a check]"
sa_nm=$(sh "$SELF" --list --no-model 2>&1)
sa_skip=$(printf '%s\n' "$sa_nm" | sed -n 's/^SKIP \([^ ]*\) .*/\1/p' | tr '\n' ' ')
[ "$sa_skip" = "$MODEL_CHECKS " ] || sa_fail="$sa_fail [--list --no-model skips: $sa_skip]"
printf '%s\n' "$sa_nm" | grep -q '^RUN 19 spec-check-reqs$' || sa_fail="$sa_fail [--no-model does not list check 19 as RUN]"
sa_only=$(sh "$SELF" --list --only 32 2>&1)
sa_run=$(printf '%s\n' "$sa_only" | sed -n 's/^RUN \([^ ]*\) .*/\1/p' | tr '\n' ' ')
case " $sa_run" in *" 31 32 "*) ;; *) sa_fail="$sa_fail [--only 32 does not run 31 and 32]";; esac
[ "$(printf '%s\n' "$sa_only" | grep -c '^SKIP ')" -eq 13 ] || sa_fail="$sa_fail [--only 32 does not skip the other thirteen]"
printf '%s\n' "$sa_only" | grep -q '^RUN 19 ' || sa_fail="$sa_fail [--only 32 leaves out a check that needs no model]"
sa_out=$(sh "$SELF" --only 7 2>&1); sa_rc=$?
if [ "$sa_rc" -ne 64 ] || ! printf '%s\n' "$sa_out" | grep -qF "$MODEL_CHECKS" || printf '%s\n' "$sa_out" | grep -q '^PASS'; then
  sa_fail="$sa_fail [--only 7: exit $sa_rc, or the numbers it takes are not printed, or a check ran]"
fi
sh "$SELF" --no-model --only 22 >/dev/null 2>&1; [ $? -eq 64 ] || sa_fail="$sa_fail [--no-model with --only is not exit 64]"
sh "$SELF" --bogus >/dev/null 2>&1; [ $? -eq 64 ] || sa_fail="$sa_fail [an unknown argument is not exit 64]"
(PATH=/usr/bin:/bin; export PATH; sh "$SELF" --list --no-model >/dev/null 2>&1) \
  || sa_fail="$sa_fail [--no-model looks for claude on the PATH]"
sa_sum=$(summary_lines 5 1 16 0)
[ "$sa_sum" = "smoke: 5 passed (1 text-only), 16 skipped (model), 0 failed
smoke: all checks run passed; 16 skipped (model)" ] || sa_fail="$sa_fail [the two last lines with skips: $sa_sum]"
[ "$(summary_lines 5 0 0 0 | sed -n 2p)" = "smoke: all checks passed" ] || sa_fail="$sa_fail [last line of a full clean run]"
[ "$(summary_lines 5 0 3 2 | sed -n 2p)" = "smoke: FAILURES above" ] || sa_fail="$sa_fail [last line with a failure]"
if [ -z "$sa_fail" ]; then pass "smoke-args (--list, --no-model, --only with its needs, three usage errors at exit 64, the two last lines)"
else failc "smoke-args" "$sa_fail"; fi
sa_scan=$(awk -v models="$MODEL_CHECKS" '
  BEGIN { n = split(models, m, " "); for (i = 1; i <= n; i++) ism[m[i]] = 1 }
  /^# [0-9]+[a-z]?\. / { lab = $2; sub(/\.$/, "", lab); g = 0; next }
  lab == "" || /^[ \t]*#/ { next }
  $0 == "if model_check " lab "; then" { g = 1; has[lab] = 1; next }
  $0 == "fi  # /model_check " lab { g = 0; shut[lab] = 1; next }
  /claude[ ]--/ || /[$][(]ask / {
    if (!ism[lab]) print "check " lab " starts a model and is not in MODEL_CHECKS (line " NR ")"
    else if (!g) print "check " lab " starts a model outside its guard (line " NR ")"
  }
  shut[lab] && /passt? "/ { after[lab] = 1 }
  END {
    for (i = 1; i <= n; i++) if (!has[m[i]] || !shut[m[i]]) print "check " m[i] " has no whole model_check guard"
    if (!after["22"] || !after["54"] || !after["64"]) print "an assertion that needs no model is no longer outside the guard of check 22, 54 or 64"
  }' "$SELF")
sa_heads=$(sed -n 's/^# \([0-9][0-9]*[a-z]\{0,1\}\)\. .*/\1/p' "$SELF" | tr '\n' ' ')
sa_reg=$(registry | awk '{ print $1 }' | tr '\n' ' ')
if [ -z "$sa_scan" ] && [ "$sa_heads" = "$sa_reg" ]; then
  pass "smoke-args (the script read as text: fifteen guarded checks start a model and no other does; model-free assertions stay outside the guards; $sa_n checks, each in the registry)"
else failc "smoke-args" "$sa_scan — headers [$sa_heads] registry [$sa_reg]"; fi

# 98. ci-smoke-job: CI runs this suite without its model checks on every pull request. The
# runner has no claude, so each pull request shows again that --no-model needs none. The
# workflow is read as text: it is triggered by pull_request, and a job on a macOS runner (the
# suite was written against bash 3.2 as sh and BSD tools; honest-evidence/design.md, third
# record) runs the suite with --no-model. No claude needed. Cites: honest-evidence/REQ-11
cj="$ROOT/.github/workflows/lint.yml"; cj_fail=""
grep -q '^  pull_request:' "$cj" || cj_fail="$cj_fail [the workflow is not triggered by pull_request]"
grep -q '^    runs-on: macos-latest$' "$cj" || cj_fail="$cj_fail [no job runs on macos-latest]"
grep -q '^        run: sh scripts/smoke\.sh --no-model </dev/null$' "$cj" || cj_fail="$cj_fail [no step runs sh scripts/smoke.sh --no-model]"
if [ -z "$cj_fail" ]; then pass "ci-smoke-job (lint.yml: on pull_request, a macOS job runs sh scripts/smoke.sh --no-model)"
else failc "ci-smoke-job" "$cj_fail"; fi

# 99. evidence-line: spec-check says how much of a spec is proven. One EVIDENCE line for each
# spec it checks: tested (no waiver, a counted citation), waived, uncited (the rest). A
# requirement that is both cited and waived counts as waived. The lines come before the summary
# line, whose form the briefing reads, and change no exit status. No claude needed.
# Cites: honest-evidence/REQ-12 honest-evidence/REQ-13 honest-evidence/REQ-14
evspec() {  # evspec <proj> <slug> <status> → REQ-1 cited, REQ-2 waived and cited, REQ-3 neither
  _d="$1/.shipkit/specs/$2"; mkdir -p "$_d" "$1/tests"
  [ -d "$1/.git" ] || (cd "$1" && git init -q)
  printf '# Spec: %s\n\n> Spec accepted at commit `abc1234` on main.\n> Status: %s\n\n## Requirements\n\n- **REQ-1.** When a happens, the system shall do b.\n- **REQ-2.** The README shall say c. [untested: prose]\n- **REQ-3.** When d happens, the system shall do e.\n' "$2" "$3" > "$_d/spec.md"
  printf -- '- [x] **T1** do it all → REQ-1, REQ-2, REQ-3\n  - Files: app/a.py\n  - Test: tests/test_%s.py\n  - After: none\n  - Done when: `pytest` → all pass\n' "$2" > "$_d/tasks.md"
  printf '# %s/REQ-1\n# %s/REQ-2\n' "$2" "$2" > "$1/tests/test_$2.py"
}
evrun() { sh "$COPY/scripts/spec-check.sh" "$@" > "$WORK/ev.out" 2>&1; echo $?; }  # → the exit status; output in ev.out
ev_fail=""
P="$WORK/ev-open"; evspec "$P" demo open
rc=$(evrun "$P")
grep -q '^EVIDENCE demo tested=1 waived=1 uncited=1$' "$WORK/ev.out" || ev_fail="$ev_fail [open spec: $(grep '^EVIDENCE' "$WORK/ev.out")]"
[ "$rc" -eq 0 ] || ev_fail="$ev_fail [open spec with an uncited requirement exits $rc, not 0]"
[ "$(sed -n '$p' "$WORK/ev.out")" = "spec-check: 1 spec(s) checked, 0 gap(s)" ] || ev_fail="$ev_fail [the summary line changed: $(sed -n '$p' "$WORK/ev.out")]"
[ "$(grep -n '^EVIDENCE' "$WORK/ev.out" | cut -d: -f1)" -lt "$(grep -n '^spec-check:' "$WORK/ev.out" | cut -d: -f1)" ] 2>/dev/null \
  || ev_fail="$ev_fail [EVIDENCE is not before the summary line]"
P="$WORK/ev-shipped"; evspec "$P" demo shipped; evspec "$P" other shipped
printf '# other/REQ-3\n' >> "$P/tests/test_other.py"
rc=$(evrun "$P")
grep -q '^EVIDENCE demo tested=1 waived=1 uncited=1$' "$WORK/ev.out" || ev_fail="$ev_fail [shipped spec: no EVIDENCE line for demo]"
grep -q '^EVIDENCE other tested=2 waived=1 uncited=0$' "$WORK/ev.out" || ev_fail="$ev_fail [second spec: $(grep '^EVIDENCE other' "$WORK/ev.out")]"
[ "$rc" -eq 1 ] && grep -q '^MISSING-TEST demo REQ-3$' "$WORK/ev.out" || ev_fail="$ev_fail [shipped spec with an uncited requirement: exit $rc]"
[ "$(sed -n '$p' "$WORK/ev.out")" = "spec-check: 2 spec(s) checked, 1 gap(s)" ] || ev_fail="$ev_fail [two specs: $(sed -n '$p' "$WORK/ev.out")]"
P="$WORK/ev-draft"; evspec "$P" demo draft
rc=$(evrun "$P")
grep -q '^EVIDENCE' "$WORK/ev.out" && ev_fail="$ev_fail [a skipped draft got an EVIDENCE line]"
if [ -z "$ev_fail" ]; then pass "evidence-line (tested, waived and uncited counted for each checked spec, before an unchanged summary line; a draft gets none; exit status as before)"
else failc "evidence-line" "$ev_fail"; fi

# 100. tests-line: a spec may say where its tests live. With a "> Tests:" line in spec.md a
# citation counts only in a file that is one of the paths listed or lies under a folder listed
# (written with or without its last slash); a citation anywhere else is named, CITED-ELSEWHERE,
# and the requirement is then missing its test as if it had none. The line by itself is not a
# gap. A spec with no such line is counted as at 5.3.0. No claude needed.
# Cites: honest-evidence/REQ-15 honest-evidence/REQ-16 honest-evidence/REQ-17 honest-evidence/REQ-18
tlspec() {  # tlspec <proj> <the Tests line's value | none> → shipped spec demo: REQ-1 cited under tests/, REQ-2 only under app/
  _d="$1/.shipkit/specs/demo"; mkdir -p "$_d" "$1/tests" "$1/app" "$1/scripts"
  [ -d "$1/.git" ] || (cd "$1" && git init -q)
  { printf '# Spec: demo\n\n> Spec accepted at commit `abc1234` on main.\n> Status: shipped\n'
    [ "$2" = none ] || printf '> Tests: %s\n' "$2"
    printf '\n## Requirements\n\n- **REQ-1.** When a happens, the system shall do b.\n- **REQ-2.** When c happens, the system shall do d.\n'; } > "$_d/spec.md"
  printf -- '- [x] **T1** do b → REQ-1\n- [x] **T2** do d → REQ-2\n' > "$_d/tasks.md"
  printf '# demo/REQ-1\n' > "$1/tests/test_demo.py"
  printf '# demo/REQ-2 is handled here\n' > "$1/app/x.py"
}
tlrun() { sh "$COPY/scripts/spec-check.sh" "$@" > "$WORK/tl.out" 2>&1; echo $?; }  # → the exit status; output in tl.out
tl_fail=""; tl_i=0
for tl_line in 'tests/' 'tests'; do
  tl_i=$((tl_i + 1)); P="$WORK/tl-$tl_i"; tlspec "$P" "$tl_line"
  rc=$(tlrun "$P")
  if [ "$rc" -ne 1 ] || ! grep -q '^CITED-ELSEWHERE demo REQ-2 app/x.py$' "$WORK/tl.out" || ! grep -q '^MISSING-TEST demo REQ-2$' "$WORK/tl.out" \
     || grep -q 'MISSING-TEST demo REQ-1' "$WORK/tl.out" || ! grep -q '^EVIDENCE demo tested=1 waived=0 uncited=1$' "$WORK/tl.out"; then
    tl_fail="$tl_fail [Tests: $tl_line → exit $rc: $(grep -E '^(CITED|MISSING|EVIDENCE)' "$WORK/tl.out" | tr '\n' ';')]"
  fi
done
P="$WORK/tl-none"; tlspec "$P" none
rc=$(tlrun "$P")
if [ "$rc" -ne 0 ] || grep -q 'CITED-ELSEWHERE' "$WORK/tl.out" || ! grep -q '^EVIDENCE demo tested=2 waived=0 uncited=0$' "$WORK/tl.out"; then
  tl_fail="$tl_fail [no Tests line → exit $rc: $(grep -E '^(CITED|MISSING|EVIDENCE)' "$WORK/tl.out" | tr '\n' ';')]"
fi
P="$WORK/tl-both"; tlspec "$P" 'tests/'; printf '# demo/REQ-2\n' >> "$P/tests/test_demo.py"
rc=$(tlrun "$P")
if [ "$rc" -ne 0 ] || ! grep -q '^CITED-ELSEWHERE demo REQ-2 app/x.py$' "$WORK/tl.out" || grep -q 'MISSING-TEST' "$WORK/tl.out"; then
  tl_fail="$tl_fail [cited under tests/ and elsewhere → exit $rc: $(grep -E '^(CITED|MISSING|EVIDENCE)' "$WORK/tl.out" | tr '\n' ';')]"
fi
P="$WORK/tl-file"; tlspec "$P" 'scripts/smoke.sh, tests/'
printf '# demo/REQ-2\n' > "$P/scripts/smoke.sh"; printf '# demo/REQ-2\n' > "$P/scripts/other.sh"
mkdir -p "$P/.shipkit/specs/other"
printf '# Spec: other\n\n> Spec accepted at commit `abc1234` on main.\n> Status: shipped\n\n## Requirements\n\n- **REQ-1.** When e happens, the system shall do f.\n' > "$P/.shipkit/specs/other/spec.md"
printf -- '- [x] **T1** do f → REQ-1\n' > "$P/.shipkit/specs/other/tasks.md"
printf '# other/REQ-1\n' >> "$P/app/x.py"
rc=$(tlrun "$P")
if [ "$rc" -ne 0 ] || ! grep -q '^CITED-ELSEWHERE demo REQ-2 scripts/other.sh$' "$WORK/tl.out" || ! grep -q '^CITED-ELSEWHERE demo REQ-2 app/x.py$' "$WORK/tl.out" \
   || grep -q 'CITED-ELSEWHERE other' "$WORK/tl.out" || ! grep -q '^EVIDENCE other tested=1 waived=0 uncited=0$' "$WORK/tl.out" \
   || ! grep -q '^EVIDENCE demo tested=2 waived=0 uncited=0$' "$WORK/tl.out"; then
  tl_fail="$tl_fail [a file on the Tests line, and a second spec with none → exit $rc: $(grep -E '^(CITED|MISSING|EVIDENCE)' "$WORK/tl.out" | tr '\n' ';')]"
fi
if [ -z "$tl_fail" ]; then pass "tests-line (a citation counts only under the Tests paths, folder or file; one elsewhere is named and its requirement misses its test; no line → as before; the name alone is no gap)"
else failc "tests-line" "$tl_fail"; fi

# 101. skipped-cite: a citation in a test that never runs proves nothing, so spec-check names it.
# A counted citation on a line that holds a skip marker, or within three lines above or below
# one, is printed with the citation's own file and line. Information only: no exit status
# changes. The markers are whole words, so an exit call or a max-fail option is not one, and
# the word in a sentence is not one either. No claude needed.
# Cites: honest-evidence/REQ-19 honest-evidence/REQ-20
skrun() { sh "$COPY/scripts/spec-check.sh" "$@" > "$WORK/sk.out" 2>&1; echo $?; }  # → the exit status; output in sk.out
sk_fail=""
P="$WORK/sk"; mkdir -p "$P/.shipkit/specs/demo" "$P/tests" "$P/app"; (cd "$P" && git init -q)
{ printf '# Spec: demo\n\n> Spec accepted at commit `abc1234` on main.\n> Status: shipped\n\n## Requirements\n\n'
  for sk_n in 1 2 3 4 5 6 7; do printf -- '- **REQ-%s.** When a%s happens, the system shall do b.\n' "$sk_n" "$sk_n"; done; } > "$P/.shipkit/specs/demo/spec.md"
printf -- '- [x] **T1** all of it → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7\n' > "$P/.shipkit/specs/demo/tasks.md"
# line 2 cites, the marker is on line 1
printf '  @tag :skip\n  test "demo/REQ-1 refunds in full" do\n  end\n' > "$P/tests/a_test.exs"
# the marker and the citation share line 1
printf "it.skip('demo/REQ-2 rejects an over-refund', () => {})\n" > "$P/tests/b.test.js"
# REQ-3 sits three lines below its marker (line 4), REQ-4 four lines below its own (line 10)
printf '@pytest.mark.skip\ndef test_three():\n    pass\n# demo/REQ-3\n\n@pytest.mark.skip\ndef test_four():\n    x = 1\n    y = 2\n# demo/REQ-4\n' > "$P/tests/test_c.py"
# three near misses on and around line 3: an exit call, a max-fail option, the word in a sentence
printf 'import sys\n# we skip nothing here, and nothing is pending\n# demo/REQ-5\nsys.exit(0)  # pytest --maxfail=1\n' > "$P/tests/test_f.py"
# the marker is one line below the citation (line 1)
printf '// demo/REQ-6\nfunc TestSix(t *testing.T) {\n\tt.Skip("later")\n}\n' > "$P/tests/d_test.go"
# the marker is a first word, two lines below the citation (line 1)
printf '# demo/REQ-7\nit "does seven" do\n  skip "later"\nend\n' > "$P/tests/e_spec.rb"
rc=$(skrun "$P")
sk_got=$(grep '^SKIPPED-CITE' "$WORK/sk.out" | sort | tr '\n' ';')
sk_want="SKIPPED-CITE demo REQ-1 tests/a_test.exs:2;SKIPPED-CITE demo REQ-2 tests/b.test.js:1;SKIPPED-CITE demo REQ-3 tests/test_c.py:4;SKIPPED-CITE demo REQ-6 tests/d_test.go:1;SKIPPED-CITE demo REQ-7 tests/e_spec.rb:1;"
[ "$sk_got" = "$sk_want" ] || sk_fail="$sk_fail [got: $sk_got]"
[ "$rc" -eq 0 ] && [ "$(sed -n '$p' "$WORK/sk.out")" = "spec-check: 1 spec(s) checked, 0 gap(s)" ] \
  || sk_fail="$sk_fail [a shipped spec whose every requirement is cited exits $rc: $(sed -n '$p' "$WORK/sk.out")]"
# with a Tests line, a skipped citation outside its paths is not a counted one: it is named
# as elsewhere, and not as skipped
printf "it.skip('demo/REQ-2 again', () => {})\n" > "$P/app/x.js"
sed 's|^> Status: shipped$|> Status: shipped\
> Tests: tests/|' "$P/.shipkit/specs/demo/spec.md" > "$WORK/sk.tmp" && mv "$WORK/sk.tmp" "$P/.shipkit/specs/demo/spec.md"
rc=$(skrun "$P")
[ "$(grep '^SKIPPED-CITE' "$WORK/sk.out" | sort | tr '\n' ';')" = "$sk_want" ] && grep -q '^CITED-ELSEWHERE demo REQ-2 app/x.js$' "$WORK/sk.out" && [ "$rc" -eq 0 ] \
  || sk_fail="$sk_fail [with a Tests line: exit $rc: $(grep -E '^(SKIPPED|CITED)' "$WORK/sk.out" | tr '\n' ';')]"
if [ -z "$sk_fail" ]; then pass "skipped-cite (five frameworks' markers on, above and below the citation; four lines away, an exit call, a max-fail option and the word in a sentence give none; exit status as before)"
else failc "skipped-cite" "$sk_fail"; fi

# 102. spec-diff: which requirements did a branch change? spec-diff.sh compares the spec in the
# working tree with a baseline: spec.md at the base ref when it is there, else spec.md at the
# first commit after the base ref whose Status reads open, else NO-BASELINE. It prints
# REQ-CHANGED, REQ-ADDED, REQ-REMOVED and, beside REQ-CHANGED, WAIVER-ADDED; the same words
# wrapped or spaced another way are not a change. Exit 0 with nothing to print, 1 with a
# finding, 64 on wrong usage. It changes no file and is sh, awk and git. No claude needed.
# Cites: honest-evidence/REQ-21 honest-evidence/REQ-22 honest-evidence/REQ-23
# honest-evidence/REQ-24 honest-evidence/REQ-25 honest-evidence/REQ-26 honest-evidence/REQ-27
# honest-evidence/REQ-28 honest-evidence/REQ-29
SDF="$COPY/scripts/spec-diff.sh"
sdc() { (cd "$1" && shift && git -c user.email=s@s -c user.name=s "$@"); }   # sdc <proj> <git arguments>
sdspec() {  # sdspec <proj> <status> → the spec demo with three requirements, the second on two lines
  mkdir -p "$1/.shipkit/specs/demo"
  printf '# Spec: demo\n\n> Spec accepted at commit `abc1234` on main.\n> Status: %s\n\n## Requirements\n\n- **REQ-1.** When a happens, the system shall do b.\n- **REQ-2.** While c holds, the system shall keep d\n  and shall keep e.\n- **REQ-3.** The README shall say f.\n\n## Out of scope\nNothing.\n' "$2" > "$1/.shipkit/specs/demo/spec.md"
}
sdrun() { sh "$SDF" "$@" > "$WORK/sd.out" 2>&1; echo $?; }   # → the exit status; output in sd.out
if [ ! -f "$SDF" ]; then
  failc "spec-diff" "scripts/spec-diff.sh does not exist (check written first, by design)"
else
  sd_fail=""
  sh -n "$SDF" 2>/dev/null || sd_fail="$sd_fail [sh -n reports a syntax error]"
  # a. the baseline is the spec at the base ref
  P="$WORK/sd-a"; mkdir -p "$P"; sdc "$P" init -q -b main; sdspec "$P" open; sdc "$P" add -A; sdc "$P" commit -q -m spec; sdc "$P" tag base
  rc=$(sdrun "$P" demo base)
  [ "$rc" -eq 0 ] && ! grep -q '^REQ-\|^WAIVER' "$WORK/sd.out" && grep -q '^spec-diff: 0 requirement(s) differ from ' "$WORK/sd.out" \
    || sd_fail="$sd_fail [an untouched spec: exit $rc: $(tr '\n' ';' < "$WORK/sd.out")]"
  # REQ-1 reworded, REQ-2 wrapped and spaced another way, REQ-3 given a waiver, REQ-4 new
  printf '# Spec: demo\n\n> Spec accepted at commit `abc1234` on main.\n> Status: open\n\n## Requirements\n\n- **REQ-1.** When a happens, the system shall do b twice.\n- **REQ-2.** While c holds,\n  the system shall   keep d and shall keep e.\n- **REQ-3.** The README shall say f. [untested: prose]\n- **REQ-4.** When g happens, the system shall do h.\n\n## Out of scope\nNothing.\n' > "$P/.shipkit/specs/demo/spec.md"
  sd_before=$(cd "$P" && git status --porcelain)
  rc=$(sdrun "$P" demo base)
  sd_got=$(grep -v '^spec-diff:' "$WORK/sd.out" | tr '\n' ';')
  [ "$rc" -eq 1 ] && [ "$sd_got" = "REQ-CHANGED demo REQ-1;REQ-CHANGED demo REQ-3;WAIVER-ADDED demo REQ-3;REQ-ADDED demo REQ-4;" ] \
    && grep -q '^spec-diff: 3 requirement(s) differ from ' "$WORK/sd.out" \
    || sd_fail="$sd_fail [four edits: exit $rc: $(tr '\n' ';' < "$WORK/sd.out")]"
  [ "$sd_before" = "$(cd "$P" && git status --porcelain)" ] || sd_fail="$sd_fail [the script changed the tree]"
  if command -v dash >/dev/null 2>&1; then
    [ "$(dash "$SDF" "$P" demo base 2>&1)" = "$(cat "$WORK/sd.out")" ] || sd_fail="$sd_fail [dash prints something else]"
  fi
  # the base is the merge base with main when none is given
  sdc "$P" checkout -q -b work; rc=$(sdrun "$P" demo)
  [ "$rc" -eq 1 ] && grep -q '^REQ-ADDED demo REQ-4$' "$WORK/sd.out" || sd_fail="$sd_fail [no base ref given: exit $rc: $(tr '\n' ';' < "$WORK/sd.out")]"
  # REQ-2 taken out
  sdspec "$P" open; grep -v 'REQ-2\|shall keep e' "$P/.shipkit/specs/demo/spec.md" > "$WORK/sd.tmp" && mv "$WORK/sd.tmp" "$P/.shipkit/specs/demo/spec.md"
  rc=$(sdrun "$P" demo base)
  [ "$rc" -eq 1 ] && [ "$(grep -v '^spec-diff:' "$WORK/sd.out" | tr '\n' ';')" = "REQ-REMOVED demo REQ-2;" ] \
    || sd_fail="$sd_fail [a requirement removed: exit $rc: $(tr '\n' ';' < "$WORK/sd.out")]"
  # b. no spec at the base ref: the baseline is the first commit in which its Status reads open
  P="$WORK/sd-b"; mkdir -p "$P"; sdc "$P" init -q -b main; sdc "$P" commit -q --allow-empty -m init; sdc "$P" tag base
  sdspec "$P" draft; sdc "$P" add -A; sdc "$P" commit -q -m draft
  rc=$(sdrun "$P" demo base)
  [ "$rc" -eq 0 ] && [ "$(cat "$WORK/sd.out")" = "NO-BASELINE demo" ] || sd_fail="$sd_fail [never open: exit $rc: $(tr '\n' ';' < "$WORK/sd.out")]"
  sdspec "$P" open; sdc "$P" add -A; sdc "$P" commit -q -m accepted
  sed 's/shall do b\./shall do b and c./' "$P/.shipkit/specs/demo/spec.md" > "$WORK/sd.tmp" && mv "$WORK/sd.tmp" "$P/.shipkit/specs/demo/spec.md"
  sdc "$P" add -A; sdc "$P" commit -q -m "edit after acceptance"
  rc=$(sdrun "$P" demo base)
  [ "$rc" -eq 1 ] && [ "$(grep -v '^spec-diff:' "$WORK/sd.out" | tr '\n' ';')" = "REQ-CHANGED demo REQ-1;" ] \
    || sd_fail="$sd_fail [first open commit as the baseline: exit $rc: $(tr '\n' ';' < "$WORK/sd.out")]"
  # c. wrong usage
  sh "$SDF" >/dev/null 2>&1; [ $? -eq 64 ] || sd_fail="$sd_fail [no argument is not exit 64]"
  sh "$SDF" "$P" nosuch base >/dev/null 2>&1; [ $? -eq 64 ] || sd_fail="$sd_fail [an unknown spec is not exit 64]"
  sh "$SDF" "$P" demo nosuchref >/dev/null 2>&1; [ $? -eq 64 ] || sd_fail="$sd_fail [an unknown base ref is not exit 64]"
  # d. sh, awk and git: no other program is run outside a comment
  sd_tools=$(awk '!/^[ \t]*#/' "$SDF" | grep -n -E '(^|[|;&(`[:space:]])(sed|grep|sort|cut|tr|head|tail|wc|mktemp|rm|cat|python3?|perl|find|xargs)[[:space:]]' | head -3)
  [ -z "$sd_tools" ] || sd_fail="$sd_fail [another program is run: $sd_tools]"
  if [ -z "$sd_fail" ]; then pass "spec-diff (changed, added, removed and waived requirements against the spec at the base ref or its first open commit; a re-wrap is no change; exit 0, 1 and 64; no file touched; sh, awk and git only)"
  else failc "spec-diff" "$sd_fail"; fi
fi

# 103. spec-edited: brief-verify.sh allows everything under the task's own spec folder, so an
# agent that rewrote the requirement it was given went unseen. Now a change to that spec's
# spec.md or design.md since the base ref is named, SPEC-EDITED <file>. Information: the exit
# status is still decided by OUTSIDE lines alone, and ticking tasks.md prints nothing.
# No claude needed. Cites: honest-evidence/REQ-30 honest-evidence/REQ-31
SE="$WORK/spec-edited"; mkdir -p "$SE/.shipkit/specs/refunds" "$SE/app"; (cd "$SE" && git init -q)
printf '# Spec: refunds\n\n> Spec accepted at commit `abc1234` on main.\n> Status: open\n\n## Purpose\nRefund a charge.\n\n## Requirements\n\n- **REQ-1.** When a refund is asked for, the system shall pay it.\n' > "$SE/.shipkit/specs/refunds/spec.md"
printf '# Design: refunds\n\n## Approach\nOne function.\n' > "$SE/.shipkit/specs/refunds/design.md"
printf -- '- [ ] **T1** Pay a refund → REQ-1\n  - Files: app/refunds.py\n  - Test: tests/test_refunds.py\n  - After: none\n  - Done when: `pytest` → all pass\n' > "$SE/.shipkit/specs/refunds/tasks.md"
(cd "$SE" && git add -A && git -c user.email=s@s -c user.name=s commit -q -m spec)
se_base=$(cd "$SE" && git rev-parse HEAD)
serun() { sh "$COPY/scripts/brief-verify.sh" "$SE" refunds T1 "$se_base" > "$WORK/se.out" 2>&1; echo $?; }   # → the exit status; output in se.out
se_fail=""
# the task's own file, and its box ticked: nothing to name
printf 'x\n' > "$SE/app/refunds.py"
sed 's/- \[ \] \*\*T1\*\*/- [x] **T1**/' "$SE/.shipkit/specs/refunds/tasks.md" > "$WORK/se.tmp" && mv "$WORK/se.tmp" "$SE/.shipkit/specs/refunds/tasks.md"
rc=$(serun)
[ "$rc" -eq 0 ] && ! grep -q 'SPEC-EDITED' "$WORK/se.out" || se_fail="$se_fail [only tasks.md ticked: exit $rc: $(tr '\n' ';' < "$WORK/se.out")]"
# the design rewritten: named, and still exit 0
printf '\nNow two functions.\n' >> "$SE/.shipkit/specs/refunds/design.md"
rc=$(serun)
[ "$rc" -eq 0 ] && grep -q '^SPEC-EDITED \.shipkit/specs/refunds/design\.md$' "$WORK/se.out" && ! grep -q 'SPEC-EDITED .*spec\.md' "$WORK/se.out" \
  && grep -q '^brief-verify: .* all inside the Files of refunds / T1$' "$WORK/se.out" \
  || se_fail="$se_fail [design.md edited: exit $rc: $(tr '\n' ';' < "$WORK/se.out")]"
# the requirement rewritten, and a file outside the task's list: both named, exit 1 for the second
sed 's/shall pay it\./shall pay it within a week./' "$SE/.shipkit/specs/refunds/spec.md" > "$WORK/se.tmp" && mv "$WORK/se.tmp" "$SE/.shipkit/specs/refunds/spec.md"
printf 'y\n' > "$SE/app/other.py"
rc=$(serun)
[ "$rc" -eq 1 ] && grep -q '^SPEC-EDITED \.shipkit/specs/refunds/spec\.md$' "$WORK/se.out" && grep -q '^SPEC-EDITED \.shipkit/specs/refunds/design\.md$' "$WORK/se.out" \
  && grep -q '^OUTSIDE app/other\.py$' "$WORK/se.out" && ! grep -q 'OUTSIDE \.shipkit' "$WORK/se.out" \
  || se_fail="$se_fail [spec.md edited and a file outside: exit $rc: $(tr '\n' ';' < "$WORK/se.out")]"
if [ -z "$se_fail" ]; then pass "spec-edited (the task's own spec.md and design.md are named when they change; a ticked tasks.md is not; the exit status is the OUTSIDE lines' alone)"
else failc "spec-edited" "$se_fail"; fi

# 104. text-label: an assertion that only reads the wording of a skill, an agent or a rule
# shows that the words are there, not that a model follows them. Those assertions pass through
# passt and print as "PASS  [text]", the count line says how many there were, and
# docs/design/smoke-audit-5.4.md lists each one with the requirement its check cites and what
# else cites that requirement. Check 76, ship-retry, is one of them. No claude needed.
# Cites: honest-evidence/REQ-32
tx_fail=""
tx_out=$( (COUNTS=/dev/null; passt "probe") 2>/dev/null )
[ "$tx_out" = "PASS  [text] probe" ] || tx_fail="$tx_fail [passt prints: $tx_out]"
# the two searches below must not find their own lines: the first is anchored on the line's
# start, the second leaves this check out
grep -q '^if \[ -z "\$sy_fail" \]; then passt "ship-retry (' "$SELF" || tx_fail="$tx_fail [check 76's assertion is not a passt call]"
tx_calls=$(awk '/^# [0-9]+[a-z]?\. / { lab = $2 } lab != "104." && /passt "[a-z0-9-]+ \(/ { n++ } END { print n + 0 }' "$SELF")
tx_rows=$(grep -c '^| [0-9][0-9]*[a-z]\{0,1\} | ' "$ROOT/docs/design/smoke-audit-5.4.md" 2>/dev/null)
[ "${tx_calls:-0}" -gt 0 ] && [ "${tx_calls:-0}" -eq "${tx_rows:-0}" ] || tx_fail="$tx_fail [$tx_calls passt calls in this script, ${tx_rows:-0} rows in the audit]"
if [ -z "$tx_fail" ]; then pass "text-label (passt prints PASS  [text]; check 76 goes through it; $tx_calls text-only assertions, each with its row in the audit)"
else failc "text-label" "$tx_fail"; fi

# 105. timing-switch: check 30 holds the fifty-spec briefing to one second of CPU. That limit
# was set on the owner's machine. CI's shared runner read 0.96 s and then 1.53 s on the same
# scripts (pull request 40), so the workflow once set SMOKE_TIMING=report: a time of a second or
# more is then printed in a PASS line that says it was not enforced. The line and byte limits
# still fail, and without the switch nothing changes. Sprint 31 made the briefing cheap and took
# the switch out; five runs passed (0.41 to 0.97 s) and the sixth failed at 1.02 s, best of
# three, on unchanged scripts, so the workflow sets the switch again (numbers-as-data T8). Check
# 30's own verdict function runs here on given numbers, in a subshell, so its lines are read and
# not counted. No claude needed.
# Cites: honest-evidence/REQ-41 honest-evidence/REQ-42 honest-evidence/REQ-43
# numbers-as-data/REQ-18
ts_v() { ( COUNTS=/dev/null; SMOKE_TIMING=$1; brief50_verdict "$2" "$3" "$4" 3 ); }  # ts_v <switch> <lines> <bytes> <seconds>
ts_fail=""
ts_out=$(ts_v report 3 299 1.53)
case "$ts_out" in
  "PASS  briefing (50 open specs"*"1.53s of CPU"*"not enforced"*) ;;
  *) ts_fail="$ts_fail [report, 1.53 s: $ts_out]" ;;
esac
ts_out=$(ts_v report 3 299 0.80)
case "$ts_out" in
  *"not enforced"*) ts_fail="$ts_fail [report, 0.80 s is called not enforced: $ts_out]" ;;
  "PASS  briefing (50 open specs"*"0.80s of CPU"*) ;;
  *) ts_fail="$ts_fail [report, 0.80 s: $ts_out]" ;;
esac
case "$(ts_v report 9 299 0.80)" in "FAIL  briefing"*) ;; *) ts_fail="$ts_fail [report, nine lines: not a FAIL]" ;; esac
case "$(ts_v report 3 801 1.53)" in "FAIL  briefing"*) ;; *) ts_fail="$ts_fail [report, 801 bytes: not a FAIL]" ;; esac
case "$(ts_v "" 3 299 1.53)" in "FAIL  briefing"*) ;; *) ts_fail="$ts_fail [no switch, 1.53 s: not a FAIL]" ;; esac
case "$(ts_v "" 3 299 0.80)" in "PASS  briefing (50 open specs"*) ;; *) ts_fail="$ts_fail [no switch, 0.80 s: not a PASS]" ;; esac
case "$(ts_v other 3 299 1.53)" in "FAIL  briefing"*) ;; *) ts_fail="$ts_fail [a switch value other than report, 1.53 s: not a FAIL]" ;; esac
ts_job=$(awk '/^  smoke-no-model:$/ { on = 1; next } on && /^  [a-z]/ { on = 0 } on' "$ROOT/.github/workflows/lint.yml")
printf '%s\n' "$ts_job" | grep -q '^      SMOKE_TIMING: report$' || ts_fail="$ts_fail [lint.yml: the smoke-no-model job does not set SMOKE_TIMING to report]"
if [ -z "$ts_fail" ]; then pass "timing-switch (SMOKE_TIMING=report: a slow fifty-spec briefing is printed, not failed; lines and bytes still fail; no switch, no change; CI's smoke job sets it)"
else failc "timing-switch" "$ts_fail"; fi

# 106. test-command: the project's test command is recorded once, by the installer, in
# .claude/rules/shipkit/.test-command, and test-command.sh prints it. Nothing that needs the
# command reads CLAUDE.md for it: on the 5.2 run a CLAUDE.md held two, and the one that exits 1
# was copied into every Done-when. The record sits beside the manifest and outside it, as
# .setup-files does, so rewriting it is not drift and removal takes it without --force
# (gate-as-software/design.md, second record). No claude needed.
# Cites: gate-as-software/REQ-2 gate-as-software/REQ-3 gate-as-software/REQ-4
# gate-as-software/REQ-5 gate-as-software/REQ-6 gate-as-software/REQ-7 gate-as-software/REQ-8
TC="$WORK/tc-proj"; mkdir -p "$TC"
printf '# demo\n\n- **Test:** `mix test`\n\nBefore a commit run `MIX_ENV=test mix test`.\n' > "$TC/CLAUDE.md"
TCS="$COPY/scripts/test-command.sh"; TCR="$TC/.claude/rules/shipkit/.test-command"; tc_fail=""
tc_run() { tc_out=$(sh "$TCS" "$@" 2>"$WORK/tc.err"); tc_rc=$?; tc_err=$(cat "$WORK/tc.err"); }
# no record: exit 1 and the message, though CLAUDE.md names two commands
tc_run "$TC"
[ "$tc_rc" -eq 1 ] && [ -z "$tc_out" ] && [ "$tc_err" = "no test command recorded; run /shipkit:setup, or pass one" ] \
  || tc_fail="$tc_fail [no record: exit $tc_rc, printed '$tc_out', said '$tc_err']"
# an install that is given TEST_COMMAND writes the record, one line
sh "$COPY/scripts/install-rules.sh" "$COPY" "$TC" >/dev/null 2>&1
sh "$COPY/scripts/install-stack.sh" "$COPY" rails "$TC" TEST_COMMAND="bundle exec rspec" TEST_FRAMEWORK=RSpec DATABASE=PostgreSQL RAILS_ARCHITECTURE=MVC API_MODE=no FRONTEND=Hotwire >/dev/null 2>&1 \
  || tc_fail="$tc_fail [the rails install exited non-zero]"
[ "$(cat "$TCR" 2>/dev/null)" = "bundle exec rspec" ] && [ "$(grep -c '' "$TCR" 2>/dev/null)" = 1 ] \
  || tc_fail="$tc_fail [after an install with TEST_COMMAND the record holds '$(cat "$TCR" 2>/dev/null)']"
# the script prints the record, not either of CLAUDE.md's commands
tc_run "$TC"
[ "$tc_rc" -eq 0 ] && [ "$tc_out" = "bundle exec rspec" ] || tc_fail="$tc_fail [with a record: exit $tc_rc, printed '$tc_out']"
# a second overlay that takes no TEST_COMMAND leaves the record, and so does an install that fails
sh "$COPY/scripts/install-stack.sh" "$COPY" oban "$TC" OBAN_QUEUES=default >/dev/null 2>&1 \
  || tc_fail="$tc_fail [the oban install exited non-zero]"
[ "$(cat "$TCR" 2>/dev/null)" = "bundle exec rspec" ] || tc_fail="$tc_fail [an install with no TEST_COMMAND changed the record to '$(cat "$TCR" 2>/dev/null)']"
sh "$COPY/scripts/install-stack.sh" "$COPY" python "$TC" TEST_COMMAND=pytest >/dev/null 2>&1 \
  && tc_fail="$tc_fail [the python install with a placeholder uncovered succeeded]"
[ "$(cat "$TCR" 2>/dev/null)" = "bundle exec rspec" ] || tc_fail="$tc_fail [a failed install changed the record to '$(cat "$TCR" 2>/dev/null)']"
# --record writes one line; an empty command is a usage error and writes nothing
tc_run "$TC" --record 'MIX_ENV=test mise exec -- mix test'
[ "$tc_rc" -eq 0 ] && [ "$(cat "$TCR" 2>/dev/null)" = "MIX_ENV=test mise exec -- mix test" ] && [ "$(grep -c '' "$TCR" 2>/dev/null)" = 1 ] \
  || tc_fail="$tc_fail [--record: exit $tc_rc, the record holds '$(cat "$TCR" 2>/dev/null)']"
tc_run "$TC" --record ''
[ "$tc_rc" -eq 2 ] && [ "$(cat "$TCR" 2>/dev/null)" = "MIX_ENV=test mise exec -- mix test" ] \
  || tc_fail="$tc_fail [--record with an empty command: exit $tc_rc, the record holds '$(cat "$TCR" 2>/dev/null)']"
# the session hook says nothing new about a project that has the record
tc_hook=$(cd "$TC" && git init -q 2>/dev/null; CLAUDE_PLUGIN_ROOT="$COPY" sh "$COPY/scripts/session-start.sh" 2>&1)
case "$tc_hook" in *test-command*|*"run /shipkit:setup"*) tc_fail="$tc_fail [the hook speaks of the record or of a stale install: $(printf '%s' "$tc_hook" | grep -E 'test-command|shipkit:setup' | head -2 | tr '\n' '|')]";; esac
# removal takes the record with the manifest, without --force
sh "$COPY/scripts/unsetup-remove.sh" "$TC" --yes >/dev/null 2>&1
[ ! -e "$TCR" ] && [ ! -e "$TC/.claude/rules/shipkit/.installed" ] || tc_fail="$tc_fail [after unsetup-remove --yes the record or the manifest is still there]"
if [ -z "$tc_fail" ]; then pass "test-command (the installer records TEST_COMMAND; a later or failed install leaves it; the script prints it and never reads CLAUDE.md; no record → exit 1; --record; removal deletes it)"
else failc "test-command" "$tc_fail"; fi

# 107. ship-check: the gate's command steps, run by a command. ship-check.sh runs steps 1, 2, 3,
# 7 and 8 of /shipkit:ship and lists step 5's migration files, and writes a block for each to
# evidence.md in a scratch directory of its own: the exact command, its exit status, the last
# twenty lines of its output and a result line. A step that is a command cannot then be
# skipped or retyped (gate-as-software/design.md, first record). The fixture is the finished
# feature check 29 gates; every run here has a stand-in claude first on the PATH, and the last
# assertion is that it was never called. The ship skill does not call the script until
# Sprint 35. No claude needed.
# Cites: gate-as-software/REQ-9 gate-as-software/REQ-10 gate-as-software/REQ-11
# gate-as-software/REQ-12 gate-as-software/REQ-13 gate-as-software/REQ-14 gate-as-software/REQ-15
# gate-as-software/REQ-16 gate-as-software/REQ-17 gate-as-software/REQ-18 gate-as-software/REQ-19
# gate-as-software/REQ-20 gate-as-software/REQ-21 gate-as-software/REQ-22 gate-as-software/REQ-23
# tests-worth-having/REQ-43
SK="$WORK/sck"; mkdir -p "$SK/base" "$SK/tmp" "$SK/tmp-h" "$SK/bin"
(cd "$SK/base" && bash "$COPY/evals/reviewer/all-met/fixture.sh" >/dev/null 2>&1)
printf '#!/bin/sh\necho called >> "%s"\n' "$SK/claude.log" > "$SK/bin/claude"; chmod +x "$SK/bin/claude"
SKS="$COPY/scripts/ship-check.sh"; SK_T='python3 -m unittest discover -s tests'; sk_fail=""
sk_run() {  # sk_run <project> <args…> → $sk_out, $sk_rc, and the scratch directory in $sk_dir
  _p=$1; shift
  sk_out=$(TMPDIR="$SK/tmp" PATH="$SK/bin:$PATH" sh "$SKS" "$_p" "$@" 2>"$SK/err"); sk_rc=$?
  sk_dir=$(printf '%s\n' "$sk_out" | sed -n 1p); sk_ev="$sk_dir/evidence.md"
}
sk_commit() { (cd "$1" && git add -A && git -c user.email=s@s -c user.name=s commit -q -m "$2"); }
sk_has() { printf '%s\n' "$sk_out" | grep -qx "$1"; }   # sk_has '<n> <result>'
# a. the finished feature: six blocks in order, every result PASS, exit 0
cp -R "$SK/base" "$SK/a"; sk_run "$SK/a" refunds base --test "$SK_T"; sk_a=$sk_dir
case "$sk_dir" in "$SK/tmp"/shipkit-ship.??????) ;; *) sk_fail="$sk_fail [a: the first line is not a scratch directory under TMPDIR: '$sk_dir']";; esac
[ "$sk_rc" -eq 0 ] && [ -d "$sk_dir" ] && [ "$(printf '%s\n' "$sk_out" | sed 1d | tr '\n' ' ')" = "1 PASS 2 PASS 3 PASS 5 PASS 7 PASS 8 PASS " ] \
  || sk_fail="$sk_fail [a: exit $sk_rc, printed: $(printf '%s' "$sk_out" | tr '\n' '|') $(sed -n 1,2p "$SK/err")]"
[ "$(grep '^### ' "$sk_ev" 2>/dev/null | tr '\n' '|')" = "### 1. Spec check, as shipped|### 2. Tests|### 3. Tasks ticked|### 5. Migration rollback|### 7. Clean tree|### 8. Decisions fired|" ] \
  || sk_fail="$sk_fail [a: the blocks' headings: $(grep '^### ' "$sk_ev" 2>/dev/null | tr '\n' '|')]"
case "$(sed -n 1p "$sk_ev" 2>/dev/null)" in "shipkit ship-check: refunds at "*" against "*) ;; *) sk_fail="$sk_fail [a: evidence.md's first line: $(sed -n 1p "$sk_ev" 2>/dev/null)]";; esac
grep -qF '`sh <plugin root>/scripts/spec-check.sh . refunds --as-shipped` → exit 0' "$sk_ev" 2>/dev/null || sk_fail="$sk_fail [a: step 1's command and exit status are not in its block]"
grep -q '^evidence: EVIDENCE refunds tested=2 waived=1 uncited=0$' "$sk_ev" 2>/dev/null || sk_fail="$sk_fail [a: step 1 has no evidence: line with spec-check's EVIDENCE line]"
grep -q '^Requirements changed on this branch:$' "$sk_ev" 2>/dev/null && grep -q '^spec-diff: ' "$sk_ev" 2>/dev/null || sk_fail="$sk_fail [a: step 1 does not carry spec-diff's output]"
grep -qF '`python3 -m unittest discover -s tests` → exit 0' "$sk_ev" 2>/dev/null || sk_fail="$sk_fail [a: step 2's command and exit status are not in its block]"
grep -q 'no migration in the diff' "$sk_ev" 2>/dev/null || sk_fail="$sk_fail [a: step 5 does not say there is no migration]"
[ "$(grep -c '^result: PASS — ' "$sk_ev" 2>/dev/null)" = 6 ] || sk_fail="$sk_fail [a: $(grep -c '^result: PASS — ' "$sk_ev" 2>/dev/null) result: PASS lines, want 6]"
[ "$(sed -n '$p' "$sk_ev" 2>/dev/null)" = "Not run, a suggestion: sh \"<plugin root>/scripts/red-check.sh\" . refunds base --test '$SK_T'" ] \
  || sk_fail="$sk_fail [a: evidence.md does not end with the red-check.sh command and the test command given: $(sed -n '$p' "$sk_ev" 2>/dev/null)]"
# b. one task unticked: step 3 fails and names the line; exit 1
cp -R "$SK/base" "$SK/b"
sed 's/^- \[x\] \*\*T3\*\*/- [ ] **T3**/' "$SK/b/.shipkit/specs/refunds/tasks.md" > "$SK/b.tasks" && cp "$SK/b.tasks" "$SK/b/.shipkit/specs/refunds/tasks.md"
sk_commit "$SK/b" untick; sk_run "$SK/b" refunds base --test "$SK_T"
[ "$sk_rc" -eq 1 ] && sk_has '3 FAIL' && grep -q 'tasks\.md:[0-9]*:- \[ \] \*\*T3\*\*' "$sk_ev" 2>/dev/null \
  || sk_fail="$sk_fail [b: an unticked task: exit $sk_rc, printed: $(printf '%s' "$sk_out" | sed 1d | tr '\n' '|')]"
# c. step 7 reads the tree as it was before anything ran: uncommitted work fails it; an earlier
# report for the slug and a file the test command made do not
cp -R "$SK/base" "$SK/c1"; echo x >> "$SK/c1/README.md"; sk_run "$SK/c1" refunds base --test "$SK_T"
[ "$sk_rc" -eq 1 ] && sk_has '7 FAIL' && grep -q '^ M README\.md$' "$sk_ev" 2>/dev/null \
  || sk_fail="$sk_fail [c: a dirty tree: exit $sk_rc, printed: $(printf '%s' "$sk_out" | sed 1d | tr '\n' '|')]"
cp -R "$SK/base" "$SK/c2"; mkdir -p "$SK/c2/.shipkit/releases"; echo 'NOT READY' > "$SK/c2/.shipkit/releases/2026-01-01-refunds.md"
sk_run "$SK/c2" refunds base --test 'echo made > made-by-the-tests.txt'
[ "$sk_rc" -eq 0 ] && sk_has '7 PASS' && grep -q 'made-by-the-tests\.txt' "$sk_ev" 2>/dev/null \
  || sk_fail="$sk_fail [c: an earlier report and a file the tests made: exit $sk_rc, printed: $(printf '%s' "$sk_out" | sed 1d | tr '\n' '|')]"
# d. a failing test command: step 2 fails with its exit status, the command ran once, and the
# steps after it still ran
cp -R "$SK/base" "$SK/d"; sk_run "$SK/d" refunds base --test "echo run >> '$SK/count'; exit 3"
[ "$sk_rc" -eq 1 ] && sk_has '2 FAIL' && grep -q '→ exit 3$' "$sk_ev" 2>/dev/null && [ "$(grep -c . "$SK/count" 2>/dev/null)" = 1 ] \
   && [ "$(grep -c '^### ' "$sk_ev" 2>/dev/null)" = 6 ] && sk_has '8 PASS' \
  || sk_fail="$sk_fail [d: a failing test command: exit $sk_rc, ran $(grep -c . "$SK/count" 2>/dev/null) time(s), printed: $(printf '%s' "$sk_out" | sed 1d | tr '\n' '|')]"
# e. no --test and no record: FAIL — no test command known. With a record, that command runs
cp -R "$SK/base" "$SK/e"; sk_run "$SK/e" refunds base
[ "$sk_rc" -eq 1 ] && sk_has '2 FAIL' && grep -q '^result: FAIL — no test command known$' "$sk_ev" 2>/dev/null \
  || sk_fail="$sk_fail [e: no test command: exit $sk_rc, printed: $(printf '%s' "$sk_out" | sed 1d | tr '\n' '|')]"
sh "$COPY/scripts/test-command.sh" "$SK/e" --record "$SK_T" 2>/dev/null; sk_commit "$SK/e" record; sk_run "$SK/e" refunds base
[ "$sk_rc" -eq 0 ] && sk_has '2 PASS' && grep -qF '`python3 -m unittest discover -s tests` → exit 0' "$sk_ev" 2>/dev/null \
  || sk_fail="$sk_fail [e: the recorded command: exit $sk_rc, printed: $(printf '%s' "$sk_out" | sed 1d | tr '\n' '|')]"
# f. migration files in the diff are listed for a person to read; that is not a failure
cp -R "$SK/base" "$SK/f"; mkdir -p "$SK/f/db/migrate" "$SK/f/schema"
echo '-- add' > "$SK/f/db/migrate/20240101_add_refunds.rb"; echo '-- sql' > "$SK/f/schema/change.sql"
sk_commit "$SK/f" migrate; sk_run "$SK/f" refunds base --test "$SK_T"
[ "$sk_rc" -eq 0 ] && sk_has '5 NEEDS-READING' && grep -q '^db/migrate/20240101_add_refunds\.rb$' "$sk_ev" 2>/dev/null && grep -q '^schema/change\.sql$' "$sk_ev" 2>/dev/null \
  || sk_fail="$sk_fail [f: two migration files: exit $sk_rc, printed: $(printf '%s' "$sk_out" | sed 1d | tr '\n' '|')]"
# g. a decision whose Fired-if command exits 0 fails step 8
cp -R "$SK/base" "$SK/g"
printf '\n## Decision: A switch that is already on   (→ REQ-1)\n\n**Decision.** On.\n**Falsifiability.** We would reverse this if the README exists.\n**Fired-if.** `test -f README.md`\n' >> "$SK/g/.shipkit/specs/refunds/design.md"
sk_commit "$SK/g" fired; sk_run "$SK/g" refunds base --test "$SK_T"
[ "$sk_rc" -eq 1 ] && sk_has '8 FAIL' && grep -q '^FIRED ' "$sk_ev" 2>/dev/null \
  || sk_fail="$sk_fail [g: a fired decision: exit $sk_rc, printed: $(printf '%s' "$sk_out" | sed 1d | tr '\n' '|')]"
# h. no such spec: exit 2, a message, and no scratch directory made
TMPDIR="$SK/tmp-h" sh "$SKS" "$SK/a" nosuch base >/dev/null 2>"$SK/err"; sk_rc=$?
[ "$sk_rc" -eq 2 ] && [ -s "$SK/err" ] && [ -z "$(ls -A "$SK/tmp-h")" ] || sk_fail="$sk_fail [h: an unknown slug: exit $sk_rc, $(ls -A "$SK/tmp-h" | wc -l | tr -d ' ') entr(ies) made in TMPDIR]"
# i. two runs at once in one project: a scratch directory each, both whole
cp -R "$SK/base" "$SK/i"
(TMPDIR="$SK/tmp" PATH="$SK/bin:$PATH" sh "$SKS" "$SK/i" refunds base --test "$SK_T" > "$SK/i1.out" 2>/dev/null) & sk_p1=$!
(TMPDIR="$SK/tmp" PATH="$SK/bin:$PATH" sh "$SKS" "$SK/i" refunds base --test "$SK_T" > "$SK/i2.out" 2>/dev/null) & sk_p2=$!
wait "$sk_p1" "$sk_p2"
sk_d1=$(sed -n 1p "$SK/i1.out"); sk_d2=$(sed -n 1p "$SK/i2.out")
[ -n "$sk_d1" ] && [ "$sk_d1" != "$sk_d2" ] && [ "$(grep -c '^### ' "$sk_d1/evidence.md" 2>/dev/null)" = 6 ] && [ "$(grep -c '^### ' "$sk_d2/evidence.md" 2>/dev/null)" = 6 ] \
  || sk_fail="$sk_fail [i: two runs at once: '$sk_d1' and '$sk_d2']"
# j. --clean removes a directory the script made, and nothing else
sh "$SKS" --clean "$sk_a" >/dev/null 2>&1; sk_rc=$?
[ "$sk_rc" -eq 0 ] && [ ! -e "$sk_a" ] || sk_fail="$sk_fail [j: --clean on its own directory: exit $sk_rc]"
mkdir -p "$SK/other" "$SK/tmp/shipkit-ship.zzzzzz"; echo keep > "$SK/other/evidence.md"; echo 'not ours' > "$SK/tmp/shipkit-ship.zzzzzz/evidence.md"
sh "$SKS" --clean "$SK/other" >/dev/null 2>&1; sk_rc=$?
sh "$SKS" --clean "$SK/tmp/shipkit-ship.zzzzzz" >/dev/null 2>&1; sk_rc2=$?
[ "$sk_rc" -eq 1 ] && [ "$sk_rc2" -eq 1 ] && [ -f "$SK/other/evidence.md" ] && [ -f "$SK/tmp/shipkit-ship.zzzzzz/evidence.md" ] \
  || sk_fail="$sk_fail [j: --clean on a directory it did not make: exit $sk_rc and $sk_rc2]"
# l. evidence.md ends with one line that names the red-check.sh command for the same project,
# slug and base. Nothing runs it. It carries --test only when the script was given one, quoted
# so that it can be pasted, and standard output is the scratch path and six lines as before
cp -R "$SK/base" "$SK/l"; sk_run "$SK/l" refunds base
[ "$(sed -n '$p' "$sk_ev" 2>/dev/null)" = 'Not run, a suggestion: sh "<plugin root>/scripts/red-check.sh" . refunds base' ] \
  && [ "$(printf '%s\n' "$sk_out" | sed 1d | grep -c .)" = 6 ] && [ "$(grep -c '^### ' "$sk_ev" 2>/dev/null)" = 6 ] \
  || sk_fail="$sk_fail [l: with no test command the last line is: $(sed -n '$p' "$sk_ev" 2>/dev/null); printed: $(printf '%s' "$sk_out" | sed 1d | tr '\n' '|')]"
sk_run "$SK/l" refunds base --test "sh -c 'exit 0'"
[ "$(sed -n '$p' "$sk_ev" 2>/dev/null)" = "Not run, a suggestion: sh \"<plugin root>/scripts/red-check.sh\" . refunds base --test 'sh -c '\\''exit 0'\\'''" ] \
  || sk_fail="$sk_fail [l: a test command that holds a quote: $(sed -n '$p' "$sk_ev" 2>/dev/null)]"
# k. no model was started, and the script is clean under sh -n
[ ! -s "$SK/claude.log" ] || sk_fail="$sk_fail [k: claude was called $(grep -c . "$SK/claude.log") time(s)]"
sh -n "$SKS" 2>/dev/null || sk_fail="$sk_fail [k: sh -n reports a syntax error]"
if [ -z "$sk_fail" ]; then pass "ship-check (six blocks in order on a finished feature; an unticked task, a dirty tree, a failing or unknown test command and a fired decision each fail their own step; migrations are listed; a scratch directory for each run; --clean removes only its own; the evidence ends with the red-check.sh command, not run; no claude)"
else failc "ship-check" "$sk_fail"; fi

# 108. release-check: a READY report is tied to a commit. For each shipped spec,
# release-check.sh finds the newest READY report and the commit it names, and prints
# NO-REPORT when there is none, ORPHAN-REPORT when that commit is not in HEAD's history, and
# CHANGED-AFTER-GATE <n> when n commits touched the spec's Paths after the report's commit and
# up to the commit that set "Status: shipped". It only prints unless --enforce is given
# (gate-as-software/design.md, fourth record). The fixture's history, in order: specs written
# open; work on each spec's paths (W); a commit on a branch that is then deleted (X); reports;
# one more commit on late's paths and one elsewhere; every spec set shipped, in a commit that
# also touches clean's paths; one more commit on clean's paths after shipping. Neither of the
# last two may count. No claude needed.
# Cites: gate-as-software/REQ-24 gate-as-software/REQ-25 gate-as-software/REQ-26
# gate-as-software/REQ-27 gate-as-software/REQ-28 gate-as-software/REQ-29 gate-as-software/REQ-30
# gate-as-software/REQ-31
RC="$WORK/rel"; RCS="$COPY/scripts/release-check.sh"; rc_fail=""
rg() { (cd "$RC" && git -c user.email=s@s -c user.name=s "$@"); }
rcspec() {  # rcspec <slug> <status> <paths|none>
  mkdir -p "$RC/.shipkit/specs/$1"
  { printf '# Spec: %s\n\n> Spec accepted at commit `abc1234` on main.\n> Status: %s\n' "$1" "$2"
    [ "$3" = none ] || printf '> Paths: %s\n' "$3"
    printf '\n- **REQ-1.** It shall work.\n'; } > "$RC/.shipkit/specs/$1/spec.md"
}
rcrep() {  # rcrep <date> <slug> <first line> <commit>
  mkdir -p "$RC/.shipkit/releases"
  printf '%s\n\n# Ship report: %s\n\n> Checked on %s at commit `%s` on `main`, against base `abc1234`.\n' \
    "$3" "$2" "$1" "$4" > "$RC/.shipkit/releases/$1-$2.md"
}
rctouch() { for d in "$@"; do mkdir -p "$RC/$d"; echo x >> "$RC/$d/f"; done; }
mkdir -p "$RC"; rg init -q; rg commit -q --allow-empty -m init
rcspec clean open "c/"; rcspec noreport open "n/"; rcspec orphan open "o/"; rcspec late open "l/"
rcspec nopaths open none; rcspec wip open "w/"; rg add -A; rg commit -q -m specs
rctouch c n o l; rg add -A; rg commit -q -m work; rc_w=$(rg rev-parse --short HEAD)
rg checkout -q -b side; rctouch o; rg add -A; rg commit -q -m side; rc_x=$(rg rev-parse --short HEAD)
rg checkout -q -; rg branch -q -D side
rcrep 2026-01-01 clean READY "$rc_x"; rcrep 2026-02-01 clean READY "$rc_w"; rcrep 2026-03-01 clean 'NOT READY' "$rc_x"
rcrep 2026-02-01 orphan READY "$rc_x"; rcrep 2026-02-01 late READY "$rc_w"; rcrep 2026-02-01 nopaths READY "$rc_w"
rg add -A; rg commit -q -m reports
rctouch l; rg add -A; rg commit -q -m 'late work'
rctouch z; rg add -A; rg commit -q -m 'elsewhere'
for sl in clean noreport orphan late nopaths; do
  sed 's/^> Status: open$/> Status: shipped/' "$RC/.shipkit/specs/$sl/spec.md" > "$RC/s.tmp" && mv "$RC/s.tmp" "$RC/.shipkit/specs/$sl/spec.md"
done
rctouch c   # the shipping commit touches clean's paths itself, as a release's report and version bump do: not counted
rg add -A; rg commit -q -m ship
rctouch c; rg add -A; rg commit -q -m 'after shipping'
rc_out=$(sh "$RCS" "$RC" 2>&1); rc_rc=$?
rc_want="CHANGED-AFTER-GATE late 1
NO-REPORT noreport
ORPHAN-REPORT orphan
release-check: 5 shipped spec(s), 3 finding(s)"   # one spec at a time, in name order
[ "$rc_rc" -eq 0 ] && [ "$rc_out" = "$rc_want" ] || rc_fail="$rc_fail [the fixture: exit $rc_rc, printed: $(printf '%s' "$rc_out" | tr '\n' '|')]"
sh "$RCS" "$RC" --enforce >/dev/null 2>&1; rc_rc=$?
[ "$rc_rc" -eq 1 ] || rc_fail="$rc_fail [--enforce with findings: exit $rc_rc, want 1]"
# a project whose one shipped spec is clean: the summary line alone, exit 0 even with --enforce
RC2="$WORK/rel2"; mkdir -p "$RC2/.shipkit/specs/one" "$RC2/.shipkit/releases"
(cd "$RC2" && git init -q && printf '# one\n\n> Status: open\n> Paths: a/\n' > .shipkit/specs/one/spec.md \
  && git add -A && git -c user.email=s@s -c user.name=s commit -q -m one \
  && printf 'READY\n\n> Checked on 2026-01-01 at commit `%s` on `main`.\n' "$(git rev-parse --short HEAD)" > .shipkit/releases/2026-01-01-one.md \
  && sed 's/open/shipped/' .shipkit/specs/one/spec.md > s.tmp && mv s.tmp .shipkit/specs/one/spec.md \
  && git add -A && git -c user.email=s@s -c user.name=s commit -q -m ship)
rc_out=$(sh "$RCS" "$RC2" --enforce 2>&1); rc_rc=$?
[ "$rc_rc" -eq 0 ] && [ "$rc_out" = "release-check: 1 shipped spec(s), 0 finding(s)" ] \
  || rc_fail="$rc_fail [a clean project: exit $rc_rc, printed: $(printf '%s' "$rc_out" | tr '\n' '|')]"
# CI runs it on every pull request, in a job that fetches the full history
rc_job=$(awk '/^  lint:$/ { on = 1; next } on && /^  [a-z]/ { on = 0 } on' "$ROOT/.github/workflows/lint.yml")
printf '%s\n' "$rc_job" | grep -q '^        run: sh plugins/shipkit/scripts/release-check\.sh \.$' \
  && printf '%s\n' "$rc_job" | grep -q '^          fetch-depth: 0$' \
  || rc_fail="$rc_fail [lint.yml: the lint job does not run release-check.sh . with the full history]"
sh -n "$RCS" 2>/dev/null || rc_fail="$rc_fail [sh -n reports a syntax error]"
if [ -z "$rc_fail" ]; then pass "release-check (no report, an orphaned report and a commit under Paths after the gate are each named; the newest READY report counts; no Paths, no count; after shipping, no count; exit 0 unless --enforce; CI runs it)"
else failc "release-check" "$rc_fail"; fi

# 109. judge: a change does not judge itself. scripts/judge.sh runs this repository's gate with
# the plugin loaded from a worktree of the last tag, so a branch that weakened the gate is not
# judged by the weakened gate (decision 0007). Without --yes it prints the tag and the command
# and runs nothing; with --yes it makes a worktree of the tag, runs the command, and removes
# that worktree and no other, however the command ends. The fixture is a small repository with
# a tag; claude is a stand-in that records what it was given, so no model runs here. CI runs
# the last tag's spec-check.sh beside the branch's. A pattern below spells the command
# claude[ ]--plugin-dir so that check 97's scan does not read it as a model call. No claude needed.
# Cites: gate-as-software/REQ-32 gate-as-software/REQ-33 gate-as-software/REQ-34
# gate-as-software/REQ-35 gate-as-software/REQ-36
JG="$WORK/judge"; JGS="$ROOT/scripts/judge.sh"; JL="$WORK/judge-log"; mkdir -p "$JG/repo/plugins/shipkit" "$JG/bin" "$JL"; jg_fail=""
cat > "$JG/bin/claude" <<STUB
#!/bin/sh
echo called >> "$JL/calls"
pd=""; prev=""; last=""
for a in "\$@"; do [ "\$prev" = --plugin-dir ] && pd=\$a; prev=\$a; last=\$a; done
printf '%s\n' "\$pd" > "$JL/pd"
[ -d "\$pd" ] && echo yes > "$JL/existed"
git -C "\$pd" rev-parse HEAD > "$JL/head" 2>/dev/null
printf '%s\n' "\$last" > "$JL/prompt"
exit \${JUDGE_STUB_EXIT:-0}
STUB
chmod +x "$JG/bin/claude"
(cd "$JG/repo" && git init -q && echo v1 > plugins/shipkit/VERSION && git add -A \
  && git -c user.email=s@s -c user.name=s commit -q -m one && git tag v1.0.0 \
  && echo v2 > plugins/shipkit/VERSION && git -c user.email=s@s -c user.name=s commit -q -am two)
jg_tag=$(cd "$JG/repo" && git rev-parse v1.0.0)
(cd "$JG/repo" && git worktree add -q --detach "$JG/theirs" HEAD 2>/dev/null)   # a worktree judge.sh did not make
jg_wt() { (cd "$JG/repo" && git worktree list | grep -c .); }
jg_run() { jg_out=$(cd "$JG/repo" && PATH="$JG/bin:$PATH" sh "$JGS" "$@" 2>&1); jg_rc=$?; }
# a. without --yes: the tag and the command are printed, nothing runs, no worktree is made
jg_before=$(jg_wt); jg_run refunds main
[ "$jg_rc" -eq 0 ] && printf '%s\n' "$jg_out" | grep -qx 'judge: the last tag is v1.0.0' \
   && printf '%s\n' "$jg_out" | grep -q 'claude[ ]--plugin-dir <worktree>/plugins/shipkit --model sonnet' \
   && [ ! -e "$JL/calls" ] && [ "$(jg_wt)" = "$jg_before" ] \
  || jg_fail="$jg_fail [a: without --yes: exit $jg_rc, $(jg_wt) worktree(s), printed: $(printf '%s' "$jg_out" | tr '\n' '|')]"
# b. with --yes: claude ran once, with the plugin from a worktree of the tag; the worktree is gone after
jg_run refunds main --test 'make test' --yes
jg_pd=$(cat "$JL/pd" 2>/dev/null)
[ "$jg_rc" -eq 0 ] && [ "$(grep -c . "$JL/calls" 2>/dev/null)" = 1 ] && [ -s "$JL/existed" ] \
   && [ "$(cat "$JL/head" 2>/dev/null)" = "$jg_tag" ] && [ ! -e "$jg_pd" ] && [ "$(jg_wt)" = "$jg_before" ] \
  || jg_fail="$jg_fail [b: with --yes: exit $jg_rc, plugin dir '$jg_pd', head $(cat "$JL/head" 2>/dev/null) want $jg_tag, $(jg_wt) worktree(s) after]"
case "$jg_pd" in */plugins/shipkit) ;; *) jg_fail="$jg_fail [b: --plugin-dir is not <worktree>/plugins/shipkit: '$jg_pd']";; esac
case "$(cat "$JL/prompt" 2>/dev/null)" in "/shipkit:ship refunds main"*"not interactive"*"The project's test command is: make test"*) ;;
  *) jg_fail="$jg_fail [b: the prompt: $(tr '\n' '|' < "$JL/prompt" 2>/dev/null)]";; esac
# c. the command fails: judge.sh exits with its status, and the worktree is still removed
rm -f "$JL/existed" "$JL/pd"
jg_out=$(cd "$JG/repo" && JUDGE_STUB_EXIT=3 PATH="$JG/bin:$PATH" sh "$JGS" refunds main --yes 2>&1); jg_rc=$?
jg_pd=$(cat "$JL/pd" 2>/dev/null)
[ "$jg_rc" -eq 3 ] && [ -s "$JL/existed" ] && [ ! -e "$jg_pd" ] && [ "$(jg_wt)" = "$jg_before" ] \
  || jg_fail="$jg_fail [c: a failing command: exit $jg_rc, $(jg_wt) worktree(s) after]"
# d. the worktree made beforehand is still there
[ -f "$JG/theirs/plugins/shipkit/VERSION" ] || jg_fail="$jg_fail [d: a worktree judge.sh did not make was removed]"
# e. no tag: exit 2 and nothing run
mkdir -p "$JG/notag" && (cd "$JG/notag" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m one)
jg_calls=$(grep -c . "$JL/calls" 2>/dev/null)
(cd "$JG/notag" && PATH="$JG/bin:$PATH" sh "$JGS" refunds main --yes >/dev/null 2>&1); jg_rc=$?
[ "$jg_rc" -eq 2 ] && [ "$(grep -c . "$JL/calls" 2>/dev/null)" = "$jg_calls" ] || jg_fail="$jg_fail [e: no tag: exit $jg_rc]"
# f. CI runs the last tag's spec-check.sh on the tree, beside the branch's own
jg_job=$(awk '/^  lint:$/ { on = 1; next } on && /^  [a-z]/ { on = 0 } on' "$ROOT/.github/workflows/lint.yml")
printf '%s\n' "$jg_job" | grep -q '^        run: sh plugins/shipkit/scripts/spec-check\.sh \.$' \
  && printf '%s\n' "$jg_job" | grep -q 'git describe --tags --abbrev=0' \
  && printf '%s\n' "$jg_job" | grep -q 'git show "\$tag:plugins/shipkit/scripts/spec-check\.sh"' \
  || jg_fail="$jg_fail [f: lint.yml's lint job does not run the last tag's spec-check.sh beside the branch's]"
sh -n "$JGS" 2>/dev/null || jg_fail="$jg_fail [sh -n reports a syntax error]"
if [ -z "$jg_fail" ]; then pass "judge (without --yes the tag and command, nothing run; with --yes the plugin from a worktree of the last tag, removed after, also on failure; another worktree kept; no tag → exit 2; CI runs the tag's spec-check)"
else failc "judge" "$jg_fail"; fi

# 110. eval-ledger: an eval result is a row, not a paragraph. scripts/evals-ledger.sh appends
# one row per case from a run's aggregate-result.json to docs/design/eval-ledger.tsv (here a
# scratch ledger, through EVALS_LEDGER) and answers three queries over the release runs in it;
# scripts/evals.sh appends after its run and keeps traces. evals.sh runs a stand-in for claude
# here (EVALS_TOOL), so nothing is paid for. No claude needed.
# Cites: numbers-as-data/REQ-1 numbers-as-data/REQ-2 numbers-as-data/REQ-3 numbers-as-data/REQ-4
# numbers-as-data/REQ-5 numbers-as-data/REQ-6 numbers-as-data/REQ-7 numbers-as-data/REQ-8
# numbers-as-data/REQ-9 numbers-as-data/REQ-10 numbers-as-data/REQ-33
EL="$WORK/eledger"; ELS="$ROOT/scripts/evals-ledger.sh"; mkdir -p "$EL/out" "$EL/repo" "$EL/bin"; el_fail=""
el_result() {  # el_result <file> <startedAt> → a result file with a 3-run case and a 5-run case
  printf '%s\n' '{"schemaVersion":1,"claudeVersion":"2.1.400","startedAt":"'"$2"'","costUsd":0.85,' \
    '"suite":{"modelOverride":"sonnet","threshold":0.6,"plugins":[{"name":"shipkit","version":"9.9.9"}]},' \
    '"cases":[{"name":"alpha","runsPerCase":3,"arms":{"with":[{"passed":true,"costUsd":0.1},{"passed":false,"costUsd":0.2},{"passed":true,"costUsd":0.3}]}},' \
    '{"name":"beta","runsPerCase":5,"arms":{"with":[{"passed":true,"costUsd":0.05},{"passed":true,"costUsd":0.05},{"passed":true,"costUsd":0.05},{"passed":true,"costUsd":0.05},{"passed":true,"costUsd":0.05}]}}],' \
    '"aggregates":{"casesTotal":2}}' > "$1"
}
el_result "$EL/out/aggregate-result.json" 2026-12-01T10:00:00.000Z
TAB=$(printf '\t')
# a. append: one row per case, the fields of REQ-2, the summary line; a second append adds none
el_out=$(EVALS_LEDGER="$EL/l.tsv" sh "$ELS" append "$EL/out" --commit abc1234 2>&1)
[ "$el_out" = "evals-ledger: 2 row(s) added, 0 already held" ] || el_fail="$el_fail [a: first append said: $el_out]"
el_want="date${TAB}version${TAB}commit${TAB}claude${TAB}model${TAB}case${TAB}set${TAB}passed${TAB}runs${TAB}threshold${TAB}cost${TAB}source
2026-12-01${TAB}9.9.9${TAB}abc1234${TAB}2.1.400${TAB}sonnet${TAB}alpha${TAB}tune${TAB}2${TAB}3${TAB}0.6${TAB}0.60${TAB}run
2026-12-01${TAB}9.9.9${TAB}abc1234${TAB}2.1.400${TAB}sonnet${TAB}beta${TAB}watch${TAB}5${TAB}5${TAB}0.6${TAB}0.25${TAB}run"
[ "$(cat "$EL/l.tsv" 2>/dev/null)" = "$el_want" ] || el_fail="$el_fail [a: the ledger: $(tr '\t\n' ' |' < "$EL/l.tsv" 2>/dev/null)]"
el_out=$(EVALS_LEDGER="$EL/l.tsv" sh "$ELS" append "$EL/out" --commit abc1234 2>&1)
[ "$el_out" = "evals-ledger: 0 row(s) added, 2 already held" ] && [ "$(grep -c . "$EL/l.tsv")" = 3 ] \
  || el_fail="$el_fail [a: second append said: $el_out, $(grep -c . "$EL/l.tsv") lines]"
# b. no --commit: HEAD's short sha; --source is written as given
(cd "$EL/repo" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m one)
el_head=$(cd "$EL/repo" && git rev-parse --short HEAD)
(cd "$EL/repo" && EVALS_LEDGER="$EL/l.tsv" sh "$ELS" append "$EL/out" --source mine >/dev/null 2>&1)
[ "$(awk -F '\t' -v c="$el_head" '$3 == c && $12 == "mine"' "$EL/l.tsv" | grep -c .)" = 2 ] \
  || el_fail="$el_fail [b: rows with HEAD's commit $el_head and source mine: $(awk -F '\t' -v c="$el_head" '$3 == c' "$EL/l.tsv" | grep -c .)]"
# c. no result file: exit 1, a message, nothing added
mkdir -p "$EL/empty"; el_n=$(grep -c . "$EL/l.tsv")
EVALS_LEDGER="$EL/l.tsv" sh "$ELS" append "$EL/empty" >/dev/null 2>"$EL/err"; el_rc=$?
[ "$el_rc" -eq 1 ] && grep -q 'no result file' "$EL/err" && [ "$(grep -c . "$EL/l.tsv")" = "$el_n" ] \
  || el_fail="$el_fail [c: no result file: exit $el_rc]"
# d. the queries, on a seeded ledger: three release runs and a partial run between them
{ printf 'date\tversion\tcommit\tclaude\tmodel\tcase\tset\tpassed\truns\tthreshold\tcost\tsource\n'
  printf '2026-01-01\t1\tc1\t-\tsonnet\ta\ttune\t3\t3\t0.6\t1.00\trelease\n'
  printf '2026-01-01\t1\tc1\t-\tsonnet\tb\ttune\t2\t3\t0.6\t1.00\trelease\n'
  printf '2026-01-01\t1\tc1\t-\tsonnet\tc\ttune\t3\t3\t0.6\t1.00\trelease\n'
  printf '2026-02-01\t2\tc2\t-\tsonnet\ta\ttune\t2\t3\t0.6\t1.00\thistory\n'
  printf '2026-02-01\t2\tc2\t-\tsonnet\tb\ttune\t2\t3\t0.6\t-\thistory\n'
  printf '2026-02-15\t2\tc3\t-\tsonnet\ta\ttune\t0\t3\t0.6\t0.10\tpartial\n'
  printf '2026-03-01\t3\tc4\t-\tsonnet\ta\ttune\t2\t3\t0.6\t0.50\trelease\n'
  printf '2026-03-01\t3\tc4\t-\tsonnet\tb\ttune\t1\t3\t0.6\t0.50\trelease\n'
  printf '2026-03-01\t3\tc4\t-\tsonnet\tc\ttune\t3\t3\t0.6\t0.50\trelease\n'; } > "$EL/q.tsv"
elq() { EVALS_LEDGER="$EL/q.tsv" sh "$ELS" "$@" 2>&1 | tr '\n' '|'; }
[ "$(elq --below-full 2)" = "a|b|" ] || el_fail="$el_fail [d: --below-full 2: $(elq --below-full 2)]"
[ "$(elq --below-full 3)" = "b|" ] || el_fail="$el_fail [d: --below-full 3: $(elq --below-full 3)]"
[ "$(elq --below-full 5)" = "" ] || el_fail="$el_fail [d: --below-full 5 with three release runs: $(elq --below-full 5)]"
[ "$(elq --rate a)" = "a 7/9 over 3 run(s)|" ] || el_fail="$el_fail [d: --rate a: $(elq --rate a)]"
[ "$(elq --rate a --last 1)" = "a 2/3 over 1 run(s)|" ] || el_fail="$el_fail [d: --rate a --last 1: $(elq --rate a --last 1)]"
[ "$(elq --rate c --last 2)" = "c 3/3 over 1 run(s)|" ] || el_fail="$el_fail [d: --rate c --last 2: $(elq --rate c --last 2)]"
[ "$(elq --runs)" = "2026-01-01 c1 3 8/9 3.00|2026-02-01 c2 2 4/6 -|2026-03-01 c4 3 6/9 1.50|" ] || el_fail="$el_fail [d: --runs: $(elq --runs)]"
[ "$(elq --runs --last 1 --prefix b)" = "2026-03-01 c4 1 1/3 0.50|" ] || el_fail="$el_fail [d: --runs --last 1 --prefix b: $(elq --runs --last 1 --prefix b)]"
EVALS_LEDGER="$EL/q.tsv" sh "$ELS" --bogus >/dev/null 2>&1; [ $? -eq 2 ] || el_fail="$el_fail [d: an unknown argument is not exit 2]"
# e. evals.sh with a stand-in tool: traces kept, rows appended as release or partial, the tool's status
el_result "$EL/tmpl.json" @DATE@
cat > "$EL/bin/tool" <<STUB
#!/bin/sh
printf '%s\n' "\$*" > "$EL/args"
out=""; prev=""
for a in "\$@"; do [ "\$prev" = --output-dir ] && out=\$a; prev=\$a; done
if [ "\${STUB_WRITE:-1}" = 1 ]; then mkdir -p "\$out" && sed "s/@DATE@/\$STUB_DATE/" "$EL/tmpl.json" > "\$out/aggregate-result.json"; fi
exit \${STUB_EXIT:-0}
STUB
chmod +x "$EL/bin/tool"
el_evals() { EVALS_TOOL="$EL/bin/tool" EVALS_LEDGER="$EL/e.tsv" EVALS_OUT="$EL/eout" sh "$ROOT/scripts/evals.sh" "$@" >/dev/null 2>&1; }
STUB_DATE=2026-12-02T10:00:00Z STUB_EXIT=3 el_evals; el_rc=$?
[ "$el_rc" -eq 3 ] && grep -q -- '--keep-temp' "$EL/args" 2>/dev/null && [ "$(awk -F '\t' '$1 == "2026-12-02" && $12 == "release"' "$EL/e.tsv" 2>/dev/null | grep -c .)" = 2 ] \
  || el_fail="$el_fail [e: a full run: exit $el_rc, args $(cat "$EL/args" 2>/dev/null), release rows $(awk -F '\t' '$12 == "release"' "$EL/e.tsv" 2>/dev/null | grep -c .)]"
STUB_DATE=2026-12-03T10:00:00Z EVALS_KEEP=0 el_evals --group alpha; el_rc=$?
! grep -q -- '--keep-temp' "$EL/args" 2>/dev/null && [ "$(awk -F '\t' '$1 == "2026-12-03" && $12 == "partial"' "$EL/e.tsv" 2>/dev/null | grep -c .)" = 2 ] \
  || el_fail="$el_fail [e: EVALS_KEEP=0 --group: args $(cat "$EL/args" 2>/dev/null), partial rows $(awk -F '\t' '$12 == "partial"' "$EL/e.tsv" 2>/dev/null | grep -c .)]"
el_n=$(grep -c . "$EL/e.tsv" 2>/dev/null)
STUB_WRITE=0 STUB_EXIT=5 el_evals; el_rc=$?
[ "$el_rc" -eq 5 ] && [ "$(grep -c . "$EL/e.tsv" 2>/dev/null)" = "$el_n" ] \
  || el_fail="$el_fail [e: no result file written (an old one left in the folder): exit $el_rc, $(grep -c . "$EL/e.tsv" 2>/dev/null) lines, want $el_n]"
sh -n "$ELS" 2>/dev/null && sh -n "$ROOT/scripts/evals.sh" 2>/dev/null || el_fail="$el_fail [sh -n reports a syntax error]"
if [ -z "$el_fail" ]; then pass "eval-ledger (append writes a row per case, once; three queries read release runs only; evals.sh keeps traces, appends release or partial rows, and exits with the tool's status, with or without a result file)"
else failc "eval-ledger" "$el_fail"; fi

# 111. ledger-backfill: the ledger starts with two release runs, so the flake rule has two runs
# to read from the first day. 5.2.0's 65 rows come from its kept result file (source
# result-file); 5.1.0's from eval-history.md's "Release run 5.1.0" and the tree at 073938c
# (source history), and must add up to the page's 65 cases and 227 runs, with exactly its three
# cases at 2 of 3. Read from the repository's ledger. No claude needed.
# Cites: numbers-as-data/REQ-11 numbers-as-data/REQ-12
LB="$ROOT/docs/design/eval-ledger.tsv"; lb_fail=""
[ -f "$LB" ] || lb_fail="$lb_fail [no docs/design/eval-ledger.tsv]"
lb_52=$(awk -F '\t' '$2 == "5.2.0" && $3 == "4e2afc2" && $12 == "result-file"' "$LB" 2>/dev/null | grep -c .)
[ "$lb_52" = 65 ] || lb_fail="$lb_fail [5.2.0 result-file rows: $lb_52, want 65]"
lb_51=$(awk -F '\t' '$12 == "history" && $1 == "2026-11-04" && $2 == "5.1.0" && $3 == "073938c" && $4 == "2.1.318" && $5 == "sonnet" && $10 == "0.6" && $11 == "-"' "$LB" 2>/dev/null)
lb_n=$(printf '%s\n' "$lb_51" | grep -c .); lb_runs=$(printf '%s\n' "$lb_51" | awk -F '\t' '{ s += $9 } END { print s + 0 }')
lb_below=$(printf '%s\n' "$lb_51" | awk -F '\t' '$8 != $9 { print $6 " " $8 "/" $9 }' | sort | tr '\n' '|')
[ "$lb_n" = 65 ] && [ "$lb_runs" = 227 ] && [ "$lb_below" = "grandfather-xl-drift 2/3|hello 2/3|intake-limit 2/3|" ] \
  && [ "$(awk -F '\t' '$12 == "history"' "$LB" 2>/dev/null | grep -c .)" = 65 ] \
  || lb_fail="$lb_fail [5.1.0 history rows: $lb_n with the fixed fields, $lb_runs runs, below full: $lb_below]"
lb_q=$(sh "$ROOT/scripts/evals-ledger.sh" --below-full 2 2>&1 | tr '\n' '|')
[ "$lb_q" = "hello|" ] || lb_fail="$lb_fail [--below-full 2 on the ledger: $lb_q]"
if [ -z "$lb_fail" ]; then pass "ledger-backfill (5.2.0: 65 rows from its result file; 5.1.0: 65 cases and 227 runs from its page and 073938c, three at 2 of 3; below full in both: hello)"
else failc "ledger-backfill" "$lb_fail"; fi

# 112. briefing-cost: the briefing starts fewer processes, and spec-check.sh says exactly what
# it said before. The briefing runs spec-check.sh at every session start for one number, and on
# fifty open specs that cost 0.82 s of CPU here and up to 1.53 s on CI's runner, against check
# 30's one second. This check holds spec-check.sh to the script at 398d1c9 (taken with git
# show), line for line and exit for exit, on check 30's fixture, on a fixture with every kind
# of line spec-check prints, and on this repository, for the whole project and for one spec,
# with --as-open and --as-shipped; reads the briefing's gap line against spec-check's count;
# and times the briefing on fifty specs against half a second of CPU, best of three. That limit
# is the owner's machine's (REQ-16): on CI (CI=true), where the runner read 0.77 s on the first
# run without the switch, and under SMOKE_TIMING=report, the time is printed and not failed.
# Check 30's one second is still held on CI. No claude needed.
# Cites: numbers-as-data/REQ-15 numbers-as-data/REQ-16 numbers-as-data/REQ-17
BK="$WORK/bcost"; mkdir -p "$BK"; bk_fail=""
git -C "$ROOT" show 398d1c9:plugins/shipkit/scripts/spec-check.sh > "$BK/old.sh" 2>/dev/null || bk_fail="$bk_fail [git show 398d1c9 failed]"
BKN="$COPY/scripts/spec-check.sh"
bk_same() {  # bk_same <project> <label> [args…] → both scripts, same lines and exit
  _p=$1; _l=$2; shift 2
  (cd "$_p" && sh "$BK/old.sh" . "$@") > "$BK/o.out" 2>&1; _o=$?
  (cd "$_p" && sh "$BKN" . "$@") > "$BK/n.out" 2>&1; _n=$?
  if [ "$_o" -ne "$_n" ] || ! cmp -s "$BK/o.out" "$BK/n.out"; then
    bk_fail="$bk_fail [$_l $*: exit $_o then $_n; first difference: $(diff "$BK/o.out" "$BK/n.out" | sed -n '2,3p' | tr '\n' '|' | cut -c1-200)]"
  fi
}
# a. check 30's fixture: fifty open specs
BK50="$BK/fifty"; mkdir -p "$BK50"; (cd "$BK50" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
i=1; while [ "$i" -le 50 ]; do bspec "$BK50" "spec-$i-with-a-rather-long-name-to-fill-the-line" open 1 4; i=$((i + 1)); done
bk_same "$BK50" fifty
bk_same "$BK50" fifty spec-7-with-a-rather-long-name-to-fill-the-line
# b. every kind of line: missing task, missing field, a bad After, a conflict, a cycle, a stray
# Status, a waiver, a pending and a missing test, a draft and a dropped spec, a spec with no
# Status line, a Tests line with a citation elsewhere, a citation beside a skip marker
BKG="$BK/gaps"; mkdir -p "$BKG/t" "$BKG/x"; (cd "$BKG" && git init -q)
bkspec() {  # bkspec <slug> <status|none> <extra spec lines> <tasks text>
  mkdir -p "$BKG/.shipkit/specs/$1"
  { printf '# Spec: %s\n\n' "$1"; [ "$2" = none ] || printf '> Status: %s\n' "$2"; printf '%b' "$3"
    printf '\n- **REQ-1.** It shall one.\n- **REQ-2.** It shall two. [untested: prose]\n- **REQ-3.** It shall three.\n'; } > "$BKG/.shipkit/specs/$1/spec.md"
  printf '%b' "$4" > "$BKG/.shipkit/specs/$1/tasks.md"
}
BKT='- [x] **T1** One → REQ-1, REQ-2\n  - Files: a.py\n  - Test: t\n  - After: none\n  - Done when: x\n- [ ] **T2** Three → REQ-3\n  - Files: a.py\n  - Test: t\n  - After: T1\n  - Done when: x\n'
bkspec alpha open '' "$BKT"
bkspec beta open '' '- [ ] **T1** One → REQ-1\n  - Files: a.py\n  - After: T9\n  - Done when: x\n- [ ] **T2** Two → REQ-2\n  - Files: a.py\n  - Test: t\n  - After: T3\n  - Done when: x\n- [ ] **T3** Three → REQ-2\n  - Files: b.py\n  - Test: t\n  - After: T2\n  - Done when: x\n'
bkspec gamma shipped '> Paths: x/\n> Tests: t/\n' "$BKT"
bkspec delta draft '' "$BKT"; bkspec epsilon dropped '' "$BKT"; bkspec zeta none '' "$BKT"
printf '> Status: open\n' >> "$BKG/.shipkit/specs/alpha/tasks.md"
printf '# Design\n\n> Status: open\n' > "$BKG/.shipkit/specs/beta/design.md"
bkspec eta Shipped '' "$BKT"   # a Status word spec-check does not know: read as open, the line is there
printf '# alpha/REQ-1 gamma/REQ-1\n' > "$BKG/x/elsewhere.py"
printf 'it.skip("x", () => {\n  // gamma/REQ-3\n})\n' > "$BKG/t/skip.test.js"
(cd "$BKG" && git add -A && git -c user.email=s@s -c user.name=s commit -q -m fixture)
bk_same "$BKG" gaps
bk_same "$BKG" gaps --as-open
bk_same "$BKG" gaps beta
bk_same "$BKG" gaps gamma --as-shipped
bk_same "$BKG" gaps delta --as-open
bk_same "$BKG" gaps nosuch
mkdir -p "$BK/with space" && cp -R "$BKG" "$BK/with space/gaps"
bk_same "$BK/with space/gaps" 'a path with a space'
# c. this repository
bk_same "$ROOT" repo
bk_same "$ROOT" repo numbers-as-data --as-shipped
# d. the briefing's gap line is spec-check's count
bk_g=$(cd "$BKG" && sh "$BKN" . 2>/dev/null | sed -n 's/^spec-check: .* checked, \([0-9]*\) gap(s)$/\1/p')
bk_b=$(cd "$BKG" && sh "$COPY/scripts/briefing.sh" 2>/dev/null | grep 'spec-check:')
[ -n "$bk_g" ] && [ "$bk_g" -gt 0 ] && [ "$bk_b" = "shipkit: spec-check: $bk_g gap(s) — run spec-check.sh" ] \
  || bk_fail="$bk_fail [d: spec-check counts '$bk_g', the briefing printed '$bk_b']"
[ -z "$(cd "$BK50" && sh "$COPY/scripts/briefing.sh" 2>/dev/null | grep 'spec-check:')" ] || bk_fail="$bk_fail [d: a gap line on fifty specs with no gap]"
bk_verdict() {  # bk_verdict <fail text> <cpu seconds> → check 112's one PASS or FAIL line
  if [ -z "$1" ] && [ "$(awk -v t="$2" 'BEGIN { print (t + 0 > 0.5) ? 1 : 0 }')" -eq 0 ]; then
    pass "briefing-cost (spec-check.sh prints what it printed at 398d1c9 on fifty specs, every kind of line and this repository; the briefing's gap line is its count; fifty specs in ${2}s of CPU, best of 3)"
  elif [ -z "$1" ] && { [ "${CI:-}" = true ] || [ "${SMOKE_TIMING:-}" = report ]; }; then
    pass "briefing-cost (output unchanged, gap line matches; fifty specs in ${2}s of CPU, best of 3, over 0.5 s: reported, not enforced, the limit is the owner's machine's (REQ-16) and this is CI or SMOKE_TIMING=report)"
  else failc "briefing-cost" "$1 [fifty specs: ${2}s of CPU, best of 3, want ≤ 0.5]"; fi
}
# f. the verdict on given numbers, in a subshell so its lines are read and not counted: the
# half second is the owner's machine's (REQ-16), so on CI (CI=true) a slower time is printed
# and not failed; a changed output fails everywhere
bk_v() { ( COUNTS=/dev/null; CI=$1; SMOKE_TIMING=""; bk_verdict "$2" "$3" ); }  # bk_v <CI> <fail text> <seconds>
case "$(bk_v true "" 0.77)" in "PASS  briefing-cost"*"0.77s of CPU"*"not enforced"*) ;; *) bk_fail="$bk_fail [f: CI, 0.77 s: not a PASS that says not enforced]" ;; esac
case "$(bk_v "" "" 0.77)" in "FAIL  briefing-cost"*) ;; *) bk_fail="$bk_fail [f: no CI, 0.77 s: not a FAIL]" ;; esac
case "$(bk_v true "[x]" 0.30)" in "FAIL  briefing-cost"*) ;; *) bk_fail="$bk_fail [f: CI, a changed output: not a FAIL]" ;; esac
case "$(bk_v "" "" 0.30)" in *"not enforced"*) bk_fail="$bk_fail [f: no CI, 0.30 s is called not enforced]" ;; "PASS  briefing-cost"*) ;; *) bk_fail="$bk_fail [f: no CI, 0.30 s: not a PASS]" ;; esac
# e. the briefing on fifty specs, best of three, against half a second of CPU
bk_t=9; bk_i=0
while [ "$bk_i" -lt 3 ]; do
  bk_i=$((bk_i + 1))
  bk_one=$(python3 -c "import os,subprocess; a=os.times(); subprocess.run(['sh','$COPY/scripts/briefing.sh'],cwd='$BK50',stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL); b=os.times(); print(round((b.children_user-a.children_user)+(b.children_system-a.children_system),2))")
  bk_t=$(awk -v a="$bk_t" -v b="$bk_one" 'BEGIN { print (b + 0 < a + 0) ? b : a }')
done
bk_verdict "$bk_fail" "$bk_t"

# 113. evals-for-diff: the cases a change needs are chosen by the change. scripts/evals-map.tsv
# names, for each eval case, the plugin paths whose text reaches it; scripts/evals-for-diff.sh
# reads `git diff --name-only <base>...HEAD` against it, and `evals.sh --for-diff <base>` runs
# what it picks. Here the diffs are made in a scratch repository and the map is this one's;
# evals.sh runs a stand-in for claude. Lint's check 19 holds the map to the case folders, on a
# copy of this tree. No claude needed.
# Cites: numbers-as-data/REQ-19 numbers-as-data/REQ-20 numbers-as-data/REQ-21
# numbers-as-data/REQ-22 numbers-as-data/REQ-23 numbers-as-data/REQ-24 numbers-as-data/REQ-25
# misses-to-checks/REQ-18
FD="$WORK/fordiff"; FDS="$ROOT/scripts/evals-for-diff.sh"; mkdir -p "$FD/repo" "$FD/bin"; fd_fail=""
fdg() { (cd "$FD/repo" && git -c user.email=s@s -c user.name=s "$@"); }
(cd "$FD/repo" && git init -q && mkdir -p plugins/shipkit/agents plugins/shipkit/rules plugins/shipkit/scripts docs \
  && echo a > plugins/shipkit/agents/reviewer.md && echo a > plugins/shipkit/rules/shipkit.md \
  && echo a > plugins/shipkit/scripts/session-start.sh && echo a > docs/x.md)
fdg add -A; fdg commit -q -m base; fdg tag base
fd_case() {  # fd_case <branch> <file> → the cases evals-for-diff.sh prints for a diff touching only <file>
  fdg checkout -q -b "$1" base; echo b >> "$FD/repo/$2"; fdg commit -q -am "$1"
  (cd "$FD/repo" && sh "$FDS" base 2>"$FD/err"); echo "exit=$?"; cat "$FD/err"
}
# The reviewer's cases are read from the map: Sprint 32 adds to the four of Sprint 31
# (misses-to-checks/REQ-18 holds their number), and a held-out case is never named reviewer-*.
fd_rev=$(awk -F '\t' 'NR > 1 && $1 ~ /^reviewer-/ { print $1 }' "$ROOT/scripts/evals-map.tsv" | sort | tr '\n' ' ')
fd_held=$(awk -F '\t' 'NR > 1 && $2 == "holdout" && index("," $3 ",", ",plugins/shipkit/agents/reviewer.md,")' "$ROOT/scripts/evals-map.tsv" | grep -c .)
fd_said=""; [ "$fd_held" -eq 0 ] || fd_said="evals-for-diff: $fd_held held-out case(s) not listed "
fd_out=$(fd_case rev plugins/shipkit/agents/reviewer.md | tr '\n' ' ')
[ -n "$fd_rev" ] && [ "$fd_out" = "${fd_rev}exit=0 $fd_said" ] || fd_fail="$fd_fail [a diff on reviewer.md: $fd_out; the map's reviewer rows: $fd_rev; held out: $fd_held]"
[ "$(printf '%s' "$fd_rev" | wc -w | tr -d ' ')" = 12 ] || fd_fail="$fd_fail [the map names $(printf '%s' "$fd_rev" | wc -w | tr -d ' ') reviewer-* cases, and misses-to-checks/REQ-18 says twelve]"
for fd_old in reviewer-all-met reviewer-decision-unbuilt reviewer-missing-req reviewer-rejected-alternative; do
  case " $fd_out" in *" $fd_old "*) ;; *) fd_fail="$fd_fail [a diff on reviewer.md does not print $fd_old]" ;; esac
done
fd_always="hello rules-care rules-decision rules-nontrivial rules-trivial exit=0 "
fd_out=$(fd_case rul plugins/shipkit/rules/shipkit.md | tr '\n' ' ')
[ "$fd_out" = "$fd_always" ] || fd_fail="$fd_fail [a diff on rules/shipkit.md: $fd_out]"
fd_out=$(fd_case hook plugins/shipkit/scripts/session-start.sh | tr '\n' ' ')
[ "$fd_out" = "$fd_always" ] || fd_fail="$fd_fail [a diff on session-start.sh: $fd_out]"
fd_out=$(fd_case doc docs/x.md | tr '\n' ' ')
[ "$fd_out" = "exit=0 " ] || fd_fail="$fd_fail [a diff under docs/: $fd_out]"
# evals.sh --for-diff: one --case for each case picked, marked partial; none picked, nothing run
printf '#!/bin/sh\nprintf "%%s\\n" "$*" > "%s"\nexit 0\n' "$FD/args" > "$FD/bin/tool"; chmod +x "$FD/bin/tool"
fdg checkout -q rev
(cd "$FD/repo" && EVALS_TOOL="$FD/bin/tool" EVALS_LEDGER="$FD/l.tsv" EVALS_OUT="$FD/out" sh "$ROOT/scripts/evals.sh" --for-diff base >/dev/null 2>&1); fd_rc=$?
fd_cases=$(tr ' ' '\n' < "$FD/args" 2>/dev/null | grep -A1 -x -- '--case' | grep -v -x -- '--case' | grep -v -x -- '--' | tr '\n' ' ')
[ "$fd_rc" -eq 0 ] && [ "$fd_cases" = "$fd_rev" ] \
  || fd_fail="$fd_fail [evals.sh --for-diff on reviewer.md: exit $fd_rc, cases $fd_cases]"
# one more reviewer row, in a scratch map, is printed with the rest: the list is the map's
{ cat "$ROOT/scripts/evals-map.tsv"; printf 'reviewer-zz-extra\ttune\tplugins/shipkit/agents/reviewer.md\n'; } > "$FD/map.tsv"
fd_out=$(cd "$FD/repo" && EVALS_MAP="$FD/map.tsv" sh "$FDS" base 2>/dev/null | tr '\n' ' ')
[ "$fd_out" = "${fd_rev}reviewer-zz-extra " ] || fd_fail="$fd_fail [a scratch map with one more reviewer row: $fd_out]"
rm -f "$FD/args"; fdg checkout -q doc
fd_msg=$(cd "$FD/repo" && EVALS_TOOL="$FD/bin/tool" EVALS_LEDGER="$FD/l.tsv" EVALS_OUT="$FD/out" sh "$ROOT/scripts/evals.sh" --for-diff base 2>&1); fd_rc=$?
[ "$fd_rc" -eq 0 ] && [ ! -e "$FD/args" ] && [ "$fd_msg" = "evals: no case reads the files this diff changed" ] \
  || fd_fail="$fd_fail [evals.sh --for-diff under docs/: exit $fd_rc, said '$fd_msg', tool run: $([ -e "$FD/args" ] && echo yes || echo no)]"
# lint: the map against the case folders, on a copy of this tree
FL="$WORK/fordiff-lint"; mkdir -p "$FL"
if command -v rsync >/dev/null 2>&1; then rsync -a --exclude /.git --exclude /.claude "$ROOT/" "$FL/"
else (cd "$ROOT" && tar cf - --exclude ./.git --exclude ./.claude .) | (cd "$FL" && tar xf -); fi
fd_clean=$(python3 "$FL/scripts/lint.py" 2>&1 | tail -1)
case "$fd_clean" in *" 0 error(s)"*) ;; *) fd_fail="$fd_fail [lint on the clean copy: $fd_clean]";; esac
awk -F '\t' -v OFS='\t' '$1 == "hello" { next } $1 == "intake-limit" { $3 = $3 ",plugins/shipkit/skills/nosuch/" } { print } END { print "nosuch-case", "tune", "plugins/shipkit/rules/shipkit.md" }' \
  "$FL/scripts/evals-map.tsv" > "$FL/m.tmp" && mv "$FL/m.tmp" "$FL/scripts/evals-map.tsv"
fd_lint=$(python3 "$FL/scripts/lint.py" 2>&1)
printf '%s\n' "$fd_lint" | grep -q 'evals-map.tsv.*no row for the eval case hello' \
  && printf '%s\n' "$fd_lint" | grep -q 'evals-map.tsv.*nosuch-case.*names no eval case' \
  && printf '%s\n' "$fd_lint" | grep -q 'evals-map.tsv.*intake-limit.*plugins/shipkit/skills/nosuch/.*does not exist' \
  && [ "$(printf '%s\n' "$fd_lint" | tail -1 | sed -n 's/^lint: \([0-9]*\) error.*/\1/p')" = 3 ] \
  || fd_fail="$fd_fail [lint on the doctored copy: $(printf '%s' "$fd_lint" | grep -E 'evals-map|^lint:' | tr '\n' '|' | cut -c1-300)]"
sh -n "$FDS" 2>/dev/null || fd_fail="$fd_fail [sh -n reports a syntax error]"
if [ -z "$fd_fail" ]; then pass "evals-for-diff (reviewer.md → the $(printf '%s' "$fd_rev" | wc -w | tr -d ' ') cases the map names reviewer-*, and one more from a scratch map; rules/shipkit.md or the hook → the rules cases and hello; docs/ → none; evals.sh --for-diff runs those, or nothing; lint holds the map to the cases)"
else failc "evals-for-diff" "$fd_fail"; fi

# 114. eval-room: room for new cases without a raise of the ceiling. The evals README's case
# table and its section on lib/with-rule.sh moved, word for word, to docs/design/eval-cases.md,
# as earlier sprints moved readings to eval-history.md; the README keeps its "## Cases" heading,
# which checks 54 and 57 read up to, with one line naming the new file. The folder is measured
# as lint's check 17 measures it: the sum of its files' sizes. The moved text is compared with
# the README at 398d1c9. No claude needed. (Decision 0005 stands: the evals stay in the plugin.)
# Cites: numbers-as-data/REQ-26 numbers-as-data/REQ-27
ER="$WORK/evroom"; mkdir -p "$ER"; er_fail=""; ERC="$ROOT/docs/design/eval-cases.md"
git -C "$ROOT" show 398d1c9:plugins/shipkit/evals/README.md > "$ER/old.md" 2>/dev/null || er_fail="$er_fail [git show 398d1c9 failed]"
sed -n '/^### A rule under test is installed by `lib\/with-rule.sh`/,/^### Path-scoped loading, measured/p' "$ER/old.md" | sed '$d' > "$ER/withrule.md"
sed -n '/^## Cases$/,/^## The cuts (4.8.0)$/p' "$ER/old.md" | sed '1d;$d' > "$ER/cases.md"
[ "$(grep -c . "$ER/withrule.md")" -gt 10 ] && [ "$(grep -c . "$ER/cases.md")" -gt 40 ] || er_fail="$er_fail [the two sections were not found at 398d1c9]"
python3 - "$ERC" "$ER/withrule.md" "$ER/cases.md" > "$ER/py.out" 2>&1 <<'PY' || er_fail="$er_fail [$(cat "$ER/py.out")]"
import sys
doc = open(sys.argv[1]).read() if __import__("os").path.exists(sys.argv[1]) else ""
for name, path in (("the with-rule.sh section", sys.argv[2]), ("the case table", sys.argv[3])):
    block = open(path).read().strip("\n")
    i = doc.find(block)
    if i < 0:
        print(f"{name} is not in eval-cases.md word for word"); sys.exit(1)
    before = doc[:i].rstrip("\n").splitlines()
    if not any(l.startswith("*Moved 2026-11-18") for l in before[-3:]):
        print(f"{name} has no dated *Moved …* line above it"); sys.exit(1)
PY
er_now="$COPY/evals/README.md"
er_under=$(sed -n '/^## Cases$/,/^## /p' "$er_now" | sed '1d;$d' | grep -v '^[[:space:]]*$')
[ "$(printf '%s\n' "$er_under" | grep -c .)" = 1 ] && printf '%s\n' "$er_under" | grep -q 'docs/design/eval-cases\.md' \
  || er_fail="$er_fail [under ## Cases the README has: $(printf '%s' "$er_under" | head -3 | tr '\n' '|' | cut -c1-200)]"
grep -q '^### A rule under test is installed by' "$er_now" && er_fail="$er_fail [the with-rule.sh section is still in the README]"
# Sprint 32 moved one more section, "What graders can check", the same way (misses-to-checks T5):
# it is in eval-cases.md word for word as the README had it at 9e061ca, under a dated line. The
# README keeps the heading with its two answers, which measure-and-slim/REQ-4 asks it to state,
# and names the file.
git -C "$ROOT" show 9e061ca:plugins/shipkit/evals/README.md 2>/dev/null \
  | sed -n '/^## What graders can check$/,/^## How a case gets the fixture$/p' | sed '$d' > "$ER/graders.md"
[ "$(grep -c . "$ER/graders.md")" -gt 20 ] || er_fail="$er_fail [the section What graders can check was not found at 9e061ca]"
python3 - "$ERC" "$ER/graders.md" > "$ER/py2.out" 2>&1 <<'PY' || er_fail="$er_fail [$(cat "$ER/py2.out")]"
import sys
doc = open(sys.argv[1]).read()
block = open(sys.argv[2]).read().strip("\n")
i = doc.find(block)
if i < 0:
    print("the section What graders can check is not in eval-cases.md word for word"); sys.exit(1)
if not any(l.startswith("*Moved 2026-11-19") for l in doc[:i].rstrip("\n").splitlines()[-4:]):
    print("the section What graders can check has no dated *Moved …* line above it"); sys.exit(1)
PY
er_g=$(sed -n '/^## What graders can check$/,/^## How a case gets the fixture$/p' "$er_now" | sed '1d;$d')
printf '%s\n' "$er_g" | grep -q 'docs/design/eval-cases\.md' && printf '%s\n' "$er_g" | grep -q '(a) Which tools were called — yes' \
  && printf '%s\n' "$er_g" | grep -q '(b) A file the run wrote — yes' && [ "$(printf '%s\n' "$er_g" | grep -c .)" -le 5 ] \
  || er_fail="$er_fail [under What graders can check the README has: $(printf '%s' "$er_g" | head -3 | tr '\n' '|' | cut -c1-200)]"
grep -q 'No custom-code graders' "$er_now" && er_fail="$er_fail [the limits of What graders can check are still in the README]"
er_bytes=$(python3 -c "import pathlib,sys; print(sum(p.stat().st_size for p in pathlib.Path(sys.argv[1]).rglob('*') if p.is_file()))" "$ROOT/plugins/shipkit/evals")
# The room Sprint 31 made (the folder at most 190,800 bytes) is what Sprint 32's cases use. From
# misses-to-checks T1 the folder is held where lint's check 17 holds it, at 204,800 bytes
# (numbers-as-data/REQ-27, amended 2026-11-19).
er_room() { [ "$1" -le 204800 ]; }
er_room "$er_bytes" || er_fail="$er_fail [the evals folder is $er_bytes bytes, want at most 204,800]"
er_room 190801 && er_room 204800 && ! er_room 204801 || er_fail="$er_fail [the limit is not 204,800: 190,801 and 204,800 must pass, and 204,801 fail]"
if [ -z "$er_fail" ]; then pass "eval-room (the case table, the with-rule.sh section and What graders can check are in docs/design/eval-cases.md word for word under dated lines; the README keeps ## Cases with one line and its two answers on graders; the evals folder is $er_bytes of 204800 bytes)"
else failc "eval-room" "$er_fail"; fi

# 115. ledger-fired-if: a reversal condition about an eval count is a command. Eleven records
# (numbers-as-data/design.md, the table) carry a Fired-if command that reads the ledger. On
# this repository each reads HOLDS. On a scratch copy whose ledger is seeded past every clause
# each reads FIRED, and on one whose ledger cannot be read each reads ERROR, never HOLDS. No
# claude needed. Cites: numbers-as-data/REQ-29 numbers-as-data/REQ-30
LF="$WORK/lfired"; mkdir -p "$LF"; lf_fail=""
lf_recs=".shipkit/decisions/0002-spec-first-eval.md|.shipkit/specs/always-on/design.md (The Care lines move only by their number)|.shipkit/specs/decisions-bind/design.md (A contradicted decision fails through the reviewer's verdict)|.shipkit/specs/graders-and-eve/design.md (The release run accepts a fifty-ninth case)|.shipkit/specs/measured-cuts/design.md (The intake's assumption names its file; the four-question ceiling counts parts)|.shipkit/specs/overlays-and-eve/design.md (\`eve.md\` ships at the measured size, not the audit's estimate)|.shipkit/specs/portfolio-run/design.md (The release run grows to 58 cases, every case every release)|.shipkit/specs/rule-evals/design.md (One case per rule file, eighteen of them)|.shipkit/specs/rule-evals/design.md (\`--group\` exists; the release run still runs everything)|.shipkit/specs/rule-evals/design.md (The stopping rule for \`rules/nontrivial\`)|.shipkit/specs/second-traps/design.md (The Gemfile line is reworded on the 4.2.0 measurement)"
lf_read() {  # lf_read <project> <word> → each of the eleven read as <word>, or a note of the first that did not
  sh "$COPY/scripts/decision-check.sh" "$1" --run > "$LF/dc.out" 2>&1
  printf '%s\n' "$lf_recs" | tr '|' '\n' | while IFS= read -r r; do
    grep -q -F "$2 $r:" "$LF/dc.out" 2>/dev/null || grep -q -F "$2  $r:" "$LF/dc.out" 2>/dev/null || grep -q -F "$2 $r (" "$LF/dc.out" 2>/dev/null || { echo "$r"; break; }
  done
}
lf_miss=$(lf_read "$ROOT" HOLDS)
[ -z "$lf_miss" ] || lf_fail="$lf_fail [this repository: not HOLDS: $lf_miss — $(grep -F "$(printf '%s' "$lf_miss" | cut -c1-40)" "$LF/dc.out" | head -1 | cut -c1-160)]"
grep -q '^ERROR' "$LF/dc.out" && lf_fail="$lf_fail [this repository: an ERROR line: $(grep '^ERROR' "$LF/dc.out" | head -1 | cut -c1-160)]"
# a copy with the records, the ledger script and a ledger seeded past every clause
LFC="$LF/copy"; mkdir -p "$LFC/scripts" "$LFC/docs/design"
cp -R "$ROOT/.shipkit" "$LFC/.shipkit"; cp "$ROOT/scripts/evals-ledger.sh" "$LFC/scripts/"
{ printf 'date\tversion\tcommit\tclaude\tmodel\tcase\tset\tpassed\truns\tthreshold\tcost\tsource\n'
  for r in 2026-01-01:z 2026-02-01:a 2026-03-01:b; do d=${r%%:*}; c=${r#*:}
    printf '%s\t9\t%s\t-\tsonnet\trules-nontrivial\ttune\t0\t3\t0.6\t0.10\trelease\n' "$d" "$c"
  done
  for k in rules-care:1:3:0.10 reviewer-decision-unbuilt:2:3:0.10 intake-limit:1:3:0.10 eve-x:3:3:1.00 scoped-x:3:3:11.00 stacks-gemfile:1:3:0.10 big:3:3:30.00; do
    IFS=: read -r n p r c <<LFEOF
$k
LFEOF
    printf '2026-03-01\t9\tb\t-\tsonnet\t%s\ttune\t%s\t%s\t0.6\t%s\trelease\n' "$n" "$p" "$r" "$c"
  done; } > "$LFC/docs/design/eval-ledger.tsv"
lf_miss=$(lf_read "$LFC" FIRED)
[ -z "$lf_miss" ] || lf_fail="$lf_fail [seeded past every clause: not FIRED: $lf_miss — $(grep -F "$(printf '%s' "$lf_miss" | cut -c1-40)" "$LF/dc.out" | head -1 | cut -c1-200)]"
chmod 000 "$LFC/docs/design/eval-ledger.tsv"
lf_miss=$(lf_read "$LFC" ERROR)
chmod 644 "$LFC/docs/design/eval-ledger.tsv"
[ -z "$lf_miss" ] || lf_fail="$lf_fail [an unreadable ledger: not ERROR: $lf_miss — $(grep -F "$(printf '%s' "$lf_miss" | cut -c1-40)" "$LF/dc.out" | head -1 | cut -c1-200)]"
if [ -z "$lf_fail" ]; then pass "ledger-fired-if (eleven reversal conditions read the ledger: HOLDS here, FIRED on a ledger past each clause, ERROR on one that cannot be read)"
else failc "ledger-fired-if" "$lf_fail"; fi

# 116. holdout-kept-out: a held-out case stays held out. The verifier plan's rule 31 lets one
# run at a release run or on the owner's word, and until Sprint 32 the map's set was a word
# nothing read. Lint takes only tune, watch and holdout there and ties `holdout` to the folder
# evals/holdout/, whose cases are named holdout-*, so no group's pattern meets them;
# scripts/evals-for-diff.sh leaves a held-out case out and says how many on standard error;
# scripts/evals-ledger.sh writes the set from the map. Lint runs on a copy of this tree, the
# other two on a scratch map (EVALS_MAP). No claude needed.
# Cites: misses-to-checks/REQ-15 misses-to-checks/REQ-16 misses-to-checks/REQ-17
# misses-to-checks/REQ-19
HK="$WORK/holdout"; HKL="$HK/tree"; mkdir -p "$HK/repo" "$HK/out" "$HKL"; hk_fail=""
# a. lint, on a copy of this tree that holds one held-out case
if command -v rsync >/dev/null 2>&1; then rsync -a --exclude /.git --exclude /.claude "$ROOT/" "$HKL/"
else (cd "$ROOT" && tar cf - --exclude ./.git --exclude ./.claude .) | (cd "$HKL" && tar xf -); fi
mkdir -p "$HKL/plugins/shipkit/evals/holdout/demo-held"
printf 'A held-out case that exists only in this copy.\n' > "$HKL/plugins/shipkit/evals/holdout/demo-held/prompt.md"
cp "$HKL/scripts/evals-map.tsv" "$HK/map.orig"
hk_lint() {  # hk_lint <set of the demo case> <awk rule for the other rows> → lint's output on the copy
  awk -F '\t' -v OFS='\t' -v s="$1" "$2"' { print } END { print "holdout-demo-held", s, "plugins/shipkit/evals/holdout/demo-held/" }' \
    "$HK/map.orig" > "$HKL/scripts/evals-map.tsv"
  python3 "$HKL/scripts/lint.py" 2>&1
}
hk_n() { printf '%s\n' "$1" | tail -1 | sed -n 's/^lint: \([0-9]*\) error.*/\1/p'; }
hk_out=$(hk_lint holdout '')
[ "$(hk_n "$hk_out")" = 0 ] || hk_fail="$hk_fail [a: a held-out case in evals/holdout/ with the set holdout: $(printf '%s' "$hk_out" | grep -E 'evals-map|holdout|^lint:' | tr '\n' '|' | cut -c1-300)]"
hk_out=$(hk_lint holdout '$1 == "hello" { $2 = "foo" }')
[ "$(hk_n "$hk_out")" = 1 ] && printf '%s\n' "$hk_out" | grep -q 'evals-map.tsv.*hello.*foo' \
  || hk_fail="$hk_fail [a: the set foo on hello's row: $(printf '%s' "$hk_out" | grep -E 'evals-map|^lint:' | tr '\n' '|' | cut -c1-300)]"
hk_out=$(hk_lint tune '')
[ "$(hk_n "$hk_out")" = 1 ] && printf '%s\n' "$hk_out" | grep -q 'evals-map.tsv.*holdout-demo-held.*evals/holdout/' \
  || hk_fail="$hk_fail [a: a case under evals/holdout/ with the set tune: $(printf '%s' "$hk_out" | grep -E 'evals-map|^lint:' | tr '\n' '|' | cut -c1-300)]"
hk_out=$(hk_lint holdout '$1 == "hello" { $2 = "holdout" }')
[ "$(hk_n "$hk_out")" = 1 ] && printf '%s\n' "$hk_out" | grep -q 'evals-map.tsv.*hello.*evals/holdout/' \
  || hk_fail="$hk_fail [a: the set holdout on hello, which is not under evals/holdout/: $(printf '%s' "$hk_out" | grep -E 'evals-map|^lint:' | tr '\n' '|' | cut -c1-300)]"
# b. evals-for-diff.sh: a held-out row that the diff meets is not printed, and is counted aloud
hkg() { (cd "$HK/repo" && git -c user.email=s@s -c user.name=s "$@"); }
(cd "$HK/repo" && git init -q && mkdir -p plugins/shipkit/agents && echo a > plugins/shipkit/agents/reviewer.md)
hkg add -A; hkg commit -q -m base; hkg tag base
echo b >> "$HK/repo/plugins/shipkit/agents/reviewer.md"; hkg commit -q -am change
{ printf 'case\tset\tpaths\n'
  printf 'reviewer-one\ttune\tplugins/shipkit/agents/reviewer.md\n'
  printf 'holdout-reviewer-one\tholdout\tplugins/shipkit/agents/reviewer.md\n'
  printf 'beta\twatch\tplugins/shipkit/agents/reviewer.md\n'; } > "$HK/map.tsv"
hk_out=$(cd "$HK/repo" && EVALS_MAP="$HK/map.tsv" sh "$ROOT/scripts/evals-for-diff.sh" base 2>"$HK/err" | tr '\n' ' ')
[ "$hk_out" = "beta reviewer-one " ] || hk_fail="$hk_fail [b: with a held-out row the diff meets, printed: $hk_out]"
[ "$(cat "$HK/err")" = "evals-for-diff: 1 held-out case(s) not listed" ] || hk_fail="$hk_fail [b: standard error: $(tr '\n' '|' < "$HK/err" | cut -c1-200)]"
grep -v '^holdout-' "$HK/map.tsv" > "$HK/map-none.tsv"
hk_out=$(cd "$HK/repo" && EVALS_MAP="$HK/map-none.tsv" sh "$ROOT/scripts/evals-for-diff.sh" base 2>"$HK/err" | tr '\n' ' ')
[ "$hk_out" = "beta reviewer-one " ] && [ ! -s "$HK/err" ] || hk_fail="$hk_fail [b: with no held-out row: printed $hk_out, standard error $(tr '\n' '|' < "$HK/err" | cut -c1-120)]"
# c. evals-ledger.sh append: the set is holdout for a case the map marks so; watch or tune for
# the others, and for every case when there is no map to read
hk_runs() { _n=$1; _s=""; while [ "$_n" -gt 0 ]; do _s="$_s{\"passed\":true,\"costUsd\":0.1}"; _n=$((_n - 1)); [ "$_n" -gt 0 ] && _s="$_s,"; done; printf '%s' "$_s"; }
printf '%s\n' '{"schemaVersion":1,"claudeVersion":"2.1.400","startedAt":"2026-12-02T10:00:00.000Z","costUsd":1.3,' \
  '"suite":{"modelOverride":"sonnet","threshold":0.6,"plugins":[{"name":"shipkit","version":"9.9.9"}]},' \
  '"cases":[{"name":"reviewer-one","runsPerCase":3,"arms":{"with":['"$(hk_runs 3)"']}},' \
  '{"name":"holdout-reviewer-one","runsPerCase":5,"arms":{"with":['"$(hk_runs 5)"']}},' \
  '{"name":"beta","runsPerCase":5,"arms":{"with":['"$(hk_runs 5)"']}}],' \
  '"aggregates":{"casesTotal":3}}' > "$HK/out/aggregate-result.json"
hk_sets() { awk -F '\t' 'NR > 1 { printf "%s=%s ", $6, $7 }' "$1" 2>/dev/null; }
EVALS_MAP="$HK/map.tsv" EVALS_LEDGER="$HK/l.tsv" sh "$ROOT/scripts/evals-ledger.sh" append "$HK/out" --commit abc1234 >/dev/null 2>&1; hk_rc=$?
[ "$hk_rc" -eq 0 ] && [ "$(hk_sets "$HK/l.tsv")" = "reviewer-one=tune holdout-reviewer-one=holdout beta=watch " ] \
  || hk_fail="$hk_fail [c: append with the scratch map: exit $hk_rc, sets $(hk_sets "$HK/l.tsv")]"
EVALS_MAP="$HK/no-such-map.tsv" EVALS_LEDGER="$HK/l2.tsv" sh "$ROOT/scripts/evals-ledger.sh" append "$HK/out" --commit abc1234 >/dev/null 2>&1; hk_rc=$?
[ "$hk_rc" -eq 0 ] && [ "$(hk_sets "$HK/l2.tsv")" = "reviewer-one=tune holdout-reviewer-one=watch beta=watch " ] \
  || hk_fail="$hk_fail [c: append with no map to read: exit $hk_rc, sets $(hk_sets "$HK/l2.tsv")]"
sh -n "$ROOT/scripts/evals-for-diff.sh" 2>/dev/null && sh -n "$ROOT/scripts/evals-ledger.sh" 2>/dev/null || hk_fail="$hk_fail [sh -n reports a syntax error]"
if [ -z "$hk_fail" ]; then pass "holdout-kept-out (lint takes tune, watch and holdout, and holds holdout to evals/holdout/; evals-for-diff.sh leaves a held-out case out and says so; the ledger writes holdout from the map)"
else failc "holdout-kept-out" "$hk_fail"; fi

# 117. grader-both-ways: a grader is shown on a reply it must pass and on one it must fail. A
# `regex` grader is a JavaScript RegExp, and the verifier plan's rules 18 and 23 ask that a new
# or changed one go through node on both sides; until Sprint 32 that was done by hand and kept
# in a commit message. scripts/grader-check.sh reads scripts/grader-replies/<case>/, where
# <grader>.pass.md must match the pattern and <grader>.fail.md must not, and this check runs it:
# first on a scratch case, where each way of being wrong is made and must be caught, then on
# this repository's replies, where every grader named in gc_need must have both sides, and where
# each reply carries the mark its requirement names: a grader shown on the wrong replies is not
# shown. No claude needed; it needs node.
# Cites: misses-to-checks/REQ-40 misses-to-checks/REQ-7 misses-to-checks/REQ-8
# misses-to-checks/REQ-9 misses-to-checks/REQ-10 misses-to-checks/REQ-14 misses-to-checks/REQ-23
# misses-to-checks/REQ-24 misses-to-checks/REQ-34 misses-to-checks/REQ-37 misses-to-checks/REQ-38
GC="$WORK/gcheck"; GCS="$ROOT/scripts/grader-check.sh"; gc_fail=""
mkdir -p "$GC/evals/demo/one/graders" "$GC/evals/demo/two/graders" "$GC/evals/fixtures/skipped" "$GC/replies/demo-one"
printf 'A scratch case.\n' > "$GC/evals/demo/one/prompt.md"; printf 'Another.\n' > "$GC/evals/demo/two/prompt.md"
printf 'Not a case: it is under fixtures.\n' > "$GC/evals/fixtures/skipped/prompt.md"
gc_grader() {  # gc_grader <file> <pattern> [flags] → a regex grader file
  { printf -- '---\ntype: regex\n'; printf "pattern: '%s'\n" "$2"; [ -z "${3:-}" ] || printf 'flags: %s\n' "$3"; printf -- '---\n'; } > "$1"
}
gc_good='^(?=[\s\S]*REQ-2\b[^\n]{0,80}NOT MET)(?=[\s\S]*verdict: fail)'
gc_grader "$GC/evals/demo/one/graders/marks.md" "$gc_good" i
gc_grader "$GC/evals/demo/two/graders/other.md" 'x'
printf -- '---\ntype: llm\n---\nA rubric.\n' > "$GC/evals/demo/two/graders/judge.md"
printf '| REQ-1 | MET | code |\n| REQ-2 | NOT MET | no code rejects it |\n\nVERDICT: FAIL\n' > "$GC/replies/demo-one/marks.pass.md"
printf '| REQ-1 | MET | code |\n| REQ-2 | MET | code and test |\n\nVERDICT: PASS\n' > "$GC/replies/demo-one/marks.fail.md"
gc_run() { GRADER_EVALS="$GC/evals" GRADER_REPLIES="$GC/replies" sh "$GCS" "$@" > "$GC/out" 2>&1; echo $?; }
gc_want() {  # gc_want <label> <exit wanted> <text the output must hold> [arguments]
  _l=$1; _e=$2; _t=$3; shift 3; _rc=$(gc_run "$@")
  [ "$_rc" = "$_e" ] && grep -q -F -- "$_t" "$GC/out" || gc_fail="$gc_fail [$_l: exit $_rc, want $_e and \"$_t\": $(tr '\n' '|' < "$GC/out" | cut -c1-240)]"
}
# a. both sides as they should be: two PASS lines, exit 0; the flag is the grader's
gc_want "a: a good pair" 0 'PASS  demo-one marks.pass.md'
grep -q -F 'PASS  demo-one marks.fail.md' "$GC/out" && grep -q -x 'grader-check: 2 as expected, 0 not' "$GC/out" || gc_fail="$gc_fail [a: $(tr '\n' '|' < "$GC/out" | cut -c1-240)]"
gc_grader "$GC/evals/demo/one/graders/marks.md" "$gc_good"
gc_want "b: the grader's flag taken away" 1 'FAIL  demo-one marks.pass.md'
# c. a pattern that matches both; d. one node cannot compile (a Python inline flag, rule 18)
gc_grader "$GC/evals/demo/one/graders/marks.md" 'REQ-2'
gc_want "c: a pattern that matches both" 1 'FAIL  demo-one marks.fail.md'
gc_grader "$GC/evals/demo/one/graders/marks.md" '(?is)REQ-2'
gc_want "d: a Python inline flag" 1 'does not compile'
gc_grader "$GC/evals/demo/one/graders/marks.md" "$gc_good" i
# e. a reply whose grader does not exist; f. a pass reply with no fail reply; g. a folder that
# names no case, the one under fixtures included; h. a reply for a grader that is not a regex
cp "$GC/replies/demo-one/marks.pass.md" "$GC/replies/demo-one/ghost.pass.md"
gc_want "e: a reply with no grader" 1 'FAIL  demo-one ghost.pass.md'
rm -f "$GC/replies/demo-one/ghost.pass.md"; mv "$GC/replies/demo-one/marks.fail.md" "$GC/keep.fail.md"
gc_want "f: a pass reply and no fail reply" 1 'FAIL  demo-one marks: a pass reply and no fail reply'
mv "$GC/keep.fail.md" "$GC/replies/demo-one/marks.fail.md"
mkdir -p "$GC/replies/fixtures-skipped"; cp "$GC/replies/demo-one/marks.pass.md" "$GC/replies/fixtures-skipped/x.pass.md"
gc_want "g: a reply folder that names no case" 1 'FAIL  fixtures-skipped: no eval case has that name'
rm -rf "$GC/replies/fixtures-skipped"; mkdir -p "$GC/replies/demo-two"
cp "$GC/replies/demo-one/marks.pass.md" "$GC/replies/demo-two/judge.pass.md"
gc_want "h: a reply for an llm grader" 1 'FAIL  demo-two judge.pass.md: not a regex grader'
rm -rf "$GC/replies/demo-two"
# i. --require: a regex grader with no replies fails, and an llm grader is not asked for any;
# one case alone; a case with no folder; usage; and no node on the PATH
gc_want "i: --require of a case shown both ways" 0 'grader-check: 2 as expected, 0 not' --require demo-one
gc_want "i: --require of a case with no replies" 1 'FAIL  demo-two other: no replies' --require demo-two
grep -q 'judge' "$GC/out" && gc_fail="$gc_fail [i: --require asked for replies to an llm grader]"
gc_want "i: one case alone" 0 'grader-check: 2 as expected, 0 not' demo-one
gc_want "i: one case alone, with no folder" 1 'FAIL  demo-two: no replies folder' demo-two
gc_want "i: an unknown option" 2 'usage: grader-check.sh' --nope
gc_rc=$(PATH=/usr/bin:/bin GRADER_EVALS="$GC/evals" GRADER_REPLIES="$GC/replies" sh "$GCS" > "$GC/out" 2>&1; echo $?)
if PATH=/usr/bin:/bin command -v node >/dev/null 2>&1; then :
else [ "$gc_rc" = 2 ] && grep -q 'node not found' "$GC/out" || gc_fail="$gc_fail [i: no node on the PATH: exit $gc_rc, $(tr '\n' '|' < "$GC/out" | cut -c1-160)]"; fi
# j. this repository: every reply does what its name says, and each grader of the cases Sprint
# 32 adds has both sides (the list grows with the cases)
gc_need="reviewer-helper-only holdout-reviewer-helper-only reviewer-skipped-test reviewer-comment-cite reviewer-weakened-req reviewer-waiver-added holdout-reviewer-skipped-test reviewer-second-round reviewer-stale-met reviewer-check-triggered escape-second-of-a-kind escape-missing-req"
gc_args=""; for gc_c in $gc_need; do gc_args="$gc_args --require $gc_c"; done
# shellcheck disable=SC2086
sh "$GCS" $gc_args > "$GC/repo.out" 2>&1; gc_rc=$?
[ "$gc_rc" -eq 0 ] || gc_fail="$gc_fail [j: this repository: exit $gc_rc: $(grep -E '^FAIL|not found|usage' "$GC/repo.out" | tr '\n' '|' | cut -c1-400)]"
# k. each reply carries the mark its requirement names (case, file, held or not, the text)
GCT=$(printf '\t')
while IFS="$GCT" read -r gc_c gc_f gc_yn gc_text; do
  [ -n "$gc_c" ] || continue
  if [ ! -f "$ROOT/scripts/grader-replies/$gc_c/$gc_f" ]; then gc_fail="$gc_fail [k: no reply $gc_c/$gc_f]"; continue; fi
  if grep -q -F -- "$gc_text" "$ROOT/scripts/grader-replies/$gc_c/$gc_f"; then gc_has=yes; else gc_has=no; fi
  [ "$gc_has" = "$gc_yn" ] || gc_fail="$gc_fail [k: $gc_c/$gc_f holds \"$gc_text\": $gc_has, want $gc_yn]"
done <<'GCK'
reviewer-helper-only	req2-not-met-and-fail.pass.md	yes	| REQ-2 | NOT MET |
reviewer-helper-only	req2-not-met-and-fail.pass-2.md	yes	| REQ-2 | CANNOT TELL |
reviewer-helper-only	req2-not-met-and-fail.fail.md	yes	| REQ-2 | MET |
reviewer-helper-only	req2-not-met-and-fail.fail-2.md	yes	| REQ-2 | MET |
reviewer-skipped-test	req2-not-met-and-fail.pass.md	yes	| REQ-2 | NOT MET |
reviewer-skipped-test	req2-not-met-and-fail.fail.md	yes	| REQ-2 | MET |
reviewer-comment-cite	req2-not-met-and-fail.pass.md	yes	| REQ-2 | NOT MET |
reviewer-comment-cite	req2-not-met-and-fail.fail.md	yes	| REQ-2 | MET |
reviewer-weakened-req	names-the-change.pass.md	yes	## Requirements changed on this branch
reviewer-weakened-req	names-the-change.pass-2.md	yes	REQ-2 was rewritten on this branch
reviewer-weakened-req	names-the-change.fail.md	yes	| REQ-2 | MET |
reviewer-weakened-req	names-the-change.fail.md	no	changed on this branch
reviewer-waiver-added	names-the-waiver.pass.md	yes	WAIVER-ADDED
reviewer-waiver-added	names-the-waiver.pass-2.md	yes	the waiver on REQ-2 is new
reviewer-waiver-added	names-the-waiver.fail.md	yes	| REQ-2 (waived) | MET |
reviewer-waiver-added	names-the-waiver.fail.md	no	WAIVER-ADDED
holdout-reviewer-helper-only	req1-not-met-and-fail.pass.md	yes	| REQ-1 | NOT MET |
holdout-reviewer-helper-only	req1-not-met-and-fail.pass-2.md	yes	| REQ-1 | CANNOT TELL |
holdout-reviewer-helper-only	req1-not-met-and-fail.fail.md	yes	| REQ-1 | MET |
holdout-reviewer-skipped-test	req1-not-met-and-fail.pass.md	yes	| REQ-1 | NOT MET |
holdout-reviewer-skipped-test	req1-not-met-and-fail.fail.md	yes	| REQ-1 | MET |
reviewer-second-round	same-mark-as-before.pass.md	yes	| REQ-2 | NOT MET |
reviewer-second-round	same-mark-as-before.fail.md	yes	| REQ-2 | CANNOT TELL |
reviewer-second-round	same-mark-as-before.fail-2.md	yes	| REQ-2 | MET |
reviewer-stale-met	not-met-despite-the-report.pass.md	yes	| REQ-2 | NOT MET |
reviewer-stale-met	not-met-despite-the-report.fail.md	yes	| REQ-2 | MET |
reviewer-check-triggered	c1-broken-and-pass.pass.md	yes	| BROKEN |
reviewer-check-triggered	c1-broken-and-pass.pass.md	yes	VERDICT: PASS
reviewer-check-triggered	c1-broken-and-pass.fail.md	no	C1
reviewer-check-triggered	c1-broken-and-pass.fail-2.md	yes	| HELD |
escape-second-of-a-kind	drafts-a-check.pass.md	yes	Trigger: path
escape-second-of-a-kind	drafts-a-check.pass.md	yes	From: .shipkit/escapes/0001-refund-above-charge.md, .shipkit/escapes/0002-
escape-second-of-a-kind	drafts-a-check.fail.md	no	Trigger:
escape-second-of-a-kind	drafts-a-check.fail-2.md	no	From: .shipkit/escapes/0001-
escape-missing-req	no-check-drafted.pass.md	no	Trigger:
escape-missing-req	no-check-drafted.fail.md	yes	Trigger:
GCK
sh -n "$GCS" 2>/dev/null || gc_fail="$gc_fail [sh -n reports a syntax error]"
if [ -z "$gc_fail" ]; then pass "grader-both-ways (grader-check.sh reads each reply through node with the grader's flags and catches a pattern that matches both, one that will not compile, a missing side, a missing grader and a missing case; this repository: $(tail -1 "$GC/repo.out"), each reply carrying the mark its requirement names)"
else failc "grader-both-ways" "$gc_fail"; fi

# 118. reviewer-trees: every tree the reviewer is graded on is built here and read, so a case
# says what its answer key says. Sprint 32 grows the shared fixture (evals/lib/review-fixture.sh)
# from four variants to fourteen. The four old cases have release runs behind them, so each of
# their trees must be, file for file and commit for commit, the tree the script at 9e061ca
# built. Each new case comes from a miss a real run showed, and its tree is read for what makes
# it that miss. helper-only (field-notes-5.2.md, section 9): the test that cites REQ-2 passes
# and calls a helper that refund never calls, so spec-check.sh is satisfied and the behaviour
# is not there. The two held-out cases are the same misses on another feature, a notes export,
# so that nothing in them shares a word with the cases the reviewer's text is tuned on, and the
# requirement they break is REQ-1, not REQ-2. No claude needed.
# Four more come from gaps the verifier plan's read of the scripts found (its section 3): a
# citation in a skipped test counts (skipped-test), so does one in a comment in the code
# (comment-cite), and an edit to the spec on its own branch is never listed, whether it rewrites
# a requirement to match the code (weakened-req) or excuses it from a test (waiver-added).
# Cites: misses-to-checks/REQ-1 misses-to-checks/REQ-2 misses-to-checks/REQ-3
# misses-to-checks/REQ-4 misses-to-checks/REQ-5 misses-to-checks/REQ-6 misses-to-checks/REQ-11
# misses-to-checks/REQ-12 misses-to-checks/REQ-13 misses-to-checks/REQ-21 misses-to-checks/REQ-22
# misses-to-checks/REQ-33
# A second round (field-notes-5.2.md, "One tree, two readings"): second-round is the helper-only
# tree with an earlier report that marked REQ-2 NOT MET, and stale-met the missing-req tree with
# one that marked it MET.
RT="$WORK/rtrees"; rt_fail=""; mkdir -p "$RT/old/lib" "$RT/old/fixtures"
rt_build() {  # rt_build <dir> <fixture script> [argument] → the tree the script leaves in <dir>
  mkdir -p "$1"
  (cd "$1" && bash "$2" ${3:+"$3"} > "$1.log" 2>&1); _rc=$?
  [ "$_rc" -eq 0 ] || rt_fail="$rt_fail [$(basename "$1"): the fixture exited $_rc: $(tail -2 "$1.log" | tr '\n' '|' | cut -c1-160)]"
}
rt_test() { (cd "$1" && python3 -m unittest discover -s tests > "$1.test" 2>&1); echo $?; }  # the test command's exit status
rt_cited() { awk -v c="# $2" 'index($0, c) { on = 1; next } on && /^[[:space:]]*$/ { exit } on' "$1"; }  # the test under a citation
# a. the four old cases: the same files, the same commits, the same diff from base
git -C "$ROOT" show 9e061ca:plugins/shipkit/evals/lib/review-fixture.sh > "$RT/old/lib/review-fixture.sh" 2>/dev/null || rt_fail="$rt_fail [git show 9e061ca failed]"
cp -R "$COPY/evals/fixtures/sample-app" "$RT/old/fixtures/sample-app"
for rt_pair in all-met:complete missing-req:missing rejected-alternative:rejected decision-unbuilt:unbuilt; do
  rt_c=${rt_pair%%:*}; rt_v=${rt_pair#*:}
  rt_build "$RT/new-$rt_c" "$COPY/evals/reviewer/$rt_c/fixture.sh"
  rt_build "$RT/old-$rt_c" "$RT/old/lib/review-fixture.sh" "$rt_v"
  diff -r -x .git "$RT/old-$rt_c" "$RT/new-$rt_c" > "$RT/diff.out" 2>&1 \
    || rt_fail="$rt_fail [$rt_c: its tree is not the one built at 9e061ca: $(head -3 "$RT/diff.out" | tr '\n' '|' | cut -c1-200)]"
  [ "$(git -C "$RT/old-$rt_c" log --format=%s 2>&1 | tr '\n' '|')" = "$(git -C "$RT/new-$rt_c" log --format=%s 2>&1 | tr '\n' '|')" ] \
    || rt_fail="$rt_fail [$rt_c: its commits are not those built at 9e061ca: $(git -C "$RT/new-$rt_c" log --format=%s 2>&1 | tr '\n' '|' | cut -c1-120)]"
  [ "$(git -C "$RT/old-$rt_c" diff base...HEAD 2>&1 | grep -v '^index ')" = "$(git -C "$RT/new-$rt_c" diff base...HEAD 2>&1 | grep -v '^index ')" ] \
    || rt_fail="$rt_fail [$rt_c: its diff from base is not the one built at 9e061ca]"
done
# b. helper-only
rt_build "$RT/helper" "$COPY/evals/reviewer/helper-only/fixture.sh"
(cd "$RT/helper" && sh "$COPY/scripts/spec-check.sh" . refunds --as-shipped > "$RT/helper.spec" 2>&1) \
  || rt_fail="$rt_fail [helper-only: spec-check.sh is not satisfied, and the miss is that it is: $(grep -v '^WAIVED' "$RT/helper.spec" | head -2 | tr '\n' '|' | cut -c1-160)]"
[ "$(rt_test "$RT/helper")" = 0 ] || rt_fail="$rt_fail [helper-only: the test command failed: $(tail -3 "$RT/helper.test" | tr '\n' '|' | cut -c1-200)]"
rt_t=$(rt_cited "$RT/helper/tests/test_refunds.py" refunds/REQ-2 2>/dev/null)
printf '%s\n' "$rt_t" | grep -q 'check_amount(' && ! printf '%s\n' "$rt_t" | grep -q -E '(^|[^_a-zA-Z.])refund\(' \
  || rt_fail="$rt_fail [helper-only: the test citing refunds/REQ-2 must call check_amount and not refund: $(printf '%s' "$rt_t" | tr '\n' '|' | cut -c1-200)]"
(cd "$RT/helper" && python3 - > "$RT/helper.py" 2>&1 <<'RTPY'
import inspect, sys
sys.path.insert(0, ".")
from app.refunds import RefundRejected, check_amount, refund
class Gateway:
    def __init__(self):
        self.amounts = []
    def refund(self, customer, amount_cents):
        self.amounts.append(amount_cents)
        return "rf_1"
gateway = Gateway()
assert "check_amount" not in inspect.getsource(refund), "refund calls the helper"
assert refund({"customer": "ada"}, 2500, 2000, gateway) == "rf_1" and gateway.amounts == [2500], \
    "refund did not pass 2500 on a charge of 2000 to the gateway"
try:
    check_amount(2500, 2000)
except RefundRejected:
    pass
else:
    raise AssertionError("check_amount let 2500 on a charge of 2000 through")
RTPY
) || rt_fail="$rt_fail [helper-only: $(tail -1 "$RT/helper.py" | cut -c1-200)]"
# b2. the four from gaps in how a citation and a spec edit are read
rt_rejects() {  # rt_rejects <dir> → refund raises RefundRejected for 2500 on a charge of 2000, and the gateway is not called
  (cd "$1" && python3 - > "$1.py" 2>&1 <<'RTPY'
import sys
sys.path.insert(0, ".")
from app.refunds import RefundRejected, refund
class Gateway:
    calls = 0
    def refund(self, customer, amount_cents):
        Gateway.calls += 1
        return "rf_1"
try:
    refund({"customer": "ada"}, 2500, 2000, Gateway())
except RefundRejected:
    assert Gateway.calls == 0, "the gateway was called"
else:
    raise AssertionError("refund did not raise RefundRejected for 2500 on a charge of 2000")
RTPY
  ) || rt_fail="$rt_fail [$(basename "$1"): $(tail -1 "$1.py" | cut -c1-200)]"
}
rt_diff() { (cd "$1" && sh "$COPY/scripts/spec-diff.sh" . refunds base 2>&1 | grep -E '^(REQ|WAIVER)-' | LC_ALL=C sort | tr '\n' '|'); }  # spec-diff's REQ- and WAIVER- lines, sorted
rt_build "$RT/skipped" "$COPY/evals/reviewer/skipped-test/fixture.sh"
(cd "$RT/skipped" && sh "$COPY/scripts/spec-check.sh" . refunds 2>&1) | grep -q '^SKIPPED-CITE refunds REQ-2 tests/test_refunds.py:' \
  || rt_fail="$rt_fail [skipped-test: spec-check.sh prints no SKIPPED-CITE line for refunds REQ-2]"
[ "$(rt_test "$RT/skipped")" = 0 ] && grep -q 'skipped=1' "$RT/skipped.test" \
  || rt_fail="$rt_fail [skipped-test: the test command must exit 0 with one test skipped: $(tail -1 "$RT/skipped.test" | cut -c1-120)]"
[ "$(grep -c 'refunds/REQ-2' "$RT/skipped/tests/test_refunds.py" 2>/dev/null)" = 1 ] \
  && rt_cited "$RT/skipped/tests/test_refunds.py" refunds/REQ-2 | sed -n 1p | grep -q '@unittest.skip' \
  || rt_fail="$rt_fail [skipped-test: the one test citing refunds/REQ-2 must carry @unittest.skip]"
rt_rejects "$RT/skipped"
rt_build "$RT/comment" "$COPY/evals/reviewer/comment-cite/fixture.sh"
grep -q '^ *# refunds/REQ-2' "$RT/comment/app/refunds.py" 2>/dev/null && ! grep -rq 'refunds/REQ-2' "$RT/comment/tests" 2>/dev/null \
  || rt_fail="$rt_fail [comment-cite: refunds/REQ-2 must be in a comment in app/refunds.py and nowhere under tests/]"
[ "$(rt_test "$RT/comment")" = 0 ] || rt_fail="$rt_fail [comment-cite: the test command failed: $(tail -2 "$RT/comment.test" | tr '\n' '|' | cut -c1-160)]"
rt_rejects "$RT/comment"
rt_build "$RT/weakened" "$COPY/evals/reviewer/weakened-req/fixture.sh"
[ "$(rt_diff "$RT/weakened")" = "REQ-CHANGED refunds REQ-2|" ] || rt_fail="$rt_fail [weakened-req: spec-diff.sh printed: $(rt_diff "$RT/weakened")]"
grep -q '^  refund the amount charged\.$' "$RT/weakened/.shipkit/specs/refunds/spec.md" 2>/dev/null || rt_fail="$rt_fail [weakened-req: REQ-2 does not say the refund is cut to the charge]"
[ "$(rt_test "$RT/weakened")" = 0 ] && grep -q 'refunds/REQ-2' "$RT/weakened/tests/test_refunds.py" \
  || rt_fail="$rt_fail [weakened-req: a test citing refunds/REQ-2 must pass: $(tail -2 "$RT/weakened.test" | tr '\n' '|' | cut -c1-160)]"
(cd "$RT/weakened" && python3 - > "$RT/weakened.py" 2>&1 <<'RTPY'
import sys
sys.path.insert(0, ".")
from app.refunds import refund
class Gateway:
    def __init__(self):
        self.amounts = []
    def refund(self, customer, amount_cents):
        self.amounts.append(amount_cents)
        return "rf_1"
gateway = Gateway()
refund({"customer": "ada"}, 2500, 2000, gateway)
assert gateway.amounts == [2000], "refund did not cut 2500 to the charge of 2000: %r" % gateway.amounts
RTPY
) || rt_fail="$rt_fail [weakened-req: $(tail -1 "$RT/weakened.py" | cut -c1-200)]"
rt_build "$RT/waived" "$COPY/evals/reviewer/waiver-added/fixture.sh"
[ "$(rt_diff "$RT/waived")" = "REQ-CHANGED refunds REQ-2|WAIVER-ADDED refunds REQ-2|" ] \
  || rt_fail="$rt_fail [waiver-added: spec-diff.sh printed: $(rt_diff "$RT/waived")]"
grep -rq 'refunds/REQ-2' "$RT/waived/tests" "$RT/waived/app" 2>/dev/null && rt_fail="$rt_fail [waiver-added: a file still cites refunds/REQ-2]"
[ "$(rt_test "$RT/waived")" = 0 ] || rt_fail="$rt_fail [waiver-added: the test command failed]"
# c. the held-out pair, on the notes-export feature
rt_notes() {  # rt_notes <dir> → the tree is the notes-export feature, with no word of the refunds one
  [ -f "$1/.shipkit/specs/notes-export/spec.md" ] && [ ! -e "$1/.shipkit/specs/refunds" ] \
    || rt_fail="$rt_fail [$(basename "$1"): the tree is not the notes-export feature]"
  if git -C "$1" diff base...HEAD 2>/dev/null | grep -q -i refund; then
    rt_fail="$rt_fail [$(basename "$1"): its diff from base holds 'refund': $(git -C "$1" diff base...HEAD | grep -i -m1 refund | cut -c1-100)]"
  fi
  [ -n "$(git -C "$1" diff base...HEAD --name-only 2>/dev/null)" ] || rt_fail="$rt_fail [$(basename "$1"): no diff from base]"
}
rt_build "$RT/notes-helper" "$COPY/evals/holdout/reviewer-helper-only/fixture.sh"
rt_notes "$RT/notes-helper"
(cd "$RT/notes-helper" && sh "$COPY/scripts/spec-check.sh" . notes-export --as-shipped > "$RT/notes-helper.spec" 2>&1) \
  || rt_fail="$rt_fail [holdout helper-only: spec-check.sh is not satisfied, and the miss is that it is: $(grep -v '^WAIVED' "$RT/notes-helper.spec" | head -2 | tr '\n' '|' | cut -c1-160)]"
[ "$(rt_test "$RT/notes-helper")" = 0 ] || rt_fail="$rt_fail [holdout helper-only: the test command failed: $(tail -3 "$RT/notes-helper.test" | tr '\n' '|' | cut -c1-200)]"
rt_t=$(rt_cited "$RT/notes-helper/tests/test_notes.py" notes-export/REQ-1 2>/dev/null)
printf '%s\n' "$rt_t" | grep -q 'is_shareable(' && ! printf '%s\n' "$rt_t" | grep -q 'export_notes(' \
  || rt_fail="$rt_fail [holdout helper-only: the test citing notes-export/REQ-1 must call is_shareable and not export_notes: $(printf '%s' "$rt_t" | tr '\n' '|' | cut -c1-200)]"
(cd "$RT/notes-helper" && python3 - > "$RT/notes-helper.py" 2>&1 <<'RTPY'
import inspect, sys
sys.path.insert(0, ".")
from app.notes import export_notes, is_shareable
private = {"title": "Pin", "body": "1234", "private": True}
assert "is_shareable" not in inspect.getsource(export_notes), "export_notes calls the helper"
assert not is_shareable(private), "is_shareable lets a private note through"
assert len(export_notes([private])) == 1, "export_notes left the private note out, so the miss is not in the tree"
RTPY
) || rt_fail="$rt_fail [holdout helper-only: $(tail -1 "$RT/notes-helper.py" | cut -c1-200)]"
rt_build "$RT/notes-skipped" "$COPY/evals/holdout/reviewer-skipped-test/fixture.sh"
rt_notes "$RT/notes-skipped"
(cd "$RT/notes-skipped" && sh "$COPY/scripts/spec-check.sh" . notes-export 2>&1) | grep -q '^SKIPPED-CITE notes-export REQ-1 tests/test_notes.py:' \
  || rt_fail="$rt_fail [holdout skipped-test: spec-check.sh prints no SKIPPED-CITE line for notes-export REQ-1]"
[ "$(rt_test "$RT/notes-skipped")" = 0 ] && grep -q 'skipped=1' "$RT/notes-skipped.test" \
  || rt_fail="$rt_fail [holdout skipped-test: the test command must exit 0 with one test skipped: $(tail -1 "$RT/notes-skipped.test" | cut -c1-120)]"
[ "$(grep -c 'notes-export/REQ-1' "$RT/notes-skipped/tests/test_notes.py" 2>/dev/null)" = 1 ] \
  && rt_cited "$RT/notes-skipped/tests/test_notes.py" notes-export/REQ-1 | sed -n 1p | grep -q '@unittest.skip' \
  || rt_fail="$rt_fail [holdout skipped-test: the one test citing notes-export/REQ-1 must carry @unittest.skip]"
(cd "$RT/notes-skipped" && python3 - > "$RT/notes-skipped.py" 2>&1 <<'RTPY'
import sys
sys.path.insert(0, ".")
from app.notes import export_notes
private = {"title": "Pin", "body": "1234", "private": True}
public = {"title": "Milk", "body": "two litres"}
assert export_notes([private, public]) == ["Milk: two litres"], "export_notes did not leave the private note out: %r" % export_notes([private, public])
RTPY
) || rt_fail="$rt_fail [holdout skipped-test: $(tail -1 "$RT/notes-skipped.py" | cut -c1-200)]"
# d. a second round: the same tree as another case, and one untracked file, an earlier report
rt_report() {  # rt_report <tree> <the tree it equals but for the report> <first line> <REQ-2's row starts>
  _f="$1/.shipkit/releases/2026-11-01-refunds.md"
  [ "$(diff -r -x .git "$2" "$1" 2>&1)" = "Only in $1/.shipkit: releases" ] \
    || rt_fail="$rt_fail [$(basename "$1"): it must be $(basename "$2")'s tree and one more folder: $(diff -r -x .git "$2" "$1" 2>&1 | head -3 | tr '\n' '|' | cut -c1-200)]"
  [ "$(sed -n 1p "$_f" 2>/dev/null)" = "$3" ] && grep -q -F "$4" "$_f" && grep -q '^### 4\. Independent review$' "$_f" && grep -q '^VERDICT: ' "$_f" \
    || rt_fail="$rt_fail [$(basename "$1"): the earlier report must start '$3' and hold '$4' in a review: $(sed -n 1p "$_f" 2>/dev/null)]"
  [ "$(git -C "$1" status --porcelain 2>/dev/null)" = "?? .shipkit/releases/" ] || rt_fail="$rt_fail [$(basename "$1"): the earlier report must be the one untracked file]"
  [ "2026-11-01" \< "$(date +%F)" ] || rt_fail="$rt_fail [$(basename "$1"): the report is not dated before today]"
}
rt_build "$RT/helper-again" "$COPY/evals/reviewer/helper-only/fixture.sh"
rt_build "$RT/round2" "$COPY/evals/reviewer/second-round/fixture.sh"
rt_report "$RT/round2" "$RT/helper-again" "NOT READY" "| REQ-2 | NOT MET |"
rt_build "$RT/stale" "$COPY/evals/reviewer/stale-met/fixture.sh"
rt_report "$RT/stale" "$RT/new-missing-req" "READY" '| REQ-2 | MET | code `app/refunds.py:'
# e. check-triggered: the all-met tree, with a checks file in the base commit whose one item
# the diff triggers and the code breaks
rt_build "$RT/check" "$COPY/evals/reviewer/check-triggered/fixture.sh"
[ "$(diff -r -x .git "$RT/new-all-met" "$RT/check" 2>&1)" = "Only in $RT/check/.shipkit: checks.md" ] \
  || rt_fail="$rt_fail [check-triggered: it must be all-met's tree and a checks file: $(diff -r -x .git "$RT/new-all-met" "$RT/check" 2>&1 | head -3 | tr '\n' '|' | cut -c1-200)]"
[ "$(git -C "$RT/check" show base:.shipkit/checks.md 2>/dev/null | grep -c '^## C[0-9]*: ')" = 1 ] \
  && git -C "$RT/check" show base:.shipkit/checks.md 2>/dev/null | grep -q -x 'Trigger: path app/refunds.py' \
  || rt_fail="$rt_fail [check-triggered: the base commit must hold a checks file with one item whose trigger is path app/refunds.py]"
sh "$COPY/scripts/checks-match.sh" "$RT/check" base 2>&1 | grep -q '^TRIGGERED C1: ' || rt_fail="$rt_fail [check-triggered: checks-match.sh . base does not print TRIGGERED C1]"
git -C "$RT/check" show base:.shipkit/checks.md 2>/dev/null | grep -q 'idempotency key' && grep -q 'gateway\.refund(order\["customer"\], amount_cents)$' "$RT/check/app/refunds.py" 2>/dev/null \
  || rt_fail="$rt_fail [check-triggered: the check asks for an idempotency key, and refund must call the gateway with two arguments]"
if [ -z "$rt_fail" ]; then pass "reviewer-trees (the four old cases' trees are, file for file and commit for commit, what the fixture at 9e061ca built; helper-only: the test citing REQ-2 passes on a helper that refund never calls, and spec-check.sh is satisfied; skipped-test, comment-cite, weakened-req and waiver-added are what spec-check.sh and spec-diff.sh say they are; held out, on notes-export with no word of refunds: the helper-only and the skipped-test miss on REQ-1; second-round and stale-met are another case's tree with one earlier report, untracked; check-triggered is all-met's tree with a check in the base commit that the diff triggers and breaks)"
else failc "reviewer-trees" "$rt_fail"; fi

# 119. checks-match: a past miss is asked about when a diff touches the same ground.
# .shipkit/checks.md holds items, each with a trigger a diff can meet (`path <glob>` or
# `added <pattern>`), a check and the miss it came from. plugins/shipkit/scripts/checks-match.sh
# prints the items a diff triggers, and reads the file from the base ref, never from the
# working tree, so a branch cannot edit the list it is judged by (the verifier plan's rule 28).
# --lint reads the file being written. Nothing runs the script yet: the reviewer's use of it
# waits for Sprint 35. Here: a scratch repository. No claude needed.
# Cites: misses-to-checks/REQ-25 misses-to-checks/REQ-26 misses-to-checks/REQ-27
# misses-to-checks/REQ-28 misses-to-checks/REQ-29 misses-to-checks/REQ-30 misses-to-checks/REQ-31
# misses-to-checks/REQ-32
CM="$WORK/cmatch"; CMS="$COPY/scripts/checks-match.sh"; cm_fail=""; mkdir -p "$CM/repo/app/sub" "$CM/repo/docs" "$CM/bin" "$CM/lint/.shipkit" "$CM/lint/docs"
cmg() { (cd "$CM/repo" && git -c user.email=s@s -c user.name=s "$@"); }
(cd "$CM/repo" && git init -q && echo x > docs/note.md); cmg add -A; cmg commit -q -m empty; cmg tag empty
mkdir -p "$CM/repo/.shipkit"
cat > "$CM/repo/.shipkit/checks.md" <<'CMEOF'
# Checks

## C1: Payments are sent once
Trigger: path app/pay.py, docs/never.md
Check: Every call to the gateway passes an idempotency key.
From: docs/note.md (the double payment), docs/note.md

## C2: Never met by this diff
Trigger: path docs/never.md
Check: Nothing.
From: docs/note.md

## C3: A retry was added
Trigger: added retry\(
Check: The retry is bounded.
From: docs/note.md

## C4: Only a removed line holds this
Trigger: added legacy_call
Check: Nothing.
From: docs/note.md

## C5: A star crosses a slash
Trigger: path app/*.txt
Check: The text is still right.
From: docs/note.md
CMEOF
printf 'def pay(charge):\n    legacy_call()\n    return charge\n' > "$CM/repo/app/pay.py"; echo one > "$CM/repo/app/sub/deep.txt"
cmg add -A; cmg commit -q -m base; cmg tag base
printf 'def pay(charge):\n    retry(charge)\n    return charge\n' > "$CM/repo/app/pay.py"; echo two > "$CM/repo/app/sub/deep.txt"
# on the branch, C2's trigger is rewritten so that this diff would meet it, and committed; the
# working tree's copy then loses C1 altogether. Neither may change what is printed.
sed -i.bak 's|^Trigger: path docs/never.md$|Trigger: path app/pay.py|' "$CM/repo/.shipkit/checks.md" && rm -f "$CM/repo/.shipkit/checks.md.bak"
cmg add -A; cmg commit -q -m change
sed -i.bak '/^## C1:/,/^From:/d' "$CM/repo/.shipkit/checks.md" && rm -f "$CM/repo/.shipkit/checks.md.bak"
cm_before=$(cmg status --porcelain)
cm_want='TRIGGERED C1: Payments are sent once
Trigger: path app/pay.py, docs/never.md
Check: Every call to the gateway passes an idempotency key.
From: docs/note.md (the double payment), docs/note.md
TRIGGERED C3: A retry was added
Trigger: added retry\(
Check: The retry is bounded.
From: docs/note.md
TRIGGERED C5: A star crosses a slash
Trigger: path app/*.txt
Check: The text is still right.
From: docs/note.md'
cm_out=$(sh "$CMS" "$CM/repo" base 2>&1); cm_rc=$?
[ "$cm_rc" -eq 0 ] && [ "$cm_out" = "$cm_want" ] \
  || cm_fail="$cm_fail [a: the base's items C1, C3 and C5, in order, each with its three lines; not C2 (the branch's edit) and not C4 (a removed line): exit $cm_rc: $(printf '%s' "$cm_out" | grep -E '^TRIGGERED|^checks-match|not found' | tr '\n' '|' | cut -c1-300)]"
[ "$(cmg status --porcelain)" = "$cm_before" ] || cm_fail="$cm_fail [a: the script changed a file]"
# b. no checks file at the base, though the branch and the working tree hold one: nothing, exit 0;
# a diff that triggers nothing: nothing, exit 0; usage and an unknown ref: 64
cm_out=$(sh "$CMS" "$CM/repo" empty 2>&1); cm_rc=$?
[ "$cm_rc" -eq 0 ] && [ -z "$cm_out" ] || cm_fail="$cm_fail [b: no checks file at the base: exit $cm_rc, printed: $(printf '%s' "$cm_out" | head -2 | tr '\n' '|' | cut -c1-160)]"
cm_out=$(sh "$CMS" "$CM/repo" HEAD 2>&1); cm_rc=$?
[ "$cm_rc" -eq 0 ] && [ -z "$cm_out" ] || cm_fail="$cm_fail [b: an empty diff: exit $cm_rc, printed: $(printf '%s' "$cm_out" | head -2 | tr '\n' '|' | cut -c1-160)]"
sh "$CMS" > /dev/null 2>&1; [ $? -eq 64 ] || cm_fail="$cm_fail [b: no arguments is not exit 64]"
sh "$CMS" "$CM/repo" > /dev/null 2>&1; [ $? -eq 64 ] || cm_fail="$cm_fail [b: one argument is not exit 64]"
sh "$CMS" "$CM/repo" no-such-ref > /dev/null 2>&1; [ $? -eq 64 ] || cm_fail="$cm_fail [b: an unknown base ref is not exit 64]"
# c. sh, awk and git only: with nothing else on the PATH it prints the same
for cm_t in awk git; do ln -s "$(command -v "$cm_t")" "$CM/bin/$cm_t" 2>/dev/null; done
cm_out=$(PATH="$CM/bin" /bin/sh "$CMS" "$CM/repo" base 2>&1)
[ "$cm_out" = "$cm_want" ] || cm_fail="$cm_fail [c: with only awk and git on the PATH: $(printf '%s' "$cm_out" | grep -v -E '^(TRIGGERED|Trigger|Check|From)' | head -2 | tr '\n' '|' | cut -c1-200)]"
sh -n "$CMS" 2>/dev/null || cm_fail="$cm_fail [c: sh -n reports a syntax error]"
# d. --lint: the file being written. Each kind of bad item is named; a good file and no file say nothing
cm_lint() { sh "$CMS" --lint "$CM/lint" > "$CM/lint.out" 2>&1; echo $?; }
echo x > "$CM/lint/docs/real.md"
[ "$(cm_lint)" = 0 ] && [ ! -s "$CM/lint.out" ] || cm_fail="$cm_fail [d: no checks file: $(tr '\n' '|' < "$CM/lint.out" | cut -c1-120)]"
printf '## C1: Good\nTrigger: path app/*\nCheck: Look.\nFrom: docs/real.md (a note), docs/real.md\n\n## C2: Good too\nTrigger: added foo|bar\nCheck: Look.\nFrom: docs/real.md\n' > "$CM/lint/.shipkit/checks.md"
[ "$(cm_lint)" = 0 ] && [ ! -s "$CM/lint.out" ] || cm_fail="$cm_fail [d: a good file: $(tr '\n' '|' < "$CM/lint.out" | cut -c1-160)]"
printf '## C1: No trigger\nCheck: Look.\nFrom: docs/real.md\n\n## C2: No check\nTrigger: path app/*\nFrom: docs/real.md\n\n## C3: No source\nTrigger: path app/*\nCheck: Look.\n\n## C4: A trigger of neither kind\nTrigger: when it rains\nCheck: Look.\nFrom: docs/real.md\n\n## C5: A source that is not there\nTrigger: added foo\nCheck: Look.\nFrom: docs/real.md, docs/nope.md (gone)\n' > "$CM/lint/.shipkit/checks.md"
[ "$(cm_lint)" = 1 ] && [ "$(grep -c '^BAD-ITEM ' "$CM/lint.out")" = 5 ] && [ "$(grep -c . "$CM/lint.out")" = 5 ] \
  && grep -q '^BAD-ITEM C1 .*Trigger' "$CM/lint.out" && grep -q '^BAD-ITEM C2 .*Check' "$CM/lint.out" && grep -q '^BAD-ITEM C3 .*From' "$CM/lint.out" \
  && grep -q '^BAD-ITEM C4 .*neither' "$CM/lint.out" && grep -q '^BAD-ITEM C5 .*docs/nope\.md' "$CM/lint.out" \
  || cm_fail="$cm_fail [d: five bad items, each named once: $(tr '\n' '|' < "$CM/lint.out" | cut -c1-400)]"
sh "$CMS" --lint > /dev/null 2>&1; [ $? -eq 64 ] || cm_fail="$cm_fail [d: --lint with no folder is not exit 64]"
# e. this repository's own file: four items, well formed, and each one's trigger is met by the
# kind of change it is about (a grader, lint.py, a requirement that names READY, a text-only pass)
CMO="$CM/own"; mkdir -p "$CMO/.shipkit/specs/x" "$CMO/scripts" "$CMO/plugins/shipkit/evals/demo/one/graders"
cmo() { (cd "$CMO" && git -c user.email=s@s -c user.name=s "$@"); }
[ "$(grep -c '^## C[0-9][0-9]*: ' "$ROOT/.shipkit/checks.md" 2>/dev/null)" = 4 ] || cm_fail="$cm_fail [e: .shipkit/checks.md does not hold four items]"
sh "$CMS" --lint "$ROOT" > "$CM/own.lint" 2>&1; cm_rc=$?
[ "$cm_rc" -eq 0 ] && [ ! -s "$CM/own.lint" ] || cm_fail="$cm_fail [e: --lint on this repository: exit $cm_rc: $(tr '\n' '|' < "$CM/own.lint" | cut -c1-300)]"
cp "$ROOT/.shipkit/checks.md" "$CMO/.shipkit/checks.md" 2>/dev/null
(cd "$CMO" && git init -q && echo x > scripts/lint.py && echo x > scripts/smoke.sh && echo x > .shipkit/specs/x/spec.md); cmo add -A; cmo commit -q -m base; cmo tag base
echo y > "$CMO/plugins/shipkit/evals/demo/one/graders/g.md"; echo y >> "$CMO/scripts/lint.py"
printf -- '- **REQ-9.** The ship report shall read READY.\n' >> "$CMO/.shipkit/specs/x/spec.md"
# (written in two parts: check 104 counts this script's own text-only assertions by that word)
printf 'pass%s "demo (the words are there)"\n' t >> "$CMO/scripts/smoke.sh"
cmo add -A; cmo commit -q -m change
cm_out=$(sh "$CMS" "$CMO" base 2>&1 | grep '^TRIGGERED ' | cut -d: -f1 | tr '\n' ' ')
[ "$cm_out" = "TRIGGERED C1 TRIGGERED C2 TRIGGERED C3 TRIGGERED C4 " ] || cm_fail="$cm_fail [e: a change of each kind must trigger this repository's four items: $cm_out]"
if [ -z "$cm_fail" ]; then pass "checks-match (the items a diff triggers, from the base ref's file: a path glob whose star crosses a slash, an added line and not a removed one; a branch's edit to the file changes nothing; no file at the base, nothing; --lint names five kinds of bad item; sh, awk and git only, and no file changed; this repository's four items are well formed and each is met by the change it is about)"
else failc "checks-match" "$cm_fail"; fi

# 120. escape-second: the second escape of a kind. /shipkit:escape repairs one spec and stops;
# its waiting step (misses-to-checks/design.md, W9) drafts a check item when an escape has the
# same cause as an earlier one on the same paths. The case's tree is escape/missing-req's after
# that first escape was handled: REQ-3 is in the spec with its code and test, and the record is
# in .shipkit/escapes/. The new report is of a negative refund, which no requirement covers. The
# map is read here too: of the eleven cases Sprint 32 adds, two are held out and nine are tuning
# cases. No claude needed. Cites: misses-to-checks/REQ-36 misses-to-checks/REQ-39
ES="$WORK/esecond"; es_fail=""; mkdir -p "$ES/tree"
(cd "$ES/tree" && bash "$COPY/evals/escape/second-of-a-kind/fixture.sh" > "$ES/build.log" 2>&1) \
  || es_fail="$es_fail [the fixture failed: $(tail -2 "$ES/build.log" | tr '\n' '|' | cut -c1-200)]"
grep -q '^- \*\*REQ-3\.\*\* ' "$ES/tree/.shipkit/specs/refunds/spec.md" 2>/dev/null || es_fail="$es_fail [the spec holds no REQ-3]"
es_rec="$ES/tree/.shipkit/escapes/0001-refund-above-charge.md"
grep -q -F '`requirement missing`' "$es_rec" 2>/dev/null && grep -q -F '`.shipkit/specs/refunds/`' "$es_rec" 2>/dev/null \
  || es_fail="$es_fail [the record 0001 does not name the cause requirement missing and the spec .shipkit/specs/refunds/]"
grep -i -E 'negative|below zero|above zero|positive|less than' "$ES/tree/.shipkit/specs/refunds/spec.md" > "$ES/neg.out" 2>/dev/null \
  && es_fail="$es_fail [a requirement already speaks of a negative amount: $(head -1 "$ES/neg.out" | cut -c1-120)]"
[ -z "$(git -C "$ES/tree" status --porcelain 2>/dev/null)" ] && [ -d "$ES/tree/.git" ] || es_fail="$es_fail [the tree is not committed clean]"
(cd "$ES/tree" && python3 -m unittest discover -s tests > "$ES/test.out" 2>&1) || es_fail="$es_fail [the test command failed: $(tail -2 "$ES/test.out" | tr '\n' '|' | cut -c1-160)]"
(cd "$ES/tree" && python3 - > "$ES/py.out" 2>&1 <<'ESPY'
import sys
sys.path.insert(0, ".")
from app.refunds import RefundFailed, refund
class Gateway:
    def __init__(self):
        self.amounts = []
    def refund(self, customer, amount_cents):
        self.amounts.append(amount_cents)
        return "rf_1"
gateway = Gateway()
assert refund({"customer": "ada"}, -500, 2000, gateway) == "rf_1" and gateway.amounts == [-500], "refund did not accept an amount below zero"
try:
    refund({"customer": "ada"}, 2500, 2000, gateway)
except RefundFailed:
    pass
else:
    raise AssertionError("REQ-3 is not built: a refund above the charge went through")
ESPY
) || es_fail="$es_fail [$(tail -1 "$ES/py.out" | cut -c1-200)]"
es_sets=$(awk -F '\t' '$1 ~ /^(holdout-reviewer-(helper-only|skipped-test)|reviewer-(helper-only|skipped-test|comment-cite|weakened-req|waiver-added|second-round|stale-met|check-triggered)|escape-second-of-a-kind)$/ { n[$2]++ } END { printf "holdout=%d tune=%d", n["holdout"], n["tune"] }' "$ROOT/scripts/evals-map.tsv")
[ "$es_sets" = "holdout=2 tune=9" ] || es_fail="$es_fail [the map's sets for the eleven cases: $es_sets]"
[ "$(awk -F '\t' '$1 ~ /^holdout-/ && $2 != "holdout"' "$ROOT/scripts/evals-map.tsv" | grep -c .)" = 0 ] || es_fail="$es_fail [a holdout- case is not held out in the map]"
if [ -z "$es_fail" ]; then pass "escape-second (the tree is the first escape's, handled: REQ-3 built, the record 0001 names requirement missing and the refunds spec, and a negative refund still goes through with no requirement about it; the map holds two of the eleven cases out and tunes on nine)"
else failc "escape-second" "$es_fail"; fi

# 121. briefing-commands: what the briefing costs, counted and not timed. CI's runner read the
# same briefing at 0.41 to 1.02 s of CPU on unchanged scripts, so no time limit holds there
# (honest-evidence/design.md, seventh record), and this machine reads it slow under load. What
# the time is made of does not vary: the commands the briefing starts. On check 30's fixture
# that is 229: 29, and four for each open spec. Here the briefing runs with a PATH that holds
# only stand-ins for the thirteen programs it uses; each adds a line to a count and runs the
# real one, and a program not on the list is "command not found". The limit is the number
# itself and no switch is read, so CI enforces it. Two things show it can fail: fifty-one specs
# count four more, and a copy of the briefing with one command added counts one more; both are
# given to the verdict with CI=true and SMOKE_TIMING=report. No claude needed.
# Cites: misses-to-checks/REQ-43 misses-to-checks/REQ-44
BN="$WORK/bcount"; BNB="$COPY/scripts/briefing.sh"; mkdir -p "$BN/bin"; bn_fail=""
for bn_t in awk sed grep sort git tr tail sh rm mktemp ls dirname cut; do
  bn_real=$(command -v "$bn_t" 2>/dev/null)
  case "$bn_real" in /*) ;; *) bn_fail="$bn_fail [$bn_t was not found as a program]"; continue ;; esac
  printf '#!/bin/sh\necho %s >> "$BRIEF_COUNT"\nexec "%s" "$@"\n' "$bn_t" "$bn_real" > "$BN/bin/$bn_t"; chmod +x "$BN/bin/$bn_t"
done
bn_project() {  # bn_project <dir> <n> → n open specs, built as check 30 builds its fifty
  mkdir -p "$1"; (cd "$1" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init)
  _k=1; while [ "$_k" -le "$2" ]; do bspec "$1" "spec-$_k-with-a-rather-long-name-to-fill-the-line" open 1 4; _k=$((_k + 1)); done
}
bn_run() {  # bn_run <project> [briefing script] → bn_n: the commands the briefing starts there; its output is in <project>.out
  : > "$BN/count"
  (cd "$1" && BRIEF_COUNT="$BN/count" PATH="$BN/bin" /bin/sh "${2:-$BNB}" > "$1.out" 2> "$1.err"); _rc=$?
  [ "$_rc" -eq 0 ] && [ ! -s "$1.err" ] \
    || bn_fail="$bn_fail [$(basename "$1"): under the stand-ins the briefing exited $_rc and said: $(head -2 "$1.err" | tr '\n' '|' | cut -c1-200)]"
  bn_n=$(grep -c . "$BN/count")
}
bn_verdict() {  # bn_verdict <count> <the output is the plain run's: yes or no> → the one PASS or FAIL line; it reads no switch
  if [ "$2" = yes ] && [ "$1" -ge 1 ] && [ "$1" -le 229 ]; then
    pass "briefing-commands (50 open specs → the briefing starts $1 commands, limit 229, and prints what it prints with the whole PATH; 51 specs and one added command are each over the limit, on CI too)"
  else failc "briefing-commands" "50 specs: $1 commands started, want at most 229; the output is the plain run's: $2"; fi
}
bn_v() { ( COUNTS=/dev/null; CI=$1; SMOKE_TIMING=$2; export CI SMOKE_TIMING; bn_verdict "$3" yes ); }  # bn_v <CI> <SMOKE_TIMING> <count>
bn_project "$BN/p50" 50; bn_project "$BN/p51" 51
bn_run "$BN/p50"; bn_50=$bn_n
(cd "$BN/p50" && sh "$BNB" > "$BN/plain.out" 2>/dev/null)
if cmp -s "$BN/p50.out" "$BN/plain.out" && [ -s "$BN/plain.out" ]; then bn_same=yes; else bn_same=no; fi
bn_run "$BN/p51"; bn_51=$bn_n
cp -R "$COPY/scripts" "$BN/scripts-plus"
sed '1a\
ls . > /dev/null
' "$BNB" > "$BN/scripts-plus/briefing.sh"
cp -R "$BN/p50" "$BN/p50-plus"; bn_run "$BN/p50-plus" "$BN/scripts-plus/briefing.sh"; bn_plus=$bn_n
[ "$bn_51" -eq $((bn_50 + 4)) ] || bn_fail="$bn_fail [fifty-one specs: $bn_51 commands, want four more than fifty's $bn_50]"
[ "$bn_plus" -eq $((bn_50 + 1)) ] || bn_fail="$bn_fail [a briefing with one command added: $bn_plus commands, want one more than $bn_50]"
case "$(bn_v true report "$bn_51")" in "FAIL  briefing-commands"*) ;; *) bn_fail="$bn_fail [fifty-one specs' count, $bn_51, with CI=true and SMOKE_TIMING=report: not a FAIL]" ;; esac
case "$(bn_v true report "$bn_plus")" in "FAIL  briefing-commands"*) ;; *) bn_fail="$bn_fail [one added command's count, $bn_plus, with CI=true and SMOKE_TIMING=report: not a FAIL]" ;; esac
case "$(bn_v "" "" 230)" in "FAIL  briefing-commands"*"230 commands"*) ;; *) bn_fail="$bn_fail [230 with no switch: not a FAIL that carries the count]" ;; esac
case "$(bn_v true report 229)" in "PASS  briefing-commands"*"starts 229 commands"*) ;; *) bn_fail="$bn_fail [229 with CI=true and SMOKE_TIMING=report: not a PASS that carries the count]" ;; esac
if [ -n "$bn_fail" ]; then failc "briefing-commands" "$bn_fail [50 specs: $bn_50 commands]"
else bn_verdict "$bn_50" "$bn_same"; fi

# 122. kind-fixtures: which kind of test proves which requirement is measured before any text
# says so (the verifier plan's V16, "measure first"). scripts/kind-probe.sh writes the project the
# measurement runs on: an accepted spec, `passbook`, whose three requirements have three shapes
# (something that never happens, a round trip, a replacement that behaves as before), a design and
# no task list. It prints the headless commands and starts one only with its run flag, which this
# check never gives a real one. A stand-in first on the PATH shows that no model is called. The
# second fixture, `inkwell`, is for the migration skill: a library kept in the tree at two major
# versions, with the changelog between them, and tests that pass on the old one and fail on the
# new. The run flag is tried once for each fixture against a second stand-in that only records
# its call and prints a canned reply, so the loop Sprint 35 pays for has run before it is paid for.
# Cites: tests-worth-having/REQ-1 tests-worth-having/REQ-2 tests-worth-having/REQ-3 tests-worth-having/REQ-4 tests-worth-having/REQ-5 tests-worth-having/REQ-15 tests-worth-having/REQ-16 tests-worth-having/REQ-20
KP="$WORK/kind-probe"; mkdir -p "$KP/bin" "$KP/tmp"; kp_fail=""
kp_sh="$ROOT/scripts/kind-probe.sh"
printf '#!/bin/sh\ntouch "%s/claude-called"\nexit 1\n' "$KP" > "$KP/bin/claude"; chmod +x "$KP/bin/claude"
kp() { PATH="$KP/bin:$PATH" TMPDIR="$KP/tmp" sh "$kp_sh" "$@"; }
kp_tree() { find "$KP" -not -path '*/__pycache__*' | sort; }
kp --scaffold kinds "$KP/kinds" >/dev/null 2>&1; kp_rc=$?
[ "$kp_rc" -eq 0 ] || kp_fail="$kp_fail [--scaffold kinds: exit $kp_rc]"
[ "$(git -C "$KP/kinds" rev-list --count HEAD 2>/dev/null)" = 1 ] && [ -z "$(git -C "$KP/kinds" status --porcelain 2>/dev/null)" ] \
  || kp_fail="$kp_fail [kinds: not one commit with a clean tree]"
kp_spec="$KP/kinds/.shipkit/specs/passbook"
grep -q '^> Spec accepted at commit ' "$kp_spec/spec.md" 2>/dev/null && grep -qx '> Status: open' "$kp_spec/spec.md" 2>/dev/null \
  && [ -f "$kp_spec/design.md" ] || kp_fail="$kp_fail [kinds: the spec lacks its stamp, Status: open or design.md]"
[ -e "$kp_spec/tasks.md" ] && kp_fail="$kp_fail [kinds: the spec already has a tasks.md]"
[ "$(grep -c '^- \*\*REQ-[0-9][0-9]*\.\*\*' "$kp_spec/spec.md" 2>/dev/null)" = 3 ] || kp_fail="$kp_fail [kinds: not three requirements]"
kp_req() { grep "^- \\*\\*REQ-$1\\.\\*\\*" "$kp_spec/spec.md" 2>/dev/null | grep -qF "$2" || kp_fail="$kp_fail [kinds: REQ-$1 does not hold \"$2\"]"; }
kp_req 1 'the balance shall never be negative'
kp_req 2 'an exported file shall import to the same records'
kp_req 3 'after the move to the new parser, every stored document shall render as before'
kp_cmd=$(sh "$COPY/scripts/test-command.sh" "$KP/kinds" 2>/dev/null)
[ -n "$kp_cmd" ] && (cd "$KP/kinds" && sh -c "$kp_cmd") >/dev/null 2>&1 \
  || kp_fail="$kp_fail [kinds: no recorded test command, or it does not exit 0: ${kp_cmd:-none}]"
kp_head=$(git -C "$KP/kinds" rev-parse HEAD 2>/dev/null)
kp --scaffold kinds "$KP/kinds" >/dev/null 2>&1; kp_rc=$?
[ "$kp_rc" -eq 2 ] && [ "$(git -C "$KP/kinds" rev-parse HEAD 2>/dev/null)" = "$kp_head" ] && [ -z "$(git -C "$KP/kinds" status --porcelain 2>/dev/null)" ] \
  || kp_fail="$kp_fail [--scaffold into the fixture again: exit $kp_rc, not 2, or the tree changed]"
mkdir -p "$KP/held"; echo kept > "$KP/held/note.txt"
kp --scaffold kinds "$KP/held" >/dev/null 2>&1; kp_rc=$?
[ "$kp_rc" -eq 2 ] && [ "$(ls -A "$KP/held" | tr '\n' ' ')" = "note.txt " ] \
  || kp_fail="$kp_fail [--scaffold into a directory that holds a file: exit $kp_rc, not 2, or something was written]"
kp_before=$(kp_tree)
kp_out=$(cd "$KP" && kp --run kinds 2>/dev/null); kp_rc=$?
[ "$kp_rc" -eq 0 ] && [ "$(printf '%s\n' "$kp_out" | grep -c .)" = 5 ] && [ "$(printf '%s\n' "$kp_out" | grep -cF '/shipkit:spec passbook tasks')" = 5 ] \
  || kp_fail="$kp_fail [--run kinds: exit $kp_rc, or not 5 lines that each hold the request]"
kp_out2=$(cd "$KP" && kp --run kinds 2 2>/dev/null); kp_rc=$?
[ "$kp_rc" -eq 0 ] && [ "$(printf '%s\n' "$kp_out2" | grep -c .)" = 2 ] && [ "$(printf '%s\n' "$kp_out2" | grep -cF '/shipkit:spec passbook tasks')" = 2 ] \
  || kp_fail="$kp_fail [--run kinds 2: exit $kp_rc, or not 2 lines that each hold the request]"
[ "$(kp_tree)" = "$kp_before" ] || kp_fail="$kp_fail [--run without its flag wrote a file]"
kp_bad() {  # kp_bad <what> <args>...: usage on standard error, nothing on standard output, exit 2
  kp_what=$1; shift
  kp_o=$(kp "$@" 2>"$KP/err"); kp_rc=$?
  [ "$kp_rc" -eq 2 ] && [ -z "$kp_o" ] && grep -qF 'kind-probe.sh --scaffold' "$KP/err" \
    || kp_fail="$kp_fail [$kp_what: exit $kp_rc, not 2 with the usage on standard error]"
}
kp_bad "an unknown mode" --frobnicate
kp_bad "no arguments"
kp_bad "an unknown fixture to --scaffold" --scaffold nosuch "$KP/nosuch"
kp_bad "an unknown fixture to --run" --run nosuch
[ -e "$KP/nosuch" ] && kp_fail="$kp_fail [an unknown fixture still made its directory]"
kp --scaffold migration "$KP/mig" >/dev/null 2>&1; kp_rc=$?
[ "$kp_rc" -eq 0 ] || kp_fail="$kp_fail [--scaffold migration: exit $kp_rc]"
[ "$(git -C "$KP/mig" rev-list --count HEAD 2>/dev/null)" = 1 ] && [ -z "$(git -C "$KP/mig" status --porcelain 2>/dev/null)" ] \
  || kp_fail="$kp_fail [migration: not one commit with a clean tree]"
[ -f "$KP/mig/vendor/textkit-1/textkit.py" ] && [ -f "$KP/mig/vendor/textkit-2/textkit.py" ] && [ -f "$KP/mig/vendor/textkit-2/CHANGELOG.md" ] \
  || kp_fail="$kp_fail [migration: the library is not there at two versions with its changelog]"
[ -e "$KP/mig/.shipkit/specs" ] && kp_fail="$kp_fail [migration: the fixture holds a spec]"
for kp_f in wrap title; do
  grep -qF "\`$kp_f()\`" "$KP/mig/vendor/textkit-2/CHANGELOG.md" 2>/dev/null && grep -qF "textkit.$kp_f(" "$KP/mig/inkwell/format.py" 2>/dev/null \
    || kp_fail="$kp_fail [migration: the changelog does not name $kp_f(), or inkwell/format.py does not call it]"
done
kp_cmd=$(sh "$COPY/scripts/test-command.sh" "$KP/mig" 2>/dev/null)
[ -n "$kp_cmd" ] && (cd "$KP/mig" && sh -c "$kp_cmd") >/dev/null 2>&1 \
  || kp_fail="$kp_fail [migration: no recorded test command, or it does not exit 0 on the old version: ${kp_cmd:-none}]"
# A second, fresh copy, and not a copy of the first: that one holds the bytecode of the run
# above, and a deps.py rewritten within the same second, at the same size, would not be re-read.
kp --scaffold migration "$KP/mig-new" >/dev/null 2>&1
sed 's/textkit-1/textkit-2/' "$KP/mig/inkwell/deps.py" > "$KP/mig-new/inkwell/deps.py" 2>/dev/null
cmp -s "$KP/mig/inkwell/deps.py" "$KP/mig-new/inkwell/deps.py" && kp_fail="$kp_fail [migration: inkwell/deps.py does not name the old version's folder]"
(cd "$KP/mig-new" && sh -c "${kp_cmd:-false}") >/dev/null 2>&1 \
  && kp_fail="$kp_fail [migration: the tests pass on the new version too, so no behaviour the code depends on changed]"
rm -rf "$KP/mig-new"
kp_before=$(kp_tree)
kp_out=$(cd "$KP" && kp --run migration 2>/dev/null); kp_rc=$?
[ "$kp_rc" -eq 0 ] && [ "$(printf '%s\n' "$kp_out" | grep -c .)" = 3 ] && [ "$(printf '%s\n' "$kp_out" | grep -cF '/shipkit-workflows:migration-plan')" = 3 ] \
  || kp_fail="$kp_fail [--run migration: exit $kp_rc, or not 3 lines that each hold the request]"
[ "$(kp_tree)" = "$kp_before" ] || kp_fail="$kp_fail [--run migration without its flag wrote a file]"
[ -e "$KP/claude-called" ] && kp_fail="$kp_fail [a model was called]"
# The run flag, against a stand-in that records where it was started and with what, and prints
# a reply in the form a headless session's JSON result has.
mkdir -p "$KP/bin2"
printf '{"type":"result","subtype":"success","result":"Step 1: write the comparison.\\n\\nStep 2: move to 2.0."}\n' > "$KP/reply.json"
printf '#!/bin/sh\npwd -P >> "%s/yes-cwd"\nprintf "%%s\\n" "$*" >> "%s/yes-args"\ncat "%s/reply.json"\n' "$KP" "$KP" "$KP" > "$KP/bin2/claude"; chmod +x "$KP/bin2/claude"
kpy() { PATH="$KP/bin2:$PATH" TMPDIR="$KP/tmp" sh "$kp_sh" "$@"; }
kpy --run kinds 1 --yes --out "$KP/yes-kinds" >/dev/null 2>&1; kp_rc=$?
[ "$kp_rc" -eq 0 ] && [ -f "$KP/yes-kinds/run-1/proj/.shipkit/specs/passbook/spec.md" ] && [ -s "$KP/yes-kinds/run-1/result.json" ] \
  || kp_fail="$kp_fail [--run kinds 1 with the run flag: exit $kp_rc, or no fixture and result under run-1]"
kpy --run migration 2 --yes --out "$KP/yes-mig" >/dev/null 2>&1; kp_rc=$?
[ "$kp_rc" -eq 0 ] && [ -f "$KP/yes-mig/run-2/proj/vendor/textkit-2/CHANGELOG.md" ] \
  && [ "$(cat "$KP/yes-mig/run-2/plan.md" 2>/dev/null | tr '\n' '|')" = "Step 1: write the comparison.||Step 2: move to 2.0.|" ] \
  || kp_fail="$kp_fail [--run migration 2 with the run flag: exit $kp_rc, or run-2 lacks its fixture or its plan.md is not the reply's text]"
[ "$(grep -c . "$KP/yes-cwd" 2>/dev/null)" = 3 ] && [ "$(sed -n 1p "$KP/yes-cwd" 2>/dev/null)" = "$(cd "$KP/yes-kinds/run-1/proj" 2>/dev/null && pwd -P)" ] \
  || kp_fail="$kp_fail [with the run flag: not three starts, the first in run-1's fixture]"
[ "$(grep -cF '/shipkit:spec passbook tasks' "$KP/yes-args" 2>/dev/null)" = 1 ] && [ "$(grep -cF '/shipkit-workflows:migration-plan textkit 1.4 2.0' "$KP/yes-args" 2>/dev/null)" = 2 ] \
  || kp_fail="$kp_fail [with the run flag: the stand-in was not given the two requests]"
if [ -z "$kp_fail" ]; then pass "kind-fixtures (kind-probe.sh scaffolds the passbook spec, three requirements, a design and no task list, and the inkwell project, a library at two versions whose tests pass on the old and fail on the new; prints 5 and 3 commands, or the number asked for, and starts none; with its run flag and a stand-in it runs each in a fresh fixture and keeps the reply)"
else failc "kind-fixtures" "$kp_fail"; fi

# 123. kind-reader: kind-probe.sh --read says which kind of test each task's Test: line names for
# the passbook spec's three requirements, and whether that is an expected kind. A tag at the
# start of the line settles it; without one a short list of words does. Six task lists written
# by hand, two for each kind, are kept in scripts/kind-replies/: one that names the kind and one
# that does not. A seventh, made here, has a ticked task whose header runs over two lines, a tag
# in capitals and words in capitals. --read-plan says whether a migration plan holds a step that
# runs the old and the new version on the same inputs and compares them: the words must be in one
# block of the plan, and two plans written by hand, one with such a step and one without, are kept
# beside the task lists.
# Cites: tests-worth-having/REQ-7 tests-worth-having/REQ-8 tests-worth-having/REQ-9 tests-worth-having/REQ-10 tests-worth-having/REQ-11 tests-worth-having/REQ-12 tests-worth-having/REQ-13 tests-worth-having/REQ-14 tests-worth-having/REQ-18 tests-worth-having/REQ-19
KR="$WORK/kind-reader"; mkdir -p "$KR/one"; kr_fail=""
kr_sh="$ROOT/scripts/kind-probe.sh"
kr_want=$(tr '|' '\t' <<'KREOF'
differential-named/tasks.md|REQ-1|property|right
differential-named/tasks.md|REQ-2|property|right
differential-named/tasks.md|REQ-3|differential|right
differential-unnamed/tasks.md|REQ-1|uncited|missed
differential-unnamed/tasks.md|REQ-2|e2e|right
differential-unnamed/tasks.md|REQ-3|none|missed
e2e-named/tasks.md|REQ-1|property|right
e2e-named/tasks.md|REQ-2|e2e|right
e2e-named/tasks.md|REQ-3|differential|right
e2e-unnamed/tasks.md|REQ-1|property|right
e2e-unnamed/tasks.md|REQ-2|none|missed
e2e-unnamed/tasks.md|REQ-3|property|missed
property-named/tasks.md|REQ-1|property|right
property-named/tasks.md|REQ-2|e2e+property|right
property-named/tasks.md|REQ-3|differential|right
property-unnamed/tasks.md|REQ-1|none|missed
property-unnamed/tasks.md|REQ-2|property|right
property-unnamed/tasks.md|REQ-3|differential|right
TOTAL REQ-1 right=4 missed=2
TOTAL REQ-2 right=5 missed=1
TOTAL REQ-3 right=4 missed=2
KREOF
)
kr_out=$(sh "$kr_sh" --read "$ROOT/scripts/kind-replies" 2>&1); kr_rc=$?
[ "$kr_rc" -eq 0 ] || kr_fail="$kr_fail [--read: exit $kr_rc]"
[ "$kr_out" = "$kr_want" ] || kr_fail="$kr_fail [--read on the six task lists: $(printf '%s\n' "$kr_out" | tr '\t\n' ' |' | cut -c1-600)]"
cat > "$KR/one/tasks.md" <<'KREOF'
# Tasks: passbook

- [x] **T1** The new parser takes over, and what the stored statements show
  does not change → REQ-3
  - Files: passbook/statements.py
  - Test: An END-TO-END run of Both Parsers over data/statements/
  - After: none
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T2** Withdrawals → REQ-1
  - Files: passbook/account.py
  - Test: [PROPERTY] tests/test_account.py, end-to-end it is not
  - After: T1
  - Done when: `python3 -m unittest -q` → all pass
KREOF
kr_one=$(sh "$kr_sh" --read "$KR/one" 2>&1 | tr '\t\n' ' |')
[ "$kr_one" = "tasks.md REQ-1 property right|tasks.md REQ-2 uncited missed|tasks.md REQ-3 e2e+differential right|TOTAL REQ-1 right=1 missed=0|TOTAL REQ-2 right=0 missed=1|TOTAL REQ-3 right=1 missed=0|" ] \
  || kr_fail="$kr_fail [--read on a ticked task with a wrapped header, a tag and words in capitals: $kr_one]"
kr_none=$(sh "$kr_sh" --read "$KR/no-such-directory" 2>"$KR/err"); kr_rc=$?
[ "$kr_rc" -eq 2 ] && [ -z "$kr_none" ] && [ -s "$KR/err" ] || kr_fail="$kr_fail [--read on a directory that is not there: exit $kr_rc, not 2 with a line on standard error]"
kr_plans=$(cd "$ROOT/scripts/kind-replies" && sh "$kr_sh" --read-plan plan-differential.md plan-none.md 2>&1 | tr '\t\n' ' |'); kr_rc=$?
[ "$kr_plans" = "plan-differential.md differential|plan-none.md none|" ] \
  || kr_fail="$kr_fail [--read-plan on the two hand-written plans: $kr_plans]"
printf 'Step 1: add tests.\n\nStep 2: run both versions on the SAME INPUTS and keep the output.\n' > "$KR/a.md"
printf 'Step 1: keep the old and new library side by side.\n\nStep 2: compare the notes by eye.\n' > "$KR/b.md"
printf 'Step 1: record golden output before the upgrade.\n' > "$KR/c.md"
: > "$KR/d.md"
kr_plans=$(cd "$KR" && sh "$kr_sh" --read-plan a.md b.md c.md d.md 2>&1 | tr '\t\n' ' |')
[ "$kr_plans" = "a.md differential|b.md none|c.md differential|d.md none|" ] \
  || kr_fail="$kr_fail [--read-plan: both phrases in one block, the phrases in two blocks, one word alone, an empty file: $kr_plans]"
kr_none=$(cd "$KR" && sh "$kr_sh" --read-plan a.md no-such-plan.md 2>"$KR/err"); kr_rc=$?
[ "$kr_rc" -eq 2 ] && [ -z "$kr_none" ] && [ -s "$KR/err" ] || kr_fail="$kr_fail [--read-plan with a file that is not there: exit $kr_rc, not 2 with nothing printed and a line on standard error]"
if [ -z "$kr_fail" ]; then pass "kind-reader (--read gives the eighteen lines and three totals expected of the six hand-written task lists: a tag settles a line, words name a kind without one, two kinds are joined, a requirement no task cites is uncited, and either kind is right for the round trip; --read-plan finds a differential step only where one block of the plan holds it)"
else failc "kind-reader" "$kr_fail"; fi

# 124. prop: spec-check.sh and brief.sh each read a task list with their own awk, and every other
# check here feeds them inputs a person thought of. scripts/prop.py checks five properties of the
# two on specs that Hypothesis generates, the same ones on every run: they agree on each task's
# files; spec-check.sh changes nothing and says the same twice; a new citation never adds a gap;
# a citation taken away adds exactly one MISSING-TEST; and the brief copies a requirement byte for
# byte. Here it runs on five inputs for each property (CI's own step runs forty), and each
# property is shown to fail on a copy of the script broken in the way it is meant to catch.
# Hypothesis comes from uv when uv is there, as lint.sh gets PyYAML, and from python3 otherwise.
# Cites: tests-worth-having/REQ-26 tests-worth-having/REQ-27 tests-worth-having/REQ-28 tests-worth-having/REQ-29 tests-worth-having/REQ-30
PR="$WORK/prop"; mkdir -p "$PR/broken" "$PR/nohyp" "$PR/cwd"; pr_fail=""
pr_py="$ROOT/scripts/prop.py"
pr_ver=$(sed -n 's/^HYPOTHESIS = "\(.*\)"$/\1/p' "$pr_py" 2>/dev/null)
if command -v uv >/dev/null 2>&1; then prop() { (cd "$PR/cwd" && uv run --quiet --with "hypothesis==$pr_ver" python3 "$pr_py" "$@"); }
else prop() { (cd "$PR/cwd" && python3 "$pr_py" "$@"); }; fi
pr_status=$(git -C "$ROOT" status --porcelain 2>/dev/null)
pr_out=$(prop --max-examples 5 --spec-check "$COPY/scripts/spec-check.sh" --brief "$COPY/scripts/brief.sh" 2>&1); pr_rc=$?
[ "$pr_rc" -eq 0 ] || pr_fail="$pr_fail [prop.py on this checkout's scripts: exit $pr_rc]"
for pr_n in agreement no-side-effect monotone exactly-one round-trip; do
  printf '%s\n' "$pr_out" | grep -q "^PASS $pr_n " || pr_fail="$pr_fail [no PASS line for $pr_n]"
done
[ -z "$(ls -A "$PR/cwd")" ] || pr_fail="$pr_fail [prop.py wrote into its working directory: $(ls -A "$PR/cwd" | tr '\n' ' ')]"
[ "$(git -C "$ROOT" status --porcelain 2>/dev/null)" = "$pr_status" ] || pr_fail="$pr_fail [prop.py changed the repository's status]"
ls -d "${TMPDIR:-/tmp}"/shipkit-prop.* >/dev/null 2>&1 && pr_fail="$pr_fail [prop.py left its temporary directory behind]"
pr_break() {  # pr_break <property> <script> <sed expression>: the property fails on the broken copy
  cp "$COPY/scripts/spec-check.sh" "$COPY/scripts/brief.sh" "$PR/broken/"
  sed "$3" "$COPY/scripts/$2" > "$PR/broken/$2"
  if cmp -s "$COPY/scripts/$2" "$PR/broken/$2"; then pr_fail="$pr_fail [$1: the break changed nothing in $2]"; return; fi
  pr_o=$(prop --only "$1" --no-shrink --spec-check "$PR/broken/spec-check.sh" --brief "$PR/broken/brief.sh" 2>&1); pr_rc=$?
  [ "$pr_rc" -eq 1 ] && printf '%s\n' "$pr_o" | grep -qx "FAIL $1" && printf '%s\n' "$pr_o" | grep -q '^--- \.shipkit/specs/.*/spec\.md$' \
    || pr_fail="$pr_fail [$1 on a broken $2: exit $pr_rc, not 1 with FAIL $1 and the input: $(printf '%s' "$pr_o" | sed -n 1,3p | tr '\n' '|' | cut -c1-200)]"
}
pr_break agreement spec-check.sh 's/function trim(s) { gsub(\/`\/, "", s); /function trim(s) { /'
pr_break no-side-effect spec-check.sh 's|^TMP=\$(mktemp|: > "$PROJ/left-behind"; &|'
pr_break monotone spec-check.sh 's/(order\[i\] in cit ? "C" : "-")/(order[i] in cit ? "-" : "C")/'
pr_break exactly-one spec-check.sh 's/echo "MISSING-TEST \$slug REQ-\$n"/&; &/'
pr_break round-trip brief.sh '/^requirement() {/,/^}/ s/on { print }/on { print; exit }/'
pr_again=$(prop --only round-trip --no-shrink --spec-check "$PR/broken/spec-check.sh" --brief "$PR/broken/brief.sh" 2>&1)
[ -n "$pr_o" ] && [ "$pr_again" = "$pr_o" ] || pr_fail="$pr_fail [two runs at one broken copy did not print the same lines]"
printf 'raise ImportError("no Hypothesis here")\n' > "$PR/nohyp/hypothesis.py"
pr_o=$(PYTHONPATH="$PR/nohyp" prop 2>&1); pr_rc=$?
[ "$pr_rc" -eq 2 ] && [ "$(printf '%s\n' "$pr_o" | grep -c .)" = 1 ] \
  && printf '%s\n' "$pr_o" | grep -qF "uv run --with hypothesis==$pr_ver python3 scripts/prop.py" \
  || pr_fail="$pr_fail [without Hypothesis: exit $pr_rc, not 2 with the one line that names the uv command: $(printf '%s' "$pr_o" | sed -n 1,2p | tr '\n' '|' | cut -c1-200)]"
if [ -z "$pr_fail" ]; then pass "prop (prop.py: the five properties hold on this checkout's spec-check.sh and brief.sh, on five generated inputs each; each fails on a copy broken for it, with the input printed; two runs print the same; without Hypothesis it names the uv command and exits 2; it writes nothing outside its own temporary directory)"
else failc "prop" "$pr_fail"; fi

# 125. prop-ci: both of CI's jobs run the five properties, since the two runners do not ship the
# same awk and users run the scripts on both (the owner's answer, 2026-11-20). Each job installs
# Hypothesis at the version prop.py is written for and runs it. The reading is shown to fail on a
# copy of the workflow that lacks one job's run step, and on one that installs another version.
# Cites: tests-worth-having/REQ-31
PC="$WORK/prop-ci"; mkdir -p "$PC"; pc_fail=""
pc_ver=$(sed -n 's/^HYPOTHESIS = "\(.*\)"$/\1/p' "$ROOT/scripts/prop.py" 2>/dev/null)
pc_read() {  # pc_read <workflow file> → one line for each thing a job lacks
  for pc_j in lint smoke-no-model; do
    pc_job=$(awk -v j="  $pc_j:" '$0 == j { on = 1; next } on && /^  [a-z]/ { on = 0 } on' "$1")
    printf '%s\n' "$pc_job" | grep -qxF "        run: pip install --quiet hypothesis==$pc_ver" || echo "$pc_j: no step installs hypothesis==$pc_ver"
    printf '%s\n' "$pc_job" | grep -qxF '        run: python3 scripts/prop.py' || echo "$pc_j: no step runs prop.py"
  done
}
[ -n "$pc_ver" ] || pc_fail="$pc_fail [prop.py names no version of Hypothesis]"
pc_miss=$(pc_read "$ROOT/.github/workflows/lint.yml")
[ -z "$pc_miss" ] || pc_fail="$pc_fail [lint.yml: $(printf '%s' "$pc_miss" | tr '\n' ';')]"
awk '/^  smoke-no-model:$/ { seen = 1 } !seen && /^        run: python3 scripts\/prop\.py$/ { next } { print }' "$ROOT/.github/workflows/lint.yml" > "$PC/no-run.yml"
[ "$(pc_read "$PC/no-run.yml")" = "lint: no step runs prop.py" ] \
  || pc_fail="$pc_fail [a workflow whose lint job does not run prop.py reads: $(pc_read "$PC/no-run.yml" | tr '\n' ';')]"
sed "s/hypothesis==$pc_ver/hypothesis==0.0.1/" "$ROOT/.github/workflows/lint.yml" > "$PC/other.yml"
[ "$(pc_read "$PC/other.yml" | grep -c 'no step installs')" = 2 ] \
  || pc_fail="$pc_fail [a workflow that installs another version reads: $(pc_read "$PC/other.yml" | tr '\n' ';')]"
if [ -z "$pc_fail" ]; then pass "prop-ci (both CI jobs install Hypothesis $pc_ver, the version prop.py is written for, and run prop.py; a workflow without one job's step, or with another version, is read as lacking it)"
else failc "prop-ci" "$pc_fail"; fi

# 126. red-check: nothing showed that a new test was ever red. red-check.sh runs the project's
# suite on a scratch worktree of the base ref, once as the base has it and once with the
# branch's citing test files copied in. A test that needs the feature fails there (RED-AT-BASE);
# one that asserts nothing passes (GREEN-AT-BASE); a base that cannot run its own suite is said
# so and not judged (BASE-NOT-RUNNABLE); and with no citing test that differs from the base
# nothing is run (NO-TESTS). It is run by hand, exits 0 whatever the word, and leaves the
# project and git as they were, also when it is stopped half way. The scratch project's suite is
# a shell script, so the check needs no language but sh.
# Cites: tests-worth-having/REQ-32 tests-worth-having/REQ-33 tests-worth-having/REQ-34 tests-worth-having/REQ-35 tests-worth-having/REQ-36 tests-worth-having/REQ-37 tests-worth-having/REQ-38 tests-worth-having/REQ-39 tests-worth-having/REQ-40 tests-worth-having/REQ-41 tests-worth-having/REQ-42
RC="$WORK/red-check"; mkdir -p "$RC/p/tests" "$RC/p/deps" "$RC/tmp" "$RC/plain"; rc_fail=""
rc_sh="$COPY/scripts/red-check.sh"
rc_git() { git -C "$RC/p" -c user.email=s@s -c user.name=smoke -c commit.gpgsign=false "$@"; }
rc_spec() {  # rc_spec <slug> [<a line under the stamp>]: a spec with two requirements
  mkdir -p "$RC/p/.shipkit/specs/$1"
  { printf '# Spec: %s\n\n> Spec accepted at commit `abc1234` on main.\n> Status: open\n' "$1"
    [ -z "$2" ] || printf '%s\n' "$2"
    printf '\n## Requirements (EARS)\n- **REQ-1.** The thing shall shout.\n- **REQ-2.** The thing shall stay.\n'; } > "$RC/p/.shipkit/specs/$1/spec.md"
}
(cd "$RC/p" && git init -q)
printf 'greet() { echo hello; }\n' > "$RC/p/lib.sh"
printf '[ -z "$RC_COUNT" ] || echo run >> "$RC_COUNT"\necho "suite: running"\nfor t in tests/*.sh; do sh "$t" || exit 1; done\n' > "$RC/p/run-tests.sh"
printf '# old/REQ-1\n. ./lib.sh\n[ "$(greet)" = hello ]\n' > "$RC/p/tests/base.sh"
printf 'deps/\n.claude/\n' > "$RC/p/.gitignore"
printf 'helper\n' > "$RC/p/deps/helper.sh"
rc_spec old
rc_git add -A >/dev/null 2>&1; rc_git commit -q -m base >/dev/null 2>&1; rc_git branch base >/dev/null 2>&1
printf '# feat/REQ-1 is cited here too, outside the tests\ngreet() { echo hello; }\nshout() { echo HELLO; }\n' > "$RC/p/lib.sh"
printf '# feat/REQ-1\n. ./lib.sh\n[ "$(shout)" = HELLO ]\n' > "$RC/p/tests/feat.sh"
printf '# vac/REQ-1\ntrue\n' > "$RC/p/tests/vacuous.sh"
rc_spec feat '> Tests: tests/'; rc_spec vac; rc_spec none
rc_git add -A >/dev/null 2>&1; rc_git commit -q -m feature >/dev/null 2>&1
git -C "$RC/p" worktree add -q "$RC/theirs" base >/dev/null 2>&1
rc_run() { TMPDIR="$RC/tmp" RC_COUNT="$RC/count" sh "$rc_sh" "$@"; }
rc_runs() { grep -c . "$RC/count" 2>/dev/null || true; }
rc_state() { rc_git status --porcelain; rc_git branch; rc_git stash list; rc_git worktree list; rc_git rev-parse HEAD; }
rc_clean() { [ -z "$(ls -A "$RC/tmp")" ] || rc_fail="$rc_fail [$1: something is left in the temporary directory: $(ls -A "$RC/tmp" | tr '\n' ' ')]"; }
rc_is() {  # rc_is <what> <want on standard output, lines joined by |> <want exit> <args>...
  rc_what=$1; rc_want=$2; rc_code=$3; shift 3
  rc_out=$(rc_run "$@" 2>"$RC/err" | tr '\n' '|'); rc_out_rc=$(rc_run "$@" >/dev/null 2>&1; echo $?)
  [ "$rc_out" = "$rc_want" ] && [ "$rc_out_rc" = "$rc_code" ] \
    || rc_fail="$rc_fail [$rc_what: \"$rc_out\" exit $rc_out_rc, want \"$rc_want\" exit $rc_code; standard error: $(sed -n 1,2p "$RC/err" | tr '\n' '|' | cut -c1-160)]"
  rc_clean "$rc_what"
}
rc_before=$(rc_state)
: > "$RC/count"
rc_is "a test that needs the feature" "TEST tests/feat.sh|RED-AT-BASE|" 0 "$RC/p" feat base --test 'sh run-tests.sh'
[ "$(rc_runs)" = 4 ] || rc_fail="$rc_fail [a red reading took $(rc_runs) runs of the suite over two calls, not 4]"
grep -q '^suite: running$' "$RC/err" || rc_fail="$rc_fail [the suite's output is not on standard error]"
rc_is "a test that asserts nothing" "TEST tests/vacuous.sh|GREEN-AT-BASE tests/vacuous.sh|" 0 "$RC/p" vac base --test 'sh run-tests.sh'
: > "$RC/count"
rc_is "a suite that fails at the base" "TEST tests/feat.sh|BASE-NOT-RUNNABLE|" 0 "$RC/p" feat base --test 'echo run >> "$RC_COUNT"; false'
[ "$(rc_runs)" = 2 ] || rc_fail="$rc_fail [a base that cannot run was run $(rc_runs) times over two calls, not 2]"
: > "$RC/count"
rc_is "a spec no file cites" "NO-TESTS|" 0 "$RC/p" none base --test 'sh run-tests.sh'
rc_is "a citing test the branch did not touch" "NO-TESTS|" 0 "$RC/p" old base --test 'sh run-tests.sh'
[ "$(rc_runs)" = 0 ] || rc_fail="$rc_fail [with no test to judge the suite was still run]"
sh "$COPY/scripts/spec-check.sh" "$RC/p" feat 2>/dev/null | grep -qx 'CITED-ELSEWHERE feat REQ-1 lib.sh' \
  || rc_fail="$rc_fail [spec-check.sh does not call lib.sh CITED-ELSEWHERE, so the two searches are not compared]"
printf '# feat/REQ-2\n. ./lib.sh\n[ "$(shout)" = HELLO ]\n' > "$RC/p/tests/new.sh"
rc_is "an untracked citing test" "TEST tests/feat.sh|TEST tests/new.sh|RED-AT-BASE|" 0 "$RC/p" feat base --test 'sh run-tests.sh'
rm -f "$RC/p/tests/new.sh"
rc_is "no test command at all" "" 2 "$RC/p" feat base
sh "$COPY/scripts/test-command.sh" "$RC/p" --record 'sh run-tests.sh' >/dev/null 2>&1
rc_is "the recorded test command" "TEST tests/feat.sh|RED-AT-BASE|" 0 "$RC/p" feat base
rc_is "a suite that needs a folder git does not track, without --link" "TEST tests/feat.sh|BASE-NOT-RUNNABLE|" 0 "$RC/p" feat base --test 'test -L deps && sh run-tests.sh'
rc_is "the same with --link" "TEST tests/feat.sh|RED-AT-BASE|" 0 "$RC/p" feat base --test 'test -L deps && test -f deps/helper.sh && sh run-tests.sh' --link deps
[ -f "$RC/p/deps/helper.sh" ] && [ ! -L "$RC/p/deps" ] || rc_fail="$rc_fail [--link: the project's own folder was removed or replaced]"
rc_is "--link with a file" "" 2 "$RC/p" feat base --test true --link run-tests.sh
rc_is "--link with a folder git tracks at the base" "" 2 "$RC/p" feat base --test true --link tests
rc_is "--link with a name that is not there" "" 2 "$RC/p" feat base --test true --link nosuch
rc_is "no arguments" "" 2
rc_is "an unknown ref" "" 2 "$RC/p" feat no-such-ref --test true
rc_is "a directory that is no repository" "" 2 "$RC/plain" feat base --test true
rc_is "an unknown slug" "" 2 "$RC/p" no-such-spec base --test true
rc_is "an unknown option" "" 2 "$RC/p" feat base --frobnicate
# Stopped half way: the suite sleeps, the script gets TERM, and nothing of it is left.
TMPDIR="$RC/tmp" sh "$rc_sh" "$RC/p" feat base --test 'sleep 30' > "$RC/sig.out" 2>/dev/null &
rc_pid=$!; rc_i=0
while [ "$rc_i" -lt 100 ] && ! ls "$RC/tmp"/shipkit-red.*/tree/run-tests.sh >/dev/null 2>&1; do sleep 0.1; rc_i=$((rc_i + 1)); done
ls "$RC/tmp"/shipkit-red.*/tree/run-tests.sh >/dev/null 2>&1 || rc_fail="$rc_fail [stopped half way: the scratch tree never appeared]"
kill -TERM "$rc_pid" 2>/dev/null; wait "$rc_pid" 2>/dev/null; rc_code=$?
[ "$rc_code" -eq 130 ] && [ "$(tr '\n' '|' < "$RC/sig.out")" = "TEST tests/feat.sh|" ] \
  || rc_fail="$rc_fail [stopped half way: exit $rc_code, not 130 with the TEST line and no word after it: $(tr '\n' '|' < "$RC/sig.out")]"
rc_clean "stopped half way"
[ "$(rc_state)" = "$rc_before" ] || rc_fail="$rc_fail [git reads differently after the runs: $(rc_state | tr '\n' '|' | cut -c1-300)]"
[ -f "$RC/theirs/lib.sh" ] || rc_fail="$rc_fail [a worktree the check made was removed]"
if [ -z "$rc_fail" ]; then pass "red-check (a test that needs the feature is RED-AT-BASE, one that asserts nothing GREEN-AT-BASE, a base that cannot run BASE-NOT-RUNNABLE after one run, no differing citing test NO-TESTS with no run; the citing files are spec-check.sh's, untracked ones too; --link shares only the folders named; every other call is exit 2 with no word; the project, git and a worktree of the check's own are as they were, also after TERM)"
else failc "red-check" "$rc_fail"; fi

# 127. brief-escapes: brief.sh printed a task's Test and Done when lines with echo, and sh reads
# escapes there: a \n became a line break, a \t a tab, \\ one backslash and \b a backspace byte
# (found 2026-11-20, tests-worth-having's "Found on the way"). The agent got a command that was
# not the one in tasks.md. Both lines now come out as written, byte for byte, and so does the
# title line at the top of the brief, which was printed with echo too.
# Cites: tests-worth-having/REQ-51 tests-worth-having/REQ-52
BE="$WORK/brief-escapes"; mkdir -p "$BE/.shipkit/specs/esc"; be_fail=""
be_test='tests/t.sh: printf '"'"'one\ntwo\tthree\\four'"'"' and grep -E '"'"'\bword\b'"'"''
be_done='`sh run.sh` prints a\nb and \c stops nothing'
be_title='Copy a\tb, c\\d and \c'
{ printf '# Spec: Esc\n\n> Spec accepted at commit `abc1234` on main.\n> Status: open\n\n'
  printf '## Purpose\nA line is copied as written.\n\n## Requirements (EARS)\n- **REQ-1.** The thing shall copy.\n\n## Out of scope\nNothing.\n'
} > "$BE/.shipkit/specs/esc/spec.md"
{ printf '# Tasks: Esc\n\n- [ ] **T1** %s → REQ-1\n  - Files: app.sh\n' "$be_title"
  printf '  - Test: %s\n  - After: none\n  - Done when: %s\n' "$be_test" "$be_done"
} > "$BE/.shipkit/specs/esc/tasks.md"
be_out=$(sh "$COPY/scripts/brief.sh" "$BE" esc T1 2>/dev/null; echo "exit $?")
be_prove=$(printf '%s\n' "$be_out" | awk '/^## Prove it with/ { on = 1; next } /^## / { on = 0 } on')
be_t=$(printf '%s\n' "$be_prove" | grep -c '^- Test: ')
be_d=$(printf '%s\n' "$be_prove" | grep -c '^- Done when: ')
[ "$(printf '%s\n' "$be_prove" | sed -n 1p)" = "- Test: $be_test" ] \
  || be_fail="$be_fail [the Test line is not the task's, byte for byte: $(printf '%s\n' "$be_prove" | sed -n 1,2p | od -c | sed -n 1,4p | tr -s ' ' | tr '\n' '|')]"
[ "$(printf '%s\n' "$be_prove" | grep '^- Done when: ')" = "- Done when: $be_done" ] \
  || be_fail="$be_fail [the Done when line is not the task's, byte for byte: $(printf '%s\n' "$be_prove" | grep -A1 '^- Done when: ' | tr '\n' '|')]"
[ "$be_t" = 1 ] && [ "$be_d" = 1 ] && [ "$(printf '%s\n' "$be_prove" | grep -c .)" = 3 ] \
  || be_fail="$be_fail [Prove it with holds $(printf '%s\n' "$be_prove" | grep -c .) lines, not 3]"
[ "$(printf '%s\n' "$be_out" | sed -n 1p)" = "# Brief: esc / T1 — $be_title" ] \
  || be_fail="$be_fail [the title line is not the task's title, byte for byte: $(printf '%s\n' "$be_out" | sed -n 1,2p | tr '\n' '|')]"
printf '%s\n' "$be_out" | tail -1 | grep -qx 'exit 0' || be_fail="$be_fail [brief.sh: $(printf '%s\n' "$be_out" | tail -1)]"
if [ -z "$be_fail" ]; then pass "brief-escapes (a task's title, Test and Done when lines that hold a backslash before n, t, b, c or another backslash are copied into the brief byte for byte)"
else failc "brief-escapes" "$be_fail"; fi

# 128. verify-run: start an application on a free port, wait until it answers, make one request
# and stop what it started (running-the-change T1). The application is a static server on
# python3's socketserver.TCPServer, so no framework and no model is needed. Not python3 -m
# http.server: its HTTPServer looks up the machine's name before it listens, which took 35 s on
# CI's macOS runner (socket.getfqdn, read on pull request #45) and kept the port shut. Every run's TMPDIR is a directory of the check's own,
# and every application command names $VR or sleep 6128, so what a run leaves behind is seen.
# Cites: running-the-change/REQ-1 running-the-change/REQ-2 running-the-change/REQ-3
# running-the-change/REQ-4 running-the-change/REQ-5 running-the-change/REQ-6
# running-the-change/REQ-7 running-the-change/REQ-8 running-the-change/REQ-9
# running-the-change/REQ-10
VRS="$COPY/scripts/verify-run.sh"; VR="$WORK/verify-run"; vr_fail=""
mkdir -p "$VR/site" "$VR/tmp" "$VR/bin"
vr_i=1; while [ "$vr_i" -le 15 ]; do echo "p$vr_i"; vr_i=$((vr_i + 1)); done > "$VR/site/page.html"
vr_srv="python3 -c 'import functools, os, socketserver, http.server; socketserver.TCPServer((\"127.0.0.1\", int(os.environ[\"PORT\"])), functools.partial(http.server.SimpleHTTPRequestHandler, directory=\"$VR/site\")).serve_forever()'"
sleep 6129 & vr_by=$!
vr_diag() {  # on a failure only: how long this machine takes to look up its own name, which
  # http.server does before it listens (HTTPServer.server_bind calls socket.getfqdn)
  python3 -c 'import socket, time
for h in ("127.0.0.1", ""):
    t = time.time(); socket.getfqdn(h); print("getfqdn(%r) %.1f s" % (h, time.time() - t))' 2>&1 | tr '\n' ' '
}
vr() {  # vr <args…> → prints the exit status; stdout in $VR/out, stderr in $VR/err
  (cd "$VR/site" && TMPDIR="$VR/tmp" sh "$VRS" "$@" >"$VR/out" 2>"$VR/err"); echo $?
}
vr_left() {  # vr_left <run>: nothing of the run is left, and the bystander still runs
  vr_n=0
  while :; do
    ps -A -o command= > "$VR/ps"
    if grep -F -e "$VR/site" -e 'sleep 6128' "$VR/ps" >/dev/null; then
      [ "$vr_n" -ge 10 ] && { vr_fail="$vr_fail [$1: a process of the run is left: $(grep -F -e "$VR/site" -e 'sleep 6128' "$VR/ps" | head -2 | tr '\n' '|')]"; break; }
      vr_n=$((vr_n + 1)); sleep 0.2
    else break; fi
  done
  [ -z "$(ls -A "$VR/tmp" 2>/dev/null)" ] || vr_fail="$vr_fail [$1: left in TMPDIR: $(ls -A "$VR/tmp" | tr '\n' ' ')]"
  kill -0 "$vr_by" 2>/dev/null || vr_fail="$vr_fail [$1: the bystander sleep was stopped]"
}
if [ ! -f "$VRS" ]; then
  failc "verify-run" "scripts/verify-run.sh does not exist (checks written first, by design)"
else
  # RAN: --env reaches the application, one GET to the path, at most 10 body lines, no app output
  rc=$(vr --start "echo NOISE; printf '%s %s %s\n' \"\$PORT\" \"\$A\" \"\$B\" > '$VR/env.txt'; exec $vr_srv 2>>'$VR/server.log'" \
         --request /page.html --env A=1 --env B=2)
  [ "$rc" -eq 0 ] || vr_fail="$vr_fail [RAN: exit $rc, want 0: $(head -3 "$VR/out" "$VR/err" | tr '\n' '|')]"
  [ "$(sed -n 1p "$VR/out")" = "RAN 200 /page.html" ] || vr_fail="$vr_fail [RAN: first line: $(sed -n 1p "$VR/out")]"
  sed -n 2p "$VR/out" | grep -q '^HTTP/[0-9.]* 200' || vr_fail="$vr_fail [RAN: no status line: $(sed -n 2p "$VR/out")]"
  [ "$(sed -n '3,$p' "$VR/out" | tr '\n' ' ')" = "p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 " ] \
    || vr_fail="$vr_fail [RAN: the body lines are not the first 10: $(sed -n '3,$p' "$VR/out" | tr '\n' ' ')]"
  grep -q NOISE "$VR/out" && vr_fail="$vr_fail [RAN: the application's output reached stdout]"
  [ "$(grep -c '"GET /page.html ' "$VR/server.log" 2>/dev/null)" = 1 ] \
    || vr_fail="$vr_fail [RAN: the path was asked $(grep -c '"GET /page.html ' "$VR/server.log" 2>/dev/null) times, want 1]"
  read -r vr_port vr_a vr_b < "$VR/env.txt" 2>/dev/null
  { [ "${vr_port:-0}" -gt 1023 ] 2>/dev/null && [ "$vr_a" = 1 ] && [ "$vr_b" = 2 ]; } \
    || vr_fail="$vr_fail [RAN: PORT, A, B in the application: $(cat "$VR/env.txt" 2>/dev/null)]"
  vr_left "RAN"
  # a server that starts listening 2 s late is waited for
  rc=$(vr --start "sleep 2; exec $vr_srv" --request /page.html --timeout 10)
  [ "$rc" -eq 0 ] && [ "$(sed -n 1p "$VR/out")" = "RAN 200 /page.html" ] \
    || vr_fail="$vr_fail [late start: exit $rc, first line $(sed -n 1p "$VR/out")]"
  vr_left "late start"
  # EXITED: the code, then the last 20 lines of the application's output
  rc=$(vr --start 'i=0; while [ $i -lt 30 ]; do echo line$i; i=$((i+1)); done; exit 3' --request /x)
  vr_want="EXITED 3"; vr_i=10; while [ "$vr_i" -le 29 ]; do vr_want="$vr_want|line$vr_i"; vr_i=$((vr_i + 1)); done
  [ "$rc" -eq 1 ] && [ "$(tr '\n' '|' < "$VR/out")" = "$vr_want|" ] \
    || vr_fail="$vr_fail [EXITED: exit $rc, out $(tr '\n' '|' < "$VR/out" | cut -c1-120)]"
  vr_left "EXITED"
  # NOT-READY: the timeout as given
  rc=$(vr --start 'sleep 6128' --request /x --timeout 2)
  [ "$rc" -eq 1 ] && [ "$(sed -n 1p "$VR/out")" = "NOT-READY after 2 s" ] \
    || vr_fail="$vr_fail [NOT-READY: exit $rc, first line $(sed -n 1p "$VR/out")]"
  vr_left "NOT-READY"
  # misuse: exit 2, a word on stderr, nothing started
  vr_bad() {  # vr_bad <label> <args…>
    vr_l=$1; shift; rm -f "$VR/marker"
    rc=$(vr "$@")
    { [ "$rc" -eq 2 ] && [ -s "$VR/err" ] && [ ! -e "$VR/marker" ]; } \
      || vr_fail="$vr_fail [misuse, $vr_l: exit $rc, stderr $(wc -c < "$VR/err" | tr -d ' ') bytes, marker $([ -e "$VR/marker" ] && echo made || echo absent)]"
  }
  vr_bad "no --start" --request /x
  vr_bad "no --request" --start "touch '$VR/marker'"
  vr_bad "path x" --start "touch '$VR/marker'" --request x
  vr_bad "timeout 0" --start "touch '$VR/marker'" --request /x --timeout 0
  vr_bad "timeout abc" --start "touch '$VR/marker'" --request /x --timeout abc
  vr_bad "env 1A=x" --start "touch '$VR/marker'" --request /x --env 1A=x
  vr_bad "env noequals" --start "touch '$VR/marker'" --request /x --env noequals
  vr_left "misuse"
  # no curl on the PATH: exit 2, curl named, nothing started
  ln -s "$(command -v sh)" "$VR/bin/sh"; ln -s "$(command -v awk)" "$VR/bin/awk"
  rm -f "$VR/marker"
  rc=$( (cd "$VR/site" && PATH="$VR/bin" TMPDIR="$VR/tmp" "$VR/bin/sh" "$VRS" --start "touch '$VR/marker'" --request /x >"$VR/out" 2>"$VR/err"); echo $?)
  { [ "$rc" -eq 2 ] && grep -q curl "$VR/err" && [ ! -e "$VR/marker" ]; } \
    || vr_fail="$vr_fail [no curl: exit $rc, stderr $(head -1 "$VR/err")]"
  # an interrupt during the wait: its processes stopped, its directory gone. A job started with &
  # ignores INT, so python3 puts INT back to its default before it becomes the script.
  (cd "$VR/site" && TMPDIR="$VR/tmp" exec python3 -c 'import os, signal, sys; signal.signal(signal.SIGINT, signal.SIG_DFL); os.execvp(sys.argv[1], sys.argv[1:])' \
     sh "$VRS" --start 'sleep 6128' --request /x --timeout 60 >"$VR/out" 2>"$VR/err") &
  vr_pid=$!; vr_n=0
  while [ "$vr_n" -lt 100 ]; do ps -A -o command= > "$VR/ps"; grep -q '^sleep 6128' "$VR/ps" && break; sleep 0.1; vr_n=$((vr_n + 1)); done
  grep -q '^sleep 6128' "$VR/ps" || vr_fail="$vr_fail [interrupt: the application never started]"
  kill -INT "$vr_pid" 2>/dev/null; wait "$vr_pid" 2>/dev/null; rc=$?
  [ "$rc" -ne 0 ] || vr_fail="$vr_fail [interrupt: exit 0]"
  vr_left "interrupt"
fi
kill "$vr_by" 2>/dev/null; wait "$vr_by" 2>/dev/null
if [ -f "$VRS" ] && [ -z "$vr_fail" ]; then pass "verify-run (RAN with the status line and 10 body lines after one GET, EXITED with the code and the last 20 lines, NOT-READY after the timeout given, exit 2 on misuse or no curl with nothing started; nothing of a run is left and a bystander lives, also after INT)"
elif [ -f "$VRS" ]; then failc "verify-run" "$vr_fail [server.log: $(tail -5 "$VR/server.log" 2>/dev/null | tr '\n' '|' | cut -c1-400)] [$(vr_diag)]"; fi

# 129. verify-run-ten: ten runs in a row on one static fixture give the same RAN line and leave
# no server behind (running-the-change T2). The fixture is the spec's: a folder holding
# index.html, served from inside it by python3's socketserver.TCPServer with
# SimpleHTTPRequestHandler on 127.0.0.1 and $PORT (check 128 says why not http.server). A server another program
# runs on this machine is listed before the runs and left out of the count.
# Cites: running-the-change/REQ-11
VT="$WORK/verify-ten"; mkdir -p "$VT/site" "$VT/tmp"; vt_fail=""
printf '<!doctype html><title>t</title><p>static fixture</p>\n' > "$VT/site/index.html"
vt_servers() { ps -A -o pid= -o command= | awk '/[h]ttp\.server/ { print $1 }' | sort; }
vt_servers > "$VT/before"
vt_i=1
while [ "$vt_i" -le 10 ]; do
  (cd "$VT/site" && TMPDIR="$VT/tmp" sh "$COPY/scripts/verify-run.sh" --start 'python3 -c "import os, socketserver, http.server; socketserver.TCPServer((\"127.0.0.1\", int(os.environ[\"PORT\"])), http.server.SimpleHTTPRequestHandler).serve_forever()"' --request /index.html >"$VT/out" 2>"$VT/err")
  vt_rc=$?
  [ "$vt_rc" -eq 0 ] && [ "$(sed -n 1p "$VT/out")" = "RAN 200 /index.html" ] \
    || vt_fail="$vt_fail [run $vt_i: exit $vt_rc, first line $(sed -n 1p "$VT/out"), then $(sed -n '2,6p' "$VT/out" | tr '\n' '|' | cut -c1-300)]"
  vt_n=0
  while :; do
    vt_servers > "$VT/after"; vt_new=$(comm -13 "$VT/before" "$VT/after" | tr '\n' ' ')
    [ -z "$vt_new" ] && break
    [ "$vt_n" -ge 10 ] && { vt_fail="$vt_fail [run $vt_i: a server is left: $vt_new]"; break; }
    vt_n=$((vt_n + 1)); sleep 0.2
  done
  [ -z "$(ls -A "$VT/tmp" 2>/dev/null)" ] || vt_fail="$vt_fail [run $vt_i: left in TMPDIR]"
  vt_i=$((vt_i + 1))
done
if [ -z "$vt_fail" ]; then pass "verify-run-ten (ten runs in a row on one static fixture each print RAN 200 /index.html first and leave no server and nothing in TMPDIR)"
else failc "verify-run-ten" "$vt_fail [$(vr_diag)]"; fi

# 130. verify-skills: the elixir and static overlays ship a verify skill, installed only on
# --with-skills, with the arguments those overlays needed before (running-the-change T3). The
# Rails overlay gets none in this sprint: checks 67 and 69 still hold it to four skills.
# Cites: running-the-change/REQ-13 running-the-change/REQ-15
VK="$WORK/verify-skills"; mkdir -p "$VK"; vk_fail=""
vk_one() {  # vk_one <stack> <KEY=value…>: the skill's description, then installs without and with --with-skills
  vk_stack=$1; shift
  vk_src="$COPY/stacks/$vk_stack/.claude/skills/verify/SKILL.md"
  if [ ! -f "$vk_src" ]; then vk_fail="$vk_fail [$vk_stack: no verify skill]"; return; fi
  vk_desc=$(sed -n 's/^description: "\(.*\)"$/\1/p' "$vk_src" | head -1)
  { [ -n "$vk_desc" ] && [ "${#vk_desc}" -le 300 ]; } \
    || vk_fail="$vk_fail [$vk_stack: description of ${#vk_desc} characters, want 1 to 300]"
  for vk_with in no yes; do
    vk_p="$VK/$vk_stack-$vk_with"; mkdir -p "$vk_p"
    if [ "$vk_with" = yes ]; then sh "$COPY/scripts/install-stack.sh" --with-skills "$COPY" "$vk_stack" "$vk_p" "$@" >/dev/null 2>"$VK/err"
    else sh "$COPY/scripts/install-stack.sh" "$COPY" "$vk_stack" "$vk_p" "$@" >/dev/null 2>"$VK/err"; fi
    vk_rc=$?
    [ "$vk_rc" -eq 0 ] || vk_fail="$vk_fail [$vk_stack, with skills $vk_with: install exit $vk_rc: $(head -2 "$VK/err" | tr '\n' '|')]"
    if [ "$vk_with" = no ]; then
      [ ! -e "$vk_p/.claude/skills/verify" ] || vk_fail="$vk_fail [$vk_stack: verify installed without --with-skills]"
    else
      cmp -s "$vk_src" "$vk_p/.claude/skills/verify/SKILL.md" \
        || vk_fail="$vk_fail [$vk_stack: --with-skills did not install the overlay's verify skill as it is]"
    fi
  done
}
vk_one elixir ELIXIR_FRAMEWORK=Phoenix ELIXIR_FRONTEND=LiveView APP_NAME=my_app TEST_COMMAND="mix test"
vk_one static BUNDLER=None DEV_SERVER=None
vk_lint=$(python3 "$ROOT/scripts/lint.py" 2>&1 | grep 'skills/verify/SKILL.md')
[ -z "$vk_lint" ] || vk_fail="$vk_fail [lint: $(printf '%s\n' "$vk_lint" | head -2 | tr '\n' '|')]"
if [ -z "$vk_fail" ]; then pass "verify-skills (elixir and static ship a verify skill with a description of 300 characters or fewer, installed as it is on --with-skills and not without, with no new install argument, and lint names neither)"
else failc "verify-skills" "$vk_fail"; fi

# 131. commit-gate: a PreToolUse command that looks for a Verified: stamp on a commit's message
# (running-the-change T5). Off by default; observe writes one log row per unstamped commit;
# enforce blocks one twice a session, then lets it through. The hook's JSON is fed on stdin, both
# compact and indented, with SHIPKIT_HOME a directory of the check's own.
# Cites: running-the-change/REQ-18 running-the-change/REQ-19 running-the-change/REQ-20
# running-the-change/REQ-21 running-the-change/REQ-22 running-the-change/REQ-23
# running-the-change/REQ-24 running-the-change/REQ-25
CGS="$COPY/scripts/commit-gate.sh"; CG="$WORK/commit-gate"; mkdir -p "$CG"; cg_fail=""
CGH="$CG/home"; CGL="$CGH/commit-gate.log"
cg_json() {  # cg_json <compact|indented> <session id, or - for none> <command> [cwd, or - for none]
  _c=$(printf '%s' "$3" | sed 's/"/\\"/g')
  _s=""; [ "$2" = - ] || _s="\"session_id\": \"$2\", "
  _d="\"cwd\": \"${4:-/proj/a}\", "; [ "${4:-}" = - ] && _d=""
  if [ "$1" = compact ]; then
    printf '{%s%s"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"%s","description":"d"}}' \
      "$(printf '%s' "$_s" | tr -d ' ')" "$(printf '%s' "$_d" | sed 's/": "/":"/; s/", $/",/')" "$_c"
  else
    printf '{\n  %s\n  %s\n  "hook_event_name": "PreToolUse",\n  "tool_name": "Bash",\n  "tool_input": {\n    "command": "%s",\n    "description": "d"\n  }\n}\n' \
      "$_s" "$_d" "$_c"
  fi
}
cg() {  # cg <mode, or - for unset> <json> → prints the exit status; stdout and stderr in $CG/out, $CG/err
  if [ "$1" = - ]; then printf '%s' "$2" | (unset SHIPKIT_COMMIT_GATE; SHIPKIT_HOME="$CGH" sh "$CGS" >"$CG/out" 2>"$CG/err"); echo $?
  else printf '%s' "$2" | SHIPKIT_COMMIT_GATE=$1 SHIPKIT_HOME="$CGH" sh "$CGS" >"$CG/out" 2>"$CG/err"; echo $?; fi
}
cg_rows() { if [ -f "$CGL" ]; then grep -c . "$CGL"; else echo 0; fi; }
cg_quiet() {  # cg_quiet <label> <rc> <want rc>: that exit, nothing on stdout or stderr
  [ "$2" -eq "$3" ] && [ ! -s "$CG/out" ] && [ ! -s "$CG/err" ] \
    || cg_fail="$cg_fail [$1: exit $2 (want $3), out $(head -c 80 "$CG/out" | tr '\n' '|'), err $(head -c 80 "$CG/err" | tr '\n' '|')]"
}
if [ ! -f "$CGS" ]; then
  failc "commit-gate" "scripts/commit-gate.sh does not exist (checks written first, by design)"
else
  sh -n "$CGS" 2>/dev/null || cg_fail="$cg_fail [sh -n reports a syntax error]"
  # not a commit, in every mode, and an unstamped commit with the gate off: nothing at all
  for cg_s in compact indented; do
    for cg_m in off observe enforce; do
      rc=$(cg "$cg_m" "$(cg_json $cg_s s1 'ls -la')"); cg_quiet "ls, $cg_m, $cg_s" "$rc" 0
    done
    for cg_m in - off bogus; do
      rc=$(cg "$cg_m" "$(cg_json $cg_s s1 'git commit -m "x"')"); cg_quiet "commit, mode $cg_m, $cg_s" "$rc" 0
    done
  done
  [ ! -e "$CGL" ] || cg_fail="$cg_fail [a log was written with the gate off or for a call that is not a commit]"
  # observe: one row per unstamped commit, the JSON's cwd or - as the last field
  rc=$(cg observe "$(cg_json compact s1 'git commit -m "x"')"); cg_quiet "observe, unstamped" "$rc" 0
  awk -F'\t' 'NR == 1 && NF == 5 && $1 ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z$/ \
      && $2 == "s1" && $3 == "observe" && $4 == "unstamped" && $5 == "/proj/a" { ok = 1 } END { exit !ok }' "$CGL" 2>/dev/null \
    || cg_fail="$cg_fail [observe: the row is not time, s1, observe, unstamped, /proj/a: $(head -1 "$CGL" 2>/dev/null)]"
  rc=$(cg observe "$(cg_json indented s1 'git commit -am "y"' -)"); cg_quiet "observe, unstamped, indented" "$rc" 0
  [ "$(cg_rows)" = 2 ] && [ "$(sed -n 2p "$CGL" | cut -f4,5)" = "$(printf 'unstamped\t-')" ] \
    || cg_fail="$cg_fail [observe, indented, no cwd: rows $(cg_rows), second $(sed -n 2p "$CGL" | tr '\t' ' ')]"
  # a stamp, also in the second -m part: nothing written, in observe and in enforce
  for cg_m in observe enforce; do
    for cg_c in 'git commit -m "feat: x" -m "Verified: tests (x)"' 'git commit -m "feat: x" -m "Verified: none (docs only)"'; do
      cg_n=$(cg_rows); rc=$(cg "$cg_m" "$(cg_json indented s1 "$cg_c")"); cg_quiet "stamped, $cg_m" "$rc" 0
      [ "$(cg_rows)" = "$cg_n" ] || cg_fail="$cg_fail [stamped, $cg_m: a row was written]"
    done
  done
  # enforce: blocked twice in a session, the third passes; another session is still blocked
  for cg_k in 1 2; do
    rc=$(cg enforce "$(cg_json compact s2 'git commit -m "wip"')")
    { [ "$rc" -eq 2 ] && [ ! -s "$CG/out" ] && [ "$(grep -c . "$CG/err")" = 1 ] \
      && grep -q 'Verified:' "$CG/err" && grep -q 'Verified: none (' "$CG/err" \
      && [ "$(tail -1 "$CGL" | cut -f2-4)" = "$(printf 's2\tenforce\tblocked')" ]; } \
      || cg_fail="$cg_fail [enforce, attempt $cg_k: exit $rc, err $(head -c 160 "$CG/err" | tr '\n' '|'), last row $(tail -1 "$CGL" | tr '\t' ' ')]"
  done
  rc=$(cg enforce "$(cg_json compact s2 'git commit -m "wip"')"); cg_quiet "enforce, attempt 3" "$rc" 0
  [ "$(tail -1 "$CGL" | cut -f2-4)" = "$(printf 's2\tenforce\tpassed')" ] || cg_fail="$cg_fail [enforce, attempt 3: last row $(tail -1 "$CGL" | tr '\t' ' ')]"
  rc=$(cg enforce "$(cg_json indented s3 'git commit -m "wip"')")
  [ "$rc" -eq 2 ] || cg_fail="$cg_fail [enforce, another session after two blocks of s2: exit $rc, want 2]"
  rc=$(cg enforce "$(cg_json compact s4 'git commit -m "wip" -m "Verified: none ()"')")
  [ "$rc" -eq 2 ] || cg_fail="$cg_fail [enforce: Verified: none () counted as a stamp, exit $rc]"
  # no message on the command line: through, with an unseen row, in observe and in enforce
  for cg_m in observe enforce; do
    for cg_c in 'git commit -F f' 'git commit --no-edit' 'git commit'; do
      rc=$(cg "$cg_m" "$(cg_json compact s5 "$cg_c")"); cg_quiet "$cg_c, $cg_m" "$rc" 0
      [ "$(tail -1 "$CGL" | cut -f2-4)" = "$(printf 's5\t%s\tunseen' "$cg_m")" ] || cg_fail="$cg_fail [$cg_c, $cg_m: last row $(tail -1 "$CGL" | tr '\t' ' ')]"
    done
  done
  # its own errors let the commit through: empty input, no session id, a log it cannot write
  rc=$(printf '' | SHIPKIT_COMMIT_GATE=enforce SHIPKIT_HOME="$CGH" sh "$CGS" 2>/dev/null; echo $?)
  [ "$rc" -eq 0 ] || cg_fail="$cg_fail [enforce, empty input: exit $rc]"
  rc=$(cg enforce "$(cg_json compact - 'git commit -m "wip"')")
  [ "$rc" -eq 0 ] || cg_fail="$cg_fail [enforce, no session id: exit $rc]"
  : > "$CG/a-file"
  rc=$(cg_json compact s6 'git commit -m "wip"' | SHIPKIT_COMMIT_GATE=enforce SHIPKIT_HOME="$CG/a-file/home" sh "$CGS" 2>/dev/null; echo $?)
  [ "$rc" -eq 0 ] || cg_fail="$cg_fail [enforce, a log it cannot write: exit $rc]"
  if [ -z "$cg_fail" ]; then pass "commit-gate (off by default and for every call that is not a commit; observe logs an unstamped commit; enforce blocks twice a session, then passes; a stamp in any -m part passes; a message it cannot see passes with an unseen row; its own errors exit 0; compact and indented JSON alike)"
  else failc "commit-gate" "$cg_fail"; fi
fi

# 132. commit-gate-hook: hooks.json runs the gate as a second command on the Bash matcher,
# beside the secret guard (running-the-change T6). With the gate unset, a commit that stages
# .env is still blocked by the guard, and the gate adds nothing.
# Cites: running-the-change/REQ-26
CH="$WORK/commit-gate-hook"; mkdir -p "$CH"; ch_fail=""
ch_cmds=$(python3 -c '
import json, sys
h = json.load(open(sys.argv[1]))
for e in h.get("hooks", {}).get("PreToolUse", []):
    if e.get("matcher") == "Bash":
        for c in e.get("hooks", []):
            print("%s\t%s\t%s" % (c.get("type"), c.get("timeout"), c.get("command")))
' "$COPY/hooks/hooks.json" 2>"$CH/err") || ch_fail="$ch_fail [hooks.json does not parse: $(head -1 "$CH/err")]"
ch_want=$(printf 'command\t5\t"${CLAUDE_PLUGIN_ROOT}/scripts/guard-commit.sh"\ncommand\t5\t"${CLAUDE_PLUGIN_ROOT}/scripts/commit-gate.sh"')
[ "$ch_cmds" = "$ch_want" ] || ch_fail="$ch_fail [the Bash entry's commands: $(printf '%s' "$ch_cmds" | tr '\t\n' ' |')]"
for ch_s in guard-commit.sh commit-gate.sh; do
  [ -x "$COPY/scripts/$ch_s" ] || ch_fail="$ch_fail [$ch_s is not an executable file]"
done
CHP="$CH/proj"; mkdir -p "$CHP"
(cd "$CHP" && git init -q && git -c user.email=s@s -c user.name=s commit -q --allow-empty -m init \
  && printf 'KEY=1\n' > .env && git add -f .env)
ch_json=$(printf '{"session_id":"s1","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m wip"}}' "$CHP")
ch_g=$(printf '%s' "$ch_json" | (cd "$CH" && sh "$COPY/scripts/guard-commit.sh" 2>/dev/null); echo $?)
ch_c=$(printf '%s' "$ch_json" | (cd "$CH" && unset SHIPKIT_COMMIT_GATE; SHIPKIT_HOME="$CH/home" sh "$COPY/scripts/commit-gate.sh" >"$CH/out" 2>&1); echo $?)
{ [ "$ch_g" -eq 2 ] && [ "$ch_c" -eq 0 ] && [ ! -s "$CH/out" ] && [ ! -e "$CH/home" ]; } \
  || ch_fail="$ch_fail [a staged .env with the gate unset: guard exit $ch_g (want 2), gate exit $ch_c (want 0), gate output $(head -c 80 "$CH/out"), log $([ -e "$CH/home" ] && echo written || echo none)]"
if [ -z "$ch_fail" ]; then pass "commit-gate-hook (the Bash entry of PreToolUse runs guard-commit.sh then commit-gate.sh, timeout 5 each, both executable; with the gate unset a staged .env is still blocked by the guard and the gate adds nothing)"
else failc "commit-gate-hook" "$ch_fail"; fi

# 133. trim-audit: docs/design/trim-audit-checks.md has one row for every smoke check in
# registry() and every case in scripts/evals-map.tsv, each cell in its form, no trap-2 case a
# candidate, and a cut row only for what is gone (running-the-change T8, T9). A new check or case
# without a row fails here, so the prune pass at each release starts from a complete list.
# Cites: running-the-change/REQ-30 running-the-change/REQ-31 running-the-change/REQ-32
TA="$WORK/trim-audit"; mkdir -p "$TA"; ta_fail=""
TAF="$ROOT/docs/design/trim-audit-checks.md"
{ registry | sed 's/^/smoke	/'; awk -F'\t' 'NR > 1 { print "eval\t" $1 }' "$ROOT/scripts/evals-map.tsv"; } > "$TA/listed"
ta_read() {  # ta_read <audit file> → one line per problem; nothing when the audit holds
  awk -F'\t' 'NR == FNR { listed[$1 "\t" $2] = 1; next }
    /<!-- audit:begin -->/ { on = 1; next } /<!-- audit:end -->/ { on = 0; next }
    !on || !/^\| / || /^\| Kind / || /^\|---/ { next }
    { n = split($0, c, / \| /); sub(/^\| /, "", c[1]); sub(/ \|$/, "", c[n])
      if (n != 7) { print "a row of " n " cells: " substr($0, 1, 60); next }
      k = c[1]; l = c[2]; key = k "\t" l; seen[key] = 1
      if (k != "smoke" && k != "eval") print "kind " k ": " l
      if (c[3] !~ /^([0-9]+\.[0-9]+\.[0-9]+|never)$/) print "last failed " c[3] ": " l
      if (c[4] == "") print "also covered by is empty: " l
      if (c[5] !~ /^([0-9]+(\.[0-9]+)? s|\$[0-9]+(\.[0-9]+)?)$/) print "cost " c[5] ": " l
      if (k == "eval" && l ~ /^trap2-/ && c[6] ~ /^yes/) print "a trap-2 case is a candidate: " l
      if (c[7] != "" && c[7] !~ /^cut [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) print "cut " c[7] ": " l
      if (key in listed && c[7] != "") print "cut but still listed: " l
      if (!(key in listed) && c[7] == "") print "not listed and not cut: " l }
    END { for (x in listed) if (!(x in seen)) { sub(/\t/, " ", x); print "no row: " x } }' "$TA/listed" "$1"
}
if [ ! -f "$TAF" ]; then
  failc "trim-audit" "docs/design/trim-audit-checks.md does not exist (checks written first, by design)"
else
  ta_out=$(ta_read "$TAF")
  [ -z "$ta_out" ] || ta_fail="$ta_fail [the audit: $(printf '%s\n' "$ta_out" | head -4 | tr '\n' '|')]"
  [ "$(awk '/<!-- audit:begin -->/{on=1} on && /^\| (smoke|eval) \|/{n++} END{print n+0}' "$TAF")" -ge "$(grep -c . "$TA/listed")" ] \
    || ta_fail="$ta_fail [fewer rows than checks and cases]"
  # the reading itself fails on a broken copy: a row taken out, a cell in the wrong form, a trap-2 case marked yes
  awk '!done && /^\| smoke \| / { done = 1; next } { print }' "$TAF" > "$TA/one-gone.md"
  awk '/^\| smoke \| / && !done { n = split($0, c, / \| /); c[5] = "quick"; s = c[1]; for (i = 2; i <= n; i++) s = s " | " c[i]; $0 = s; done = 1 } { print }' "$TAF" > "$TA/bad-cost.md"
  awk '/^\| eval \| trap2-/ && !done { n = split($0, c, / \| /); c[6] = "yes: full score, a script holds it"; s = c[1]; for (i = 2; i <= n; i++) s = s " | " c[i]; $0 = s; done = 1 } { print }' "$TAF" > "$TA/trap2-yes.md"
  awk '/^\| smoke \| / && !done { n = split($0, c, / \| /); c[7] = "cut 2026-11-20 |"; s = c[1]; for (i = 2; i <= n; i++) s = s " | " c[i]; $0 = s; done = 1 } { print }' "$TAF" > "$TA/cut-listed.md"
  for ta_c in one-gone bad-cost trap2-yes cut-listed; do
    [ -n "$(ta_read "$TA/$ta_c.md")" ] || ta_fail="$ta_fail [the reading passes a broken copy: $ta_c]"
  done
  if [ -z "$ta_fail" ]; then pass "trim-audit (one row per smoke check and eval case, each cell in its form, no trap-2 case a candidate, a cut row only for what is gone; the reading fails on a copy with a row gone, a cost in the wrong form a trap-2 case marked yes, or a cut row whose check is still listed)"
  else failc "trim-audit" "$ta_fail"; fi
fi

# The last assertion of a --no-model run: the stand-in `claude` was never called.
if [ "$NO_MODEL" -eq 1 ]; then
  if [ ! -s "$WORK/claude-calls.log" ]; then pass "smoke-args (--no-model started no claude process: the stand-in first on the PATH was never called)"
  else failc "smoke-args" "claude was called $(grep -c . "$WORK/claude-calls.log") time(s) under --no-model: $(sed -n 1,3p "$WORK/claude-calls.log" | cut -c1-120 | tr '\n' '|')"; fi
fi

echo
summary_lines "$(grep -c p "$COUNTS")" "$(grep -c t "$COUNTS")" "$(grep -c s "$COUNTS")" "$(grep -c f "$COUNTS")"
exit $fail
