# Spec: One eval per rule (Sprint 9, release 4.2.0)

> Spec accepted at commit `d8c7fb8` on sprint-9/rule-evals.
> Status: shipped
> Paths: plugins/shipkit/evals/, plugins/shipkit/hooks/, plugins/shipkit/scripts/inject-rule.sh, scripts/, docs/design/eval-results-4.2.md, docs/design/trim-audit-4.0.md, .shipkit/decisions/, plugins/shipkit/rules/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Give every rule file a case that shows whether it changes what Claude does, measure the 4.0
trims against the pre-trim text so the trim audit's criterion (c) gets its number, and settle
`rules/nontrivial` — fix it within the byte budget or accept it by record.

Source: `docs/plans/evidence-sprint-plan.md`, Sprint 9, tasks S9-T1 to S9-T5, and the intake
beside this file (which corrects the plan's rule count from 15 to 18).

## User stories

- As the owner, I want a number beside every rule file — passes with it, without it, and with
  the text it had before the trim — so that the next trim or cut rests on a measurement.
- As the executor of a later sprint, I want a harness that installs one rule into an eval
  fixture the way `/shipkit:setup` does, so that a new rule gets its case in an afternoon.
- As a reader of the trim audit, I want its unmeasured column filled in, append-only, so that
  the approved verdicts stay as they were and the new evidence sits beside them.

## Requirements (EARS)

### The harness (S9-T1)

- **REQ-1.** When run as `evals/lib/with-rule.sh <rule>` in a workspace, the harness shall
  install that one rule file under the workspace's `.claude/rules/shipkit/` (stack rules under
  `.claude/rules/shipkit/<stack>/`) with the content shipkit's own installer writes for it, and
  nothing else from `rules/` or the overlay. *(Amended 2026-10-07 with the owner's yes: the
  sandbox loads no installed file, and installing the always-on rules as files would silence
  the hook that delivers them.)*
- **REQ-2.** When the harness installs a rule, the workspace's installation manifest
  (`.claude/rules/shipkit/.installed`) shall record that file and the plugin's version.
- **REQ-3.** While `SHIPKIT_EVAL_NO_RULE=1` is set, the harness shall install no rule file and
  write no marker, leaving the workspace as the fixture left it.
- **REQ-4.** While `SHIPKIT_EVAL_RULE_REF` names a git ref, the harness shall install the rule
  under test with that ref's text of the file, taken from this repository's history.
- **REQ-21.** While `CLAUDE_CODE_EVAL_CONFINED=1` is set and `.claude/rules/shipkit/.eval-rule`
  names an installed rule file, the session hook shall add that file's text to the session's
  context. *(Added 2026-10-07: the eval sandbox sets `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1` and
  loads no `.claude/` or `CLAUDE.md` from the workspace; the hook is the one delivery path.)*
- **REQ-22.** If `CLAUDE_CODE_EVAL_CONFINED` is not `1`, or no `.eval-rule` marker exists, then
  the session hook shall add nothing for the rule under test.
- **REQ-5.** When run as `evals/fixtures/stack-gen.sh <stack>` in an empty directory, for each
  of the nine stacks that ship a rule, the generator shall write a project with at least one
  file matching a `paths:` glob of each of that stack's rule files. *(Relaxed from "every
  glob" on 2026-10-07: a project holding every manifest a rule lists — `Pipfile` beside
  `pyproject.toml` beside `setup.py` — would confuse the very trap the case probes.)*
- **REQ-6.** Where a core rule's `paths:` globs match nothing in `sample-app` (`migrations`,
  `monorepo`, `ui-ux`), `stack-gen.sh` shall offer a shape whose files match them.
- **REQ-7.** When run with `--group <name>`, `scripts/evals.sh` shall run only the cases whose
  names begin with `<name>-` (the cases under `plugins/shipkit/evals/<name>/`).
- **REQ-8.** When run without `--group`, `scripts/evals.sh` shall run every case.
- **REQ-9.** The lint shall fail when the files under `plugins/shipkit/evals/` total more than
  131,072 bytes. *(Raised from 102,400 with the owner's yes on 2026-10-07; intake question 2.)*

### The cases (S9-T2, S9-T3)

- **REQ-10.** `plugins/shipkit/evals/scoped/` shall hold one case per path-scoped core rule —
  `dependencies`, `migrations`, `monorepo`, `testing`, `ui-ux` — each of whose scaffold
  installs its rule through `with-rule.sh`.
- **REQ-11.** `plugins/shipkit/evals/stacks/` shall hold one case per stack rule file — the
  thirteen under `plugins/shipkit/stacks/*/.claude/rules/` — each of whose scaffold installs
  its rule through `with-rule.sh`.
- **REQ-12.** Each rule case's `description:` shall name the rule file it probes and the line
  it takes as the trap.
- **REQ-13.** Where the rule under test has a `paths:` line, the case's prompt shall ask for an
  edit to a file that matches one of its globs. [untested: prose, verified by reading; the
  with-rule arm of T4 is the behavioural check]

### The measurement (S9-T4)

- **REQ-14.** `docs/design/eval-results-4.2.md` shall hold, for each of the eighteen rule
  files, the runs passed and the tool calls of each run in each of three arms — with the rule,
  without it, with the `v3.7.0` text — counted by `scripts/trace-tools.sh`. [untested:
  documentation, verified by reading; no cell empty]
- **REQ-15.** Where a rule file is byte-identical at `v3.7.0` and at the measured commit, the
  results shall report its pre-trim arm as the same text as the with arm and shall not run it.
  [untested: documentation, verified by reading]
- **REQ-16.** `docs/design/trim-audit-4.0.md` shall carry an appended section "Criterion (c),
  measured in 4.2.0" with one line per trimmed rule file (fourteen) giving its with and
  pre-trim numbers, and the sections above it unchanged. [untested: documentation; `git diff`
  of the file shows additions only]

### `rules/nontrivial` (S9-T5)

- **REQ-17.** `.shipkit/decisions/0002-spec-first-eval.md` shall exist with a Context written
  from the traces of three failing runs, the attempts made and their numbers as Alternatives,
  and a concrete reversal clause. [untested: documentation, verified by reading]
- **REQ-18.** The three always-on rules shall total at most 3,000 bytes after any kept
  attempt. [untested: enforced by the existing lint budget check and exit-checklist line 5]
- **REQ-19.** Where an attempt is kept, `rules/nontrivial` shall pass at least two of three
  runs while `rules/trivial` and `rules/decision` hold their baseline. [untested: an eval
  result, not a repository test — `bash scripts/evals.sh --group rules` on 2026-10-07 gave
  3 of 3, 3 of 3, 3 of 3 with the kept sentence; recorded in `evals/README.md` and record 0002]
- **REQ-20.** Where no attempt is kept, the evals README's known-result note shall say that
  record 0002 accepts `rules/nontrivial`'s range and name the record. [untested: the
  condition did not hold — the first attempt was kept (T5, 2026-10-07); the README's note
  was updated all the same]

## Release steps (not requirements)

- T4 ends with a stop: the owner sees the eighteen-row table before T5 starts; no file under
  `plugins/shipkit/rules/` or `stacks/` changes in T4.
- The gate (`/shipkit:ship rule-evals`) answers `READY`; the report is committed.
- Release as 4.2.0; the sprint exit checklist holds; the pull request is merged after a green
  check; tag.

## Out of scope

- Rule edits other than T5's bounded attempts; the four files cut in 4.0; overlay skills;
  the real run; the deletions B11 to B13; context cost as a decision input.
