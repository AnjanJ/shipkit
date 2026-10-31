# Tasks: What a number can say (Sprint 24)

One commit per task, test and code together, except T1, which is one commit per grader, and T3, which
is two: the moved readings, then the cases. The steps for each task are in
`docs/plans/binding-sprint-plan.md` under the same task number (S24-T0 to S24-T4, S24-T-MERGE).
**Measurement runs are in the plan's budget line (§4, Sprint 24 ≈ $10): the harvest and the four cases
again ≈ $2.50, `eve/matrix` and `eve/consolidate` × 3 ≈ $1.20, Care 30 runs ≈ $1, `--group eve` and
`--group rules` ≈ $3, about $7.70 in all. Anything else needs the owner's yes (rule 15). Every sandbox
and scratch copy is removed after reading (rule 13), and "reading" means every question this spec asks
of it: the harvest stays until T2 has read it.**

- [x] **T0** Write the sprint spec (S24-T0) → REQ-1 to REQ-14, the spec itself
  - Files: .shipkit/specs/readable-numbers/, docs/plans/binding-sprint-plan.md
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . readable-numbers --as-open` → 0 gaps on the draft; `sh plugins/shipkit/scripts/decision-check.sh . --run` → no FIRED or ERROR; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the spec in the thread; stamped at the branch-point commit, `Status: open`; the plan's S24-T1, budget row, risk row and S24-T-MERGE amended in the same commit, with the owner's two answers
- [x] **T1** Four graders, both sides (S24-T1, G4) → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6
  - Files: plugins/shipkit/evals/trap2/rails/graders/, plugins/shipkit/evals/trap2/go-mod/graders/, plugins/shipkit/evals/trap2/experiments/graders/, plugins/shipkit/evals/trap2/package-json/graders/, scripts/evals.sh, docs/design/eval-history.md
  - Test: on the old graders, `bash scripts/evals.sh --case trap2-rails --runs 5 -j 4 --keep-temp`, the same for `trap2-go-mod` and `trap2-experiments`, and `EVALS_MODEL=haiku bash scripts/evals.sh --case trap2-package-json -j 4 --keep-temp`; each written file rebuilt in the scratchpad from its trace's Write, Edit and Bash calls and the fixture. Then per grader, through `node`, before any further run (rule 23): the failed file fails the old pattern and passes the new; every file that passed the old passes the new; a seeded violation fails the new (`order.update_column(:x, 1)`, `go mod vendor`, a silent fallback with no device logged, an unconditional `npm install`); for `rails` and `go-mod`, a real call with a trailing comment fails the new. `scripts/evals.sh` cites `readable-numbers/REQ-1` to `REQ-5`. Then the four cases once more on the corrected graders, `package-json` on `sonnet` and on `haiku`
  - After: T0
  - Done when: both sides in each commit's test plan, written after the result was read (rule 24); the four cases read from their traces, each failed file saying what it did; a miss that does not recur is said so, and `go-mod` gains no compile form without a harvested file; the evals directory at most 204,800 bytes; lint 0/0
- [x] **T2** `map_read` sees a repo-wide Grep (S24-T2, G5) → REQ-7, REQ-8
  - Files: scripts/trace-tools.sh, scripts/smoke.sh, docs/design/eval-results-5.1.md
  - Test: the check-first on T1's traces: does a Grep's `tool_result` carry the matched paths? Smoke check 78, written first, red, on a stored two-line trace: a Grep with no path whose result lists `PROJECT_MAP.md` reads `map_read` 1 (cites `readable-numbers/REQ-7`), one whose result does not reads 0 and `map_shell` is unchanged (cites `readable-numbers/REQ-8`)
  - After: T1
  - Done when: check 78 PASS; the check-first's result in the table; T1's sandboxes removed; lint 0/0
- [x] **T3** `reports.md` watched, and the room for it (S24-T3, G6, G9) → REQ-9, REQ-10, REQ-11, REQ-14
  - Files: plugins/shipkit/evals/README.md, docs/design/eval-history.md, plugins/shipkit/evals/eve/matrix/, plugins/shipkit/evals/eve/consolidate/, plugins/shipkit/evals/fixtures/FACTS-PORTFOLIO.md, scripts/lint.py, docs/design/eval-results-5.1.md
  - Test: first commit: the five sections moved whole, the README naming where, `bash scripts/lint.sh` 0/0 and smoke checks 57, 58 and 59 PASS alone, `scripts/lint.py`'s check 17 cites `readable-numbers/REQ-14`. Second commit: each grader through `node` on a written reply, passing a right reply and failing a seeded wrong one (a matrix of manifest ranges only; a consolidation with no path) (rule 23); `case.yaml` cites `readable-numbers/REQ-9` and `REQ-10`; then both cases three runs each, `--keep-temp`
  - After: T2
  - Done when: one row per run with whether it read `reports.md`; a miss recorded by trace and a ROADMAP item; the evals directory at most 204,800 bytes, measured; lint 0/0
- [ ] **T4** The Care line, read twice more (S24-T4, G7) → REQ-12, REQ-13
  - Files: plugins/shipkit/evals/rules/care-quiet/, plugins/shipkit/evals/README.md, scripts/evals.sh, docs/design/eval-results-5.1.md, ROADMAP.md
  - Test: the fixture run by hand leaves `app/orders.py` modified and `app/refunds.py` untracked; `case.yaml` cites `readable-numbers/REQ-12`; then `claude plugin eval plugins/shipkit --ablation with-without --case rules-care-quiet --runs 5 --keep-temp --scaffold --allow-tools Bash Write Edit --trust-plugin --no-publish --model sonnet`, the same on `haiku`, and `rules-care` on `haiku`; every trace read for what ran, a judge's verdict checked against it
  - After: T3
  - Done when: the table has no empty cell; a miss by the design's bar is a ROADMAP item; two-sided Fisher p given for each with-against-without, the weak ones said so; no file under `plugins/shipkit/rules/` changed; the evals directory at most 204,800 bytes; lint 0/0
- [ ] **T-MERGE** Merge, untagged (S24-T-MERGE) → REQ-14
  - Files: docs/design/eval-results-5.1.md, docs/plans/binding-sprint-plan.md, CHANGELOG.md, .shipkit/specs/readable-numbers/
  - Test: the sprint exit checklist with `--group eve` and `--group rules`; `map_read` read on `eve/why`; the second record's clause checked with `git diff --stat 2e8bed0 HEAD`; the plan's §0 rows for this sprint at their targets, or the record says why not
  - After: T4
  - Done when: the checklist holds; the pull request has "What was awkward", and is merged with a merge commit after a green check; no tag; the branch kept; the owner's cache untouched
