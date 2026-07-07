# Decision Records

When a **non-trivial choice** is made with **≥2 real alternatives**, capture it as a decision
record. Skip defaults and one-liners — a record needs a genuine fork in the road. Naming the
alternatives is what proves you *decided* rather than *defaulted*.

## The five parts — in order

1. **Context** — what situation forced the decision? What constraints were in play? (Without this,
   no one can later judge whether the choice was reasonable *for the situation you were in*.)
2. **Alternatives** — the options actually considered (**≥2 real ones**, not strawmen).
3. **Case for** — the argument for the chosen option.
4. **Case against** — the honest argument *against your own choice*: the costs, the risks, what
   you're giving up. Do not skip this. Writing the case against your own decision is what makes the
   record trustworthy.
5. **Decision + falsifiability clause** — the choice itself, plus one sentence:
   **"I would reverse this if ___."**

## The falsifiability clause must be concrete — this is enforced

The clause is the point of the whole record: it makes a decision *checkable for staleness later*.
It **must** be a concrete, observable condition — a metric, an event, or a threshold:

- ✅ "…if p99 latency exceeds 200ms." / "…if we exceed 3 external API consumers." / "…if the team
  grows past 8 engineers."
- ❌ "…if it turns out to be wrong." / "…if it doesn't work out." / "…if requirements change."

A vague hedge is not a falsifiability clause — rewrite it or the record is incomplete. If you
genuinely cannot state a reversing condition, say so explicitly ("no clear reversal condition
identified") rather than faking one.

## Where records live

- **Feature-scoped** decisions → inline in that spec's `.shipkit/specs/<feature>/design.md`.
  A spec's design *is* a set of decision records (see `spec-driven.md`).
- **Project-wide** decisions (not tied to one feature — e.g. "Paddle over Stripe", "monolith over
  microservices") → standalone `.shipkit/decisions/NNNN-<slug>.md`, numbered sequentially. This is
  the canonical durable log the elders read.

The decision log is the map's counterpart: `PROJECT_MAP.md` records *what/where*; the decision log
records *why*. A record that is superseded is marked (not deleted) and points to the record that
replaced it.

## Relationship to commits

The commit rule in `shipkit.md` already asks you to name rejected alternatives in a substantive
commit message. A decision record is that instinct promoted to a durable, queryable artifact — use
a record (not just a commit line) when the decision is one a future reader will need to revisit.
