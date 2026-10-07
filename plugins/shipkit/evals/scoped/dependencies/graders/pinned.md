---
type: regex
pattern: '"requests(\[[^\]]*\])?\s*(>=|==|~=|===|<=|>|<|!=)[^"]*"'
target: { source: file, path: pyproject.toml }
---
