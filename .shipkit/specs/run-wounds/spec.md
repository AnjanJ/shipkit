# Spec: What the run hurt on (Sprint 11, release 4.4.0)

> Spec accepted at commit `74d6c11` on sprint-11/run-wounds (2026-10-08).
> Status: open
> Paths: plugins/shipkit/scripts/briefing.sh, plugins/shipkit/scripts/session-start.sh, plugins/shipkit/skills/intake/, plugins/shipkit/skills/product/, plugins/shipkit/skills/handoff/, plugins/shipkit/evals/, scripts/, docs/design/eval-history.md, docs/plans/field-sprint-plan.md, .shipkit/releases/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Make shipkit right on the project it was wrong on: a briefing that stops reporting shipped
pre-3.3 specs as in flight, an intake that searches the repository before it asks the owner and
says what it searched, headless runs that leave their questions where the next session can see
them, and three one-line gaps the field notes named.

Source: `docs/plans/field-sprint-plan.md`, Sprint 11 (S11-T1 to S11-T4), decisions C2, C3, C4;
`docs/design/field-notes-4.3.md` §0 to §5, §9, §10.

## User stories

- As the owner of a project that used shipkit before 3.3, I want the session briefing to be
  right about which specs are in flight, so that I trust its other lines.
- As an owner asked questions by the intake, I want each question to be one the repository
  cannot answer, so that I spend my answers where they change what gets built.
- As the next session after a headless run, I want the questions that run could not ask written
  in the spec folder, so that I can answer them without re-running the research.

## Requirements (EARS)

### The briefing on pre-3.3 specs (S11-T1)

- **REQ-1.** While a spec has no `Status` line and every task in its `tasks.md` is ticked, the
  briefing shall print no progress line for it.
- **REQ-2.** While a spec has no `Status` line and every task in its `tasks.md` is ticked, the
  session hook shall print no drift line for it.
- **REQ-3.** When at least one spec under `.shipkit/specs/` has no `Status` line, the briefing
  shall print one line giving the count of such specs and the fix (`> Status: shipped`).
- **REQ-4.** While a spec has no `Status` line and at least one task is unticked, the briefing
  shall report its progress and next task as it does for an open spec.
- **REQ-5.** `spec-check.sh` shall go on reading a spec with no `Status` line as open. [untested:
  no change; `spec-contract/REQ-7` and smoke check 19h hold it]

### The intake searches before it asks (S11-T2)

- **REQ-6.** When a candidate question is answered by a file in the repository, the intake shall
  not ask it and shall name the file. *(Amended at the ship commit, branch not taken: the fixed
  list of places and the "assumption with file and line" form were not added — the
  `intake/answered` case passed 3 of 3 on the 4.3.0 text, so the design record's clause fired
  before the list was written; the case now tests the text as it stands.)*
- **REQ-7.** When the intake states that the repository has no answer to a question, it shall name
  the places it searched. [untested: prose, verified by reading; the eval case reads the reply's
  questions, not its absence claims]
- **REQ-8.** The intake shall ask the `grandfather` agent, not read the codebase itself, for how
  the code works today. [untested: prose; whether a headless run obeys is not visible in a reply]
  *(Amended at the ship commit, branch not taken: the per-question delegation of the search list
  went with the list — see REQ-6.)*

### Headless runs leave their questions on disk (S11-T3)

- **REQ-9.** When no user is present and questions remain, the intake shall write `intake.md` with
  each remaining question under "Answers" marked *unanswered*.
- **REQ-10.** When an intake pass finds an `intake.md` with unanswered questions and the request
  carries answers, the intake shall fill them and ask nothing the file or the request already
  answers. [untested: prose, verified by reading; the second pass is the owner's interactive run]
- **REQ-11.** When no user is present, `/shipkit:product` shall write a block under the review
  line in `product.md` beginning `> Open questions for the owner:` holding the questions it would
  have asked. *(Reworded at the ship commit with the owner's yes: a section would be an eighth
  heading, and smoke check 23 holds the file to seven.)*

### Three lines (S11-T4)

- **REQ-12.** When a directory with a higher version name exists beside the running plugin root
  in the plugin cache, the session hook shall print one line naming the running version, the
  newer one and "restart".
- **REQ-13.** If no higher version directory exists, then the session hook shall print no
  version line.
- **REQ-14.** While the product file's first goal has metric, target and date all "none set",
  the briefing shall print the goal followed by "(no metric set)" and none of the three fields.
- **REQ-15.** When the next step cannot start, the handoff note shall carry a "## Blocked on"
  heading with one line saying what it waits for. [untested: prose, verified by reading]

## Release steps (not requirements)

- S11-T2's Check first moves two README history sections to `docs/design/eval-history.md` only
  with the owner's yes (intake question 1).
- The gate (`/shipkit:ship run-wounds`) answers `READY`; the report is committed.
- Release as 4.4.0; the sprint exit checklist holds; the pull request is merged after a green
  check; tag `v4.4.0`; the owner's cache update (C12 D5) is its own yes.

## Out of scope

Rule and agent text; trap-2 cases; the reviewer and `brief-verify.sh`; `decision-check.sh`;
migrating a user's specs; eve; a second real run.
