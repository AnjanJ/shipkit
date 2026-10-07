# Shipkit evals

Cases that measure whether shipkit changes what Claude does. They run with `claude plugin eval`
(Claude Code 2.1.269 or later) and make real model calls on your account.

```sh
bash scripts/evals.sh                 # every case, three runs each
bash scripts/evals.sh --case hello    # one case
```

`scripts/evals.sh` exits non-zero if any case fails. A case passes when at least two of its three
runs pass (`--threshold 0.66`). The model under test is pinned to `sonnet` so that a change of
default model is not mistaken for a change in shipkit; set `EVALS_MODEL` to use another. Results
(`aggregate-result.json`, `report.html`) go to `$TMPDIR/shipkit-evals`, or to `EVALS_OUT`.

## The case format that works

Verified on Claude Code 2.1.289. One directory per case, holding a prompt and its graders:

```text
evals/
  hello/
    prompt.md            frontmatter: run limits and tools; body: the prompt, sent as written
    graders/
      names-map.md       frontmatter: type and options; body: the rubric (llm graders only)
```

`prompt.md`:

```markdown
---
max_turns: 3
allowed_tools: [Read, Glob, Grep]
---

Which shipkit skill builds PROJECT_MAP.md?
```

`graders/names-map.md`:

```markdown
---
type: regex
pattern: '/shipkit:map'
---
```

A directory is a case only if it holds `prompt.md` or `case.yaml`, so cases can be grouped under
a plain folder, and a folder without either file, such as `fixtures/`, is ignored.
An unknown frontmatter key is an error. A case with no grader does not load.

## What graders can check

Both answers were found by running probe cases with a control grader that had to fail.

