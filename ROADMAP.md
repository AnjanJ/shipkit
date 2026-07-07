# Roadmap

Where shipkit is heading and why. Written 2026-07-03, after a full design review of v1.2.5.
Newest thinking wins — treat this as a living document, not a contract.

**North star:** reposition shipkit from "21-skill methodology bundle" to **the project
knowledge layer for Claude Code** — map + elders (grandfather/eve/archivist) + registry +
lessons — with the generic workflow content demoted or split out.

**Status (as of 2026-07-08, v2.7.0):** the north star is largely realized. The repositioning
(1.3, 2.0) shipped; the knowledge layer then grew **forward** with spec-driven development and
decision records (2.5), and its optional decision-recall (MemPalace) got one-command setup (2.7).
Everything below through 2.7 is shipped; treat the rest as living direction.

Two verified platform facts shaped this plan (checked against official Claude Code docs), both now
realized in shipped code:

1. **Plugins can ship hooks** — `hooks/hooks.json` at plugin root, `${CLAUDE_PLUGIN_ROOT}`
   for bundled scripts; `SessionStart` fires on startup/resume/clear/post-compaction.
   ✅ Realized: the map-freshness hook shipped in 1.3.0 and gained spec-drift nudges in 2.5.0.
2. **Forked skills cannot use AskUserQuestion** — it is explicitly blocked in subagents.
   ✅ Realized: the fork-interactivity audit (1.3.0) fixed the affected skills; new interactive
   skills (`/shipkit:spec`, `/shipkit:decide`, `/shipkit:connect-memory`) all run inline for this
   reason.

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

## 2.5 — Spec-Driven Development + Decision Records — ✅ SHIPPED 2026-07-07 (2.5.0 + 2.6.0)

Full design: [`docs/design/spec-driven-development.md`](docs/design/spec-driven-development.md).
Written 2026-07-07. **Shipped across two releases:** 2.5.0 (the SDD core) and 2.6.0 (completion).
All four design open-questions are now settled (see the design doc §7). What landed:

- **2.5.0** — the always-on `spec-driven` + `decisions` rules; `/shipkit:spec` (the three
  questions → `.shipkit/specs/<feature>/`, EARS requirements, design-as-decision-records);
  `grandfather`/`eve`/`archivist` taught to read `.shipkit/`; the spec-drift freshness hook.
- **2.6.0** — `/shipkit:decide` (standalone five-part decision capture with a concrete
  falsifiability clause); the registry `Active Specs` column so `eve` sees open specs across the
  portfolio; an explicit guard that `/unsetup` never deletes `.shipkit/`; and narrated capability
  playbooks (new-repo / legacy-repo / elders) plus a "How Shipkit Works" automatic-vs-invoked
  section in the docs.

The original proposal follows, kept for the rationale.

