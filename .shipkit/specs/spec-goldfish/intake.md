# Intake: Spec goldfish — a zero-context read of a spec before its tasks are written

> Intake taken on 2026-11-08.

## Request
Spec goldfish: a zero-context check of a spec before tasks.md, borrowed from Google's
Elephant-Goldfish Model (`google/elephant-goldfish-model`, `docs/designs/review.md`). A new
read-only agent gets only the spec slug, reads `spec.md`, `design.md` and the repo files they link,
and for each REQ-N either sketches the one-line test it would write or says UNCLEAR and what is
missing; it lists undefined terms and assumptions, and ends `VERDICT: SELF-CONTAINED` or `GAPS`.
`/shipkit:spec` starts it from the main session just before the Plan Mode gate. The main session
triages each finding: fix; contest only by citing a file and line the goldfish could read; or
escalate to the owner, and the fix for an escalated gap is to put the missing knowledge in the
spec, because the implementer (handed `brief.sh` output) is a goldfish too. One pass, a second only
if something was fixed, never more than two. Eval: a spec with a planted undefined term must come
back `GAPS`; a clean spec `SELF-CONTAINED`. Also a task: correct the stale "subagents cannot spawn
subagents" claim at `ROADMAP.md:685`, `scripts/lint.py:174` and
`plugins/shipkit/skills/ship/SKILL.md:7-8`. To be specced after fifth-run ships, not in Sprint 28.

## Serves goal
None. There is no `.shipkit/product.md`; `/shipkit:product` would set goals.

## Conflicts found
None. Searched: the open specs `fifth-run`, `gate-on-setup` and `users-machine` (spec titles,
purposes and every `## Decision:` title); records 0001–0006 in `.shipkit/decisions/`; `ROADMAP.md`
for goldfish, spec review, Plan Mode and nesting. None covers a review of a spec before its tasks.

One tension, settled in answer 1: `docs/design/context-cost.md:20` sets the agent descriptions every
session loads at ≤ 1,000 bytes; `scripts/context-cost.sh` reads 991 on 2026-11-08 (4 agents).

## Answers
1. **What form does the goldfish take: a new agent, a mode of `reviewer`, or the built-in `Explore`
   given a goldfish prompt?** A new agent. Its file fixes its instructions, its model and its tools,
   which no prompt overrides. `Explore`'s own prompt reads excerpts, the wrong habit for a reader
   that must take in the whole spec, and shipkit does not control its model; a `reviewer` mode
   mixes two verdict vocabularies and puts the mode in a prompt. The agent is only started by name
   from `/shipkit:spec`, so its description is one line (≈ 80 bytes, e.g. "Reads a spec cold,
   before its tasks are written. Started by /shipkit:spec only."), and the agents ceiling in
   `context-cost.md` rises from 1,000 to 1,075 (≈ 1,071 after).
2. **Does `GAPS` block the spec?** No, it is advisory, with two conditions. Before Plan Mode is
   shown, every finding has a disposition: fixed, contested with a file and line the goldfish could
   read, or escalated to the owner. A gap the owner accepts is written into the spec (e.g.
   "Goldfish: GAPS accepted by owner — REQ-4's 'stale'"), so `/shipkit:escape` can trace a bug to it.
   The record carries the clause: make it blocking if, in 2 of 5 specs approved with open gaps, the
   ship reviewer later answers CANNOT TELL or NOT MET on the same requirement.
3. **Every spec, or opt-in?** Every spec, at the design gate, skipped only on the owner's word
   ("no goldfish"). Not re-run when a spec is amended. Reason: `7a2e1d6` — scripts "are only used if
   every session knows they exist" — and `/shipkit:spec` already runs only for non-trivial work.

## Assumptions made
- The model is `sonnet`, as `reviewer` (`plugins/shipkit/agents/reviewer.md:4`).
- `tools: Read, Glob, Grep, Bash`; `disallowedTools: Edit, Write, Agent` — as `reviewer.md:5-6`,
  and as decision 0006 requires of every shipkit agent.
- The main session starts it with the slug and nothing else, as the ship gate starts the reviewer
  (`plugins/shipkit/skills/ship/SKILL.md:128`).
- It runs in `/shipkit:spec`'s Q2, before the Plan Mode gate (`plugins/shipkit/skills/spec/SKILL.md:73`),
  so the owner sees the design and the goldfish report together.
- One pass; a second only if a finding was fixed; never more than two.
- A comprehension gap cannot be contested away: if only knowledge outside the files answers it,
  that knowledge goes into the spec.
- The reply is written to a file and pasted whole, as the gate does with the reviewer's reply
  (`ship/SKILL.md`, step 4).
- Evals: a spec with a planted undefined term comes back `GAPS` and names it; a clean spec comes
  back `SELF-CONTAINED`. The run's cost per goldfish is measured there, not assumed.
- A task corrects the stale platform claim at `ROADMAP.md:685`, `scripts/lint.py:174` and
  `ship/SKILL.md:7-8`. Nesting was confirmed on Claude Code 2.1.319 by a nonce probe on 2026-11-08;
  decision 0006 (`.shipkit/decisions/0006-main-session-starts-every-agent.md`) keeps the rule
  that the main session starts every agent.

## Out of scope
- EGM's five stages, its personas (zoom-out, critic, style, implementation readiness) and its
  synthesizer agent.
- Nesting: no agent starts another (decision 0006).
- Re-running the goldfish on spec amendments.
- Any change in Sprint 28: the spec is written after fifth-run ships.
