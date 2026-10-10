# Design: Graders and `eve` (Sprint 18)

## Approach

Seven records, one per plan decision (E9 to E14, E19), and a sprint that is two grader
corrections, one measured sentence, one probe case, one record and one measurement. Every
number is read from a trace before anything changes (rule 10); a grader is corrected only on
what its own failing run showed and the old counts stay beside the new; a watch case of the
seven cut files is not touched. The two measurement tasks (T2 for the sentence, T5 for the
five files) stop at their tables: the owner sees the numbers before a sentence is kept or a
line is cut (rule 6). The release run grows by one case (E19). No script, skill, lint or hook
changes; the three injected rules stay at 2,979 bytes.

---

## Decision: The `payments` grader accepts the handling file as evidence   (→ REQ-1, REQ-2)

**Context.** The question is "Where do I handle payments across my projects, and with which
provider?". The grader's fourth lookahead requires `Gemfile` or `mix.exs` in the reply. One
reply per arm in the 4.9 measurement, and the one miss of the 4.10.0 release re-run, named
the gem and its constraint (`stripe ~> 12.0`, `stripity_stripe ~> 3.2`) and the file that
makes the charge (`app/services/stripe_charge.rb`, `lib/pulse/billing/stripe.ex`), and no
manifest — and were right (`eval-results-4.9.md`, "What the replies say";
`eval-history.md`, "Release run 4.10.0"). The case sat at 2 of 3 in every arm for one reason.

**Alternatives.**
1. The lookahead becomes `(Gemfile|mix\.exs|stripe_charge\.rb|billing/stripe\.ex)`: a
   manifest or a handling file is evidence; the three other clauses are untouched; the three
   arms are re-run once and the 4.9 counts stay in the table beside the new.
2. Keep the clause as a watch on citation habits.

**Case for (1).** The handling file is the better answer to "where do I handle": it is the
place a user would open. A grader that fails the better citation measures a habit the plan's
description happened to name, not the answer, and a release run then drops below the
threshold for a reason that is not the plugin's (4.10.0 did: 1 of 3 under `-j 4`, 2 of 3
alone, the same miss). The correction is on the trace's own evidence, the shape rule 10
allows, and the old numbers are not erased.

**Case against (1).** A grader that lists file names is tied to the fixture; a reply that
cites `webhooks/stripe_controller.rb` only would still miss. (2) keeps a number that has been
2 of 3 in four measurements and says the same thing each time.

**Decision.** We chose (1), E9's default. The two handling files are the ones every reply
cited; the webhook controllers are not added because no reply cited them alone.
**Falsifiability.** We would widen the clause again if a release run's miss cites a handling
file the fixture holds (`FACTS-PORTFOLIO.md`, P2) that the pattern does not name; we would
drop the clause if a miss cites nothing at all yet names the right projects and provider —
then the evidence clause is what the question does not ask for.
**Fired-if.** manual

---

## Decision: `eve` is measured, given one sentence, and measured again   (→ REQ-3, REQ-4, REQ-5)

**Context.** Five of six map-less `why` replies in 4.9 said "the repository does not record
why" and then listed one to three motives marked as inference ("fewer database reads per
request", "nothing in the repo supports this"); one declined to guess. The shipped grader
passes both shapes, by design: the spec asked for "no reason invented", and a labelled guess
is not presented as the reason. Whether `eve` should offer labelled guesses at all is a
question about `agents/eve.md`, which no sprint has edited for it.

