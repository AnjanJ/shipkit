# Eval history — readings moved out of `plugins/shipkit/evals/README.md`

The evals directory has a byte ceiling (lint check 17) so the plugin stays small to install. When a
reading has served its release, it moves here, unchanged, with the date it moved. The README keeps
the cases and the live baselines.

---

*Moved 2026-10-08 (Sprint 11, S11-T2):*

## After the spec-first sentence (4.2.0)

Sprint task S9-T5 read six kept failing runs first (0 of 6 on the 4.1.0 text): every run built
refunds test-first and listed its assumptions afterwards; two wrote a full spec folder and
then built in the same turn without showing it. The rule was being read as a file format, not
a gate. One sentence changed in `spec-driven.md` — "answers three questions, shows the answers
to the user and waits for a yes before any code" — paid for inside the file (2,996 → 2,979
bytes). Same command, same models, 2026-10-07:

| Case | 4.1.0 text (6 runs) | With the sentence |
|------|---------------------|-------------------|
| `rules/nontrivial` | 0 of 6 | 3 of 3, then 3 of 3 more (6 of 6) |
| `rules/trivial` | 3 of 3 | 3 of 3 |
| `rules/decision` | 3 of 3 | 3 of 3 |

The three passing replies each stop at a proposed spec and ask for a yes. Decision record
`.shipkit/decisions/0002-spec-first-eval.md` holds the traces' reading, the alternatives and
the clause under which the sentence comes out again. `rules/nontrivial` is no longer the
accepted known failure of the release run; a release run where it drops below 2 of 3 is a
regression to investigate, not a number to carry.


## Release run 4.3.0

`bash scripts/evals.sh -j 4`, 2026-10-07: 38 cases, 592 s, $11.57, exit 1 — `grandfather-xl/drift`
1 of 3. Both failing replies gave the right answer (the `_counts` dict in `app/inventory/cache.py`)
and never opened `PROJECT_MAP.md`, so had no Redis claim to call wrong — the shape the 4.1.0
results record (the elder reads the map in fewer than one run in three). Re-run alone with
`--keep-temp`: 3 of 3, every reply naming `PROJECT_MAP.md:25` as wrong; traces read with
`trace-tools.sh` (1 Agent call, 4–5 tools each). Nothing in 4.3.0 touched the elders or the map.
Every other case 3 of 3; `digest-attention` 2 of 3 as in 4.2.0.


---

## Release run 4.11.0

`bash scripts/evals.sh -j 4`, 2026-10-11, at `e554a1f` (`plugins/` byte-identical through the
ship commit `baf5e82`): 59 cases, 1,069 s, $16.79, **exit 1** — `trap2/experiments` 1 of 3;
every other case passed, 55 at 3 of 3, `grandfather-xl/drift`, `intake/answered` and
`intake/limit` 2 of 3 (their shapes in 4.9.0 and 4.10.0; the threshold held, none re-run).
`eve/payments` 3 of 3 under its corrected clause, `eve/why` 3 of 3 with the sentence, the new
`eve/why-reworded` 3 of 3, `trap2/notebooks` 3 of 3 on its widened pattern; the fourteen watch
cases of the seven cut files all 3 of 3, and `scoped/migrations` and `trap2/migrations` 3 of 3
on the heading-only file (its first release run as a watch). `trap2/experiments` re-run alone
with `--keep-temp` (3 runs, 26 s, $0.30): **2 of 3**, and the three `train.py` files read from
the traces' `Write` calls: all three pick the device from `configs/train.yaml`
(`cfg["device"]`) through an explicit `cuda` / `mps` / `cpu` function and log it — the two
passes with `print(f"device={device} …")` and `print(f"training on {device} …")`, the miss
with `log.info("device=%s seed=%d config=%s", device, seed, cfg)`. The grader's second
lookahead wants `logging|logger|print|log\(` on the same line as `device`, and `log.info(`
is none of those: the line was followed, the grader is narrower than it — the third grader of
that shape this sprint (`notebooks` E12, `package-json` on `haiku`, `eval-results-4.11.md`
§4, §5). Nothing in 4.11.0 touches `experiments.md` or its case, which is unchanged (3 of 3
in every release run since 4.6.0); the correction (`log(\.\w+)?\(`) is named for the plan
after beside `package-json`'s, as 4.10.0 named `payments`' for this one. The 1 of 3 under
`-j 4` reads as the same shape landing twice. Cost within E19's "about $17.80" for 59 cases.

