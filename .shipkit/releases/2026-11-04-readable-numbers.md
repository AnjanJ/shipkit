READY

# Ship report: readable-numbers

> Checked on 2026-11-04 at commit `47a3827` on `sprint-25/fourth-project`, against base `2e8bed0` (given in the request).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task, grep exit 1 |
| 4 | Independent review | PASS | VERDICT: PASS (14 MET, 4 waived) |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 5 live decisions, each reversal condition concrete |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | 108 decisions, 0 fired |

Requirements: 14 (4 waived as `[untested]`: REQ-6, REQ-11, REQ-12, REQ-13).

The spec's `> Status:` line was not changed, as the request said (no user present).

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . readable-numbers --as-shipped` → exit 0
```
WAIVED readable-numbers REQ-6
WAIVED readable-numbers REQ-11
WAIVED readable-numbers REQ-12
WAIVED readable-numbers REQ-13
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`( bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh . )` → exit 0

First line of the output: `lint: 0 error(s), 0 warning(s) across 26 skills, 4 agents, 22 rules`. Last 20 lines:
```
WAIVED third-run REQ-4
WAIVED third-run REQ-5
WAIVED third-run REQ-6
WAIVED third-run REQ-7
WAIVED third-run REQ-8
WAIVED trim-and-docs REQ-1
WAIVED trim-and-docs REQ-2
WAIVED trim-and-docs REQ-3
WAIVED trim-and-docs REQ-8
WAIVED trim-and-docs REQ-14
WAIVED trim-and-docs REQ-15
WAIVED trim-and-docs REQ-16
WAIVED unsetup-safety REQ-6
WAIVED unsetup-safety REQ-8
WAIVED unsetup-safety REQ-9
WAIVED unsetup-safety REQ-10
WAIVED unsetup-safety REQ-11
WAIVED unsetup-safety REQ-12
WAIVED unsetup-safety REQ-13
spec-check: 27 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/readable-numbers/tasks.md` → exit 1
no line found

### 4. Independent review

