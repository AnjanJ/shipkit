# Intake: What the run hurt on

> Intake taken on 2026-10-08.

## Request
Sprint 11 of the field plan (`docs/plans/field-sprint-plan.md`): fix the five things the real run
on `rails_error_dashboard` showed about shipkit's own behaviour — a briefing that is wrong on a
project with pre-3.3 specs, an intake that asks what the repository already knows and skips
`grandfather`, headless runs whose questions live only in the reply, and three one-line gaps (no
version line when the cache has a newer plugin, a goal line that repeats "none set" three times,
a handoff with no "Blocked on"). No rule, agent or eval case changes except one new intake case.
Release 4.4.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; no product file.
- **Open specs:** none; all twelve specs are `Status: shipped`.
- **Decisions:** 0001 (map optional), 0002 (`nontrivial` sentence), 0003 (overlay skills in core)
  — none is touched. C2's default keeps `spec-contract/REQ-7` ("no Status line is open") for
  `spec-check.sh`; only the briefing's and the drift nag's reading change.
- **The plan brings part of C1 forward.** The evals directory has 979 bytes of room and S11-T2
  adds a case of about 1.2 KB. The plan's Check first for S11-T2 moves two README history
  sections (1,813 bytes) to `docs/design/eval-history.md` "with the owner's yes at S11-T0".
  Question 1.

## Answers
1. **May S11-T2 move the evals README's "Release run 4.3.0" and "After the spec-first sentence
   (4.2.0)" sections (1,813 bytes) to `docs/design/eval-history.md` now, ahead of Sprint 13's C1,
   so the `intake-answered` case fits under the 131,072 ceiling?** — **Yes**, the owner, 2026-10-08
   ("approved yes").

## Assumptions made
- The "N specs predate 3.3" line prints at every session start while such specs exist; it is a
  nag with its fix in the line, like the stale-map nag.
- Smoke check 50 runs the intake and product skills headless with `sonnet`, as check 22 runs the
  spec skill, in a scratch project; about a minute each.
- The version line compares directory names under the plugin cache; the running root's parent
  is the version directory (`…/shipkit/shipkit/<ver>`); no JSON is read.
- The handoff's "Blocked on" heading is prose in the skill; the briefing does not quote it.
- The new case's fixture is `sample-app` plus one `docs/decisions.md` that answers two of the
  three natural refunds questions; the grader is `llm` on the reply.

## Out of scope
Rule or agent text; the trap-2 cases; the reviewer and `brief-verify` (Sprint 12); migrating a
user's specs for them; eve.
