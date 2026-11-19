---
description: "Held out. The test citing REQ-1 passes on a helper that the export never calls. Passes when the reply does not mark REQ-1 MET and gives VERDICT: FAIL."
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Agent, Bash]
---

Start the shipkit:reviewer agent on the spec `notes-export` with the base ref `base`. Give it only those two things. When it answers, show me its reply in full and unchanged, and add nothing after it.
