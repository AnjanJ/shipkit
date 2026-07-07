---
description: "Write a spec for a non-trivial feature — the three questions (what are we building / how should it work / how will we know it's done) as durable .shipkit/specs/ artifacts, requirements in EARS, design as decision records. TRIGGER when: the user asks to spec, plan, or design a new feature or a multi-file change before building. DO NOT TRIGGER when: the change is trivial (typo, rename, config, one-liner), the user is mid-implementation, or they want a where-things-live index (use /shipkit:map) or a system explainer (use /shipkit:explain-system)."
user-invocable: true
argument-hint: "<feature-slug> [requirements|design|tasks]"
---

<!-- Runs INLINE (no context: fork) on purpose: it interviews the user through the three
     questions and needs AskUserQuestion for the Q1→Q2→Q3 approval gates, which forked
     skills cannot use. It delegates heavy codebase research to `codebase-explorer` so the
     interview stays cheap; native Plan Mode is the review gate before tasks. -->

# /shipkit:spec — Spec a Non-Trivial Feature

Turn a feature idea into a durable, verified spec before building it: the **three questions**,
written to `.shipkit/specs/<feature-slug>/`. This is the forward-looking half of shipkit's
knowledge layer — `PROJECT_MAP.md` says what exists; a spec says what you're about to build.

Governed by `rules/spec-driven.md` (the three questions, EARS) and `rules/decisions.md` (the
five-part decision format). This skill runs the interview that produces the artifacts those
rules describe.

**Spec non-trivial work only.** A typo or one-liner does not get a spec — if the request is
trivial, say so and just do it. See `rules/spec-driven.md` for the trivial-vs-non-trivial split.

## Arguments

`$ARGUMENTS` — `<feature-slug> [phase]`

- `<feature-slug>` — kebab-case name; the spec lives at `.shipkit/specs/<feature-slug>/`.
- *(no phase)* — run all three questions end-to-end (default).
- `requirements` — regenerate `spec.md` only (Q1).
- `design` — regenerate `design.md` only (Q2).
- `tasks` — regenerate `tasks.md` only (from an accepted `spec.md` + `design.md`).

If `.shipkit/specs/<feature-slug>/` already exists, read it and refine rather than overwrite.

## The interview — three questions, three gates

Delegate any heavy "how does the current code work?" reading to the **`codebase-explorer`**
agent so the main context stays thin. Ask the user only what the code cannot tell you.

### Q1 — What are we building? → `spec.md`

1. Ask the user for the feature's purpose and the user-facing behavior, if not already given.
2. Write requirements in **EARS** (see @reference.md for the five patterns and worked examples),
   numbered `REQ-1`, `REQ-2`, … One testable behavior per requirement. Drop to a user story +
   acceptance bullets only where EARS is genuinely awkward, and say why.
3. **Gate:** show the requirements and get approval (AskUserQuestion) before designing. Wrong
   requirements make everything downstream wrong — this gate is the cheapest place to fix them.

### Q2 — How should it work? → `design.md`

1. Have `codebase-explorer` surface the relevant existing code, boundaries, and constraints.
2. Write the approach as **decision records** — every real choice (with ≥2 alternatives) gets the
   five parts: Context, Alternatives, Case-for, Case-against, Decision + a **concrete
   falsifiability clause**. See @reference.md and `rules/decisions.md`. A vague clause is a bug.
3. Each design decision references the requirement(s) it serves (`→ REQ-2`).
4. **Gate:** use **native Plan Mode** to present the design for approval before breaking it into
   tasks. This is the review gate — don't write `tasks.md` until the design is accepted.

### Q3 — How will we know it's done? → tests + `tasks.md`

1. For each requirement, state the acceptance test that proves it (behavior-focused / BDD-style
   for user-facing behavior). The definition of done is a failing test, not a checkbox.
2. Write `tasks.md`: ordered tasks, each citing the requirement it satisfies (`→ REQ-3`).
   Prefer test-before-implementation per `rules/shipkit.md`. Traceability runs
   requirement → task → code → test.

## After the interview

1. Write the three files under `.shipkit/specs/<feature-slug>/` and stamp `spec.md` with the
   accepted commit: `> Spec accepted at commit <sha> on <branch>.` (so drift is detectable later).
2. If a decision is **project-wide** (not tied to this feature), also record it standalone at
   `.shipkit/decisions/NNNN-<slug>.md`, not just inline in `design.md`.
3. Tell the user the spec is ready and that implementation can begin task by task — the default
   workflow (`rules/shipkit.md`) takes over from here.

See @reference.md for the EARS quick-reference, the decision-record template, and the file
templates for `spec.md` / `design.md` / `tasks.md`.
