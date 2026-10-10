# Tasks: Eve's portfolio and a second project (Sprint 16)

One commit per task, test and code together. The steps for each task are in
`docs/plans/portfolio-sprint-plan.md` under the same task number (S16-T0 to S16-T4). **Measurement
runs are in the sprint's budget line (§4 and S16-T-REL): 27 runs at T2, up to two re-runs
alone, the second real run at T3 (≈ $5–8); any other needs the owner's yes (rule 15). T2 stops
after its table; nothing T3 finds is fixed; each release-step row (F3, F4, F5) is the owner's
own yes.**

- [x] **T0** Write the sprint spec; make room (S16-T0) → REQ-1 (and REQ-2 to REQ-12, the spec itself)
  - Files: .shipkit/specs/portfolio-run/, scripts/lint.py, scripts/smoke.sh
  - Test: scripts/smoke.sh check 42 "lint-negative" (its expected message becomes "the limit is 196,608") — run alone, red before the lint change, green after; `sh plugins/shipkit/scripts/spec-check.sh . portfolio-run --as-open` → 0 gaps on the draft
  - After: none
  - Done when: 0 gaps; check 42 → PASS; evals bytes reported; lint 0/0; the owner's approval, with E11's repository path and the intake's answers, is in the thread; stamped at the branch-point commit, `Status: open`
- [x] **T1** The portfolio fixture (S16-T1) → REQ-2, REQ-3, REQ-4, REQ-5, REQ-6
  - Files: plugins/shipkit/evals/fixtures/portfolio-gen/generate.py, plugins/shipkit/evals/fixtures/FACTS-PORTFOLIO.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 59 "portfolio-gen" (two generations into two directories give identical HEAD tree hashes per project; `--maps 1` leaves `pulse` and `insight` without a map and the registry says `—` for both; the three stack signals grep as the facts file says; the vacuum reason is in `pulse`'s map and in no file or commit under `projects/`) — written first, red
  - After: T0
  - Done when: check 59 → PASS; evals bytes ≤ 196,608; lint 0/0
- [x] **T2** Three `eve` cases, three arms (S16-T2) → REQ-7, REQ-8, REQ-9
  - Files: plugins/shipkit/evals/eve/jobs/, plugins/shipkit/evals/eve/payments/, plugins/shipkit/evals/eve/why/, scripts/evals.sh, plugins/shipkit/evals/README.md, docs/design/eval-results-4.9.md, ROADMAP.md, .shipkit/decisions/0001-project-map-default.md
  - Test: `bash scripts/evals.sh --group eve` (3 cases × 3 arms × 3 runs, `--keep-temp`, counts from `scripts/trace-tools.sh`; the two scratch-copy arms made under the scratchpad and removed after their traces are read); Check first: `why` answered from `pulse`'s map in the three-map arm and "not recorded" in the no-map arm on the first run (§3) — if not, traces read and the fixture or question corrected (rule 10), never `agents/eve.md`
  - After: T1
  - Done when: the 3 × 3 table has no empty cell; the three readings are written after the traces are read (rule 10); every `eve` case ≥ 2 of 3 in the three-map arm; evals bytes ≤ 196,608; lint 0/0; **stop: the owner sees the table before T3**
- [ ] **T3** The second real run (S16-T3) → REQ-10, REQ-11
  - Files: docs/design/field-notes-4.9.md, ROADMAP.md
  - Test: none beyond lint — a measurement written up; `git status` in the notes before the first step; rule 17 for the run's length; `~/.claude/shipkit/plugin-root` written back after every `--plugin-dir` session
  - After: T2
  - Done when: the notes have every step with its six parts; the ROADMAP's open list has one item per finding, each citing a section; the branch's fate is recorded (F3 its own yes, `git log shipkit/real-run-2` read first); lint 0/0
- [ ] **T4** The roadmap for the plan after (S16-T4) → REQ-12
  - Files: ROADMAP.md
  - Test: none beyond lint — check 16 reads the status line
  - After: T3
  - Done when: Sprints 14–16 shipped in the table; every "Still open after Sprint 16" item names a file and section; lint 0/0
- [ ] **T-REL** Release 4.9.0 (S16-T-REL)
  - Files: plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, CHANGELOG.md, README.md, ROADMAP.md, docs/design/eval-history.md, .shipkit/releases/, .shipkit/specs/portfolio-run/spec.md
  - Test: the sprint exit checklist (lint, smoke, evals at 58 cases, spec-check, the two byte lines with the new ceiling); the gate headless
  - After: T4
  - Done when: the gate says READY; the report is committed with `Status: shipped`; the release run is in `eval-history.md`; the pull request is merged after a green check; tag `v4.9.0` pushed
