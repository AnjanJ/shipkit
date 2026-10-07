# Intake: Loose ends and a real run

> Intake taken on 2026-10-07.

## Request
Sprint 10 of the evidence plan, the last one: catch the gate's first-run misses (missing
requirement citations) with the two-second check instead of the ten-minute gate; close the
overlay-skills question open since 3.0 by record (B9); run the whole loop once on a repository
that is not shipkit and write field notes, fixing nothing (B10); delete what the owner has
approved deleting, each its own yes (B11 to B13); update the roadmap. Release 4.3.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; there is no product file.
- **Open specs:** none. All eleven specs under `.shipkit/specs/` are `Status: shipped`.
- **Decision 0001** (the map is optional): not a conflict. The real run uses whatever the
  named repository has; the notes record whether a map was built and whether anyone read it.
- **Decision 0002** (`rules/nontrivial`, one sentence kept): not a conflict; its clause is
  checked on this sprint's release run and the notes say what it showed.
- **The plan's S10-T1 branches do not match the history (rule 6: say so first).** The plan
  says: run the plain `spec-check.sh .` at `ceef7f5^`; if it already fails, write a one-line doc
  note; if it passes, extend "the scan set or the status set". The history already shows what
  the Check first will say. At `ceef7f5^` the spec `trim-and-docs` was `Status: open`; the
  plain run asks an open spec for tasks only, never for tests — by design, asserted by smoke
  check 19 ("open spec is not asked for tests yet", `spec-contract/REQ-3`). The gate's step 1
  runs `spec-check.sh . <slug> --as-shipped`, which has existed since 3.5.0 (`feab49b`) and is
  exactly what caught the four uncited requirements. So the check existed, and the plain run
  cannot be made to fail on them without breaking a shipped requirement. Neither plan branch
  fits: the gap is that nothing shows the debt before the gate runs. Question 2 below.
- **The plan's S10-T2 count.** "Rails ships five" — Rails ships six (four invocable skills and
  two knowledge bases); the total of eleven is right. Recorded in 0003.
- **B11's count.** The plan says "the seven merged `sprint-N/*` branches" and its Done-when
  says "only this plan's branches" remain. Nine exist today (`sprint-1` to `sprint-9`).
  Assumption: B11 covers `sprint-1` to `sprint-7`; `sprint-8` and `sprint-9` are this plan's
  and stay. Each deletion is still its own yes at T4.
- **B12's precondition holds already.** No smoke check reads `/private/tmp/e-*` (grep of
  `scripts/smoke.sh` for `private/tmp` and `/tmp/e-`: nothing); check 40 uses a synthetic
  trace. 354 sandboxes exist today, not the plan's 48 or the handoff's ~290.

## Answers
1. **Which repository for the real run (B10), and may the plugin cache be updated from 3.1.0
   to 4.2.0 before it?** — *unanswered.* S10-T3 cannot start without the name. The B10 record
   in `design.md` names the repository once given.
2. **S10-T1's remedy, given that `--as-shipped` already catches the gap.** Options: (a) the
   plan's doc-note branch — one sentence in the ship skill and the release task, "run
   `spec-check.sh . <slug> --as-shipped` before the gate"; (b) the plain, slug-less run prints
   an information line `PENDING-TEST <slug> REQ-N` (exit unchanged, 0) for each open spec's
   requirement that no test cites yet, so the debt is visible every time anyone runs
   spec-check during the sprint, plus the sentence of (a); (c) a lint check that runs
   `--as-shipped` on open specs — red for the whole sprint, so rejected. Recommended: (b).
   — **(b), approved by the owner on 2026-10-07** with the requirements.

## Assumptions made
- B9 at its default: the overlay skills stay in core; the release is 4.3.0, not 5.0.0.
- The Check first of S10-T1 is still run as the plan writes it, in a scratch worktree at
  `ceef7f5^` that the task removes; its output goes in the commit, whatever it says.
- The real run's branch in the named repository is approved by the owner before the first
  commit there; nothing there is merged by the executor.
- The plugin cache update is the first step of S10-T3 and its own field-notes section.
- The ROADMAP heading "Sprint 8 SHIPPED 2026-10-07; Sprints 9 and 10 next" (line 32) is stale
  since 4.2.0 and is corrected in S10-T5 with the rest of the roadmap.
- No new eval case; `plugins/shipkit/evals/` has 1,641 bytes of room and no task needs them.

## Out of scope
Any edit under `plugins/` during the real run; rule edits; new eval cases; the sixteen rules
that pass without their text; measuring path-scoped loading; the map-reading rate of the elders;
moving the overlay skills (the other B9 option); blanket deletions.
