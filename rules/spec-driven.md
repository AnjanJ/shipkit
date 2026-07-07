# Spec-Driven Development

Applies to **non-trivial** work — new features, refactors, integrations, architectural changes.
Trivial work (typo, rename, config, one-liner, or "just do it") is exempt: **never spec a typo.**
This rides the same trivial-vs-non-trivial split as the default workflow in `shipkit.md`.

## The three questions

Before building something non-trivial, answer three questions — in order:

1. **What are we building?** — requirements. Write them in **EARS** (below). This is `spec.md`.
2. **How should it work?** — the approach, written as **decision records** (see `decisions.md`),
   not loose prose. This is `design.md`.
3. **How will we know it's done?** — acceptance criteria expressed as **tests**. Each requirement
   becomes a behavior-focused (BDD/TDD) test, written *before* the implementation, per `shipkit.md`.
   The definition of done is a failing test, not a checkbox.

For a small-but-non-trivial change these can be a few lines each — scale the spec to the work. A
full spec folder is for features and multi-file changes, not every branch.

## Where specs live

Under the shipkit artifact root, one folder per feature:

```
.shipkit/specs/<feature-slug>/
  spec.md      # Q1 — requirements (EARS)
  design.md    # Q2 — approach, as decision records
  tasks.md     # ordered tasks, each citing the requirement it satisfies (→ REQ-N)
```

Specs branch and PR with the code they describe. Stamp an accepted spec with its commit
(`> Spec accepted at commit <sha> on <branch>`) so drift from the code is detectable later.

## EARS — requirements format (default, escapable)

Write each requirement as one testable `shall` statement using one of these patterns:

- **Ubiquitous** — `The <system> shall <response>.`
- **State-driven** — `While <precondition>, the <system> shall <response>.`
- **Event-driven** — `When <trigger>, the <system> shall <response>.`
- **Optional** — `Where <feature is present>, the <system> shall <response>.`
- **Unwanted** — `If <trigger>, then the <system> shall <response>.`

One behavior per requirement — if you need "and", split it. Number them (`REQ-1`, `REQ-2`) so tasks
and tests can cite them.

**Escapable:** where EARS is forced or awkward, drop to a user story + explicit acceptance bullets,
and say why. Opinionated, not dogmatic — the goal is testable requirements, not EARS for its own sake.

## Traceability

Requirement → task → code → test. Each task in `tasks.md` cites the requirement it satisfies; each
requirement ends up covered by a test. If a requirement has no task and no test, it isn't done.

## Scope discipline

- Spec **non-trivial** work only. Say so when you skip a spec for small work — don't skip silently.
- Greenfield features and complex changes in large codebases are the sweet spot. In brownfield,
  lock what exists and spec only the delta.
- Don't let design decisions leak into `spec.md` (the *what*), and don't restate requirements in
  `design.md` (the *how*). Keep the three questions in their own files.
