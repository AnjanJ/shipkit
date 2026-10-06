# Spec: Trim and tell the story (Sprint 7, release 4.0.0 or 3.8.0)

> Spec accepted at commit `568338e` on sprint-7/trim-and-docs.
> Status: open
> Paths: docs/design/trim-audit-4.0.md, plugins/shipkit/rules/, plugins/shipkit/stacks/, plugins/shipkit/skills/, plugins/shipkit-workflows/skills/, plugins/shipkit/scripts/, scripts/lint.py, scripts/smoke.sh, README.md, GUIDE.md, ROADMAP.md, CHANGELOG.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Less to load, a clear pitch, and one worked example from idea to shipped. Nothing is cut
without the owner's yes on that row.

Source: `docs/plans/quality-gate-sprint-plan.md`, Sprint 7, tasks S7-T1 to S7-T5, and the
intake beside this file.

## User stories

- As the owner, I want one table that says what each rule, overlay and workflow skill costs
  and whether it earns its place, so that I decide the cuts, not the executor.
- As a new reader, I want the README to tell me in five lines what shipkit is and then show me
  the loop, one command per step, so that I know what to type without reading the history.
- As someone adopting the loop, I want one worked example with the real files it produces, so
  that I can compare my first run against a known good one.

## Requirements (EARS)

### The audit (S7-T1)

- **REQ-1.** `docs/design/trim-audit-4.0.md` shall hold one row for each of the six
  path-scoped rules, each of the sixteen stack overlay rules, each of the seven
  `shipkit-workflows` skills and knowledge bases, and `PROJECT_MAP.md` as the default, with the
  columns lines, bytes, verdict (`keep`, `trim`, `cut`) and reason. [untested: a table, verified
  by reading and counting]
- **REQ-2.** The audit shall give a rule line `keep` only on criterion (a) a project-specific
  value, (b) a specific trap that is not obvious, or (c) an eval that shows it changes the
  result, and shall mark (c) as not measured where no eval exists. [untested: judgement,
  verified by reading]
- **REQ-3.** The audit's `PROJECT_MAP.md` row shall cite decision 0001 and state whether its
  re-test condition has been met. [untested: documentation]

### The trims (S7-T2)

- **REQ-4.** Every stack overlay rule under `plugins/shipkit/stacks/*/.claude/rules/` shall be
  40 lines or fewer.
- **REQ-5.** Every skill description in both plugins shall be 300 characters or fewer.
- **REQ-6.** The lint shall fail when a stack rule exceeds 40 lines or a skill description
  exceeds 300 characters.
- **REQ-7.** The three always-on rules shall still total at most 3,000 bytes.
- **REQ-8.** Only `cut` rows the owner approved shall be removed; every removed item shall be
  listed in the changelog with what to use instead. [untested: documentation, verified by
  reading against the audit]
- **REQ-9.** No script under `plugins/shipkit/scripts/` shall call `mktemp` without a
  template, and the lint shall fail when one does.

### The README (S7-T3)

- **REQ-10.** `README.md` shall carry no "New in X.Y" or version-history text above its Install
  section.
- **REQ-11.** `README.md` shall show the loop — product, intake, spec, brief, build, review,
  ship, escape, digest — with one command per step.
- **REQ-12.** Every `/shipkit:` or `/shipkit-workflows:` command named in `README.md` shall be
  a skill that exists under `plugins/*/skills/`.
- **REQ-13.** `README.md` shall be 250 lines or fewer.
- **REQ-14.** `README.md` shall keep the paragraph that says what "verified" means and what
  shipkit only attributes. [untested: prose, verified by reading]

### The guide and the roadmap (S7-T4, S7-T5)

- **REQ-15.** `GUIDE.md` shall hold "Playbook 4 — one feature from idea to shipped", in which
  each of the nine steps of the loop appears with its command and the file it produced, using
  the refunds feature of the eval fixture and real output. [untested: documentation, verified
  by reading; the nine commands are counted]
- **REQ-16.** `ROADMAP.md` shall mark Sprints 1 to 7 as shipped with their versions, state the
  north star in one sentence, and list what is still open. [untested: documentation]
- **REQ-17.** The status line of `ROADMAP.md` shall name the released version.

## Release steps (not requirements)

- S7-T1 stops after the table: the owner decides every `cut` row before S7-T2 starts.
- The gate (`/shipkit:ship trim-and-docs`) answers `READY`; the report is committed.
- Release as 4.0.0 if any `cut` row was approved, else 3.8.0; the sprint exit checklist holds;
  the pull request is merged after a green check; tag.

## Out of scope

- Any cut not approved row by row (A8).
- New features, new skills, new agents.
- Acting on decision 0001 before its own re-test condition is met or the owner waives it.
