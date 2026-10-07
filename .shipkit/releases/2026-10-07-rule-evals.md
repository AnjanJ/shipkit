READY

# Ship report: rule-evals

> Checked on 2026-10-07 at commit `8793815` on `sprint-9/rule-evals`, against base `d8c7fb8` (merge-base with `main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no database migration in the diff |
| 6 | Decisions | PASS | every live decision has a concrete reversal condition |
| 7 | Clean tree | PASS | nothing uncommitted before the gate ran |
| 8 | Decisions fired | PASS | 15 entries, all MANUAL, none FIRED |

Requirements: 22 (8 waived as `[untested]`: REQ-13 to REQ-20).

## Evidence

### 1. Spec check, as shipped
`sh plugins/shipkit/scripts/spec-check.sh . rule-evals --as-shipped` → exit 0
```
WAIVED rule-evals REQ-13 … REQ-20 (eight lines)
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0
```
lint: 0 error(s), 0 warning(s) across 34 skills, 7 agents, 21 rules
...
WAIVED unsetup-safety REQ-13
spec-check: 11 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/rule-evals/tasks.md` → no line found (5 of 5 done).

### 4. Independent review
Reviewer was given only the slug and the base ref `d8c7fb8b3681634d43b520a0c249c5ae9baf8c46`. Its reply:

> ## Review: rule-evals against d8c7fb8
> REQ-1, 2, 3, 4, 21, 22, 5, 6, 7, 8, 9, 10, 11, 12: MET, each with code and test location
> (with-rule.sh, inject-rule.sh, stack-gen.sh, scripts/evals.sh, scripts/lint.py, scripts/smoke.sh).
> REQ-13 (waived): MET, checked on the ui-ux case only; 54 of 54 with-arm passes in eval-results-4.2.md.
> REQ-14, 15, 16 (waived): MET (eighteen-row results table; four "same text" rows; 14 criterion (c) rows in trim-audit-4.0.md, additions only).
> REQ-17 (waived): MET (record 0002 has Context, Alternatives, concrete reversal clause).
> REQ-18 (waived): MET, always-on rules total 2,979 bytes, under 3,000.
> REQ-19 (waived): MET, nontrivial 3 of 3 (6 of 6 with extra runs); the reviewer read these results and did not re-run them.
> REQ-20 (waived): MET.
>
> Changes beyond the spec: `plugins/shipkit/hooks/hooks.json` and `plugins/shipkit/scripts/inject-rule.sh` are outside `> Paths:`, but tasks.md T1's Files line lists them as added with the owner's yes on 2026-10-07. Nothing else.
> Decisions not followed: none. (The superseded "without the rule" record is not checked; its replacement is followed.)
>
> Requirements: 22 MET, 0 NOT MET, 0 CANNOT TELL (7 waived).
> VERDICT: PASS

Note: the reviewer says 7 waived; step 1 prints 8 `WAIVED` lines (REQ-13 to REQ-20). This report uses step 1's count.

### 5. Migration rollback
No file under `db/migrate/`, `priv/repo/migrations/`, `alembic/`, `prisma/migrations/`, and no `*.sql`, changed. Four files under `plugins/shipkit/evals/scoped/migrations/` matched a loose `migrations/` pattern; they are eval-case files for a rule about migrations, not database migrations.

### 6. Decisions
Every live `## Decision:` in `design.md` carries a reversal clause naming a cost, a pass count, a size or an event (e.g. "more than $10 in a single release run", "above 120 KB and no case added", "a Claude Code release stops setting `CLAUDE_CODE_EVAL_CONFINED`"). "Without the rule is setup's install minus one file" is marked superseded and was not judged.

### 7. Clean tree
`git status --porcelain` before step 1: empty. Nothing new was left behind by the test run (status empty afterwards too).

### 8. Decisions fired
`sh plugins/shipkit/scripts/decision-check.sh . --run` → exit 0
```
decision-check: 15 decision(s), 0 fired, 0 hold, 15 manual, 0 error(s)
```
The 15 MANUAL lines cover `.shipkit/decisions/0002-spec-first-eval.md` and the `design.md` files of map-on-trial, rule-evals and trim-and-docs. None is FIRED.
