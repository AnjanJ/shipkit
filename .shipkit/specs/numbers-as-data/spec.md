# Spec: numbers as data

> Spec accepted at commit `398d1c9` on sprint-31/numbers-as-data.
> Status: open
> Paths: scripts/evals.sh, scripts/evals-ledger.sh, scripts/evals-map.tsv, scripts/evals-for-diff.sh, scripts/lint.py, scripts/smoke.sh, docs/design/eval-ledger.tsv, docs/design/eval-history.md, docs/design/eval-cases.md, plugins/shipkit/evals/README.md, plugins/shipkit/scripts/briefing.sh, plugins/shipkit/scripts/spec-check.sh, .github/workflows/lint.yml, .shipkit/decisions/
> Tests: scripts/smoke.sh

## Purpose

Make eval results something a script can read, and make the cases a change needs something a
script can choose. Today every release's results are prose in `docs/design/eval-history.md`, so
whether a case has been below full score twice is found by reading, and no reversal condition
about an eval count can be a command. Cases for a diff are picked by hand. A flaky case is run
again until it passes. The evals directory has 53 bytes of room. And smoke check 30 cannot hold
its one-second limit on CI's runner. This is Sprint 31 of `docs/plans/verifier-sprint-plan.md`.

## User stories

- As the owner at a release, I want each case's result kept as a row, so that "below full score
  in two releases running" is a query and not a reading.
- As the owner of a change to one skill, I want the eval cases that read it named by a script,
  so that I pay only for those.
- As the author of a decision record, I want a reversal condition about an eval count to be a
  command, so that it fires on its own.
- As the owner, I want the briefing quick enough that CI holds its limit, so that the check is
  enforced everywhere it runs.

## Terms

- **The ledger.** `docs/design/eval-ledger.tsv`: a header line, then one row per case per eval
  run, with twelve tab-separated fields in this order: `date` (`YYYY-MM-DD`, the day the run
  started), `version` (the plugin's), `commit` (short sha), `claude` (Claude Code's version),
  `model`, `case`, `set`, `passed`, `runs`, `threshold`, `cost` (US dollars, two decimals) and
  `source`. A field the source does not hold is `-`.
