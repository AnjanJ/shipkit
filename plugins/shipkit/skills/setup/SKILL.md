---
description: "Configure shipkit for your project"
user-invocable: true
argument-hint: "[<base> <add-on>… e.g. rails hotwire react]"
---

<!-- Runs INLINE (no context: fork) on purpose: this skill interviews the user
     (stack confirmation, project purpose, backup decisions) and forked skills
     cannot use AskUserQuestion. It runs once per project; the context cost is fine. -->

# /setup — Configure Shipkit for Your Project

Tailor shipkit to your specific project. Detects your stack, test framework, package manager,
installs shipkit's rules as files, and installs stack-specific skills, rules, and knowledge bases.
The installs are done by two scripts shipped with the plugin, so the result is the same every
time; your job is detection, the interview, and CLAUDE.md.

**This skill is optional.** Shipkit's skills, agents and session hook work without it. Run this
when you want the rules installed in the project (the path-scoped ones only work this way) and
stack-specific configuration. Re-run it after a plugin upgrade when the session hook says the
installed rules are stale.

## Phase 0: Locate the plugin

Everything this skill installs is copied from the plugin's own directory. Find it, in order:

1. The context line `shipkit: plugin root is <path>` printed by the shipkit session hook at the
   start of this session. Use that path.
2. Else read `~/.claude/shipkit/plugin-root` (the hook also writes it there).
3. Else stop and tell the user: "The shipkit session hook has not run yet — restart Claude Code
   (or start a new session) and run `/shipkit:setup` again." Do not guess a path.

Call it `<root>` below. Sanity-check it: `<root>/scripts/install-rules.sh` and `<root>/stacks/`
must exist.

## Phase 1: Detect Project

1. **Detect the overlay set** from `$ARGUMENTS` or by reading project files. A project has
   **one base** stack and **zero or more add-ons** — detect all of them, not just the first
   match. `$ARGUMENTS` may name several (`rails hotwire react`).

   **Base stacks** (pick one):

   | Signal | Base |
   |--------|------|
   | `Gemfile` with `rails` | `rails` |
   | `mix.exs` | `elixir` |
   | `go.mod` | `go` |
   | `manage.py`, or `pyproject.toml`/`requirements.txt` with django/fastapi/flask | `python` |
   | `package.json` with `"react"` and no server framework above | `react` (standalone SPA) |
   | `index.html` or a bare `package.json` | `static` |

   **Add-ons** (install every one whose signal is present):

   | Signal | Add-on | Requires base |
   |--------|--------|---------------|
   | `turbo-rails`, `stimulus-rails` or `importmap-rails` in Gemfile, or `@hotwired/*` in package.json | `hotwire` | `rails` |
   | `react` in package.json **and** a base of `rails` or `elixir` (usually with `inertia_rails`, `vite_rails` or `jsbundling-rails`) | `react` | `rails` / `elixir` |
   | `:phoenix_live_view` in `mix.exs` | `liveview` | `elixir` |
   | `:oban` in `mix.exs` | `oban` | `elixir` |
   | `torch`, `tensorflow`, `jax`, `scikit-learn`, `transformers`, `pandas`, `polars` or `jupyter` in deps, or any of `*.ipynb` / `notebooks/` / `data/` present | `ml` | `python` |

   Then **confirm the whole set in one question**: "Detected: rails + hotwire + react. Install
   these overlays?" Let the user add or remove one. Ask only if detection is ambiguous or the
   set is empty.

2. **Detect test framework:**
   - Rails: RSpec (if in Gemfile) or Minitest
   - React: Vitest (if in package.json) or Jest
   - Python: pytest (if in pyproject.toml/requirements.txt) or unittest
   - Go: `go test`
   - Elixir: ExUnit
   - Static: none

3. **Detect package manager:**
   - Node: bun.lockb→bun, pnpm-lock.yaml→pnpm, yarn.lock→yarn, else npm
   - Python: uv.lock→uv, poetry.lock→poetry, Pipfile.lock→pipenv, else pip

4. **Detect the stack's placeholder values** (Phase 5 passes them to the install script):

