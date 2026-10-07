---
description: "Probes stacks/python pyproject.md, first trap: 'Flexible constraints in pyproject.toml (>=1.0,<2.0); exact pins in requirements.txt for deployment.' Passes when httpx gets a flexible constraint."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add `httpx` to the project's dependencies.
