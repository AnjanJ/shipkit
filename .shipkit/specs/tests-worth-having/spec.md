# Spec: tests worth having

> Spec accepted at commit `6fea503` on sprint-33/tests-worth-having.
> Status: open
> Paths: scripts/kind-probe.sh, scripts/kind-replies/, scripts/prop.py, plugins/shipkit/scripts/red-check.sh, plugins/shipkit/scripts/ship-check.sh, plugins/shipkit/scripts/brief.sh, .github/workflows/lint.yml, GUIDE.md, .shipkit/specs/gate-as-software/spec.md
> Tests: scripts/smoke.sh, scripts/prop.py

## Purpose

Three kinds of test are hard for a model to fool: an end-to-end test, a property test, whose
inputs nobody chose, and a differential test, which uses the old system as the judge. Shipkit
says only "behavior-focused" and names no other kind; its two task parsers are tested only on
inputs a person thought of; and its gate takes on trust that a new test was ever red. This is
Sprint 33 of `docs/plans/verifier-sprint-plan.md`. It builds a probe that will measure which
kind of test the spec skill names and whether a migration plan asks for a test of unchanged
behaviour, five properties on `spec-check.sh` and `brief.sh` that CI runs on generated inputs,
and `red-check.sh`, which shows whether a cited test fails without the feature. It starts no
model. The text that `spec/reference.md` and the migration skill may gain is written into this
spec's `design.md` and waits for Sprint 35, which measures first (the plan's rules 33 and 34).

## User stories

- As the owner, I want a number for how often the spec skill names the right kind of test, so
  that guidance goes in only where the model misses.
- As the owner planning an upgrade, I want to know whether the plan asks for a test that runs
  the old and the new on the same inputs, so that unchanged behaviour is checked and not hoped.
- As the owner, I want shipkit's parsers tried on inputs nobody wrote by hand, so that the edge
  cases nobody thought of are found before a user finds them.
- As the owner at a gate, I want to see that a cited test fails on the tree without the feature,
  so that a test that proves nothing is named.

## Terms

- **The base of this spec.** Commit `6fea503`, `main` when this spec was written.
- **A kind.** One of three kinds of test. `e2e`: a test that drives the product through an entry
  point a user has. `property`: a test that checks a statement on generated inputs.
  `differential`: a test that runs an old and a new implementation on the same inputs and
  compares what they give.
- **A tag.** `[e2e]`, `[property]` or `[differential]`, written as the first thing after `Test:`
  on a task's `Test:` line.
- **A kind's words.** The phrases by which a `Test:` line without a tag names a kind. `design.md`
  holds the list. Among them are "property test" and "Hypothesis" for `property`, "end-to-end"
  for `e2e`, and "old and new" for `differential`.
- **The kinds fixture.** The project `kind-probe.sh --scaffold kinds` writes. Its spec is
  `passbook`.
- **The expected kind.** Of the kinds fixture's REQ-1, `property`. Of its REQ-2, `e2e` or
  `property`: either is right (the owner, 2026-11-20). Of its REQ-3, `differential`.
- **The migration fixture.** The project `kind-probe.sh --scaffold migration` writes.
- **A differential step.** In a migration plan: a step that runs the old version and the new
  version of the dependency on the same inputs and compares the results.
- **Well-formed.** A `spec.md` and a `tasks.md` in the form that
  `plugins/shipkit/skills/spec/reference.md` gives under "File templates": requirements as
  `- **REQ-N.**` items, tasks as `- [ ] **T<n>**` items with the four sub-lines, no task that
  lists one file twice. `design.md` gives the letters and lengths `prop.py` draws from.
- **The gap count.** The number before `gap(s)` in the last line `spec-check.sh` prints.
- **A citing test file.** For a spec: a file that holds `<slug>/REQ-N` for a requirement the
  spec has and that `spec-check.sh` counts as a citation: not Markdown, not under `.shipkit/`
  or `docs/`, and under the spec's `> Tests:` paths when it has that line.
- **Differs from the base.** A file whose content in the project's working tree is not its
  content at the base ref: changed or added, committed or not, untracked files included.
- **The scratch tree.** A git worktree of the base ref that `red-check.sh` makes outside the
  project, inside a directory it creates.
- **A verdict word.** `RED-AT-BASE`, `GREEN-AT-BASE`, `BASE-NOT-RUNNABLE` or `NO-TESTS`.
- **Waiting text.** Text for a file a model reads, written word for word into `design.md` and
  applied in Sprint 35 only after the run that measures the need for it.
