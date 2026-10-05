# Tasks: Product, intake, brief (Sprint 3, release 3.4.0)

One commit per task, test and code together. The steps for each task are in
`docs/plans/quality-gate-sprint-plan.md` under the same task number.

- [x] **T1** The product file and `/shipkit:product` (S3-T1)
      → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6
  - Files: plugins/shipkit/skills/product/SKILL.md, plugins/shipkit/skills/product/reference.md, scripts/smoke.sh, .claude-plugin/marketplace.json
  - Test: scripts/smoke.sh check "product-file" (the skill, given its answers, writes seven headings and at most three goals)
  - After: none
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); the product-file check → PASS
- [ ] **T2** Studio priorities and the registry (S3-T2) → REQ-7, REQ-8, REQ-9, REQ-10
  - Files: plugins/shipkit/skills/product/SKILL.md, plugins/shipkit/skills/map/SKILL.md, plugins/shipkit/agents/eve.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check "registry-columns" (template has both columns; eve names studio.md)
  - After: T1
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); the registry-columns check → PASS
- [ ] **T3** `/shipkit:intake` (S3-T3) → REQ-11, REQ-12, REQ-13, REQ-14, REQ-15, REQ-16, REQ-17
  - Files: plugins/shipkit/skills/intake/SKILL.md, plugins/shipkit/skills/spec/SKILL.md, plugins/shipkit/evals/intake/, plugins/shipkit/evals/README.md, .claude-plugin/marketplace.json
  - Test: eval cases intake/nongoal, intake/trivial, intake/limit
  - After: T1
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); `bash scripts/evals.sh --case 'intake-*'` → three cases pass
- [ ] **T4** `brief.sh`: build a brief from a task (S3-T4)
      → REQ-18, REQ-19, REQ-20, REQ-21, REQ-22, REQ-23
  - Files: plugins/shipkit/scripts/brief.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh section "brief" (valid task, unknown task, old-format task; written first)
  - After: T2
  - Done when: the brief smoke checks → all PASS; `sh -n plugins/shipkit/scripts/brief.sh` → clean
- [ ] **T5** `brief-verify.sh`: check what came back (S3-T5) → REQ-24, REQ-25, REQ-26
  - Files: plugins/shipkit/scripts/brief-verify.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh section "brief-verify" (allowed only, one extra, one untracked; written first)
  - After: T4
  - Done when: the brief-verify smoke checks → all PASS
- [ ] **T6** Tell Claude when to use the brief (S3-T6) → REQ-27, REQ-28
  - Files: plugins/shipkit/rules/spec-driven.md, plugins/shipkit/skills/spec/SKILL.md, GUIDE.md
  - Test: scripts/lint.py check 8a (the always-on byte budget)
  - After: T3, T5
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); the three rules total ≤ 3,000 bytes
- [ ] **T7** Use it for real, once: the Sprint 4 spec and one handed-over task (S3-T7) → REQ-29
  - Files: .shipkit/specs/review-and-ship/
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . review-and-ship`
  - After: T6
  - Done when: the Sprint 4 spec exists and passes spec-check; one task was handed over with `brief.sh` and checked with `brief-verify.sh`; the observations are written down for the pull request
- [ ] **T-REL** Release 3.4.0 → REQ-30
  - Files: CHANGELOG.md, README.md, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, .shipkit/specs/product-intake-brief/spec.md
  - Test: the sprint exit checklist
  - After: T7
  - Done when: the five checklist lines hold; the pull request is merged; tag `v3.4.0` exists
