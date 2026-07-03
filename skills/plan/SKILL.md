---
description: "Plan before coding: PRD, tech spec, and atomic task breakdown. TRIGGER when: user asks to build, add, implement, create, or refactor a feature. DO NOT TRIGGER when: task is a simple rename, typo fix, config change, or user says 'just do it'."
user-invocable: true
argument-hint: "[<feature-description>]"
---

<!-- Runs INLINE (no context: fork) on purpose: the PRD interview and the three
     approval checkpoints need AskUserQuestion, which forked skills cannot use.
     Context-thinness comes from delegating Phase 2 research to codebase-explorer. -->

# /plan — Plan Before You Code

Every non-trivial coding task starts here. Understand first, design second, code last.

**Skip this for:** renames, typo fixes, config changes, one-liners, or when the user says "just do it."

Feature: $ARGUMENTS

## Phase 1: Clarify — The PRD

**Goal:** Understand exactly what the user wants before reading a single line of code.

Ask probing questions using AskUserQuestion. Group related questions — don't ask one at a time. Keep asking until you can answer ALL of these:

1. **Purpose** — What problem does this solve? Why does it need to exist?
2. **Users** — Who uses this? What's their context? (end user, admin, API consumer, internal)
3. **Behaviors** — What are the specific things a user can do? List as user stories: "User can X so that Y."
4. **Acceptance criteria** — How do we know each behavior works? Be specific.
5. **Edge cases** — What happens when things go wrong? Empty states, errors, concurrent access, permissions.
6. **Out of scope** — What does this deliberately NOT do? Setting boundaries prevents scope creep.
7. **Constraints** — Performance requirements? Compatibility? Deadlines? Dependencies on other work?

**Do NOT proceed to Phase 2 until the user confirms the PRD.**

### Output: PRD Summary

See @reference.md for the PRD template format.

### CHECKPOINT — Present the PRD. Wait for user approval.

---

## Phase 2: Technical Design — The Tech Spec

**Goal:** Design the approach by reading existing code and considering best practices.

### 2.1 Read Existing Code

**Delegate this to the `codebase-explorer` agent** — it does the heavy reading in its own
context and returns a summary, so the planning session stays thin. Read directly only when
the scope is small (a handful of known files). Have it report on:
- Current architecture (directory structure, patterns, conventions)
- Related existing code (similar features, shared utilities, data models)
- Test patterns (framework, style, coverage of related areas)
- CLAUDE.md and project conventions

### 2.2 Design the Approach

For each major decision, consider:
- **Scalability** — Will this work at 10x current load? What's the bottleneck?
- **Fault tolerance** — What fails? How does it recover? What does the user see?
- **Readability** — Can a new developer understand this in 5 minutes?
- **Maintainability** — What changes when requirements change? How localized is the impact?
- **Security** — Input validation, authorization, data exposure, injection risks

### 2.3 Document the Design

See @reference.md for the tech spec template. Cover: data model changes, API/interface design, component structure, files to create/modify, dependencies, risks, and trade-offs.

### CHECKPOINT — Present the tech spec. Wait for user approval.

---

## Phase 3: Task Breakdown — Sprint Planning

**Goal:** Decompose the approved design into atomic sub-tasks. Each task = one testable behavior = one TDD cycle = one atomic commit.

### 3.1 Decompose by Behavior

Break the feature into the smallest independently testable behaviors. Order by dependency:

1. **Foundation** — data model, schema changes, core types
2. **Core logic** — business rules, services, domain operations
3. **Interface** — API endpoints, UI components, CLI commands
4. **Integration** — connecting components, wiring events, external services
5. **Edge cases** — error handling, validation, boundary conditions
6. **Polish** — performance, logging, documentation

### 3.2 Define Each Task

For each task, specify:
- **Description** — what this task does in one sentence
- **Acceptance criteria** — how to verify it works
- **Test** — the BDD-style test description ("it does X when Y")
- **Complexity** — S (< 30 min), M (30-60 min), L (60+ min)

See @reference.md for the task breakdown template.

### 3.3 Present the Sprint Plan

Present as a numbered checklist. Each item maps to one TDD cycle:

```
[ ] Task 1: Create orders table migration (S)
    Test: "orders table exists with required columns"
[ ] Task 2: Order model with validations (S)
    Test: "it validates presence of user and total"
[ ] Task 3: OrderService.create with inventory check (M)
    Test: "it creates order when inventory available, raises when not"
...
```

### CHECKPOINT — Present the task list. Wait for user approval. Then execute: one task at a time, each following the TDD cycle (test first → implement → refactor → commit).

---

## Constraints

- **Questions before code** — Phase 1 is pure conversation. No file reading until Phase 2.
- **User approves each phase** — never skip a checkpoint.
- **Atomic tasks** — if a task needs "and" in its description, split it.
- **Each task = one commit** — test + implementation + refactor in one atomic commit.
- **Design for the real world** — consider scale, failure, readability, maintainability, security in Phase 2. Not as afterthoughts.
- **BDD-style tests** — describe behavior from the user's perspective, not implementation details.
- **Order matters** — foundation before features, core before edge cases.
- **No gold plating** — only tasks that serve the approved PRD. Nothing speculative.
