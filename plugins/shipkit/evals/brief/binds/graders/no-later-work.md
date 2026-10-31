---
type: regex
pattern: '^(?![\s\S]*(?:^|\n)[^#\n]*(?:\bInvalidExpiry\b|\bLinkExpired\b|\bnow\s*[:=]|self\.now\b|\.tzinfo\b))[\s\S]*expires_at'
target: { source: file, path: src/linkshort/service.py }
---
