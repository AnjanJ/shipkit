# Spec: What a decision binds (Sprint 23)

> Spec accepted at commit `6379fd7` on sprint-23/decisions-bind (2026-10-31).
> Status: open
> Paths: plugins/shipkit/scripts/brief.sh, plugins/shipkit/agents/reviewer.md, plugins/shipkit/evals/brief/, plugins/shipkit/evals/reviewer/, plugins/shipkit/evals/lib/, scripts/smoke.sh, docs/design/eval-results-5.1.md, docs/plans/binding-sprint-plan.md, .shipkit/specs/review-and-ship/spec.md, CHANGELOG.md

## Purpose

Shipkit records what was decided so that the work follows it. On `linkshort`, T1's agent built the
alternative the design had rejected, because the brief selects a decision by the requirement it
cites, and the decision governed a field T1 touched without citing T1's requirements. Reading the
code found the next link open too: the reviewer reports a decision not followed, says "the ship
gate weighs them", and the gate has no such step, so a READY can stand on a contradicted decision.

This sprint closes both links: every live decision reaches every task of its feature, the reviewer
reads what a decision turned down, and a contradicted decision fails the review.

Source: `docs/plans/binding-sprint-plan.md` (approved 2026-10-31), G1, G2, G3, G9, Sprint 23;
`docs/design/field-notes-5.0.md` §8.1, §9.2.

## User stories

- As someone handing a task to an agent, I want the brief to carry every decision of the feature,
  so that an agent touching code a decision governs knows the decision exists.
- As the owner, I want the reviewer to tell work not yet built from work built the rejected way,
  so that a finding says which of the two I am looking at.
- As the owner, I want a READY to mean the code does not contradict a live decision, so that
  changing my mind is a recorded act and not an accident the gate lets through.

## Requirements (EARS)

### The brief (G1, S23-T1, S23-T2)

- **REQ-1.** When `brief.sh` prints a task's brief, its `Decisions that bind you` section shall
  list the title of every live decision in the feature's `design.md`, whichever requirements the
  decision cites, and shall name that file for the full text.
- **REQ-2.** `brief.sh` shall leave out a decision marked superseded.
- **REQ-3.** Where the feature has no `design.md` or no live decision, the section shall say that
  none is recorded for this feature.
- **REQ-4.** The eval suite shall hold a case `brief/binds` in which an agent, given a task's brief
  and a design whose live decision cites only a later task's requirements, changes code that
  decision governs; the case shall pass only when the code does not use the alternative the
  decision rejected and does not build the later tasks' work.
  > *Amended 2026-10-31 (T2, the owner's word):* the first form could not see 9 of 10 runs building
  > later tasks' work inside T1.
- **REQ-5.** `docs/design/eval-results-5.1.md` shall hold one row per run of `brief/binds`, on
  `brief.sh` before and after REQ-1, each saying whether the rejected alternative was built.
  [untested: a record, verified by reading]

- **REQ-14.** Where the section lists a decision, it shall say above the list that a decision limits
  how the task is done and is not extra work: the task builds only what its requirements ask, and
  contradicts none of them.
  > *Added 2026-10-31 (T2, the owner's word):* REQ-1 alone took the rejected alternative from 3 of 10
  > runs to 0 of 10, and 9 of 10 runs then built later tasks' work inside T1, one saying it did so
  > "to follow the binding decisions". The design has the record.

### The reviewer (G2, G3, S23-T3)

- **REQ-6.** For each live decision, the reviewer shall read the alternatives the record turned
  down as well as its choice, and shall call the decision contradicted where the code does what
  the record turned down or the opposite of what it chose.
- **REQ-7.** Under "Decisions not followed", the reviewer shall mark each decision it lists
  `contradicted` or `not built`; a decision whose code does not exist yet shall be `not built`.
- **REQ-8.** The reviewer's reply shall end with `VERDICT: PASS` if every requirement is `MET` and
  no live decision is `contradicted`, and with `VERDICT: FAIL` otherwise.
  > *Amends `review-and-ship/REQ-6` in place (G3).*
- **REQ-9.** A decision marked `not built` shall not change the verdict.
- **REQ-10.** The reviewer shall not weigh a decision marked superseded, whatever the code does.
- **REQ-11.** When `/shipkit:ship` runs on a feature whose code contradicts a live decision, its
  report shall start `NOT READY` and name the decision; once that decision is marked superseded by
  a record the code follows, the same feature shall be `READY`.
  [untested: forced at the merge, both results recorded in eval-results-5.1.md]
- **REQ-12.** `agents/reviewer.md` shall state what decides the verdict, and shall not say the ship
  gate weighs anything the gate does not.

### The ceiling (G9, S23-T3)

- **REQ-13.** The `reviewer` cases shall build their fixture from one script under `evals/lib/`,
  and `plugins/shipkit/evals/` shall stay at or under 204,800 bytes.

## Merge steps (not requirements)

- The sprint exit checklist with `--group brief` and `--group reviewer`.
- No gate on this spec at the merge: `/shipkit:ship` runs on it at 5.1.0's release, with the other
  two, and `Status: shipped` is set there (rule 22), as Sprints 20 and 21 were.
- Merged untagged after a green check. The owner's cache is not touched.

## Out of scope

The graders, `map_read`, `reports.md` and the Care line (Sprint 24); the four debts, the run and
5.1.0 (Sprint 25); why the model writes `placeholder`; printing a decision's alternatives in the
brief; a `Governs:` field; any change to `skills/ship/SKILL.md`, whose step 4 already turns
`VERDICT: FAIL` into `FAIL`; any new always-on byte.
