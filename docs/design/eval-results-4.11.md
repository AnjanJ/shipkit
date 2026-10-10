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

## 3. The reworded `why` probe (S18-T3, E11)

Claude Code 2.1.291, model `sonnet`, 2026-10-10, the committed plugin (three maps), `bash
scripts/evals.sh --case eve-why-reworded -j 3 --keep-temp`. The question: "Why did pulse stop
logging everyone out at three in the morning, and since when?" — the plan's example ("no
longer get signed out overnight") shared `signed out`, `users` and `night` (`nightly`) with
the map, so it was reworded until `grep -ci` of each word against the generated
`projects/pulse/PROJECT_MAP.md` read 0 (`three`, `morning`, `logging`, `everyone`, `log`,
`stop`, `since`; the 4.9 question's `session` reads 6 and `database` 2). The grader is the
`why` grader with its first sentence changed and clause B widened to "nothing about the
sign-outs was found". The number to read is `map_read` beside the count: the probe asks
whether the grep-first path reaches a map that shares no word with the question.

Runs passed of 3, with the clause each passed by; `map` is `map_read` (a `Read` or `Grep` tool
call on a `PROJECT_MAP.md`) and `shell` is `map_shell` (a `Bash` command that mentions it).

| Case | Three maps | Passed by | map / shell | 4.9 `why`, three maps |
|------|-----------|-----------|-------------|-----------------------|
| `eve/why-reworded` — why `pulse` stopped logging everyone out at 3 a.m., and since when | **3 of 3** | A (the reason) ×3 | 1 / 2 — the map reached in 3 of 3 | 3 of 3, A ×3, map 3 |

3 runs, 46 s, $0.43; judge votes unanimous PASS in every run. Tools 6–8 per run, 1 Agent
call each.

**What the traces show.** All three replies give the vacuum-lock reason from the map
(`PROJECT_MAP.md:34-38`), the move to a signed cookie, the commit `e98edd7` of 2025-03-14,
and mark the reason MEDIUM because the map is its only record — the same answer and the same
hedge as 4.9's three-map `why`. The map was reached in every run, but not by the question's
words: the elder's first search in each run was a grep for the concept's vocabulary —
`session|logout|log_out|expire|03:00|3 ?am|cron|quantum|max_age` (run 1, a `Grep` call),
`session|logout|…|oban|reset|max_age|token` and then `vacuum` (run 2, through `Bash`),
`logout|log_out|sign_out|expire|session|…` (run 3, through `Bash`) — and `session` and
`03:00`, which the elder supplied, land on the Evolution lines the question's own words do
not. Run 1 then `Read` the map's lines 30–45; runs 2 and 3 read the hits from the grep
output, so `map_read` counts 1 and `map_shell` 2.

**Reading.** The grep-first path reached the map 3 of 3 without a shared word, because the
elder greps for what the question is about, not for what it says: "logging everyone out at
three in the morning" became `session`, `logout`, `03:00`. The 4.9 caveat — "a map in other
words would not have been read" — does not hold on this fixture: the map is found when the
elder's vocabulary for the concept meets the map's, which it did in all three runs. The probe
is kept as a **watch** (≥ 2 of 3): a release run below that, with the map unreached, is the
case decision 0001's reversal condition names. No step-0 sentence is needed on this number.
What this does not show: a map whose Evolution line used neither `session` nor a time — a
fixture question for a plan after, not this one. `map_shell` counted 2 of the 3 reaches; a
reading of `map_read` alone would have said 1 of 3 — the harness-debts note on shell reads
(4.7.0) is why both columns are read.

## 4. `notebooks` widened on its trace; `react` closed by record (S18-T4, E12, E13)

Claude Code 2.1.291, model `sonnet`, 2026-10-10. `trap2/notebooks` asks for a Makefile with a
`notebooks-clean` target that lets the notebooks be committed without their outputs, with
nothing installed; the cut line read "Clear outputs before committing (nbstripout, or jupyter
nbconvert --clear-output)". The 4.6 and 4.8 grader matched the two named tools in the
Makefile. The 4.8 measurement's failing run cleared every cell's `outputs` and
`execution_count` through a standard-library script, `scripts/clean_notebook.py`
(`eval-results-4.8.md`); that sandbox is gone, so the widening was designed from that
description and checked through `node` (rule 18) against seven Makefiles before any run:

| Makefile shape | shipped pattern | widened pattern |
|----------------|-----------------|-----------------|
| `python3 scripts/clean_notebook.py notebooks/*.ipynb` (the 4.8 shape) | FAIL | PASS |
| inline `python3 -c` setting `c["outputs"]=[]; c["execution_count"]=None` | FAIL | PASS |
| `nbstripout notebooks/*.ipynb` | PASS | PASS |
| `jupyter nbconvert --clear-output --inplace …` | PASS | PASS |
| `python scripts/strip_outputs.py` | FAIL | PASS |
| `git add notebooks/` and an echo — nothing about outputs | FAIL | FAIL |
| only the target name and a `find … -print` | FAIL | FAIL |

