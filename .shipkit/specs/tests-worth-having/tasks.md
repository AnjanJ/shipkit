# Tasks: tests worth having

The test command for this spec is the model-free smoke suite: `sh scripts/smoke.sh --no-model
</dev/null`. Every new smoke check is written first and shown failing, then the code.

T0 to T9 are Sprint 33's and start no model: `kind-probe.sh --run` is only ever run here without
`--yes`, or with it against a stand-in for `claude` that records its call. No file under `plugins/*/skills`, `plugins/*/agents` or `plugins/*/rules` changes in
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
- [x] **T2** `kind-probe.sh`: the migration fixture → REQ-15, REQ-16
  - Files: scripts/kind-probe.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 122, extended: `--scaffold migration` into an empty directory leaves one commit and a clean tree that holds `vendor/textkit-1/`, `vendor/textkit-2/` and a changelog naming a change in a function `inkwell/format.py` calls, and no `.shipkit/specs/`; the recorded test command exits 0 there, and fails on a fresh copy whose `inkwell/deps.py` names version 2.0; `--run migration` prints 3 lines, each holding `/shipkit-workflows:migration-plan`, writes no file and never calls the stand-in `claude`. Added while building (2026-11-20): `--run kinds 1 --yes` and `--run migration 2 --yes`, with a second stand-in that records where and with what it was started and prints a canned JSON result, each start in a fresh fixture under `run-<i>/proj`, and each migration run's `plan.md` holds the reply's text
  - After: T1
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 122 `PASS`, exit 0
- [x] **T3** `--read`, and six task lists written by hand → REQ-7, REQ-8, REQ-9, REQ-10, REQ-11, REQ-12, REQ-13, REQ-14
  - Files: scripts/kind-probe.sh, scripts/kind-replies/, scripts/smoke.sh
  - Test: scripts/smoke.sh check 123 (`kind-reader`): on `scripts/kind-replies/`, `--read` prints three tab-separated lines for each of the six `tasks.md` files, in path order, and they are the eighteen lines of the table in `design.md`, "The eight files written by hand"; then `TOTAL REQ-1 right=4 missed=2`, `TOTAL REQ-2 right=5 missed=1` and `TOTAL REQ-3 right=4 missed=2`
  - After: T2
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 123 `PASS`, exit 0
- [x] **T4** `--read-plan`, and two plans written by hand → REQ-18, REQ-19
  - Files: scripts/kind-probe.sh, scripts/kind-replies/, scripts/smoke.sh
  - Test: scripts/smoke.sh check 123, extended: `--read-plan` on `plan-differential.md` and `plan-none.md` prints two tab-separated lines, the first ending `differential` and the second `none`; a file that does not exist is a line on standard error and exit 2
  - After: T3
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 123 `PASS`, exit 0
- [x] **T5** `prop.py`: five properties of the two parsers, each shown to fail on a broken copy → REQ-21, REQ-22, REQ-23, REQ-24, REQ-25, REQ-26, REQ-27, REQ-28, REQ-29, REQ-30
  - Files: scripts/prop.py, scripts/smoke.sh
  - Test: scripts/smoke.sh check 124 (`prop`): `prop.py --max-examples 5` prints `PASS` for each of the five names and exits 0, and leaves `git status --porcelain` and the working directory's listing as they were; for each row of the table in `design.md`, "How each property is shown to fail", the broken copy differs from the script and `prop.py --only <name> --no-shrink` at it exits 1 and prints `FAIL <name>` with the input; two such runs at one broken copy print the same lines; with a `hypothesis.py` that raises `ImportError` first on `PYTHONPATH` it prints the `uv run --with hypothesis==6.170.16 python3 scripts/prop.py` line, checks nothing and exits 2. Each property function in `prop.py` cites its requirement
  - After: T4
  - Done when: `uv run --quiet --with hypothesis==6.170.16 python3 scripts/prop.py` → five `PASS` lines, exit 0; `sh scripts/smoke.sh --no-model </dev/null` → check 124 `PASS`, exit 0
- [x] **T6** Both CI jobs install Hypothesis and run the properties → REQ-31
  - Files: .github/workflows/lint.yml, scripts/smoke.sh
  - Test: scripts/smoke.sh check 125 (`prop-ci`): each of the workflow's two jobs holds a step that installs `hypothesis==` at the version `prop.py` holds and a step whose run line is `python3 scripts/prop.py`; a copy of the workflow with one job's step taken out fails the check's own reading
  - After: T5
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 98, 105, 108, 109 and 125 `PASS`, exit 0; on the pull request, both jobs run the step and are green
  - Note (2026-11-20): the two steps are in both jobs and check 125 reads them. The task stays open
    until both jobs have run the properties on the pull request, which needs the owner's yes to
    push. Not verified until then: that `pip install hypothesis==6.170.16` works on CI's Python
    3.12, how long forty inputs take on each runner, and whether Ubuntu's awk gives the answers
    macOS's gives.
  - Verified (2026-11-20): on pull request #44 at `18e0356` (run 44686605730) both jobs ran
    "Property tests of the two parsers" green, five `PASS` lines each, forty inputs each:
    `lint` on Ubuntu, Python 3.12.16, 10 s; `smoke-no-model` on macOS arm64, Python 3.12.10,
    35 s. `pip install hypothesis==6.170.16` worked on both. Ubuntu's awk agreed with macOS's on
    the forty inputs. CI's smoke run: 250 passed, 0 failed.
