# Design: numbers as data

## Approach

Five pieces, each a script or a moved file with model-free checks, and no paid run.

1. `scripts/evals-ledger.sh` writes and reads `docs/design/eval-ledger.tsv`. `scripts/evals.sh`
   stops being a bare `exec`: it runs the tool, keeps traces, and appends the run's rows, marked
   `release`, or `partial` when only some cases ran; the queries read release runs only. The
   ledger starts with 5.1.0 and 5.2.0.
2. `briefing.sh` and `spec-check.sh` start fewer processes, so the briefing on fifty open specs
   fits in half a second here and in one second on CI's runner. `spec-check.sh` prints exactly
   what it printed at `398d1c9`. Then CI's `SMOKE_TIMING=report` comes out. The flake rule goes
   into `eval-history.md`'s head, and the note and kit for Sprint 35 go at the end of this file.
3. `scripts/evals-map.tsv` names, for each eval case, the plugin paths whose text reaches it.
   `scripts/evals-for-diff.sh` reads a diff against it, `evals.sh --for-diff` runs what it picks,
   and lint holds the map to the cases on disk.
4. Two sections of `plugins/shipkit/evals/README.md` move to `docs/design/eval-cases.md`.
5. The decision records whose reversal condition is an eval count get a `Fired-if` command that
   reads the ledger. The list is the table at the end of this file.

Nothing a model reads changes. `evals.sh` is run by a person, not loaded by a session.

## Decision: The ledger's JSON is read with python3, its queries with awk   (→ REQ-1 to REQ-7)

**Context.** A result file is nested JSON (`cases[].arms.with[].passed`). The plugin's own
scripts are POSIX `sh`, awk and git, and must not need python on a user's machine
(`spec-contract/REQ-10`). `evals-ledger.sh` is a contributor's script under `scripts/`, run where
`claude plugin eval` runs; `scripts/lint.py` and smoke check 38 already need `python3` there.

**Alternatives.**
1. `append` reads the result file with an inline `python3 -I` program; `--below-full` and
   `--rate` read the TSV with awk.
2. `jq` for the JSON.
3. awk for the JSON, by pattern.

**Case for (1).** `python3` reads JSON exactly and is already a contributor's dependency; the
queries, which Fired-if commands run, need only `sh` and awk.

**Case against (1).** Two languages in one script. (2) is not installed on the owner's machine
or named anywhere in the repository. (3) breaks the day the file's field order or spacing
changes.

**Decision.** We chose (1).
**Falsifiability.** We would move `append` to a separate `python3` script if the inline program
passes 60 lines.
**Fired-if.** manual

## Decision: An eval run is the rows that share a date and a commit   (→ REQ-4, REQ-6, REQ-7)

**Context.** The plan fixed the ledger's twelve columns. The queries need to know which rows
make one run, and `append` needs to know a row it already holds.

**Alternatives.**
1. Rows with the same `date` and `commit` are one run; a row is held when its `date`, `commit`
   and `case` are.
2. A thirteenth column, a run id from the result file's `startedAt`.

**Case for (1).** It keeps the plan's columns and needs nothing the backfill cannot give: 5.1.0's
prose has a date and a commit, and no `startedAt`.

**Case against (1).** Two runs on one commit on one day read as one run, and the second is
refused as already held. That happens when a release run is repeated after a failure, which rule
30 says to read first, not to run again; a repeat is then given `--commit` with a suffix by hand.
(2) separates them, at a column the backfill fills with `-`.

**Decision.** We chose (1).
**Falsifiability.** We would add (2) if a release run is refused as already held because a run
on the same commit and day was appended first.
**Fired-if.** manual

## Decision: 5.1.0's rows are rebuilt from its page and from the tree it ran   (→ REQ-12)

**Context.** "Release run 5.1.0" (`eval-history.md`) gives 65 cases, 227 runs, the three cases at
2 of 3 by name, and "62 cases at full score", but no list of cases and no runs per case. It names
the commit, `073938c`.