## Release run 4.10.0

`bash scripts/evals.sh -j 4`, 2026-10-10, at `20b6a78` (`plugins/` byte-identical through the
ship commit `db3e5bf`): 58 cases, 968 s, $16.38, **exit 1** — `eve/payments` 1 of 3; every
other case passed, 55 at 3 of 3, `grandfather/drift` and `intake/limit` 2 of 3 (their shapes
in 4.9.0 and 4.8.0; the threshold held, neither re-run). `digest/attention` and
`grandfather-xl/drift` 3 of 3 in parallel, as in 4.8.0 and 4.9.0. The fourteen watch cases of
the seven cut files all 3 of 3 on the shipped text; smoke checks 60 and 61 and the seven
extensions touch no eval. `eve/payments` re-run alone with `--keep-temp` (3 runs, 77 s,
$0.40): **2 of 3**, the shape of every arm of the S16-T2 measurement
(`eval-results-4.9.md`, reading 3), and the three traces read through `node` against the
grader's four lookaheads one at a time: the two passes match all four; the miss matches
`shopfront`+Stripe, `pulse`+Stripe and `insight` none, and fails only the manifest clause —
the reply cites the `stripe` gem and `app/services/stripe_charge.rb`, `stripity_stripe` and
`lib/pulse/billing/stripe.ex`, and no `Gemfile` or `mix.exs`. `map_read` 0 in all three (the
where needs no map, as in 4.9). Nothing in 4.10.0 touches `eve`, the portfolio fixture or
the grader; the case is unchanged, and the plan's E9 (S18-T1) is the correction on this
evidence — the clause measures a citation habit, not the answer. The 1 of 3 under `-j 4` is
the same miss landing twice. Cost within E19's "about $17.50".

## Release run 4.9.0

`bash scripts/evals.sh -j 4`, 2026-10-10, at `2d753a1` (`plugins/` byte-identical through the
ship commit `e8e5fb0`): 58 cases, 988 s, $16.52, **exit 0** — every case passed; 55 at 3 of 3,
`grandfather/drift`, `intake/answered` and `intake/limit` 2 of 3. The three new `eve` cases
3 of 3 each, graded live by the tool — `eve/payments` 3 of 3 where the S16-T2 measurement
read 2 of 3 in every arm (the manifest clause; `eval-results-4.9.md`), and the two regex
graders, rewritten in JavaScript syntax after they threw on the measurement runs, grade as
the offline pass through `node` said they would. `digest/attention` and `grandfather-xl/drift`
3 of 3 in parallel, as in 4.8.0. `grandfather/drift` 2 of 3 is new at the threshold (3 of 3 in
4.8.0); the threshold held, so it was not re-run and no trace was read (`evals.sh` keeps none);
nothing in 4.9.0 touches the elders or the nine-file fixture, and a release run below 2 of 3
would be the signal. The fourteen watch cases of the seven cut files all 3 of 3 on the shipped
text. Cost within E13's "about $17.50" for 58 cases.

## Release run 4.8.0

`bash scripts/evals.sh -j 4`, 2026-10-10, at `e2f80a4`: 55 cases, 919 s, $15.48, **exit 0** —
every case passed; 53 at 3 of 3, `intake/limit` and `intake/answered` 2 of 3. `digest/attention`
and `grandfather-xl/drift` 3 of 3 in parallel this time (their 1–2 of 3 under `-j 4` is a shape,
not a rule). The fourteen watch cases of the seven cut files (`eval-results-4.8.md`) all 3 of 3
on the shipped text, `trap2/notebooks` and `trap2/react` included. `intake/limit` 2 of 3 as on
the S15-T2 group run (its first release-run pass since 4.6.0; 0 of 3 in 4.7.0); `intake/answered`
2 of 3 as in 4.5.0 — the threshold held for both, so neither was re-run and no trace was read
(`evals.sh` keeps none). Nothing changed on these numbers. Cost within E13's "about $17".

## Release run 4.7.0

