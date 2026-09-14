---
description: "Configure shipkit for your project"
user-invocable: true
argument-hint: "[rails|react|python|go|elixir|static]"
---

<!-- Runs INLINE (no context: fork) on purpose: this skill interviews the user
     (stack confirmation, project purpose, backup decisions) and forked skills
     cannot use AskUserQuestion. It runs once per project; the context cost is fine. -->

# /setup — Configure Shipkit for Your Project

Tailor shipkit to your specific project. Detects your stack, test framework, package manager,
installs shipkit's rules as files, and installs stack-specific skills, rules, and knowledge bases.

**This skill is optional.** Shipkit's skills, agents and session hook work without it. Run this
when you want the rules installed in the project (the path-scoped ones only work this way) and
stack-specific configuration.

## Phase 0: Locate the plugin

Everything this skill installs is copied from the plugin's own directory. Find it, in order:

1. The context line `shipkit: plugin root is <path>` printed by the shipkit session hook at the
   start of this session. Use that path.
2. Else read `~/.claude/shipkit/plugin-root` (the hook also writes it there).
3. Else stop and tell the user: "The shipkit session hook has not run yet — restart Claude Code
   (or start a new session) and run `/shipkit:setup` again." Do not guess a path.

Call it `<root>` below. Sanity-check it: `<root>/rules/shipkit.md` and `<root>/stacks/` must exist.

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
   - **Workflow style** — how strict should the coding workflow be?
     - `strict-tdd` — iron-law red-green-refactor for every change (`/shipkit:tdd`)
     - `test-first` (default) — prefer test-before-implementation, pragmatic exceptions
     - `lightweight` — tests where they earn their keep; you decide when
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

Read @reference.md for the full CLAUDE.md template. The template includes: Project Info, Workflow Rules (plan mode, subagents, verification, bug fixing, core principles, library usage), Conventions (commits, destructive operations, general), and a placeholder for stack-specific sections from Phase 5.

## Phase 4: Install Shipkit's Rules

Claude Code does not load rules from a plugin, only from a project's `.claude/rules/`
(discovered recursively, path-scoped rules included). Without this phase, the always-on rules
reach a session only through the hook's injection and the path-scoped rules never load at all.

Copy all nine files from `<root>/rules/` into `.claude/rules/shipkit/`, unchanged:

| File | Kind |
|------|------|
| `shipkit.md` | always-on — default workflow, commit discipline, lessons memory |
| `spec-driven.md` | always-on — the three questions, EARS |
| `decisions.md` | always-on — five-part decision records |
| `testing.md`, `migrations.md`, `security.md`, `dependencies.md`, `monorepo.md`, `ui-ux.md` | path-scoped (their `paths:` frontmatter stays as is) |

Once `.claude/rules/shipkit/` exists the session hook stops injecting the always-on rules, so
nothing loads twice. Tell the user these are copies: re-run `/shipkit:setup` after a plugin
upgrade to refresh them.

## Phase 5: Install Stack-Specific Content

Source: `<root>/stacks/<stack>/`. Each stack directory has the same shape:

| Source (under `<root>/stacks/<stack>/`) | Destination in the project |
|------|------|
| `CLAUDE.md.append` | appended to `CLAUDE.md` (the stack-specific section) |
| `.claude/rules/*.md` | `.claude/rules/shipkit/<stack>/` |
| `.claude/skills/<name>/` | `.claude/skills/<name>/` (workflow skills and on-demand knowledge bases alike) |

Copy the files, then **substitute every `{{PLACEHOLDER}}`** in what you copied. The
placeholders and where their values come from:

