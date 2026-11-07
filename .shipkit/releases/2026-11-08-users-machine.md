READY

# Ship report: users-machine

> Checked on 2026-11-08 at commit `b60377d` on `sprint-28/fifth-run`, against base `9b32e36`.

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0, 0 gaps |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked line found (exit 1) |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 6 decisions, each reversal condition concrete |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | 0 fired, 5 hold, 124 manual, 0 error |

Requirements: 11 (3 waived as `[untested]`: REQ-9, REQ-10, REQ-11).

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . users-machine --as-shipped` → exit 0
```
WAIVED users-machine REQ-9
WAIVED users-machine REQ-10
WAIVED users-machine REQ-11
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`( bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh . )` → exit 0
```
.......
----------------------------------------------------------------------
Ran 7 tests in 0.003s

OK
```

### 3. Tasks ticked
`git grep -n --untracked '^- \[ \]' .shipkit/specs/users-machine/tasks.md` → exit 1
no line found

### 4. Independent review
## Review: users-machine against 9b32e36

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `plugins/shipkit/skills/setup/SKILL.md:137-142`; test `scripts/smoke.sh:2975-3017` (check 90, cites `users-machine/REQ-1`). The check asserts the setup text only, not setup's behaviour, which is a prose skill. |
| REQ-2 | MET | code `plugins/shipkit/skills/setup/SKILL.md:142` ("Otherwise write the test command as detected"); test `scripts/smoke.sh:2981-2990` (check 90 asserts that phrase, cites `REQ-2`) |
| REQ-3 | MET | code `plugins/shipkit/stacks/elixir/CLAUDE.md.append:22-23` and `plugins/shipkit/stacks/go/CLAUDE.md.append:19`; test `scripts/smoke.sh:2991-3010`. It checks the exit 2 naming `TEST_COMMAND`, both elixir lines, no bare `mix test`, and go's run-all line. |
| REQ-4 | MET | code `plugins/shipkit/agents/reviewer.md:29-31`; test `scripts/smoke.sh:3019-3040` (check 91, cites `REQ-4`) |
| REQ-5 | MET | code `plugins/shipkit/skills/ship/SKILL.md:45` and the Searches note at `:60-63`; test `scripts/smoke.sh:3029-3044`. It runs step 3's command on an untracked `tasks.md`: exit 0 with an unticked line, exit 1 when all are ticked. |
| REQ-6 | MET | files `plugins/shipkit/agents/reviewer.md`, `plugins/shipkit/skills/ship/SKILL.md` and `plugins/shipkit/skills/ship/reference.md:40`; test `scripts/smoke.sh:3045-3055`. It scans all three for a bare search command and for `\|` in a code span. |
| REQ-7 | MET | code `scripts/wait-probe.sh` (`--scaffold` and `--run`; default of five not individually read); test `scripts/smoke.sh:3061-3085` (check 92). The check asserts 8 to 16 tracked files, a clean commit and no model call. |
| REQ-8 | MET | code `scripts/wait-probe.sh` (`--read`); test `scripts/smoke.sh:3125-3133`. The two stored transcripts give 240 s / 2 Monitor / 1 sleep and 5 s / 0 / 0, with a fake `claude` on the PATH proving no model call. |
| REQ-9 (waived) | MET | `docs/design/eval-results-5.2.md:36-42`: five rows, no empty cell (wall, idle, Monitor, sleep, cost) |
| REQ-10 (waived) | MET | The bar was not met: the five runs idled 6 to 24 s. `ROADMAP.md:172` names the wait as the platform's and cites `docs/design/eval-results-5.2.md` §1. `ROADMAP.md:47` also records that no skill says anything about waiting. The intake and ask skills are unchanged in the diff, as the otherwise branch requires. |
| REQ-11 (waived) | MET | `.shipkit/decisions/0005-evals-home.md`: Context, Alternatives, Case for, Case against and Decision are all present. It cites the loading and plugin-evals pages, and its reversal condition is an event (docs or `--help` naming a way to leave a path out). `ROADMAP.md:168` points to it. |

## Changes beyond the spec
- `.claude-plugin/marketplace.json`
- `GUIDE.md`
- `README.md`
- `docs/design/field-notes-5.2.md`
- `plugins/shipkit/.claude-plugin/plugin.json`
- `plugins/shipkit-workflows/.claude-plugin/plugin.json`
- `.shipkit/specs/fifth-run/spec.md`, `.shipkit/specs/fifth-run/design.md` and `.shipkit/specs/fifth-run/tasks.md` (another spec's folder)
- `.shipkit/specs/gate-on-setup/spec.md` (another spec's folder)

## Decisions not followed
None.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 11 MET, 0 NOT MET, 0 CANNOT TELL (3 waived).
VERDICT: PASS

### 5. Migration rollback
no migration in the diff (`git diff 9b32e36...HEAD --name-only` lists no file under `db/migrate/`, `migrations/`, `priv/repo/migrations/`, `alembic/`, `prisma/migrations/`, and no `*.sql`).

### 6. Decisions
Six live decisions in `.shipkit/specs/users-machine/design.md`, none superseded:
- `mise exec --` goes before the program, only when the project pins with mise: "We would revert to (2) if S27-T1's Check first, `MIX_ENV=test mise exec -- mix test` in a headless `claude -p` Bash call on an `office_bestie` worktree, does not run the suite; or if a real run's setup on a pinned project writes a command its own gate's step 2 cannot run."
- The elixir and go sections take the test command setup detected: "We would take (2) if a real run's `CLAUDE.md` names two different test commands again, from any stack."
- The gate searches with `git grep`, and step 3 reads an untracked `tasks.md`: "We would revisit if a gate's reviewer marks a requirement NOT MET, or a step reads PASS, on a search that printed nothing for a line `git grep -n` finds at the same commit."
- The wait is counted from the session's own transcript: "We would count by (2) if, on any of the five runs, the transcript's last entry and the process's exit differ by more than 10 s."
- The fixture is scaffolded by the script, small enough for research under a minute: "We would move to (3) if none of the five runs starts `grandfather` in the background …"
- A sentence goes in only if 2 of 5 runs idle over 60 s, and stays only if the number moves: "We would take (3) if the five runs show a wait over 60 s exactly once and a real headless run in Sprint 28 shows it again."

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run` → exit 0
```
decision-check: 0 decision(s), 0 fired, 0 hold, 0 manual, 0 error(s)
```
