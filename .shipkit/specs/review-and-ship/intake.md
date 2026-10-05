# Intake: Reviewer and ship gate

> Intake taken on 2026-10-06.

## Request
Sprint 4 of the quality-gate plan: a `reviewer` agent that checks a branch against its spec
without having seen the implementer's reasoning, and `/shipkit:ship`, one command that says
READY or NOT READY with evidence. Also `/shipkit:escape` for a bug that reached users, and one
line in the Rails overlay's deploy-check and release skills pointing at the gate.

## Serves goal
None — this repository has no `.shipkit/product.md`. The owner chose to record that and move on.

## Conflicts found
- **Non-goals:** could not be checked; there is no product file.
- **Open specs:** `product-intake-brief` is open and does not cover this request.
- **Decision records:** none contradicts it.
- **The plan against what 3.3 shipped:** the plan lets the reviewer mark a requirement `MET`
  only with the file and line of the code *and of the test*, and passes the gate only if every
  requirement is `MET`. A requirement marked `[untested: …]` has no test, so no spec with a
  waiver could pass — and 31 of this repository's 83 requirements are waived. The owner
  resolved it: see the first answer.

## Answers
1. **How should the reviewer and the gate treat a requirement marked `[untested: reason]`?**
   Verify it by reading: the reviewer checks it against the code or prose and marks it `MET`
   with that file and line; no test is needed. The gate report says how many were waived.
2. **Which command is this repository's test command for gate step 2?**
   `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` — the same as CI. The
   smoke suite stays a release step run by hand.
3. **What goes under "Serves goal", with no product file?** "None", recorded as such.

## Assumptions made
- "Treating the spec as shipped" (gate step 1) needs a way to ask `spec-check.sh` for the
  shipped-level check on a spec that is still open: an `--as-shipped` option.
- The gate's test command is asked for once when `CLAUDE.md` does not name one; this
  repository has no `CLAUDE.md`, and S4-T5 will supply the command from answer 2.
- Adding an agent and two skills changes the counts in the marketplace description; the lint
  forces that edit in the task that adds each one.
- The one task handed to an agent as the Sprint 3 trial is S4-T4 (the Rails overlay lines):
  two files, no dependency on the rest of the sprint. Its result is held, not merged, until
  Sprint 4's requirements are approved.

## Out of scope
- Deploying, pushing, merging or tagging from the gate.
- General bug-hunting or style review by the reviewer; that is the built-in `/code-review`.
- A product file for shipkit itself.
