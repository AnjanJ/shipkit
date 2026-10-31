# Spec: The owner's project, and 5.1.0 (Sprint 25)

> Spec accepted at commit `6831e71` on sprint-25/fourth-project (2026-10-31).
> Status: open
> Paths: plugins/shipkit/scripts/install-stack.sh, plugins/shipkit/skills/setup/SKILL.md, plugins/shipkit/skills/escape/SKILL.md, plugins/shipkit/skills/handoff/SKILL.md, plugins/shipkit/skills/intake/SKILL.md, plugins/shipkit/skills/product/, plugins/shipkit/skills/ship/reference.md, plugins/shipkit/skills/spec/reference.md, scripts/smoke.sh, docs/design/field-notes-5.1.md, docs/design/eval-history.md, ROADMAP.md, CHANGELOG.md, README.md

## Purpose

5.1.0 is the first release in which a decision binds: a contradicted decision reads NOT READY. Only
fixtures have shown that. And no real project has run the three fixes for a project that already has
its own `CLAUDE.md` and rules since they shipped in 4.10.0. So this sprint runs the whole loop on the
owner's Elixir project, which has all three preconditions, and reads what holds.

First it pays four small debts, so the run can read them. A FastAPI project stops loading Django
advice on every `models.py`, and setup stops saying it loads on Django files only, which is untrue.
A stack section stops listing the alternatives the project did not pick, about 210 bytes of a Python
section that loads in every session, and stops telling a sync project to use an async ORM. Templates
stop handing out a date: a real intake was stamped 2026-10-05 on 2026-10-31. A `Fired-if` stops
firing on bytecode.

Then the release, one for all three sprints.

Source: `docs/plans/binding-sprint-plan.md` (approved 2026-10-31), G8, G10, G11, G12, Sprint 25;
`docs/design/field-notes-5.0.md`; `ROADMAP.md`, "Still open after Sprint 22".

## User stories

- As a FastAPI or Flask user, I want no Django rule in my project, so that opening `models.py` does
  not load advice for a framework I do not use.
- As a user of any stack, I want the section in my `CLAUDE.md` to say what my project is, so that
  every session stops paying for what it is not.
- As a user of `/shipkit:intake`, `/shipkit:escape`, `/shipkit:handoff`, `/shipkit:product` or
  `/shipkit:ship`, I want today's date on what they write, so that a date in `.shipkit/` can be
  believed.
- As someone writing a decision, I want to be told a `Fired-if` should use `git grep`, so that it
  does not fire on `__pycache__`.
- As the owner, I want the loop read on a project with its own rules, so that I know what the fixes
  do outside a fixture.
- As a user upgrading, I want one release that says first what got stricter, so that a NOT READY I
  did not get before does not surprise me.

## Requirements (EARS)

### Four debts (G8, S25-T1)

- **REQ-1.** When `install-stack.sh` installs the `python` stack and `PYTHON_FRAMEWORK` does not name
  Django, it shall not write `python/django.md`, shall not record it in the manifest, and shall still
  write `python/pyproject.md`.
- **REQ-2.** When `install-stack.sh` installs the `python` stack and `PYTHON_FRAMEWORK` names Django
  (`Django` or `django`, alone or followed by more words), it shall write `python/django.md` as it
  does today.
- **REQ-3.** The setup skill's table of what each stack installs shall not say
  `(loads on Django files only)`, and shall say `django.md` installs on a Django project.
- **REQ-4.** No stamp line in any file under `plugins/shipkit/skills/` shall hold a literal date, and
  the six stamp lines shall hold `<YYYY-MM-DD>`.
- **REQ-5.** Each of the six files holding a stamp line shall say, before its template, that the date
  comes from `date +%F`.
- **REQ-6.** When `install-stack.sh` writes a stack's `CLAUDE.md` section, the lines between the
  shipkit markers shall hold no `<!--`, for every stack that has a section, and both markers shall
  stay.
- **REQ-7.** `stacks/*/CLAUDE.md.append` shall keep its comments, which setup reads for a `TODO:` hint.
- **REQ-8.** When `install-stack.sh` writes the `python` section and `ASYNC_MODE` is `no` or `No`, the
  section shall hold no `**Async DB:**` line and shall keep its `**Async:**` line; for any other value
  it shall hold both.
