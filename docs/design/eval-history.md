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
