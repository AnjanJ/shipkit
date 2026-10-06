---
description: "Write an atomic git commit whose message scales to the change: a subject line for trivial ones, What/Why/How/Test plan for substantive ones. TRIGGER when: the user asks to commit, or a task or fix is done. DO NOT TRIGGER when: the user is mid-edit or says they will commit themselves."
user-invocable: true
argument-hint: "[optional: what to emphasize, or a message]"
---

<!-- Runs INLINE (no context: fork) on purpose: it inspects the working tree, stages
     specific files, and commits — and may need to ask the user (unrelated changes,
     destructive-looking diffs). Forked skills cannot interact with the user. -->

# /commit — Atomic Commit, Message Scaled to the Change

Produce one atomic commit whose message carries what a future reader (and the project elders)
will need. The always-on `shipkit` rule carries the short form — atomic commits, stage files by
name, never `--no-verify`, no co-author trailer — and points here for the rest. This skill is
the single source of truth for the message format; the CLAUDE.md written by `/shipkit:setup`
defers to it. Use the format for **every** substantive commit, not only when invoked by name.

## Commit discipline

**Atomicity (always).** One logical change per commit — one behavior, one fix, or one refactor.
Test and implementation land together. Never `git add .` / `git add -A`; stage the specific
files. Each commit leaves the build/tests green. Never `--no-verify`.

**Message depth scales to the change.** Do not force a template onto a one-liner.

- **Trivial** (version bump, typo, formatting, a one-line doc/config change): a good imperative
  subject line is enough. `chore: bump to 2.2.0`.

- **Substantive** (a feature, fix, refactor, integration, or anything with a decision behind
  it): subject line + a body with these sections. Include a section only when it has real
  content — omit it rather than pad.

  ```
  <type>: <imperative subject, <=72 chars, the WHAT in one line>

  What:  what changed, concretely (the surfaces touched).
  Why:   the problem or goal this serves — the reason it exists.
  How:   the approach, and the decisions made getting there.
         Name alternatives you rejected and why ("chose X over Y because…") —
         this is the highest-value line for a future reader.
  Test plan: how this was verified — commands run and what you observed,
         or why no test applies (docs/config/generated).

  Risk/Rollback: (only if it touches data, config, or prod behavior) what could
         break and how to undo it.
  Follow-ups: (only if the commit deliberately leaves gaps) what's left for later.
  Refs: (only if applicable) #issue / PR / link.
  ```

**Never** add a co-author/`Co-Authored-By` trailer unless the user explicitly asks. Never
amend, squash, or force-push published commits without asking. When on the default branch for
non-trivial work, branch first.

A decision worth revisiting later belongs in a decision record (`/shipkit:decide`), not only in
the commit's How line.

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

3. **Judge trivial vs substantive** (per "Commit discipline" above):
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