- **REQ-9.** `install-stack.sh` shall take `.section-<stack>.sha` from the section as written, after
  REQ-6 and REQ-8, so that a re-run with the same values reports the section already current and
  changes nothing.
- **REQ-10.** The `Fired-if` section of `skills/spec/reference.md` shall say that a `Fired-if` command
  reads tracked files, and shall name `git grep`.

### The run (G10, S25-T2)

- **REQ-11.** Before any paid step, the run shall show that `~/code/office_bestie` builds and its test
  suite runs in a fresh worktree at `179f99d`, on the throwaway branch `shipkit/real-run-5`, with
  `MIX_TEST_PARTITION=_shipkit5` so that its tests use a database of their own, and shall record the
  count as the run's baseline; where it cannot, the run shall stop and ask the owner.
  [untested: a run, read from its log]
- **REQ-12.** The run shall take the nine steps of `docs/design/field-notes-5.0.md` on the item the
  owner named, `TODO.md:204`, with setup saying yes to `--with-skills`, and one
  `/shipkit:ask --walk <feature>`,
  each headless on `sonnet` with `--plugin-dir`; `docs/design/field-notes-5.1.md` shall give every
  step its six parts. [untested: a record, verified by reading]
- **REQ-13.** `docs/design/field-notes-5.1.md` shall read each of G1, G2, G3, E1, E2 and E3 as held or
  not shown, each with the file and line that show it, and shall say how each of the four debts met
  the run. [untested: a record, verified by reading]
- **REQ-14.** While a step of the run is in progress, no file under `plugins/` shall be edited, and
  nothing the run finds shall be fixed in this sprint: each finding goes to the ROADMAP.
  [untested: a rule of the run, verified by the log and `git log`]
- **REQ-15.** The worktree, the branch and the run's test database shall each be removed only on the
  owner's yes, after the log has been read. [untested: a step, verified by reading]

### The roadmap (S25-T3)

- **REQ-16.** `ROADMAP.md` shall hold the plan's section with its three rows and 5.1.0, and "Still
  open after Sprint 25" with the run's findings, what the plan's §5 left, and the evals every user
  carries and never runs, at 198,837 of 528,427 bytes at 5.0.0; every item shall cite a file and a
  section. [untested: a record, verified by reading]

### The release (G11, G12, S25-T-REL)

- **REQ-17.** The plan's exit checklist shall hold in full, with `bash scripts/evals.sh -j 4` exiting
  0, or each failing case named with its trace and the owner having said go, and the run recorded in
  `docs/design/eval-history.md`. [untested: a release step, verified by reading]
- **REQ-18.** `/shipkit:ship` shall read READY on `decisions-bind`, `readable-numbers` and
  `fourth-project`, one at a time, each against its acceptance commit, and each spec's `Status:` shall
  change to `shipped` on the owner's yes. [untested: the gate is its own check]
- **REQ-19.** The reviewer's `placeholder` shall be counted again from the session logs against 3 of
  74, and the count shall say the reviewer has run on `sonnet` since `4f81799`.
  [untested: a count, verified by reading]
- **REQ-20.** The five version lines shall read 5.1.0, and the CHANGELOG's entry shall open with "What
  changed for you", lead with the gate's new NOT READY, and say what a project set up on 5.0.0 sees:
  `django.md` stays, and an unedited section loses its comments at the next setup.
  [untested: a release step, verified by reading]
- **REQ-21.** The release shall reach `main` by a pull request holding "What was awkward", a green
  check and a merge commit, and the annotated tag `v5.1.0` shall be on the remote.
  [untested: a release step, verified by `git ls-remote`]
- **REQ-22.** Each of G12's three items shall happen only on its own yes, by rule 26.
  [untested: a step, verified by reading]

## Out of scope

Everything in the plan's §5, and anything the run finds. No always-on byte: the three rules and every
skill and agent description stay as they are. No new eval case, so the evals directory stays at most
204,800 bytes. Nothing deletes `django.md` from a project set up on 5.0.0.
