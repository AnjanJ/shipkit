# 0007 — A change does not judge itself

> Status: **decided on 2026-11-17, on the owner's yes** (the verifier plan's rule 28 and its V9),
> written out on 2026-11-18 with Sprint 30 (`.shipkit/specs/gate-as-software/`, REQ-37).
> The tools: `scripts/judge.sh` runs this repository's ship gate with the plugin from a worktree
> of the last tag; CI runs the last tag's `spec-check.sh` beside the branch's own.

## Context

A branch that changes `plugins/shipkit/skills/ship/SKILL.md`, `plugins/shipkit/agents/reviewer.md`
or `plugins/shipkit/scripts/spec-check.sh` has been gated by its own copies of them. The 5.1.0 and
5.2.0 release gates ran with `--plugin-dir` at the checkout (`docs/design/eval-history.md`,
"Release run 5.1.0" and "Release run 5.2.0"), and CI ran the branch's `spec-check.sh` on the
branch. A branch that weakened the gate would have been judged by the weakened gate, and nothing
would have said so.

This applies to shipkit's own repository, which is the one project whose changes can edit the
judge. In a user's project the plugin is installed from a release and the project's branches
cannot edit it.

## Alternatives

1. **The last tagged release judges:** its skill, its reviewer and its scripts, loaded from a
   worktree of the tag. The checkout's own gate runs as well, as a test of the new gate, and both
   results are recorded.
2. The checkout judges itself, as before.
3. The tip of `main` judges.

## Case for (1)

A branch cannot edit a tag, and a tag is what users run. The judge is then fixed before the
branch starts, and the only way to change it is a release, which has its own gate.

## Case against (1)

The tag does not know what has been added since. A line it cannot read may fail a good spec, and
a check that is new on the branch is not applied by the judge at all; only the checkout's own
run, kept as a test, applies it. Every release gate also needs a worktree of the tag. (2) costs
none of that and keeps the risk above. (3) moves with every merge, so a weakening that got merged
judges the next branch.

## Decision

We chose (1). At 5.4.0 `v5.3.0` judges every spec of the release, and the checkout's gate runs on
two of them, as the test of the new gate.

**Falsifiability.** We would make the tip of `main` the judge if the last tag's gate fails a spec
at two releases running for a reason that is only the tag's age, such as a line it cannot read.
**Fired-if.** manual
