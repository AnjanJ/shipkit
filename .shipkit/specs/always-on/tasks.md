# Tasks: What every session pays (Sprint 20)

One commit per task, test and code together. The steps for each task are in
`docs/plans/thinning-sprint-plan.md` under the same task number (S20-T0 to S20-T5, S20-T-MERGE).
**Measurement runs are in the plan's budget line (§4, Sprint 20 ≈ $6): W1 the `rules` group
at `-j 3` once (9 runs) and one `--runs 1 --keep-temp` trace; W2 one probe × 3 runs × 2 arms;
four auto-invoke probes; one `Explore` probe; the two `--group` runs at merge. Anything else
needs the owner's yes (rule 15). W2 and every removal STOP for the owner's word (rule 6).**

- [x] **T0** Write the sprint spec (S20-T0) → REQ-1 to REQ-20, the spec itself
  - Files: .shipkit/specs/always-on/, docs/plans/thinning-sprint-plan.md
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . always-on --as-open` → 0 gaps on the draft; `sh plugins/shipkit/scripts/decision-check.sh .` → no FIRED; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the spec in the thread; the plan's approval line and amendments in the same commit; stamped at the branch-point commit, `Status: open`
- [x] **T1** The context cost as a script (S20-T1) → REQ-1, REQ-2, REQ-3
  - Files: scripts/context-cost.sh, docs/design/context-cost.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 63 "context-cost" (the script on `$PROJ` before and after a setup prints every row; the hook row equals `wc -c` of the hook's own output) — written first, red; cites `always-on/REQ-1`, `always-on/REQ-2`
  - After: T0
  - Done when: check 63 → PASS; the baseline row in the document matches the script on this repository; lint 0/0
- [x] **T2** `spec-driven` and `decisions` opt-in per project (S20-T2, W1) → REQ-4, REQ-5, REQ-6, REQ-7
  - Files: plugins/shipkit/scripts/inject-rule.sh, plugins/shipkit/scripts/session-start.sh, plugins/shipkit/hooks/hooks.json, scripts/smoke.sh, README.md, GUIDE.md, plugins/shipkit/evals/README.md
  - Test: Check first: one `rules/*` case `--runs 1 --keep-temp` after the change shows the injected header in its trace (≈ $0.15). scripts/smoke.sh checks 1 and 2 on a `$PROJ` with `.shipkit/` (cites `always-on/REQ-5`); new check 64 "opt-out" (a fresh session on a project without `.shipkit/`: the `spec-driven.md` codeword NOT seen, the `shipkit.md` one seen, the opt-in line present once; cites `always-on/REQ-4`, `always-on/REQ-7`); a check that runs the hook with `CLAUDE_CODE_EVAL_CONFINED=1` in a bare directory and sees all three headers (cites `always-on/REQ-6`) — written first, red
  - After: T1
  - Done when: checks 1, 2, 64 and the confined check → PASS; `bash scripts/evals.sh --group rules -j 3` → every case at its 4.12.0 count; the trace shows all three headers; lint 0/0
- [x] **T3** The Care lines measured (S20-T3, W2) → REQ-8, REQ-9, REQ-20
  - Files: plugins/shipkit/evals/rules/care/, plugins/shipkit/evals/README.md, scripts/evals.sh, docs/design/eval-results-5.0.md, scripts/lint.py, plugins/shipkit/rules/shipkit.md, plugins/shipkit/scripts/inject-rule.sh
  - Test: the case's own grader on its three plugin runs and three plugin-off runs (`--keep-temp`, verdicts read from the traces; cites `always-on/REQ-8` in `scripts/evals.sh`'s citation comment); lint check 17 at the new ceiling (`always-on/REQ-20` cited in `scripts/lint.py`); the W2 record's table has no empty cell
  - After: T2
  - Done when: the table has no empty cell; **the owner's go in the thread before any change to `shipkit.md`'s delivery**; evals bytes ≤ 204,800; lint 0/0
- [ ] **T4** Ten core skills (S20-T4, W3) → REQ-10, REQ-11, REQ-12, REQ-13, REQ-14, REQ-15
  - Files: plugins/shipkit/skills/ask/, plugins/shipkit/skills/setup/, plugins/shipkit-workflows/skills/commit/, plugins/shipkit/skills/walkthrough/, plugins/shipkit/skills/explain-system/, plugins/shipkit/skills/unsetup/, plugins/shipkit/skills/update-rules/, plugins/shipkit/skills/context-audit/, plugins/shipkit/skills/connect-memory/, plugins/shipkit/skills/commit/, plugins/shipkit/rules/shipkit.md, scripts/smoke.sh, scripts/lint.py, README.md, GUIDE.md, CHANGELOG.md, .claude-plugin/marketplace.json
  - Test: Check first: four headless auto-invoke probes, one per merged trigger (≈ $0.60). scripts/smoke.sh: every check that reads a moved SKILL.md by path follows it; a check that invokes `ask --walk`, `ask --system`, `setup remove` and `setup rules` by name and sees the merged body's fixed first line (cites `always-on/REQ-10`, `always-on/REQ-11`, `always-on/REQ-12`); a check that `ls plugins/shipkit/skills` holds no old name and `plugins/shipkit-workflows/skills/commit` exists (cites `always-on/REQ-13`); `scripts/context-cost.sh` ≤ 2,400 and 10 (cites `always-on/REQ-14`) — written first, red
  - After: T3
  - Done when: the four probes fire the merged skill; every smoke check that names a skill PASS; context-cost shows ≤ 2,400 bytes and 10 skills; the migration table lists seven old names; the three rules ≤ 3,000 bytes; lint 0/0 with its count updated
- [ ] **T5** Four agents (S20-T5, W4) → REQ-16, REQ-17, REQ-18, REQ-19
  - Files: plugins/shipkit/agents/grandfather.md, plugins/shipkit/agents/tracer.md, plugins/shipkit/agents/codebase-explorer.md, plugins/shipkit/agents/archivist.md, plugins/shipkit/skills/map/, plugins/shipkit/skills/spec/, plugins/shipkit/skills/ask/, scripts/smoke.sh, scripts/lint.py, README.md, GUIDE.md, CHANGELOG.md
  - Test: Check first: the `Explore` claim and the fork-with-argument claim (one probe each). scripts/smoke.sh: the walkthrough checks on `grandfather`'s trace mode (cites `always-on/REQ-16`); a check that `plugins/shipkit/agents/` holds no `archivist.md` or `tracer.md` and `skills/map/SKILL.md` has `context: fork` (cites `always-on/REQ-17`); the `codebase-explorer` check by the branch taken (cites `always-on/REQ-18`); `scripts/context-cost.sh` agents ≤ 1,000 (cites `always-on/REQ-19`) — written first, red
  - After: T4
  - Done when: `bash scripts/evals.sh --group grandfather -j 4` → every case at its 4.12.0 count; the smoke suite PASS; context-cost shows agents ≤ 1,000 bytes; lint 0/0
- [ ] **T-MERGE** Merge, untagged (S20-T-MERGE, rule 22)
  - Files: docs/design/context-cost.md
  - Test: the exit checklist: lint; the full smoke suite; `--group rules`, `--group grandfather`, `--group hello`; spec-check 0 gaps; the two byte lines; the §0 table re-measured into context-cost.md
  - After: T5
  - Done when: every line true; pull request with "What was awkward"; merged with a merge commit; no tag; the owner's cache untouched
