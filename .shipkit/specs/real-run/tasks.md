# Tasks: Loose ends and a real run (Sprint 10)

One commit per task, test and code together. The steps for each task are in
`docs/plans/evidence-sprint-plan.md` under the same task number (S10-T1 to S10-T5), as amended
by the intake beside this file (T1's remedy, T2's Rails count, B11's branch count). **T3 needs
the owner to name the repository first and changes nothing under `plugins/`. T4 asks one yes
per row.**

- [x] **T1** Show the citation debt before the gate (S10-T1) → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5
  - Files: plugins/shipkit/scripts/spec-check.sh, scripts/smoke.sh, plugins/shipkit/skills/ship/SKILL.md, .shipkit/specs/real-run/spec.md (added with the owner's yes on 2026-10-07: REQ-5's branch-not-taken note lives there)
  - Test: scripts/smoke.sh check 48 "pending-test" (an open spec with one uncited requirement, one excused and one cited: the plain run prints `PENDING-TEST demo REQ-1`, `WAIVED demo REQ-2`, nothing for REQ-3, exits 0; with a slug and `--as-shipped` it prints `MISSING-TEST demo REQ-1` and exits 1; a shipped spec prints no PENDING line) — written first, red; check 19 still passes
  - After: none
  - Done when: the Check first is run in a scratch worktree at `ceef7f5^` (plain run and `--as-shipped`, both outputs in the commit message) and the worktree is removed; check 48 → PASS; check 19 → PASS; `sh -n plugins/shipkit/scripts/spec-check.sh` clean; `sh plugins/shipkit/scripts/spec-check.sh .` → 0 gaps on this repository; `bash scripts/lint.sh` → 0/0
- [x] **T2** Where the overlay skills live, decision 0003 (S10-T2) → REQ-6, REQ-7, REQ-8
  - Files: .shipkit/decisions/0003-overlay-skills-home.md, docs/design/two-plugin-split.md, ROADMAP.md
  - Test: reading — the record has Context, Alternatives (3), Case for, Case against, Decision, a countable clause and a `Fired-if` line; `sh plugins/shipkit/scripts/decision-check.sh . --run` prints `HOLDS` for 0003; §5 item 6 says "settled, see 0003"; `grep -n 'From 3.0' ROADMAP.md` finds nothing
  - After: none
  - Done when: the three readings above hold; `bash scripts/lint.sh` → 0/0
- [ ] **T3** The real run (S10-T3) → REQ-9, REQ-10, REQ-11
  - Files: docs/design/field-notes-4.3.md, ROADMAP.md, GUIDE.md
  - Test: reading — the notes have a section for the cache update and each of the nine steps, each with the six fields and an evidence line; every awkwardness is a one-line candidate under "Still open after Sprint 10" naming its section; REQ-11's branch is marked when the condition did not hold
  - After: T1, T2
  - Done when: the readings hold; `git diff --stat main -- plugins/` shows nothing from this task; nothing in the named repository was merged; `bash scripts/lint.sh` → 0/0
- [ ] **T4** Housekeeping the owner approved, B11 to B13 (S10-T4) → REQ-12
  - Files: ROADMAP.md
  - Test: reading — for each approved row, ROADMAP records what was removed and when; the command outputs are in the commit message
  - After: T3
  - Done when: `git branch --list 'sprint-*'` and `git ls-remote --heads origin 'sprint-*'` list only sprint-8, sprint-9 and sprint-10 (if B11 approved); `git worktree list` shows one line (if B13); `ls -d /private/tmp/e-*` matches nothing (if B12); any row not approved is recorded as kept
- [ ] **T5** Update the roadmap (S10-T5) → REQ-13, REQ-14
  - Files: ROADMAP.md
  - Test: reading — Sprints 8 to 10 marked shipped with 4.1.0, 4.2.0, 4.3.0; the evidence-plan heading no longer says "Sprints 9 and 10 next"; every "Still open after Sprint 10" item names its evidence; the north-star paragraph is unchanged or the change is explained
  - After: T4
  - Done when: `bash scripts/lint.sh` → 0/0 (the status line, check 16); the readings hold

## After the gate

- **Ship:** run `/shipkit:ship real-run` on this branch and fix what it finds; the report
  starts with `READY` and is committed.
- **Release 4.3.0:** version in five places, changelog with "What using it for real showed"
  (the field notes' three sharpest awkwardnesses), counts, the sprint exit checklist, pull
  request with "What was awkward", merge after a green check, tag `v4.3.0`.
