---
description: "End-to-end feature code walkthrough"
user-invocable: true
argument-hint: "[<feature-name> [surface|deep]]"
context: fork
agent: codebase-explorer
---

# /walkthrough — Guided Code Walkthrough

Trace one feature end-to-end — from trigger to database and back — and produce a
step-by-step walkthrough in `docs/code-walkthrough/<feature-name>.md`.

**How this relates to /onboard and /explain-system:**
- `/onboard` maps WHAT exists (architecture, entities, history) — the city map
- `/explain-system` explains WHY decisions were made (trade-offs, ADRs) — the urban planning textbook
- `/walkthrough` traces HOW one feature works step by step — the guided walking tour

## Arguments

Target: $ARGUMENTS (required — feature name or file path, optionally followed by `surface` or `deep`)

- `<feature-name>` — name of the feature to trace (e.g., `checkout`, `login`, `webhook-processing`)
- `<file-path>` — path to a specific file to use as entry point
- `surface` — happy path + data flow only (50-80 lines output)
- `deep` (default) — adds error paths, side effects, key concepts (100-200 lines output)

---

## Phase 1: Locate and Scope

**Goal:** Find all entry points for this feature and let the user pick which path to trace.

### 1.1 Identify Entry Points

**If a file path was given:**
- Read the file
- Identify its role (controller, job, event handler, CLI, etc.)
- Treat it as the entry point — skip to 1.2

**If a feature name was given:**
Use `codebase-explorer` agent to search:
- Routes/URL patterns matching the feature name
- File names matching the feature name (controllers, services, jobs, commands)
- Git log: `git log --all --oneline --grep="<feature-name>"` for related commits
- Test files mentioning the feature name (tests often name features explicitly)

### 1.2 Catalog All Entry Points

Features often have multiple triggers: HTTP requests, background jobs, cron, webhooks, events, admin actions, CLI, internal calls. Find ALL of them and present as a table (trigger type, entry point, file:line).

### CHECKPOINT — Ask user which entry point to trace. Confirm deep or surface.

---

## Phase 2: Trace

**Goal:** Follow the call chain from the selected entry point through every layer,
building a raw trace table.

### 2.1 Follow the Call Chain

Follow each method call from entry point through layers. Record: step #, layer, file:line, method, data in, action, data out. **Cap at 10 hops.**

### 2.2 Map Data Transformations

Note how data changes shape at each boundary (params → model → DB → response).

### 2.3 Side Effects (deep mode only)

Catalog: jobs enqueued, emails/notifications, webhooks, cache ops, events published, external API calls.

### 2.4 Error Paths (deep mode only)

For each failure: what goes wrong, where caught, what user sees.

### 2.5 Read Tests

Find tests for this feature — they reveal edge cases code hides.

### 2.6 Build Raw Trace Table

Compile internal trace (step, layer, file:line, method, data in/out, side effects, errors).

### CHECKPOINT — Summarize layers/side effects/errors found. Ask to proceed.

---

## Phase 3: Explain

**Goal:** Transform the raw trace into a readable, guided walkthrough. See @reference.md for section formats (user journey, code trace, data transformations, side effects, error paths, key concepts).

### CHECKPOINT — Present full walkthrough for review. Write only after approval.

---

## Phase 4: Write

**Goal:** Write the approved walkthrough to `docs/code-walkthrough/<feature-name>.md`.

Write to `docs/code-walkthrough/<feature-name>.md` (kebab-case). Include header block (entry point, depth, layers, steps, date). Warn before overwriting existing files.

---

See @reference.md for full constraints.
