# Intake: The run's debts

> Intake taken on 2026-10-10.

## Request
Sprint 17 of the second-run plan (`docs/plans/second-run-sprint-plan.md`), the plan's first:
fix what the second real run (`docs/design/field-notes-4.9.md`) found in setup, the brief and
the gate, each with a smoke check written first; close the one finding that is the platform's
by record; remove the two cache directories the owner names, each on its own yes. Release
4.10.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; no product file.
- **Open specs:** none; all eighteen specs are `Status: shipped`. `install-lifecycle` (DR-4)
  gave the stack section its markers and sha — E1 builds on them and changes neither.
  `gate-blind-spots` REQ-9 asked for the reviewer's reply pasted and the gate has condensed it
  twice since (4.7.0, 4.9.0) — E7 changes the mechanism, not the requirement.
  `product-intake-brief` (REQ-18 to REQ-26) owns `brief.sh` and `brief-verify.sh`; E4 adds a
  stderr line and E5 widens the always-allowed list the way `gate-blind-spots` REQ-5 did in
  4.5.0; the brief on stdout is byte-identical.
- **Decisions:** 0001, 0002, 0003 untouched. The plan's E8 is closed by record in this
  sprint's `design.md`, not as a project decision: it binds no code.
- **Harness changes:** two new smoke checks (60, 61); checks 25, 26, 27, 29 and 53 extended;
  no lint change; no eval change; no rule file changes (the three injected rules stay at
  2,979 bytes). Agent text changes: `agents/reviewer.md` (E5's list, E6's sentence). Skill
  text changes: `setup` (E1 relay, E3 backup rule), `ship` (E7 step 4). Script changes:
  `install-stack.sh`, `install-rules.sh`, `brief.sh`, `brief-verify.sh`.

## Answers
1. **The plan's E1 to E8 and E18 F1, F2, every default, and the sprint's budget (two gate
   runs ≈ $1, the release run ≈ $16.50)?** — **"approved"**, the owner, 2026-10-10.
2. **E18's precondition: does the owner's interactive session report the 4.9.0 root?** —
   **Yes**: this session's hook line read `plugin root is …/4.9.0` at start (2026-10-10). F1
   and F2 still wait for S17-T5 and a yes each.
3. **E3's check: the plan's check 61 says "a tracked old backup → it stays at the root and
   `git status --short` is empty after setup", which only a live `/shipkit:setup` run shows.
   Setup is a seven-phase skill on sonnet (55 s in the real run, more in the smoke sandbox),
   and its backup phase is model-driven prose. Is check 61 a grep of the skill's text (the
   `git ls-files --error-unmatch` command and the "left in place" sentence) with the
   behaviour measured on the third real run (S19-T3, E17 says the run reports whether E1 to
   E7 held), or a live setup run inside the smoke suite?** — *assumed: the grep; see
   "Assumptions made". The owner can change it at approval.*
4. **E7's measure: the plan names a headless gate dry run at S17-T4 (≈ $0.50) whose report
   is compared with the review file. Smoke check 29 already runs the gate twice on sonnet
   against the `reviewer/all-met` fixture. Is the dry run check 29 run alone at T4, extended
   to assert the pasted reply, rather than a new check with a flag that keeps the file?** —
   *assumed: yes; the budget line is unchanged (check 29 alone is the ≈ $0.50 run).*

## Assumptions made
- **Check 61 greps the skill's text for E3**, and the behaviour is measured on the third
  real run: a live setup run in the smoke suite would cost ≈ $0.50 and two to three minutes
  per smoke run for one phase of seven, and the smoke runner's sandbox has no tracked backup
  to begin with. The `install-rules.sh` half of check 61 (E2) runs the script.
- **Check 29 is E7's dry run.** Its first run (the complete feature, READY) already produces
  a report; the extension asserts the report's step 4 block holds the reviewer's `## Review:`
  heading, one `| REQ-N |` row per requirement in the fixture's spec, the `Requirements: …`
  count line and the `VERDICT:` line — the reviewer's fixed shape, which a summary collapses.
  The reply is not compared byte for byte with the review file: the gate removes its own
  scratch files (4.7.0), and a flag to keep one for a test would be a change to the gate for
  the test's sake.
- **The next smoke check numbers are 60 and 61** (check 59 is the last at 4.9.0); T3 and T4
  extend 25, 26, 27, 29 and 53 and add none.
- **E1's heading match is the section's first `## ` line**, compared whole (`## Elixir-Specific`),
  against `CLAUDE.md` lines outside shipkit's own markers. A heading inside a shipkit block
  from an earlier run is shipkit's and does not count (plan §6, first risk).
- **E2 compares basenames at `.claude/rules/` top level only** — the field note's shape
  (`dependencies.md`, `migrations.md`, `testing.md` beside `shipkit/`) — against the files
  `install-rules.sh` installs (the core rules). Overlay rules installed by `install-stack.sh`
  are not compared: nothing in the run showed that shape.
- **E4's line goes to stderr** so `brief-verify.sh`, which reads `brief.sh`'s stdout for the
  Files list, and any caller that captures the brief see the brief unchanged.
- **E5 adds both directories** although `.shipkit-baseline/` is ignored when setup's
  `.gitignore` lines are in place (`brief-verify` never sees it then): a project that declined
  the lines, or one set up before 3.1, has it tracked or untracked and visible.
- **The plan file is committed at T0 with an approval line** under its Status, as the
  portfolio plan was at S14-T0.
- The three leaked-wait quotes for E8's record are the intake's (§4.1), the gate's (§9.3)
  and the 4.9.0 release gate's (`CHANGELOG.md` 4.9.0, "What using it for real showed").

## Out of scope
The graders and `eve` (Sprint 18, E9 to E14); the `SessionEnd` hook, the refusal text and the
third real run (Sprint 19, E15 to E17); `agents/eve.md`, `agents/grandfather.md`, every rule
file; the three findings that are `office_bestie`'s own; `brief-verify.sh --since` (E4's other
option); a gate that re-checks MET citations (E6's other option); the "do not narrate waiting"
sentence (E8's other option); `.claude/rules/shipkit/` rules that `install-stack.sh` writes
(E2 compares core rules only); any deletion E18 F1 and F2 do not name.
