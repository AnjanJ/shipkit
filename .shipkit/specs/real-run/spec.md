# Spec: Loose ends and a real run (Sprint 10, release 4.3.0)

> Spec accepted at commit `5085d2f` on sprint-10/real-run.
> Status: open
> Paths: plugins/shipkit/scripts/spec-check.sh, scripts/smoke.sh, plugins/shipkit/skills/ship/SKILL.md, .shipkit/decisions/, docs/design/two-plugin-split.md, docs/design/field-notes-4.3.md, ROADMAP.md, GUIDE.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Close the evidence plan: make the requirement-citation debt visible before the gate runs,
settle where the stack overlay skills live, run shipkit's whole loop once on a repository that
is not shipkit and write down what it was like, remove what the owner approved removing, and
leave a roadmap whose every open item points at the evidence that put it there.

Source: `docs/plans/evidence-sprint-plan.md`, Sprint 10, tasks S10-T1 to S10-T5, and the
intake beside this file (which corrects S10-T1's two branches, S10-T2's Rails count and
B11's branch count).

## User stories

- As the owner, I want to see an uncited requirement the day it is written, not in a ten-minute
  gate run at release, so that the gate's first run passes.
- As a reader of the design doc, I want the overlay-skills question answered with a reason and
  a reversal condition, so that it is not reopened every sprint.
- As the owner, I want field notes from one honest run on a real project, so that the next plan
  starts from what happened rather than from what shipkit says about itself.
- As the executor of the next plan, I want a roadmap where every open item cites its evidence.

## Requirements (EARS)

### Citation debt before the gate (S10-T1)

- **REQ-1.** When run without a slug and without `--as-shipped`, for each spec whose status is
  `open`, `spec-check.sh` shall print `PENDING-TEST <slug> REQ-N` for every requirement that is
  not excused and that no test cites.
- **REQ-2.** While a spec is `open`, a `PENDING-TEST` line shall not change `spec-check.sh`'s
  exit status: a spec with every requirement tasked exits 0 as before.
- **REQ-3.** If a requirement is excused from a test (the `untested` bracket), then
  `spec-check.sh` shall print `WAIVED` for it and no `PENDING-TEST` line.
- **REQ-4.** The ship skill shall tell the executor to run `spec-check.sh . <slug> --as-shipped`
  before starting the gate. [untested: prose, verified by reading]
- **REQ-5.** Where the Check first at `ceef7f5^` shows the plain run already exits non-zero on
  the uncited requirements, the change shall be REQ-4's sentence only, and REQ-1 to REQ-3 shall
  not be built. [untested: the condition did not hold — at `ceef7f5^` the plain run exited 0
  (9 specs, 0 gaps; with the slug, 1 spec, 0 gaps) and only `--as-shipped` named REQ-4, 5, 7
  and 11 of trim-and-docs; T1 built REQ-1 to REQ-4 (2026-10-07)]

### The overlay skills (S10-T2)

- **REQ-6.** `.shipkit/decisions/0003-overlay-skills-home.md` shall exist with the five parts, a
  table of the eleven overlay skills saying for each whether it installs knowledge or tells
  Claude how to work, a concrete reversal clause and a `Fired-if` line. [untested:
  documentation, verified by reading; `decision-check.sh . --run` lists it as `HOLDS`]
- **REQ-7.** `docs/design/two-plugin-split.md` §5 item 6 shall read as settled and point at
  record 0003. [untested: documentation]
- **REQ-8.** `ROADMAP.md` shall no longer carry the "From 3.0" overlay-skills line. [untested:
  documentation]

### The real run (S10-T3)

- **REQ-9.** `docs/design/field-notes-4.3.md` shall hold one section for the plugin-cache update
  and one for each of the nine steps of the loop (`product`, `intake`, `spec`, `brief.sh`,
  build, `ship`, `handoff`, a fresh session's "what should I do next?", and the review the
  gate started), each stating what the step asked for, what it produced, how long it took,
  what was awkward, whether that is the tool's fault or the project's, and quoting the exact
  prompt or output where it matters. [untested: documentation, verified by reading; no section
  reads "worked fine" without an evidence line]
- **REQ-10.** When a step in the real run is awkward, `ROADMAP.md`'s "Still open after Sprint
  10" shall carry a one-line candidate for it that names its field-notes section. [untested:
  documentation]
- **REQ-11.** Where a step of `GUIDE.md`'s playbook proves wrong in the real run, `GUIDE.md`
  shall be corrected in that step only. [untested: the condition did not hold — Playbook 4's
  steps matched the run step for step (field notes, closing section); `GUIDE.md` is unchanged
  (T3, 2026-10-07)]

### Housekeeping (S10-T4)

- **REQ-12.** `ROADMAP.md` shall record what B11 to B13 removed, and the date, for each row the
  owner approved. [untested: documentation]

### The roadmap (S10-T5)

- **REQ-13.** `ROADMAP.md` shall mark Sprints 8 to 10 shipped with their releases. [untested:
  documentation; the status line is held by lint check 16]
- **REQ-14.** Every item under "Still open after Sprint 10" shall name the field-notes section
  or the eval-results table that put it there. [untested: documentation, verified by reading]

## Release steps (not requirements)

- T1's Check first is run in a scratch worktree at `ceef7f5^` that T1 removes; its output and
  the branch it chose are in T1's commit message.
- T3 changes nothing under `plugins/`; nothing in the named repository is merged by the
  executor; the plugin cache is updated with the owner's yes first.
- T4 deletes only what the owner approved, each row its own yes, each command's output in the
  commit message.
- The gate (`/shipkit:ship real-run`) answers `READY`; the report is committed.
- Release as 4.3.0; the sprint exit checklist holds; the pull request is merged after a green
  check; tag `v4.3.0`.

## Out of scope

Any edit under `plugins/` during the real run; rule edits; new eval cases; the sixteen rules
that pass without their text; measuring path-scoped loading; the elders' map-reading rate;
moving the overlay skills; blanket deletions.
