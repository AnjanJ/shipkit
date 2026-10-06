---
description: "A bug in production that no requirement covers. Passes when the reply names the cause 'requirement missing' and proposes a new requirement."
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

/shipkit:escape Refunds above the charge were accepted in production. A shop owner refunded 25.00 on an order that was charged 20.00 and the gateway paid it out. It should have been refused. We noticed when the gateway's weekly statement did not match our orders. This run is not interactive: you cannot ask me anything.
