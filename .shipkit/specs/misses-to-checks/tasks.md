# Tasks: misses to checks

The test command for this spec is the model-free smoke suite: `sh scripts/smoke.sh --no-model
</dev/null`. Every new smoke check is written first and shown failing, then the code.

T0 to T13 are Sprint 32's and start no model; `scripts/evals.sh` is only ever run here with a
stand-in for `claude plugin eval` (`EVALS_TOOL`). No file under `plugins/*/skills`,
`plugins/*/agents` or `plugins/*/rules` changes in them. T14 and T15 need paid runs and wait for
Sprint 35.

- [x] **T0** The design holds the waiting text and the records for the plan's V13, V14 and V15 → REQ-45, REQ-46, REQ-47
  - Files: .shipkit/specs/misses-to-checks/design.md
  - Test: none: REQ-45 to REQ-47 are prose, read against `design.md`
  - After: none
  - Done when: `design.md` holds W1 to W10, each naming the case it waits on, and a record for each of V13, V14 and V15 with its reversal event; `sh plugins/shipkit/scripts/decision-check.sh . --run` → 0 fired, 0 error(s)
- [ ] **T1** Smoke check 114 reads the ceiling and check 113 reads its reviewer cases from the map → REQ-18
  - Files: scripts/smoke.sh, .shipkit/specs/numbers-as-data/spec.md
  - Test: scripts/smoke.sh checks 113 and 114, changed: for a diff on `agents/reviewer.md` check 113 expects every map row named `reviewer-*`, and a scratch map with one more such row prints it too; check 114 fails above 204,800 bytes and no longer at 190,800
  - After: T0
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 113 and 114 `PASS`, exit 0; `numbers-as-data/spec.md` carries a dated note under its REQ-21 and its REQ-27
- [ ] **T2** A held-out case stays held out: lint, `evals-for-diff.sh` and the ledger → REQ-15, REQ-16, REQ-17, REQ-19, REQ-20
  - Files: scripts/lint.py, scripts/evals-for-diff.sh, scripts/evals-ledger.sh, scripts/evals.sh, scripts/smoke.sh, docs/design/eval-cases.md, .shipkit/specs/numbers-as-data/spec.md
  - Test: scripts/smoke.sh check 116 (`holdout-kept-out`): on a copy of this tree, lint fails a row whose set is `foo`, a case under `evals/holdout/` whose set is `tune`, and a `holdout` row whose case is elsewhere, naming each; with a scratch map, `evals-for-diff.sh` prints no held-out case and writes `evals-for-diff: 1 held-out case(s) not listed` to standard error; `evals-ledger.sh append` with that map writes `holdout` for the case it marks and `tune` or `watch` for the others
  - After: T1
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 116 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s); `docs/design/eval-cases.md` says when a held-out case runs; `numbers-as-data/spec.md` carries a dated note under its term "A case's set"
- [ ] **T3** `grader-check.sh` shows a grader both ways through `node` → REQ-40
  - Files: scripts/grader-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 117 (`grader-both-ways`): on a scratch case, a reply the pattern must pass reads `PASS` and one it must fail reads `FAIL` as expected, with the grader's flags honoured; a pattern changed to match both makes the script exit 1; a reply file whose grader does not exist, and a case with a `pass` file and no `fail` file, make it exit 1; on this repository's `scripts/grader-replies/` it exits 0
  - After: T2
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 117 `PASS`, exit 0; `sh -n scripts/grader-check.sh` → no output
- [ ] **T4** `reviewer/helper-only`, and a check that builds every reviewer tree → REQ-1, REQ-2, REQ-7
  - Files: plugins/shipkit/evals/lib/review-fixture.sh, plugins/shipkit/evals/reviewer/helper-only/, scripts/grader-replies/reviewer-helper-only/, scripts/evals-map.tsv, docs/design/eval-cases.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 118 (`reviewer-trees`): each of the four old cases' trees equals, file for file, the tree the shared fixture at `9e061ca` (`git show`) builds; in the `helper-only` tree the test citing `refunds/REQ-2` calls only `check_amount`, `refund` does not call it and passes 2500 on a charge of 2000 to the gateway, and the test command exits 0. Check 117 reads the new grader's three replies
  - After: T3
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 77, 113, 117 and 118 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T5** `holdout/reviewer-helper-only` on the `notes-export` feature, and the bytes measured → REQ-11, REQ-12, REQ-14, REQ-41
  - Files: plugins/shipkit/evals/lib/review-fixture.sh, plugins/shipkit/evals/holdout/reviewer-helper-only/, scripts/grader-replies/holdout-reviewer-helper-only/, scripts/evals-map.tsv, docs/design/eval-cases.md, scripts/smoke.sh, plugins/shipkit/evals/README.md
  - Test: scripts/smoke.sh check 118, extended: the held-out tree is the `notes-export` feature, its diff from `base` holds no `refund` in any letter case, the test citing `notes-export/REQ-1` calls only `is_shareable`, `export_notes` does not call it and returns a private note, and the test command exits 0. Check 77, extended: a case under `evals/holdout/reviewer-*` builds from the shared fixture too. Check 117 reads the new grader's replies
  - After: T4
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 77, 116, 117 and 118 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s); the evals folder's size and the projection for the nine cases to come are written under this task as a note, and the README's section "What graders can check" has moved to `docs/design/eval-cases.md` only if the projection passed 204,800
- [ ] **T6** Four more tuning cases: `skipped-test`, `comment-cite`, `weakened-req`, `waiver-added` → REQ-3, REQ-4, REQ-5, REQ-6, REQ-8, REQ-9, REQ-10
  - Files: plugins/shipkit/evals/lib/review-fixture.sh, plugins/shipkit/evals/reviewer/skipped-test/, plugins/shipkit/evals/reviewer/comment-cite/, plugins/shipkit/evals/reviewer/weakened-req/, plugins/shipkit/evals/reviewer/waiver-added/, scripts/grader-replies/, scripts/evals-map.tsv, docs/design/eval-cases.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 118, extended: `skipped-test` runs green with one test skipped and `spec-check.sh` prints `SKIPPED-CITE refunds REQ-2`; in `comment-cite`, `refunds/REQ-2` is in a comment in `app/refunds.py` and nowhere under `tests/`; in `weakened-req`, `spec-diff.sh . refunds base` prints `REQ-CHANGED refunds REQ-2` and no other `REQ-` or `WAIVER-` line and `refund` caps the amount; in `waiver-added` it prints `WAIVER-ADDED` and `REQ-CHANGED` for REQ-2 and no test cites it. Check 117 reads the four graders' replies
  - After: T5
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 117 and 118 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T7** `holdout/reviewer-skipped-test` → REQ-13, REQ-14
  - Files: plugins/shipkit/evals/lib/review-fixture.sh, plugins/shipkit/evals/holdout/reviewer-skipped-test/, scripts/grader-replies/holdout-reviewer-skipped-test/, scripts/evals-map.tsv, docs/design/eval-cases.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 118, extended: `export_notes` leaves a private note out, the test citing `notes-export/REQ-1` is skipped, the test command exits 0 and `spec-check.sh . notes-export` prints `SKIPPED-CITE notes-export REQ-1`. Check 117 reads the grader's replies
  - After: T6
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 116, 117 and 118 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T8** A second round: `reviewer/second-round` and `reviewer/stale-met` → REQ-21, REQ-22, REQ-23, REQ-24
  - Files: plugins/shipkit/evals/lib/review-fixture.sh, plugins/shipkit/evals/reviewer/second-round/, plugins/shipkit/evals/reviewer/stale-met/, scripts/grader-replies/, scripts/evals-map.tsv, docs/design/eval-cases.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 118, extended: `second-round` is the `helper-only` tree plus one untracked file, `.shipkit/releases/2026-11-01-refunds.md`, whose first line is `NOT READY` and whose table marks REQ-2 `NOT MET`; `stale-met` is the `missing-req` tree plus that file with `READY` and REQ-2 `MET` at an `app/refunds.py` line. Check 117 reads both graders' replies, a `CANNOT TELL` reply among those `second-round` must fail
  - After: T7
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 117 and 118 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T9** `checks-match.sh` prints the items a diff triggers, from the base ref → REQ-25, REQ-26, REQ-27, REQ-28, REQ-29, REQ-30, REQ-31
  - Files: plugins/shipkit/scripts/checks-match.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 119 (`checks-match`), in a scratch repository: a `path` trigger is met by a changed file and prints `TRIGGERED C<n>: <title>` with the item's three lines, in the file's order; an `added` trigger is met by an added line and not by a removed one; the working tree's edited copy is not read; a checks file that exists only on the branch gives nothing and exit 0; no arguments and an unknown ref exit 64; `--lint` prints `BAD-ITEM` and exits 1 for an item with a missing line, a trigger of neither kind and a source that does not exist, and exits 0 on a good file and on none; `git status --porcelain` is the same before and after
  - After: T8
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 119 `PASS`, exit 0; `sh -n plugins/shipkit/scripts/checks-match.sh` → no output
- [ ] **T10** This repository's four check items, and the guide → REQ-32, REQ-35
  - Files: .shipkit/checks.md, GUIDE.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 119, extended: this repository's `.shipkit/checks.md` holds four items and `checks-match.sh --lint` exits 0 on it
  - After: T9
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 119 `PASS`, exit 0; `sh plugins/shipkit/scripts/checks-match.sh --lint .` → no output, exit 0; `GUIDE.md` names the script, `--lint`, an item's form and both kinds of trigger; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T11** `reviewer/check-triggered`, and the twelve reviewer cases → REQ-18, REQ-33, REQ-34, REQ-41
  - Files: plugins/shipkit/evals/lib/review-fixture.sh, plugins/shipkit/evals/reviewer/check-triggered/, scripts/grader-replies/reviewer-check-triggered/, scripts/evals-map.tsv, docs/design/eval-cases.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 118, extended: in the `check-triggered` tree `base` holds a checks file with one item, `checks-match.sh . base` prints `TRIGGERED C1`, `refund` calls `gateway.refund` with two arguments, and the tree is otherwise `all-met`'s. Check 113: a diff on `agents/reviewer.md` prints exactly twelve cases, all named `reviewer-*`. Check 77: every case whose prompt starts the reviewer builds from the shared fixture. Check 117 reads the grader's three replies
  - After: T10
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 77, 113, 117 and 118 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T12** `escape/second-of-a-kind`, a second grader on the first escape, and the eleven rows → REQ-36, REQ-37, REQ-38, REQ-39, REQ-42
  - Files: plugins/shipkit/evals/escape/second-of-a-kind/, plugins/shipkit/evals/escape/missing-req/graders/, scripts/grader-replies/, scripts/evals-map.tsv, docs/design/eval-cases.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 120 (`escape-second`): the tree's spec holds REQ-3, `.shipkit/escapes/0001-refund-above-charge.md` names the cause `requirement missing` and the spec `.shipkit/specs/refunds/`, `refund` accepts an amount below zero and the test command exits 0; the map gives `holdout` to the two held-out cases and `tune` to the other nine. Check 117 reads the new grader's replies and those of `escape-missing-req`'s second grader
  - After: T11
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 117 and 120 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s), which holds the evals folder to 204,800 bytes; `docs/design/eval-cases.md` has a row for each of the eleven cases, and each one's `case.yaml` names its miss
- [ ] **T13** The briefing's command count, enforced on every machine → REQ-43, REQ-44
  - Files: scripts/smoke.sh
  - Test: scripts/smoke.sh check 121 (`briefing-commands`): with thirteen stand-ins as the whole `PATH`, the briefing on check 30's fixture prints what it prints under the normal `PATH` and starts at most 229 commands, and the `PASS` line carries the count; the count from fifty-one specs, given to the verdict with `CI=true` and `SMOKE_TIMING=report`, is a `FAIL`
  - After: T12
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 121 `PASS` with its count, exit 0; on the pull request, CI's `smoke-no-model` job reads the same count
- [ ] **T14** Sprint 35: baselines, text only where a baseline misses, and the runs after → REQ-48
  - Files: plugins/shipkit/agents/reviewer.md, plugins/shipkit/skills/escape/SKILL.md, plugins/shipkit/skills/ship/reference.md, docs/design/eval-history.md, docs/design/eval-ledger.tsv, scripts/smoke.sh
  - Test: none: REQ-48 is read from Sprint 35's record
  - After: T13
  - Done when: `eval-history.md` holds, for each waiting entry W1 to W10, its case's score before, whether the text went in, and the score after
- [ ] **T15** Sprint 35: the held-out pair runs at the release run, and no text answers it → REQ-49
  - Files: docs/design/eval-history.md, docs/design/eval-ledger.tsv
  - Test: none: REQ-49 is read from Sprint 35's record
  - After: T14
  - Done when: the ledger holds the two `holdout-` rows of the 5.4.0 release run, and any held-out failure is a line in `eval-history.md` dated before any change of text

## Found on the way

Not fixed here; each goes to the sprint's pull request.

- `docs/design/eval-cases.md` has no row for `reviewer/decision-unbuilt` or
  `reviewer/rejected-alternative` (found 2026-11-19; its table has rows for `reviewer/missing-req`
  and `reviewer/all-met` only).
- The hand-off note of 2026-11-19 said smoke check 114 enforces the 204,800-byte ceiling. It
  enforced 190,800 (`numbers-as-data/REQ-27`); T1 moves it.
