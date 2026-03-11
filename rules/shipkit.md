# Shipkit Plugin Rules

## Lessons Memory
- At session start, read `.claude/lessons.md` if it exists
- When the user corrects you or you discover a project-specific pattern, append a dated one-liner to `.claude/lessons.md` (e.g., `- 2026-03-11: Always use factory_bot, never fixtures`)
- If `.claude/lessons.md` exceeds 30 lines, alert the user and suggest consolidating: graduate recurring lessons to CLAUDE.md rules via `/shipkit:update-rules`, remove redundant entries

## Setup Awareness
- If the project has no CLAUDE.md and the user mentions setting up or configuring, suggest `/shipkit:setup`
- If the user wants to remove shipkit configuration, suggest `/shipkit:unsetup`
- User guide: https://codeberg.org/AnjanJ/shipkit/src/branch/main/GUIDE.md