| Placeholder | Value |
|-------------|-------|
| `{{TEST_COMMAND}}` | the detected test command (e.g. `bundle exec rspec`, `npm test`, `pytest`, `go test ./...`, `mix test`) |
| `{{TEST_FRAMEWORK}}` | RSpec / Minitest / Jest / Vitest / pytest / unittest / ExUnit |
| `{{DATABASE}}` | from `config/database.yml` / env: PostgreSQL / MySQL / SQLite |
| `{{RAILS_ARCHITECTURE}}` | `app/commands/` or `app/queries/` → CQRS; `app/services/` → Service Objects; else MVC |
| `{{API_MODE}}` | `config.api_only = true` in `config/application.rb` → yes, else no |
| `{{FRONTEND}}` | Hotwire (turbo-rails/stimulus in Gemfile/package.json) / React / API-only |
| `{{PYTHON_FRAMEWORK}}` | Django / FastAPI / Flask / None, from dependencies |
| `{{API_STYLE}}` | REST / GraphQL / gRPC, from dependencies and routes |
| `{{ASYNC_MODE}}` | yes if the framework or code uses `async def`, else no |
| `{{ORM}}` | Django ORM / SQLAlchemy / Tortoise, from dependencies |
| `{{GO_FRAMEWORK}}` | stdlib net/http / Gin / Echo / Chi / Fiber, from `go.mod` |
| `{{MODULE_PATH}}` | the `module` line of `go.mod` |
| `{{DB_LIBRARY}}` | database/sql / sqlx / GORM / ent, from `go.mod` |
| `{{ELIXIR_FRAMEWORK}}` | Phoenix (if `:phoenix` in `mix.exs`) / bare Elixir |
| `{{ELIXIR_FRONTEND}}` | LiveView / API-only / SPA, from `mix.exs` and `lib/*_web/` |
| `{{REACT_PATTERN}}` | Functional components (default) / Class components |
| `{{STATE_MANAGEMENT}}` | Zustand / Redux / Context / None, from `package.json` |
| `{{STYLING}}` | Tailwind / CSS Modules / styled-components, from config files and `package.json` |
| `{{ROUTER}}` | React Router / Next.js / Expo Router, from `package.json` |
| `{{BUNDLER}}` | None / Vite / Webpack / Parcel, from `package.json` |
| `{{DEV_SERVER}}` | None / `npx serve` / `vite dev`, from `package.json` scripts |

Rules for substitution:
- Replace **every** occurrence, in `CLAUDE.md` and in every installed skill and rule.
- If you cannot detect a value, write `TODO: <the hint from the HTML comment next to it>` — never
  leave the braces.
- Finish with `grep -rn '{{' CLAUDE.md .claude/` — it must print nothing. If it does, fix those
  before moving on.

What each stack installs:

| Stack | Skills | Rules | Knowledge bases (skills with `user-invocable: false`) |
|-------|--------|-------|---------|
| Rails | `/new-feature`, `/release`, `/safety-check`, `/deploy-check` | `gemfile.md`, `rails.md` | `code-review-standards-rails`, `ai-rails` |
| React | `/component` | `package-json.md`, `react.md` | — |
| Python | `/new-feature` | `pyproject.md`, `python.md` | — |
| Go | `/new-feature` | `go-mod.md`, `go.md` | — |
| Elixir | `/new-feature` | `mix-deps.md`, `elixir.md` | — |
| Static | `/audit` | — | — |

## Phase 6: Create Lessons File

If `.claude/lessons.md` doesn't already exist, create it:

```markdown
# Lessons Learned

<!-- Shipkit auto-manages this file. Limit: 30 lines. -->
<!-- When this file exceeds 30 lines, graduate recurring lessons to CLAUDE.md via /update-rules. -->
<!-- Format: one line per lesson, dated. -->
```

If it already exists, leave it as-is (it was backed up in Phase 2).

## Phase 7: Install Settings (Optional)

Ask the user if they want `.claude/settings.json` with safe defaults. See @reference.md for settings details and enterprise mode options.

## Phase 8: Summary

Report what was installed:
- Backup location (`.shipkit-backup-<ts>/`)
- CLAUDE.md line count
- Stack detected
- Shipkit rules installed under `.claude/rules/shipkit/` (list the 9 files) — note the hook will
  no longer inject the always-on ones
- Stack skills, rules, knowledge bases installed (with their paths)
- Placeholder check result (`grep -rn '{{'` was empty)
- Lessons file created/preserved
- Settings created (if applicable)

Suggest next steps:
1. Try `/shipkit:map --register`, `/shipkit:ask`, `/qa`
2. Use `/update-rules` to add project-specific rules
3. Use `/context-audit` to check context usage
4. When I learn something project-specific, I'll save it to `.claude/lessons.md` (30-line limit — recurring lessons graduate to CLAUDE.md rules)
5. **Want the elders to recall past decisions** ("why did we pick X?")? Run `/shipkit:connect-memory` to set up optional episodic memory (MemPalace). Skip it and the elders fall back to git history — nothing breaks.
6. Run `/unsetup` anytime to restore your previous configuration
