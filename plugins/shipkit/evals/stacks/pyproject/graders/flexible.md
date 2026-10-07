---
type: regex
pattern: '"httpx\s*>=[^"]*"'
target: { source: file, path: pyproject.toml }
---
