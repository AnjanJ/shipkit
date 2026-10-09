---
type: regex
pattern: '^(?![\s\S]*vendor)[\s\S]*go build'
target: { source: file, path: Makefile }
---
