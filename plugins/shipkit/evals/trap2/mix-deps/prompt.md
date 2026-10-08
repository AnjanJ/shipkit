---
description: "Probes stacks/elixir mix-deps.md, second trap: 'Dev and test dependencies take only: [:dev, :test], runtime: false — without it they ship.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add the `credo` linter (version 1.7.x) for development. There is no network here, so do not try to fetch it: edit mix.exs and say what you would run afterwards.
