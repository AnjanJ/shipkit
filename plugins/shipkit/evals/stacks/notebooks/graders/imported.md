---
type: regex
pattern: 'from ledger(\.\w+)* import[^"]*monthly_totals'
target: { source: file, path: notebooks/explore.ipynb }
---
