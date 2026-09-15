# Design: The Two-Plugin Split + Composable Stacks

Status: **proposal, decisions settled** · Written 2026-09-14 · Targets **2.10** (stacks, non-breaking) then **3.0** (split, breaking).
Resolves ROADMAP item 6 ("still open" since 2.0) and the methodology-scope question left after 2.9.

Settled by the author on 2026-09-14: the second plugin is named **`shipkit-workflows`**;
**`ui-ux` and `ai-feature` are cut** (not moved) because the official `frontend-design` plugin
and the built-in `claude-api` skill now cover them; **React is a frontend add-on** whose primary
pairing is Rails, not a standalone base stack; `humanize` stays.

Two coupled pieces of work:

1. **The split.** One repo, one marketplace, two plugins: `shipkit` (the knowledge layer) and
   `shipkit-workflows` (the opinionated methodology skills). Users install one or both. The
   core plugin's pitch becomes one sentence and its per-session context tax drops.
2. **Composable stacks.** `/shipkit:setup` stops assuming a project has exactly one stack, and
   the overlays grow to cover the stacks the author actually ships: Rails **+ Hotwire + React**,
   Phoenix **+ LiveView**, Python **+ ML/AI**. The elders learn the same signals.

They are ordered stacks-first on purpose: the stack work is non-breaking and delivers value now,
and doing it *before* the file move avoids rebasing overlay work across a directory rename.

---

## 1. What goes where

The rule for drawing the line: **core = anything that produces, reads, or installs knowledge
artifacts; workflows = anything that tells Claude how to do the work.** Not "how opinionated is
it" — that test is fuzzy and every reviewer draws it differently.

| | `shipkit` (core) | `shipkit-workflows` |
|---|---|---|
| **Pitch** | The project knowledge layer for Claude Code: a verified map per project, elder agents that answer from their own context, a cross-project registry, specs and decision records, and a session hook that keeps it all fresh. | Opinionated engineering workflows for Claude Code: QA, strict TDD, root-cause debugging, legacy audits, migration plans, prose humanizing, and a code-review knowledge base. |
| **Skills (12 / 7)** | `map`, `ask`, `setup`, `unsetup`, `connect-memory`, `commit`, `update-rules`, `context-audit`, `spec`, `decide`, `explain-system`, `walkthrough` | `qa`, `tdd`, `debug`, `humanize`, `legacy-audit`, `migration-plan`, and the KB `code-review-standards` |
| **Cut in 3.0** | — | `ui-ux` + its KB `ui-ux-standards` (→ the official `frontend-design` plugin; the path-scoped `ui-ux.md` rule keeps a WCAG 2.2 AA baseline), `ai-feature` (→ the built-in `claude-api` skill for the SDK; stack knowledge such as `ai-rails` stays in the overlays) |
| **Agents (5 / 1)** | `grandfather`, `eve`, `archivist`, `codebase-explorer`, `tracer` | `test-analyzer` |
| **Rules (9 / 0)** | all nine — the hook injects the 3 always-on, `setup` installs all 9 | none |
| **Hooks** | `SessionStart` (unchanged) | none |
| **Stacks** | all overlays (setup installs them) | none |
| **Scripts** | `session-start.sh`, `inject-rule.sh`, `install-rules.sh`, `install-stack.sh`, `lib-rules-sha.sh` | none |

Why each borderline item landed where it did:

- **`spec` / `decide` → core.** They write `.shipkit/` artifacts the elders read. 2.5 positioned
  them as "the knowledge layer looking forward"; moving them out would contradict that.
- **`explain-system` / `walkthrough` → core.** Read-only research that returns verified
  knowledge docs, on core agents (`codebase-explorer`, `tracer`). They are "ask", not "do".
- **`commit` → core.** The commit-discipline rule is always-on in core and `spec`/`decide`
  lean on it; the skill is thin.
- **Rules stay in core, all nine.** The alternative (move the "Default Coding Workflow" section
  and the six path-scoped rules to workflows) needs a second installer, a second hook so
  `setup` can find the workflows root, and a stale-stamp for two rule sets. That is a lot of
  machinery to move ~40 short lines that already have a `Workflow style: lightweight` escape
  hatch. Revisit only if core-only users say the rules are too much. Falsifiability: two
  independent reports that the core rules are "too opinionated" reverse this.
