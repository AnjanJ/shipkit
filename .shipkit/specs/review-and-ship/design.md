# Design: Reviewer and ship gate (Sprint 4, release 3.5.0)

## Approach

The reviewer is an agent with read-only tools that is handed two things — a spec's name and a
base ref — and nothing the implementer said. The gate is a skill that runs inline in the main
session: it runs two scripts, starts the reviewer, reads the answers and writes a report. The
main session starts the reviewer; no agent starts another.

---

## Decision: The reviewer uses the session's model   (→ REQ-2, REQ-6)

**Context.** The reviewer reads a spec and a diff and judges each requirement. A wrong `MET`
is the costly error: it lets unfinished work through the gate. The owner settled this as A4.
Whether an agent file may omit `model:` and inherit the session's model is a platform claim
the plan has not yet tested; S4-T1 checks it first.

**Alternatives.**
1. No `model:` in the agent file; it inherits the session's model.
2. Pin `model: sonnet` to cap the cost of every review.
3. Pin the most capable model available, whatever the session uses.

**Case for (1).** The review is only worth running if it is at least as careful as the work
it checks; a reviewer weaker than the implementer waves through what it cannot follow. The
user has already chosen what they are willing to pay for in this session. Option 3 names a
model that will be out of date within a release or two.

**Case against (1).** A review costs whatever the session costs, on every ship. A user on a
small model gets a small reviewer and may not realise it. And the result of the gate now
depends on which model the session happened to be using.

**Decision.** We chose (1). If the platform does not allow an agent to omit `model:`, the
written fallback is `model: sonnet`.
**Falsifiability.** We would reverse this — pin a model — if the `reviewer/missing-req` eval
passes on `sonnet` and fails on the session default in two of three runs, or if a single
`/shipkit:ship` review of a sprint-sized diff costs more than $2 at list price.

---

## Decision: The gate is a skill, not a script   (→ REQ-10, REQ-11)

**Context.** Five of the gate's seven steps are mechanical (run a script, run the tests, grep
for unticked boxes, check `git status`). Two need judgement: the reviewer's verdict, and
whether each decision's reversal condition is concrete. Sprints 2 and 3 built scripts wherever
a script could do the job.

**Alternatives.**
1. A skill, `/shipkit:ship`, run inline, that calls the scripts for the mechanical steps.
2. A script, `ship.sh`, that does the mechanical steps and cannot do the other two.
3. A script for the five mechanical steps plus a skill that wraps it and adds the two.

**Case for (1).** Starting the reviewer is something only the main session can do. Finding the
project's test command, asking for it once, and asking before setting `Status: shipped` are
conversations. The mechanical steps are each one command; a wrapper script around five
commands would add a file without removing any judgement.

**Case against (1).** A skill's steps are instructions a model follows, not code: it can skip
one, or report `PASS` for a command it did not run. The scripts in Sprints 2 and 3 cannot do
that. The gate is the place that matters most and it is the least mechanically enforced.

**Decision.** We chose (1). The report must carry the evidence for every step — the command
and the tail of its output — so that a skipped or invented step is visible to a reader.
**Falsifiability.** We would reverse this — move the mechanical steps into a script, option
3 — if a gate report in this plan records `PASS` for a step whose evidence is missing or does
not match a re-run, even once.

---

## Data / interface changes

- New agent `reviewer` (core goes from 5 to 6 agents) — REQ-1 to REQ-8.
- New skills `/shipkit:ship` and `/shipkit:escape` (core goes from 14 to 16 skills) — REQ-10
  to REQ-18.
- `spec-check.sh` gains `--as-shipped` — REQ-9.
- New files a project accumulates: `.shipkit/releases/<date>-<slug>.md` and
  `.shipkit/escapes/NNNN-<slug>.md` — REQ-11, REQ-18.
- New eval cases under `plugins/shipkit/evals/reviewer/` and `evals/escape/` — REQ-2, REQ-6,
  REQ-16, REQ-17.
