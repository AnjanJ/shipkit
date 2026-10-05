# Spec: Product, intake, brief (Sprint 3, release 3.4.0)

> Spec accepted at commit `f1f95d2` on sprint-3/product-intake-brief.
> Status: shipped
> Paths: plugins/shipkit/skills/product/, plugins/shipkit/skills/intake/, plugins/shipkit/scripts/brief.sh, plugins/shipkit/scripts/brief-verify.sh, plugins/shipkit/evals/intake/

## Purpose

Shipkit learns what the product is for, asks a few good questions before work starts, and
turns a spec task into a brief any agent can follow and a check on what the agent hands back.

Source: `docs/plans/quality-gate-sprint-plan.md`, Sprint 3, tasks S3-T1 to S3-T7.

## User stories

- As a solo engineer, I want one short file that says what the product is for and what it
  deliberately does not do, so that a request can be checked against it before any code.
- As a solo engineer, I want to be asked the few questions that would change what gets built,
  and none that a file already answers.
- As someone handing a task to an agent, I want the brief built by a script from the spec, and
  the agent's result checked by a script, so that neither depends on anyone's summary.

## Requirements (EARS)

### The product file and `/shipkit:product` (S3-T1)

- **REQ-1.** When `/shipkit:product` finishes, `.shipkit/product.md` shall contain these seven
  headings in this order: `One line`, `Users`, `Goals this quarter`, `Non-goals`,
  `Metrics that matter`, `Constraints`, `Now / Next / Later`.
- **REQ-2.** `.shipkit/product.md` shall list at most three goals under `Goals this quarter`.
- **REQ-3.** `/shipkit:product` shall first read `README.md`, `CLAUDE.md` and `PROJECT_MAP.md`,
  fill in what they answer, and ask only for what is still empty, in at most eight questions.
  [untested: skill prose; the interview cannot be scripted headless]
- **REQ-4.** If a goal has no metric or no date after being asked for once more, then
  `/shipkit:product` shall write `metric: none set` for it rather than drop the gap.
  [untested: skill prose]
- **REQ-5.** Where `.shipkit/product.md` already exists, `/shipkit:product` shall update it and
  its review date, and shall not start over. [untested: skill prose]
- **REQ-6.** `.shipkit/product.md` shall be at most 60 lines. [untested: skill prose]

### Studio priorities and the registry (S3-T2)

- **REQ-7.** When `/shipkit:product --studio` is run, it shall write
  `~/.claude/shipkit/studio.md`: at most five ranked priorities, each naming its product, and
  a review date. [untested: skill prose; writes outside the project]
- **REQ-8.** The registry template in `skills/map/SKILL.md` shall carry a `Product` column and
  a `Top Goal` column.
- **REQ-9.** When `/shipkit:map --register` adds or refreshes a row, it shall fill the two
  columns from `.shipkit/product.md`, or `?` where there is none, and shall not rewrite a
  user's existing rows beyond adding the columns. [untested: skill prose]
- **REQ-10.** `agents/eve.md` shall name `studio.md` and the two registry columns and say what
  each is for.

### `/shipkit:intake` (S3-T3)

- **REQ-11.** When the request is trivial, `/shipkit:intake` shall say no intake is needed and
  stop.
- **REQ-12.** When the request touches a non-goal in `.shipkit/product.md`, `/shipkit:intake`
  shall say so plainly before asking any question.
- **REQ-13.** When the request is already covered by an open spec, or contradicts a decision
  record, `/shipkit:intake` shall say so plainly before asking any question.
  [untested: skill prose; the non-goal conflict (REQ-12) is the one measured]
- **REQ-14.** `/shipkit:intake` shall ask at most four questions, the most important first,
  and none that a file already answers.
- **REQ-15.** `/shipkit:intake` shall ask which quarterly goal the request serves, accept
  "none", and record the answer. [untested: skill prose]
- **REQ-16.** `/shipkit:intake` shall write `.shipkit/specs/<slug>/intake.md` with the
  headings `Request`, `Serves goal`, `Conflicts found`, `Answers`, `Assumptions made`,
  `Out of scope`. [untested: skill prose]
- **REQ-17.** Where `.shipkit/specs/<slug>/intake.md` does not exist, `/shipkit:spec` shall run
  the intake before its first question. [untested: skill prose]

### `brief.sh` (S3-T4)

- **REQ-18.** When `brief.sh <project-dir> <slug> <task-id>` is run for a valid task, it shall
  print a brief with the title line and these eight headings in this order: `Goal`,
  `Requirement`, `You may edit`, `Prove it with`, `Already done`, `Decisions that bind you`,
  `Not in scope`, `Report back in exactly this form`.
- **REQ-19.** The `Requirement` section shall contain the full text of each requirement the
  task cites, copied word for word from `spec.md`.
- **REQ-20.** The `Already done` section shall list every task the task comes after, directly
  or through a chain of `After` lines.
- **REQ-21.** If the task id does not exist in the spec, then `brief.sh` shall exit 1 and name
  the task and the spec.
- **REQ-22.** If the task has no `Files` line, then `brief.sh` shall exit 1 and say the spec
  must be in the 3.3 task format.
- **REQ-23.** `brief.sh` shall be POSIX `sh` and use no model.

### `brief-verify.sh` (S3-T5)

- **REQ-24.** When every file changed since `<base-ref>` is on the task's `Files` line,
  `brief-verify.sh <project-dir> <slug> <task-id> <base-ref>` shall exit 0.
- **REQ-25.** If a tracked file not on the task's `Files` line changed since `<base-ref>`, then
  `brief-verify.sh` shall print `OUTSIDE <file>` and exit 1.
- **REQ-26.** If a new untracked file is not on the task's `Files` line, then
  `brief-verify.sh` shall print `OUTSIDE <file>` and exit 1.

### When to use the brief (S3-T6)

- **REQ-27.** The `spec-driven` rule and the spec skill shall say: a spec task handed to
  another agent is handed over as the unchanged output of `brief.sh`; the main session runs
  `brief-verify.sh` and the task's `Done when` command itself; tasks with no unfinished
  predecessor may run at the same time, each in its own git worktree; and the team is matched
  to the work. [untested: rule and skill prose]
- **REQ-28.** After S3-T6 the three always-on rules shall still total at most 3,000 bytes.

### Use it for real, and exit (S3-T7)

- **REQ-29.** The Sprint 3 pull request shall have a "What was awkward" section with at least
  one observation from writing the Sprint 4 spec with `/shipkit:intake` and `/shipkit:spec`
  and handing one Sprint 4 task over with `brief.sh`. [untested: a pull request description]
- **REQ-30.** When Sprint 3 is complete, the five lines of the sprint exit checklist shall
  hold. [untested: a checklist, verified by running it]

## Out of scope

- Starting or supervising agents. Claude Code does that; shipkit supplies the brief going in
  and the check coming out.
- Checking the *content* of what an agent changed. `brief-verify.sh` checks which files
  changed; the reviewer agent (Sprint 4) reads them.
- Validating a product's goals. The skill makes a missing metric visible; it does not judge
  whether the goal is a good one.
- The Sprint 4 features themselves. S3-T7 writes their spec and hands over one task as a trial.
