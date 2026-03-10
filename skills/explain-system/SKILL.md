---
description: "Explore codebase and write a verified system design explainer doc in /docs"
user-invocable: true
argument-hint: "[full|quick|section <name>]"
context: fork
agent: general-purpose
---

# /explain-system — Verified System Design Explainer

Explore a codebase, reason about WHY it's designed the way it is, verify every claim
against source code, and produce a system design document in `docs/SYSTEM_DESIGN.md`.

**How this differs from /onboard:** `/onboard` maps WHAT exists (architecture, flows,
entities). `/explain-system` explains WHY the system is designed this way (decisions,
trade-offs, constraints). `/onboard` gives you a map of the city. `/explain-system`
gives you the textbook chapter explaining why the city was planned this way.

## Arguments

Scope: $ARGUMENTS (default: `full`)

- `full` — All 6 phases with checkpoints between each
- `quick` — Phases 1-2 only, produce a brief explainer (skip verification loop)
- `section <name>` — Regenerate one section (e.g., `section decisions`, `section flows`)

**If `docs/ARCHITECTURE.md` exists** (from `/onboard`), read it as input. Don't redo
work that's already been done — build on it.

---

## Phase 1: Problem Discovery

**Goal:** Understand what this system solves, who uses it, and why it exists.

### 1.1 Read Foundation Files

Read (via `codebase-explorer` agent for heavy reading):
- README, CLAUDE.md, docs/ directory
- Dependency files (Gemfile, package.json, mix.exs, go.mod, etc.)
- Config files (database.yml, docker-compose.yml, CI configs)
- If `docs/ARCHITECTURE.md` exists, use it as a starting point

### 1.2 Formulate Problem Statement

Answer:
1. **What does it solve?** — The core problem in one sentence
2. **Who uses it?** — End users, internal teams, API consumers, other systems
3. **Why does it exist?** — What would users do without it? (spreadsheets, manual process, competitor)
4. **What's the scope?** — What it deliberately does NOT do

### Output: Problem Statement

Present: system name, core problem, users, alternatives, scope boundary.

### CHECKPOINT — Stop and ask user to confirm before proceeding.

---

## Phase 2: Deep Exploration (C4-Inspired Zoom Levels)

**Goal:** Map the system at three zoom levels (Context, Container, Component) and
surface the trade-offs the current architecture makes.

The C4 Model (Simon Brown) uses four zoom levels to communicate architecture: Context,
Container, Component, Code. We use the first three — enough to explain the system
without drowning in implementation details.

### 2.1 Context Level — The System in Its Environment

What actors and external systems interact with this system?
- Users (types, roles, access patterns)
- External APIs consumed (payment, email, auth, storage)
- External APIs exposed (webhooks, public API, integrations)
- Other internal systems (if microservices or SOA)

### 2.2 Container Level — Deployable Units

Identify: web app, background workers, databases, cache, message queue, CDN/storage/search.

### 2.3 Component Level — Internal Structure

Use `codebase-explorer` agent to trace 2-3 primary flows through internal components:
- What are the major internal boundaries? (modules, engines, contexts, packages)
- How do components communicate? (method calls, events, queues, HTTP)
- Where are the sync vs async boundaries?

### 2.4 Domain Model