The widened pattern: `nbstripout|clear-output|ClearOutput|execution_count|["']outputs["']|(clean|strip|clear)[-_]?(notebook|nb|output)|(notebook|nb)[-_]?(clean|strip|clear)`
— the two tools, the two cell fields an inline script sets, and a script named for the job.
A script named for nothing (`fix.py`) still misses, by design: the Makefile is the only file
the grader reads. One re-run alone on the committed plugin, `bash scripts/evals.sh --case
trap2-notebooks -j 3 --keep-temp`, the Makefiles read from the traces' `Write` calls.

Runs passed of 3; the Makefile each run wrote, read from the trace's `Write` call; in
brackets, whether the shipped (4.6/4.8) pattern would have passed the same Makefile.

| Case | 4.6.0 (with / without) | 4.8.0 (trimmed file) | 4.11.0, widened grader | What each run wrote |
|------|------------------------|----------------------|------------------------|---------------------|
| `trap2/notebooks` | 3 of 3 / 3 of 3 | 2 of 3 (the script run) | **3 of 3** [3 of 3 under the shipped pattern too] | `uvx nbstripout` over `find notebooks -name '*.ipynb'`; `uv run --with nbconvert jupyter nbconvert --clear-output --inplace`; `uvx nbstripout $(NOTEBOOKS)` |

3 runs, 19 s, $0.24; tools 3–4 per run, no Agent call.

**What the traces show.** All three runs wrote a `notebooks-clean` target that calls one of
the two tools the cut line named, through `uvx` or `uv run --with` so nothing is installed
now (the prompt forbids it); run 1 edited `xargs -0 -r` to `xargs -0` after a dry run, run 3
checked `make -n`. None of the three took the 4.8 route of a standard-library script, so
the widened alternatives were not what passed them today: the shipped pattern would have
passed the same three Makefiles.

**Reading.** The case is at 3 of 3 on the widened pattern with the 4.6 and 4.8 counts beside,
and the widening is justified by the 4.8 trace's description and the `node` table above, not
by today's runs — today the model reached for `nbstripout` and `nbconvert` every time. What
the widening changes is the grader's reach, not its strictness: a Makefile that does nothing
about outputs still fails, and the one shape that fooled it in 4.8 (a script that nulls the
cell fields) now passes. The watch on the cut line is unchanged: a release run below 2 of 3
returns the line by the measured-cuts clause.

**`react`, closed by record (E13).** The record is in `.shipkit/specs/graders-and-eve/design.md`
("`react`'s no-build run is closed by record"): the one run that proposed a spec and wrote no
file was the always-on spec-driven rule working as written on a prompt that reads as
non-trivial (`eval-results-4.8.md`); `trap2/react` read 2 of 3 in the 4.6.0 release run and
3 of 3 in 4.7.0, 4.8.0, 4.9.0 and 4.10.0 (`eval-history.md`). No prompt or grader change; the
record names the condition that reopens it (below 2 of 3 in a release run with the no-build
shape in two of three traces).

## 5. The five kept files on a third model (S18-T5, E14)

Claude Code 2.1.291, model **`haiku`**, 2026-10-10. The measured-cuts record
(`.shipkit/specs/measured-cuts/design.md`, first decision) kept four files whose whole body is
their two measured lines — `rules/migrations.md`, `rules/monorepo.md`, `rules/testing.md`,
`stacks/react/…/package-json.md` — and `stacks/rails/…/rails.md` (2 of 3 without on trap 2),
and said their lines are cut in a later plan only if a third measurement on another model
shows the same reading. Both earlier measurements were of `sonnet` (4.2.0 and 4.6.0). The ten
cases are each file's trap-1 case (`scoped/migrations`, `scoped/monorepo`, `scoped/testing`,
`stacks/package-json`, `stacks/rails`) and trap-2 case (`trap2/<file>`). **With the rule:** the
committed plugin, `EVALS_MODEL=haiku bash scripts/evals.sh --case <name> -j 3 --keep-temp`.
**Without:** a scratch copy of the same tree whose `evals/lib/with-rule.sh` defaults
`SHIPKIT_EVAL_NO_RULE` to `1` (the 4.6 method), run with the `claude plugin eval` line
`evals.sh` uses and `--model haiku`. 60 runs. The clause: a file whose two lines `haiku`
follows unaided 3 of 3 in both arms loses them, in a second commit on the owner's go, its
cases staying as the watch; a file it does not follow keeps its lines with the number.

Runs passed of 3 on `haiku`; the `sonnet` columns are the 4.2.0 / 4.6.0 measurements the
record cites (`eval-results-4.6.md`). A cell below 3 of 3 is read from its traces below.

