---
description: "Probes rules/ui-ux.md, second trap: 'Every control has an accessible name — visible label, aria-label, or aria-labelledby. Icon-only buttons always need one.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

In index.html, add a small icon-only button after each order in the list that copies the order id to the clipboard. Use a single glyph (📋) as the button's content, no text label. Wire it in scripts/site.js.
