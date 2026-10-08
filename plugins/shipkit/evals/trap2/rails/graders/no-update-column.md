---
type: regex
pattern: '^(?![\s\S]*update_column)[\s\S]*reviewed_at'
target: { source: file, path: app/models/order.rb }
---
