# Design: Spec goldfish — a zero-context read of a spec before its tasks are written

## Approach

There are seven records. Two cover the agent: what form it takes, and what it counts as a gap. Three
cover the skill: where the read runs, what a `GAPS` verdict does, and where the reply is kept. One
covers the stale platform claim, and one the eval fixture. The agent copies the reviewer's habits
wherever they fit: the frontmatter, ignoring anything it is told besides the slug, a fixed reply
shape ending in one verdict line, `git grep` for searches, and a second start when the reply has no
verdict. The skill copies the ship gate's step 4. Where this design departs from those two, a
record says why.

The goldfish's instructions live in its agent file. `/shipkit:spec` gains one numbered step in Q2,
between "each design decision references the requirement(s)" and the Plan Mode gate, and the gate
then shows the design, the goldfish's reply and one disposition per finding together.

---

## Decision: The goldfish is a new agent, `shipkit:goldfish`   (→ REQ-1, REQ-16)

**Context.** The intake (answer 1) settled this with the owner; this record keeps the reasons where
`brief.sh` and the ship reviewer will read them. The agents every session loads cost 991 bytes of
descriptions on 2026-11-08 against a 1,000-byte ceiling (`docs/design/context-cost.md:20`, smoke
check `agents-four`, which also asserts three core agents).

**Alternatives.**
1. A new agent file, `plugins/shipkit/agents/goldfish.md`, with a description of about 80 bytes and
   the agents ceiling raised to 1,075.
2. A mode of `reviewer`, chosen by the prompt ("read cold, no base ref").
3. The built-in `Explore` agent, given a goldfish prompt by the main session.

**Case for (1).** The file fixes the instructions, the model and the tools, and no prompt can change
them. That is what keeps a goldfish a goldfish (decision 0006, "Case for"). The description can say
it is started by `/shipkit:spec` only, so no session reaches for it on its own.

**Case against (1).** Every session in every project pays about 80 more bytes for an agent that runs
once per spec, and the ceiling the thinning plan won (1,720 → 991) moves back up. (2) costs no
bytes. (3) costs none either, and needs no file to maintain. A fourth core agent also means smoke
check `agents-four` changes its count.

**Decision.** We chose (1). (2) would put two verdict vocabularies in one file and the mode in a
prompt, which is the path the goldfish exists to close. (3) reads excerpts by design, the wrong
habit for a reader that must take in a whole spec, and shipkit does not control its model.
**Falsifiability.** We would reverse this, folding the goldfish into `reviewer` as a second
procedure, if a fifth core agent is proposed and the agents row would pass 1,075 bytes.
**Fired-if.** `test "$(ls plugins/shipkit/agents/*.md | wc -l)" -ge 5`

---

## Decision: A gap is what a test author would have to guess   (→ REQ-5, REQ-6, REQ-7)

**Context.** A reader with no context can find something missing in any spec: why the feature
exists, how the code it touches works, what a word means to a newcomer. If every such thing counts,
the verdict is always `GAPS` and the owner learns to skip it. The implementer the goldfish stands in
for has one job per requirement: write the test that fails first.

**Alternatives.**
1. A finding counts only if, without it, the goldfish could not write that requirement's test
   without guessing: a term with no definition in the spec, its design or a file they name; an
   input, output, threshold or error the requirement leaves open; an assumption the test would
   have to make. Background a test does not need is not a finding.
2. Anything a newcomer would ask about counts, as EGM's goldfish reviews do.
3. Only `UNCLEAR` requirement rows count, with no separate lists for terms and assumptions.

**Case for (1).** It ties every finding to a requirement's test, the thing `brief.sh` hands an
implementer, so the main session can check each one. The `goldfish/clean` eval can pass, because a
clean spec does not have to explain the whole repository.

**Case against (1).** It will miss a gap that hurts the design rather than a test. For example, a
decision whose reason depends on context outside the repo will pass as long as each test can still
be written. (2) catches that, and is what the source model does. (3) is simpler to grade, but an
undefined term used in three requirements would come back as three rows instead of one named term.

