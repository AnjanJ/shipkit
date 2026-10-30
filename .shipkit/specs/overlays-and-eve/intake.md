# Intake: What a set-up project pays (Sprint 21)

> Intake taken on 2026-10-30, by hand from the approved thinning plan.

## Request
A project that ran `/shipkit:setup` pays for its stack's traps and nothing else; `eve` pays for
what her cases show she uses (`docs/plans/thinning-sprint-plan.md`, Sprint 21, W6–W9).

## Serves goal
The plan's §0 table: overlay skills 0 by default on a set-up project (today a Rails project
carries six, 17,529 bytes, six listings every session); the appends audited line by line;
`agents/eve.md` ≤ 11,500 bytes per call if the audit's arm holds (17,010 today).

## Conflicts found
- `.shipkit/decisions/0003-overlay-skills-home.md` (2026-10-07: the overlay skills stay in
  core): W6 and W8 amend it — the skills stay in core but install on a flag, and duplicates
  are cut; a new record 0004 says so and 0003 is marked amended, not deleted (the decisions
  rule).
- `docs/design/trim-audit-eve.md` (PR #21): W9 runs the audit's arm as written; its clause
  decides. No conflict.
- `.shipkit/specs/always-on/` (Sprint 20, open until 5.0.0): shares `scripts/smoke.sh`,
  `GUIDE.md`, `CHANGELOG.md`; no requirement overlaps.
- No other open spec.

## Answers
1. Default install of an overlay: rules and the `CLAUDE.md` section; skills only on a flag?
   — Yes, W6's default (the owner's approval of the plan, 2026-10-30).
2. Which overlay skills are cut as duplicates? — Decided per skill at T3's STOP, on the
   side-by-side the audit shows; the candidates the plan names: `release` and `deploy-check`
   against `ship`, `new-feature` against `spec`, `code-review-standards-rails` against
   `reviewer`, `safety-check` against `shipkit.md`'s Care lines.
3. Does the append audit run an eval? — No (W7): no case installs an append; the 4.0 rule and
   the owner's word per row decide, the python finding first.
4. Does `eve`'s trim change her measured sentence or step 0? — No (the audit's own scope).

## Assumptions made
- `install-stack.sh` can take `--with-skills` before its positional arguments without
  changing the contract `<plugin-root> <stack> [project-dir] KEY=value …` (plan §3; checked
  in T1; the fallback is an environment variable the setup skill sets).
- The five `eve` cases at their 4.12.0 counts (3 of 3 each; `digest/attention` 3 of 3 in the
  4.12.0 release run) are the watch for W9.

## Out of scope
The always-on surface (Sprint 20, shipped untagged); the run again and 5.0.0 (Sprint 22);
`agents/grandfather.md`; step 4's measured sentence and step 0's triage in `eve.md`; the
digest shape; any grader; a new case for the matrix or consolidation shapes.
