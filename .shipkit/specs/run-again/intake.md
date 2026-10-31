# Intake: The run again, and 5.0.0 (Sprint 22)

> Intake taken on 2026-10-31, by hand from the approved thinning plan.

## Request
Pay the four one-line debts the 4.12 run found and settle the headless wait; run the same loop
on the same project with the thinned plugin and write down what changed and what a session
there costs; write the roadmap for the plan after; release 5.0.0
(`docs/plans/thinning-sprint-plan.md`, Sprint 22, W5, W11, W12, W13, W14).

## Serves goal
The plan's §0 table, read for the first time on a real project: what a session on `linkshort`
pays on the thinned plugin against the 4.12 run, and whether the thinned loop still does the
same nine steps. One release at the end of three sprints (rule 22).

## Conflicts found
- `.shipkit/specs/run-debts/design.md`, "The leaked wait sentence is closed by record": W14 may
  reopen it. Its condition is an interactive session; W14 writes in a headless one. Reopened
  only if the clause says so.
- W13 and W6: the plan reads W13's `.claude/skills/` line on the re-run, but since W6 a headless
  setup installs no skill, so the run cannot show it. The design says so; the smoke check proves
  the line.
- W13's wording and `brief-verify`'s own rule: `.claude/rules/shipkit/` is allowed because only
  the installer writes there, and `.claude/skills/` is also where a project keeps its own
  skills. The design narrows the line to the skills the manifest lists.
- `.shipkit/specs/always-on/` and `overlays-and-eve/` stay open until 5.0.0, and always-on's
  T-MERGE is unticked though merged (`0615060`); the release ticks it and gates all three.
- No other open spec.

## Answers
1. Which project? — `~/code/linkshort`, W5's choice: clean at `a5f1eb8`, no `shipkit/real-run-*`
   branch.
2. Is the run's request the same? — Yes: link expiry, TODO.md item 1.
3. Does the wait's sentence ship if the runs do not show the wakeup? — No: W14's clause.
4. Is anything the run finds fixed? — No (W5, rule 6): each finding seeds the plan after.

## Assumptions made
- `scripts/smoke.sh` holds 205 checks and `plugins/shipkit/evals/` 60 cases: the plan's 59 plus
  W2's `rules/care`.
- Branch `claude/wizardly-fermi-u6f5w2` is on the remote, as W12's F3 says. Two other old branches
  there (`feat/superpowers-learnings`, `fix/report-absolute-path`) are not this plan's.
- The cache directories `shipkit/4.11.0` and `shipkit-workflows/3.0.0` are not this spec's: the
  owner's yes stands, for a session whose hook line reads 4.12.0.

## Out of scope
Anything the run finds; the two graders 4.11.0 found narrower than their line; smoke checks
`agents` and `ship-gate`'s open watches (they go on the ROADMAP); `map_read`'s Grep gap; the
always-on surface, the overlays and `eve` (Sprints 20 and 21); a new eval case.
