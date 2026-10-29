# Tasks: The window and a third project (Sprint 19)

One commit per task, test and code together. The steps for each task are in
`docs/plans/second-run-sprint-plan.md` under the same task number (S19-T0 to S19-T4).
**Measurement runs are in the sprint's budget line (§4 and S19-T-REL): E15 one headless probe
≈ $0.10, E16 one probe run ≈ $0.15 (a second only if the first never attempted the write),
E17 the third real run ≈ $5–8, the gate ≈ $0.50, the release run at 59 cases ≈ $17.80; any
other needs the owner's yes (rule 15). T3 fixes nothing it finds (rule 6 and E17); F3's
deletion is the owner's own yes after the notes. Every sandbox, scratch copy and worktree a
task creates is removed after reading (rule 13).**

- [x] **T0** Write the sprint spec (S19-T0) → REQ-1 to REQ-8, the spec itself
  - Files: .shipkit/specs/third-run/
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . third-run --as-open` → 0 gaps on the draft; `sh plugins/shipkit/scripts/decision-check.sh .` → no FIRED; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the spec is in the thread ("approved", 2026-10-11; E17's repository and request still owed, before T3); stamped at the branch-point commit, `Status: open`
- [x] **T1** A session puts `plugin-root` back — paid by the installed-root rule, PR #21 `fe02c68` (S19-T1) → REQ-1, REQ-2, REQ-3, REQ-4
  - Files: plugins/shipkit/scripts/session-start.sh, plugins/shipkit/scripts/session-end.sh, plugins/shipkit/hooks/hooks.json, scripts/smoke.sh, plugins/shipkit/evals/README.md
  - Test: Check first (plan §3, fourth claim): one headless `-p` session on `haiku` from a scratch copy whose `hooks.json` carries a `SessionEnd` hook that prints to a file → the file exists or not (≈ $0.10); scripts/smoke.sh check 62 "plugin-root-back" (the four script branches of REQ-3 from a scratch `HOME`; plus one headless session from the scratch root when the check-first says `SessionEnd` fires for `-p`) — written first, red; the README's window note says which sessions restore
  - After: T0
  - Done when: check 62 → PASS; `sh -n` clean on both scripts; lint 0/0
- [x] **T2** The refusal text, captured (S19-T2) → REQ-5
  - Files: plugins/shipkit/evals/README.md, docs/design/eval-results-4.12.md
  - Test: a probe case on a scratch copy of the plugin (never committed) whose prompt asks for `.pre-commit-config.yaml` at the workspace root, `--runs 1 --keep-temp` with `Write` allowed; the `Write` call and its `tool_result` read from the trace; the text quoted in the README's paragraph with the Claude Code version, or the paragraph says what the trace held instead; smoke check 57 (keeps the paragraph) → PASS; the sandbox and the copy removed
  - After: T1
  - Done when: the README quotes the text or says the trace held none; check 57 → PASS; lint 0/0
- [ ] **T3** The third real run (S19-T3) → REQ-6, REQ-7
  - Files: docs/design/field-notes-4.12.md, ROADMAP.md
  - Test: none beyond lint — prose, written while running from the commands and their output; the run itself: a worktree of the owner's repository at its default branch on `shipkit/real-run-3` under this session's scratchpad, `claude --plugin-dir "<this checkout>/plugins/shipkit" --model sonnet` headless at this sprint's branch, the 4.9 steps in order (the hook, setup, product, intake on the owner's request, spec, one task through `brief.sh` from a clean tree and `brief-verify.sh`, the gate), `git status --short` before the first step, the Done-when of every step run by the runner; **nothing found is fixed**; F3 after the notes on the owner's yes, the branch's log read first
  - After: T2
  - Done when: the notes hold every step with its six parts and one line per E1 to E7; the ROADMAP's open list has one item per finding citing a section; the branch's fate is recorded; lint 0/0
- [ ] **T4** The roadmap for the plan after (S19-T4) → REQ-8
  - Files: ROADMAP.md
  - Test: none beyond lint (check 16 holds the status line) — prose, read: Sprints 17 to 19 in a shipped table as the portfolio plan's; "Still open after Sprint 19" from the third run's findings, Sprint 18's readings that named something, and the three releases' "What using it for real showed"; every item cites a file and section
  - After: T3
  - Done when: lint 0/0; every open item names a file and section
- [ ] **T-REL** Release 4.12.0 (S19-T-REL)
  - Files: plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, CHANGELOG.md, README.md, ROADMAP.md, docs/design/eval-history.md, .shipkit/releases/, .shipkit/specs/third-run/spec.md
  - Test: the sprint exit checklist (lint, smoke, evals at 59 cases, spec-check, the two byte lines); the gate headless; the CHANGELOG says which sessions no longer need rule 17's write-back
  - After: T4
  - Done when: the gate says READY; the report is committed with `Status: shipped`; the release run is in `eval-history.md`; the pull request is merged after a green check; tag `v4.12.0` pushed
