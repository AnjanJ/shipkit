---
description: "Leave a note for the next session: what is in flight, what got done, the one next step, open questions and traps, in .shipkit/state.md (30 lines). TRIGGER when: the user is wrapping up or pausing with unfinished spec work or uncommitted changes. DO NOT TRIGGER when: the session only did trivial work, or nothing is in flight."
user-invocable: true
argument-hint: "[anything the note must not miss]"
---

<!-- Runs INLINE (no context: fork) on purpose: the note is written from what THIS session
     knows, which a forked agent cannot see. It asks nothing unless the next step is unclear. -->

# /shipkit:handoff — Leave a Note for the Next Session

The next session — tomorrow's, or this one after its context is compacted — starts blank.
Write it the note you would want: what is half done and where, what got finished, the single
next thing to do, what only the user can answer, and the traps found on the way. The session
hook's briefing quotes the "Next step" line at every start.

From the user (optional): $ARGUMENTS

## Procedure

1. **Gather, do not ask.** Everything the note needs is already in front of you:
   - this conversation: what was worked on, what was finished, what was found;
   - `git status --porcelain` and `git diff --stat` for what is uncommitted, and
     `git log --oneline -5` for what was committed this session;
   - the open specs' `tasks.md` for which task was in progress.
   Ask the user one question **only** if, after that, you cannot say what the next step is.
   Do not ask about anything else.

2. **Write `.shipkit/state.md`**, replacing any earlier one, in exactly this shape:

   ```markdown
   # Handoff

   > Written 2026-10-06 at commit `a1b2c3d` on feature/refunds.

   ## In flight
   - <what is half done, and in which files — or "Nothing">

   ## Done this session
   - <what was finished, one line each>

   ## Next step
   <exactly one line: the very next thing to do, concrete enough to start on>

   ## Open questions
   - <things only the user can answer — or "None">

   ## Do not forget
   - <traps found this session: a flaky test, a command that must run first — or "None">
   ```

   The five headings, in this order, all present. **Exactly one line under "Next step"** — the
   briefing prints it, so it must stand alone. **At most 30 lines in all**: this is a note,
   not a diary. Each "In flight" line names the files, so the next session can open them.
   The commit sha is `git rev-parse --short HEAD`; the branch is `git branch --show-current`
   (or `detached` when there is none).

3. **Tell the user** in two or three lines: that the note is written, the next step as written,
   and any open question. Do not paste the note back.

## Guardrails

- Replace, never append: the note describes now, not history. History is in git.
- One next step. If two things come next, pick the one to do first and put the other under
  "In flight".
- Write only what this session knows. Do not invent progress and do not soften a failure: a
  test that is still red goes under "In flight" or "Do not forget", as it is.
- Never commit, stage or change any other file. `state.md` is git-ignored by default
  (`/shipkit:setup` offers to add it); the user decides whether it travels.
- When no user is present (a non-interactive run), use what the request says and ask nothing;
  if the next step is still unclear, write "Decide the next step: <the two candidates>" as the
  one line.
