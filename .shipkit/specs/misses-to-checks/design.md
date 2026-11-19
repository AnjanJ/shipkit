# Design: misses to checks

## Approach

Four things are built, none of which starts a model.

1. **Eleven eval cases.** Eight grow out of the shared fixture's refunds feature as new variants,
   two are built on a second feature the shared fixture learns (`notes-export`), and one is an
   escape case that builds on the existing escape fixture. Each case's tree is built and read by
   a smoke check, and each grader is shown both ways by `node` on replies kept in the
   repository.
2. **Held-out cases that stay held out.** They live in `plugins/shipkit/evals/holdout/`, the map
   marks them, lint ties the folder to the mark, `evals-for-diff.sh` leaves them out and the
   ledger writes the set.
3. **`checks-match.sh`,** which reads `.shipkit/checks.md` from the base ref and prints the items
   a diff triggers, with this repository's first four items.
4. **A count of the commands the briefing starts,** enforced on every machine, CI included.

Nothing in `plugins/*/skills`, `plugins/*/agents` or `plugins/*/rules` changes. The sentences
those files may gain are under "The waiting text" below, word for word, each with the case it
waits on. Sprint 35 measures each case on the text as it is at `v5.3.0`, applies a sentence only
where its case misses, and measures again (REQ-48).

Labels from `docs/plans/verifier-sprint-plan.md` used below: V13 is its decision on held-out
cases, V14 its decision on the checks file, V15 its decision on reviewer rounds. Rule 29 is "a
new check starts in observe mode", rule 31 "tuning cases and held-out cases are different
cases", rule 34 "what a model reads changes only after its baseline".

## Decision: Two reviewer cases are held out, in a folder of their own   (→ REQ-11 to REQ-20, REQ-39)

This is the record for V13, held-out cases.

**Context.** The reviewer's text is tuned on the cases it is reported on: `goldfish-gap` went
from 0 of 5 to 5 of 5 on the case its text was written against (`docs/design/eval-history.md`,
"After the fix"). Rule 31 says a held-out case runs at a release run or on the owner's word.
The plan's S32-T1 gives the two cases the set `holdout` in the map and nothing more, and nothing
reads that field: `scripts/evals.sh:53` turns `--group reviewer` into `--case "reviewer-*"`,
`scripts/evals-for-diff.sh` reads the map's first and third fields, `scripts/lint.py` check 19
accepts any word in the second, and `scripts/evals-ledger.sh:93` writes `watch` or `tune` from
the runs per case. A held-out case under `evals/reviewer/` would run in every tuning run.

**Alternatives.**
1. A folder of their own, `plugins/shipkit/evals/holdout/`, so that their names start
   `holdout-` and no other group's pattern meets them. The map says `holdout`; lint ties the
   folder to the word; `evals-for-diff.sh` leaves them out; the ledger writes the set from the
   map. `bash scripts/evals.sh --group holdout` is the run on the owner's word.
2. Keep them under `evals/reviewer/`, as the plan sketched, and have `evals.sh --group` build
   its `--case` list from the map, leaving `holdout` rows out unless `EVALS_HOLDOUT=1`.
