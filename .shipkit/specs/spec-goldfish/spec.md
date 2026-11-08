# Spec: Spec goldfish — a zero-context read of a spec before its tasks are written

> Spec accepted at commit `3fbf612` on spec-goldfish (2026-11-08).
> Status: shipped
> Paths: plugins/shipkit/agents/goldfish.md, plugins/shipkit/skills/spec/, plugins/shipkit/evals/goldfish/, scripts/smoke.sh, scripts/lint.py, docs/design/context-cost.md, docs/design/eval-history.md, scripts/evals.sh, ROADMAP.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/skills/ship/SKILL.md

## Purpose

An implementer handed `brief.sh` output knows only what the spec's files say. The author of the
spec knows much more, and cannot see which of it never reached the page. A new read-only agent,
`goldfish`, reads the spec cold just before `/shipkit:spec`'s design gate and says, requirement by
requirement, whether it could write the test from the files alone. The owner then sees the design
and the goldfish's report together. A gap is fixed by writing the missing knowledge into the spec,
because the implementer is a goldfish too.

Source: `.shipkit/specs/spec-goldfish/intake.md` (2026-11-08); Google's Elephant-Goldfish Model,
`google/elephant-goldfish-model`, `docs/designs/review.md`; decision 0006
(`.shipkit/decisions/0006-main-session-starts-every-agent.md`).

## User stories

- As the owner, I want to see which requirements a reader without my context could not test, so
  that I fix the spec before tasks are cut from it, not after an implementer guesses.
- As an implementer agent handed a brief, I want the requirement I am given to be answerable from
  the spec's files, so that I do not fill a gap with a guess.

## Requirements (EARS)

### The agent

- **REQ-1.** The shipkit plugin shall ship an agent `goldfish` in
  `plugins/shipkit/agents/goldfish.md` with `model: sonnet`, `tools: Read, Glob, Grep, Bash` and
  `disallowedTools: Edit, Write, Agent`.
- **REQ-2.** When started with a spec slug, the goldfish shall read `.shipkit/specs/<slug>/spec.md`,
  then `design.md` if it exists, then the repository files those two name, and no other file under
  `.shipkit/specs/<slug>/`.
- **REQ-3.** If the request carries anything besides the slug, the goldfish shall ignore it and
  use only what it read under REQ-2.
- **REQ-4.** If no slug is given, or `.shipkit/specs/<slug>/spec.md` does not exist, the goldfish
  shall say which and stop.
- **REQ-5.** For each `REQ-N` in `spec.md`, the goldfish shall give exactly one row: `TESTABLE`
  with a one-line sketch of the test it would write, or `UNCLEAR` with what is missing.
- **REQ-6.** The goldfish shall list each term the spec relies on that neither the spec, its
  design nor a file they name defines, and each assumption the spec relies on without stating it,
  or write "None." under each heading.
- **REQ-21.** The goldfish shall list an unstated assumption only if the requirement's test, as the
  requirement is written, cannot be written without it, and shall give for each one what the test
  would have to guess; it shall not list an input the requirement does not mention, nor behaviour
  a test would meet only by checking more than the requirement asks. (Amended 2026-11-08, on the
  owner's yes, after T5's `gap` reply listed both kinds.)
- **REQ-7.** The goldfish's reply shall end with `VERDICT: SELF-CONTAINED` when no row is
  `UNCLEAR` and both lists are empty, and `VERDICT: GAPS` otherwise, with nothing after that line.

### `/shipkit:spec`

- **REQ-8.** When `design.md` is written and before the Plan Mode gate, `/shipkit:spec` shall have
  the main session start `shipkit:goldfish` with the slug and nothing else, write its reply to a
  file, and show the reply to the owner whole and unchanged.
- **REQ-9.** If the goldfish's reply has no `VERDICT:` line, `/shipkit:spec` shall start it once
  more with the same slug, and if the second reply has none either, tell the owner the read
  failed and go on to the gate.
- **REQ-10.** Before the Plan Mode gate is shown, the main session shall give each finding one
  disposition: `fixed` (the spec or design was edited), `contested` (with a `path:line` the
  goldfish could have read under REQ-2), or `escalated` (put to the owner).
- **REQ-11.** If a finding can be answered only by knowledge that is in no file the goldfish could
  read under REQ-2, then the main session shall not mark it `contested`.
- **REQ-12.** When the owner accepts an escalated finding without a fix, `/shipkit:spec` shall
  write into `spec.md`, under `## Goldfish`, one line per accepted gap in the form
  `Goldfish: GAPS accepted by owner — <REQ-N or term>`.
- **REQ-13.** If any finding of the first read was `fixed`, `/shipkit:spec` shall start the
  goldfish a second time; it shall never start it more than twice for one gate.
- **REQ-14.** Where the owner says "no goldfish", `/shipkit:spec` shall skip the read and write
  `Goldfish: skipped on the owner's word (<date>)` under `## Goldfish` in `spec.md`.
- **REQ-15.** A `GAPS` verdict shall not stop the spec: once every finding has a disposition, the
  Plan Mode gate is shown as before.

### Context cost

- **REQ-16.** `scripts/context-cost.sh`'s `agents` row, with both plugins and the goldfish, shall
  read at most 1,075 bytes, and `docs/design/context-cost.md` shall give 1,075 as the agents
  ceiling with the reason (this spec).

### The stale platform claim

- **REQ-17.** `ROADMAP.md`, `scripts/lint.py` and `plugins/shipkit/skills/ship/SKILL.md` shall no
  longer say that a subagent cannot start a subagent; where each gave that as a reason, it shall
  give decision 0006 instead.

### Evals

- **REQ-18.** An eval case `goldfish/gap` shall start the goldfish on a fixture spec with one
  planted undefined term, and pass only when the reply ends `VERDICT: GAPS` and names that term.
- **REQ-19.** An eval case `goldfish/clean` shall start the goldfish on a fixture spec with no
  gap, and pass only when the reply ends `VERDICT: SELF-CONTAINED`.
- **REQ-22.** `goldfish/gap` shall also fail when the reply's `## Unstated assumptions` section
  names a zero or negative amount, or which of two checks runs first. (Amended 2026-11-08.)
- **REQ-20.** The eval run that first runs REQ-18 and REQ-19 shall record each case's result and
  cost in `docs/design/eval-history.md`. [untested: a paid run, read from its record]

## Out of scope

- EGM's five stages, its personas (zoom-out, critic, style, implementation readiness) and its
  synthesizer agent.
- Nesting: no agent starts another (decision 0006).
- Re-running the goldfish when a spec is amended outside `/shipkit:spec` (by `/shipkit:escape` or
  by hand).
- Making `GAPS` blocking. The design records the condition under which it would become blocking.
- Changes to `/shipkit:escape`: an accepted gap is a line in `spec.md`, which escape already reads.
- Reading `intake.md` (`brief.sh` never gives it to an implementer) or `tasks.md` (it does not
  exist yet at the design gate).
