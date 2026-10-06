READY

# Ship report: review-and-ship

> Checked on 2026-10-06 at commit `7ae7572` (`7ae75728814755dc4ed7385e6cfb7b9c96bd3bf9`) on `sprint-4/review-and-ship`, against base `374b43b` (`git merge-base HEAD main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 2 decisions, reversal conditions concrete |
| 7 | Clean tree | PASS | nothing uncommitted |

Requirements: 19 (9 waived as `[untested]`).

## Evidence

### 1. Spec check, as shipped
`sh plugins/shipkit/scripts/spec-check.sh . review-and-ship --as-shipped` → exit 0
```
WAIVED review-and-ship REQ-1
WAIVED review-and-ship REQ-2
WAIVED review-and-ship REQ-3
WAIVED review-and-ship REQ-4
WAIVED review-and-ship REQ-5
WAIVED review-and-ship REQ-8
WAIVED review-and-ship REQ-10
WAIVED review-and-ship REQ-11
WAIVED review-and-ship REQ-15
WAIVED review-and-ship REQ-18
spec-check: 1 spec(s) checked, 0 gap(s)
```
(The script printed ten WAIVED lines; the reviewer counts nine waived requirements. Lines are quoted as printed.)

### 2. Tests
`bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0
```
WAIVED review-and-ship REQ-5
WAIVED review-and-ship REQ-8
WAIVED review-and-ship REQ-10
WAIVED review-and-ship REQ-11
WAIVED review-and-ship REQ-15
WAIVED review-and-ship REQ-18
WAIVED spec-contract REQ-5
WAIVED spec-contract REQ-19
WAIVED spec-contract REQ-20
WAIVED spec-contract REQ-24
WAIVED spec-contract REQ-25
WAIVED spec-contract REQ-26
WAIVED unsetup-safety REQ-6
WAIVED unsetup-safety REQ-8
WAIVED unsetup-safety REQ-9
WAIVED unsetup-safety REQ-10
WAIVED unsetup-safety REQ-11
WAIVED unsetup-safety REQ-12
WAIVED unsetup-safety REQ-13
spec-check: 6 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/review-and-ship/tasks.md`
no line found (exit 1)

### 4. Independent review
Reviewer was given only the slug and the base ref. Its reply, unchanged:

## Review: review-and-ship against 374b43ba4bcb6769595730fe58c12586f8803e32

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 (waived) | MET | `plugins/shipkit/agents/reviewer.md:17-26` (takes only the slug and base ref, ignores any summary, reads spec.md, design.md, tasks.md, then the diff) |
| REQ-2 | MET | code `plugins/shipkit/agents/reviewer.md:30-41`; test `plugins/shipkit/evals/reviewer/missing-req/graders/req2-not-met-and-fail.md` (case.yaml cites `review-and-ship/REQ-2`). The eval is a model-run case I did not run. |
| REQ-3 (waived) | MET | `plugins/shipkit/agents/reviewer.md:36-38` |
| REQ-4 (waived) | MET | `plugins/shipkit/agents/reviewer.md:42-44` |
| REQ-5 (waived) | MET | `plugins/shipkit/agents/reviewer.md:45-46` |
| REQ-6 | MET | code `plugins/shipkit/agents/reviewer.md:78-80`; test `plugins/shipkit/evals/reviewer/missing-req/graders/req2-not-met-and-fail.md` (checks `VERDICT: FAIL` and no `VERDICT: PASS`; case.yaml cites REQ-6). Only the FAIL direction is tested here. The PASS direction is covered by the `all-met` eval's grader, `plugins/shipkit/evals/reviewer/all-met/graders/pass-and-nothing-missing.md`. |
| REQ-7 | MET | code `plugins/shipkit/agents/reviewer.md:5-6`; test `scripts/smoke.sh:949-956` (check 27, cites REQ-7) |
| REQ-8 (waived) | MET | `plugins/shipkit/agents/reviewer.md:48-52` and `:71-72` |
| REQ-9 | MET | code `plugins/shipkit/scripts/spec-check.sh:50-60` and `:178`; test `scripts/smoke.sh:958-974` (check 28, cites REQ-9). It checks MISSING-TEST, exit 1, and that spec.md is unchanged. |
| REQ-10 (waived) | MET | `plugins/shipkit/skills/ship/SKILL.md:32-71` (seven steps in order, PASS/FAIL/SKIPPED with evidence) |
| REQ-11 (waived) | MET | `plugins/shipkit/skills/ship/SKILL.md:73-82` (report path, first line READY or NOT READY, waived count, sha). It defers the exact shape to `plugins/shipkit/skills/ship/reference.md`. |
| REQ-12 | MET | code `plugins/shipkit/skills/ship/SKILL.md:75-77`; test `scripts/smoke.sh:976-1000` (check 29, cites REQ-12; asserts the report's first line is `READY`). It needs a live model run, and I did not run it. |
| REQ-13 | MET | code `plugins/shipkit/skills/ship/SKILL.md:42`; test `scripts/smoke.sh:1001-1013` (first line `NOT READY` and a step 3 row marked FAIL) |
| REQ-14 | MET | code `plugins/shipkit/skills/ship/SKILL.md:79` and `:84-87`; test `scripts/smoke.sh:995-999` (asserts the tree has no changes outside the report). The "only after READY and a yes" rule for the Status line is tested only by the prompt telling the run not to change it. |
| REQ-15 (waived) | MET | `plugins/shipkit/skills/ship/SKILL.md:15-16` and `:89-95` |
| REQ-16 | MET | code `plugins/shipkit/skills/escape/SKILL.md:35-50`; test `plugins/shipkit/evals/escape/missing-req/graders/cause-and-new-requirement.md` (case.yaml cites REQ-16). The grader checks for the phrase "requirement missing", not that it is the only cause named. |
| REQ-17 | MET | code `plugins/shipkit/skills/escape/SKILL.md:28-33` and `:76-83`; test `plugins/shipkit/evals/escape/missing-req/graders/cause-and-new-requirement.md` (checks for a proposed REQ-3 containing "shall"; case.yaml cites REQ-17) |
| REQ-18 (waived) | MET | `plugins/shipkit/skills/escape/SKILL.md:21-26` (at most three questions), `:52-72` (record), `:80-83` (`Status: open` plus a failing-first task) |
| REQ-19 | MET | code `plugins/shipkit/stacks/rails/.claude/skills/deploy-check/SKILL.md:11` and `plugins/shipkit/stacks/rails/.claude/skills/release/SKILL.md:12`; test `scripts/lint.py:478-493` (check 13, cites REQ-19). The diff only adds lines in each skill. |

## Changes beyond the spec
- `plugins/shipkit/skills/spec/reference.md` — outside the spec's Paths.

## Decisions not followed
- None. One note: the reviewer uses `model: inherit` (`plugins/shipkit/agents/reviewer.md:4`), where the design says to omit `model:`. The effect is the same, so I don't count it as a deviation. The gate-as-skill decision is followed: `plugins/shipkit/skills/ship/SKILL.md:36` and `:94` require evidence for every step.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 19 MET, 0 NOT MET, 0 CANNOT TELL (9 waived).
VERDICT: PASS

Note from the gate: the reviewer flagged `plugins/shipkit/skills/spec/reference.md` as changed outside the spec's Paths. It did not fail the verdict.

### 5. Migration rollback
`git diff 374b43b...HEAD --name-only`, filtered for `db/migrate/`, `migrations/`, `priv/repo/migrations/`, `alembic/`, `prisma/migrations/`, `*.sql` → no match (exit 1). No migration in the diff.

### 6. Decisions
Both decisions in `design.md` are live (none superseded).
- "The reviewer uses the session's model": "We would reverse this — pin a model — if the `reviewer/missing-req` eval passes on `sonnet` and fails on the session default in two of three runs, or if a single `/shipkit:ship` review of a sprint-sized diff costs more than $2 at list price."
- "The gate is a skill, not a script": "We would reverse this — move the mechanical steps into a script, option 3 — if a gate report in this plan records `PASS` for a step whose evidence is missing or does not match a re-run, even once."

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty

The test run left no new files (`git status --porcelain` was still empty afterwards).
