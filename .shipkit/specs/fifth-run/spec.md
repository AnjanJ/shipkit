# Spec: The owner's project again, and 5.2.0 (Sprint 28)

> Spec accepted at commit `f138e94` on sprint-28/fifth-run (2026-11-06).
> Status: open
> Paths: README.md, GUIDE.md, docs/design/field-notes-5.2.md, ROADMAP.md, CHANGELOG.md, docs/design/eval-history.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, docs/plans/machine-sprint-plan.md, .shipkit/specs/gate-on-setup/spec.md, .shipkit/specs/users-machine/spec.md

## Purpose

Sprints 26 and 27 changed four things a first spec on a real project meets: setup's own
`CLAUDE.md` and `.gitignore` lines no longer count against it, the reviewer has a mark for half
built, the test command setup writes runs on a pinned toolchain, and the gate searches with
`git grep`. Only fixtures and smoke checks have shown any of it. This sprint runs the loop on the
owner's Elixir project again, where all four lines meet the code they were written for. It answers
the two questions PR #30 left (an install with `--scope project`, and a gate run again on a later
day) and then releases all three sprints as 5.2.0.

Source: `docs/plans/machine-sprint-plan.md` (approved 2026-11-05), G6, G10 to G13, Sprint 28;
`docs/design/field-notes-5.1.md`; `docs/design/eval-results-5.2.md` §1;
`.shipkit/specs/review-and-ship/spec.md` REQ-20.

## User stories

- As a user whose plugins are installed for one project, I want the README to tell me how to
  update them, so that a project does not stay on an old version without my knowing.
- As the owner, I want the loop read on my own project, so that I know what Sprints 26 and 27 do
  outside a fixture.
- As a user upgrading, I want one release whose notes say first what changed for me.

## Requirements (EARS)

### `--scope project` (G11, S28-T1)

- **REQ-1.** The run shall install both plugins with `--scope project` in a scratch directory,
  from a marketplace one version behind what it then offers, run `claude plugin update` with
  `--scope project` for each plugin once from outside that directory and once from inside it, and
  record in `docs/design/field-notes-5.2.md` each command, its output and exit status, and the
  version each install reads after it. [untested: a run, read from its record]
- **REQ-2.** `README.md` and `GUIDE.md` ("Updating") shall each say how an install that
  `claude plugin list` shows as `Scope: project` is updated, as REQ-1's record shows, beside what
  they say of `Scope: local`. [untested: prose, read against REQ-1's record]
- **REQ-3.** The run of REQ-1 shall leave the owner's own `~/.claude/plugins/installed_plugins.json`
  and `known_marketplaces.json` as they were, each file's checksum before and after recorded with
  REQ-1's record. [untested: a run, read from its record]

### The run (G6, G10, G11, S28-T2)

- **REQ-4.** Before any paid step, the run shall show that `~/code/office_bestie` builds and its
  test suite runs in a fresh worktree at its `main` (`179f99d`), at
  `/private/tmp/shipkit-real-run-6` on the throwaway branch `shipkit/real-run-6`, with
  `MIX_TEST_PARTITION=_shipkit6` so that its tests use a database of their own, and shall record
  the count as the run's baseline; where it cannot, the run shall stop and ask the owner.
  [untested: a run, read from its log]
- **REQ-5.** The run shall take the nine steps of `docs/design/field-notes-5.1.md` (§1 to §9) on
  the item the owner names, each headless on `sonnet` with `--plugin-dir`, except setup, which the
  owner runs and reads in a session of their own; `docs/design/field-notes-5.2.md` shall give
  every step its six parts. [untested: a record, verified by reading]
- **REQ-6.** No word the runner writes into a step's prompt shall name `mise` or a test command,
  so that each step takes the test command from what setup wrote (`brief.sh`'s output, passed
  unchanged, carries it from `tasks.md`). [untested: a rule of the run, verified by the prompts
  kept in the record]
- **REQ-7.** When a step ends, the run shall copy its output to a folder outside `/private/tmp`
  and write its section of `field-notes-5.2.md` before the next step starts.
  [untested: a rule of the run, verified by the record's times]
- **REQ-8.** The gate (step 9) shall run on the run's first day with its report left untracked, and
  again on a later day on the same tree; `field-notes-5.2.md` shall say whether the second reply
  names the first report as superseded, as `review-and-ship/REQ-20` says, and whether the first
  report is still in place. [untested: a run, read from its record]
- **REQ-9.** `field-notes-5.2.md` shall read each of the plan's G1 to G7 as held or not shown, each
  with the file and line or the log that shows it. [untested: a record, verified by reading]
- **REQ-10.** While a step of the run is in progress, no file under `plugins/` shall be edited, and
  nothing the run finds shall be fixed in this sprint: each finding goes to the ROADMAP.
  [untested: a rule of the run, verified by the record and `git log`]
- **REQ-11.** The run shall remove nothing (the worktree, the branch, the run's test database,
  the copied output) without the owner's yes, and `field-notes-5.2.md` shall say what was removed,
  when and on whose word. [untested: a step, verified by reading]

### The roadmap (S28-T3)

- **REQ-12.** `ROADMAP.md` shall hold the machine plan's section with its three rows and 5.2.0,
  and "Still open after Sprint 28" with the run's findings and what the plan's §5 left; every item
  shall cite a file and a section. [untested: a record, verified by reading]

### The release (G12, G13, S28-T-REL)

- **REQ-13.** The plan's exit checklist shall hold in full, with `bash scripts/evals.sh -j 4`
  exiting 0, or each failing case named with its trace and the owner having said go, and the run
  recorded in `docs/design/eval-history.md`. [untested: a release step, verified by reading]
- **REQ-14.** `/shipkit:ship` shall read READY on `gate-on-setup` against `03e87eb` and on
  `users-machine` against `9b32e36`, one at a time, each gate recorded in `eval-history.md`, and
  each spec's `Status:` shall change to `shipped` on the owner's yes.
  [untested: the gate is its own check]
- **REQ-15.** The five version lines shall read 5.2.0, and the CHANGELOG's `[Unreleased]` entry
  shall become 5.2.0's, open with "What changed for you", and lead with two things: setup's own
  lines no longer count against a first spec, and the test command setup writes runs on a pinned
  toolchain. [untested: a release step, verified by reading]

## Release steps (not requirements)

By rule 27, nothing here is a `REQ-N`: this spec's gate cannot read any of it.

- `/shipkit:ship` reads READY on `fifth-run` against its acceptance commit, last of the three; the
  report is committed, and the spec's `Status:` changes to `shipped` on the owner's yes.
- The release reaches `main` by a pull request holding "What was awkward", a green check on its
  head sha and a merge commit; the annotated tag `v5.2.0` is on the remote (`git ls-remote`).
- Each of G13's items happens only on its own yes, by rule 26: the owner's cache to 5.2.0 after the
  tag; the three sprint branches; the `5.1.0` cache once its `.in_use` names no live process.

## Out of scope

Everything in the plan's §5, and anything the run finds. No change under `plugins/` but the two
version lines. No smoke check and no eval case: the evals directory stays at most 204,800 bytes,
and the three always-on rules stay at 2,999 bytes. `/shipkit:ask --walk`, which the 5.1 run took
as a tenth step: it is not among the nine.
