# Tasks: The spec is a contract (Sprint 2, release 3.3.0)

One commit per task, test and code together. The steps for each task are in
`docs/plans/quality-gate-sprint-plan.md` under the same task number.

- [x] **T1** `spec-check.sh`, part one: requirements and tests (S2-T1)
      → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9, REQ-10
  - Files: plugins/shipkit/scripts/spec-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh section "spec-check" (six scratch-project checks, written first)
  - After: none
  - Done when: the spec-check smoke checks → all PASS; `sh -n plugins/shipkit/scripts/spec-check.sh` → clean
- [x] **T2** `spec-check.sh`, part two: the task format (S2-T2) → REQ-11, REQ-12, REQ-13, REQ-14
  - Files: plugins/shipkit/scripts/spec-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh section "spec-check-tasks" (one check per message, plus the old format)
  - After: T1
  - Done when: the spec-check-tasks smoke checks → all PASS
- [x] **T3** Drift measured on the right files (S2-T3) → REQ-15, REQ-16, REQ-17, REQ-18
  - Files: plugins/shipkit/scripts/session-start.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh section "spec-drift-paths" (four checks, written first)
  - After: T1, T2
  - Done when: the four new checks and the two existing `spec-staleness` checks → all PASS
- [x] **T4** Teach the spec skill and the rule the new formats (S2-T4)
      → REQ-19, REQ-20, REQ-21, REQ-22
  - Files: plugins/shipkit/skills/spec/SKILL.md, plugins/shipkit/skills/spec/reference.md, plugins/shipkit/rules/spec-driven.md, GUIDE.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check "spec-new-format" (a spec written for "refunds" passes spec-check)
  - After: T1, T2, T3
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); the three rules ≤ 3,000 bytes; the spec-new-format check → PASS
- [x] **T5** Bring this repository's own specs up to the new format (S2-T5) → REQ-23, REQ-24
  - Files: .shipkit/specs/install-lifecycle/spec.md, .shipkit/specs/unsetup-safety/spec.md, .shipkit/specs/measure-and-slim/spec.md, scripts/smoke.sh, scripts/lint.py, scripts/evals.sh
  - Test: `sh plugins/shipkit/scripts/spec-check.sh .`
  - After: T1, T2, T3, T4
  - Done when: `sh plugins/shipkit/scripts/spec-check.sh .` → exit 0, no `MISSING-` line
- [ ] **T6** Run the check in CI (S2-T6) → REQ-25
  - Files: .github/workflows/lint.yml
  - Test: the pull request's `lint` check
  - After: T5
  - Done when: the pull request's `lint` check runs the new step and passes
- [ ] **T-REL** Release 3.3.0 → REQ-26
  - Files: CHANGELOG.md, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, .shipkit/specs/spec-contract/spec.md
  - Test: the sprint exit checklist
  - After: T6
  - Done when: the five checklist lines hold; the pull request is merged; tag `v3.3.0` exists
