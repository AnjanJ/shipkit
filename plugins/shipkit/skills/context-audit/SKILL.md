---
description: "Audit context usage — what shipkit and your project actually load into every session, and where the bloat is"
user-invocable: true
context: fork
---

# /context-audit — Context Window Audit

Report what this project loads into Claude's context at session start and on every file edit,
and where it can be trimmed. **For real token numbers, the user should run Claude Code's
built-in `/context`** — this skill explains *what* is loading and *why*; it does not estimate
percentages.

## Sizes on disk
!`f=$(wc -l CLAUDE.md .claude/CLAUDE.md 2>/dev/null; find .claude/rules -name '*.md' 2>/dev/null | xargs wc -l 2>/dev/null); [ -n "$f" ] && echo "$f" || echo "no CLAUDE.md or .claude/rules found"`

## What actually loads (Claude Code facts — reason from these, not from guesses)

| Source | When it loads | Notes |
|--------|---------------|-------|
| `CLAUDE.md` (project root, `.claude/CLAUDE.md`, and parent dirs up to `~/.claude/CLAUDE.md`) | Every session, in full | The main always-on cost |
| `.claude/rules/**/*.md` **without** `paths:` frontmatter | Every session, in full | Always-on rules (shipkit's `shipkit.md`, `spec-driven.md`, `decisions.md` if installed by `/setup`) |
| `.claude/rules/**/*.md` **with** `paths:` frontmatter | Only when Claude touches a matching file | Path-scoped; near-zero cost until triggered |
| Shipkit session hook output | Every session | One `plugin root` line, plus the three always-on rules **only if** `.claude/rules/shipkit/` is not installed |
| Skill **descriptions** (every registered skill, plugin and project) | Every session | ~1 line each; shipkit's 20 skills ≈ 1.2k tokens |
| Skill **bodies** (`SKILL.md` + its references) | Only when the skill is invoked | `user-invocable: false` knowledge bases behave the same — description always, body on demand |
| MCP tool schemas | Deferred until first use (tool search) | Not a per-session cost |
| Claude Code's own project memory (`~/.claude/projects/<dir>/memory/`) | Its index every session | Native; shipkit ≤ 2.8's `.claude/lessons.md` is legacy — migrate and delete it |

## Process

1. **List the always-on files** — `CLAUDE.md` chain, always-on rules under `.claude/rules/`,
   the hook's output — and report their line counts in a table:

| File | Lines | Loads | Status |
|------|-------|-------|--------|
| CLAUDE.md | 142 | every session | OK |
| .claude/rules/shipkit/shipkit.md | 60 | every session | OK (installed by /setup) |
| .claude/rules/shipkit/testing.md | 12 | on test files | path-scoped |
| .claude/lessons.md | 41 | every session | legacy (shipkit ≤ 2.8) — migrate into rules, then delete |

2. **Flag issues:**
   - `CLAUDE.md` over 200 lines → prune; move stable detail into path-scoped rules or an
     on-demand skill
   - Any always-on rule over 100 lines → split, or give it `paths:` so it becomes path-scoped
   - `.claude/lessons.md` present → legacy; migrate entries via `/shipkit:update-rules`, then delete it
   - Content duplicated between `CLAUDE.md` and a rule → keep one copy
   - Stale content (references to deleted files, old commands) → remove
   - Always-on rules that only matter for some files → add `paths:` frontmatter

3. **Check skills** (`.claude/skills/*/SKILL.md`): count them (each costs its description every
   session), and flag any body over 200 lines as worth trimming — it loads in full when invoked.

4. **Report** a short summary and the three highest-impact recommendations. End by suggesting
   `/context` for the exact token breakdown.

## Tips for Reducing Context

- Path-scope anything that only applies to some files (`paths:` frontmatter on the rule)
- Move stable reference material into a `user-invocable: false` skill — description-only cost
  until it is needed
- Keep `CLAUDE.md` to project facts (purpose, stack, commands, key paths); let rules carry
  conventions
- Let Claude Code's native project memory hold corrections; keep CLAUDE.md for facts and rules for conventions
- Use `disable-model-invocation: true` on mechanical skills (release, deploy-check) so their
  descriptions are not offered to the model every turn
