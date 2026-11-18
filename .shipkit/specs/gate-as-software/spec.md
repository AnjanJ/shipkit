# Spec: gate as software

> Spec accepted at commit `930122f` on sprint-30/gate-as-software.
> Status: open
> Paths: plugins/shipkit/scripts/, scripts/smoke.sh, scripts/judge.sh, .github/workflows/, .shipkit/decisions/0007-a-change-does-not-judge-itself.md, plugins/shipkit/skills/ship/, plugins/shipkit/skills/spec/, plugins/shipkit/skills/setup/, GUIDE.md
> Tests: scripts/smoke.sh, .github/workflows/

## Purpose

Make the parts of the ship gate that are commands exist as commands. Today a model runs each of
the gate's steps, captures the output and pastes it back; the test command is copied from
`CLAUDE.md`, where a project can hold two; a `READY` report names a commit that nothing reads
again; and a branch that changes the gate is judged by its own copy of the gate. This is Sprint 30
of `docs/plans/verifier-sprint-plan.md`. It builds scripts and their checks. The text that makes
the skills use them waits in `design.md` for Sprint 35 (the plan's rules 33 and 34).

## User stories

- As the owner reading a ship report, I want each command step's evidence to come from a script,
  so that a step cannot be skipped or paraphrased.
- As the owner of a project with a pinned toolchain, I want the gate and every task to run the
  one test command setup recorded, so that the command that exits 1 is never copied again.
- As the owner at a release, I want to be told when work landed after the gate's report, so that
  `READY` at an old commit is not read as `READY` now.
- As the owner of this repository, I want its gates judged by the last release's gate, so that a
  branch cannot pass by weakening the judge.

## Terms

- **The session hook.** `plugins/shipkit/scripts/session-start.sh`. It counts, for an open spec
  with a `> Paths:` line, the commits since acceptance that touch those paths
  (`spec-contract/REQ-16`).
- **The record.** The file `.claude/rules/shipkit/.test-command` in a project: one line, the
  project's test command. It is not a Markdown file, so Claude Code does not load it as a rule.
- **The installer.** `plugins/shipkit/scripts/install-stack.sh`, which setup runs once for each
  stack overlay, with `KEY=value` arguments. At 5.3.0 seven of the ten overlays take a
  `TEST_COMMAND` argument: elixir, go, hotwire, liveview, python, rails and react. The overlays
  ml, oban and static take none, and a project with no overlay never runs the installer.
- **The gate's steps.** The eight rows of the table in `plugins/shipkit/skills/ship/SKILL.md`.
  **A command step** is one of steps 1, 2, 3, 7 and 8: its result follows from a command's exit
  status or output alone.
- **A migration file.** A changed file under `db/migrate/`, `migrations/`, `priv/repo/migrations/`,
  `alembic/` or `prisma/migrations/`, or a changed `*.sql` (the ship skill's note on step 5).
- **The base ref.** The commit a branch's work started from. When none is given: the merge base
  of `HEAD` and the default branch (`main`, or `master`).
- **A scratch directory.** A directory `ship-check.sh` made with `mktemp -d`, named
  `shipkit-ship.XXXXXX` under `${TMPDIR:-/tmp}`, holding the file `evidence.md`.
- **A step's block.** The lines of `evidence.md` for one step: a heading with the step's number
  and name, the exact command, `exit <N>`, the last twenty lines of the command's output, and one
  line `result: PASS — <reason>`, `result: FAIL — <reason>` or `result: NEEDS-READING — <reason>`.
- **A `READY` report.** A file `.shipkit/releases/<YYYY-MM-DD>-<slug>.md` whose first line is
  exactly `READY`. **Its commit** is the one its `> Checked on … at commit` line names. A spec's
  **newest** `READY` report is the one with the latest date in its name.
- **A shipped spec.** A spec whose `spec.md` has the line `> Status: shipped`. **Its shipping
  commit** is the first commit, in history's order, in which that line is present.
- **A finding.** A line `release-check.sh` prints that starts `NO-REPORT`, `ORPHAN-REPORT` or
  `CHANGED-AFTER-GATE`.
- **The last tag.** The name `git describe --tags --abbrev=0` prints. At this spec's start it is
  `v5.3.0`.

## Requirements (EARS)

The `> Paths:` line, read as written:

- **REQ-1.** Where an entry of a spec's `> Paths:` line starts or ends with the letter `t`, the
  session hook shall count the commits that touch that entry's path as it is written, with no
  letter removed.

One test command:

- **REQ-2.** When the installer is given a `TEST_COMMAND=<command>` argument and the install
  succeeds, it shall write `<command>` as the one line of the record.
- **REQ-3.** When the installer runs with no `TEST_COMMAND` argument, it shall leave an existing
  record unchanged.
- **REQ-4.** When `unsetup-remove.sh <project> --yes` removes an installation, it shall delete the
  record.
- **REQ-5.** When `test-command.sh <project>` is run and the record exists, it shall print the
  record's line and exit 0.
- **REQ-6.** If the record does not exist, then `test-command.sh <project>` shall print `no test
  command recorded; run /shipkit:setup, or pass one` on standard error and exit 1.
- **REQ-7.** `test-command.sh` shall not read `CLAUDE.md`: where a project's `CLAUDE.md` names
  two test commands and the record holds a third, it shall print the record's.
- **REQ-8.** When `test-command.sh <project> --record '<command>'` is run, it shall write
  `<command>` as the one line of the record and exit 0.

The gate's command steps, run by a command:

- **REQ-9.** When `ship-check.sh <project> <slug> [base] [--test '<command>']` is run, it shall
  make a scratch directory and print that directory's path as its first line of output.
- **REQ-10.** If `.shipkit/specs/<slug>/spec.md` does not exist, then `ship-check.sh` shall say
  so on standard error, make no scratch directory and exit 2.
- **REQ-11.** `ship-check.sh` shall write one block for each of steps 1, 2, 3, 5, 7 and 8 to
  `evidence.md`, in that order, and shall run every step even after one has failed.
- **REQ-12.** Step 1's block shall hold `spec-check.sh . <slug> --as-shipped` and its exit status,
  `PASS` when that status is 0, and after it the output of `spec-diff.sh` for the slug and the
  base ref.
- **REQ-13.** Step 2's block shall hold the test command, run once, and its exit status, `PASS`
  when that status is 0. The command is the one given with `--test`; when none is given, the one
  `test-command.sh` prints.
- **REQ-14.** If no `--test` is given and there is no record, then step 2's result shall be
  `FAIL — no test command known`, and no command shall be run for it.
- **REQ-15.** Step 3's block shall hold `git grep -n --untracked '^- \[ \]'` on the spec's
  `tasks.md`, `PASS` when no line is found.
- **REQ-16.** Step 5's block shall list the migration files in `git diff --name-only <base>...HEAD`:
  `PASS` when there is none, `NEEDS-READING` when there is one or more.
- **REQ-17.** Step 7's block shall hold the output of `git status --porcelain` as it was before
  any other step's command ran, `PASS` when it is empty apart from a report for the same slug
  under `.shipkit/releases/`.
- **REQ-18.** Step 8's block shall hold `decision-check.sh . --run` and its output, `FAIL` when a
  line of that output starts `FIRED`.
- **REQ-19.** `ship-check.sh` shall exit 1 when any block's result is `FAIL`, and 0 otherwise.
- **REQ-20.** While two runs of `ship-check.sh` are in progress in one project, each shall have a
  scratch directory of its own.
- **REQ-21.** When `ship-check.sh --clean <dir>` is run on a scratch directory, it shall remove
  that directory and exit 0.
- **REQ-22.** If `<dir>` is not a scratch directory, then `ship-check.sh --clean <dir>` shall
  remove nothing and exit 1.
- **REQ-23.** `ship-check.sh` shall start no `claude` process.

A `READY` report is tied to a commit:

- **REQ-24.** Where a shipped spec has no `READY` report, `release-check.sh <project>` shall print
  `NO-REPORT <slug>`.
- **REQ-25.** Where the commit of a shipped spec's newest `READY` report is not an ancestor of
  `HEAD`, `release-check.sh` shall print `ORPHAN-REPORT <slug>`.
- **REQ-26.** Where `n` commits, one or more, touch a shipped spec's `Paths` after its newest
  `READY` report's commit and before its shipping commit, `release-check.sh` shall print
  `CHANGED-AFTER-GATE <slug> <n>`. The shipping commit itself is not counted. (Amended
  2026-11-18 on the owner's yes: it read "up to its shipping commit", and on this repository's
  first reading all seven lines it printed were the shipping commit adding its own report or a
  version bump.)
- **REQ-27.** While a shipped spec has no `> Paths:` line, `release-check.sh` shall print no
  `CHANGED-AFTER-GATE` line for it.
- **REQ-28.** `release-check.sh` shall print, as its last line, `release-check: <s> shipped
  spec(s), <f> finding(s)`.
- **REQ-29.** When run without `--enforce`, `release-check.sh` shall exit 0 whatever it prints.
- **REQ-30.** When run with `--enforce`, `release-check.sh` shall exit 1 if it printed a finding.
- **REQ-31.** The repository's CI shall run `release-check.sh .` on every pull request, with the
  full history fetched.

A change does not judge itself:

- **REQ-32.** When `scripts/judge.sh <slug> <base>` is run without `--yes`, it shall print the
  last tag and the command it would run, start no `claude` process and make no worktree.
- **REQ-33.** When run with `--yes`, `judge.sh` shall make a worktree of the last tag in a new
  temporary directory and start `claude` with the plugin loaded from that worktree.
- **REQ-34.** When the command `judge.sh --yes` started has ended, whatever its exit status,
  `judge.sh` shall remove the worktree it made.
- **REQ-35.** `judge.sh` shall remove no worktree it did not make.
- **REQ-36.** The repository's CI shall run the last tag's `spec-check.sh` on the pull request's
  tree beside the branch's own, and shall fail when either exits non-zero.
- **REQ-37.** `.shipkit/decisions/0007-a-change-does-not-judge-itself.md` shall hold the five
  parts of a decision record, with an event as its reversal condition. [untested: prose, verified
  by reading]

Waiting for Sprint 35 (each changes what a model reads, or needs a paid run):

- **REQ-38.** The ship skill shall run `ship-check.sh` for the command steps and step 5's list,
  and shall build its report's blocks for those steps by pasting them from `evidence.md`.
- **REQ-39.** In a ship report, the block of each command step shall equal the block
  `ship-check.sh` writes for the same tree.
- **REQ-40.** When the spec skill writes a task's `Done when`, it shall use the command
  `test-command.sh` prints, and shall ask the user once when there is no record. [untested: read
  from the record of Sprint 35's real run]
- **REQ-41.** When setup finishes on a project whose overlays take no `TEST_COMMAND`, or that has
  no overlay, the setup skill shall write the record with `test-command.sh --record`. [untested:
  read from the record of Sprint 35's real run]
- **REQ-42.** When `claude` is started by the command `judge.sh` prints, the plugin root the
  session reports shall be inside the worktree of the last tag. [untested: one paid session in
  Sprint 35, read from its record]
The guide, in this sprint:

- **REQ-43.** `GUIDE.md` shall name `test-command.sh`, `ship-check.sh`, `release-check.sh` and
  `scripts/judge.sh`, and say what each prints. [untested: prose, verified by reading]

## Out of scope

- Any paid model run in this sprint, and any change to an existing skill, agent or rule file
  before Sprint 35 (the plan's rules 33 and 34). REQ-38 to REQ-42 are this spec's, and their tasks
  wait for that sprint.
- Steps 4 and 6 of the gate, and the judgment in step 5 of whether each migration has a rollback.
  They stay the model's.
- Turning `release-check.sh` from observe to enforce in CI.
- A record for a project set up before this change. It has none until setup runs again, and
  `test-command.sh` says so.
- Making the briefing's gap count cheap: the plan's S31-T2.
- A `> Tests:` line on any spec shipped before `honest-evidence`.
- The eval ledger, the flake rule and the cases chosen by a diff: Sprint 31.
