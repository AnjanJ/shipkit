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
| `hook` | 3,951 | the session hook's output in that directory: the root line (≈ 60), the version line (23), and three injected rules with their four-line headers (2,014 + 1,018 + 829); `--eval-rule` prints nothing outside the eval tool | the plan's §0 says ≤ 1,900 where the project has not opted in; **after W1 (S20-T2) the row reads 2,269** — root 60, version 23, the opt-in line 172, `shipkit.md` with its header 2,014 — so the plan's ceiling never counted the header (≈ 230) or the line; the honest ceiling for W1 alone is ≤ 2,300, and ≤ 300 if W2 finds the Care lines followed unaided (root, version, the opt-in line) |
| `skills-core` | 3,969 | the `description:` line of each of 17 `plugins/shipkit/skills/*/SKILL.md` | **≤ 2,950** (W3: 10 skills; the plan's draft said 2,400 — the eight skills W3 does not touch total 2,535 on their own and lint caps a description at 300, so the owner amended the ceiling on 2026-10-30; after W3 the row reads 2,894) |
| `skills-workflows` | 1,598 | the same for 6 `plugins/shipkit-workflows/skills/*/SKILL.md` | ≤ 1,900 (7 skills; `commit` joins) |
| `agents` | 1,720 | the `description:` line of each of 7 agents (6 core, `test-analyzer`) | ≤ 1,000 (W4: 4 agents) — after W4 the row reads 991 (3 core + `test-analyzer`) |
| `overlay-skills` | 0 | whole files of the skills setup installed under the project's `.claude/skills/`, read from the manifest `.claude/rules/shipkit/.installed` | 0 by default (W6: installed on a flag) — **after S21-T1 a Rails install without `--with-skills` reads 0** (6 skills, 17,529 bytes, with it) |
| `overlay-appends` | 0 | the stack sections between `<!-- shipkit:stack:X -->` markers in the project's `CLAUDE.md` | audited line by line (W7) — **after S21-T2** a Rails project's section is 1,388 bytes (was 1,651), a FastAPI project's 1,012 (was 2,507; its Django lines now load only on Django files) |
| `rules-always-on` | 2,979 | `rules/shipkit.md` + `spec-driven.md` + `decisions.md` as shipped | ≤ 3,000, lint-held; the text does not change in this plan (two skill names move with W3) |

On this repository itself (set up, `.shipkit/` present, the rules installed as files) the
`hook` row is 339 bytes: the root and version lines plus the briefing's spec and rules lines,
no rule injected. That is what an opted-in project pays, and W1 does not change it.

Not in the table, by the plan's §0: `agents/eve.md` is 12,067 bytes in `eve`'s own context
per call, 510 of them comments the model never receives (W9, `docs/design/trim-audit-eve.md`;
16,947 before the trim); `agents/grandfather.md` 9,156; the briefing
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
| 2026-10-30 | S20-T2 (W1) | 2,269 | 3,969 | 1,598 | 1,720 | 2,979 | the two loop rules opt-in; one opt-in line (172 bytes) added; an opted-in project unchanged |
| 2026-10-30 | S20-T3 (W2) | 2,290 | 3,969 | 1,598 | 1,720 | 3,000 | the Care line reworded (+105 bytes in `shipkit.md`, trims elsewhere; the three rules at the budget) |
| 2026-10-30 | S20-T4 (W3) | 2,289 | 2,894 | 1,885 | 1,720 | 2,999 | ten core skills (17 → 10, −27%); `commit` in workflows (6 → 7); the ceiling amended 2,400 → 2,950 on the owner's word (the eight untouched skills total 2,535) |
| 2026-10-30 | S20-T5 (W4) | 2,289 | 2,894 | 1,885 | 991 | 2,999 | four agents (7 → 4, −42%): tracer into grandfather, archivist into `map` (forked), codebase-explorer → the built-in Explore |
| 2026-10-30 | S21-T1, T2 (W6, W7) | 2,289 | 2,894 | 1,885 | 991 | 2,999 | on a scratch set-up project (`install-rules.sh` + `install-stack.sh`): Rails `overlay-skills` 17,529 → 0 by default, `overlay-appends` 1,651 → 1,388; Python `overlay-appends` 2,507 → 1,012 (+ `django.md`, path-scoped) |
| 2026-10-30 | S21 exit (W6–W9) | 2,289 | 2,894 | 1,885 | 991 | 2,999 | the §0 table re-measured on a bare dir and scratch Rails and Python installs: Rails `overlay-skills` 0 by default, `overlay-appends` 1,388; Python `overlay-skills` 0, `overlay-appends` 1,003 (shorter placeholder values than T2's 1,012); `eve.md` 12,067 (W9); `ask/SKILL.md` 6,294 (+161, the shapes in `reports.md`) |
| 2026-10-31 | S22-T2 (W5) | 2,289 | 2,894 | 1,885 | 991 | 2,999 | a real project, `linkshort` before setup; after setup `hook` 90, `overlay-skills` 0, `overlay-appends` 1,051 (`field-notes-5.0.md`) |
| 2026-10-31 | 5.0.0 | 2,289 | 2,894 | 1,885 | 991 | 2,999 | the §0 table at the release, every row at its ceiling or the record says why (`CHANGELOG.md` 5.0.0); `eve.md` 12,067 |
