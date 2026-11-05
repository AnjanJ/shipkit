# 0005 — The evals stay inside the plugin

> Status: **decided on 2026-11-05 (machine plan G8, Sprint 27, S27-T4).**
> Spec: `.shipkit/specs/users-machine/` (REQ-11); plan: `docs/plans/machine-sprint-plan.md`, G8 and
> S27-T4; the docs read at S27-T0: `.shipkit/specs/users-machine/intake.md`, "G8's Check first holds".

## Context

`plugins/shipkit/evals/` ships inside every install: 202,547 of the plugin's 539,814 tracked bytes,
278 of its 363 files, at this commit. No user runs them. Only `scripts/evals.sh`, from a checkout,
does (`claude plugin eval "$ROOT/plugins/shipkit"`, `scripts/evals.sh:43`), and no skill, agent,
hook or rule reads them: under `plugins/shipkit/`, outside `evals/`, the only mention is a comment
in `scripts/inject-rule.sh:24`. They cost bytes on disk and no byte of context.

The plugin docs, read at S27-T0 and again for this record on 2026-11-05 (Claude Code 2.1.318):

- **Loading reference**, "In-place and copied plugins"
  (https://code.claude.com/docs/en/plugins/loading.md): for every marketplace plugin not loaded in
  place, "Claude Code copies the plugin into `cache/<marketplace>/<plugin>/<version>/` at install
  and loads that copy". The page names no way to leave a path out of that copy.
- **Plugin evals**, "Use a different eval directory"
  (https://code.claude.com/docs/en/plugin-evals.md): the directory is set by `--eval-dir` or
  `"experimental": { "evals": … }` in `plugin.json`, as "a relative path of plain directory names
  … An absolute path or one containing `..` isn't accepted".

So the eval directory has to be under the plugin, and whatever is under the plugin is copied into
every install.

## Alternatives

1. **Keep `plugins/shipkit/evals/` where it is, and record why.**
2. Move the suite out of the plugin (a repository-level `evals/`), and have `scripts/evals.sh`
   assemble a scratch copy, the plugin plus the suite, and run `claude plugin eval` on that copy.
3. Move the suite into a plugin of its own in the marketplace. An eval measures the plugin that
   holds it, so this one would measure an empty plugin; it is listed only to rule it out.

## Case for (1)

The runner is the plugin as it is shipped, with nothing assembled for the eval. `scripts/evals.sh`,
`lint.py` check 17's ceiling, the reviewer fixture (`evals/lib/review-fixture.sh`) and every
result path stay as they are. The cost is disk only: a session loads none of it. The docs offer no
way to keep a suite outside the plugin, so (2) works around the platform rather than with it.

## Case against (1)

Every user downloads and keeps 202,547 bytes, 37.5% of the plugin, that they will never run, and
each update writes another copy beside the last until the 14-day cleanup removes it. (2) would ship
none of it, at the cost of one copy step in `evals.sh` and a suite that no longer sits beside the
plugin it measures. The ceiling in check 17 keeps the bytes from growing; it does not make them
useful to the user.

## Decision

(1). The evals stay in `plugins/shipkit/evals/`; check 17's ceiling stays the limit on what they
cost.

**Falsifiability.** We would move them, as (2) or by whatever the platform offers, if the plugin
docs or `claude plugin eval --help` name a way to leave a path out of an installed copy or to keep
the eval directory outside the plugin root.
**Fired-if.** manual