- **A result file.** The `aggregate-result.json` that `claude plugin eval --output-dir <dir>`
  writes into `<dir>`. At Claude Code 2.1.319 it holds `claudeVersion`, `startedAt`, `suite`
  (with `modelOverride`, `threshold` and the plugin's `version`) and `cases`, each with `name`,
  `runsPerCase` and `arms.with`, one entry per run with `passed` and `costUsd`.
- **A case's set.** `holdout` when the case's row in the map says so; otherwise `watch` when
  its runs per case are 5, and `tune`.
  > *Amended 2026-11-19 (`misses-to-checks` T2, the owner's yes):* this said "`holdout` is
  > Sprint 32's and is not written here". Sprint 32 writes it: `misses-to-checks/REQ-19`.
- **An eval run in the ledger.** The rows that share one `date` and one `commit`. Runs are ordered
  by `date`, then by the order their rows were appended.
- **A release run.** An eval run whose rows' `source` is not `partial`. `evals.sh` writes
  `partial` for a run it was given `--case`, `--group` or `--for-diff` for, and `release`
  otherwise; the backfilled runs (`result-file`, `history`) are release runs. The queries of
  REQ-6, REQ-7 and REQ-33 read release runs only.
- **Full score.** `passed` equals `runs`.
- **The map.** `scripts/evals-map.tsv`: a header line, then one row per eval case with three
  tab-separated fields: the case's name, its set, and a comma-separated list of paths under
  `plugins/` whose text reaches the case. A path that ends in `/` is a folder and meets every file
  under it.
- **A path meets a file** when it is that file's path, or ends in `/` and the file is under it.
- **An eval case.** A folder under `plugins/shipkit/evals/`, outside `fixtures/`, that holds a
  `prompt.md` (a `case.yaml` is optional: `hello` has none). Its name is the one `claude plugin
  eval` gives it, the folder's path under `evals/` with `/` read as `-`; the 5.2.0 result file
  names all 65 of its cases that way. At this spec's base there are 67.
- **Check 30's fixture.** The fifty open specs that `scripts/smoke.sh` check 30 builds, each with
  four tasks of which one is ticked.
- **The base of this spec.** Commit `398d1c9`, `main` when this spec was written.

## Requirements (EARS)

The eval ledger:

- **REQ-1.** When `scripts/evals-ledger.sh append <dir>` is run on a directory that holds a result
  file, it shall append one row to the ledger for each case in that file.
- **REQ-2.** In a row that `append` writes, `passed` shall be the number of the case's runs with
  `passed` true, `runs` the number of its runs, `cost` the sum of its runs' `costUsd`, `set` as
  the Terms say, and `date`, `version`, `claude`, `model` and `threshold` from the result file.
- **REQ-3.** `append` shall take the row's `commit` from `--commit <sha>` when given, and
  otherwise from `HEAD`; and its `source` from `--source <word>` when given, and otherwise `run`.
- **REQ-4.** If the ledger already holds a row with the same `date`, `commit` and `case`, then
  `append` shall not write that row again.
- **REQ-5.** `append` shall print `evals-ledger: <a> row(s) added, <s> already held`.
- **REQ-6.** When `evals-ledger.sh --below-full <n>` is run, it shall print, one per line in name
  order, each case that is below full score in every one of the last `n` release runs in the ledger.
  A case with no row in one of those runs is not printed.
- **REQ-7.** When `evals-ledger.sh --rate <case> [--last <k>]` is run, it shall print `<case>
  <p>/<r> over <m> run(s)`, where `p` and `r` are the sums of `passed` and `runs` over the case's
  rows in the last `k` release runs (every release run when `--last` is not given), and `m` is how many of
  those runs hold a row for the case.
- **REQ-8.** `scripts/evals.sh` shall run `claude plugin eval`, then `evals-ledger.sh append` on
  its output directory with `--source release`, or `--source partial` when it was given `--case`,
  `--group` or `--for-diff`, and shall exit with `claude plugin eval`'s exit status.
- **REQ-9.** If the eval run wrote no result file, then `evals.sh` shall append no row and shall
  still exit with the eval run's status.
- **REQ-10.** `evals.sh` shall pass `--keep-temp` to `claude plugin eval` unless `EVALS_KEEP` is
  `0`.
- **REQ-11.** The ledger shall hold 65 rows for the 5.2.0 release run, read from its result file,
  with `source` `result-file`.
- **REQ-12.** The ledger shall hold one row for each case of the 5.1.0 release run, with `source`
  `history`, `cost` `-`, `date` `2026-11-04`, `version` `5.1.0`, `commit` `073938c`, `claude`
  `2.1.318`, `model` `sonnet`, `threshold` `0.6`, and `passed` as `eval-history.md`'s "Release run
  5.1.0" gives it: 2 of 3 for `grandfather-xl-drift`, `hello` and `intake-limit`, and full score
  for every other case. (The page gives the date, the commit and Claude Code's version;
  `scripts/evals.sh` at `073938c` gives the model and the threshold.)

The flake rule, and a briefing quick enough for CI:

- **REQ-13.** `docs/design/eval-history.md` shall state the plan's rule 30 above its first
  section. [untested: prose, verified by reading]
- **REQ-14.** This spec's `design.md` shall hold, for each of `hello`, `intake-limit` and smoke
  checks 2 (`rules-skip`) and 4 (`agents`), what `docs/design/eval-history.md` says of its
  failures, with the section each line comes from, and the command Sprint 35 runs to read it ten
  times with traces kept: `bash scripts/evals.sh --case <name> --runs 10` for an eval case, and
  ten runs of `SMOKE_KEEP=1 sh scripts/smoke.sh --only <n> </dev/null` for a smoke check.
  [untested: prose, verified by reading]
- **REQ-15.** Where `spec-check.sh .` reports `G` gaps on a project, `briefing.sh` shall print
  `shipkit: spec-check: G gap(s) — run spec-check.sh` when `G` is above 0, and no gap line when it
  is 0.
- **REQ-16.** On check 30's fixture, `briefing.sh` shall take at most half a second of CPU, the
  best of three runs, on the owner's machine.
- **REQ-17.** `spec-check.sh` shall print the same lines, and exit with the same status, as it
  did at the base of this spec, for the same tree and the same arguments.
- **REQ-18.** The CI job of `honest-evidence/REQ-11` shall set `SMOKE_TIMING` to `report`.
  > *Amended 2026-11-19 (T8, the owner's yes):* this said the job shall not set `SMOKE_TIMING`.
  > Without it the runner passed check 30 five times running (0.41 to 0.97 s), and the sixth run
  > read 1.02 s, best of three, on unchanged scripts. The runner's CPU time spreads too far for
  > the one-second limit, so the switch is back and the limit holds on the owner's machine.

The cases for a diff:

- **REQ-19.** The map shall have one row for each eval case, and each row shall name a case that
  exists.
- **REQ-20.** When `scripts/evals-for-diff.sh <base>` is run, it shall print, one per line in
  name order, each case whose row has a path that meets a file in `git diff --name-only
  <base>...HEAD`.
- **REQ-21.** When the diff touches only `plugins/shipkit/agents/reviewer.md`, `evals-for-diff.sh`
  shall print every case the map names `reviewer-*`, and no other.
  > *Amended 2026-11-19 (`misses-to-checks` T1, the owner's yes):* this named the four cases
  > whose prompt starts the `reviewer` agent, `reviewer-all-met`, `reviewer-decision-unbuilt`,
  > `reviewer-missing-req` and `reviewer-rejected-alternative`, "and no other". Sprint 32 adds
  > reviewer cases, so the list is read from the map; `misses-to-checks/REQ-18` holds their
  > number, twelve, once they are all in.
- **REQ-22.** When the diff touches `plugins/shipkit/rules/shipkit.md` or
  `plugins/shipkit/scripts/session-start.sh`, `evals-for-diff.sh` shall print every case whose
  name starts `rules-`, and `hello`.
- **REQ-23.** When the diff touches no file under `plugins/`, `evals-for-diff.sh` shall print
  nothing and exit 0.
- **REQ-24.** When `evals.sh --for-diff <base>` is run, it shall run `claude plugin eval` with one
  `--case <name>` for each case `evals-for-diff.sh` prints; when it prints none, `evals.sh` shall
  run nothing, say so, and exit 0.
- **REQ-25.** `scripts/lint.py` shall report an error for an eval case with no row in the map, a
  row that names no eval case, and a path in a row that does not exist.

Room for new cases:

- **REQ-26.** `plugins/shipkit/evals/README.md`'s case table and its section on `with-rule.sh`
  shall be in `docs/design/eval-cases.md`, word for word, under a line that gives the date they
  moved; the README shall keep its `## Cases` heading with one line under it naming that file.
- **REQ-27.** `plugins/shipkit/evals/` shall be at most 204,800 bytes, measured as `lint.py`'s
  check 17 measures it: the sum of the sizes of every file under the folder.
  > *Amended 2026-11-19 (`misses-to-checks` T1, the owner's yes):* this said 190,800 bytes, the
  > room Sprint 31 made for Sprint 32's cases: 14,244 bytes under check 17's ceiling. Those
  > cases now use that room, so the folder is held at the ceiling itself.
- **REQ-28.** `scripts/lint.py`'s check 17 shall name the limit it enforces, 204,800 bytes.
  [untested: prose, verified by reading]

Reversal conditions that read the ledger:

- **REQ-29.** Each decision record that this spec's `design.md` lists as having an eval-count
  condition shall carry a `**Fired-if.**` command that calls `scripts/evals-ledger.sh`, in place
  of `manual`, with nothing else in the record changed.
- **REQ-30.** `decision-check.sh . --run` shall print `HOLDS` for each command REQ-29 adds, and
  shall print no `ERROR` line. A clause that names more release runs than the ledger holds reads
  `HOLDS`.
- **REQ-33.** When `evals-ledger.sh --runs [--last <k>] [--prefix <p>]` is run, it shall print one
  line for each release run, oldest first, `<date> <commit> <c> <passed>/<runs> <cost>`, over the
  rows of that run whose case name starts with `<p>` (every row when `--prefix` is not given):
  `c` cases, the sums of `passed` and `runs`, and the sum of `cost` with two decimals, or `-` when
  any of those rows has `cost` `-`. With `--last <k>`, only the last `k` runs.

Waiting for Sprint 35 (each needs a paid run):

- **REQ-31.** The release run of 5.4.0 shall append its rows to the ledger through `evals.sh`.
  [untested: read from Sprint 35's record]
- **REQ-32.** Sprint 35 shall run the kit of REQ-14 for each of its four cases and record, for
  each, a corrected grader, a changed sentence, or the case deleted with its reason. [untested:
  read from Sprint 35's record]

## Out of scope

- Any paid model run in this sprint, and any change to an existing skill, agent or rule file
  (the plan's rules 33 and 34).
- Raising check 17's ceiling, or moving an eval case out of the plugin (decision 0005).
- Holdout cases and the eleven cases from real misses: Sprint 32.
- A `Fired-if` command for a condition the ledger cannot answer.
- Backfilling releases before 5.1.0.
- Changing what `spec-check.sh` prints.
