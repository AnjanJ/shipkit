# Shipkit User Guide

A complete guide to using every skill, agent, and feature in shipkit.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Setup & Unsetup](#setup--unsetup)
3. [The Project Elders](#the-project-elders)
4. [Episodic Memory (MemPalace)](#episodic-memory-mempalace)
5. [Skills Reference](#skills-reference)
6. [Agents](#agents)
7. [Knowledge Bases](#knowledge-bases)
8. [Path-Scoped Rules](#path-scoped-rules)
9. [Common Workflows](#common-workflows)
10. [Tips](#tips)

---

## Getting Started

After installing the plugin, all skills are available as `/shipkit:<skill-name>`. You can start using them immediately — no configuration needed.

```
/shipkit:review-my-code    # review your staged changes
/shipkit:test              # run your tests
/shipkit:qa                # full QA workflow
```

For the best experience, run `/shipkit:setup` once per project to tailor everything to your stack.

---

## Setup & Unsetup

### /shipkit:setup

Configures shipkit for your specific project. Run it once when you start using shipkit in a new codebase.

**What it does:**
1. Snapshots your current `CLAUDE.md` + `.claude/` directory to `.shipkit-backup-<timestamp>/`
2. Detects your stack (Rails, React, Python, Go, Elixir, static)
3. Detects test framework and package manager
4. Asks for your project purpose and team conventions
5. Creates a tailored CLAUDE.md with workflow rules
6. Installs stack-specific skills, rules, and knowledge bases
7. Optionally creates `.claude/settings.json` with safe defaults

**How backups work:**
- Everything is copied to `.shipkit-backup-<YYYYMMDD-HHMMSS>/` at project root
- If an older shipkit backup already exists, you're asked to preserve or delete it
- Preserved old backups are nested inside the new one and restored automatically by `/unsetup`

**Usage:**
```
/shipkit:setup              # auto-detect stack
/shipkit:setup rails        # skip detection, use Rails
/shipkit:setup react        # skip detection, use React
```

**When to run it:**
- First time using shipkit in a project
- After cloning a project that doesn't have a CLAUDE.md
- When switching stacks (run `/shipkit:unsetup` first)

### /shipkit:unsetup

Reverses everything `/setup` did. Restores your project to its pre-shipkit state.

**What it does:**
1. Finds the `.shipkit-backup-<timestamp>/` directory
2. Shows you exactly what will be restored
3. Asks for confirmation before proceeding
4. Removes current `CLAUDE.md` and `.claude/` directory
5. Restores everything from the backup snapshot
6. If the backup contained a nested older backup, restores that too
7. Deletes the backup directory after successful restore

**Usage:**
```
/shipkit:unsetup
```

**When to run it:**
- You want to remove shipkit's project configuration
- Before switching to a different stack (then run `/setup` again)
- Before uninstalling the plugin entirely

**Full removal:**
```
/shipkit:unsetup                     # remove project configuration
/plugin uninstall shipkit@shipkit    # remove the plugin
```

**Note:** If you never ran `/setup`, you don't need `/unsetup`. Just uninstall the plugin directly.

---

## The Project Elders

The elders solve one problem: **answering questions about a project without polluting your main
session's context.** When you ask "how does X work?" the naive path is to read a dozen files into
your main conversation — which then carries that weight for the rest of the session. Instead, an
elder subagent does the reading in *its own* context and hands back only the answer.

### The pieces

| Piece | Role |
|-------|------|
| `PROJECT_MAP.md` | A verified, ~150-line index of one project: architecture, where-things-live, data model, evolution, gotchas. Stamped with the git SHA it was built at. |
| `archivist` agent | Builds and refreshes `PROJECT_MAP.md`. Run via `/shipkit:map`. |
| `grandfather` agent | Answers questions about **one** project. Reads the map, verifies the specific claim against live source, returns a tight cited answer. Run via `/shipkit:ask`. |
| `eve` agent | Answers questions **across all** registered projects (the 360° view). Run via `/shipkit:ask --all`. |
| Registry | `~/.claude/shipkit/project-registry.md` — the list of projects eve reads. Populated by `/shipkit:map --register`. |

### Typical usage

```
# One-time per project: build the map and register it
/shipkit:map --register

# Ask about THIS project (→ grandfather)
/shipkit:ask how does locale fallback work in this monolith?
/shipkit:ask is it safe to remove the legacy_token column?

# Ask across ALL your projects (→ eve)
/shipkit:ask --all which apps deploy to Hetzner vs AWS?
/shipkit:ask --all everywhere I integrate Stripe

# After a big change, refresh the map
/shipkit:map refresh
```

### When to use them — and when not to

- **Use** for research: architecture, "where does X live", "why was this done this way",
  portfolio-wide lookups, deciding whether a change is safe.
- **Do not use** mid-edit for a fact you need right now to keep typing — a subagent round-trip is
  slower than just reading the one file. The elders are read-only; they inform, they do not edit.

### How they stay honest

The map is an *index*, not the final word. When the map and live source disagree, the elders trust
**source** and flag the drift in their answer — so a stale map produces a correction, not a confident
wrong answer. Refresh with `/shipkit:map refresh` when you see drift flagged.

You also get an automatic nudge: a shipkit `SessionStart` hook compares the map's SHA stamp to
HEAD and prints a one-line reminder when the map is ≥20 commits behind (tune with
`SHIPKIT_MAP_STALE_COMMITS`) or when a dependency manifest has changed since it was built. It is
silent otherwise and never blocks a session.

---

## Episodic Memory (MemPalace)

`PROJECT_MAP.md` answers *"how is this built?"*. It cannot answer *"what did we **decide**, and why?"*
— that narrative lives in your past conversations. [MemPalace](https://github.com/mempalace/mempalace)
is an **optional** local-first memory store that fills exactly this gap.

**It is opt-in. ShipKit does not install it for you.** The `grandfather` and `eve` agents allowlist
the `mcp__mempalace__*` tools, so:

- If MemPalace **is** installed and registered → the elders use it for decision-history questions.
- If it is **not** → those tools are simply absent and the elders run fine without it; decision
  questions fall back to git history. Nothing breaks.

Plugin subagents cannot declare their own MCP server (Claude Code ignores inline `mcpServers` for
security), so you register MemPalace **once at user scope** and the elders' `tools:` allowlist grants
it to *only those two agents*. Because Claude Code defers tool schemas by default (tool search), the
~30 MemPalace tools stay **out of your main session's context** until an elder actually calls one —
the thin-context principle is preserved.

### Enabling it

```bash
# 1. Install (puts `mempalace-mcp` on PATH; ~300 MB embedding model downloads on first use)
uv tool install mempalace        # or: pipx install mempalace

# 2. Register once at user scope, then RESTART Claude Code so the server loads
claude mcp add --scope user mempalace mempalace-mcp

# 3. Backfill a project's history from your Claude transcripts.
#    Claude transcripts are keyed by the DIRECTORY you ran Claude in, under ~/.claude/projects/
#    (not by repo name — find the dir whose sessions hold the decisions you want recalled).
mempalace mine ~/.claude/projects/-Users-you-code-myproject --mode convos --wing myproject --dry-run
mempalace mine ~/.claude/projects/-Users-you-code-myproject --mode convos --wing myproject
```

### Concepts

- **Wing** = a project (use one `--wing` per project). **Room** = an auto-classified topic
  (technical / planning / architecture / decisions / problems). **Drawer** = one verbatim chunk.
- **Recall is a claim, not gospel.** The elders treat anything MemPalace returns as a statement that
  was true *when said*, and verify it against current source before stating it — the same discipline
  they apply to the map.

### Troubleshooting

- **Search fails with "malformed inverted index for FTS5 table"** — the full-text index is corrupt.
  `mempalace repair --yes` rebuilds it; if `repair` refuses (SQLite-layer corruption), back up
  `~/.mempalace/palace/chroma.sqlite3`, then run
  `sqlite3 chroma.sqlite3 "INSERT INTO embedding_fulltext_search(embedding_fulltext_search) VALUES('rebuild');"`
  and confirm `PRAGMA integrity_check;` returns `ok`.

---

## Skills Reference

### /shipkit:ask — Ask the Project Elders

Route a question to a research subagent so your main context stays thin. See
[The Project Elders](#the-project-elders) for the full picture.

- `/shipkit:ask <question>` → `grandfather` answers about **this** project.
- `/shipkit:ask --all <question>` → `eve` answers across **all** registered projects.

The agent reads the relevant `PROJECT_MAP.md`, verifies the specific claim against live source
(and queries MemPalace for decision-history questions if installed), and returns a tight, cited
answer. Use it for "how/where/why" research, not for facts you need inline while editing.

### /shipkit:map — Build & Refresh the Project Map

Create or refresh the `PROJECT_MAP.md` that the elders read.

- `/shipkit:map` → build it if absent, refresh it if present.
- `/shipkit:map refresh` → force a re-verification pass against current source.
- `/shipkit:map section <name>` → regenerate one section (e.g. `section evolution`).
- `/shipkit:map --register` → also add the project to `~/.claude/shipkit/project-registry.md`
  so `eve` can include it in cross-project answers.

Run it once per project to start, and `refresh` after a big change (new domain, refactor,
framework upgrade). A stale map makes the elders flag drift — that is your cue to refresh.

### /shipkit:plan — Plan Before You Code

Turns a feature request into a plan before any code is written. Runs **inline** so its
questions and approval checkpoints reach you; the heavy codebase research is delegated to the
`codebase-explorer` agent so it does not weigh down your session.

**Three phases, each with a checkpoint:**
1. **PRD** — probing questions (purpose, users, behaviors, acceptance criteria, edge cases, out of
   scope, constraints) until the requirements are unambiguous. Waits for your approval.
2. **Tech spec** — reads existing code and conventions, then designs the approach against
   scalability, fault tolerance, readability, maintainability, and security.
3. **Atomic task breakdown** — a sequenced list of small, independently testable tasks.

```
/shipkit:plan add team billing with seat-based pricing
/shipkit:plan                         # describe the feature when prompted
```

**Skip it** for renames, typo fixes, config changes, one-liners, or when you just say "just do it."
Pair it with `/shipkit:tdd` to build each task test-first.

### /shipkit:qa — Quality Assurance

5-phase QA workflow that asks probing questions before writing tests.

**Phases:**
1. Reconnaissance — detect test framework, classify changed files by risk
2. Interrogation — ask 3-8 probing questions before writing any tests
3. Test Plan — structured plan organized by category for your approval
4. Spec Writing — one assertion per test, descriptive names, arrange-act-assert
5. Execution — run tests, fix failures, produce QA report

```
/shipkit:qa                              # QA recent changes
/shipkit:qa src/services/payment.ts      # focus on specific file
```

---

### /shipkit:review-my-code — Code Review

Reviews code through 8 lenses with severity levels.

**The 8 lenses:**
1. Clean Code + Single Responsibility
2. DRY (Don't Repeat Yourself)
3. KISS (Keep It Simple)
4. YAGNI (You Aren't Gonna Need It)
5. Language Idioms
6. Framework Patterns + OCP/DIP
7. Performance & Scalability
8. Error Handling

**Severity levels:** BLOCKER, CRITICAL, MAJOR, MINOR, NIT, PRAISE

**Verdict:** APPROVE, REQUEST CHANGES, or NEEDS DISCUSSION

```
/shipkit:review-my-code                          # review staged changes
/shipkit:review-my-code src/billing.ts           # review specific file
/shipkit:review-my-code 142                      # review PR #142
```

---

### /shipkit:test — Run Tests

Auto-detects your test framework and runs tests. Diagnoses failures automatically.

```
/shipkit:test                    # run all tests
/shipkit:test quick              # fast tests only
/shipkit:test specific path/to   # run one test file
/shipkit:test coverage           # with coverage reporting
```

---

### /shipkit:tdd — Test-Driven Development

Enforces the Red-Green-Refactor cycle. No production code without a failing test first.

**Iron Law:** Write the test first. Watch it fail. Write minimal code to pass. Refactor.

Includes rationalization prevention (excuse-to-reality table), red flags list, testing anti-patterns catalog, and a verification checklist.

```
/shipkit:tdd feature       # TDD for a new feature
/shipkit:tdd bugfix        # TDD for a bug fix
/shipkit:tdd refactor      # TDD for refactoring
```

---

### /shipkit:debug — Systematic Debugging

Root-cause debugging with a 4-phase process. No fixes without investigation first.

**Phases:**
1. Root Cause Investigation — read errors, reproduce, trace data flow
2. Pattern Analysis — find working examples, compare
3. Hypothesis and Testing — test one variable at a time
4. Implementation — create failing test, fix root cause, verify

Includes the **three-strike rule:** after 3 failed fixes, stop and question the architecture.

```
/shipkit:debug                                  # general debugging
/shipkit:debug "TypeError in checkout flow"     # describe the error
/shipkit:debug src/services/payment.ts          # debug a specific file
```

---

### /shipkit:humanize — AI Writing Detection

Detects and removes AI-generated writing patterns. Two modes: humanize (rewrite) and analyze (detect only).

Covers 40 patterns across vocabulary, structure, tone, and formatting. Includes a full pattern library reference.

```
/shipkit:humanize                   # humanize provided text
/shipkit:humanize analyze           # detect patterns only, don't rewrite
```

---

### /shipkit:onboard — Codebase Onboarding

5-phase exploration for unfamiliar codebases.

**Phases:**
1. Trace one request/flow end-to-end
2. Map the architecture
3. Analyze git history for hotspots
4. Generate lightweight docs (ARCHITECTURE.md, CODEBASE_MAP.md)
5. Suggest project-specific skills

```
/shipkit:onboard                         # full 5-phase onboarding
/shipkit:onboard zoom-in src/app.ts      # start from specific file
/shipkit:onboard zoom-out                # skip tracing, go to architecture
```

---

### /shipkit:explain-system — System Design Docs

Explores your codebase and writes a verified system design document explaining WHY it's designed the way it is.

```
/shipkit:explain-system                  # full 6-phase explanation
/shipkit:explain-system quick            # phases 1-2 only
/shipkit:explain-system section auth     # regenerate just one section
```

---

### /shipkit:walkthrough — Feature Trace

Traces one feature from entry point through every layer.

```
/shipkit:walkthrough user-registration           # trace by feature name
/shipkit:walkthrough src/controllers/auth.ts     # trace from file
/shipkit:walkthrough checkout surface            # happy path only
/shipkit:walkthrough checkout deep               # include error paths
```

---

### /shipkit:update-rules — Update CLAUDE.md

Adds, updates, or removes rules in CLAUDE.md while maintaining structure.

```
/shipkit:update-rules always use factory_bot, never fixtures
/shipkit:update-rules remove the rule about JIRA references
/shipkit:update-rules add: API responses must include request_id
```

**Never manually edit CLAUDE.md** — use this skill to keep formatting consistent.

---

### /shipkit:context-audit — Context Window Health

Reports what's consuming your context window and suggests optimizations.

```
/shipkit:context-audit
```

Use this when Claude seems to be forgetting things or losing context.

---

### /shipkit:use-library — Documentation-First Library Usage

Reads docs before using any library. Fetches official docs, checks versions, verifies compatibility.

```
/shipkit:use-library redis
/shipkit:use-library @tanstack/react-query
/shipkit:use-library fastapi
```

Will NOT write code until documentation has been read.

---

### /shipkit:ai-feature — AI/LLM Feature Scaffolding

Scaffolds AI features with the right library for your stack.

```
/shipkit:ai-feature chat
/shipkit:ai-feature embeddings
/shipkit:ai-feature rag
/shipkit:ai-feature agent
/shipkit:ai-feature structured-output
```

---

### /shipkit:legacy-audit — Legacy Codebase Audit

Audits for modernization opportunities. Read-only — does not modify files.

```
/shipkit:legacy-audit              # all categories
/shipkit:legacy-audit deps         # dependency age and security
/shipkit:legacy-audit dead-code    # unused files and functions
/shipkit:legacy-audit complexity   # hotspots cross-referenced with git churn
/shipkit:legacy-audit coverage     # test coverage gaps
```

---

### /shipkit:migration-plan — Dependency Migration Planning

Plans major upgrades with impact analysis. Plan only — does not execute.

```
/shipkit:migration-plan rails 7.1 8.0
/shipkit:migration-plan react 18 19
/shipkit:migration-plan webpack vite
```

---

### /shipkit:ui-ux — UI/UX Design & Review

Empathy-driven UI/UX for web and mobile (iOS, Android, Flutter, React Native).

**Modes:**
- **Design** — user flow first, all 5 states, accessibility, mobile, performance
- **Review** — 24-point checklist with severity levels and score
- **Audit** — comprehensive UI/UX evaluation
- **Improve** — identify top 3 improvements and implement them

```
/shipkit:ui-ux design user-onboarding
/shipkit:ui-ux review
/shipkit:ui-ux audit
/shipkit:ui-ux improve src/UserProfile.tsx
```

The `ui-ux` path-scoped rule also auto-loads when editing any UI file, applying core principles without needing to invoke the skill.

---

## Lessons Memory

Shipkit includes a lightweight project memory system via `.claude/lessons.md`.

### How it works

- When you correct Claude or it discovers a project-specific pattern, it writes a one-line entry to `.claude/lessons.md` with the date
- At the start of every session, Claude reads this file to avoid repeating mistakes
- The file has a **30-line limit** — when exceeded, Claude alerts you and suggests consolidating

### Why 30 lines?

Research shows frontier LLMs have a ~150-200 effective instruction limit. CLAUDE.md uses ~130 lines, path-scoped rules add ~15-30 when active. Lessons.md needs to stay small to avoid crowding out useful context. 30 lines gives enough room for project-specific corrections without degrading performance.

### The graduation cycle

```
Correction → lessons.md (short-term memory)
        ↓ repeats
/update-rules → CLAUDE.md (permanent rule)
        ↓ lessons entry removed
```

Lessons that keep recurring should become proper rules via `/shipkit:update-rules`. This keeps lessons.md lean and CLAUDE.md authoritative.

### Example

```markdown
# Lessons Learned

- 2026-03-11: Use `factory_bot` not fixtures — project convention
- 2026-03-11: API responses must include `request_id` header
- 2026-03-12: Don't use `after_save` for email notifications — use a job
```

---

## Agents

Agents are used automatically by skills, or you can reference them in prompts.

### grandfather

Single-project elder. Answers "how/where/why" questions about the current project by reading its
`PROJECT_MAP.md`, verifying the specific claim against live source, and (if MemPalace is installed)
querying decision history. Returns a tight, cited answer so your main context stays thin.

Used by `/shipkit:ask`. See [The Project Elders](#the-project-elders).

### eve

Cross-project elder (named for the common ancestor of the whole portfolio). Answers questions across
**all** registered projects by reading `~/.claude/shipkit/project-registry.md` and each project's map.

Used by `/shipkit:ask --all`.

### archivist

Builds and refreshes the `PROJECT_MAP.md` that grandfather and eve read. Detects the stack, maps
structure and data model, reconstructs evolution from git, collects gotchas, and verifies every cited
path exists before writing. Writes only that one file.

Used by `/shipkit:map`.

### test-analyzer

Diagnoses test failures. Checks for state leakage, timing issues, environment differences, dependency changes, and order-dependent failures.

Used automatically by `/shipkit:test` when tests fail. Or reference directly: "use the test-analyzer agent to diagnose this flaky test."

### codebase-explorer

Read-only exploration agent. Traces call chains, maps directories, analyzes schemas, finds patterns, identifies hotspots.

Used automatically by `/shipkit:onboard` during phases 1-3. Or reference directly: "use the codebase-explorer agent to map the services directory."

Both agents: read-only, cap at 20 files per task, report confidence levels.

---

## Knowledge Bases

Loaded on demand by skills — not always in context.

### code-review-standards

Backs `/shipkit:review-my-code` with detailed criteria for each of the 8 lenses, anti-pattern catalog with smell-to-pattern mapping, and severity definitions.

### ui-ux-standards

Backs `/shipkit:ui-ux` with cross-platform accessibility standards, design principles, platform-specific navigation patterns, performance budgets, and anti-pattern catalog.

### Stack-specific (installed via /setup)

- **code-review-standards-rails** — ActiveRecord performance, Sidekiq best practices, Hotwire consistency
- **ai-rails** — RubyLLM patterns for chat, embeddings, streaming, tool use, testing

---

## Path-Scoped Rules

These auto-load when you edit matching files. No action needed.

| Rule | When It Loads | What It Enforces |
|------|--------------|-----------------|
| `testing` | Test files (`*_test.*`, `*_spec.*`) | Arrange-act-assert, one behavior per test, descriptive names |
| `migrations` | Database migrations | Reversibility, safety checks, rollback strategies |
| `security` | Controllers, API, auth files | Input validation, parameterized queries, no hardcoded secrets |
| `dependencies` | Dependency files (Gemfile, package.json, etc.) | Version constraints, security audits, test suite after changes |
| `monorepo` | Monorepo configs, workspace files | Cross-package testing, dependency hoisting, breaking change paths |
| `ui-ux` | UI files (web + mobile) | Empathy-first design, accessibility, all 5 states, platform conventions |

### Stack-specific rules (installed via /setup)

| Rule | Stack | What It Enforces |
|------|-------|-----------------|
| `rails` | Rails | N+1 prevention, strong params, migration safety, callback patterns |
| `gemfile` | Rails | Pessimistic version constraints, bundle audit |
| `react` | React | Component patterns, hooks rules, TypeScript conventions |
| `package-json` | React | Caret constraints, npm audit, no `*` or `latest` |
| `python` | Python | Virtual env, type hints, ruff/flake8 conventions |
| `pyproject` | Python | Version constraints, pip-audit |
| `go` | Go | Error handling, go vet, golangci-lint conventions |
| `go-mod` | Go | go mod tidy, govulncheck |
| `elixir` | Elixir | Context boundaries, OTP patterns, formatter/Credo |
| `mix-deps` | Elixir | Version constraints, hex audit |

---

## Common Workflows

**Joining a project:**
```
/shipkit:setup  →  /shipkit:onboard  →  /shipkit:explain-system
```

**Building a feature (with TDD):**
```
/shipkit:plan <feature>  →  /shipkit:ui-ux design <feature>  →  /shipkit:tdd  →  /shipkit:qa  →  /shipkit:test
```

**Adding a dependency:**
```
/shipkit:use-library <name>  →  write code  →  /shipkit:test
```

**Debugging a bug:**
```
/shipkit:debug  →  /shipkit:tdd bugfix  →  /shipkit:test
```

**Pre-PR checklist:**
```
/shipkit:test  →  /shipkit:review-my-code  →  /shipkit:humanize (for docs/PR description)
```

**Modernizing a legacy codebase:**
```
/shipkit:legacy-audit  →  /shipkit:migration-plan <dep> <old> <new>  →  execute  →  /shipkit:test
```

**Leaving shipkit:**
```
/shipkit:unsetup  →  /plugin uninstall shipkit@shipkit
```

---

## Tips

1. **Interactive skills pause at checkpoints.** Inline skills like `/shipkit:plan` and `/shipkit:qa` stop between phases for your input — don't skip these. Research skills (`/shipkit:onboard`, `/shipkit:walkthrough`, `/shipkit:explain-system`) instead run end-to-end in a forked context and return their findings; any file they propose is only written after you approve it.

2. **Use `/clear` between skills.** Each skill works best with a fresh context window.

3. **Skills adapt to your stack.** You don't need to specify your test framework or language — skills detect it automatically.

4. **Arguments are optional.** Every skill has sensible defaults. Add arguments only to narrow scope.

5. **Path-scoped rules are automatic.** You don't invoke them — they load when you edit matching files.

6. **Stack-specific content needs /setup.** Base skills and rules work instantly. Stack-specific skills (like `/new-feature` for Rails) require running `/shipkit:setup` first.
