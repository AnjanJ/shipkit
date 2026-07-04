# Changelog

All notable changes to Shipkit are documented here. Newest first.

## [2.2.0] — 2026-07-04

### Docs

- **Doc audit against 2.1.0 code.** Fixed two stale claims found by auditing every count and
  cross-reference: the `code-review-standards` knowledge base has 9 review lenses (a 9th,
  AI/LLM integration, engages only when AI code is present), but the README and GUIDE still
  said "8 lenses"; and the README what's-new banner still led with 2.0, omitting eve's
  `matrix`/`consolidate` reports. Everything else — 16 skills, 5 agents, 6 path-scoped rules,
  stack tables, version strings — verified accurate.

## [2.1.0] — 2026-07-04

### Added — Portfolio reports

Two named report shapes for `eve`, completing the roadmap's "double down on eve" item:

- **`/shipkit:ask --all matrix <target>`** — dependency/version matrix across every registered
  repo, read from lockfiles (installed truth over declared ranges), one evidenced row per
  project. Built for upgrade planning and vulnerability sweeps ("which repos still ship
  lodash < 4.17.21?"). Eve reports what's found in the repos and never invents upstream
  "latest"/"vulnerable" claims — it names the check to run instead.
- **`/shipkit:ask --all consolidate`** — ranked report of patterns implemented in multiple
  repos that could exist once (auth glue, API clients, deploy scripts…), with per-copy
  `path` evidence, drift notes, and an honest "not worth consolidating" verdict where that's
  the right call. Capped at the top 5-7 candidates.

## [2.0.0] — 2026-07-04

Shipkit is now **the project knowledge layer for Claude Code**: project maps, the elders,
the cross-project registry, and freshness automation. The generic workflow skills that
duplicated what Claude Code does natively are gone; the remaining workflow skills are
opt-in. If you relied on a removed skill, pin the [`v1.3.0`](https://codeberg.org/AnjanJ/shipkit/src/tag/v1.3.0) tag.

### Removed (use the native equivalent)

| Removed skill | Use instead |
|---------------|-------------|
| `/shipkit:plan` | Claude Code's built-in **plan mode** (the shipkit workflow rule tells Claude to delegate plan research to `codebase-explorer`) |
| `/shipkit:review-my-code` | Built-in **`/code-review`** — the `code-review-standards` knowledge base (8 lenses, anti-patterns, severities) is kept and can back any review |
| `/shipkit:test` | Just ask Claude to run the tests — it detects the framework; the `test-analyzer` agent is kept for diagnosing failures |
| `/shipkit:use-library` | Claude reads docs before using unfamiliar libraries; the dependencies rule still enforces docs-first on dependency files |
| `/shipkit:onboard` | `/shipkit:map` + `/shipkit:ask` (the elders ARE the onboarding), or built-in `/init` for a CLAUDE.md |

### Changed

- **Ten workflow skills no longer auto-trigger** (`debug`, `tdd`, `qa`, `ui-ux`, `humanize`,
  `ai-feature`, `legacy-audit`, `migration-plan`, `explain-system`, `walkthrough`): they are
  `disable-model-invocation: true`, so they cost your context nothing and never fire
  unexpectedly — invoke them when you want them.
- **Registry v2.** The project registry gains `Stack` and `Deploys To` columns (pulled from
  each verified map at `--register`/`refresh` time), so `eve` answers common portfolio sweeps
  ("which are Rails?", "which deploy to Vercel?") from the registry alone — zero repo reads.
- README, GUIDE, and marketplace metadata rewritten around the knowledge-layer positioning.

## [1.3.0] — 2026-07-04

### Changed

- **The coding workflow is softer, configurable, and defined once.** The workflow used to be
  restated in three places (`rules/shipkit.md`, the `/setup` CLAUDE.md template, `/plan`) and
  installed strict TDD + "BDD is not optional" into every project. Now `rules/shipkit.md` is
  the single source of truth, `/plan` and `/tdd` point at it, and `/shipkit:setup` asks for a
  **workflow style** — `strict-tdd` (the old iron law, now opt-in via `/shipkit:tdd`),
  `test-first` (the new default: prefer test-before-implementation, pragmatic exceptions), or
  `lightweight` (tests where they earn their keep). Prescriptions you didn't choose degrade
  over long sessions anyway; a declared style is honored better than an imposed law.

- **`eve`'s grep guidance is now stack-agnostic.** Her fast-path examples were hardcoded to one
  specific portfolio (Hetzner/Kamal, Oban vs Sidekiq, Rails versions) and could aim another
  user's sweep at the wrong signals entirely. Replaced with a multi-ecosystem signal
  cheat-sheet (deploy, background jobs, framework versions, payments, datastores across
  Ruby/JS/Python/Go/Elixir/Rust/PHP), explicitly labeled as examples to extend, not an
  exhaustive registry.

### Added

- **Map-freshness hook.** A `SessionStart` hook (`hooks/hooks.json` +
  `scripts/check-map-freshness.sh`) compares `PROJECT_MAP.md`'s SHA stamp to HEAD and prints a
  one-line reminder when the map is ≥20 commits behind (tune with `SHIPKIT_MAP_STALE_COMMITS`)
  or when a dependency manifest changed since it was built. Silent otherwise; never fails a
  session. Maps used to rot until an elder happened to flag drift — now staleness announces
  itself. The project registry also gains a `Mapped At` SHA column so `eve` can spot stale
  rows without opening each map.

- **Plugin lint + CI.** `./scripts/lint.sh` validates everything the plugin ships: frontmatter
  parses with required fields, `@reference` links resolve, files directly under `agents/` are
  real agents (the 1.2.1 bogus-agent bug class), plugin/marketplace/CHANGELOG versions agree,
  no machine-specific absolute paths, rule `paths:` globs are well-formed, and — new bug class
  from this release — forked skills contain no interactive checkpoints. Runs in Woodpecker CI
  on every push (`.woodpecker.yml`). The path check immediately caught two real leaks of the
  author's home directory in the `/shipkit:map` registry template; those examples are now
  generic.

### Fixed

- **Interactive skills no longer run in forked contexts.** Forked skills cannot use
  AskUserQuestion (blocked in subagents), so every mid-run question or approval checkpoint in a
  `context: fork` skill silently never reached the user. Nine skills were affected:
  - `/setup`, `/unsetup`, `/plan`, `/qa`, `/tdd` now run **inline** — their interviews,
    approval checkpoints, and (for unsetup) the destructive-restore confirmation actually reach
    you. `/plan` and `/qa` keep context thin by delegating heavy code reading to
    `codebase-explorer` instead.
  - `/onboard`, `/walkthrough`, `/explain-system` stay forked but are now **fire-and-forget**:
    all choices come from arguments, they run end-to-end, and they RETURN their drafted docs as
    proposals — the main session writes files only after you approve. This also fixes
    `/onboard` and `/walkthrough` promising file writes while running as the read-only
    `codebase-explorer` agent, which has no Write tool.

## [1.2.5] — 2026-06-14

- **`grandfather` triages reads too.** Same cheap-path idea as eve, applied to single-project
  questions: a direct lookup ("where do background jobs live?", "what Ruby version?") now greps
  the signal directly instead of reading the whole `PROJECT_MAP.md` first. The map is read for
  explanation/judgment/orientation questions, where it earns its cost. Smaller win than eve (one
  map, not 19) but trims the reflexive full-map read on quick lookups.

## [1.2.4] — 2026-06-14

- **`eve` is cheaper for single-fact questions.** Added a triage step: portfolio questions that
  ask for one attribute per project ("which deploy to Hetzner?", "Oban vs Sidekiq?", "Rails 7?")
  now take a grep-the-signal fast path instead of full-reading every `PROJECT_MAP.md`. A
  single-fact sweep over ~20 repos drops from ~50k tokens (20 full map reads) to a handful of
  grep calls. Synthesis/360° questions still read the relevant maps in full.

## [1.2.3] — 2026-06-14

- **Docs:** documented `/shipkit:plan` in the README and GUIDE (it shipped but was undocumented),
  added this changelog, and added a "what's new" pointer to the README.

## [1.2.0 – 1.2.2] — 2026-06-13

The headline of the 1.2 line: **the project elders** — subagents that answer questions
about your code without polluting your main session's context — plus optional
**episodic memory** so they can recall *why* you decided things, not just how the code looks today.

### Added — The Project Elders

- **`grandfather` agent** — answers "how/where/why" questions about **one** project. Reads that
  project's `PROJECT_MAP.md`, verifies the specific claim against live source, and returns a tight,
  cited answer. All the file reading happens in its own context, so your main session stays thin.
- **`eve` agent** — the cross-project (360°) elder. Answers questions across **all** your registered
  projects by reading the registry plus each project's map ("which apps deploy to Hetzner?",
  "everywhere I integrate Stripe").
- **`archivist` agent** — builds and refreshes `PROJECT_MAP.md`: a verified, ~150-line index of a
  project (architecture, where-things-live, data model, evolution, gotchas), stamped with the git
  SHA it was built at. Verifies every cited path exists before writing.
- **`/shipkit:ask`** — route a question to an elder. `/shipkit:ask <q>` → grandfather (this project);
  `/shipkit:ask --all <q>` → eve (all projects).
- **`/shipkit:map`** — build/refresh a project's map. `--register` also adds it to
  `~/.claude/shipkit/project-registry.md` so eve can include it in cross-project answers.
  `refresh` re-verifies; `section <name>` regenerates one section.

### Added — Episodic memory (optional)

- `grandfather` and `eve` now allowlist the `mcp__mempalace__*` tools. If you install and register
  [MemPalace](https://github.com/mempalace/mempalace) at user scope, the elders use it to recall
  **decision history** ("why did we choose Paddle over Stripe?") from your past conversations —
  the narrative a structural map cannot hold. **Entirely opt-in; nothing breaks without it.**
- Because Claude Code defers tool schemas by default, the ~30 MemPalace tools cost your **main
  session almost nothing** until an elder actually calls one. See the README and GUIDE for the
  two-line install + the recall-is-a-claim caveat.

### Added — `/shipkit:plan`

- Plan-before-code workflow: PRD → tech spec → atomic task breakdown, each with a checkpoint.
  Runs in a forked context so the planning research does not weigh down your main session.

### Fixed

- **MemPalace wiring (1.2.2):** plugin subagents silently ignore inline `mcpServers` frontmatter
  (Claude Code strips it for security). Switched to user-scope MCP registration + a `tools:`
  allowlist on the elders, then verified recall end-to-end against a live project.
- Removed a machine-specific absolute path from the shipped agents (1.2.1) so MemPalace works for
  any user via `PATH`.
- Moved the PROJECT_MAP template under `agents/templates/` so it no longer registers as a bogus
  agent.

### Docs

- README and GUIDE document the elders, the episodic-memory add-on, and `/shipkit:plan`, including
  when **not** to use the elders (do not round-trip a subagent mid-edit for a fact you need inline).

## [1.1.0] — earlier

- Added `/shipkit:tdd`, `/shipkit:debug`, and `/shipkit:humanize` skills.
- Reduced context pollution; introduced progressive disclosure and auto-invocable skills.

## [1.0.0] — initial

- Core skills (setup/unsetup, qa, review-my-code, test, onboard, explain-system, walkthrough,
  update-rules, context-audit, use-library, ai-feature, legacy-audit, migration-plan, ui-ux),
  knowledge bases, and path-scoped rules. Stack detection via `/shipkit:setup`.