3. The label alone.
4. No held-out cases: every case is a tuning case (V13's other option).

**Case for (1).** How `evals.sh` runs a group does not change, and that cannot be tried for real
before Sprint 35. The name carries the fact into every result table and ledger row. One command
runs them and no other.

**Case against (1).** A held-out reviewer case no longer sits beside the reviewer's other cases,
so smoke check 77 and anyone listing them looks in two folders. When text is changed in response
to a held-out case it becomes a tuning case (rule 31) and its folder moves, so its ledger rows
carry two names. Two cases, five runs each, is a small sample. (2) keeps one folder and changes
every group's command line, untested until a paid run. (3) is what exists and keeps nothing out.

**Decision.** We chose (1).
**Falsifiability.** We would stop paying for a held-out pair, as (4), if in three release runs
running each held-out case scores the same as its tuning twin (`holdout-reviewer-helper-only`
with `reviewer-helper-only`, `holdout-reviewer-skipped-test` with `reviewer-skipped-test`).
**Fired-if.** `q() { sh scripts/evals-ledger.sh --runs --last 3 --prefix "$1"; }; a=$(q holdout-reviewer-helper-only) && b=$(q reviewer-helper-only) && c=$(q holdout-reviewer-skipped-test) && d=$(q reviewer-skipped-test) || exit 2; printf '%s\n' "$a" "$b" "$c" "$d" | awk '{ k = int((NR - 1) / 3); s[k] = s[k] " " $4; if ($3 == 0) z = 1 } END { exit !(NR == 12 && !z && s[0] == s[1] && s[2] == s[3]) }'` <!-- covers: three release runs, each holding all four cases, with equal passed/runs for each pair -->

## Decision: One shared script builds both features, and the bytes are measured after two cases   (→ REQ-1, REQ-11, REQ-36, REQ-41)

**Context.** `plugins/shipkit/evals/` is 190,556 bytes and lint's check 17 fails above 204,800:
14,244 of room. Decision 0005 and the plan's S31-T4 say the ceiling does not rise. Today a
reviewer case's own folder is 820 to 1,116 bytes, the shared fixture is 6,078 and writes the
refunds feature only, and `escape/missing-req` is 3,388, of which its fixture is 2,550. The
estimate for this spec, from those sizes:

| What | Bytes, about |
|---|---|
| The shared fixture: five refunds variants | 1,900 |
| The shared fixture: two earlier reports and one checks file | 700 |
| The shared fixture: the `notes-export` feature and its two variants | 2,300 |
| Eight reviewer case folders, about 900 each | 7,200 |
| Two held-out case folders | 1,800 |
| `escape/second-of-a-kind`, built on `escape/missing-req`'s fixture | 1,850 |
| A second grader on `escape/missing-req` | 90 |
| Total | 15,840 |

That is about 1,600 over the room. It is an estimate.

**Alternatives.**
1. One shared script with a second feature in it, every case's own folder kept to a prompt, a
   five-line `case.yaml`, a three-line `fixture.sh` and one grader; `escape/second-of-a-kind`
   runs `escape/missing-req/fixture.sh` and adds to its tree. After the first tuning case and
   the first held-out case are written the folder is measured and the rest projected. If the
   projection passes the ceiling, the evals README's section "What graders can check" (2,871
   bytes, read by no smoke check) moves word for word to `docs/design/eval-cases.md`, as S31-T4
   moved two sections. Only if that is not enough is the owner asked which case to cut.
2. A second fixture script for `notes-export`.
3. A fixture of its own in every new case.
4. A fourth raise of the ceiling.
5. Cut `comment-cite` and `waiver-added` now: today's reviewer text and `spec-diff.sh` are the
   likeliest to catch them already.

**Case for (1).** It is what `decisions-bind/design.md`, "The ceiling stays, and the reviewer
fixtures share one script", chose for the same squeeze, and it keeps all eleven cases. The
README section is documentation for people; moving it costs no case and no check.

**Case against (1).** The shared script grows to about 11 KB with ten more variants and two
features, and a mistake in it reaches fourteen cases; REQ-1 and the tree check are the guard.
The estimate may be wrong by more than the README section gives back. (2) repeats the header,
the git setup and the commit lines, about 500 bytes. (3) is about 4 KB a case. (4) needs the
owner's word and reverses a decision twice upheld. (5) drops two of the five real misses before
anything is measured.

**Decision.** We chose (1).
**Falsifiability.** We would cut a case, the owner choosing which, if the folder would pass
204,800 bytes with all eleven cases in it after the README section has moved.
**Fired-if.** `test "$(git ls-files -z plugins/shipkit/evals | xargs -0 cat | wc -c)" -gt 204800`

## Decision: Only the two variants that edit the spec commit it first   (→ REQ-1, REQ-5, REQ-6)

**Context.** `spec-diff.sh` compares the working tree's requirements with a baseline: `spec.md`
at the base ref, or else at the first commit after it in which `> Status:` reads `open`
(`honest-evidence/REQ-21`). The shared fixture tags the sample application `base` and then makes
one commit that holds the spec and the code together, so a requirement rewritten "on the branch"
has no earlier form to be compared with. The four existing cases have a release history on the
trees they build today.

**Alternatives.**
1. The `weakened` and `waived` variants make two commits after `base`: the spec as first
   written, then the code with the edited spec. Every other variant keeps the one commit.
