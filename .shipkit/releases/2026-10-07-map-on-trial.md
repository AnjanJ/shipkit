READY

# Ship report: map-on-trial

> Checked on 2026-10-07 at commit `725462f` on `sprint-8/map-on-trial`, against base `598464a` (merge-base with `main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 4 decisions, reversal conditions concrete |
| 7 | Clean tree | PASS | nothing uncommitted before the gate ran |
| 8 | Decisions fired | PASS | 7 Fired-if entries, all MANUAL, none FIRED |

Requirements: 17 (6 waived as `[untested]`: REQ-5, 12, 13, 14, 16, 17).

## Evidence

### 1. Spec check, as shipped
`sh plugins/shipkit/scripts/spec-check.sh . map-on-trial --as-shipped` → exit 0
```
WAIVED map-on-trial REQ-5
WAIVED map-on-trial REQ-12
WAIVED map-on-trial REQ-13
WAIVED map-on-trial REQ-14
WAIVED map-on-trial REQ-16
WAIVED map-on-trial REQ-17
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0
```
WAIVED trim-and-docs REQ-16
WAIVED unsetup-safety REQ-6
...
WAIVED unsetup-safety REQ-13
spec-check: 10 spec(s) checked, 0 gap(s)
```
Lint line from an earlier run of the same command: `lint: 0 error(s), 0 warning(s) across 34 skills, 7 agents, 21 rules`.
(My first attempt at this step failed on a shell quirk and recorded no result; the run above is the rerun.)

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/map-on-trial/tasks.md` → no line found

### 4. Independent review
Reviewer was given only the slug and the base ref `598464a72caed606143a9be6c6b744a5e433496b`. Its reply, in short:

- REQ-1 to REQ-17: all MET, none NOT MET, none CANNOT TELL (it counted 5 waived; step 1 shows 6).
- Changes beyond the spec: `docs/plans/evidence-sprint-plan.md` is outside `> Paths:`, but `tasks.md` T1 names it with the owner's yes.
- Decisions not followed: none.
- Not covered: general bugs, style, performance, security (`/code-review`).
- It did not run tests; it cited smoke checks 38 to 42.

Its last line: `VERDICT: PASS`

### 5. Migration rollback
`git diff 598464a...HEAD --name-only | /usr/bin/grep -E 'db/migrate/|migrations/|alembic/|prisma/migrations/|\.sql$'` → no match

### 6. Decisions
`design.md` has four live decisions, none superseded:
- XL fixture generated at scaffold time: reverse if all five cases are answered in ≤2 tool calls in all three arms.
- Comparison acts in the same release: reverse if S8-T4's Files line grows beyond eleven files.
- What "optional" means: move to (2) if the nag is reported as noise in the six months after 4.1.0; revisit (3) only on a new measurement.
- What counts as a correct answer: reverse if no-map `drift` runs get the underlying fact wrong.

Each is a metric, event or threshold.

### 7. Clean tree
`git status --porcelain`, captured before step 1 → empty. Also empty after the gate's test run.

### 8. Decisions fired
`sh plugins/shipkit/scripts/decision-check.sh . --run` → exit 0
```
decision-check: 7 decision(s), 0 fired, 0 hold, 7 manual, 0 error(s)
```
The seven `MANUAL` lines are four from `map-on-trial/design.md` and three from `trim-and-docs/design.md`. They need a human, and they do not fail the step.

## Not done
The spec's `> Status:` line is unchanged, as instructed. The run was not interactive.
