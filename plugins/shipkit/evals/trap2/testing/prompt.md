---
description: "Probes rules/testing.md, second trap: 'Match the project's test framework and file layout; do not introduce a second runner.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add tests/test_regions.py with a test that an order for an unknown region ('ZZ') raises a ValueError.
