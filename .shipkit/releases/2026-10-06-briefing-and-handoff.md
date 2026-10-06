READY

# Ship report: briefing-and-handoff

> Checked on 2026-10-06 at commit `51b42bb` on `sprint-5/briefing-and-handoff`, against base `ef84b16`.

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | PASS | exit 0 |
| 2 | Tests | PASS | `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0 |
| 3 | Tasks ticked | PASS | no line found |
| 4 | Independent review | PASS | VERDICT: PASS |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 3 decisions, reversal conditions concrete |
| 7 | Clean tree | PASS | nothing uncommitted |

Requirements: 16 (4 waived as `[untested]`).

## Evidence

### 1. Spec check, as shipped
`sh <plugin root>/scripts/spec-check.sh . briefing-and-handoff --as-shipped` → exit 0
```
WAIVED briefing-and-handoff REQ-11
WAIVED briefing-and-handoff REQ-12
WAIVED briefing-and-handoff REQ-13
WAIVED briefing-and-handoff REQ-16
spec-check: 1 spec(s) checked, 0 gap(s)
```

### 2. Tests
`bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .` → exit 0
```
WAIVED review-and-ship REQ-5
WAIVED review-and-ship REQ-8
WAIVED review-and-ship REQ-10
WAIVED review-and-ship REQ-11
WAIVED review-and-ship REQ-15
WAIVED review-and-ship REQ-18
WAIVED spec-contract REQ-5
WAIVED spec-contract REQ-19
WAIVED spec-contract REQ-20
WAIVED spec-contract REQ-24
WAIVED spec-contract REQ-25
WAIVED spec-contract REQ-26
WAIVED unsetup-safety REQ-6
WAIVED unsetup-safety REQ-8
WAIVED unsetup-safety REQ-9
WAIVED unsetup-safety REQ-10
WAIVED unsetup-safety REQ-11
WAIVED unsetup-safety REQ-12
WAIVED unsetup-safety REQ-13
spec-check: 7 spec(s) checked, 0 gap(s)
```

### 3. Tasks ticked
`grep -n '^- \[ \]' .shipkit/specs/briefing-and-handoff/tasks.md`
no line found

### 4. Independent review
## Review: briefing-and-handoff against ef84b169de8bec1a0d4d9dd598d3da3fa3644b08

I did not run the tests. I read the spec, design and diff.

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `plugins/shipkit/scripts/briefing.sh:81-85` (awk caps 8 lines and 800 bytes), test `scripts/smoke.sh:1077` (50 specs) |
| REQ-2 | MET | code `briefing.sh:25-51`, test `scripts/smoke.sh:1055-1065` (check 30b, alpha and beta lines) |
| REQ-3 | MET | code `briefing.sh:54-60`, test `scripts/smoke.sh:1069` (gap line) and the "no spec-check:" negative check in 30b |
| REQ-4 | MET | code `briefing.sh:63-66`, test `scripts/smoke.sh` 30b (top goal line) |
| REQ-5 | MET | code `briefing.sh:69-80`, test `scripts/smoke.sh` 30b ("last handoff (2026-10-01, 2 commits ago)") |
| REQ-6 | MET | code `briefing.sh:17`, test `scripts/smoke.sh:1043` |
| REQ-7 | MET | code `briefing.sh:86` (`exit 0`) and the `2>/dev/null` redirects, test `scripts/smoke.sh:1086` (random-bytes tasks.md, empty stderr) |
| REQ-8 | MET | code `spec-check.sh` single-awk change (`spec_reqs`), test `scripts/smoke.sh:1077` (checks under 1s with 50 specs) |
| REQ-9 | MET | code `session-start.sh:26-30, 135, 265` (`briefing` is the last call on every path), test `scripts/smoke.sh:1093` |
| REQ-10 | MET | code `plugins/shipkit/skills/handoff/SKILL.md:29-56`, test `scripts/smoke.sh:1098-1128` (check 31) |
| REQ-11 (waived) | MET | `plugins/shipkit/skills/handoff/SKILL.md:2` (TRIGGER: wrapping up or pausing with unfinished spec work or uncommitted changes; DO NOT TRIGGER: trivial work) |
| REQ-12 (waived) | MET | `plugins/shipkit/skills/handoff/SKILL.md:21-27` (gathers from the session and git; asks only if the next step is unclear) |
| REQ-13 (waived) | MET | `plugins/shipkit/skills/setup/SKILL.md` Step 3 (diff adds `.shipkit/state.md` to the list of lines to offer) |
| REQ-14 | MET | code: briefing quotes the Next step line (`briefing.sh:72-78`), test `scripts/smoke.sh:1130-1143` (check 32, haiku session) |
| REQ-15 | MET | code `session-start.sh:54-57, 67`, test `scripts/smoke.sh:1145-1155` (compact prints the line; startup and no input do not) |
| REQ-16 (waived) | MET | `CHANGELOG.md` 3.6.0 entry: a reminder before compaction was not built, because `PreCompact` output does not reach the model while `SessionStart` with `source: "compact"` does |

Notes on the evidence:
- The tests cite the requirements in comments as `briefing-and-handoff/REQ-N`. Check 30 cites REQ-1 to REQ-9, check 31 cites REQ-10, check 32 cites REQ-14, and check 33 cites REQ-15.
- REQ-10: the smoke test does not check that an earlier `state.md` is replaced. The skill's "replace, never append" rule covers that part. This is a small gap in the test and does not change the verdict.
- REQ-5: the "commits ago" count is omitted when the handoff sha is not in the repository. The spec does not say what to do in that case.

## Changes beyond the spec
Changed files outside the spec's `> Paths:` line and outside `.shipkit/specs/briefing-and-handoff/`:
- `CHANGELOG.md`
- `README.md`
- `plugins/shipkit/.claude-plugin/plugin.json`
- `plugins/shipkit-workflows/.claude-plugin/plugin.json`

All four look like 3.6.0 release housekeeping. `plugins/shipkit/hooks/hooks.json` is listed in Paths but was not changed.

## Decisions not followed
None. I checked all three non-superseded decisions:
- `state.md` is git-ignored by default: the setup skill offers it.
- A briefing, not a team of agents at session start: `briefing.sh` uses no model, and the byte limit is enforced by the smoke check at `scripts/smoke.sh:1077`.
- The compaction reminder fires after compaction: `session-start.sh:67`.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 16 MET, 0 NOT MET, 0 CANNOT TELL (4 waived).
VERDICT: PASS

### 5. Migration rollback
no migration in the diff (`git diff ef84b16...HEAD --name-only` lists no file under a migrations path and no `*.sql`)

### 6. Decisions
- `state.md` is git-ignored by default: "reverse … if the owner works on the same project from a second machine during this plan and loses a handoff to it, or if a user reports the same."
- A briefing, not a standing team of agents at session start: "reverse … if, in two sprints of this plan, the owner records that the briefing led the session to start on the wrong task because of what the eight lines left out."
- The compaction reminder fires after compaction, not before: "reverse … if a later Claude Code release lets a `PreCompact` hook put text in front of the model."

### 7. Clean tree
`git status --porcelain`, captured before step 1
empty
The test run left no new files behind (`git status --porcelain` was still empty afterwards).
