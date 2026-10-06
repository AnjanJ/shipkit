# Spec: Reviewer and ship gate (Sprint 4, release 3.5.0)

> Spec accepted at commit `374b43b` on sprint-4/review-and-ship.
> Status: open
> Paths: plugins/shipkit/agents/reviewer.md, plugins/shipkit/skills/ship/, plugins/shipkit/skills/escape/, plugins/shipkit/evals/, plugins/shipkit/scripts/spec-check.sh, plugins/shipkit/stacks/rails/.claude/skills/deploy-check/, plugins/shipkit/stacks/rails/.claude/skills/release/, scripts/smoke.sh, scripts/lint.py, .claude-plugin/marketplace.json

## Purpose

A second pair of eyes that has not seen the implementer's reasoning, and one command that says
whether a feature is ready, with evidence. When a bug reaches users anyway, a way to trace it
back to the requirement that was missing, wrong or untested.

Source: `docs/plans/quality-gate-sprint-plan.md`, Sprint 4, tasks S4-T1 to S4-T5, and the
intake beside this file (`intake.md`).

## User stories

- As a solo engineer, I want my branch checked against its spec by something that was not in
  the room when I wrote it, so that "done" is not only my own opinion.
- As a solo engineer, I want one command that tells me READY or NOT READY and shows why, so
  that shipping is a decision made on evidence.
- As a solo engineer, when a bug escapes, I want to know which link broke — no spec, a missing
  requirement, a missing test — so that the fix includes the thing that would have caught it.

## Requirements (EARS)

### The `reviewer` agent (S4-T1)

- **REQ-1.** When the `reviewer` agent is given a spec folder name and a base git ref, it shall
  read that spec's `spec.md`, `design.md` and `tasks.md` and `git diff <base>...HEAD`, and
  shall ask for and use nothing else from whoever wrote the code.
  [untested: agent prose, verified by reading]
- **REQ-2.** For each requirement that is not marked `[untested: …]`, the reviewer shall give
  exactly one verdict: `MET` with the file and line of the code and of the test, `NOT MET`
  with what is missing, or `CANNOT TELL` with what it would need to see.
- **REQ-3.** For each requirement marked `[untested: …]`, the reviewer shall verify it by
  reading and give `MET` with the file and line that satisfies it, `NOT MET`, or
  `CANNOT TELL`; no test is required for `MET`. [untested: agent prose, verified by reading]
- **REQ-4.** The reviewer shall list every changed file outside the spec's `Paths` under
  "Changes beyond the spec". [untested: agent prose, verified by reading]
- **REQ-5.** The reviewer shall list every decision in `design.md` that the code does not
  follow. [untested: agent prose, verified by reading]
- **REQ-6.** The reviewer's reply shall end with `VERDICT: PASS` if every requirement is `MET`,
  and with `VERDICT: FAIL` otherwise.
- **REQ-7.** The reviewer shall have the tools `Read`, `Glob`, `Grep` and `Bash`, and shall not
  have `Edit`, `Write` or `Agent`.
- **REQ-8.** The reviewer shall not review for general bugs or style, shall say so, and shall
  point to the built-in `/code-review` for that. [untested: agent prose, verified by reading]

### `/shipkit:ship` (S4-T2)

- **REQ-9.** When `spec-check.sh` is run with `--as-shipped`, it shall apply the checks for a
  shipped spec (a cited test for every requirement not excused) to a spec whose status is
  `open`, without changing any file.
- **REQ-10.** When `/shipkit:ship <slug> [base-ref]` is run, it shall carry out the seven steps
  of the gate in order — spec-check as shipped, the project's test command, every task ticked,
  the reviewer's verdict, a rollback for any migration, a concrete reversal condition on every
  decision, a clean working tree — and record each as `PASS`, `FAIL` or `SKIPPED` with the reason.
  [untested: skill prose; REQ-12 and REQ-13 check the outcome]
- **REQ-11.** `/shipkit:ship` shall write `.shipkit/releases/<date>-<slug>.md` whose first
  line is `READY` or `NOT READY`, followed by the seven results, the evidence for each, the
  number of requirements waived as `[untested]`, and the commit sha.
  [untested: skill prose; REQ-12 and REQ-13 check the outcome]
- **REQ-12.** When `/shipkit:ship` is run on a feature that is complete, the report's first
  line shall be `READY`.
- **REQ-13.** When `/shipkit:ship` is run on the same feature with one task unticked, the
  report's first line shall be `NOT READY` and it shall name step 3.
- **REQ-14.** `/shipkit:ship` shall change no file except the report, and — only after a
  `READY` result and the owner's yes — the spec's `Status` line.
- **REQ-15.** `/shipkit:ship` shall never deploy, push, merge, tag or edit code; on
  `NOT READY` it shall list what to fix and stop. [untested: skill prose, verified by reading]

### `/shipkit:escape` (S4-T3)

- **REQ-16.** When a bug that reached users is reported, `/shipkit:escape` shall pick exactly
  one cause from: `no spec`, `requirement missing`, `requirement wrong`,
  `requirement right, no test`, `test existed but was wrong`,
  `outside the product (dependency, infrastructure)`, and say why.
- **REQ-17.** When the cause is `requirement missing` or `requirement wrong`, `/shipkit:escape`
  shall propose the new or corrected requirement for the spec whose `Paths` cover the broken
  code.
- **REQ-18.** `/shipkit:escape` shall ask at most three questions, write
  `.shipkit/escapes/NNNN-<slug>.md` (date, what happened, the cause, the spec, the fix), and —
  where a requirement was missing or wrong — set the spec's `Status: open` and add a task
  whose test fails first. [untested: skill prose, verified by reading]

### The Rails overlay (S4-T4)

- **REQ-19.** The Rails overlay's `deploy-check` and `release` skills shall each contain the
  line "If this feature has a spec, run `/shipkit:ship <slug>` first.", with nothing else in
  either skill removed or rewritten.

## Release steps (not requirements)

Requirements describe the product; these describe what happens to this spec after the gate,
and the gate cannot judge them because they come after it. Removed from the requirements on
2026-10-06, owner-approved, after the first real run of `/shipkit:ship` on this branch
answered `NOT READY` on exactly these two (they were REQ-20 and REQ-21).

- `/shipkit:ship review-and-ship` is run on this branch; its report,
  `.shipkit/releases/<date>-review-and-ship.md`, starts with `READY` and is committed.
- The five lines of the sprint exit checklist hold before the release.

## Out of scope

- Deploying, pushing, merging or tagging from the gate.
- General bug-hunting or style review by the reviewer (the built-in `/code-review` does that).
- A reviewer that starts other agents, or a gate that runs without the main session.
- Running the tests inside the reviewer. The gate runs them; the reviewer reads.
- A product file for shipkit itself.
