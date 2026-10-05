---
description: "REQ-2 has no code and no test. Passes when the reply marks REQ-2 NOT MET and gives VERDICT: FAIL."
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Agent, Bash]
---

Start the shipkit:reviewer agent on the spec `refunds` with the base ref `base`. Give it only those two things. When it answers, show me its reply in full and unchanged, and add nothing after it.
