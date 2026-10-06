---
description: "Trace a bug that reached users to the link that broke (no spec, missing or wrong requirement or test, outside the product), record it, reopen the spec with a failing-first task. TRIGGER when: the user reports a bug found in production. DO NOT TRIGGER when: a test fails during development."
user-invocable: true
argument-hint: "<what went wrong, in a sentence>"
---

<!-- Runs INLINE (no context: fork) on purpose: it asks the user what happened, and forked
     skills cannot ask. Code research goes to `grandfather` so the main context stays thin. -->

# /shipkit:escape — A Bug Got Out. Which Link Broke?

A bug reached users. Fixing it is half the job; the other half is knowing why nothing caught
it, and putting that right so the same kind of bug is caught next time. This skill names the
one link that broke, writes it down, and — where the spec was at fault — repairs the spec
first.

What happened: $ARGUMENTS

This skill does not fix the code. It leaves a task whose test fails first; the fix is that task.

## 1. Find out what happened

You need three facts: **what users saw**, **what should have happened**, and **how it was
noticed**. Take them from the request where it gives them. Ask only for what is missing — at
most **three** questions. If no user is present to answer, work from what you were given and
write "not known" for the rest.

## 2. Find the spec

Find the broken code (ask the **`grandfather`** agent if it is not obvious), then find the
spec under `.shipkit/specs/*/spec.md` whose `> Paths:` cover it. A spec with no `Paths` line
covers the feature its title names. Say which spec you found — or say plainly that there is
none.

## 3. Name exactly one cause

Pick **one** from this list — the first that is true, reading down — and say in one or two
sentences why it is that one and not the next:

| Cause | It is this when… |
|-------|------------------|
| `no spec` | no spec covers the broken code |
| `requirement missing` | a spec covers it, and no requirement says what should have happened |
| `requirement wrong` | a requirement covers the case and asks for the wrong behaviour |
| `requirement right, no test` | the requirement is right, and no test cites or exercises it (or it is marked `[untested]`) |
| `test existed but was wrong` | a test cites the requirement and passed anyway |
| `outside the product (dependency, infrastructure)` | the code did what the spec asks; a library, a service or the environment did not |

Write the cause exactly as it appears in the left column. One cause, not two: if two seem
true, the earlier one in the table is the cause and the other is a consequence.

## 4. Record it

Write `.shipkit/escapes/NNNN-<slug>.md`, numbered in sequence from `0001`:

```markdown
# Escape 0001: <short title>

> Recorded on 2026-10-06.

## What happened
<what users saw, what should have happened, how it was noticed>

## Cause
`requirement missing` — <why this one>

## Spec
`.shipkit/specs/<slug>/` — or "None"

## Fix
<the requirement added or corrected, and the task that carries the fix — or what else is to be done>
```

## 5. Repair the spec, when the spec was the broken link

- **`requirement missing`** — add the requirement to that spec's `spec.md` as the next
  `REQ-N`, in EARS form, saying what should have happened. Show it to the user in your reply.
- **`requirement wrong`** — correct the requirement in place, and note under it what it said
  before and the date. Show both versions in your reply.
- In both cases: set the spec's `> Status:` to `open`, and add a task to `tasks.md` in the
  3.3 format (`Files`, `Test`, `After`, `Done when`) that cites the new or corrected
  requirement. Its `Test` is a test that **fails now** and cites `<slug>/REQ-N`; the fix is
  done when it passes.
- **`requirement right, no test`** and **`test existed but was wrong`** — leave the
  requirement alone; set `Status: open` and add the task whose failing-first test proves it.
- **`no spec`** — do not invent a spec here. Recommend `/shipkit:spec` for the area and say so
  in the record.
- **`outside the product`** — change no spec. Record what failed and whether a guard on our
  side is worth a requirement; that is the user's call.

## 6. Report

In a few lines: the cause, the spec, the requirement added or corrected (quoted), the task
that now carries the fix, and where the record is.

## Guardrails

- Exactly one cause, written as in the table.
- Never mark an escape as `outside the product` to avoid saying a requirement was missing.
- Do not fix the code in this skill, and do not write the passing test — the task does that.
- An escape record is never deleted; a wrong diagnosis is corrected with a dated note.
