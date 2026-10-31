---
description: "Every requirement is met and the code does what a live decision turned down. Passes when the reply gives VERDICT: FAIL, marks no requirement NOT MET, and names the decision contradicted."
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Agent, Bash]
---

Start the shipkit:reviewer agent on the spec `refunds` with the base ref `base`. Give it only those two things. When it answers, show me its reply in full and unchanged, and add nothing after it.
