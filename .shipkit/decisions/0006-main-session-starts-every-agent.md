# 0006 — The main session starts every agent

> Status: **decided on 2026-11-08, on the owner's yes.**
> The rule: `plugins/shipkit/skills/spec/SKILL.md:132`, "No agent starts another agent: every agent
> is started by the main session." The probe ran in a scratch folder outside the repo, deleted
> after, on the owner's yes; its result is in Context.

## Context

The rule was written when the platform gave it no choice. `ROADMAP.md:685` lists, as a constraint
checked by a nonce test since 2.8, "a subagent cannot spawn subagents either"; the 1.3.0 fork audit
and 2.8.0 (`4703485`, `df8bdbc`, 2026-09-14) removed every fork-delegates-to-subagent instruction;
`scripts/lint.py:174` fails a forked skill that tries; `/shipkit:ship` runs inline for the same
reason (`plugins/shipkit/skills/ship/SKILL.md:7`). The sentence itself came in `7a2e1d6` (S3-T6,
`product-intake-brief` REQ-27), beside the rules for `brief.sh`. No record gave its reason.

That constraint no longer holds. The Claude Code sub-agents page, read on 2026-11-07
(https://code.claude.com/docs/en/sub-agents): "By default, a subagent can spawn subagents of its
own, up to three layers below the main conversation"; `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` sets
the depth. A nonce probe on Claude Code 2.1.319, 2026-11-08, `claude -p --model haiku`: an `outer`
agent with `tools: Agent` and nothing else started an `inner` agent with `tools: Read`, and returned
`10370ce8b2a39c24`, the contents of a file only `inner` could read. The main session's one tool call
was `Agent`. Two runs cost $0.009. (The first run also showed that `--disallowedTools` given to
`claude -p` applies to subagents: `inner` was refused as "spawned with zero tools".)
`AskUserQuestion` is still removed from every subagent, so interactive skills still run inline
whatever this record says.

The question now arrives from Google's Elephant-Goldfish Model (`google/elephant-goldfish-model`,
`docs/designs/review.md`), whose review synthesizer is an agent that starts reviewer agents in
parallel and merges their findings; its fallback, "direct dispatch", has the main session start
each reviewer.

## Alternatives

1. **Keep the rule: only the main session starts agents.**
2. Allow nesting for review fan-out: a synthesizer agent starts the reviewers and returns one
   merged report (EGM's pattern).
3. Allow nesting one level down for read-only research only (an elder starting `Explore`), and
   keep implementing and reviewing agents started by the main session.

## Case for (1)

Three reasons remain once the platform's no is gone.

- **The brief arrives word for word.** `brief.sh` assembles a task's brief with "no model, no
  paraphrase", and the agent gets it unchanged (`spec/SKILL.md`, "Handing a task to an agent").
  An agent between the main session and the implementer would brief it in its own words.
- **The checks stay with the session that owns them.** The main session runs `brief-verify.sh` and
  the task's `Done when` itself, because "the agent's report is a claim, not proof". Through a
  middle agent the session would be checking a claim about a claim.
- **A goldfish stays a goldfish.** The reviewer hears only the slug and the base ref
  (`ship/SKILL.md:128`), and its `disallowedTools: Edit, Write, Agent` holds that by tool, not by
  prose. A goldfish started by another agent gets a prompt that agent wrote, which is a path for
  the author's context to leak in.
- **Cost.** "Do not start agents 'in case'" (`spec/SKILL.md`). Under the superseded reviewer-model
  record, 21 of 55 reviews on Opus 5.5 cost more than $2, the highest $9.34; nesting multiplies
  agents where no one sees them start.

Nothing shipkit runs needs nesting: the ship gate starts one reviewer; the proposed spec goldfish
is one agent; EGM's own fallback is direct dispatch.

## Case against (1)

The main session pays for every agent's reply in its own context. The ship gate pastes the
reviewer's whole reply on purpose (`ship/SKILL.md`, step 4), so a review with several reviewers per
pass would grow the main session by each reply in full, where (2) would return one merged,
deduplicated report. (3) would let an elder hand its code reading to `Explore` and keep its own
context small; under (1) the elder reads directly. The rule also now rests on reasons a reader has
to take on trust, where before the platform enforced it: nothing stops an agent with `Agent` in its
tools from starting another, so each agent file has to leave `Agent` out.

## Decision

(1). The main session starts every agent. Each shipkit agent leaves `Agent` out of its tools or
lists it in `disallowedTools`. The stale platform claim in `ROADMAP.md:685`, `scripts/lint.py:174`
and `ship/SKILL.md:7-8` is corrected as a task of the spec that adds the spec goldfish, not here.

**Falsifiability.** We would reverse this, as (2), if a shipkit flow starts three or more reviewers
in one pass and pasting their whole replies, as the gate requires, pushes the main session into
compaction during an eval run.
**Fired-if.** manual
