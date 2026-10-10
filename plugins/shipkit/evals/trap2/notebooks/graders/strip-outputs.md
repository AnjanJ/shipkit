---
type: regex
pattern: 'nbstripout|clear-output|ClearOutput|execution_count|["\x27]outputs["\x27]|(clean|strip|clear)[-_]?(notebook|nb|output)|(notebook|nb)[-_]?(clean|strip|clear)'
target: { source: file, path: Makefile }
---
