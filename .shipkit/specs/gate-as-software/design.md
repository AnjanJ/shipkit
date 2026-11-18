# Design: gate as software

## Approach

Four new scripts and two small changes carry the work. `test-command.sh` prints the one test
command setup recorded. `ship-check.sh` runs the gate's command steps and writes their evidence.
`release-check.sh` reads shipped specs against their `READY` reports. `scripts/judge.sh` prints,
and on `--yes` runs, this repository's gate from the last tag. The session hook's `> Paths:` trim
is corrected, and the installer writes the record.

Each script is POSIX `sh`, awk and git, and each has smoke checks that need no model. Nothing a
model reads changes in this sprint. Until Sprint 35 the ship skill runs the gate as it does today
and the scripts are run by their checks alone; the text that makes the skills use them is at the
end of this file, word for word (the plan's rules 33 and 34).

`release-check.sh` and CI's second `spec-check` are new checks, so by the plan's rule 29 the first
only prints. The second can fail a pull request from its first day: it runs a script that is
already released, on a tree that script passes today.

## Decision: The gate's command steps are run by a script   (→ REQ-9 to REQ-23, REQ-38, REQ-39)

**Context.** This record replaces "The gate is a skill, not a script"
(`review-and-ship/design.md:78`), which kept every step in the skill and turned down a script for
the mechanical steps with a skill around it. Its reversal condition, a report that records `PASS`
for a step whose evidence is missing or does not match a re-run, has not fired: nothing in
`docs/design/`, `.shipkit/releases/`, `ROADMAP.md` or `CHANGELOG.md` records one (searched
2026-11-18). The owner chose to replace it all the same, on 2026-11-18, for what the runs since
have shown. The skill spends a page telling the model how not to misreport an exit code
(`ship/SKILL.md`, "Notes on the steps"). On the 5.2 run the gate ran the failing test command
first on both days (`field-notes-5.2.md` §9.1). At 5.3.0 a second gate removed the first one's
scratch files, because both use the same file names. Five of the eight steps are commands with
an exit status.

**Alternatives.**
1. `ship-check.sh` runs steps 1, 2, 3, 7 and 8 and lists step 5's migration files. The skill
   keeps step 4 (the reviewer), step 6 and the judgment in step 5, and pastes the script's blocks
   into the report.
2. Leave the skill as it is.
3. A script that runs the whole gate and starts the reviewer itself with a headless `claude`.

**Case for (1).** A command step's result comes from an exit status and no model touches it, so
it cannot be skipped, paraphrased or typed from memory. The steps cost no tokens. One script owns
the scratch directory and the test command. And the steps can be tested without a model, which
the skill's instructions cannot.

**Case against (1).** Until Sprint 35 the steps are written in two places, the skill and the
script, and can drift; the comparison that holds them together (REQ-39) waits for that sprint.
The script cannot ask for a test command, so a project with no record fails step 2 where the
skill would have asked. (2) keeps one place and keeps every risk above. (3) would start an agent
from outside the main session, against decision 0006, and every run of it would be paid.

**Decision.** We chose (1), the owner's yes of 2026-11-18.
**Falsifiability.** We would return the command steps to the skill if, on two real runs, a
report has to record a command step's result against the script's own `result:` line because
the script was wrong for that project.
**Fired-if.** manual

## Decision: The record sits beside the manifest, not in it   (→ REQ-2, REQ-3, REQ-4, REQ-8)

**Context.** The plan put the record in the installation manifest so that removal takes it out.
The manifest holds each file's digest as installed (`lib-manifest.sh`, header). Removal keeps an
owned file whose content changed unless `--force` is given, and the session hook reads a missing
owned file as an incomplete install. The record changes for good reasons: a second overlay's
install, `--record`, a hand correction. `setup-files.sh`'s record already sits beside the
manifest, outside it, and removal deletes it by name when the manifest goes
(`unsetup-remove.sh:146-148`, `gate-on-setup/REQ-12`).

**Alternatives.**
1. `.claude/rules/shipkit/.test-command`, beside the manifest and outside it. Removal deletes it
   by name where it deletes `.setup-files`.
2. The same file, listed in the manifest.
3. A `test=` line in the manifest's header.
4. A marked line in `CLAUDE.md` that the script reads.

**Case for (1).** Rewriting the record is never read as drift or as an incomplete install, and
removing it never depends on `--force`. It is the pattern `.setup-files` set, in the same folder.
The file is not Markdown, so Claude Code does not load it as a rule and rule 34 is kept.

**Case against (1).** Removal now knows two files by name, and a third would make that a list
worth generalising. (2) is the plan's wording and breaks the first time the record is rewritten.
(3) puts a value that changes into a header three scripts parse. (4) is what the plan's V6, the
test command, turned down: nothing reads `CLAUDE.md` for the command.

**Decision.** We chose (1).
**Falsifiability.** We would move the record into the manifest if a user reports a
`.test-command` file left behind after `/shipkit:setup remove`.
**Fired-if.** manual

## Decision: Each run of `ship-check.sh` has a scratch directory of its own   (→ REQ-9, REQ-20, REQ-21, REQ-22)

**Context.** The gate writes four files with fixed names under `${TMPDIR:-/tmp}` and ends with
`rm -f "${TMPDIR:-/tmp}"/shipkit-ship-*.out` (`ship/SKILL.md`, "The report"). Two gates at once
share those names: at 5.3.0 smoke check 29's nested gate removed the outer gate's files, and
pull request 34 gave that check a `TMPDIR` of its own. The ROADMAP carries "two gates share one
scratch path" as open.

**Alternatives.**
1. `mktemp -d "${TMPDIR:-/tmp}/shipkit-ship.XXXXXX"`, its path printed first. `--clean` removes
   a directory only when its name fits that template and its `evidence.md` starts with the
   script's own first line.
2. Fixed names with the slug in them.
3. A folder under `.shipkit/` in the project.

**Case for (1).** Two gates cannot collide, even on one slug in two worktrees, and clean-up
cannot remove a path the script did not make.

**Case against (1).** The model has to carry a path from the script's first line to the
reviewer's file and to `--clean`, which is a new place to slip, and a run that dies leaves a
directory behind. (2) still collides for one slug in two worktrees. (3) dirties the tree that
step 7 reads.

**Decision.** We chose (1).
**Falsifiability.** We would take (2) if, in two gates, the model writes the reviewer's reply
outside the directory the script printed.
**Fired-if.** manual

## Decision: `release-check.sh` counts until the shipping commit, and only prints   (→ REQ-24 to REQ-31)

**Context.** A `READY` report names the commit it checked and nothing reads that again, so work
can land after the gate and before the spec is called shipped. This repository has 31 shipped
specs and 26 reports; the specs that predate the gate (3.5.0) have none. The plan's rule 29 says
a new check starts by printing what it would have failed.

**Alternatives.**
1. Count the commits that touch the spec's `Paths` after the report's commit and before the
   shipping commit. Print findings and exit 0; `--enforce` exits 1. CI runs it without
   `--enforce`.
2. The same count, failing CI from the first day.
3. Count up to `HEAD`.

**Case for (1).** The first run reads 31 specs' history that nobody has read this way; failing
on it would turn every pull request red for the past. The count stops where the spec was called
shipped, so a later sprint that touches the same files is not counted against it. The shipping
commit itself is left out: it adds the report and bumps versions, which are the release
routine. On the first reading, 2026-11-18, counting it gave seven lines on this repository and
leaving it out gave none.

**Case against (1).** A printed line can be ignored, and a finding in CI's log is not red. (2)
has teeth and no first reading behind it. (3) would grow for ever: `scripts/smoke.sh` is in most
specs' `Paths`. Leaving the shipping commit out means code put into that commit is not counted;
the owner reads that commit when saying yes to `shipped`.

**Decision.** We chose (1).
**Falsifiability.** We would pass `--enforce` in CI once the script has run at two releases with
every finding it printed explained in the release's record. We would drop the count if its first
reading of this repository prints `CHANGED-AFTER-GATE` for more than half of the shipped specs
that have a report: it would then be measuring the release routine and not late work.
**Fired-if.** manual

## Decision: The last tag judges this repository's gates   (→ REQ-32 to REQ-37, REQ-42)

This is the draft of `.shipkit/decisions/0007-a-change-does-not-judge-itself.md`; the task for
REQ-37 writes it out there, because it binds every later spec of this repository.

**Context.** A branch that changes `ship/SKILL.md`, `reviewer.md` or `spec-check.sh` has been
gated by its own copies of them: the 5.1.0 and 5.2.0 release gates ran with `--plugin-dir` at the
checkout (`docs/design/eval-history.md`, "Release run 5.1.0" and "Release run 5.2.0"), and CI
runs the branch's `spec-check.sh` on the branch. A branch that weakened the gate would have been
judged by the weakened gate. The plan's rule 28 and its V9, who judges this repository's gates,
settled the answer with the owner on 2026-11-17.

**Alternatives.**
1. The last tagged release judges: its skill, its reviewer, its scripts, loaded from a worktree
   of the tag. The checkout's own gate runs as well, as a test of the new gate, and both results
   are recorded.
2. The checkout judges itself, as today.
3. The tip of `main` judges.

**Case for (1).** A branch cannot edit a tag, and a tag is what users run.

**Case against (1).** The tag does not know what has been added since: a line it cannot read
may fail a good spec, and a check that is new on the branch is not applied by the judge at all.
(3) moves with every merge, so a weakening that got merged judges the next branch.

**Decision.** We chose (1).
**Falsifiability.** We would make the tip of `main` the judge if the last tag's gate fails a
spec at two releases running for a reason that is only the tag's age, such as a line it cannot
read.
**Fired-if.** manual

## Data / interface changes

`plugins/shipkit/scripts/session-start.sh` (REQ-1). Line 275 trims each `> Paths:` entry with
`[[:space:]]` in place of `[ \t]`, as `spec-check.sh` reads its `> Tests:` line. BSD sed reads
`[ \t]` as a space, a backslash or the letter t.

`plugins/shipkit/scripts/test-command.sh` (REQ-5 to REQ-8), new:

- `test-command.sh <project>` prints the record's first line and exits 0. No record, or an empty
  one: the message of REQ-6 on standard error, exit 1.
- `test-command.sh <project> --record '<command>'` makes `.claude/rules/shipkit/` if it is not
  there, writes the one line and exits 0. An empty command, or one that holds a newline: usage on
  standard error, exit 2, nothing written.
- Any other form: usage, exit 2.

`plugins/shipkit/scripts/install-stack.sh` (REQ-2, REQ-3). It remembers the value of a
`TEST_COMMAND=` argument. After the overlay's files are written and the manifest is updated, and
only when that value is not empty, it runs `test-command.sh <project> --record '<value>'`. An
install that exits non-zero has not reached that line.

`plugins/shipkit/scripts/unsetup-remove.sh` (REQ-4). Where it removes `.setup-files`, it removes
`.test-command` as well.

`plugins/shipkit/scripts/ship-check.sh` (REQ-9 to REQ-23), new:

- `ship-check.sh <project> <slug> [base] [--test '<command>']`. No `base`: the merge base of
  `HEAD` and the default branch. Usage error: exit 2. No such spec: REQ-10.
- Standard output: the scratch directory's path, then one line for each step, `<n> <result>`,
  in the order 1, 2, 3, 5, 7, 8. Everything else goes to `<scratch>/evidence.md`.
- `evidence.md`'s first line is `shipkit ship-check: <slug> at <short sha> against <short base>`.
  `--clean` looks for the words `shipkit ship-check: ` at its start.
- A block is written as the ship report already writes a step:

  ```markdown
  ### 2. Tests
  `MIX_ENV=test mise exec -- mix test` → exit 0
  <the last twenty lines of the command's output>
  result: PASS — exit 0
  ```

  The step names are the report's: "Spec check, as shipped", "Tests", "Tasks ticked", "Migration
  rollback", "Clean tree", "Decisions fired". The plugin's location is written `<plugin root>`
  in a command, never as a path, since the report is committed.
- Step 1's block has two more parts under its result line: `evidence: ` followed by
  `spec-check`'s `EVIDENCE` line, so that it is there even when twenty lines do not reach it;
  and `Requirements changed on this branch:` followed by every line `spec-diff.sh . <slug>
  <base>` printed, or `none`. Step 1's result is `spec-check`'s exit status alone.
- Step 2 runs the command in a subshell from the project's root, once, with its output in
  `<scratch>/tests.out`.
- Step 5 has no command of the project's to run. Its block's command is the `git diff
  --name-only <base>...HEAD` it read, and its lines are the migration files, or `no migration in
  the diff`.
- Step 7's capture is taken before step 1 runs. A line of it is set aside when it names a file
  `.shipkit/releases/<date>-<slug>.md`; any other line makes the result `FAIL`. Files that
  appeared during step 2 are listed under the block as a note and change nothing.
- Step 8's output goes to `<scratch>/decisions.out`; `MANUAL` and `ERROR` lines are in the block
  and do not fail it.
- `ship-check.sh --clean <dir>` is REQ-21 and REQ-22.

`plugins/shipkit/scripts/release-check.sh` (REQ-24 to REQ-30), new:

- `release-check.sh <project> [--enforce]`. It reads every `.shipkit/specs/*/spec.md` with
  `> Status: shipped`, in name order.
- A report's commit is read from its `> Checked on <date> at commit` line, between the first
  pair of backticks, and resolved with `git rev-parse --verify`. A report whose commit cannot be
  resolved is an `ORPHAN-REPORT`.
- The shipping commit is the oldest commit that `git log -G'^> Status: shipped'` lists for the
  spec's `spec.md`.
- The count of REQ-26 is `git rev-list --count <report's commit>..<shipping commit>^ -- <paths>`:
  the shipping commit itself is not counted. A shipping commit that is not after the report's
  commit gives 0 and no line.
- Findings are printed in the order `NO-REPORT`, `ORPHAN-REPORT`, `CHANGED-AFTER-GATE` for each
  spec, then the summary line of REQ-28.

`scripts/judge.sh` (REQ-32 to REQ-35), new:

- `judge.sh <slug> <base> [--test '<command>'] [--yes]`, run from this repository's root.
- Without `--yes` it prints `judge: the last tag is <tag>` and the command, with `<worktree>` in
  place of a path, and exits 0.
- The command is the one the release gates have used, with the plugin taken from the tag:
  `claude --plugin-dir <worktree>/plugins/shipkit --model sonnet --allowedTools Read Glob Grep
  Bash Write Skill Agent -p "/shipkit:ship <slug> <base>"`, followed in the same prompt by "This
  run is not interactive and you cannot ask me anything. Do not change the spec's Status line."
  and, when `--test` is given, "The project's test command is: <command>". Standard input is
  `/dev/null`.
- With `--yes` it makes a directory with `mktemp -d`, adds a detached worktree of the tag inside
  it with `git worktree add --detach`, runs the command from this repository's root, then removes
  that worktree with `git worktree remove --force` and the directory, and exits with the
  command's status. A trap does the same removal when the script is interrupted.
- It removes only the worktree whose path it made in that run.

`.github/workflows/lint.yml` (REQ-31, REQ-36). The `lint` job fetches the full history and gains
two steps: `sh plugins/shipkit/scripts/release-check.sh .`, and the last tag's `spec-check.sh`,
taken with `git show <tag>:plugins/shipkit/scripts/spec-check.sh` into a temporary file and run
on the tree. The branch's own `spec-check` step stays; the job fails when either exits non-zero.

`.shipkit/specs/review-and-ship/design.md`. Under the heading of "The gate is a skill, not a
script", one line is added: it is marked as replaced by this file's first record, with the date.
Nothing else in that file changes.

## Text that waits for Sprint 35

By the plan's rule 34 these are applied after the baseline, not before. `honest-evidence` holds
text for the same two ship files; where the two meet, Sprint 35 applies them together.

**`plugins/shipkit/skills/ship/SKILL.md`** (REQ-38). "Before step 1" becomes:

> Run `sh "<plugin root>/scripts/ship-check.sh" . <slug> <base>` once, adding `--test
> '<command>'` only when the user gave a test command. Its first line is the scratch directory;
> keep it, every later path is inside it. The script runs steps 1, 2, 3, 7 and 8 and lists step
> 5's migration files, and writes a block for each to `evidence.md` there. Do not run those
> commands yourself and do not retype a block.

In the table, the "How" of steps 1, 2, 3, 7 and 8 becomes "`ship-check.sh`'s block, read from
`evidence.md`", and "PASS means" becomes "its `result:` line says `PASS`". Step 5's "How" becomes
"`ship-check.sh`'s list; for each file it names, is the way to roll it back written down?" Step
4 writes the reviewer's reply to `review.out` in the scratch directory.

The notes "Exit codes and output" and "Step 2 — the test command" are replaced by one: "A
command step's result is the script's `result:` line. If it reads `FAIL — no test command known`,
ask the user for the command once and run the script again with `--test`; if no user is present,
the step stays `FAIL`."

In "The report", "Then remove the scratch files this run wrote" becomes "Then run `sh "<plugin
root>/scripts/ship-check.sh" --clean <the scratch directory>`", and the evidence for steps 1, 2,
3, 5, 7 and 8 is "each block pasted whole from `evidence.md`".

**`plugins/shipkit/skills/ship/reference.md`** (REQ-38). In the template, each of the blocks 1,
2, 3, 5, 7 and 8 ends with its `result:` line. One rule replaces "Every `→ exit N` is the number
the command's own `echo "exit $?"` printed": "The blocks of steps 1, 2, 3, 5, 7 and 8 are pasted
from `ship-check.sh`'s `evidence.md`, whole and unchanged."

**`scripts/smoke.sh`, check 29** (REQ-39). After the gate's run, the check runs `ship-check.sh`
on the same fixture at the same commit, and fails unless each of the blocks 1, 2, 3, 7 and 8 in
the model's report is found, line for line, in the script's `evidence.md`.

**`plugins/shipkit/skills/spec/SKILL.md`** (REQ-40). Q3, step 2, gains: "The command in each
`Done when` is the one `sh "<plugin root>/scripts/test-command.sh" .` prints. If it exits 1, ask
the user for the test command once, and write that."

**`plugins/shipkit/skills/setup/SKILL.md`** (REQ-41). After the installer's step: "If no overlay
was installed, or none of the installed ones takes `TEST_COMMAND`, record the detected command
yourself: `sh "<root>/scripts/test-command.sh" . --record '<the test command>'`."

**`GUIDE.md`** (REQ-43) names the four scripts where the guide already speaks of the gate, of
setup and of releasing shipkit itself. This is prose a person reads, so it lands with the scripts
in this sprint.
