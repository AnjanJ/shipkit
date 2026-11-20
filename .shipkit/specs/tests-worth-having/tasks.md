# Tasks: tests worth having

The test command for this spec is the model-free smoke suite: `sh scripts/smoke.sh --no-model
</dev/null`. Every new smoke check is written first and shown failing, then the code.

T0 to T9 are Sprint 33's and start no model: `kind-probe.sh --run` is only ever run here without
`--yes`. No file under `plugins/*/skills`, `plugins/*/agents` or `plugins/*/rules` changes in
them. T10 and T11 need paid runs and wait for Sprint 35.

A property of REQ-21 to REQ-25 that fails on this checkout's own scripts stops T5. It is put to
the owner, with the input it failed on, before any change to `spec-check.sh` or `brief.sh`.

- [x] **T0** The design holds the waiting text and the records for the plan's V16, V17 and V18 → REQ-45, REQ-46, REQ-47
  - Files: .shipkit/specs/tests-worth-having/design.md
  - Test: none: REQ-45 to REQ-47 are prose, read against `design.md`
  - After: none
  - Done when: `design.md` holds W1 to W5, each naming what it waits on, and a record for each of V16, V17 and V18 with its reversal event; `sh plugins/shipkit/scripts/decision-check.sh . --run` → 0 fired, 0 error(s)
- [x] **T1** `kind-probe.sh`: the kinds fixture, and the commands printed and not run → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-20
  - Files: scripts/kind-probe.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 122 (`kind-fixtures`): `--scaffold kinds` into an empty directory leaves one commit and a clean tree, a spec `passbook` with a stamp, `Status: open` and a `design.md`, no `tasks.md`, and exactly three requirements holding the three sentences; the recorded test command exits 0 there; a second scaffold into the same directory exits 2 and changes nothing; `--run kinds` prints 5 lines and `--run kinds 2` prints 2, each holding `/shipkit:spec passbook tasks`, writes no file and never calls a stand-in `claude` put first on the `PATH`; an unknown mode and an unknown fixture name each print the usage on standard error and exit 2
  - After: T0
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 122 `PASS`, exit 0; `sh -n scripts/kind-probe.sh` → no output
- [ ] **T2** `kind-probe.sh`: the migration fixture → REQ-15, REQ-16
  - Files: scripts/kind-probe.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 122, extended: `--scaffold migration` into an empty directory leaves one commit and a clean tree that holds `vendor/textkit-1/`, `vendor/textkit-2/` and a changelog naming a change in a function `inkwell/format.py` calls, and no `.shipkit/specs/`; the recorded test command exits 0 there; `--run migration` prints 3 lines, each holding `/shipkit-workflows:migration-plan`, writes no file and never calls the stand-in `claude`
  - After: T1
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 122 `PASS`, exit 0
- [ ] **T3** `--read`, and six task lists written by hand → REQ-7, REQ-8, REQ-9, REQ-10, REQ-11, REQ-12, REQ-13, REQ-14
  - Files: scripts/kind-probe.sh, scripts/kind-replies/, scripts/smoke.sh
  - Test: scripts/smoke.sh check 123 (`kind-reader`): on `scripts/kind-replies/`, `--read` prints three tab-separated lines for each of the six `tasks.md` files, in path order, and they are the eighteen lines of the table in `design.md`, "The eight files written by hand"; then `TOTAL REQ-1 right=4 missed=2`, `TOTAL REQ-2 right=5 missed=1` and `TOTAL REQ-3 right=4 missed=2`
  - After: T2
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 123 `PASS`, exit 0
- [ ] **T4** `--read-plan`, and two plans written by hand → REQ-18, REQ-19
  - Files: scripts/kind-probe.sh, scripts/kind-replies/, scripts/smoke.sh
  - Test: scripts/smoke.sh check 123, extended: `--read-plan` on `plan-differential.md` and `plan-none.md` prints two tab-separated lines, the first ending `differential` and the second `none`; a file that does not exist is a line on standard error and exit 2
  - After: T3
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 123 `PASS`, exit 0
- [ ] **T5** `prop.py`: five properties of the two parsers, each shown to fail on a broken copy → REQ-21, REQ-22, REQ-23, REQ-24, REQ-25, REQ-26, REQ-27, REQ-28, REQ-29, REQ-30
  - Files: scripts/prop.py, scripts/smoke.sh
  - Test: scripts/smoke.sh check 124 (`prop`): `prop.py --max-examples 5` prints `PASS` for each of the five names and exits 0, and leaves `git status --porcelain` and the working directory's listing as they were; for each row of the table in `design.md`, "How each property is shown to fail", the broken copy differs from the script and `prop.py --only <name> --no-shrink` at it exits 1 and prints `FAIL <name>` with the input; two such runs at one broken copy print the same lines; with a `hypothesis.py` that raises `ImportError` first on `PYTHONPATH` it prints the `uv run --with hypothesis==6.170.16 python3 scripts/prop.py` line, checks nothing and exits 2. Each property function in `prop.py` cites its requirement
  - After: T4
  - Done when: `uv run --quiet --with hypothesis==6.170.16 python3 scripts/prop.py` → five `PASS` lines, exit 0; `sh scripts/smoke.sh --no-model </dev/null` → check 124 `PASS`, exit 0
