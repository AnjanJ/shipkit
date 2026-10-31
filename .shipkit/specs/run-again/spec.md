# Spec: The run again, and 5.0.0 (Sprint 22)

> Spec accepted at commit `e0a38a9` on sprint-22/run-again (2026-10-31).
> Status: open
> Paths: plugins/shipkit/scripts/brief.sh, plugins/shipkit/scripts/brief-verify.sh, plugins/shipkit/agents/reviewer.md, plugins/shipkit/skills/ship/, plugins/shipkit/skills/setup/, plugins/shipkit/skills/intake/, scripts/smoke.sh, docs/design/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, .shipkit/specs/always-on/, .shipkit/specs/overlays-and-eve/, .shipkit/specs/run-debts/design.md

## Purpose

Sprints 20 and 21 cut what a session pays. No real project has run on the result. This sprint
pays the four one-line debts the 4.12 run found, settles the headless wait that held a session
open for twenty minutes, runs the same nine steps on the same project with the same request,
and says section by section what changed and what a session there now costs. Then it writes
the roadmap for the plan after and releases 5.0.0, a breaking version:
ten skills where there were seventeen, four agents where there were seven, overlay skills
behind a flag.

Source: `docs/plans/thinning-sprint-plan.md` (approved 2026-10-30), W5, W11–W14, Sprint 22;
`docs/design/field-notes-4.12.md` §2, §4, §8, §9.

## User stories

- As someone handing a spec task to an agent, I want the brief to say how a test cites its
  requirement, so that `spec-check` sees the agent's tests without a second pass.
- As someone running a shipkit skill headless, I want the session to end when the work ends,
  so that a 65-second intake does not hold a runner for twenty minutes.
- As the owner, I want the same loop on the same project read against the last run, so that I
  know what the thinning cost and what it bought, from a real project instead of a table.
- As a user upgrading from 4.12.0, I want every changed name in one table, so that a habit
  that stopped working has one place to look.

## Requirements (EARS)

### The four one-line debts (S22-T1, W13)

- **REQ-1.** When `brief.sh` prints a task's brief, its "Prove it with" section shall say that
  each test cites its requirement as `<slug>/REQ-N`, with the spec's own slug in the line.
- **REQ-2.** When a task's change holds a file the manifest `.claude/rules/shipkit/.installed`
  lists under `.claude/skills/`, `brief-verify.sh` shall not report that file; a file under
  `.claude/skills/` the manifest does not list shall still be reported `OUTSIDE`.
- **REQ-3.** The `reviewer` agent shall not list a skill file the manifest lists under "Changes
  beyond the spec", and shall still list one it does not.
- **REQ-4.** When `/shipkit:ship` runs, it shall capture the pre-step `git status --porcelain`
  in `"${TMPDIR:-/tmp}/shipkit-ship-status.out"`, inside the pattern its own cleanup removes,
  and step 7 shall read that file.
- **REQ-5.** `skills/setup/SKILL.md` shall give the number of rules `install-rules.sh` copies,
  and the number shall match the files under `plugins/shipkit/rules/`.

### The headless wait (S22-T1, W14)

- **REQ-6.** `docs/design/eval-results-5.0.md` shall hold one row per headless `/shipkit:intake`
  run: wall-clock, `duration_api_ms`, whether the session called `Agent`, and whether its
  transcript holds a `ScheduleWakeup` call. A run with no `Agent` call shall not count toward
  the clause, and the table shall say so. [untested: a measurement, read from the transcripts]
- **REQ-7.** Where at least one run without the sentence schedules a wakeup and no run with it
  does, `intake` and `ship` shall carry the sentence where they hand work to an agent.
  Otherwise neither shall carry it, and the record "The leaked wait sentence is closed by
  record" in `run-debts/design.md` shall be reopened with the headless condition written in.
  [untested: the clause decides on the table; the file state is read]

### The run again (S22-T2, W5)

- **REQ-8.** `docs/design/field-notes-5.0.md` shall hold the nine steps on `~/code/linkshort`
  with the request link expiry (TODO.md item 1), each written as Asked for / Produced / Took /
  Awkward / Whose fault / Evidence, each ending with one line against the 4.12 section of the
  same number: same, better or worse, and the evidence. [untested: prose, verified by reading]
- **REQ-9.** The notes shall hold `scripts/context-cost.sh`'s output on the worktree three
  times under one heading: before setup, after setup, after the first spec. [untested: prose,
  verified by reading]
- **REQ-10.** The notes shall say for each of REQ-1 to REQ-5 whether it held on the run, or that
  the run could not show it. [untested: prose, verified by reading]
- **REQ-11.** Nothing the run finds shall be changed in this sprint, REQ-15 alone excepted on the
  owner's word; the ROADMAP's open list
  shall hold one item per finding, each citing the notes' section, and the fate of branch
  `shipkit/real-run-4` and its worktree shall be recorded. [untested: prose, verified by
  reading]

### The roadmap for the plan after (S22-T3)

- **REQ-12.** `ROADMAP.md` shall mark Sprints 20 to 22 and the 5.0.0 release in a "Thinning plan"
  table, and shall hold a "Still open after Sprint 22" list: the run's findings, what "Still
  open after Sprint 19" still holds, and Sprint 21's open watches (`ship-gate`'s `placeholder`
  reply, the `agents` check on haiku, `map_read`'s Grep gap), every item citing a file and a
  section. [untested: prose; lint check 16 holds the status line]

### The release (S22-T-REL, W11)

- **REQ-13.** The CHANGELOG's 5.0.0 entry shall open with "What changed for you" and shall
  carry the Migration table, the plan's §0 table before and after, and the smoke check count.
  [untested: prose, verified by reading]
- **REQ-14.** When 5.0.0 is released, `always-on` and `overlays-and-eve` shall each have every task
  ticked, a READY report under `.shipkit/releases/`, and `Status: shipped`. [untested: the gate's
  own steps hold it]
  > *Amended 2026-10-31 (T-REL, before this spec's gate):* this also named `run-again`, which no
  > gate can hold true of itself: its report and its `Status` come after it. That state stays
  > under the release steps below, as `third-run` kept it.
- **REQ-15.** When the `reviewer` agent's reply to `/shipkit:ship` has no `VERDICT:` line, the gate
  shall start the reviewer once more with the same slug and base ref and use that reply; where
  the second reply has none either, step 4 shall be `FAIL`.
  > *Added 2026-10-31 (T-REL, the owner's word):* the release smoke failed `ship-gate` twice in a row
  > on a reviewer whose last call was `SubagentHandback {"message": "placeholder"}`. This spec had
  > listed that watch as out of scope; the exit checklist cannot pass with it, and a false NOT READY
  > lands on a user's complete feature. The design has the record.

## Release steps (not requirements)

- F3: branch `claude/wizardly-fermi-u6f5w2` on the remote, its own yes. F4: the owner's cache
  updated to 5.0.0 after the tag, its own yes. This sprint's branch after the tag, its own yes.
- The gate (`/shipkit:ship`) answers `READY` for each of the three specs; the reports are
  committed.
- Release as 5.0.0; the sprint exit checklist holds (evals at 60 cases); the release run is
  recorded in `docs/design/eval-history.md`; the pull request is merged after a green check; tag
  `v5.0.0`.

## Out of scope

Fixing anything the run finds; a fifth debt; the two graders 4.11.0 found narrower than their
line; why the model writes `placeholder`, the `agents` smoke check's open watch and `map_read`'s
Grep gap, which go on the ROADMAP; a stub for any renamed skill (rule 21); a new eval case; any deletion this
spec does not name, and nothing it names without its own yes.
