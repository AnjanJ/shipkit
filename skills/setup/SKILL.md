---
description: "Configure shipkit for your project — detect stack, fill CLAUDE.md, install stack-specific skills and rules"
user-invocable: true
argument-hint: "[rails|react|python|go|elixir|static]"
---

# /setup — Configure Shipkit for Your Project

Tailor shipkit to your specific project. Detects your stack, test framework, package manager, and installs stack-specific skills, rules, and knowledge bases.

**This skill is optional.** Shipkit works out of the box without setup. Run this when you want stack-specific configuration.

## Phase 1: Detect Project

1. **Detect stack** from `$ARGUMENTS` or by reading project files:
   - `Gemfile` → Rails
   - `mix.exs` → Elixir
   - `go.mod` → Go
   - `manage.py` or `pyproject.toml` with django/fastapi/flask → Python
   - `package.json` with `"react"` → React
   - `index.html` or `package.json` → Static
   - Ask the user if ambiguous

2. **Detect test framework:**
   - Rails: RSpec (if in Gemfile) or Minitest
   - React: Vitest (if in package.json) or Jest
   - Python: pytest (if in pyproject.toml/requirements.txt) or unittest
   - Go: `go test`
   - Elixir: ExUnit
   - Static: none

3. **Detect package manager:**
   - Node: bun.lockb→bun, pnpm-lock.yaml→pnpm, yarn.lock→yarn, else npm
   - Python: uv.lock→uv, poetry.lock→poetry, Pipfile.lock→pipenv, else pip

4. **Ask the user:**
   - One-line project purpose (e.g., "SaaS billing platform for freelancers")
   - Branch naming prefix (e.g., `feature/`, `JIRA-123-`) — optional
   - PR description preference: summary+test plan, minimal, or none — optional

## Phase 1.5: Create Backup Manifest

Before writing ANY files, record the current state so `/unsetup` can restore it:

1. Create `.claude/shipkit-manifest.json` with:
   ```json
   {
     "installed_at": "ISO timestamp",
     "stack": "detected stack",
     "had_claude_md": true/false,
     "files_created": [],
     "files_modified": []
   }
   ```
2. If `CLAUDE.md` exists, back it up to `CLAUDE.md.pre-shipkit`
3. If `.claude/settings.json` exists, back it up to `.claude/settings.json.pre-shipkit`
4. As you create/modify files in later phases, add each path to the manifest's `files_created` or `files_modified` arrays

## Phase 2: Create CLAUDE.md

If no CLAUDE.md exists, create one. If one exists, back it up to `CLAUDE.md.pre-shipkit` (already done in Phase 1.5) and ask before overwriting.

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

### 1. Plan Mode Default
Enter plan mode for any task requiring 3+ steps. Spend 80% of effort in planning.
For simple fixes (typo, one-line change), skip planning and just do it.

### 2. Subagent Strategy
Use subagents only for atomic, well-defined tasks (search, test run, file analysis).
Keep all reasoning and decision-making in the main session — never split thinking across agents.

### 3. Verification Before Done
Never say "done" without proving it works:
- Code change → run tests
- Bug fix → reproduce before/after
- New feature → run the feature + related tests
- Refactor → full test suite passes
- Before any commit → suggest running `/review-my-code` to catch issues early

### 4. Autonomous Bug Fixing
When tests fail, read the error, read the source, fix the root cause.
Don't ask the user what to do — investigate and fix. Only ask if genuinely stuck.

### 5. Core Principles
- Simplicity first — the right amount of complexity is the minimum needed
- No laziness — never skip tests, never leave TODOs, never stub implementations
- Minimal impact — change only what's necessary, don't refactor neighbors
- When corrected, update CLAUDE.md or `.claude/lessons.md` so the mistake doesn't repeat
- If an approach isn't working after 2-3 attempts, stop and reconsider

### 6. Library Usage
When using ANY library or API you haven't used in this session, read its documentation first.
Use the `/use-library` skill or WebFetch. Never guess at an API — always verify against current docs.

---

## Conventions

### Commits
- Small, atomic commits — one logical change per commit
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

{stack-specific section — see Phase 3}
```

## Phase 3: Install Stack-Specific Content

Based on detected stack, install the appropriate additions:

### Rails
- Append Rails-specific section to CLAUDE.md (architecture, key paths, testing, gotchas, database)
- Install stack-specific rules: `gemfile.md` (Gemfile/gemspec patterns), `rails.md` (always-on Rails conventions)
- Install stack-specific skills: `/new-feature` (scaffold Rails class), `/release` (release workflow), `/safety-check` (security audit), `/deploy-check` (pre-deploy checklist)
- Install knowledge bases: `code-review-standards-rails` (ActiveRecord, Sidekiq, Hotwire checks), `ai-rails` (RubyLLM patterns)

### React
- Append React-specific section to CLAUDE.md (component patterns, state, testing, TypeScript)
- Install rules: `package-json.md`, `react.md`
- Install skills: `/component` (scaffold React component)

### Python
- Append Python-specific section to CLAUDE.md (framework, virtual env, testing, type hints)
- Install rules: `pyproject.md`, `python.md`
- Install skills: `/new-feature` (scaffold Python module)

### Go
- Append Go-specific section to CLAUDE.md (project layout, error handling, testing, tooling)
- Install rules: `go-mod.md`, `go.md`
- Install skills: `/new-feature` (scaffold Go package)

### Elixir
- Append Elixir-specific section to CLAUDE.md (contexts, testing, OTP, deployment)
- Install rules: `mix-deps.md`, `elixir.md`
- Install skills: `/new-feature` (scaffold Elixir module)

### Static
- Append static-specific section to CLAUDE.md (structure, tooling, deployment)
- Install skills: `/audit` (SEO, a11y, performance)

## Phase 4: Install Settings (Optional)

Ask the user: "Want me to create `.claude/settings.json` with safe defaults? (allows test/lint/build, denies destructive ops)"

If yes, create `.claude/settings.json` with:
- Allow: test command, lint command, build command, git read commands
- Deny: `rm -rf`, force push, hard reset, clean -f, reading .env files

Also ask: "Enterprise mode? (also blocks curl, docker, cloud CLIs, secrets files)" — if yes, add the extended deny list.

## Phase 5: Summary

Report what was installed:
- CLAUDE.md line count
- Stack detected
- Skills, rules, knowledge bases installed
- Settings created (if applicable)

Suggest next steps:
1. Try `/qa`, `/review-my-code`, `/test`
2. Use `/update-rules` to add project-specific rules
3. Use `/context-audit` to check context usage
