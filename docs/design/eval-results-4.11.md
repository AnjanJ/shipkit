# Eval results for 4.11.0 — graders on their traces, `eve` on her guesses, five kept files on a third model

> Sprint 18 of the second-run plan (`docs/plans/second-run-sprint-plan.md`, E9 to E14; spec
> `graders-and-eve`). Every count below was read from the traces with `scripts/trace-tools.sh`
> and, for the regex cases, the final reply checked clause by clause through `node` (rule 18);
> the readings were written after the traces (rule 10). Each sandbox was removed after reading.

## 1. `payments` graded on what the question asked (S18-T1, E9)

Claude Code 2.1.291, model `sonnet`, 2026-10-10. The 4.9 grader's fourth lookahead required
`Gemfile` or `mix.exs` in the reply; the 4.11.0 grader accepts those or a file that handles
the provider (`stripe_charge.rb`, `billing/stripe.ex`); the three other lookaheads are
byte-identical (`plugins/shipkit/evals/eve/payments/graders/stripe-twice-insight-none.md`).
Before any run, the two patterns were checked through `node` against a reply assembled from
the fragments the 4.9 misses are quoted by (the gem and its constraint, the handling files,
no manifest): the shipped pattern FAIL, the corrected PASS; a reply citing `Gemfile` and
`mix.exs` only: PASS under both; a reply giving `pulse` Paddle: FAIL under both. The three
arms as in 4.9: the committed plugin (`EVALS_OUT=… bash scripts/evals.sh --case eve-payments
-j 3 --keep-temp`) and two scratch copies of the corrected tree whose `fixture.sh` defaults
`SHIPKIT_EVAL_MAPS` to `1` and `0`, run with the `claude plugin eval` line `evals.sh` uses.

Runs passed of 3 under the corrected grader; in brackets, how many of the same three replies
the 4.9 clause (`Gemfile` or `mix.exs` required) would have passed, read from the replies
through `node`; `map` is `map_read` (a `Read` or `Grep` of a `PROJECT_MAP.md` in any session;
`map_shell` was 0 in every run). The 4.9 column is `eval-results-4.9.md`'s table.

| Case | Three maps | One map (`shopfront`) | No map | 4.9 (old clause), every arm |
|------|-----------|------------------------|--------|-----------------------------|
| `eve/payments` — where payments are handled, which provider | **3 of 3** [1 of 3] (map 0) | **3 of 3** [1 of 3] (map 0) | **3 of 3** [1 of 3] (map 0) | 2 of 3 (map 0) |

9 runs, 86 s, $1.17 (three maps $0.41, one map $0.37, no map $0.39). Tools 3–5 per run,
1 Agent call each; main-session input tokens 46k–95k.

**What the replies say.** Nine of nine place Stripe at `shopfront` and `pulse` and give
`insight` none ("a case-insensitive search for stripe, paddle, billing and payment found
nothing"), and every one names the gem with its constraint (`stripe` 12.4.0, declared
`~> 12.0`; `stripity_stripe` 3.2.0, declared `~> 3.2`) and the file that makes the charge
(`app/services/stripe_charge.rb`, `lib/pulse/billing/stripe.ex`), most of them the webhook
controllers too. Six of the nine never write the word `Gemfile` or `mix.exs`: they give the
resolved version and the declared constraint without naming the manifest, and cite the
handling file as the place. Those six are the 4.9
misses' shape, and today they are two per arm where 4.9 had one — the same answer, cited by
the file a user would open. No run read a map (nine of nine `map_read` 0), as in all eighteen
of 4.9's sweep and where runs.

**Reading.** The clause measured a citation habit, and the habit is the majority one: under
the 4.9 wording this day's runs would have read 1 of 3 in every arm, below the threshold, with
every reply right. Under the corrected clause the case reads 3 of 3 in every arm and the three
clauses that carry the answer — both projects with Stripe, `insight` none — are unchanged and
still hold. The grader now fails a wrong provider, a missing project or an invented one for
`insight`, and passes the two ways a right reply cites its evidence. `payments` stays in the
suite as the cross-project where; its number is now the answer's.

## 2. `eve` on her guesses: measure, one sentence, measure (S18-T2, E10)

