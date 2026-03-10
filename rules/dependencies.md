---
paths:
  - "**/Gemfile"
  - "**/*.gemspec"
  - "**/package.json"
  - "**/package-lock.json"
  - "**/yarn.lock"
  - "**/pnpm-lock.yaml"
  - "**/bun.lockb"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
  - "**/Pipfile"
  - "**/setup.py"
  - "**/setup.cfg"
  - "**/go.mod"
  - "**/go.sum"
  - "**/mix.exs"
  - "**/mix.lock"
---

# Dependency Management Rules

## Before Adding Any Dependency
1. Read the library's documentation first — use the `/use-library` skill
2. Check the latest stable version and use it unless the project pins a major version
3. Verify compatibility: run the full test suite AFTER adding the dependency
4. Check for security advisories before adoption

## Never
- Never add a dependency without running tests afterward
- Never downgrade a dependency without documenting why
- Never use `*` or unpinned versions in dependency files
- Never run bare `bundle update` or `npm update` without targeting specific packages
