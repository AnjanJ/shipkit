# Eval results for 4.9.0 — `eve` on a portfolio of three, with three maps, one and none

> Sprint 16, S16-T2 (portfolio plan E10). Spec `portfolio-run`, REQ-7 to REQ-9. The question C11
> left at 4.6.0: what does `eve` lose when fewer projects carry a map? Three cases on the
> generated portfolio fixture (`plugins/shipkit/evals/fixtures/FACTS-PORTFOLIO.md`), each run
> under three arms. Every count below was read from the traces with `scripts/trace-tools.sh`
> and the replies read before the readings were written (rule 10).

## What was run

Claude Code 2.1.291, model `sonnet`, 2026-10-10. The **three-map arm** is the committed plugin
(`bash scripts/evals.sh --case eve-<name> -j 3 --keep-temp`, one invocation per case); the
**one-map** and **no-map arms** are scratch copies of `plugins/shipkit` whose three `fixture.sh`
files default `SHIPKIT_EVAL_MAPS` to `1` and `0`, run with the same `claude plugin eval` line
`evals.sh` uses. `--maps 1` maps `shopfront` only, so in that arm `pulse` — the project the `why`
case asks about — has no map. 30 runs, $3.85: the 27 the plan budgeted plus one re-run of
`why` in the no-map arm after its grader was corrected (below).

Two graders were corrected on trace evidence before their numbers counted, and one was not:

- **`jobs` and `payments` (regex):** the first patterns used Python inline flags (`(?is)`); the
  eval tool's regex grader is a JavaScript `RegExp`, and every run of both cases "threw:
  Invalid regular expression". The replies were right. The patterns were rewritten in
  JavaScript syntax (`[\s\S]*`, `[Ss]idekiq`) and the **same 18 replies graded from their
  traces with the corrected pattern through `node`** — a regex is deterministic, so this is
  the verdict the tool would have given. The release run grades them live. The README's
  limits now say so.
- **`why` (llm), the no-map arm:** the first wording ended "a guess labelled as a guess is
  still a reason offered: FAIL", and the arm scored **0 of 3**: every reply led with "the
  repository does not record why" and then listed motives marked as guesses with no support
  in the repo. The spec (REQ-8) and the plan (E10) ask for "no reason invented", which the
  replies honour; the sentence was stricter than its requirement. It now reads: speculation
  passes only when marked as a guess with no support in the repository, and the plain "not
  recorded" must still be there. The arm was re-run (3 runs, $0.40). Both numbers are in
  the table.
- **`payments`' manifest clause was kept.** The plan's grader asks that a manifest path be
  cited (`Gemfile` or `mix.exs`); one reply per arm names the gem and its constraint and the
  file that handles the charge, but no manifest file. Those three are fails. Moving the
  clause would have moved every cell to 3 of 3; it stays as the plan wrote it, and reading 3
  says what it measures.

## The table

Runs passed of 3; `map` is the number of runs whose trace holds a `Read` or `Grep` of a
`PROJECT_MAP.md` (`map_read`; `map_shell` was 0 in every run).

| Case | Three maps | One map (`shopfront`) | No map |
|------|-----------|------------------------|--------|
| `eve/jobs` — which projects run background jobs, with what | **3 of 3** (map 0) | **3 of 3** (map 0) | **3 of 3** (map 0) |
| `eve/payments` — where payments are handled, which provider | **2 of 3** (map 0) | **2 of 3** (map 0) | **2 of 3** (map 0) |
| `eve/why` — why `pulse` moved sessions off the database, and when | **3 of 3** (map 3) | **3 of 3** (map 0) | **3 of 3** (map 0); first grader wording **0 of 3** |

Cost per arm: three maps $1.16, one map $1.16, no map $1.13 (+ $0.40 for the first `why`
run). Main-session input tokens 46k–95k per run; the elder's own context is where the work
happens (tools 3–11 per run, 1 Agent call each).

## What the replies say

**`jobs`, every arm.** The answer is the same table in all nine runs: `shopfront` Sidekiq,
`pulse` Oban, `insight` Celery, each with the manifest line and the file that starts the
worker. No run read a map, not even with three on disk: the first tool after the registry is
one `Grep` over the three repositories for a list of job libraries (`sidekiq|solid_queue|…|oban|
…|celery|…`), then a confirming read per hit. The registry's `Stack` column does not name a job
library (the fixture was built so), and no reply tried to answer from it.

**`payments`, every arm.** Nine of nine place Stripe at `shopfront` and `pulse` and give
`insight` none, citing `app/services/stripe_charge.rb`, `app/controllers/webhooks/
stripe_controller.rb`, `lib/pulse/billing/stripe.ex` and `lib/pulse_web/controllers/
webhook_controller.ex`. The three fails each name the gem (`stripe ~> 12.0`,
`stripity_stripe ~> 3.2`) without the word `Gemfile` or `mix.exs`. Two replies list the
providers they searched for and did not find in `insight`, which is the honest shape of a
negative. No run read a map.

