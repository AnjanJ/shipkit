# Intake: What a number can say (Sprint 24)

> Intake taken on 2026-10-31, by hand from the approved binding plan.

## Request
Make a release run's exit code believable: four graders corrected on both sides, a `map_read` that
sees a repo-wide Grep, `reports.md` watched, and the Care line read on a second prompt and a second
model (`docs/plans/binding-sprint-plan.md`, Sprint 24, G4, G5, G6, G7).

## Serves goal
The ROADMAP's north star: shipkit "checks the result against the intent", which a check that fails
correct work cannot do. This repository has no `.shipkit/product.md`, so the goal is the plan's §0
table.

## Conflicts found
- The thinning plan's §5 changed no grader. G4 reverses that for this plan only, as G4 says.
- `decisions-bind`'s record "The ceiling stays" holds at 204,800 bytes, with `eve/consolidate` the
  first case dropped and a raise only on the owner's word. The owner kept it: see Answers.
- The plan's S24-T1 takes the wrongly-failed files "from the session logs under `~/.claude/projects/`".
  That cannot work. On 2026-10-31 no directory there is named for an `e-*` sandbox, and
  `evals/README.md` says `--keep-temp` keeps `config/` and `out/trace.jsonl`, not the workspace. The
  files are rebuilt from a trace's Write, Edit and Bash calls.
- The plan's exit line 3 and S24-T-MERGE name `--group trap2`. The design's second record reads the
  four changed cases instead, and the owner took that at the spec's approval: see Answers.
- `scripts/lint.py:591` calls 5.0.0's raise "the third raise"; its own list has four (128, 160,
  192 KB, 200 KiB), so another would be the fifth, not the plan's "fourth". Nothing here raises, so
  the comment stays.
- Open specs: `decisions-bind` only. `review-and-ship` and `spec-contract` matched a search on
  `Status: open` in their text and read `Status: shipped`.

## Answers
1. How much of Sprint 24 runs? — All of it, T1 to T4 (the owner, 2026-10-31).
2. How is room made in the evals directory? — Move readings out of `evals/README.md` to
   `docs/design/eval-history.md`; no raise, and `eve/consolidate` drops first if the measured bytes do
   not fit (the owner, 2026-10-31).
3. How does T1 spend its paid runs? — The four changed cases, harvested on the old graders and run
   again on the corrected ones, with no `--group trap2` before the release run, about $2.50 (the owner,
   2026-10-31, at the spec's approval).

## Assumptions made
- `package-json`'s wrongly-failed file appears on `haiku` and not on `sonnet`:
  `docs/design/eval-results-4.11.md` §5, 0 of 3 on `haiku`, `sonnet` hardcoding the manager.
- `go-mod`'s miss is 1 run in 3, so a harvest may not reproduce it
  (`docs/design/eval-history.md`, "Release run 5.0.0"). The record describes the file and does not
  quote it, so no compile form is widened without a file that shows it.
- `eve/matrix` and `eve/consolidate` need no generator change: Stripe's versions, constraints and
  both copies are already in `fixtures/portfolio-gen/generate.py`.
- T2's check-first reads a trace from T1's harvest, so that harvest is kept until T2 has read it.

## Out of scope
Any rule text, Care included (G7 measures only); any grader but the four; a fix for anything `eve/matrix`,
`eve/consolidate` or `rules/care-quiet` finds, which goes to the ROADMAP; moving the evals out of the
plugin; the four debts, the run and 5.1.0 (Sprint 25).
