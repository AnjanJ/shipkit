# Spec: The spec is a contract (Sprint 2, release 3.3.0)

> Spec accepted at commit `65941bf` on sprint-2/spec-contract.
> Status: open
> Paths: plugins/shipkit/scripts/spec-check.sh, plugins/shipkit/scripts/session-start.sh, plugins/shipkit/skills/spec/, plugins/shipkit/rules/spec-driven.md, .github/workflows/lint.yml

## Purpose

A spec stops being a document someone promises to follow: a script checks it. This sprint
gives a spec a status and a list of paths, lets a test cite the requirement it proves, gives
tasks a format a script can read, measures drift only on the files a spec covers, and runs the
check in CI.

Source: `docs/plans/quality-gate-sprint-plan.md`, Sprint 2, tasks S2-T1 to S2-T6. The formats
this sprint introduces are defined there under "The formats this sprint introduces"; this spec
is written in them.

## User stories

- As a solo engineer, I want a command that fails when a requirement has no task or no test,
  so that "done" is something a script agrees with.
- As a user with finished specs, I want the session hook to stop nagging about them, so that
  the nag means something when it appears.
- As someone handing tasks to agents, I want each task to say which files it may change, so
  that two tasks cannot quietly edit the same file at once.

## Requirements (EARS)

### `spec-check.sh`: requirements and tests (S2-T1)

- **REQ-1.** When `spec-check.sh <project-dir>` is run with no slug, it shall check every spec
  under `.shipkit/specs/`; with a slug, only that spec.
- **REQ-2.** If `spec-check.sh` is called with wrong usage (no project directory, or one that
  does not exist), then it shall exit 64.
- **REQ-3.** When a spec's status is `open` or `shipped` and a requirement that is not excused
  is not mentioned in `tasks.md`, `spec-check.sh` shall print `MISSING-TASK <slug> REQ-N`.
- **REQ-4.** When a spec's status is `shipped` and no file outside `.shipkit/`, `docs/` and
  `*.md` contains `<slug>/REQ-N`, `spec-check.sh` shall print `MISSING-TEST <slug> REQ-N`.
- **REQ-5.** When a requirement line ends with `[untested: <reason>]`, `spec-check.sh` shall
  print `WAIVED <slug> REQ-N` and shall not print `MISSING-TEST` for it.
- **REQ-6.** When a spec's status is `draft` or `dropped`, `spec-check.sh` shall print
  `SKIPPED <slug> (<status>)` and check nothing in it.
- **REQ-7.** Where a spec has no `Status` line, `spec-check.sh` shall treat it as `open`.
- **REQ-8.** `spec-check.sh` shall exit 1 if it printed any `MISSING-`, `BAD-AFTER`,
  `CONFLICT` or `CYCLE` line, and 0 otherwise.
- **REQ-9.** A citation of one spec's requirement (`a/REQ-1`) shall not satisfy another spec's
  requirement of the same number (`b/REQ-1`).
- **REQ-10.** `spec-check.sh` shall be POSIX `sh` and shall not need python on the user's machine.

### `spec-check.sh`: the task format (S2-T2)

- **REQ-11.** When a spec is `open` and has a `Status` line, and a task lacks `Files`, `Test`,
  `After` or `Done when`, `spec-check.sh` shall print `MISSING-FIELD <slug> T<n> <field>`.
- **REQ-12.** If a task's `After` line names a task that does not exist, then `spec-check.sh`
  shall print `BAD-AFTER <slug> T<n> <name>`.
- **REQ-13.** If two tasks list the same file and the later one does not come after the
  earlier one — named in its `After`, or reached through a chain of `After` lines — then
  `spec-check.sh` shall print `CONFLICT <slug> T<a> T<b> <file>`.
  *(Reworded on 2026-10-05, owner-approved: the first wording required a direct name. See the
  superseding decision in `design.md`.)*
- **REQ-14.** Where a spec has no `Status` line and its tasks are in the pre-3.3 format,
  `spec-check.sh` shall report no task-format finding for it.
- **REQ-27.** If a task's `After` lines lead back to itself, then `spec-check.sh` shall print
  `CYCLE <slug> T<n>`. *(Added on 2026-10-05 with the reworded REQ-13.)*

### Drift measured on the right files (S2-T3)

- **REQ-15.** While a spec's status is `shipped`, `dropped` or `draft`, the session hook shall
  print no drift line for it.
- **REQ-16.** Where a spec has a `Paths` line, the session hook shall count only the commits
  since acceptance that touch those paths.
- **REQ-17.** Where a spec has a `Paths` line and is over the threshold, the hook's line shall
  say "N commits have touched its paths since it was accepted".
- **REQ-18.** Where a spec has neither a `Status` nor a `Paths` line, the session hook shall
  behave exactly as in 3.2.0: the existing `spec-staleness` smoke checks pass unchanged.

### The skill and the rule (S2-T4)

- **REQ-19.** The `spec.md` and `tasks.md` templates in `skills/spec/reference.md` shall show
  the `Status` and `Paths` lines, the `<slug>/REQ-N` citation, the `[untested: …]` excuse and
  the task format with `Files`, `Test`, `After` and `Done when`.
  [untested: a template, verified by reading]
- **REQ-20.** `/shipkit:spec` shall write `Status: draft` at Q1, set `Status: open` and ask for
  `Paths` at acceptance, write tasks in the new format, and then run `spec-check.sh` and fix
  what it reports. [untested: skill prose, verified by reading; REQ-21 checks the outcome]
- **REQ-21.** When `/shipkit:spec` writes a spec for "refunds" in the fixture project, the
  written spec shall get exit 0 from `spec-check.sh`.
- **REQ-22.** The `spec-driven` rule shall say that tests cite `<slug>/REQ-N`, and the three
  always-on rules shall still total at most 3,000 bytes.

### This repository's own specs (S2-T5)

- **REQ-23.** When `sh plugins/shipkit/scripts/spec-check.sh .` is run in this repository, it
  shall exit 0 and print no `MISSING-` line.
- **REQ-24.** While S2-T5 is carried out, no smoke or lint check shall change what it does:
  only comments are added. [untested: verified from the commit's diff]

### CI (S2-T6)

- **REQ-25.** The `lint` workflow shall run `sh plugins/shipkit/scripts/spec-check.sh .` after
  the lint, and fail when it fails.
  [untested: a CI configuration, verified by the pull request's own check]

### Sprint exit

- **REQ-26.** When Sprint 2 is complete, the five lines of the sprint exit checklist in the
  plan shall hold: lint clean, smoke passing, no eval case that passed in 3.2.0 failing,
  `spec-check.sh .` exiting 0, always-on rules at most 3,000 bytes.
  [untested: a checklist, verified by running it]

## Out of scope

- Any new skill or agent.
- Making `spec-check.sh` understand test results. It checks that a citation exists, not that
  the test passes; the ship gate (Sprint 4) runs the tests.
- Changing what any existing smoke or lint check does in order to cite a requirement.
- Rewriting the two older specs' requirements. They gain status, paths and citations only.
