---
type: regex
pattern: '^(?![\s\S]*(?:^|\n)[^#\n]*\bupdate_columns?\b)[\s\S]*reviewed_at'
target: { source: file, path: app/models/order.rb }
---
