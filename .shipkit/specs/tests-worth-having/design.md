# Design: tests worth having

## Approach

Three scripts are built and one gains a line. None starts a model.

1. **`scripts/kind-probe.sh`,** a probe outside the eval suite. It writes two fixtures, prints
   the headless commands that Sprint 35 will run, and reads what those runs leave: a task list
   for the kinds fixture, a plan for the migration fixture. Its readers are tested on eight
   files written by hand under `scripts/kind-replies/`.
2. **`scripts/prop.py`,** five properties of `spec-check.sh` and `brief.sh`, checked on inputs
   Hypothesis generates, with the same inputs on every run. Both CI jobs run it.
3. **`plugins/shipkit/scripts/red-check.sh`,** which runs a project's suite on a scratch tree
   of the base ref, first as the base has it and then with the branch's citing test files
   copied in, and says whether those tests fail without the feature.
4. **`ship-check.sh`** ends `evidence.md` with one line that names the `red-check.sh` command.

Nothing in `plugins/*/skills`, `plugins/*/agents` or `plugins/*/rules` changes. The text those
files may gain is under "The waiting text" below, word for word. Sprint 35 measures first and
applies a line only where the measurement shows a miss (REQ-48, REQ-49).

Labels from `docs/plans/verifier-sprint-plan.md` used below: V16 is its decision on test kinds
("measure first"), V17 its decision on the property-test library, V18 its decision that red at
base is a script run by hand. Rule 29 is "a new check starts in observe mode", rule 33 "paid
steps come last", rule 34 "what a model reads changes only after its baseline".

## Decision: Measure first, with a probe outside the suite   (→ REQ-1 to REQ-14, REQ-45, REQ-48)

This is the record for V16, test kinds.

**Context.** No file in either plugin names a property test, a differential test or an
end-to-end test (`git grep` over `plugins/`, 2026-11-20); `spec/SKILL.md:98-99` says
"behavior-focused". Every rule line since 4.2.0 went in with a number behind it. The evals
folder is at 204,629 of 204,800 bytes, so a new eval case does not fit.

**Alternatives.**
1. A probe under `scripts/`, like `scripts/wait-probe.sh`: a fixture, the commands, a reader.
   The text waits in this file until five runs show which kind the model misses.
