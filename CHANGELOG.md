# Changelog

All notable changes to Shipkit are documented here. Newest first.

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
