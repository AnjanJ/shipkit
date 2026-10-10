# Intake: Eve's portfolio and a second project

> Intake taken on 2026-10-10.

## Request
Sprint 16 of the portfolio plan (`docs/plans/portfolio-sprint-plan.md`), the plan's last: give
the two things that still have no number theirs. A generated three-project fixture and three
`eve` cases run under three arms (three maps, one, none) measure what `eve` loses when fewer
projects carry a map; shipkit's loop run end to end on a second real repository of another
stack, with nothing found fixed, measures what the three releases since the first run changed;
then the roadmap the plan after starts from. Release 4.9.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; no product file.
- **Open specs:** none; all seventeen specs are `Status: shipped`. `second-traps` (4.6.0) named
  `eve`'s loss as unmeasured under C11 and left it to a plan with its own fixture; this is that
  plan. `run-wounds` (4.4.0) fixed what the first real run found; the second run measures those
  fixes on another stack and fixes nothing of its own.
- **Decisions:** 0001 (map optional) gains a second appended note — `eve`'s number — and stays
  closed; its "Step 0, closed" note (4.8.0) names this sprint's `why` case as the thing that
  would reopen it, so the `why` traces are read against that clause too. 0002 and 0003
  untouched.
- **Harness changes:** lint check 17's ceiling (163,840 → 196,608) and smoke check 42's expected
  message; one new smoke check (59); `scripts/evals.sh` gains a citation comment. No rule file,
  no skill, no agent changes — `agents/eve.md` is read-only in this plan (§3).

## Answers
1. **E11 names `~/code/pulse` at approval, and the directory is not on disk at T0. Which
   repository is the second real run on (its absolute path; a Phoenix/LiveView or Python
   project so a second stack's rules and skills are exercised)?** — **`~/code/office_bestie`**,
   the owner, 2026-10-10: Elixir/Phoenix 1.8 with LiveView; it has a `CLAUDE.md`, a `.claude/`
   directory and a `PROJECT_MAP.md`, no `.shipkit/`, and a working tree with 29 modified or
   untracked entries at `main` (`179f99d`) — the notes record `git status` before the first
   step and the run touches none of them.
2. **The 4.3 run's intake step took "one small real change" the owner named (the health check
   endpoint). What is the one real request the intake step of this run takes?** — *open: not
   named at approval; the owner names it at T3, before the intake step runs.*
3. **The budget (§4 and S16-T-REL): 27 runs at T2 ≈ $5, up to two re-runs alone ≈ $1, the
   second run ≈ $5–8, the release run at 58 cases ≈ $17.50. In the budget (rule 15)?** —
   **Yes**, the owner, 2026-10-10 ("approved, in budget").

## Assumptions made
- The new smoke check is **59**, not the plan's 56: the plan was written at 4.6.0's 55 checks
  and Sprints 14 and 15 added 56, 57 and 58 (`scripts/smoke.sh`, the last section header).
  The plan's text is read as "the next number".
- The `why` case asks why `pulse` moved sessions off the database *and when*; the "when" is the
  date the map's Evolution line carries — the generator writes fixed dates, so the fact is
  stable across generations (`FACTS-PORTFOLIO.md` lists it).
- The three `eve` prompts carry the digest case's two lines verbatim
  (`plugins/shipkit/evals/digest/attention/prompt.md`, lines 9–10): `SHIPKIT_HOME` is the
  workspace's `shipkit-home/`, and the run is not interactive. The registry's `Path` column
  holds absolute paths under the workspace, as the digest fixture writes them.
- `trace-tools.sh`'s `map_read` already counts a subagent's `Read` or `Grep` of
  `PROJECT_MAP.md` (its header: "main session or subagent"), so `eve`'s reads need no change
  to the script; the 4.9 results document's columns come from it unchanged.
- The second real run happens on this sprint's branch *before* the release prep, with
  `--plugin-dir` pointing at this checkout (S16-T3); the cache path is written back to
  `~/.claude/shipkit/plugin-root` after every such session. Rule 17 holds for its length.
- The three arms are the committed plugin and two scratch copies of it whose `fixture.sh`
  differs by one flag; the scratch copies are made under the scratchpad and removed after
  their traces are read (rule 13).
- Lint check 17's new comment says the room is "for cases and generators" (E10's wording), and
  smoke check 42's doctored copy (a 60 KB file on top of 148,311 bytes) still exceeds 196,608,
  so the check keeps firing.

## Out of scope
Any change to `agents/eve.md`, `agents/grandfather.md`, a rule file or a skill; fixing anything
the second run finds (each finding is an item under "Still open after Sprint 16"); the four
kept whole-body files and `rails`; `trap2/notebooks`' grader; the mid-run plugin-root window;
the refusal text of `.pre-commit-config.yaml`; the elder's step 0 (closed by record at 4.8.0,
reopened only by the clause 0001 names).
