# Shipkit

- If `.claude/lessons.md` exists, read it at session start. On corrections, append a dated one-liner. Alert user at 30 lines to consolidate via `/shipkit:update-rules`.
- If no CLAUDE.md exists and user asks about project setup, suggest `/shipkit:setup`.

## Default Coding Workflow

When the user asks to build, add, implement, or change something — assess first:

**Non-trivial work** (new features, refactors, integrations, architectural changes):
1. **Plan first** — clarify requirements (PRD), design the approach (tech spec), break into atomic tasks (sprint plan). Use `/plan`.
2. **Then execute each task with TDD** — for each planned task: write a failing test (red) → make it pass (green) → refactor → atomic commit.
3. **Repeat** until all tasks complete.

**Trivial work** (renames, typo fixes, config changes, one-liners, or user says "just do it"):
- Skip planning. Write the test first, implement, commit.

Skip TDD only for: config changes, docs, generated code, or throwaway prototypes — and only if the user agrees.

For user-facing features, write BDD-style tests: describe what the user experiences, not how the code works. This is not optional.
