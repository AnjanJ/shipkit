# Spec: The harness pays its debts (Sprint 14, release 4.7.0)

> Spec accepted at commit `66a993f` on sprint-14/harness-debts (2026-10-09).
> Status: open
> Paths: plugins/shipkit/scripts/spec-check.sh, plugins/shipkit/skills/spec/, plugins/shipkit/skills/ship/, plugins/shipkit/evals/README.md, scripts/, docs/design/eval-results-4.6.md, docs/design/eval-history.md, docs/plans/portfolio-sprint-plan.md, .shipkit/releases/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Make the tools shipkit builds itself with stop lying or littering: `spec-check.sh` checks a
draft without anyone flipping its status; the gate removes the scratch files it writes once the
report holds their content; the smoke suite puts `~/.claude/shipkit/plugin-root` back as it
found it; `trace-tools.sh` counts the map reads its document says it counts and the shell
reads it missed; the eval sandbox's refusal of a root dotfile is understood and written down
for case authors; and the rulebook stops contradicting the gate on when a spec note lands.

Source: `docs/plans/portfolio-sprint-plan.md`, Sprint 14 (S14-T1 to S14-T6), decisions E4 to
E9; `docs/design/field-notes-4.3.md` §6; `docs/design/eval-results-4.6.md` "The elder's step
1" and the `notebooks` row; `.shipkit/specs/gate-blind-spots/design.md` "Exit codes are
echoed"; `CHANGELOG.md` 4.6.0 "What using it for real showed".

## User stories

- As an owner writing a spec, I want `spec-check` to tell me what a draft is missing before I
  accept it, so that the first gate run is not where I learn a task has no `Files:` line.
- As an owner running the gate, I want nothing left under `$TMPDIR` afterwards and nothing
  left changed under `~/.claude/shipkit/` after a smoke run, so that the next session starts
  from the state I left it in.
- As an owner reading an eval table, I want the map-read column to count every way the elder
  read the map, so that a rate of 8 of 15 means 8 and not "8 by one tool".
- As an author of an eval case, I want to know before writing it what the sandbox will refuse,
  so that a case is not corrected on trace evidence a second time for the same reason.

## Requirements (EARS)

### `spec-check` checks a draft (S14-T1)

- **REQ-1.** When `spec-check.sh` is run with `--as-open` on a spec whose `Status` is `draft`,
  it shall check the spec as it checks an open spec — `MISSING-TASK`, `PENDING-TEST`,
  `MISSING-FIELD`, `BAD-AFTER`, `CONFLICT` and `CYCLE` — and shall change no file.
- **REQ-2.** When `spec-check.sh` is run with `--as-open` on a spec whose `Status` is `open`,
  `shipped` or `dropped`, it shall print what it prints without the flag.
- **REQ-3.** When the spec skill checks a draft it has just written, it shall run
  `spec-check.sh` with `--as-open` and shall not change the spec's `Status` line to do so.
  [untested: prose, verified by reading and by smoke check 55's grep of the skill; smoke check
  22's headless spec run is not extended]

### The gate cleans up after itself (S14-T2)

- **REQ-4.** When the ship report has been written, the ship skill shall remove the scratch
  files it wrote under `${TMPDIR:-/tmp}` (`shipkit-ship-*.out`) and nothing else there.
  [untested: verified by a headless dry run of the gate on the shipped `second-traps` spec, the
  `/bin/ls` of `$TMPDIR` before and after quoted in the S14-T2 commit message; the report is
  deleted by design]
- **REQ-5.** The report template shall say, at each evidence block pasted from a scratch file,
  that the file is removed once the report holds its output. [untested: prose, verified by
  reading]

### The smoke suite restores the plugin root (S14-T3)

- **REQ-6.** When the smoke suite exits, by success, failure or an early `exit`, it shall leave
  `~/.claude/shipkit/plugin-root` with the content it had when the suite started, or absent if
  it was absent.
- **REQ-7.** The smoke suite's header shall say that the runner restores `plugin-root` on exit
  and that a session started during a run reads a scratch root until the run ends. [untested:
  prose, verified by reading]

### `map_read` counts what the document says; `map_shell` beside it (S14-T4)

- **REQ-8.** `trace-tools.sh` shall print `map_read` as 1 when any `Read` or `Grep` tool_use in
  the trace, main session or subagent, has an input path ending in `PROJECT_MAP.md`, else 0.
- **REQ-9.** `trace-tools.sh` shall print a `map_shell` column: 1 when any `Bash` tool_use in
  the trace, main session or subagent, has a command containing `PROJECT_MAP.md`, else 0.

### The root-dotfile refusal, understood (S14-T5)

- **REQ-10.** The evals README shall state, under "How a case gets the fixture", what a case cannot
  ask for: a dotfile at the workspace root, with the refusal as the trace or the tool's
  documentation gives it, the form that works, and the rule for case authors. [untested:
  prose, verified by reading and by smoke check 57's grep of the README; the two probe runs are
  recorded in the S14-T5 commit message]

## Release steps (not requirements)

- The ROADMAP's six items — a draft `spec-check`, the gate's scratch files, the smoke suite and
  `plugin-root`, `map_read`'s shell blind spot, the dotfile refusal, rule 5 against the gate —
  are struck, each with its pointer (E9's by the plan's rule 16 and amended rule 5, no plugin
  file changed).
- The gate (`/shipkit:ship harness-debts`) answers `READY`; the report is committed.
- Release as 4.7.0; the sprint exit checklist holds; the release run is recorded in
  `docs/design/eval-history.md`; the pull request is merged after a green check; tag `v4.7.0`;
  the owner's cache update (E12 F5) is its own yes.

## Out of scope

Rule text and the twelve cut candidates; the elder's step 0; the intake's assumption sentence;
the portfolio fixture, `eve`'s cases and the second real run; the cache directories; the shape
of `digest/attention` and `grandfather-xl/drift` under `-j 4`; a hook change for the smoke
suite; a committed probe case for the dotfile refusal.