| Placeholder | Value |
|-------------|-------|
| `{{TEST_COMMAND}}` | the detected test command (e.g. `bundle exec rspec`, `npm test`, `pytest`, `go test ./...`, `mix test`) |
| `{{TEST_FRAMEWORK}}` | RSpec / Minitest / Jest / Vitest / pytest / unittest / ExUnit |
| `{{DATABASE}}` | from `config/database.yml` / env: PostgreSQL / MySQL / SQLite |
| `{{RAILS_ARCHITECTURE}}` | `app/commands/` or `app/queries/` → CQRS; `app/services/` → Service Objects; else MVC |
| `{{API_MODE}}` | `config.api_only = true` in `config/application.rb` → yes, else no |
| `{{FRONTEND}}` | Hotwire (turbo-rails/stimulus in Gemfile/package.json) / React / API-only |
| `{{PYTHON_FRAMEWORK}}` | Django / FastAPI / Flask / None, from dependencies |
| `{{API_STYLE}}` | REST / GraphQL / gRPC, from dependencies and routes |
| `{{ASYNC_MODE}}` | yes if the framework or code uses `async def`, else no |
| `{{ORM}}` | Django ORM / SQLAlchemy / Tortoise, from dependencies |
| `{{GO_FRAMEWORK}}` | stdlib net/http / Gin / Echo / Chi / Fiber, from `go.mod` |
| `{{MODULE_PATH}}` | the `module` line of `go.mod` |
| `{{DB_LIBRARY}}` | database/sql / sqlx / GORM / ent, from `go.mod` |
| `{{ELIXIR_FRAMEWORK}}` | Phoenix (if `:phoenix` in `mix.exs`) / bare Elixir |
| `{{ELIXIR_FRONTEND}}` | LiveView / API-only / SPA, from `mix.exs` and `lib/*_web/` |
| `{{REACT_PATTERN}}` | Functional components (default) / Class components |
| `{{STATE_MANAGEMENT}}` | Zustand / Redux / Context / None, from `package.json` |
| `{{STYLING}}` | Tailwind / CSS Modules / styled-components, from config files and `package.json` |
| `{{ROUTER}}` | React Router / Next.js / Expo Router, from `package.json` |
| `{{BUNDLER}}` | None / Vite / Webpack / Parcel, from `package.json` |
| `{{DEV_SERVER}}` | None / `npx serve` / `vite dev`, from `package.json` scripts |
| `{{JS_BUNDLING}}` | importmap / esbuild / vite / webpack, from Gemfile + `package.json` (hotwire) |
| `{{STIMULUS_PATH}}` | `app/javascript/controllers/` or `app/frontend/controllers/`, whichever exists (hotwire) |
| `{{SYSTEM_TEST_COMMAND}}` | the system/feature test command (e.g. `bin/rails test:system`, `bundle exec rspec spec/system`) (hotwire) |
| `{{PUBSUB_TOPICS}}` | topic shapes from `lib/*_web/live/` and contexts, or `none` (liveview) |
| `{{LIVEVIEW_TEST_COMMAND}}` | e.g. `mix test test/<app>_web/live` (liveview) |
| `{{OBAN_QUEUES}}` | the `queues:` list from `config/config.exs` (oban) |
| `{{DATASETS}}` | where datasets live and how they are fetched (ml) |
| `{{TRAIN_COMMAND}}` | e.g. `python train.py --config configs/base.yaml` (ml) |
| `{{EVAL_COMMAND}}` | e.g. `python eval.py --checkpoint <path>` (ml) |
| `{{NOTEBOOK_COMMAND}}` | e.g. `jupyter lab`, `uv run jupyter lab` (ml) |
| `{{TRACKER}}` | MLflow / Weights & Biases / none, from deps and config (ml) |
| `{{HARDWARE}}` | CPU / CUDA / MPS, from config or code (ml) |
| `{{ARTIFACT_PATH}}` | where trained weights are written, e.g. `checkpoints/` (ml) |

   Only the placeholders the overlays you are installing actually use matter — run
   `grep -oh '{{[A-Z_]*}}' <root>/stacks/<overlay> -r | sort -u` per overlay. A value you
   cannot detect becomes `TODO: <the hint from the HTML comment next to it>`.

