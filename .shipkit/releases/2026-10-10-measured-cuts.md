READY

# Ship report: measured-cuts

> Checked on 2026-10-10 at commit `28a9853` on `sprint-15/measured-cuts`, against base `ce58c95` (merge-base with `main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `( bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh . )` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 3 decisions, each with a concrete reversal condition |
| 7 | Clean tree | PASS | `git status --porcelain` empty before step 1 |
| 8 | Decisions fired | PASS | 0 fired, 2 hold, 40 manual |

Requirements: 6 (4 waived as `[untested]`: REQ-3, REQ-4, REQ-5, REQ-6).

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . measured-cuts --as-shipped; echo "exit $?"` → exit 0
```
WAIVED measured-cuts REQ-3
WAIVED measured-cuts REQ-4
WAIVED measured-cuts REQ-5
WAIVED measured-cuts REQ-6
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`( bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh . ) > out 2>&1; echo "exit $?"` → exit 0
```
WAIVED unsetup-safety REQ-13
spec-check: 17 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/measured-cuts/tasks.md; echo "exit $?"` → exit 1
no line found

### 4. Independent review
Reviewer reply (REQ-1 and REQ-2 MET with file and line; REQ-3 to REQ-6 waived, each MET on inspection):
- REQ-1 MET: 14 lines deleted across 7 rule files; smoke check 58 (`scripts/smoke.sh:1998-2008`).
- REQ-2 MET: the 14 trap-1 and trap-2 case directories are untouched; the README records the watch.
- REQ-3 MET (waived): the five kept files are not in the diff.
- REQ-4 MET (waived): `plugins/shipkit/evals/README.md:325-335`.
- REQ-5 MET (waived): `plugins/shipkit/skills/intake/SKILL.md:57-62`.
- REQ-6 MET (waived): `.shipkit/decisions/0001-project-map-default.md:113-126`.
- Changes beyond the spec: none. Decisions not followed: none.

Requirements: 6 MET, 0 NOT MET, 0 CANNOT TELL (4 waived).
VERDICT: PASS

### 5. Migration rollback
`git diff ce58c95...HEAD --name-only` filtered for migration paths and `*.sql` → no match. No migration.

### 6. Decisions
Three live decisions in `design.md`, each with a falsifiability clause naming a threshold or event:
- Cut lines: a cut line returns if its trap case drops below 2 of 3 in a release run.
- Elder's step 0: change it if an elder case where the grep does not land gives a wrong answer that the map gets right.
- Intake: the second sentence comes out if `intake/limit` is still below 2 of 3 on the release run.

### 7. Clean tree
`git status --porcelain` before step 1 → empty.

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run; echo "exit $?"` → exit 0
```
decision-check: 42 decision(s), 0 fired, 2 hold, 40 manual, 0 error(s)
```
The MANUAL lines (40) are not failures. Those for this spec are the three above.
