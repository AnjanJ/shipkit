# Spec: Briefing and handoff (Sprint 5, release 3.6.0)

> Spec accepted at commit `ef84b16` on sprint-5/briefing-and-handoff.
> Status: open
> Paths: plugins/shipkit/scripts/briefing.sh, plugins/shipkit/scripts/session-start.sh, plugins/shipkit/scripts/spec-check.sh, plugins/shipkit/skills/handoff/, plugins/shipkit/skills/setup/SKILL.md, plugins/shipkit/hooks/hooks.json, scripts/smoke.sh, .claude-plugin/marketplace.json

## Purpose

A session starts by knowing where things stand and ends by leaving a note. The session hook
prints a few lines — open specs and their next task, gaps, the top goal, the last handoff —
and `/shipkit:handoff` writes the note the next session's briefing reads from.

Source: `docs/plans/quality-gate-sprint-plan.md`, Sprint 5, tasks S5-T1 to S5-T4, and the
intake beside this file.

## User stories

- As a solo engineer, I want the first thing a session tells me to be where I left off, so
  that I do not reconstruct it from `git log`.
- As a solo engineer, I want to end a session with one command that writes down what is in
  flight and what comes next, so that tomorrow's session, or a compacted one, can resume.

## Requirements (EARS)

### `briefing.sh` (S5-T1)

- **REQ-1.** `briefing.sh` shall print at most eight lines, each starting `shipkit:`, totalling
  at most 800 bytes.
- **REQ-2.** For each open spec, up to three, `briefing.sh` shall print
  `shipkit: <slug>: N of M tasks done, next <task-id> — <title>`.
- **REQ-3.** When `spec-check.sh` reports one or more gaps, `briefing.sh` shall print
  `shipkit: spec-check: N gap(s) — run spec-check.sh`; otherwise it shall print no such line.
- **REQ-4.** Where `.shipkit/product.md` exists, `briefing.sh` shall print
  `shipkit: top goal: <the first goal under "Goals this quarter">`.
- **REQ-5.** Where `.shipkit/state.md` exists, `briefing.sh` shall print
  `shipkit: last handoff (<date>, N commits ago): <the "Next step" line>`.
- **REQ-6.** If `.shipkit/` does not exist, then `briefing.sh` shall print nothing.
- **REQ-7.** `briefing.sh` shall exit 0 whatever it finds, including a `tasks.md` it cannot
  parse, and shall print no error.
- **REQ-8.** `briefing.sh` shall finish in under one second on a project with 50 open specs.
- **REQ-9.** `session-start.sh` shall call `briefing.sh` last, after the drift lines.

### `/shipkit:handoff` (S5-T2)

- **REQ-10.** When `/shipkit:handoff` finishes, `.shipkit/state.md` shall hold, in this order,
  a `# Handoff` title, a `> Written <date> at commit <sha> on <branch>.` line, and the
  headings `In flight`, `Done this session`, `Next step`, `Open questions`, `Do not forget`,
  with exactly one line under `Next step`, in at most 30 lines; any earlier `state.md` is
  replaced.
- **REQ-11.** The skill's description shall say to use it when wrapping up or before a long
  pause with unfinished spec work or uncommitted change, and not after trivial work.
  [untested: skill prose, verified by reading]
- **REQ-12.** `/shipkit:handoff` shall fill the file from the session and from `git status`,
  and shall ask nothing unless the next step is unclear.
  [untested: skill prose, verified by reading]
- **REQ-13.** `/shipkit:setup` shall offer to add `.shipkit/state.md` to `.gitignore`.
  [untested: skill prose, verified by reading]

### Close the loop (S5-T3)

- **REQ-14.** When a new session in a project with a `state.md` is asked "what should I do
  next?", its reply shall contain the handoff's "Next step" text.

### Around compaction (S5-T4)

- **REQ-15.** When the session hook runs after a compaction (`SessionStart` with
  `source: "compact"`), it shall print
  `shipkit: context was just compacted — run /shipkit:handoff if work is in flight.` and shall
  not print that line at any other start.
- **REQ-16.** The 3.6.0 changelog shall record that a reminder *before* compaction was not
  built, and why. [untested: changelog prose, verified by reading]

## Release steps (not requirements)

- The sprint exit checklist holds; the pull request is merged; tag `v3.6.0` exists.

## Out of scope

- A transcript or conversation memory. `state.md` is a 30-line note.
- Starting any agent at session start.
- Reading `state.md` in full into the session. The briefing quotes one line; the model reads
  the file if it wants more.
