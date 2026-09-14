---
paths:
  - "pnpm-workspace.yaml"
  - "lerna.json"
  - "packages/**"
  - "apps/**"
---

# Monorepo Rules

## When Modifying Shared Packages
- Changes to a shared package require running tests in ALL consuming packages
- Never bump a shared package version without checking downstream consumers
- Use `--filter` (pnpm) or `--scope` (lerna) to run targeted builds

## Dependency Management
- Shared dependencies should be hoisted to the root `package.json`
- Package-specific dependencies stay in the package's own `package.json`
- Never install the same dependency at different versions across packages without documenting why

## Cross-Package Changes
- If a change spans multiple packages, ensure they can be deployed independently
- Breaking changes to internal APIs require a migration path (deprecate → migrate → remove)
- Run the full monorepo test suite before merging cross-package PRs
