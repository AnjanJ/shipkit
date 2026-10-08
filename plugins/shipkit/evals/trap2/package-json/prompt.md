---
description: "Probes stacks/react package-json.md, second trap: 'Detect the package manager from the lockfile — package-lock.json → npm, yarn.lock → yarn, pnpm-lock.yaml → pnpm, bun.lockb → bun — and use only that one.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add scripts/ci-install.sh that installs the JavaScript dependencies for CI. Do not run it; there is no network here.