2. Every variant commits the spec first.
3. The spec goes into the `base` commit.

**Case for (1).** The four old trees do not change at all, history included, so REQ-1 holds
without argument and their past scores still describe them.

**Case against (1).** Two shapes of history in one script. (2) is more uniform and changes what
`git log` shows in four cases with measured histories. (3) changes `git diff base...HEAD` in
every case: the spec would no longer be in it.

**Decision.** We chose (1).
**Falsifiability.** We would give every variant the two commits, as (2), when a third variant
needs a requirement's earlier form.
**Fired-if.** manual

## Decision: "Names a change" is a pattern, not a judge   (→ REQ-9, REQ-10)

**Context.** `weakened-req` and `waiver-added` pass when the reply names the edit. Today's
reviewer has no section for it, so a grader that asks for the waiting text's heading alone
scores 0 of 5 by construction and the baseline says nothing. The evals README prefers `regex` to
`llm`: a judge runs three times a run and can disagree with itself.

**Alternatives.**
1. A `regex` that takes either form the Terms give: the heading "Requirements changed on this
   branch" with `REQ-2` under it, or one line that holds `REQ-2` and a word from a short list.
2. A `regex` for the heading alone.
3. An `llm` grader.

**Case for (1).** A reply that says "REQ-2 was reworded" in its own way passes before any text
is added, so the baseline can show whether the sentence is needed. It is cheap and repeatable.