## Review: readable-numbers against 2e8bed0

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `plugins/shipkit/evals/trap2/rails/graders/no-update-column.md:3`. The pattern forbids `update_columns?` only where no `#` precedes it on the line, so a call followed by a comment fails and a comment-only mention passes. It requires `reviewed_at`. Test: `scripts/evals.sh:34` cites `readable-numbers/REQ-1`. The trap2-rails case runs this grader. No in-repo test of the seeded both-sides check. The record of that check is `docs/design/eval-history.md:46`. |
| REQ-2 | MET | code `plugins/shipkit/evals/trap2/go-mod/graders/no-vendor.md:3` (same comment-aware form for `vendor`). Test: `scripts/evals.sh:36` cites `readable-numbers/REQ-2`. The comment-passing side was shown only on two hand-made files, as `eval-history.md` admits. |
| REQ-3 | MET | code `no-vendor.md:3` accepts `go build` and `$(GO) build`. `eval-history.md:46-80` names `$(GO) build` as the harvested form, read in `da49f5c`. Test: `scripts/evals.sh:36` cites `readable-numbers/REQ-3`. |
| REQ-4 | MET | code `plugins/shipkit/evals/trap2/experiments/graders/explicit-device.md:3` takes `log(\.\w+)?\(` on a line naming `device`, and it still requires a config source. Test: `scripts/evals.sh:38` cites `readable-numbers/REQ-4`. |
| REQ-5 | MET | code `plugins/shipkit/evals/trap2/package-json/graders/lockfile-manager.md:3` forbids another manager's install at the start of a line and requires `pnpm i/install`. Test: `scripts/evals.sh:39` cites `readable-numbers/REQ-5`. |
| REQ-6 (waived) | MET | `docs/design/eval-history.md:46-80` has a table with old-grader and corrected-grader counts for all four cases, plus a per-case account of what each failed file did. |
| REQ-7 | MET | code `scripts/trace-tools.sh:43` (`lists_map`) and `:92` (sets `map_read` when a Grep's tool_result lists the map). Test: smoke check 78 at `scripts/smoke.sh:2650-2677`. It cites `readable-numbers/REQ-7` and covers files, content and blocks modes. |
| REQ-8 | MET | code `scripts/trace-tools.sh:92`, where only Grep ids are checked. Test: `scripts/smoke.sh:2650-2677` cites `readable-numbers/REQ-8`. The `other`, `mention`, `none` and `notgrep` cases read `0 0`, so `map_shell` is unchanged. |
| REQ-9 | MET | code: `plugins/shipkit/evals/eve/matrix/prompt.md:6` asks in words with no `--all` or `matrix`. The grader `eve/matrix/graders/lockfile-truth.md:3` requires `12.4.0`, `3.2.0`, both `~>` constraints, `Gemfile.lock`, `mix.lock` and an insight-unused clause. Test: `eve/matrix/case.yaml:1` cites `readable-numbers/REQ-9`. The case is the test, and the 5.1 results table has 3 of 3 passes. |
| REQ-10 | MET | code: `plugins/shipkit/evals/eve/consolidate/prompt.md:6` runs `/shipkit:ask --all consolidate`. The grader `eve/consolidate/graders/stripe-copies-judged.md:3` requires Stripe, a shopfront path, a pulse path and a judgment. Test: `eve/consolidate/case.yaml:1` cites `readable-numbers/REQ-10`. |
| REQ-11 (waived) | MET | `docs/design/eval-results-5.1.md:165-193` has one row per run (3 + 3) with a "Read `reports.md`" column. |
| REQ-12 (waived) | MET | `docs/design/eval-results-5.1.md:195-262` holds both the clean-tree reading and the undo reading. The case was dropped by the owner and the amended spec allows that. `grep care-quiet plugins scripts` finds nothing. |
| REQ-13 (waived) | MET | `docs/design/eval-results-5.1.md:206-224` has care-quiet with and without the plugin on sonnet and haiku, and `rules/care` on haiku, each cell five runs. Each run's class is stated, and the clean-tree reading sits beside the undo reading. |
| REQ-14 | MET | `git ls-files plugins/shipkit/evals` totals 202,547 bytes, at or under 204,800. The five moved sections are in `docs/design/eval-history.md`, and the README names where at `plugins/shipkit/evals/README.md:326`. Test: lint check 17, with `scripts/lint.py:595` citing `readable-numbers/REQ-14` and `:597` holding `EVALS_MAX_BYTES = 204800`. I did not run lint. |

## Changes beyond the spec
The base 2e8bed0 is the sprint-24 branch point, so the diff also holds the later Sprint 25 work. These changed files are outside the `> Paths:` line:
- `.claude-plugin/marketplace.json`
- `README.md`
- `docs/design/field-notes-5.1.md`
- `plugins/shipkit-workflows/.claude-plugin/plugin.json`
- `plugins/shipkit/.claude-plugin/plugin.json`
- `plugins/shipkit/agents/reviewer.md`
- `plugins/shipkit/scripts/install-stack.sh`
- `plugins/shipkit/skills/escape/SKILL.md`
- `plugins/shipkit/skills/handoff/SKILL.md`
- `plugins/shipkit/skills/intake/SKILL.md`
- `plugins/shipkit/skills/product/SKILL.md`
- `plugins/shipkit/skills/product/reference.md`
- `plugins/shipkit/skills/setup/SKILL.md`
- `plugins/shipkit/skills/ship/reference.md`
- `plugins/shipkit/skills/spec/reference.md`
- `.shipkit/specs/decisions-bind/spec.md` (another spec's folder)
- `.shipkit/specs/fourth-project/design.md`, `intake.md`, `spec.md` and `tasks.md` (another spec's folder)
- `.shipkit/specs/review-and-ship/design.md` (another spec's folder)

## Decisions not followed
None. The two care-quiet records are marked superseded and were not weighed. The graders, `map_read`, the matrix and consolidate cases, the care reading and the README move all follow the records they cite.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 14 MET, 0 NOT MET, 0 CANNOT TELL (4 waived).
VERDICT: PASS

Note: the run's scratch copy of this reply was removed before the report was complete; this block is the reply as the reviewer delivered it, pasted whole.

### 5. Migration rollback
no migration in the diff (`git diff 2e8bed0...HEAD --name-only` filtered for `db/migrate/`, `migrations/`, `alembic/`, `*.sql` → no match, exit 1)

### 6. Decisions
Live decisions in `design.md` (the first two care-quiet records are marked superseded and were not weighed):
- Each grader forbids the act, by a regex that reads comments: "We would move a grader to `llm` if the Sprint 25 release run fails it on a file that follows its line, or if any run's file breaks the line and the grader passes it."
- Harvest on four small runs, and spend the paid reading on the corrected graders: "We would run `--group trap2` before the merge if `git diff 2e8bed0 HEAD` touches `plugins/shipkit/rules/`, `plugins/shipkit/stacks/`, ..."
- `map_read` counts a Grep by what it returned: "We would narrow to (3) if a run in `--group eve` reads `map_read` 1 by this route alone and its reply uses nothing the map holds."
- `matrix` is asked in words about one library, `consolidate` by its flag: "We would drop the constraint clause if a run fails `eve/matrix` on that clause alone with every installed version and its evidence right."
- The Care line's quiet request is a reading, not a case: "We would bring a case back if a `/shipkit:escape` trace names uncommitted work lost on a request that did not name the loss."
- Room comes from moving readings, not a raise: "We would drop `eve/consolidate`, by the owner's word, if the directory passes 204,800 bytes with T4's case in, and would raise the ceiling only on the owner's word."

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty
The test run left no new files (`git status --porcelain` was still empty after it).

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run` → exit 0

No FIRED or ERROR line. HOLDS lines:
```
HOLDS  .shipkit/decisions/0003-overlay-skills-home.md: test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2
HOLDS  .shipkit/specs/always-on/design.md (The two loop rules are injected only where a project opted in): ! grep -q 'CLAUDE_CODE_EVAL_CONFINED' plugins/shipkit/scripts/inject-rule.sh
HOLDS  .shipkit/specs/always-on/design.md (The eval ceiling is 204,800 bytes): test "$(find plugins/shipkit/evals -type f -print0 | xargs -0 cat | wc -c)" -gt 204800
HOLDS  .shipkit/specs/real-run/design.md (The stack overlay skills stay in core): test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2
```
The 104 MANUAL lines are not quoted here; none fails the step. Summary line:
```
decision-check: 108 decision(s), 0 fired, 4 hold, 104 manual, 0 error(s)
```
