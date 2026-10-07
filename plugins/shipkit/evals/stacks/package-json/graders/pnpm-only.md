---
type: regex
pattern: '^(?![\s\S]*\b(npm|yarn|bun) (install|add|i)\b)[\s\S]*\bpnpm (add|install|i)\b'
target: { source: file, path: STEPS.txt }
---
