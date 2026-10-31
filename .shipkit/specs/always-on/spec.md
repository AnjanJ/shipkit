# Spec: What every session pays (Sprint 20, untagged)

> Spec accepted at commit `877a8e5` on sprint-20/always-on (2026-10-30).
> Status: shipped
> Paths: plugins/shipkit/scripts/, plugins/shipkit/hooks/, plugins/shipkit/skills/, plugins/shipkit/agents/, plugins/shipkit/rules/shipkit.md, plugins/shipkit/evals/, plugins/shipkit-workflows/skills/, scripts/, docs/design/, README.md, GUIDE.md, CHANGELOG.md

## Purpose

Every Claude Code session on every project pays for shipkit before a word is typed: the hook's
output (3,951 bytes on a project that never opted in), seventeen core and six workflow skill
descriptions (5,567 bytes), seven agent descriptions (1,720 bytes). The 2026-10-22 review
measured it and found almost none of it used in a typical session on another product. This
sprint makes the surface earn its place by the plan's rule 20 — every always-on byte has a
number or the owner's word: a script that prints what a session pays, so the table is
re-measured and not remembered; the two loop rules injected only where a project opted in;
the Care lines measured with and without the plugin before anything moves; ten core skills
where there were seventeen and four agents where there were seven, with every merged trigger
proved to fire before the old name goes; and the eval ceiling raised for the one probe that
does not fit.

Source: `docs/plans/thinning-sprint-plan.md` (approved 2026-10-30), §0, W1–W4, W10, Sprint 20;
`docs/design/field-notes-4.12.md` §1 (a project with nothing gets no word about setup).

## User stories

- As someone working on a project that has never run shipkit, I want a session there to
  carry shipkit's one rule of care and one line telling me how to opt in, so that a tool I
  did not turn on does not fill my context with the spec discipline of a loop I am not using.
- As the owner, I want the cost of every always-on byte printed by a script, so that the next
  cut or the next addition is argued from a number and not from memory.
- As a user of `/shipkit:walkthrough` or `/shipkit:unsetup`, I want the same work one argument
  away under `ask` and `setup`, and a migration table that says so, so that a shorter skill
  list does not mean a lost capability.

## Requirements (EARS)

### The context cost as a script (S20-T1)

- **REQ-1.** When `scripts/context-cost.sh <project-dir>` is run, it shall print, with no
  model call, one row each for: the session hook's output bytes in that directory (the real
  hook run with `CLAUDE_PLUGIN_ROOT`), the skill description bytes and count per plugin, the
  agent description bytes and count, the overlay skills and `CLAUDE.md` append sections
  installed in that project with their bytes, and the three always-on rules' bytes.
- **REQ-2.** The hook row printed by `scripts/context-cost.sh` shall equal `wc -c` of the
  hook's own output in the same directory.
- **REQ-3.** `docs/design/context-cost.md` shall hold the 4.12.0 numbers as the baseline, the
  ceilings from the plan's §0, and the commands that produce each row. [untested: prose,
  verified by reading]

### `spec-driven` and `decisions` opt-in per project (S20-T2, W1)

- **REQ-4.** Where the working directory has neither `.shipkit/` nor
  `.claude/rules/shipkit/`, the session hook shall inject `shipkit.md` and shall not inject
  `spec-driven.md` or `decisions.md`.
- **REQ-5.** Where the working directory has `.shipkit/`, the session hook shall inject every
  always-on rule whose file is not installed under `.claude/rules/shipkit/`, as before.
- **REQ-6.** While `CLAUDE_CODE_EVAL_CONFINED=1` is set, the session hook shall inject all
  three always-on rules regardless of the working directory's contents.
- **REQ-7.** Where the working directory has neither `.shipkit/` nor
  `.claude/rules/shipkit/`, the session hook shall print exactly one line naming the opt-in
  (`/shipkit:product` or `/shipkit:setup`), and shall print it once per session.

### The Care lines measured (S20-T3, W2)

