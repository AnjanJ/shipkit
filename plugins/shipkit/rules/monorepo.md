---
paths:
  - "pnpm-workspace.yaml"
  - "lerna.json"
  - "turbo.json"
  - "nx.json"
---

# Monorepo Rules
- A change to a shared package is not done until the tests of every package that consumes it
  have run — its own suite proves nothing about its callers.
- Run targeted builds and tests with `--filter` (pnpm, turbo) or `--scope` (lerna); a
  full-monorepo run on every edit is what makes people skip the tests.
