# Design: Briefing and handoff (Sprint 5, release 3.6.0)

## Approach

A script and a skill. `briefing.sh` is POSIX shell that reads files already on disk — open
specs' `tasks.md`, `spec-check.sh`'s output, `product.md`, `state.md` — and prints at most eight
short lines; `session-start.sh` calls it last, so it rides the hook command that already runs
in every session. `/shipkit:handoff` is an inline skill that writes `state.md` from what the
session knows. The compaction reminder reuses the same hook: `SessionStart` fires again after
compaction, and the hook's input says so.

---

## Decision: `state.md` is git-ignored by default   (→ REQ-10, REQ-13)

**Context.** The handoff note is written at the end of a session and read at the start of
the next. It names half-done work and open questions. The owner settled this as A5.

**Alternatives.**
1. Ignored by default: `/shipkit:setup` offers to add it to `.gitignore`; the user may commit
   it anyway.
2. Committed: it follows the user across machines and shows in history.

**Case for (1).** The note is written for the next session on this machine, often with
uncommitted work it describes; committing it would mean a commit every time a session ends,
or a stale note in history. It can mention things that do not belong in the repository
("ask the client about the invoice"). A user who wants it to travel removes the ignore line.

**Case against (1).** A second machine, or a clone, starts without the note, and the
briefing says nothing. Nothing in history shows what was in flight at a given commit.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this — commit it by default — if the owner works on the
same project from a second machine during this plan and loses a handoff to it, or if a user
reports the same.

---

## Decision: A briefing, not a standing team of agents at session start   (→ REQ-1, REQ-9)

**Context.** A session could start by launching agents — one to read the specs, one the
decisions, one the product file — and report. Or the hook could print a few lines of text.

**Alternatives.**
1. A briefing: at most eight lines, at most 800 bytes, from a script that uses no model.
2. A standing team: the main session starts agents at session start to assemble a picture.
3. Nothing at start; the user asks the elders when they want to know.

**Case for (1).** It costs nothing before the task is known: no tokens are spent reading
what the user may not need. It is the same every time and can be tested with fixtures. Every
line names the file it came from, so the model reads more only when it matters. Option 3
leaves the "where was I" question to be asked, which is exactly the question people forget
to ask.

**Case against (2), recorded as the plan asked.** A team costs tokens before the task is
known, on every start including the trivial ones; it loses detail at every handoff from
agent to session; and it depends on agents whose results arrive after the user has started
typing. No feature in this plan depends on an agent starting another agent, and a team at
start would be the first.

**Case against (1).** Eight lines can be wrong in the way a summary is wrong: a spec's "next
task" is the first unticked box, which is not always the next thing to do. The briefing
grows if nobody guards the 800 bytes.

**Decision.** We chose (1), with the byte limit enforced by a smoke check.
**Falsifiability.** We would reverse this — add an agent at start — if, in two sprints of
this plan, the owner records that the briefing led the session to start on the wrong task
because of what the eight lines left out.

---

## Decision: The compaction reminder fires after compaction, not before   (→ REQ-15, REQ-16)

**Context.** The plan asks for a hook that fires before compaction and whose output reaches
the model. The documentation shows `PreCompact` exists, but its stdout and `systemMessage` do
not reach the model; `SessionStart` runs again after compaction with `source: "compact"`,
and that output does.

**Alternatives.**
1. Print the reminder from `session-start.sh` when the hook's input says `"compact"`.
2. Skip the task entirely, as the plan allows.
3. Block compaction from `PreCompact` (exit 2) until a handoff is written.

**Case for (1).** The model sees it at the moment it matters: just after it lost the detail,
when `state.md` is the thing to write or read. It is one `case` in a script that already runs.
Option 3 would stop the user's session from recovering from a full context.

**Case against (1).** The reminder is late: whatever was in flight is already summarised. It
is one more line in a budget of eight.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this — remove the line — if a later Claude Code release
lets a `PreCompact` hook put text in front of the model, at which point the reminder moves
there.

---

## Data / interface changes

- New script `briefing.sh`, called by `session-start.sh` — REQ-1 to REQ-9.
- New skill `/shipkit:handoff` (core goes from 16 to 17 skills) — REQ-10 to REQ-12.
- New file `.shipkit/state.md`, git-ignored by default — REQ-10, REQ-13.
- One new line from the session hook after compaction — REQ-15.
