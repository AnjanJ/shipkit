# Shipkit User Guide

A complete guide to using every skill, agent, and feature in shipkit.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [How Shipkit Works](#how-shipkit-works) — automatic vs. invoked
3. [Setup & Unsetup](#setup--unsetup)
4. [The Project Elders](#the-project-elders)
5. [Episodic Memory (MemPalace)](#episodic-memory-mempalace)
6. [Skills Reference](#skills-reference)
7. [Spec-Driven Development](#spec-driven-development)
8. [Memory](#memory)
9. [Agents](#agents)
10. [Knowledge Bases](#knowledge-bases)
11. [Path-Scoped Rules](#path-scoped-rules) — automatic + always-on
12. [Common Workflows](#common-workflows)
13. [Tips](#tips)

---

## Getting Started

Shipkit ships as **two plugins from one marketplace**. Install either or both:

```
/plugin marketplace add https://github.com/AnjanJ/shipkit.git
/plugin install shipkit@shipkit                # the knowledge layer
/plugin install shipkit-workflows@shipkit      # optional: the engineering workflows
```

`shipkit` is the knowledge layer — maps, elders, registry, specs, decisions, stack overlays.
`shipkit-workflows` is the opinionated half — QA, strict TDD, debugging, audits, migration
plans. **Each works without the other**, so you can install just one.

Skills are namespaced by their plugin: `/shipkit:<name>` and `/shipkit-workflows:<name>`. You
can start using them immediately — no configuration needed.

```
/shipkit:ask <question>     # ask the elders about this project (or --all, portfolio-wide)
/shipkit:map --register     # optional: a PROJECT_MAP.md index + a row in eve's registry
/shipkit-workflows:qa       # full QA workflow (needs the workflows plugin)
```

For the best experience, run `/shipkit:setup` once per project to tailor everything to your stack
and pick a workflow style.

---

## How Shipkit Works

Shipkit has three kinds of behavior. Most confusion ("do I have to run something?") disappears
once you know which is which.

| Kind | Fires… | Your action |
|------|--------|-------------|
| 🟢 **Automatic** (rules + hooks) | On its own — when you edit a file, do certain work, or start a session | None |
| 🔵 **Auto-invoked** (skills with `TRIGGER when:`) | When your request matches the skill | None, or invoke by name to force |
| ⚪ **You invoke** (research/one-shot skills) | When you type `/shipkit:<name>` | Call it deliberately |

### 🟢 Automatic — no command needed

You never call these. How they reach a session matters, because Claude Code does **not** load a
plugin's `rules/` directory: the always-on rules and the hook work as soon as the plugin is
loaded (the session hook injects the rules); the path-scoped rules need
`/shipkit:setup` once per project, which installs every rule as a file under
`.claude/rules/shipkit/`.

| What | When it fires | What it does |
|------|--------------|--------------|
| **Path-scoped rules** (after `/shipkit:setup`) | You edit a matching file (test, migration, controller, dependency file, UI, monorepo config) | Applies that file type's conventions — see [Path-Scoped Rules](#path-scoped-rules) |
| **`spec-driven` rule** | You start **non-trivial** feature work | Puts the three questions (what/how/done) + EARS + TDD-first in effect — see [Spec-Driven Development](#spec-driven-development) |
| **`decisions` rule** | You make a real choice (≥2 alternatives) | Prompts a five-part decision record with a falsifiability clause |
| **Commit discipline** | Any commit | Atomic commits, message scaled to the change, no `git add .`, no `--no-verify` |
| **Session hook** | Session start | Tells Claude the plugin root, injects the always-on rules unless installed as files, and prints one line if `PROJECT_MAP.md` or a spec has drifted from the code |

### 🔵 Auto-invoked — Claude picks the right skill

Every shipkit skill is model-invocable. The ones below carry `TRIGGER when: / DO NOT TRIGGER
when:` guidance, so Claude runs them when your request matches — you don't have to remember they
exist. You can still invoke any by name to force it.

| Skill | Auto-fires when you… |
|-------|---------------------|
| `/shipkit:spec` | ask to build/design a non-trivial feature before coding |
| `/shipkit:decide` | make a project-wide choice with real alternatives |
| `/shipkit:commit` | ask to commit, or reach a natural commit point |
| `/shipkit-workflows:debug` | hit a failing test or a bug to root-cause |
| `/shipkit-workflows:tdd` | explicitly ask for strict red-green-refactor |
| `/shipkit:explain-system` | ask *why* a system is designed the way it is |
| `/shipkit:walkthrough` | ask how one feature works end-to-end |
| `/shipkit-workflows:legacy-audit` | ask to assess/modernize an inherited codebase |
| `/shipkit-workflows:migration-plan` | ask to plan a major upgrade or framework migration |
| `/shipkit-workflows:humanize` | ask to de-AI writing in docs/READMEs/PRs |

### ⚪ You invoke — call it when you want it

Research, setup, and one-shot tools you reach for on purpose — you decide when. (Most don't
auto-fire; `/shipkit:connect-memory` will also start on its own if you *ask* to "set up episodic
memory", but you'd normally just call it.)

| Skill | Use it to… |
|-------|-----------|
| `/shipkit:ask` | ask the elders a question (this project, or `--all` for the portfolio) |
| `/shipkit:map` | build/refresh `PROJECT_MAP.md`; `--register` for cross-project answers |
| `/shipkit:setup` / `/shipkit:unsetup` | configure shipkit for your stack, or revert |
| `/shipkit:connect-memory` | set up MemPalace so the elders recall past decisions |
| `/shipkit:context-audit` | check context-window health and find bloat |
| `/shipkit-workflows:qa` | run the 5-phase QA workflow |
| `/shipkit:update-rules` | change CLAUDE.md rules (never edit them by hand) |

**Rule of thumb:** the *knowledge layer* (maps, elders, registry) is something you **ask**; the
*discipline* (rules, commit hygiene, spec/decision capture, freshness) is something that
**happens**.

---

## Setup & Unsetup

### /shipkit:setup

Configures shipkit for your specific project. Run it once when you start using shipkit in a new codebase.

**What it does:**
1. Snapshots your current `CLAUDE.md` + `.claude/` — once to `.shipkit-baseline/` (the state
   before shipkit ever touched this project, never overwritten again) and to a rolling
   `.shipkit-backup-<timestamp>/` for this run
2. Detects your stack (Rails, React, Python, Go, Elixir, static)
3. Detects test framework and package manager
4. Asks for your project purpose, team conventions, and **workflow style** — `strict-tdd`
   (iron-law red-green-refactor), `test-first` (the default: prefer test-before-implementation,
   pragmatic exceptions), or `lightweight` (tests where they earn their keep)
5. Creates a tailored CLAUDE.md that declares your choices; the workflow itself is defined
   once, in shipkit's always-on rules
6. Installs all nine shipkit rules as files under `.claude/rules/shipkit/` via
   the plugin's `scripts/install-rules.sh` — Claude Code only loads rules from a project, so this is what
   makes the path-scoped rules work. The install is stamped with the plugin version; the session
   hook tells you when a plugin upgrade has made the copies stale, and re-running setup refreshes them
7. Installs stack-specific skills and rules via the plugin's `scripts/install-stack.sh`
   (into `.claude/skills/` and `.claude/rules/shipkit/<stack>/`), filling every
   `{{placeholder}}` from detection — the script refuses to leave one unfilled
8. Optionally creates `.claude/settings.json` with safe defaults

The CLAUDE.md it writes is short on purpose — project facts (purpose, stack, commands, key
paths, workflow style). Conventions live in the rules, so no generic boilerplate is restated.

**How backups work:**

Two artifacts, answering two different questions:

| Artifact | Answers | Written |
|----------|---------|---------|
| `.shipkit-baseline/` | What did this project look like *before shipkit ever touched it*? | **Once, ever** — never overwritten |
| `.shipkit-backup-<ts>/` | What did it look like before *this* setup run? | Every run |

- Keeping them separate matters: re-running `/setup` used to overwrite the "pre-shipkit"
  snapshot with an already-configured shipkit install, so `/unsetup` restored shipkit onto
  itself and called that your original state.
- An older backup is nested inside the new one as `previous-backup/`. Shipkit **never offers to
  delete one** — freeing a directory is not worth an unrecoverable loss. Delete them yourself
  when you're ready.
- `/setup` offers to add all three (`.shipkit-baseline/`, `.shipkit-backup-*/`,
  `.shipkit-recovery-*/`) to your `.gitignore` — they can contain your local settings.

**Usage:**
```
/shipkit:setup              # auto-detect stack
/shipkit:setup rails        # skip detection, use Rails
/shipkit:setup react        # skip detection, use React
```

**When to run it:**
- First time using shipkit in a project
- After cloning a project that doesn't have a CLAUDE.md
- When switching stacks (run `/shipkit:unsetup` first)

### /shipkit:unsetup

Reverses what `/setup` did — removing **shipkit's files, and only shipkit's files**.

**What it does:**
1. Takes a recovery snapshot to `.shipkit-recovery-<timestamp>/` **first**, before reading or
   touching anything — so the unsetup itself can be undone. `.claude/` is commonly gitignored,
   so git is no safety net here.
2. Finds the `.shipkit-backup-<timestamp>/` directory
3. Shows you the actual removal set — the concrete list of paths, plus a diff for `CLAUDE.md`
4. Asks for confirmation before proceeding
5. Removes only the paths recorded in the installation manifest, then prunes the directories it
   emptied. Another plugin's agents, your `settings.local.json`, anything you added after setup
   — all untouched. A file **you** edited since installation is reported and kept unless you
   explicitly ask for it to go.
6. Restores `CLAUDE.md` (and anything else missing) from the backup; if the backup contained a
   nested older backup, restores that too
7. **Keeps** both `.shipkit-recovery-<ts>/` and `.shipkit-backup-<ts>/` and tells you they're
   safe to delete — it will not destroy the record of what you just came from

`.shipkit/` — your specs and decision records — is never touched. That's your work product, not
shipkit's configuration.

**If shipkit can't prove ownership** (a project set up before 3.1, so there's a version stamp
rather than a manifest) it says so and asks, rather than deleting `.claude/` wholesale.

**Usage:**
```
/shipkit:unsetup
```

**When to run it:**
- You want to remove shipkit's project configuration
- Before switching to a different stack (then run `/setup` again)
- Before uninstalling the plugin entirely

**Full removal:**
```
/shipkit:unsetup                     # remove project configuration
/plugin uninstall shipkit@shipkit    # remove the plugin
```

**Note:** If you never ran `/setup`, you don't need `/unsetup`. Just uninstall the plugin directly.

---

## The Project Elders

The elders solve one problem: **answering questions about a project without polluting your main
session's context.** When you ask "how does X work?" the naive path is to read a dozen files into
your main conversation — which then carries that weight for the rest of the session. Instead, an
elder subagent does the reading in *its own* context and hands back only the answer.

### The pieces

| Piece | Role |
|-------|------|
| `PROJECT_MAP.md` | A verified, ~150-line index of one project: architecture, where-things-live, data model, evolution, gotchas. Stamped with the git SHA it was built at. |
| `archivist` agent | Builds and refreshes `PROJECT_MAP.md`. Run via `/shipkit:map`. |
| `grandfather` agent | Answers questions about **one** project. Reads the map, verifies the specific claim against live source, returns a tight cited answer. Run via `/shipkit:ask`. |
| `eve` agent | Answers questions **across all** registered projects (the 360° view). Run via `/shipkit:ask --all`. |
| Registry | `~/.claude/shipkit/project-registry.md` — the list of projects eve reads. Populated by `/shipkit:map --register`. |

### Typical usage

```
# Ask about THIS project (→ grandfather) — no map needed; it reads the source
/shipkit:ask how does locale fallback work in this monolith?

# Optional, once per project: an index for the elders and a row in eve's registry
/shipkit:map --register
/shipkit:ask is it safe to remove the legacy_token column?

# Ask across ALL your projects (→ eve)
/shipkit:ask --all which apps deploy to Hetzner vs AWS?
/shipkit:ask --all everywhere I integrate Stripe

# Portfolio reports (→ eve, fixed report shapes)
/shipkit:ask --all matrix rails          # every repo's Rails version, from lockfiles
/shipkit:ask --all matrix lodash         # vulnerability/upgrade sweep for one dep
/shipkit:ask --all consolidate           # what am I maintaining N times?

# After a big change, refresh the map
/shipkit:map refresh
```

### When to use them — and when not to

- **Use** for research: architecture, "where does X live", "why was this done this way",
  portfolio-wide lookups, deciding whether a change is safe.
- **Do not use** mid-edit for a fact you need right now to keep typing — a subagent round-trip is
  slower than just reading the one file. The elders are read-only; they inform, they do not edit.

### How they stay honest

The map is an *index*, not the final word. When the map and live source disagree, the elders trust
**source** and flag the drift in their answer — so a stale map produces a correction, not a confident
wrong answer. Refresh with `/shipkit:map refresh` when you see drift flagged.

You also get an automatic nudge: a shipkit `SessionStart` hook compares the map's SHA stamp to
HEAD and prints a one-line reminder when the map is ≥20 commits behind (tune with
`SHIPKIT_MAP_STALE_COMMITS`) or when a dependency manifest has changed since it was built. It is
silent otherwise and never blocks a session.

---

## Episodic Memory (MemPalace)

`PROJECT_MAP.md` answers *"how is this built?"*. It cannot answer *"what did we **decide**, and why?"*
— that narrative lives in your past conversations. [MemPalace](https://github.com/mempalace/mempalace)
is an **optional** local-first memory store that fills exactly this gap.

**It is opt-in. ShipKit does not install it for you.** The `grandfather` and `eve` agents allowlist
the `mcp__mempalace__*` tools, so:

- If MemPalace **is** installed and registered → the elders use it for decision-history questions.
- If it is **not** → those tools are simply absent and the elders run fine without it; decision
  questions fall back to git history. Nothing breaks.

Plugin subagents cannot declare their own MCP server (Claude Code ignores inline `mcpServers` for
security), so you register MemPalace **once at user scope** and the elders' `tools:` allowlist grants
it to *only those two agents*. Because Claude Code defers tool schemas by default (tool search), the
~30 MemPalace tools stay **out of your main session's context** until an elder actually calls one —
the thin-context principle is preserved.

### Enabling it

**The easy way — `/shipkit:connect-memory`.** One skill does the whole setup: detects what's
already done, installs MemPalace if missing, registers it at user scope, **auto-derives your
transcript directory** (so you don't hand-build the `~/.claude/projects/-Users-...` path),
backfills this project's history (dry-run first, then for real), and reminds you to restart Claude
Code. Run it once per machine to install/register, and once per project to backfill. It's safe to
re-run — it skips whatever is already done.

```
/shipkit:connect-memory                 # set it up for this project
/shipkit:connect-memory --wing myapp    # override the wing name
/shipkit:connect-memory --reinstall     # force re-install/register on a broken setup
```

**By hand** (what the command runs for you), if you'd rather:

```bash
# 1. Install (puts `mempalace-mcp` on PATH; ~300 MB embedding model downloads on first use)
uv tool install mempalace        # or: pipx install mempalace

# 2. Register once at user scope, then RESTART Claude Code so the server loads
claude mcp add --scope user mempalace mempalace-mcp

# 3. Backfill a project's history from your Claude transcripts.
#    Claude transcripts are keyed by the DIRECTORY you ran Claude in, under ~/.claude/projects/,
#    with EVERY non-alphanumeric character replaced by "-" (~/code/my_app → -Users-you-code-my-app;
#    not by repo name — find the dir whose sessions hold the decisions you want recalled).
#    NOTE: run `mempalace split <dir>` first if transcripts are concatenated mega-files.
mempalace mine ~/.claude/projects/-Users-you-code-myproject --mode convos --wing myproject --dry-run
mempalace mine ~/.claude/projects/-Users-you-code-myproject --mode convos --wing myproject
```

### Concepts

- **Wing** = a project (use one `--wing` per project). **Room** = an auto-classified topic
  (technical / planning / architecture / decisions / problems). **Drawer** = one verbatim chunk.
- **Recall is a claim, not gospel.** The elders treat anything MemPalace returns as a statement that
  was true *when said*, and verify it against current source before stating it — the same discipline
  they apply to the map.

### Troubleshooting

- **Search fails with "malformed inverted index for FTS5 table"** — the full-text index is corrupt.
  `mempalace repair --yes` rebuilds it; if `repair` refuses (SQLite-layer corruption), back up
  `~/.mempalace/palace/chroma.sqlite3`, then run
  `sqlite3 chroma.sqlite3 "INSERT INTO embedding_fulltext_search(embedding_fulltext_search) VALUES('rebuild');"`
  and confirm `PRAGMA integrity_check;` returns `ok`.

---

## Skills Reference

### /shipkit:ask — Ask the Project Elders

Route a question to a research subagent so your main context stays thin. See
[The Project Elders](#the-project-elders) for the full picture.

- `/shipkit:ask <question>` → `grandfather` answers about **this** project.
- `/shipkit:ask --all <question>` → `eve` answers across **all** registered projects.
- `/shipkit:ask --all digest` → runs `portfolio-digest.sh` (below), then `eve` answers one
  question from the page and `studio.md`: *which product needs attention this week, and why?*
  — at most three, each reason a quoted digest line and the studio priority it bears on.

The agent reads the relevant `PROJECT_MAP.md`, verifies the specific claim against live source
(and queries MemPalace for decision-history questions if installed), and returns a tight, cited
answer. Use it for "how/where/why" research, not for facts you need inline while editing.

### /shipkit:map — Build & Refresh the Project Map

Create or refresh the `PROJECT_MAP.md` that the elders read.

- `/shipkit:map` → build it if absent, refresh it if present.
- `/shipkit:map refresh` → force a re-verification pass against current source.
- `/shipkit:map section <name>` → regenerate one section (e.g. `section evolution`).
- `/shipkit:map --register` → also add the project to `~/.claude/shipkit/project-registry.md`
  so `eve` can include it in cross-project answers.

Run it once per project to start, and `refresh` after a big change (new domain, refactor,
framework upgrade). A stale map makes the elders flag drift — that is your cue to refresh.

### /shipkit:connect-memory — Set Up Episodic Memory

Wire up [MemPalace](#episodic-memory-mempalace) so `grandfather`/`eve` can recall *why* past
decisions were made — end to end, so you don't hand-run the install and hand-derive your
transcript path.

- `/shipkit:connect-memory` → detect state, install if missing, register at user scope, backfill
  this project's history (dry-run first), remind you to restart Claude Code.
- `/shipkit:connect-memory --wing <name>` → override the wing name (default: directory basename).
- `/shipkit:connect-memory --reinstall` → force re-install/register on a broken setup.

Once per machine to install/register; once per project to backfill. Optional — skip it and the
elders fall back to git history for decision questions. Full concepts and troubleshooting live in
[Episodic Memory](#episodic-memory-mempalace).

### /shipkit-workflows:qa — Quality Assurance

5-phase QA workflow that asks probing questions before writing tests.

**Phases:**
1. Reconnaissance — detect test framework, classify changed files by risk
2. Interrogation — ask 3-8 probing questions before writing any tests
3. Test Plan — structured plan organized by category for your approval
4. Spec Writing — one assertion per test, descriptive names, arrange-act-assert
5. Execution — run tests, fix failures, produce QA report

```
/shipkit-workflows:qa                              # QA recent changes
/shipkit-workflows:qa src/services/payment.ts      # focus on specific file
```

---

### /shipkit-workflows:tdd — Test-Driven Development

Enforces the Red-Green-Refactor cycle. No production code without a failing test first.

**Iron Law:** Write the test first. Watch it fail. Write minimal code to pass. Refactor.

Includes rationalization prevention (excuse-to-reality table), red flags list, testing anti-patterns catalog, and a verification checklist.

```
/shipkit-workflows:tdd feature       # TDD for a new feature
/shipkit-workflows:tdd bugfix        # TDD for a bug fix
/shipkit-workflows:tdd refactor      # TDD for refactoring
```

---

### /shipkit-workflows:debug — Systematic Debugging

Root-cause debugging with a 4-phase process. No fixes without investigation first.

**Phases:**
1. Root Cause Investigation — read errors, reproduce, trace data flow
2. Pattern Analysis — find working examples, compare
3. Hypothesis and Testing — test one variable at a time
4. Implementation — create failing test, fix root cause, verify

Includes the **three-strike rule:** after 3 failed fixes, stop and question the architecture.

```
/shipkit-workflows:debug                                  # general debugging
/shipkit-workflows:debug "TypeError in checkout flow"     # describe the error
/shipkit-workflows:debug src/services/payment.ts          # debug a specific file
```

---

### /shipkit-workflows:humanize — AI Writing Detection

Detects and removes AI-generated writing patterns. Two modes: humanize (rewrite) and analyze (detect only).

Covers 40 patterns across vocabulary, structure, tone, and formatting. Includes a full pattern library reference.

```
/shipkit-workflows:humanize                   # humanize provided text
/shipkit-workflows:humanize analyze           # detect patterns only, don't rewrite
```

---

### /shipkit:explain-system — System Design Docs

Explores your codebase and writes a verified system design document explaining WHY it's designed the way it is.

```
/shipkit:explain-system                  # full 6-phase explanation
/shipkit:explain-system quick            # phases 1-2 only
/shipkit:explain-system section auth     # regenerate just one section
```

---

### /shipkit:walkthrough — Feature Trace

Traces one feature from entry point through every layer.

```
/shipkit:walkthrough user-registration           # trace by feature name
/shipkit:walkthrough src/controllers/auth.ts     # trace from file
/shipkit:walkthrough checkout surface            # happy path only
/shipkit:walkthrough checkout deep               # include error paths
```

---

### /shipkit:update-rules — Update CLAUDE.md

Adds, updates, or removes rules in CLAUDE.md while maintaining structure.

```
/shipkit:update-rules always use factory_bot, never fixtures
/shipkit:update-rules remove the rule about JIRA references
/shipkit:update-rules add: API responses must include request_id
```

**Never manually edit CLAUDE.md** — use this skill to keep formatting consistent.

---

### /shipkit:commit — Atomic Commit, Message Scaled to the Change

Builds one atomic commit whose message carries the reasoning a future reader (and the elders)
will want. It inspects the working tree, splits or questions tangled changes rather than
bundling them, stages the specific files, and writes a message whose depth matches the change.

The always-on shipkit rule carries the short form (atomic commits, files staged by name, no
`--no-verify`, no co-author trailer) and points to this skill for the message format, so Claude
follows it on *any* substantive commit it makes — not only when you invoke the skill by name.

- **Trivial** change (version bump, typo, one-line doc/config) → a clean imperative subject is
  the whole message.
- **Substantive** change → subject + body: **What** changed, **Why** it exists, **How** and the
  decisions made (including alternatives rejected), and a **Test plan** (the command run and
  what you observed). Plus **Risk/Rollback**, **Follow-ups**, and **Refs** where they apply.

```
/shipkit:commit                     # inspect the tree and commit it well
/shipkit:commit emphasize the perf tradeoff in the why
```

It never bundles unrelated changes, never fabricates a test plan, and never adds a co-author
trailer or touches published commits unless you ask.

---

### /shipkit:context-audit — Context Window Health

Reports what's consuming your context window and suggests optimizations.

```
/shipkit:context-audit
```

Use this when Claude seems to be forgetting things or losing context.

---

### /shipkit-workflows:legacy-audit — Legacy Codebase Audit

Audits for modernization opportunities. Read-only — does not modify files.

```
/shipkit-workflows:legacy-audit              # all categories
/shipkit-workflows:legacy-audit deps         # dependency age and security
/shipkit-workflows:legacy-audit dead-code    # unused files and functions
/shipkit-workflows:legacy-audit complexity   # hotspots cross-referenced with git churn
/shipkit-workflows:legacy-audit coverage     # test coverage gaps
```

---

### /shipkit-workflows:migration-plan — Dependency Migration Planning

Plans major upgrades with impact analysis. Plan only — does not execute.

```
/shipkit-workflows:migration-plan rails 7.1 8.0
/shipkit-workflows:migration-plan react 18 19
/shipkit-workflows:migration-plan webpack vite
```

---

### /shipkit:spec — Spec a Non-Trivial Feature

Turn a feature idea into a durable, verified spec before building it — the **three questions**,
written to `.shipkit/specs/<feature-slug>/`. This is the forward-looking half of the knowledge
layer: `PROJECT_MAP.md` says what exists; a spec says what you're about to build.

```
/shipkit:spec checkout-redesign            # run all three questions end-to-end
/shipkit:spec checkout-redesign design     # regenerate design.md only
```

The three questions:
1. **What are we building?** → `spec.md`, requirements in EARS (`When X, the system shall Y`).
2. **How should it work?** → `design.md`, the approach written as five-part decision records.
3. **How will we know it's done?** → acceptance criteria as tests, and `tasks.md` (each task cites
   its requirement).

Runs inline with an approval gate after requirements and native Plan Mode before tasks. Spec
**non-trivial** work only — a typo or one-liner doesn't get a spec. See the *Spec-Driven
Development* section below for the full picture.

---

### /shipkit:decide — Capture a Decision Record

Record a project-wide decision as a durable, five-part artifact in `.shipkit/decisions/`.

```
/shipkit:decide "Paddle over Stripe"
/shipkit:decide "monolith over microservices"
```

The five parts: **Context · Alternatives (≥2 real) · Case for · Case against · Decision +
falsifiability clause**. The falsifiability clause must be concrete — "we would reverse this if
p99 latency exceeds 200ms", not "if it turns out wrong" — because that's what lets `grandfather`
later answer *"is this decision now falsified?"*.

**A decision can check itself.** When the condition can be measured from the repository, the
record carries one more optional line, which `/shipkit:decide` asks for:

```markdown
**Falsifiability.** We would reverse this if the routes file passes 500 lines.
**Fired-if.** `test "$(wc -l < config/routes.rb)" -gt 500`
```

The command exits 0 once the condition has come true (it *is* the condition, so it composes
straight from the sentence). When it cannot be measured from the repository — users, latency,
cost — write `**Fired-if.** manual`. Then:

```sh
sh "<plugin root>/scripts/decision-check.sh" .          # list every command; runs nothing
sh "<plugin root>/scripts/decision-check.sh" . --run    # FIRED / HOLDS / MANUAL / ERROR per record
```

Listing is the default. The commands come from the repository you point it at, so read them
before using `--run` in one you do not trust; nothing runs them from a hook. The elders show
the list for any project and run it only for one in your registry; `/shipkit:ship` runs it as
its eighth step — a `FIRED` decision is `NOT READY` until you write a superseding record or
say to proceed.

Use this for **project-wide** decisions not tied to one feature. Feature-scoped decisions belong
inline in that spec's `design.md` (via `/shipkit:spec`). Capture real forks only — a decision
with one option isn't a decision.

---

## Spec-Driven Development

Shipkit extends the knowledge layer *forward in time*. `PROJECT_MAP.md` is the backward-looking
index (what exists, where); **specs** and **decision records** capture what you're building next
and *why* — as durable, verified artifacts the elders read.

Everything lives under one root, **`.shipkit/`**, so a human always knows where to look and
`grandfather`/`eve`/MemPalace share one canonical place to reference:

```
.shipkit/
  specs/<feature-slug>/
    spec.md      # WHAT — requirements (EARS), plus a status and the paths it covers
    design.md    # HOW — approach, as decision records
    tasks.md     # STEPS — ordered, each citing its requirement and naming its files
  decisions/
    NNNN-<slug>.md   # project-wide decision records (the "why" log)
```

### The three questions (always-on)

Two always-on rules drive this without any command:

- **`spec-driven`** — on non-trivial feature work, answer *what are we building* (EARS
  requirements), *how should it work* (design), *how will we know it's done* (tests, TDD/BDD-first).
  Trivial work is exempt — it never specs a typo.
- **`decisions`** — when a real choice is made (≥2 alternatives), capture it in five parts:
  **Context · Alternatives · Case for · Case against · Decision + falsifiability clause.**

The **falsifiability clause** is the key idea: a concrete "I would reverse this if ___" (a metric,
event, or threshold — never a vague hedge). It makes decisions *queryable for staleness* — ask
`grandfather` *"are any past decisions now falsified?"* and it checks each clause against current
reality. A hollow clause is treated as a bug.

### A spec is a contract a script checks

Since 3.3 a spec is not only read, it is checked. Three small conventions make that possible:

- **Status and paths.** Under its acceptance stamp, `spec.md` carries `> Status:` — `draft`,
  `open`, `shipped` or `dropped` — and `> Paths:`, the files or folders the feature lives in.
- **Tests cite requirements.** A test names the requirement it proves as `<slug>/REQ-N`
  (for example `refunds/REQ-3`) in a comment or its name. A requirement that is prose only is
  excused by ending it with `[untested: <reason>]`.
- **Tasks name their files.** Each task lists `Files`, `Test`, `After` and `Done when`. Two
  tasks that list the same file must be ordered by `After` (directly or through a chain), so
  tasks that share nothing can be handed to agents at the same time.

Then one script reads all of it:

```sh
sh "<plugin root>/scripts/spec-check.sh" .            # every spec
sh "<plugin root>/scripts/spec-check.sh" . refunds    # one spec
```

| Line | Meaning |
|------|---------|
| `MISSING-TASK refunds REQ-2` | no task mentions the requirement |
| `MISSING-TEST refunds REQ-2` | the spec is `shipped` and no test cites `refunds/REQ-2` |
| `MISSING-FIELD refunds T3 Test` | a task lacks one of its four lines |
| `BAD-AFTER refunds T3 T9` | `After` names a task that does not exist |
| `CONFLICT refunds T1 T2 app/refunds.py` | two tasks share a file and are not ordered |
| `CYCLE refunds T2` | the task's `After` lines lead back to itself |
| `WAIVED refunds REQ-4` | excused with `[untested: …]` — information, not a gap |
| `SKIPPED refunds (draft)` | drafts and dropped specs are not checked |

It exits 1 when there is a gap, so it can run in CI. It checks that a citation *exists*, not
that the test passes — running the tests is still your job. `/shipkit:spec` writes specs in
this format and runs the check itself. A spec written before 3.3, with none of the new lines,
is treated as `open` and is not asked for the task format.

### Handing a task to an agent

A task in the checked format already says everything an agent needs, so the brief is built by
a script and the result is checked by one:

```sh
git rev-parse HEAD                                              # note where the work starts
sh "<plugin root>/scripts/brief.sh" . refunds T3                # the brief — hand it over unchanged
sh "<plugin root>/scripts/brief-verify.sh" . refunds T3 <sha>   # afterwards: which files changed?
```

- The brief carries the goal, the requirement **word for word**, the only files the task may
  edit, the test and the `Done when` command, the tasks already done, the decisions that bind
  it, what is out of scope, and a fixed form to report back in. Add context below it if the
  agent needs more; never replace part of it.
- `brief-verify.sh` prints `OUTSIDE <file>` for anything changed that the task did not list,
  and exits 1. Then run the task's `Done when` command yourself — the agent's report is a
  claim, not proof.
- Tasks with no unfinished predecessor can run at the same time, each in its own git worktree.
- Match the team to the work: no agent for a trivial change, one for one task, the elders for
  a research question.

### How it ties into the elders

- `grandfather` reads `.shipkit/decisions/` and specs to answer *why is X built this way?*,
  *what are we building next?*, and *which decisions are now falsified?* — preferring these
  verified records over `git log` or MemPalace recall.
- `eve` greps `.shipkit/decisions/` across the portfolio (*"where did we decide against
  microservices, and are those reasons still true?"*).
- `archivist` links active specs and decisions from `PROJECT_MAP.md`, so the map is the front door.

### Freshness

A `SessionStart` hook nudges once per **open** spec whose code has drifted ≥15 commits past its
acceptance SHA (override with `SHIPKIT_SPEC_STALE_COMMITS`) — the same closed-loop treatment the
map already gets. With a `Paths` line, only commits that touch those paths count. Silent when
fresh, and silent for `shipped`, `dropped` and `draft` specs.

### The weekly digest

One page across every project in your registry, from files already on disk, with no model:

```sh
sh "<plugin root>/scripts/portfolio-digest.sh"                 # ~/.claude/shipkit/digests/<date>.md
sh "<plugin root>/scripts/portfolio-digest.sh" --run-checks    # also run the Fired-if commands
```

Each project gets seven lines — top goal and review date, open specs with task progress, spec
gaps, decisions, escapes in the last 30 days by cause, map age in commits, uncommitted files
and unpushed commits — and a project whose path has moved gets `path not found`. The registry
and the output directory live under `SHIPKIT_HOME` (default `~/.claude/shipkit`). The session
briefing adds one line when the newest digest is more than seven days old. `/shipkit:ask --all
digest` runs the script and has `eve` read the page against `studio.md`.

**Scheduling it is optional.** The plugin root is in `~/.claude/shipkit/plugin-root`; put the
command in whichever scheduler your machine has. With `cron`, Monday at 08:00:

```cron
0 8 * * 1  sh "$(cat "$HOME/.claude/shipkit/plugin-root")/scripts/portfolio-digest.sh" >> "$HOME/.claude/shipkit/digests/cron.log" 2>&1
```

With `launchd` on macOS, save this as `~/Library/LaunchAgents/dev.shipkit.digest.plist` and
run `launchctl load ~/Library/LaunchAgents/dev.shipkit.digest.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>dev.shipkit.digest</string>
  <key>ProgramArguments</key><array>
    <string>/bin/sh</string><string>-c</string>
    <string>sh "$(cat "$HOME/.claude/shipkit/plugin-root")/scripts/portfolio-digest.sh"</string>
  </array>
  <key>StartCalendarInterval</key><dict><key>Weekday</key><integer>1</integer><key>Hour</key><integer>8</integer></dict>
</dict></plist>
```

A laptop that is asleep at 08:00 gets no digest that week; `launchd` runs a missed job at the
next wake, `cron` does not. The briefing's "newest is N days old" line is the backstop.

**Could a scheduled cloud agent do this instead?** Checked against the Claude Code routines
documentation (`code.claude.com/docs/en/routines`) on 2026-10-06: a routine runs on Anthropic's
cloud, clones the GitHub repositories you select fresh on every run, and uses the skills
committed to those repositories — not your installed plugins, and nothing from your home
directory. The digest needs `~/.claude/shipkit/project-registry.md` and every registered
project on disk, including ones that are not on GitHub, so a routine cannot produce it as
built. It could run a copy of the script committed to one repository against the repositories
it clones, which is a different, GitHub-only tool; nothing in shipkit depends on it (decision
A7, recorded in `.shipkit/specs/decisions-and-digest/design.md`).

---

## Memory

Shipkit keeps three kinds of durable, *verified* knowledge and leaves the rest to Claude Code:

| Kind | Where | Who maintains it |
|------|-------|------------------|
| Structure — what exists and where | `PROJECT_MAP.md` | `archivist`, via `/shipkit:map` |
| Intent and why — specs and decision records | `.shipkit/specs/`, `.shipkit/decisions/` | you, via `/shipkit:spec` and `/shipkit:decide` |
| Conversation history (optional) | MemPalace | `/shipkit:connect-memory` |

Corrections and preferences ("use factory_bot, not fixtures") belong in Claude Code's own
per-project memory or, when they are real conventions, in a rule via `/shipkit:update-rules`.
Shipkit ≤ 2.8 kept a `.claude/lessons.md` for this; it is retired. If your project still has
one, Claude reads it at session start and offers to migrate its entries into rules — then delete
it. The elder agents deliberately carry no private memory of their own: the map, the registry
and `.shipkit/` *are* their memory, and every one of them is a file you can read and check.

---

## Agents

Agents are used automatically by skills, or you can reference them in prompts.

### grandfather

Single-project elder. Answers "how/where/why" questions about the current project by reading its
`PROJECT_MAP.md`, verifying the specific claim against live source, and (if MemPalace is installed)
querying decision history. Returns a tight, cited answer so your main context stays thin.

Used by `/shipkit:ask`. See [The Project Elders](#the-project-elders).

### eve

Cross-project elder (named for the common ancestor of the whole portfolio). Answers questions across
**all** registered projects by reading `~/.claude/shipkit/project-registry.md` and each project's map.

Used by `/shipkit:ask --all`.

### archivist

Builds and refreshes the `PROJECT_MAP.md` that grandfather and eve read. Detects the stack, maps
structure and data model, reconstructs evolution from git, collects gotchas, and verifies every cited
path exists before writing. Writes only that one file.

Used by `/shipkit:map`.

### test-analyzer

Diagnoses test failures. Checks for state leakage, timing issues, environment differences, dependency changes, and order-dependent failures.

Reference it directly when tests fail: "use the test-analyzer agent to diagnose this flaky test."

### codebase-explorer

Read-only exploration agent. Traces call chains, maps directories, analyzes schemas, finds patterns, identifies hotspots.

Used by `/shipkit-workflows:qa` and plan-mode research for heavy reading. Or reference directly: "use the codebase-explorer agent to map the services directory."

### tracer

Deep, single-feature traces: follows one call chain from trigger through every layer to the
datastore and back, reads the tests for the edge cases, and returns a `file:line`-cited
walkthrough. Sonnet, 40 turns, up to 40 files — the budget a real trace needs, which the
explorer's bounded budget is not meant for.

Used by `/shipkit:walkthrough`. Or reference directly: "use the tracer agent to trace the checkout flow."

All three: read-only, report confidence levels, keep no private memory between runs.

---

## Knowledge Bases

Shipped as skills with `user-invocable: false`: their one-line description is always known to
Claude, the body loads only when a skill or rule points at them or Claude reaches for one. Not
always in context. Since 4.0 the core plugins ship none; two come with the Rails overlay.

### Reviewing code — use the built-in

Claude Code's `/code-review` covers the general lenses (clean code, duplication, idioms,
performance, error handling), so shipkit's `code-review-standards` knowledge base was removed in
4.0 (`ui-ux-standards` went in 3.0 for the same reason; the `ui-ux` **path-scoped rule stays**
with its WCAG 2.2 AA baseline). One lens the built-in does not name, kept here:

**Reviewing code an AI wrote.** Look for the failure modes of generated code rather than of
tired people: a plausible API that does not exist (a method, option or flag the library never
had — check the docs, not the shape); a test that asserts what the code does rather than what
the requirement says (compare it with the `REQ-N` it cites, not with the implementation);
defensive scaffolding for states that cannot occur (`if x is None` on a value the caller
guarantees); a comment that describes intent the code does not carry out; a "fix" that
silences the symptom (a broadened `except`, a retry, a default) where the root cause was one
line away; and three near-copies of a helper where the second one should have been a call.
Severity follows the requirement: a `NOT MET` requirement is a blocker whatever the code's
quality; a style finding on a `MET` one is a note.

### Stack-specific (installed via /setup)

- **code-review-standards-rails** — ActiveRecord performance, Sidekiq best practices, Hotwire consistency; applied alongside the built-in `/code-review`
- **ai-rails** — RubyLLM patterns for chat, embeddings, streaming, tool use, testing

---

## Path-Scoped Rules

Installed into `.claude/rules/shipkit/` by `/shipkit:setup` (Claude Code only loads rules from a
project, never from a plugin). After that they auto-load when you edit matching files — no
action needed. Re-run `/shipkit:setup` after a plugin upgrade to refresh the copies.

Since 4.0 each rule holds only the lines that name a trap the model gets wrong unprompted; the
defaults it already follows were trimmed (the audit is `docs/design/trim-audit-4.0.md`). The
`security` rule was removed: the always-on `shipkit.md` and the commit guard keep the one line
that bites, and the rest was default behaviour.

| Rule | When It Loads | What It Enforces |
|------|--------------|-----------------|
| `testing` | Test files (`*_test.*`, `*_spec.*`) | Use the factories and fixtures that already exist; match the project's framework |
| `migrations` | Database migrations | Batched backfills on large tables; `CONCURRENTLY` for an index on a busy table |
| `dependencies` | Dependency files (Gemfile, package.json, etc.) | No `*` or unpinned version; never a bare `bundle update` / `npm update` |
| `monorepo` | Workspace manifests (`pnpm-workspace.yaml`, `lerna.json`, `turbo.json`, `nx.json`) | A shared package's change runs its consumers' tests; `--filter` / `--scope` |
| `ui-ux` | UI files (web + mobile) | The WCAG 2.2 AA baseline: contrast ratios, target size, reduced motion, errors not by colour alone, no layout shift |

### Always-on rules

These are not path-scoped — they apply to the work itself, not to a file type. The session
hook injects them (together with `shipkit.md`, the workflow + commit-discipline rule) at the
start of every session; once `/shipkit:setup` has installed them as files the hook stops
injecting and they load from `.claude/rules/shipkit/` like any project rule.

| Rule | Applies To | What It Enforces |
|------|-----------|-----------------|
| `spec-driven` | Non-trivial feature work | The three questions (what/how/done), EARS requirements, TDD/BDD-first — see *Spec-Driven Development* |
| `decisions` | Any non-trivial choice (≥2 alternatives) | The five-part decision record with a concrete falsifiability clause |

### Stack-specific rules (installed via /setup)

| Rule | Stack | What It Enforces |
|------|-------|-----------------|
| `rails` | Rails | `find_each` not `all.each`; over 100 ms goes to a job; never `update_column` |
| `gemfile` | Rails | `~>` constraints, `bundle audit`, `ruby_llm` for AI features, grep before removing a gem |
| `react` | React | Only the host-app rules (below); the file says so, and a standalone SPA skips them |
| `package-json` | React | Frozen-lockfile installs, never hand-edit a lockfile, one package manager from the lockfile |
| `pyproject` | Python | Flexible constraints in `pyproject.toml`, exact pins for deployment, `pip-audit`, the package manager from the lockfile |
| `go-mod` | Go | `go get @latest` then `go mod tidy`, `govulncheck`, vendor only if `vendor/` exists |
| `mix-deps` | Elixir | `~>` constraints, `mix hex.audit` / `mix deps.audit`, `only: [:dev, :test], runtime: false` |

The language-convention rules (`python`, `go`, `elixir`) were removed in 4.0: every line was a
default the model already follows.

Add-on overlays install alongside their base — a Rails app with Turbo installs both `rails` and
`hotwire`:

| Rule | Add-on (requires) | What It Enforces |
|------|-------------------|-----------------|
| `hotwire` | Hotwire (Rails) | Frames for scoped navigation, Streams only for multi-region or broadcast updates; Stimulus values/targets/outlets over `querySelector`; `disconnect()` cleanup because Turbo caches pages; stable ids for morphing; system tests for every Turbo flow |
| `react` | React (Rails/Elixir) | Inertia props as the API contract, routing stays in Rails, server-owned auth and flash, asset build before the suite |
| `liveview` | LiveView (Elixir) | `mount/3` runs twice (guard with `connected?/1`), `stream/4` for collections, `handle_params/3` for URL state, scoped PubSub topics, function components over nested LiveViews, test the disconnected render too |
| `jobs` | Oban (Elixir) | Idempotent `perform/1`, IDs as args, `unique:` deduplication, `{:cancel, _}` vs `{:error, _}`, queues by priority |
| `notebooks` | ML (Python) | Exploration only, promote reused code to modules, clear outputs, no secrets in cells |
| `experiments` | ML (Python) | Seeds set and logged, runs recorded with config + git SHA, explicit device, never evaluate on training data, metrics saved beside weights |
| `data` | ML (Python) | Raw data and weights out of git, documented provenance and licence, pinned dataset versions, schema checks on load |

---

## Common Workflows

Four end-to-end playbooks cover most of how you'll use shipkit: **starting a new repo**,
**taking over a legacy one**, **asking the elders**, and **one feature from idea to shipped**.
Each step says what you do, what it gives you, and what comes next. Shorter recipes follow at
the end.

---

### Playbook 1 — Starting a new repo (greenfield)

A fresh repo is where shipkit's spec-driven flow shines most: you have no existing code to work
around, so a spec becomes the single source of truth and gives the AI no room to invent. Build
**spec-first**.

**1. Configure shipkit for the project.**
```
/shipkit:setup
```
Pick your stack and a workflow style (`test-first` is the sensible default; `strict-tdd` if you
want the iron law; `lightweight` if you don't). **What you get:** a tailored `CLAUDE.md`, the
always-on rules (spec-driven, decisions, commit discipline) now in effect, and stack-specific
skills/rules installed. One-time per repo.

**2. Spec the first feature before writing code.**
```
/shipkit:spec user-signup
```
This runs the three questions — *what are we building* (requirements in EARS), *how should it
work* (design, written as decision records), *how will we know it's done* (acceptance criteria as
tests). **What you get:** `.shipkit/specs/user-signup/{spec,design,tasks.md}`, an approval gate on
the requirements, and native Plan Mode before the tasks are locked. **Why first:** the spec is the
artifact you'll build against — and the one the elders read later to explain *what you're
building*.

**3. Build task by task.**
The `tasks.md` is ordered and each task cites its requirement. Work through them — the always-on
rules fire automatically (test-first per your chosen style, atomic commits, and any real
architectural fork prompts a decision record). **What you get:** code that traces
requirement → task → test, with the *why* captured as you go. No extra commands needed; the
discipline is automatic.

**4. Record project-wide decisions as they come up.**
```
/shipkit:decide "Postgres over SQLite"
```
When you make a choice that isn't tied to one feature (a datastore, a deploy target, an auth
strategy), capture it. **What you get:** a five-part record in `.shipkit/decisions/` with a
concrete falsifiability clause — so a year from now you (or grandfather) can answer *why* and
*"is this still the right call?"*.

**5. Optional: map the repo once it has a shape, and register it.**
```
/shipkit:map --register
```
**What you get:** a verified `PROJECT_MAP.md` and a row in your cross-project registry, so `eve`
sees this repo in portfolio sweeps. The elders answer without a map — measured on a 224-file
project, a map changed neither the answers nor the tool-call count (decision 0001,
`docs/design/eval-results-4.1.md`) — so build one for `eve`, or when the commit history is too
thin to explain how the project evolved. **When:** once there's real structure, not on day one.

**From here:** ask the elders when you need to understand something (Playbook 3), `/shipkit:map
refresh` after big changes, and repeat steps 2–4 per feature.

---

### Playbook 2 — Taking over a legacy / inherited repo

The opposite starting point: lots of existing code, little context, and the standard warning is
*don't retro-spec the whole thing*. **Understand first, then spec only what you change.**

**1. Get oriented with an audit.**
```
/shipkit-workflows:legacy-audit
```
**What you get:** a modernization assessment — dependency age, dead code, complexity hotspots,
test-coverage gaps. This tells you what you're walking into before you touch anything.

**2. Optional: an index for you — and a registry row for `eve`.**
```
/shipkit:map --register
```
**What you get:** a verified `PROJECT_MAP.md` — architecture, where-things-live, data model,
evolution, gotchas — which *you* can read in five minutes on an unfamiliar codebase. The elders
do not need it: on a 224-file test they answered as well and as fast from the source alone
(decision 0001). Skip it if you only want to ask questions; build it for your own orientation,
for `eve`'s portfolio view, or when the commit log is too thin to carry the project's history.

**3. Understand before you change.**
```
/shipkit:ask how does authentication flow through this app?   # grandfather, cited answer
/shipkit:walkthrough checkout                                  # trace one path step by step
/shipkit:explain-system                                        # why is it built this way?
```
**What you get:** grandfather traces the flow and returns a cited answer without dumping the code
into your session; `/shipkit:walkthrough` traces one path step by step; `/shipkit:explain-system`
returns the *why* (decisions, trade-offs). **Why:** on legacy code, the reason something exists is
usually the thing you're missing — and the thing most likely to bite you if you change it blind.

**4. When you add a feature, spec only the delta.**
```
/shipkit:spec add-sso
```
**What you get:** a spec for the *new* behavior on top of the old code — lock what exists, spec the
change. Don't spec the whole legacy surface; spec the part you're adding or reworking. This is
where spec-driven development pays off in brownfield without drowning you in ceremony.

**5. Plan any big upgrade before executing it.**
```
/shipkit-workflows:migration-plan rails 6.1 7.0
```
**What you get:** an impact analysis and a step-by-step execution plan for a major/breaking
upgrade — before you start, not halfway through.

**From here:** as you learn non-obvious things, turn the real conventions into rules with
`/shipkit:update-rules`; refresh the map after big changes; capture the decisions you make with
`/shipkit:decide` so the next person (or you in six months) inherits the *why* you didn't have.

---

### Playbook 3 — Asking the elders (when & why)

The elders exist to answer questions **without polluting your main context** — the subagent reads
the files, you get back only the cited answer. Reach for them whenever the answer would otherwise
cost you a dozen file reads in your working session.

**grandfather — one project.** Use it for:

| You want to… | Ask |
|--------------|-----|
| Understand how something works | `/shipkit:ask how does locale fallback work here?` |
| Find where something lives | `/shipkit:ask where are background jobs defined?` |
| Know *why* a decision was made | `/shipkit:ask why did we choose Paddle over Stripe?` |
| Judge whether a change is safe | `/shipkit:ask is it safe to drop the legacy_token column?` |
| Check if a past decision still holds | `/shipkit:ask are any of our decisions now falsified?` |

**eve — across all your registered projects.** Use it for the 360° view:

| You want to… | Ask |
|--------------|-----|
| Find a pattern across the portfolio | `/shipkit:ask --all which apps deploy to Hetzner vs AWS?` |
| Locate every place you do X | `/shipkit:ask --all everywhere I integrate Stripe` |
| Sweep versions for an upgrade/CVE | `/shipkit:ask --all matrix rails` |
| Find duplication worth consolidating | `/shipkit:ask --all consolidate` |
| See what's in flight | `/shipkit:ask --all which projects have an open spec?` |

**When *not* to use them:** mid-edit, when you need one fact to keep typing — just read the file;
a subagent round-trip is slower. And they're read-only: they inform, they don't edit. Get the
answer, then act in your main session.

**Why they stay trustworthy:** the map is an *index*, not the last word. When it disagrees with
live source, the elders trust **source** and flag the drift — so a stale map yields a correction,
not a confident wrong answer. Refresh with `/shipkit:map refresh` when you see a drift flag or the
session-start hook nudges you.

---

### Playbook 4 — one feature from idea to shipped

The nine steps of the loop, run for real on 2026-10-06 against `evals/fixtures/sample-app`
(a nine-file Python order service with a `charge` function and no refunds), with `sonnet`,
headless. Every file below is what the step wrote, cut for length and nothing else; the one
thing changed is the path, shown as `~/code/shop`. Two steps did not go to plan, and those are
the most useful part.

**Step 1 — Product.** `/shipkit:product` (the users, goals, non-goals and constraints given in
the request, since the run could not ask). Wrote `.shipkit/product.md`:

```markdown
# Product: sample-app

> Product reviewed on 2026-10-06.

## One line
A small order service that takes orders, adds tax and charges the card, for owners of small online shops.

## Goals this quarter
- Cut failed charges — metric: share of all charges that fail; target: under 2%; by: 2026-12-31
- Ship refunds — metric: share of refunds needing no manual step; target: 95%; by: 2026-11-15

## Non-goals
- No multi-currency support.
- No storefront or cart.
```

**Step 2 — Intake.** `/shipkit:intake Add refunds: a charged order can be refunded in full or
in part through the payment gateway.` The first pass wrote nothing: it found no conflict,
asked `grandfather` what the code does today, named the goal it serves without asking, and
stopped with four questions — the first of them a real finding:

> **Charge data:** Refunds need the receipt or charge id and the charged amount saved on the
> order, and today neither is saved (`app/billing.py:27-32`). Should the intake count recording
> them at charge time as part of this feature?

A second pass with the answers wrote `.shipkit/specs/refunds/intake.md`:

```markdown
## Serves goal
Ship refunds — metric: share of refunds needing no manual step; target: 95%; by: 2026-11-15

## Conflicts found
None. No non-goal in `.shipkit/product.md` is touched, and there are no open specs or decision records.

## Answers
- What happens when a refund exceeds the original charge? It is refused.
- Are partial refunds allowed? Yes, one per order.
- Where does the gateway's refund number go? It is stored on the order.

## Out of scope
- Refund history and statements.
- Multiple partial refunds on one order.
```

**Step 3 — Spec.** `/shipkit:spec refunds` (every approval gate treated as approved). Wrote
`spec.md` with nine requirements, `design.md` with two decision records (each ending
`**Fired-if.** manual`), and `tasks.md`; then ran `spec-check.sh`, which found no gap.

```markdown
> Spec accepted at commit `790c2f5` on master.
> Status: open
> Paths: app/billing.py, tests/test_refunds.py

- **REQ-1.** When an order is charged through `charge_order`, the system shall store the gateway's receipt number and the charged amount in cents on the order.
- **REQ-3.** When a refund of an amount no larger than the charged amount is requested for a charged order, the system shall ask the gateway to refund that amount against the charge receipt and store the gateway's refund number on the order.
- **REQ-5.** If the requested refund amount is larger than the charged amount, then the system shall refuse the refund with `RefundRefused` without calling the gateway.
```

```markdown
- [ ] **T1** Record the charge on the order → REQ-1, REQ-2
  - Files: app/billing.py, tests/test_refunds.py
  - Test: tests/test_refunds.py::ChargeOrderTest::test_a_charge_is_stored_on_the_order
  - After: none
  - Done when: `python3 -m unittest discover -s tests -p "test_refunds.py"` → all pass
- [ ] **T2** Refund a charged order, in full or in part, and refuse bad refunds → REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9
  - Files: app/billing.py, tests/test_refunds.py
  - After: T1
```

The intake's finding became the spec's first assumption: "scope is widened to the charge flow
… a new `charge_order` stores the receipt and amount on the order."

**Step 4 — Brief.** `sh "<plugin root>/scripts/brief.sh" . refunds T1` — no model. Printed:

```markdown
# Brief: refunds / T1 — Record the charge on the order

## Requirement
- **REQ-1.** When an order is charged through `charge_order`, the system shall store the gateway's receipt number and the charged amount in cents on the order.
- **REQ-2.** If the gateway fails the charge in `charge_order`, then the system shall raise `ChargeFailed` and leave the order unchanged.

## You may edit
- app/billing.py
- tests/test_refunds.py
Nothing else. If the task cannot be done inside these files, stop and report blocked.

## Prove it with
- Test: tests/test_refunds.py::ChargeOrderTest::test_a_charge_is_stored_on_the_order
- Done when: `python3 -m unittest discover -s tests -p "test_refunds.py"` → all pass

## Report back in exactly this form
RESULT: done | blocked
CHANGED: <files>
TEST: <command> → <last lines of output>
NOT VERIFIED: <anything you did not check, or "nothing">
DEVIATIONS: <anything you did differently from this brief, or "none">
```

**Step 5 — Build.** `claude -p "$(sh "<plugin root>/scripts/brief.sh" . refunds T1)"` — the
brief handed to a fresh session unchanged. It wrote `charge_order` in `app/billing.py` and
`tests/test_refunds.py`, and reported in the brief's form:

```text
RESULT: done
CHANGED: app/billing.py, tests/test_refunds.py
TEST: `python3 -m unittest discover -s tests -p "test_refunds.py"` → Ran 2 tests in 0.000s, OK.
NOT VERIFIED: nothing. The new tests failed with an import error before I added `charge_order`, then passed after.
DEVIATIONS: I added a second test, `test_a_failed_charge_raises_and_leaves_the_order_unchanged`, which covers REQ-2.
```

**Step 6 — Review.** `sh "<plugin root>/scripts/brief-verify.sh" . refunds T1 89e540d`, then
the task's `Done when`. The first did not go to plan:

```text
OUTSIDE app/__pycache__/billing.cpython-314.pyc
OUTSIDE tests/__pycache__/test_refunds.cpython-314.pyc
brief-verify: 9 file(s) changed, 7 outside the Files of refunds / T1
```

Seven files outside the task — all `__pycache__`, left by the test run, because the fixture
has no `.gitignore`. The agent stayed inside its two files; the project was missing a line.
That is the kind of thing the check is for, and the fix is a `.gitignore`, not a conversation
with the agent. The `Done when` passed: `Ran 7 tests … OK`.

**Step 7 — Ship.** `/shipkit:ship refunds 89e540d`, with T2 deliberately not built yet. Wrote
`.shipkit/releases/2026-10-06-refunds.md`:

```markdown
NOT READY

| # | Step | Result | Reason |
|---|------|--------|--------|
| 1 | Spec check, as shipped | FAIL | exit 1, 7 gaps: REQ-3 to REQ-9 have no test |
| 2 | Tests | PASS | `python3 -m unittest discover -s tests` → exit 0 (7 tests) |
| 3 | Tasks ticked | FAIL | 2 tasks not ticked: T1, T2 |
| 4 | Independent review | FAIL | VERDICT: FAIL (2 MET, 7 NOT MET) |
| 5 | Migration rollback | PASS | no migration in the diff |
| 6 | Decisions | PASS | 2 decisions, reversal conditions concrete |
| 7 | Clean tree | PASS | nothing uncommitted |
| 8 | Decisions fired | PASS | no FIRED line; 2 MANUAL |

## To fix before shipping
- Step 1 and 4: implement T2 (`refund_order`, `RefundRefused`, `RefundFailed`, gateway refund call) and write the tests for REQ-3 to REQ-9, each citing `refunds/REQ-N`.
- Step 3: tick T1 (its code and REQ-1/REQ-2 tests exist) and T2 in `.shipkit/specs/refunds/tasks.md` once done.
- Note from review: `__pycache__/*.pyc` files are committed in the diff. Remove them from git and add a `.gitignore` entry.
```

Three steps failed for the one reason that was true — half the feature is not built — and the
reviewer, told only the slug and the base ref, found the same `__pycache__` problem step 6 had.
A `READY` here would have been the bug.

**Step 8 — Escape.** `/shipkit:escape A refund of 25.00 was paid out on an order charged 20.00;
the gateway's weekly statement did not match our orders.` Wrote
`.shipkit/escapes/0001-refund-larger-than-charge.md` and added **T3** to
`tasks.md`, a test citing `refunds/REQ-5` that fails now:

```markdown
## Cause
`requirement right, no test` — a spec covers this code (`refunds`, Paths include `app/billing.py`), and REQ-5 says exactly what should have happened: a refund larger than the charged amount is refused with `RefundRefused` without calling the gateway. So it is not `requirement missing` or `requirement wrong`. No test cites `refunds/REQ-5` (`spec-check` reported `MISSING-TEST refunds REQ-5` in the ship report of 2026-10-06), so it is not `test existed but was wrong`.

## Fix
No requirement change; REQ-5 stands. `Status` stays `open`. Task **T3** carries a test that cites `refunds/REQ-5`, uses a 2500-cent refund on a 2000-cent charge, and fails now.
```

It also said what it could not know: no code in the repository pays refunds, so the payout
came from outside it, and the gateway statement should say where.

**Step 9 — Digest.** `/shipkit:ask --all digest`, with the project registered. `portfolio-digest.sh`
wrote `~/.claude/shipkit/digests/2026-10-06.md`:

```markdown
## shop — ~/code/shop

- Top goal: Cut failed charges — metric: share of all charges that fail; target: under 2%; by: 2026-12-31 (product reviewed on 2026-10-06)
- Open specs: refunds 0 of 3 tasks done, next T1
- Spec gaps: 0
- Decisions: 2 with a Fired-if line, 2 manual; commands not run (add --run-checks)
- Escapes (30 days): 1 — requirement right, no test 1
- Map: PROJECT_MAP.md, no readable stamp
- Git: 0 uncommitted file(s), no upstream
```

and `eve` answered from it and `studio.md`:

> **1. shop** — *Escape:* the digest says "Escapes (30 days): 1 — requirement right, no test 1".
> The requirement was correct, but nothing tested it, so a defect reached users. *Stalled spec:*
> "Open specs: refunds 0 of 3 tasks done, next T1". *Studio priority:* it matches priority 1,
> failed charges under 2% before the holiday season. **Suggested action this week:** add a test
> for the escaped requirement, then start refunds T1.

What the run took: ten headless `sonnet` sessions (the intake ran twice), four and a half
minutes end to end by the files' timestamps; the cost was not measured. What it left behind:
seven files under `.shipkit/` and one under `~/.claude/shipkit/digests/`, every one of them
readable by the next session, a script, or you.

---

### Shorter recipes

**Debugging a bug:**
```
/shipkit-workflows:debug  →  /shipkit-workflows:tdd bugfix  →  run the tests
```

**Pre-PR checklist:**
```
run the tests  →  /code-review (built-in)  →  /shipkit-workflows:humanize (for docs/PR description)
```

**Leaving shipkit:**
```
/shipkit:unsetup  →  /plugin uninstall shipkit@shipkit
```
(`/unsetup` restores your pre-shipkit `CLAUDE.md` and `.claude/`; it never touches `.shipkit/` —
your specs and decisions are yours to keep.)

---

## Tips

1. **Interactive skills pause at checkpoints.** Inline skills like `/shipkit-workflows:qa` stop between phases for your input — don't skip these. Research skills (`/shipkit:walkthrough`, `/shipkit:explain-system`) instead run end-to-end in a forked context and return their findings; any file they propose is only written after you approve it.

2. **Skills adapt to your stack.** You don't need to specify your test framework or language — skills detect it automatically.

3. **Arguments are optional.** Every skill has sensible defaults. Add arguments only to narrow scope.

4. **Path-scoped rules are automatic once installed.** `/shipkit:setup` copies them into `.claude/rules/shipkit/`; from then on they load when you edit matching files.

5. **Stack-specific content needs /setup.** Skills, agents, the hook and the always-on rules work instantly. Path-scoped rules and stack-specific skills (like `/new-feature` for Rails) require running `/shipkit:setup` first.

6. **Releasing shipkit itself** (for contributors): `./scripts/lint.sh` checks the files the plugin ships and runs in CI; `./scripts/smoke.sh` checks that Claude Code still behaves the way the plugin assumes (rules inject, the per-hook cap, the agent set, the install scripts) — it needs a logged-in `claude`, so run it locally before tagging.
