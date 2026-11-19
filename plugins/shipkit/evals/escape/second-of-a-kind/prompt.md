---
description: "Passes when the reply drafts a check item with a trigger and both escapes on its From: line."
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

/shipkit:escape A refund of a negative amount was accepted in production. A shop owner entered -5.00 as a refund on an order charged 20.00 and the gateway took 5.00 more from the customer. It should have been refused. We noticed from the customer's complaint. This run is not interactive: you cannot ask me anything.
