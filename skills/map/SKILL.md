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
2. Add or update this project's row. Use the project's path and pull the one-liner from the
   freshly written map's "What this project is" line.
3. Keep it sorted, one project per line, deduped by path.

Registry template:

```markdown
# Shipkit Project Registry
> Portfolio index for `eve`. One row per project. Update via `/shipkit:map --register`.

| Project | Path | Map | Summary |
|---------|------|-----|---------|
| acme-api | ~/projects/acme-api | docs/PROJECT_MAP.md | REST API for the Acme storefront |
| acme-web | ~/projects/acme-web | PROJECT_MAP.md | Customer-facing web app |
```

## When to run

- **First time** on a project → `build` + `--register`.
- **After a big change** (new domain, refactor, framework upgrade) → `refresh`. A stale map
  makes the elders confidently wrong — refreshing is how you keep the system honest.
- **Lightweight upkeep** → `section evolution` after a notable architectural decision, rather
  than a full rebuild.

## Note on freshness

The map is stamped with the git SHA it was built at. If the elders flag drift in their answers,
that is your signal to run `/shipkit:map refresh`.
