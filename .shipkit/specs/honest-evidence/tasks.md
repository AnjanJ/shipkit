# Tasks: honest evidence

The test command for this spec is the model-free smoke suite: `sh scripts/smoke.sh --no-model
</dev/null`. Until T1 lands, `scripts/smoke.sh` takes no argument and any run of it starts a
model, so T1's own checks are first shown red through the new argument parser alone (`--list`),
which starts nothing.

T1 to T9 are Sprint 29's and start no model. T10 and T11 change what a model reads; by the
verifier plan's rules 33 and 34 they stay unticked until Sprint 35, and `design.md` holds the
text each one applies.

- [x] **T1** The smoke suite runs without a model: `--no-model`, `--only`, `--list`, the registry of checks and the counts → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9, REQ-10, REQ-40
  - Files: scripts/smoke.sh
  - Test: scripts/smoke.sh check 97 (`smoke-args`), which runs the script's own `--list` forms and its usage errors
  - After: none
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → last line `smoke: all checks run passed; 16 skipped (model)`, exit 0
  - Note (2026-11-17): the Done-when first read `PATH=/usr/bin:/bin sh …`. That takes `claude` off the `PATH` by taking everything else off it too: the system's Python 3.9 then runs check 38, which needs 3.10. A stand-in `claude` first on the `PATH` already keeps the real one out of reach, and check 97 runs `--list --no-model` on a bare `PATH`.
  - Note (2026-11-17): check 30's fifty-spec time is now the briefing's CPU time, not the wall clock. The verifier plan gives that fix to Sprint 31 (S31-T2, subtask 2); it is done here because the check failed the first model-free run, 1.0 s on three tries with the owner at work in another window, and would fail every free run on a busy machine.
- [x] **T2** CI runs the model-free suite on every pull request → REQ-11
  - Files: .github/workflows/lint.yml, scripts/smoke.sh
  - Test: scripts/smoke.sh check 98 (`ci-smoke-job`), which reads the workflow for a pull-request job that runs `scripts/smoke.sh --no-model`
  - After: T1
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 98 `PASS`, exit 0
- [x] **T3** `spec-check.sh` prints an `EVIDENCE` line for each spec → REQ-12, REQ-13, REQ-14
  - Files: plugins/shipkit/scripts/spec-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 99 (`evidence-line`), on a fixture with one tested, one waived and one uncited requirement
  - After: T2
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 99 `PASS`, exit 0; `sh plugins/shipkit/scripts/spec-check.sh .` → 0 gap(s)
- [x] **T4** A `> Tests:` line narrows where a citation counts, and `CITED-ELSEWHERE` names one outside it → REQ-15, REQ-16, REQ-17, REQ-18
  - Files: plugins/shipkit/scripts/spec-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 100 (`tests-line`), on a fixture cited once under the listed path and once outside it
  - After: T3
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 100 `PASS` and check 30's timing `PASS`, exit 0; `sh plugins/shipkit/scripts/spec-check.sh .` → 0 gap(s)
- [ ] **T5** `SKIPPED-CITE` names a citation in a skipped test → REQ-19, REQ-20
  - Files: plugins/shipkit/scripts/spec-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 101 (`skipped-cite`), with a citation three lines from a skip marker and one four lines away
  - After: T4
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 101 `PASS`, exit 0; `sh plugins/shipkit/scripts/spec-check.sh .` → 0 gap(s)
- [ ] **T6** `spec-diff.sh` lists the requirements a branch changed, added, removed or waived → REQ-21, REQ-22, REQ-23, REQ-24, REQ-25, REQ-26, REQ-27, REQ-28, REQ-29
  - Files: plugins/shipkit/scripts/spec-diff.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 102 (`spec-diff`), on git fixtures for each kind of line and both baselines
  - After: T5
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 102 `PASS`, exit 0; `sh -n plugins/shipkit/scripts/spec-diff.sh` → exit 0
- [ ] **T7** `brief-verify.sh` prints `SPEC-EDITED` when a task's work touched its own spec → REQ-30, REQ-31
  - Files: plugins/shipkit/scripts/brief-verify.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 103 (`spec-edited`), which edits a fixture spec's `design.md` and then only its `tasks.md`
  - After: T6
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 103 `PASS` and check 26 `PASS`, exit 0
- [ ] **T8** Text-only assertions are printed as `PASS  [text]`, counted, and listed in an audit → REQ-32, REQ-33
  - Files: scripts/smoke.sh, docs/design/smoke-audit-5.4.md
  - Test: scripts/smoke.sh check 104 (`text-label`), which finds check 76's line printed as `PASS  [text]` and the audit's rows equal in number to the `passt` calls
  - After: T7
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 104 `PASS`, a count line with a text-only number above zero, exit 0
- [ ] **T9** The guide names the new arguments, the `> Tests:` line, `spec-diff.sh` and the four new kinds of line → REQ-39
  - Files: GUIDE.md
  - Test: none: REQ-39 is prose, read against the guide
  - After: T8
  - Done when: `git grep -c -E 'no-model|spec-diff\.sh|CITED-ELSEWHERE|SKIPPED-CITE|SPEC-EDITED|EVIDENCE' GUIDE.md` → 6 or more; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T10** Sprint 35: the ship report carries the evidence line and the block of changed requirements, and the gate's reply says when the result rests on reading alone → REQ-34, REQ-35, REQ-36
  - Files: plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/skills/ship/reference.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 29 (`ship-gate`), extended: the report of a fully waived fixture carries `> Evidence: 0 of` and its reply says the result rests on reading alone
  - After: T8
  - Done when: the baseline of Sprint 35 is read by the owner; `sh scripts/smoke.sh --only 29 </dev/null` → check 29 `PASS`, exit 0
- [ ] **T11** Sprint 35: the spec skill asks where the tests live, and its reference describes the `> Tests:` line → REQ-37, REQ-38
  - Files: plugins/shipkit/skills/spec/SKILL.md, plugins/shipkit/skills/spec/reference.md, scripts/smoke.sh
  - Test: none: REQ-37 is read from the record of Sprint 35's real run, REQ-38 against the reference file
  - After: T10
  - Done when: the real run's notes show a `> Tests:` line the skill wrote; `bash scripts/lint.sh` → 0 error(s)

## Found on the way

Not fixed here; each goes to the sprint's pull request and to the ROADMAP's "Still open".

- The spec skill writes the goldfish's reply to one fixed temp file name
  (`shipkit-spec-goldfish.out`). At this spec's design gate that file held another project's
  reply. This spec's two replies were written beside it under their own names.
- `plugins/shipkit/scripts/session-start.sh:275` trims a spec's `> Paths:` with
  `sed 's/^[ \t]*//; s/[ \t]*$//'`. BSD sed reads `[ \t]` as a space, a backslash or the letter
  t, so a path that starts or ends with "t" loses it: `tests/billing/` becomes `ests/billing/`,
  and drift is then counted on a path that does not exist. `spec-check.sh` reads its new
  `> Tests:` line with `[[:space:]]` for that reason.
- Smoke check 38 (`ledger-gen`) needs Python 3.10 or later (`sys.stdlib_module_names`). On this
  machine `/usr/bin/python3` is 3.9.6; the check passes only because a newer `python3` comes
  first on the `PATH`. CI's new job pins 3.12.
