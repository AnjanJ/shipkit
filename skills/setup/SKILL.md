---
description: "Configure shipkit for your project"
user-invocable: true
argument-hint: "[rails|react|python|go|elixir|static]"
context: fork
agent: general-purpose
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

## Phase 2: Backup Current State

Before writing ANY files, snapshot the current state so `/unsetup` can restore it.

### Step 1: Check for existing backup

Look for any existing `.shipkit-backup-*` directory at the project root.

If one exists, ask the user:
> "Found an existing shipkit backup from `<timestamp>`. Do you want to preserve it or delete it?"

- **Preserve:** The old backup will be saved inside the new backup directory (as `previous-backup/`), so `/unsetup` restores everything including the old backup.
- **Delete:** Remove the old backup directory before proceeding.

### Step 2: Create the backup directory

Create `.shipkit-backup-<YYYYMMDD-HHMMSS>/` at the project root.

### Step 3: Snapshot everything

Copy the following into the backup directory (only files/dirs that exist):
- `CLAUDE.md` → `.shipkit-backup-<ts>/CLAUDE.md`
- `.claude/` (entire directory) → `.shipkit-backup-<ts>/.claude/`

If the user chose to preserve an existing backup (Step 1), move it into:
- `.shipkit-backup-<ts>/previous-backup/` (the entire old `.shipkit-backup-*` directory)

Then delete the old backup from the project root (it now lives inside the new one).

### Step 4: Confirm to user

Tell the user:
> "Backed up current state to `.shipkit-backup-<ts>/`. You can restore it anytime with `/unsetup`."

## Phase 3: Create CLAUDE.md

Read @reference.md for the full CLAUDE.md template. The template includes: Project Info, Workflow Rules (plan mode, subagents, verification, bug fixing, core principles, library usage), Conventions (commits, destructive operations, general), and a placeholder for stack-specific sections from Phase 4.

## Phase 4: Install Stack-Specific Content

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

## Phase 5: Create Lessons File

If `.claude/lessons.md` doesn't already exist, create it:

```markdown
# Lessons Learned

<!-- Shipkit auto-manages this file. Limit: 30 lines. -->
<!-- When this file exceeds 30 lines, graduate recurring lessons to CLAUDE.md via /update-rules. -->
<!-- Format: one line per lesson, dated. -->
```

If it already exists, leave it as-is (it was backed up in Phase 2).

## Phase 6: Install Settings (Optional)

Ask the user if they want `.claude/settings.json` with safe defaults. See @reference.md for settings details and enterprise mode options.

## Phase 7: Summary

Report what was installed:
- Backup location (`.shipkit-backup-<ts>/`)
- CLAUDE.md line count
- Stack detected
- Skills, rules, knowledge bases installed
- Lessons file created/preserved
- Settings created (if applicable)

Suggest next steps:
1. Try `/qa`, `/review-my-code`, `/test`
2. Use `/update-rules` to add project-specific rules
3. Use `/context-audit` to check context usage
4. When I learn something project-specific, I'll save it to `.claude/lessons.md` (30-line limit — recurring lessons graduate to CLAUDE.md rules)
5. Run `/unsetup` anytime to restore your previous configuration
