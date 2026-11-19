# Shipkit evals

Cases that measure whether shipkit changes what Claude does. They run with `claude plugin eval`
(Claude Code 2.1.269 or later) and make real model calls on your account.

```sh
bash scripts/evals.sh                 # every case: 3 runs, the 16 watch cases 5
bash scripts/evals.sh --case hello    # one case
bash scripts/evals.sh --group stacks  # one group: the cases named stacks-* (4.2.0)
```

`scripts/evals.sh` exits non-zero if any case fails. A case passes at 2 of 3 runs, a watch case
at 3 of 5 (`runs: 5` in its `case.yaml`, 4.12.0; `--threshold 0.6`; `--runs 3` puts every case
back to three). The model under test is pinned to `sonnet` so that a change of
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
file was created, and a `regex` grader with `target: { source: file, path: out.txt }` reads
its contents. (An `llm` grader with `target:` was accepted by the 3.2 probe; on Claude Code
2.1.291 the case refuses to load — `graders.0: Unrecognized key(s) in object: 'target'` — so
a judgement about a written file is a `regex` on the file or an `llm` grader on the reply.) Probe: the prompt asked for `out.txt` containing one word; both graders
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
- **A `regex` grader is a JavaScript `RegExp`.** A Python inline flag such as `(?is)` makes the
  grader throw ("Invalid regular expression") and every run fails with no model error. Use
  `[\s\S]*` for "across lines" and `[Ss]idekiq` for case (4.9.0, the three `eve` cases).

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

The section on `lib/with-rule.sh` moved to `docs/design/eval-cases.md` (2026-11-18).

### Path-scoped loading, measured (4.6.0)

Smoke check 54 (`scoped-loading`), 2026-10-08, Claude Code 2.1.291, `haiku`: with the rules
installed by `install-rules.sh` into a scratch project and a nonce appended to `dependencies.md`
and to a copied `rails/gemfile.md`, the nonce **did not** reach context when the prompt merely
named `pyproject.toml` or `Gemfile` with no tool use, and **did** when the model read the file
(`--allowedTools Read`, "Read the file pyproject.toml, then …"): `dependencies.md` for
`pyproject.toml`, `gemfile.md` for `Gemfile`, and neither for `README.md`. So `paths:` globs
fire on a file access, not on a mention — the eval cases, whose model edits the matching file,
would meet the rule either way, and the always-on delivery through the hook stands in for a
load the sandbox cannot do. The ROADMAP item "measured by nothing" now carries this number.

### What a case cannot ask for (4.7.0)

A file whose **name** is on Claude Code's protected list. Every `trap2/notebooks` run in both
arms wrote `.pre-commit-config.yaml` at the workspace root and was refused
(`docs/design/eval-results-4.6.md`), and 4.6.0 read that as "the sandbox refuses a root
dotfile". It does not: two probes on 2026-10-09 wrote `.editorconfig` at the workspace root
and `config/.editorconfig` in a subdirectory; both tool_results read `File created
successfully`. What is refused is the name: the permission-modes documentation lists
`.pre-commit-config.yaml` (with `.gitconfig`, `.zshrc`, `.npmrc`, `.mcp.json`) as protected
files whose writes are *denied* in the eval tool's non-interactive mode; `--allow-tools
Write` does not override it. The refusal itself, read from a probe's trace on
2026-10-11 (Claude Code 2.1.296): a `tool_result` with `is_error: true` that begins
"Permission to use Write has been denied because Claude Code is running in don't ask mode."
then the standard advice to try other tools reasonably or stop and explain (the full text:
`docs/design/eval-results-4.12.md`). The rule for a
case author: do not ask for a file on that list; a dotfile with any other name is fine at the
root or below, and a case that needs a protected file's effect asks for what does the same
job (`trap2/notebooks` asks for a Makefile target). Smoke check 57 keeps this paragraph.

## Cases

The case table moved to `docs/design/eval-cases.md` (2026-11-18).

## The cuts (4.8.0)

Seven rule files lost their two measured lines in 4.8.0 (`.shipkit/specs/measured-cuts/design.md`,
plan E1): `ui-ux`, `hotwire`, `liveview`, `mix-deps`, `notebooks`, `pyproject`, `react` — the
line each 4.2.0 case walks into and the line each `trap2/` case walks into, both passed without
the text on both days. Their fourteen cases are unchanged and still install the file: they are
the **watch**. The rule: a cut line returns to its file if its case drops below 2 of 3 in a
release run (below 3 of 5 from 4.12.0: the sixteen watch cases run five times). Four files whose whole body is their two measured lines (`migrations`, `monorepo`,
`testing`, `package-json`) and `rails` (at the threshold) keep theirs by record. `migrations` lost its two
lines in 4.11.0 on `haiku`'s measurement (`eval-results-4.11.md` §5); its two cases stay as
the watch. `trap2/notebooks`'
regex was widened in 4.11.0 (E12) to the other forms a Makefile can clear outputs by —
`execution_count`, a quoted `outputs`, a script named for it (`clean_notebook`,
`strip_outputs`) — after a 4.8 run did the job through a standard-library script and the
grader missed it; the 4.6 and 4.8 counts stay beside (`eval-results-4.11.md` §4). The numbers on
the trimmed text are in `docs/design/eval-results-4.8.md`; smoke check 58 keeps this list and
the files honest.

## Baselines and older readings

The baselines (3.1.0; 3.2.0 after the rule shrink; 4.0.0 XL; 4.1.0 scoped and stacks), the
4.2.0 spec-first reading and the 4.3.0 to 4.5.0 release runs are in
`docs/design/eval-history.md` — moved out of this directory for room (field plan C1). So are the
checks before the XL cases, the Gemfile line, `eve`'s portfolio and its arms, Trap 2 and
`intake/answered`, moved for room in Sprint 24 (`readable-numbers/REQ-14`).