- [ ] **T6** Both CI jobs install Hypothesis and run the properties → REQ-31
  - Files: .github/workflows/lint.yml, scripts/smoke.sh
  - Test: scripts/smoke.sh check 125 (`prop-ci`): each of the workflow's two jobs holds a step that installs `hypothesis==` at the version `prop.py` holds and a step whose run line is `python3 scripts/prop.py`; a copy of the workflow with one job's step taken out fails the check's own reading
  - After: T5
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 98, 105, 108, 109 and 125 `PASS`, exit 0; on the pull request, both jobs run the step and are green
- [ ] **T7** `red-check.sh`: a cited test is run on the base tree → REQ-32, REQ-33, REQ-34, REQ-35, REQ-36, REQ-37, REQ-38, REQ-39, REQ-40, REQ-41, REQ-42
  - Files: plugins/shipkit/scripts/red-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 126 (`red-check`): in a scratch repository with a base commit and a feature commit, a citing test that needs the feature gives `TEST <file>` and `RED-AT-BASE`; a test that asserts nothing gives `GREEN-AT-BASE <file>`; a suite broken at the base gives `BASE-NOT-RUNNABLE` after one run; no differing citing file gives `NO-TESTS` with no run; a citation outside the spec's `> Tests:` paths is not a `TEST` line and is the file `spec-check.sh` calls `CITED-ELSEWHERE`; an untracked citing test is listed; no `--test` and no record is exit 2 with no verdict word; `--link deps` puts a link in the scratch tree and its target's files are there afterwards; a `--link` name that is a file, or tracked at the base, is exit 2; after every run, and after a `TERM` sent during a run, the scratch directory is gone and `git status --porcelain`, `git branch`, `git stash list`, `git worktree list` and `HEAD` read as before, with a worktree made by the check still there; standard output holds only `TEST` lines and the verdict line; wrong usage, an unknown ref, a directory that is no repository and an unknown slug are each exit 2
  - After: T6
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 126 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s); `sh -n plugins/shipkit/scripts/red-check.sh` → no output
- [ ] **T8** `ship-check.sh` ends its evidence with the `red-check.sh` command → REQ-43
  - Files: plugins/shipkit/scripts/ship-check.sh, .shipkit/specs/gate-as-software/spec.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 107, extended: the last line of `evidence.md` starts `Not run, a suggestion:` and holds `red-check.sh`, the slug and the base ref, and holds `--test` only when `ship-check.sh` was given one; standard output is still the scratch path and the six step lines; the file still has six `### ` headings
  - After: T7
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 107 `PASS`, exit 0; `gate-as-software/spec.md` carries a dated note under its REQ-11
- [ ] **T9** `GUIDE.md` says what `red-check.sh` is for → REQ-44
  - Files: GUIDE.md
  - Test: none: REQ-44 is prose, read against `GUIDE.md`
  - After: T8
  - Done when: `GUIDE.md` has a section "Red at base" after "Checks that a diff triggers" that gives the four verdict words, says a `--link` folder is shared with the project it is pointed at, and says it is run by hand; `bash scripts/lint.sh` → 0 error(s)
- [ ] **T10** Sprint 35: both probes run, and text only where they miss → REQ-6, REQ-17, REQ-48, REQ-49
  - Files: plugins/shipkit/skills/spec/reference.md, plugins/shipkit-workflows/skills/migration-plan/SKILL.md, docs/design/eval-history.md
  - Test: none: REQ-6 and REQ-17 start a model, and REQ-48 and REQ-49 are read from Sprint 35's record
  - After: T9
  - Done when: `eval-history.md` holds, for each of W2 to W5, the probe's reading before, whether the text went in, and the reading after
- [ ] **T11** Sprint 35: `red-check.sh` is read on the clone of the owner's project → REQ-50
  - Files: docs/design/eval-history.md
  - Test: none: REQ-50 is read from Sprint 35's record
  - After: T10
  - Done when: `eval-history.md` holds the verdict word `red-check.sh` printed on the clone, the task it was run on and the time it took

## Found on the way

Not fixed here; each goes to the sprint's pull request.

- The spec skill keeps the goldfish's reply at one fixed path, `shipkit-spec-goldfish.out` in the
  system temp directory (`plugins/shipkit/skills/spec/SKILL.md`, Q2 step 4). On 2026-11-20 that
  file held the reply for a spec of another project, written by a session in another window.
  Two sessions on one machine write one file. This spec's reply was kept beside it under another
  name and the other session's file was left as it was. The fix is a change to a skill's text,
  so it waits for Sprint 35 (the plan's rule 34).