**Decision.** We chose (1). The agent's instructions give the test-author rule and one example of a
finding that does not count.
*Amended 2026-11-08, on the owner's yes (→ REQ-21, REQ-22):* T5's traced `gap` reply listed two
assumptions the rule should have dropped: zero or negative amounts, and the order of two checks.
The agent's step 3 ("each thing a test would have to assume") was wider than the rule, and the
rule came after the procedure. Now the rule comes first, each assumption names what its test must
guess, and two kinds of item are named as not counting. A third grader on `goldfish/gap` watches
for that noise.
**Falsifiability.** We would reverse this, loosening it toward (2), if `goldfish/gap` fails 2 of
its first 3 runs. We would tighten the wording if `goldfish/clean` fails 2 of its first 3.
**Fired-if.** manual

---

## Decision: The read runs after `design.md` is written and before the Plan Mode gate   (→ REQ-8, REQ-13)

**Context.** `/shipkit:spec` has two gates: requirements (Q1, `AskUserQuestion`) and design (Q2,
native Plan Mode, `plugins/shipkit/skills/spec/SKILL.md:72`). `tasks.md` is written after the
second. The intake's assumption puts the read at the second, so the owner sees the design and the
report together.

**Alternatives.**
1. Before the Plan Mode gate, reading `spec.md` and `design.md`.
2. Before the Q1 gate, reading `spec.md` alone.
3. After `tasks.md`, reading all three, before `spec-check.sh` runs.

**Case for (1).** A requirement is often clear only once a decision fixes a term (a threshold, a file
name). At (1) the goldfish sees both, the owner approves both at once, and `tasks.md` is cut from a
spec that has already been read cold.

**Case against (1).** A gap in a requirement is cheapest to fix at Q1, before a design is built on
it, and (1) finds it one gate late. A fix at (1) can also edit an accepted requirement, and the
stamp then names a commit from before the edit. (3) would also check each task's `Test` line, which
is closest to what an implementer actually gets.

**Decision.** We chose (1). An accepted requirement that a finding changes is edited in place, and
the Plan Mode gate names each one. The stamp stays, since the owner approves the change at that
gate.
**Falsifiability.** We would reverse this, moving the read to the Q1 gate, if in 3 of the first 5
specs the read covers, a `fixed` finding changes the text of a requirement rather than the design.
**Fired-if.** manual

---

## Decision: `GAPS` is advisory; an accepted gap is written into the spec   (→ REQ-10, REQ-11, REQ-12, REQ-15)

**Context.** The intake (answer 2) settled this with the owner, along with the reversal condition
below. The ship reviewer answers `CANNOT TELL` or `NOT MET` per requirement, and its report is kept
under `.shipkit/releases/`.

**Alternatives.**
1. Advisory. Every finding gets a disposition before the gate. A gap the owner accepts is written
   under `## Goldfish` in `spec.md`.
2. Blocking. The Plan Mode gate is not shown while the verdict is `GAPS`.
3. Advisory, with nothing recorded.

**Case for (1).** The owner keeps the last word, and an accepted gap leaves a line that
`/shipkit:escape` and the ship reviewer will both read. A guess made later can then be traced to the
gap it filled.

**Case against (1).** A gap that is easy to accept is easy to keep. The rule against contesting
outside knowledge (REQ-11) is prose that the main session must follow with no check behind it. (2)
would force the fix, at the cost of a loop when the goldfish is wrong, and the limit of two reads
(REQ-13) would then leave a spec that can never pass.

**Decision.** We chose (1).
**Falsifiability.** We would make `GAPS` blocking if, in 2 of the first 5 specs approved with an
accepted gap, the ship reviewer later answers `CANNOT TELL` or `NOT MET` on the same requirement.
**Fired-if.** manual

---

## Decision: The reply is written to a temporary file and pasted whole, as the ship gate's review is   (→ REQ-8, REQ-9)

