# /shipkit:ship — Report format

`.shipkit/releases/<YYYY-MM-DD>-<slug>.md`. The first line is read by scripts and by people in
a hurry: exactly `READY` or `NOT READY`, nothing else on it.

```markdown
NOT READY

# Ship report: refunds

> Checked on 2026-10-06 at commit `a1b2c3d` on `feature/refunds`, against base `9f8e7d6`.

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `python3 -m unittest discover -s tests` → exit 0 |
| 3 | Tasks ticked | FAIL | 1 task not ticked: T2 |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 1 decision, reversal condition concrete |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | 1 Fired-if command, HOLDS |

Requirements: 3 (1 waived as `[untested]`).

## To fix before shipping
- Step 3: tick T2 in `.shipkit/specs/refunds/tasks.md` once it is done, or finish it.

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . refunds --as-shipped` → exit 0
<the script's output, pasted>

### 2. Tests
`python3 -m unittest discover -s tests` → exit 0
<the last 20 lines of shipkit-ship-tests.out, pasted from the file>

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/refunds/tasks.md` → exit 1
<the lines found, or "no line found">

### 4. Independent review
<the reviewer's whole reply, unchanged>

### 5. Migration rollback
<the migration files found and where the rollback is written, or "no migration in the diff">

### 6. Decisions
<each live decision's title and its reversal condition, quoted>

### 7. Clean tree
`git status --porcelain`, captured before step 1
<its output, or "empty">
<a note on any files the gate's own test run left behind>

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run` → exit 0
<every FIRED, HOLDS, MANUAL and ERROR line and the summary line, pasted from shipkit-ship-decisions.out>
```

Rules:

- One row per step, always all eight, numbered 1 to 8 in the first column.
- `Result` is `PASS`, `FAIL` or `SKIPPED` and nothing else.
- When the first line is `READY`, leave out "To fix before shipping".
- The evidence section is not optional: a result with no evidence under it is not a result.
- Every `→ exit N` is the number the command's own `echo "exit $?"` printed, and every output
  block is pasted from the command's captured output. Nothing in the evidence is typed from
  memory, and "exit code not captured" never appears.
- Write the plugin's location as `<plugin root>` in commands, never the absolute path: the
  report is committed, and a path from one machine is noise on every other.
