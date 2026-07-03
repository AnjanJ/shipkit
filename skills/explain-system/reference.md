# Explain System — Reference Material

## ADR Format Template

For each major architectural decision, present in ADR format:
- **Context:** What situation/constraint led to this decision?
- **Decision:** What was chosen?
- **Trade-offs:** What was gained? What was sacrificed? What alternatives existed?
- **Consequences:** What followed from this decision?
- **Confidence:** VERIFIED (code evidence), INFERRED (indirect evidence), UNCERTAIN (needs user input)
- **Revisit-when:** Under what conditions should this decision be reconsidered?

## Phase 4: Verification Loop — Detailed Steps

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

## Phase 5: Document Structure Template (100-200 lines)

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

## Phase 6: Trade-Off Analysis Template

For each improvement opportunity found during Phases 2-4:
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

## Constraints

- **Read-only, always** — you never write files; the document is returned as a proposal
- **No mid-run interaction** — non-interactive fork; verification is self-enforced (unverifiable claims are cut or made explicit open questions, never user-arbitrated) and the caller handles review + file writing
- **Use codebase-explorer for heavy reading** — keep your own context for reasoning
- **Zero UNCERTAIN claims in final doc** — Phase 4 gate, not optional
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
