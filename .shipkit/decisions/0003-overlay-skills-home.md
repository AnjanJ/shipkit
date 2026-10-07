# 0003 — The stack overlay skills stay in core

> Status: **decided on 2026-10-07 — the overlay skills stay in core (shipkit 4.3.0, Sprint 10, S10-T2).**
> Spec: `.shipkit/specs/real-run/`; plan: `docs/plans/evidence-sprint-plan.md`, B9 and S10-T2.
> Settles item 6 of `docs/design/two-plugin-split.md` §5, open since 3.0 (2026-09-14).

## Context

Shipkit 3.0 split one plugin into two by one rule: **core produces, reads or installs knowledge;
`shipkit-workflows` tells Claude how to do the work.** Every skill was sorted by that rule
except the ones inside the stack overlays, which 3.0 deferred ("core (recommended) or a
`workflow-skills/` subfolder installed only when workflows is present").

What the overlays ship today, at 4.2.0 — eleven `SKILL.md` files, 31,493 bytes in all,
under `plugins/shipkit/stacks/*/.claude/skills/`:

| Overlay | Skill | Invocable | What it does | Knowledge, or how-to-work? |
|---|---|---|---|---|
| rails | `ai-rails` | no (KB) | RubyLLM patterns: chat, embeddings, tools, streaming | knowledge |
| rails | `code-review-standards-rails` | no (KB) | Rails lenses for ActiveRecord, Sidekiq, Hotwire | knowledge |
| rails | `/new-feature` | yes | YAGNI/SRP gate, detects CQRS / service objects / MVC, scaffolds class + spec | how-to-work, on project knowledge |
| rails | `/release` | yes | two-phase release with an approval gate; defers to `/shipkit:ship` | how-to-work |
| rails | `/deploy-check` | yes | migrations, brakeman, bundle-audit, tests, env; defers to `/shipkit:ship` | how-to-work |
| rails | `/safety-check` | yes | audits a diff against a Rails checklist (N+1, SQL injection, strong params …) | knowledge, delivered as a how-to |
| go | `/new-feature` | yes | YAGNI/SRP gate, detects layout and framework, scaffolds package + test | how-to-work, on project knowledge |
| python | `/new-feature` | yes | same, detects Django / FastAPI / plain | how-to-work, on project knowledge |
| elixir | `/new-feature` | yes | scaffolds context, schema or LiveView + test | how-to-work, on project knowledge |
| react | `/component` | yes | detects TS, Storybook, CSS approach, test runner; scaffolds component + test + story | how-to-work, on project knowledge |
| static | `/audit` | yes | SEO, a11y, performance and link checklists | knowledge, delivered as a how-to |

Read by their text alone, two are pure knowledge bases, two are checklists, and seven tell
Claude how to do a task. That is why the question stayed open: the rule sorts the *text* to
workflows.

Three facts about how they are *delivered* were not in the 3.0 table:

1. **They are installed into the project, not loaded from the plugin.** `install-stack.sh`
   copies each one to `<project>/.claude/skills/<name>/` with the overlay's placeholders
   substituted. They cost no plugin context in any session, and a project that never runs
   `/shipkit:setup` never sees them. Core's own job is installing them.
2. **None of the eleven refers to `shipkit-workflows`.** Two refer to core (`/release` and
   `/deploy-check` say "if this feature has a spec, run `/shipkit:ship <slug>` first"). The
   knowledge base `code-review-standards-rails` is the stack-specific half of the generic
   `code-review-standards` that *did* move to workflows — but its consumer is Claude Code's
   built-in `/code-review`, not `/qa` or `/tdd`.
3. **The user cannot install half an overlay.** `setup` runs `install-stack.sh` once per
   overlay; a split home means setup installing one overlay from two plugin roots, one of
   which may be absent.

Also recorded here: the plan's S10-T2 text says "Rails ships five"; Rails ships **six** (four
invocable skills and two knowledge bases). The eleven total is right.

## Alternatives

1. **Stay in core** (B9's default). Nothing moves; §5 item 6 is marked settled.
2. **Move the invocable ones to `shipkit-workflows`** as `stacks/*/.claude/skills/` there, with
   `setup` installing them only when workflows is installed. A breaking change for anyone who
   installs core alone and expects `/new-feature` after setup: 4.3.0 becomes 5.0.0.
3. **A `workflow-skills/` subfolder inside each core overlay**, installed only when
   `shipkit-workflows` is detected (3.0's "follow-up option"). Not breaking for users who have
   both plugins; breaking for core-only users all the same.

## Case for (1)

- The dividing rule's third verb is **installs**. These files are knowledge *artifacts* that
  core writes into the project, next to the rules and the CLAUDE.md sections, by the same
  script, recorded in the same manifest, removed by the same `/shipkit:unsetup`. The rule
  sorts the installer, and the installer is core.
- They cost nothing where the split was meant to save: the per-session context tax. Moving
  them saves no bytes in any session.
- Seven of eleven need the project's own facts (its architecture pattern, its test runner, its
  CSS approach) and would be wrong as generic workflows; the four that do not are checklists
  and knowledge bases, which the rule already puts in core.
- Options 2 and 3 both make `setup` conditional on a second plugin being present and both
  break the core-only install. A major version for a file move nobody has asked for.
- Measured demand is zero: no issue, no field note and no eval has pointed at an overlay skill
  since 3.0.

## Case against (1)

- Read as text, `/release`, `/deploy-check` and the scaffolds are exactly what
  `shipkit-workflows` is for; a reader of §1's table will keep asking the question this record
  closes, so the design doc must say *why* in one line, not just "settled".
- Core's pitch ("the project knowledge layer") now has to carry "and it installs a Rails
  release workflow into your project". That is a small untidiness in the one-sentence pitch.
- `code-review-standards-rails` and `code-review-standards` are a split pair: the generic half
  is in workflows, the Rails half in core. Anyone extending the review lenses edits two plugins.
- The real run (B10, S10-T3) has not happened yet; this decision is taken before the first
  non-shipkit project has used an overlay skill in anger. It is reversible, and the clause
  below says when.

## Decision

**The overlay skills stay in core (option 1)**, B9's default, approved by the owner on
2026-10-07. `docs/design/two-plugin-split.md` §5 item 6 reads "settled, see 0003"; the ROADMAP's
"From 3.0" line goes.

**Falsifiability.** We would reverse this if two or more overlay skills come to call a
`/shipkit-workflows:*` skill by name (today: zero), or if two independent core-only users report
that `/shipkit:setup` installed workflow skills they did not want. The first count is the
command below; the second is the issue tracker.
**Fired-if.** `test "$(grep -rl 'shipkit-workflows:' plugins/shipkit/stacks/*/.claude/skills/ 2>/dev/null | wc -l)" -ge 2`
