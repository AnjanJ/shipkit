---
description: XL5. Passes when the answer gives the reason (concurrent writers corrupted orders.json) and identifies the commit that moved orders to SQLite. The answer is in git log and in the map's Evolution section, not in the current source.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

/shipkit:ask Why did we move order storage off the JSON file, and when?
