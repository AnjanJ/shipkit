# Tasks: The run's debts (Sprint 17)

One commit per task, test and code together. The steps for each task are in
`docs/plans/second-run-sprint-plan.md` under the same task number (S17-T0 to S17-T5).
**Measurement runs are in the sprint's budget line (§4 and S17-T-REL): smoke check 29 alone
at T4 and the release gate (≈ $1), the release run (≈ $16.50); any other needs the owner's yes
(rule 15). F1 and F2 at T5 are each the owner's own yes, after the target is looked at.**

- [x] **T0** Write the sprint spec (S17-T0) → REQ-1 to REQ-11, the spec itself
  - Files: .shipkit/specs/run-debts/, docs/plans/second-run-sprint-plan.md
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . run-debts --as-open` → 0 gaps on the draft; `sh plugins/shipkit/scripts/decision-check.sh .` → no FIRED; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the spec is in the thread; stamped at the branch-point commit, `Status: open`; the plan carries its approval line
- [x] **T1** The installer sees the heading (S17-T1) → REQ-1, REQ-2
  - Files: plugins/shipkit/scripts/install-stack.sh, plugins/shipkit/skills/setup/SKILL.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 60 "heading-seen" (a `CLAUDE.md` with the heading → the stderr line names it and `/shipkit:update-rules`, both sections present, the marker and `.section-<stack>.sha` intact; without → one heading, no line; the setup skill's text carries the relay) — written first, red; Check first: the installer reads `CLAUDE.md` before it appends (plan §3, first claim)
  - After: T0
  - Done when: check 60 → PASS; lint 0/0
- [x] **T2** Same-named rules named; a tracked backup left alone (S17-T2) → REQ-3, REQ-4
  - Files: plugins/shipkit/scripts/install-rules.sh, plugins/shipkit/skills/setup/SKILL.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 61 "same-named" (a project with `.claude/rules/testing.md` beside `shipkit/` → the one line names it and the file is unchanged; without → no line; the setup skill's backup phase carries `git ls-files --error-unmatch` and the left-in-place sentence) — written first, red; Check first: `git ls-files --error-unmatch` outside a repository (plan §3, second claim)
  - After: T1
  - Done when: check 61 → PASS; lint 0/0
- [x] **T3** The brief warns on a dirty tree; setup's files always allowed (S17-T3) → REQ-5, REQ-6, REQ-7
  - Files: plugins/shipkit/scripts/brief.sh, plugins/shipkit/scripts/brief-verify.sh, plugins/shipkit/agents/reviewer.md, scripts/smoke.sh
  - Test: scripts/smoke.sh checks 25, 26 and 53 extended (a dirty tree → the stderr line with the count and a byte-identical brief on stdout, a clean tree → none; a change under `.claude/rules/shipkit/` and `.shipkit-baseline/` → not OUTSIDE; `CLAUDE.md` and `.gitignore` → OUTSIDE still; the reviewer's step 4 names the four) — written first, red
  - After: T2
  - Done when: checks 25, 26, 53 → PASS; lint 0/0
- [x] **T4** The reviewer cites file lines; the gate pastes its reply (S17-T4) → REQ-8, REQ-9
  - Files: plugins/shipkit/agents/reviewer.md, plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/skills/ship/reference.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 27 extended (the reviewer's text carries the `grep -n` sentence) and check 29 extended (the ship skill's step 4 names `shipkit-ship-review.out`; the READY report's review block holds `## Review:`, a row per requirement of the fixture's spec, the `Requirements:` line and `VERDICT: PASS`) — written first, red; check 29 alone is the sprint's gate dry run (≈ $0.50); Check first: the Agent result reaches the skill as text it can `Write` (plan §3, third claim)
  - After: T3
  - Done when: checks 27 and 29 → PASS; lint 0/0
- [x] **T5** The wait sentence, closed by record; two cache directories (S17-T5) → REQ-10, REQ-11
  - Files: .shipkit/specs/run-debts/design.md, ROADMAP.md
  - Test: none beyond lint — prose, read; F1 and F2 each on the owner's yes, `/bin/ls` of the target and the interactive session's hook line first, the command and its output in the commit message
  - After: T4
  - Done when: the record exists with the three quotes and the reopen condition; the ROADMAP rows are written; lint 0/0
- [ ] **T-REL** Release 4.10.0 (S17-T-REL)
  - Files: plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, CHANGELOG.md, README.md, ROADMAP.md, docs/design/eval-history.md, .shipkit/releases/, .shipkit/specs/run-debts/spec.md
  - Test: the sprint exit checklist (lint, smoke, evals at 58 cases, spec-check, the two byte lines); the gate headless
  - After: T5
  - Done when: the gate says READY; the report is committed with `Status: shipped`; the release run is in `eval-history.md`; the pull request is merged after a green check; tag `v4.10.0` pushed
