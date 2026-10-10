# Intake: What the numbers allow

> Intake taken on 2026-10-09.

## Request
Sprint 15 of the portfolio plan (`docs/plans/portfolio-sprint-plan.md`): act on the two
measurements each of twelve rule lines now carries — cut what the model follows unaided, keep
each cut's case as the watch that brings the line back, keep what the owner names; add the one
intake sentence the grader already asks for; close the elder's step 0 by record; remove the two
cache directories the owner has already named. Release 4.8.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; no product file.
- **Open specs:** none; all sixteen specs are `Status: shipped`. `second-traps` wrote the
  sixteen trap-2 cases and named the twelve cut candidates under C8 ("no rule text changes in
  Sprint 13 on its own measurement"); this sprint is the plan after, which C8 deferred to.
  `rule-evals` (4.2.0) wrote the trap-1 cases; both sets stay as watch cases.
- **Decisions:** 0001 (map optional) gains an appended note and stays closed (E2); 0002
  (`nontrivial` sentence) and 0003 (overlay skills) untouched. The trim audit's standing rule
  since 4.0.0 — a cut needs a measurement — is what this sprint acts on, with two per line.
- **Rule files change** (seven of them) and one skill (`intake`). No agent changes.

## Answers
1. **Four of the eleven candidate files — `rules/migrations.md`, `rules/monorepo.md`,
   `rules/testing.md`, `stacks/react/.claude/rules/package-json.md` — have exactly two bullets,
   and both are the measured lines. Cutting both leaves a heading over nothing, which is
   cutting the file; the plan's §5 says this plan does not cut a file, and each file's two
   watch cases install it by name through `with-rule.sh`. Keep the four whole as statements of
   standards (recommended: the record says so, no run), or remove the four files and rewrite
   their eight cases to install nothing?** — **Keep**, the owner, 2026-10-09: the four stay whole as statements
   of standards; the sprint cuts fourteen lines from seven files.
2. **`intake/limit` fell to 0 of 3 in the 4.7.0 release run and 0 of 1 alone: the reply asks
   three numbered questions whose sub-parts the grader counts as five or more; carried as a
   known failure on the owner's merge. E3's task edits the intake skill. Add a second sentence
   there — "a question with several parts counts as several; four is the ceiling on parts" —
   and watch the case, or leave the skill at E3's one sentence and carry the failure?** —
   **Both sentences**, the owner, 2026-10-09.
3. **The re-run on the trimmed text is 14 cases (seven files × two), 42 runs ≈ $4, not the
   plan's 66 runs ≈ $6.50; the intake group once ≈ $1.70. In the budget (rule 15)?** —
   **Yes**, within the plan's S15 line (≈ $8.50) as approved.

## Assumptions made
- A "measured line" is the bullet (or the two adjacent bullets) the case's `description:`
  quotes, as the design's table lists them by line number at 4.7.0; the rest of the file is
  byte-identical after the cut.
- `rails/rails.md` keeps both lines (2 of 3 without is the threshold, and the `update_attribute`
  runs skipped validations by a method the line does not name), as E1 says.
- The watch cases are not edited: their fixtures and graders are as at 4.6.0; only the installed
  file is shorter. A case that drops below 2 of 3 on the trimmed text returns its line in the
  same commit with the owner's yes (the record's clause, fired on the spot).
- The step-0 note cites numbers already in `docs/design/eval-results-4.6.md` and
  `docs/design/eval-history.md` (the 4.0.0 XL baseline's token columns); no new run.
- F1 and F2 are done only once the owner's interactive session's hook line says `4.7.0`
  (the cache was updated at 4.7.0's release; the restart applies it).

## Out of scope
The four files that separated on trap 2 (`data`, `experiments`, `gemfile`, `go-mod`) and the
two that separated on trap 1 (`dependencies`, `jobs`); `agents/grandfather.md` and
`agents/eve.md`; the portfolio fixture and the second real run (Sprint 16); the shape of
`digest/attention` under `-j 4`; a change to any grader.