Claude Code 2.1.291, model `sonnet`, 2026-10-10. The shipped `why` grader
(`plugins/shipkit/evals/eve/why/graders/vacuum-or-not-recorded.md`) is byte-identical to its
4.10.0 form throughout and passes a reply that says "not recorded" and then speculates, as
long as the speculation is marked as a guess with no support in the repository. The **strict
wording** is S16-T2's first sentence (`eval-results-4.9.md`, "What was run"), written into the
no-map scratch copy's grader only — clause B's last two sentences become: *A guess labelled as
a guess is still a reason offered: FAIL.* The no-map arm is the scratch copy whose `fixture.sh`
defaults `SHIPKIT_EVAL_MAPS` to `0` (T1's); the three-map arm is the committed plugin with the
shipped grader. Three measurements: the no-map arm under the strict wording before the
sentence (the baseline); the same after the sentence in `agents/eve.md` step 4; the three-map
arm after the sentence, under the shipped grader. The sentence stays only if the second reads
at least 2 of 3 and the third 3 of 3.

Runs passed of 3; `map` is `map_read`.

| Arm | Grader | Before the sentence | After the sentence |
|-----|--------|---------------------|--------------------|
| No map | strict (a labelled guess is a reason offered) | **1 of 3** (map 0) — the baseline | **2 of 3** (map 0) |
| Three maps | shipped | 3 of 3 (4.9; 4.10.0 release run) | **3 of 3** (map 3) |

Baseline: 3 runs, 49 s, $0.40; judge votes unanimous in every run (FAIL FAIL FAIL, PASS PASS
PASS, FAIL FAIL FAIL). Tools 7–10 per run, 1 Agent call each.

**The baseline replies.** All three give the date, the commit (`e98edd7`, "wip"), the move
(`store: :cookie` in `endpoint.ex`, the `drop_sessions` migration, the deleted
`session_store.ex`) and say the repository does not record why. Run 1 then adds "The code
suggests some likely motives, but these are the agent's inference, not evidence" and lists
them: FAIL. Run 3 adds "Typical reasons for this kind of move are fewer database reads per
request and no session table to clean up, but those are generic, not evidence about Pulse":
FAIL. Run 2 says "I can't tell you why" and offers nothing: PASS. The 4.9 measurement's first
wording read 0 of 3 on this arm; today's 1 of 3 is one reply that declined where five of six
had guessed. The shape is the one 4.9 reading 3 named: "not recorded", then motives marked as
guesses.

After the sentence: no-map arm 3 runs, 39 s, $0.41 (judge votes PASS FAIL FAIL, PASS PASS
PASS, PASS PASS PASS); three-map arm 3 runs, 30 s, $0.35 (unanimous PASS in every run). 9 runs
in all for E10, $1.16.

**The replies after the sentence.** No-map arm: all three say the reason is not recorded and
give the date and the move; two say outright "Eve didn't guess a motive" / "Eve didn't guess
at motives" and offer none — PASS. The third offers no motive for the move either; it ends
"The reason is probably in discussion history outside the repo. The person who made the March
2025 change is the best source", and two judges of three read that "probably" as a guess
offered — FAIL under the strict wording, which is the wording's edge, not a motive. Three-map
arm: all three give the vacuum-lock reason from `PROJECT_MAP.md:34-39`, mark it MEDIUM because
the map is the only record, and read the map (`map_read` 1 in each, as in 4.9) — the sentence
did not stop `eve` from giving a reason a map holds.

**Reading.** The sentence's rule was: stay if the strict arm reads at least 2 of 3 with it and
the three-map arm 3 of 3. Both hold: 1 of 3 → 2 of 3 on the strict wording, and 3 of 3 with
`map_read` 3 where the map has the reason. **The sentence stays** in `agents/eve.md` step 4.
What it changed is visible in the replies: before, two of three appended "likely motives" or
"typical reasons" after "not recorded"; after, two of three say they offered none and the third
points to where a reason might be rather than what it might be. The shipped `why` grader is
unchanged (`git diff v4.10.0 -- plugins/shipkit/evals/eve/why` is empty) and still passes both
shapes; the number that would show a regression is the strict one, which lives in this
document and is re-run by hand, not in the suite.
