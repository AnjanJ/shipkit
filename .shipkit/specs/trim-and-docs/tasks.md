# Tasks: Trim and tell the story (Sprint 7)

One commit per task, test and code together. The steps for each task are in
`docs/plans/quality-gate-sprint-plan.md` under the same task number. **T1 ends with a stop:**
the owner decides every `cut` row before T2 starts (A8).

- [x] **T1** The audit table (S7-T1) → REQ-1, REQ-2, REQ-3
  - Files: docs/design/trim-audit-4.0.md
  - Test: reading — one row per item (6 + 16 + 7 + 1 = 30 rows), four columns, (c) marked where not measured, the map row cites decision 0001
  - After: none
  - Done when: the table is complete and shown to the owner; every `cut` row has the owner's yes or no
- [x] **T2** Apply the approved trims (S7-T2) → REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9
  - Files: plugins/shipkit/rules/, plugins/shipkit/stacks/, plugins/shipkit/skills/, plugins/shipkit-workflows/skills/, plugins/shipkit/scripts/, scripts/lint.py, CHANGELOG.md, .claude-plugin/marketplace.json, scripts/smoke.sh, plugins/shipkit-workflows/.claude-plugin/plugin.json
  - Test: scripts/lint.py checks for the 40-line, 300-character and bare-mktemp limits (written first, red on today's tree: 2 rules over 40 lines, 8 descriptions over 300 characters, 7 scripts with bare mktemp)
  - After: T1
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); `bash scripts/evals.sh -j 4` → no case below its 3.7.0 result; `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md | wc -c` ≤ 3000
- [ ] **T3** Rewrite the README (S7-T3) → REQ-10, REQ-11, REQ-12, REQ-13, REQ-14
  - Files: README.md, scripts/lint.py
  - Test: scripts/lint.py checks that every skill named in README.md exists, README.md is ≤ 250 lines, and no "New in" line sits above the Install heading (written first, red on today's README: 348 lines, "New in 2.9" above Install)
  - After: T2
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s)
- [ ] **T4** One worked example in the guide (S7-T4) → REQ-15
  - Files: GUIDE.md
  - Test: reading — nine steps, each with its command and the file it produced; `grep -c '^\*\*Step' GUIDE.md` or the equivalent counts nine in Playbook 4
  - After: T3
  - Done when: each of the nine steps appears with its command and file
- [ ] **T5** Update the roadmap (S7-T5) → REQ-16, REQ-17
  - Files: ROADMAP.md, scripts/lint.py
  - Test: scripts/lint.py checks that the ROADMAP status line names the marketplace version (written first, red: the status line names v2.9.0)
  - After: T3
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); the status line names the release

## After the gate

- **Ship:** run `/shipkit:ship trim-and-docs` on this branch and fix what it finds; the report
  starts with `READY` and is committed.
- **Release:** 4.0.0 if a `cut` row was approved, else 3.8.0 — version in five places,
  changelog (every cut with its replacement), counts, the sprint exit checklist, pull request,
  merge after a green check, tag.
