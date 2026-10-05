# Tasks: Reviewer and ship gate (Sprint 4, release 3.5.0)

One commit per task, test and code together. The steps for each task are in
`docs/plans/quality-gate-sprint-plan.md` under the same task number.

- [x] **T1** The `reviewer` agent (S4-T1)
      → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-8
  - Files: plugins/shipkit/agents/reviewer.md, plugins/shipkit/evals/reviewer/, plugins/shipkit/evals/README.md, .claude-plugin/marketplace.json, scripts/smoke.sh
  - Test: eval case reviewer/missing-req (REQ-2 has no code → NOT MET and VERDICT: FAIL)
  - After: none
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); `bash scripts/evals.sh --case 'reviewer-*'` → passes
- [ ] **T2** `/shipkit:ship` (S4-T2) → REQ-9, REQ-10, REQ-11, REQ-12, REQ-13, REQ-14, REQ-15
  - Files: plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/skills/ship/reference.md, plugins/shipkit/scripts/spec-check.sh, scripts/smoke.sh, .claude-plugin/marketplace.json
  - Test: scripts/smoke.sh checks "spec-check --as-shipped" and "ship-gate" (READY; NOT READY naming step 3; no other file changed)
  - After: T1
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); the two smoke checks → PASS
- [ ] **T3** `/shipkit:escape` (S4-T3) → REQ-16, REQ-17, REQ-18
  - Files: plugins/shipkit/skills/escape/SKILL.md, plugins/shipkit/evals/escape/, plugins/shipkit/evals/README.md, .claude-plugin/marketplace.json
  - Test: eval case escape/missing-req (names the cause `requirement missing`, proposes a new REQ)
  - After: T2
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); `bash scripts/evals.sh --case 'escape-*'` → passes
- [ ] **T4** Link the Rails overlay to the gate (S4-T4) → REQ-19
  - Files: plugins/shipkit/stacks/rails/.claude/skills/deploy-check/SKILL.md, plugins/shipkit/stacks/rails/.claude/skills/release/SKILL.md, scripts/lint.py
  - Test: scripts/lint.py check "13. Rails overlay points at the ship gate" (an error when either skill lacks the line; written first)
  - After: none
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); `grep -c 'If this feature has a spec, run `/shipkit:ship <slug>` first.'` → 1 in each of the two skills
- [ ] **T5** Use it for real, once: ship this sprint through its own gate (S4-T5) → REQ-20
  - Files: .shipkit/releases/
  - Test: the first line of `.shipkit/releases/<date>-review-and-ship.md`
  - After: T3, T4
  - Done when: `.shipkit/releases/<date>-review-and-ship.md` exists, its first line is `READY`, and it is committed
- [ ] **T-REL** Release 3.5.0 → REQ-21
  - Files: CHANGELOG.md, README.md, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, .shipkit/specs/review-and-ship/spec.md
  - Test: the sprint exit checklist
  - After: T5
  - Done when: the five checklist lines hold; the pull request is merged; tag `v3.5.0` exists
