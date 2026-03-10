# Shipkit User Guide

A complete guide to using every skill, agent, and feature in shipkit.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Setup & Unsetup](#setup--unsetup)
3. [Skills Reference](#skills-reference)
4. [Agents](#agents)
5. [Knowledge Bases](#knowledge-bases)
6. [Path-Scoped Rules](#path-scoped-rules)
7. [Common Workflows](#common-workflows)
8. [Tips](#tips)

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
1. Detects your stack (Rails, React, Python, Go, Elixir, static)
2. Detects test framework and package manager
3. Asks for your project purpose and team conventions
4. Creates a tailored CLAUDE.md with workflow rules
5. Installs stack-specific skills, rules, and knowledge bases
6. Optionally creates `.claude/settings.json` with safe defaults

**What it backs up:**
- Existing `CLAUDE.md` → `CLAUDE.md.pre-shipkit`
- Existing `.claude/settings.json` → `.claude/settings.json.pre-shipkit`
- Creates `.claude/shipkit-manifest.json` tracking every file it creates

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
1. Reads the manifest (`.claude/shipkit-manifest.json`)
2. Shows you exactly what will be removed and restored
3. Asks for confirmation before proceeding
4. Restores `CLAUDE.md` and `settings.json` from backups
5. Deletes only files that `/setup` created — never touches your own files
6. Cleans up empty directories and the manifest itself

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

## Skills Reference

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

## Agents

Agents are used automatically by skills, or you can reference them in prompts.

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

**Building a feature:**
```
/shipkit:ui-ux design <feature>  →  write code  →  /shipkit:qa  →  /shipkit:test
```

**Adding a dependency:**
```
/shipkit:use-library <name>  →  write code  →  /shipkit:test
```

**Pre-PR checklist:**
```
/shipkit:test  →  /shipkit:review-my-code
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

1. **Skills pause at checkpoints.** Multi-phase skills like `/shipkit:onboard` and `/shipkit:qa` stop between phases for your input. Don't skip these.

2. **Use `/clear` between skills.** Each skill works best with a fresh context window.

3. **Skills adapt to your stack.** You don't need to specify your test framework or language — skills detect it automatically.

4. **Arguments are optional.** Every skill has sensible defaults. Add arguments only to narrow scope.

5. **Path-scoped rules are automatic.** You don't invoke them — they load when you edit matching files.

6. **Stack-specific content needs /setup.** Base skills and rules work instantly. Stack-specific skills (like `/new-feature` for Rails) require running `/shipkit:setup` first.
