# Tasks: The harness pays its debts (Sprint 14)

One commit per task, test and code together. The steps for each task are in
`docs/plans/portfolio-sprint-plan.md` under the same task number (S14-T0 to S14-T6). **Measurement
runs are in the sprint's budget line (§4 and S14-T-REL): one gate dry run at T2, two probe runs at
T5; any other needs the owner's yes (rule 15).**

- [x] **T0** Write the sprint spec (S14-T0) → REQ-1 to REQ-10 (the spec itself)
  - Files: .shipkit/specs/harness-debts/, docs/plans/portfolio-sprint-plan.md
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . harness-debts` → 0 gaps once stamped open
  - After: none
  - Done when: `spec-check.sh . harness-debts` → 0 gaps; the owner's approval is in the thread; stamped at the branch-point commit, `Status: open`
- [x] **T1** `spec-check` checks a draft (S14-T1) → REQ-1, REQ-2, REQ-3
  - Files: plugins/shipkit/scripts/spec-check.sh, plugins/shipkit/skills/spec/SKILL.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 55 "spec-check-draft" (a draft with a task lacking `Files:` → `SKIPPED` without the flag, `MISSING-FIELD` with it; a draft with an unnamed requirement → `MISSING-TASK` with it; a shipped spec with the flag → same output as without; the skill's text has no status flip) — written first, red; Check first: the status claim in the plan's §3
  - After: T0
  - Done when: check 55 → PASS; `spec-check.sh .` on this repository → 0 gaps as before; lint 0/0
- [x] **T2** The gate cleans up after itself (S14-T2) → REQ-4, REQ-5
  - Files: plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/skills/ship/reference.md
  - Test: a headless `/shipkit:ship second-traps` dry run on this branch (≈ $0.50, in the budget): `/bin/ls "$TMPDIR"/shipkit-ship-*.out` before and after, both in the commit message; the report read, then deleted
  - After: T1
  - Done when: no `shipkit-ship-*.out` under `$TMPDIR` after the run; the report still quotes every step's exit code and pasted output; lint 0/0
- [ ] **T3** The smoke suite restores the plugin root (S14-T3) → REQ-6, REQ-7
  - Files: scripts/smoke.sh
  - Test: scripts/smoke.sh check 56 "plugin-root-restore" (the save and restore functions run in a subshell with `HOME` pointed at a scratch directory: a sentinel file is overwritten and restored; an absent file is absent again after an overwrite) — written first, red; the full-run proof is the Done-when `cmp`
  - After: T2
  - Done when: check 56 → PASS; `cp ~/.claude/shipkit/plugin-root "$TMPDIR/pr.save"; sh scripts/smoke.sh </dev/null; cmp ~/.claude/shipkit/plugin-root "$TMPDIR/pr.save"` → identical and `smoke: all checks passed`; a scratch copy of the script with a forced `exit 1` after check 3 also restores; lint 0/0
- [ ] **T4** `map_read` counts what the document says; `map_shell` beside it (S14-T4) → REQ-8, REQ-9
  - Files: scripts/trace-tools.sh, scripts/smoke.sh, docs/design/eval-results-4.6.md
  - Test: scripts/smoke.sh check 40 extended (the synthetic trace gains a `Grep` on the map's path and a `Bash` whose command is `cat PROJECT_MAP.md`; run 1 asserts `map_read 1 map_shell 1`, run 2 asserts `0 0`) — written first, red
  - After: T3
  - Done when: check 40 → PASS with the new columns; the header's column list names both; the appended line in the 4.6 document says its rates were counted by `Read` alone; lint 0/0
- [ ] **T5** The root-dotfile refusal, understood (S14-T5) → REQ-10
  - Files: plugins/shipkit/evals/README.md, ROADMAP.md
  - Test: scripts/smoke.sh check 57 "dotfile-paragraph" (the README's "How runs are isolated" section has a "What a case cannot ask for" paragraph naming the workspace root and a subdirectory form) — written first, red; the two probe runs on a scratch copy (≈ $0.30, in the budget) are the evidence, quoted in the commit message; Check first: the tool's documentation through the `claude-code-guide` agent
  - After: T4
  - Done when: check 57 → PASS; the paragraph quotes the refusal (or the documentation, with the fallback stated); the ROADMAP item is replaced by the pointer; nothing under `$TMPDIR` from this task remains; lint 0/0
- [ ] **T6** Rule 5 and the gate, closed (S14-T6) → release step
  - Files: ROADMAP.md
  - Test: none beyond lint — the item is struck with a pointer to the plan's rule 16 and amended rule 5
  - After: T5
  - Done when: lint 0/0; the ROADMAP's open list has six items left (E1, E2, E3, E10, E11, F1/F2), each still citing its evidence
- [ ] **T-REL** Release 4.7.0 (S14-T-REL)
  - Files: plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, CHANGELOG.md, README.md, ROADMAP.md, docs/design/eval-history.md, .shipkit/releases/, .shipkit/specs/harness-debts/spec.md
  - Test: the sprint exit checklist (lint, smoke, evals, spec-check, the two byte lines); the gate headless
  - After: T6
  - Done when: the gate says READY; the report is committed with `Status: shipped`; the release run is in `eval-history.md`; the pull request is merged after a green check; tag `v4.7.0` pushed
