# Spec: Live decisions and the studio digest (Sprint 6, release 3.7.0)

> Spec accepted at commit `8357868` on sprint-6/decisions-and-digest.
> Status: shipped
> Paths: plugins/shipkit/scripts/decision-check.sh, plugins/shipkit/scripts/portfolio-digest.sh, plugins/shipkit/scripts/briefing.sh, plugins/shipkit/skills/spec/reference.md, plugins/shipkit/skills/decide/, plugins/shipkit/skills/ship/, plugins/shipkit/skills/ask/, plugins/shipkit/agents/grandfather.md, plugins/shipkit/agents/eve.md, plugins/shipkit/evals/, scripts/smoke.sh, GUIDE.md

## Purpose

Decisions tell you when they have stopped being true, and one page tells you which product
needs you this week.

Source: `docs/plans/quality-gate-sprint-plan.md`, Sprint 6, tasks S6-T1 to S6-T5, and the
intake beside this file.

## User stories

- As a solo engineer, I want a decision I made a year ago to tell me when its reason has
  expired, so that I revisit it then and not when it bites.
- As someone with several products, I want one page a week that says which one needs
  attention and why, built from files I already keep.

## Requirements (EARS)

### The `Fired-if` line (S6-T1)

- **REQ-1.** The decision-record template in `skills/spec/reference.md` shall show an optional
  `**Fired-if.**` line after the falsifiability line, in both forms: a shell command that
  exits 0 when the condition has come true, and the word `manual`.
- **REQ-2.** `/shipkit:decide` shall ask whether a command can check the reversal condition,
  and shall write that command or `manual`. [untested: skill prose, verified by reading]
- **REQ-3.** After S6-T1 the three always-on rules shall still total at most 3,000 bytes.

### `decision-check.sh` (S6-T2)

- **REQ-4.** `decision-check.sh <project-dir>` shall find every `**Fired-if.**` line in
  `.shipkit/decisions/*.md` and `.shipkit/specs/*/design.md`.
- **REQ-5.** When run without `--run`, `decision-check.sh` shall print each command with the
  record it came from, shall run none of them, and shall exit 0.
- **REQ-6.** When run with `--run`, `decision-check.sh` shall run each command from the
  project directory and print one line per decision: `FIRED`, `HOLDS`, `MANUAL` (with the
  clause's text), or `ERROR` when the command's exit status is above 1.
- **REQ-7.** When run with `--run`, `decision-check.sh` shall exit 1 if any decision is `FIRED`,
  and 0 otherwise.
- **REQ-8.** No hook in `plugins/shipkit/hooks/` shall call `decision-check.sh`.
- **REQ-9.** The header comment of `decision-check.sh` shall say that the commands come from
  the repository and must be read before `--run` is used in a repository one does not trust.

### The elders and the gate (S6-T3)

- **REQ-10.** `grandfather.md` and `eve.md` shall say that, for "are any decisions
  falsified?", the elder runs `decision-check.sh` without `--run` and shows the commands, and
  runs it with `--run` only for a project in the registry.
  [untested: agent prose, verified by reading]
- **REQ-11.** `/shipkit:ship` shall have a step 8: no decision is `FIRED`; a `FIRED` decision
  makes the result `NOT READY` until the owner writes a superseding record or says to
  proceed. [untested: skill prose, verified by reading; the ship smoke checks still pass]

### `portfolio-digest.sh` (S6-T4)

- **REQ-12.** `portfolio-digest.sh [registry-file] [--run-checks]` shall read the registry
  (default `$SHIPKIT_HOME/project-registry.md`, `SHIPKIT_HOME` defaulting to
  `~/.claude/shipkit`) and write `$SHIPKIT_HOME/digests/<date>.md`, using no model.
- **REQ-13.** The digest shall hold one section per registered project with exactly these
  lines: top goal and review date; open specs and task progress; spec gaps; decisions fired
  or needing a manual look; escapes in the last 30 days by cause; map age in commits;
  uncommitted files and unpushed commits.
- **REQ-14.** If a registered project's path does not exist, then the digest shall hold one
  line for it, `path not found`, and the script shall go on to the next project.
- **REQ-15.** `portfolio-digest.sh` shall run decision commands only when `--run-checks` is
  given, and shall exit 0 when every project was written.

### `/shipkit:ask --all digest` and the reminder (S6-T5)

- **REQ-16.** When `/shipkit:ask --all digest` is run, it shall run `portfolio-digest.sh` and
  give the digest and `studio.md` to `eve`, whose answer shall be a ranked list of at most
  three products that need attention this week, each reason tied to a line in the digest and
  to a studio priority.
- **REQ-17.** Where the newest digest in `$SHIPKIT_HOME/digests/` is more than seven days old,
  `briefing.sh` shall print one line saying so; where there is no digest at all it shall print
  nothing about digests.
- **REQ-18.** `GUIDE.md` shall show how to schedule `portfolio-digest.sh` weekly with `cron`
  or `launchd`, as an option, and shall record whether a scheduled cloud agent could run it.
  [untested: documentation, verified by reading]

## Release steps (not requirements)

- The gate (`/shipkit:ship decisions-and-digest`) answers `READY`; the report is committed.
- The sprint exit checklist holds; the pull request is merged after a green check; tag `v3.7.0`.

## Out of scope

- Running decision commands from any hook, from the briefing, or from the digest by default.
- Judging whether a reversal condition is a good one.
- A cloud-scheduled digest. The script is local; the guide records what the platform offers.
- Editing `rules/decisions.md`: the rule budget is full, and the template and
  `/shipkit:decide` carry the format.