- **REQ-8.** The eval suite shall hold a case `rules/care` whose prompt asks for a change
  that is destructive on its face and whose grader passes a reply that asks before acting or
  refuses the destructive step, and fails one that runs it.
- **REQ-9.** `shipkit.md`'s delivery on a project that never opted in shall follow the W2
  record's clause — universal unless the `rules/care` probe reads 3 of 3 unaided in both arms,
  in which case it joins the opt-in set — and the record shall hold the table either way.
  [untested: the decision is the owner's after the table; the record is prose]

### Ten core skills (S20-T4, W3)

- **REQ-10.** When `/shipkit:ask --walk <feature>` is invoked, it shall produce the end-to-end
  walkthrough `/shipkit:walkthrough <feature>` produced, through the same agent.
- **REQ-11.** When `/shipkit:ask --system` is invoked, it shall produce the system-design
  document `/shipkit:explain-system` produced.
- **REQ-12.** When `/shipkit:setup remove`, `/shipkit:setup rules`, `/shipkit:setup audit` or
  `/shipkit:setup memory` is invoked, it shall do what `/shipkit:unsetup`,
  `/shipkit:update-rules`, `/shipkit:context-audit` or `/shipkit:connect-memory` did, from the
  same body kept as a reference file.
- **REQ-13.** `/shipkit-workflows:commit` shall be the commit skill, and `plugins/shipkit/`
  shall carry no skill directory for any of the seven old names (`walkthrough`,
  `explain-system`, `unsetup`, `update-rules`, `context-audit`, `connect-memory`, `commit`).
- **REQ-14.** The ten core skills' descriptions shall total at most 2,950 bytes, and each
  merged description shall carry the merged-in skill's `TRIGGER when:` lines.
  > *Amended 2026-10-31 (the 5.0.0 gate):* the ceiling was 2,400. The owner amended it to 2,950 at
  > S20-T4 on 2026-10-30 (`design.md`, the plan's amendments): the eight untouched skills total
  > 2,535 and lint caps a description at 300. The amendment reached the design and not this line,
  > and no test held the number; the gate's reviewer found both. Smoke check 65 now reads it.
- **REQ-15.** The CHANGELOG's 5.0.0 entry shall carry a migration table mapping each of
  the seven old skill names to its new form, and `shipkit.md`'s two references
  (`/shipkit:update-rules`, `/shipkit:commit`) shall name the new forms with the three rules
  still at most 3,000 bytes. [untested: prose, verified by reading and by lint's byte check]

### Four agents (S20-T5, W4)

- **REQ-16.** When `grandfather` is handed a trace request (the mode named in the hand-off),
  it shall return the step-by-step, `file:line`-cited walkthrough `tracer` returned.
- **REQ-17.** When `/shipkit:map` builds or refreshes `PROJECT_MAP.md`, it shall do so from a
  forked context carrying the archivist's body, and `plugins/shipkit/agents/` shall hold no
  `archivist.md` or `tracer.md`.
- **REQ-18.** Where the check-first shows the built-in `Explore` agent is callable from a
  plugin skill in a headless session, `plugins/shipkit/agents/` shall hold no
  `codebase-explorer.md` and every skill that named it shall name `Explore`; otherwise it
  stays and the design record says so. [untested: the branch is decided by the check; the
  outcome is read by `ls` and by lint's agent count]
- **REQ-19.** The remaining agents' descriptions shall total at most 1,000 bytes.

### The eval ceiling (W10)

- **REQ-20.** Lint shall hold the evals directory at or under 204,800 bytes, raised from
  196,608 in the same commit that adds the first new case.

## Out of scope

Overlay skills, the `CLAUDE.md` appends and the two unscoped overlay rules (Sprint 21, W6–W8);
`agents/eve.md` (W9); the run again and 5.0.0 (Sprint 22); the four one-line debts and the
headless wait (W13, W14); any grader; any text of the three always-on rules beyond the two
renamed skill names; a stub skill or agent for any removed name (rule 21).
