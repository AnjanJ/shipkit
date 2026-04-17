# Onboard — Reference Material

## Architectural Shape Classification

| Shape | Signals |
|-------|---------|
| Monolith with conceptual seams | Single deploy, `app/` with models/controllers/services |
| Modular monolith | `engines/`, `packages/`, or `components/` with internal boundaries |
| Microservices | Multiple services in subdirs, API gateways, service-to-service calls |
| Monorepo | `apps/`, `packages/`, shared libraries, workspace config |

## Flow Pattern Classification

| Pattern | Signals |
|---------|---------|
| Request-driven (sync) | Routes → controllers → response cycle |
| Event-driven (async) | Event/message classes, broker configs, subscriber definitions |
| Hybrid | Both routes AND event processing (most real apps) |

## Phase 3: Git Analysis Commands

### 3.1 Hotspot Analysis

Run (via codebase-explorer agent):
```
git log --since="6 months ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20
```

High churn + high line count = abstraction under strain. These files are where bugs live
and where refactoring would have the most impact.

### 3.2 Change Pattern Analysis

For the top 5 hotspots:
- Are changes **additive** (new features extending existing code)?
- Or **invasive** (cutting across multiple layers for one feature)?
- Repeated invasive changes = the abstraction needs rework

### 3.3 Contributors

```
git shortlog -sn --since="6 months ago"
```

Who works on what areas? This tells you who to ask questions.

### 3.4 PR Archaeology (if GitHub)

Use `gh` CLI to check recent merged PRs — descriptions contain the "why" that code misses.

### 3.5 Metaprogramming Scan

Flag metaprogramming (`method_missing`, metaclasses, Proxy, etc.) — this is where "magic" hides.

### 3.6 Exit Criteria Check

Can you: trace main flows? Name key components? Point to where state lives?
If yes → Phase 4. If no → investigate the gap.

## Phase 5: Opportunity Detection Signals

Look for: CI/CD scripts, frequent migrations, complex test factories, many background jobs,
feature flags, monitoring config, i18n files, custom scripts — each could become a
project-specific skill or agent.

For each suggestion, provide: evidence found, what it would do, complexity, priority.

## Constraints

- **Read-only until Phase 4** — Phases 1-3 only read files and run git commands
- **User checkpoints are mandatory** — present findings and WAIT at every phase boundary
- **Use codebase-explorer agent for heavy reading** — keep main context clean
- **Lightweight docs** — ARCHITECTURE.md: 40-80 lines, CODEBASE_MAP.md: 30-60 lines
- **Stack-agnostic** — all phases work for any language/framework
- **Time-box git analysis** — cap at 20 hotspot files, 6-month window
- **Never auto-create skills/agents** — Phase 5 outputs proposals only
- **"Enough" exit criteria** — can trace main flows, name key components, point to state
- **Blame-free framing** — "What were the constraints?" not "Why is this bad?"
- **WHY not HOW** — documentation explains why decisions were made, not how code works
- **Questions unlock questions** — each answer unlocks the next question; iterate, don't exhaust
