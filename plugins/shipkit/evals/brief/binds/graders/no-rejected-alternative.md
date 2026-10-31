---
type: regex
pattern: '^(?![\s\S]*(?:^|\n)[^#\n]*\b(?:AwareDatetime|field_validator)\b)[\s\S]*expires_at'
target: { source: file, path: src/linkshort/api.py }
---