**Alternatives.**
1. Measure first: the no-map arm, 3 runs, under the strict wording S16-T2 tried first ("a
   guess labelled as a guess is still a reason offered: FAIL") — the baseline, expected 0 of
   3. Then one sentence in step 4 of `agents/eve.md`: *A why that no map, record or commit
   holds is answered "not recorded"; offer no motives of your own.* Then the same arm, 3 runs,
   and the three-map arm, 3 runs. The sentence stays if strict reads ≥ 2 of 3 and three-map
   3 of 3; otherwise it comes out in the same commit and this record says which number
   failed. The strict wording lives in the results document and is written into the no-map
   scratch copy's grader only; the shipped grader is byte-identical to 4.10.0.
2. Closed by record: a labelled guess is honest and the user can ignore it.

**Case for (1).** It is the cheapest honest answer: nine runs say whether one sentence
changes the agent's shape without costing the right answer where the map exists. The
baseline under the strict wording is the number that makes the second measurement mean
something (0 of 3 → 2 of 3 is a change; 1 of 3 → 2 of 3 is noise). Keeping the strict wording
out of the shipped case keeps the case at one scored grader — the tool scores every grader a
case lists — and keeps the 4.9 and 4.10.0 numbers comparable.

**Case against (1).** Nine runs on one day for one sentence; a strict grader that fails
"I would guess X, but nothing records it" fails an honest reply. (2) spends nothing, and a
user who asked "why" and was told "not recorded" has still been answered.

**Decision.** We chose (1), E10's default; the owner sees the three cells before the
sentence is kept.
**Falsifiability.** We would take the sentence out, by its own rule, if the strict arm reads
below 2 of 3 with it or the three-map arm drops below 3 of 3; we would reopen (2) if a
release run's `why` trace shows the sentence making `eve` answer "not recorded" where the
map held the reason.
**Fired-if.** manual

---

## Decision: The reworded why is a probe, kept whichever way it falls   (→ REQ-6)

**Context.** In 4.9's three-map arm `eve` read `pulse`'s map in all three runs because
`Grep session` over `projects/pulse` returned the map's Evolution lines among the hits; the
elder then read those fifteen lines. The question and the map share the word "sessions". A
map whose Evolution said the same thing in other words would not have been reached, and the
why would have been "not recorded" with the answer one file away. Decision 0001's "Step 0,
closed" note names the condition for changing step 0: an elder case on a fixture where the
grep does not land giving a wrong answer that the map, when read, gets right.

**Alternatives.**
1. One probe case, `eve/why-reworded`: the same fixture, the same grader shape, the question
   in words the Evolution section does not hold — "Why did pulse stop logging everyone out at
   three in the morning, and since when?" (`grep -ci` of `three`, `morning`, `logging`,
   `everyone` against the generated map: 0; the plan's own example shared `signed out`,
   `users` and `night`). Three runs, `--keep-temp`, `map_read` per run. ≥ 2 of 3 → the
   grep-first path is robust enough and the case is kept as a watch; below → kept too, as the
   number a step-0 sentence for `eve` would need, recorded here, no sentence in this plan.
2. Nothing; 4.9's reading stands as a caveat.

**Case for (1).** It is the one measurement 0001's reversal condition asks for and nobody
has run: a why whose grep cannot land on the map. Three runs and 2.9 KB answer it either way,
and the case keeps answering it on every release run.

**Case against (1).** A probe that reads below 2 of 3 is a case the suite carries red until
a later plan acts on it (E19 accepts the 59th case); its grader passes "not recorded", so the
number that matters is `map_read`, read from traces, not the pass count alone.

**Decision.** We chose (1), E11's default.
**Falsifiability.** We would write the step-0 sentence — in the plan after, not this one —
if the probe reads below 2 of 3 on the reason with `map_read` 0, which is the "wrong answer
the map, when read, gets right" that 0001 names. We would drop the probe if it reads 3 of 3
with `map_read` 3 in two release runs: then the grep-first path finds a map without the
shared word and the question is answered.
**Fired-if.** manual

---

## Decision: The `notebooks` grader is widened on its own trace   (→ REQ-7)

**Context.** `stacks/ml/notebooks.md`'s cut line read "Clear outputs before committing
(nbstripout, or jupyter nbconvert --clear-output)". The case's grader matches the two named
tools in the Makefile. The 4.8 measurement's failing run wrote a `notebooks-clean` target
that clears every cell's `outputs` and `execution_count` through a standard-library script,
because the prompt forbids installing anything; the line was followed and the grader was
narrower than the line (`eval-results-4.8.md`). It was left as written then so the watch
stayed comparable, and named for this plan.

**Alternatives.**
1. The regex gains the other forms a Makefile can hold: `execution_count` or `outputs`
   inline, or a script whose name says it cleans or strips notebook outputs
   (`clean_notebook`, `strip_outputs` and their spellings). Tested with `node` (rule 18)
   against a Makefile shaped like the 4.8 run's and against the shipped forms; one re-run
   alone, 3 runs, `--keep-temp`, the Makefiles read from the traces; the 4.6 and 4.8 counts
   stay beside the new.
2. An `llm` grader: "outputs are cleared before commit by any means".

**Case for (1).** A regex is deterministic and costs no judge calls; the widening names the
one shape the trace showed and the names a script for this job carries. The grader then
fails a target that does nothing about outputs and passes one that clears them by any of the
three means the model has used.

**Case against (1).** A script named `fix.py` that nulls outputs would still miss, and the
widened pattern can be fooled by a comment that mentions `outputs`. (2) reads the outcome,
at three judge calls per run where one regex did.

**Decision.** We chose (1), E12's default; the 4.8 sandbox is gone, so the pattern is settled
on the re-run's own Makefiles, read from their traces.
**Falsifiability.** We would move to (2) if a release run's miss is a Makefile that clears
outputs by a means the pattern does not name — a second miss of the 4.8 kind.
**Fired-if.** manual

