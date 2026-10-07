# Eval results for 4.2.0 — every rule file, with, without, and before the trim

Measured 2026-10-07 for sprint task S9-T4 (spec `rule-evals`, REQ-14 to REQ-16). Eighteen
rule files — the five path-scoped core rules and the thirteen stack rule files — each with a
case whose prompt walks into the rule's first named trap, run three times in each of three
arms. The trim audit of 4.0 (`trim-audit-4.0.md`) kept or cut lines on criteria (a) and (b)
alone and said so; this is criterion (c), "shown by an eval to change the result", measured.

**Read the first paragraph of "What this does not show" before the table.** The eval sandbox
loads no file from the workspace's `.claude/`, so every rule here is delivered by the plugin's
session hook as always-on text. The numbers measure the rule's **text**, not path-scoped
loading.

## What was run

The eighteen cases under `plugins/shipkit/evals/scoped/` and `evals/stacks/` (prompts, traps
and graders in `evals/README.md`), three runs each, under three conditions:

1. **With the rule** — the plugin as committed at S9-T3: the scaffold installs the one rule
   file under test with `evals/lib/with-rule.sh`, and `inject-rule.sh --eval-rule` prints it.
2. **Without the rule** — a scratch copy of the plugin whose `with-rule.sh` defaults
   `SHIPKIT_EVAL_NO_RULE` to `1`: the same fixture, no rule file, no marker, nothing printed.
3. **Pre-trim text** — a scratch copy whose `with-rule.sh` defaults `SHIPKIT_EVAL_RULE_REF` to
   `v3.7.0` and knows the repository path: the rule's text as it was before the 4.0 trim,
   taken by `git show`. Run for the fourteen files the trim changed; the four it did not
   (`ml/data`, `ml/experiments`, `ml/notebooks`, `oban/jobs`) are byte-identical at `v3.7.0`
   and `HEAD` (`git diff v3.7.0 HEAD --stat`), so their pre-trim arm would repeat arm 1 and
   was not bought.

Claude Code 2.1.291, model `sonnet`, `-j 4`, every run kept with `--keep-temp`; the three
arms ran back to back between 12:57 and 13:09. Tool calls were counted from each run's
`trace.jsonl` by `scripts/trace-tools.sh`, never from the eval summary; no run called an
`Agent`. The traces also show the delivery: the hook's "rule in force" block appears in all
54 with-arm and all 42 pre-trim runs and in none of the 54 without-arm runs.

The T2 and T3 baselines (same tree, same command as arm 1, run an hour earlier) are a second
set of with-rule runs: 54 of 54 there too.

## Results

| Condition | Cases | Runs passed | Tool calls | Tool calls per run | Cost (list) |
|-----------|-------|-------------|------------|--------------------|-------------|
| With the rule | 18 | 54 of 54 | 291 | 5.39 | $5.07 |
| Without the rule | 18 | 48 of 54 | 282 | 5.22 | $4.82 |
| Pre-trim text (`v3.7.0`) | 14 | 42 of 42 | 215 | 5.12 | $3.82 |

Per rule, runs passed and the tool calls of each run:

