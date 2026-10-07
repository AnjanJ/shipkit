---
type: regex
pattern: '^(?![\s\S]*<(li|div|span|ul)[^>]*onclick)[\s\S]*<a [^>]*href="/?orders/'
target: { source: file, path: index.html }
---
