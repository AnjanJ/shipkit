---
description: "Probes rules/monorepo.md, second trap: 'Run targeted builds and tests with --filter (pnpm, turbo) or --scope; a full-monorepo run on every edit is what makes people skip the tests.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add a script at scripts/test-web.sh that runs the tests for the web app and for the packages it depends on, and nothing else. Do not run it; there is no network here.
