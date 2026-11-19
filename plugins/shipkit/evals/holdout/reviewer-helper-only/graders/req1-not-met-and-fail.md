---
type: regex
pattern: '^(?=[\s\S]*REQ-1\b[^\n]{0,80}(?:NOT MET|CANNOT TELL))(?=[\s\S]*VERDICT: FAIL)(?![\s\S]*VERDICT: PASS)(?![\s\S]*REQ-1\b[^\n|]*\|\s*\**MET\b)'
---
