# Intake: Graders and `eve`

> Intake taken on 2026-10-10.

## Request
Sprint 18 of the second-run plan (`docs/plans/second-run-sprint-plan.md`), the plan's second:
act on the three readings the portfolio measurement left (`docs/design/eval-results-4.9.md`,
"The three readings", 3) and the two grader notes the 4.8.0 release carried, each on its
trace; measure the five kept rule files on a third model and cut or keep each by the
measured-cuts clause. Release 4.11.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; no product file.
- **Open specs:** none; all nineteen specs are `Status: shipped`. `portfolio-run` (REQ-7)
  owns the three `eve` cases and the portfolio generator — E9 corrects one grader's clause,
  E10 edits the agent and no shipped grader, E11 adds a fourth case on the same generator.
  `measured-cuts` (its first decision's Falsifiability) names the third-model measurement E14
  runs, and its clause decides the cut. `second-traps` (REQ-4, REQ-5) owns the sixteen
  `trap2` cases — E12 widens one grader on the evidence its own results document kept.
  `harness-debts` (REQ-8) made `map_read` count `Grep`; E11's probe reads it.
- **Decisions:** 0001 gains one line in its `eve` note (E10, E11); 0002, 0003 untouched. E13
  and E19 are closed by record in this sprint's `design.md`: they bind no code.
- **Harness changes:** one new eval case (`eve/why-reworded`, ≈ 2.9 KB; room 4,830 bytes);
  two graders corrected (`eve/payments`, `trap2/notebooks`); `scripts/evals.sh`'s citation
  header; smoke check 58's comment, and its kept list only on a cut. No lint change. Agent text
  change: `agents/eve.md`, one sentence, kept only if the measurement says so. Rule files: the
  five kept files change only on the owner's go after the table (the three injected rules
  stay at 2,979 bytes either way). No skill or script changes.

## Answers
1. **The plan's E9 to E14 and E19, every default, and the sprint's budget (E9 9 runs ≈ $1.10,
   E10 9 runs ≈ $1.20, E11 3 runs ≈ $0.45, E12 3 runs ≈ $0.30, E14 60 `haiku` runs ≈ $3, up to
   two re-runs alone ≈ $1; the gate ≈ $0.50; the release run at 59 cases ≈ $17.80)?** —
   **"approved"** for the plan as a whole, the owner, 2026-10-10 (S17-T0); this spec is the
   sprint's reading of it — **"approved"**, the owner, 2026-10-10, every assumption below standing.
