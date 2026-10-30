# Intake: What every session pays (Sprint 20)

> Intake taken on 2026-10-30, by hand from the approved thinning plan.

## Request
Make the always-on surface earn its place: measure it with a script, inject the loop's two
rules only where a project opted in, measure the Care lines, cut seventeen core skills to ten
and seven agents to four (`docs/plans/thinning-sprint-plan.md`, Sprint 20, W1–W4, W10).

## Serves goal
The plan's §0 table: a session on a project that never opted in pays ≤ 1,900 bytes of hook
output (≤ 120 if W2's clause fires), ≤ 2,400 bytes of core skill descriptions, ≤ 1,000 of agent
descriptions.

## Conflicts found
- `.shipkit/decisions/0001-project-map-default.md` (the map is optional): W4 moves the
  archivist into the `map` skill's forked body for that reason — consistent.
- `.shipkit/decisions/0003-overlay-skills-home.md` (overlay skills stay in core): untouched by
  this sprint; Sprint 21's W6/W8 amend it with 0004.
- `.shipkit/specs/run-debts/design.md`, "The leaked wait sentence is closed by record": not
  this sprint (W14, Sprint 22).
- Open specs: none (`third-run` shipped 2026-10-30).

## Answers
1. Which skills merge where? — As W3: `walkthrough`, `explain-system` → `ask --walk`,
   `ask --system`; `unsetup`, `update-rules`, `context-audit`, `connect-memory` → `setup
   remove | rules | audit | memory`; `commit` → `shipkit-workflows`. (The owner's approval of
   the plan, 2026-10-30.)
2. Does `shipkit.md` go opt-in too? — Only by W2's number, after the owner sees the table.
3. What about the two words of `shipkit.md` that name renamed skills? — They follow the
   rename in T4 (plan §5, amended); the budget stays under 3,000.
4. Which eval groups are the watch? — `rules` (T2, T3), `grandfather` (T5), `hello`.

## Assumptions made
- `--ablation with-without` gives a plugin-off arm where the hook does not run (plan §3,
  checked in T1/T3).
- A merged skill's `TRIGGER when:` lines still auto-invoke (checked by four probes in T4).
- The built-in `Explore` agent is callable from a plugin skill headless; a `context: fork`
  skill can branch on its argument (checked in T5; fallbacks in the plan).

## Out of scope
Overlay skills, appends and `eve` (Sprint 21); the run again and 5.0.0 (Sprint 22); any
grader; any line of the three always-on rules' text beyond the two renamed skill names.
