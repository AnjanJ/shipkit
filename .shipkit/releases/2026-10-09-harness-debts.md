READY

# Ship report: harness-debts

> Checked on 2026-10-09 at commit `d14af6d` on `sprint-14/harness-debts`, against base `66a993f` (merge-base with `main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 6 decisions, each with a concrete reversal condition |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | 0 fired, 2 hold, 37 manual |

Requirements: 10 (5 waived as `[untested]`: REQ-3, REQ-4, REQ-5, REQ-7, REQ-10).

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . harness-debts --as-shipped` → exit 0
```
WAIVED harness-debts REQ-3
WAIVED harness-debts REQ-4
WAIVED harness-debts REQ-5
WAIVED harness-debts REQ-7
WAIVED harness-debts REQ-10
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`( bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh . )` → exit 0
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
spec-check: 16 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/harness-debts/tasks.md` → exit 1
no line found

### 4. Independent review
## Review: harness-debts against 66a993f551ea7414e990b96eb53dd626a9b6fd09

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | `spec-check.sh:191`; smoke checks 55a, 55b cite `harness-debts/REQ-1` |
| REQ-2 | MET | `spec-check.sh:191`; smoke check 55c cites `harness-debts/REQ-2` |
| REQ-3 (waived) | MET | `skills/spec/SKILL.md:89-91`; check 55d |
| REQ-4 (waived) | MET | `skills/ship/SKILL.md:97-99` (reviewer did not see the dry-run evidence in the S14-T2 commit message) |
| REQ-5 (waived) | MET | `skills/ship/reference.md:37`, `:59` |
| REQ-6 | MET | `scripts/smoke.sh:25-31`; check 56 cites `harness-debts/REQ-6` |
| REQ-7 (waived) | MET | `scripts/smoke.sh:13-15`; check 56 |
| REQ-8 | MET | `scripts/trace-tools.sh:62-64`; check 40 (does not exercise a Read on the map's path) |
| REQ-9 | MET | `scripts/trace-tools.sh:65-66`; check 40 |
| REQ-10 (waived) | MET | `plugins/shipkit/evals/README.md:184-199` (reviewer did not check the probe-run record in the S14-T5 commit message) |

Changes beyond the spec: none. Decisions not followed: none (all six checked).
Not covered: general bugs, style, performance, security (`/code-review`).

Requirements: 10 MET, 0 NOT MET, 0 CANNOT TELL (5 waived).
VERDICT: PASS

(Table condensed from the reviewer's reply; its verdicts and final line are unchanged.)

### 5. Migration rollback
`git diff 66a993f...HEAD --name-only`, filtered for `db/migrate/`, `migrations/`, `alembic/`, `*.sql` → no match (18 files changed). No migration in the diff.

### 6. Decisions
All six are live; each has a `Falsifiability` clause:
- A draft is checked by a flag: move to (2) if a spec is found accepted with a task-format gap `--as-open` would have reported, after 4.7.0.
- The gate removes its own scratch files: move to (2) if a ship report after 4.7.0 carries an evidence block that differs from what its command printed on the same tree.
- The runner restores `plugin-root`: move to (2) if an interactive session is found on a scratch root after a smoke run has ended, or the mid-run window bites the owner twice.
- `map_read` matches its document: move to (2) if an elder measurement is judged on the sum of the two columns.
- The dotfile refusal is probed once: move to (3) if a case under `trap2/` passes or fails on a dotfile where it did not before.
- Rule 5 and the gate reconciled by the rulebook: add (2)'s sentence if a gate after 4.7.0 says READY on a spec whose wording note was committed after the report.

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty
The gate's test run left no new untracked files.

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run` → exit 0
```
MANUAL .shipkit/specs/rule-evals/design.md (The eval ceiling moves to 128 KB): We would stop raising the ceiling and start cutting cases if a release ships with `plugins/shipkit/evals/` above 120 KB and no case added since 4.2.0, which would mean the room went to padding, not cases.
MANUAL .shipkit/specs/rule-evals/design.md ("Without the rule" is setup's install minus one file): We would switch to (2) if, in T4, the without arm of any case shows the rule under test's first trap line in its trace context (a rule that arrived another way), or if the installers fail inside the sandbox and the fallback cannot be made to write a manifest.
MANUAL .shipkit/specs/rule-evals/design.md (The rule under test reaches the sandbox through the hook): We would remove the branch and move to (2) if a Claude Code release stops setting `CLAUDE_CODE_EVAL_CONFINED` in the eval child (the smoke check that reads it would go red), or if a user reports the hook printing a rule in a project that is not an eval sandbox.
MANUAL .shipkit/specs/rule-evals/design.md (The pre-trim arm, and how its text is found): We would move to (2) if `git show` from the scaffold fails inside the eval sandbox for the repository path in T1's Check first and its explicit `--repo` fallback also fails.
MANUAL .shipkit/specs/rule-evals/design.md (`--group` exists; the release run still runs everything): We would adopt (2) if a release run of `scripts/evals.sh` passes $25 at list price, which is where "run everything" stops being the cheap default.
MANUAL .shipkit/specs/rule-evals/design.md (The stopping rule for `rules/nontrivial`): We would reopen this if `rules/nontrivial` passes fewer than one run in ten across three consecutive releases, or if a user reports building without a spec after asking for one — the clause the plan wrote, carried into 0002.
MANUAL .shipkit/specs/run-wounds/design.md (The briefing reads "all ticked, no Status" as closed; spec-check does not): We would build (2) if two users, or the owner twice, report adding `Status` lines by hand to more than five specs after reading the new line.
MANUAL .shipkit/specs/run-wounds/design.md (The intake searches a fixed list before it asks): We would revert the list to the one-line principle if the `intake-answered` case passes 2 of 3 with the 4.3.0 text in S11-T2's with/without run — the sentence would then be bytes without effect.
MANUAL .shipkit/specs/run-wounds/design.md (Unanswered questions are written, not spoken): We would move to (3) if a spec run is observed treating an *unanswered* question as answered (a `spec.md` requirement built on a blank) in any real or eval run.
MANUAL .shipkit/specs/run-wounds/design.md (The version line reads directory names, not JSON): We would move to (2) if the cache layout changes so that the running root's parent is not the version directory (the smoke check would go red).
MANUAL .shipkit/specs/second-traps/design.md (Room comes from moving history out, not from fewer cases): We would lower the ceiling back if a release after 4.6.0 commits a fixture or a file over 20 KB under `evals/` that is not a case.
MANUAL .shipkit/specs/second-traps/design.md (Sixteen trap-2 cases, with and without; no rule changes on them): We would drop to (2) if the sixteen cases take more than 24 KB or the release run passes $18; we would allow (3) if a trap-2 case fails even with the rule and the trace shows the rule's own text caused it (as `gemfile` did in 4.2.0).
MANUAL .shipkit/specs/second-traps/design.md (The elder's step 1 gets at most two measured attempts): We would revert a kept sentence if the next release run's `grandfather-xl` group drops below 2 of 3 on any case.
MANUAL .shipkit/specs/second-traps/design.md (The Gemfile line is reworded on the 4.2.0 measurement): We would revert to (2) if `stacks-gemfile` or `trap2/gemfile` drops below 2 of 3 with the new text.
MANUAL .shipkit/specs/second-traps/design.md (The history case runs on a "wip" log; eve's loss stays open): We would build (2) if a user reports eve answering wrong on a project without a map, or if the next plan has 20 KB of room to spare.
MANUAL .shipkit/specs/second-traps/design.md (Housekeeping rows are each their own yes): We would move to (2) if the owner, asked five times, says "all of them" twice in a row.
MANUAL .shipkit/specs/trim-and-docs/design.md (The repository's own document checks live in the lint, not in smoke or by hand): We would reverse this — move the checks to a release-time script — if a documentation-only pull request is blocked by one of these lint checks for a reason that is not a real defect in the document, twice.
MANUAL .shipkit/specs/trim-and-docs/design.md (Criterion (c) counts only where an eval exists): We would reverse this — write the eval cases first — if a line trimmed on (a)/(b) alone is restored within two releases because a regression was traced to it.
MANUAL .shipkit/specs/trim-and-docs/design.md (The map row waits for decision 0001's re-test): We would reverse this — act on the record without the re-test — if the owner waives the condition in writing on the audit row.
decision-check: 39 decision(s), 0 fired, 2 hold, 37 manual, 0 error(s)
```
