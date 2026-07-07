# /shipkit:spec — Reference

Templates and quick-references for the spec interview. See `rules/spec-driven.md` and
`rules/decisions.md` for the governing discipline; this file is the how-to-write-it detail.

---

## EARS quick-reference

Every requirement is one testable `shall` statement in one of five patterns. Pick the pattern
that matches the behavior; number requirements `REQ-N` so tasks and tests can cite them.

| Pattern | When to use | Template | Example |
|---|---|---|---|
| **Ubiquitous** | always-true property | `The <system> shall <response>.` | The API shall return responses in JSON. |
| **State-driven** | true during a state | `While <precondition>, the <system> shall <response>.` | While no session exists, the API shall return 401. |
| **Event-driven** | response to a trigger | `When <trigger>, the <system> shall <response>.` | When a user submits an invalid card, the system shall display a re-enter prompt. |
| **Optional** | only if a feature is present | `Where <feature>, the <system> shall <response>.` | Where SSO is enabled, the login page shall show the SSO button. |
| **Unwanted** | guarding against bad input/state | `If <trigger>, then the <system> shall <response>.` | If the upload exceeds 10MB, then the system shall reject it with a size error. |

Rules of thumb: one behavior per requirement (if you need "and", split it); prefer the most
specific pattern that fits; **escapable** — where EARS is forced, use a user story + acceptance
bullets and note why.

Each `shall` maps to one acceptance test — that 1:1 mapping is the whole reason to use EARS.

---

## Decision-record template (for `design.md` and `.shipkit/decisions/`)

```markdown
## Decision: <short title>   (→ REQ-2, REQ-4)

**Context.** What situation forced this decision; the constraints in play.

**Alternatives.**
1. <option A>
2. <option B>
3. <option C — if any>

**Case for <chosen>.** The argument for the choice.

**Case against <chosen>.** The honest costs, risks, and what we give up by choosing it.

**Decision.** We chose <option>.
**Falsifiability.** We would reverse this if <concrete, checkable condition — a metric, event,
or threshold>.
```

The falsifiability line **must** be concrete (e.g. "if p99 latency exceeds 200ms", "if we exceed
3 external API consumers") — never "if it turns out wrong". If no reversal condition exists, say
so explicitly. See `rules/decisions.md` for the ✅/❌ examples and the enforcement rule.

---

## File templates

### `spec.md` (Q1 — what)

```markdown
# Spec: <feature name>

> Spec accepted at commit `<sha>` on <branch>.

## Purpose
<one or two lines: what this is and why we're building it>

## User stories
- As a <role>, I want <goal> so that <benefit>.

## Requirements (EARS)
- **REQ-1.** When <trigger>, the <system> shall <response>.
- **REQ-2.** While <precondition>, the <system> shall <response>.
- **REQ-3.** If <trigger>, then the <system> shall <response>.

## Out of scope
<what this deliberately does NOT do>
```

### `design.md` (Q2 — how, as decision records)

```markdown
# Design: <feature name>

## Approach
<a few lines of orientation — the shape of the solution>

<one Decision block (template above) per real architectural choice, each citing its REQ-N>

## Data / interface changes
<schema, API, or contract changes — cite the requirements they serve>
```

### `tasks.md` (Q3 — steps, traceable)

```markdown
# Tasks: <feature name>

- [ ] **T1** <task> → REQ-1  (test first: <the behavior test that proves REQ-1>)
- [ ] **T2** <task> → REQ-2
- [ ] **T3** <task> → REQ-3

Order tasks so each leaves the build green. Every requirement must be covered by a task and a
test — an uncovered requirement is not done.
```

---

## Reminders

- Delegate heavy codebase reading to `codebase-explorer` — keep the interview cheap.
- Don't let the *how* leak into `spec.md`, or requirements get restated in `design.md`.
- Approval gates: requirements (Q1) before design; design (Q2, via native Plan Mode) before tasks.
- Project-wide decisions also go standalone in `.shipkit/decisions/NNNN-<slug>.md`.
