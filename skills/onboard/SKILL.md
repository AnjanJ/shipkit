---
description: "Multi-phase codebase onboarding: zoom in, zoom out, recognize patterns, learn history, generate docs"
user-invocable: true
argument-hint: "[scope: full|quick|zoom-in <file>|zoom-out]"
context: fork
agent: codebase-explorer
---

# /onboard — Codebase Onboarding

Systematically explore and document an unfamiliar codebase. Based on Ridhwana Khan's
"Architecture of Understanding" talk from RubyConf TH 2026
(https://www.youtube.com/watch?v=Op5GunxvRKU): zoom in first, then zoom out, recognize
patterns, learn from history, externalize understanding.

**Core philosophy:** "The instinct is to zoom out, get a lay of the land. Resist that
urge. Zoom in first." Mental models built bottom-up (from a real flow) are more accurate
than those built top-down (from directory listings).

## Project Snapshot
!`find . -maxdepth 2 -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.toml" -o -name "*.lock" -o -name "Gemfile" -o -name "mix.exs" 2>/dev/null | grep -v node_modules | grep -v vendor | head -25`

## Arguments

Scope: $ARGUMENTS (default: `full`)

- `full` — Run all 5 phases with checkpoints between each
- `zoom-in <file>` — Start Phase 1 from a specific file (skip auto-detection)
- `zoom-out` — Skip Phase 1, start at Phase 2 (only if you already understand a flow)

---

## Phase 1: Zoom In — Get a Foothold

> "Keep scope tight — paste only the smallest relevant snippet."
> "Ask practical questions, not architectural ones."

**Goal:** Trace ONE request/flow end-to-end. Build your first mental model from concrete
code, not abstractions.

### 1.1 Pick an Entry Point

If user provided `zoom-in <file>`, use that file. Otherwise auto-detect:
1. Check README for getting-started hints
2. Check `git log --oneline -20` — recent changes = active code
3. Find the "front door": routes file, main entry point, or primary controller/handler

### 1.2 Trace the Flow

Use the `codebase-explorer` agent for heavy file reading. Keep main context clean.

1. Follow the call chain through layers (e.g., controller → service → model → DB)
2. **Stop after 5-8 files** — this is reconnaissance, not exhaustive mapping
3. At each file, note:
   - Naming conventions (snake_case? camelCase? what prefix/suffix patterns?)
   - File organization (by feature? by type? by layer?)
   - How dependencies are referenced (imports, injection, includes, concerns)

### 1.3 Ask Practical Questions

Frame questions about behavior, not architecture:
- "What DB record changes when X happens?" / "Is this sync or async?"
- "What would break this flow?" / "What happens if called twice?"

### 1.4 Validate with Tests

Read tests for this flow — do descriptions match behavior? Do tests reveal edge cases?

### Output: "First Trail"

Present: entry point, flow (files traversed), step-by-step description, conventions spotted, open questions, test coverage.

### CHECKPOINT — Stop and ask user to confirm before proceeding.

---

## Phase 2: Zoom Out — Map the Architecture

> "I'm not tracing edge cases. I'm trying to see the dominant shapes."
> "Data models are the most honest part of the system."

**Goal:** Classify the system's shape, flow patterns, and core entities without getting
lost in details.

### 2.1 Stack Detection

Read dependency files to identify: framework + version, database, background jobs, cache, search, external services.

### 2.2 Architectural Shape

Classify from directory structure and code organization:

| Shape | Signals |
|-------|---------|
| Monolith with conceptual seams | Single deploy, `app/` with models/controllers/services |
| Modular monolith | `engines/`, `packages/`, or `components/` with internal boundaries |
| Microservices | Multiple services in subdirs, API gateways, service-to-service calls |
| Monorepo | `apps/`, `packages/`, shared libraries, workspace config |

### 2.3 Flow Pattern

| Pattern | Signals |
|---------|---------|
| Request-driven (sync) | Routes → controllers → response cycle |
| Event-driven (async) | Event/message classes, broker configs, subscriber definitions |
| Hybrid | Both routes AND event processing (most real apps) |

### 2.4 Data Model as Ground Truth

Read the schema source of truth (schema.rb, models.py, schema.prisma, migrations, etc.):
1. Identify 3-5 **core entities** everything connects to
2. Map relationships (has_many, belongs_to, many-to-many)
3. Look for: audit tables, soft deletes, constraints, foreign keys

### 2.5 Consistency Check

Look for repetition across parallel features:
- Same shapes in familiar places = consistent codebase
- Different patterns for similar things = evolved codebase with tech debt

### 2.6 Language-Specific Signals

Note language-specific patterns: metaprogramming, dynamic dispatch, async patterns, macro usage — anything that affects flow tracing.

### Output: "Architecture Snapshot"

Present: stack + versions, architectural shape, flow pattern, API style, core entities table, directory map, external integrations, consistency assessment.

### CHECKPOINT — Stop and ask user to confirm before proceeding.

---

## Phase 3: Learn from History — Git as Historian

> "Code captures decisions, but not the context behind those decisions."
> "What were the constraints?" — not "Why is this bad?"

**Goal:** Identify hotspots, change patterns, and the team's priorities. Use blame-free
framing — the code reflects constraints, not incompetence.

### 3.1 Hotspot Analysis

Run (via codebase-explorer agent):
```
git log --since="6 months ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20
```

High churn + high line count = abstraction under strain. These files are where bugs live
and where refactoring would have the most impact.

### 3.2 Change Pattern Analysis

For the top 5 hotspots:
- Are changes **additive** (new features extending existing code)?
- Or **invasive** (cutting across multiple layers for one feature)?
- Repeated invasive changes = the abstraction needs rework

### 3.3 Contributors

```
git shortlog -sn --since="6 months ago"
```

Who works on what areas? This tells you who to ask questions.

### 3.4 PR Archaeology (if GitHub)

Use `gh` CLI to check recent merged PRs — descriptions contain the "why" that code misses.

### 3.5 Metaprogramming Scan

Flag metaprogramming (`method_missing`, metaclasses, Proxy, etc.) — this is where "magic" hides.

### 3.6 Exit Criteria Check

Can you: trace main flows? Name key components? Point to where state lives?
If yes → Phase 4. If no → investigate the gap.

### Output: "History Report"

Present: hotspot table (file, commits, lines, assessment), change patterns, key contributors, PR themes, metaprogramming locations, "enough" check results.

### CHECKPOINT — Stop and ask user to confirm before proceeding.

---

## Phase 4: Document — Externalize Understanding

> "Understanding is valuable but fragile. If I don't externalize it, it disappears."
> "Documentation stays current when it lives close to code, focuses on WHY not HOW,
> and is updated alongside changes."

**Goal:** Generate lightweight docs that help both humans AND future AI agents understand
this codebase. Focus on WHY, not HOW — how changes with every commit, why endures.

### 4.1 Generate `docs/ARCHITECTURE.md` (40-80 lines)

System overview, stack, core entities, directory map, key patterns, primary flow, hotspots, integrations.

### 4.2 Generate `docs/CODEBASE_MAP.md` (30-60 lines)

Module inventory, external integrations, testing landscape, background jobs, config files.

### 4.3 Propose CLAUDE.md Updates

Present as a diff — do NOT auto-write. Propose: Key Paths, commands, conventions, gotchas.

### CHECKPOINT — Present all docs for review. Only write files after approval.

---

## Phase 5: Detect Opportunities — Skill & Agent Suggestions

**Goal:** Based on everything discovered, suggest project-specific skills and agents
that would make working in this codebase faster. Max 5 suggestions, prioritized by
impact.

### Detection Signals

Look for: CI/CD scripts, frequent migrations, complex test factories, many background jobs,
feature flags, monitoring config, i18n files, custom scripts — each could become a
project-specific skill or agent.

For each suggestion, provide: evidence found, what it would do, complexity, priority.

**Never auto-create skills or agents.** Present proposals only. User decides what to build.

---

## Constraints

- **Read-only until Phase 4** — Phases 1-3 only read files and run git commands
- **User checkpoints are mandatory** — present findings and WAIT at every phase boundary
- **Use codebase-explorer agent for heavy reading** — keep main context clean
- **Lightweight docs** — ARCHITECTURE.md: 40-80 lines, CODEBASE_MAP.md: 30-60 lines
- **Stack-agnostic** — all phases work for any language/framework
- **Time-box git analysis** — cap at 20 hotspot files, 6-month window
- **Never auto-create skills/agents** — Phase 5 outputs proposals only
- **"Enough" exit criteria** — can trace main flows, name key components, point to state
- **Blame-free framing** — "What were the constraints?" not "Why is this bad?"
- **WHY not HOW** — documentation explains why decisions were made, not how code works
- **Questions unlock questions** — each answer unlocks the next question; iterate, don't exhaust
