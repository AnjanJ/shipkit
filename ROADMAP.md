# Roadmap

Where shipkit is heading and why. Written 2026-07-03, after a full design review of v1.2.5.
Newest thinking wins — treat this as a living document, not a contract.

**North star:** reposition shipkit from "21-skill methodology bundle" to **the project
knowledge layer for Claude Code** — map + elders (grandfather/eve/archivist) + registry +
lessons — with the generic workflow content demoted or split out.

Two verified platform facts shape this plan (checked against official Claude Code docs):

1. **Plugins can ship hooks** — `hooks/hooks.json` at plugin root, `${CLAUDE_PLUGIN_ROOT}`
   for bundled scripts; `SessionStart` fires on startup/resume/clear/post-compaction.
   Map-freshness automation is fully buildable.
2. **Forked skills cannot use AskUserQuestion** — it is explicitly blocked in subagents.
   Any skill with `context: fork` that asks the user questions mid-run is broken today.

---

## 1.3 — Hardening (non-breaking) — ✅ SHIPPED 2026-07-04 as 1.3.0

All five items below landed (the fork-interactivity audit found **nine** affected skills, not
three — including `/unsetup`, whose destructive-restore confirmation ran where the user could
never see it). Remaining from the review: the 2.0 items, plus the 1.3 deprecation notices for
the cut-bucket skills, which are deferred until the cut-vs-split decision (see 2.0 item 6).

Ordered; each item was small and independently shippable with its own changelog entry.

### 1. Fix fork-interactivity bugs (live bugs — first)

At least three skills run in `context: fork` but assume interactive checkpoints, which
subagents cannot do:

- **`/setup`** — asks project purpose, branch prefix, PR preference, backup preserve/delete.
  Fix: drop `context: fork`. One-time operation; inline context cost is acceptable and its
  questions must reach the user.
- **`/plan`** — three AskUserQuestion approval checkpoints (PRD → spec → tasks).
  Fix: run inline, delegate Phase-2 codebase research to `codebase-explorer`. Interactive
  checkpoints stay where they belong; context-thinness stays where it matters.
- **`/qa`** — "probing questions before writing tests."
  Fix: same split — interactive phases inline, research delegated.

Audit all remaining forked skills for the same assumption. Add a lint rule (below): a skill
with `context: fork` must not mention AskUserQuestion, checkpoints, or "ask the user."

### 2. Plugin lint + CI (second — everything after it gets caught by it)

Dependency-free `scripts/lint.sh` (bash + small python for YAML). Checks:

- Frontmatter parses and has required fields for every skill/agent.
- Every `@reference.md` / `@templates/...` reference resolves.
- `agents/` contains only real agents (the actual 1.2.1 template-as-bogus-agent bug class).
- `plugin.json` / `marketplace.json` versions match; CHANGELOG has an entry for the version.
- No machine-specific absolute paths (`/Users/...`).
- Rule `paths:` globs are valid.
- Fork-interactivity rule from item 1.

Wire into Woodpecker CI on Codeberg (`.woodpecker.yml`); document `./scripts/lint.sh` as the
pre-release step.

### 3. Map-freshness hook

`hooks/hooks.json` with a `SessionStart` hook running `scripts/check-map-freshness.sh`:

- Extract the SHA stamp from `PROJECT_MAP.md`.
- `git rev-list <sha>..HEAD --count` — if the map is ≥ N commits stale (default ~20), **or**
  a dependency manifest changed since the stamp, print one line:
  `PROJECT_MAP.md is N commits stale — /shipkit:map refresh`.
- Milliseconds of cost, no dependencies, silent when fresh.

Also: add a `mapped-at` SHA column to the project registry so `eve` can flag stale rows per
project in portfolio answers.

### 4. Genericize the examples

`eve.md`'s grep examples reflect one specific portfolio (Hetzner/Kamal/Oban/LiveView) and can
mislead other users' sweeps. Replace with a multi-ecosystem **signal cheat-sheet**, explicitly
labeled non-exhaustive:

- Deploy: `fly.toml`, `vercel.json`, `render.yaml`, `wrangler.toml`, `config/deploy.yml`,
  Dockerfile + CI configs.
