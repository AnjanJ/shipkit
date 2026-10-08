# Tasks: Second traps and the elder's first step (Sprint 13)

One commit per task, test and code together. The steps for each task are in
`docs/plans/field-sprint-plan.md` under the same task number (S13-T0 to S13-T7). **Measurement
runs are in the sprint's budget table (§4); any other needs the owner's yes (rule 15). T2 stops
after its table; T4's keep and each T6 row are the owner's own yes.**

- [x] **T0** Write the sprint spec; make room (S13-T0) → REQ-1, REQ-2
  - Files: .shipkit/specs/second-traps/, plugins/shipkit/evals/README.md, docs/design/eval-history.md, scripts/lint.py, scripts/smoke.sh
  - Test: scripts/smoke.sh check 42 "lint-negative" (expects "the limit is 163,840"; a 60 KB file still trips it)
  - After: none
  - Done when: `spec-check.sh . second-traps` → 0 gaps; check 42 → PASS; evals bytes reported; lint 0/0
- [x] **T1** Path-scoped loading, measured (S13-T1) → REQ-3
  - Files: scripts/smoke.sh, plugins/shipkit/evals/README.md, ROADMAP.md
  - Test: scripts/smoke.sh check 54 "scoped-loading" (haiku, scratch project: `dependencies.md` installed by install-rules.sh with a nonce; prompt naming `pyproject.toml` → nonce seen; naming `README.md` → not seen; the same for `rails/gemfile.md` and `Gemfile`) — written first, red; Check first: the loading claim in the plan's §3
  - After: T0
  - Done when: check 54 → PASS with both halves (or the fallback recorded); the README paragraph states the result; the ROADMAP item is replaced by the number; lint 0/0
- [x] **T2** Sixteen trap-2 cases, with and without (S13-T2) → REQ-4, REQ-5, REQ-6, REQ-7
  - Files: plugins/shipkit/evals/trap2/, scripts/evals.sh, scripts/smoke.sh, plugins/shipkit/evals/README.md, docs/design/eval-results-4.6.md, ROADMAP.md
  - Test: scripts/smoke.sh check 47 extended to `trap2/*` (case format parses, 34 cases); `bash scripts/evals.sh --group trap2` with the rule and on a scratch copy without it, counts from trace-tools.sh
  - After: T1
  - Done when: check 47 → PASS for 34 cases; `--group trap2` → every case ≥ 2 of 3 with the rule; the sixteen-row table has no empty cell; evals bytes ≤ 163,840; lint 0/0; **stop: the owner sees the table before T3**
- [ ] **T3** The Gemfile line that stopped work (S13-T3) → REQ-8
  - Files: plugins/shipkit/stacks/rails/.claude/rules/gemfile.md, plugins/shipkit/evals/README.md
  - Test: `bash scripts/evals.sh --case stacks-gemfile` 3× with the new text (and `trap2/gemfile` if its line is this one); lint check 14 holds the byte limit
  - After: T2
  - Done when: `--case stacks-gemfile` → 3 of 3, no run halted on the network; lint 0/0
- [ ] **T4** The elder's step 1 (S13-T4) → REQ-9, REQ-10, REQ-11
  - Files: plugins/shipkit/agents/grandfather.md, scripts/trace-tools.sh, docs/design/eval-results-4.6.md, .shipkit/decisions/0001-project-map-default.md
  - Test: the read-rate column of trace-tools.sh checked by hand against one kept trace; the five `grandfather-xl` cases on the 4.5.0 text (baseline, 15 runs) and after each attempt (15 runs each, at most two); Check first: the read-rate claim in the plan's §3
  - After: T3
  - Done when: the results doc has the baseline and each attempt's rate and answers; the kept text (owner's go) or the revert with 0001's note is in the commit; `--group grandfather` ≥ 2 of 3 per case; lint 0/0
- [ ] **T5** The "wip" history (S13-T5) → REQ-12, REQ-13
  - Files: plugins/shipkit/evals/fixtures/ledger-gen/generate.py, scripts/smoke.sh, docs/design/eval-results-4.6.md, ROADMAP.md
  - Test: scripts/smoke.sh check 39 gains `--wip` (same files and tree hashes per commit, messages all "wip") — written first, red; `grandfather-xl/history` with and without the map on the wip log (6 runs, scratch copies); Check first: the generator claim in the plan's §3
  - After: T4
  - Done when: the generator check → PASS; the results doc has the six runs; the ROADMAP names what eve still owes; lint 0/0
- [ ] **T6** Housekeeping the owner approves (S13-T6) → REQ-14
  - Files: ROADMAP.md
  - Test: none beyond lint — each row's command and its output go in the commit message
  - After: T5
  - Done when: the ROADMAP records each of D1 to D5 as removed or kept with the date; D4 says who does it after the tag; lint 0/0
- [ ] **T7** The roadmap for the plan after (S13-T7) → REQ-15
  - Files: ROADMAP.md
  - Test: none beyond lint — every open item names a file and section
  - After: T6
  - Done when: Sprints 11 to 13 marked shipped; "Still open after Sprint 13" complete with evidence; lint 0/0

## After the gate

- **Ship:** run `/shipkit:ship second-traps` on this branch and fix what it finds — any
  branch-not-taken note goes in before the gate; the report starts with `READY` and is
  committed.
- **Release 4.6.0:** version in five places, changelog with "What using it for real showed",
  counts, the sprint exit checklist (smoke before the gate too, rule 14; the release run about
  $16), pull request with "What was awkward", merge after a green check, tag `v4.6.0`; then
  D4 and D5 on their own yeses.