- **Stack overlays stay whole in core.** Their skills (`/new-feature`, `/release`, …) are
  workflow-ish, but they are installed *into the project* by `install-stack.sh`, cost no plugin
  context, and splitting an overlay across two roots means `setup` installing from two places.
  Not worth it. Follow-up option: an overlay may later declare `workflow-skills/` that setup
  installs only when workflows is present.
- **KBs go with their consumers.** `code-review-standards` is loaded by `/qa` and `/tdd` (and
  by the native `/code-review` when the user points at it), so it goes to workflows.
  `ui-ux-standards` loses its only skill consumer when `/ui-ux` is cut, so it is cut with it;
  the one thing the path-scoped `ui-ux.md` rule needs from it (the accessibility baseline)
  moves inline into the rule.
- **Why cut rather than move `ui-ux` and `ai-feature`.** Both now have a native or official
  equivalent that is maintained by someone else: `frontend-design` (official plugin) for UI
  work, and the built-in `claude-api` skill for the Anthropic SDK. Keeping them would repeat
  the 2.0 mistake of shipping what the platform ships. Same treatment as 2.0's five cuts:
  CHANGELOG pointers to the equivalents, `v2.9.0` pinnable.

### 1.1 The cross-plugin seams (all of them)

A grep of every reference from one half into the other finds **eight lines**. Each half must
work alone, so each seam becomes a soft reference ("if installed") or a fallback:

| File (half) | Reference into the other half | Change |
|---|---|---|
| `rules/shipkit.md:27,32` (core) | `strict-tdd` → "follow `/shipkit:tdd`" | "follow `/shipkit-workflows:tdd` if that plugin is installed; otherwise the iron law stated here: test first, watch it fail, minimal code, refactor." (Add the one-paragraph law so strict-tdd still means something core-only.) |
| `rules/ui-ux.md:55` (core) | "Load the `ui-ux-standards` skill" | Not a seam any more — the KB is cut. Replace the line with a ten-line WCAG 2.2 AA baseline (semantic structure, focus order, contrast, labels, keyboard reach, no layout shift) and a pointer to the `frontend-design` plugin for design direction. |
| `scripts/smoke.sh:66` (repo) | expects both KBs registered | Expect only `code-review-standards`, and run that check against the workflows plugin dir. |
| `skills/setup/SKILL.md:91,172,196` + `reference.md:24,37` (core) | mentions `/shipkit:tdd`, `code-review-standards`, `/qa` | Same soft wording; Phase 7 next-steps line becomes "with `shipkit-workflows` installed, try `/shipkit-workflows:qa`". |
| `agents/codebase-explorer.md:17` (core) | mentions `/qa` as a caller | Drop the caller list (it is descriptive, not load-bearing). |
| `skills/qa/SKILL.md:9,32` (workflows) | delegates research to `codebase-explorer` | "Delegate to `shipkit:codebase-explorer` if available, else the built-in `Explore` agent." |
| `skills/tdd/SKILL.md:16` (workflows) | "the default workflow is defined in `rules/shipkit.md`" | Make `tdd` self-contained (it already carries the iron law; drop the pointer). |

No plugin-to-plugin dependency mechanism is used — see §2.3.

---

## 2. Repository layout and the marketplace

### 2.1 Layout

```
shipkit/                                  ← the repo = the marketplace
├── .claude-plugin/marketplace.json       ← lists BOTH plugins
├── plugins/
│   ├── shipkit/                          ← core
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/  hooks/  rules/  scripts/  skills/  stacks/
│   └── shipkit-workflows/
│       ├── .claude-plugin/plugin.json
│       ├── agents/  skills/
├── scripts/lint.sh  lint.py  smoke.sh    ← repo-level, iterate both plugin roots
├── docs/  README.md  GUIDE.md  CHANGELOG.md  ROADMAP.md  LICENSE
└── .woodpecker.yml
```

`marketplace.json`:

```json
{
  "name": "shipkit",
  "owner": { "name": "AJ" },
  "metadata": { "description": "…", "version": "3.0.0" },
  "plugins": [
    { "name": "shipkit",           "source": "./plugins/shipkit",           "version": "3.0.0", "description": "12 skills, 5 agents, 9 rules …" },
    { "name": "shipkit-workflows", "source": "./plugins/shipkit-workflows", "version": "3.0.0", "description": "6 skills + 1 knowledge base, 1 agent …" }
  ]
}
```