5. **Ask the user:**
   - One-line project purpose (e.g., "SaaS billing platform for freelancers")
   - **Workflow style** — how strict should the coding workflow be?
     - `strict-tdd` — iron-law red-green-refactor for every change (walked with enforcement by
       `/shipkit-workflows:tdd` when that plugin is installed)
     - `test-first` (default) — prefer test-before-implementation, pragmatic exceptions
     - `lightweight` — tests where they earn their keep; spec-driven answers stay inline
   - Branch naming prefix (e.g., `feature/`, `JIRA-123-`) — optional
   - PR description preference: summary+test plan, minimal, or none — optional

## Phase 2: Backup Current State

Before writing ANY files, snapshot the current state so `/unsetup` can restore it.

Two **different** artifacts, for two different questions. Conflating them was a real bug:
re-running `/setup` used to overwrite the "pre-shipkit" snapshot with an already-configured
shipkit install, so `/unsetup` restored shipkit onto itself and called that the original state.

| Artifact | Answers | Written |
|----------|---------|---------|
| `.shipkit-baseline/` | *What did this project look like before shipkit ever touched it?* | **Once, ever.** Never overwritten. |
| `.shipkit-backup-<ts>/` | *What did it look like before this particular setup run?* | Every run. |

### Step 1: Capture the baseline — once, ever

Look for `.shipkit-baseline/` at the project root.

- **If it exists, do not touch it.** Not a refresh, not a merge, not "just this once". It is the
  only record of the pre-shipkit project, and a later `/setup` is exactly the event that would
  corrupt it. Say: "Baseline already captured — leaving it untouched."
- **If it does not exist**, create it and copy in whatever exists now:
  - `CLAUDE.md` → `.shipkit-baseline/CLAUDE.md`
  - `.claude/` (entire directory) → `.shipkit-baseline/.claude/`
  - Write `.shipkit-baseline/.captured` containing the ISO-8601 timestamp, the git SHA if the
    project is a repo, and the shipkit version capturing it.

  One caveat to state honestly when you create it: if shipkit was already set up in this project
  *before* this version, this baseline captures a shipkit-era state, not a pristine one. Write
  `pre-existing-shipkit=true` into `.captured` when `.claude/rules/shipkit/` already exists, so
  `/unsetup` can say so rather than overclaim.

### Step 2: Snapshot this run

Create `.shipkit-backup-<YYYYMMDD-HHMMSS>/` at the project root and copy into it (only what
exists): `CLAUDE.md` and the entire `.claude/` directory.

If an older `.shipkit-backup-*` directory exists, move it inside the new one as
`previous-backup/` (nesting, as before) and remove it from the project root.

**Never offer to delete an existing backup.** The old preserve-or-delete prompt is gone: the
delete branch silently destroyed the only record of an earlier state, and "free up a directory"
is not worth an unrecoverable loss. If the user asks to clean them up, they can delete the
directories themselves — deliberately, not as a side effect of running setup.

### Step 3: Keep the snapshots out of git

These directories can contain an entire `.claude/`, including local settings. Check the
project's `.gitignore` for the three shipkit artifacts:

```
.shipkit-baseline/
.shipkit-backup-*/
.shipkit-recovery-*/
```

If the project has a `.gitignore` and any are missing, offer to add them. If it has none, say so
and let the user decide — do not create a `.gitignore` uninvited. If they decline, warn once that
a snapshot may be committed.

### Step 4: Confirm to user

> "Backed up current state to `.shipkit-backup-<ts>/`. You can restore it anytime with
> `/unsetup`." — and, only when you created it this run: "Captured the pre-shipkit baseline to
> `.shipkit-baseline/`."

## Phase 3: Create CLAUDE.md

Read @reference.md for the template. It is **project facts only** (purpose, stack, commands,
key paths, workflow style, team conventions) — every convention and workflow rule lives in the
rules installed in Phase 4, and the template says so. Keep it under 40 lines before the stack
section.

## Phase 4: Install Shipkit's Rules

Claude Code does not load rules from a plugin, only from a project's `.claude/rules/`
(discovered recursively, path-scoped rules included). Run:

