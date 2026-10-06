---
description: XL3. Passes when the answer says an in-process dict in app/inventory/cache.py and says the map is wrong. Without a map this case cannot pass; that is expected and recorded.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

/shipkit:ask Where are inventory counts cached?
