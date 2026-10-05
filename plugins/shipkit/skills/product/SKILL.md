---
description: "Write or update .shipkit/product.md: what the product is for, its users, up to three measurable goals this quarter, and what it deliberately does not do. TRIGGER when: the user wants to set or revisit product goals, non-goals or priorities. DO NOT TRIGGER when: specifying one feature (use /shipkit:spec)."
user-invocable: true
argument-hint: "[what changed, if you are updating]"
---

<!-- Runs INLINE (no context: fork) on purpose: it interviews the user, and forked skills
     cannot ask questions. It is short and run rarely, so the inline cost is small. -->

# /shipkit:product — Say What the Product Is For

Write `.shipkit/product.md`: one short file that says what this product is for, who uses it,
what it is trying to achieve this quarter, and what it deliberately does not do. It is the
intent the rest of shipkit checks work against — `/shipkit:intake` reads its goals and
non-goals before a spec is written. The file's exact shape is in @reference.md.

Notes from the user (optional): $ARGUMENTS

## Procedure

1. **Read what already exists, before asking anything.**
   - If `.shipkit/product.md` exists, read it. You are **updating** it: keep what is still
     true, change what the user says has changed, and set a new review date. Never start over
     and never drop a section the user did not ask to change.
   - Read `README.md`, `CLAUDE.md` and `PROJECT_MAP.md` if they exist. Fill in every section
     they already answer (the one line, the users, the stack and other constraints).

2. **Ask only for what is still empty.** At most **eight** questions in all, a few at a time,
   never one the files already answered. Usual gaps, in order of importance: the goals for
   this quarter, the non-goals, the metrics that matter, what is being worked on now.

3. **Hold the line on goals.**
   - **At most three.** If the user gives more, ask which three matter most this quarter and
     move the rest to `Next` or `Later` under "Now / Next / Later". Do not write a fourth goal.
   - **Each goal needs a metric, a target and a date.** If one is missing, ask for it, once.
     If it is still missing, write `metric: none set` (or `by: no date set`) in its place. A
     visible gap is better than an invented number: never make up a metric, target or date.

4. **Ask for non-goals if none were given.** "What will this product deliberately not do?" is
   the question people skip and the one `/shipkit:intake` needs most. One or two are enough.

5. **Write `.shipkit/product.md`** in the shape in @reference.md: the seven headings, in that
   order, every one present even if its body is "Not decided yet." Keep it to **60 lines or
   fewer** — it is read at the start of other work, so it must stay short. Set the review line
   to today's date.

6. **Report** in three or four lines: where the file is, the goals as written, and any gap
   left open (`metric: none set`). Do not paste the file back.

## Guardrails

- Never invent a goal, metric, date, user or non-goal. Ask, or leave the gap visible.
- Update, never restart: an existing file is the user's work.
- This file says *what the product is for*, not how it is built — no architecture here; that
  is `PROJECT_MAP.md` and the decision records.
- When no user is present to answer (a non-interactive run), use the answers given in the
  request, ask nothing, and mark what is missing as a gap.
