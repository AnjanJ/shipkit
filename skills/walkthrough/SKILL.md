---
description: "End-to-end feature code walkthrough"
user-invocable: true
disable-model-invocation: true
argument-hint: "[<feature-name> [surface|deep]]"
context: fork
agent: codebase-explorer
---

<!-- FIRE-AND-FORGET FORK: runs non-interactively as the read-only codebase-explorer
     agent. It cannot ask the user anything mid-run and cannot write files. It traces
     end-to-end and RETURNS the walkthrough; the main session presents it and writes
     docs/code-walkthrough/<feature>.md only after the user approves. -->

# /walkthrough — Guided Code Walkthrough

Trace one feature end-to-end — from trigger to database and back — and produce a
step-by-step walkthrough, returned as a proposed `docs/code-walkthrough/<feature-name>.md`.

**How this relates to the other explainers:**
- `/shipkit:map` (archivist) indexes WHAT exists and where — the city map
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
You ARE the read-only explorer — search directly:
- Routes/URL patterns matching the feature name
- File names matching the feature name (controllers, services, jobs, commands)
- Git log: `git log --all --oneline --grep="<feature-name>"` for related commits
- Test files mentioning the feature name (tests often name features explicitly)

### 1.2 Catalog All Entry Points

Features often have multiple triggers: HTTP requests, background jobs, cron, webhooks, events, admin actions, CLI, internal calls. Find ALL of them and record a table (trigger type, entry point, file:line) for the final output.

### Pick the entry point yourself — you cannot ask mid-run
- If a file path was given, that IS the entry point.
- Otherwise trace the **primary user-facing trigger** (usually the HTTP route).
- Include the full entry-point table in your output with a note: "re-run
  `/shipkit:walkthrough <feature> from <entry>` to trace a different trigger."
- Depth comes from the arguments; default `deep`.

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

Compile internal trace (step, layer, file:line, method, data in/out, side effects, errors), then continue to Phase 3.

---

## Phase 3: Explain

**Goal:** Transform the raw trace into a readable, guided walkthrough. See @reference.md for section formats (user journey, code trace, data transformations, side effects, error paths, key concepts).

---

## Phase 4: Return the Deliverable

**You are read-only and non-interactive: write NOTHING.** Return in your final output:

1. The entry-point table (with the re-run note for other triggers).
2. The full walkthrough under a marked heading: `PROPOSED: docs/code-walkthrough/<feature-name>.md`
   (kebab-case), including the header block (entry point, depth, layers, steps, date).

The main session presents it and, on approval, writes the file — checking first whether it
would overwrite an existing one.

---

See @reference.md for full constraints.
