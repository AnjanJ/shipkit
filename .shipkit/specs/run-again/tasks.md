# Tasks: The run again, and 5.0.0 (Sprint 22)

One commit per task, test and code together, except T1, which is two: W13's, then W14's. The
steps for each task are in `docs/plans/thinning-sprint-plan.md` under the same task number
(S22-T0 to S22-T3, S22-T-REL). **Measurement runs are in the plan's budget line (§4, Sprint 22 ≈
$25–31): W14 six runs (≈ $1.50), the run again (≈ $2–8), the three gates (≈ $1.50), the release
run at 60 cases (≈ $21). Anything else needs the owner's yes (rule 15). T1 STOPs for the owner
to see W14's table before the sentence stays (rule 6). T2 fixes nothing it finds. Every deletion
is its own yes. Every sandbox, scratch copy and worktree a task creates is removed after
reading (rule 13), and traces are read through the eval output directory before that.**

- [x] **T0** Write the sprint spec (S22-T0) → REQ-1 to REQ-14, the spec itself
  - Files: .shipkit/specs/run-again/
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . run-again --as-open` → 0 gaps on the draft; `sh plugins/shipkit/scripts/decision-check.sh . --run` → no FIRED or ERROR; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the spec in the thread; stamped at the branch-point commit, `Status: open`
- [x] **T1** The four one-line debts, and the headless wait measured (S22-T1, W13, W14) → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7
  - Files: plugins/shipkit/scripts/brief.sh, plugins/shipkit/scripts/brief-verify.sh, plugins/shipkit/agents/reviewer.md, plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/skills/setup/SKILL.md, plugins/shipkit/skills/intake/SKILL.md, scripts/smoke.sh, docs/design/eval-results-5.0.md, .shipkit/specs/run-debts/design.md, CHANGELOG.md
  - Test: scripts/smoke.sh, each written first, red: check 71 "brief-cites" (a brief's Prove it with names `<slug>/REQ-N` with the real slug — cites `run-again/REQ-1`); check 72 "stack-skill-allowed" (a manifest-listed `.claude/skills/x/SKILL.md` is not reported, an unlisted `.claude/skills/y/SKILL.md` is `OUTSIDE` — cites `run-again/REQ-2`); check 73 "reviewer-skills" (the reviewer's step 4 names the manifest — cites `run-again/REQ-3`); check 74 "ship-capture" (the pre-step names `shipkit-ship-status.out`, step 7 reads it, the cleanup's pattern covers it — cites `run-again/REQ-4`); check 75 "setup-rule-count" (setup's word matches `ls plugins/shipkit/rules/*.md` — cites `run-again/REQ-5`). W14: `/shipkit:intake` headless on the `evals/intake/limit` fixture with a request whose answer is in the code, three runs, `--output-format json`, a 25-minute wall clock each; wall-clock from `date`, `duration_api_ms` from the result, `ScheduleWakeup` and `Agent` from each session's transcript; **STOP: the owner sees the table;** a baseline with no wakeup ends it, otherwise the sentence and three more runs; kept or not by the clause
  - After: T0
  - Done when: checks 71–75 PASS; the table has no empty cell; the owner's go in the thread before the sentence stays; the 4.10.0 record reopened or left as it is, and the design says which; the sandboxes removed; lint 0/0
- [x] **T2** The run again, on the thinned plugin (S22-T2, W5) → REQ-8, REQ-9, REQ-10, REQ-11
  - Files: docs/design/field-notes-5.0.md, docs/design/context-cost.md, ROADMAP.md
  - Test: none beyond lint — prose, written while running from the commands and their output; the run itself: a worktree of `~/code/linkshort` at `main` on `shipkit/real-run-4` under this session's scratchpad, `claude --plugin-dir "<this checkout>/plugins/shipkit" --model sonnet` headless at this sprint's branch, the nine steps of `field-notes-4.12.md` in order, the request link expiry (TODO.md item 1), `git status --short` before the first step; `scripts/context-cost.sh` on the worktree before setup, after setup and after the first spec; no file under `plugins/` edited while a step runs
  - After: T1
  - Done when: every step has its six parts and its 4.12 line; the three cost rows are in the notes; REQ-1 to REQ-5 each read as held or not shown; one ROADMAP item per finding; the branch's fate recorded, its log read first, the worktree and branch removed on the owner's yes; lint 0/0
- [ ] **T3** The roadmap for the plan after (S22-T3) → REQ-12
  - Files: ROADMAP.md
  - Test: lint check 16 holds the status line; the rest read: every "Still open after Sprint 22" item cites a file and a section
  - After: T2
  - Done when: the "Thinning plan" section has its three rows and 5.0.0; the list holds the run's findings, what "Still open after Sprint 19" still holds and Sprint 21's three open watches; lint 0/0
- [ ] **T-REL** Release 5.0.0 (S22-T-REL, W11, W12) → REQ-13, REQ-14
  - Files: plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, CHANGELOG.md, README.md, ROADMAP.md, docs/design/eval-history.md, docs/design/context-cost.md, .shipkit/releases/, .shipkit/specs/always-on/tasks.md, .shipkit/specs/always-on/spec.md, .shipkit/specs/overlays-and-eve/spec.md, .shipkit/specs/run-again/spec.md
  - Test: the sprint exit checklist (lint, smoke in full, `bash scripts/evals.sh -j 4` at 60 cases, spec-check, the two byte lines, the §0 table); always-on's T-MERGE and this T-REL ticked in the release prep commit; `/shipkit:ship` headless on `always-on`, `overlays-and-eve` and `run-again`; the CHANGELOG entry read for "What changed for you", the Migration table, §0 before and after and the check count
  - After: T3
  - Done when: all three gates say READY; the reports are committed with `Status: shipped`; the release run is in `eval-history.md`; the pull request is merged after a green check; tag `v5.0.0` pushed; F3, F4 and this sprint's branch each asked as its own yes
