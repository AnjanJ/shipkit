# Tasks: Live decisions and the studio digest (Sprint 6, release 3.7.0)

One commit per task, test and code together. The steps for each task are in
`docs/plans/quality-gate-sprint-plan.md` under the same task number.

- [x] **T1** The `Fired-if` line (S6-T1) → REQ-1, REQ-2, REQ-3
  - Files: plugins/shipkit/skills/spec/reference.md, plugins/shipkit/skills/decide/SKILL.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check "fired-if-template" (the template shows both forms); lint check 8a for the budget
  - After: none
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); the fired-if-template check → PASS
- [x] **T2** `decision-check.sh` (S6-T2) → REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9
  - Files: plugins/shipkit/scripts/decision-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh section "decision-check" (list only, with a marker the command would create; --run FIRED/HOLDS/MANUAL/ERROR; no hook names it; written first)
  - After: T1
  - Done when: the decision-check smoke checks → all PASS; `sh -n plugins/shipkit/scripts/decision-check.sh` → clean
- [ ] **T3** Teach the elders and the gate (S6-T3) → REQ-10, REQ-11
  - Files: plugins/shipkit/agents/grandfather.md, plugins/shipkit/agents/eve.md, plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/skills/ship/reference.md
  - Test: scripts/smoke.sh checks 29 (the ship gate) still pass; reading
  - After: T2
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s)
- [ ] **T4** `portfolio-digest.sh` (S6-T4) → REQ-12, REQ-13, REQ-14, REQ-15
  - Files: plugins/shipkit/scripts/portfolio-digest.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh section "portfolio-digest" (a scratch registry with two projects and one missing path → a file with three sections, exit 0; written first)
  - After: T2
  - Done when: the portfolio-digest smoke checks → all PASS; `sh -n plugins/shipkit/scripts/portfolio-digest.sh` → clean
- [ ] **T5** `/shipkit:ask --all digest`, the old-digest line, the guide (S6-T5) → REQ-16, REQ-17, REQ-18
  - Files: plugins/shipkit/skills/ask/SKILL.md, plugins/shipkit/agents/eve.md, plugins/shipkit/scripts/briefing.sh, GUIDE.md, plugins/shipkit/evals/digest/, plugins/shipkit/evals/README.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check "digest-old" (a digest eight days old → the line; none → no line); eval case digest/attention (eve names a product and cites a digest line)
  - After: T3, T4
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); the digest-old check → PASS; `bash scripts/evals.sh --case 'digest-*'` → passes

## After the gate

- **Ship:** run `/shipkit:ship decisions-and-digest` on this branch and fix what it finds; the
  report starts with `READY` and is committed.
- **Release 3.7.0:** version in five places, changelog, counts, the sprint exit checklist, pull
  request, merge after a green check, tag `v3.7.0`.
