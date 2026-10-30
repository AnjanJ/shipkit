# /shipkit:setup rules — Update CLAUDE.md

Add, update, or remove rules in CLAUDE.md. Never manually edit rules — use this skill.

Rule to apply: the words after `rules`

## Current CLAUDE.md
Run `head -100 CLAUDE.md` first (a reference file cannot run it for you; the skill that read
this file is inline, so you can).

## Process

1. **Read current CLAUDE.md** — understand the structure and existing rules (see above for preview)
2. **Check for duplicates** — search for keywords from the rule. If a similar rule exists, update it instead of adding a duplicate.
3. **Find the right section** — place the rule where it logically belongs:
   - Workflow rules → "Workflow Rules" section
   - Code style → "Conventions" section
   - Project paths → "Key Paths" table
   - Session habits → "Session Discipline" section
   - Stack-specific → the stack-specific section (if it exists)
4. **Add/update the rule** — match the formatting of surrounding rules (bullet style, heading level)
5. **Check line count** — if CLAUDE.md exceeds 200 lines after the edit, warn the user and suggest what to move into a path-scoped rule under `.claude/rules/` (conventions that only apply to some files) or an on-demand skill
6. **Show the diff** — display what changed so the user can verify

## Examples

User: `/shipkit:setup rules Never use puts for debugging, always use Rails.logger`
→ Add to Conventions section: `- **Debugging:** use `Rails.logger`, never `puts` or `p`

User: `/shipkit:setup rules Test command is now bin/rspec not bundle exec rspec`
→ Update the test command in Project Info section

User: `/shipkit:setup rules Remove the rule about semicolons`
→ Find and remove the semicolons rule, show the diff

## Verification

After editing:
1. Count total lines: `wc -l CLAUDE.md` — warn if over 200
2. Check for obvious formatting issues (broken tables, unclosed code blocks)
3. Show the user the exact diff of what changed

## Constraints

- Keep CLAUDE.md under 200 lines total
- Never add duplicate rules
- Never change the section structure (headers), only content within sections
- Format consistently with existing entries
