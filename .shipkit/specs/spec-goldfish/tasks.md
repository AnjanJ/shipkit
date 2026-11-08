# Tasks: Spec goldfish — a zero-context read of a spec before its tasks are written

One commit per task, test and code together. Each smoke check is written first and seen failing
before the code it checks, and cites its requirement as `spec-goldfish/REQ-N`. The eval cases
cite theirs in the header of `scripts/evals.sh`, where every case's citation lives (a Markdown
case file cannot carry one that `spec-check.sh` counts). Four tasks share `scripts/smoke.sh`, so they run in order. **The only paid
run is T5** (two eval cases at about 3 runs each, on sonnet), and it needs the owner's yes. The
version bump and `CHANGELOG.md` belong to the release, not to this spec.

- [x] **T1** Correct the stale "subagents cannot spawn subagents" claim → REQ-17
  - Files: scripts/lint.py, ROADMAP.md, plugins/shipkit/skills/ship/SKILL.md, scripts/smoke.sh
  - Test: smoke check 93 `stale-nesting`. `git grep -n -i -E 'cannot spawn subagents|an agent cannot start an agent'` finds nothing in the three files. `lint.py`'s forked-skill message names decision 0006. `lint.py` fails a scratch forked skill whose body says "start the `shipkit:reviewer` agent", and passes one that does not.
  - After: none
  - Done when: `bash scripts/smoke.sh` → check 93 passes and no check fails; `bash scripts/lint.sh` → 0 errors, 0 warnings
- [x] **T2** The goldfish agent and the agents ceiling → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-16
  - Files: plugins/shipkit/agents/goldfish.md, docs/design/context-cost.md, scripts/smoke.sh, .claude-plugin/marketplace.json, README.md
  - Test: smoke check 94 `goldfish-agent`. It checks the frontmatter (`model: sonnet`, the tools, `disallowedTools: Edit, Write, Agent`), and that the body names the files it reads and does not read, the ignore-everything-but-the-slug rule, the stop on a missing slug or spec, the `TESTABLE`/`UNCLEAR` rows, the terms and assumptions lists with "None.", the test-author rule, and the two verdict lines as the last line. Check `agents-four` is amended to four core agents and at most 1,075 bytes with `test-analyzer`, and `context-cost.md`'s agents row reads 1,075. `marketplace.json` says 4 agents (lint compares it with `agents/*.md`), and the README's agent table lists `goldfish`.
  - After: T1
  - Done when: `bash scripts/smoke.sh` → checks 94 and `agents-four` pass and no check fails; `scripts/context-cost.sh .` → `agents` ≤ 1,075 with 5 descriptions; `bash scripts/lint.sh` → 0/0
- [x] **T3** `/shipkit:spec` starts the goldfish before the Plan Mode gate → REQ-8, REQ-9, REQ-10, REQ-11, REQ-12, REQ-13, REQ-14, REQ-15
  - Files: plugins/shipkit/skills/spec/SKILL.md, plugins/shipkit/skills/spec/reference.md, scripts/smoke.sh
  - Test: smoke check 95 `spec-goldfish-step`. In `SKILL.md`, Q2 has a step after `design.md` and before the Plan Mode gate that starts `shipkit:goldfish` with the slug only, writes the reply to `shipkit-spec-goldfish.out` and pastes it whole. A reply with no verdict gets one more start. Each finding gets one of `fixed`, `contested` with a `path:line`, or `escalated`, and outside knowledge is never `contested`. There are at most two reads for one gate. `GAPS` does not stop the gate. The "no goldfish" skip line is there. `reference.md`'s `spec.md` template has a `## Goldfish` section showing both line forms.
  - After: T2
  - Done when: `bash scripts/smoke.sh` → check 95 passes and no check fails; `bash scripts/lint.sh` → 0/0
