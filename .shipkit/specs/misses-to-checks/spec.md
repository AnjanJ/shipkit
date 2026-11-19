# Spec: misses to checks

> Spec accepted at commit `9e061ca` on sprint-32/misses-to-checks.
> Status: open
> Paths: plugins/shipkit/evals/reviewer/, plugins/shipkit/evals/holdout/, plugins/shipkit/evals/escape/, plugins/shipkit/evals/lib/review-fixture.sh, plugins/shipkit/scripts/checks-match.sh, .shipkit/checks.md, .shipkit/specs/numbers-as-data/spec.md, scripts/evals-map.tsv, scripts/evals-for-diff.sh, scripts/evals-ledger.sh, scripts/evals.sh, scripts/lint.py, scripts/smoke.sh, scripts/grader-check.sh, scripts/grader-replies/, docs/design/eval-cases.md, GUIDE.md, plugins/shipkit/agents/reviewer.md, plugins/shipkit/skills/escape/, plugins/shipkit/skills/ship/
> Tests: scripts/smoke.sh

## Purpose

Grade the reviewer on misses a real run showed, and turn a miss that has happened twice into a
check that a diff triggers. Today the reviewer's four eval cases are made up; the cases its text
is tuned on are the cases it is reported on; a second gate on one tree gave different marks from
the first (`docs/design/field-notes-5.2.md`, "One tree, two readings"); nothing asks about a past
miss when a diff touches the same ground; and `/shipkit:escape` repairs one spec and stops. This
is Sprint 32 of `docs/plans/verifier-sprint-plan.md`. It builds eleven eval cases with their
graders, one new script and the plumbing that keeps held-out cases held out, and it starts no
model. Every sentence the reviewer and the escape skill may gain is written into this spec's
`design.md` and waits for Sprint 35, which measures first (the plan's rules 33 and 34).

## User stories

- As the owner at a release, I want the reviewer scored on the misses a real run showed, so that
  its number says something about the next real run.
- As the owner, I want two cases the reviewer's text was never tuned on, so that a better score
  is not only a better fit.
- As the owner on a second gate of one tree, I want the marks to hold unless the tree changed,
  so that a changed mark means something.
- As the owner of a miss that happened twice, I want it asked about whenever a diff touches the
  same ground, so that it is not found a third time by a user.
- As the owner, I want CI to fail a briefing that starts more commands, so that its cost is held
  where a timing limit cannot be.

## Terms

- **The base of this spec.** Commit `9e061ca`, `main` when this spec was written.
- **An eval case, its name, the map, a case's set.** As `numbers-as-data/spec.md` defines them:
  a folder under `plugins/shipkit/evals/` that holds a `prompt.md`; the folder's path under
  `evals/` with `/` read as `-`; `scripts/evals-map.tsv`; and the second field of the case's row
  in the map.
- **A release run.** As `numbers-as-data/spec.md` defines it: an eval run that
  `scripts/evals.sh` was given no `--case`, `--group` or `--for-diff` for, so that it runs every
  case. The owner starts it, at a release.
- **A case's score.** The number of its runs that passed, out of the runs made in one eval run:
  3 of 5. It is **full** when the two numbers are equal, and it **rose** when, over the same
  number of runs, more passed after a change of text than before it.
- **A held-out case.** A case whose set is `holdout`. By the plan's rule 31 it runs at a release
  run or on the owner's word, and no agent or skill text is changed against it.
- **A held-out failure.** A held-out case whose score is below full in an eval run. It is
  **written down** as one line under that run's heading in `docs/design/eval-history.md`: the
  case, its score and the date.
- **A case's tree.** What the case's `fixture.sh` leaves when it is run in an empty directory: a
  git repository whose first commit is tagged `base`.
- **The shared fixture.** `plugins/shipkit/evals/lib/review-fixture.sh`, which builds the tree of
  every case whose prompt starts the `reviewer` agent.
- **The refunds feature.** The spec `refunds` the shared fixture writes today: REQ-1 (a refund
  goes through the gateway), REQ-2 (a refund above the charge raises `RefundRejected` and the
  gateway is not called) and REQ-3 (the README, waived), with `app/refunds.py` and
  `tests/test_refunds.py`.
- **A note, a private note.** In the `notes-export` feature a note is a dict with a `title` and
  a `body`; it is private when its `private` key is true.
- **The test command.** `python3 -m unittest discover -s tests`, run in a case's tree.
- **A reply marks REQ-N `<verdict>`** when the row of its review table that starts `| REQ-N`
  holds that verdict.
- **A reply names a change to REQ-N** when a section headed `Requirements changed on this
  branch` holds `REQ-N`, or one line holds `REQ-N` and one of `REQ-CHANGED`, `changed`,
  `rewritten`, `reworded`, `edited` or `weakened`.
- **A reply names a waiver REQ-N gained** when a section headed `Requirements changed on this
  branch` holds `REQ-N` and `waive`, or one line holds `REQ-N` and either `WAIVER-ADDED` or
  `waiver` with `added`, `new` or `gained`.
- **An earlier report.** A file `.shipkit/releases/<YYYY-MM-DD>-<slug>.md`, dated before the
  day of the run, whose first line is `READY` or `NOT READY` and which holds a review table.
- **A grader is shown both ways** when its pattern, read by `node` as a JavaScript `RegExp` with
  the grader's flags, matches a reply it must pass and does not match a reply it must fail.
- **The checks file.** `.shipkit/checks.md`. An **item** starts at a line `## C<n>: <title>` and
  runs to the next such line or the end of the file. It holds three lines, which start
  `Trigger:`, `Check:` and `From:`.
- **A trigger** is `path <glob>[, <glob>]…` or `added <pattern>`.
  - A `path` trigger **is met** when a file that `git diff --name-only <base>...HEAD` names
    matches one of its globs. A glob is matched against the whole path as a shell `case`
    pattern, so `*` also matches `/`.
  - An `added` trigger **is met** when a line that `git diff <base>...HEAD` adds matches its
    pattern, an extended regular expression as `awk` reads it. A `+++` header is not an added
    line, and the leading `+` is not part of the line.
- **A source.** Each comma-separated entry of an item's `From:` line. Its first word is a path
  from the project's root.
- **A command the briefing starts.** A program found through `PATH` and run by `briefing.sh` or
  by a script it runs. A shell's builtins and functions are not counted. On check 30's fixture
  (`numbers-as-data/spec.md`, Terms) the briefing starts 229 at the base of this spec: 29, and
  four for each open spec (69 on ten specs, 429 on a hundred).
- **The waiting text.** A sentence, step or block that an existing skill, agent or template file
  may gain in Sprint 35, written word for word in this spec's `design.md` and in no other file.

## Requirements (EARS)

The four cases the reviewer has today:

- **REQ-1.** For each of `reviewer-all-met`, `reviewer-missing-req`,
  `reviewer-rejected-alternative` and `reviewer-decision-unbuilt`, the case's tree shall hold
  the same files with the same contents as the tree the shared fixture built for it at the base
  of this spec.

Five tuning cases, each from a real miss:

- **REQ-2.** In the tree of `reviewer-helper-only`, a test that cites `refunds/REQ-2` shall call
  only a helper function of `app/refunds.py`, `refund` shall not call that helper and shall pass
  an amount above the charge to the gateway, and the test command shall exit 0.
- **REQ-3.** In the tree of `reviewer-skipped-test`, `refund` shall raise `RefundRejected` for
  an amount above the charge, the only test that cites `refunds/REQ-2` shall carry a skip
  marker, the test command shall exit 0 with that test skipped, and `spec-check.sh . refunds`
  shall print a `SKIPPED-CITE refunds REQ-2` line.
- **REQ-4.** In the tree of `reviewer-comment-cite`, `refund` shall raise `RefundRejected` for
  an amount above the charge, `refunds/REQ-2` shall appear in a comment in `app/refunds.py` and
  in no file under `tests/`, and the test command shall exit 0.
- **REQ-5.** In the tree of `reviewer-weakened-req`, the spec's REQ-2 shall say that a refund
  above the charge is cut to the charge, the code and a passing test that cites `refunds/REQ-2`
  shall do that, and `spec-diff.sh . refunds base` shall print `REQ-CHANGED refunds REQ-2` and
  no other `REQ-` or `WAIVER-` line.
- **REQ-6.** In the tree of `reviewer-waiver-added`, no test shall cite `refunds/REQ-2`, and
  `spec-diff.sh . refunds base` shall print `WAIVER-ADDED refunds REQ-2` and `REQ-CHANGED
  refunds REQ-2`, and no other `REQ-` or `WAIVER-` line.
- **REQ-7.** The grader of `reviewer-helper-only` shall pass a reply that marks REQ-2 `NOT MET`
  or `CANNOT TELL` and ends `VERDICT: FAIL`, and shall fail a reply that marks REQ-2 `MET`.
- **REQ-8.** The graders of `reviewer-skipped-test` and `reviewer-comment-cite` shall each pass
  a reply that marks REQ-2 `NOT MET` and ends `VERDICT: FAIL`, and shall each fail a reply that
  marks REQ-2 `MET`.
- **REQ-9.** The grader of `reviewer-weakened-req` shall pass a reply that names a change to
  REQ-2, and shall fail a reply that marks REQ-2 `MET` and names no change.
- **REQ-10.** The grader of `reviewer-waiver-added` shall pass a reply that names a waiver REQ-2
  gained, and shall fail a reply that marks `REQ-2 (waived)` `MET` and names no waiver gained.

Two held-out cases, on another feature:

- **REQ-11.** The trees of `holdout-reviewer-helper-only` and `holdout-reviewer-skipped-test`
  shall be built by the shared fixture on a feature `notes-export`, and their diff
  `base...HEAD` shall hold no line that contains `refund` in any letter case.
- **REQ-12.** In the tree of `holdout-reviewer-helper-only`, a test that cites
  `notes-export/REQ-1` shall call only a helper function of `app/notes.py`, the export function
  shall not call that helper and shall return a private note, and the test command shall exit 0.
- **REQ-13.** In the tree of `holdout-reviewer-skipped-test`, the export function shall leave a
  private note out, the only test that cites `notes-export/REQ-1` shall carry a skip marker, the
  test command shall exit 0 with that test skipped, and `spec-check.sh . notes-export` shall
  print a `SKIPPED-CITE notes-export REQ-1` line.
- **REQ-14.** The grader of `holdout-reviewer-helper-only` shall pass a reply that marks REQ-1
  `NOT MET` or `CANNOT TELL` and ends `VERDICT: FAIL`; the grader of
  `holdout-reviewer-skipped-test` shall pass a reply that marks REQ-1 `NOT MET` and ends
  `VERDICT: FAIL`; and each shall fail a reply that marks REQ-1 `MET`.

A held-out case stays held out:

- **REQ-15.** If a row of the map has a set other than `tune`, `watch` or `holdout`, then
  `scripts/lint.py` shall report an error that names the row.
- **REQ-16.** If a case's folder is under `plugins/shipkit/evals/holdout/` and its set is not
  `holdout`, or its set is `holdout` and its folder is elsewhere, then `scripts/lint.py` shall
  report an error that names the case.
- **REQ-17.** `scripts/evals-for-diff.sh` shall not print a held-out case; when it leaves one or
  more out, it shall write `evals-for-diff: <n> held-out case(s) not listed` to standard error.
- **REQ-18.** When the diff touches only `plugins/shipkit/agents/reviewer.md`,
  `evals-for-diff.sh` shall print the twelve cases whose name starts `reviewer-`, and no other.
- **REQ-19.** When `evals-ledger.sh append` writes a row for a held-out case, the row's `set`
  shall be `holdout`.
- **REQ-20.** `docs/design/eval-cases.md` shall say that a held-out case runs at a release run,
  or by `bash scripts/evals.sh --group holdout` on the owner's word, and that no text is changed
  against one. [untested: prose, verified by reading]

A second round that builds on the first:

- **REQ-21.** The tree of `reviewer-second-round` shall be the tree of `reviewer-helper-only`
  with an earlier report for `refunds` whose first line is `NOT READY` and whose review table
  marks REQ-2 `NOT MET`.
- **REQ-22.** The tree of `reviewer-stale-met` shall be the tree of `reviewer-missing-req` with
  an earlier report for `refunds` whose first line is `READY` and whose review table marks REQ-2
  `MET` with a `path:line` in `app/refunds.py`.
- **REQ-23.** The grader of `reviewer-second-round` shall pass a reply that marks REQ-2 `NOT
  MET` and ends `VERDICT: FAIL`, and shall fail a reply that marks REQ-2 `CANNOT TELL` and one
  that marks it `MET`.
- **REQ-24.** The grader of `reviewer-stale-met` shall pass a reply that marks REQ-2 `NOT MET`
  and ends `VERDICT: FAIL`, and shall fail a reply that marks REQ-2 `MET`.

Checks that a diff triggers:

- **REQ-25.** When `plugins/shipkit/scripts/checks-match.sh <project> <base>` is run, it shall
  read the checks file as the commit `<base>` holds it, and shall not read the working tree's
  copy.
- **REQ-26.** For each item whose trigger is met, in the file's order, `checks-match.sh` shall
  print `TRIGGERED C<n>: <title>` and then the item's `Trigger:`, `Check:` and `From:` lines as
  they are written.
- **REQ-27.** While a line was removed by the diff and not added, an `added` trigger shall not
  be met by it.
- **REQ-28.** If `<base>` holds no checks file, then `checks-match.sh` shall print nothing and
  exit 0, whether or not the working tree holds one.
- **REQ-29.** `checks-match.sh` shall exit 0 whether or not it prints an item, and 64 on wrong
  usage or a base ref git does not know.
- **REQ-30.** When `checks-match.sh --lint <project>` is run, it shall read the working tree's
  checks file and print `BAD-ITEM C<n> <reason>` for each item that has no `Trigger:`, `Check:`
  or `From:` line, a trigger that is neither a `path` nor an `added` trigger, or a source whose
  path does not exist; it shall exit 1 when it prints one and 0 otherwise, and 0 with no output
  when there is no checks file.
- **REQ-31.** `checks-match.sh` shall change no file, and shall be POSIX `sh` with awk and git
  only.
- **REQ-32.** This repository's `.shipkit/checks.md` shall hold four items and pass `--lint`: a
  grader's pattern changed, so both sides go through `node`; a numeric limit in `scripts/lint.py`
  changed, so the owner's yes is cited; a requirement names its own gate; and a text-only smoke
  check was added for a requirement about behaviour.
- **REQ-33.** In the tree of `reviewer-check-triggered`, the commit `base` shall hold a checks
  file with one item, C1, whose trigger is `path app/refunds.py`; `checks-match.sh . base` shall
  print `TRIGGERED C1`; the code shall do what C1's check forbids; and every requirement of
  `refunds` shall be met as in `reviewer-all-met`.
- **REQ-34.** The grader of `reviewer-check-triggered` shall pass a reply that holds `C1` and
  `BROKEN` on one line and ends `VERDICT: PASS`, and shall fail a reply that does not hold `C1`
  and one that holds `C1` and `HELD` on one line.
- **REQ-35.** `GUIDE.md` shall name `checks-match.sh`, its `--lint`, the form of an item and the
  two kinds of trigger, and say that the file is read from the base ref. [untested: prose,
  verified by reading]

The second escape of a kind:

- **REQ-36.** In the tree of `escape-second-of-a-kind`, the spec `refunds` shall hold a REQ-3
  that an earlier escape added, `.shipkit/escapes/0001-refund-above-charge.md` shall name the
  cause `requirement missing` and the spec `.shipkit/specs/refunds/`, `refund` shall accept an
  amount below zero, and no requirement shall say what happens to one.
- **REQ-37.** The grader of `escape-second-of-a-kind` shall pass a reply that holds a line
  starting `Trigger:` with `path` or `added` after it, and a line starting `From:` that names
  `.shipkit/escapes/0001-` and `.shipkit/escapes/0002-`; and shall fail a reply with no
  `Trigger:` line and one whose `From:` line names one record.
- **REQ-38.** `escape-missing-req`, a first escape, shall carry a second grader that passes a
  reply with no line starting `Trigger:` and fails a reply that holds one.

Every new case is listed, and its grader is proven:

- **REQ-39.** The map shall give the set `holdout` to the two cases of REQ-11 and `tune` to
  `reviewer-helper-only`, `reviewer-skipped-test`, `reviewer-comment-cite`,
  `reviewer-weakened-req`, `reviewer-waiver-added`, `reviewer-second-round`,
  `reviewer-stale-met`, `reviewer-check-triggered` and `escape-second-of-a-kind`.
- **REQ-40.** For each grader of REQ-7 to REQ-10, REQ-14, REQ-23, REQ-24, REQ-34, REQ-37 and
  REQ-38, `scripts/smoke.sh` shall hold a reply it must pass and each reply it must fail, and
  shall fail when the grader is not shown both ways on them.
- **REQ-41.** Each case whose prompt starts the `reviewer` agent, held-out cases included, shall
  build its tree by calling the shared fixture.
- **REQ-42.** `docs/design/eval-cases.md` shall hold a row for each of the eleven cases, and
  each case's `case.yaml` shall name, in a comment, the miss the case comes from. [untested:
  prose, verified by reading]

