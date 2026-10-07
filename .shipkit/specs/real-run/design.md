# Design: Loose ends and a real run (Sprint 10)

## Approach

Five small tasks, each its own commit, in the plan's order. One of them changes a shipped
script (`spec-check.sh` gains an information line); one writes a project-wide decision record;
one runs shipkit on somebody else's repository and brings back notes; one deletes what the
owner has already approved deleting; one leaves the roadmap pointing at evidence. Nothing under
`plugins/` changes in the real run, and no measurement runs are planned — the release run is
the only eval bill.

---

## Decision: The citation debt is shown, not enforced, before the gate   (→ REQ-1, REQ-2, REQ-3, REQ-4, REQ-5)

**Context.** Both 4.0.0 gates failed their first run on requirements with no cited test. The
plan's Check first (plain `spec-check.sh .` at `ceef7f5^`) will exit 0: the spec was `open`,
and an open spec is asked for tasks only — `spec-contract/REQ-3`, smoke check 19. The flag that
asks an open spec for tests, `--as-shipped`, has existed since 3.5.0 and is the gate's step 1;
it is what caught the gap. So the check exists; it was not run before the gate.

**Alternatives.**
1. An information line: without a slug, the plain run prints `PENDING-TEST <slug> REQ-N` for
   each open spec's uncited requirement, exit unchanged. Plus one sentence in the ship skill:
   run `--as-shipped` before the gate.
2. The sentence only (the plan's doc-note branch).
3. A lint check that runs `--as-shipped` on every open spec — red from the first commit of a
   sprint to the last, so it would be ignored.
4. Make the plain run fail on an open spec's uncited requirement — breaks a shipped
   requirement and the sprint rhythm (tests land task by task).

**Case for (1).** About eight lines in a script the exit checklist already runs; the debt is
on screen every time anyone runs spec-check during the sprint, which is the moment it is cheap
to fix; a smoke check can prove it; the shipped meaning of exit 0 on an open spec is kept.

**Case against (1).** One more line kind to read (`WAIVED`, `SKIPPED`, now `PENDING-TEST`), and
a line that is information only can be ignored as easily as a flag can be forgotten. The
sentence in the ship skill is the second guard. If the Check first contradicts the history
(REQ-5), (2) is what lands.

**Decision.** We chose (1), approved by the owner on 2026-10-07 (intake question 2), subject
to the Check first's actual output (REQ-5).
**Falsifiability.** We would move to (3) if a release gate after 4.3.0 fails its first run on an
uncited requirement despite the `PENDING-TEST` line having been printed for it.
**Fired-if.** manual

---

## Decision: The stack overlay skills stay in core   (→ REQ-6, REQ-7, REQ-8)

The full record is `.shipkit/decisions/0003-overlay-skills-home.md` (project-wide, so it lives
standalone); this is its summary.

**Context.** The 3.0 split sorted every skill by one rule (core produces, reads or installs
knowledge; workflows tell Claude how to work) and deferred the eleven skills inside the stack
overlays. Read as text, seven of them are how-to-work. Read as delivery, all eleven are files
`install-stack.sh` copies into the project, cost no plugin context, and none refers to
`shipkit-workflows`.

**Alternatives.** (1) Stay in core. (2) Move the invocable ones to `shipkit-workflows`; 4.3.0
becomes 5.0.0. (3) A `workflow-skills/` subfolder installed only when workflows is present.

**Case for (1).** The rule's third verb is *installs*, and the installer is core; a move saves
no context in any session and breaks the core-only install for a file move nobody asked for.

**Case against (1).** Core's pitch now carries a Rails release workflow; the review-standards
pair is split across the two plugins; the decision is taken before the first real run.

**Decision.** We chose (1) — B9's default, approved by the owner on 2026-10-07.
**Falsifiability.** We would reverse this if two or more overlay skills come to call a
`/shipkit-workflows:*` skill by name, or two independent core-only users report unwanted
workflow skills from setup.
**Fired-if.** `test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2`

---

## Decision: The real run is on the owner's repository, notes only   (→ REQ-9, REQ-10, REQ-11)

**Context.** Every run of the loop so far has been on shipkit itself or on its fixtures. The
installed plugin in the owner's sessions is 3.1.0, so the real run also tests the update path.
B10 is approved; the repository is still to be named.

**Alternatives.**
1. A repository the owner names (B10): a small active project of theirs with a test suite,
   on a branch they approve; the loop once, end to end, with the released 4.2.0 plugin from
   the marketplace cache; notes in `docs/design/field-notes-4.3.md`; nothing fixed in the same
   task.
2. The XL fixture or `sample-app` as "the real project" — already measured; it would show
   nothing the evals have not.
3. Fix each awkwardness as it is found, in the same sprint — the notes become a changelog of
   fixes and the run stops being a measurement.

**Case for (1).** It is the only arm that has not been run. Notes-only keeps the observation
clean and gives the next plan its seed, which is what B10 was for.

**Case against (1).** One project, one run, one model: anecdote, not measurement — the notes
say so in their first line. The owner's time is spent too (approving a branch, naming a change,
answering the intake's questions). The named repository: *to be filled in at T3 with the
owner's answer to intake question 1.*

**Decision.** We chose (1).
**Falsifiability.** We would re-run on a second repository before the next plan if the notes
list fewer than three awkwardnesses, which would mean the run was too small to learn from.
**Fired-if.** manual

---

## Data / interface changes

- Changed: `plugins/shipkit/scripts/spec-check.sh` prints `PENDING-TEST <slug> REQ-N` for an
  open spec's uncited, unexcused requirements when run without `--as-shipped` (REQ-1 to
  REQ-3); exit status unchanged. `scripts/smoke.sh` gains check 48 for it.
  `plugins/shipkit/skills/ship/SKILL.md` gains one sentence (REQ-4).
- New: `.shipkit/decisions/0003-overlay-skills-home.md` (REQ-6);
  `docs/design/field-notes-4.3.md` (REQ-9).
- Edited documentation: `docs/design/two-plugin-split.md` §5 item 6 (REQ-7); `ROADMAP.md`
  (REQ-8, REQ-10, REQ-12 to REQ-14); `GUIDE.md` only under REQ-11.
- Removed outside the tree, each with its own yes: `sprint-1/*` to `sprint-7/*` local and
  remote branches (B11), `/private/tmp/e-*` (B12), the detached worktree (B13).
