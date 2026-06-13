# PROJECT_MAP.md Template

The archivist writes this structure. Grandfather reads it. Keep it 120-220 lines.

```markdown
# PROJECT_MAP — <project name>

> Map generated at commit `<sha>` on `<branch>`. Refresh with `/shipkit:map`.
> This is a navigational index. Claims here are verified at write time but source is truth —
> always re-check the specific file before acting on a pointer.

## What this project is
<2-3 sentences: what it does, who uses it, why it exists.>

## Stack
- **Language/framework:** <Rails 7.1 / Phoenix 1.7 / React 18 + TS / ...>
- **Datastore:** <PostgreSQL / ...>  **Cache/queue:** <Redis, Sidekiq, Oban, ...>
- **Deploy:** <Hetzner / AWS / Cloudflare Pages — and how>
- **Test:** <RSpec / ExUnit / Vitest> — run with `<command>`

## Layout (where things live)
| Path | Purpose |
|------|---------|
| `app/models/` | ... |
| `lib/<app>/` | domain contexts |
| ... | ... |

## Core modules / domains
- **<Name>** (`path/`) — responsibility, key files. Boundary: what it owns vs delegates.
- ...

## Data model
<Entities + relationships in prose/table. Mental model, not schema dump.>
- `User` ──< `Property` ──< `Lease` ...

## Primary flows
1. **<Flow name>** — entry (`controller#action` / route) → ... → result. Sync/async boundary.
2. ...

## Evolution  ← highest-value section; source can't tell you this
- **Origin:** started as <...>
- **Major shifts:** <the 2-4 inflection points — a rewrite, an extraction, an i18n pass>
- **Heading toward:** <current trajectory>
- **Decisions of record:** <ADR pointers or notable commits>

## Gotchas
- <Non-obvious trap a newcomer gets wrong, with the file it bites in.>
- ...

## External touchpoints
- <Third-party API / webhook / queue> — handled in `<path>`.

## Pointers to deeper docs
- `docs/ARCHITECTURE.md` (if present), `CLAUDE.md` rules, ADRs.

## Unverified / open questions
- <Anything the archivist could not confirm against source.>
```

## Writing rules
- A path in the table must exist on disk when written.
- "Heading toward" is inference — keep it short and honest, never invent a roadmap.
- If a section has nothing real to say, omit it rather than pad.
- The Evolution and Gotchas sections justify the map's existence — never skip them.