**Alternatives.**
1. The case list and each case's runs from the tree at `073938c`: every `prompt.md` folder under
   `plugins/shipkit/evals/` outside `fixtures/`, and `runs: 5` in its `case.yaml` or 3 when there
   is none. `passed` is `runs` except for the three named cases. The rows are kept only if they
   add up to the page's 65 cases and 227 runs.
2. Only the three named cases.
3. No 5.1.0 rows.

**Case for (1).** Every number comes from the page or from the commit the page names, and the
two totals check the reading (the plan's rule 25). `--below-full 2` and `--rate --last 2` need two
whole runs to mean anything.

**Case against (1).** A case that passed for a reason the page does not give is recorded as full
score on the page's word alone. `cost` and `claude` per case are `-`, so a cost query reads 5.1.0
as unknown. (2) leaves 62 cases out and makes "below full in two runs" look true for anything
missing. (3) leaves the flake rule one run short until 5.4.0.

**Decision.** We chose (1).
**Falsifiability.** We would drop the 5.1.0 rows if the tree at `073938c` does not add up to 65
cases and 227 runs.
**Fired-if.** manual

## Decision: The briefing is made cheap by starting fewer processes, not by a cache   (→ REQ-15, REQ-16, REQ-17)

**Context.** On check 30's fixture the briefing costs 0.82 s of CPU here, of which `spec-check.sh
.` is 0.63 s (measured 2026-11-18, best of five). A trace of that run counts about 2,600 shell
commands, among them 151 `grep`, 101 `awk` and 100 `sed`: roughly nine processes a spec. They
are two `sed` to read the status, a `grep` to look for a stray `Status:` line, an `awk` for the
requirements, a `grep` for each requirement's citation, a `grep` for the `Status:` line again, an
`awk` for the tasks, and `wc` and `tr` to count its lines. The briefing adds about 0.2 s, most of
it one `grep` per spec to count specs with no `Status:` line. CI's runner has read 1.6 to 1.8
times this machine's time.

**Alternatives.**
1. Fewer processes, same output. In `spec-check.sh`: the status read by one `sed`; each
   requirement's citation looked up inside the requirements `awk`, which reads the citation list
   as a third file, in place of a `grep` per requirement; one `grep` for the stray `Status:`
   lines of both files; and the tasks' findings counted with the shell's own arithmetic. In
   `briefing.sh`: specs with no `Status:` line counted by one `grep -L` over all of them.
2. A cache keyed on `HEAD` and `git status`, so a session that starts on the same tree reads the
   last count.
3. A second, smaller count in `briefing.sh` that does not call `spec-check.sh`.
4. One `awk` that checks every spec in a single pass.

**Case for (1).** It cuts what every caller pays, the gate's step 1 too, and changes no output,
which a check holds against the script at `398d1c9` (REQ-17). Each step is small and can be
measured on its own.

**Case against (1).** It touches the script every gate rests on, for speed; a mistake in it is a
wrong gap count, which the comparison check is there to catch. It may still fall short of half a
second. (2) helps only a session that starts where the last one ended, and a cold start after a
commit, which is the common case and the one check 30 measures, pays the full cost. (3) is two
counts that can disagree. (4) is a rewrite of the whole script for a gain (1) may already give.

**Decision.** We chose (1).
**Falsifiability.** We would take (4) if, after (1), the briefing on check 30's fixture still
takes more than half a second of CPU, best of three, here.
**Fired-if.** manual

## Decision: The map is written by hand and held to the cases by lint   (→ REQ-19 to REQ-25)

**Context.** A case's text arrives from several places: the skill its prompt invokes, the agent
that skill starts, the rule `evals/lib/with-rule.sh` installs, the scripts the skill runs, and,
for every case, the session hook and `rules/shipkit.md`. 5.3.0 picked its cases by hand and ran
none (`eval-history.md`, "Release run 5.3.0").

**Alternatives.**
1. `scripts/evals-map.tsv`, one row per case, written by hand. Lint fails a case with no row, a
   row with no case, and a path that does not exist. The hook and `rules/shipkit.md` are listed
   in the rows of the `rules-*` cases and `hello` only; the full release run stays the check on
   everything else they reach.
2. Derive the map at run time from each prompt's `/shipkit:` command and each `case.yaml`.
3. No map: every change runs every case.

**Case for (1).** Each row says, readably, why a case is picked, and lint keeps the rows and the
folders in step as cases come and go.

**Case against (1).** A row can name too few paths, and then a change is not measured by a case
it reaches; lint checks that paths exist, not that they are all there. (2) misses what a prompt
does not name: the agent a skill starts, the rule a fixture installs. (3) costs $21 a release
for any one-line change, which is why 5.3.0 ran none.

**Decision.** We chose (1).
**Falsifiability.** We would add (2)'s derivation as a lint warning if a release run shows a case
whose score moved on a diff the map did not select it for.
**Fired-if.** manual

## Decision: A Fired-if command composes the ledger's queries, and an error is exit 2   (→ REQ-29, REQ-30)

**Context.** `decision-check.sh` reads a command's exit status: 0 fired, 1 holds, anything else an
error (`gate-blind-spots/REQ-2`). The ledger's queries print; they do not answer yes or no.

**Alternatives.**
1. Each command runs a query into a variable, exits 2 if the query failed, and tests the output
   with `grep`, `awk` or `test`: `o=$(sh scripts/evals-ledger.sh --below-full 2) || exit 2; printf
   '%s\n' "$o" | grep -qx rules-nontrivial`.
2. A third query mode, `--check '<condition>'`, that exits 0, 1 or 2 itself.

**Case for (1).** It needs nothing beyond REQ-6 and REQ-7, and a broken ledger reads as `ERROR`,
never as `HOLDS`, because the query's status is checked before the test.

**Case against (1).** The commands are long and a little repetitive. (2) would be shorter, at the
cost of a small language in the script that nothing else needs.

**Decision.** We chose (1), with a third query, `--runs`, for the clauses about a run's cost or
its number of cases, which `--below-full` and `--rate` cannot answer (REQ-33, added after the
goldfish's first read).
**Falsifiability.** We would add (2) if more than three records need the same composed command.
**Fired-if.** manual

## Data / interface changes

`scripts/evals-ledger.sh` (REQ-1 to REQ-7), new:

- `evals-ledger.sh append <dir> [--commit <sha>] [--source <word>]`: reads
  `<dir>/aggregate-result.json`. No such file: `evals-ledger: no result file in <dir>` on standard
  error, exit 1. Creates the ledger with its header line when it does not exist.
- `evals-ledger.sh --below-full <n>`, `evals-ledger.sh --rate <case> [--last <k>]` and
  `evals-ledger.sh --runs [--last <k>] [--prefix <p>]`: REQ-6, REQ-7 and REQ-33. The cost and
  case-count clauses of the table below compose `--runs`. An empty ledger answers nothing and exits 0. Usage: exit 2.
- `EVALS_LEDGER` overrides the ledger's path, so the smoke checks write a scratch ledger.
- `model` is `suite.modelOverride`; `threshold` is `suite.threshold`; `version` is the version of
  the plugin named `shipkit` in `suite.plugins`; `date` is the first ten characters of
  `startedAt`; `cost` sums each run's `costUsd`, printed with two decimals.

`scripts/evals.sh` (REQ-8 to REQ-10, REQ-24). It runs `claude plugin eval` as it does today, with
`--keep-temp` added unless `EVALS_KEEP=0`, as a child and not through `exec`; then `sh
scripts/evals-ledger.sh append "$out"`; then it exits with the eval run's status. A failed append
prints a warning and does not change that status. `--for-diff <base>` (first argument, like
`--group`) asks `evals-for-diff.sh` for the cases and passes one `--case <name>` for each; with
none it prints `evals: no case reads the files this diff changed` and exits 0. `EVALS_TOOL`
names the command to run in place of `claude`, so the smoke checks give it a stand-in.

`docs/design/eval-ledger.tsv`: the header line `date version commit claude model case set passed
runs threshold cost source`, tab-separated. 5.2.0's 65 rows are appended from
`~/.cache/shipkit-rel-5.2.0/aggregate-result.json` with `--commit` set to the commit
"Release run 5.2.0" names and `--source result-file`. 5.1.0's rows are written by a one-off
`python3` read of the tree at `073938c`, by the third record above, and are not a mode of the
script.

`plugins/shipkit/scripts/spec-check.sh` and `briefing.sh` (REQ-15 to REQ-17): the first record's
option 1. Smoke check 30 gains nothing; a new check compares this `spec-check.sh` with the one at
`398d1c9`, taken with `git show`, on check 30's fixture, on a fixture with every kind of gap
line, and on this repository, and reads the briefing's gap line against `spec-check`'s count.

`.github/workflows/lint.yml` (REQ-18): `SMOKE_TIMING: report` comes out of the `smoke-no-model`
job, with its comment, after five passes running on the runner without it. Until then the task
stays open.

`scripts/evals-map.tsv` (REQ-19 to REQ-23): the header line `case set paths`. `scripts/
evals-for-diff.sh <base>` reads `git diff --name-only <base>...HEAD`, and prints each case one of
whose paths equals a changed file or, ending in `/`, holds it.

`scripts/lint.py` (REQ-25, REQ-28): check 17's heading names 204,800 bytes; a new check 19 holds
the map to the cases.

`plugins/shipkit/evals/README.md` and `docs/design/eval-cases.md` (REQ-26, REQ-27): the table
under `## Cases` and the section on `with-rule.sh` move word for word under a line `*Moved
2026-11-18 (Sprint 31, S31-T4):*`. `## Cases` stays in the README with one line naming the new
file, because smoke checks 54 and 57 read up to that heading. Decision 0005 stands; one cost is
added to what it weighed: the ceiling has begun to shape fixtures (the goldfish's fixture lost a
comment and a `git init` to fit, "The noise, before the fix").

## Reversal conditions the ledger can answer (REQ-29)

Read 2026-11-18 from `decision-check.sh . --run`: of 143 `MANUAL` lines, these name an eval case,
a group or a run's cost, and the ledger holds the numbers to decide them. A command covers the
clause named here; a record's other clauses, which need a trace, a user or a real run, stay for a
person to read, and the record says so in a comment after its command.

| Record | The clause the command covers |
|---|---|
| `.shipkit/decisions/0002-spec-first-eval.md` | `rules-nontrivial` below 2 of 3 in two release runs running, or `rules-trivial` below full in any |
| `always-on`, "The Care lines move only by their number" | `rules-care` below 2 of 3 in a release run |
| `decisions-bind`, "A contradicted decision fails through the reviewer's verdict" | `reviewer-decision-unbuilt` or `reviewer-all-met` below full |
| `graders-and-eve`, "The release run accepts a fifty-ninth case" | a release run above $25, or above 80 cases |
| `measured-cuts`, "The intake's assumption names its file; the four-question ceiling counts parts" | `intake-limit` below 2 of 3 in the last release run |
| `overlays-and-eve`, "`eve.md` ships at the measured size, not the audit's estimate" | the five `eve` cases above $0.15 a run on average in a release run |
| `portfolio-run`, "The release run grows to 58 cases, every case every release" | a release run above $25 (its second clause, two runs with every count unchanged, stays for a person) |
| `rule-evals`, "One case per rule file, eighteen of them" | the `scoped-` and `stacks-` cases above $10 in a release run |
| `rule-evals`, "`--group` exists; the release run still runs everything" | a release run above $25 |
| `rule-evals`, "The stopping rule for `rules/nontrivial`" | `rules-nontrivial` passing fewer than one run in ten over three release runs |
| `second-traps`, "The Gemfile line is reworded on the 4.2.0 measurement" | `stacks-gemfile` or `trap2-gemfile` below 2 of 3 |

A cost clause reads only runs whose `cost` is known, so 5.1.0's `-` never counts toward one. A
clause that names more release runs than the ledger holds exits 1 (`HOLDS`): the condition has
not been shown, and REQ-30 asks for that reading.

**Found while reading, not given a command:** `second-traps`, "Sixteen trap-2 cases, with and
without", turns on "the release run passes $18". 5.1.0 cost $21.10 and 5.2.0 $21.25
(`eval-history.md`), so the condition has been true for two releases and nothing said so. A
command would read `FIRED`, and REQ-30 asks that each new command read `HOLDS`; by the plan this
goes to the owner, not to a rewording. It stays `manual` until the owner decides.

Left out because the ledger cannot answer them: conditions about an arm (`with` and `without`,
`haiku`), a trace, "the next release run" after a past change, a count from before 5.1.0, the
first runs of a new case, and anything a user or a real run reports.

## Text for Sprint 35

Nothing a model reads waits on this spec. Sprint 35 runs the release through `evals.sh`, which
appends its rows (REQ-31), and runs the kit below (REQ-32).

### What the records say of the four (REQ-14, read 2026-11-18)

**`hello`.** Below full in both release runs the ledger holds; `evals-ledger.sh --below-full 2`
names it alone.
- "Release run 5.1.0": "run 1's last message did not hold the `names-map` pattern."
- "Release run 5.2.0": "2 of 3: one run's last message did not hold the `names-map` pattern, its
  shape at 5.1.0."
- "Baseline 3.1.0": 3 of 3. Neither release run kept a trace, so the failing replies were never
  read.

**`intake-limit`** (`intake/limit`). 2 of 3 in 4.8.0, 4.9.0, 4.10.0, 4.11.0, 4.12.0, 5.0.0 and
5.1.0; 3 of 3 in 5.2.0.
- "Release run 4.7.0": 0 of 3. The trace, read: "the grader counts a sub-part that needs its own
  answer as a question of its own — three judges in each of the four runs counted five or more."
- "Release run 4.12.0": "run 1 scored 0.00 on `four-questions-or-fewer` (judge votes FAIL FAIL
  FAIL: the reply asked more than four questions) … it was not re-run and no grader changed."
