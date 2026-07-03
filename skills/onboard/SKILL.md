---
description: "Multi-phase codebase onboarding"
user-invocable: true
argument-hint: "[scope: full|quick|zoom-in <file>|zoom-out]"
context: fork
agent: codebase-explorer
---

<!-- FIRE-AND-FORGET FORK: this runs non-interactively as the read-only
     codebase-explorer agent. It cannot ask the user anything mid-run and cannot
     write files. It runs all phases end-to-end and RETURNS the report + drafted
     docs; the main session presents them and writes only what the user approves. -->

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

- `full` — Run all 5 phases end-to-end, then return the combined report
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

You ARE the read-only explorer, running in a fork — read freely; none of it lands in the
caller's context.

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

Record: entry point, flow (files traversed), step-by-step description, conventions spotted, open questions, test coverage. This becomes section 1 of your final report — then continue to Phase 2.

---

## Phase 2: Zoom Out — Map the Architecture

> "I'm not tracing edge cases. I'm trying to see the dominant shapes."
> "Data models are the most honest part of the system."

**Goal:** Classify the system's shape, flow patterns, and core entities without getting
lost in details.

### 2.1 Stack Detection

Read dependency files to identify: framework + version, database, background jobs, cache, search, external services.

### 2.2 Architectural Shape

Classify from directory structure and code organization. See @reference.md for shape and flow pattern classification tables.

### 2.3 Data Model as Ground Truth

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

Record: stack + versions, architectural shape, flow pattern, API style, core entities table, directory map, external integrations, consistency assessment. Section 2 of the report — continue to Phase 3.

---

## Phase 3: Learn from History — Git as Historian

**Goal:** Identify hotspots, change patterns, and the team's priorities. Use blame-free
framing — the code reflects constraints, not incompetence.

See @reference.md for git analysis commands, hotspot analysis, change pattern analysis, contributor mapping, and exit criteria.

### Output: "History Report"

Record: hotspot table (file, commits, lines, assessment), change patterns, key contributors, PR themes, metaprogramming locations, "enough" check results. Section 3 — continue to Phase 4.

---

## Phase 4: Document — Externalize Understanding

> "Understanding is valuable but fragile. If I don't externalize it, it disappears."
> "Documentation stays current when it lives close to code, focuses on WHY not HOW,
> and is updated alongside changes."

**Goal:** Generate lightweight docs that help both humans AND future AI agents understand
this codebase. Focus on WHY, not HOW — how changes with every commit, why endures.

### 4.1 Draft `docs/ARCHITECTURE.md` (40-80 lines)

System overview, stack, core entities, directory map, key patterns, primary flow, hotspots, integrations.

### 4.2 Draft `docs/CODEBASE_MAP.md` (30-60 lines)

Module inventory, external integrations, testing landscape, background jobs, config files.

### 4.3 Propose CLAUDE.md Updates

Present as a diff — do NOT auto-write. Propose: Key Paths, commands, conventions, gotchas.

**You are read-only and non-interactive: write NOTHING.** Return the drafted docs in your
final output, each under a clearly marked heading (`PROPOSED: docs/ARCHITECTURE.md`, etc.),
so the main session can present them to the user and write only what gets approved.

---

## Phase 5: Detect Opportunities — Skill & Agent Suggestions

**Goal:** Based on everything discovered, suggest project-specific skills and agents
that would make working in this codebase faster. Max 5 suggestions, prioritized by
impact.

See @reference.md for detection signals and full constraints.

**Never auto-create skills or agents.** Present proposals only. User decides what to build.
