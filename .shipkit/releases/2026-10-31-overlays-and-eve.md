READY

# Ship report: overlays-and-eve

> Checked on 2026-10-31 at commit `9bc13af` on `sprint-22/run-again`, against base `0615060` (given in the request).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task, exit 1 |
| 4 | Independent review | PASS | VERDICT: PASS (13 MET, 0 NOT MET, 4 waived) |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 6 decisions, each with a concrete reversal condition |
| 7 | Clean tree | PASS | empty |
| 8 | Decisions fired | PASS | 0 fired, 4 hold, 83 manual |

Requirements: 17 (4 waived as `[untested]`: REQ-5, REQ-6, REQ-8, REQ-10).

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . overlays-and-eve --as-shipped` → exit 0
```
WAIVED overlays-and-eve REQ-5
WAIVED overlays-and-eve REQ-6
WAIVED overlays-and-eve REQ-8
WAIVED overlays-and-eve REQ-10
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0
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
spec-check: 24 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/overlays-and-eve/tasks.md` → exit 1
no line found

### 4. Independent review
## Review: overlays-and-eve against 0615060

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `plugins/shipkit/scripts/install-stack.sh:30-31,118-123`; test `scripts/smoke.sh:2406-2421` (check 67, cites `overlays-and-eve/REQ-1`) |
| REQ-2 | MET | code `plugins/shipkit/scripts/install-stack.sh:30-31`; test `scripts/smoke.sh:2422-2428` (4 skills installed and listed in the manifest) |
| REQ-3 | MET | code `plugins/shipkit/skills/setup/SKILL.md:250-256` (asks once, names the count, says "listed in every session", non-interactive takes no skills); test `scripts/smoke.sh:2432-2436`, which only greps the text |
| REQ-4 | MET | `unsetup-remove.sh` is unchanged (it is manifest-driven); test `scripts/smoke.sh:2429-2431` covers both installs |
| REQ-5 (waived) | MET | `docs/design/trim-audit-overlays.md:44-133` has per-stack row tables, python first. I did not count rows against the append lines one by one. |
| REQ-6 (waived) | MET | `docs/design/trim-audit-overlays.md:8` defines "kept on the owner's word"; the owner's decisions are at `:184`. The file state is pinned by `scripts/smoke.sh:2439-2456` (cites REQ-6/7). |
| REQ-7 | MET | `plugins/shipkit/stacks/rails/.claude/rules/rails.md:2-6` and `plugins/shipkit/stacks/react/.claude/rules/react.md:2-7` carry `paths:`; test `scripts/smoke.sh:2457-2461`. Python's `django.md` is also scoped. |
| REQ-8 (waived) | MET | `docs/design/trim-audit-overlays.md:141-172`: all eleven skills with the covering text and a verdict. The table shows the covering text as prose, not as lines set side by side. I judged that sufficient. |
| REQ-9 | MET | `deploy-check` and `safety-check` are deleted from `plugins/shipkit/stacks/rails/.claude/skills/`; the owner's yes is at `docs/design/trim-audit-overlays.md:166`; test `scripts/smoke.sh:2465-2484` (check 69, cites REQ-9) |
| REQ-10 (waived) | MET | `.shipkit/decisions/0004-overlay-skills-flag.md:47` (Falsifiability) and `:51` (Fired-if); `.shipkit/decisions/0003-overlay-skills-home.md:3` says "Amended by 0004" and the file still exists; `decision-check.sh` runs and lists decisions. I did not read all five parts of 0004. |
| REQ-11 | MET | The measurement is in `docs/design/eval-results-5.0.md:113-190`: all five cases 3 of 3, `map_read` 0 for jobs and payments, 3 for why. The citation is at `scripts/evals.sh:29`. The test is an eval run, not a smoke check; I did not re-run it. |
| REQ-12 | MET | `plugins/shipkit/agents/eve.md` is 12,067 bytes (`wc -c`); test `scripts/smoke.sh:2489-2512` (check 70, ceiling 12067, cites REQ-12) |
| REQ-13 | MET | code `plugins/shipkit/skills/ask/SKILL.md:28,30` (reads `@reports.md` on matrix and consolidate) and `plugins/shipkit/skills/ask/reports.md`; test `scripts/smoke.sh:2489-2512`; shape runs in `docs/design/eval-results-5.0.md` (two runs each) |

## Changes beyond the spec
The diff from 0615060 includes later sprints' work. These changed files are outside the spec's `> Paths:`:
- `.claude-plugin/marketplace.json`
- `ROADMAP.md`
- `docs/plans/thinning-sprint-plan.md`
- `plugins/shipkit/.claude-plugin/plugin.json`
- `plugins/shipkit-workflows/.claude-plugin/plugin.json`
- `plugins/shipkit/agents/reviewer.md`
- `plugins/shipkit/evals/fixtures/stack-gen.sh`
- `plugins/shipkit/scripts/brief-verify.sh`
- `plugins/shipkit/scripts/brief.sh`
- `plugins/shipkit/skills/ship/SKILL.md`
- `scripts/evals.sh`
- `scripts/lint.py`
- Other specs' folders: `.shipkit/specs/always-on/spec.md` and `tasks.md`, `.shipkit/specs/review-and-ship/spec.md`, `.shipkit/specs/run-again/` (design, intake, spec, tasks), and `.shipkit/specs/run-debts/design.md`.

## Decisions not followed
None. I checked the four non-superseded decisions in `.shipkit/specs/overlays-and-eve/design.md` that I read: the flag, the cuts, the shapes in `reports.md`, and the measured size.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 13 MET, 0 NOT MET, 0 CANNOT TELL (4 waived).
VERDICT: PASS

### 5. Migration rollback
no migration in the diff (`git diff 0615060...HEAD --name-only` names none under a migration path and no `*.sql`)

### 6. Decisions
- Overlay skills install on a flag, not by default: "We would reverse this — skills by default again — if two of the next three real runs' notes show the user asking for the skills after setup declined them."
- The appends and the two unscoped rules are audited by the 4.0 rule, no eval: "We would reverse a trim — returning the line — if a release run's case …" (line 66)
- The eleven overlay skills are measured against the loop; duplicates go: "We would reverse a cut — restoring the skill behind the flag — if a user …" (line 98)
- `eve`'s prompt is trimmed by the audit's one arm and its clause: "We would reverse a candidate — returning it to `eve.md` — if its case …" (line 138)
- `eve.md` ships at the measured size: "We would reopen the size if a release run's five `eve` cases average more than $0.15 a run (0.126 on the arm) or any of them hits `maxTurns`."
- The matrix and consolidation shapes live in `skills/ask/reports.md`: "We would move the shapes back to `agents/eve.md` if a `--all matrix` or `--all consolidate` request comes back without its shape because `reports.md` was not read."

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run` → exit 0
```
MANUAL .shipkit/decisions/0002-spec-first-eval.md: We would revert the sentence if `rules/nontrivial` passes fewer than two of three runs in two consecutive release runs of `scripts/evals.sh`, or if `rules/trivial` drops below three of three in any release run (the gate costing a turn on trivial work), or if a user reports being asked for a yes on work they called trivial. We would reopen the question — as the plan's clause put it — if a user reports building without a spec after asking for one.
HOLDS  .shipkit/decisions/0003-overlay-skills-home.md: test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2
MANUAL .shipkit/decisions/0004-overlay-skills-flag.md: We would reverse the flag — skills by default again — if two of the next three real runs' notes show the user asking for the skills after setup declined them. We would reverse a cut — restoring that skill behind the flag — if a user asks for it by name in an issue or a real run's notes within two releases.
MANUAL .shipkit/specs/always-on/design.md (Sprint 19 ran as written, and this plan starts from 4.12.0): We would reverse this — splitting the amendments into a second file — if the amendments section grows past the decision table it amends (more than about 60 lines).
HOLDS  .shipkit/specs/always-on/design.md (The two loop rules are injected only where a project opted in): ! grep -q 'CLAUDE_CODE_EVAL_CONFINED' plugins/shipkit/scripts/inject-rule.sh
MANUAL .shipkit/specs/always-on/design.md (The Care lines move only by their number): We would reverse this — returning the original wording, or moving `shipkit.md` to the opt-in set — if the `rules/care` watch reads below 2 of 3 in a release run (the reworded line no longer earns its bytes), or if a real run's notes show a session deleting or force-pushing with the rule in context.
MANUAL .shipkit/specs/always-on/design.md (Ten core skills, the merged bodies as reference files): We would reverse this for a given merge — restoring that skill as its own directory — if its auto-invoke probe fails to fire the merged skill after one rewording of the description, or if a release run's smoke check that invokes the merged form fails twice. (A count of skill directories would fire on today's tree by construction — seventeen — so the clause is manual; once T4 lands, a directory restored under an old name is what REQ-13's smoke check reports.)
MANUAL .shipkit/specs/always-on/design.md (Four agents; the archivist forks inside `map`, the tracer is `grandfather`'s mode): We would reverse a removal — restoring that agent — if the `grandfather` group drops below its 4.12.0 count in a release run after the merge, or if the walkthrough smoke checks fail on the trace mode twice. (A count of agent files would fire on today's tree by construction — seven — so the clause is manual; once T5 lands, an agent file restored is what REQ-17's and REQ-18's smoke checks report.)
HOLDS  .shipkit/specs/always-on/design.md (The eval ceiling is 204,800 bytes): test "$(find plugins/shipkit/evals -type f -print0 | xargs -0 cat | wc -c)" -gt 204800
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
MANUAL .shipkit/specs/overlays-and-eve/design.md (Overlay skills install on a flag, not by default): We would reverse this — skills by default again — if two of the next three real runs' notes show the user asking for the skills after setup declined them.
MANUAL .shipkit/specs/overlays-and-eve/design.md (The appends and the two unscoped rules are audited by the 4.0 rule, no eval): We would reverse a trim — returning the line — if a release run's case for that stack drops below its count after the trim, or a real run's notes show the model doing what the trimmed line forbade.
MANUAL .shipkit/specs/overlays-and-eve/design.md (The eleven overlay skills are measured against the loop; duplicates go (0004 amends 0003)): We would reverse a cut — restoring the skill behind the flag — if a user asks for it by name in an issue or a real run's notes within two releases.
MANUAL .shipkit/specs/overlays-and-eve/design.md (`eve`'s prompt is trimmed by the audit's one arm and its clause): We would reverse a candidate — returning it to `eve.md` — if its case drops below 2 of 3 in a release run after the trim, or a matrix or consolidation request through `ask` comes back without its shape.
MANUAL .shipkit/specs/overlays-and-eve/design.md (`eve.md` ships at the measured size, not the audit's estimate): We would reopen the size if a release run's five `eve` cases average more than $0.15 a run (0.126 on the arm) or any of them hits `maxTurns`.
MANUAL .shipkit/specs/overlays-and-eve/design.md (The matrix and consolidation shapes live in `skills/ask/reports.md`): We would move the shapes back to `agents/eve.md` if a `--all matrix` or `--all consolidate` request comes back without its shape because `reports.md` was not read.
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
MANUAL .shipkit/specs/run-again/design.md (The four debts are paid before the run, one sentence each): We would move REQ-1's line out of the brief and into a `spec-check` hint if the run's tests still cite no `link-expiry/REQ-N` with the line in the brief.
MANUAL .shipkit/specs/run-again/design.md (A stack skill is allowed by the manifest, not by its directory): We would widen to the directory (2) if a run's `brief-verify` or reviewer reports a skill file setup wrote that the manifest does not list.
MANUAL .shipkit/specs/run-again/design.md (The run takes setup's default, so smoke alone proves the skills line): We would run the flag path if, after 5.0.0, a user or a run reports an installed stack skill as `OUTSIDE` or beyond the spec.
MANUAL .shipkit/specs/run-again/design.md (The headless wait is measured, then one sentence, then measured): We would reopen this if the sentence stays and any headless run after it schedules a wakeup, or if it goes and a headless session holds open more than 120 s past its last API call in the release run or the re-run.
MANUAL .shipkit/specs/run-again/design.md (The loop runs again on `linkshort`, same request, and fixes nothing): We would use a project not yet seen for the next run if this one's sections show none better and none worse: then the like-with-like run has stopped teaching.
MANUAL .shipkit/specs/run-again/design.md (5.0.0, with a migration table and no stubs): No reversal condition exists: the renames are on `main`, so the version can only follow them. A name a user cannot find adds a row to the table, not a stub.
MANUAL .shipkit/specs/run-again/design.md (The release gates all three open specs): We would gate only the last spec of a one-release plan next time if both extra gates answer READY first time with no reviewer finding.
MANUAL .shipkit/specs/run-again/design.md (Each deletion is its own yes): No reversal condition exists: this is the owner's rule, not a measured choice, and it changes on the owner's word.
MANUAL .shipkit/specs/run-debts/design.md (The installer looks for the heading before it appends): We would move to (2) if the third real run (E17) shows a project that already carries the heading ending with both sections after the user read the line — then the line is not enough and the installer must choose.
MANUAL .shipkit/specs/run-debts/design.md (A same-named rule beside shipkit's is named, not merged): We would extend the comparison to overlay rules if a real run shows a same-named overlay rule beside shipkit's that the line missed.
MANUAL .shipkit/specs/run-debts/design.md (A tracked backup stays where it is): We would move the backup phase into a script if the third real run shows the model nesting a tracked backup with the sentence in front of it.
MANUAL .shipkit/specs/run-debts/design.md (The brief warns on a dirty tree; the verifier is unchanged): We would build (2) if a later real run hands over from a dirty tree with the line printed — then the reminder is not read and the verifier must cope.
MANUAL .shipkit/specs/run-debts/design.md (Setup's two directories join the always-allowed list): We would add (2) if two consecutive real runs report `CLAUDE.md` and `.gitignore` as beyond the spec with no change in them but setup's.
MANUAL .shipkit/specs/run-debts/design.md (One sentence tells the reviewer where a line number comes from): We would build (2) if the third real run's reviewer cites a diff position with the sentence in place.
MANUAL .shipkit/specs/run-debts/design.md (The gate pastes the reviewer's reply from a file): We would reverse to a sentence-only approach if check 29 shows the block pasted from the file still condensed in two consecutive smoke runs — then the file is not the mechanism.
MANUAL .shipkit/specs/run-debts/design.md (The leaked wait sentence is closed by record): We would add the sentence (2) if an interactive session's reply opens with a wait sentence and continues — then it is the skill's shape, not the harness's; or if a headless session schedules a wakeup and holds open more than 120 s past its last API call in the release run or the run again. > *Reopened 2026-10-31 (thinning plan W14, run-again/REQ-7, the owner's word at the table):* the > 4.12 run gave the same wait a timer (`field-notes-4.12.md` §4.1). Three headless intakes without > a sentence scheduled no wakeup and took 50–66 s (`eval-results-5.0.md` §4), so the clause kept > no sentence and the decision stands. The headless condition above is new.
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
MANUAL .shipkit/specs/third-run/design.md (The session that opened the window closes it): We would remove the end hook (2) if the T1 probe shows `SessionEnd` does not run for `-p` sessions **and** an interactive session's end shows no restore either — then the hook closes nothing. We would add a `reason` matcher if a `clear` or `resume` restores a value an interactive session still needs.
MANUAL .shipkit/specs/third-run/design.md (`plugin-root` is written only from the installed root): We would add an end hook (2) if a checkout-only user reports a session reading a scratch path — then `plugin-root.dev` is not enough for them.
MANUAL .shipkit/specs/third-run/design.md (The refusal text comes from one probe's trace): We would replace the quote if a later Claude Code's trace shows a different text — the paragraph names the version it was read on.
MANUAL .shipkit/specs/third-run/design.md (The loop runs a third time, on the owner's project, and fixes nothing): We would run (2) in addition — in the plan after, not this one — if the third run shows one of E1 to E7 not holding: then the fix was shaped to one project.
MANUAL .shipkit/specs/third-run/design.md (The run's branch and worktree go, on their own yes): We would keep the branch (2) if the owner wants the task's change merged into the project — then it is the project's branch, not the run's.
MANUAL .shipkit/specs/trim-and-docs/design.md (The repository's own document checks live in the lint, not in smoke or by hand): We would reverse this — move the checks to a release-time script — if a documentation-only pull request is blocked by one of these lint checks for a reason that is not a real defect in the document, twice.
MANUAL .shipkit/specs/trim-and-docs/design.md (Criterion (c) counts only where an eval exists): We would reverse this — write the eval cases first — if a line trimmed on (a)/(b) alone is restored within two releases because a regression was traced to it.
MANUAL .shipkit/specs/trim-and-docs/design.md (The map row waits for decision 0001's re-test): We would reverse this — act on the record without the re-test — if the owner waives the condition in writing on the audit row.
decision-check: 87 decision(s), 0 fired, 4 hold, 83 manual, 0 error(s)
```
