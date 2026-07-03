---
description: "Build or refresh this project's PROJECT_MAP.md — the verified index the elders read. Run after big changes. Use --register to add the project to your cross-project registry for eve."
user-invocable: true
argument-hint: "[refresh | section <name> | --register]"
---

# /shipkit:map — Build & Refresh the Project Map

`PROJECT_MAP.md` is the artifact that makes `grandfather` and `eve` fast *and* accurate.
This skill runs the **`archivist`** agent to create or refresh it. The heavy file-reading
happens in the agent's context, not yours.

## Arguments

Mode: `$ARGUMENTS` (default: build if no map exists, else refresh)

- *(none)* — Build `PROJECT_MAP.md` if absent; refresh it if present.
- `refresh` — Force a re-verification pass against current source; update drift.
- `section <name>` — Regenerate one section only (e.g. `section evolution`).
- `--register` — After mapping, add this project to the cross-project registry (below).

## How to run it

1. **Delegate to the `archivist` agent** via the Agent tool. Tell it the mode and the working
   directory. Do not map the project yourself in the main context.
2. The agent writes `PROJECT_MAP.md` (repo root, or `docs/` if that is the convention) and
   returns a 5-line summary: what it wrote, line count, HEAD sha, any unverified sections.
3. Relay that summary. Do not echo the whole map.

## The registry (for eve / cross-project)

The registry lives at `~/.claude/shipkit/project-registry.md`. It is what `eve` reads to
get the portfolio view. Each line: project name, path, map location, one-line description.

On `--register` (and offer it on first `build` of any project):
1. Read `~/.claude/shipkit/project-registry.md` if it exists; create it if not (template below).
2. Add or update this project's row. Use the project's path, the map's HEAD short SHA in
   `Mapped At`, and pull `Stack`, `Deploys To`, and the one-line `Summary` from the freshly
   written map (the archivist already verified them).
3. Keep it sorted, one project per line, deduped by path.
4. On any `refresh`, update the row's `Mapped At` SHA — and `Stack`/`Deploys To` if they
   changed (if the project is registered).

Registry template:

```markdown
# Shipkit Project Registry
> Portfolio index for `eve`. One row per project. Update via `/shipkit:map --register`.

| Project | Path | Map | Mapped At | Stack | Deploys To | Summary |
|---------|------|-----|-----------|-------|------------|---------|
| acme-api | ~/projects/acme-api | docs/PROJECT_MAP.md | ab12cd3 | Rails 8 / Postgres | Fly.io | REST API for the Acme storefront |
| acme-web | ~/projects/acme-web | PROJECT_MAP.md | 9f8e7d6 | Next.js / TS | Vercel | Customer-facing web app |
```

Column notes:
- `Mapped At` — the git SHA the map was built at; lets `eve` flag stale rows without opening
  each map.
- `Stack` / `Deploys To` — one short phrase each, taken from the verified map. They let `eve`
  answer common portfolio sweeps ("which are Rails?", "which deploy to Vercel?") from the
  registry alone — zero repo reads. Use `?` when the map doesn't say; never guess.

## When to run

- **First time** on a project → `build` + `--register`.
- **After a big change** (new domain, refactor, framework upgrade) → `refresh`. A stale map
  makes the elders confidently wrong — refreshing is how you keep the system honest.
- **Lightweight upkeep** → `section evolution` after a notable architectural decision, rather
  than a full rebuild.

## Note on freshness

The map is stamped with the git SHA it was built at. You don't have to track drift yourself:
a shipkit `SessionStart` hook checks the stamp against HEAD and prints a one-line reminder
when the map is ≥20 commits behind (override with `SHIPKIT_MAP_STALE_COMMITS`) or when a
dependency manifest changed since it was built. The elders flagging drift in their answers is
the other signal. Either way: `/shipkit:map refresh`.
