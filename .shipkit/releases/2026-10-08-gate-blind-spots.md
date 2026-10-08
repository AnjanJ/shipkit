READY

# Ship report: gate-blind-spots

> Checked on 2026-10-08 at commit `652a0e0` on `sprint-12/gate-blind-spots`, against base `e0ba01a` (merge-base with `main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked line (exit 1) |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 4 live decisions, reversal conditions concrete |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | 0 fired, 2 hold, 25 manual, 0 errors |

Requirements: 10 (6 waived as `[untested]`).

The spec's `> Status:` line was not changed, as the request said. It is still `open`.

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . gate-blind-spots --as-shipped` → exit 0
```
WAIVED gate-blind-spots REQ-3
WAIVED gate-blind-spots REQ-4
WAIVED gate-blind-spots REQ-5
WAIVED gate-blind-spots REQ-8
WAIVED gate-blind-spots REQ-9
WAIVED gate-blind-spots REQ-10
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`( bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh . ) > shipkit-ship-tests.out 2>&1` → exit 0
```
WAIVED spec-contract REQ-19
WAIVED spec-contract REQ-20
WAIVED spec-contract REQ-24
WAIVED spec-contract REQ-25
WAIVED spec-contract REQ-26
WAIVED trim-and-docs REQ-1
WAIVED trim-and-docs REQ-2
WAIVED trim-and-docs REQ-3
WAIVED trim-and-docs REQ-8
WAIVED trim-and-docs REQ-14
WAIVED trim-and-docs REQ-15
WAIVED trim-and-docs REQ-16
WAIVED unsetup-safety REQ-6
WAIVED unsetup-safety REQ-8
WAIVED unsetup-safety REQ-9
WAIVED unsetup-safety REQ-10
WAIVED unsetup-safety REQ-11
WAIVED unsetup-safety REQ-12
WAIVED unsetup-safety REQ-13
spec-check: 14 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/gate-blind-spots/tasks.md` → exit 1
no line found

### 4. Independent review
## Review: gate-blind-spots against e0ba01a151da6b7d003e8d12e9d2723f22807d3d

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `plugins/shipkit/scripts/decision-check.sh:81` (the `sub(/[ \t]*<!--.*-->[ \t]*$/ …)` strip), test `scripts/smoke.sh` check 52, the "With comment" and "Manual with comment" records. It cites `gate-blind-spots/REQ-1`. |
| REQ-2 | MET | code `plugins/shipkit/scripts/decision-check.sh:114` (the `ERROR … (exit $rc): <first stderr line>` echo, with stderr kept at line 109), test `scripts/smoke.sh` check 52 (asserts `(exit 2): .*health_report\.rb.*No such file`). It cites REQ-2. |
| REQ-3 (waived) | MET | `plugins/shipkit/skills/spec/SKILL.md:92-95` runs `decision-check.sh . --run` and treats `FIRED` or `ERROR` on a record it just wrote as a defect. Check 52 also greps for the wording. |
| REQ-4 (waived) | MET | `plugins/shipkit/skills/spec/reference.md:88` says "The command must exit 1 on the tree the record is written against". It sits in the `Fired-if` section. |
| REQ-5 (waived) | MET | `plugins/shipkit/agents/reviewer.md:42-46` excludes everything under `.shipkit/` except `.shipkit/specs/<other>/`. Check 53 greps the wording. |
| REQ-6 | MET | code `plugins/shipkit/scripts/brief-verify.sh:57`, which allows anything under `.shipkit/` except `.shipkit/specs/` paths outside the spec's own folder. Test `scripts/smoke.sh` check 53, first case: `product.md`, a release report, `state.md`, a decision record and the spec's own `design.md` give exit 0 and no `OUTSIDE`. It cites REQ-6. |
| REQ-7 | MET | code `plugins/shipkit/scripts/brief-verify.sh:57`, test `scripts/smoke.sh` check 53, second case: `.shipkit/specs/other/spec.md` gives exactly one `OUTSIDE` line and exit 1. It cites REQ-7. The Files-line exception is covered by the generic Files matching in the same script. Check 25b also uses another spec's `spec.md`. |
| REQ-8 (waived) | MET | `plugins/shipkit/skills/ship/SKILL.md:41-58`. Steps 1, 2, 3 and 8 each end `; echo "exit $?"`, and a note says never to infer the code. Steps 5, 6 and 7 are not commands, as the requirement says. `plugins/shipkit/skills/ship/reference.md:33-59` carries `→ exit N` in the template. |
| REQ-9 (waived) | MET | `plugins/shipkit/skills/ship/reference.md:68-70` says output blocks are pasted from the command's captured output and never typed from memory. The template blocks say "pasted". `plugins/shipkit/skills/ship/SKILL.md:54-58` says the same. |
| REQ-10 (waived) | MET | `plugins/shipkit/scripts/brief-verify.sh:14-20` says ignored files are not seen, by design, and that the task's Done-when output is where a build artifact shows. It cites C6. `ROADMAP.md` marks the question closed by record. |

I read the dry-run evidence for REQ-8 and REQ-9 only as the spec describes it. The report was deleted by design, so I did not check it.

## Changes beyond the spec
None. Every changed file is under the spec's `Paths` or under `.shipkit/gate-blind-spots/`. That covers `scripts/smoke.sh`, `ROADMAP.md`, `CHANGELOG.md`, `.claude-plugin/marketplace.json` and both `plugin.json` files.

## Decisions not followed
None. I checked the four non-superseded decisions against the code:
- The trailing HTML comment is stripped, not rejected.
- `.shipkit/` is allowed in the script and the reviewer, with another spec's folder still caught.
- Exit codes are echoed on the command line, and output goes to files under `${TMPDIR:-/tmp}/shipkit-ship-<step>.out`.
- Ignored files are closed by record, with a header sentence only.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 10 MET, 0 NOT MET, 0 CANNOT TELL (6 waived).
VERDICT: PASS

### 5. Migration rollback
`git diff e0ba01a...HEAD --name-only` lists 17 files; none is under `db/migrate/`, `migrations/`, `alembic/` or a `*.sql` (grep exit 1). No migration in the diff.

### 6. Decisions
Four live decisions in `design.md`, none superseded:
- A trailing HTML comment is stripped, not rejected: "We would move to (2) if a `Fired-if` command is found cut short by the strip in any real or eval run."
- Everything under `.shipkit/` is allowed, except another spec's folder: "We would move to (2) if an agent is observed writing a file under `.shipkit/` (outside any spec folder) that a task did not ask for, in any real or eval run."
- Exit codes are echoed on the command line, output is read from a file: "We would move to (2) or add a script if a ship report after 4.5.0 is found to say an exit code was not captured, or to carry evidence that differs from the command's output on the same tree."
- Ignored files are invisible to `brief-verify.sh`, by design: "We would build (2) if an agent is observed, in a real run, writing a file into an ignored path that the task's Done-when did not catch."

Each is an observable event, so each is concrete.

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty

The gate's own runs left no new files; `git status --porcelain` was still empty after step 8.

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run` → exit 0

Lines from `shipkit-ship-decisions.out`:
- `HOLDS .shipkit/decisions/0003-overlay-skills-home.md: test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2`
- `HOLDS .shipkit/specs/real-run/design.md (The stack overlay skills stay in core): same command`
- 25 `MANUAL` lines: decision 0002 and the `gate-blind-spots`, `map-on-trial`, `real-run`, `rule-evals`, `run-wounds` and `trim-and-docs` design records. Each holds a reversal condition for a person to judge. None is a `FIRED` or `ERROR` line.

```
decision-check: 27 decision(s), 0 fired, 2 hold, 25 manual, 0 error(s)
```
