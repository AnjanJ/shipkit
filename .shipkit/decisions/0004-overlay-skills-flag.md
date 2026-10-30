# 0004 — The overlay skills install on a flag, and two Rails skills the loop says are gone

> Status: **decided on 2026-10-30 — amends 0003 (thinning plan W6 and W8, Sprint 21, S21-T1 and S21-T3).**
> Spec: `.shipkit/specs/overlays-and-eve/`; plan: `docs/plans/thinning-sprint-plan.md`, W6, W8;
> the side-by-side: `docs/design/trim-audit-overlays.md`, "The eleven overlay skills against the loop".

## Context

0003 (2026-10-07) kept the eleven overlay skills in core because core installs them and they
cost no plugin context. True — and silent about the project's context: `install-stack.sh`
copied every one into `<project>/.claude/skills/`, so a Rails project carried six listings in
every session (17,529 bytes on disk) whether or not anyone wanted them. The loop the skills
predate (`intake`, `spec`, `ship`, the `reviewer`, the Care line, the path-scoped rules) now
says some of what they say.

## Alternatives

1. **In core, installed on `--with-skills`; the two that duplicate the loop cut.** The flag
   before the installer's positional arguments; setup asks once and names the count; a
   non-interactive run installs none. `deploy-check` (the gate's steps 2 and 5, `gemfile.md`'s
   line, the deploy pipeline; its two unique lines move into `release`) and `safety-check`
   (every checklist line a rule loaded on the matching edit, or a lens `/code-review` reads)
   go; nine stay behind the flag.
2. In core, installed by default, all eleven (0003 as decided).
3. In `shipkit-workflows` (0003's rejected option: they are project-specific and installed,
   not loaded from the plugin).

## Case for (1)

The user's skill list carries what they asked for; the Rails user who wants `release` and
`new-feature` says yes once. A skill that repeats a rule or the gate is two voices on one
question, and behind the flag still a listing for nothing new. The side-by-side in the audit
makes the duplication readable, not asserted.

## Case against (1)

One more question in setup; a non-interactive setup takes the default and must say so (the
4.12 run's shape). "Duplicates the loop" is a reading: a Rails user who never runs the loop had
`safety-check` as a one-command review of a diff; `/code-review` with the Rails lens is now
that. `review-and-ship` REQ-19 named `deploy-check` and is amended in place.

## Decision

(1). 0003's "the overlay skills stay in core" stands; its "installed by default" does not;
`deploy-check` and `safety-check` are cut on the owner's yes of 2026-10-30.

**Falsifiability.** We would reverse the flag — skills by default again — if two of the next
three real runs' notes show the user asking for the skills after setup declined them. We would
reverse a cut — restoring that skill behind the flag — if a user asks for it by name in an
issue or a real run's notes within two releases.
**Fired-if.** manual