- **Sprint 35's record.** `docs/design/eval-history.md`.

## Requirements (EARS)

The kinds fixture:

- **REQ-1.** When `scripts/kind-probe.sh --scaffold kinds <dir>` is run and `<dir>` is missing
  or empty, it shall write there a git repository with one commit and a clean tree, whose spec
  `passbook` has an acceptance stamp, `Status: open` and a `design.md`, and has no `tasks.md`.
- **REQ-2.** The spec of the kinds fixture shall hold three requirements and no more: its REQ-1
  shall hold "the balance shall never be negative", its REQ-2 "an exported file shall import to
  the same records", and its REQ-3 "after the move to the new parser, every stored document
  shall render as before".
- **REQ-3.** The kinds fixture shall record a test command, and that command shall exit 0 in the
  fixture as written.
- **REQ-4.** If the `<dir>` given to `--scaffold` holds a file, then `kind-probe.sh` shall write
  nothing and exit 2.
- **REQ-5.** When `scripts/kind-probe.sh --run kinds [N]` is run without `--yes`, it shall print
  N lines, 5 when N is not given, each a command that holds `/shipkit:spec passbook tasks`,
  shall start no `claude`, shall write no file and shall exit 0.
- **REQ-6.** When `scripts/kind-probe.sh --run kinds [N] --yes [--out <dir>]` is run, it shall
  scaffold the kinds fixture once for each run under `<dir>`, run the command in it, and keep
  each run's `tasks.md` there. [untested: it starts a model; Sprint 35 runs it]

The reader of task lists:

- **REQ-7.** When `scripts/kind-probe.sh --read <dir>` is run, it shall print one line for each
  file named `tasks.md` under `<dir>`, in path order, and each of the kinds fixture's three
  requirements. The line shall hold four tab-separated fields: the file's path, `REQ-<n>`, the
  kinds named, and `right` or `missed`.
- **REQ-8.** The kinds named for a requirement shall be the kinds that the `Test:` lines of the
  tasks citing it name, written in the order `e2e`, `property`, `differential` and joined by
  `+`. The field shall read `none` when those lines name no kind, and `uncited` when no task
  cites the requirement.
- **REQ-9.** A `Test:` line that starts with a tag shall name that tag's kind and no other.
- **REQ-10.** A `Test:` line with no tag shall name each kind one of whose words it holds.
- **REQ-11.** The fourth field shall read `right` when the kinds named hold an expected kind of
  the requirement, and `missed` when they do not.
- **REQ-12.** After those lines `--read` shall print one line for each of the three
  requirements, `TOTAL REQ-<n> right=<r> missed=<m>`, where r and m count the files.
- **REQ-13.** `scripts/kind-replies/` shall hold six task lists for the kinds fixture, two for
  each kind: one in which the `Test:` line of the task for that kind's requirement names the
  kind, and one in which it names none. `scripts/smoke.sh` shall fail unless `--read` marks
  that requirement `right` in the first and `missed` in the second.
- **REQ-14.** On a task list in which the task for the kinds fixture's REQ-2 names `property`
  and no other kind, `--read` shall mark REQ-2 `right`.

The migration fixture and its reader:

- **REQ-15.** When `scripts/kind-probe.sh --scaffold migration <dir>` is run and `<dir>` is
  missing or empty, it shall write there a git repository with one commit and a clean tree. The
  tree shall hold a project that uses a library at one major version, that library at the next
  major version, a changelog between the two that names a change in behaviour the project's
  code depends on, and a recorded test command that exits 0. It shall hold no spec.
- **REQ-16.** When `scripts/kind-probe.sh --run migration [N]` is run without `--yes`, it shall
  print N lines, 3 when N is not given, each a command that holds
  `/shipkit-workflows:migration-plan`, shall start no `claude`, shall write no file and shall
  exit 0.
- **REQ-17.** When `scripts/kind-probe.sh --run migration [N] --yes [--out <dir>]` is run, it
  shall scaffold the migration fixture once for each run under `<dir>`, run the command in it,
  and keep each run's plan there as a file. [untested: it starts a model; Sprint 35 runs it]
- **REQ-18.** When `scripts/kind-probe.sh --read-plan <file>…` is run, it shall print one line
  for each file, two tab-separated fields: the file's path, and `differential` when the plan
  holds a differential step or `none` when it holds none.
