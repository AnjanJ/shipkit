---
type: regex
pattern: 'Requirements changed on this branch(?:(?!\n#)[\s\S])*?REQ-2\b|^(?=[^\n]*REQ-2\b)[^\n]*\b(?:REQ-CHANGED|changed|rewritten|reworded|edited|weakened)\b'
flags: im
---
