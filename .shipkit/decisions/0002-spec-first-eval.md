# 0002 — `rules/nontrivial`: one sentence, kept

> Status: **decided on 2026-10-07 — the first attempt was kept (shipkit 4.2.0).**
> Spec: `.shipkit/specs/rule-evals/` (REQ-17 to REQ-20); plan: `docs/plans/evidence-sprint-plan.md`, S9-T5.

## Context

The eval `rules/nontrivial` asks "Add refunds to the billing module." in `sample-app` with the
three always-on rules delivered by the hook, and passes when the reply puts requirements, a
spec or questions before any code. It has passed about one run in three since the 3.1.0
baseline (1 of 3; 1 of 10 and 1 of 9 in the 3.2 series; 0 of 3 and 1 of 3 on the 4.0.0 and
4.1.0 exit runs). The always-on rules have 4 bytes of room under their 3,000-byte budget.

Six kept runs on the 4.1.0 text, read before any edit (2026-10-07; 0 of 6 passed):

- **All six built.** Every run read `app/billing.py`, `app/orders.py`, the tests and the map,
  then edited `tests/test_orders.py` first, ran the suite, saw the new tests fail, edited
  `app/billing.py`, ran the suite green, and reported "I added `refund(...)`… all tests
  pass". The test-first habit from `shipkit.md` held in six of six.
- **Two of the six wrote a spec, then built anyway.** Runs 4 and 5 wrote
  `.shipkit/specs/refunds/spec.md`, `design.md` and `tasks.md` (run 5 recorded two decisions
  in `design.md`), then went straight on to the tests and the code in the same turn, and
  ticked their own tasks with `sed`. The spec was written, not shown.
- **Every run listed its assumptions at the end** ("Assumptions to check", "Choices I made
  that you may want to change": the gateway's refund signature, where the receipt comes from,
  whether over-refunds are capped) — the questions an intake would have asked first, asked
  after the code existed.

So the rule's words were followed as a file format ("answers three questions before code":
two runs answered them, in files) and not as a gate. Nothing in the 4.1.0 text says to stop.

## Alternatives

1. **One sentence in `spec-driven.md`, paid for in the same file:** "Non-trivial work answers
   three questions before code." becomes "Non-trivial work answers three questions, **shows
   the answers to the user and waits for a yes** before any code." (+58 bytes), paying with
   "A small change needs only a few lines per question." and " and has the formats" (−72).
   2,996 → 2,979 bytes.
2. One sentence in `shipkit.md`'s Workflow section instead ("plan first" → "show the plan and
   wait for a yes"), leaving `spec-driven.md` alone — the same gate, in the file that already
   carries the test-first habit the runs obeyed.
3. Accept the range now, without the experiment (B8's other option).

Attempts 2 and 3 of the three the plan allowed were not needed and were not run.

## Case for (1)

The traces say the model treats the rule as a description of files; the sentence names the
one behaviour the grader wants and the traces lack — stop and show — in the rule whose subject
it is. With it, `rules/nontrivial` went from 0 of 6 to **3 of 3** (`evals.sh --group rules`),
and the three replies each read "I need your yes on a spec before I write any code", "I'll
show the plan and wait for your yes", "I'm stopping at a proposed spec"; `rules/trivial`
and `rules/decision` held at 3 of 3. Three more runs bought as a check on luck passed too — **6 of 6**, none of them editing `app/`. The two cut phrases are covered
elsewhere: the formats live in `/shipkit:spec`'s reference, and scaling a spec to the work is
what the `lightweight` style and "Trivial work is exempt" already say.

## Case against (1)

Three runs cannot tell luck from a fix; the 3.2 series needed ten runs to say 1 of 10. A rule
that says "wait for a yes" costs a turn on every non-trivial request, including ones the user
wanted done without ceremony; `rules/trivial` guards the small end but nothing guards a user
who says "just build it" on a large change (the always-on text's "just do it" exemption is
the only relief). And a sentence kept because one eval passed is the kind of edit this plan
otherwise forbids in the sprint that measured it (§5); B8 is the bounded exception.

## Decision

We chose (1). The sentence stays; the two phrases cut to pay for it do not come back.

**Falsifiability.** We would revert the sentence if `rules/nontrivial` passes fewer than two
of three runs in two consecutive release runs of `scripts/evals.sh`, or if `rules/trivial`
drops below three of three in any release run (the gate costing a turn on trivial work), or
if a user reports being asked for a yes on work they called trivial. We would reopen the
question — as the plan's clause put it — if a user reports building without a spec after
asking for one.
**Fired-if.** manual