- **REQ-19.** `scripts/kind-replies/` shall hold two migration plans written by hand, one with a
  differential step and one without. `scripts/smoke.sh` shall fail unless `--read-plan` prints
  `differential` for the first and `none` for the second.
- **REQ-20.** If `kind-probe.sh` is run with a mode or a fixture name it does not know, then it
  shall print its usage on standard error, do nothing else and exit 2.

Five properties of the two parsers:

- **REQ-21.** For a well-formed task list in which no task names another on its `After` line,
  `spec-check.sh` shall print one `CONFLICT` line for each two tasks and each file that
  `brief.sh` prints under "You may edit" for both of them, naming those two tasks and that file,
  and shall print no other `CONFLICT` line.
- **REQ-22.** For a well-formed spec, a run of `spec-check.sh` shall leave every file under the
  project directory as it was, and a second run shall print the lines the first printed.
- **REQ-23.** For a well-formed spec, adding a citation of one of its requirements to a file
  that counts shall not raise the gap count.
- **REQ-24.** For a well-formed shipped spec in which every requirement without a waiver is
  cited once, taking away the citation of one requirement shall add one `MISSING-TEST` line,
  for that requirement, shall raise the gap count by one, and shall change no other line but
  the spec's `EVIDENCE` line.
- **REQ-25.** For a well-formed spec and a task that cites one of its requirements, the lines
  `brief.sh` prints for that requirement under "Requirement" shall be the requirement's lines
  in `spec.md`, byte for byte.
- **REQ-26.** `scripts/prop.py` shall check REQ-21 to REQ-25 on inputs that Hypothesis
  generates. It shall exit 0 when every one holds. When one does not, it shall exit 1 and print
  that property's name and the input it failed on.
- **REQ-27.** Two runs of `scripts/prop.py` on one tree shall try the same inputs.
- **REQ-28.** For each of REQ-21 to REQ-25, when `scripts/prop.py` is pointed at a copy of the
  script in which that behaviour is broken, it shall exit 1 and name that property.
- **REQ-29.** If Hypothesis cannot be imported, then `scripts/prop.py` shall print one line that
  holds the command `uv run --with hypothesis==<version> python3 scripts/prop.py`, with the
  version it is written for, check nothing and exit 2.
- **REQ-30.** `scripts/prop.py` shall write only under a temporary directory that it makes and
  removes.
- **REQ-31.** The `lint` job and the `smoke-no-model` job of `.github/workflows/lint.yml` shall
  each install Hypothesis, at the version `scripts/prop.py` is written for, and run `python3
  scripts/prop.py`.

Red at base:

- **REQ-32.** When `plugins/shipkit/scripts/red-check.sh <project> <slug> <base> [--test
  '<command>'] [--link <dirs>]` is run, it shall print `TEST <file>` for each citing test file
  of the spec that differs from the base, in path order.
- **REQ-33.** If no citing test file of the spec differs from the base, then `red-check.sh`
  shall print `NO-TESTS`, make no scratch tree and run no command.
- **REQ-34.** Where a citing test file differs from the base, `red-check.sh` shall make the
  scratch tree and run the test command in it once. If that run fails, then it shall print
  `BASE-NOT-RUNNABLE` and run nothing more.
- **REQ-35.** When the run of REQ-34 passes, `red-check.sh` shall copy each listed file from the
  project into the scratch tree at the same path and run the test command again. It shall print
  `RED-AT-BASE` when that run fails, and `GREEN-AT-BASE` followed by the listed files when it
  passes.
- **REQ-36.** The test command shall be the `--test` argument, or without one the command
  `test-command.sh <project>` prints. If there is neither, then `red-check.sh` shall say so on
  standard error, make no scratch tree, print no verdict word and exit 2.
- **REQ-37.** Where `--link` names folders, separated by commas, `red-check.sh` shall link each
  into the scratch tree at the same path, from the project, before the first run. Without
  `--link` it shall link nothing.
- **REQ-38.** If a `--link` name is not a folder of the project, or is a path git tracks at the
  base ref, then `red-check.sh` shall make no scratch tree, print no verdict word and exit 2.
- **REQ-39.** On every way out, an interrupt included, `red-check.sh` shall remove the scratch
  tree and the directory it made, and shall remove no worktree and no directory that it did not
  make.
