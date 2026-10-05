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

The `rules` cases run in the fixture with no `.claude/rules/`, so the three always-on rules
reach the session through the plugin's hook — the path a plugin-only user gets.

`gap` uses a judge and not a "no provider name appears" regex on purpose: an honest answer
lists the names it searched for and did not find.

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
