---
description: "Verified system design explainer"
user-invocable: true
argument-hint: "[full|quick|section <name>]"
context: fork
agent: general-purpose
---

<!-- FIRE-AND-FORGET FORK: runs non-interactively — it cannot ask the user anything
     mid-run. All phases run end-to-end; verification is self-enforced (unverifiable
     claims get cut, not user-arbitrated). It RETURNS the drafted document; the main
     session presents it and writes docs/SYSTEM_DESIGN.md only after user approval. -->

# /explain-system — Verified System Design Explainer

Explore a codebase, reason about WHY it's designed the way it is, verify every claim
against source code, and return a system design document proposed for `docs/SYSTEM_DESIGN.md`.

**How this differs from /onboard:** `/onboard` maps WHAT exists (architecture, flows,
entities). `/explain-system` explains WHY the system is designed this way (decisions,
trade-offs, constraints). `/onboard` gives you a map of the city. `/explain-system`
gives you the textbook chapter explaining why the city was planned this way.

## Arguments

Scope: $ARGUMENTS (default: `full`)

- `full` — All 6 phases end-to-end, returning the finished document
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

Record: system name, core problem, users, alternatives, scope boundary. This opens the final document — continue to Phase 2.

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

Record: context (actors + externals), containers, key components, domain model table, trade-off table. Continue to Phase 3.

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

See @reference.md for ADR format template. Each decision needs: Context, Decision, Trade-offs, Consequences, Confidence, Revisit-when.

### 3.4 Invariants, Security, and Protections

Identify: validation rules, authorization patterns, data integrity guarantees, auth pattern, input validation, encryption, secrets management. Continue to Phase 4.

---

## Phase 4: Verification Loop — THE KEY DIFFERENTIATOR

Every factual claim is individually verified against source code. See @reference.md for detailed verification steps (compile claims table, re-verify, zero-UNCERTAIN gate).

**Gate: Zero UNCERTAIN claims in final doc.** Not optional. You cannot ask the user to
arbitrate — a claim you cannot verify against source gets **cut or rewritten** as an explicit
open question, never stated as fact. Include the final claims table in your output so the
user can audit the verification.

---

## Phase 5: Draft the Document

**Goal:** Draft the full `docs/SYSTEM_DESIGN.md` content (100-200 lines). See @reference.md for document structure template and writing rules. **Do not write the file** — it goes into your final output (Phase 6).

---

## Phase 6: Improvement Opportunities + Return the Deliverable

**Goal:** Evidence-based improvement suggestions. Every suggestion must cite specific files. No generic advice. See @reference.md for trade-off analysis template and opportunities table format.

Then return, in your final output:

1. The full document under a marked heading: `PROPOSED: docs/SYSTEM_DESIGN.md`
2. The claims table from Phase 4
3. The opportunities table

The main session presents these and, on approval, writes the file.

---

See @reference.md for full constraints.
