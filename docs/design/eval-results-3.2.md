# Eval results for 3.2.0 — what the project map is worth

Measured 2026-10-05 for sprint task S1-T4 (spec `measure-and-slim`, REQ-12). The decision that
rests on these numbers is `.shipkit/decisions/0001-project-map-default.md`.

## What was run

The four `grandfather` cases (`lookup`, `explain`, `drift`, `gap`) from
`plugins/shipkit/evals/`, three runs each, under three conditions:

1. **With the map** — the fixture as shipped, shipkit 3.1.0 loaded.
2. **Without the map** — a scratch copy of the plugin whose fixture has no `PROJECT_MAP.md`,
   shipkit 3.1.0 loaded.
3. **Plugin off** — the fixture as shipped, no plugin loaded (the baseline arm of
   `--ablation with-without`).

Claude Code 2.1.289, model `sonnet`, judge `haiku`. Tool calls were counted from each run's
trace (`--keep-temp`), main session and subagent together. With the plugin loaded, every run
includes one `Agent` call: the hand-off from `/shipkit:ask` to `grandfather`.

## Results

| Condition | Cases passed (of 4) | Runs passed (of 12) | Tool calls, 12 runs | Tool calls per run | Cost (list price) |
|-----------|---------------------|---------------------|---------------------|--------------------|-------------------|
| With the map, plugin on | 4 | 12 | 49 | 4.08 | $1.37 |
| Without the map, plugin on | 3 | 9 | 51 | 4.25 | $1.37 |
| Plugin off (map present) | 4 | 12 | 37 | 3.08 | $0.71 |

Per case, runs passed and tool calls in each of the three runs:

| Case | With the map | Without the map | Plugin off |
|------|--------------|-----------------|------------|
| `lookup` | 3 of 3 — 2, 2, 2 | 3 of 3 — 2, 2, 2 | 3 of 3 — 1, 1, 1 |
| `explain` | 3 of 3 — 3, 4, 4 | 3 of 3 — 4, 4, 4 | 3 of 3 — 3, 3, 3 |
| `drift` | 3 of 3 — 5, 5, 5 | 0 of 3 — 5, 5, 5 | 3 of 3 — 4, 4, 4 |
| `gap` | 3 of 3 — 6, 6, 5 | 3 of 3 — 7, 5, 6 | 3 of 3 — 5, 3, 5 |

## How to read these numbers

**The one failing cell is not a wrong answer.** Without the map, `drift` failed all three runs,
and all three replies were correct: orders are stored in `data/orders.json`, cited to
`app/orders.py:11`. The case also requires the reply to say the map is wrong, and with no map
there is nothing to call wrong. So on the question each case asks, the elder answered 12 of 12
correctly with the map and 12 of 12 without it. The map's only "extra pass" is for noticing an
error that exists because the map does.

**The map saved almost no work.** 49 tool calls against 51 is 4% fewer. Three of the four cases
used the same number of calls either way.

**With the plugin off, Claude did as well with fewer calls and at about half the cost.** The prompt still began
`/shipkit:ask`; with no such skill, Claude answered the question directly. It passed all four
cases, including `drift` — it read the map, read the code, and said the map was wrong — and
used 12 fewer tool calls. The 12 extra calls with the plugin on are exactly the 12 `Agent`
hand-offs. The plugin-on runs keep the research out of the main session's context, which these
cases do not measure.

## What this does not show

- **The fixture has nine files.** A single `Grep` finds any answer. A map is an index, and an
  index is worth little when the whole library fits on one shelf. Nothing here says what the
  map is worth in a codebase of hundreds of files.
- **All four questions have their answer in one file.** There is no question about how the
  project evolved or why it is shaped as it is — the section of the map the archivist calls its
  highest-value part, and one the source cannot answer.
- **Twelve runs per condition.** Enough to see "no difference", not enough to rank small ones.
- **Context cost was not measured**: how many tokens stay in the main session with and without
  the elder. That is the elder's stated purpose and needs its own measure.

## Reproduce

```sh
# conditions 1 and 3
claude plugin eval plugins/shipkit --case 'grandfather-*' --ablation with-without \
  --model sonnet --threshold 0.66 --scaffold --keep-temp --allow-tools Bash
# condition 2: copy plugins/shipkit elsewhere, delete evals/fixtures/sample-app/PROJECT_MAP.md
# from the copy, and run the same command on the copy with --ablation none
```
