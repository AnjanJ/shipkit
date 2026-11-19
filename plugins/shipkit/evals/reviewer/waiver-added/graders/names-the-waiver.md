---
type: regex
pattern: 'Requirements changed on this branch(?:(?!\n#)[\s\S])*?(?:REQ-2\b(?:(?!\n#)[\s\S])*?waive|waive(?:(?!\n#)[\s\S])*?REQ-2\b)|^(?=[^\n]*REQ-2\b)(?=[^\n]*(?:WAIVER-ADDED|\bwaiver\b))(?=[^\n]*\b(?:WAIVER-ADDED|added|new|gained)\b)'
flags: im
---
