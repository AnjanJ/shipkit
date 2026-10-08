---
type: regex
pattern: '^(?![\s\S]*(poetry|pipenv|\n\s*pip install|python -m pip))[\s\S]*uv (sync|pip|run)'
target: { source: file, path: Makefile }
---