**`why`, three maps.** All three give the vacuum-lock reason, the move to a cookie store and
the date, citing `projects/pulse/PROJECT_MAP.md:34-39`, and all three mark the reason MEDIUM
because "it rests on one line in the map; the commit says only wip". The map was reached by
the grep, not by a decision to read it: `Grep session` over `projects/pulse` returns the map's
Evolution lines among the hits, and the elder then `Read`s those fifteen lines. This is step
0 of `agents/eve.md` working as 0001's "Step 0, closed" note describes it.

**`why`, one map and none.** All six give the date and the move (`store: :cookie` in
`endpoint.ex`, the `drop_sessions` migration, commit `e98edd7` of 2025-03-14) and say the
repository does not record why: "the commit message is just wip", "no `.shipkit/` decisions",
"the README doesn't mention sessions". Five of the six then add one to three motives marked
as inference ("fewer database reads per request", "simpler scaling on Fly.io") with "nothing in
the repo supports this"; one declines to guess ("Nothing records a reason, so I won't guess").
None presents a motive as the reason. In the one-map arm no run read `shopfront`'s map, which
could not have answered.

## The three readings

**1. A case the maps never change: the sweep and the where.** `jobs` and `payments` hold the
same counts in every arm and read no map in any — 18 runs, 0 map reads. `eve`'s cheap path
(the registry for the project list, one grep for the signal, a confirming read per hit) does
not need a map for a single-fact sweep or a cross-project where, and with three maps on disk
it still does not open them. The maps cost nothing here because they are never read.

**2. A case only a map answers: `why`.** With `pulse` mapped, the reason comes back 3 of 3,
from the map, with the map named as the only source. Without it, the reason is not found 6 of
6 and the reply says so. The `history` shape 4.6.0 saw in one project (3 of 3 with the map, 0
of 3 without, on a "wip" log) holds across a portfolio: a why that no file and no commit
records is recoverable only from a map's Evolution section. The grader passes both halves
because both are right answers; the table's `map` column is what separates them.

**3. What neither reading expected.**

- *The manifest clause measures a citation habit, not the answer.* `payments` sits at 2 of 3 in
  every arm for the same reason: one reply per arm cites the file that handles the charge and
  the gem's constraint, but not the manifest file. The question was "where do I handle
  payments", and the handling file is the better evidence; the clause came from the plan's
  grader description and stays, but a plan after may decide the manifest is the wrong thing
  to insist on.
- *`eve` speculates after saying "not recorded".* Five of six map-less `why` replies append
  motives marked as guesses. The agent's constraints ask it to name gaps and label confidence,
  which it does — but a user who asked "why" is handed three plausible reasons for a decision
  the repository never explains. Whether the agent should offer labelled guesses at all is a
  question for `agents/eve.md`, which this plan does not edit; it is named for the plan after.
- *The map is found by the grep, not chosen.* In the three-map arm the elder read `pulse`'s
  map only because `Grep session` landed on its Evolution lines. A map whose Evolution used
  different words than the question would not have been read, and the `why` would have been
  "not recorded" with the answer sitting one file away. The fixture's map says "sessions"; a
  real map might not.
- *A JavaScript regex.* The eval tool's `regex` grader is a JavaScript `RegExp`; a Python
  inline flag throws and the run fails without a model error. Three cases' worth of runs were
  graded from their traces because of it; the README now says so under "What graders can check".

## Decision 0001, and the registry's advice

Record 0001 gains the number: across 27 runs on a three-project portfolio, the sweep and the
where never read a map and never needed one; the why was answered only where the project
had a map. The map stays optional, and its value is where 4.6.0 and this run both put it: the
Evolution section, for the question no file records.

## Reproduce

```sh
EVALS_OUT="$TMPDIR/s16-m3" bash scripts/evals.sh --group eve -j 3 --keep-temp
for n in 1 0; do
  cp -R plugins/shipkit "$TMPDIR/shipkit-maps$n"
  for c in jobs payments why; do
    sed -i '' "s/SHIPKIT_EVAL_MAPS:-3/SHIPKIT_EVAL_MAPS:-$n/" "$TMPDIR/shipkit-maps$n/evals/eve/$c/fixture.sh"
  done
  claude plugin eval "$TMPDIR/shipkit-maps$n" --trust-plugin --ablation none --no-publish \
    --model sonnet --threshold 0.66 --output-dir "$TMPDIR/s16-m$n" --case 'eve-*' \
    -j 3 --keep-temp --scaffold --allow-tools Bash Write Edit
done
for d in m3 m1 m0; do sh scripts/trace-tools.sh "$TMPDIR/s16-$d"; done
```

## What this does not show

One model on one day, on a fixture whose facts were planted to be found by one grep each. The
`why`'s map was reached because its Evolution line shares a word with the question; a map
written in other words is unmeasured. Nothing here says what `eve` does on twenty projects, or
on a question that needs two maps read together (a synthesis), which no case asks.
