# Eval results for 4.1.0 — the map on a 224-file fixture

Measured 2026-10-07 for sprint task S8-T3 (spec `map-on-trial`, REQ-12 to REQ-14). This is the
re-test that decision 0001 (`.shipkit/decisions/0001-project-map-default.md`) asked for before
anyone acted on it: the same question as `eval-results-3.2.md`, on a fixture of at least 200
files, with one question about how the project evolved.

## What was run

The five `grandfather-xl` cases (`lookup`, `explain`, `drift`, `gap`, `history`) from
`plugins/shipkit/evals/`, on the generated `ledger` fixture (224 files, 27 commits, the facts in
`evals/fixtures/FACTS-XL.md`), three runs each, under three conditions:

1. **With the map** — the fixture as generated, shipkit 4.0.0 loaded (the `with` arm of
   `--ablation with-without`).
2. **Without the map** — a scratch copy of the plugin whose XL scaffolds pass `--no-map`,
   shipkit 4.0.0 loaded (the eval tool does not forward the caller's environment to a
   scaffold, so `SHIPKIT_EVAL_NO_MAP=1` cannot select the arm; see `evals/README.md`). The
   git history is byte-identical to arm 1: the map is untracked in both.
3. **Plugin off** — the fixture as generated, no plugin loaded (the `without` arm of the
   same `--ablation with-without` run as arm 1).

Claude Code 2.1.291, model `sonnet`, judge `haiku`, `-j 4`, every run kept with `--keep-temp`.
Tool calls and tokens were counted from each run's `trace.jsonl` by `scripts/trace-tools.sh`
— never from the eval summary — main session and subagent together. With the plugin loaded,
every run includes one `Agent` call: the hand-off from `/shipkit:ask` to `grandfather`.

The baseline run of S8-T2 (same tree, same command as arm 1, run two hours earlier) is a fourth
set of fifteen with-map runs and is reported as a check on arm 1.

## Results

| Condition | Cases passed (of 5) | Runs passed (of 15) | Tool calls, 15 runs | Tool calls per run | Input tokens per run (main session) | Cost (list) |
|-----------|---------------------|---------------------|---------------------|--------------------|-------------------------------------|-------------|
| With the map, plugin on | 5 | 14 | 62 | 4.13 | 78.0k (48.0k) | $1.58 |
| Without the map, plugin on | 4 | 12 | 65 | 4.33 | 73.8k (45.2k) | $1.59 |
| Plugin off (map present) | 4 | 13 | 51 | 3.40 | 48.5k (48.5k) | $0.88 |
| *With the map, plugin on — S8-T2 baseline run* | *5* | *15* | *65* | *4.33* | *75.5k (48.0k)* | *$1.58* |

Per case, runs passed and tool calls in each of the three runs:

| Case | With the map | Without the map | Plugin off | *With the map, baseline run* |
|------|--------------|-----------------|------------|------------------------------|
| `lookup` | 3 of 3 — 2, 3, 2 | 3 of 3 — 2, 2, 2 | 3 of 3 — 2, 1, 1 | *3 of 3 — 2, 2, 2* |
| `explain` | 3 of 3 — 5, 5, 5 | 3 of 3 — 4, 4, 3 | 3 of 3 — 4, 4, 5 | *3 of 3 — 3, 4, 5* |
| `drift` | 2 of 3 — 4, 3, 4 | 0 of 3 — 4, 4, 5 | 1 of 3 — 5, 5, 4 | *3 of 3 — 4, 3, 4* |
| `gap` | 3 of 3 — 3, 3, 5 | 3 of 3 — 5, 6, 6 | 3 of 3 — 3, 3, 2 | *3 of 3 — 6, 3, 4* |
| `history` | 3 of 3 — 5, 7, 6 | 3 of 3 — 5, 6, 7 | 3 of 3 — 4, 4, 4 | *3 of 3 — 7, 9, 7* |

## The two numbers the clause asks for

Decision 0001: *restore the map as the default if, on this fixture, it gives at least one more
correct answer or at least 20% fewer tool calls than no map.* The counting rule for `drift` was
fixed in the spec's design before any run (REQ-14): a pass that exists only because the map
contains the planted error is not one more correct answer.

- **One more correct answer? No.** By the graders, 14 of 15 runs with the map against 12 of 15
  without. The three-run gap is `drift`, which requires the reply to say the map is wrong, and
  without a map there is nothing to call wrong. Read for the fact the question asks — where
  are inventory counts cached? — **all nine `drift` replies, in every arm, are right**: a
  module-level dict, `_counts`, at `app/inventory/cache.py:2`, per worker, emptied on restart.
  The one with-map failure is the same shape in reverse: the elder answered correctly from the
  source and never opened the map, so it never saw the Redis claim to contradict. On the
  questions asked, the elder answered 15 of 15 with the map and 15 of 15 without.
