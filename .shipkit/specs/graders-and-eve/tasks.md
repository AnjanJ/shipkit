# Tasks: Graders and `eve` (Sprint 18)

One commit per task, test and code together. The steps for each task are in
`docs/plans/second-run-sprint-plan.md` under the same task number (S18-T0 to S18-T5).
**Measurement runs are in the sprint's budget line (§4 and S18-T-REL): E9 9 runs ≈ $1.10,
E10 9 runs ≈ $1.20, E11 3 runs ≈ $0.45, E12 3 runs ≈ $0.30, E14 60 `haiku` runs ≈ $3, up to
two re-runs alone ≈ $1, the gate ≈ $0.50, the release run at 59 cases ≈ $17.80; any other
needs the owner's yes (rule 15). T2 and T5 STOP at their tables: the owner says go before a
sentence is kept or a line is cut (rule 6). Every count is read from traces with
`scripts/trace-tools.sh` and every sandbox a task keeps is removed after reading (rule 13).**

- [x] **T0** Write the sprint spec (S18-T0) → REQ-1 to REQ-10, the spec itself
  - Files: .shipkit/specs/graders-and-eve/
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . graders-and-eve --as-open` → 0 gaps on the draft; `sh plugins/shipkit/scripts/decision-check.sh .` → no FIRED; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the spec is in the thread; stamped at the branch-point commit, `Status: open`
- [x] **T1** `payments` graded on what the question asked (S18-T1) → REQ-1, REQ-2
  - Files: plugins/shipkit/evals/eve/payments/graders/stripe-twice-insight-none.md, plugins/shipkit/evals/README.md, docs/design/eval-results-4.11.md, scripts/evals.sh
  - Test: `node` on the pattern (rule 18) against one reply assembled from the quoted 4.9 miss (gem and constraint, handling files, no manifest) — the shipped pattern FAIL, the corrected PASS — and against a reply that cites `Gemfile` only (PASS still); then the three arms once (the committed plugin and the two scratch copies, 9 runs, `--keep-temp`), the traces read, the first table of `eval-results-4.11.md` with the 4.9 counts beside; `scripts/evals.sh`'s header cites graders-and-eve/REQ-1
  - After: T0
  - Done when: the table has no empty cell; the reading is written after the traces; the three sandboxes removed; lint 0/0
- [x] **T2** `eve` on her guesses: measure, one sentence, measure (S18-T2) → REQ-3, REQ-4, REQ-5
  - Files: plugins/shipkit/agents/eve.md, docs/design/eval-results-4.11.md, .shipkit/decisions/0001-project-map-default.md
  - Test: the no-map arm (T1's scratch copy, its `why` grader rewritten to the strict wording) 3 runs → the baseline; **STOP: the owner sees the baseline**; the sentence in `agents/eve.md` step 4; the same arm 3 runs and the three-map arm 3 runs (the committed plugin, the shipped grader); the three cells in the results document; `git diff v4.10.0 --stat -- plugins/shipkit/evals/eve/why` empty
  - After: T1
  - Done when: the three cells are filled; the sentence stays only if strict ≥ 2 of 3 and three-map 3 of 3, otherwise it is out in the same commit and the record says which number failed; record 0001's `eve` note has the line; the shipped `why` grader byte-identical to v4.10.0; the sandboxes removed; lint 0/0
- [x] **T3** The reworded `why` probe (S18-T3) → REQ-6
  - Files: plugins/shipkit/evals/eve/why-reworded/, plugins/shipkit/evals/README.md, docs/design/eval-results-4.11.md, scripts/evals.sh
  - Test: Check first (plan §3, fifth claim): the question's words against the generated map (`grep -ci` of `three`, `morning`, `logging`, `everyone` → 0 each; reword until so); the case runs 3 times with `--keep-temp` on the committed plugin; `map_read` per run and the pass count from the traces; `case.yaml` cites graders-and-eve/REQ-6; `bash scripts/lint.sh` holds the evals budget (check 17)
  - After: T2
  - Done when: the cell is filled with `map_read` per run; the README says what the probe watches; evals bytes ≤ 196,608; the sandboxes removed; lint 0/0
- [x] **T4** `notebooks` widened on its trace; `react` closed by record (S18-T4) → REQ-7, REQ-8
  - Files: plugins/shipkit/evals/trap2/notebooks/graders/strip-outputs.md, plugins/shipkit/evals/README.md, docs/design/eval-results-4.11.md, scripts/evals.sh, .shipkit/specs/graders-and-eve/design.md, ROADMAP.md
  - Test: `node` on the widened pattern (rule 18) against a Makefile shaped like the 4.8 run's (`python3 scripts/clean_notebook.py`; an inline `execution_count` form) — the shipped pattern FAIL, the widened PASS — and against the `nbstripout` and `nbconvert --clear-output` forms (PASS still) and a target that does nothing about outputs (FAIL); one re-run alone, 3 runs, `--keep-temp`, the Makefiles read from the traces; `scripts/evals.sh`'s header cites graders-and-eve/REQ-7; the `react` record's counts checked against `eval-history.md`
  - After: T3
  - Done when: `notebooks` ≥ 2 of 3 on the widened pattern with the 4.6 and 4.8 counts beside; the `react` record exists with the five counts and the reopen condition, and the ROADMAP item points to it; the sandboxes removed; lint 0/0
- [ ] **T5** The five kept files on a third model (S18-T5) → REQ-9, REQ-10
  - Files: docs/design/eval-results-4.11.md, .shipkit/specs/measured-cuts/design.md, scripts/smoke.sh, plugins/shipkit/rules/migrations.md, plugins/shipkit/rules/monorepo.md, plugins/shipkit/rules/testing.md, plugins/shipkit/stacks/react/.claude/rules/package-json.md, plugins/shipkit/stacks/rails/.claude/rules/rails.md
  - Test: `EVALS_MODEL=haiku bash scripts/evals.sh --case <name> -j 3 --keep-temp` for the ten cases (`scoped-migrations`, `scoped-monorepo`, `scoped-testing`, `stacks-package-json`, `stacks-rails`, `trap2-migrations`, `trap2-monorepo`, `trap2-testing`, `trap2-package-json`, `trap2-rails`) with the rule, and the same ten through the `claude plugin eval` line on a scratch copy whose `with-rule.sh` installs nothing, 60 runs; the table per file from the traces; **STOP: the owner sees the table before any cut**; smoke check 58's comment cites graders-and-eve/REQ-10 and its kept list names the files still kept — on a cut, check 58 changed first (red) and the lines out (green), in a second commit on the owner's go; the five rule files change only then
  - After: T4
  - Done when: the table has no empty cell; the note is appended to the measured-cuts record; any cut has the owner's go in the thread, its cases staying as the watch; check 58 → PASS; the sandboxes removed; lint 0/0
- [ ] **T-REL** Release 4.11.0 (S18-T-REL)
  - Files: plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, CHANGELOG.md, README.md, ROADMAP.md, docs/design/eval-history.md, .shipkit/releases/, .shipkit/specs/graders-and-eve/spec.md
  - Test: the sprint exit checklist (lint, smoke, evals at 59 cases, spec-check, the two byte lines); the gate headless
  - After: T5
  - Done when: the gate says READY; the report is committed with `Status: shipped`; the release run is in `eval-history.md`; the pull request is merged after a green check; tag `v4.11.0` pushed
