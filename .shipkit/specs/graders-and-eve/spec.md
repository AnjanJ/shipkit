# Spec: Graders and `eve` (Sprint 18, release 4.11.0)

> Spec accepted at commit `c99ddcc` on sprint-18/graders-and-eve (2026-10-10).
> Status: shipped
> Paths: plugins/shipkit/evals/, plugins/shipkit/agents/, plugins/shipkit/rules/, plugins/shipkit/stacks/, scripts/, docs/design/, .shipkit/decisions/, .shipkit/specs/measured-cuts/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Act on what the measurements said and the releases carried. The portfolio measurement
(`docs/design/eval-results-4.9.md`, "The three readings", 3) left three things: `payments`'
grader insists on a manifest where the question asked where payments are handled, so one
right reply per arm fails; `eve` says "not recorded" and then offers motives marked as guesses;
and the one map she read was reached because a grep landed on a shared word. The 4.8.0
release carried two grader notes: `trap2/notebooks`' regex names two tools where its line
asks for an outcome, and `trap2/react` once built nothing because the always-on rule asked
for a spec first. Each grader is corrected on its trace evidence with the old counts kept
beside the new; `eve` is measured, given one sentence, and measured again, the sentence
staying only if the number says so; the reworded why is a probe case whose number is kept
whichever way it falls; `react` is closed by record. Last, the five rule files kept whole by
the measured-cuts record are measured on a third model, `haiku`, and each is cut or kept by
that record's own clause, the owner seeing the table first.

Source: `docs/plans/second-run-sprint-plan.md`, Sprint 18 (S18-T0 to S18-T5), decisions E9
to E14 and E19; `docs/design/eval-results-4.9.md` reading 3; `docs/design/eval-results-4.8.md`
"The two runs below 3 of 3"; `.shipkit/specs/measured-cuts/design.md`, the first decision's
Falsifiability; `ROADMAP.md` "Still open after Sprint 16".

## User stories

- As the owner reading a release run, I want a grader to fail a reply only when the reply is
  wrong, so that a drop below the threshold means the plugin changed, not that the model
  cited the better file.
- As a user asking `eve` why a project did something nobody recorded, I want "not recorded"
  and nothing invented after it, so that I am not handed three plausible reasons for a
  decision the repository never explains — and I want that measured before the agent's text
  changes.
- As the owner deciding what a rule file is worth, I want the five kept files measured on a
  weaker model before any line is cut, so that a cut rests on three models' numbers and a
  kept line carries the number that kept it.

## Requirements (EARS)

### `payments` graded on what the question asked (S18-T1)

- **REQ-1.** The `eve/payments` grader's evidence clause shall accept a reply that cites a
  dependency manifest (`Gemfile`, `mix.exs`) or a file that handles the provider
  (`app/services/stripe_charge.rb`, `lib/pulse/billing/stripe.ex`), and its three other
  clauses (`shopfront` with Stripe, `pulse` with Stripe, `insight` none) shall be unchanged;
  the pattern shall compile as a JavaScript `RegExp`.
- **REQ-2.** `docs/design/eval-results-4.11.md` shall hold the `payments` counts on the
  three arms (three maps, one, none) under the corrected grader beside the 4.9 counts, with
  `map_read` per cell, and its reading shall be written after the traces were read.
  [untested: prose, verified by reading]

### `eve` on her guesses: measure, one sentence, measure (S18-T2)

- **REQ-3.** Where the no-map `why` arm under the strict wording reads at least 2 of 3 with
  the sentence and the three-map arm still reads 3 of 3, `agents/eve.md`'s verify step shall
  carry one sentence telling `eve` that a why no map, record or commit holds is answered
  "not recorded" with no motives of her own; where either number falls short, the agent shall
  be unchanged and the design record shall say which number failed. [untested: model
  behaviour, measured once on scratch arms; the cells are in `eval-results-4.11.md`]
- **REQ-4.** The shipped `eve/why` grader shall be byte-identical to its 4.10.0 form; the
  strict wording shall live in `eval-results-4.11.md` and be applied only through a scratch
  copy. [untested: verified by `git diff v4.10.0 --stat -- plugins/shipkit/evals/eve/why`
  being empty at the gate]
- **REQ-5.** Decision 0001's `eve` note shall gain one line with the sentence's fate and the
  three cells. [untested: prose, verified by reading]

### The reworded `why` probe (S18-T3)

- **REQ-6.** The suite shall hold a probe case `eve/why-reworded` on the three-map portfolio
  fixture whose question asks why `pulse` stopped logging everyone out at three in the
  morning and since when — words that `pulse`'s `PROJECT_MAP.md` Evolution section does not
  hold (`grep -ci` of `three`, `morning`, `logging`, `everyone` against the generated map is
  0) — graded as the `why` case is (the reason and the move, or a plain "not recorded" with
  no reason invented); the README shall say what it watches, and `plugins/shipkit/evals/`
  shall stay at or under 196,608 bytes.

### `notebooks` widened on its trace; `react` closed by record (S18-T4)

- **REQ-7.** The `trap2/notebooks` grader shall match, beside `nbstripout` and `nbconvert
  --clear-output`, a Makefile that clears cell outputs by nulling `outputs` or
  `execution_count` inline or through a script whose name says it cleans or strips notebook
  outputs; the pattern shall compile as a JavaScript `RegExp`, and the 4.6 and 4.8 counts
  shall stand beside the new one in `eval-results-4.11.md`.
- **REQ-8.** The sprint's `design.md` shall record `trap2/react`'s no-build run as closed by
  record, with the case's counts in the five runs since 4.6.0 and the condition that reopens
  it, and the ROADMAP's item shall point to the record. [untested: prose, verified by reading]

### The five kept files on a third model (S18-T5)

- **REQ-9.** `eval-results-4.11.md` shall hold one table over the five kept files
  (`migrations`, `monorepo`, `testing`, `package-json`, `rails`) with their trap-1 and trap-2
  cases on `haiku`, with the rule and without, no cell empty, every count read from traces,
  and the reading written after the traces. [untested: prose, verified by reading]
- **REQ-10.** The measured-cuts record shall gain an appended note saying, per kept file,
  whether `haiku` followed both lines unaided 3 of 3 in both arms and whether the lines were
  cut or kept; the five rule files and smoke check 58's kept list shall agree with the note.

## Release steps (not requirements)

- The gate (`/shipkit:ship graders-and-eve`) answers `READY`; the report is committed.
- Release as 4.11.0; the sprint exit checklist holds (evals at 59 cases, E19); the release
  run is recorded in `docs/design/eval-history.md`; the pull request is merged after a green
  check; tag `v4.11.0`.
- F4: this sprint's branch after the tag, its own yes; F5: the owner's cache updated to
  4.11.0, its own yes.

## Out of scope

The `SessionEnd` hook, the refusal text, the third real run and the roadmap for the plan
after (Sprint 19); `agents/grandfather.md`; the `why` case's shipped grader; a step-0
sentence for `eve`; an `llm` grader for `notebooks`; a prompt line for `react`; `opus` for
the third-model measurement; the `jobs` case; `--group` on changed groups only; every rule
file outside the five kept, and any of the five without the owner's go after the table; the
fourteen watch cases of the seven cut files.
