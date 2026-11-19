# Tasks: numbers as data

The test command for this spec is the model-free smoke suite: `sh scripts/smoke.sh --no-model
</dev/null`. Every new smoke check is written first and shown failing, then the code.

T1 to T8 are Sprint 31's and start no model; `scripts/evals.sh` is only ever run here with a
stand-in for `claude plugin eval` (`EVALS_TOOL`). T8 needs five runs of CI's workflow, each on the
owner's yes at the time. T9 and T10 need a paid run and wait for Sprint 35.

- [x] **T1** The ledger: `evals-ledger.sh` appends and answers three queries, and `evals.sh` appends after a run → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9, REQ-10, REQ-33
  - Files: scripts/evals-ledger.sh, scripts/evals.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 110 (`eval-ledger`): a canned result file with a 3-run and a 5-run case appended to a scratch ledger gives the right rows and summary line; a second append adds none; `--below-full`, `--rate` and `--runs` answer on a seeded ledger that holds a `partial` run; `evals.sh` with a stand-in tool passes `--keep-temp` (not with `EVALS_KEEP=0`), appends with `--source release` or `partial`, and exits with the tool's status, also when it wrote no result file
  - After: none
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 110 `PASS`, exit 0; `sh -n scripts/evals-ledger.sh scripts/evals.sh` → no output
  - Note (2026-11-18): `evals.sh` first told an earlier result file from this run's with `-nt` against a marker; bash 3.2 compares whole seconds, so a fast run's file read as old and no row was added. It now moves an earlier `aggregate-result.json` aside to `aggregate-result.json.prev` before the run.
- [x] **T2** The ledger holds 5.1.0 and 5.2.0 → REQ-11, REQ-12
  - Files: docs/design/eval-ledger.tsv, scripts/smoke.sh
  - Test: scripts/smoke.sh check 111 (`ledger-backfill`): the repository's ledger holds 65 `result-file` rows for 5.2.0 and one `history` row for each 5.1.0 case, whose `runs` add up to 227, with 2 of 3 for exactly `grandfather-xl-drift`, `hello` and `intake-limit`
  - After: T1
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 111 `PASS`, exit 0; `sh scripts/evals-ledger.sh --below-full 2` → `hello`
  - Note (2026-11-18): the tree at `073938c` gives 65 cases, 227 runs and 16 watch cases, the page's totals. `--runs` reads 5.2.0 at $21.23 where the result file and the page say $21.25: each row's cost is rounded to cents (REQ-2) and `--runs` adds the rounded figures, so a run's total can be off by up to half a cent a case. The cost clauses in the table are $10 and $25, far from that.
- [x] **T3** The briefing starts fewer processes, and `spec-check.sh` prints what it printed at `398d1c9` → REQ-15, REQ-16, REQ-17
  - Files: plugins/shipkit/scripts/briefing.sh, plugins/shipkit/scripts/spec-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 112 (`briefing-cost`): `spec-check.sh` and the one at `398d1c9` (`git show`) print the same lines and exit the same on check 30's fixture, on a fixture with every kind of gap line and on this repository, as a whole and for one slug, with `--as-open` and `--as-shipped`; the briefing's gap line matches `spec-check`'s count; on check 30's fixture the briefing takes at most 0.5 s of CPU, best of three, reported and not failed under `SMOKE_TIMING=report`
  - After: T2
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 112 `PASS` and check 30 `PASS`, exit 0
- [x] **T4** The flake rule in the eval history, and the note and kit for Sprint 35 → REQ-13, REQ-14
  - Files: docs/design/eval-history.md, .shipkit/specs/numbers-as-data/design.md
  - Test: none: REQ-13 and REQ-14 are prose, read against the two files
  - After: T3
  - Done when: `eval-history.md` states rule 30 above its first `##`; `design.md`'s last section has an entry for each of the four, each line naming its source section and each with its command; `bash scripts/lint.sh` → 0 error(s)
  - Note (2026-11-18): `eval-history.md` has no line on smoke checks 2 and 4; the note says so and quotes `ROADMAP.md` and `CHANGELOG.md`, where they are recorded.
