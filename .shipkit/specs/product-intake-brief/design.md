# Design: Product, intake, brief (Sprint 3, release 3.4.0)

## Approach

Two skills that ask (`product`, `intake`) and two scripts that do not (`brief.sh`,
`brief-verify.sh`). The skills run inline, because they interview the user. The scripts are
plain text processing over the spec format Sprint 2 made machine-readable: a brief is the
task's own lines plus the requirement text it cites, and the verification is a set difference
between the files that changed and the files the task was allowed to change.

---

## Decision: Intake is its own skill, not a phase of `/shipkit:spec`   (→ REQ-11 to REQ-17)

**Context.** Before a spec is written, someone should check the request against what the
product is for, against open specs and past decisions, and ask the few questions that change
what gets built. `/shipkit:spec` already has three phases and two approval gates. The owner
settled this as A2 when approving the plan.

**Alternatives.**
1. A separate `/shipkit:intake` skill that writes `intake.md`; `/shipkit:spec` runs it first
   when that file is missing.
2. A "phase 0" inside `/shipkit:spec`.
3. A rule sentence only: "check non-goals before specifying".

**Case for (1).** Intake is useful without a spec: a request can be turned away at a non-goal,
or found to be trivial, before any spec exists. Its output is a file the spec, the brief and
the reviewer can all read. It keeps `/shipkit:spec` from growing a fourth phase. Option 3 has
no room in a 3,000-byte rule budget and leaves nothing on disk.

**Case against (1).** One more skill description in every session, and the plan adds five.
Two skills to keep in step where there was one. A user who goes straight to `/shipkit:spec`
gets the intake anyway, so the separate name mostly serves the cases that stop early.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this — fold intake into `/shipkit:spec` — if, by the
Sprint 7 audit, every recorded use of `/shipkit:intake` in this repository was followed at
once by `/shipkit:spec` (no intake ever ended at "trivial" or at a conflict).

---

## Decision: The brief is built by a script, not written by the model   (→ REQ-18 to REQ-23)

**Context.** A task handed to an agent needs a brief: the goal, the requirement, the files it
may touch, how to prove it, what not to do. Today the session writes that from memory, and
what it leaves out or rewords is invisible. Since Sprint 2 every part of a brief exists as
structured text in the spec.

**Alternatives.**
1. `brief.sh` assembles the brief from `spec.md`, `design.md` and `tasks.md`, with no model.
2. The session writes the brief, guided by a template in a skill.
3. A script builds a skeleton and the model fills in the judgement parts.

**Case for (1).** The requirement reaches the agent word for word, so the agent and the
reviewer argue from the same sentence. The same task always yields the same brief, which makes
a bad result attributable to the spec rather than to a paraphrase. It costs no tokens to
build and can be tested with fixtures.

**Case against (1).** A script cannot notice that a task needs context the spec does not
hold; the brief is only as good as the spec. Parsing Markdown with awk is brittle against
specs that drift from the format. Extra context still has to be added by hand, below the
brief.

**Decision.** We chose (1). Extra context may be added below the script's output, never in
place of it.
**Falsifiability.** We would reverse this — move to (3) — if, during Sprints 3 to 6, more than
one in three briefs handed to an agent needed context added below it for the agent to finish
the task.

---

## Data / interface changes

- New skills `/shipkit:product` and `/shipkit:intake` (core goes from 12 to 14 skills) —
  REQ-1 to REQ-17.
- New file formats: `.shipkit/product.md`, `~/.claude/shipkit/studio.md`,
  `.shipkit/specs/<slug>/intake.md` — REQ-1, REQ-7, REQ-16.
- Two new columns in the project registry, `Product` and `Top Goal` — REQ-8, REQ-9.
- New scripts `brief.sh <project-dir> <slug> <task-id>` and
  `brief-verify.sh <project-dir> <slug> <task-id> <base-ref>` — REQ-18 to REQ-26.
- New eval cases under `plugins/shipkit/evals/intake/` — REQ-11, REQ-12, REQ-14.
