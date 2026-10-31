# Intake: What a decision binds (Sprint 23)

> Intake taken on 2026-10-31, by hand from the approved binding plan.

## Request
Make a recorded decision hold: every live decision of a feature reaches every task's brief, the
reviewer reads what a decision turned down, and a gate does not say READY on a decision the code
contradicts (`docs/plans/binding-sprint-plan.md`, Sprint 23, G1, G2, G3, G9).

## Serves goal
The ROADMAP's north star: shipkit "remembers what was intended" and "checks the result against the
intent". This repository has no `.shipkit/product.md`, so the goal is the plan's §0 table.

## Conflicts found
- `review-and-ship/REQ-6` defines the verdict by requirements alone, and both `reviewer` cases cite
  it. G3 changes that rule, so REQ-6 is amended in place with a note, as `review-and-ship/REQ-19`
  was in Sprint 21. `review-and-ship/REQ-5` (list every decision not followed) stands.
- Smoke's `brief` check asserts that a decision citing another requirement is left out: its
  fixture's "Describe refunds in one README section", on T3's brief. REQ-1 reverses that, so the
  assertion flips in the same commit. No requirement in any spec fixes the selection rule;
  `product-intake-brief/REQ-18` names only the heading, which stays.
- `agents/reviewer.md:89` says "the ship gate weighs them". `skills/ship/SKILL.md` has no such step.
  The plan's G3 record replaces the sentence.
- The thinning plan's §5 kept the reviewer and the gate unchanged. That bound that plan only.
- `scripts/lint.py`'s ceiling comment records three raises. G9 makes no fourth.
- `run-again`'s "The gate starts a silent reviewer once more" stands; this spec adds a clause to
  the same agent, and §6 of the plan names the risk.
- No open spec.

## Answers
1. Which decisions reach a brief? — Every live one of the feature, by title (G1, approved).
2. Does a contradicted decision fail the gate? — Yes, through the reviewer's verdict (G3, approved).
3. Does the fix ship if the baseline shows nothing? — Yes, on `field-notes-5.0.md` §8.1's one run,
   and the record says the number shows nothing (the plan's §3).
4. Can a case run `brief.sh` in the sandbox? — It need not: the fixture runs it and leaves the
   output for the agent, as `with-rule.sh` reaches into the plugin from a fixture.

## Assumptions made
- `linkshort`'s `69578a5` and `cc4619c` are unreachable objects, readable on 2026-10-31. T1 copies
  the design's shape into the fixture before anything else.
- The fixture needs no network: the agent writes the code and does not run it, as `trap2/go-mod`'s
  prompt says.

## Out of scope
Sprints 24 and 25: the graders, `map_read`, `reports.md`, the Care line, the four debts, the run,
5.1.0. Printing a decision's alternatives in the brief. A `Governs:` field. Any change to
`skills/ship/SKILL.md`. Why the model writes `placeholder`.
