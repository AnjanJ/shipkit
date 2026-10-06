# Tasks: Briefing and handoff (Sprint 5, release 3.6.0)

One commit per task, test and code together. The steps for each task are in
`docs/plans/quality-gate-sprint-plan.md` under the same task number.

- [x] **T1** `briefing.sh` (S5-T1) → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9
  - Files: plugins/shipkit/scripts/briefing.sh, plugins/shipkit/scripts/session-start.sh, scripts/smoke.sh, plugins/shipkit/scripts/spec-check.sh
  - Test: scripts/smoke.sh section "briefing" (no .shipkit → empty; two open specs and a state.md → the right lines; 50 specs → ≤ 8 lines, ≤ 800 bytes, under a second; broken tasks.md → exit 0; written first)
  - After: none
  - Done when: the briefing smoke checks → all PASS; `sh -n plugins/shipkit/scripts/briefing.sh` → clean
- [ ] **T2** `/shipkit:handoff` (S5-T2) → REQ-10, REQ-11, REQ-12, REQ-13
  - Files: plugins/shipkit/skills/handoff/SKILL.md, plugins/shipkit/skills/setup/SKILL.md, scripts/smoke.sh, .claude-plugin/marketplace.json
  - Test: scripts/smoke.sh check "handoff-file" (the skill, run headless with the session's facts given, writes the five headings and a one-line Next step)
  - After: T1
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); the handoff-file check → PASS
- [ ] **T3** Close the loop (S5-T3) → REQ-14
  - Files: scripts/smoke.sh
  - Test: scripts/smoke.sh check "handoff-loop" (a fresh session asked "what should I do next?" repeats the Next step)
  - After: T2
  - Done when: the handoff-loop check → PASS
- [ ] **T4** The reminder after compaction (S5-T4) → REQ-15, REQ-16
  - Files: plugins/shipkit/scripts/session-start.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check "compact-reminder" (hook input with source compact → the line; source startup → no line)
  - After: T3
  - Done when: the compact-reminder check → PASS; the changelog entry (release) records why no pre-compaction reminder exists

## After the gate

- **Ship:** run `/shipkit:ship briefing-and-handoff` on this branch and fix what it finds;
  the report starts with `READY` and is committed.
- **Release 3.6.0:** version in five places, changelog, counts, the sprint exit checklist,
  pull request, merge, tag `v3.6.0`.