- [x] **T5** The map, `evals-for-diff.sh`, `evals.sh --for-diff`, and lint check 19 → REQ-19, REQ-20, REQ-21, REQ-22, REQ-23, REQ-24, REQ-25
  - Files: scripts/evals-map.tsv, scripts/evals-for-diff.sh, scripts/evals.sh, scripts/lint.py, scripts/smoke.sh
  - Test: scripts/smoke.sh check 113 (`evals-for-diff`): in a scratch repository with this map, a diff on `agents/reviewer.md` prints the four reviewer cases; one on `rules/shipkit.md` or `session-start.sh` prints every `rules-` case and `hello`; one under `docs/` prints nothing and exits 0; `evals.sh --for-diff` with a stand-in tool passes one `--case` for each and runs nothing when there is none; lint on a copy fails a case with no row, a row with no case and a path that does not exist, and passes the clean copy
  - After: T4
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 113 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s); `sh scripts/evals-for-diff.sh main` → the eleven cases whose fixture holds `.shipkit/`, and no other
  - Note (2026-11-18): the plan's done-when read "no case", written before the briefing's speed-up joined this sprint. T3 changed `briefing.sh` and `spec-check.sh`, whose lines the session hook prints in a fixture with a `.shipkit/` folder, so the map picks those eleven. None needs a run: check 112 holds `spec-check.sh`'s output byte for byte to `398d1c9`, so the text that reaches them did not change. `digest-attention` makes `.shipkit/` only in sub-projects, where the hook does not run, and is not picked. The rule cases list `inject-rule.sh`, which delivers their rule.
- [x] **T6** Two README sections move to `docs/design/eval-cases.md` → REQ-26, REQ-27, REQ-28
  - Files: plugins/shipkit/evals/README.md, docs/design/eval-cases.md, scripts/lint.py, scripts/smoke.sh
  - Test: scripts/smoke.sh check 114 (`eval-room`): the moved text equals the README's at `398d1c9` word for word under its dated line; the README keeps `## Cases` with one line naming the new file; the evals folder is at most 190,800 bytes; checks 54, 57 and 58 still pass
  - After: T5
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 54, 57, 58 and 114 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s)
- [x] **T7** Eleven reversal conditions read the ledger → REQ-29, REQ-30
  - Files: scripts/evals-ledger.sh, .shipkit/decisions/0002-spec-first-eval.md, .shipkit/specs/always-on/design.md, .shipkit/specs/decisions-bind/design.md, .shipkit/specs/graders-and-eve/design.md, .shipkit/specs/measured-cuts/design.md, .shipkit/specs/overlays-and-eve/design.md, .shipkit/specs/portfolio-run/design.md, .shipkit/specs/rule-evals/design.md, .shipkit/specs/second-traps/design.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 115 (`ledger-fired-if`): `decision-check.sh . --run` on this repository prints `HOLDS` for each of the eleven records of `design.md`'s table and no `ERROR`; on a scratch copy whose ledger is seeded past each clause, each reads `FIRED`; on one whose ledger is unreadable, each reads `ERROR`
  - After: T6
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 115 `PASS`, exit 0; `sh plugins/shipkit/scripts/decision-check.sh . --run` → 0 fired, 0 error(s)
  - Note (2026-11-18): `scripts/evals-ledger.sh` was added to Files. Check 115 showed a ledger that cannot be read gave decision 0002 `HOLDS`: the queries ended in a pipe to `sort` or `cat`, whose status hid awk's failure. The queries now exit 2 on a ledger they cannot read and on an awk failure, so a command built on them reads `ERROR`.
