---
description: "Probes stacks/elixir mix-deps.md, first trap: 'Use the pessimistic constraint ~> for every hex package.' Passes when the new dep uses ~>."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add the `tesla` HTTP client to this project's dependencies in mix.exs.