The briefing's command count:

- **REQ-43.** On check 30's fixture, `briefing.sh` shall start at most 229 commands.
- **REQ-44.** `scripts/smoke.sh` shall count the commands of REQ-43 in a check that starts no
  model, shall print the count in its `PASS` line, and shall fail above 229 whatever
  `SMOKE_TIMING` and `CI` are set to.

What a model reads (written here, applied in Sprint 35 after its baseline):

- **REQ-45.** This spec's `design.md` shall hold the waiting text for `agents/reviewer.md`: a
  skipped, pending or excluded test proves nothing; a citation outside a test is not a test; a
  section "Requirements changed on this branch" that reads `spec-diff.sh`; the reading of an
  earlier report's `NOT MET` and `CANNOT TELL` rows and of its decisions not followed; that an
  earlier `MET` is never evidence; the line `Changed since the review of <date>: …`; and the
  section "Checks this diff triggered". Each shall name the case it waits on. [untested: prose,
  verified by reading]
- **REQ-46.** This spec's `design.md` shall hold the waiting text for the escape skill, one step
  after the record is written, and the block the ship report's template gains for triggered
  checks. [untested: prose, verified by reading]
- **REQ-47.** This spec's `design.md` shall hold a record for each of the plan's decisions V13
  (held-out cases), V14 (the checks file) and V15 (reviewer rounds), each with the event that
  reverses it. [untested: prose, verified by reading]
