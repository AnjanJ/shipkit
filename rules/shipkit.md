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

## Commit Discipline

The single source of truth for how shipkit commits. `/shipkit:commit` and the CLAUDE.md
written by `/shipkit:setup` defer to it. Applies to every commit you make, not just ones the
user asks for by name.

**Atomicity (always).** One logical change per commit — one behavior, one fix, or one refactor.
Test and implementation land together. Never `git add .` / `git add -A`; stage the specific
files. Each commit leaves the build/tests green. Never `--no-verify`.

**Message depth scales to the change.** Do not force a template onto a one-liner.

- **Trivial** (version bump, typo, formatting, a one-line doc/config change): a good imperative
  subject line is enough. `chore: bump to 2.2.0`.

- **Substantive** (a feature, fix, refactor, integration, or anything with a decision behind
  it): subject line + a body with these sections. Include a section only when it has real
  content — omit it rather than pad.

  ```
  <type>: <imperative subject, <=72 chars, the WHAT in one line>

  What:  what changed, concretely (the surfaces touched).
  Why:   the problem or goal this serves — the reason it exists.
  How:   the approach, and the decisions made getting there.
         Name alternatives you rejected and why ("chose X over Y because…") —
         this is the highest-value line for a future reader.
  Test plan: how this was verified — commands run and what you observed,
         or why no test applies (docs/config/generated).

  Risk/Rollback: (only if it touches data, config, or prod behavior) what could
         break and how to undo it.
  Follow-ups: (only if the commit deliberately leaves gaps) what's left for later.
  Refs: (only if applicable) #issue / PR / link.
  ```

**Never** add a co-author/`Co-Authored-By` trailer unless the user explicitly asks. Never
amend, squash, or force-push published commits without asking. When on the default branch for
non-trivial work, branch first.
