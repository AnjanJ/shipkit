# Shipkit

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

**15 skills** — slash commands for common workflows:

| Skill | What It Does |
|-------|-------------|
| `/shipkit:setup` | Configure for your stack (Rails, React, Python, Go, Elixir, static) |
| `/shipkit:unsetup` | Remove setup and restore your project to its pre-shipkit state |
| `/shipkit:qa` | 5-phase QA workflow with probing questions before writing tests |
| `/shipkit:review-my-code` | 8-lens code review (Clean Code, DRY, KISS, YAGNI, Idioms, Framework, Perf, Errors) |
| `/shipkit:test` | Auto-detect test framework and run tests |
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

**2 agents** — diagnostic subagents:

| Agent | What It Does |
|-------|-------------|
| `test-analyzer` | Auto-diagnoses test failures |
| `codebase-explorer` | Read-only exploration: traces flows, maps architecture |

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

Made with ❤️ by [Anjan](https://anjan.dev)
