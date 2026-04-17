# Walkthrough — Reference Material

## Phase 3: Explanation Section Formats

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
