---
description: "Write an atomic git commit with a message that scales to the change — a good subject for trivial commits, and What/Why/How-decisions/Test plan for substantive ones. TRIGGER when: the user asks to commit, or work reaches a natural commit point (a task done, a fix verified). DO NOT TRIGGER when: the user is mid-edit, or explicitly says they'll commit themselves."
user-invocable: true
argument-hint: "[optional: what to emphasize, or a message]"
---

<!-- Runs INLINE (no context: fork) on purpose: it inspects the working tree, stages
     specific files, and commits — and may need to ask the user (unrelated changes,
     destructive-looking diffs). Forked skills cannot interact with the user. -->

# /commit — Atomic Commit, Message Scaled to the Change

Produce one atomic commit whose message carries what a future reader (and the project elders)
will need. The rules for atomicity and message depth live in the **Commit Discipline** section
of the shipkit workflow rule — this skill applies them. Read that rule; do not restate it here.

Emphasis from the user (optional): $ARGUMENTS

## Procedure

1. **See what's there.** `git status` and `git diff` (and `git diff --staged`). Understand the
   actual change before writing a word about it.

2. **Check atomicity.** Is this one logical change, or several tangled together?
   - One logical change → stage its specific files (never `git add .`/`-A`) and continue.
   - Several unrelated changes → do NOT bundle them. Stage and commit the coherent subset,
     then repeat for the next. If the split isn't obvious, ask the user how to group them.
   - Something you didn't expect in the tree (unrelated edits, a stray file, anything that
     looks like a secret or a destructive deletion) → stop and ask before committing it.

3. **Judge trivial vs substantive** (per the rule):
   - Trivial (version bump, typo, formatting, one-line doc/config) → a clear imperative
     subject line is the whole message. Don't manufacture a body.
   - Substantive (feature, fix, refactor, integration, a decision behind it) → write the body
     with **What / Why / How-and-decisions / Test plan**, plus **Risk/Rollback**,
     **Follow-ups**, **Refs** only where each has real content.

4. **Fill the Test plan honestly.** State the command you actually ran and what you observed
   ("`npm test` → 24 pass"), or that it's docs/config with no test surface. Do not claim a
   verification you didn't perform. If tests should exist and don't, say so in Follow-ups.

5. **Commit.** Imperative subject ≤72 chars, prefixed by type (`feat`/`fix`/`refactor`/
   `docs`/`chore`/`test`/`perf`). No `Co-Authored-By` trailer unless the user asked for one.
   Never `--no-verify`. If on the default branch for non-trivial work, branch first.

6. **Report** the one-line result (branch + short SHA + subject). Don't paste the whole diff.

## Guardrails
- **Atomic or ask.** Tangled changes get split or questioned, never silently bundled.
- **Stage specifically.** The files this change touched — not the whole tree.
- **Honest test plan.** A real command and its result, or an honest "no test surface."
- **Never** amend/squash/force-push published commits, or add a co-author trailer, without
  the user asking.
