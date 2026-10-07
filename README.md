# Shipkit

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow?logo=buymeacoffee)](https://buymeacoffee.com/anjanj) [![Sponsor](https://img.shields.io/badge/Sponsor-GitHub%20Sponsors-ea4aaa?logo=githubsponsors)](https://github.com/sponsors/AnjanJ)

**Shipkit is the colleague a solo engineer does not have, as a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin.**
It remembers what was intended (a product file, specs with numbered requirements, decision
records that can check themselves), asks good questions before work is handed off, checks the
result against the intent with a reviewer that has not heard your reasoning, refuses to call
unfinished work done, and once a week tells you which product needs you. Two plugins, one repo:
`shipkit` (the loop, the elders, the rules) and `shipkit-workflows` (QA, strict TDD, debugging,
audits, migration plans, humanizing). Install either or both; each works without the other.

*What "verified" means here, precisely:* `grandfather` reads the source — and the project map as
an index when one exists — and checks the specific claim it is about to make against live source. `eve` answers some portfolio
questions straight from the registry and labels those MEDIUM confidence — attributed snapshots,
not live reads. Every answer carries `file:line` citations so you can check it yourself. There is
no independent validator confirming that a citation supports its claim; the durable part of the
promise is that the knowledge lives in **files you can read and correct**, not in opaque agent
memory.

**[User Guide](GUIDE.md)** — every skill, agent and script, with four playbooks. &nbsp;·&nbsp;
**[Changelog](CHANGELOG.md)** — what changed in each release. &nbsp;·&nbsp;
**[Roadmap](ROADMAP.md)** — where this is going.

## Install

```
/plugin marketplace add https://github.com/AnjanJ/shipkit.git
/plugin install shipkit@shipkit                # the loop, the elders, the rules
/plugin install shipkit-workflows@shipkit      # optional: opinionated engineering workflows
```

Restart Claude Code after installing. Everything below is then available, and the session hook
injects the three always-on rules at the start of every session.

Then, once per project, `/shipkit:setup`: it installs the rules as files under
`.claude/rules/shipkit/` (the path-scoped ones only load this way), detects your stack, writes
a `CLAUDE.md` of project facts, and installs the stack overlay. Optional, recommended, and
reversible with `/shipkit:unsetup`.

To run from a checkout instead, point at the two plugin roots:
`claude --plugin-dir ~/code/shipkit/plugins/shipkit --plugin-dir ~/code/shipkit/plugins/shipkit-workflows`.

## The loop

Nine steps from an idea to a shipped feature, one command each. Every step writes a file under
`.shipkit/` that a person, a script and the next session can read. `<plugin root>` is printed by
the session hook (`shipkit: plugin root is …`).

| # | Step | Command | What it writes |
|---|------|---------|----------------|
| 1 | **Product** — what it is for, three measurable goals, the non-goals | `/shipkit:product` | `.shipkit/product.md` |
| 2 | **Intake** — conflicts with non-goals, open specs and past decisions, then at most four questions | `/shipkit:intake Add refunds` | `.shipkit/specs/refunds/intake.md` |
| 3 | **Spec** — requirements in EARS, design as decision records, tasks a script can check | `/shipkit:spec refunds` | `.shipkit/specs/refunds/{spec,design,tasks}.md` |
| 4 | **Brief** — one task as a brief any agent can follow, built by a script, no model | `sh "<plugin root>/scripts/brief.sh" . refunds T1` | the brief, on stdout |
| 5 | **Build** — hand the brief over unchanged; the agent reports in the brief's fixed form | `claude -p "$(sh "<plugin root>/scripts/brief.sh" . refunds T1)"` | the task's files, and nothing else |
| 6 | **Review** — did the work stay inside the task's files? then run the task's `Done when` | `sh "<plugin root>/scripts/brief-verify.sh" . refunds T1 <sha>` | `OUTSIDE <file>` lines, or none |
| 7 | **Ship** — eight checks with evidence, an independent reviewer, `READY` or `NOT READY` | `/shipkit:ship refunds` | `.shipkit/releases/<date>-refunds.md` |
| 8 | **Escape** — a bug reached users: name the link that broke, reopen the spec with a failing-first task | `/shipkit:escape Refunds above the charge were paid out` | `.shipkit/escapes/0001-*.md` |
| 9 | **Digest** — which product needs attention this week, and why | `/shipkit:ask --all digest` | `~/.claude/shipkit/digests/<date>.md` |

Step 7 is the gate: spec-check as shipped, the project's tests, every task ticked, the
`reviewer` agent's verdict per requirement, a rollback for any migration, a concrete reversal
condition on every decision, a clean tree, and no decision whose `Fired-if` command says its
reason has expired. It never deploys, pushes or edits; it reports.

```
/shipkit:ask are any of our past decisions now falsified?    # grandfather runs decision-check.sh
sh "<plugin root>/scripts/spec-check.sh" .                    # every requirement has a task and a cited test
sh "<plugin root>/scripts/portfolio-digest.sh"                # the weekly page, by hand or from cron
```

Playbook 4 in the [guide](GUIDE.md#playbook-4--one-feature-from-idea-to-shipped) walks the nine
steps on a real feature and shows the file each one produced.

## What runs by itself

- **Three always-on rules**, 3,000 bytes in all, injected by the session hook (or loaded from
  `.claude/rules/shipkit/` after setup): the default workflow and commit discipline
  (`shipkit.md`), spec-driven development on non-trivial work (`spec-driven.md`), decision
  records with a falsifiability clause (`decisions.md`).
- **Five path-scoped rules**, installed by `/shipkit:setup` and loaded when you edit a matching
  file: tests, migrations, dependency files, monorepo manifests, UI files. Each holds only the
  traps the model gets wrong unprompted.
- **The session hook**: where the plugin lives; one line if `PROJECT_MAP.md` or a spec has
  drifted from its code; a briefing of at most eight lines — open specs and their next task,
  spec-check gaps, the top goal, the last handoff, a digest more than a week old. After a
  compaction it says so. Silent when there is nothing to say.
- **The commit guard**: a `PreToolUse` hook that blocks a `git commit` with a secret-looking
  file staged.
- **Auto-invoked skills**: when a request matches a skill's `TRIGGER when:` guidance Claude runs
  it unasked — a real architectural choice → `/shipkit:decide`; a non-trivial feature →
  `/shipkit:spec`; a failing test → `/shipkit-workflows:debug`. Invoke any by name to force it.

## What you invoke

**The elders** do the reading in their own context and hand back a cited answer, so your
session stays thin:

```
/shipkit:ask how does locale fallback work here?  # grandfather: this project
/shipkit:ask --all which apps deploy to Hetzner?  # eve: every registered project
/shipkit:ask --all matrix rails                   # eve: a version matrix from lockfiles
/shipkit:ask --all consolidate                    # eve: what exists N times that should exist once
/shipkit:map --register                           # optional: a PROJECT_MAP.md index, and a row in eve's registry
```

**Everything else in `shipkit`** (17 skills, 6 agents):

| Skill | What it does |
|-------|--------------|
| `/shipkit:setup` / `/shipkit:unsetup` | Install the rules, the stack overlay and a `CLAUDE.md`; remove only what shipkit installed |
| `/shipkit:product`, `/shipkit:intake`, `/shipkit:spec`, `/shipkit:ship`, `/shipkit:escape` | The loop, above |
| `/shipkit:decide` | A project-wide decision as a five-part record, with an optional `Fired-if` command |
| `/shipkit:handoff` | A note for the next session: in flight, done, the one next step, open questions, traps |
| `/shipkit:commit` | An atomic commit whose message scales to the change |
| `/shipkit:explain-system` | A verified system-design document: why it is built this way |
| `/shipkit:walkthrough` | One feature traced end to end, `file:line`-cited |
| `/shipkit:connect-memory` | Optional episodic memory ([MemPalace](https://github.com/mempalace/mempalace)) for the elders' decision recall |
| `/shipkit:update-rules`, `/shipkit:context-audit` | Change `CLAUDE.md` rules; see what loads into every session |

| Agent | What it does |
|-------|--------------|
| `grandfather` | One project: architecture, where things live, why — source as proof, a map as index when there is one |
| `eve` | Every registered project: sweeps, matrices, consolidation, the weekly digest |
| `archivist` | Builds and refreshes `PROJECT_MAP.md` — optional since 4.1.0: on a 224-file test it changed neither answers nor tool calls (decision 0001) |
| `reviewer` | Checks a branch against its spec with fresh eyes — behind `/shipkit:ship` |
| `tracer` | A deep trace of one feature — behind `/shipkit:walkthrough` |
| `codebase-explorer` | Read-only exploration for the other skills |

**`shipkit-workflows`** (6 skills, 1 agent): `/shipkit-workflows:qa` (a five-phase QA pass),
`/shipkit-workflows:tdd` (strict red-green-refactor), `/shipkit-workflows:debug` (root cause
before any fix), `/shipkit-workflows:legacy-audit`, `/shipkit-workflows:migration-plan`,
`/shipkit-workflows:humanize` (remove AI writing patterns from prose), and the `test-analyzer`
agent.

**Stack overlays**, installed by `/shipkit:setup` from what it detects — one base (Rails, React,
Python, Go, Elixir, Static) plus any add-ons (Hotwire, React in Rails, LiveView, Oban, ML). Each
adds a few skills and rules that hold that stack's traps: `mount/3` runs twice, `perform/1` must
be idempotent, Turbo caches pages so a leaked listener fires twice, never evaluate on training
data. The guide lists every overlay.

## Uninstall

Never ran `/shipkit:setup`: uninstall the plugin; nothing was written to your project.

```
/plugin uninstall shipkit@shipkit
```

Ran `/shipkit:setup`: `/shipkit:unsetup` first. It takes a recovery snapshot, then removes only
the files shipkit installed, using the manifest that records them; a file you edited since is
reported and kept unless you say otherwise. Then uninstall the plugin.

## Research

- **[Do Context Files Actually Work?](https://arxiv.org/pdf/2602.11988)** (ETH Zurich, 2026) — LLM-generated context files hurt performance; human-written ones help only marginally. "Describe only minimal requirements."
- **[Optimizing Coding Agent Rules](https://arize.com/blog/optimizing-coding-agent-rules-claude-md-agents-md-clinerules-cursor-rules-for-improved-accuracy/)** (Arize, 2025) — the best rules are root-cause focused and name specific traps.
- **[Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)** (HumanLayer, 2025) — ~150–200 instructions is the ceiling; progressive disclosure over monolithic files.

## License

MIT

## Support

If this project saves you time, consider sponsoring. It keeps development going and lets me know
people are finding it useful.

<a href="https://github.com/sponsors/AnjanJ" target="_blank"><img src="https://img.shields.io/badge/Sponsor_on_GitHub-ea4aaa?style=for-the-badge&logo=githubsponsors&logoColor=white" alt="Sponsor on GitHub"></a>&nbsp;&nbsp;<a href="https://www.buymeacoffee.com/anjanj" target="_blank"><img src="https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black" alt="Buy Me A Coffee"></a>

Made with ❤️ by [Anjan](https://anjan.dev)