2. **E11's wording: the plan's example question ("Why do pulse's users no longer get signed
   out overnight, and since when?") shares three words with `pulse`'s map — `signed out`
   (Evolution, "every user was signed out"), `users` (Origin, "a users table") and `night`
   (`nightly`, which a `grep -i night` lands on). Is the question reworded until the check
   passes?** — *assumed: yes, as the plan's §3 fifth claim says ("reword until it does not");
   the wording in REQ-6 was checked today against the generated map: 0 hits for `three`,
   `morning`, `logging`, `everyone`, `log`, `stop`, `since`.*
3. **E12's evidence: the 4.8 sandbox is gone (every sandbox is removed after reading), so the
   failing run's Makefile and script are not on disk; `eval-results-4.8.md` describes them
   (a `notebooks-clean` target clearing every cell's `outputs` and `execution_count` through
   `scripts/clean_notebook.py`). Is the widened pattern designed from that description, tested
   with `node` against a reply shaped like it, and settled on the T4 re-run's own Makefiles
   read from their traces?** — *assumed: yes; see "Assumptions made".*
4. **E10's strict grader: the plan offers a second grader file kept unscored, or the strict
   wording in the results document applied through the scratch copy. The eval tool scores
   every grader a case lists (the README: "each case has exactly one scored grader"), so an
   unscored second file is not a shape the tool has. Is the strict wording kept in the
   results document and written into the no-map scratch copy's grader only?** — *assumed:
   yes; the shipped `why` case stays at one grader, byte-identical to 4.10.0.*

## Assumptions made
- **A requirement is cited from a file that counts as a test.** `spec-check.sh` reads
  citations from files outside `.shipkit/`, `docs/` and `*.md`; a grader file is `.md`, so the
  grader requirements (REQ-1, REQ-7) are cited from `scripts/evals.sh`'s header, the probe
  case from its `case.yaml` (REQ-6), and the kept-files requirement from smoke check 58's
  comment (REQ-10). `scripts/evals.sh` is therefore on T1's and T4's Files lines beside the
  plan's, and `scripts/smoke.sh` on T5's unconditionally (its comment; the kept list only on
  a cut).
- **E9's red/green is a `node` check on a reply assembled from the quoted fragments.** The
  three 4.9 misses are quoted as fragments (`stripe ~> 12.0`, `stripity_stripe ~> 3.2`,
  `app/services/stripe_charge.rb`, `lib/pulse/billing/stripe.ex`, no `Gemfile` or `mix.exs`;
  `eval-results-4.9.md`, "What the replies say"; `eval-history.md`, "Release run 4.10.0");
  one reply built from them fails the shipped pattern and passes the corrected one. The nine
  runs are the measure.
- **E10's strict wording** is the shipped grader's text with the two sentences of clause B
  that allow marked speculation replaced by S16-T2's first sentence, quoted in
  `eval-results-4.9.md`: "a guess labelled as a guess is still a reason offered: FAIL". The
  first grader file was never committed (5a760e5 holds the corrected one); the sentence is the
  record.
- **E10's sentence** goes into `agents/eve.md` step 4 ("Verify per project before claiming"),
  as the plan names it: *A why that no map, record or commit holds is answered "not recorded";
  offer no motives of your own.* It stays only if the strict measure reads ≥ 2 of 3 with it
  and the three-map arm still 3 of 3; otherwise it comes out in the same commit.
- **E11's probe** copies the `why` case's fixture and grader shape (≈ 2.9 KB) with the
  question and the grader's first sentence changed; it is kept whether or not it reaches 2 of
  3, as the plan says (a watch, or the number the plan after starts from).
- **E12's pattern** must match what a Makefile holds: a target that calls a script shows the
  script's name, not the script's `json` lines. The widened pattern therefore matches, beside
  `nbstripout` and `nbconvert --clear-output`, an inline form (`execution_count` or `outputs`
  in the Makefile) and a script whose name says what it does (`clean`/`strip` with
  `notebook`/`output`); a name that says nothing (`fix.py`) is not matched, and the reading
  says so.
- **E13's counts** for the record: `trap2/react` 2 of 3 in the 4.6.0 release run (traces not
  read then), 3 of 3 in 4.7.0, 4.8.0, 4.9.0 and 4.10.0; the no-build run was in the S15
  measurement (`eval-results-4.8.md`, 2 of 3).
- **E14's ten cases**: `scoped/migrations`, `scoped/monorepo`, `scoped/testing`,
  `stacks/package-json`, `stacks/rails` (trap 1) and `trap2/` of each (trap 2); the without
  arm is a scratch copy whose `lib/with-rule.sh` defaults `SHIPKIT_EVAL_NO_RULE` to `1`
  (the 4.6 method), run with the `claude plugin eval` line `evals.sh` uses and `--model
  haiku`; the with arm is the committed plugin through `EVALS_MODEL=haiku bash
  scripts/evals.sh`.
- **The results document** is `docs/design/eval-results-4.11.md`, created at T1 and grown by
  each task; every count in it is read from traces with `scripts/trace-tools.sh` (rule 10).
- **No new smoke check**: the plan lists none for this sprint; check 58's comment changes,
  its assertions only on a cut.
- **The plan file is not touched**: its approval line was written at S17-T0 for all three
  sprints.

## Out of scope
The `SessionEnd` hook, the refusal text, the third real run and the roadmap for the plan after
(Sprint 19, E15 to E17); `agents/grandfather.md`; the `why` case's shipped grader (E10's other
option, "closed by record", and any wording change); a step-0 sentence for `eve` (E11's
condition is measured, not acted on); an `llm` grader for `notebooks` (E12's other option); a
"this is a trivial change" prompt line for `react` (E13's other option); `opus` for E14; the
`jobs` case; `--group` on changed groups only (E19's other option); any rule file not among
the five kept, and any of the five without the owner's go after the table; the fourteen
watch cases.