Install becomes:

```
/plugin marketplace add https://github.com/AnjanJ/shipkit.git
/plugin install shipkit@shipkit                # the knowledge layer
/plugin install shipkit-workflows@shipkit      # optional: the methodology skills
```

Local testing: `claude --plugin-dir ~/code/shipkit/plugins/shipkit --plugin-dir ~/code/shipkit/plugins/shipkit-workflows`
(verify the flag repeats — see §2.4).

Alternative considered: keep core at the repo root (`"source": "./"`) and add `./workflows`.
Zero path churn, but the core plugin's cache copy would then contain the workflows tree, the
core `agents/` scan (recursive) must never see a stray `.md`, and the layout reads as
"core + an appendix" rather than two peers. Rejected: 3.0 is breaking anyway, so pay the churn once.

### 2.2 Versioning

Lockstep. Both `plugin.json` files and `metadata.version` carry the same version; one CHANGELOG
with a `### shipkit` / `### shipkit-workflows` subsection per release where they differ. The
lint already enforces "all versions equal"; it stays that way. Independent versions can come
later if the halves ever release on different cadences. Falsifiability: three consecutive
releases that touch only one half reverse this.

### 2.3 No hard dependency between the halves (even though the platform offers one)

Claude Code *does* document a `dependencies` array in `plugin.json`
(https://code.claude.com/docs/en/plugin-dependencies), so `shipkit-workflows` *could* declare
`"dependencies": ["shipkit"]`. Recommendation: **do not, in 3.0.** Each half is complete on
its own (§1.1) at the cost of eight soft-worded lines, which is cheaper than owning the
dependency's install-time semantics (auto-install? version pinning? behaviour when core is
disabled but installed?) before they have been nonce-tested. Falsifiability: if a user reports
`/shipkit-workflows:qa` degrading noticeably without `codebase-explorer`, add the dependency.

There is no documented way for one plugin to find another's files at runtime
(`${CLAUDE_PLUGIN_ROOT}` is per plugin). If detection is ever needed, the cheapest reliable
signal is the core hook's `~/.claude/shipkit/plugin-root` file (written every session) plus a
mirror `workflows-root` from a one-line `SessionStart` hook in workflows. Not built in 3.0.

### 2.4 Platform facts — verified in the docs, to nonce-test before building (like 2.8/2.9)

Verified against the official docs on 2026-09-14 (plugin-marketplaces, discover-plugins, hooks,
plugins, plugin-dependencies pages):

- ✅ A marketplace lists several plugins; `source` may be a relative subdirectory path
  (`"./plugins/my-plugin"`); each subdirectory carries its own `.claude-plugin/plugin.json`.
- ✅ Skills are namespaced by plugin name (`/shipkit:map`, `/shipkit-workflows:qa`).
- ✅ `SessionStart` hooks from every enabled plugin fire in the same session (only core ships one).
- ✅ `/plugin install <name>@<marketplace>` is per plugin — install one, both, or neither.
- ✅ `disable-model-invocation: true` is documented. `user-invocable: false` (which the two
  knowledge bases already rely on since 2.8) is **not** documented; it is covered by the
  smoke test, which stays the guard.

Still to nonce-test in a real session (docs and behaviour have disagreed before):

| # | Fact | Why it matters | Check |
|---|---|---|---|
| 1 | The two-entry `marketplace.json` installs each plugin from its subdirectory | the whole layout | `/plugin marketplace add` of a local clone, install both |
| 2 | No skill/agent name collision, and `shipkit:` agents are unaffected by the second plugin | every doc | fresh session, `/` menu and agent list |
| 3 | `--plugin-dir` may be repeated | smoke test and local dev | `claude --help` |
| 4 | `/plugin update` follows the `source` change from `./` to `./plugins/shipkit` for an already-installed `shipkit@shipkit` | every existing user | upgrade a 2.9 install to the split branch |
| 5 | Both plugins toggle independently in `settings.json` `enabledPlugins` | "install one or both" | inspect settings after install |

`scripts/smoke.sh` gains a check for #2 and runs its existing checks against `plugins/shipkit`.

