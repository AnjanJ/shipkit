---
type: regex
pattern: '(^|\n)/?data/|\.parquet'
target: { source: file, path: .gitignore }
---
