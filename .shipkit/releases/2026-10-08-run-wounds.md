READY

# Ship report: run-wounds

> Checked on 2026-10-08 at commit `f23c633` on `sprint-11/run-wounds`, against base `74d6c11` (merge-base with `main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0, 0 gaps |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh <plugin root>/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 4 decisions, each reversal condition concrete |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | 23 decisions, 0 fired |

Requirements: 15 (5 waived as `[untested]`).

The spec's `> Status:` line was not changed (this run was not interactive, and the request said to leave it).

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . run-wounds --as-shipped` → exit 0
```
WAIVED run-wounds REQ-5
WAIVED run-wounds REQ-7
WAIVED run-wounds REQ-8
WAIVED run-wounds REQ-10
WAIVED run-wounds REQ-15
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`bash scripts/lint.sh && sh <plugin root>/scripts/spec-check.sh .` → exit 0

Last lines of output (the tail the run showed; the final line is the summary):
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
spec-check: 13 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/run-wounds/tasks.md`
no line found

### 4. Independent review
Run against base `74d6c11319de4f6783bee5fe958640b1003260bd`.

## Review: run-wounds against 74d6c11319de4f6783bee5fe958640b1003260bd

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `plugins/shipkit/scripts/briefing.sh:41-46` (a spec with no Status line and all tasks ticked is skipped); test `scripts/smoke.sh` check 49 (comment at :1678, assertions at about :1693-1699, cites `run-wounds/REQ-1`) |
| REQ-2 | MET | code `plugins/shipkit/scripts/session-start.sh:207-217` (`spec_is_closed`); test `scripts/smoke.sh` check 49 hook assertion (about :1700-1703, cited at :1678) |
| REQ-3 | MET | code `plugins/shipkit/scripts/briefing.sh:67-77` (count line, with `> Status: shipped`); test `scripts/smoke.sh` check 49 (the "4 specs predate 3.3" assertion, about :1697-1698) |
| REQ-4 | MET | code `plugins/shipkit/scripts/briefing.sh:41-46` (the skip applies only when nothing is unticked); test `scripts/smoke.sh` check 49 (`gamma: 0 of 2 tasks done, next T1`) |
| REQ-5 (waived) | MET | `spec-check.sh` is not in the diff, so it still reads a missing Status as open. The spec cites `spec-contract/REQ-7` and smoke check 19h for this. |
| REQ-6 | MET | Code: `plugins/shipkit/skills/intake/SKILL.md:57-58` and `:109` ("drop anything a file already answers", "never one a file already answers"). The spec amendment says no list was added. Test: eval case `plugins/shipkit/evals/intake/answered/` (`graders/cites-the-file.md` requires the file to be named), cited at `scripts/evals.sh:14`. Result: 3 of 3 on the 4.3.0 text and 3 of 3 with it (`docs/design/eval-history.md:50-63`). The same file also records a later arm with `answered` at 2 of 3, which still meets the ≥2 of 3 bar. The case cites the requirement in `scripts/evals.sh`, not in the case files themselves. Caveat: the skill text never says in so many words to name the file. That behaviour is held only by the grader. |
| REQ-7 (waived) | MET | `plugins/shipkit/skills/intake/SKILL.md:47-49` (a claim of absence names the places searched) |
| REQ-8 (waived) | MET | `plugins/shipkit/skills/intake/SKILL.md:34-35` (ask `grandfather`, do not read the codebase in this skill) |
| REQ-9 | MET | code `plugins/shipkit/skills/intake/SKILL.md:66-69, 77-78, 94-95` (write `intake.md` with "— *unanswered*"); test `scripts/smoke.sh` check 50 (cited at :1706; asserts `## Answers` and "unanswered" in the file) |
| REQ-10 (waived) | MET | `plugins/shipkit/skills/intake/SKILL.md:71-73` |
| REQ-11 | MET | code `plugins/shipkit/skills/product/SKILL.md:90-94` (a `> Open questions for the owner:` blockquote under the review line, not a heading); test `scripts/smoke.sh` check 50, product half (cited at :1709; asserts the block and the seven headings) |
| REQ-12 | MET | code `plugins/shipkit/scripts/session-start.sh:71-95` (higher sibling version directory gives one line naming both versions and "restart"); test `scripts/smoke.sh` check 51 (4.3.0 beside 4.10.0) |
| REQ-13 | MET | code `plugins/shipkit/scripts/session-start.sh:71-95` (the line prints only for a strictly higher version); test `scripts/smoke.sh` check 51 (run from the highest version with 3.1.0 and a non-version directory beside it, and run from this repository) |
| REQ-14 | MET | code `plugins/shipkit/scripts/briefing.sh:91-97`; test `scripts/smoke.sh` check 51 (all-none goal gives "(no metric set)" and no "metric:"; a goal with one field set keeps all three) |
| REQ-15 (waived) | MET | `plugins/shipkit/skills/handoff/SKILL.md:56-59` (conditional `## Blocked on` heading with one line). Smoke check 30 also asserts the skill text, at `scripts/smoke.sh:1066-1069`. |

## Changes beyond the spec
None. Every changed file is under the spec's `> Paths:` or inside `.shipkit/specs/run-wounds/`.

## Decisions not followed
None. The "fixed list" decision is marked as fired in `design.md`, and the code matches that note: no list was added and only the absence-claim sentence went in.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 15 MET, 0 NOT MET, 0 CANNOT TELL (5 waived).
VERDICT: PASS

### 5. Migration rollback
`git diff 74d6c11...HEAD --name-only`, filtered for `db/migrate/`, `migrations/`, `alembic/`, `prisma/migrations/`, `*.sql`
no migration in the diff

### 6. Decisions
Four live decisions in `.shipkit/specs/run-wounds/design.md`, none superseded:
- The briefing reads "all ticked, no Status" as closed; spec-check does not — "We would build (2) if two users, or the owner twice, report adding `Status` lines by hand to more than five specs after reading the new line."
- The intake searches a fixed list before it asks — "We would revert the list to the one-line principle if the `intake-answered` case passes 2 of 3 with the 4.3.0 text in S11-T2's with/without run." (Marked fired 2026-10-08, S11-T2: the case passed 3 of 3, the list was never added; recorded in the design.)
- Unanswered questions are written, not spoken — "We would move to (3) if a spec run is observed treating an *unanswered* question as answered (a `spec.md` requirement built on a blank) in any real or eval run."
- The version line reads directory names, not JSON — "We would move to (2) if the cache layout changes so that the running root's parent is not the version directory (the smoke check would go red)."

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run` → exit 0
```
MANUAL .shipkit/decisions/0002-spec-first-eval.md: We would revert the sentence if `rules/nontrivial` passes fewer than two of three runs in two consecutive release runs of `scripts/evals.sh`, or if `rules/trivial` drops below three of three in any release run (the gate costing a turn on trivial work), or if a user reports being asked for a yes on work they called trivial. We would reopen the question — as the plan's clause put it — if a user reports building without a spec after asking for one.
HOLDS  .shipkit/decisions/0003-overlay-skills-home.md: test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2
MANUAL .shipkit/specs/map-on-trial/design.md (The XL fixture is generated at scaffold time, never committed): We would reverse this — commit a real-repository fixture and raise the budget — if, on the generated fixture, every one of the five cases is answered in two tool calls or fewer in all three arms, which would mean the generator failed to make a codebase that needs searching.
MANUAL .shipkit/specs/map-on-trial/design.md (The comparison acts in the same release): We would reverse this — split the change into its own sprint — if S8-T4's Files line has to grow beyond the eleven files it names, which would mean "optional" is a bigger change than B4 describes.
MANUAL .shipkit/specs/map-on-trial/design.md (What "optional" means, if it comes to that): We would move to (2) if, in the six months after 4.1.0, the nag is reported as noise by a project that deliberately keeps no map (it should be impossible — the nag needs a map — so a report would mean a bug, not a policy change). We would revisit (3) only on a new measurement, never on this one.
MANUAL .shipkit/specs/map-on-trial/design.md (What counts as a correct answer, settled before the run): We would reverse this — count `drift` as given — if the no-map `drift` runs get the underlying fact wrong (an in-process dict in `app/inventory/cache.py`), because then the failure would be a wrong answer, not a missing accusation.
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
MANUAL .shipkit/specs/run-wounds/design.md (The briefing reads "all ticked, no Status" as closed; spec-check does not): We would build (2) if two users, or the owner twice, report adding `Status` lines by hand to more than five specs after reading the new line.
MANUAL .shipkit/specs/run-wounds/design.md (The intake searches a fixed list before it asks): We would revert the list to the one-line principle if the `intake-answered` case passes 2 of 3 with the 4.3.0 text in S11-T2's with/without run — the sentence would then be bytes without effect.
MANUAL .shipkit/specs/run-wounds/design.md (Unanswered questions are written, not spoken): We would move to (3) if a spec run is observed treating an *unanswered* question as answered (a `spec.md` requirement built on a blank) in any real or eval run.
MANUAL .shipkit/specs/run-wounds/design.md (The version line reads directory names, not JSON): We would move to (2) if the cache layout changes so that the running root's parent is not the version directory (the smoke check would go red).
MANUAL .shipkit/specs/trim-and-docs/design.md (The repository's own document checks live in the lint, not in smoke or by hand): We would reverse this — move the checks to a release-time script — if a documentation-only pull request is blocked by one of these lint checks for a reason that is not a real defect in the document, twice.
MANUAL .shipkit/specs/trim-and-docs/design.md (Criterion (c) counts only where an eval exists): We would reverse this — write the eval cases first — if a line trimmed on (a)/(b) alone is restored within two releases because a regression was traced to it.
MANUAL .shipkit/specs/trim-and-docs/design.md (The map row waits for decision 0001's re-test): We would reverse this — act on the record without the re-test — if the owner waives the condition in writing on the audit row.
decision-check: 23 decision(s), 0 fired, 2 hold, 21 manual, 0 error(s)
```
The `MANUAL` lines have no command to run; none is a `FIRED` line, so the step passes.