```bash
"<root>/scripts/install-rules.sh" "<root>"
```

It copies all nine rules to `.claude/rules/shipkit/` and stamps `.installed` with the plugin
version and a digest, so the session hook can tell you when a plugin upgrade has made the copies
stale. Once the directory exists the hook stops injecting the always-on rules — nothing loads
twice. If the script exits non-zero, show its message and stop.

## Phase 5: Install Stack-Specific Content

Run the install script **once per overlay**, base first, then each add-on. Pass only the
placeholders that overlay uses (Phase 1 step 4):

```bash
# base
"<root>/scripts/install-stack.sh" "<root>" rails \
  TEST_COMMAND="bundle exec rspec" TEST_FRAMEWORK=RSpec DATABASE=PostgreSQL \
  RAILS_ARCHITECTURE=MVC API_MODE=no FRONTEND=Hotwire

# add-ons
"<root>/scripts/install-stack.sh" "<root>" hotwire \
  JS_BUNDLING=importmap STIMULUS_PATH="app/javascript/controllers/" \
  SYSTEM_TEST_COMMAND="bundle exec rspec spec/system"
```

Each run copies `<root>/stacks/<overlay>/.claude/rules/*` → `.claude/rules/shipkit/<overlay>/`,
`.claude/skills/*` → `.claude/skills/`, appends that overlay's `CLAUDE.md.append` to `CLAUDE.md`
once (guarded by its own marker, so re-runs and sibling overlays never collide), substitutes the
placeholders, and **fails with exit 2 listing any placeholder you did not pass** — pass a
`TODO: …` value rather than omitting one. If one overlay fails, fix it and re-run that overlay;
the others are already installed. Relay every manifest in the summary.

**Bases:**

| Base | Skills | Rules | Knowledge bases (skills with `user-invocable: false`) |
|-------|--------|-------|---------|
| `rails` | `/new-feature`, `/release`, `/safety-check`, `/deploy-check` | `gemfile.md`, `rails.md` | `code-review-standards-rails`, `ai-rails` |
| `react` (standalone) | `/component` | `package-json.md`, `react.md` | — |
| `python` | `/new-feature` | `pyproject.md`, `python.md` | — |
| `go` | `/new-feature` | `go-mod.md`, `go.md` | — |
| `elixir` | `/new-feature` | `mix-deps.md`, `elixir.md` | — |
| `static` | `/audit` | — | — |

**Add-ons:**

| Add-on | Requires | Skills | Rules |
|--------|----------|--------|-------|
| `hotwire` | `rails` | — | `hotwire.md` |
| `react` | `rails` / `elixir` | `/component` | `package-json.md`, `react.md` (its Rails-integration section applies when the base is `rails`) |
| `liveview` | `elixir` | — | `liveview.md` |
| `oban` | `elixir` | — | `jobs.md` |
| `ml` | `python` | — | `notebooks.md`, `experiments.md`, `data.md` |

## Phase 6: Install Settings (Optional)

Ask the user if they want `.claude/settings.json` with safe defaults. See @reference.md for settings details and enterprise mode options.

## Phase 7: Summary

Report what was installed:
- Backup location (`.shipkit-backup-<ts>/`), and the baseline (`.shipkit-baseline/`) — say
  whether you captured it this run or found it already there
- CLAUDE.md line count
- Overlay set installed (base + add-ons), workflow style chosen
- Shipkit rules installed under `.claude/rules/shipkit/` (the install script's line, including
  the version stamp) — note the hook will no longer inject the always-on ones
- Skills, rules and knowledge bases installed per overlay (each install script's
  manifest) and any `TODO:` values the user should fill in
- Settings created (if applicable)

Suggest next steps:
1. Try `/shipkit:map --register` and `/shipkit:ask` (and `/shipkit-workflows:qa` if you have
   the workflows plugin)
2. Use `/update-rules` to add project-specific rules
3. Use `/context-audit` to check context usage
4. **Want the elders to recall past decisions** ("why did we pick X?")? Run `/shipkit:connect-memory` to set up optional episodic memory (MemPalace). Skip it and the elders fall back to git history — nothing breaks.
5. Run `/unsetup` anytime to restore your previous configuration
