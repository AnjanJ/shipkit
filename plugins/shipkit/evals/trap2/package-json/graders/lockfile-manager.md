---
type: regex
pattern: '^(?![\s\S]*(?:^|\n)(?:exec +)?(?:npm (?:ci|install)|yarn(?:\s|$)|bun install))[\s\S]*pnpm (?:i|install)'
target: { source: file, path: scripts/ci-install.sh }
---
