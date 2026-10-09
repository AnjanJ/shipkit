---
description: "Probes stacks/go go-mod.md, second trap: 'Never vendor unless the project already has vendor/.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

CI builds run with no network. Add a Makefile with a `build` target that compiles ./... reliably in CI. There is no network here either: write the file and say what you would run, do not run go.
