# Intake: Second traps and the elder's first step

> Intake taken on 2026-10-08.

## Request
Sprint 13 of the field plan (`docs/plans/field-sprint-plan.md`): give the two biggest unmeasured
claims their numbers — path-scoped loading in a headless session, and the sixteen rules whose
4.2.0 case passed without their text — try the one experiment 4.1 named (the elder's step 1),
reword the one rule line that stopped work (`gemfile.md`'s lock-diff step), run the XL history
case on a "wip" log, do the housekeeping the owner approves row by row, and write the roadmap
for the plan after. Release 4.6.0. T0 also makes room: the evals README's five baselines move
to `docs/design/eval-history.md` and lint check 17's ceiling becomes 163,840 (C1).

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; no product file.
- **Open specs:** none; all fourteen specs are `Status: shipped`.
- **Decisions:** 0001 (the map is optional) is the one this sprint can touch — T4 appends the
  measured read rates to it, nothing else; 0002 (`nontrivial` sentence) and 0003 (overlay
  skills) are untouched. The standing rule since the trim audit — no rule text changes on a
  sprint's own measurement — is C8's default and holds; C10's `gemfile.md` edit rests on the
  4.2.0 measurement, which the rule allows.
- **An agent file may change.** T4 edits `agents/grandfather.md` step 1 by at most two
  one-sentence attempts, each measured, kept only on the owner's go (C9, rule 6).
- **A rule file changes.** T3 edits one line of `stacks/rails/.claude/rules/gemfile.md` (C10).

## Answers
None asked now. C1 and C7 to C13 were approved at their defaults with the plan (2026-10-08);
T6's rows D1 to D5 are each asked at T6; T4's "keep" is asked when an attempt qualifies; T2's
table is shown before T3 starts.

## Assumptions made
- The README's "Two things checked before the XL cases were written" section stays: it is a
  note on how the eval tool behaves, not a reading. The five baselines and the 3.2.0 shrink
  section moved; the pointers to `eval-history.md` are one paragraph.
- The sixteen trap-2 cases follow the 4.2.0 case shape (`prompt.md` + a regex grader on the
  written file, scaffold = the 4.2 fixture + `with-rule.sh <rule>`), one folder each under
  `evals/trap2/`, named by rule.
- "The second named line" is the rule file's second bullet (or second sentence of a one-bullet
  rule); T2's results doc names the line it chose for each rule.
- The without arm is a scratch copy of the plugin with `NO_RULE` defaulted, as the 4.2.0
  arms were selected (no env reaches a scaffold).
- The read rate is counted from traces: a `Read` tool_use whose input path ends in
  `PROJECT_MAP.md`, main session or subagent; `trace-tools.sh` gains the column if its Check
  first needs it.
- The `--wip` generator keeps every byte of every file and every tree hash; only commit
  messages change. If the Check first finds otherwise, a second fixture directory is generated
  and the comparison is between fixtures, as the plan's fallback says.
- Housekeeping rows (C12) are commands run only after that row's yes; D4 (sprint branches)
  waits for `v4.6.0` and is either a commit on `main`'s next branch or the owner's own hand —
  T6 says which.

## Out of scope
Cutting or trimming any rule (C8); a multi-project fixture for eve (C11); a second real run;
`spec-check` on drafts; a new skill or agent; anything C12 does not name.
