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
> Status: open
> Paths: app/billing/, tests/billing/

## Purpose
<one or two lines: what this is and why we're building it>

## User stories
- As a <role>, I want <goal> so that <benefit>.

## Requirements (EARS)
- **REQ-1.** When <trigger>, the <system> shall <response>.
- **REQ-2.** While <precondition>, the <system> shall <response>.
- **REQ-3.** If <trigger>, then the <system> shall <response>.
- **REQ-4.** The README shall describe <thing>. [untested: prose, verified by reading]

## Out of scope
<what this deliberately does NOT do>
```

The three lines under the title are read by scripts, so keep their exact form:

- **The stamp** — written when the requirements are accepted. Before that, write
  `> Spec not yet accepted.` in its place.
- **`Status`** — one of `draft` (being written), `open` (accepted, work in progress),
  `shipped` (done), `dropped` (abandoned). A spec with no `Status` line is treated as `open`.
  Only an `open` spec is nagged about by the session hook; only a `shipped` one is asked for
  tests by `spec-check.sh`.
- **`Paths`** — a comma-separated list of the files or folders the feature lives in (no spaces
  inside a path). Drift is then counted only on commits that touch them. No `Paths` line means
  the whole repository.

**How a test cites a requirement.** Anywhere in the test file — a comment or a test name —
write the spec's folder name, a slash, and the requirement: `refunds/REQ-3`. The folder name
is needed because every spec has its own `REQ-1`. A citation in a `.md` file, under `docs/` or
under `.shipkit/` does not count.

**How a requirement is excused from having a test.** End it with `[untested: <reason>]`, as
`REQ-4` does above. Use it for requirements that are prose only, and give a real reason.

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

- [ ] **T1** Refund a charge in full → REQ-1
  - Files: app/billing/refunds.py, tests/billing/test_refunds.py
  - Test: tests/billing/test_refunds.py::test_full_refund_returns_a_receipt
  - After: none
  - Done when: `pytest tests/billing/test_refunds.py` → all pass
- [ ] **T2** Reject refunds larger than the original charge → REQ-2
  - Files: app/billing/refunds.py, tests/billing/test_refunds.py
  - Test: tests/billing/test_refunds.py::test_refund_over_charge_is_rejected
  - After: T1
  - Done when: `pytest tests/billing/test_refunds.py` → all pass
```

Every task has the four sub-lines:

- **`Files`** — the only files the task may change, comma-separated.
- **`Test`** — the test that must fail before the work and pass after it.
- **`After`** — the tasks that must be finished first, comma-separated, or `none`.
- **`Done when`** — the command to run and what it must show.

**The sharing rule:** if two tasks list the same file, the later one must name the earlier one
on its own `After` line — directly, not through a chain. `T2` above shares both files with `T1`,
so it says `After: T1`. This is what makes it safe to give tasks to agents working at the same
time: two tasks with no file in common and no `After` between them can run together.

Order tasks so each leaves the build green. Every requirement must be mentioned by a task, and
every requirement not marked `[untested: …]` must be cited by a test before the spec is `shipped`.

**Check it with the script**, not by eye:

```sh
sh "<plugin root>/scripts/spec-check.sh" . <feature-slug>
```

It prints one line per gap — `MISSING-TASK`, `MISSING-TEST`, `MISSING-FIELD`, `BAD-AFTER`,
`CONFLICT` — and exits 1 if there is any. `WAIVED` and `SKIPPED` lines are information, not gaps.

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