**Context.** The ship gate writes the reviewer's reply to `${TMPDIR:-/tmp}/shipkit-ship-review.out`
and pastes from that file, because a reply copied from memory arrived as a summary in the 4.7.0
and 4.9.0 gates (`ship/SKILL.md:72-76`).

**Alternatives.**
1. `${TMPDIR:-/tmp}/shipkit-spec-goldfish.out`, overwritten by each read. It is pasted whole into
   the conversation, and only the accepted gaps are kept, in `spec.md`.
2. `.shipkit/specs/<slug>/goldfish.md`, committed with the spec.
3. No file: the reply is pasted straight from the agent's result.

**Case for (1).** It reuses a pattern that has already fixed the summarizing problem once. It adds no
file to the spec folder, so `spec-check.sh` and the reviewer are unchanged, and a second read cannot
mistake the first read's report for part of the spec (REQ-2 also forbids it).

**Case against (1).** The full report is gone once the session ends, and only what the owner
accepted survives. (2) would let `/shipkit:escape` see what the goldfish said and what the main
session contested, not just what was accepted.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this, as (2), if a `/shipkit:escape` record names a goldfish
finding that was contested or fixed and the record says it could not tell which.
**Fired-if.** manual

---

## Decision: `lint.py` keeps its forked-skill check, with decision 0006 as the reason   (→ REQ-17)

**Context.** `scripts/lint.py:170-175` fails a forked skill whose body delegates to an agent, saying
"subagents cannot spawn subagents". On Claude Code 2.1.319 they can (decision 0006, Context). A
forked skill is a subagent, and 0006 keeps the rule that only the main session starts an agent.
`ship/SKILL.md:7-8` and `ROADMAP.md:780` give the same platform reason.

**Alternatives.**
1. Keep the check and change its comment and message to cite decision 0006.
2. Delete the check, since the platform no longer forbids nesting.

**Case for (1).** The rule the check enforces still holds, and only its reason changed.

**Case against (1).** The check matches one old agent name, `codebase-explorer`, which smoke check
`agents-four` already keeps out of every skill. It catches almost nothing, and keeping it keeps a
pattern few will recognise.

**Decision.** We chose (1), widened to match the start of any agent by name (`shipkit:` or a bare
agent name after "start", "launch", "delegate to"). The 2.1.319 probe goes in `ROADMAP.md` as a
note dated 2026-11-08 under item 2, replacing the old text. A history entry is corrected only where
it states a constraint as current.
**Falsifiability.** We would reverse this, deleting the check, if decision 0006 is superseded.
**Fired-if.** `grep -qi '^> Status:.*superseded' .shipkit/decisions/0006-main-session-starts-every-agent.md`

---

## Decision: The goldfish's eval fixture lives in `evals/goldfish/`, not `evals/lib/`   (→ REQ-18, REQ-19)

**Context.** The reviewer's cases share `evals/lib/review-fixture.sh`, which builds a `refunds` spec
and its code on the sample app. The goldfish needs a spec and a design without code or tasks, in
two variants. A folder with no `prompt.md` or `case.yaml` is not a case (`evals/README.md`), so a
script can sit in `evals/goldfish/` beside the case folders.

**Alternatives.**
1. `plugins/shipkit/evals/goldfish/spec-fixture.sh <clean|gap>`, called by each case's `fixture.sh`.
2. `plugins/shipkit/evals/lib/goldfish-fixture.sh`, beside the reviewer's.
3. Two more variants of `review-fixture.sh`.

**Case for (1).** It stays inside the accepted `Paths`, and the goldfish's fixture changes only with
the goldfish.

**Case against (1).** It breaks the convention that shared fixture scripts live in `lib/`. (3)
would reuse the `refunds` text, but it would tie two agents' evals to one script, so a change for
one could break the other.

**Decision.** We chose (1). The `gap` variant plants one term, "the grace window", in a requirement,
with no definition in the spec, the design or any file. The `clean` variant gives the same
requirement a stated number of days.
**Falsifiability.** We would reverse this, moving the script to `lib/`, if a third agent's eval
needs a spec fixture without code.
**Fired-if.** manual
