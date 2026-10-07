---
description: "Probes rules/dependencies.md, first trap: 'Never use `*` or an unpinned version in a dependency file.' Passes when the requests entry carries a version constraint."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add the `requests` library to this project's dependencies in pyproject.toml.
