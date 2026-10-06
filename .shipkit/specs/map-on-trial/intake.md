# Intake: The map on trial

> Intake taken on 2026-10-06.

## Request
Sprint 8 of the evidence plan: run the re-test decision 0001 asked for — a generated fixture
of at least 200 files and 25 commits, the four elder questions plus one about how the project
evolved, three arms (with the map, without it, plugin off), tool calls counted from traces by a
script — and let the record's own clause settle whether the project map stays the default. If
it falls on the "optional" side, make the map optional in the same release (B3, B4). 4.1.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; there is no product file.
- **Open specs:** none. All nine specs under `.shipkit/specs/` are `Status: shipped`.
- **Decision 0001 (`.shipkit/decisions/0001-project-map-default.md`)** — not a conflict: this
  sprint *is* the re-test the record wrote for itself. Its status line ("measured, not yet
  acted on") and its own clause (restore the map as the default if, on the larger fixture, it
  gives at least one more correct answer or at least 20% fewer tool calls) are the sprint's
  acceptance test. The record's rule for `drift` carries over: a pass that exists only because
  the map contains a planted error does not count as "one more correct answer".
- **The eval budget (A9 of the last plan):** `plugins/shipkit/evals/` is 51,525 bytes of a
  100 KB ceiling that no check enforces. A committed 200-file fixture would breach it; the
  plan's B2 (a generator, ≤ 12 KB) is how the sprint stays inside. This sprint adds the
  missing check so the ceiling holds after it.
- **The byte budget:** the three always-on rules stand at 2,996 of 3,000 bytes. No task in
  this sprint touches them.

## Answers
The plan approved today answers what this intake would otherwise ask: the fixture is generated,
not committed (B2); the outcome is acted on in this release (B3); "optional" means the elders
use a map when one exists and `setup`, README and GUIDE offer it instead of requiring it, with
the archivist, `/shipkit:map` and the stale-map nag untouched (B4). No further question would
change what gets built, so none was asked.

## Assumptions made
- The 100 KB eval ceiling becomes a lint check (`scripts/lint.py`) in T1, so it runs in CI on
  every push; `scripts/lint.py` is therefore on T1's Files line although the plan lists only
  the generator, `FACTS-XL.md`, `smoke.sh` and the README for S8-T1. Same reasoning as Sprint
  7: a limit checked once is a limit that drifts.
- The XL fixture is plain Python with no dependencies, like `sample-app`, so the generator
  needs no toolchain in the eval sandbox and the five XL cases need no `--allow-tools` beyond
  what `scripts/evals.sh` already grants.
- Tool calls are counted main session and subagent together, as in 3.2, so the two
  measurements compare like for like; the counter also prints the split where the trace allows
  it, as a second number, not the one the clause reads.
- The `history` question is answerable without a map from `git log`; the map's Evolution
  section summarises what the commit messages say and adds nothing they lack. A map arm that
  wins on `history` wins on cost, not on access.
- T4's two branches are written as EARS "Where" requirements (REQ-15 to REQ-17); the branch
  whose condition does not hold is marked `[untested: the condition did not hold]` in T4, which
  is why `spec.md` is on T4's Files line.
- The release is 4.1.0 on either branch. Making a default optional removes nothing.

## Out of scope
- Any change to the always-on rules, the archivist, `/shipkit:map`, the stale-map nag, or
  `eve`'s registry columns.
- Measuring context cost as a decision input. If the trace allows it, input tokens are
  reported as a second number; the clause reads correct answers and tool calls only.
- Rule evals, the pre-trim comparison and `rules/nontrivial` (Sprint 9); the real run and the
  deletions B11 to B13 (Sprint 10).
