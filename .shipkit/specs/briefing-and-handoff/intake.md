# Intake: Briefing and handoff

> Intake taken on 2026-10-06.

## Request
Sprint 5 of the quality-gate plan: a session starts by knowing where things stand (a short
briefing from the session hook) and ends by leaving a note (`/shipkit:handoff` writing
`.shipkit/state.md`), with a reminder around context compaction if the platform allows it.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; there is no product file.
- **Open specs:** none. All six specs are shipped.
- **Decision records:** none contradicts it. The plan's always-on budget table allows the
  briefing 800 bytes on top of the 3,000-byte rules; the rules stand at 2,996.
- **The plan against the platform (S5-T4):** the hooks documentation has a `PreCompact`
  event, but its stdout and `systemMessage` do not reach the model — stderr is shown to the
  user on a manual `/compact`, and exit 2 blocks compaction. So "remind the model before
  compaction" cannot be built as written. What the platform does offer: `SessionStart` fires
  again **after** compaction with `source: "compact"`, and that hook's output does reach the
  model. The intake proposes using that instead (see Assumptions).

## Answers
No question was asked: the plan fixes the briefing's lines, the handoff's headings, and the
`state.md` decision (A5), and the one open point above is a platform fact, not a preference.

## Assumptions made
- S5-T4 is built on `SessionStart` with `source: "compact"` rather than `PreCompact`: the
  hook prints one line after compaction — "shipkit: context was just compacted — run
  /shipkit:handoff if work is in flight" — which the model sees. The plan's task is otherwise
  skipped as it says, and the changelog records why.
- `briefing.sh` reads the handoff's "Next step" line only; it never reads the rest of
  `state.md` into the session.
- The handoff eval or smoke check runs the skill headless with the session's facts given in
  the prompt, as the product and spec checks do.
- Adding a skill changes the marketplace count in the task that adds it (lint).

## Out of scope
- Persisting conversation history. The handoff is a note the next session reads, not a
  transcript.
- Any agent started at session start. The briefing is lines of text.
