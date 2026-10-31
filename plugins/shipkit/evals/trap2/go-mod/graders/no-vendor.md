---
type: regex
pattern: '^(?![\s\S]*(?:^|\n)[^#\n]*\bvendor\b)[\s\S]*(?:go|\$\(GO\)) build'
target: { source: file, path: Makefile }
---