2. Add the table to `spec/reference.md` now, unmeasured (V16's other option).
3. Three eval cases in the suite, one for each kind.

**Case for (1).** It costs no byte of the evals folder and nothing until Sprint 35. Text goes
in for a kind only when the model misses that kind, so `reference.md` grows by what is needed.

**Case against (1).** Five runs is a small sample, and a probe outside the suite is not run at
a release unless someone runs it. (2) is the quickest and nobody would know whether it changed
anything. (3) needs about 3,000 bytes the folder does not have.

**Decision.** We chose (1).
**Falsifiability.** We would add the table unmeasured, as (2), if fewer than 4 of the 5
baseline runs in Sprint 35 leave a `tasks.md` that `--read` can read.
**Fired-if.** manual

## Decision: The reader goes by a tag, then by a short list of words   (→ REQ-7 to REQ-14, REQ-18)

**Context.** The reader has to say which kind a `Test:` line names. No script reads the text of
a `Test:` line today: `spec-check.sh:123` notes only that the line exists and `brief.sh:154`
prints it as written. So a tag changes no other script's output.

**Alternatives.**
1. A tag at the start of the line settles it. Without a tag, a kind is named when the line
   holds one of that kind's words ("The reader's words" below).
2. A model judges each line.
3. Tags only: a line with no tag names nothing.

**Case for (1).** It runs in the smoke suite for nothing, gives the same answer twice, and the
word list is short enough to read. A baseline run has no tag to find, since the skill does not
know the tag yet, so (3) would read every baseline as `none`.

**Case against (1).** A word list misses a kind said in other words, and takes a word used in
passing as naming a kind. A line that names a test function and nothing else reads `none`,
which is what the probe is meant to count. (2) costs money on every read and can differ
between two reads.

**Decision.** We chose (1).
**Falsifiability.** We would replace the word list if, on the fifteen lines `--read` prints for
the five baseline task lists in Sprint 35, its fourth field differs from the owner's reading
on 2 or more.
**Fired-if.** manual

## Decision: One fixture holds the three requirements   (→ REQ-1, REQ-2, REQ-5)

**Context.** The plan asks for "three requirements, one per kind" and for five runs. Its budget
line counts "three test-kind probes × 5", which is fifteen runs.

**Alternatives.**
1. One project, one spec, three requirements. A run writes one `tasks.md`, and `--read` prints
   three lines for it. Five runs give fifteen readings.
2. Three projects with one requirement each, five runs of each.

**Case for (1).** A third of the paid runs for the same number of readings, and it is how a real
spec looks: several requirements of different shapes in one task list.

**Case against (1).** The three readings of one run are not independent. A model that names the
kind on one task is likely to name it on the next. (2) keeps them apart and costs three times
as much.

**Decision.** We chose (1).
**Falsifiability.** We would split the fixture in three, as (2), if in all 5 baseline runs the
three requirements read alike: all three `right`, or all three `missed`.
**Fired-if.** manual

## Decision: The migration fixture carries both versions and the changelog   (→ REQ-15 to REQ-17)

**Context.** The migration skill's first step reads the changelog with WebFetch
(`plugins/shipkit-workflows/skills/migration-plan/SKILL.md`, "Step 1"). The probe asks one
thing of the plan: does it hold a differential step.

**Alternatives.**
1. A made-up library kept in the fixture at two major versions, with its changelog beside it.
   The request names the changelog's path.
2. A real library and a real upgrade, read from the web.

**Case for (1).** Three runs before and three after read the same changelog, whenever they
run. The old and the new version are both in the tree, so a differential step is something
the plan can really ask for.

**Case against (1).** The skill says to fetch; a run may try the web for a library that does
not exist and lose a turn, or say it could not find it. A real upgrade is closer to what the
owner will do. (2) changes under the probe between the before and the after runs.

**Decision.** We chose (1).
**Falsifiability.** We would move to a real library, as (2), if 2 or more of the 3 baseline
runs end without a plan, or with a plan that says the changelog could not be read.
**Fired-if.** manual

## Decision: Hypothesis, at one version, with the same inputs on every run   (→ REQ-21 to REQ-30)

This is the record for V17, the property-test library.

**Context.** `spec-check.sh` and `brief.sh` each parse `tasks.md` with their own awk
(`spec-check.sh:110-160`, `brief.sh:36-83`), and every smoke check feeds them inputs a person
thought of. Checked on 2026-11-20: `uv run --with hypothesis` installs Hypothesis 6.170.16 and
runs it, on the Python that `uv` picks (3.14.8 here; `python3` here is 3.15.2 and cannot import
it). CI pins Python 3.12 and installs with `pip`. Hypothesis's own text for its `derandomize`
setting: "every run will test the same set of test cases until you update Hypothesis, Python,
or the test function". Without `database=None` it writes `.hypothesis/examples` in the working
directory. One run of `spec-check.sh` takes about 37 ms and one of `brief.sh` about 46 ms on a
small project, and both read a project that is not a git repository.

**Alternatives.**
1. Hypothesis pinned to `6.170.16`, with `derandomize=True`, `database=None` and no deadline.
   `prop.py` holds the version in one constant; CI's `pip` line and the hint of REQ-29 name it.
2. Hypothesis at whatever version is newest on the day.
3. A seeded generator on the standard library (V17's other option).

**Case for (1).** It shrinks a failing input to a small one, which a hand-written generator
does not. With the pin, a job that passed yesterday tries the same inputs today, so a red run
means the scripts changed.

**Case against (1).** One more thing to install in two CI jobs, and `python3 scripts/prop.py`
does not run on this machine without `uv`. The pin has to be moved by hand, and each move
changes the inputs. This machine and CI run different Pythons, so they try different inputs:
a failure on CI is repeated from the input it prints, not by running here. (2) can turn a pull
request red because of a release on PyPI. (3) installs nothing and finds less.

**Decision.** We chose (1).
**Falsifiability.** We would move to (3) if `pip install hypothesis==6.170.16` fails in either
CI job, or the step that runs `prop.py` takes more than 120 seconds there in two runs running.
**Fired-if.** manual

## Decision: The properties run in both CI jobs   (→ REQ-31)

**Context.** CI has two jobs: `lint` on `ubuntu-latest` and `smoke-no-model` on `macos-latest`
(`.github/workflows/lint.yml:19`, `:64`). The properties are about two awk programs, and the two
runners do not ship the same awk. `lint` already runs `spec-check.sh` on this repository's
specs. The repository is public, so the minutes cost nothing.

**Alternatives.**
1. Both jobs.
2. `smoke-no-model` only, the runner the smoke suite assumes.
3. `lint` only.

**Case for (1).** Users run these scripts on both systems. A parser that reads one input two
ways on two awks is the kind of fault generated inputs are for.

**Case against (1).** A failure on one runner only cannot be repeated on this machine. It may
ask for a change to a shipped script for an awk the owner does not use. (2) tests what the
owner runs; (3) is the cheaper runner.

**Decision.** We chose (1) (the owner, 2026-11-20). A property that fails on one runner only is
put to the owner before any fix.
**Falsifiability.** We would take the step out of one job if a property fails there only and
the owner rules the fix out of this plan; the record then names the awk and the input.
**Fired-if.** manual

## Decision: Agreement is read from `CONFLICT` lines, with no new mode   (→ REQ-21)

**Context.** The plan asks that the two parsers "agree on every task's id and files".
`brief.sh` prints a task's files under "You may edit". `spec-check.sh` prints findings only:
its modes are a slug, `--as-shipped` and `--as-open` (`spec-check.sh:5`), and no line lists a
task. It does name two ids and a file in each `CONFLICT` line, one for each two tasks that
list one file where the later does not come after the earlier (`spec-check.sh:147-156`).

**Alternatives.**
1. Generate task lists in which no task names another on its `After` line. Then every file two
   tasks share is a `CONFLICT` line. The generator ends each list with a task that lists every
   file of the list, so every task's every file is shared and is seen.
2. A new mode in `spec-check.sh` that prints each task's id and files.
3. A third parser in `prop.py`, with each script compared against it.

**Case for (1).** No shipped script changes, so smoke check 112, which holds `spec-check.sh`'s
output to its copy at `398d1c9`, is not touched. What is compared is what users see.

**Case against (1).** It is indirect: a fault in how `After` is read is not looked for, since
no generated task has one. (2) is direct and adds a flag that only a test uses. (3) is a third
reading of the format that can be wrong in its own way.

**Decision.** We chose (1).
**Falsifiability.** We would add (2) if a difference between the two parsers' ids or files is
found by other means, a smoke check or an escape record, on an input this generator can make.
**Fired-if.** manual

## Decision: `red-check.sh` is run by hand, and every verdict exits 0   (→ REQ-32 to REQ-42, REQ-50)

This is the record for V18, red at base.

**Context.** Nothing shows that a new test was ever red. The default workflow says "test
before code" and the gate takes it on trust. A test that passes on the tree without the
feature proves nothing about the feature. Rule 29 says a new check prints and changes no
verdict until a real run has read it.

**Alternatives.**
1. A script a person runs. It prints a verdict word and exits 0 whichever it is.
   `ship-check.sh` names the command and does not run it.
2. A step of the gate now (V18's other option).
3. Exit 1 on `GREEN-AT-BASE`.

**Case for (1).** Its first reading on a real project is Sprint 35's. Until then nobody knows
how long a second run of a real suite takes, or how often a base tree cannot run at all.

**Case against (1).** A check nobody is made to run is run rarely. (2) and (3) would fail
gates on a verdict that no real project has yet shown to be right.

**Decision.** We chose (1).
**Falsifiability.** It becomes an observed step of `ship-check.sh` when the run on the clone of
the owner's project in Sprint 35 gives the right verdict in under five minutes.
**Fired-if.** manual

## Decision: The base tree is a detached worktree in a directory of its own   (→ REQ-34, REQ-39, REQ-40)

**Context.** The suite has to run on the base ref's files without touching the project's
working tree. `scripts/judge.sh:55-71` already does this for the last tag: `mktemp -d` with a
template, `git worktree add --detach` inside it, and one function that removes the worktree
and the directory. No script under `plugins/` uses a worktree today.

**Alternatives.**
1. `mktemp -d "${TMPDIR:-/tmp}/shipkit-red.XXXXXX"`, the worktree at `tree` inside it, removed
   by a function set on `EXIT`, with `INT`, `TERM` and `HUP` leading to it.
2. `git archive <base> | tar -x` into the directory: no worktree at all.
3. Check the base out in the project's own tree, behind a stash.

**Case for (1).** The scratch tree is a git checkout, so a suite that asks git a question still
works, and the project's files, index and stash are never written. Lint rejects a bare `mktemp`
in `plugins/shipkit/scripts/` (`scripts/lint.py:527-532`), which the template answers.

**Case against (1).** While it runs, `git worktree list` in the project shows one more line. A
kill that cannot be caught leaves the directory and a `prunable` entry behind. (2) leaves
nothing in git and gives the suite a tree that is not a repository. (3) puts the owner's
uncommitted work at risk, which REQ-40 forbids.

**Decision.** We chose (1). The test command runs as a child that the script waits for, so a
signal reaches the script while the suite is running; the script then stops the child and
removes what it made.
**Falsifiability.** We would move to (2) if a run of `red-check.sh` that ended on a signal it
can catch leaves a line in `git worktree list`.
**Fired-if.** manual

## Decision: One run of the suite with all the listed files   (→ REQ-35)

**Context.** The plan has the script copy the listed test files in and run the suite again,
once. The test command is one line for the whole suite (`test-command.sh`).

**Alternatives.**
1. One run with every listed file. `RED-AT-BASE` when it fails, `GREEN-AT-BASE` with the files
   when it passes.
2. One run for each listed file, copied in alone.
3. Read each test's own result from the runner's output.

**Case for (1).** Two runs of the suite in all, whatever the number of files. No knowledge of
any test runner.

**Case against (1).** `RED-AT-BASE` means that at least one listed file fails without the
feature. A file whose tests all pass at base hides behind one that fails; `GUIDE.md` says so.
(2) answers for each file and costs a suite run for each. (3) needs a reader for every runner.

**Decision.** We chose (1).
**Falsifiability.** We would add (2), as an option, if a reading is `RED-AT-BASE` while one of
its listed files, copied in alone, gives `GREEN-AT-BASE`.
**Fired-if.** manual

## Decision: `red-check.sh` repeats the citation search   (→ REQ-32, REQ-33)

**Context.** Which files count as citing a spec is decided inside `spec-check.sh`: one `git
grep` over the project that leaves out `.shipkit/`, `docs/` and `*.md` and takes untracked
files (`spec-check.sh:188-198`), then a filter to the spec's `> Tests:` paths
(`spec-check.sh:204-213`, `:273-281`). No line it prints lists the files that count:
`CITED-ELSEWHERE` names files that do not, and `SKIPPED-CITE` only those near a skip marker.

**Alternatives.**
1. `red-check.sh` makes the same search with the same three exclusions and the same rule for
   `> Tests:`. A smoke check runs both on one fixture that has a `> Tests:` line and a citation
   outside it, and the file `spec-check.sh` calls `CITED-ELSEWHERE` must not be a `TEST` line.
2. A new line in `spec-check.sh`'s output for each file that counts.
3. Read `spec-check.sh`'s temporary files.

**Case for (1).** No shipped script's output changes. The briefing runs `spec-check.sh` at
every session start, and its 229 commands and its output are both held by smoke checks.

**Case against (1).** The rule now lives in two scripts, and a change to one must be made in
the other. (2) keeps one rule and changes output that check 112 compares byte for byte. (3)
reads files that exist only while the other script runs.

**Decision.** We chose (1).
**Falsifiability.** We would move the search into one file that both scripts read when the
citation rule next changes: a third exclusion, or a second line like `> Tests:`.
**Fired-if.** manual

## Decision: `--link` links a folder, and never copies it   (→ REQ-37, REQ-38)

**Context.** A base tree has no `deps`, `_build` or `node_modules`: they are not tracked. Many
suites cannot start without them, and then every reading is `BASE-NOT-RUNNABLE`.

**Alternatives.**
1. `--link a,b` makes a symbolic link in the scratch tree to each named folder of the project.
   Nothing is linked unless named. A name that is not a folder, or that git tracks at the base
   ref, is refused before anything is made.
2. Copy the named folders.
3. Link nothing; the person installs dependencies in the scratch tree.

**Case for (1).** A link costs nothing, where a copy of `node_modules` can be hundreds of
megabytes on every run. The person names each folder, so nothing is shared by surprise.

**Case against (1).** A suite that writes into a linked folder writes into the project it was
pointed at: a build of the base's code can land in the project's `_build`. That is why the
plan's run uses the clone and never the live checkout, and why `GUIDE.md` says it. Removing
the scratch tree removes the links and leaves what they point to. (2) is safe and slow. (3)
leaves most projects unreadable.

**Decision.** We chose (1).
**Falsifiability.** We would copy, as (2), if one run with `--link` leaves the project it was
pointed at unable to build or to run its tests until the folder is rebuilt.
**Fired-if.** manual

## Decision: The suggestion is the last line of `evidence.md`   (→ REQ-43)

**Context.** The plan says `ship-check.sh` "prints the command as a suggestion". Its standard
output is the scratch path and one line for each step, and smoke check 107 holds the rest of
it to "1 PASS 2 PASS 3 PASS 5 PASS 7 PASS 8 PASS" (`scripts/smoke.sh:3964`). The same check
counts six `### ` headings and six `result: PASS` lines in `evidence.md` and reads nothing from
the file's end. In Sprint 35 the ship skill pastes the blocks from `evidence.md`
(`gate-as-software`, T7). The owner said yes to this sprint on 2026-11-20.

**Alternatives.**
1. One line after the last block of `evidence.md`.
2. One more line on standard output.
3. A line on standard error.

**Case for (1).** It is where the report's text will come from, and no check that reads the
file is changed.

**Case against (1).** Nobody reads `evidence.md` until the ship skill pastes it, which is
Sprint 35's text. (2) breaks check 107 and anything that reads the six lines. (3) is seen by a
person at a terminal and by no report.

**Decision.** We chose (1). The line is `Not run, a suggestion: sh "<plugin
root>/scripts/red-check.sh" . <slug> <base>`, followed by ` --test '<command>'` when
`ship-check.sh` was given one. It is written after step 8's block whatever the results.
**Falsifiability.** We would move the line if a ship report written in Sprint 35 by
`gate-as-software`'s T7 drops it or puts it inside a step's block.
**Fired-if.** manual

## The fixtures

Both are written by `kind-probe.sh --scaffold`, from text inside the script, and end with `git
init`, one commit with a fixed date and author, and a clean tree. Python's standard library is
all they need; the recorded test command is `python3 -m unittest -q` in both.

**The kinds fixture, `passbook`.** A small program that keeps an account, stores statements as
documents and renders them with a parser.

- `passbook/account.py`: an account with a balance and `deposit`. No `withdraw` yet.
- `passbook/statements.py`: `parse_v1`, the parser in use, and `render`, which shows a parsed
  statement. `data/statements/` holds three stored documents.
- `passbook/cli.py` and `passbook/__main__.py`: `python3 -m passbook balance` and `render`.
- `tests/test_account.py`, `tests/test_statements.py`: tests of what exists, all passing.
- `.claude/rules/shipkit/.test-command`: the recorded command.
- `.shipkit/specs/passbook/intake.md`, `spec.md` and `design.md`. The spec carries a stamp,
  `Status: open` and `> Paths: passbook/, tests/`. Its three requirements are: REQ-1, for
  withdrawals, "the balance shall never be negative"; REQ-2, for a new `export` and `import`,
  "an exported file shall import to the same records"; REQ-3, for a new `parse_v2`, "after the
  move to the new parser, every stored document shall render as before". The design has one
  record: `parse_v2` replaces `parse_v1`, which stays in the tree until the move is proven.
  There is no `tasks.md`: writing it is the run.
- The intake is there so that `/shipkit:spec passbook tasks` does not start one
  (`spec/SKILL.md:46-49`).

**The migration fixture, `inkwell`.** A small program that formats notes with a library it
keeps in its own tree.

- `vendor/textkit-1/textkit.py`, version 1.4, and `vendor/textkit-2/textkit.py`, version 2.0.
- `vendor/textkit-2/CHANGELOG.md`. It names two changes from 1.4 to 2.0: `wrap()` now strips
  trailing spaces from each line, and `title()` no longer capitalises a word after an
  apostrophe. `inkwell/format.py` calls both.
- `inkwell/deps.py`: one line that puts `vendor/textkit-1` on the import path.
- `tests/test_format.py`: passing tests on version 1.4.
- `.claude/rules/shipkit/.test-command`. No `.shipkit/specs/`.

**The commands `--run` prints.** One line for each run, of the form `wait-probe.sh:355-357`
uses: the `claude` program, `--plugin-dir` at this checkout's plugin (`plugins/shipkit` for
kinds, `plugins/shipkit-workflows` for migration), `--model sonnet`, `--output-format json`,
and `-p` with the request. The kinds request is `/shipkit:spec passbook tasks` followed by
"This run is not interactive: you cannot ask me anything." The migration request is
`/shipkit-workflows:migration-plan textkit 1.4 2.0`, the changelog's path, and the same
sentence. With `--yes` each run gets a fresh fixture at `<out>/run-<i>/proj`; a kinds run
leaves its `tasks.md` inside it, and a migration run's reply is written to
`<out>/run-<i>/plan.md`. `--out` defaults to a new directory under `TMPDIR`, as in
`wait-probe.sh`. Without `--yes` nothing is made.

## The reader's words

Case does not count. A tag is read first and ends the reading of that line (REQ-9).

| Kind | Words |
|---|---|
| `property` | "property test", "property-based", "property based", "hypothesis", "generated inputs", "generated sequences", "generated records" |
| `e2e` | "end-to-end", "end to end", "e2e", "through the cli", "through the command line", "subprocess" |
| `differential` | "differential", "old and new", "old and the new", "both parsers", "both versions", "golden", "characterization", "characterisation" |

A task cites a requirement when its header line holds `REQ-<n>` after the arrow, as `brief.sh`
reads it. `--read` knows the three requirements and their expected kinds; they are constants
in the script beside the fixture's text.

`--read-plan` reads a plan in blocks, a block being the lines between two blank lines. A plan
holds a differential step when one block holds "differential", "characterization",
"characterisation" or "golden", or holds one of "old and new", "old and the new", "both
versions", "1.4 and 2.0" together with one of "same input", "same inputs", "compare",
"identical".

**The eight files written by hand,** under `scripts/kind-replies/`:

| File | What its `Test:` lines say | `--read` must print |
|---|---|---|
| `property-named/tasks.md` | REQ-1: `[property]`. REQ-2: two tasks, `[e2e]` and `[property]`. REQ-3: `[differential]` | REQ-1 `property` `right`; REQ-2 `e2e+property` `right`; REQ-3 `differential` `right` |
| `property-unnamed/tasks.md` | REQ-1: a test function's name only. REQ-2: "a property test over generated records", no tag. REQ-3: "old and new parser on every stored document" | REQ-1 `none` `missed`; REQ-2 `property` `right` (REQ-14); REQ-3 `differential` `right` |
| `e2e-named/tasks.md` | REQ-2: `[e2e]` and, later in the line, the words "not a property test". REQ-1: "Hypothesis". REQ-3: "golden" | REQ-2 `e2e` `right` (REQ-9); REQ-1 `property` `right`; REQ-3 `differential` `right` |
| `e2e-unnamed/tasks.md` | REQ-2: a test function's name only. REQ-1: `[property]`. REQ-3: `[property]`, the wrong kind | REQ-2 `none` `missed`; REQ-1 `property` `right`; REQ-3 `property` `missed` |
| `differential-named/tasks.md` | REQ-3: "a differential test: both parsers on each stored document". REQ-1, REQ-2: `[property]` | all three `right` |
| `differential-unnamed/tasks.md` | REQ-3: a test function's name only. REQ-2: `[e2e]`. No task cites REQ-1 | REQ-3 `none` `missed`; REQ-2 `e2e` `right`; REQ-1 `uncited` `missed` |
| `plan-differential.md` | a first step that runs 1.4 and 2.0 on the same inputs and compares | `differential` |
| `plan-none.md` | the skill's six steps as it writes them today; "old" and "new" appear in different blocks | `none` |

The `TOTAL` lines over the six task lists are then: REQ-1 `right=4 missed=2`, REQ-2 `right=5
missed=1`, REQ-3 `right=4 missed=2` (REQ-12).

## What `prop.py` generates

- **A slug:** a lower-case letter, then up to eleven of lower-case letters, digits and `-`.
- **A spec:** a title, a stamp, a `> Status:` line (`open` or `shipped`, as the property needs),
  a Purpose, and one to six requirements numbered from 1. A requirement is `- **REQ-N.**` and
  one to three lines of text; later lines are indented two spaces. With chance, a requirement
  ends with `[untested: <reason>]`. Requirements follow one another directly, or with a blank
  line or a `###` heading between them. Text is drawn from letters, digits, spaces and
  ``.,;:'"()[]{}<>/\|!?*_`~@#$%^&=+-``, and from "é", "ß" and "→". It never holds `**REQ-`,
  `[untested:` or a slash followed by `REQ-`, and no line of it starts with `#`.
- **A task list:** one to five tasks `T1` to `T5`, each with a title, an arrow, one or more
  `REQ-N` of the spec, and the four sub-lines. `Files` holds one to three names drawn from a
  pool of six, each a path of letters, digits and `._/-`, written plain or inside backticks,
  and no name twice in one task. `After` is `none`. `Test` and `Done when` are text as above.
  For REQ-21 a last task lists every name the others list.
- **Citations:** lines `# <slug>/REQ-N` in `tests/test_gen.py`.
- **Sizes:** 40 inputs for each property; `--max-examples <n>` changes it. Each input is written
  to a fresh directory under one `tempfile.TemporaryDirectory`, which is all `prop.py` writes
  (REQ-30). The projects are not git repositories.

**The five properties,** by the names `prop.py` prints: `agreement` (REQ-21), `no-side-effect`
(REQ-22), `monotone` (REQ-23), `exactly-one` (REQ-24), `round-trip` (REQ-25). Each is one
function that cites its requirement as `tests-worth-having/REQ-<n>` in a comment.

**How it is run.** `prop.py [--only <name>] [--max-examples <n>] [--no-shrink] [--spec-check
<path>] [--brief <path>]`. The two paths default to this checkout's scripts. It prints `PASS
<name>` or `FAIL <name>` for each property, and after a `FAIL` the files of the failing input,
then one last line with the count that hold and the versions of Hypothesis and Python. Exit 0
when all hold, 1 when one fails, 2 when Hypothesis cannot be imported or the arguments are
wrong.

**How each property is shown to fail (REQ-28).** The smoke check makes a broken copy of one
script with `sed`, checks with `cmp` that the copy differs from the script, and runs `prop.py
--only <name> --no-shrink` at it: the exit must be 1 and the output must hold `FAIL <name>`.

| Property | The break |
|---|---|
| `agreement` | `spec-check.sh` no longer strips backticks from a file name |
| `no-side-effect` | `spec-check.sh` leaves a file in the project |
| `monotone` | `spec-check.sh` reads a cited requirement as not cited |
| `exactly-one` | `spec-check.sh` prints each `MISSING-TEST` line twice |
| `round-trip` | `brief.sh` prints only the first line of a requirement |

REQ-27 is shown by running `prop.py` twice at one broken copy and comparing the two outputs.
REQ-29 is shown with a directory first on `PYTHONPATH` that holds a `hypothesis.py` which
raises `ImportError`. REQ-31 is shown by a smoke check that reads each job of
`.github/workflows/lint.yml` for its install line, with the version `prop.py` holds, and its
run line; the pull request's own run then shows both jobs green.

**In the smoke suite** `prop.py` is started as `uv run --quiet --with hypothesis==<version>
python3` when `uv` is on the `PATH`, and as `python3` when it is not, which is how
`scripts/lint.sh` starts lint. There the five properties run on 5 inputs each; the 40 are for
CI's own step and for line 9 of the plan's exit checklist.

## `red-check.sh`, step by step

1. Read the arguments. Wrong usage, a project that is not a git repository, a base ref git does
   not know, or no `.shipkit/specs/<slug>/spec.md`: a line on standard error, exit 2.
2. Find the test command: `--test`, or what `test-command.sh <project>` prints. Neither: exit 2
   with that script's message (REQ-36).
3. Check each `--link` name: it must be a folder of the project and must have no tracked path
   at the base ref (`git ls-tree`). Otherwise exit 2 (REQ-38).
4. List the citing test files. The search is `spec-check.sh`'s: `git grep -n -I -o --untracked`
   for `<slug>/REQ-<n>` over the project, leaving out `.shipkit/`, `docs/` and `*.md`; kept
   only for numbers the spec has; and kept only under the spec's `> Tests:` paths when it has
   that line. Of those, keep the files that differ from the base: not in the base ref, or
   different from it (`git diff --quiet <base> -- <file>`). Print `TEST <file>` for each.
5. None: print `NO-TESTS`, exit 0 (REQ-33).
6. Make the directory and the worktree. Set the removal on `EXIT`; `INT`, `TERM` and `HUP`
   stop a running child and exit 130.
7. Make each link.
8. Run the command in the scratch tree, as `sh -c`, with standard input from `/dev/null` and
   its output on standard error. Non-zero: print `BASE-NOT-RUNNABLE`, exit 0 (REQ-34).
9. Copy each listed file from the project to the same path in the scratch tree, making folders
   as needed. Run the command again. Non-zero: `RED-AT-BASE`. Zero: `GREEN-AT-BASE` and the
   files, separated by spaces (REQ-35). Exit 0.

An untracked file that cites the spec counts, as it does for `spec-check.sh`: a test written
and not yet committed is the common case when this is run.

## The waiting text

Nothing below is in any skill file. Sprint 35 applies an entry only where its probe shows a
miss, and keeps it only where the number moves (REQ-48, REQ-49).

### For `plugins/shipkit/skills/spec/reference.md`

In the section "`tasks.md` (Q3 — steps, traceable)", after the paragraph that ends "must be
cited by a test before the spec is `shipped`." and before "Check it with the script".

**W1, the frame. It goes in with the first of W2 to W4 that goes in, and not alone.**

> **Which kind of test.** The shape of a requirement says which kind of test proves it. Name the
> kind at the start of the `Test:` line with a tag: `[property]`, `[e2e]` or `[differential]`.
> A requirement of no shape below gets the smallest test that fails without the behaviour, and
> no tag.
>
> | The requirement says | The test |
> |---|---|

**W2, waits on the kinds fixture's REQ-1.**

> | something holds always, or never ("shall never be negative") | `[property]`: generated inputs, one statement checked on each |

**W3, waits on the kinds fixture's REQ-2.**

> | a round trip gives back what went in ("an exported file shall import to the same records") | `[property]` over generated values, or `[e2e]` through both commands |

**W4, waits on the kinds fixture's REQ-3.**

> | a replacement behaves as before ("after the move, every document shall render as before") | `[differential]`: the old and the new on the same inputs, compared |

### For `plugins/shipkit-workflows/skills/migration-plan/SKILL.md`

**W5, waits on the migration fixture.** In "Step 5: Migration Plan", under "Ordering
principles", as a new first item, with the six that are there renumbered 2 to 7. The skill's
description, 293 characters, is not changed.

> 1. Where behaviour must stay the same, start with a differential test. Before any version
>    changes, the first step writes a test that runs the old version and the new version on the
>    same inputs and compares what they give. It sets aside the differences that do not matter
>    (order, whitespace, timestamps) and keeps a list of the differences that are meant, each
>    with the changelog line that announces it.

### What Sprint 35 does with it

- **The baseline,** on the text as it is at `v5.3.0`: `kind-probe.sh --run kinds --yes`, five
  runs, and `--run migration --yes`, three runs. `--read` and `--read-plan` give the table the
  owner sees.
- **Text only where the baseline misses.** W2, W3 or W4 goes in when its requirement read
  `missed` in 2 or more of the 5 runs, with W1. W5 goes in when fewer than 3 of the 3 plans
  hold a differential step.
- **Then the same runs again.** A row stays when more of the 5 runs read `right` than before.
  W5 stays when more of the 3 plans hold a differential step than before.
- **`red-check.sh`** is run on the clone of the owner's project under `~/.cache/`, on the first
  task that adds a test, with the time it took. The live checkout is never its project.
- **Not verified until then:** that a headless `/shipkit:spec passbook tasks` writes a
  `tasks.md` without stopping at a gate, and that `/shipkit-workflows:migration-plan`, whose
  context is a fork, leaves its plan in the reply that `--output-format json` returns.

## Data / interface changes

- `scripts/kind-probe.sh`: new. `--scaffold kinds|migration <dir>`, `--run kinds|migration [N]
  [--out <dir>] [--yes]`, `--read <dir>`, `--read-plan <file>…` (REQ-1 to REQ-20).
- `scripts/kind-replies/`: new, the eight files of the table above (REQ-13, REQ-19).
- `scripts/prop.py`: new (REQ-21 to REQ-30).
- `.github/workflows/lint.yml`: in each job, a step that installs `hypothesis==6.170.16` and a
  step that runs `python3 scripts/prop.py` (REQ-31). No existing line changes: smoke checks 98,
  105, 108 and 109 read lines of this file.
- `plugins/shipkit/scripts/red-check.sh`: new, mode 755 (REQ-32 to REQ-42). Output: `TEST
  <file>` lines, then one of `NO-TESTS`, `BASE-NOT-RUNNABLE`, `RED-AT-BASE`, `GREEN-AT-BASE
  <file>…`.
- `plugins/shipkit/scripts/ship-check.sh`: one line at the end of `evidence.md` (REQ-43).
  Standard output and exit status are as they were.
- `.shipkit/specs/gate-as-software/spec.md`: a dated note on REQ-11.
- `GUIDE.md`: a section "Red at base", after "Checks that a diff triggers" (REQ-44).
- `scripts/smoke.sh`: new checks from 122, each with a line in `registry()` and none starting a
  model: `kind-fixtures` (REQ-1 to REQ-5, REQ-15, REQ-16, REQ-20), `kind-reader` (REQ-7 to
  REQ-14, REQ-18, REQ-19), `prop` (REQ-26 to REQ-30), `prop-ci` (REQ-31) and `red-check`
  (REQ-32 to REQ-42). Check 107 gains the assertions for REQ-43.
- `docs/plans/verifier-sprint-plan.md` is not changed. Line 9 of its exit checklist, `python3
  scripts/prop.py`, is run on this machine as `uv run --with hypothesis==6.170.16 python3
  scripts/prop.py`.