### 2.5 Lint / smoke / CI changes

- `lint.py`: take a list of plugin roots (derived from `marketplace.json` `source` fields) and
  run every per-plugin check on each; keep the version-equality and CHANGELOG checks
  repo-level. The "N skills / N agents" description-count check becomes per plugin.
- `smoke.sh`: point at `plugins/shipkit`; add the namespace check. Its `agents` expectation
  reads `plugins/shipkit/agents/*.md`.
- `.woodpecker.yml`: unchanged (it runs `lint.py`). *(Superseded in 3.1.0: the project moved to
  GitHub, so the Codeberg pipeline ran nowhere and was removed. Lint now runs via
  `.github/workflows/lint.yml`. The layout above is the 3.0 design as written, kept as a record.)*
- Every `rsync`/`tar` scratch copy and `${CLAUDE_PLUGIN_ROOT}` use is already root-relative;
  `session-start.sh`'s fallback (`dirname $0/..`) still resolves to the core root.

### 2.6 Migration for existing users (3.0 CHANGELOG + `setup` note)

- `shipkit@shipkit` keeps its name, so `/plugin update` keeps core working; the six
  workflow skills, the review KB and `test-analyzer` disappear until
  `shipkit-workflows@shipkit` is installed.
- Skill names change namespace: `/shipkit:qa` → `/shipkit-workflows:qa`, and likewise `tdd`,
  `debug`, `humanize`, `legacy-audit`, `migration-plan`.
- Removed, with pointers: `/shipkit:ui-ux` and the `ui-ux-standards` KB → install the official
  `frontend-design` plugin; `/shipkit:ai-feature` → the built-in `claude-api` skill plus the
  stack overlay's AI knowledge base (`ai-rails`).
- `.claude/rules/shipkit/` installs are unaffected (rules did not move); the stale-rules nudge
  fires once because the digest changed — `/shipkit:setup` refreshes.
- Pin `v2.9.0` for the single-plugin layout.

---

## 3. Composable stacks (2.10)

### 3.1 The gap

`/shipkit:setup` picks **one** stack (`argument-hint: [rails|react|python|go|elixir|static]`)
and the overlays are web-framework shaped. Against the stacks the author actually works in:

