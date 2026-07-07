---
description: "Capture a project decision as a durable, five-part record with a falsifiability clause, appended to .shipkit/decisions/. TRIGGER when: a non-trivial choice is made with ≥2 real alternatives (a tech pick, an architectural fork, a build-vs-buy) and it's worth a future reader revisiting. DO NOT TRIGGER when: the choice is a default with no real alternative, it's trivial/one-liner, or the decision is feature-scoped and already belongs inline in a spec's design.md (use /shipkit:spec)."
user-invocable: true
argument-hint: "<decision in a phrase, e.g. 'Paddle over Stripe'>"
---

<!-- Runs INLINE (no context: fork) on purpose: the five-part interview needs AskUserQuestion
     to draw out alternatives, the case-against, and a concrete falsifiability clause, which
     forked skills cannot use. It's a short, one-shot interview — inline cost is negligible. -->

# /shipkit:decide — Capture a Decision Record

Turn a real project decision into a durable, queryable record: the **five parts** — Context,
Alternatives, Case for, Case against, Decision + **falsifiability clause** — appended to
`.shipkit/decisions/NNNN-<slug>.md`. This is the "why" the elders read, the counterpart to the
map's "what/where".

Governed by `rules/decisions.md` (the format and the concrete-falsifiability requirement). This
skill runs the interview that produces one record.

**Capture real decisions only.** A record needs a genuine fork — **≥2 real alternatives**. A
forced default is not a decision; note it in a commit and move on. If the decision is scoped to a
feature you're specing, it belongs **inline in that spec's `design.md`** (via `/shipkit:spec`),
not as a standalone record. Use this skill for **project-wide** decisions (a tech choice, an
architectural stance) that aren't tied to one feature.

## The interview

Draw out each part; don't accept thin answers. See @../spec/reference.md for the decision-record
template and `rules/decisions.md` for the ✅/❌ falsifiability examples.

1. **Context** — what situation forced this? What constraints were in play? (Ask until you have
   the real pressure behind the decision, not just "we needed a database.")
2. **Alternatives** — the options actually considered (**≥2 real ones**). If the user names only
   the chosen path, ask what else was on the table — a record with one option isn't a decision.
3. **Case for** — the argument for the chosen option.
4. **Case against** — the honest costs and risks of the *chosen* option. Push here: this is the
   part people skip, and it's what makes the record trustworthy. "What do we give up?"
5. **Decision + falsifiability clause** — the choice, plus a **concrete, checkable** reversal
   condition (a metric, event, or threshold). If the user offers a vague hedge ("if it doesn't
   work out"), ask for the observable signal that would actually make them reconsider. If there
   genuinely isn't one, record "no clear reversal condition identified" — don't fake it.

## Writing the record

1. Find the next number: the highest `NNNN` in `.shipkit/decisions/` + 1 (start at `0001`).
   Create `.shipkit/decisions/` if it doesn't exist.
2. Write `.shipkit/decisions/NNNN-<slug>.md` using the template in @../spec/reference.md, with a
   short kebab-case slug from the decision (e.g. `0007-paddle-over-stripe.md`).
3. If this **supersedes** an earlier record, mark the old one superseded (don't delete it) and
   point it at the new one.
4. Tell the user the record's path and one-line summary. `grandfather` can now answer *why* this
   was chosen — and *"is this decision now falsified?"* by checking the clause against reality.

## Relationship to other skills

- **`/shipkit:spec`** writes feature-scoped decisions inline in `design.md`. This skill is for
  standalone, project-wide ones. Same five-part format; different home.
- The **`decisions` rule** already prompts you to capture records during normal work — this skill
  is the explicit, guided version for when you want to sit down and record one deliberately.