- [x] **T4** The two eval cases and their fixture → REQ-18, REQ-19
  - Files: plugins/shipkit/evals/goldfish/spec-fixture.sh, plugins/shipkit/evals/goldfish/gap/case.yaml, plugins/shipkit/evals/goldfish/gap/fixture.sh, plugins/shipkit/evals/goldfish/gap/prompt.md, plugins/shipkit/evals/goldfish/gap/graders/names-term-and-gaps.md, plugins/shipkit/evals/goldfish/clean/case.yaml, plugins/shipkit/evals/goldfish/clean/fixture.sh, plugins/shipkit/evals/goldfish/clean/prompt.md, plugins/shipkit/evals/goldfish/clean/graders/self-contained.md, scripts/smoke.sh, scripts/evals.sh
  - Test: smoke check 96 `goldfish-fixture`, run offline in a scratch directory. `spec-fixture.sh gap` writes a `refunds` `spec.md` and `design.md` (no `tasks.md`, no code) in which "grace window" appears and is defined nowhere in the scratch tree. `spec-fixture.sh clean` writes the same requirement with the number of days stated. Each grader's regex matches a sample reply of its kind and rejects one of the other kind. `scripts/evals.sh`'s header cites `spec-goldfish/REQ-18` and `spec-goldfish/REQ-19` for the two cases.
  - After: T3
  - Done when: `bash scripts/smoke.sh` → check 96 passes and no check fails; `bash scripts/lint.sh` → 0/0
- [x] **T5** The first paid run of both cases, recorded → REQ-18, REQ-19, REQ-20
  - Files: docs/design/eval-history.md
  - Test: `bash scripts/evals.sh --case goldfish-gap` and `bash scripts/evals.sh --case goldfish-clean`, on the owner's yes
  - After: T4
  - Done when: both commands exit 0; `eval-history.md` has a dated section with each case's pass count, cost and Claude Code version, and the commit it ran at; if either case fails 2 of its 3 runs, the record says so and the owner is told that the "A gap is what a test author would have to guess" decision's condition has fired
- [ ] **T6** Room, the noise grader, and the baseline → REQ-22
  - Files: plugins/shipkit/evals/goldfish/gap/graders/names-term-and-gaps.md, plugins/shipkit/evals/goldfish/spec-fixture.sh, docs/design/eval-history.md, scripts/smoke.sh, scripts/evals.sh
  - Test: smoke check 96 gains: `names-term-and-gaps` refuses a GAPS reply whose `## Unstated assumptions` names a zero or negative amount or which check runs first, and takes one that names only the grace window's unit; `scripts/evals.sh`'s header cites `spec-goldfish/REQ-22`. Room, on the owner's choice of 2026-11-08 (option 1): the noise check joins the existing grader, and `spec-fixture.sh` loses its comment line and its `git init` (the T5 traces show no git use); the README and the ceiling stay. Then the baseline, on the owner's yes: `bash scripts/evals.sh --case goldfish-gap --runs 5 --keep-temp` on today's agent text
  - After: T5
  - Done when: `bash scripts/smoke.sh` → check 96 passes and no check fails; `bash scripts/lint.sh` → 0/0 (evals at most 204,800 bytes); the baseline's pass count, per-run noise (read from the traces) and cost recorded in `eval-history.md`. If it is 5 of 5, stop and tell the owner the fix has nothing to prove
- [ ] **T7** The assumptions step follows the test-author rule → REQ-21
  - Files: plugins/shipkit/agents/goldfish.md, scripts/smoke.sh
  - Test: smoke check 94 gains: the test-author rule comes before `## Procedure`; step 3 says an assumption counts only if the test cannot be written without it; the reply shape has `the test must guess:`; the two "does not count" kinds (an input the requirement does not mention, behaviour beyond what it asks) are named
  - After: T6
  - Done when: `bash scripts/smoke.sh` → check 94 passes and no check fails; `bash scripts/lint.sh` → 0/0
- [ ] **T8** The run after the fix, recorded → REQ-21, REQ-22
  - Files: docs/design/eval-history.md
  - Test: on the owner's yes, `bash scripts/evals.sh --case goldfish-gap --runs 5 --keep-temp` and `bash scripts/evals.sh --case goldfish-clean --keep-temp`
  - After: T7
  - Done when: set before the run: `goldfish-gap` at least 4 of 5 with all three graders, `goldfish-clean` 3 of 3; both counts, the noise per run read from the traces, and the cost in `eval-history.md`. Below either, the record says so and the owner is told
