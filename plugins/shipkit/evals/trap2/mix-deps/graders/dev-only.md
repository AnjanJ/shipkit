---
type: regex
pattern: ':credo[^\n]*only:[^\n]*runtime:\s*false'
target: { source: file, path: mix.exs }
---
