---
description: "Check a request before it becomes a spec: conflicts with the product's non-goals, open specs and past decisions, then at most four questions whose answers change what gets built. TRIGGER when: a non-trivial feature request arrives and no spec exists yet. DO NOT TRIGGER when: the change is trivial."
user-invocable: true
argument-hint: "<the request, in the user's words>"
---

<!-- Runs INLINE (no context: fork) on purpose: it asks the user questions, and forked skills
     cannot. Code research is delegated to `grandfather` so the main context stays thin. -->

# /shipkit:intake — Ask Before Building

The colleague who says "wait — didn't we decide not to do that?" before the work starts. Check
one request against what the project already knows, say plainly what conflicts, ask the few
questions that would change what gets built, and write the answers down for the spec.

The request: $ARGUMENTS

Do the steps in order. Do not write code, and do not start the spec, in this skill.

## 1. Is it trivial?

A rename, a typo, a config value, a one-line change, or the user said "just do it": say
**"Trivial — no intake needed."** in one line and stop. Write no file and ask no question.
(Whoever called you then simply does the change.)

## 2. Read what the project already knows

- `.shipkit/product.md` — the goals this quarter and the **non-goals**. If it does not exist,
  say so in one line and carry on; suggest `/shipkit:product` at the end.
- The specs under `.shipkit/specs/*/spec.md` whose status is open (no `> Status:` line, or
  `Status: open`) — their titles and purposes.
- The titles of the records in `.shipkit/decisions/` and of the `## Decision:` blocks in open
  specs' `design.md`.
- For "how does the code do X today?", ask the **`grandfather`** agent. Do not read the
  codebase yourself in this skill.

## 3. Say what conflicts — before any question

Look for three kinds of conflict. State each one you find plainly, naming the file and the
line it comes from, **before** asking anything:

- **Non-goal** — the request does something `product.md` lists under "Non-goals".
  Say: "This conflicts with the non-goal '<text>' in `.shipkit/product.md`."
- **Open spec** — an open spec already covers it, wholly or in part. Name the spec.
- **Decision** — it contradicts a decision record. Name the record and its reversal condition.

When you say that something does **not** exist in the project — no source for a value, no
earlier decision, no doc — name the places you searched for it, in the same sentence. A claim
of absence with no search behind it was wrong once already ("queue status has no source": it did).

A conflict does not end the intake: the user may have changed their mind. Ask whether to go
ahead anyway (that is one of your four questions). If they do, the non-goal or the decision
is what must change first — say so. If there is no conflict, say "No conflicts found" in one line.

## 4. Ask at most four questions

List what is still unknown. Keep only the unknowns whose answer would **change what gets
built** — drop anything a file already answers and anything you could decide with a sensible
default (write those down as assumptions instead). Then ask **at most four** questions, the
most important first, numbered. Four is a ceiling, not a target: two good questions beat four.

One of the four is which quarterly goal this serves — unless `product.md` makes it obvious, in
which case state it ("this serves the goal 'Ship refunds'") and do not ask. "None" is an
allowed answer.

If no user is present to answer (a non-interactive run): state the conflicts and the questions
in the reply, then **write `intake.md` anyway** (step 5) with each question under "## Answers"
followed by `— *unanswered*`. Do not answer your own questions. The file is where the next
session looks; a reply is gone with the session that wrote it.

If `intake.md` already exists with unanswered questions: fill in the answers the request gives,
keep the rest marked unanswered, and ask only those — never a question the file or the request
already answers.

## 5. Write `.shipkit/specs/<slug>/intake.md`

`<slug>` is a short kebab-case name for the feature. Once the questions are answered — or, when
nobody could answer, with them marked unanswered — write:

```markdown
# Intake: <feature>

> Intake taken on 2026-10-05.

## Request
<the request, in the user's words>

## Serves goal
<the goal from product.md, word for word — or "None">

## Conflicts found
<each conflict and what the user decided about it — or "None">

## Answers
<each question and its answer — or the question followed by "— *unanswered*">

## Assumptions made
<what you decided without asking, so the user can object>

## Out of scope
<what this request will not include>
```

Then tell the user the intake is written and that `/shipkit:spec <slug>` is the next step.

## Guardrails

- Conflicts first, questions second. Never bury a conflict under a question.
- Never more than four questions, and never one a file already answers.
- Never invent an answer. An unanswered question is written as unanswered.
- "Serves goal: None" is information, not a failure — it is written down as it is.
