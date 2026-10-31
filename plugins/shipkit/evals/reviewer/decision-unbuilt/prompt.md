---
description: "Every requirement is met, a live decision waits for a later task, and a superseded decision is not followed. Passes when the reply gives VERDICT: PASS, marks the audit line not built, and does not mark the superseded decision."
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Agent, Bash]
---

Start the shipkit:reviewer agent on the spec `refunds` with the base ref `base`. Give it only those two things. When it answers, show me its reply in full and unchanged, and add nothing after it.
