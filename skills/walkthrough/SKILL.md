---
description: "Trace one feature end-to-end and write a guided code walkthrough in docs/code-walkthrough/"
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

**Goal:** Transform the raw trace into a readable, guided walkthrough. Present it for
review before writing to disk.

### 3.1 User Journey

3-5 sentences of what happens from the USER's perspective. No code, no technical terms.

### 3.2 Step-by-Step Code Trace

For each step: layer, file:line, 2-3 sentence explanation (WHY, not just what), optional code snippet, data in/out.

### 3.3 Data Transformation Summary

Table showing how data changes shape across layers (params → model → DB → response).

### 3.4 Side Effects (deep mode only)

List all side effects grouped by type: jobs, events, external APIs, emails, cache ops.

### 3.5 Error Paths (deep mode only)

For each failure: what goes wrong → where caught → what user sees.

### 3.6 Key Concepts (deep mode only)

Define 3-5 domain terms or patterns from this trace in plain language.

### CHECKPOINT — Present full walkthrough for review. Write only after approval.

---

## Phase 4: Write

**Goal:** Write the approved walkthrough to `docs/code-walkthrough/<feature-name>.md`.

Write to `docs/code-walkthrough/<feature-name>.md` (kebab-case). Include header block (entry point, depth, layers, steps, date). Warn before overwriting existing files.

---

## Constraints

- **File:line references mandatory** — every step must cite exact source location
- **Read-only until Phase 4** — Phases 1-3 only read files and run git commands
- **Use codebase-explorer for heavy reading** — keep main context clean for reasoning
- **User checkpoints mandatory** — present findings and WAIT at every phase boundary
- **Plain language required** — define every domain term on first use
- **Cap trace at 10 hops** — if deeper, note "continues beyond trace depth"
- **surface = happy path only** — skip side effects, error paths, key concepts sections
- **Output length: surface 50-80 lines, deep 100-200 lines** — never exceed 200 lines
- **Stack-agnostic** — all phases work for any language/framework
- **No auto-writing** — present full doc in Phase 3, write only after approval in Phase 4
- **Warn before overwriting** — existing walkthrough files require explicit confirmation
- **Tests inform the trace** — read tests in Phase 2 to surface edge cases code hides
- **No jargon without definition** — if you use a term, define it on first use
- **One feature per walkthrough** — don't combine multiple features in one document
