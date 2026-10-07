---
type: regex
pattern: 'apps/(web|api)|--filter[= ][\x22\x27]?(\.\.\.|web\b|api\b)|turbo run test|pnpm (-r|-w|--recursive) |(^|\n)\s*pnpm (run )?test\b'
target: { source: file, path: CHECKS.txt }
---