| Stack | What exists today | What is missing |
|---|---|---|
| **Rails + Hotwire** | `rails` overlay (2 rules, 4 skills, 2 KBs); a `FRONTEND` placeholder; a Hotwire table inside the Rails review KB | No Hotwire rule at all. Nothing path-scoped fires when editing a Stimulus controller or a `turbo_stream.erb`. No guidance on Frames vs Streams vs Drive, Stimulus values/targets/outlets, morphing, or system-test coverage of Turbo flows. |
| **React** | `react` overlay (2 rules, `/component`), treated as a standalone stack | The author's React lives inside Rails apps (Inertia / `vite_rails` / `jsbundling`), and today a Rails + React project gets one overlay or the other, never both. Next.js/RSC and TanStack Query are unmentioned. |
| **Elixir / Phoenix + LiveView** | `elixir` overlay (2 rules, `/new-feature` scaffolds a LiveView); an `ELIXIR_FRONTEND` placeholder | No LiveView rule. Nothing fires on `*.heex` or `lib/*_web/live/**` beyond the generic UI rule. Mount-runs-twice, `assign` vs `stream`, `handle_params`, PubSub fan-out, Oban idempotency, `mix precommit` style checks are absent. |
| **Python (web)** | `python` overlay (Django/FastAPI gotchas) | Fine for web. |
| **Python ML / AI** | nothing | No notebook rule (`*.ipynb`), no experiment/reproducibility rule (seeds, config, tracking), no data-handling rule (never commit raw data; document provenance), no `uv`/`ruff` defaults, no train/eval commands in CLAUDE.md. (LLM-SDK guidance is the built-in `claude-api` skill's job, so no Python AI KB is planned.) |
| **Elders** | `eve`/`archivist` know Phoenix/LiveView/Oban/Sidekiq signals | They do not know Hotwire (`turbo-rails`, `stimulus-rails`, `importmap.rb`) or ML signals (`torch`, `transformers`, `notebooks/`, `data/`, `models/`, `mlruns/`, `wandb/`). The map template has no "Frontend interaction model" or "Data & models" section. |
| **Path-scoped rules** | `migrations` covers Rails/Ecto/Django/Alembic; `dependencies` covers all manifests | `security` misses Django `views.py`/`serializers.py`; `dependencies` misses `uv.lock`, `poetry.lock`, `importmap.rb`. |

### 3.2 The model: base overlays + add-ons, installed as a set

Overlays become **composable**. A project has one or more *base* stacks and zero or more
*add-ons*; `setup` detects the set, confirms it with the user, and runs `install-stack.sh` once
per overlay. The install script already supports this unchanged: rules land in
`.claude/rules/shipkit/<overlay>/`, CLAUDE.md sections are marker-guarded per overlay, and each
overlay declares only the placeholders it uses.

| Overlay | Kind | Detection signal | New rules (path-scoped) | New KB | CLAUDE.md.append |
|---|---|---|---|---|---|
| `rails` | base | `Gemfile` with `rails` | (existing) | (existing) | existing |
| `hotwire` | add-on to rails | `turbo-rails` / `stimulus-rails` / `importmap-rails` in Gemfile, or `@hotwired/*` in package.json | `hotwire.md` — paths `app/javascript/controllers/**`, `app/views/**/*.turbo_stream.erb`, `app/views/**/*.erb`, `app/components/**`. Content: Drive by default; Frames for scoped nav; Streams only for multi-region updates; Stimulus controllers small, use `values`/`targets`/`outlets`, no `querySelector`; morph-safe markup; every Turbo flow has a system test. | — | Frontend: Hotwire; JS bundling (importmap / esbuild / vite); system-test command |
| `react` | **add-on** (primary pairing: `rails`; also `elixir`; a base-less SPA still installs it alone) | `react` in package.json; with `rails`, also `inertia_rails` / `vite_rails` / `jsbundling-rails` in Gemfile | (existing 2 rules) + a Rails-integration block used only when the base is `rails`: components under `app/frontend/` or `app/javascript/`, Inertia props are the API contract, no duplicate routing in React, `vite_rails`/`jsbundling` build in the test command | — | existing, plus Integration: Inertia / Vite / jsbundling and the bundler command; the existing `BUNDLER` placeholder reused |
| `elixir` | base | `mix.exs` | (existing) | — | existing |
| `liveview` | add-on to elixir | `:phoenix_live_view` in `mix.exs` | `liveview.md` — paths `lib/*_web/live/**`, `**/*.heex`, `lib/*_web/components/**`. Content: mount runs twice (`connected?/1`); `stream` for collections, `assign` for scalars; `handle_params` for URL state; PubSub subscribe in `mount` only when connected; function components over nested LiveViews; `phx-*` bindings over JS; LiveViewTest for every interaction. Plus `jobs.md` for Oban if `:oban` present: idempotent `perform/1`, `unique` options, args are IDs. | — | Frontend: LiveView; PubSub topics; Oban queues |
| `python` | base | `pyproject.toml` / `requirements*.txt` | (existing) + `security.md` path additions | — | existing |
| `ml` | add-on to python | any of `torch`, `tensorflow`, `jax`, `scikit-learn`, `transformers`, `pandas`, `polars`, `jupyter` in deps, or `*.ipynb` / `notebooks/` / `data/` present | `notebooks.md` (`**/*.ipynb`, `notebooks/**`): notebooks are for exploration, promote anything reused to a module, clear outputs before commit, no secrets in cells. `experiments.md` (`experiments/**`, `configs/**`, `**/train*.py`, `**/eval*.py`, `**/*.yaml` under configs): set seeds, log every run with config + git SHA, make device selection explicit, never eval on train data, save metrics next to weights. `data.md` (`data/**`, `**/datasets/**`): never commit raw data or weights, document provenance and licence, schema-check on load, pin dataset versions. | — (LLM-SDK guidance is the built-in `claude-api` skill) | Datasets and where they live; train / eval / notebook commands; tracker (MLflow / W&B / none); hardware (CPU / CUDA / MPS); model artifact location |
| `go`, `static` | base | (existing) | — | — | existing |

Detection is a table in `setup` Phase 1 (one row per overlay, one signal each); the user
confirms the set in one question ("Detected: rails + hotwire + react. Correct?"). CLAUDE.md's
`Stack:` line lists the full set. `unsetup` is unaffected (it restores the snapshot).

### 3.3 Core changes that ride along

- **`archivist`**: two optional map sections — *Frontend interaction model* (Hotwire / LiveView
  / SPA / Inertia: where the UI state lives, how updates reach the browser) and *Data & models*
  (datasets, pipelines, training entry points, artifact locations, experiment tracker). Written
  only when the signals are present.
- **`eve`**: add Hotwire, LiveView and ML rows to the signal cheat-sheet; registry `Stack`
  column already free-text, no schema change.
- **Path-scoped rules**: `security.md` adds `**/views.py`, `**/serializers.py`, `**/live/**`
  (belt and braces; `lib/*_web/**` already matches); `dependencies.md` adds `**/uv.lock`,
  `**/poetry.lock`, `**/importmap.rb`; `session-start.sh`'s manifest regex adds `uv.lock` and
  `importmap.rb`.
- **AI/LLM knowledge lives in the overlays, not a skill.** `ai-rails` (RubyLLM, Turbo Streams for
  streaming, jobs for every LLM call) stays and gets a LiveView sibling only if a real Phoenix
  AI project asks for it. The Anthropic SDK itself is the built-in `claude-api` skill's job.

### 3.4 What this deliberately does not do

- **No learning content.** System design, DS&A and ML theory are `bodhikit`'s job (the tutor
  plugin, already installed alongside). Shipkit contributes what a tutor cannot: verified
  explanations of *real* systems (`/shipkit:explain-system`, `/shipkit:walkthrough`). A future
  bridge — "explain this system, then teach it to me" — would be a bodhikit skill that calls a
  shipkit agent, not a shipkit feature.
