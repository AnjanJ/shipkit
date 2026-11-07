# Spec: The user's machine (Sprint 27)

> Spec accepted at commit `9b32e36` on sprint-27/users-machine (2026-11-05).
> Status: shipped
> Paths: plugins/shipkit/skills/setup/SKILL.md, plugins/shipkit/stacks/elixir/CLAUDE.md.append, plugins/shipkit/stacks/go/CLAUDE.md.append, plugins/shipkit/agents/reviewer.md, plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/skills/ship/reference.md, scripts/wait-probe.sh, docs/design/eval-results-5.2.md, plugins/shipkit/skills/intake/SKILL.md, plugins/shipkit/skills/ask/SKILL.md, .shipkit/decisions/0005-evals-home.md, ROADMAP.md, scripts/smoke.sh, docs/plans/machine-sprint-plan.md, CHANGELOG.md

## Purpose

A user's machine is never shipkit's test fixture. On the 5.1 run the project's toolchain was pinned
with `mise`, so the test command setup wrote did not run in a headless shell; the owner's `grep` is
ripgrep, so the release gate's reviewer called a line missing that is there; and a headless intake
stayed open four minutes after its work, waiting on watches it set for an agent that had finished.
This sprint makes what setup writes run on the user's machine, makes the gate's searches read the
same whatever the user's shell says, measures the wait before saying anything about it, and records
why the evals stay inside the plugin.

Source: `docs/plans/machine-sprint-plan.md` (approved 2026-11-05), G4, G5, G7, G8, Sprint 27;
`docs/design/field-notes-5.1.md` §2, §4; `docs/design/eval-history.md`, "Release run 5.1.0";
`.shipkit/specs/users-machine/intake.md`.

## User stories

- As a user whose project pins its toolchain with `mise`, I want the test command in my `CLAUDE.md`
  to run in a headless session, so that a task's Done-when and the gate's tests run at all.
- As the owner, I want the gate's searches to find a line that is there whatever my `grep` is.
- As the owner, I want the headless wait measured before a sentence about it goes into a skill.

## Requirements (EARS)

### A test command for a pinned toolchain (G4, S27-T1)

- **REQ-1.** When the project has `.tool-versions`, `mise.toml` or `.mise.toml` at its root and
  `mise` is on the `PATH`, setup shall write the detected test command with `mise exec --` before
  its program and after any leading `VAR=value` words (`MIX_ENV=test mise exec -- mix test`), and
  shall say so in its reply.
- **REQ-2.** When the project has none of those files, or `mise` is not on the `PATH`, setup shall
  write the detected test command unchanged.
- **REQ-3.** The elixir overlay's `CLAUDE.md` section shall write its run-all and run-one test lines
  with the `TEST_COMMAND` placeholder, and the go overlay's its run-all line, so that each section
  names the command setup's **Test:** line names; `install-stack.sh` for either without
  `TEST_COMMAND` shall exit 2 naming it.

### Searches no alias can bend (G5, S27-T2)

- **REQ-4.** The reviewer's procedure shall tell it to search the repository with `git grep -n`,
  with `-E` for alternation, and never to write `\|` in a search.
- **REQ-5.** The ship skill's step 3 shall find an unticked task with `git grep -n --untracked`, so
  that an untracked `tasks.md` is read, and the skill shall tell the gate to search as REQ-4 says.
- **REQ-6.** `agents/reviewer.md`, `skills/ship/SKILL.md` and `skills/ship/reference.md` shall name
  no search command but `git grep`, and hold no `\|` in a command.

### The headless wait, measured (G7, S27-T3)

- **REQ-7.** `scripts/wait-probe.sh` shall scaffold a fixture project whose research for an intake
  takes under a minute, run a given number of headless `/shipkit:intake` sessions on it (five by
  default), and print for each the seconds from the intake file's last write to the session's end,
  and the number of `Monitor` and `sleep` calls the session made.
- **REQ-8.** Given a stored session transcript, `wait-probe.sh` shall compute those numbers from the
  transcript alone, with no model call.
- **REQ-9.** The five runs shall be recorded in `docs/design/eval-results-5.2.md`, one row per run:
  wall time, idle seconds, `Monitor` and `sleep` calls, cost.
  [untested: a measurement, read by the owner at the task's stop]
- **REQ-10.** Where 2 or more of the 5 runs idle over 60 s, `skills/intake/SKILL.md` and
  `skills/ask/SKILL.md` shall each say to wait for the agent's own notification and to arm no
  `Monitor` and no `sleep`, and five runs again shall be recorded beside the first; otherwise
  `ROADMAP.md` shall carry one line naming the wait as the platform's and citing the runs.
  [untested: one of two outcomes, chosen on REQ-9's numbers at the owner's stop]

### The evals' home, recorded (G8, S27-T4)

- **REQ-11.** A project-wide decision record, `.shipkit/decisions/0005-evals-home.md`, shall keep
  the evals inside the plugin, in its five parts, cite the two plugin docs pages read at S27-T0, and
  give a reversal condition that is an event.
  [untested: a record; `decision-check.sh` reads its Fired-if]

## Merge steps (not requirements)

- The sprint exit checklist with `--group reviewer`, and the full smoke suite (rule 22).
- No gate on this spec at the merge: `/shipkit:ship` runs on it at 5.2.0's release (rule 27).
- Merged untagged after a green check. The owner's cache is not touched.

## Out of scope

The run and 5.2.0 (Sprint 28); `--scope project` (G11); setup's own searches of the plugin's files;
the stack skills' test lines; merging two `## Elixir-Specific` sections (G6); moving the evals (G8);
a decision's record in the brief; any new always-on byte.
