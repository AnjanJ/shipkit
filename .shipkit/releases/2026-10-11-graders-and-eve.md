READY

# Ship report: graders-and-eve

> Checked on 2026-10-11 at commit `e554a1f` on `sprint-18/graders-and-eve`, against base `c99ddcc` (merge-base with `main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task (exit 1) |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 7 decisions, each with a concrete reversal condition |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | 0 fired, 2 hold, 59 manual |

Requirements: 10 (6 waived as `[untested]`: REQ-2, 3, 4, 5, 8, 9). The reviewer's own count says 5 waived; step 1's six `WAIVED` lines are the script's count.

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . graders-and-eve --as-shipped` → exit 0
```
WAIVED graders-and-eve REQ-2
WAIVED graders-and-eve REQ-3
WAIVED graders-and-eve REQ-4
WAIVED graders-and-eve REQ-5
WAIVED graders-and-eve REQ-8
WAIVED graders-and-eve REQ-9
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
spec-check: 20 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/graders-and-eve/tasks.md` → exit 1
no line found

### 4. Independent review
## Review: graders-and-eve against c99ddccb6b7445ce35a63f6855543d8cecaf0a3b

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `plugins/shipkit/evals/eve/payments/graders/stripe-twice-insight-none.md:3`. The fourth lookahead is now `(Gemfile\|mix\.exs\|stripe_charge\.rb\|billing/stripe\.ex)` and the other three clauses are untouched in the diff. The case itself is the test: `eve/payments` is cited at `scripts/evals.sh:22` as `graders-and-eve/REQ-1`, with node checks and 9 runs at `docs/design/eval-results-4.11.md:14-29`. The `case.yaml` has no citation. I did not run the pattern through `RegExp`; it is the same syntax as before plus literal alternatives. |
| REQ-2 (waived) | MET | `docs/design/eval-results-4.11.md:27-29` has the three arms with 4.9 counts beside them and `map_read` per cell. The reading at `:46-52` follows the trace description at `:34-44`. |
| REQ-3 (waived) | MET | Sentence at `plugins/shipkit/agents/eve.md:145-146`. Cells at `docs/design/eval-results-4.11.md:71-74` are strict 1 of 3 → 2 of 3 and three-map 3 of 3. Both conditions hold, so the sentence stays. |
| REQ-4 (waived) | MET | `git diff v4.10.0 --stat -- plugins/shipkit/evals/eve/why` is empty. The strict wording is in `docs/design/eval-results-4.11.md:59-64`. |
| REQ-5 (waived) | MET | `.shipkit/decisions/0001-project-map-default.md:139-146` carries the sentence's fate and the three cells. |
| REQ-6 | MET | code `plugins/shipkit/evals/eve/why-reworded/prompt.md`, `fixture.sh`, `graders/vacuum-or-not-recorded.md`. Test: `plugins/shipkit/evals/eve/why-reworded/case.yaml:1` ("Proves graders-and-eve/REQ-6") and `scripts/evals.sh:23`. The `grep -ci` = 0 check is recorded at `docs/design/eval-results-4.11.md:119-122`. The README row and the "what it watches" text are in `plugins/shipkit/evals/README.md`. `git ls-files plugins/shipkit/evals` totals 196,289 bytes, under 196,608. |
| REQ-7 | MET | code `plugins/shipkit/evals/trap2/notebooks/graders/strip-outputs.md:3` matches `execution_count`, quoted `outputs`, and script names. Test: `scripts/evals.sh:25` cites `graders-and-eve/REQ-7`. The node table at `docs/design/eval-results-4.11.md:172-182` and the 4.6, 4.8 and 4.11 counts at `:191-193` back it. The `RegExp` compile check is stated only as node checks, not re-run by me. |
| REQ-8 (waived) | MET | `.shipkit/specs/graders-and-eve/design.md:168-196` holds the record with the counts (2 of 3 in 4.6.0, then 3 of 3 in 4.7.0 to 4.10.0) and the reopen condition. The ROADMAP item points to it, at `ROADMAP.md` in the "Still open" list. |
| REQ-9 (waived) | MET | `docs/design/eval-results-4.11.md:240-246` has the five files, both traps, haiku with and without, no empty cell. The trace reading is at `:251-279` and the reading follows at `:281`. |
| REQ-10 | MET | The note is at `.shipkit/specs/measured-cuts/design.md:73`. `plugins/shipkit/rules/migrations.md` is cut, with only its heading left. Smoke check 58 at `scripts/smoke.sh:2068` uses `cr_gone` for migrations and still `cr_kept`s the other four. Its comment cites `graders-and-eve/REQ-10`. The other four rule files are unchanged. |

## Changes beyond the spec
- None. Every changed file is under `> Paths:` or is this spec's own folder. That covers `.shipkit/decisions/0001-project-map-default.md`, `.shipkit/specs/measured-cuts/design.md`, `.claude-plugin/marketplace.json` and both `plugin.json` files. `plugins/shipkit/rules/migrations.md` is under `rules/`. `plugins/shipkit/evals/README.md` is under `evals/` (the root `README.md` is unchanged).

## Decisions not followed
- None. The payments, eve, probe, notebooks, react, haiku and 59th-case decisions are all consistent with the code. The `package-json` grader is left uncorrected, as the T5 task's Files line implies.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 10 MET, 0 NOT MET, 0 CANNOT TELL (5 waived).
VERDICT: PASS

### 5. Migration rollback
`git diff c99ddcc...HEAD --name-only` lists 23 files; none under `db/migrate/`, `migrations/`, `alembic/`, `prisma/migrations/`, or any `*.sql`. No migration in the diff.

### 6. Decisions
All seven live decisions in `.shipkit/specs/graders-and-eve/design.md` carry a "We would ..." clause with a measured trigger:
- design.md:45 — `payments` grader: "We would widen the clause again if a release run's miss cites a handling..."
- :86 — `eve` sentence: "We would take the sentence out, by its own rule, if the strict arm reads..."
- :123-125 — reworded why probe: "We would write the step-0 sentence ... We would drop the probe if it reads 3 of 3..."
- :162 — `notebooks` grader: "We would move to (2) if a release run's miss is a Makefile that clears..."
- :193 — `react`: "We would add the prompt line (2) if `trap2/react` drops below 2 of 3 in a..."
- :227 — haiku measurement: "We would stop the measurement and keep every file if the with-rule arm of..."
- :253 — 59th case: "We would move to (2) if a release run passes $25 or the case count passes..."

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run` → exit 0
```
MANUAL .shipkit/decisions/0002-spec-first-eval.md: We would revert the sentence if `rules/nontrivial` passes fewer than two of three runs in two consecutive release runs of `scripts/evals.sh`, or if `rules/trivial` drops below three of three in any release run (the gate costing a turn on trivial work), or if a user reports being asked for a yes on work they called trivial. We would reopen the question — as the plan's clause put it — if a user reports building without a spec after asking for one.
HOLDS  .shipkit/decisions/0003-overlay-skills-home.md: test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2
MANUAL .shipkit/specs/gate-blind-spots/design.md (A trailing HTML comment is stripped, not rejected): We would move to (2) if a `Fired-if` command is found cut short by the strip in any real or eval run.
MANUAL .shipkit/specs/gate-blind-spots/design.md (Everything under `.shipkit/` is allowed, except another spec's folder): We would move to (2) if an agent is observed writing a file under `.shipkit/` (outside any spec folder) that a task did not ask for, in any real or eval run.
MANUAL .shipkit/specs/gate-blind-spots/design.md (Exit codes are echoed on the command line, output is read from a file): We would move to (2) or add a script if a ship report after 4.5.0 is found to say an exit code was not captured, or to carry evidence that differs from the command's output on the same tree.
MANUAL .shipkit/specs/gate-blind-spots/design.md (Ignored files are invisible to `brief-verify.sh`, by design): We would build (2) if an agent is observed, in a real run, writing a file into an ignored path that the task's Done-when did not catch.
MANUAL .shipkit/specs/graders-and-eve/design.md (The `payments` grader accepts the handling file as evidence): We would widen the clause again if a release run's miss cites a handling file the fixture holds (`FACTS-PORTFOLIO.md`, P2) that the pattern does not name; we would drop the clause if a miss cites nothing at all yet names the right projects and provider — then the evidence clause is what the question does not ask for.
MANUAL .shipkit/specs/graders-and-eve/design.md (`eve` is measured, given one sentence, and measured again): We would take the sentence out, by its own rule, if the strict arm reads below 2 of 3 with it or the three-map arm drops below 3 of 3; we would reopen (2) if a release run's `why` trace shows the sentence making `eve` answer "not recorded" where the map held the reason.
MANUAL .shipkit/specs/graders-and-eve/design.md (The reworded why is a probe, kept whichever way it falls): We would write the step-0 sentence — in the plan after, not this one — if the probe reads below 2 of 3 on the reason with `map_read` 0, which is the "wrong answer the map, when read, gets right" that 0001 names. We would drop the probe if it reads 3 of 3 with `map_read` 3 in two release runs: then the grep-first path finds a map without the shared word and the question is answered.
MANUAL .shipkit/specs/graders-and-eve/design.md (The `notebooks` grader is widened on its own trace): We would move to (2) if a release run's miss is a Makefile that clears outputs by a means the pattern does not name — a second miss of the 4.8 kind.
MANUAL .shipkit/specs/graders-and-eve/design.md (`react`'s no-build run is closed by record): We would add the prompt line (2) if `trap2/react` drops below 2 of 3 in a release run and the traces show the no-build shape in two of its three runs — then the rule fires on this prompt more often than not, and the line it probes is not being measured.
MANUAL .shipkit/specs/graders-and-eve/design.md (The five kept files are measured on `haiku`, and the clause decides): We would stop the measurement and keep every file if the with-rule arm of any file reads below 2 of 3 on `haiku` — then the model is not following the line even when told, and "unaided" has no meaning on it. A cut line returns by the measured-cuts clause (its case below 2 of 3 in a release run).
MANUAL .shipkit/specs/graders-and-eve/design.md (The release run accepts a fifty-ninth case): We would move to (2) if a release run passes $25 or the case count passes 80 — then the suite has outgrown "every case, every release".
MANUAL .shipkit/specs/harness-debts/design.md (A draft is checked by a flag, not by a status flip): We would move to (2) if a spec is found accepted (stamped `open`) with a task-format gap that `--as-open` would have reported, in any real or eval run after 4.7.0 — that is, if the flag goes unused where it was needed.
MANUAL .shipkit/specs/harness-debts/design.md (The gate removes its own scratch files): We would move to (2) if a ship report after 4.7.0 is found to carry an evidence block that differs from what its command printed on the same tree — the file would then be worth keeping until the owner has compared them.
MANUAL .shipkit/specs/harness-debts/design.md (The runner restores `plugin-root`; the hook keeps writing it): We would move to (2) if an interactive session is found running on a scratch root after a smoke run has *ended* — that is, if the trap did not restore it — or if the mid-run window bites the owner twice.
MANUAL .shipkit/specs/harness-debts/design.md (`map_read` matches its document; `map_shell` is a second column): We would move to (2) if a future elder measurement is judged on the sum of the two columns rather than on `map_read` — at that point the split has stopped earning its column.
MANUAL .shipkit/specs/harness-debts/design.md (The dotfile refusal is probed once, then recorded): We would move to (3) if the sandbox's rule is found changed by a Claude Code release — a case under `trap2/` that passes or fails on a dotfile where it did not before — since then the README's paragraph is stale and a watch is cheaper than a re-probe.
MANUAL .shipkit/specs/harness-debts/design.md (Rule 5 and the gate are reconciled by the rulebook, not the skill): We would add (2)'s sentence if a gate after 4.7.0, in this repository or a real run, says READY on a spec whose wording note was committed after the report.
MANUAL .shipkit/specs/map-on-trial/design.md (The XL fixture is generated at scaffold time, never committed): We would reverse this — commit a real-repository fixture and raise the budget — if, on the generated fixture, every one of the five cases is answered in two tool calls or fewer in all three arms, which would mean the generator failed to make a codebase that needs searching.
MANUAL .shipkit/specs/map-on-trial/design.md (The comparison acts in the same release): We would reverse this — split the change into its own sprint — if S8-T4's Files line has to grow beyond the eleven files it names, which would mean "optional" is a bigger change than B4 describes.
MANUAL .shipkit/specs/map-on-trial/design.md (What "optional" means, if it comes to that): We would move to (2) if, in the six months after 4.1.0, the nag is reported as noise by a project that deliberately keeps no map (it should be impossible — the nag needs a map — so a report would mean a bug, not a policy change). We would revisit (3) only on a new measurement, never on this one.
MANUAL .shipkit/specs/map-on-trial/design.md (What counts as a correct answer, settled before the run): We would reverse this — count `drift` as given — if the no-map `drift` runs get the underlying fact wrong (an in-process dict in `app/inventory/cache.py`), because then the failure would be a wrong answer, not a missing accusation.
MANUAL .shipkit/specs/measured-cuts/design.md (A line followed unaided on both traps comes out; its case stays as the watch): A cut line returns to its file if its trap-1 or trap-2 case — unchanged, run on the trimmed file — drops below 2 of 3 in a release run; the restore is the first task of the next sprint, or the same commit when it happens on this sprint's re-run. A kept file's lines are cut in a later plan if a third measurement on another model shows the same reading.
MANUAL .shipkit/specs/measured-cuts/design.md (The elder's step 0 stays; a read that changes no answer is not worth its tokens): We would run (2), or change step 0, if an elder case on a fixture where the grep does *not* land (the portfolio `why` case of Sprint 16 is the first) gives a wrong answer that the map, when read, gets right.
MANUAL .shipkit/specs/measured-cuts/design.md (The intake's assumption names its file; the four-question ceiling counts parts): The second sentence comes out if `intake/limit` is still below 2 of 3 on the release run after it is added — then the ceiling, not the wording, is the problem, and a record for the plan after says so.
MANUAL .shipkit/specs/portfolio-run/design.md (A portfolio fixture and three `eve` cases under three arms): The three-arm design is wrong if `why` passes in the no-map arm by reading the reason from a file — then the generator leaked the fact and REQ-5's grep in check 59 is what catches it; the `jobs` or `payments` case is rewritten if it passes 3 of 3 in every arm by the registry's `Stack` column alone (the trace shows no manifest opened), since then it measures the registry and not `eve`.
MANUAL .shipkit/specs/portfolio-run/design.md (The second real run is on a repository of another stack, and fixes nothing): We would run (2) in the plan after if this run's findings are all marked the project's fault in "Whose fault" — then a second stack said nothing about shipkit and the Rails project's fixes are still unmeasured.
MANUAL .shipkit/specs/portfolio-run/design.md (The release run grows to 58 cases, every case every release): We would move to (2) if a release run passes $25 or if two consecutive release runs change no count from the run before — then the full run is a receipt, not a measurement.
MANUAL .shipkit/specs/real-run/design.md (The citation debt is shown, not enforced, before the gate): We would move to (3) if a release gate after 4.3.0 fails its first run on an uncited requirement despite the `PENDING-TEST` line having been printed for it.
HOLDS  .shipkit/specs/real-run/design.md (The stack overlay skills stay in core): test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2
MANUAL .shipkit/specs/real-run/design.md (The real run is on the owner's repository, notes only): We would re-run on a second repository before the next plan if the notes list fewer than three awkwardnesses, which would mean the run was too small to learn from.
MANUAL .shipkit/specs/rule-evals/design.md (One case per rule file, eighteen of them): We would fold cases back to one per stack if the eighteen rule cases cost more than $10 in a single release run of `scripts/evals.sh` (their share of the bill, from `trace-tools.sh`), which would mean the fixtures grew past "three to six files, nothing run".
MANUAL .shipkit/specs/rule-evals/design.md (The eval ceiling moves to 128 KB): We would stop raising the ceiling and start cutting cases if a release ships with `plugins/shipkit/evals/` above 120 KB and no case added since 4.2.0, which would mean the room went to padding, not cases.
MANUAL .shipkit/specs/rule-evals/design.md ("Without the rule" is setup's install minus one file): We would switch to (2) if, in T4, the without arm of any case shows the rule under test's first trap line in its trace context (a rule that arrived another way), or if the installers fail inside the sandbox and the fallback cannot be made to write a manifest.
MANUAL .shipkit/specs/rule-evals/design.md (The rule under test reaches the sandbox through the hook): We would remove the branch and move to (2) if a Claude Code release stops setting `CLAUDE_CODE_EVAL_CONFINED` in the eval child (the smoke check that reads it would go red), or if a user reports the hook printing a rule in a project that is not an eval sandbox.
MANUAL .shipkit/specs/rule-evals/design.md (The pre-trim arm, and how its text is found): We would move to (2) if `git show` from the scaffold fails inside the eval sandbox for the repository path in T1's Check first and its explicit `--repo` fallback also fails.
MANUAL .shipkit/specs/rule-evals/design.md (`--group` exists; the release run still runs everything): We would adopt (2) if a release run of `scripts/evals.sh` passes $25 at list price, which is where "run everything" stops being the cheap default.
MANUAL .shipkit/specs/rule-evals/design.md (The stopping rule for `rules/nontrivial`): We would reopen this if `rules/nontrivial` passes fewer than one run in ten across three consecutive releases, or if a user reports building without a spec after asking for one — the clause the plan wrote, carried into 0002.
MANUAL .shipkit/specs/run-debts/design.md (The installer looks for the heading before it appends): We would move to (2) if the third real run (E17) shows a project that already carries the heading ending with both sections after the user read the line — then the line is not enough and the installer must choose.
MANUAL .shipkit/specs/run-debts/design.md (A same-named rule beside shipkit's is named, not merged): We would extend the comparison to overlay rules if a real run shows a same-named overlay rule beside shipkit's that the line missed.
MANUAL .shipkit/specs/run-debts/design.md (A tracked backup stays where it is): We would move the backup phase into a script if the third real run shows the model nesting a tracked backup with the sentence in front of it.
MANUAL .shipkit/specs/run-debts/design.md (The brief warns on a dirty tree; the verifier is unchanged): We would build (2) if a later real run hands over from a dirty tree with the line printed — then the reminder is not read and the verifier must cope.
MANUAL .shipkit/specs/run-debts/design.md (Setup's two directories join the always-allowed list): We would add (2) if two consecutive real runs report `CLAUDE.md` and `.gitignore` as beyond the spec with no change in them but setup's.
MANUAL .shipkit/specs/run-debts/design.md (One sentence tells the reviewer where a line number comes from): We would build (2) if the third real run's reviewer cites a diff position with the sentence in place.
MANUAL .shipkit/specs/run-debts/design.md (The gate pastes the reviewer's reply from a file): We would reverse to a sentence-only approach if check 29 shows the block pasted from the file still condensed in two consecutive smoke runs — then the file is not the mechanism.
MANUAL .shipkit/specs/run-debts/design.md (The leaked wait sentence is closed by record): We would add the sentence (2) if an interactive session's reply opens with a wait sentence and continues — then it is the skill's shape, not the harness's.
MANUAL .shipkit/specs/run-debts/design.md (Two cache directories go, each on its own yes): We would stop at F1 if `claude plugin list` or the next session's hook line names `4.6.0` after its removal — then the manager still wanted it.
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
decision-check: 61 decision(s), 0 fired, 2 hold, 59 manual, 0 error(s)
```