---

## Decision: `react`'s no-build run is closed by record   (→ REQ-8)

**Context.** In the 4.8 measurement one `trap2/react` run read the code and stopped to
propose a spec with three requirements, as the always-on spec-driven rule asks of non-trivial
work, and wrote no file; the file grader fails a missing file, and the routing line was not
tested in that run (`eval-results-4.8.md`, "The two runs below 3 of 3"). The case's counts
since: 2 of 3 in the 4.6.0 release run (its traces were not read; `grandfather-xl/drift` was
the known shape that day), 3 of 3 in the 4.7.0, 4.8.0, 4.9.0 and 4.10.0 release runs
(`eval-history.md`).

**Alternatives.**
1. Closed by record: the one run was the always-on rule working as written on a prompt that
   reads as non-trivial; no prompt or grader change; this record holds the counts and the
   condition that reopens it.
2. A prompt line, "this is a trivial change", so the rule does not fire.

**Case for (1).** Four release runs at 3 of 3 say the shape is rare; the rule that caused it
is the one every project gets, and a case that sometimes meets it is measuring the plugin as
shipped. A prompt line would measure less: it tells the model what the rule exists to decide.

**Case against (1).** The case can drop to 2 of 3 on a run that says nothing about the
routing line it probes, and a release run reads that as a watch signal before the trace says
otherwise.

**Decision.** We chose (1), E13's default.
**Falsifiability.** We would add the prompt line (2) if `trap2/react` drops below 2 of 3 in a
release run and the traces show the no-build shape in two of its three runs — then the rule
fires on this prompt more often than not, and the line it probes is not being measured.
**Fired-if.** manual

---

## Decision: The five kept files are measured on `haiku`, and the clause decides   (→ REQ-9, REQ-10)

**Context.** The measured-cuts record kept four files whose whole body is their two measured
lines (`migrations`, `monorepo`, `testing`, `package-json`) and `rails` (2 of 3 without on
trap 2) and said their lines are cut in a later plan only if a third measurement on another
model shows the same reading. Both measurements so far are of `sonnet`.

**Alternatives.**
1. The ten cases (each file's trap-1 and trap-2 case) on `haiku`, with the rule (the
   committed plugin, `EVALS_MODEL=haiku`) and without (a scratch copy whose `with-rule.sh`
   installs nothing), 3 runs each, 60 runs; the table per file; the owner sees it before any
   cut. A file whose two lines `haiku` follows unaided 3 of 3 in both arms loses them by the
   record's clause, in a second commit on the owner's go, its cases staying as the watch and
   check 58's kept list updated; a file it does not follow keeps its lines with the number.
2. `opus`.

**Case for (1).** A weaker model following a line unaided is the stronger evidence that the
line is a standard everyone has, not a rule that needs stating; a stronger model following it
says less. Sixty `haiku` runs cost about what ten `sonnet` runs do. The clause already written
decides the cut, so the measurement adds a number and no new argument.

**Case against (1).** `haiku` may fail a trap for reasons that are not the line's — a weaker
model builds less — and a with-arm below 3 of 3 then says nothing about the rule. A kept file
that is cut becomes an empty file, which the installer still installs.

**Decision.** We chose (1), E14's default; the cut, if any, is a second commit after the
owner's go.
**Falsifiability.** We would stop the measurement and keep every file if the with-rule arm of
any file reads below 2 of 3 on `haiku` — then the model is not following the line even when
told, and "unaided" has no meaning on it. A cut line returns by the measured-cuts clause (its
case below 2 of 3 in a release run).
**Fired-if.** manual

---

## Decision: The release run accepts a fifty-ninth case   (→ REQ-6)

**Context.** The release run is 58 cases, $16.38 at 4.10.0 and $16.52 at 4.9.0, every case
every release. The probe case (E11) makes 59; the eve cases cost about $0.40 each per three
runs.

**Alternatives.**
1. Every case, every release: 59 cases, about $17.80.
2. `--group` on the groups a release changed.

**Case for (1).** A release run that skips a group cannot say a case that passed before still
passes (exit checklist line 3), and the watch cases exist to be run when nothing near them
changed. The cost of the 59th case is one more `eve` run per release.

**Case against (1).** $17 per release is the largest single cost of a sprint, and most of it
re-measures what did not change.

**Decision.** We chose (1), E19's default.
**Falsifiability.** We would move to (2) if a release run passes $25 or the case count passes
80 — then the suite has outgrown "every case, every release".
**Fired-if.** manual
