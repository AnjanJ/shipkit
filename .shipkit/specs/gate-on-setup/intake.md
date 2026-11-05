# Intake: What the gate says about setup (Sprint 26)

> Intake taken on 2026-11-05, by hand from the approved machine plan.

## Request
A first spec after `/shipkit:setup` is reviewed on its own work, not on setup's; the reviewer has a
word for a decision that is half built; and four small debts are paid
(`docs/plans/machine-sprint-plan.md`, Sprint 26, G1, G2, G3).

## Serves goal
The ROADMAP's north star: shipkit "checks the result against the intent". A line the user learns to
skip is a line the gate has stopped saying anything with. This repository has no
`.shipkit/product.md`, so the goal is the plan's §0 table.

## Conflicts found
- `run-debts/REQ-6` and `REQ-7`, and that spec's fifth decision ("Setup's two directories join the
  always-allowed list"), say `CLAUDE.md` and `.gitignore` are reported even when setup changed them.
  Its Falsifiability ("two consecutive real runs report `CLAUDE.md` and `.gitignore` as beyond the
  spec with no change in them but setup's") is met: 4.12 (`field-notes-4.12.md:379`), 5.0
  (`field-notes-5.0.md:203`), 5.1 (`field-notes-5.1.md` §9.1). G2 supersedes the record and amends
  both requirements in place, with a note.
- **G2 as the plan words it does not cover two of the three runs.** On `linkshort` (4.12, 5.0) setup
  *created* `CLAUDE.md` (`git status` → `?? CLAUDE.md`, `field-notes-5.0.md:69`): its project-facts
  half is written by the setup skill's model, outside every shipkit marker. A markers-only check
  would have silenced the 5.1 run's `CLAUDE.md` at most. And setup's `.gitignore` lines are the
  model's too: four named in `setup/SKILL.md:198-205`, five written on the 5.1 run (§2). The design's
  fourth record proposes a digest written when setup ends: a change to G2, which the owner approved
  on 2026-11-05.
- `decisions-bind/REQ-7` says the reviewer marks a decision `contradicted` or `not built`. G3 adds a
  third mark, so REQ-7 is amended in place with a note. `REQ-8` and `REQ-9` (the verdict) stand.
- Smoke `brief-verify` part c2 (`scripts/smoke.sh:1003-1015`) asserts `OUTSIDE CLAUDE.md` and
  `OUTSIDE .gitignore`. With no digest on record that stays true, so c2 stands unchanged.
- Smoke check 68 caps the elixir append at 1,220 bytes; it is 1,137, and `APP_NAME` adds 28.
- Lint check 9 fails a double-brace placeholder that setup's table does not list, so REQ-4 has a test already.
- No open spec.

## Answers
1. Which half of setup's `CLAUDE.md` is setup's? — All of it, when the file is unchanged since setup
   ended: the digest (design, fourth record), approved by the owner as a change to G2.
2. Does a stray `Status:` line fail the gate? — Yes: `spec-check` exits 1 on it (G1, approved), and
   the fix is deleting one line.
3. Does `partly built` change the verdict? — No (G3, approved).

## Assumptions made
- A headless setup may skip the step that records the digest. Then both files are reported, as
  today: the failure is the old behaviour, never a silent pass.
- `git hash-object` is on every machine shipkit runs on: every script already needs git.

## Out of scope
Sprints 27 and 28: the test command on a pinned toolchain, the gate's searches, the headless wait,
the evals' home, the run, 5.2.0. Merging two `## Elixir-Specific` sections (G6). A decision's record
in the brief. Any new always-on byte.
