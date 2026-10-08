# Spec: The gate's blind spots (Sprint 12, release 4.5.0)

> Spec accepted at commit `e0ba01a` on sprint-12/gate-blind-spots (2026-10-08).
> Status: open
> Paths: plugins/shipkit/scripts/decision-check.sh, plugins/shipkit/scripts/brief-verify.sh, plugins/shipkit/skills/spec/, plugins/shipkit/skills/ship/, plugins/shipkit/agents/reviewer.md, scripts/, docs/design/eval-history.md, docs/plans/field-sprint-plan.md, .shipkit/releases/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Make the gate, the reviewer and the briefs stop failing on things that are not defects: a
reversal condition written before the code it measures exists, files under `.shipkit/` that no
spec will ever list, exit codes lost to pipes and output typed from memory in the ship report,
and a question about ignored files that has been open since 4.0 and is closed by record.

Source: `docs/plans/field-sprint-plan.md`, Sprint 12 (S12-T1 to S12-T4), decisions C5, C6;
`docs/design/field-notes-4.3.md` §6, §7, §8, §8a.

## User stories

- As an owner reading a fresh spec, I want a decision's `Fired-if` command to be one that can
  only fire once the code exists, so that the gate's step 8 fails on decisions that were wrong,
  not on files not yet written.
- As an owner reading a ship report or a brief check, I want `product.md`, the release report and
  the handoff note never to be called "outside the spec", so that a finding there means something.
- As an owner reading a ship report, I want every exit code to be the one the command returned
  and every evidence block to be the output the command printed, so that I can trust a PASS.

## Requirements (EARS)

### A `Fired-if` that cannot fire before the code exists (S12-T1)

- **REQ-1.** When a `Fired-if` command is followed on its line by an HTML comment (`<!-- … -->`),
  `decision-check.sh` shall run the command without the comment.
- **REQ-2.** When a `Fired-if` command exits above 1, `decision-check.sh --run` shall print an
  `ERROR` line carrying the exit code and the first line of the command's standard error.
- **REQ-3.** When the spec skill has written `design.md`, it shall run `decision-check.sh . --run`
  and treat a `FIRED` or `ERROR` line on a record it just wrote as a defect to fix before handing
  over. [untested: prose, verified by reading; smoke check 22's headless spec run is not extended]
- **REQ-4.** The spec reference shall say, under "The `Fired-if` line", that the command must
  exit 1 on the tree the record is written against. [untested: prose, verified by reading]

### `.shipkit/` is never "outside the spec" (S12-T2)

- **REQ-5.** When listing changes beyond the spec, the reviewer shall exclude every changed file
  under `.shipkit/` except one inside another spec's folder. [untested: prose, verified by
  reading; the `reviewer-all-met` and `reviewer-missing-req` cases guard the rest of the agent]
- **REQ-6.** `brief-verify.sh` shall allow `.shipkit/product.md`, `.shipkit/state.md`, every
  file under `.shipkit/releases/`, every file under `.shipkit/decisions/` and every file in the
  spec's own folder, for every task.
- **REQ-7.** When a changed file lies inside another spec's folder and the task's Files line does
  not name it, `brief-verify.sh` shall report it as `OUTSIDE`.

### The gate keeps its exit codes and its output (S12-T3)

- **REQ-8.** The ship report shall quote, for every step that runs a command, the exit code the
  command returned, captured by the command line itself and never inferred from its output.
  [untested: verified by a headless dry run of the gate on the shipped `real-run` spec, its report
  read and then deleted]
- **REQ-9.** The ship report's evidence blocks shall carry output pasted from the command's
  captured output, never typed from memory, and the report template shall say so. [untested:
  prose, verified by reading and by the same dry run]

### `brief-verify.sh` and ignored files, closed by record (S12-T4)

- **REQ-10.** While a file an agent writes is hidden by `.gitignore`, `brief-verify.sh` shall not
  report it, and its header shall say that this is by design and that the task's Done-when output
  is where such a file is seen. [untested: closed by record C6; the header is prose]

## Release steps (not requirements)

- The ROADMAP's "Files no spec will ever list" item and the ignored-files question are marked
  shipped or closed by record.
- The gate (`/shipkit:ship gate-blind-spots`) answers `READY`; the report is committed.
- Release as 4.5.0; the sprint exit checklist holds; the pull request is merged after a green
  check; tag `v4.5.0`; the owner's cache update (C12 D5) is its own yes.

## Out of scope

Rule text; trap-2 cases; `spec-check.sh`; the elders; a second real run; a draft-tolerant
`spec-check`; a waived-and-unmet reviewer row (§8a); the 4.3.0 and 4.4.0 gate reports.
