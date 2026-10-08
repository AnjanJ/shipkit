# Tasks: The gate's blind spots (Sprint 12)

One commit per task, test and code together. The steps for each task are in
`docs/plans/field-sprint-plan.md` under the same task number (S12-T1 to S12-T4). **T3's dry
gate run is a measurement run: intake question 1 says whether it is in the budget.**

- [x] **T1** A `Fired-if` that cannot fire before the code exists (S12-T1) → REQ-1, REQ-2, REQ-3, REQ-4
  - Files: plugins/shipkit/scripts/decision-check.sh, plugins/shipkit/skills/spec/SKILL.md, plugins/shipkit/skills/spec/reference.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 52 "fired-if-early" (a design.md whose Fired-if names a missing file → `ERROR` with the exit code and stderr naming the file; the same line with a trailing `<!-- … -->` → parsed, same result; after `touch` of the file with 10 lines → `FIRED`; the summary line's words unchanged) — written first, red
  - After: none
  - Done when: check 52 → PASS; check 35 → PASS; `sh plugins/shipkit/scripts/decision-check.sh . --run` on this repository → 0 error(s); lint 0/0
- [x] **T2** `.shipkit/` is never "outside the spec" (S12-T2) → REQ-5, REQ-6, REQ-7
  - Files: plugins/shipkit/agents/reviewer.md, plugins/shipkit/scripts/brief-verify.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 53 "shipkit-allowed" (a task whose run wrote `.shipkit/product.md`, `.shipkit/releases/<date>-x.md`, `.shipkit/state.md`, `.shipkit/decisions/0001-x.md` and its own spec's `design.md` → exit 0, no OUTSIDE line; a write to `.shipkit/specs/other/spec.md` → one OUTSIDE line, exit 1) — written first, red
  - After: T1
  - Done when: check 53 → PASS; check 26 → PASS; `bash scripts/evals.sh --group reviewer` → both cases ≥ 2 of 3; lint 0/0
- [ ] **T3** The gate keeps its exit codes and its output (S12-T3) → REQ-8, REQ-9
  - Files: plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/skills/ship/reference.md
  - Test: a headless `/shipkit:ship real-run` on this branch (the shipped spec; a dry run) — every step that runs a command quotes `exit N` captured by the command line; no "not captured"; the report is read and then deleted
  - After: T1, T2
  - Done when: the dry run's report quotes every exit code; `git status --short` shows no report left; lint 0/0
- [ ] **T4** `brief-verify.sh` and ignored files, closed by record (S12-T4) → REQ-10
  - Files: plugins/shipkit/scripts/brief-verify.sh, ROADMAP.md
  - Test: none beyond lint — a header sentence and a roadmap edit; the record is in design.md (C6)
  - After: T2
  - Done when: the header says ignored files are invisible by design and names the Done-when output; the ROADMAP's ignored-files question is marked closed by record; lint 0/0

## After the gate

- **Ship:** run `/shipkit:ship gate-blind-spots` on this branch and fix what it finds — the
  branch-not-taken notes go in before the gate, not with the report (Sprint 11's lesson); the
  report starts with `READY` and is committed.
- **Release 4.5.0:** version in five places, changelog with "What using it for real showed",
  counts, the sprint exit checklist (smoke before the gate too, rule 14), pull request with
  "What was awkward", merge after a green check, tag `v4.5.0`.