- "Release run 5.1.0": "run 2's judges voted FAIL FAIL PASS on `four-questions-or-fewer`, its
  shape since 4.9.0."
- "Release run 5.0.0": "`intake/limit` 2 of 3, its shape since 4.9.0."

**Smoke check 2, `rules-skip` (`haiku`).** `eval-history.md` has no line on it. It is recorded
in `ROADMAP.md:419-420`: "fails on variance and passes alone with its dependency — the known shape
in the 4.9.0 release's full run". And in `CHANGELOG.md:808-809`, Sprint 16's release: "160 of
161 with check 2 (`rules-skip`, haiku) failing on variance and passing alone with its
dependency".

**Smoke check 4, `agents` (`haiku`).** `eval-history.md` has no line on it. It is recorded in
`ROADMAP.md:287-288`: "asked for names starting `shipkit:`, the model lists the skills too; 1 of 2
full runs at Sprint 21's merge, 3 of 3 alone".

### The kit, for Sprint 35 (REQ-32)

Each is run ten times, traces kept, before any text or grader changes (rule 30). Each ends in one
outcome: a corrected grader (rule 23, a reply it must pass and one it must fail), a changed
sentence (on the owner's go, rule 6), or the case deleted with its reason on `eval-history.md`.

| Case | The command | What to read in the traces |
|---|---|---|
| `hello` | `bash scripts/evals.sh --case hello --runs 10` | Each failing run's last message against `evals/hello/graders/names-map.md`: is the map's name missing, or there in a form the pattern does not take? |
| `intake-limit` | `bash scripts/evals.sh --case intake-limit --runs 10` | Each failing run's questions, counted as `four-questions-or-fewer` counts them: does a question with parts count as several, as 4.7.0 found? |
| smoke check 2 | ten runs of `SMOKE_KEEP=1 sh scripts/smoke.sh --only 2 </dev/null` (its fixture is built outside its model guard, so `--only 2` alone is enough) | The kept reply of each failing run: what did `haiku` say about the skipped rule? |
| smoke check 4 | ten runs of `SMOKE_KEEP=1 sh scripts/smoke.sh --only 4 </dev/null` | The kept list of each failing run: skills named beside the agents, as `ROADMAP.md:287` says? |

`evals.sh --case` rows are marked `partial`, so the kit's runs never count as a release run.
