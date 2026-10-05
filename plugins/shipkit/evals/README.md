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
- **The run cannot read `evals/`.** A case that needs files names them in a `case.yaml` beside
  the prompt (`context.add_dirs`, read-only) or builds them with a `context.scaffold_script`
  (runs only with `--scaffold`).
- **`Bash`, `Write`, `Edit`, `WebFetch` need `--allow-tools`** on the command line. A case's
  `allowed_tools` alone grants only the read-only tools.
- **Graders marked `tool_used: Skill` are not scored** when the no-plugin comparison runs
  (`--ablation with-without`); they show whether the plugin fired.
- `llm` graders call a judge model three times per run and can disagree with themselves.
  Prefer `regex`, `tool_used` and `file_exists` where they can express the check.

## Cases

| Case | Checks |
|------|--------|
| `hello` | The harness itself: the plugin loads and a grader can read the reply. |
