# Spec: The map on trial (Sprint 8, release 4.1.0)

> Spec accepted at commit `16df449` on sprint-8/map-on-trial.
> Status: shipped
> Paths: plugins/shipkit/evals/, scripts/, docs/design/eval-results-4.1.md, .shipkit/decisions/, plugins/shipkit/skills/setup/, plugins/shipkit/skills/map/, plugins/shipkit/agents/, README.md, GUIDE.md, ROADMAP.md, CHANGELOG.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Run the re-test decision 0001 asked for, on a fixture where a map could plausibly help, and let
the record's own clause decide whether the project map stays shipkit's default.

Source: `docs/plans/evidence-sprint-plan.md`, Sprint 8, tasks S8-T1 to S8-T4, and the intake
beside this file.

## User stories

- As the owner, I want the map's default settled by the numbers the record asked for, so that
  the standing cost of keeping a map fresh rests on evidence, not habit.
- As the executor of a later sprint, I want a fixture with two hundred files and a history, so
  that an elder eval measures the map where a map could matter.
- As a reader of eval results, I want tool calls and tokens counted by a script from the
  traces, so that the numbers are reproducible and no summary is mistaken for evidence.

## Requirements (EARS)

### The XL fixture (S8-T1)

- **REQ-1.** When run in an empty directory, `plugins/shipkit/evals/fixtures/ledger-gen/generate.py`
  shall write at least 200 files outside `.git` and a git history of at least 25 commits.
- **REQ-2.** Two runs of the generator shall produce byte-identical trees outside `.git`.
- **REQ-3.** The generator shall write a `PROJECT_MAP.md` that is the only file in the fixture
  naming Redis, and with `--no-map` shall write no `PROJECT_MAP.md` while producing the same
  number of commits.
- **REQ-4.** The fixture shall contain no text naming an email provider.
- **REQ-5.** `plugins/shipkit/evals/fixtures/FACTS-XL.md` shall list facts XL1 to XL5 with file
  and line, and for XL5 the commit. [untested: documentation, verified by reading]
- **REQ-6.** The generator shall be at most 16,384 bytes and shall import only standard-library
  modules. *(Accepted at 12,288; raised to 16,384 by the owner on 2026-10-07 after three
  compaction passes left 14,076 bytes — the 100 KB ceiling of REQ-7 is the enforced budget.)*
- **REQ-7.** The lint shall fail when the files under `plugins/shipkit/evals/` total more than
  102,400 bytes.

### The cases and the counter (S8-T2)

- **REQ-8.** `plugins/shipkit/evals/grandfather-xl/` shall hold five cases — `lookup`,
  `explain`, `drift`, `gap`, `history` — each of whose scaffold runs the generator.
- **REQ-9.** While `SHIPKIT_EVAL_NO_MAP=1` is set, each XL case's scaffold shall build the
  fixture without a `PROJECT_MAP.md`.
- **REQ-10.** `scripts/trace-tools.sh <dir>` shall print one line per run found under `<dir>`,
  with the case, the run, the tool-call count, the `Agent` call count and the input tokens.
- **REQ-11.** The tool-call count `scripts/trace-tools.sh` prints for a run shall equal the
  number of `tool_use` rows in that run's `trace.jsonl`.

### The comparison (S8-T3)

- **REQ-12.** `docs/design/eval-results-4.1.md` shall hold, for each of three arms (with the
  map, without the map, plugin off) and each of the five cases, the runs passed and the
  tool-call count of each of three runs, counted by `scripts/trace-tools.sh`. [untested:
  documentation, verified by reading; no cell empty]
- **REQ-13.** `.shipkit/decisions/0001-project-map-default.md` shall carry a section
  "Re-test (4.1.0)" stating the two numbers the clause asks for and a status line naming the
  side they fall on. [untested: documentation, verified by reading]
- **REQ-14.** If a `drift` pass exists only because the map contains the planted error, then
  the comparison shall not count it as one more correct answer. [untested: a counting rule,
  verified by reading the results document]

### The outcome (S8-T4)

- **REQ-15.** Where the re-test falls on the optional side, `/shipkit:setup`, `README.md` and
  `GUIDE.md` shall present the map as an option and not as a required or first step, and the
  lint shall fail when one of them does.
- **REQ-16.** Where the re-test falls on the optional side, `grandfather` and `eve` shall read
  `PROJECT_MAP.md` as an index when it exists and go to the source when it does not.
  [untested: agent prose, verified by reading; the elder evals of S8-T2 must still pass]
- **REQ-17.** Where the re-test falls on the default side, `README.md` and `ROADMAP.md` shall
  no longer describe the re-test as pending. [untested: the condition did not hold — the
  re-test fell on the optional side (`docs/design/eval-results-4.1.md`); the pending language
  was removed by T4 all the same]

## Release steps (not requirements)

- S8-T3 ends with a stop: the owner sees the two tables and the status line before S8-T4.
- The gate (`/shipkit:ship map-on-trial`) answers `READY`; the report is committed.
- Release as 4.1.0; the sprint exit checklist holds; the pull request is merged after a green
  check; tag.

## Out of scope

- The always-on rules, the archivist, `/shipkit:map`, the stale-map nag, `eve`'s registry.
- Context cost as a decision input (reported if the trace allows it; not read by the clause).
- Rule evals, `rules/nontrivial`, the real run, the deletions (Sprints 9 and 10).
