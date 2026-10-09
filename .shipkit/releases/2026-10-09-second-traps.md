READY

# Ship report: second-traps

> Checked on 2026-10-09 at commit `b7868020e526893190a60dbf70587f882479164b` on `sprint-13/second-traps`, against base `c1c7b18ab9f128a790269c480375893e50f31265` (`git merge-base HEAD main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no database migration in the diff |
| 6 | Decisions | PASS | 6 decisions, each reversal condition is a metric or event |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | 33 decisions, 0 fired |

Requirements: 15 (10 waived as `[untested]`).

The spec's `> Status:` line was not changed, as instructed. It is still `open`.

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . second-traps --as-shipped` → exit 0
```
WAIVED second-traps REQ-2
WAIVED second-traps REQ-3
WAIVED second-traps REQ-6
WAIVED second-traps REQ-7
WAIVED second-traps REQ-9
WAIVED second-traps REQ-10
WAIVED second-traps REQ-11
WAIVED second-traps REQ-13
WAIVED second-traps REQ-14
WAIVED second-traps REQ-15
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`( bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh . ) > "${TMPDIR:-/tmp}/shipkit-ship-tests.out" 2>&1` → exit 0
```
WAIVED spec-contract REQ-19
WAIVED spec-contract REQ-20
WAIVED spec-contract REQ-24
WAIVED spec-contract REQ-25
WAIVED spec-contract REQ-26
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
spec-check: 15 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/second-traps/tasks.md` → exit 1
no line found

### 4. Independent review
## Review: second-traps against c1c7b18ab9f128a790269c480375893e50f31265

I did not run any tests or evals. Evidence is the diff, the files, and the counts recorded in `docs/design/eval-results-4.6.md`.

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `scripts/lint.py` (`EVALS_MAX_BYTES = 163840`); test `scripts/smoke.sh` check 42 expects "the limit is 163,840" and carries the `second-traps/REQ-1` citation. The evals directory totals 145,241 bytes, under the limit. |
| REQ-2 (waived) | MET | `plugins/shipkit/evals/README.md` ~L319 and ~L324 point to `docs/design/eval-history.md`. The README no longer holds the baselines. The pointer is two separate mentions, not one paragraph, which is a minor deviation. |
| REQ-3 (waived) | MET | README section "Path-scoped loading, measured (4.6.0)" states the result and names smoke check 54. Check 54 in `scripts/smoke.sh` also asserts the README paragraph exists and cites `second-traps/REQ-3`. The paragraph is a subsection placed after the "How a case gets the fixture" heading, not inside it. |
| REQ-4 | MET | The 16 `plugins/shipkit/evals/trap2/*/` directories each hold case.yaml, fixture.sh, prompt.md and a regex grader. `scripts/smoke.sh` check 47 lists all 16 in `RC_EXPECT` and cites `second-traps/REQ-4`. |
| REQ-5 | MET | `docs/design/eval-results-4.6.md` shows 3 of 3 with the rule on every row, counted from the traces. `scripts/evals.sh` cites `second-traps/REQ-5`. I could not re-run it; the rows are the record. |
| REQ-6 (waived) | MET | `docs/design/eval-results-4.6.md` has 16 rows, each with with-arm and without-arm counts and one of the three readings. |
| REQ-7 (waived) | MET | The diff shows no rule text changed apart from `gemfile.md` (REQ-8). `ROADMAP.md` ~L45-50 names the twelve cut candidates. |
| REQ-8 | MET | Code `plugins/shipkit/stacks/rails/.claude/rules/gemfile.md` L7 now reads "when `bundle install` has run, read the `Gemfile.lock` diff". The file is 472 bytes. The test is the existing `stacks-gemfile` eval, recorded as 3 of 3 in the evals README ("The Gemfile line") and cited in `scripts/evals.sh`. The 3 of 3 is a recorded count I did not re-run. |
| REQ-9 (waived) | MET | `scripts/trace-tools.sh` adds the `map_read` column, counted for a `Read` ending in `PROJECT_MAP.md` in the main session or a subagent. It carries the `second-traps/REQ-9` citation. Results doc: "checked by hand against two traces". |
| REQ-10 (waived) | MET | `plugins/shipkit/agents/grandfather.md` is not in the diff. `.shipkit/decisions/0001-project-map-default.md` has an appended note with the rates: baseline 1 of 15, attempt 1 4 of 15, attempt 2 8 of 15. Both attempts fell short of 10 of 15 and all 45 answers were right. |
| REQ-11 (waived) | MET | The condition (10 or more of 15) was never reached. The agent is unchanged, so no sentence was added. This is satisfied vacuously. |
| REQ-12 | MET | Code `plugins/shipkit/evals/fixtures/ledger-gen/generate.py` (`WIP` flag; commit message "wip"). Test `scripts/smoke.sh` check 39 `--wip` compares tree hashes against the normal build and asserts every message is "wip". It cites `second-traps/REQ-12`. |
| REQ-13 (waived) | MET | `ROADMAP.md` ~L185 and the "Still open after Sprint 13" list record eve's loss as unmeasured and open, because no multi-project fixture exists. |
| REQ-14 (waived) | MET | `ROADMAP.md` ~L154-171 records D1 to D5, each with the 2026-10-09 date and removed or kept. D2's 3.1.0 directory is kept. D4 is done by the release step after the tag, as the roadmap says. The owner's yes for each row is asserted in the prose; I could not verify it from the files. |
| REQ-15 (waived) | MET | `ROADMAP.md` ~L45-90 "Still open after Sprint 13" lists the cut candidates, eve, the step-1 limit, and the items from the "What using it for real showed" sections. Each item cites a file and section. |

## Changes beyond the spec
None. Every changed file is under the spec's `> Paths:` or under `.shipkit/` (this spec's own folder and decision 0001).

## Decisions not followed
None.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 15 MET, 0 NOT MET, 0 CANNOT TELL (9 waived).
VERDICT: PASS

(Note: the reviewer counts 9 waived; step 1's script lists 10 `WAIVED` lines, and this report uses the script's count.)

### 5. Migration rollback
`git diff c1c7b18...HEAD --name-only` matched the migration patterns on four files, all eval-case files for a case named `migrations`, not database migrations:
`plugins/shipkit/evals/trap2/migrations/{case.yaml,fixture.sh,prompt.md,graders/concurrent.md}`.
No file under `db/migrate/`, `priv/repo/migrations/`, `alembic/`, `prisma/migrations/`, and no `*.sql`. Nothing to roll back.

### 6. Decisions
Six live decisions in `.shipkit/specs/second-traps/design.md`, none superseded; each has a concrete reversal condition:
- Room comes from moving history out: "lower the ceiling back if a release after 4.6.0 commits a fixture or a file over 20 KB under `evals/` that is not a case."
- Sixteen trap-2 cases: "drop to (2) if the sixteen cases take more than 24 KB or the release run passes $18".
- The elder's step 1 gets at most two measured attempts: "revert a kept sentence if the next release run's `grandfather-xl` group drops below 2 of 3 on any case."
- The Gemfile line is reworded: "revert to (2) if `stacks-gemfile` or `trap2/gemfile` drops below 2 of 3 with the new text."
- The history case runs on a "wip" log: "build (2) if a user reports eve answering wrong on a project without a map, or if the next plan has 20 KB of room to spare."
- Housekeeping rows are each their own yes: "move to (2) if the owner, asked five times, says 'all of them' twice in a row."

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty

A second `git status --porcelain` after the test run was also empty, so the test run left no files behind.

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run > "${TMPDIR:-/tmp}/shipkit-ship-decisions.out" 2>&1` → exit 0
```
HOLDS  .shipkit/decisions/0003-overlay-skills-home.md: test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2
HOLDS  .shipkit/specs/real-run/design.md (The stack overlay skills stay in core): test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2
decision-check: 33 decision(s), 0 fired, 2 hold, 31 manual, 0 error(s)
```
No `FIRED` and no `ERROR` line. The 31 `MANUAL` lines (reversal conditions with no command) include the six `second-traps` decisions quoted under step 6, plus `.shipkit/decisions/0002-spec-first-eval.md` and the earlier specs' decisions; they do not fail the step.
