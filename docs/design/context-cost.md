# Context cost — what a session pays for shipkit, measured

> The thinning plan's rule 20 instrument (`docs/plans/thinning-sprint-plan.md` §0): every byte
> that loads into every session has a number or the owner's word. `scripts/context-cost.sh
> <project-dir>` prints the rows below for one project; this file holds the baseline the plan
> starts from and the ceilings it is aiming at. Re-measured at every sprint's merge
> (S20-T-MERGE, S21-T-MERGE, S22-T-REL). Spec: `.shipkit/specs/always-on/` (REQ-1 to REQ-3).

## The baseline: 4.12.0, a project that never opted in

`scripts/context-cost.sh "$(mktemp -d)"` on 2026-10-30 at `877a8e5` — an empty git repository,
no `CLAUDE.md`, no `.claude/`, no `.shipkit/`; the plugin at `plugins/shipkit` (4.12.0) with
`plugins/shipkit-workflows` beside it:

| Row | Bytes | What it counts | Ceiling after the plan |
|---|---:|---|---|
| `hook` | 3,951 | the session hook's output in that directory: the root line (≈ 60), the version line (23), and three injected rules with their four-line headers (2,014 + 1,018 + 829); `--eval-rule` prints nothing outside the eval tool | ≤ 1,900 where the project has not opted in (W1: root, version, `shipkit.md` with its header, the opt-in line); ≤ 120 if W2 finds the Care lines followed unaided |
| `skills-core` | 3,969 | the `description:` line of each of 17 `plugins/shipkit/skills/*/SKILL.md` | ≤ 2,400 (W3: 10 skills) |
| `skills-workflows` | 1,598 | the same for 6 `plugins/shipkit-workflows/skills/*/SKILL.md` | ≤ 1,900 (7 skills; `commit` joins) |
| `agents` | 1,720 | the `description:` line of each of 7 agents (6 core, `test-analyzer`) | ≤ 1,000 (W4: 4 agents) |
| `overlay-skills` | 0 | whole files of the skills setup installed under the project's `.claude/skills/`, read from the manifest `.claude/rules/shipkit/.installed` | 0 by default (W6: installed on a flag); a Rails project today carries 6 skills, 17,529 bytes |
| `overlay-appends` | 0 | the stack sections between `<!-- shipkit:stack:X -->` markers in the project's `CLAUDE.md` | audited line by line (W7); 1.6–2.3 KB per stack today |
| `rules-always-on` | 2,979 | `rules/shipkit.md` + `spec-driven.md` + `decisions.md` as shipped | ≤ 3,000, lint-held; the text does not change in this plan (two skill names move with W3) |

On this repository itself (set up, `.shipkit/` present, the rules installed as files) the
`hook` row is 339 bytes: the root and version lines plus the briefing's spec and rules lines,
no rule injected. That is what an opted-in project pays, and W1 does not change it.

Not in the table, by the plan's §0: `agents/eve.md` is 17,010 bytes in `eve`'s own context
per call (W9, `docs/design/trim-audit-eve.md`); `agents/grandfather.md` 9,156; the briefing
is ≤ 800 bytes and only with `.shipkit/`; the path-scoped rules load on a matching edit only.

## How each row is measured

The script runs the real hook — `scripts/session-start.sh`, then `scripts/inject-rule.sh` for
`shipkit`, `spec-driven`, `decisions` and `--eval-rule`, the four commands `hooks/hooks.json`
lists — from inside the project directory with `CLAUDE_PLUGIN_ROOT` set, under a scratch
`HOME` and `CLAUDE_CONFIG_DIR` so the owner's `~/.claude/shipkit/plugin-root` and
`plugin-root.dev` do not move; `wc -c` of that output is the row (smoke check 63 asserts the
equality). A description is the text after `description:` on the first such line of the
file's frontmatter, plus its newline — what the skill or agent listing carries into the
session; the sum over files is the row. Overlay skills are the manifest's `.claude/skills/`
entries, whole files, since a listed project skill is read when it fires; appends are counted
with their markers. No model is called; the script exits 0 and prints eight tab-separated
rows (a header row with the date, project and plugin version, then the seven above).

Run it on any project: `scripts/context-cost.sh ~/code/<project>`; on a checkout other than
this one, `CLAUDE_PLUGIN_ROOT=<root> scripts/context-cost.sh <project>`.

## History

| Date | Tree | hook (bare) | skills-core | skills-workflows | agents | rules | Note |
|---|---|---:|---:|---:|---:|---:|---|
| 2026-10-22 | 4.11.0 + PR #21 | 3,945 | 3,952 | 1,592 | 1,713 | 2,979 | the plan's §0, measured by hand |
| 2026-10-30 | 4.12.0 (`877a8e5`) | 3,951 | 3,969 | 1,598 | 1,720 | 2,979 | the script's first run; the baseline |
