# Tasks: What a decision binds (Sprint 23)

One commit per task, test and code together, except T3, which is two: the shared fixture, then the
reviewer. The steps for each task are in `docs/plans/binding-sprint-plan.md` under the same task
number (S23-T0 to S23-T3, S23-T-MERGE). **Measurement runs are in the plan's budget line (§4, Sprint
23 ≈ $5–6): `brief/binds` 10 runs × 2 arms (raised from 3 on the owner's yes at T1's STOP, about $1.30 more) and 10 more at T2's STOP (the owner's yes, about $1), four `reviewer` cases × 3, the forced gate twice, the two
`--group` runs at merge. Anything else needs the owner's yes (rule 15). T1 STOPs for the owner to see
the baseline (rule 6). Every sandbox and scratch copy is removed after reading (rule 13), and traces
are read through the eval output directory before that.**

- [x] **T0** Write the sprint spec (S23-T0) → REQ-1 to REQ-13, the spec itself
  - Files: .shipkit/specs/decisions-bind/, docs/plans/binding-sprint-plan.md
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . decisions-bind --as-open` → 0 gaps on the draft; `sh plugins/shipkit/scripts/decision-check.sh . --run` → no FIRED or ERROR; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the spec in the thread; stamped at the branch-point commit, `Status: open`; the plan's approval line in the same commit
- [x] **T1** The case first: does a brief let a rejected alternative through? (S23-T1, G1) → REQ-4, REQ-5
  - Files: plugins/shipkit/evals/brief/, docs/design/eval-results-5.1.md
  - Test: `bash scripts/evals.sh --group brief -j 4` on today's `brief.sh`, ten runs; each run read from its written file for `AwareDatetime`; the fixture's design copies `linkshort`'s `69578a5` shape (three decisions, the third citing REQ-3 and REQ-4, T1 on REQ-1 and REQ-2 sharing two files with T2); `case.yaml` cites `decisions-bind/REQ-4`
  - After: T0
  - Done when: the table has no empty cell; **STOP: the owner sees the number**; the owner's go in the thread; the sandboxes removed; lint 0/0
- [x] **T2** Every live decision reaches every task (S23-T2, G1) → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-14
  - Files: plugins/shipkit/scripts/brief.sh, plugins/shipkit/evals/brief/, scripts/smoke.sh, docs/design/eval-results-5.1.md, CHANGELOG.md
  - Test: scripts/smoke.sh, written first, red: the `brief` check's left-out assertion flips ("one README section" now listed on T3's brief, citing `decisions-bind/REQ-1`), "Old ledger idea" still left out (`decisions-bind/REQ-2`), a spec with no live decision says none is recorded for this feature (`decisions-bind/REQ-3`), the sentence above a listed decision and not above "None recorded" (`decisions-bind/REQ-14`); `brief/binds`' second grader, both sides through `node` (rule 23); then `bash scripts/evals.sh --group brief -j 4 --runs 10`, on REQ-1 alone and again with REQ-14
  - After: T1
  - Done when: the `brief` check PASS; both sets of rows in the table; no rejected alternative and later tasks' work in at most 1 of 10 runs; lint 0/0
- [x] **T3** A contradicted decision fails the review (S23-T3, G2, G3, G9) → REQ-6, REQ-7, REQ-8, REQ-9, REQ-10, REQ-12, REQ-13
  - Files: plugins/shipkit/agents/reviewer.md, plugins/shipkit/evals/lib/, plugins/shipkit/evals/reviewer/, scripts/smoke.sh, .shipkit/specs/review-and-ship/spec.md, CHANGELOG.md
  - Test: first commit: the two fixtures on the shared script, `bash scripts/evals.sh --group reviewer -j 4` still 3 of 3 each, smoke check 77 "reviewer-fixture" (cites `decisions-bind/REQ-13`). Second commit, each written first, red: `reviewer/rejected-alternative` (every requirement met, the code uses what a live record turned down: `VERDICT: FAIL`, the decision named `contradicted`; cites `decisions-bind/REQ-6`, `REQ-7`, `REQ-8`), `reviewer/decision-unbuilt` (a live decision a later task will build, and a superseded record the code does not follow: `VERDICT: PASS`, the first `not built`, the second not marked; cites `decisions-bind/REQ-7`, `REQ-9`, `REQ-10`); smoke check 77 extended: the reviewer's text names both states and no longer says the gate weighs anything (`decisions-bind/REQ-12`); then `--group reviewer`, every case 3 of 3
  - After: T2
  - Done when: every `reviewer` case 3 of 3; check 77 PASS; the evals directory at most 204,800 bytes; `review-and-ship/REQ-6` amended in place with its note; lint 0/0
- [x] **T-MERGE** Merge, untagged (S23-T-MERGE) → REQ-11
  - Files: docs/design/eval-results-5.1.md, .shipkit/specs/decisions-bind/
  - Test: the sprint exit checklist with `--group brief` and `--group reviewer`; `/shipkit:ship` forced twice on `rejected-alternative`'s fixture: contradicted → NOT READY naming the decision; the decision marked superseded by a record the code follows → READY; both results recorded
  - After: T3
  - Done when: the checklist holds; the pull request is merged after a green check, no tag; the owner's cache untouched