| Rule | With | tool calls | Without | tool calls | Pre-trim | tool calls |
|---|---|---|---|---|---|---|
| `rules/dependencies` | 3 of 3 | 4, 4, 5 | **0 of 3** | 2, 2, 2 | 3 of 3 | 7, 8, 8 |
| `rules/migrations` | 3 of 3 | 4, 4, 3 | 3 of 3 | 5, 5, 6 | 3 of 3 | 5, 4, 5 |
| `rules/monorepo` | 3 of 3 | 10, 8, 7 | 3 of 3 | 10, 9, 9 | 3 of 3 | 9, 9, 9 |
| `rules/testing` | 3 of 3 | 9, 9, 12 | 3 of 3 | 11, 9, 8 | 3 of 3 | 9, 9, 9 |
| `rules/ui-ux` | 3 of 3 | 4, 4, 4 | 3 of 3 | 5, 3, 5 | 3 of 3 | 4, 4, 5 |
| `elixir/mix-deps` | 3 of 3 | 5, 4, 4 | 3 of 3 | 3, 3, 3 | 3 of 3 | 4, 5, 4 |
| `go/go-mod` | 3 of 3 | 2, 2, 2 | 3 of 3 | 3, 2, 2 | 3 of 3 | 3, 2, 2 |
| `hotwire/hotwire` | 3 of 3 | 6, 3, 5 | 3 of 3 | 4, 3, 3 | 3 of 3 | 6, 3, 5 |
| `liveview/liveview` | 3 of 3 | 3, 3, 3 | 3 of 3 | 4, 4, 4 | 3 of 3 | 3, 3, 3 |
| `ml/data` | 3 of 3 | 4, 4, 10 | 3 of 3 | 9, 4, 4 | same text | — |
| `ml/experiments` | 3 of 3 | 10, 8, 5 | 3 of 3 | 4, 3, 4 | same text | — |
| `ml/notebooks` | 3 of 3 | 6, 17, 17 | 3 of 3 | 15, 10, 15 | same text | — |
| `oban/jobs` | 3 of 3 | 8, 5, 5 | **0 of 3** | 4, 4, 5 | same text | — |
| `python/pyproject` | 3 of 3 | 6, 5, 5 | 3 of 3 | 6, 7, 7 | 3 of 3 | 6, 6, 5 |
| `rails/gemfile` | 3 of 3 | 2, 2, 2 | 3 of 3 | 2, 2, 2 | 3 of 3 | 2, 2, 2 |
| `rails/rails` | 3 of 3 | 3, 3, 3 | 3 of 3 | 3, 3, 3 | 3 of 3 | 3, 3, 3 |
| `react/package-json` | 3 of 3 | 3, 3, 3 | 3 of 3 | 3, 4, 5 | 3 of 3 | 3, 5, 3 |
| `react/react` | 3 of 3 | 8, 6, 5 | 3 of 3 | 8, 9, 8 | 3 of 3 | 10, 9, 6 |

## The three readings that matter

**1. Rules whose case passes equally without them — sixteen of eighteen.** For each, the
without-arm traces show the model doing what the rule's first trap asks, unprompted:

| Rule | What the three without-arm runs wrote |
|---|---|
| `migrations` | an id-range loop (`.step(BATCH_SIZE)`) twice, `in_batches(of: 10_000)` once |
| `monorepo` | `pnpm --filter web test` and `… api test` (twice), a turbo filter per package once |
| `testing` | `from tests.support import make_order` (or `from support …`) in all three |
| `ui-ux` | `<li><a href="orders/1041.html">…</a></li>` in all three; no `onclick` anywhere |
| `mix-deps` | `{:tesla, "~> 1.9"}` in all three |
| `go-mod` | `go get github.com/spf13/cobra@latest` in all three; `go.mod` untouched by hand |
| `hotwire` | `turbo_frame_tag "line_items"` in all three |
| `liveview` | `if connected?(socket), do: Phoenix.PubSub.subscribe(…)` in all three |
| `data` | `data/*` in `.gitignore` plus a fetch step in all three |
| `experiments` | `df.sample(frac=1, random_state=SEED)` in all three |
| `notebooks` | the function in the package and imported by the notebook in all three |
| `pyproject` | `"httpx>=0.28,<1"` in all three |
| `gemfile` | `gem "pagy", "~> 9.0"` in all three |
| `rails` | `Order.where(status: "paid").find_each` in all three |
| `package-json` | `pnpm add clsx` in all three; no `npm`, `yarn` or `bun` |
| `react` | `total_cents` as a prop from the controller in all three; no `fetch`, no `useEffect` |

What I believe, from the traces: these are **cases whose first trap the model already
avoids**, not evidence that the files are dead weight. Each case probes one line — the first
named trap — and `sonnet` on 2026-10-07 clears that line unaided every time. Nothing here
measures the other lines (`hotwire.md` has fourteen bullets; one was probed), a different
model, or a user whose own habits differ from the model's defaults. The right reading is the
plan's: a finding, recorded, and no rule is edited on it in this sprint. The next plan may
pick the second-named trap for the files it doubts, or decide that a line the model already
follows is still worth its bytes as a statement of the project's standards.

**2. Rules whose pre-trim text scores higher than the 4.0 text — none.** Fourteen files, 42 of
42 runs in both arms. The trims cost nothing on these cases. One cost ran the other way:
`dependencies.md` at `v3.7.0` ("read the docs first", "run the full test suite after",
"check for security advisories") took 7, 8 and 8 tool calls against 4, 4 and 5 with the
trimmed text — the model obeyed the generic lines and ran things the task did not need. The
other thirteen moved within a call or two either way.

**3. Rules whose case fails even with the rule — none, after one prompt was corrected.** The
first `gemfile` run scored 0 of 3 *with* the rule installed: all three runs refused to edit
the `Gemfile` because the sandbox has no network, and the rule's second line ("read the
`Gemfile.lock` diff after `bundle install`") left the model unwilling to guess a version for
`~>`. That is the rule stopping the edit, which is a finding of its own: a rule that names a
network step can halt work where there is no network, and a prompt has to say so. The prompt
now gives the major version and states there is no network, as the `go-mod` and
`package-json` prompts already did; with that, 3 of 3 in every arm.