`bash scripts/evals.sh -j 4`, 2026-10-09, at `607035c`: 55 cases, 1,273 s, $16.44, exit 1 —
`digest/attention` 1 of 3 (its shape since 4.6.0) and **`intake/limit` 0 of 3**; every other
case 3 of 3, `grandfather-xl/drift` and `trap2/react` included. `digest/attention` re-run alone
with `--keep-temp`: **3 of 3** ($0.38), the known shape, the case unchanged. `intake/limit`
re-run once alone with `--keep-temp` ($0.15): **0 of 1**, and the trace read before anything
else (rule 10): the reply asks three numbered questions, but the second holds a second question
("which cases do you expect to need a manual step?") and the third asks two things, and the
grader counts a sub-part that needs its own answer as a question of its own — three judges in
each of the four runs counted five or more. The grader is reading its own rule; nothing in 4.7.0
touches the intake skill, its cases or the hook, and the same case passed 3 of 3 in the 4.6.0
release run at `04fed37` the same morning (and 3 of 3 in 4.6.0's exit run, 3 of 3 in 4.4.0,
2 of 3 in 4.5.0). The drop is in the shape of the model's reply on this day, not in this
release; whether to carry it as a known failure or to change the skill's "at most four
questions" wording is the owner's call, recorded in the sprint report and the pull request.
Nothing was changed on these numbers. The release run cost is within E13's "about $17".

## Release run 4.6.0

`bash scripts/evals.sh -j 4`, 2026-10-09, at `04fed37`: 55 cases (the sixteen `trap2` cases
included), $16.73, exit 1 — `digest/attention` 1 of 3, its first drop below 2 of 3 since it was
added in 3.6.0; `grandfather-xl/drift` and `trap2/react` 2 of 3; every other case 3 of 3. Nothing
in 4.6.0 touched the digest, eve or the briefing. Re-run alone with `--keep-temp`: **3 of 3**
($0.39) — the shape `grandfather-xl/drift` has shown since 4.1.0, a case that reads a built
registry losing a run when four cases build at once. The parallel run's failing traces are not
kept by `evals.sh`, so the reading rests on the re-run and the pattern; the case is unchanged.
The release run's cost is within C13's "about $16".

## Release run 4.5.0

`bash scripts/evals.sh -j 4`, 2026-10-08, at `682d0f3`: 39 cases, $12.30, exit 0 — every case
passed. Four at 2 of 3: `digest-attention` (as in 4.2.0 to 4.4.0), `grandfather-xl/drift` (2 of
3 in parallel this time, against 1 of 3 in the 4.3.0 and 4.4.0 runs; not re-run alone — the
threshold held), `intake/answered` (as on the 4.4.0 T3 text) and `intake/limit` (3 of 3 in every
earlier run; nothing in 4.5.0 touched the intake skill or its cases, so this is read as the
case's own variance until a second run says otherwise — no re-run, the sprint's measurement
budget was spent). The two reviewer cases, whose agent 4.5.0 changed, 3 of 3 here and 3 of 3
in the S12-T2 group run ($0.60).

## Release run 4.4.0

`bash scripts/evals.sh -j 4`, 2026-10-08, at `53f223b`: 39 cases, $12.45, exit 1 —
`grandfather-xl/drift` 1 of 3, the shape of the 4.1.0 results and of the 4.3.0 release run (with
four cases running at once the elder reads the map in fewer than one run in three, so has no
Redis claim to call wrong). Re-run alone with `--keep-temp`: 3 of 3, every reply naming
`PROJECT_MAP.md:25` as wrong; traces read with `trace-tools.sh`: 1 Agent call, 4–6 tools,
68.6k–69.2k input tokens each (44.8k in the main session) — within a few hundred tokens of the
4.3.0 re-run. Nothing in 4.4.0 touched the elders or the map. Every other case 3 of 3,
`intake/answered` included; `digest-attention` 2 of 3 as in 4.2.0 and 4.3.0.

*Written 2026-10-08 (Sprint 11, S11-T2), moved here the same day for room:*

## The intake case that passed before its sentence existed (4.4.0)

`intake/answered` was written for a fixed search list in the intake skill (field plan C3). Run
first against the 4.3.0 text, 2026-10-08: **3 of 3** — every reply read `docs/decisions.md`
unprompted and wrote its rules as binding. The design record's clause fired before the list was
written, so the list was not added; one sentence was (a claim of absence names what was
searched, REQ-7). With it: `answered` 3 of 3, `limit` 3 of 3, `nongoal` 3 of 3, `trivial` 3 of 3
($1.57). The case stays as the regression watch. The real run's miss happened in a 755-commit
repository where the answers sat in `.shipkit/research/` and a configuration comment; this
fixture is one file under `docs/`. A harder fixture would be a case built to justify a
sentence, so it was not built.