- Background jobs: sidekiq / oban / celery / bullmq / river.
- …same pattern for framework versions, payment providers, etc.

Generic project names in the registry template. The lint's absolute-path check prevents
regressions.

### 5. Soften and single-source the workflow

- `rules/shipkit.md` becomes the **only** place the default workflow is defined; `/plan` and
  `/tdd` reference it instead of restating it.
- Reword "BDD is not optional" → "prefer behavior-focused tests for user-facing features."
  Prescriptive LLM rules degrade over long sessions and alienate users who don't share the
  conviction.
- Make intensity a **setup choice**: `/setup` asks "workflow style: strict TDD / test-first
  default / lightweight" and writes the matching CLAUDE.md section. Strict TDD stays fully
  available (the `/tdd` skill and setup option) — it just stops being installed into
  strangers' projects as law.

---

## 2.0 — Repositioning (breaking) — ✅ SHIPPED 2026-07-04 as 2.0.0

Decision made: **hard cut**, not a two-plugin split. The five cut skills point to native
equivalents in the CHANGELOG; `v1.3.0` is tagged for anyone who relied on them. Registry v2
landed with `Stack` / `Deploys To` columns. The portfolio version/dependency matrix and
consolidation report shipped as **2.1.0** (`/shipkit:ask --all matrix <target>` and
`--all consolidate`) — the review's seven findings are now fully addressed.

Still open (not yet scheduled): Woodpecker CI is configured (`.woodpecker.yml`) but Codeberg
CI access is invite-gated — request access via Codeberg's Community tracker, then enable the
repo at ci.codeberg.org. Until then, run `./scripts/lint.sh` before each release.

### 6. Triage the 21 skills

Three buckets:

| Bucket | Skills | Action |
|--------|--------|--------|
| **Core** (headline, model-invocable) | `ask`, `map`, `setup`, `unsetup`, `update-rules`, `context-audit` | Keep — the knowledge layer + its hygiene tools |
| **Demote** | `debug`, `tdd`, `qa`, `ui-ux`, `humanize`, `ai-feature`, `legacy-audit`, `migration-plan`, `explain-system`, `walkthrough` | `disable-model-invocation: true` — removes the description from context until invoked, cutting the per-session context tax and stopping auto-trigger surprises |
| **Cut** (deprecation pointers) | `plan` (→ native plan mode), `review-my-code` (→ native `/code-review`; keep the 8-lens KB), `test`, `use-library`, `onboard` (→ `/init` + Explore agents) | Deprecate in 1.3 docs, remove in 2.0 |

Preferred structure: `marketplace.json` supports multiple plugins from one repo. Split into
**`shipkit`** (the knowledge layer) and **`shipkit-workflows`** (the methodology skills).
Nothing is deleted; users opt into the opinionated half; the core plugin's pitch becomes one
sentence.

### 7. Double down on eve (the moat)

Eve lives *outside* any single repo — native project memory can't easily replicate a
portfolio view. Invest there:

- **Registry v2:** add stack, deploy-target, and mapped-at-SHA columns so many single-fact
  sweeps are answered from the registry alone — zero repo reads, cheaper than the current
  grep fast path.
- **New portfolio capabilities:** version/dependency matrix ("which repos are on Rails
  < 7.1?", vulnerable-dependency sweeps), consolidation report (duplicated patterns across
  repos).
- **Hedge platform risk deliberately:** keep `PROJECT_MAP.md` and the registry as plain,
  documented markdown artifacts. If Claude Code ships native cross-session memory, shipkit's
  artifacts become its best-structured input rather than roadkill — say so in the README.

### Migration

- 1.3 marks the cut-bucket skills deprecated in README/GUIDE with pointers to native
  equivalents.
- 2.0 performs the split/cut in one release, with a migration note surfaced by `/setup` and a
  README rewritten around the knowledge-layer pitch.

---

## Origin

This roadmap came out of an honest design review (2026-07-03) whose seven findings map to the
items above: (1) skill breadth dilutes identity → item 6; (2) thin moat → item 7; (3) map
staleness → item 3; (4) over-prescriptive workflow → item 5; (5) author-specific examples →
item 4; (6) no plugin validation → item 2; (7) fork/interactivity mismatch → item 1.
