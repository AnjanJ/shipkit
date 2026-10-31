# Intake: The owner's project, and 5.1.0 (Sprint 25)

> Intake taken on 2026-10-31, by hand from the approved binding plan.

## Request
Pay four debts, each with a smoke check, so the run can read them; run the whole loop on
`~/code/office_bestie`, a project with its own `CLAUDE.md` and rules; give the plan after it a
roadmap; release 5.1.0 (`docs/plans/binding-sprint-plan.md`, Sprint 25, G8, G10, G11, G12).

## Serves goal
The ROADMAP's north star: shipkit remembers what was intended and "checks the result against the
intent". Sprints 23 and 24 changed that check and only fixtures have read it. This repository has
no `.shipkit/product.md`, so the goal is the plan's §0 table.

## Conflicts found
- S25-T1 names `skills/spec/SKILL.md` for the `Fired-if` sentence. That file only runs
  `decision-check.sh` (line 94). The line is taught at `skills/spec/reference.md:82`, and
  `skills/decide/SKILL.md:51` points to the same place. The sentence goes in `reference.md`, the
  plan's Files line is corrected at approval, and check 82 reads `reference.md`.
- G8 says a section loses its `<!-- a / b -->` alternatives. Of the 34 comment lines in ten stacks,
  26 are alternatives, 5 are hints (`<!-- from go.mod -->`) and 3 are
  `<!-- /shipkit:setup fills these in from detection -->`. None helps once the section is filled, so
  all 34 go. The design says so; the two shipkit markers stay.
- G8's "the async line" is `**Async DB:**` at `stacks/python/CLAUDE.md.append:23`. `**Async:** no` at
  line 8 is a fact about the project and stays. No other stack has one.
- Setup's "(loads on Django files only)" is false, not merely unneeded: `django.md`'s `paths:` are
  `**/models.py`, `**/views.py`, `**/serializers.py`, `**/migrations/**` and `**/settings*.py`. Any
  FastAPI project with a `models.py` loads it.
- §5 leaves "the hand-written stamp" alone. That is the acceptance stamp (`ROADMAP.md:158`), not the
  six template dates, so G8 and §5 do not collide.
- §6's risk row keeps the run out of the owner's repository and says nothing of their database.
  `config/test.exs:12` at `179f99d` names `office_bestie_test` plus `MIX_TEST_PARTITION`, and
  `mix.exs:84` runs `ecto.create` and `ecto.migrate` before `test`. A worktree's `mix test` would
  migrate the owner's own test database. The run sets a partition, and the plan is amended at
  approval.
- S25-T2 and §6 put the worktree under the session's scratchpad, which went away on 2026-10-31,
  before the run. The tasks name `/private/tmp/shipkit-real-run-5`, the owner's word at approval, and
  the plan is amended with it: outside every repository and just as disposable, though a reboot can
  clear it, so the log is read and copied into the field notes as each step ends.
- The reviewer's `model: sonnet` (`4f81799`) landed after the plan was approved. S25-T-REL's
  `placeholder` count is against 3 of 74, taken before the pin, so the two are not like with like.
  The count says so.
- `/shipkit:ship` runs on two specs already merged, so each needs its base given: `6379fd7` and
  `2e8bed0`, their acceptance commits. 5.0.0 did this for `always-on` and `overlays-and-eve`.
- Open specs: `decisions-bind` and `readable-numbers`, both gated at this release.
  `review-and-ship` and `spec-contract` matched a search on `Status: open` in their text and read
  `Status: shipped`.

## Answers
1. Which backlog item does the run take? — `TODO.md:204`, the team's day, the 4.9 run's item and still
   unchecked, so 5.1 reads like with like against 4.9 on one project (the owner, 2026-10-31).
2. Where does the worktree go, now the scratchpad is gone? — `/private/tmp/shipkit-real-run-5` (the
   owner, 2026-10-31).

## Assumptions made
- `django.md` is the only stack rule with a condition, and `**Async DB:**` the only section line
  (read across `stacks/` on 2026-10-31).
- All 34 comments sit on one line, end the line, and hold no placeholder (both counted on
  2026-10-31), so a one-line `sed` removes them and the placeholder pre-check is untouched.
- Setup reads a `TODO:` hint from `CLAUDE.md.append` (`setup/SKILL.md:134`), which stays as it is.
- A 5.0.0 project whose section is unedited refreshes at its next setup, because the recorded sha
  matches; an edited one shows the diff and is left alone (`install-stack.sh`, the `CUR` branch).
- `office_bestie` still holds every G10 precondition at `179f99d`: `CLAUDE.md:76` for E1, five files
  in `.claude/rules/` for E2, 14 tracked `.shipkit-backup` files for E3, read on 2026-10-31.

## Out of scope
All of the plan's §5: why the model writes `placeholder`; any always-on byte; `Test:` being singular,
the hand-written stamp, setup's two clocks, `sleep 45`; the pinned toolchain; the `agents` and
`rules-skip` smoke flakes; re-measuring the `eve` trim; and anything the run finds, which goes to the
ROADMAP. Also deleting `django.md` from a project set up on 5.0.0: nothing deletes it, and the
CHANGELOG names it.