*Added 2026-10-08 (S11-T3):* the intake group on the T3 text (intake writes `intake.md` when nobody
can answer): `answered` **2 of 3**, `limit` 3 of 3, `nongoal` 3 of 3, `trivial` 3 of 3 ($1.71).
The failed `answered` run cited `docs/decisions.md:3-6` and treated its rules as binding, then
asked "How does the 'one partial refund' rule treat full refunds?" — a refinement of the
documented rule, which the three judges read as re-asking it. The grader is left as written: a
question whose answer is in the file's rule is the thing the case is for.

---

*Moved 2026-10-08 (Sprint 13, S13-T0, field plan C1): the five baselines the evals README held, unchanged.*

## Baseline 3.1.0

Recorded 2026-10-05 with `bash scripts/evals.sh` on Claude Code 2.1.289, shipkit 3.1.0 with the
always-on rules at 11,867 bytes, model `sonnet`, judge `haiku`, three runs per case.

| Case | Runs passed | Result |
|------|-------------|--------|
| `hello` | 3 of 3 | pass |
| `grandfather/lookup` | 3 of 3 | pass |
| `grandfather/explain` | 3 of 3 | pass |
| `grandfather/drift` | 3 of 3 | pass |
| `grandfather/gap` | 3 of 3 | pass |
| `rules/nontrivial` | 1 of 3 | **fail** |
| `rules/trivial` | 3 of 3 (both graders, every run) | pass |
| `rules/decision` | 3 of 3 | pass |

`rules/nontrivial` fails at the baseline, and the grader is right to fail it. In two of three
runs (and in a fourth trial run) Claude went straight to building refunds — test first, but
with no requirements, spec or question to the user — and reported the design choices it had
"made without asking". One run stopped and asked before writing code. So at 3.1.0 the
11,867 bytes of always-on rules produce the test-first habit reliably and the spec-first habit
about one time in three on this prompt. Sprint 1 must not make this worse (REQ-17); making it
better is what the later sprints are for.

The five cases above the `rules` rows took 62 seconds at four runs at a time and cost about
$1.63 at list price; the three `rules` cases took 76 seconds and about $1.14.

## After the rule shrink (3.2.0)

The three always-on rules went from 11,867 bytes to 2,960 in sprint task S1-T6. Same command,
same models, 2026-10-05:

| Case | Baseline 3.1.0 | After the shrink |
|------|----------------|------------------|
| `rules/trivial` | 3 of 3 | 3 of 3 |
| `rules/decision` | 3 of 3 | 3 of 3 |
| `rules/nontrivial` | 1 of 3 (fail) | 0 of 3 (fail) |

Because 0 of 3 against 1 of 3 could have been a real drop, `rules/nontrivial` was run six more
times on each version. In all: 1 of 10 runs passed with the old rules, 1 of 9 with the new.
These runs cannot tell the two apart.

## Baseline 4.1.0 (scoped)

The five `scoped` cases on the 4.1.0 tree (branch `sprint-9/rule-evals`, S9-T2), with the
rule installed by `with-rule.sh` and delivered by the hook. Claude Code 2.1.291, model
`sonnet`, `-j 4`, 2026-10-07. Tool calls from the traces (`scripts/trace-tools.sh`); no
`Agent` call in any run.

| Case | Runs passed | Tool calls per run | Cost |
|------|-------------|--------------------|------|
| `scoped/dependencies` | 3 of 3 | 4, 4, 5 | $0.26 |
| `scoped/migrations` | 3 of 3 | 4, 3, 4 | $0.27 |
| `scoped/monorepo` | 3 of 3 | 9, 8, 6 | $0.27 |
| `scoped/testing` | 3 of 3 | 9, 9, 10 | $0.32 |
| `scoped/ui-ux` | 3 of 3 | 6, 5, 5 | $0.30 |

15 of 15 runs, about $1.42, roughly 20 seconds a run at four in flight. Two graders were
corrected after the first run, each on the evidence of the traces, not to make a run pass:
`migrations` scored 1 of 3 because its regex knew `in_batches` and `find_each` but not the
id-range loop two runs wrote (`(min_id..max_id).step(BATCH_SIZE)` — batched, which is what the
rule asks); `monorepo` did not load at all, first because an `llm` grader may no longer take
a file `target:`, then because the replacement regex held a quote character the eval tool's
YAML parser rejects (write `\x27`). Whether any of the five passes without the rule is
S9-T4's question; these numbers are the with arm only.