**The gap.** `PROJECT_MAP.md` looks backward (what exists, where). Shipkit has no forward-looking
artifact (what we're *about* to build) and no durable **narrative of decisions** (the "why" the
README's Episodic-memory section explicitly calls out as missing). This item adds both, as new
classes of verified, elder-readable artifact — **extending the knowledge layer forward in time,
not re-adding a methodology bundle.**

**Positioning guardrail.** 2.0 deliberately cut the old `/plan` skill to stop being a methodology
bundle. This must NOT walk that back: no port of Spec Kit's seven `/speckit.*` commands, no
workflow that overlaps native Plan Mode. Specs and decisions are *artifacts the elders read*, and
the discipline is carried by always-on **rules** that ride the existing trivial-vs-non-trivial
split — not by a command chain.

### The model — three questions (user-facing)

1. **What are we building?** → `spec.md`, requirements in **EARS notation** (default, prose-escapable).
2. **How should it work?** → `design.md`, written **as decision records** (below).
3. **How will we know it's done?** → acceptance criteria as **tests** (TDD/BDD-first). Each EARS
   `shall` maps 1:1 to a behavior-focused test. SDD sits *above* TDD: the spec says what to test.

Artifacts live under a single dotted root, `.shipkit/specs/<feature-slug>/`, one folder per
feature, SHA-stamped like the map so drift is detectable. `.shipkit/` is the canonical home for
all shipkit-generated docs — one place humans, the elders, and MemPalace all reference.

### Decision records — the five-part format (the spine)

Every "how" answer is a decision. Records use five parts, in order: **Context · Alternatives (≥2
real) · Case for · Case against (the honest cost of your own choice) · Decision + falsifiability
clause.** The **falsifiability clause** — a concrete, checkable "I'd reverse this if ___" — is the
novel piece: it makes decisions *queryable for staleness* ("chose SQLite because <10k users; now
at 40k" → fired). Hard rule: the clause must be a metric/event/threshold, never a vague hedge —
the guard against LLM-generated hollow honesty, enforced like `explain-system`'s zero-UNCERTAIN
gate. Lives inline in a spec's `design.md` (feature-scoped) or standalone
`.shipkit/decisions/NNNN-*.md` (project-wide). The standalone log is the map's counterpart:
map = *what/where*, log = *why*.

### Reuse (minimal new surface)

- **Rules** (the "effortless" property): `rules/spec-driven.md` + `rules/decisions.md` fire the
  discipline automatically on non-trivial work — no command to memorize; a typo never gets specced.
- **Skills:** one thin `/shipkit:spec` (inline, interviews Q1→Q2→Q3, delegates research to
  `codebase-explorer`, native Plan Mode as the review gate). `/shipkit:decide` optional — ship the
  rule first, add the skill only if capture proves unreliable.
- **Agents:** teach `grandfather`/`eve` that `specs/` + the decision log are first-class sources
  (enables "what's next?", "why X?", and "which decisions are now falsified?"); `archivist` links
  active specs/decisions from the map. Structured records are preferred over fuzzy MemPalace recall
  for "why" questions (verified > recalled) — complementary, not competing.
- **Hook:** extend `check-map-freshness.sh` (one proven mechanism) to flag specs whose code has
  drifted and, cheaply, surface fired falsifiability clauses at session start.

### Build order (each independently shippable)

Rules → agent reads → `/shipkit:spec` → hook extension → `/shipkit:decide` (if needed) → docs.
See the design doc §7 for the open decisions (record home, skill-vs-rule, one-hook-vs-two, EARS
strictness — the last settled as *default, escapable*).

---

## 2.7 — One-command episodic-memory setup — ✅ SHIPPED 2026-07-08 as 2.7.0

**The gap.** MemPalace (the optional decision-recall store the elders use) had thorough but fully
**manual** onboarding — install, register, restart, backfill — and `/shipkit:setup` never
mentioned it. The worst friction was hand-deriving the `~/.claude/projects/-Users-...` transcript
path, which users got wrong.

**What shipped.** `/shipkit:connect-memory` — an inline skill that sets it up end-to-end: detects
what's already done and skips it, installs via `uv`/`pipx` if missing, registers at user scope,
**auto-derives the transcript directory**, splits concatenated transcripts, backfills this
project's history (dry-run first, then real), and reminds you to restart Claude Code. `/shipkit:setup`
now points users to it; README/GUIDE lead with the command and keep the manual steps as a fallback.

**Positioning held.** MemPalace stays opt-in and **unbundled** (a separate package + ~300 MB
model) — the base plugin remains dependency-free. This only automates the setup the docs already
described by hand; skip it and the elders fall back to git history, nothing breaks.

---

## Origin

This roadmap came out of an honest design review (2026-07-03) whose seven findings map to the
items above: (1) skill breadth dilutes identity → item 6; (2) thin moat → item 7; (3) map
staleness → item 3; (4) over-prescriptive workflow → item 5; (5) author-specific examples →
item 4; (6) no plugin validation → item 2; (7) fork/interactivity mismatch → item 1.