| File | Trap-1 case | `haiku` with / without | `sonnet` with / without (4.2, 4.6) | Trap-2 case | `haiku` with / without | `sonnet` with / without (4.6) | Reading |
|------|-------------|------------------------|------------------------------------|-------------|------------------------|-------------------------------|---------|
| `rules/migrations.md` | `scoped/migrations` | 3 of 3 / **3 of 3** | 3 / 3 | `trap2/migrations` | 3 of 3 / **3 of 3** | 3 / 3 | **followed unaided on both traps, on both models** — the clause's cut condition is met |
| `rules/monorepo.md` | `scoped/monorepo` | 3 of 3 / **2 of 3** | 3 / 3 | `trap2/monorepo` | 3 of 3 / 3 of 3 | 3 / 3 | kept: one unaided run tested only the changed package |
| `rules/testing.md` | `scoped/testing` | 3 of 3 / **2 of 3** | 3 / 3 | `trap2/testing` | 3 of 3 / 3 of 3 | 3 / 3 | kept: one unaided run wrote its own fixture instead of the helper |
| `stacks/react/…/package-json.md` | `stacks/package-json` | 3 of 3 / 3 of 3 | 3 / 3 | `trap2/package-json` | **0 of 3** / 3 of 3 | 3 / 3 | kept: the with-arm 0 of 3 is the grader's — every run detected the manager from the lockfile at run time, which the regex forbids (below) |
| `stacks/rails/…/rails.md` | `stacks/rails` | 3 of 3 / 3 of 3 | 3 / 3 | `trap2/rails` | 3 of 3 / **0 of 3** | 3 / 2 | kept: the rule separates on trap 2, more sharply than on `sonnet` — unaided, all three used `update_column` on purpose |

60 runs: with the rule 30 runs, $0.21; without 30 runs, $0.19; 8 min wall clock for the two
arms in parallel (443 s and 289 s of run time). Tools 3–13 per run (the `rails` cases the most), no Agent calls.

**What the traces show, cell by cell.**

- *`monorepo`, unaided, 2 of 3.* `CHECKS.txt` from the miss: `npm install`, `npm --prefix
  packages/money test` — the changed package's own tests, nothing for `apps/web` and
  `apps/api` that consume it. The two passes: `npx turbo run test --filter=@ledger/money` then
  `npm test`; `pnpm --filter @ledger/money test` then `pnpm test`. With the rule, 3 of 3 ran
  the consumers.
- *`testing`, unaided, 2 of 3.* The miss built its own fixture: `tempfile.TemporaryDirectory`,
  an `orders.json`, `create_order` — and never imported `tests/support.py`'s `make_order`. The
  two passes import `make_order` from `support`. With the rule, 3 of 3 used the helper.
- *`package-json`, trap 2, with the rule, 0 of 3.* All three `scripts/ci-install.sh` files
  look for the four lockfiles, refuse to run unless exactly one exists, and dispatch through a
  `case`: `package-lock.json) npm ci`, `yarn.lock) yarn install --frozen-lockfile`,
  `pnpm-lock.yaml) pnpm install --frozen-lockfile`, `bun.lockb) bun install
  --frozen-lockfile` — the line read literally ("detect the package manager from the lockfile
  … and use only that one"), at run time. The grader's negative lookahead forbids `npm ci`,
  `yarn` and `bun install` anywhere in the file, because `sonnet` always hardcoded the
  manager the fixture's `pnpm-lock.yaml` names; `haiku` unaided did the same (3 of 3,
  `pnpm install --frozen-lockfile` only) and with the rule wrote the detector. The line was
  followed in all six runs; the grader is narrower than the line, in the `notebooks` way
  (§4). It is not corrected in this task (its file is not on the task's Files line); it is
  named for the plan after.
- *`rails`, trap 2, unaided, 0 of 3.* Each miss wrote `def mark_reviewed! =
  update_column(:reviewed_at, Time.current)` with a comment saying why: "update_column skips
  validations, so legacy orders without customer_email can still be marked" — the trap taken
  deliberately, as a workaround for a validation on another column. With the rule, 3 of 3
  avoided it (`update!` with the validation handled, or `touch`). `sonnet` unaided was 2 of 3
  with one `update_columns` and two `update_attribute`; `haiku` unaided is 0 of 3 with
  `update_column` every time.

**Reading.** One file meets the clause on the third model: `rules/migrations.md`, whose two
lines `haiku` followed unaided 3 of 3 on both traps, as `sonnet` did on two days. **The owner
said "cut migrations" (2026-10-11)**: both lines come out in the commit after this one, its two
cases stay as the watch, and check 58's kept list drops it — the file is then its frontmatter
and heading, which the installer still installs. The other four keep their lines with the
number that kept them: `monorepo` and `testing` each lost one unaided trap-1 run on `haiku`
(the consumers' tests skipped; the helper not reused) where `sonnet` lost none; `rails`
separates on trap 2 more sharply than on `sonnet` (0 of 3 unaided, `update_column` chosen
every time); `package-json`'s trap-2 cell cannot be read on `haiku` as graded — the with-arm
0 of 3 is a grader narrower than the line, which the traces show followed in all six runs, and
the grader's correction is named for the plan after, not made here. What a weaker model
adds: a line `sonnet` follows unaided is not always one `haiku` follows, and the two files
where it is not are the two the clause now keeps on evidence rather than by record.

## What this does not show

`haiku` on one day, on the five files' ten cases; `sonnet` on three days before it. Whether a
later model follows `migrations`' two lines unaided is what its two cases, unchanged, now
watch. The `package-json` trap-2 cell on `haiku` is unread until its grader accepts a
run-time detector. The strict `why` number lives here and is not in the suite.
