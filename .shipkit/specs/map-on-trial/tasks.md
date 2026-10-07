# Tasks: The map on trial (Sprint 8)

One commit per task, test and code together. The steps for each task are in
`docs/plans/evidence-sprint-plan.md` under the same task number. **T3 ends with a stop:** the
owner sees the two tables and the record's status line before T4 starts; the clause picks T4's
branch and the owner says go.

- [x] **T1** The XL fixture generator (S8-T1) → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7
  - Files: plugins/shipkit/evals/fixtures/ledger-gen/generate.py, plugins/shipkit/evals/fixtures/FACTS-XL.md, plugins/shipkit/evals/README.md, scripts/smoke.sh, scripts/lint.py, .shipkit/specs/map-on-trial/spec.md, .shipkit/specs/map-on-trial/design.md, .shipkit/specs/map-on-trial/intake.md, .shipkit/specs/map-on-trial/tasks.md, docs/plans/evidence-sprint-plan.md (the last five added with the owner's yes on 2026-10-07: REQ-6 raised from 12,288 to 16,384 bytes)
  - Test: scripts/smoke.sh check "ledger-gen" (two generations are identical outside .git; ≥ 200 files; ≥ 25 commits; Redis only in the map; no email provider named; --no-map leaves no map and the same commit count; ≤ 16,384 bytes; standard-library imports only) and scripts/lint.py check 17 (evals ≤ 102,400 bytes) — both written first; the smoke check is red because the generator does not exist, the lint check is shown red against a scratch oversized file
  - After: none
  - Done when: the ledger-gen smoke check → PASS (its import check parses the file with `ast`, so a syntax error fails it; `py_compile` is not used because it leaves a `__pycache__` under evals/); `bash scripts/lint.sh` → 0 error(s), 0 warning(s)
- [x] **T2** Five XL cases and a trace counter (S8-T2) → REQ-8, REQ-9, REQ-10, REQ-11
  - Files: plugins/shipkit/evals/grandfather-xl/, scripts/trace-tools.sh, scripts/evals.sh, scripts/smoke.sh, plugins/shipkit/evals/README.md
  - Test: scripts/smoke.sh checks "xl-scaffold" (each of the five fixture.sh scripts builds the fixture in a scratch directory; with SHIPKIT_EVAL_NO_MAP=1 no PROJECT_MAP.md) and "trace-tools" (on a kept trace, the printed tool-call count equals `grep -c '"type":"tool_use"'`; one line per run with five fields) — written first, red
  - After: T1
  - Done when: both smoke checks → PASS; `sh -n scripts/trace-tools.sh` → clean; `bash scripts/evals.sh --case 'grandfather-xl-*'` runs all five and prints a result for each, recorded in evals/README.md under "Baseline 4.0.0 (XL)"; both Check-first answers are in the README
- [x] **T3** The comparison, and what the record says now (S8-T3) → REQ-12, REQ-13, REQ-14
  - Files: docs/design/eval-results-4.1.md, .shipkit/decisions/0001-project-map-default.md
  - Test: reading — the three-arm table has no empty cell; every per-case cell has three tool-call counts from scripts/trace-tools.sh; the drift rule of REQ-14 is applied and shown; the record's status line names a side
  - After: T2
  - Done when: the two tables and the status line are shown to the owner; `git diff --stat main -- plugins/` shows nothing from this task; the owner has said which branch of T4 to take
- [ ] **T4** Act on the outcome (S8-T4) → REQ-15, REQ-16, REQ-17
  - Files: plugins/shipkit/skills/setup/SKILL.md, plugins/shipkit/agents/grandfather.md, plugins/shipkit/agents/eve.md, plugins/shipkit/skills/map/SKILL.md, README.md, GUIDE.md, ROADMAP.md, .shipkit/decisions/0001-project-map-default.md, scripts/smoke.sh, scripts/lint.py, .shipkit/specs/map-on-trial/spec.md
  - Test: optional side — scripts/lint.py check 18 (no required/first-step map phrasing in setup, README, GUIDE), written first and red on the 4.0.0 tree; default side — `grep -rn "re-test\|not yet acted" README.md ROADMAP.md` → nothing. The branch not taken has its requirements marked `[untested: the condition did not hold]`
  - After: T3
  - Done when: `bash scripts/lint.sh` → 0 error(s), 0 warning(s); `sh scripts/smoke.sh` → all pass; `bash scripts/evals.sh --case 'grandfather*'` → every case that passed in T2 still passes (drift excepted when run without a map); `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md | wc -c` → 2996 (unchanged)

## After the gate

- **Ship:** run `/shipkit:ship map-on-trial` on this branch and fix what it finds; the report
  starts with `READY` and is committed.
- **Release 4.1.0:** version in five places, changelog (the field notes say what the XL
  fixture showed that the nine-file one could not), counts, the sprint exit checklist, pull
  request, merge after a green check, tag `v4.1.0`.
