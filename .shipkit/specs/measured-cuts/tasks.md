# Tasks: What the numbers allow (Sprint 15)

One commit per task, test and code together. The steps for each task are in
`docs/plans/portfolio-sprint-plan.md` under the same task number (S15-T0 to S15-T4). **Measurement
runs are in the sprint's budget line (§4 and S15-T-REL): 42 runs on the trimmed text at T1, up to
three re-runs alone, the intake group once at T2; any other needs the owner's yes (rule 15). T1
stops after its table; each T4 row is the owner's own yes.**

- [x] **T0** Write the sprint spec (S15-T0) → REQ-1 to REQ-6 (the spec itself)
  - Files: .shipkit/specs/measured-cuts/
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . measured-cuts --as-open` → 0 gaps on the draft
  - After: none
  - Done when: 0 gaps; the owner's approval, with the answers to the intake's questions 1 and 2, is in the thread; stamped at the branch-point commit, `Status: open`
- [x] **T1** The cuts, re-measured (S15-T1) → REQ-1, REQ-2, REQ-3, REQ-4
  - Files: plugins/shipkit/rules/ui-ux.md, plugins/shipkit/stacks/hotwire/.claude/rules/hotwire.md, plugins/shipkit/stacks/liveview/.claude/rules/liveview.md, plugins/shipkit/stacks/elixir/.claude/rules/mix-deps.md, plugins/shipkit/stacks/ml/.claude/rules/notebooks.md, plugins/shipkit/stacks/python/.claude/rules/pyproject.md, plugins/shipkit/stacks/react/.claude/rules/react.md, scripts/evals.sh, scripts/smoke.sh, plugins/shipkit/evals/README.md, docs/design/eval-results-4.8.md, ROADMAP.md
  - Test: scripts/smoke.sh check 58 "cuts-recorded" (the README names the seven cut files and the watch rule; each cut file no longer contains its two measured lines, each kept file still does) — written first, red; `bash scripts/evals.sh` on the fourteen cases (`--case` per group), three runs each, `--keep-temp`, counts from trace-tools.sh; Check first: each trimmed file read whole, the diff shown to the owner before any run
  - After: T0
  - Done when: check 58 → PASS; the fourteen cases ≥ 2 of 3 on the trimmed text (or a returned line named, with the owner's yes); the results document's eleven-row table has no empty cell (bytes and lines before and after, both counts); lint 0/0 (check 14, the 40-line limit); always-on rules unchanged at 2,979 bytes; **stop: the owner sees the table before T2**
- [x] **T2** The intake's assumption names its file (S15-T2) → REQ-5
  - Files: plugins/shipkit/skills/intake/SKILL.md, plugins/shipkit/evals/README.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 58 extended (the skill's step 4 names the file and line) — written first, red; `bash scripts/evals.sh --group intake` once (≈ $1.70)
  - After: T1
  - Done when: check 58 → PASS; every intake case's count recorded in the README's intake paragraph (`answered`, `nongoal`, `trivial` ≥ 2 of 3; `limit` whichever way it falls, read from its trace if below 2 of 3); lint 0/0
- [x] **T3** The elder's step 0, closed by record (S15-T3) → REQ-6
  - Files: .shipkit/decisions/0001-project-map-default.md, ROADMAP.md
  - Test: none beyond lint — a record; `decision-check.sh . --run` → 0 errors
  - After: T2
  - Done when: the note is appended with its numbers; the ROADMAP item carries the pointer; lint 0/0
- [x] **T4** Two cache directories (S15-T4, E12 F1 and F2) → release step
  - Files: ROADMAP.md
  - Test: none beyond lint — each row's command and its output go in the commit message; the owner's interactive hook line reads `4.7.0` first
  - After: T3
  - Done when: the ROADMAP records each row as removed or kept, with the date; lint 0/0
- [x] **T-REL** Release 4.8.0 (S15-T-REL)
  - Files: plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, CHANGELOG.md, README.md, ROADMAP.md, docs/design/eval-history.md, .shipkit/releases/, .shipkit/specs/measured-cuts/spec.md
  - Test: the sprint exit checklist (lint, smoke, evals, spec-check, the two byte lines); the gate headless
  - After: T4
  - Done when: the gate says READY; the report is committed with `Status: shipped`; the release run is in `eval-history.md`; the pull request is merged after a green check; tag `v4.8.0` pushed
