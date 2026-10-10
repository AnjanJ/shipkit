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
