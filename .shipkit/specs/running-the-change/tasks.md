# Tasks: running the change

The test command for this spec is the model-free smoke suite: `sh scripts/smoke.sh --no-model
</dev/null`. Every new smoke check is written first and shown failing, then the code. New checks
are numbered from 128, each with a line in `registry()`, before "# The last assertion of a
--no-model run".

Every task here is Sprint 34's and starts no model. No existing file under `plugins/*/skills`,
`plugins/*/agents`, `plugins/*/rules` or `plugins/shipkit/stacks` is changed or removed (the
plan's rules 33 and 34; exit-checklist line 10). The waiting text in `design.md` is applied in
Sprint 35, under that sprint's own spec tasks.

T9 cuts nothing without the owner's yes for each cut, given in the thread to one numbered list.

- [x] **T0** The spec: intake, requirements, design with its waiting text, tasks → REQ-16
  - Files: .shipkit/specs/running-the-change/intake.md, .shipkit/specs/running-the-change/spec.md, .shipkit/specs/running-the-change/design.md, .shipkit/specs/running-the-change/tasks.md
  - Test: none: REQ-16 is prose, read against `design.md` ("Waiting text for Sprint 35")
  - After: none
  - Done when: `sh plugins/shipkit/scripts/spec-check.sh . running-the-change --as-open` → exit 0; `sh plugins/shipkit/scripts/decision-check.sh . --run` → 0 fired, 0 error(s)
- [x] **T11** The secret guard reads `cwd` from indented hook JSON → REQ-35
  - Files: plugins/shipkit/scripts/guard-commit.sh, scripts/smoke.sh, .shipkit/specs/running-the-change/spec.md, .shipkit/specs/running-the-change/tasks.md
  - Test: scripts/smoke.sh check 18 (`guard-commit`), extended: the hook JSON of `git commit -m wip`, indented over several lines with a space after each colon and naming the project as `cwd`, run from another directory while `config/server.key` is staged, exits 2 and names the file
  - After: T0
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 18 `PASS`, exit 0
  - Found 2026-11-20 at the design gate: `guard-commit.sh:30` read `cwd` only as `"cwd":"`, so with indented JSON it checked the directory it started in. The new case was red (exit 0) before the fix and green after it; the other seven cases of check 18 passed both times.
- [x] **T1** `verify-run.sh`: start, probe, one request, stop, three outcomes → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9, REQ-10, REQ-12
  - Files: plugins/shipkit/scripts/verify-run.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 128 (`verify-run`), with `TMPDIR` set to an empty directory of the check's own: a start command that writes `$PORT`, `$A` and `$B` to a file and then serves a folder with python3's `socketserver.TCPServer` and `SimpleHTTPRequestHandler` (not `http.server`, amended 2026-11-21: see the spec's "a static fixture"), run with `--env A=1 --env B=2 --request /page.html`, where `page.html` has 15 lines, prints `RAN 200 /page.html`, then a status line holding `200`, then the page's first 10 lines and no more, and exits 0; the file holds a port above 1023, `1` and `2`; the server's log holds exactly one `GET /page.html`; a start command that sleeps 2 s before serving, with `--timeout 10`, gives `RAN`; `--start 'i=0; while [ $i -lt 30 ]; do echo line$i; i=$((i+1)); done; exit 3'` prints `EXITED 3`, then `line10` to `line29` and nothing else, and exits 1; `--start 'sleep 60' --timeout 2` prints `NOT-READY after 2 s` first and exits 1; each bad form (no `--start`, no `--request`, path `x`, `--timeout 0`, `--timeout abc`, `--env 1A=x`, `--env noequals`) exits 2 with standard error not empty, and a marker file the start command would write is absent; a `PATH` holding `sh` and `awk` but no `curl` exits 2 with `curl` named on standard error; after every run, and after an `INT` sent to a run waiting on `sleep 60`, the `TMPDIR` directory is empty, no process whose command line names the check's folder or `sleep 6128` is left (read from `ps -A -o command=`), and a `sleep 6129` the check started beforehand still runs. The script's header cites `running-the-change/REQ-12` beside the lines REQ-12 asks for
  - After: T11
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 128 `PASS`, exit 0; `sh -n plugins/shipkit/scripts/verify-run.sh` → no output; `bash scripts/lint.sh` → 0 errors
  - Note (2026-11-20): the suite's run for this commit exited 1 on one check: 112 (`briefing-cost`) read 0.54 s of CPU, best of three, against its half second. It was read and not run again, as on 2026-11-19 (misses-to-checks T5): `briefing.sh` and `spec-check.sh` are unchanged since `main`, the check times a fixture of fifty specs of its own, and the load average was 4.1 just after the run, with another window at work. The other 251 checks passed, check 128 among them. Check 128 alone takes about 5 s; run against two broken copies of the script (one that never stops the application, one that probes the request path), it failed both.
- [x] **T2** Ten runs in a row on one static fixture → REQ-11
  - Files: scripts/smoke.sh
  - Test: scripts/smoke.sh check 129 (`verify-run-ten`): a fresh folder holding `index.html`, ten runs of `verify-run.sh` with the spec's static fixture as the start command and `--request /index.html` from inside it, each first line `RAN 200 /index.html`, and no `http.server` process started by a run left after it (read with `ps -A -o pid= -o command=` against the list taken before)
  - After: T1
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 129 `PASS`, exit 0
  - Note (2026-11-20): check 129 could not be red first: the behaviour it holds is T1's, already built. It was shown to fail instead on a copy of the script whose clean-up does not stop the application ("a server is left" from run 1 on) and passes on the script, ten runs in about 4 s.
- [x] **T3** The elixir and static `verify` skills, installed only on `--with-skills` → REQ-13, REQ-14, REQ-15
  - Files: plugins/shipkit/stacks/elixir/.claude/skills/verify/SKILL.md, plugins/shipkit/stacks/static/.claude/skills/verify/SKILL.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 130 (`verify-skills`): both files exist with a `description:` of 300 characters or fewer; `install-stack.sh` for `elixir` and for `static` into fresh projects, with the `KEY=value` arguments that smoke's existing install checks pass for those stacks, exits 0 and leaves no `.claude/skills/verify/`; the same with `--with-skills` exits 0 and leaves `.claude/skills/verify/SKILL.md` byte-identical to the overlay's file; `scripts/lint.py` prints no line naming either file. The text is the design's, "The two `verify` skills"
  - After: T2
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 130 `PASS`, checks 67 and 69 `PASS`, exit 0; `bash scripts/lint.sh` → 0 errors, 0 warnings
- [x] **T4** `context-cost.md`: the two skills' bytes, and the Rails count corrected → REQ-17
  - Files: docs/design/context-cost.md
  - Test: none: REQ-17 is prose, read against `docs/design/context-cost.md`
  - After: T3
  - Done when: `context-cost.md` gives each `verify` skill's description bytes and file bytes as `wc -c` and `scripts/context-cost.sh` measure them on a fresh `--with-skills` install, and says the Rails overlay ships 4 skills with their bytes re-measured; `git grep -n '6 skills' docs/design/context-cost.md` → nothing
- [x] **T5** `commit-gate.sh`: off, observe and enforce → REQ-18, REQ-19, REQ-20, REQ-21, REQ-22, REQ-23, REQ-24, REQ-25, REQ-27
  - Files: plugins/shipkit/scripts/commit-gate.sh, scripts/smoke.sh
  - Test: scripts/smoke.sh check 131 (`commit-gate`), with `SHIPKIT_HOME` set to a fresh directory, the hook's JSON fed on stdin both compact and indented: a call for `ls -la` in each of `off`, `observe` and `enforce` prints nothing, writes no log and exits 0; an unstamped `git commit -m "x"` with the mode unset, `off` and `bogus` does the same; in `observe` it adds one row whose fields are a UTC time, the session id, `observe`, `unstamped` and the JSON's `cwd`, prints nothing and exits 0, and with no `cwd` in the JSON the last field is `-`; a message holding `Verified: tests (x)`, and one in two `-m` parts with `Verified: none (docs only)` in the second, write nothing and exit 0 in `observe` and in `enforce`; in `enforce` the first and second unstamped commits of one session each add a `blocked` row, print one line on standard error holding `Verified:` and `Verified: none (`, and exit 2, and the third adds a `passed` row and exits 0, while a commit of another session id is still blocked; `git commit -F f`, `git commit --no-edit` and a bare `git commit` each add an `unseen` row and exit 0 in `observe` and in `enforce`; empty stdin, JSON with no `session_id`, and a `SHIPKIT_HOME` that cannot be written each exit 0 in `enforce`; `Verified: none ()` does not count as a stamp. The script's header cites `running-the-change/REQ-27` beside the lines REQ-27 asks for
  - After: T3
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 131 `PASS`, exit 0; `sh -n plugins/shipkit/scripts/commit-gate.sh` → no output
- [x] **T6** `hooks.json` runs the gate beside the secret guard → REQ-26
  - Files: plugins/shipkit/hooks/hooks.json, scripts/smoke.sh, scripts/lint.py
  - Test: scripts/smoke.sh check 132 (`commit-gate-hook`): `hooks.json` parses; the `PreToolUse` entry whose matcher is `Bash` lists exactly two commands, `guard-commit.sh` then `commit-gate.sh`, each with timeout 5; each resolves to an executable file in the copy; the guard's existing check (smoke `:696-742`) still passes; with `SHIPKIT_COMMIT_GATE` unset, the hook JSON of a commit that stages `.env` is still blocked by the guard and the gate adds nothing. `scripts/lint.py` changes only if it rejects a second command, and then only to accept it
  - After: T5
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 132 `PASS`, exit 0; `bash scripts/lint.sh` → 0 errors, 0 warnings; the always-on rules still 2,999 bytes
- [x] **T7** The gate's cost measured, and the guide's section → REQ-28, REQ-29
  - Files: .shipkit/specs/running-the-change/design.md, GUIDE.md
  - Test: none: REQ-28 and REQ-29 are prose, read against `design.md` and `GUIDE.md`
  - After: T6
  - Done when: the record "a separate script, and what it costs" in `design.md` gives `commit-gate.sh`'s time per call on a call that is not a commit, measured as the design's other four were (300 calls, the JSON for `ls -la`); `GUIDE.md` has a section on the commit gate with its three modes, `$SHIPKIT_HOME/commit-gate.log`, and the two `git log` lines from the design; `sh plugins/shipkit/scripts/decision-check.sh . --run` → 0 fired, 0 error(s)
- [x] **T8** The audit of every smoke check and eval case, held to the registry → REQ-30, REQ-31
  - Files: docs/design/trim-audit-checks.md, scripts/smoke.sh
  - Test: scripts/smoke.sh check 133 (`trim-audit`): between `<!-- audit:begin -->` and `<!-- audit:end -->`, the audit has one row for each label `registry()` prints and each case `scripts/evals-map.tsv` lists, and no row without `cut YYYY-MM-DD` for anything else; each row's "last failed" cell is `X.Y.Z` or `never`, its "also covered by" cell is labels or cases or `nothing`, its cost is `<n> s` or `$<n>`; no trap-2 case's Candidate cell starts with `yes`; and on a copy of the audit with one row taken out, one cell put in the wrong form, or a trap-2 case marked `yes`, the check's own reading fails
  - After: T6
  - Done when: `sh scripts/smoke.sh --no-model </dev/null` → check 133 `PASS`, exit 0; the audit's candidates go to the owner as one numbered list
- [x] **T9** The cuts the owner says yes to, with their citations moved → REQ-32, REQ-33
  - Files: docs/design/trim-audit-checks.md, scripts/smoke.sh, scripts/evals-map.tsv, docs/design/eval-cases.md, plugins/shipkit/evals/
  - Test: scripts/smoke.sh check 133, extended: a row marked `cut YYYY-MM-DD` names a label `registry()` no longer prints or a case `scripts/evals-map.tsv` no longer lists, and a copy of the audit with a cut row whose label is still listed fails the check's own reading
  - After: T8
  - Done when: each cut has the owner's yes in the thread; `sh scripts/smoke.sh --no-model </dev/null` → check 133 `PASS`, exit 0; `sh plugins/shipkit/scripts/spec-check.sh .` → 0 gaps; `sh scripts/grader-check.sh` → 0 not as expected
  - Note (2026-11-20): the audit's two candidates went to the owner, who replied "yes to all". `2b rules-fallback` is cut: its row reads `cut 2026-11-20`, `install-lifecycle/REQ-5` is still cited by `8b incomplete-install` (spec-check 0 gaps), and check 97's counts of model checks go from sixteen to fifteen. Check 133 was red first ("cut but still listed") with the row marked and 2b still in the suite. `9c managed-block` is not cut yet: this spec says a check whose citation cannot move is not cut, and only 9c proves the second half of `install-lifecycle/REQ-10`, so the owner was asked again and said "keep" (2026-11-20): it stays, and T9 ends with the one cut. The suite's run exited 1 on check 112 (`briefing-cost`) alone, 0.57 s against 0.5 at a load average of 10.5; read and not run again, `briefing.sh` and `spec-check.sh` unchanged since `main`.
- [x] **T10** The plan's release task holds the prune pass → REQ-34
  - Files: docs/plans/verifier-sprint-plan.md
  - Test: none: REQ-34 is prose, read against the plan's "The release task"
  - After: T0
  - Done when: the plan's "### The release task" holds a line that makes a prune pass, against `docs/design/trim-audit-checks.md`, part of every release

## The sprint's exit checklist (2026-11-20, at `765bda8`)

All ten lines of the plan's checklist hold. Line 1: `bash scripts/lint.sh` 0 errors, 0 warnings
across 28 skills, 5 agents, 22 rules. Line 2: `sh scripts/smoke.sh --no-model </dev/null` exit 0,
257 passed (35 text-only), 15 skipped (model), 0 failed, at a load average of 2.7; check 112
(`briefing-cost`), which failed twice earlier in the sprint on a loaded machine (0.54 s and
0.57 s against 0.5, read and not run again), passed. Line 3: the sprint wrote and changed no
grader; `sh scripts/grader-check.sh` 37 as expected, 0 not. Line 4: `spec-check.sh .` exit 0, 37
specs, 0 gaps; this spec reads tested=26, waived=9, uncited=0. Line 5: the three always-on rules,
2,999 of 3,000 bytes. Line 6: the evals folder, 204,629 of 204,800 bytes, as at the sprint's
start (the prune cut no case). Line 7, the plan's §0 rows this sprint owns: paid model runs, 0;
"a way for the gate to run the change", `verify-run.sh` and a `verify` skill for two stacks, not
three (the intake's answer 1: Rails waits for Sprint 35, with setup's count and checks 67 and 69);
"a commit stamped with how it was verified", the gate that reads the stamp exists, off, and the
commit skill's text that writes it waits for Sprint 35 (rule 34); the three always-on rules,
unchanged; eval cases, 78, none cut; smoke checks, 1 to 133 less 2b (136, 15 of them model
checks), the prune's one cut. Line 8: `release-check.sh .` 31 shipped, 5 findings, the five
`NO-REPORT` lines of the sprint's start. Line 9: `uv run --with hypothesis==6.170.16 python3
scripts/prop.py` exit 0, five properties hold on forty inputs each. Line 10: no existing skill,
agent, rule or overlay file changed or removed since `main`. Beside the ten:
`decision-check.sh . --run` 190 decisions, 0 fired, 0 errors; `checks-match.sh . main` exit 0,
no line.

## After the gate

T-MERGE: the plan's exit checklist (ten lines, plan §1), its results written under this file's
"The sprint's exit checklist", then a merge commit to `main`, untagged, each step on the owner's
yes (push, pull request, merge).
