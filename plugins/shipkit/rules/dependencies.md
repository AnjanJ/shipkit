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
  - "**/uv.lock"
  - "**/poetry.lock"
  - "**/requirements*.txt"
  - "**/Pipfile"
  - "**/setup.py"
  - "**/setup.cfg"
  - "**/go.mod"
  - "**/go.sum"
  - "**/mix.exs"
  - "**/mix.lock"
  - "**/importmap.rb"
---

# Dependency Management Rules
- Never use `*` or an unpinned version in a dependency file.
- Never run a bare `bundle update`, `npm update` or `mix deps.update --all`: name the package.
  A bare update moves every dependency at once and hides which one broke the build.
- Never downgrade a dependency without saying why in the commit.