- **No new agents.** Everything above is rules, overlays, and words in existing agents.
- **No per-framework scaffolding beyond what exists.** No `/stimulus-controller`, no
  `/notebook`. Scaffolds earn their place only when a project's conventions can't be inferred
  by reading a neighbour, which is rarely true for these.

---

## 4. Build order (each step independently shippable)

**2.10 — composable stacks (non-breaking)**

1. `setup` Phase 1: multi-overlay detection table + one confirmation question; Phase 5 loops
   `install-stack.sh`; `argument-hint` accepts a list. (No script change.)
2. `hotwire` overlay. 3. `liveview` overlay (+ Oban rule). 4. `ml` overlay.
5. Path-scoped rule and hook additions (§3.3). 6. `archivist` / `eve` signals and map sections.
7. `react` becomes an add-on with the Rails-integration block. 8. Lint: an overlay's rules must have `paths:`; an add-on must name
   its base in a `# requires: rails` comment so `setup` can order installs. Docs + CHANGELOG.

**3.0 — the split (breaking)**

9. Seams (§1.1) — each half works alone. Ship this inside 2.10 if convenient; it is harmless.
10. `lint.py` multi-root; `smoke.sh` on `plugins/shipkit` + namespace check.
11. Nonce-test the five platform facts (§2.4); record results in the CHANGELOG like 2.8 did.
12. `git mv` into `plugins/shipkit` and `plugins/shipkit-workflows`; two `plugin.json`; the
    two-entry `marketplace.json`.
13. README (install block, two tables), GUIDE (namespaces), CHANGELOG (migration list),
    ROADMAP (close item 6). 14. Tag `v3.0.0`; keep `v2.9.0` pinnable.

---

## 5. Decisions

Settled 2026-09-14:

1. **Name of the second plugin: `shipkit-workflows`.** Long as a namespace, but the skills are
   mostly auto-invoked, so it is typed rarely, and it says what it is.
2. **`ui-ux` and `ai-feature`: cut**, with their native/official equivalents listed in the
   CHANGELOG (§1, §2.6). `ui-ux-standards` goes with `ui-ux`.
3. **React: an add-on whose primary pairing is Rails** (§3.2). Standalone SPAs still install it.
4. **`humanize` stays**, in workflows.

Still open (settle before step 9):

5. **Rules: all in core (recommended, §1) or split.** See the falsifiability clause there.
6. **Stack overlay skills** (`/new-feature`, `/release`, …): core (recommended) or a
   `workflow-skills/` subfolder installed only when workflows is present. Defer.
