---
description: "Audit context usage — find bloated files consuming context window"
user-invocable: true
---

# /context-audit — Context Window Audit

Check what's consuming your Claude Code context and find optimization opportunities.

## File Sizes
!`wc -l CLAUDE.md .claude/rules/*.md .claude/lessons.md 2>/dev/null || echo "no context files found"`

## Process

1. **List all auto-loaded files:**
   - `CLAUDE.md` (always loaded)
   - `.claude/settings.json` / `.claude/settings.local.json`
   - Any memory files (`.claude/memory/`, `.claude/lessons.md`)
   - Parent CLAUDE.md files (home directory, parent dirs)

2. **Count lines for each file** and report:

| File | Lines | Status |
|------|-------|--------|
| CLAUDE.md | 142 | OK |
| .claude/lessons.md | 205 | WARNING — over 100 lines |
| ~/.claude/CLAUDE.md | 45 | OK |

3. **Flag issues:**
   - Any file over 100 lines → suggest trimming or splitting
   - CLAUDE.md over 200 lines → needs immediate pruning
   - Duplicate content across files → suggest consolidation
   - Stale content (references to deleted files, old conventions) → suggest removal
   - Large knowledge bases that could be skills instead (loaded on demand, not always)

4. **Check skill files:**
   - List skills with `user-invocable: true` (loaded on demand — good)
   - List skills with `user-invocable: false` (loaded as context — check if needed)
   - Flag skills over 200 lines → suggest trimming

5. **Report total context budget:**

```
Context Budget Summary:
  Auto-loaded files:    X lines
  Knowledge bases:      Y lines (always loaded)
  Skills:               Z files (loaded on demand)
  Estimated context:    ~N% of budget

  Recommendations:
  - Move lessons.md entries older than 30 days to archive
  - Split CLAUDE.md conventions into a knowledge base skill
  - Remove unused knowledge base: code-review-standards
```

## Tips for Reducing Context

- Move stable rules to knowledge base skills (loaded only when relevant)
- Archive old lessons — keep only recent, actionable ones
- Use `disable-model-invocation: true` on mechanical skills (test, release)
- Remove comments and examples from CLAUDE.md — keep it terse
