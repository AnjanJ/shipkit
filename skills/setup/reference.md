# Setup — Reference Material

## CLAUDE.md Template

Write a CLAUDE.md with this structure:

```markdown
# {project-name}

## Project Info

- **Purpose:** {project purpose or "TODO: describe what this project does"}
- **Stack:** {detected stack}
- **Language:** {language}
- **Test framework:** {detected framework}
- **Test command:** `{detected command}`
- **Lint command:** `{detected command}`
- **Build command:** `{detected command}`

Detailed conventions, platform rules, and review standards live in `.claude/rules/` and `.claude/knowledge/` — read them on demand, not upfront.

---

## Workflow Rules

### 1. Plan Before Coding
For non-trivial work, plan first: clarify requirements (PRD), design the approach (tech spec),
break into atomic tasks (sprint plan). Use `/plan` or enter plan mode.
For trivial fixes (rename, typo, config, one-liner), skip planning and code directly.

### 2. Subagent Strategy
Use subagents only for atomic, well-defined tasks (search, test run, file analysis).
Keep all reasoning and decision-making in the main session — never split thinking across agents.

### 3. Default Coding Workflow
When adding a feature, fixing a bug, or changing behavior — follow this cycle automatically:
1. **Write a failing test first** (red) — one test for one behavior. BDD-style for user-facing features.
2. **Make it pass** (green) — simplest code that passes. Nothing extra.
3. **Refactor** — clean up while tests stay green.
4. **Commit** — atomic commit: this test + its implementation. Tests must pass.
5. **Repeat** — next behavior, next test.
Skip TDD only for config, docs, generated code, or prototypes — with user agreement.

### 4. Verification Before Done
Never say "done" without proving it works:
- Code change → run tests
- Bug fix → reproduce before/after
- New feature → run the feature + related tests
- Refactor → full test suite passes
- Before any commit → suggest running `/review-my-code` to catch issues early

### 5. Autonomous Bug Fixing
When tests fail, read the error, read the source, fix the root cause.
Don't ask the user what to do — investigate and fix. Only ask if genuinely stuck.

### 6. Core Principles
- Simplicity first — the right amount of complexity is the minimum needed
- No laziness — never skip tests, never leave TODOs, never stub implementations
- Minimal impact — change only what's necessary, don't refactor neighbors
- When corrected, update CLAUDE.md or `.claude/lessons.md` so the mistake doesn't repeat
- If an approach isn't working after 2-3 attempts, stop and reconsider

### 7. Library Usage
When using ANY library or API you haven't used in this session, read its documentation first.
Use the `/use-library` skill or WebFetch. Never guess at an API — always verify against current docs.

---

## Conventions

### Commits
- Atomic commits — one passing test + its implementation, one refactor, or one fix per commit
- Each commit must leave tests passing — never commit broken tests
- Imperative mood, explain the "why" not the "what"
- Never add a co-author signature unless explicitly told to
- Never amend or squash published commits without asking
- Stage specific files — never `git add .` or `git add -A`

### Destructive Operations — ALWAYS Ask First
These actions require explicit user confirmation every time:
- **Database:** dropping tables, removing columns, changing column types, deleting migrations — present a rollback strategy before executing
- **Files:** deleting files, `rm -rf`, overwriting uncommitted changes
- **Secrets:** never stage or commit `.env`, credentials, private keys, or API tokens
- **Git:** force push, reset --hard, amending published commits, deleting branches
- **Dependencies:** never upgrade a major version (e.g., Rails 7→8, React 18→19) without asking
- **External APIs:** warn before making calls that could cost money or hit rate limits

### General
- Prefer editing existing files over creating new ones
- Always run tests after changes — never skip, never `--no-verify`
- Use `/update-rules` to modify this file — never edit manually
{team conventions if provided}

{stack-specific section — see Phase 4}
```

## Phase 6: Settings Defaults

Ask the user: "Want me to create `.claude/settings.json` with safe defaults? (allows test/lint/build, denies destructive ops)"

If yes, create `.claude/settings.json` with:
- Allow: test command, lint command, build command, git read commands
- Deny: `rm -rf`, force push, hard reset, clean -f, reading .env files

Also ask: "Enterprise mode? (also blocks curl, docker, cloud CLIs, secrets files)" — if yes, add the extended deny list.