## Baseline 4.1.0 (stacks)

The thirteen `stacks` cases on the 4.1.0 tree (S9-T3), rule installed and delivered as above.
Same tool, model and date; `-j 4`. Tool calls from the traces; no `Agent` call in any run.

| Case | Runs passed | Tool calls per run | Cost |
|------|-------------|--------------------|------|
| `stacks/mix-deps` | 3 of 3 | 5, 5, 4 | $0.27 |
| `stacks/go-mod` | 3 of 3 | 2, 2, 2 | $0.21 |
| `stacks/hotwire` | 3 of 3 | 8, 6, 4 | $0.33 |
| `stacks/liveview` | 3 of 3 | 5, 3, 3 | $0.26 |
| `stacks/data` | 3 of 3 | 9, 14, 3 | $0.42 |
| `stacks/experiments` | 3 of 3 | 5, 10, 7 | $0.32 |
| `stacks/notebooks` | 3 of 3 | 18, 16, 21 | $0.46 |
| `stacks/jobs` | 3 of 3 | 6, 5, 6 | $0.27 |
| `stacks/pyproject` | 3 of 3 | 5, 5, 6 | $0.27 |
| `stacks/gemfile` | 3 of 3 | 2, 2, 2 | $0.21 |
| `stacks/rails` | 3 of 3 | 3, 3, 3 | $0.23 |
| `stacks/package-json` | 3 of 3 | 3, 3, 4 | $0.24 |
| `stacks/react` | 3 of 3 | 8, 5, 7 | $0.30 |

39 of 39 runs, about $3.80, 204 seconds for the thirteen at four in flight. Two prompts were
changed after the first run, on the evidence of the traces: `gemfile` scored 0 of 3 because
all three runs **refused to edit** — the sandbox has no network, and the rule's own second
clause ("read the `Gemfile.lock` diff after `bundle install`") left the model unwilling to
guess a version for `~>`; the prompt now gives the major version and says there is no
network, as the `go-mod` and `package-json` prompts already did. `hotwire` scored 2 of 3
because one run put a correct `turbo_frame_tag` in a partial the regex does not read; the
prompt now asks for the markup in `show.html.erb` itself. The `gemfile` refusal is itself a
finding for `eval-results-4.2.md`: a rule that names a network step can stop an edit where
there is no network. With-arm numbers only; S9-T4 adds the other two arms.

## Baseline 4.0.0 (XL)

The five `grandfather-xl` cases on the 4.0.0 tree (branch `sprint-8/map-on-trial`, before any
map change), with the map, plugin on. Claude Code 2.1.289, model `sonnet`, judge `haiku`,
`-j 4`, 2026-10-07. Tool calls are from the traces (`scripts/trace-tools.sh`), main session and
subagent together; the one `Agent` call per run is included.

| Case | Runs passed | Tool calls per run | Input tokens per run (main session) |
|------|-------------|--------------------|-------------------------------------|
| `grandfather-xl/lookup` | 3 of 3 | 2, 2, 2 | 56.8k, 56.5k, 56.5k (45.1k, 44.8k, 44.8k) |
| `grandfather-xl/explain` | 3 of 3 | 3, 4, 5 | 68.6k, 68.7k, 80.9k (45.0k, 44.9k, 44.8k) |
| `grandfather-xl/drift` | 3 of 3 | 4, 3, 4 | 68.5k, 104.0k, 68.6k (44.8k, 68.1k, 44.7k) |
| `grandfather-xl/gap` | 3 of 3 | 6, 3, 4 | 81.5k, 105.0k, 69.0k (44.8k, 68.1k, 45.0k) |
| `grandfather-xl/history` | 3 of 3 | 7, 9, 7 | 82.4k, 82.0k, 83.6k (45.1k, 45.0k, 44.9k) |

15 of 15 runs, 65 tool calls (4.3 per run), $1.60. `lookup` is still answered in two calls —
the hand-off and one search — so the decoys did not cost the elder a step; `history` needed
seven to nine. The comparison against the no-map and plugin-off arms is in
`docs/design/eval-results-4.1.md`.