**The two rules that earn their line.** `rules/dependencies` — without it, every run wrote a
bare `"requests"`; with it, `"requests>=2.32.3,<3"` twice and `"requests==2.32.5"` once (a
pin is not "unpinned"; the regex and the rule agree). `oban/jobs` — without it, every run
wrote a `perform/1` that calls the gateway with no guard; with it, every run added a
`unique:` option (`period: :infinity`, keyed on the worker and args or on `order_id`). The
at-least-once trap is the first line of the file, and on this evidence it is the line that
changes what gets written.

## How to read these numbers

- Three runs per arm cannot tell 3 of 3 from 2 of 3 reliably; they can tell 3 of 3 from 0 of
  3, which is the only separation this table shows. The two rules that separate the arms do
  so completely.
- Tool-call counts vary more between runs of one arm than between arms (`notebooks`: 6 to
  17 with the rule). No per-rule tool-call difference here is a claim; the one named above
  (`dependencies`, pre-trim) is three runs against three and is offered as a direction, not
  a size.
- "Same text" in the pre-trim column is a reading of `git diff v3.7.0 HEAD`, not a run.
- A pass is a regex on the file the run wrote (`evals/README.md` lists each), so a pass
  without the rule means the file has what the rule asks for, not that the reply mentioned
  the rule.

## What this does not show

- **Path-scoped loading.** `claude plugin eval` runs the model with
  `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1` and loads no `.claude/` file or `CLAUDE.md` from the
  workspace (the Check first of S9-T1, `evals/README.md`). Every rule here reached the model
  through the session hook as always-on text. Whether a rule's `paths:` globs fire on the
  file the prompt edits — the thing that makes a path-scoped rule path-scoped — is measured
  by nothing in this sprint. Two of the eighteen (`rails.md`, `react.md`) have no `paths:`
  line and are always-on in a real project anyway.
- **The other lines of each file.** One trap per file was probed. A file whose first trap the
  model clears unaided may hold a later line it does not.
- **Other models.** `sonnet` only. The defaults that make sixteen cases pass without a rule
  are this model's.
- **The rule in company.** Only the file under test was installed, so a stack rule was
  measured alone, not next to `rules/dependencies.md`; a user has both.
- **Four runs wrote the graded file with Bash** (a heredoc) rather than `Write` or `Edit`;
  the grader read the file either way, and the trace extract above used the file's content
  where the tool input had it.

## Reproduce

```sh
# with the rule (arm 1): the committed plugin
EVALS_OUT="$TMPDIR/t4-with-scoped" bash scripts/evals.sh --group scoped -j 4 --keep-temp
EVALS_OUT="$TMPDIR/t4-with-stacks" bash scripts/evals.sh --group stacks -j 4 --keep-temp

# without (arm 2) and pre-trim (arm 3): scratch copies, one line each in with-rule.sh
cp -R plugins/shipkit "$TMPDIR/shipkit-norule"
sed -i '' 's/^: "${SHIPKIT_EVAL_NO_RULE:=}"/: "${SHIPKIT_EVAL_NO_RULE:=1}"/' "$TMPDIR/shipkit-norule/evals/lib/with-rule.sh"
cp -R plugins/shipkit "$TMPDIR/shipkit-pretrim"
sed -i '' -e 's/^: "${SHIPKIT_EVAL_RULE_REF:=}"/: "${SHIPKIT_EVAL_RULE_REF:=v3.7.0}"/' \
  -e "s|^REPO=.*|REPO=$PWD|" "$TMPDIR/shipkit-pretrim/evals/lib/with-rule.sh"
rm -rf "$TMPDIR/shipkit-pretrim/evals/stacks"/{data,experiments,notebooks,jobs}   # same text
for arm in norule pretrim; do for g in scoped stacks; do
  claude plugin eval "$TMPDIR/shipkit-$arm" --trust-plugin --ablation none --no-publish \
    --model sonnet --threshold 0.66 --output-dir "$TMPDIR/t4-$arm-$g" --case "$g-*" \
    -j 4 --keep-temp --scaffold --allow-tools Bash Write Edit
done; done

# count from the traces, never the summary
for d in "$TMPDIR"/t4-*; do sh scripts/trace-tools.sh "$d"; done
```
