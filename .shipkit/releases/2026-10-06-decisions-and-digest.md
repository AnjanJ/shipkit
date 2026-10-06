READY

# Ship report: decisions-and-digest

> Checked on 2026-10-06 at commit `5ad877611092eb27cf6fa1506c8ae09ef1986c57` on `sprint-6/decisions-and-digest`, against base `835786805646625c1f5eddc03892a4be48834703` (merge-base with `main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0, 0 gaps |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no line found |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 3 decisions, reversal conditions concrete |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | none recorded (0 decisions with a Fired-if line) |

Requirements: 18 (4 waived as `[untested]`: REQ-2, REQ-10, REQ-11, REQ-18).

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . decisions-and-digest --as-shipped` → exit 0
```
WAIVED decisions-and-digest REQ-2
WAIVED decisions-and-digest REQ-10
WAIVED decisions-and-digest REQ-11
WAIVED decisions-and-digest REQ-18
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0
```
WAIVED unsetup-safety REQ-13
spec-check: 8 spec(s) checked, 0 gap(s)
```
Lint: `lint: 0 error(s), 0 warning(s) across 35 skills, 7 agents, 25 rules`

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/decisions-and-digest/tasks.md`
no line found

### 4. Independent review
Review: decisions-and-digest against 835786805646625c1f5eddc03892a4be48834703

The reviewer read the diff and files and did not run the tests. Verdicts (full table in the reviewer's reply):
REQ-1 to REQ-18 all MET, each with a file or smoke check (`scripts/smoke.sh` checks 34 to 37) cited.
REQ-16 has no smoke check citing it; its only test is the eval under `plugins/shipkit/evals/digest/attention/`, which the reviewer did not see run.

Changes beyond the spec: version bumps (`.claude-plugin/marketplace.json`, both `plugin.json`), `CHANGELOG.md`, `README.md`, and `plugins/shipkit/scripts/spec-check.sh` (`mktemp` takes a `TMPDIR` template; unrelated to the spec's behaviour).

Decisions not followed: none.

Requirements: 18 MET, 0 NOT MET, 0 CANNOT TELL (4 waived).
VERDICT: PASS

### 5. Migration rollback
no migration in the diff

### 6. Decisions
- A decision may carry a command, run only on request: reverse "if a `Fired-if` command in any project the owner registers does something other than read files or run a read-only command, or if fewer than one in five records written during this plan carries a command rather than `manual`."
- Exit status 0 means "fired": reverse "if, in this plan's own records, more than one `Fired-if` command is written inverted by mistake."
- A local script writes the digest, not a scheduled cloud agent: reverse "if every project in the owner's registry is on GitHub and the local digest is missed in two consecutive weeks because the machine was off."

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run` → exit 0
```
decision-check: 0 decision(s), 0 fired, 0 hold, 0 manual, 0 error(s)
```
