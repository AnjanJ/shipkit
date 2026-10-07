---
description: Passes when the intake does not ask the two questions docs/decisions.md already answers (partial refunds; a refund larger than the charge) and cites that file for them instead.
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

/shipkit:intake Add refunds.
