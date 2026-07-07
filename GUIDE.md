# Shipkit User Guide

A complete guide to using every skill, agent, and feature in shipkit.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [How Shipkit Works](#how-shipkit-works) — automatic vs. invoked
3. [Setup & Unsetup](#setup--unsetup)
4. [The Project Elders](#the-project-elders)
5. [Episodic Memory (MemPalace)](#episodic-memory-mempalace)
6. [Skills Reference](#skills-reference)
7. [Spec-Driven Development](#spec-driven-development)
8. [Lessons Memory](#lessons-memory)
9. [Agents](#agents)
10. [Knowledge Bases](#knowledge-bases)
11. [Path-Scoped Rules](#path-scoped-rules) — automatic + always-on
12. [Common Workflows](#common-workflows)
13. [Tips](#tips)

---

## Getting Started

After installing the plugin, all skills are available as `/shipkit:<skill-name>`. You can start using them immediately — no configuration needed.

```
/shipkit:map --register    # build this project's PROJECT_MAP.md + register it
/shipkit:ask <question>    # ask the elders about this project (or --all, portfolio-wide)
/shipkit:qa                # full QA workflow
```

For the best experience, run `/shipkit:setup` once per project to tailor everything to your stack
and pick a workflow style.

---

## How Shipkit Works

Shipkit has three kinds of behavior. Most confusion ("do I have to run something?") disappears
once you know which is which.

| Kind | Fires… | Your action |
|------|--------|-------------|
| 🟢 **Automatic** (rules + hooks) | On its own — when you edit a file, do certain work, or start a session | None |
| 🔵 **Auto-invoked** (skills with `TRIGGER when:`) | When your request matches the skill | None, or invoke by name to force |
| ⚪ **You invoke** (research/one-shot skills) | When you type `/shipkit:<name>` | Call it deliberately |

### 🟢 Automatic — no command needed

These are always on once the plugin is loaded. You never call them.

| What | When it fires | What it does |
|------|--------------|--------------|
| **Path-scoped rules** | You edit a matching file (test, migration, controller, dependency file, UI, monorepo config) | Applies that file type's conventions — see [Path-Scoped Rules](#path-scoped-rules) |
| **`spec-driven` rule** | You start **non-trivial** feature work | Puts the three questions (what/how/done) + EARS + TDD-first in effect — see [Spec-Driven Development](#spec-driven-development) |
| **`decisions` rule** | You make a real choice (≥2 alternatives) | Prompts a five-part decision record with a falsifiability clause |
| **Commit discipline** | Any commit | Atomic commits, message scaled to the change, no `git add .`, no `--no-verify` |
| **Lessons memory** | You correct Claude / a project pattern emerges | Appends a dated line to `.claude/lessons.md` (30-line cap) — see [Lessons Memory](#lessons-memory) |
| **Freshness hook** | Session start | One line if `PROJECT_MAP.md` or a spec has drifted from the code; silent otherwise |

### 🔵 Auto-invoked — Claude picks the right skill

Every shipkit skill is model-invocable. The ones below carry `TRIGGER when: / DO NOT TRIGGER
when:` guidance, so Claude runs them when your request matches — you don't have to remember they
exist. You can still invoke any by name to force it.

| Skill | Auto-fires when you… |
|-------|---------------------|
| `/shipkit:spec` | ask to build/design a non-trivial feature before coding |
| `/shipkit:decide` | make a project-wide choice with real alternatives |
| `/shipkit:commit` | ask to commit, or reach a natural commit point |
| `/shipkit:debug` | hit a failing test or a bug to root-cause |
| `/shipkit:tdd` | explicitly ask for strict red-green-refactor |
| `/shipkit:ai-feature` | ask to add AI/LLM functionality (chat, RAG, embeddings) |
| `/shipkit:ui-ux` | build, design, or review UI |
| `/shipkit:explain-system` | ask *why* a system is designed the way it is |
| `/shipkit:walkthrough` | ask how one feature works end-to-end |
| `/shipkit:legacy-audit` | ask to assess/modernize an inherited codebase |
| `/shipkit:migration-plan` | ask to plan a major upgrade or framework migration |
| `/shipkit:humanize` | ask to de-AI writing in docs/READMEs/PRs |

### ⚪ You invoke — call it when you want it

Research and one-shot tools you reach for on purpose. These don't auto-fire — you decide when.

| Skill | Use it to… |
|-------|-----------|
| `/shipkit:ask` | ask the elders a question (this project, or `--all` for the portfolio) |
| `/shipkit:map` | build/refresh `PROJECT_MAP.md`; `--register` for cross-project answers |
| `/shipkit:setup` / `/shipkit:unsetup` | configure shipkit for your stack, or revert |
| `/shipkit:context-audit` | check context-window health and find bloat |
| `/shipkit:qa` | run the 5-phase QA workflow |
| `/shipkit:update-rules` | change CLAUDE.md rules (never edit them by hand) |

**Rule of thumb:** the *knowledge layer* (maps, elders, registry) is something you **ask**; the
*discipline* (rules, commit hygiene, spec/decision capture, freshness) is something that
**happens**.

---

## Setup & Unsetup

### /shipkit:setup

Configures shipkit for your specific project. Run it once when you start using shipkit in a new codebase.

**What it does:**
1. Snapshots your current `CLAUDE.md` + `.claude/` directory to `.shipkit-backup-<timestamp>/`
2. Detects your stack (Rails, React, Python, Go, Elixir, static)
3. Detects test framework and package manager
4. Asks for your project purpose, team conventions, and **workflow style** — `strict-tdd`
   (iron-law red-green-refactor), `test-first` (the default: prefer test-before-implementation,
   pragmatic exceptions), or `lightweight` (tests where they earn their keep)
5. Creates a tailored CLAUDE.md that declares your choices; the workflow itself is defined
   once, in shipkit's always-on rules
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

# Portfolio reports (→ eve, fixed report shapes)
/shipkit:ask --all matrix rails          # every repo's Rails version, from lockfiles
/shipkit:ask --all matrix lodash         # vulnerability/upgrade sweep for one dep
/shipkit:ask --all consolidate           # what am I maintaining N times?

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

### /shipkit:commit — Atomic Commit, Message Scaled to the Change

Builds one atomic commit whose message carries the reasoning a future reader (and the elders)
will want. It inspects the working tree, splits or questions tangled changes rather than
bundling them, stages the specific files, and writes a message whose depth matches the change.

The format lives in the **Commit Discipline** section of the always-on shipkit rule, so Claude
follows it on *any* commit it makes — not only when you invoke this skill by name.

- **Trivial** change (version bump, typo, one-line doc/config) → a clean imperative subject is
  the whole message.
- **Substantive** change → subject + body: **What** changed, **Why** it exists, **How** and the
  decisions made (including alternatives rejected), and a **Test plan** (the command run and
  what you observed). Plus **Risk/Rollback**, **Follow-ups**, and **Refs** where they apply.

```
/shipkit:commit                     # inspect the tree and commit it well
/shipkit:commit emphasize the perf tradeoff in the why
```

It never bundles unrelated changes, never fabricates a test plan, and never adds a co-author
trailer or touches published commits unless you ask.

---

### /shipkit:context-audit — Context Window Health

Reports what's consuming your context window and suggests optimizations.

```
/shipkit:context-audit
```

Use this when Claude seems to be forgetting things or losing context.

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

### /shipkit:spec — Spec a Non-Trivial Feature

Turn a feature idea into a durable, verified spec before building it — the **three questions**,
written to `.shipkit/specs/<feature-slug>/`. This is the forward-looking half of the knowledge
layer: `PROJECT_MAP.md` says what exists; a spec says what you're about to build.

```
/shipkit:spec checkout-redesign            # run all three questions end-to-end
/shipkit:spec checkout-redesign design     # regenerate design.md only
```

The three questions:
1. **What are we building?** → `spec.md`, requirements in EARS (`When X, the system shall Y`).
2. **How should it work?** → `design.md`, the approach written as five-part decision records.
3. **How will we know it's done?** → acceptance criteria as tests, and `tasks.md` (each task cites
   its requirement).

Runs inline with an approval gate after requirements and native Plan Mode before tasks. Spec
**non-trivial** work only — a typo or one-liner doesn't get a spec. See the *Spec-Driven
Development* section below for the full picture.

---

### /shipkit:decide — Capture a Decision Record

Record a project-wide decision as a durable, five-part artifact in `.shipkit/decisions/`.

```
/shipkit:decide "Paddle over Stripe"
/shipkit:decide "monolith over microservices"
```

The five parts: **Context · Alternatives (≥2 real) · Case for · Case against · Decision +
falsifiability clause**. The falsifiability clause must be concrete — "we would reverse this if
p99 latency exceeds 200ms", not "if it turns out wrong" — because that's what lets `grandfather`
later answer *"is this decision now falsified?"*.

Use this for **project-wide** decisions not tied to one feature. Feature-scoped decisions belong
inline in that spec's `design.md` (via `/shipkit:spec`). Capture real forks only — a decision
with one option isn't a decision.

---

## Spec-Driven Development

Shipkit extends the knowledge layer *forward in time*. `PROJECT_MAP.md` is the backward-looking
index (what exists, where); **specs** and **decision records** capture what you're building next
and *why* — as durable, verified artifacts the elders read.

Everything lives under one root, **`.shipkit/`**, so a human always knows where to look and
`grandfather`/`eve`/MemPalace share one canonical place to reference:

```
.shipkit/
  specs/<feature-slug>/
    spec.md      # WHAT — requirements (EARS)
    design.md    # HOW — approach, as decision records
    tasks.md     # STEPS — ordered, each citing its requirement
  decisions/
    NNNN-<slug>.md   # project-wide decision records (the "why" log)
```

### The three questions (always-on)

Two always-on rules drive this without any command:

- **`spec-driven`** — on non-trivial feature work, answer *what are we building* (EARS
  requirements), *how should it work* (design), *how will we know it's done* (tests, TDD/BDD-first).
  Trivial work is exempt — it never specs a typo.
- **`decisions`** — when a real choice is made (≥2 alternatives), capture it in five parts:
  **Context · Alternatives · Case for · Case against · Decision + falsifiability clause.**

The **falsifiability clause** is the key idea: a concrete "I would reverse this if ___" (a metric,
event, or threshold — never a vague hedge). It makes decisions *queryable for staleness* — ask
`grandfather` *"are any past decisions now falsified?"* and it checks each clause against current
reality. A hollow clause is treated as a bug.

### How it ties into the elders

- `grandfather` reads `.shipkit/decisions/` and specs to answer *why is X built this way?*,
  *what are we building next?*, and *which decisions are now falsified?* — preferring these
  verified records over `git log` or MemPalace recall.
- `eve` greps `.shipkit/decisions/` across the portfolio (*"where did we decide against
  microservices, and are those reasons still true?"*).
- `archivist` links active specs and decisions from `PROJECT_MAP.md`, so the map is the front door.

### Freshness

A `SessionStart` hook nudges once per accepted spec whose code has drifted ≥15 commits past its
acceptance SHA (override with `SHIPKIT_SPEC_STALE_COMMITS`) — the same closed-loop treatment the
map already gets. Silent when fresh.

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

Reference it directly when tests fail: "use the test-analyzer agent to diagnose this flaky test."

### codebase-explorer

Read-only exploration agent. Traces call chains, maps directories, analyzes schemas, finds patterns, identifies hotspots.

Used by `/shipkit:qa` and plan-mode research for heavy reading. Or reference directly: "use the codebase-explorer agent to map the services directory."

Both agents: read-only, cap at 20 files per task, report confidence levels.

---

## Knowledge Bases

Loaded on demand by skills — not always in context.

### code-review-standards

Detailed review criteria: 8 core lenses (Clean Code, DRY, KISS, YAGNI, Idioms, Framework Patterns, Performance, Error Handling) plus a 9th that engages only when AI/LLM code is present, an anti-pattern catalog with smell-to-pattern mapping, and severity definitions. Load it for any diff review — Claude Code's built-in `/code-review` or a manual pass.

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

### Always-on rules

These are not path-scoped — they apply to the work itself, not to a file type.

| Rule | Applies To | What It Enforces |
|------|-----------|-----------------|
| `spec-driven` | Non-trivial feature work | The three questions (what/how/done), EARS requirements, TDD/BDD-first — see *Spec-Driven Development* |
| `decisions` | Any non-trivial choice (≥2 alternatives) | The five-part decision record with a concrete falsifiability clause |

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

Three end-to-end playbooks cover most of how you'll use shipkit: **starting a new repo**,
**taking over a legacy one**, and **asking the elders**. Each step says what you do, what it gives
you, and what comes next. Shorter recipes follow at the end.

---

### Playbook 1 — Starting a new repo (greenfield)

A fresh repo is where shipkit's spec-driven flow shines most: you have no existing code to work
around, so a spec becomes the single source of truth and gives the AI no room to invent. Build
**spec-first**.

**1. Configure shipkit for the project.**
```
/shipkit:setup
```
Pick your stack and a workflow style (`test-first` is the sensible default; `strict-tdd` if you
want the iron law; `lightweight` if you don't). **What you get:** a tailored `CLAUDE.md`, the
always-on rules (spec-driven, decisions, commit discipline) now in effect, and stack-specific
skills/rules installed. One-time per repo.

**2. Spec the first feature before writing code.**
```
/shipkit:spec user-signup
```
This runs the three questions — *what are we building* (requirements in EARS), *how should it
work* (design, written as decision records), *how will we know it's done* (acceptance criteria as
tests). **What you get:** `.shipkit/specs/user-signup/{spec,design,tasks.md}`, an approval gate on
the requirements, and native Plan Mode before the tasks are locked. **Why first:** the spec is the
artifact you'll build against — and the one the elders read later to explain *what you're
building*.

**3. Build task by task.**
The `tasks.md` is ordered and each task cites its requirement. Work through them — the always-on
rules fire automatically (test-first per your chosen style, atomic commits, and any real
architectural fork prompts a decision record). **What you get:** code that traces
requirement → task → test, with the *why* captured as you go. No extra commands needed; the
discipline is automatic.

**4. Record project-wide decisions as they come up.**
```
/shipkit:decide "Postgres over SQLite"
```
When you make a choice that isn't tied to one feature (a datastore, a deploy target, an auth
strategy), capture it. **What you get:** a five-part record in `.shipkit/decisions/` with a
concrete falsifiability clause — so a year from now you (or grandfather) can answer *why* and
*"is this still the right call?"*.

**5. Build the map once the repo has a shape, and register it.**
```
/shipkit:map --register
```
**What you get:** a verified `PROJECT_MAP.md` and a row in your cross-project registry — from now
on the elders can answer questions about this repo, and `eve` sees it in portfolio sweeps. **When:**
once there's real structure (a few features in), not on day one.

**From here:** ask the elders when you need to understand something (Playbook 3), `/shipkit:map
refresh` after big changes, and repeat steps 2–4 per feature.

---

### Playbook 2 — Taking over a legacy / inherited repo

The opposite starting point: lots of existing code, little context, and the standard warning is
*don't retro-spec the whole thing*. **Understand first, then spec only what you change.**

**1. Get oriented with an audit.**
```
/shipkit:legacy-audit
```
**What you get:** a modernization assessment — dependency age, dead code, complexity hotspots,
test-coverage gaps. This tells you what you're walking into before you touch anything.

**2. Build the map so you (and the elders) have an index.**
```
/shipkit:map --register
```
**What you get:** a verified `PROJECT_MAP.md` — architecture, where-things-live, data model,
evolution, gotchas. On an unfamiliar codebase this is the highest-value first move: it turns "I
have no idea where anything is" into a navigable index, and lets you ask the elders from now on.

**3. Understand before you change.**
```
/shipkit:ask how does authentication flow through this app?   # grandfather, cited answer
/shipkit:walkthrough checkout                                  # trace one path step by step
/shipkit:explain-system                                        # why is it built this way?
```
**What you get:** grandfather traces the flow and returns a cited answer without dumping the code
into your session; `/shipkit:walkthrough` traces one path step by step; `/shipkit:explain-system`
returns the *why* (decisions, trade-offs). **Why:** on legacy code, the reason something exists is
usually the thing you're missing — and the thing most likely to bite you if you change it blind.

**4. When you add a feature, spec only the delta.**
```
/shipkit:spec add-sso
```
**What you get:** a spec for the *new* behavior on top of the old code — lock what exists, spec the
change. Don't spec the whole legacy surface; spec the part you're adding or reworking. This is
where spec-driven development pays off in brownfield without drowning you in ceremony.

**5. Plan any big upgrade before executing it.**
```
/shipkit:migration-plan rails 6.1 7.0
```
**What you get:** an impact analysis and a step-by-step execution plan for a major/breaking
upgrade — before you start, not halfway through.

**From here:** as you learn non-obvious things, they graduate into `.claude/lessons.md`
automatically; refresh the map after big changes; capture the decisions you make with
`/shipkit:decide` so the next person (or you in six months) inherits the *why* you didn't have.

---

### Playbook 3 — Asking the elders (when & why)

The elders exist to answer questions **without polluting your main context** — the subagent reads
the files, you get back only the cited answer. Reach for them whenever the answer would otherwise
cost you a dozen file reads in your working session.

**grandfather — one project.** Use it for:

| You want to… | Ask |
|--------------|-----|
| Understand how something works | `/shipkit:ask how does locale fallback work here?` |
| Find where something lives | `/shipkit:ask where are background jobs defined?` |
| Know *why* a decision was made | `/shipkit:ask why did we choose Paddle over Stripe?` |
| Judge whether a change is safe | `/shipkit:ask is it safe to drop the legacy_token column?` |
| Check if a past decision still holds | `/shipkit:ask are any of our decisions now falsified?` |

**eve — across all your registered projects.** Use it for the 360° view:

| You want to… | Ask |
|--------------|-----|
| Find a pattern across the portfolio | `/shipkit:ask --all which apps deploy to Hetzner vs AWS?` |
| Locate every place you do X | `/shipkit:ask --all everywhere I integrate Stripe` |
| Sweep versions for an upgrade/CVE | `/shipkit:ask --all matrix rails` |
| Find duplication worth consolidating | `/shipkit:ask --all consolidate` |
| See what's in flight | `/shipkit:ask --all which projects have an open spec?` |

**When *not* to use them:** mid-edit, when you need one fact to keep typing — just read the file;
a subagent round-trip is slower. And they're read-only: they inform, they don't edit. Get the
answer, then act in your main session.

**Why they stay trustworthy:** the map is an *index*, not the last word. When it disagrees with
live source, the elders trust **source** and flag the drift — so a stale map yields a correction,
not a confident wrong answer. Refresh with `/shipkit:map refresh` when you see a drift flag or the
session-start hook nudges you.

---

### Shorter recipes

**Debugging a bug:**
```
/shipkit:debug  →  /shipkit:tdd bugfix  →  run the tests
```

**Pre-PR checklist:**
```
run the tests  →  /code-review (built-in)  →  /shipkit:humanize (for docs/PR description)
```

**Leaving shipkit:**
```
/shipkit:unsetup  →  /plugin uninstall shipkit@shipkit
```
(`/unsetup` restores your pre-shipkit `CLAUDE.md` and `.claude/`; it never touches `.shipkit/` —
your specs and decisions are yours to keep.)

---

## Tips

1. **Interactive skills pause at checkpoints.** Inline skills like `/shipkit:qa` stop between phases for your input — don't skip these. Research skills (`/shipkit:walkthrough`, `/shipkit:explain-system`) instead run end-to-end in a forked context and return their findings; any file they propose is only written after you approve it.

2. **Use `/clear` between skills.** Each skill works best with a fresh context window.

3. **Skills adapt to your stack.** You don't need to specify your test framework or language — skills detect it automatically.

4. **Arguments are optional.** Every skill has sensible defaults. Add arguments only to narrow scope.

5. **Path-scoped rules are automatic.** You don't invoke them — they load when you edit matching files.

6. **Stack-specific content needs /setup.** Base skills and rules work instantly. Stack-specific skills (like `/new-feature` for Rails) require running `/shipkit:setup` first.
