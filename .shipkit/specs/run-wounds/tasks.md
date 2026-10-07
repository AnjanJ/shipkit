# Tasks: What the run hurt on (Sprint 11)

One commit per task, test and code together. The steps for each task are in
`docs/plans/field-sprint-plan.md` under the same task number (S11-T1 to S11-T4). **T2's Check
first moves README history only with the owner's yes (intake question 1).**

- [x] **T1** The briefing on a project with pre-3.3 specs (S11-T1) → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5
  - Files: plugins/shipkit/scripts/briefing.sh, plugins/shipkit/scripts/session-start.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 49 "pre33-specs" (three all-ticked specs with no Status → no progress line, no drift line, one "predate 3.3" line naming 3; one no-Status spec with an unticked task → reported as open; `Status: open` all ticked → "all ticked" as today) — written first, red
  - After: none
  - Done when: check 49 → PASS; check 30 → PASS; check 19h → PASS; `bash scripts/lint.sh` → 0/0
- [x] **T2** The intake searches before it asks (S11-T2) → REQ-6, REQ-7, REQ-8
  - Files: plugins/shipkit/skills/intake/SKILL.md, plugins/shipkit/evals/intake/answered/, scripts/evals.sh, plugins/shipkit/evals/README.md, docs/design/eval-history.md
  - Test: eval case `intake-answered` (sample-app + docs/decisions.md answering two of three natural refunds questions; grader: at most one question asked, the other two cited to the file) — run with the 4.3.0 text first (expect < 2 of 3), then with the new text (≥ 2 of 3)
  - After: none
  - Done when: `bash scripts/evals.sh --case intake-answered` → ≥ 2 of 3 with the new text; the old-text arm's numbers recorded in evals/README.md; `--group intake` → every case ≥ 2 of 3; evals bytes ≤ 131072; lint 0/0
- [ ] **T3** Headless runs leave their questions on disk (S11-T3) → REQ-9, REQ-10, REQ-11
  - Files: plugins/shipkit/skills/intake/SKILL.md, plugins/shipkit/skills/product/SKILL.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 50 "headless-questions" (sonnet, scratch project: a non-interactive `/shipkit:intake` with no answers → `.shipkit/specs/*/intake.md` exists and contains "unanswered"; a non-interactive `/shipkit:product` with no answers → product.md contains "## Open questions for the owner") — written first, red
  - After: T1, T2
  - Done when: check 50 → PASS; `bash scripts/evals.sh --group intake` → every case ≥ 2 of 3; lint 0/0
- [ ] **T4** Three lines: version, quiet goal, Blocked on (S11-T4) → REQ-12, REQ-13, REQ-14, REQ-15
  - Files: plugins/shipkit/scripts/session-start.sh, plugins/shipkit/scripts/briefing.sh, plugins/shipkit/skills/handoff/SKILL.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 51 "version-and-goal" (a scratch cache with 4.3.0 and 4.4.0 directories, the hook run from 4.3.0 → one line naming both and "restart"; run from 4.4.0 → no line; a product file whose first goal has three "none set" → "(no metric set)" and no "metric:" in the briefing) — written first, red; the handoff heading is read in check 30's state.md assertions
  - After: T3
  - Done when: check 51 → PASS; check 30 → PASS; `sh plugins/shipkit/scripts/session-start.sh` in this repository prints no version line; lint 0/0

## After the gate

- **Ship:** run `/shipkit:ship run-wounds` on this branch and fix what it finds; the report starts
  with `READY` and is committed.
- **Release 4.4.0:** version in five places, changelog with "What using it for real showed",
  counts, the sprint exit checklist (smoke before the gate too, rule 14), pull request with
  "What was awkward", merge after a green check, tag `v4.4.0`.
