# /shipkit:spec — Reference

Templates and quick-references for the spec interview. The always-on `spec-driven` and
`decisions` rules say *when* to write a spec or a record, in a few lines each; this file is the
single source for *how* — the EARS patterns, the five-part record, the file templates, and how
the workflow styles change the ceremony.

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

### The five parts, and why each is there

1. **Context** — what situation forced the decision, and the constraints in play. Without it,
   no one can later judge whether the choice was reasonable *for the situation you were in*.
2. **Alternatives** — the options actually considered: **two or more real ones**, not strawmen.
   Naming them is what proves you *decided* rather than *defaulted*. A default with no real
   alternative, or a one-liner, does not get a record.
3. **Case for** — the argument for the chosen option.
4. **Case against** — the honest argument *against your own choice*: the costs, the risks, what
   you give up. Do not skip it. This part is what makes the record trustworthy.
5. **Decision + falsifiability clause** — the choice, plus one sentence: "I would reverse this
   if ___."

### The falsifiability clause must be concrete — this is enforced

The clause is the point of the whole record: it makes a decision *checkable for staleness
later*. It **must** be an observable condition — a metric, an event, or a threshold:

- ✅ "…if p99 latency exceeds 200ms." / "…if we exceed 3 external API consumers." / "…if the
  team grows past 8 engineers."
- ❌ "…if it turns out to be wrong." / "…if it doesn't work out." / "…if requirements change."

A vague hedge is not a falsifiability clause — rewrite it or the record is incomplete. If you
genuinely cannot state a reversing condition, say so explicitly ("no clear reversal condition
identified") rather than faking one.

### Where records live

- **Feature-scoped** decisions → inline in that spec's `.shipkit/specs/<feature>/design.md`.
  A spec's design *is* a set of decision records.
- **Project-wide** decisions (not tied to one feature — "Paddle over Stripe", "monolith over
  microservices") → standalone `.shipkit/decisions/NNNN-<slug>.md`, numbered in sequence. This
  is the durable log the elders read: `PROJECT_MAP.md` records *what/where*, the log records
  *why*.
- A record that is superseded is marked, not deleted, and points to the record that replaced it.
- A substantive commit message already names rejected alternatives (see `/shipkit:commit`). Use
  a record, not just a commit line, when a future reader will need to revisit the decision.

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

## Scope, traceability and workflow style

- **Spec non-trivial work only** — new features, refactors, integrations, architectural
  changes. Trivial work (typo, rename, config, one-liner, "just do it") is exempt; say so when
  you skip a spec, don't skip silently. Scale the spec to the work: a small-but-non-trivial
  change needs a few lines per question, and a full spec folder is for features and multi-file
  changes, not every branch.
- **Brownfield:** lock what exists and spec only the delta.
- **Traceability:** requirement → task → code → test. A requirement with no task and no test is
  not done. The definition of done is a failing test written before the implementation, not a
  checkbox.
- **Stamp** an accepted spec with its commit so drift from the code is detectable later. Specs
  branch and merge with the code they describe.
- **Workflow style** (the `Workflow style:` line in CLAUDE.md, set by `/shipkit:setup`; absent
  means `test-first`):
  - `strict-tdd` — iron-law red-green-refactor for every change: write the test first, watch it
    fail for the right reason, write the minimal code to pass, then refactor with the suite
    green. Never write implementation before a failing test. With the `shipkit-workflows`
    plugin installed, `/shipkit-workflows:tdd` walks this with enforcement. Specs as written
    here.
  - `test-first` — non-trivial work is planned first (plan mode: clarify requirements, design
    the approach, break into atomic tasks; heavy codebase research goes to `codebase-explorer`),
    then done task by task, test before implementation where practical, one atomic commit per
    task. Skipping tests is reasonable for config, docs, generated code and throwaway
    prototypes — say so. Specs as written here.
  - `lightweight` — plan and implement; tests where they earn their keep. Answer the three
    questions **inline in the conversation**, a few lines each, and write `.shipkit/specs/`
    only when the user asks or invokes `/shipkit:spec`. The decisions rule still applies in
    full: a real fork still gets a record.
- Invoking `/shipkit:spec` by name always writes the files, whatever the style.

## Reminders

- Delegate heavy codebase reading to `codebase-explorer` — keep the interview cheap.
- Don't let the *how* leak into `spec.md`, or requirements get restated in `design.md`.
- Approval gates: requirements (Q1) before design; design (Q2, via native Plan Mode) before tasks.
- Project-wide decisions also go standalone in `.shipkit/decisions/NNNN-<slug>.md`.
