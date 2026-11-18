# Intake: numbers as data

> Intake taken on 2026-11-18.

## Request

Sprint 31 of `docs/plans/verifier-sprint-plan.md`, "Numbers a script can read", approved by the
owner on 2026-11-17 ("yes to all") and amended on 2026-11-18. Five pieces:

1. S31-T1, the eval ledger: `docs/design/eval-ledger.tsv`, one row per case per run, appended by
   a new `scripts/evals-ledger.sh` that `scripts/evals.sh` calls after a run, with two queries,
   `--below-full <n>` and `--rate <case> [--last <k>]`. 5.2.0 is backfilled from its kept result
   file and 5.1.0 from `docs/design/eval-history.md`.
2. S31-T2, the flake rule: rule 30 written into `eval-history.md`'s head; a note on what the
   records say about `hello`, `intake/limit` and the `agents` and `rules-skip` smoke checks; a kit
   for Sprint 35; and the briefing's gap count made cheap, so that smoke check 30 passes on CI's
   runner without `SMOKE_TIMING=report`.
3. S31-T3, the cases for a diff chosen by the diff: `scripts/evals-map.tsv`,
   `scripts/evals-for-diff.sh` and `evals.sh --for-diff <base>`, with a lint check.
4. S31-T4, room for new cases with no raise: the README's `## Cases` table and its `with-rule.sh`
   section move to `docs/design/eval-cases.md`, and `lint.py`'s "192 KB" is corrected.
5. S31-T5, `Fired-if` commands that read the ledger, in place of `manual`, where a reversal
   condition names an eval case and a count.

The owner's words on how to do it, from 2026-11-17: "lets put things that would cost as for the
end of development", and "do what you think is best". So this sprint starts no paid model run
and changes no existing skill, agent or rule file (the plan's rules 33 and 34).

## Serves goal

None. There is no `.shipkit/product.md` (`.shipkit/` holds `decisions/`, `releases/`, `specs/` and
`state.md`). The ROADMAP's north star is the nearest statement: shipkit "checks the result against
the intent, and refuses to call unfinished work done" (`ROADMAP.md:6-8`).

## Conflicts found

None.

- **Non-goals:** none recorded, since there is no product file.
- **Open specs:** two, and both are touched without being contradicted.
  - `honest-evidence`: its design's seventh record, "On CI the briefing's time is printed, not
    enforced", says the switch comes out of the workflow once, after S31-T2's fix, check 30 passes
    five times running on the CI runner without it. Piece 2 is that fix; taking the switch out is
    the record's own reversal, not a contradiction.
  - `gate-as-software`: its `> Paths:` holds `plugins/shipkit/scripts/` and
    `.github/workflows/`, where piece 2 changes `briefing.sh`, possibly `spec-check.sh`, and
    `lint.yml`. Its tasks for those files are done; T7 to T10 change only skill files and
    `eval-history.md` in Sprint 35. Piece 1 also changes `eval-history.md`; the two edits are to
    different sections, a sprint apart.
- **Decisions touched and not contradicted:**
  - `.shipkit/decisions/0005-evals-home.md`, "The evals stay inside the plugin; check 17's
    ceiling stays the limit". Piece 4 moves two README sections, not eval cases, and raises no
    ceiling; the plan's V12 settled that 0005 stands. Its reversal condition (the platform names a
    way to keep evals outside the plugin root) has not come true.
  - Piece 5 changes the `Fired-if` line of shipped records, from `manual` to a command, and
    nothing else in them. The decisions rule asks that a superseded record be marked and not
    deleted; no record is superseded here.

## Answers

No question was asked. Every unknown is answered by the approved plan or by a file, and each is
written below as an assumption for the owner to object to.

## Assumptions made

1. **The 5.2.0 result file is read where it is,** `~/.cache/shipkit-rel-5.2.0/aggregate-result.json`
   (312,001 bytes, 2026-11-08; top-level keys `claudeVersion`, `costUsd`, `cases`, `aggregates`
   and others). The ledger keeps its numbers; the file itself is not copied into the repository.
2. **A field the source does not hold is written `-`,** never guessed: 5.1.0's prose may give no
   cost per case or Claude Code version (the plan's rule 25: each number is read against its page).
3. **No eval runs in this sprint.** `evals.sh`'s new wrapper is tested with a stand-in for
   `claude plugin eval` (the plan, S31-T1 subtask 4).
4. **Piece 2's five passes on the CI runner happen on this sprint's pull request,** through runs
   of the workflow that the owner says yes to at that point (pushes and workflow runs are
   outward-facing). Until five pass, the switch stays in the workflow and the task stays open.
5. **The briefing's gap count must give the same number `spec-check.sh .` gives;** how it is made
   cheap is the design's choice, and `spec-check.sh`'s own output does not change (the plan).
6. **Piece 5's target is set in the spec** from a count made then; the plan's §0 says "fewer". A
   first rough count found 117 `MANUAL` lines whose clause mentions a case, a run or "N of M";
   the spec counts the ones whose condition the ledger can actually answer.
7. **A `Fired-if` command written in piece 5 must read `HOLDS` today.** One that fires is put to
   the owner, not reworded.
8. **The new lint check is numbered 19,** after `lint.py`'s check 18; check 17's heading is
   corrected from "192 KB" to the 204,800-byte limit it enforces.
9. **The map and the ledger live outside `plugins/shipkit/evals/`,** under `scripts/` and
   `docs/design/`, so neither counts against check 17's ceiling.
10. **Scripts stay POSIX `sh` and awk;** reading the JSON result file may use `python3`, as
    `scripts/` already does, since these are contributors' scripts and not plugin scripts
    (`spec-contract/REQ-10` binds the plugin's `spec-check.sh`).
11. **This spec has a `> Tests:` line,** written by hand: `scripts/smoke.sh`, `scripts/lint.py`.

## Out of scope

- Any paid model run, and any change to an existing skill, agent or rule file.
- Running the root-cause kit of piece 2: that is Sprint 35's, ten runs a case.
- Raising check 17's ceiling, or moving any eval case out of the plugin.
- Writing the eleven cases from real misses: Sprint 32.
- A `Fired-if` command for a condition the ledger cannot answer.
