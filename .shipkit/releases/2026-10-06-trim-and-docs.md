READY

# Ship report: trim-and-docs

> Checked on 2026-10-06 at commit `ceef7f5` on `sprint-7/trim-and-docs`, against base `568338e` (merge-base with `main`).

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no unticked task |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 3 decisions, reversal conditions concrete |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | 3 Fired-if entries, all MANUAL, none FIRED |

Requirements: 17 (7 waived as `[untested]`).

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . trim-and-docs --as-shipped` → exit 0
```
WAIVED trim-and-docs REQ-1
WAIVED trim-and-docs REQ-2
WAIVED trim-and-docs REQ-3
WAIVED trim-and-docs REQ-8
WAIVED trim-and-docs REQ-14
WAIVED trim-and-docs REQ-15
WAIVED trim-and-docs REQ-16
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0
```
lint: 0 error(s), 0 warning(s) across 34 skills, 7 agents, 21 rules
...
WAIVED unsetup-safety REQ-10
WAIVED unsetup-safety REQ-11
WAIVED unsetup-safety REQ-12
WAIVED unsetup-safety REQ-13
spec-check: 9 spec(s) checked, 0 gap(s)
```
(The first run's output was cut at its last 20 lines. A second run, redirected to a file, gave exit 0.)

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/trim-and-docs/tasks.md`
no line found

### 4. Independent review
## Review: trim-and-docs against 568338e10f1ec76f10452a449afd4f8d89b692c2

I did not run the tests. I did run `scripts/lint.py` once, and it reported 0 errors and 0 warnings.

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 (waived) | MET | `docs/design/trim-audit-4.0.md:30-90`. The tables hold 6 path-scoped rules, 16 stack rules, 7 workflow skills (including the knowledge base) and the map row, each with lines, bytes, verdict and reason. |
| REQ-2 (waived) | MET | `docs/design/trim-audit-4.0.md:9-20` states criteria (a), (b) and (c). Line 16 says "(c) is not measured for any row", and lines 114-115 repeat it. |
| REQ-3 (waived) | MET | `docs/design/trim-audit-4.0.md:82` cites decision 0001 and says the re-test has not been run. |
| REQ-4 | MET | Code: the longest stack rules are `hotwire.md` and `liveview.md` at 40 lines each. Test: `scripts/lint.py:502-510` (section 14 cites REQ-4). |
| REQ-5 | MET | Code: the 14 skill SKILL.md files in the diff were shortened. Test: `scripts/lint.py:503,512-517` (section 14 cites REQ-5). I did not measure each description by hand, but the lint passes. |
| REQ-6 | MET | Code and test: `scripts/lint.py:502-517` raises an `err` for a stack rule over 40 lines or a description over 300 characters. |
| REQ-7 | MET | Code: the three always-on rules total 535 + 1722 + 739 = 2,996 bytes. Test: `scripts/lint.py:358-381` (check 8a), whose comment at line 364 cites trim-and-docs/REQ-7. |
| REQ-8 (waived) | MET | `docs/design/trim-audit-4.0.md:98-110` records the owner's yes on each of the five cuts. `CHANGELOG.md` 4.0.0 "Removed" lists each removed item with what to use instead. The files are gone: `security.md` and the `code-review-standards` skill are absent, as are the elixir, go and python convention rules. |
| REQ-9 | MET | Code: no bare `mktemp` remains in `plugins/shipkit/scripts/`. The grep output printed the command name as `n`, which looks like display rewriting. The lines carry the `${TMPDIR:-/tmp}/shipkit.XXXXXX` template. Test: `scripts/lint.py:519-525` fails on a bare `mktemp`. |
| REQ-10 | MET | Code: `README.md` has no version-history text above `## Install` (line 25). Test: `scripts/lint.py:540-547`. |
| REQ-11 | MET | Code: the `README.md` loop table has nine rows, each with a command. Test: `scripts/lint.py:548-558`. |
| REQ-12 | MET | Code: `README.md` names only existing skills. Test: `scripts/lint.py:559-563`. |
| REQ-13 | MET | Code: `README.md` is 173 lines. Test: `scripts/lint.py:533-539`. |
| REQ-14 (waived) | MET | `README.md:14-20` keeps the "What 'verified' means here" paragraph. |
| REQ-15 (waived) | MET | `GUIDE.md:1115` is Playbook 4. Steps 1-9 each appear with a command and the file written. Steps 4-9 are at about `GUIDE.md:1199-1295`. It uses the refunds feature on the eval fixture, with real output including a NOT READY and OUTSIDE lines. |
| REQ-16 (waived) | MET | `ROADMAP.md:7-9` is the one-sentence north star. `ROADMAP.md:19-30` marks Sprints 1-7 shipped with versions. The open items are listed after the table. |
| REQ-17 | MET | Code: `ROADMAP.md:15` says "v4.0.0". Test: `scripts/lint.py:565-577`. |

Where the spec says tests should cite `<slug>/REQ-N`, the checks are lint checks. The citations are in `scripts/lint.py` comments, so the citation format is satisfied.

## Changes beyond the spec
None. Every changed file is under the spec's `> Paths:` or inside `.shipkit/specs/trim-and-docs/`. `plugins/shipkit/skills/*`, `stacks/*/.claude/skills/code-review-standards-rails/SKILL.md` and `scripts/smoke.sh` fall under the listed `skills/`, `stacks/` and `scripts/` paths.

## Decisions not followed
None.
- Decision 1 (checks live in the lint): the checks are in `scripts/lint.py`.
- Decision 2 (criterion (c) counts only where an eval exists): the audit marks (c) as not measured.
- Decision 3 (the map row waits for decision 0001's re-test): the map row is carried as "keep — pending re-test", and nothing about the map changed.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 17 MET, 0 NOT MET, 0 CANNOT TELL (7 waived).
VERDICT: PASS

### 5. Migration rollback
`git diff 568338e...HEAD --name-only` lists no file under `db/migrate/`, `migrations/`, `priv/repo/migrations/`, `alembic/`, `prisma/migrations/`, and no `*.sql`. No migration in the diff.

### 6. Decisions
- "The repository's own document checks live in the lint, not in smoke or by hand": reverse "if a documentation-only pull request is blocked by one of these lint checks for a reason that is not a real defect in the document, twice."
- "Criterion (c) counts only where an eval exists": reverse "if a line trimmed on (a)/(b) alone is restored within two releases because a regression was traced to it."
- "The map row waits for decision 0001's re-test": reverse "if the owner waives the condition in writing on the audit row."

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty
The test run left no new files (`git status --porcelain` was empty afterward too).

### 8. Decisions fired
`sh <plugin root>/scripts/decision-check.sh . --run` → exit 0
```
MANUAL .shipkit/specs/trim-and-docs/design.md (The repository's own document checks live in the lint, not in smoke or by hand): We would reverse this — move the checks to a release-time script — if a documentation-only pull request is blocked by one of these lint checks for a reason that is not a real defect in the document, twice.
MANUAL .shipkit/specs/trim-and-docs/design.md (Criterion (c) counts only where an eval exists): We would reverse this — write the eval cases first — if a line trimmed on (a)/(b) alone is restored within two releases because a regression was traced to it.
MANUAL .shipkit/specs/trim-and-docs/design.md (The map row waits for decision 0001's re-test): We would reverse this — act on the record without the re-test — if the owner waives the condition in writing on the audit row.
decision-check: 3 decision(s), 0 fired, 0 hold, 3 manual, 0 error(s)
```