- **At least 20% fewer tool calls? No.** 62 against 65 is **4.6% fewer**. Counting the
  baseline run too, thirty with-map runs used 127 calls (4.23 per run) against 65 in fifteen
  without (4.33 per run): 2.3% fewer.

Both numbers fall on the clause's "otherwise" side, as they did on the nine-file fixture.

## How to read these numbers

**The elder rarely reads the map, even when told to.** `grandfather`'s first instruction is to
read `PROJECT_MAP.md` as an index. In the thirty with-map runs it opened the map in nine. It
greps first; the grep finds the answer; the map is read, if at all, afterwards. With the plugin
off, Claude read the map in nine of fifteen runs — more often than the elder did — because its
own grep for the term landed on the map's line and it followed the hit.

**The history question did not separate the arms.** `history` is the case the record asked
for: its answer is in commit 20's message and in the map's *Evolution* section, not in the
current source. Every run in every arm answered it, and every run — with the map or without —
ran `git log`, twice. Of the six with-map `history` runs (arm 1 and the baseline), five read
the map as well, and four of those ran `git log` before opening it. The map's two sentences
did not replace the history; they were checked against it. On this fixture the history is twenty-seven well-written commit messages,
which is the best case for `git log` and the weakest for an Evolution section; a project with a
noisier log would test this better.

**The decoys cost nothing.** `lookup` has two wrong `MAX_RETRIES` constants beside the right
`RETRY_CAP`; the elder found the right one in a single grep in every run, with or without a
map, and said why the other two were not it. The fixture makes the elder search more than
`sample-app` did (4.1 calls per run against 3.1 in 3.2) but a single well-chosen grep still
finds most answers.

**Context cost is the same either way.** The main session's input tokens — what the elder is
meant to keep out of your context — are 48.0k per run with the map and 45.2k without. The map
is not what keeps the main session thin; the hand-off is. With the plugin off everything runs in
the main session (48.5k, all of it main) at just over half the cost, because there is no second
agent; what that buys is a thinner main context for the *next* question, which these one-shot
cases cannot measure, as 3.2 also noted.

**Plugin off was again cheaper and about as accurate.** 51 calls against 62 and $0.88 against
$1.58. The eleven-call difference is the fifteen `Agent` hand-offs less the four calls the
elder saved by searching from a fresh context. This is the same picture as 3.2 and is not what
this sprint decides; it is recorded.

## What this does not show

- **Fifteen runs per arm.** Enough to see "no difference" again; not enough to rank the small
  ones (62 against 65 is inside run-to-run noise: the two with-map sets differ by 3 themselves).
- **One kind of history.** Clean, descriptive commit messages. A map's Evolution section might
  earn its keep on a repository whose log says "fix", "wip", "more fixes"; this fixture cannot
  say.
- **One elder, one shot.** `eve` answers portfolio questions from maps without opening each
  repository; nothing here measures that, and nothing in this sprint changes it.
- **The map was never stale.** It was generated with the code. A stale map's cost — a wrong
  answer trusted — is the case against the map in the record and is not measured here either.

## Reproduce

```sh
# arms 1 and 3 (with the map, and plugin off), kept traces
claude plugin eval plugins/shipkit --trust-plugin --ablation with-without --no-publish \
  --model sonnet --threshold 0.66 --output-dir "$TMPDIR/xl-arm-with-off" \
  --case 'grandfather-xl-*' -j 4 --keep-temp --scaffold --allow-tools Bash Write Edit
# arm 2: a scratch copy whose scaffolds pass --no-map
cp -R plugins/shipkit "$TMPDIR/shipkit-nomap"
sed -i '' 's/generate.py" \$flags/generate.py" --no-map/' "$TMPDIR/shipkit-nomap"/evals/grandfather-xl/*/fixture.sh
claude plugin eval "$TMPDIR/shipkit-nomap" --trust-plugin --ablation none --no-publish \
  --model sonnet --threshold 0.66 --output-dir "$TMPDIR/xl-arm-nomap" \
  --case 'grandfather-xl-*' -j 4 --keep-temp --scaffold --allow-tools Bash Write Edit
# the numbers
sh scripts/trace-tools.sh "$TMPDIR/xl-arm-with-off" "$TMPDIR/xl-arm-nomap"
```

The no-map run exits 1: `drift` scores 0 of 3 there by design, below the threshold.
