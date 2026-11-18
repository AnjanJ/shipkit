# Tasks: gate as software

The test command for this spec is the model-free smoke suite: `sh scripts/smoke.sh --no-model
</dev/null`. Every new smoke check is written first and shown failing, then the script is written.

T1 to T6 are Sprint 30's and start no model. T7 to T10 change what a model reads or need a paid
run; by the verifier plan's rules 33 and 34 they stay unticked until Sprint 35, and `design.md`
holds the text each one applies.

- [x] **T1** The session hook reads a `> Paths:` entry as it is written → REQ-1
  - Files: plugins/shipkit/scripts/session-start.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 21 (`spec-drift-paths`), one more case: an open spec whose `> Paths:` is `tests/, notes.txt` and twenty commits that touch only those two paths; the hook's line must count twenty. It also cites `spec-contract/REQ-16`
  - After: none
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 21's new case `PASS`, exit 0
- [x] **T2** The test command is recorded once, and `test-command.sh` prints it → REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-8
  - Files: plugins/shipkit/scripts/test-command.sh, plugins/shipkit/scripts/install-stack.sh, plugins/shipkit/scripts/unsetup-remove.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 106 (`test-command`): an install with `TEST_COMMAND` writes the record; a second overlay without it leaves the record; the script prints the record beside a `CLAUDE.md` that names two other commands; no record is exit 1 with the message; `--record` writes one line; removal deletes the record
  - After: T1
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 106 `PASS`, exit 0; `sh -n plugins/shipkit/scripts/test-command.sh` → no output
- [ ] **T3** `ship-check.sh` runs the gate's command steps and writes their evidence → REQ-9, REQ-10, REQ-11, REQ-12, REQ-13, REQ-14, REQ-15, REQ-16, REQ-17, REQ-18, REQ-19, REQ-20, REQ-21, REQ-22, REQ-23
  - Files: plugins/shipkit/scripts/ship-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 107 (`ship-check`): a complete fixture gives six blocks in order and exit 0; an unticked task fails step 3; a dirty tree fails step 7 and a file the test command made does not; a failing test command fails step 2 with its exit status, run once; no test command known; a migration file is listed as `NEEDS-READING`; a fired decision fails step 8; an unknown slug is exit 2 with no directory made; two runs at once keep two directories; `--clean` removes its own and refuses another; a stand-in `claude` is never called
  - After: T2
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 107 `PASS`, exit 0; `sh -n plugins/shipkit/scripts/ship-check.sh` → no output
- [ ] **T4** `release-check.sh` reads shipped specs against their `READY` reports, and CI shows it → REQ-24, REQ-25, REQ-26, REQ-27, REQ-28, REQ-29, REQ-30, REQ-31
  - Files: plugins/shipkit/scripts/release-check.sh, .github/workflows/lint.yml, scripts/smoke.sh
  - Test: scripts/smoke.sh check 108 (`release-check`): a clean fixture prints the summary line alone; a shipped spec with no report; a report whose commit is on an abandoned branch; a commit under `Paths` after the report and before the shipping commit; a shipped spec with no `Paths` line; exit 0 without `--enforce` and 1 with it; the workflow runs the script on pull requests with the full history
  - After: T3
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 108 `PASS`, exit 0; `sh plugins/shipkit/scripts/release-check.sh .` → exit 0, and its lines for this repository are written under "Found on the way" below
- [ ] **T5** The judge: `judge.sh`, the last tag's `spec-check.sh` in CI, and decision 0007 → REQ-32, REQ-33, REQ-34, REQ-35, REQ-36, REQ-37
  - Files: scripts/judge.sh, .github/workflows/lint.yml, .shipkit/decisions/0007-a-change-does-not-judge-itself.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 109 (`judge`), with a stand-in `claude`: without `--yes` the tag and the command are printed, the stand-in is not called and no worktree is added; with `--yes` the stand-in's `--plugin-dir` is inside a worktree of the last tag; that worktree is gone afterwards, also when the stand-in exits non-zero; a worktree made beforehand survives; the workflow runs the last tag's `spec-check.sh` beside the branch's
  - After: T4
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 109 `PASS`, exit 0; `sh plugins/shipkit/scripts/decision-check.sh . --run` → 0 fired, 0 error(s)
- [ ] **T6** The guide names the four scripts and what each prints → REQ-43
  - Files: GUIDE.md
  - Test: none: REQ-43 is prose, read against the guide
  - After: T5
  - Done when: `git grep -c -E 'test-command\.sh|ship-check\.sh|release-check\.sh|judge\.sh' GUIDE.md` → 4 or more; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T7** Sprint 35: the ship skill runs `ship-check.sh` and pastes its blocks → REQ-38, REQ-39
  - Files: plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/skills/ship/reference.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 29 (`ship-gate`), extended: each of the blocks 1, 2, 3, 7 and 8 in the model's report is found, line for line, in the `evidence.md` that `ship-check.sh` writes for the same fixture at the same commit
  - After: T5
  - Done when: the baseline of Sprint 35 is read by the owner; `sh scripts/smoke.sh --only 29 </dev/null` → check 29 `PASS`, exit 0
- [ ] **T8** Sprint 35: the spec skill writes the recorded command into each `Done when` → REQ-40
  - Files: plugins/shipkit/skills/spec/SKILL.md
  - Test: none: REQ-40 is read from the record of Sprint 35's real run
  - After: T7
  - Done when: the real run's notes show a `Done when` that holds the recorded command; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T9** Sprint 35: setup records the command where no overlay takes it → REQ-41
  - Files: plugins/shipkit/skills/setup/SKILL.md
  - Test: none: REQ-41 is read from the record of Sprint 35's real run
  - After: T8
  - Done when: the real run's notes show a record that the setup skill wrote; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T10** Sprint 35: the plugin the judge loads is the last tag's → REQ-42
  - Files: docs/design/eval-history.md
  - Test: none: REQ-42 is one paid session, read from its record
  - After: T9
  - Done when: `docs/design/eval-history.md` quotes the session's plugin-root line, and the path is inside the worktree `judge.sh` made

## Found on the way

Not fixed here; each goes to the sprint's pull request.
