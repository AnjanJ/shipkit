# Intake: The gate's blind spots

> Intake taken on 2026-10-08.

## Request
Sprint 12 of the field plan (`docs/plans/field-sprint-plan.md`): close the four findings about the
gate, the reviewer and the briefs that the real run on `rails_error_dashboard` left — a `Fired-if`
that fires (or errors) before the code it measures exists, `.shipkit/` files the reviewer and
`brief-verify.sh` call "outside the spec", exit codes lost to pipes and output typed from memory
in the ship report, and the ignored-files question open since 4.0. Release 4.5.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; no product file.
- **Open specs:** none; all thirteen specs are `Status: shipped`. `run-wounds` lists "the reviewer
  and `brief-verify.sh`; `decision-check.sh`" as out of its scope — they are this sprint's.
- **Decisions:** 0001 (map optional), 0002 (`nontrivial` sentence), 0003 (overlay skills in core)
  — none is touched. `decisions-and-digest` shipped `decision-check.sh`'s four result words; this
  sprint changes what the `ERROR` line carries and what a `Fired-if` line may be followed by,
  not the words.
- **An agent file changes.** S12-T2 edits `plugins/shipkit/agents/reviewer.md` (step 4's
  exclusion). The plan names it; the `reviewer-all-met` and `reviewer-missing-req` cases guard it.

## Answers
1. **S12-T3's Done-when is a headless `/shipkit:ship real-run` on this branch (a dry run, its
   report deleted after reading). The sprint's budget line names "the reviewer group once (about
   $1), the release run" and not this run (about $1–2 of `sonnet`). Is it in the budget (rule
   15)?** — **Yes**, the owner, 2026-10-08: the dry run is in the budget.
2. **Field notes §6 item 2: `spec-check.sh` cannot check a draft, so the spec skill flipped the
   status to run it. S12-T1 does not touch `spec-check.sh`. Leave that as it is (recommended —
   scope; a `--as-open` flag is a Sprint 13 candidate), or add it to T1's Files?** — **Leave it
   out**, the owner, 2026-10-08.

## Assumptions made
- `decision-check.sh` strips only a trailing `<!-- … -->` from a `Fired-if` command; anything
  else after the command is still part of it, as today.
- The `ERROR` line gains the first line of the command's stderr after the exit code; the four
  result words and the summary line are unchanged, so smoke check 35 and the ship skill's "no
  `FIRED` line" reading still hold.
- The spec skill runs `decision-check.sh . --run` once, after `design.md` is written, as it runs
  `spec-check.sh`; a `FIRED` or `ERROR` on a record just written is fixed before hand-over. The
  spec skill's headless run in smoke check 22 is not extended; REQ-3 is prose.
- The reviewer's allow-list and `brief-verify.sh`'s are the same set (C5's default): everything
  under `.shipkit/` except another spec's folder.
- The ship skill captures exit codes with `; echo "exit $?"` where a command's output is read
  directly, and with a scratch file where the output is long; the report's evidence blocks say
  the output is pasted. The 4.3.0 and 4.4.0 reports are left as they are.
- C6 is closed by record: `brief-verify.sh` does not see ignored files, by design; one header
  sentence says so and what to read instead. No smoke case is built for it.

## Out of scope
Rule text; trap-2 cases; `spec-check.sh` (question 2); the elders; a
second real run; a draft-tolerant `spec-check`; the waived-and-unmet reviewer row (§8a, mild).
