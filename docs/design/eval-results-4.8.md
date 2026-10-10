# Eval results for 4.8.0 — the cuts, re-measured

Measured 2026-10-10 for sprint task S15-T1 (spec `measured-cuts`, REQ-1 and REQ-2; portfolio
plan E1). Seven rule files lost the two lines their cases had measured — the line each 4.2.0
case walks into (`eval-results-4.2.md`, reading 1: passes equally without) and the line each
`trap2/` case walks into (`eval-results-4.6.md`: passes without on both traps) — and their
fourteen cases, unchanged, were run three times each on the trimmed file. Four files whose
whole body is their two measured lines (`migrations`, `monorepo`, `testing`, `package-json`)
and `rails` (2 of 3 without, the threshold) keep theirs by the design's record; the owner said
"keep" at T0.

## What was run

`bash scripts/evals.sh --case <name> -j 3 --keep-temp`, one invocation per case, Claude Code
2.1.291, model `sonnet`, the plugin as committed at S15-T1 (the trimmed files installed by
`with-rule.sh` as always). 42 runs, $4.07. Counts read from the traces with
`scripts/trace-tools.sh`; the two runs below 3 of 3 read before the table was written (rule 10).

## The seven files

| File | Bytes | Lines | Trap-1 case (4.2.0 with / without → trimmed) | Trap-2 case (4.6.0 with / without → trimmed) | Tool calls (trap-1; trap-2) |
|------|-------|-------|---------------------------------------------|---------------------------------------------|-----------------------------|
| `rules/ui-ux.md` | 1,972 → 1,702 | 65 → 61 | 3 / 3 → **3 of 3** | 3 / 3 → **3 of 3** | 4, 4, 3; 8, 4, 8 |
| `stacks/hotwire hotwire.md` | 2,020 → 1,580 | 40 → 34 | 3 / 3 → **3 of 3** | 3 / 3 → **3 of 3** | 6, 15, 5; 6, 8, 6 |
| `stacks/liveview liveview.md` | 1,973 → 1,618 | 40 → 35 | 3 / 3 → **3 of 3** | 3 / 3 → **3 of 3** | 3, 3, 3; 11, 9, 10 |
| `stacks/elixir mix-deps.md` | 322 → 166 | 9 → 7 | 3 / 3 → **3 of 3** | 3 / 3 → **3 of 3** | 4, 6, 5; 2, 3, 3 |
| `stacks/ml notebooks.md` | 1,015 → 587 | 20 → 15 | 3 / 3 → **3 of 3** | 3 / 3 → **2 of 3** (see below) | 14, 12, 16; 5, 5, 4 |
| `stacks/python pyproject.md` | 483 → 186 | 13 → 10 | 3 / 3 → **3 of 3** | 3 / 3 → **3 of 3** | 5, 5, 5; 4, 3, 3 |
| `stacks/react react.md` | 1,077 → 701 | 14 → 9 | 3 / 3 → **3 of 3** | 3 / 3 → **2 of 3** (see below) | 5, 7, 8; 9, 12, 12 |

2,342 bytes and 33 lines out; the always-on rules are untouched (2,979 bytes). No file is near
lint's 40-line stack limit.

## The two runs below 3 of 3

**`trap2/notebooks`, run 1.** The reply added a `notebooks-clean` Makefile target that clears
every code cell's `outputs` and `execution_count` through a standard-library script it wrote
(`scripts/clean_notebook.py`), because the prompt forbids installing anything; it ran the
target twice and reverted the one whitespace diff. The grader's regex names the tools the cut
line named as examples (`nbstripout|clear-output|ClearOutput`) and so missed a reply that does
what the line asks. The line was followed; the grader was narrower than the line. The grader
is **not** changed in this sprint — the watch cases stay byte-identical to their 4.6.0 form so
the comparison holds — and the widening (`outputs` cleared by any means) is named for the
plan after.

**`trap2/react`, run 1.** The reply read the code and stopped to propose a spec with three
requirements, as the always-on spec-driven rule asks of non-trivial work, and wrote no file;
the grader fails a missing file. The routing line was not tested in that run. The two runs
that built used Inertia links and no client router.

Neither run walked into its trap, so no line returns. Both cases are at 2 of 3, which is the
threshold the clause names; a release run below it reads the traces first, as here.

## Reading

Fourteen of fourteen cases hold on the trimmed text. Each cut line now has three measurements
saying `sonnet` follows it unaided — with the text, without it, and with the file as shipped —
on three days. The cases stay as the watch (`evals/README.md`, "The cuts (4.8.0)"); the clause
in `.shipkit/specs/measured-cuts/design.md` brings a line back on a release run below 2 of 3.

## What this does not show

One model, three days. Whether a later model follows these lines unaided is what the watch is
for. The four kept files and `rails` were not re-run: nothing in them changed.