- **REQ-48.** A waiting sentence shall go into `agents/reviewer.md` or the escape skill only
  where its case scored below full on the text as it is at `v5.3.0`, and shall stay only where
  the case's score rose after it. [untested: read from Sprint 35's record]
- **REQ-49.** No text shall be changed in response to the result of a held-out case; a held-out
  failure shall be written into `docs/design/eval-history.md` before any text changes.
  [untested: read from Sprint 35's record]

## Requirements of `numbers-as-data` that this spec amends

Each gets a dated note in `numbers-as-data/spec.md`, as `honest-evidence/REQ-43` did, in the
task that moves its smoke check, so the words and the check change in one commit (the owner's
yes, 2026-11-19):

- **Its REQ-21** names the four reviewer cases "and no other" for a diff on `reviewer.md`.
  Smoke check 113 holds it against this repository's map, so the first new reviewer row breaks
  it. REQ-18 above takes its place.
- **Its REQ-27** holds the evals folder to 190,800 bytes, the room Sprint 31 made for these
  cases; smoke check 114 enforces it, and the folder is at 190,556. From this spec on the
  folder is held by lint's check 17, at 204,800 bytes, and check 114 reads that number.
- **Its term "A case's set"** says `holdout` "is not written here". REQ-19 above writes it.

## Out of scope

- Any paid model run in this sprint, and any change to an existing skill, agent, rule or overlay
  file (the plan's rules 33 and 34). REQ-48 and REQ-49 are this spec's, and their tasks wait for
  Sprint 35.
- Raising check 17's ceiling, or moving an eval case out of the plugin (decision 0005).
- A second reviewer.
- Making a triggered check change the reviewer's verdict, and having `ship-check.sh` or any
  skill run `checks-match.sh`: Sprint 35, in observe mode (the plan's rule 29).
- Writing a check item into `.shipkit/checks.md` from an escape: the escape skill's waiting
  text, applied in Sprint 35.
- Changing the briefing's half-second and one-second limits, or taking `SMOKE_TIMING` out of the
  CI job again.
- An `evals.sh` option that leaves a set out of a run: a held-out case is kept out of a group by
  its name.
- The probes, the property tests and `red-check.sh`: Sprint 33.
