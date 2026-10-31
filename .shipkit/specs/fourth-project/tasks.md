# Tasks: The owner's project, and 5.1.0 (Sprint 25)

One commit per task, test and code together, except T1, which is one commit per debt. The steps for
each task are in `docs/plans/binding-sprint-plan.md` under the same task number (S25-T0 to S25-T-REL).
**Paid runs are in the plan's budget line (§4, Sprint 25, $25 to $33): the run $2 to $8, three gates
about $1.50, the full run $21 to $23. Anything else needs the owner's yes (rule 15). Nothing under
`plugins/` is edited while a smoke run, an eval run or a step of the run is in progress.**

- [x] **T0** Write the sprint spec (S25-T0) → REQ-1 to REQ-22, the spec itself
  - Files: .shipkit/specs/fourth-project/, docs/plans/binding-sprint-plan.md
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . fourth-project --as-open` → 0 gaps on the draft; `sh plugins/shipkit/scripts/decision-check.sh . --run` → no FIRED or ERROR; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the spec in the thread and their backlog item in the intake's Answers; stamped at the branch-point commit, `Status: open`; the plan's S25-T1 Files line, S25-T2 step (the worktree's place, the run's database) and §6 risk row amended in the same commit
- [x] **T1** Four debts, each with a check (S25-T1, G8) → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9, REQ-10
  - Files: plugins/shipkit/scripts/install-stack.sh, plugins/shipkit/skills/setup/SKILL.md, plugins/shipkit/skills/escape/SKILL.md, plugins/shipkit/skills/handoff/SKILL.md, plugins/shipkit/skills/intake/SKILL.md, plugins/shipkit/skills/product/SKILL.md, plugins/shipkit/skills/product/reference.md, plugins/shipkit/skills/ship/reference.md, plugins/shipkit/skills/spec/reference.md, scripts/smoke.sh
  - Test: smoke checks 79 to 82, each written first and shown red, each citing its `fourth-project/REQ-N`, run alone with no model. 79: `django.md` on `PYTHON_FRAMEWORK=Django` and `django` and not on `FastAPI`, the manifest agreeing, `pyproject.md` on both, setup's parenthesis gone. 80: no line under `plugins/shipkit/skills` matches `^\s*> .*20[0-9]{2}-[0-9]{2}-[0-9]{2}`, the six lines hold `<YYYY-MM-DD>`, the six files name `date +%F`. 81: every stack's filled section holds no `<!--` between its markers, both markers stay, the sources keep theirs, `ASYNC_MODE=no` has no `**Async DB:**` and `yes` has it, a re-run reads "already current" with the sha unchanged. 82: `spec/reference.md`'s `Fired-if` section names `git grep`. Then the existing installer checks alone
  - After: T0
  - Done when: checks 79 to 82 PASS and were red first; every existing check that installs a stack still PASSES; each commit's test plan written after its result was read (rule 24); lint 0/0
- [ ] **T2** The run (S25-T2, G10) → REQ-11, REQ-12, REQ-13, REQ-14, REQ-15
  - Files: docs/design/field-notes-5.1.md, ROADMAP.md
  - Test: the Check first, free and before any paid step: the worktree at `/private/tmp/shipkit-real-run-5`, `mise exec -- mix deps.get`, `mix compile`, `MIX_TEST_PARTITION=_shipkit5 mix test`, the count recorded; then the nine steps and `/shipkit:ask --walk`, each by `claude --plugin-dir <checkout>/plugins/shipkit --model sonnet --allowedTools Read Glob Grep Bash Write Edit Skill Agent --output-format json -p`, standard input from `/dev/null`, `MIX_TEST_PARTITION` set for each; every stamp the run writes read against the run's date
  - After: T1
  - Done when: every step has its six parts; G1, G2, G3, E1, E2 and E3 each read as held or not shown; the owner's product repository holds nothing from the run but the worktree and branch; those and the run's database removed on the owner's yes, the log read first; lint 0/0
- [ ] **T3** The roadmap for the plan after (S25-T3) → REQ-16
  - Files: ROADMAP.md
  - Test: `bash scripts/lint.sh` → 0/0; every new item read for a file and a section
  - After: T2
  - Done when: the plan's section has its three rows and 5.1.0; "Still open after Sprint 25" holds the run's findings, what §5 left, and the evals line at 198,837 of 528,427 bytes; lint 0/0
- [ ] **T-REL** Release 5.1.0 (S25-T-REL, G11, G12) → REQ-17, REQ-18, REQ-19, REQ-20, REQ-21, REQ-22
  - Files: .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, CHANGELOG.md, README.md, ROADMAP.md, docs/design/eval-history.md, .shipkit/releases/
  - Test: the plan's exit checklist in full, one run at a time: `bash scripts/lint.sh`, `sh scripts/smoke.sh </dev/null`, `bash scripts/evals.sh -j 4`, `spec-check`, the three rules, the evals' bytes, the §0 table; then `/shipkit:ship` on `decisions-bind` against `6379fd7`, `readable-numbers` against `2e8bed0` and `fourth-project` against `6831e71`; the `placeholder` count from the session logs
  - After: T3
  - Done when: all three READY; each spec `shipped` on the owner's yes; the run in `eval-history.md`; the pull request with "What was awkward", a green check and a merge commit; `git ls-remote` shows `v5.1.0`, annotated; each of G12 done on its own yes or left, and said so