- **REQ-40.** After a run of `red-check.sh`, the project's `git status --porcelain`, `git
  branch`, `git stash list`, `git worktree list` and `HEAD` shall read as they read before it.
- **REQ-41.** `red-check.sh` shall print the output of the two runs on standard error, and on
  standard output only the `TEST` lines and then one line that starts with a verdict word.
- **REQ-42.** `red-check.sh` shall exit 0 when it prints a verdict word, whichever it is, and 2
  on wrong usage, an unknown base ref, a project that is not a git repository or a spec it
  cannot find.
- **REQ-43.** `ship-check.sh` shall end `evidence.md` with one line that starts `Not run, a
  suggestion:` and holds the `red-check.sh` command for its project, slug and base ref, and
  shall print on standard output what it printed at the base of this spec.
- **REQ-44.** `GUIDE.md` shall have a section on `red-check.sh`: what each verdict word means,
  that a folder named by `--link` is shared with the project it is pointed at, and that it is
  run by hand and is not a gate step. [untested: prose, verified by reading]

What a model reads (written here, applied in Sprint 35 after its baseline):

- **REQ-45.** This spec's `design.md` shall hold the waiting text for
  `plugins/shipkit/skills/spec/reference.md`: a table that maps a requirement's shape to a kind,
  and the tag. [untested: prose, verified by reading]
- **REQ-46.** This spec's `design.md` shall hold the waiting step for
  `/shipkit-workflows:migration-plan`: where behaviour must stay the same, the plan's first task
  is a differential test that sets aside the differences that do not matter and lists the ones
  that are meant. The skill's description shall stay as it is. [untested: prose, verified by
  reading]
- **REQ-47.** This spec's `design.md` shall hold a record for each of the plan's decisions V16
  (test kinds), V17 (the property-test library) and V18 (red at base), each with the event that
  reverses it. [untested: prose, verified by reading]
- **REQ-48.** A line of REQ-45's text shall go into `reference.md` only for a kind whose
  requirement read `missed` in 2 or more of 5 runs of the kinds probe on the text as it is at
  `v5.3.0`, and shall stay only where more of 5 runs after it read `right`. [untested: read
  from Sprint 35's record]
- **REQ-49.** REQ-46's step shall go into the migration skill only after 3 runs of the
  migration probe without it, and shall stay only where more of 3 runs after it hold a
  differential step. [untested: read from Sprint 35's record]
- **REQ-50.** `red-check.sh` shall be read on the clone of the owner's project, never on the
  live checkout, and its verdict word and its time shall be written into the record.
  [untested: read from Sprint 35's record]

Found on the way (added 2026-11-20 on the owner's yes, after acceptance):

- **REQ-51.** The `Test` and `Done when` lines that `brief.sh` prints under "Prove it with" shall
  be the task's own text in `tasks.md`, byte for byte, also when it holds a backslash.
- **REQ-52.** The title line that `brief.sh` prints first shall hold the task's title as
  `tasks.md` has it, byte for byte, also when it holds a backslash.

## A requirement of `gate-as-software` that this spec amends

It gets a dated note in `gate-as-software/spec.md`, in the task that changes `ship-check.sh`, so
the words and the script change in one commit (the owner's yes, 2026-11-20):

- **Its REQ-11** has `ship-check.sh` write one block for each of six steps to `evidence.md`.
  REQ-43 above adds one line after the last block. The line starts with neither `### ` nor
  `result:`, so smoke check 107 counts the blocks as before.

## A property that fails

A property of REQ-21 to REQ-25 that fails on the checkout's own scripts is a finding, not a
flaky check. It is put to the owner before any change to `spec-check.sh` or `brief.sh`, with the
input it failed on. So is a property that fails on one of CI's two runners only (the owner,
2026-11-20). The fix keeps smoke checks 112 and 121 as they read, or the owner says otherwise.

## Out of scope

- Any paid model run in this sprint, and any change to an existing skill, agent, rule or overlay
  file (the plan's rules 33 and 34). REQ-6, REQ-17 and REQ-48 to REQ-50 are this spec's, and
  their tasks wait for Sprint 35.
- Writing a tag into any `tasks.md` of this repository, and having any script read one outside
  `kind-probe.sh`.
- Making `red-check.sh` a gate step, observed or enforced, or having any skill run it (V18).
- A verdict for each test file on its own: `red-check.sh` runs the suite once with all the
  listed files.
- A new mode or flag in `spec-check.sh` or `brief.sh`.
- Property tests on any script other than `spec-check.sh` and `brief.sh`.
- An eval case, and room in the evals folder: both probes live under `scripts/`.
- `verify-run.sh`, the commit gate and the prune: Sprint 34.
