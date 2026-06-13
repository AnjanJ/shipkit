# Shipkit

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow?logo=buymeacoffee)](https://buymeacoffee.com/anjanj) [![Sponsor](https://img.shields.io/badge/Sponsor-GitHub%20Sponsors-ea4aaa?logo=githubsponsors)](https://github.com/sponsors/AnjanJ)

Ship better code with Claude. A plugin for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that gives you workflow rules, skills, agents, knowledge bases, and path-scoped rules — out of the box.

**[User Guide](GUIDE.md)** — detailed docs for every skill, agent, setup/unsetup, and common workflows.

## Install

```
/plugin marketplace add https://codeberg.org/AnjanJ/shipkit.git
/plugin install shipkit@shipkit
```

**Restart Claude Code after installing** to load the plugin.

Or test locally:
```bash
claude --plugin-dir ~/code/shipkit
```

**That's it.** All skills, agents, rules, and knowledge bases are immediately available.

Want to go further? Run `/shipkit:setup` to tailor everything to your specific project — it auto-detects your stack, creates a CLAUDE.md, and installs stack-specific skills and rules. This is optional but recommended for the best experience.

## What You Get Instantly

**21 skills** — slash commands for common workflows:

| Skill | What It Does |
|-------|-------------|
| `/shipkit:setup` | Configure for your stack (Rails, React, Python, Go, Elixir, static) |
| `/shipkit:unsetup` | Remove setup and restore your project to its pre-shipkit state |
| `/shipkit:ask` | Ask the project elders a question — routed to a subagent, keeps main context thin |
| `/shipkit:map` | Build/refresh a project's `PROJECT_MAP.md` and register it for cross-project answers |
| `/shipkit:qa` | 5-phase QA workflow with probing questions before writing tests |
| `/shipkit:review-my-code` | 8-lens code review (Clean Code, DRY, KISS, YAGNI, Idioms, Framework, Perf, Errors) |
| `/shipkit:test` | Auto-detect test framework and run tests |
| `/shipkit:tdd` | Test-driven development — Red-Green-Refactor with Iron Law enforcement |
| `/shipkit:debug` | Systematic root-cause debugging — investigate before fixing |
| `/shipkit:humanize` | Detect and remove AI-generated writing patterns from text |
| `/shipkit:onboard` | Multi-phase codebase onboarding |
| `/shipkit:explain-system` | Explore codebase and write verified system design docs |
| `/shipkit:walkthrough` | Trace one feature end-to-end |
| `/shipkit:update-rules` | Update CLAUDE.md rules (never edit manually) |
| `/shipkit:context-audit` | Check context window health and find bloat |
| `/shipkit:use-library` | Read docs before using any library |
| `/shipkit:ai-feature` | Scaffold AI/LLM features (chat, embeddings, RAG, agents) |
| `/shipkit:legacy-audit` | Audit legacy codebase for modernization |
| `/shipkit:migration-plan` | Plan major dependency upgrades |
| `/shipkit:ui-ux` | Empathy-driven UI/UX design, review, and audit (web + mobile) |

**5 agents** — subagents that do heavy work in their own context so yours stays thin:

| Agent | What It Does |
|-------|-------------|
| `grandfather` | Answers questions about **one** project (architecture, where-things-live, why) — reads its `PROJECT_MAP.md`, verifies against live source, returns a tight cited answer |
| `eve` | Answers questions **across all** your registered projects (the 360° view) |
| `archivist` | Builds/refreshes the `PROJECT_MAP.md` that grandfather and eve read |
| `test-analyzer` | Auto-diagnoses test failures |
| `codebase-explorer` | Read-only exploration: traces flows, maps architecture |

### The project elders — ask, don't pollute

The biggest idea in this release: instead of loading project knowledge into your main session
(and burning context), you **ask an elder** and get back only the answer.

```
/shipkit:map                      # in a project: build its PROJECT_MAP.md once
/shipkit:map --register           # also add it to your cross-project registry
/shipkit:ask how does locale fallback work here?      # → grandfather (this project)
/shipkit:ask --all which apps deploy to Hetzner?      # → eve (all projects)
```

`grandfather`/`eve` do all the file reading in their own context and hand back a short, cited
answer — your main context never sees the 40 file reads behind it. Use them for research,
architecture questions, and "where/why" lookups. Keep editing in your main session. See
[GUIDE.md](GUIDE.md) for details, and **Episodic memory** below for the optional decision-recall add-on.

**2 knowledge bases** — on-demand reference material:

| KB | What It Provides |
|----|-----------------|
| `code-review-standards` | 8 review lenses, anti-pattern catalog, severity definitions |
| `ui-ux-standards` | Cross-platform UI/UX: a11y, design, performance, mobile patterns |

**6 path-scoped rules** — auto-loaded when editing matching files:

| Rule | Triggers On |
|------|-------------|
| `testing.md` | Test files (`*_test.*`, `*_spec.*`) |
| `migrations.md` | Database migrations |
| `security.md` | Controllers, API, auth files |
| `dependencies.md` | Dependency files (Gemfile, package.json, go.mod, etc.) |
| `monorepo.md` | Monorepo configs and workspace files |
| `ui-ux.md` | UI files (web, iOS, Android, Flutter, React Native) |

## Optional: Full Stack Configuration

Run `/shipkit:setup` to tailor the plugin to your project. It backs up your existing files first, and everything it does can be reversed with `/shipkit:unsetup`.

1. **Snapshots your current state** — copies `CLAUDE.md` + `.claude/` to `.shipkit-backup-<timestamp>/`
2. **Auto-detects** your stack, test framework, and package manager
3. **Creates CLAUDE.md** with your project info and workflow rules
4. **Installs stack-specific** skills, rules, and knowledge bases
5. **Creates settings.json** with safe permission defaults

### Stack-Specific Additions

| Stack | Extra Skills | Extra Rules | Extra KBs |
|-------|-------------|-------------|-----------|
| Rails | `/new-feature`, `/release`, `/safety-check`, `/deploy-check` | gemfile, rails | code-review-standards-rails, ai-rails |
| React | `/component` | package-json, react | — |
| Python | `/new-feature` | pyproject, python | — |
| Go | `/new-feature` | go-mod, go | — |
| Elixir | `/new-feature` | mix-deps, elixir | — |
| Static | `/audit` | — | — |

## Optional: Episodic memory (MemPalace)

`PROJECT_MAP.md` captures **structure** — how a project is built today. It does *not* capture the
**narrative of decisions**: "why did we pick Paddle over Stripe?", "what did we decide last session?".
That history lives in your past conversations.

[MemPalace](https://github.com/mempalace/mempalace) is an optional, local-first memory store
(MIT, no API calls) that indexes your conversation history verbatim and retrieves it with semantic
search. ShipKit's `grandfather` and `eve` agents will **automatically use it for decision-history
questions if it is installed** — and run perfectly fine without it (those questions just fall back to
git history).

**ShipKit does not bundle or auto-install MemPalace** — it is a separate Python package plus a
~300 MB local embedding model, so it stays opt-in. To enable it:

```bash
# 1. Install MemPalace (puts `mempalace-mcp` on your PATH; uv or pipx)
uv tool install mempalace        # or: pipx install mempalace

# 2. Backfill a project's decision history from your Claude Code transcripts.
#    Transcripts are keyed by the directory you ran Claude in, under ~/.claude/projects/
mempalace mine ~/.claude/projects/-<your-project-dir> --mode convos --wing <project> --dry-run
mempalace mine ~/.claude/projects/-<your-project-dir> --mode convos --wing <project>   # for real
```

That's it — the elder agents already declare MemPalace as an inline MCP server scoped to themselves,
so its tools load **only inside those subagents**, never your main session. No config needed on your
end beyond installing it. See [GUIDE.md](GUIDE.md) → *Episodic memory* for wings/rooms, repair, and
the recall-is-a-claim caveat.

> If you do not install MemPalace, nothing breaks — the elders simply skip the decision-recall step.

## Uninstalling

**Plugin-only users** (never ran `/setup`): just uninstall the plugin. Nothing was written to your project.
```
/plugin uninstall shipkit@shipkit
```

**Users who ran `/setup`**: run `/shipkit:unsetup` first to restore your project, then uninstall the plugin.
```
/shipkit:unsetup          # restores CLAUDE.md and .claude/ from .shipkit-backup-<timestamp>/
/plugin uninstall shipkit@shipkit
```

`/setup` snapshots your entire `CLAUDE.md` and `.claude/` directory to `.shipkit-backup-<timestamp>/` before making any changes. `/unsetup` restores from that snapshot — your project goes back to exactly how it was.

## Research

Design decisions in this plugin are informed by:

- **[Do Context Files Actually Work?](https://arxiv.org/pdf/2602.11988)** (ETH Zurich, 2025) — LLM-generated context files hurt performance. Human-written help only marginally. "Describe only minimal requirements."
- **[Optimizing Coding Agent Rules](https://arize.com/blog/optimizing-coding-agent-rules-claude-md-agents-md-clinerules-cursor-rules-for-improved-accuracy/)** (Arize, 2025) — Optimized rulesets contain 20–50 rules. Best rules are root-cause focused, correctness-preserving, edge-case aware.
- **[Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)** (HumanLayer, 2025) — ~150–200 instruction limit for frontier LLMs. Progressive disclosure over monolithic files.

## License

MIT

---

## Support

If this project saves you time, consider sponsoring. It keeps development going and lets me know people are finding it useful.

<a href="https://github.com/sponsors/AnjanJ" target="_blank"><img src="https://img.shields.io/badge/Sponsor_on_GitHub-ea4aaa?style=for-the-badge&logo=githubsponsors&logoColor=white" alt="Sponsor on GitHub"></a>&nbsp;&nbsp;<a href="https://www.buymeacoffee.com/anjanj" target="_blank"><img src="https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black" alt="Buy Me A Coffee"></a>

Made with ❤️ by [Anjan](https://anjan.dev)