Read schema files and map the domain model in plain language:
- Core entities and their relationships (teach the mental model, don't dump schema)
- What data the system protects (validations, constraints, foreign keys)
- History preservation patterns (audit logs, event sourcing, versioned records)

### 2.5 Trade-Off Analysis

For each architectural choice discovered, identify:
- **What does this design optimize for?** (development speed? scale? simplicity? reliability?)
- **What does it sacrifice?** (flexibility? performance? operational simplicity?)
- Example: "Monolith optimizes for development speed and deployment simplicity, but
  sacrifices independent scaling of components"

### Output: System Map

Present: context (actors + externals), containers, key components, domain model table, trade-off table.

### CHECKPOINT — Stop and ask user to confirm before proceeding.

---

## Phase 3: Design Reasoning (ADR-Informed)

**Goal:** For each major architectural choice, examine evidence for WHY it was chosen.
Present findings in ADR (Architecture Decision Record) format: Context, Decision,
Trade-offs, Consequences.

### 3.1 Search for Existing ADRs

Look for existing decision records in:
- `docs/adr/`, `docs/decisions/`, `doc/architecture/`
- `ADR-*.md` or `NNNN-*.md` patterns
- README sections about architecture decisions

If found, use as primary source of truth. Don't reinvent what the team already documented.

### 3.2 Examine Evidence for Decisions

For each major choice, check: code evidence, commit history (`git log --grep`), inline comments/PR descriptions, and constraints (team size, deployment, scale signals).

### 3.3 Present Each Decision in ADR Format

For each decision: Context, Decision, Trade-offs (gained/sacrificed/alternatives), Consequences, Confidence (VERIFIED/INFERRED/UNCERTAIN), Revisit-when.

### 3.4 Invariants, Security, and Protections

Identify: validation rules, authorization patterns, data integrity guarantees, auth pattern, input validation, encryption, secrets management.

### CHECKPOINT — Stop and ask user to confirm before proceeding.

---

## Phase 4: Verification Loop — THE KEY DIFFERENTIATOR

This is what makes `/explain-system` different from just asking an LLM to explain a
codebase. Every factual claim is individually verified against source code before it
appears in the final document.

Based on atomic fact verification — the gold standard for preventing hallucination in
AI-generated text: break claims into atomic facts and verify each independently.

### Step 4.1 — Compile Claims Table

Extract every factual claim from Phases 1-3 into a table (~30-40 entries max). Each claim needs: source file(s), confidence level (VERIFIED/INFERRED/UNCERTAIN), status.

### Step 4.2 — Present to User

Present sorted: UNCERTAIN first (need user input), then INFERRED (need confirmation), then VERIFIED (for transparency).

### Step 4.3 — Re-Verify and Cross-Reference

After user feedback: re-read source files for corrected claims, verify "X calls Y" claims against imports/references, promote confirmed INFERRED to VERIFIED.

### Step 4.4 — Gate: Zero UNCERTAIN in Final Doc

**Not optional.** All UNCERTAIN claims must be resolved or marked "*[Not confirmed from code]*".

### CHECKPOINT — Present final claims table. Ask user to confirm before writing.

---

## Phase 5: Write the Document

**Goal:** Generate `docs/SYSTEM_DESIGN.md` (100-200 lines) that teaches someone who
knows programming but not this codebase WHY the system is designed this way.

### Document Structure (100-200 lines)

1. The Problem — what, who, alternatives, scope
2. Core Concepts — domain model in plain language
3. System Overview — C4 levels (context, containers, components)
4. Architectural Decisions — ADR format with confidence tags
5. Trade-off Map — summary table
6. Data Flows — step-by-step with file:line references
7. Component Interactions — boundaries, sync/async, integration points
8. Constraints, Invariants, Security
9. Improvement Opportunities — from Phase 6

**Writing rules:** From first principles, WHY not WHAT, file:line on every claim, no undefined jargon, tag INFERRED claims, 100-200 lines max.

### CHECKPOINT — Present full document. Only write after approval.

---

## Phase 6: Improvement Opportunities

**Goal:** Evidence-based improvement suggestions. Every suggestion must cite specific
files. No generic advice.

### Analysis

For each opportunity found during Phases 2-4:
- Cite the specific file(s) and line(s) that evidence the issue
- Categorize: Architecture, Performance, Reliability, Developer Experience, Security
- Assess impact (HIGH/MEDIUM/LOW), risk, and effort (S/M/L)

### Trade-Off Analysis Required

Improvements are never free. For each suggestion:

- **Current trade-off:** What the system gains by its current design
- **Proposed trade-off:** What the improvement gains AND what it costs
- **When to act:** Under what conditions this becomes urgent vs. nice-to-have

### Output: Opportunities Table

Table with: category, opportunity, evidence (file:line), impact, risk, effort. For each: state current trade-off, proposed change, and when to act.

**No generic advice.** Every suggestion must cite specific files.

### CHECKPOINT — Present opportunities for approval before finalizing document.

---

## Constraints

- **Read-only until Phase 5** — Phases 1-4 and 6 only read files and run git commands
- **User checkpoints mandatory** — present findings and WAIT at every phase boundary
- **Use codebase-explorer for heavy reading** — keep main context clean for reasoning
- **Zero UNCERTAIN claims in final doc** — Phase 4 gate, not optional even if user asks
- **From first principles** — teach, don't assume reader knowledge of the codebase
- **WHY not WHAT** — every section explains reasoning behind the design
- **Evidence-based improvements only** — cite specific files, no generic advice
- **Stack-agnostic** — all phases work for any language/framework
- **File:line references required** — on every factual claim in the final doc
- **Target doc length: 100-200 lines** — concise enough to read in one sitting
- **Cap claims table at ~30-40 entries** — group related claims to stay manageable
- **If ARCHITECTURE.md exists, read it** — build on /onboard output, don't duplicate
- **Verification is not optional** — the claims table is the skill's core differentiator
- **ADR format for decisions** — Context, Decision, Trade-offs, Consequences
- **Trade-off analysis is central** — every decision and improvement includes what's gained AND sacrificed
