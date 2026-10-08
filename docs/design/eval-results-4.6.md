# Eval results for 4.6.0 — the second trap, with and without

Measured 2026-10-08 for sprint task S13-T2 (spec `second-traps`, REQ-4 to REQ-7). The sixteen
rule files whose 4.2.0 case passed equally without the rule (`eval-results-4.2.md`, reading 1)
each get a second case, under `plugins/shipkit/evals/trap2/`, whose prompt walks into the
rule's **second** named line — the line the 4.2.0 case did not probe — with a regex grader on
the written file. Three runs with the rule, three without.

**The first paragraph of 4.2.0's "What this does not show" still applies:** the eval sandbox
loads no file from the workspace's `.claude/`, so the rule is delivered by the plugin's hook as
always-on text. These numbers measure the rule's **text**. (Path-scoped loading itself was
measured in a normal session by smoke check 54 this sprint: the globs fire on a read of a
matching file — `evals/README.md`, "Path-scoped loading, measured".)

## What was run

The sixteen cases, three runs each, two arms, Claude Code 2.1.291, model `sonnet`, `-j 4`,
every run kept with `--keep-temp`:

1. **With the rule** — the plugin as committed at S13-T2: `with-rule.sh <rule>` installs the one
   file and `inject-rule.sh --eval-rule` prints it.
2. **Without** — a scratch copy whose `with-rule.sh` defaults `SHIPKIT_EVAL_NO_RULE` to `1`.

Counts are read from the traces with `scripts/trace-tools.sh`, never from the eval summary.
The three readings: **passes without on both traps** (the 4.2.0 case and this one) → a named
cut candidate for the next plan, by C8 — no rule text changes in this sprint; **separates on
trap 2** → the line earns its bytes; **fails even with** → the grader or prompt is read from
the traces before anything else is concluded.

## The sixteen rows

