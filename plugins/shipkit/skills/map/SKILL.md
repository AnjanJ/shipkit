---
description: "Build or refresh this project's PROJECT_MAP.md — an optional verified index the elders read when it exists; worth it for eve's portfolio view or a thin commit history. Run after big changes. Use --register to add the project to your cross-project registry."
user-invocable: true
argument-hint: "[refresh | section <name> | --register]"
context: fork
---

<!-- Runs FORKED (its own context): this skill IS the archivist since 5.0.0 — the heavy
     file-reading happens here, not in the caller's context. It cannot ask the user anything
     mid-run; it writes PROJECT_MAP.md (and the registry on --register) and returns a summary. -->

# /shipkit:map — Build & Refresh the Project Map

`PROJECT_MAP.md` is the artifact that makes `grandfather` and `eve` fast *and* accurate.
This skill creates or refreshes it, running forked so the heavy file-reading never reaches
the caller's context. The procedure, constraints and output template are in `@archivist.md`
(the `archivist` agent's body until 5.0.0); read it first and follow it for the mode below.

## Arguments

Mode: `$ARGUMENTS` (default: build if no map exists, else refresh)

- *(none)* — Build `PROJECT_MAP.md` if absent; refresh it if present.
- `refresh` — Force a re-verification pass against current source; update drift.
- `section <name>` — Regenerate one section only (e.g. `section evolution`).
- `--register` — After mapping, add this project to the cross-project registry (below).

## How to run it

1. **Read `@archivist.md`** and do what it says for the mode: detect the stack and entry
   points, map the structure, reconstruct the evolution from git, collect gotchas, verify every
   cited path before writing. You are forked: do the reading here.
2. Write `PROJECT_MAP.md` (repo root, or `docs/` if that is the convention).
3. Return a 5-line summary: what you wrote, line count, HEAD sha, any unverified sections —
   and, on a first build, one line offering `/shipkit:map --register` (you cannot ask mid-run).
   Do not echo the whole map.

## The registry (for eve / cross-project)

The registry lives at `~/.claude/shipkit/project-registry.md`. It is what `eve` reads to
get the portfolio view. Each line: project name, path, map location, one-line description.

On `--register` (offered in the summary on a first `build`; this runs in the same fork):
1. Read `~/.claude/shipkit/project-registry.md` if it exists; create it if not (template below).
2. Add or update this project's row. Use the project's path, the map's HEAD short SHA in
   `Mapped At`, and pull `Stack`, `Deploys To`, and the one-line `Summary` from the freshly
   written map (verified while writing it). For `Active Specs`, list the feature slugs
   under `.shipkit/specs/*/` whose spec is open — no `> Status:` line, or `Status: open` — (or
   `—` if none); this lets `eve` answer "which projects have an open spec?" from the registry
   alone. For `Product` and `Top Goal`, read `.shipkit/product.md`: the text under "One line",
   and the first bullet under "Goals this quarter". Write `?` in both if the file does not
   exist — never guess them from the README.
3. Keep it sorted, one project per line, deduped by path.
4. **An existing registry without the `Product` and `Top Goal` columns:** add the two columns
   to the header, and put `?` in them for every row you are not registering now. Change nothing
   else in those rows — they are the user's, and their projects are not open in front of you.
5. On any `refresh`, update the row's `Mapped At` SHA — and `Stack`/`Deploys To`/`Active Specs`/
   `Product`/`Top Goal` if they changed (if the project is registered).

Registry template:

```markdown
# Shipkit Project Registry
> Portfolio index for `eve`. One row per project. Update via `/shipkit:map --register`.

| Project | Path | Map | Mapped At | Stack | Deploys To | Active Specs | Product | Top Goal | Summary |
|---------|------|-----|-----------|-------|------------|--------------|---------|----------|---------|
| acme-api | ~/projects/acme-api | docs/PROJECT_MAP.md | ab12cd3 | Rails 8 / Postgres | Fly.io | billing-v2 | Order API for small shops | Failed charges under 2% by 2026-12-31 | REST API for the Acme storefront |
| acme-web | ~/projects/acme-web | PROJECT_MAP.md | 9f8e7d6 | Next.js / TS | Vercel | — | ? | ? | Customer-facing web app |
```

Column notes:
- `Mapped At` — the git SHA the map was built at; lets `eve` flag stale rows without opening
  each map.
- `Stack` / `Deploys To` — one short phrase each, taken from the verified map. They let `eve`
  answer common portfolio sweeps ("which are Rails?", "which deploy to Vercel?") from the
  registry alone — zero repo reads. Use `?` when the map doesn't say; never guess.
- `Active Specs` — feature slugs with an open spec under `.shipkit/specs/*/`, comma-separated,
  or `—` if none. Lets `eve` answer "which projects have an open spec?" / "what's in flight
  across the portfolio?" from the registry alone. This is a point-in-time snapshot — refresh it
  on `/shipkit:map --register`; treat it as a hint, and verify against the repo for certainty.

- `Product` / `Top Goal` — what the product is for, and its first goal this quarter, copied from
  the project's `.shipkit/product.md` (written by `/shipkit:product`). `?` means the project
  has no product file yet. `Summary` says what the code is; `Product` says what it is for.
  Together with `~/.claude/shipkit/studio.md` they let `eve` weigh one project against another.

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