**(a) Which tools were called — yes.** A `tool_used` grader counts calls to a named tool, and
`tool_order` checks that one call came before another. Probe: the prompt asked for a Glob call;
`tool_used: Glob` passed ("Glob called 1x") and the control `tool_used: Grep` failed ("Grep
called 0x"). `input_match` narrows the count to calls whose JSON input matches a regex.

**(b) A file the run wrote — yes, if the run is allowed to write.** `file_exists` checks that a
file was created, and a `regex` or `llm` grader with `target: { source: file, path: out.txt }`
reads its contents. Probe: the prompt asked for `out.txt` containing one word; both graders
passed and the control `file_exists: missing.txt` failed. The case must list `Write` in
`allowed_tools` **and** the command must pass `--allow-tools Write`; without the grant the tool
is removed from the run and every file grader fails. `file_exists` sees only files created
during the run, not files that were edited.

Limits worth knowing before writing a case:

- **No custom-code graders.** A grader cannot run a script. To check a command's result, have
  the prompt ask Claude to run it and write the outcome to a file, then grade the file — or use
  a check in `scripts/smoke.sh`.
- **Every run starts in an empty workspace** with a temporary home. Nothing from your own
  settings, `CLAUDE.md`, memory or other plugins loads. This plugin's hooks, skills and agents do.
- **The run cannot read `evals/`.** A case that needs files gets them from a `case.yaml` beside
  the prompt; see "How a case gets the fixture" below.
- **`Bash`, `Write`, `Edit`, `WebFetch` need `--allow-tools`** on the command line. A case's
  `allowed_tools` alone grants only the read-only tools. `scripts/evals.sh` grants `Bash`,
  `Write` and `Edit` (confined to the run's workspace): `grandfather` uses the first, the
  `rules` cases the other two.
- **Graders marked `tool_used: Skill` are not scored** when the no-plugin comparison runs
  (`--ablation with-without`); they show whether the plugin fired.
- `llm` graders call a judge model three times per run and can disagree with themselves.
  Prefer `regex`, `tool_used` and `file_exists` where they can express the check.

## How a case gets the fixture

`fixtures/sample-app/` is a nine-file order service with known answers, listed in
`fixtures/FACTS.md`. A case that needs it has two more files:

```text
grandfather/lookup/
  prompt.md
  case.yaml        names the scaffold script
  fixture.sh       copies fixtures/sample-app into the run's workspace and commits it
  graders/
```

The script runs before Claude starts, and only when the command passes `--scaffold`
(`scripts/evals.sh` does). `context.add_dirs` cannot do this job: it refuses any path outside
the case's own folder ("escapes the case directory"), so it cannot point at a shared fixture.

### The XL fixture is generated, not copied

`fixtures/ledger-gen/generate.py` writes `ledger` — a 224-file, 27-commit plain-Python service
— into the run's empty workspace. Decision 0001 asked for a fixture of 200+ files with a
history question before the map's default is judged; committing one would breach the 100 KB
budget for this directory (lint check 17), so the fixture costs 14 KB of generator instead.
It is deterministic (fixed dates, no clock): two runs are byte-identical outside `.git`, which
the `ledger-gen` smoke check proves. `--no-map` omits `PROJECT_MAP.md`; the map is left
untracked in both arms so the git history is the same with and without it. The five planted
facts, their decoys and the rules for editing the generator are in `fixtures/FACTS-XL.md`.

## Cases

Each case has exactly one scored grader, so a run is a plain pass or fail and "two of three
runs" means what it says. The exception is `rules/trivial`, which has two (the file was fixed;
no spec was proposed); read its two graders separately when its score is not 0 or 1.

| Case | Prompt | Passes when the answer… | Grader |
|------|--------|-------------------------|--------|
| `hello` | Which shipkit skill builds PROJECT_MAP.md? | contains `/shipkit:map` | regex |
| `grandfather/lookup` | `/shipkit:ask` Where is the retry limit set? | names `jobs/retry.py` and the number 5 (F1) | regex |
| `grandfather/explain` | `/shipkit:ask` How is tax applied to an order? | names `apply_tax` and `billing.py` (F2) | regex |
| `grandfather/drift` | `/shipkit:ask` Where are orders stored? | says a JSON file and says the map is wrong (F3) | llm |
| `grandfather/gap` | `/shipkit:ask` Which payment provider do we use? | says none could be found and presents none as in use (F4) | llm |
| `rules/nontrivial` | Add refunds to the billing module. | proposes requirements, a spec or questions before writing code | llm |
| `rules/trivial` | Fix the typo in README.md: 'recieve'. | fixes it, and proposes no spec | regex on the file, llm |
| `rules/decision` | Should we move orders from the JSON file to SQLite? Decide and record it. | names two or more options and a concrete reversal condition | llm |
| `intake/nongoal` | `/shipkit:intake` Add EUR and GBP pricing. | says the request conflicts with the non-goal on multi-currency support | regex |
| `intake/trivial` | `/shipkit:intake` Rename `apply_tax` to `add_tax`. | says the request is trivial and runs no intake | llm |
| `intake/limit` | `/shipkit:intake` Add refunds. | asks at least one and at most four questions, and builds nothing | llm |
| `reviewer/missing-req` | start `shipkit:reviewer` on spec `refunds`, base `base` | marks REQ-2 `NOT MET` and ends `VERDICT: FAIL` | regex |
| `reviewer/all-met` | the same, on a complete feature | ends `VERDICT: PASS` with no `NOT MET` row | regex |
| `escape/missing-req` | `/shipkit:escape` Refunds above the charge were accepted in production… | names the cause `requirement missing` and proposes a new `REQ-3 … shall …` | regex |
| `digest/attention` | `/shipkit:ask --all digest` | names `ledger` and cites its digest line (`Escapes (30 days)` or `requirement missing`) | regex |
| `grandfather-xl/lookup` | `/shipkit:ask` Where is the job retry cap set? | names `jobs/policy.py` and the number 7, past two decoy `MAX_RETRIES` (XL1) | regex |
| `grandfather-xl/explain` | `/shipkit:ask` How is VAT applied at checkout? | names `apply_vat`, `billing/tax.py` and `checkout.py` (XL2) | regex |
| `grandfather-xl/drift` | `/shipkit:ask` Where are inventory counts cached? | says an in-process dict and says the map is wrong (XL3) | llm |
| `grandfather-xl/gap` | `/shipkit:ask` Which email provider sends our notifications? | says none could be found and presents none as in use (XL4) | llm |
| `grandfather-xl/history` | `/shipkit:ask` Why did we move order storage off the JSON file, and when? | gives the concurrent-writer corruption and identifies the commit (XL5) | llm |

The `intake` cases need a product file with a non-goal. Their scaffold script writes
`.shipkit/product.md` into the run's workspace after copying the fixture, so the shared fixture
stays as the other cases expect it. They were added in 3.4.0 and passed 3 of 3 each on
2026-10-05; there is no 3.1.0 baseline for them because the skill did not exist.

The `rules` cases run in the fixture with no `.claude/rules/`, so the three always-on rules
reach the session through the plugin's hook — the path a plugin-only user gets.

`gap` uses a judge and not a "no provider name appears" regex on purpose: an honest answer
lists the names it searched for and did not find.

The `reviewer` cases build their feature in the scaffold: the fixture as a commit tagged
`base`, then one commit adding a `refunds` spec (three requirements, one of them waived) and
its code. In `missing-req` the second requirement has no code and no test. `all-met` is the
control: a reviewer that fails everything would pass `missing-req` and be useless. Both were
added in 3.5.0 and passed 3 of 3 on 2026-10-06.

`escape/missing-req` runs on a shipped `refunds` spec that never said a refund may not exceed
the charge. Added in 3.5.0; 3 of 3 on 2026-10-06.

`digest/attention` builds three small products in the workspace — `ledger` with an escape
recorded today and uncommitted work, `notes` with a spec three tasks of four done, `brochure`
with nothing going on — plus a registry pointing at them and a `studio.md` ranking `ledger`
first, all under `shipkit-home/`. The prompt names that directory as `SHIPKIT_HOME`, so the
skill's run of `portfolio-digest.sh` writes the digest there and not under the run's home.
Passes when `eve`'s answer names `ledger` and quotes its digest line. Added in 3.7.0.

The `grandfather-xl` cases are the four elder questions again, on the generated 224-file
fixture with decoys, plus one the current source cannot answer: `history` is in `git log`
(commit 20 of 27) and in the map's *Evolution* section. They exist for decision 0001's re-test
(`.shipkit/specs/map-on-trial/`); the comparison and its numbers are in
`docs/design/eval-results-4.1.md`. Added in 4.1.0.

### Two things checked before the XL cases were written (2026-10-07)

- **The eval tool does not pass the caller's environment to a scaffold script.** Probe: a
  scaffold created an open spec named `probe-${SHIPKIT_EVAL_PROBE:-unset}`, whose slug the
  session briefing prints and the trace records; run with the variable set, the trace said
  `probe-unset`. So the no-map arm cannot be selected by `SHIPKIT_EVAL_NO_MAP=1` on the eval
  command. It runs from a scratch copy of the plugin whose XL scaffolds pass `--no-map`:

  ```sh
  cp -R plugins/shipkit "$TMPDIR/shipkit-nomap"
  sed -i '' 's/generate.py" \$flags/generate.py" --no-map/' "$TMPDIR/shipkit-nomap"/evals/grandfather-xl/*/fixture.sh
  EVALS_OUT="$TMPDIR/xl-nomap" claude plugin eval "$TMPDIR/shipkit-nomap" --case 'grandfather-xl-*' …
  ```

  The variable is still honoured when a scaffold is run by hand (the `xl-scaffold` smoke check
  does this). `--keep-temp` keeps a sandbox's `config/` and `out/trace.jsonl`, **not** its
  workspace — a probe has to surface through the trace.
- **What the trace holds**, from the kept sandboxes: tool calls are `tool_use` content blocks
  inside `assistant` rows (there are no tool rows of their own); subagent turns are in the same
  trace with `parent_tool_use_id` set, so main-session and subagent counts can be split; one
  API response may arrive as several `assistant` rows sharing `message.id` and the same `usage`
  block, so tokens are summed once per message id; the `result` row carries `total_cost_usd`.
  `scripts/trace-tools.sh <output-dir>` prints all of this per run, reading the run list from
  `aggregate-result.json`. Pass it a directory of sandboxes (`/private/tmp`) to count kept
  runs without a summary.

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
