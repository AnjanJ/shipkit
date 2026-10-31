---
type: regex
pattern: '^(?=[\s\S]*audit line[^\n]*not built)(?=[\s\S]*VERDICT: PASS)(?![\s\S]*VERDICT: FAIL)(?![\s\S]*\n- [^\n]*(?<!not )contradicted)(?![\s\S]*\n- [^\n]*app/billing\.py[^\n]*(?:contradicted|not built))'
---
