---
type: regex
pattern: '^(?![\s\S]*(\bnpm (ci|install)|yarn|bun install))[\s\S]*pnpm (i|install)'
target: { source: file, path: scripts/ci-install.sh }
---