- [x] **T8** CI enforces the briefing's limit again → REQ-18
  - Files: .github/workflows/lint.yml, scripts/smoke.sh, .shipkit/specs/honest-evidence/spec.md
  - Test: scripts/smoke.sh check 105 (`timing-switch`), changed: the `smoke-no-model` job does not set `SMOKE_TIMING`, and the switch still works when set by hand
  - After: T7
  - Done when: five CI runs in a row on the runner, without the switch, read check 30 `PASS`; `sh scripts/smoke.sh --no-model </dev/null` → exit 0
  - Note (2026-11-18): this reverses `honest-evidence`'s seventh record by its own clause, and `honest-evidence/REQ-43` ("the CI job shall set `SMOKE_TIMING` to `report`") stops being true. That requirement is amended in the same commit, on the owner's word at the time.
  - Note (2026-11-18): the first CI run that reached a runner read check 30 at 0.69 s (PASS) and failed check 112: 0.77 s of CPU against its half second. Check 112 had read the switch too, and T8's first commit missed it. REQ-16's half second is "on the owner's machine", so check 112 now prints the time on CI (`CI=true`) and still fails on a changed output. The count of five runs starts again after that fix.
  - Done (2026-11-19): five `workflow_dispatch` runs in a row at `354eb13`, 03:35 to about 04:00 UTC, all green, smoke 238 passed and 0 failed each (runs 44452531406, 44452757519, 44452972791, 44453303674, 44453648212). Check 30, first try each time: 0.41, 0.50, 0.76, 0.97 and 0.58 s of CPU. Check 112, best of three, printed on CI: 0.54, 0.45, 0.66, 0.78 and 0.52 s. Three earlier attempts were cancelled because no macOS runner took the job; they ran no step and are not counted. The runner's spread is wide: 0.97 s is 0.03 s from the limit, and check 30 fails only if three tries in a row reach 1 s.
  - Note (2026-11-19): the next CI run, on the pull request at `f451af5` (a change to two spec files only), failed check 30 at 1.02 s, best of three, while check 112 read the same briefing at 0.72 s in the same job (run 44461093791). On the owner's yes the switch is back in the workflow, check 105 asserts it again, and REQ-18 and `honest-evidence/REQ-43` are amended. The task stays ticked: its five runs passed; the sixth showed that five runs were not enough.
- [ ] **T9** Sprint 35: the release run appends its rows → REQ-31
  - Files: docs/design/eval-ledger.tsv
  - Test: none: REQ-31 is read from Sprint 35's record
  - After: T8
  - Done when: the ledger holds the 5.4.0 release run's rows with `source` `release`
- [ ] **T10** Sprint 35: the kit runs for the four flaky cases → REQ-32
  - Files: docs/design/eval-history.md, docs/design/eval-ledger.tsv
  - Test: none: REQ-32 is read from Sprint 35's record
  - After: T9
  - Done when: `eval-history.md` records, for each of the four, a corrected grader, a changed sentence or the case deleted with its reason

## Found on the way

Not fixed here; each goes to the sprint's pull request.

- `second-traps/design.md`, "Sixteen trap-2 cases, with and without", reverses if "the release run
  passes $18". 5.1.0 cost $21.10 and 5.2.0 $21.25 (`eval-history.md`), so the condition has been
  true for two releases. It stays `manual` and is put to the owner (2026-11-18).
  Decided the same day, on the owner's yes: `.shipkit/decisions/0008-trap2-cases-stay.md` keeps
  all sixteen and fires on the trap-2 cases' own cost (above $8) or size (above 24 KB); the old
  record is marked superseded.
- For Sprint 32: CI's runner read the same briefing at 0.41 to over 1.02 s of CPU on unchanged
  scripts, so a CPU limit cannot be enforced there. The number of processes the briefing starts
  on check 30's fixture is the cost's cause and is the same on any machine; CI could enforce a
  count and print the time. Its own requirement, so it goes to Sprint 32's intake.