- [x] **T7** `red-check.sh`: a cited test is run on the base tree → REQ-32, REQ-33, REQ-34, REQ-35, REQ-36, REQ-37, REQ-38, REQ-39, REQ-40, REQ-41, REQ-42
  - Files: plugins/shipkit/scripts/red-check.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 126 (`red-check`): in a scratch repository with a base commit and a feature commit, a citing test that needs the feature gives `TEST <file>` and `RED-AT-BASE`; a test that asserts nothing gives `GREEN-AT-BASE <file>`; a suite broken at the base gives `BASE-NOT-RUNNABLE` after one run; no differing citing file gives `NO-TESTS` with no run; a citation outside the spec's `> Tests:` paths is not a `TEST` line and is the file `spec-check.sh` calls `CITED-ELSEWHERE`; an untracked citing test is listed; no `--test` and no record is exit 2 with no verdict word; `--link deps` puts a link in the scratch tree and its target's files are there afterwards; a `--link` name that is a file, or tracked at the base, is exit 2; after every run, and after a `TERM` sent during a run, the scratch directory is gone and `git status --porcelain`, `git branch`, `git stash list`, `git worktree list` and `HEAD` read as before, with a worktree made by the check still there; standard output holds only `TEST` lines and the verdict line; wrong usage, an unknown ref, a directory that is no repository and an unknown slug are each exit 2
  - After: T6
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 126 `PASS`, exit 0; `bash scripts/lint.sh` → 0 error(s); `sh -n plugins/shipkit/scripts/red-check.sh` → no output
- [x] **T8** `ship-check.sh` ends its evidence with the `red-check.sh` command → REQ-43
  - Files: plugins/shipkit/scripts/ship-check.sh, .shipkit/specs/gate-as-software/spec.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 107, extended: the last line of `evidence.md` starts `Not run, a suggestion:` and holds `red-check.sh`, the slug and the base ref, and holds `--test` only when `ship-check.sh` was given one; standard output is still the scratch path and the six step lines; the file still has six `### ` headings
  - After: T7
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 107 `PASS`, exit 0; `gate-as-software/spec.md` carries a dated note under its REQ-11
- [x] **T9** `GUIDE.md` says what `red-check.sh` is for → REQ-44
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
- [x] **T12** `brief.sh` copies a task's `Test` and `Done when` lines as written → REQ-51
  - Files: plugins/shipkit/scripts/brief.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 127 (`brief-escapes`): a task whose `Test` line holds `\n`, `\t`, `\\` and `\b` and whose `Done when` line holds `\n` and `\c` gives a brief whose "Prove it with" holds those two lines byte for byte and three lines in all; `brief.sh` exits 0
  - After: T9
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → checks 71 and 127 `PASS`, exit 0; `sh -n plugins/shipkit/scripts/brief.sh` → no output

## The sprint's exit checklist (2026-11-20, at the commit after T9's)

Lint 0 errors. `sh scripts/smoke.sh --no-model </dev/null` exit 0: 249 passed (35 text-only), 16
skipped (model), 0 failed. No grader was written or changed; `scripts/grader-check.sh` still reads
37 replies as expected, 0 not. `spec-check.sh .` exit 0: 36 specs, 0 gaps; this spec reads
tested=41, waived=9, uncited=0. The three always-on rules: 2,999 of 3,000 bytes. The evals folder:
204,629 of 204,800 bytes, as at the sprint's start. `release-check.sh .`: 31 shipped, 5 findings,
the five of the sprint's start. Line 9, for the first time: `uv run --with hypothesis==6.170.16
python3 scripts/prop.py` exit 0, five properties hold on forty inputs each (Hypothesis 6.170.16,
Python 3.14.8). `decision-check.sh . --run`: 179 decisions, 0 fired, 0 errors. Line 10: no existing
skill, agent, rule or overlay file is changed or removed since `main`.

T6 closed on 2026-11-20, after both CI jobs ran the properties on pull request #44. Still open: T10 and T11, for Sprint 35.

## Found on the way

Not fixed here; each goes to the sprint's pull request.

- The spec skill keeps the goldfish's reply at one fixed path, `shipkit-spec-goldfish.out` in the
  system temp directory (`plugins/shipkit/skills/spec/SKILL.md`, Q2 step 4). On 2026-11-20 that
  file held the reply for a spec of another project, written by a session in another window.
  Two sessions on one machine write one file. This spec's reply was kept beside it under another
  name and the other session's file was left as it was. The fix is a change to a skill's text,
  so it waits for Sprint 35 (the plan's rule 34).
- `brief.sh` does not copy a task's `Test:` and `Done when:` lines as written when they hold a
  backslash (found 2026-11-20, while choosing what `prop.py` may generate). It prints them with
  `echo` (`brief.sh:154-155`), and `sh` on this machine reads escapes there: in a scratch task,
  `'one\ntwo\tthree\\four'` came out with a real line break, a tab and one backslash, and
  `grep -E '\bword\b'` with two backspace bytes. The requirement itself is printed by awk and
  is exact, which is what REQ-25 holds. None of the five properties reads these two lines. The
  fix is `printf '%s\n'` in a shipped script outside this sprint's files, so it is put to the
  owner. Fixed on the owner's yes (2026-11-20): T12, REQ-51, check 127. The
  title line (`brief.sh:137`) is printed with `echo` too and is left as it was.