**Case against (1).** A word list misses a phrasing nobody thought of ("REQ-2 no longer says
…"), and may take a line that uses "changed" about something else ("REQ-2 … no code changed").
Both sides are shown on written replies, not on real ones, until Sprint 35.

**Decision.** We chose (1).
**Falsifiability.** We would use an `llm` grader if, after one correction of the pattern (both
sides shown), it still misjudges a reply kept from a release run.
**Fired-if.** manual

## Decision: The reviewer reads the earlier report's open rows   (→ REQ-21 to REQ-24, REQ-45)

This is the record for V15, reviewer rounds.

**Context.** On the 5.2 run one tree got two readings: REQ-5 and REQ-6 of `team-day-boundary`
were `NOT MET` on day one and `CANNOT TELL` on day two, and one decision was `followed`, then
`partly built`. "The verdict did not move; the marks did" (`docs/design/field-notes-5.2.md`,
"One tree, two readings"). A report's name carries its date, so an earlier day's report is
still on disk at the second round (`review-and-ship/design.md`, "An earlier day's report is
named, not removed").

**Alternatives.**
1. The reviewer reads the newest earlier report for the slug, when there is one: only its
   `NOT MET` and `CANNOT TELL` rows and its decisions marked `contradicted`, `partly built` or
   `not built`. It starts from those marks, and says what changed. An earlier `MET` is never
   evidence.
2. Fully fresh each round, as today.
3. A second reviewer, and the gate compares the two.

**Case for (1).** A changed mark then means the tree changed or the reviewer says why. It adds
no agent (decision 0006). The reviewer is still given two things: the earlier report is a file
in the repository, written by the gate, and the builder's account is still withheld.

**Case against (1).** "Fresh eyes" is weakened: an earlier reading can anchor the next, most
dangerously an earlier `MET` on code that has since gone, which is what `stale-met` is for.
(2) keeps the reviewer independent of its own past and leaves the two readings as they are. (3)
doubles the cost of step 4 and needs a rule for a tie.

**Decision.** We chose (1), as waiting text. Two cases grade it: `reviewer-second-round` is the
helper-only tree with an untracked `NOT READY` report whose table marks REQ-2 `NOT MET`, and the
reply's mark must match; `reviewer-stale-met` is the missing-requirement tree with a `READY`
report whose table marks REQ-2 `MET`, and the reply must still say `NOT MET`.
**Falsifiability.** The reviewer stops reading earlier reports if `reviewer-stale-met` reads
`MET` in one or more of five runs at a release run.
**Fired-if.** manual <!-- the ledger holds pass and fail, not the mark a reply gave -->

## Decision: A checks file read from the base ref, reported and not judged   (→ REQ-25 to REQ-35, REQ-45, REQ-46)

This is the record for V14, the checks file.

**Context.** Nothing asks the reviewer about a past miss when a diff touches the same ground.
The closest thing shipkit has is a path-scoped rule, which steers the builder. By rule 28 a
change does not judge itself, so a list of checks cannot be read from the branch it judges.

**Alternatives.**
1. `.shipkit/checks.md`: items with a trigger readable from a diff, a check, and the miss it
   came from. `checks-match.sh` reads the file from the base ref and prints the items a diff
   triggers. In Sprint 35 the reviewer runs it and reports each item `HELD`, `BROKEN` or
   `CANNOT TELL`; the verdict rule does not change.
2. Prose advice in the reviewer's own text.
3. More path-scoped rules for the builder.
4. `ship-check.sh` runs the matcher as a ninth step that can fail the gate.

**Case for (1).** Each item is asked only when its trigger is met, so the list can grow without
every review paying for all of it. The file is the project's own. Read from the base ref, an
item added on a branch takes effect after it merges, and a branch cannot delete the item that
would catch it.

**Case against (1).** A model still judges whether a check held, so a `BROKEN` can be false;
that is why it does not touch the verdict yet. A new item protects nothing until it is merged.
(2) costs every review the whole list and has no trigger. (3) is advice to the party being
checked. (4) gives teeth to a check nobody has seen fire (rule 29).

**Decision.** We chose (1), in observe mode. The verdict rule changes, by a superseding record,
when two real gates in a row report a triggered check with no false `BROKEN`.
**Falsifiability.** We would take the section out of the reviewer if a reader finds a `BROKEN`
row false at two real gates running.
**Fired-if.** manual

## Decision: A glob is a shell pattern, and an added line is matched by awk   (→ REQ-26, REQ-27, REQ-31)

**Context.** A `path` trigger needs a way to say "any grader file", and an `added` trigger a way
to say "a line like this was added". The script is POSIX `sh` with awk and git only (REQ-31).

**Alternatives.**
1. A glob is matched against the whole path by the shell's `case`, where `*` also crosses `/`.
   An `added` pattern is an extended regular expression matched by awk against each line the
   diff adds, read from `git diff <base>...HEAD -U0` with the leading `+` taken off and `+++`
   headers left out. The pattern reaches awk through the environment, not `-v`, so a backslash
   in it is not rewritten.
2. Git's own pathspec, `:(glob)`, where `*` stops at `/` and `**` crosses it.
3. A regular expression for paths too.

**Case for (1).** One short rule that a person can check by eye, and no dependence on which
pathspec magic a git version has. `plugins/shipkit/evals/*/graders/*` reads as it looks.

**Case against (1).** `*` cannot be made to stop at a `/`, so "only files directly in this
folder" cannot be said. (2) can say it and reads differently from every glob in the map and in
`> Paths:`. (3) asks the author to escape every dot in a path.

**Decision.** We chose (1).
**Falsifiability.** We would take git's pathspec, as (2), when an item needs a `*` that does not
cross `/`.
**Fired-if.** manual

## Decision: The two sides of a grader are files, and the smoke suite reads them through node   (→ REQ-40)

**Context.** The plan's rules 18 and 23 ask that a new or changed `regex` grader go through
`node` on a reply it must pass and one it must fail, because a grader is a JavaScript `RegExp`.
Until now that was done by hand and recorded in a commit's test plan, so the proof is not run
again. Smoke check 96 does it for the goldfish case with Python's `re`, which is a different
engine.

**Alternatives.**
1. `scripts/grader-check.sh [<case>]` reads `scripts/grader-replies/<case>/<grader>.pass.md`
   and `<grader>.fail.md` (and `.fail-2.md`), where `<grader>` is the grader file's name without
   `.md`, and prints `PASS` or `FAIL` for each file by running the grader's pattern and flags in
   `node`. A smoke check runs it for every folder there and fails on any `FAIL`, on a reply
   whose grader does not exist, and on a case of this spec with no `pass` or no `fail` file.
2. By hand, in the commit's test plan, as before.
3. Python's `re`, as check 96.
4. The replies beside the graders, inside the evals folder.

**Case for (1).** The proof is kept and run on every pull request, so a pattern edited later is
caught by the replies it was shown on. The replies sit outside the evals folder and cost none of
its bytes. The by-hand command of rule 18 becomes one script.

**Case against (1).** The model-free suite now needs `node`, on CI's runner too, which is not
yet verified. About thirty small files. (2) costs nothing and proves it once. (3) can pass a
pattern that `node` rejects, or the reverse. (4) costs about 8 KB of the room.

**Decision.** We chose (1).
**Falsifiability.** We would go back to (2) if CI's macOS runner has no `node` and the owner
says no to a step that installs it.
**Fired-if.** manual

## Decision: The count is taken with a PATH of stand-ins, and CI enforces it from the first run   (→ REQ-43, REQ-44)

**Context.** CI's runner read the same briefing at 0.41 to 1.02 s of CPU on unchanged scripts,
so no time limit holds there (`honest-evidence/design.md`, seventh record). What the time is
made of does not vary: on check 30's fixture the briefing starts 229 commands, measured twice on
2026-11-19 with a stand-in for every program on `PATH`: 105 `awk`, 59 `sed`, 53 `grep`, two
`sort`, two `git` and one each of `tr`, `tail`, `sh`, `rm`, `mktemp`, `ls`, `dirname` and `cut`.
Ten specs give 69 and a hundred give 429: 29, and four for each open spec.

**Alternatives.**
1. The check builds a scratch directory holding one stand-in for each program on a list (the
   thirteen above). Each stand-in adds a line to a count file and runs the real program by its
   full path. The briefing runs with that directory as its whole `PATH`. A program not on the
   list is "command not found", which the check shows; the briefing's output must equal its
   output under the normal `PATH`.
2. A stand-in for every program on the machine's `PATH` (2,321 here).
3. `sh -x`, counting the trace's lines.
4. Count on the owner's machine and print on CI, as with the time.

**Case for (1).** Thirteen files, the same on every machine. Nothing is counted short: an
unlisted program fails loudly. The count is exact, so the limit can be the number itself and any
added command is a red check and a decision.

**Case against (1).** Rule 29 says a new check starts in observe mode, and this one fails from
its first run; the reason it may is that it measures no machine, and its first run on CI is on
this sprint's own pull request, before anything rests on it. A briefing that rightly needs a new
program fails the check until the list and the limit are changed. A subshell or a command
substitution that runs only builtins forks and is not counted. (2) needs no list and writes
thousands of files on every run. (3) counts builtins and assignments, and a script started as
`sh file` does not inherit `-x`. (4) repeats the gap this check is for.

**Decision.** We chose (1), with the limit at 229 (the owner's yes, 2026-11-19).

How the check shows that it fails above the limit (REQ-44): its verdict is a function of one
number, as check 30's `brief50_verdict` and check 112's `bk_verdict` are. The check counts the
briefing on check 30's fixture and gives that number to the function: 229 or fewer is a `PASS`
line that carries the count. It then builds the same fixture with fifty-one open specs, where
the briefing starts 233 commands, counts again, and gives that number to the function with
`CI=true` and `SMOKE_TIMING=report` set: the line must be a `FAIL`. So the count is shown to
rise with the work, and the limit to hold under both switches, with no override and no extra
stand-in.

**Falsifiability.** CI prints the count and does not fail on it if its runner's count differs
from the owner's machine's on one commit.
**Fired-if.** manual

## The trees

Every variant starts as the shared fixture does today: the sample application, committed and
tagged `base`. The refunds variants then write the `refunds` spec, design and tasks as today.

| Case | Variant | What differs from `complete` |
|---|---|---|
| `reviewer/helper-only` | `helper` | `app/refunds.py` gains `check_amount(amount_cents, charged_cents)`, which raises `RefundRejected`; `refund` does not call it. The test citing `refunds/REQ-2` calls only `check_amount`. |
| `reviewer/skipped-test` | `skipped` | The test citing `refunds/REQ-2` has `@unittest.skip("flaky on CI")` on the line above it. |
| `reviewer/comment-cite` | `comment` | A comment `# refunds/REQ-2` sits above the check in `refund`; the test for REQ-2 is left out. |
| `reviewer/weakened-req` | `weakened` | Two commits. The second rewrites REQ-2 to "…then the system shall refund the amount charged.", caps the amount in `refund`, and its test citing `refunds/REQ-2` asserts the cap. |
| `reviewer/waiver-added` | `waived` | Two commits. The second ends REQ-2 with `[untested: the gateway refuses it too]`; the test for REQ-2 is left out. |
| `reviewer/second-round` | `round2` | The `helper` tree, then `.shipkit/releases/2026-11-01-refunds.md`, untracked: `NOT READY`, its table marking REQ-2 `NOT MET`. |
| `reviewer/stale-met` | `stale` | The `missing` tree, then the same file: `READY`, its table marking REQ-2 `MET` with `app/refunds.py:12`. |
| `reviewer/check-triggered` | `check` | `.shipkit/checks.md` is written before the `base` commit, with C1: `Trigger: path app/refunds.py`, `Check: Every call to gateway.refund passes an idempotency key as its third argument.` The code calls it with two. |
| `holdout/reviewer-helper-only` | `notes-helper` | The `notes-export` feature; see below. |
| `holdout/reviewer-skipped-test` | `notes-skipped` | The same feature. |

An earlier report in the two second-round trees holds its first line, the `# Ship report:`
title, a `> Checked on 2026-11-01 …` line, and under `### 4. Independent review` a review table
of three rows with its count line and verdict line, as `skills/ship/reference.md` lays a report
out.

**The `notes-export` feature** has a spec with two requirements: REQ-1, "If a note is marked
private, then the export shall leave it out.", and REQ-2, "When an export is requested, the
system shall return one line for each note, its title first."; a one-record `design.md`; two
ticked tasks; `app/notes.py` with `is_shareable(note)` and `export_notes(notes)`; and
`tests/test_notes.py`. A note is a dict with a `title` and a `body`, and is private when its
`private` key is true: `is_shareable(note)` returns `not note.get("private")`, and
`export_notes(notes)` returns one string for each note it keeps, `"<title>: <body>"`. The requirement the two held-out variants break is REQ-1, not REQ-2, so
that text tuned on the refunds cases cannot pass them by the row it expects. In `notes-helper`,
`export_notes` does not call `is_shareable` and the test citing `notes-export/REQ-1` calls only
`is_shareable`. In `notes-skipped`, `export_notes` filters and that test is skipped.

**`escape/second-of-a-kind`** runs `escape/missing-req/fixture.sh`, then adds what the first
escape left: REQ-3 in the spec ("If the refund amount is larger than the amount charged, then
the system shall raise `RefundFailed` and shall not call the gateway."), the check in `refund`
with its test, and `.shipkit/escapes/0001-refund-above-charge.md` in the escape skill's shape.
Its prompt reports a refund of a negative amount that the gateway turned into a charge.

## The checks file's first four items

Each was read against its source on 2026-11-19. A `From:` note holds no comma, since a comma
separates sources.

```markdown
# Checks

Asked about when a diff meets the trigger. `plugins/shipkit/scripts/checks-match.sh` reads this
file from the base ref, so an item added on a branch takes effect after it merges.

## C1: A grader's pattern changed
Trigger: path plugins/shipkit/evals/*/graders/*
Check: The pattern is shown both ways through node: a reply it must pass and one it must fail are in scripts/grader-replies/ or in the commit's test plan.
From: docs/design/eval-history.md (Four graders corrected: the old graders failed 15 of 36 correct files)

## C2: A numeric limit in lint.py changed
Trigger: path scripts/lint.py
Check: Where a ceiling or a limit's number changed the commit names the owner's yes or the decision that allowed it.
From: scripts/lint.py (check 17's comment records each raise of the evals ceiling and who allowed it)

## C3: A requirement names its own gate
Trigger: added ^- [*][*]REQ-[0-9]+[.][*][*].*(READY|the tag|the merge)
Check: No requirement asks for its own READY report or the tag or the merge or anything after the gate. Those belong in the release task.
From: docs/design/eval-history.md (Release run 5.1.0: four requirements the spec could not meet at its own gate)

## C4: A text-only smoke check was added
Trigger: added passt "
Check: The requirement it cites is about wording or another assertion proves the behaviour.
From: docs/design/smoke-audit-5.4.md (18 of its 35 text-only assertions are all the proof their requirements have)
```

## The waiting text

Nothing below is in any skill, agent or template file. Sprint 35 applies an entry only where
its case scores below full on the text as it is at `v5.3.0`, and keeps it only where the score
rises (REQ-48). A case that already passes gets no text and stays as the watch.

### For `plugins/shipkit/agents/reviewer.md`

**W1, waits on `reviewer-skipped-test`.** In step 3, after the paragraph that starts "Be
strict.":

> A test that is skipped, pending or excluded from the run proves nothing. When the only test
> that cites or exercises a requirement is one of those, the requirement is `NOT MET`: say that
> the test is skipped and give its `path:line`.

**W2, waits on `reviewer-comment-cite`.** In step 3, after W1's place:

> A citation outside a test is not a test. `<slug>/REQ-N` in a comment in the implementation, in
> a fixture or in a document counts for nothing: `MET` needs a test that runs the behaviour.

**W3, waits on `reviewer-helper-only`.** In step 3, after W2's place. The plan lists three
candidate sentences and this is a fourth, written so that Sprint 35 has one if the baseline
misses:

> A test proves a requirement only when it reaches the behaviour through what the requirement
> names. When the requirement is about an entry point and the test calls only a helper that the
> entry point never calls, the requirement is `NOT MET`: say which function is tested and which
> is not.

**W4, waits on `reviewer-weakened-req` and `reviewer-waiver-added`.** A new step 6, and a
section in the reply after "Decisions not followed":

> 6. **Requirements changed on this branch.** Run
>    `sh "<plugin root>/scripts/spec-diff.sh" . <slug> <base>` (the plugin root is in
>    `~/.claude/shipkit/plugin-root`). For each `REQ-CHANGED`, `REQ-ADDED`, `REQ-REMOVED` and
>    `WAIVER-ADDED` line it prints, say in a few words what the edit did: "REQ-2 was reworded
>    from rejecting the refund to capping it", or "REQ-2 gained a waiver". If it prints
>    `NO-BASELINE` or none of those lines, write "None." A changed requirement is reported and
>    does not change the verdict.

> ```markdown
> ## Requirements changed on this branch
> - REQ-2 — `REQ-CHANGED` — <what the edit did> — or "None."
> ```

The ship report already quotes `spec-diff.sh`'s lines under the same heading in step 1's
evidence (`honest-evidence/REQ-36`). That block is the script's output; this section is the
reviewer's reading of each edit, inside step 4's evidence. The two stay under one heading so a
reader finds both by one search.

**W5, waits on `reviewer-second-round`.** At the end of step 1:

> If `.shipkit/releases/` holds a report for `<slug>` from an earlier day, read the newest: only
> the rows of its review table marked `NOT MET` or `CANNOT TELL`, and its decisions marked
> `contradicted`, `partly built` or `not built`. Check those first. Start from the mark it gave:
> keep it unless the files now show otherwise, and when you give a different mark, say why on
> the "Changed since" line.

**W6, waits on `reviewer-stale-met`.** Directly after W5:

> An earlier `MET` is never evidence. Find every requirement again in the code and in its test,
> whatever an earlier report said.

**W7, goes in with W5 and waits on `reviewer-second-round`.** One line in the reply, under the review table, only when an earlier
report was read:

> ```markdown
> Changed since the review of <YYYY-MM-DD>: REQ-5 NOT MET → CANNOT TELL — <why> — or "nothing".
> ```

**W8, waits on `reviewer-check-triggered`.** A new step 7, a section in the reply after
"Requirements changed on this branch", and one changed sentence under the reply's shape:

> 7. **Checks this diff triggered.** Run `sh "<plugin root>/scripts/checks-match.sh" . <base>`.
>    For each item it prints, do what its `Check:` line says and give one row: `HELD` when the
>    diff keeps to it, `BROKEN` when it does not, `CANNOT TELL` when you cannot say, each with
>    `path:line`. If it prints nothing, write "None." A `BROKEN` row is reported and does not
>    change the verdict.

> ```markdown
> ## Checks this diff triggered
> | Check | Result | Evidence |
> |-------|--------|----------|
> | C1: <title> | BROKEN | `app/refunds.py:12` — what breaks it |
> ```

> Changes beyond the spec, changed requirements, triggered checks and decisions marked
> `not built` or `partly built` are reported and do not change the verdict.

### For `plugins/shipkit/skills/escape/SKILL.md`

**W9, waits on `escape-second-of-a-kind`.** A new section between "4. Record it" and "5. Repair
the spec":

> ## 4a. The second of a kind becomes a check
>
> Read the other records in `.shipkit/escapes/`. If an earlier one names the same cause and its
> spec's `> Paths:` share a file or a folder with this one's, this escape is the second of its
> kind. Draft one item for `.shipkit/checks.md`:
>
> ```markdown
> ## C<n>: <what to ask, in a few words>
> Trigger: path <glob>
> Check: <what to verify in a diff that meets the trigger>
> From: .shipkit/escapes/<the earlier record>, .shipkit/escapes/<this record>
> ```
>
> The trigger must be readable from a diff: `path` with a file or folder the two escapes share,
> or `added` with a pattern for the lines a diff adds. Show the item in your reply. Write it to
> `.shipkit/checks.md` only when the user says yes; if no user is present, show it and write
> nothing. If no trigger can be read from a diff, say so and draft nothing. A first escape of
> its kind proposes no check.

### For `plugins/shipkit/skills/ship/reference.md`

**W10, goes in with W8 and waits on `reviewer-check-triggered`.** One line in the report's template under the `Requirements:` line, and
one rule:

> ```markdown
> Checks this diff triggered: 1 (1 BROKEN, 0 HELD, 0 CANNOT TELL), reported and not judged.
> ```

> - The "Checks this diff triggered" line counts the rows of the reviewer's section of that
>   name. When the reviewer wrote "None.", the line reads `Checks this diff triggered: 0`.

### What Sprint 35 does with it

- **First, one free reading.** In a session started by `claude plugin eval` on this checkout,
  `~/.claude/shipkit/plugin-root` must name this checkout's plugin, or W4 and W8 run the
  installed release's scripts, which have no `checks-match.sh`.
- **The baseline,** on the text as it is at `v5.3.0`: the eight `reviewer-` cases of this spec
  five times each, `escape-second-of-a-kind` and `escape-missing-req` three times each.
- **Text only where the baseline misses,** then the same runs again.
- **The held-out pair** runs at the release run, by `bash scripts/evals.sh --group holdout` or
  in the full run, and never between a baseline and its after-run (REQ-49).
- **Smoke check 70 (`report-shapes`)** learns W7's and W10's lines when they go in.

## Data / interface changes

- `plugins/shipkit/evals/lib/review-fixture.sh <variant>`: ten new variants, as "The trees"
  names them. The four old ones print and build what they did (REQ-1).
- `plugins/shipkit/scripts/checks-match.sh <project> <base>` and `--lint <project>`: new
  (REQ-25 to REQ-31). Output: for each triggered item, `TRIGGERED C<n>: <title>` and its three
  lines. `--lint` prints `BAD-ITEM C<n> <reason>`.
- `.shipkit/checks.md`: new, four items (REQ-32).
- `scripts/evals-map.tsv`: eleven rows; the second field may now be `holdout` (REQ-39).
- `scripts/lint.py` check 19: an error for a set that is not one of three words, and for a
  `holdout` row outside `evals/holdout/` or a case there with another set (REQ-15, REQ-16).
- `scripts/evals-for-diff.sh`: skips rows whose second field is `holdout`, and says on standard
  error how many it skipped (REQ-17).
- `scripts/evals-ledger.sh append`: reads the map (`EVALS_MAP`, as `evals-for-diff.sh` does) and
  writes `holdout` for a case the map marks so (REQ-19).
- `scripts/evals.sh`: its header gains two lines on `--group holdout`. No code changes.
- `scripts/grader-check.sh [<case>]` and `scripts/grader-replies/`: new (REQ-40).
- `scripts/smoke.sh`: new checks from 116; check 77 also reads `evals/holdout/reviewer-*`
  (REQ-41); check 113 expects the twelve reviewer cases (REQ-18); check 114 reads 204,800.
- `plugins/shipkit/evals/escape/missing-req/graders/`: a second grader (REQ-38).
  `docs/design/eval-cases.md` says "each case has exactly one scored grader" with one exception;
  that sentence gains this case.
- `.shipkit/specs/numbers-as-data/spec.md`: three dated notes, on REQ-21, REQ-27 and the term
  "A case's set".