| Case | Rule | Second trap (the line probed) | With | Without | Reading |
|------|------|-------------------------------|------|---------|---------|
| `data` | `stacks/ml data.md` | Document provenance and licence for every dataset: where it came from, when it was pulled, what the terms permit. | 3 of 3 | 1 of 3 | **separates on trap 2** — with the rule every run wrote `datasets/README.md` with provenance and licence fields (blank where it could not know); without it two runs wrote nothing and asked for the facts first, one wrote the file |
| `experiments` | `stacks/ml experiments.md` | Device selection is explicit (cuda / mps / cpu), configurable, and logged. Never silently fall back to CPU for a training run. | 3 of 3 | 0 of 3 | **separates on trap 2** — without the rule every run wrote `"cuda" if torch.cuda.is_available() else "cpu"` and never printed the choice; with it the device is an argument or config value and every run logs it. *(First prompt corrected on trace evidence: the fixture's `train.py` had no training loop and every run in both arms declined to change it; the prompt now asks for the entry point.)* |
| `gemfile` | `stacks/rails gemfile.md` | For Rails AI features prefer ruby_llm unless the project already uses another. | 3 of 3 | 0 of 3 | **separates on trap 2** — with the rule every run added `ruby_llm`; without it every run added `anthropic` |
| `go-mod` | `stacks/go go-mod.md` | Never vendor unless the project already has vendor/. | 3 of 3 | 0 of 3 | **separates on trap 2** — without the rule every Makefile ran `go mod vendor` for the offline build; with it none did (module cache, `GOFLAGS=-mod=mod`) |
| `hotwire` | `stacks/hotwire hotwire.md` | Use static values/targets/outlets — never document.querySelector or getElementById from inside a controller. | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate |
| `liveview` | `stacks/liveview liveview.md` | Put URL-derived state in handle_params/3, not mount/3 — it is what runs on push_patch/live_patch. | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate |
| `migrations` | `rules/migrations.md` | An index on a high-traffic table needs CONCURRENTLY or the ORM's equivalent, or writes block until it is built. | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate |
| `mix-deps` | `stacks/elixir mix-deps.md` | Dev and test dependencies take only: [:dev, :test], runtime: false — without it they ship. | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate |
| `monorepo` | `rules/monorepo.md` | Run targeted builds and tests with --filter (pnpm, turbo) or --scope; a full-monorepo run on every edit is what makes people skip the tests. | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate |
| `notebooks` | `stacks/ml notebooks.md` | Clear outputs before committing (nbstripout, or jupyter nbconvert --clear-output). | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate. *(First grader target corrected on trace evidence: every run in both arms wrote the right `nbstripout` hook and the sandbox denied writing a root dotfile; the case now asks for a Makefile target.)* |
| `package-json` | `stacks/react package-json.md` | Detect the package manager from the lockfile — package-lock.json → npm, yarn.lock → yarn, pnpm-lock.yaml → pnpm, bun.lockb → bun — and use only that one. | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate. *(First regex corrected on trace evidence: every run in both arms wrote `pnpm install --frozen-lockfile` and the `npm install` exclusion matched inside `pnpm install`.)* |
| `pyproject` | `stacks/python pyproject.md` | Detect the package manager from the lockfile — poetry.lock → poetry, uv.lock → uv, Pipfile.lock → pipenv, else pip — and use that one; never install outside a virtualenv. | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate |
| `rails` | `stacks/rails rails.md` | Never update_column / update_columns — they skip validations and callbacks. | 3 of 3 | 2 of 3 | passes without, at the threshold — without the rule one run used `update_columns` and two used `update_attribute` (not named by the rule, and it also skips validations); with it none |
| `react` | `stacks/react react.md` | Routing stays in Rails. No client-side router duplicating config/routes.rb; use Inertia links/visits. | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate |
| `testing` | `rules/testing.md` | Match the project's test framework and file layout; do not introduce a second runner. | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate |
| `ui-ux` | `rules/ui-ux.md` | Every control has an accessible name — visible label, aria-label, or aria-labelledby. Icon-only buttons always need one. | 3 of 3 | 3 of 3 | passes without on both traps — cut candidate |

## The three readings

**Separates on trap 2 — four of sixteen.** `data` (provenance and licence fields written without
being asked, where without the rule two runs would not write at all), `gemfile` (`ruby_llm`
against `anthropic`, three to none), `go-mod` (no vendoring for an offline build, three to none),
`experiments` (an explicit, logged device against a silent fallback, three to none). Each of
these four files has one line the 4.2.0 case did not probe that changed what `sonnet` wrote on
2026-10-08. The 4.2.0 reading stands for their first lines.

**Passes without on both traps — twelve of sixteen, named cut candidates (C8).** `hotwire`,
`liveview`, `migrations`, `mix-deps`, `monorepo`, `notebooks`, `package-json`, `pyproject`,
`react`, `testing`, `ui-ux` at 3 of 3 in both arms, and `rails` at 3 of 3 against 2 of 3 — the
one without-run that reached for `update_columns` is the trap the line names, and the two that
used `update_attribute` skipped validations by a method the line does not name. Two lines per
file, two measurements each: that is what the next plan needs to decide a cut. No rule text
changes on these numbers in this sprint.

**Fails even with — none, after three cases were corrected on trace evidence** (the rows say
what was wrong: a fixture with nothing to train, a root dotfile the sandbox would not write, a
regex that matched `pnpm` as `npm`). The first run of the sixteen cost $9.09 (96 runs); the
re-run of the three corrected cases in both arms, with the owner's yes, $1.60 (18 runs).
Tool calls per run from the traces: 1 to 11 with the rule, 2 to 10 without; no `Agent` call in
any run.


## What this does not show

One line per file, one model, one day — the same limits as 4.2.0. A rule whose both traps pass
without it is a rule the model follows unaided *today*; whether a line is still worth its
bytes as a statement of the project's standards is the next plan's decision, with these two
measurements in hand (C8). A case that separates on trap 2 shows the text changed the result on
that line, not on the file's other lines.

## Reproduce

```sh
EVALS_OUT="$TMPDIR/s13-with" bash scripts/evals.sh --group trap2 -j 4 --keep-temp
cp -R plugins/shipkit "$TMPDIR/shipkit-norule-s13"
sed -i '' 's/^: "${SHIPKIT_EVAL_NO_RULE:=}"/: "${SHIPKIT_EVAL_NO_RULE:=1}"/' "$TMPDIR/shipkit-norule-s13/evals/lib/with-rule.sh"
claude plugin eval "$TMPDIR/shipkit-norule-s13" --trust-plugin --ablation none --no-publish \
  --model sonnet --threshold 0.66 --output-dir "$TMPDIR/s13-norule" --case 'trap2-*' \
  -j 4 --keep-temp --scaffold --allow-tools Bash Write Edit
sh scripts/trace-tools.sh "$TMPDIR/s13-with"; sh scripts/trace-tools.sh "$TMPDIR/s13-norule"
```
