# Shipkit

- If `.claude/lessons.md` exists, read it at session start. On corrections, append a dated one-liner. Alert user at 30 lines to consolidate via `/shipkit:update-rules`.
- If no CLAUDE.md exists and user asks about project setup, suggest `/shipkit:setup`.

## Default Coding Workflow

This section is the single source of truth for the shipkit workflow — `/shipkit:tdd` and
the CLAUDE.md written by `/shipkit:setup` defer to it.

**Workflow style.** If the project's CLAUDE.md declares a `Workflow style:` (set by
`/shipkit:setup`), honor it:
- `strict-tdd` — iron-law red-green-refactor; follow `/shipkit:tdd` for every change.
- `test-first` — the default below.
- `lightweight` — plan and implement; write tests where they earn their keep, when the user wants them.

**The default (`test-first`).** When the user asks to build, add, implement, or change
something — assess first:

**Non-trivial work** (new features, refactors, integrations, architectural changes):
1. **Plan first** — enter plan mode; clarify requirements, design the approach, break into atomic tasks. Delegate heavy codebase research to `codebase-explorer`.
2. **Execute task by task** — prefer writing the test before the implementation; one atomic commit per task (test + implementation together).

**Trivial work** (renames, typo fixes, config changes, one-liners, or user says "just do it"):
- Skip planning. Implement, with a covering test where one makes sense.

Skipping tests is reasonable for config, docs, generated code, or throwaway prototypes — say
so when you skip, don't skip silently.

For user-facing features, prefer behavior-focused (BDD-style) tests: describe what the user
experiences, not how the code works.
