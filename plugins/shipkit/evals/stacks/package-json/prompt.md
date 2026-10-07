---
description: "Probes stacks/react package-json.md, first trap: 'Install with the frozen-lockfile flag; never hand-edit a lockfile. Detect the package manager from the lockfile — pnpm-lock.yaml → pnpm — and use only that one.' Passes when STEPS.txt uses pnpm and no other manager."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add `clsx` to the frontend dependencies. There is no network here; if a command cannot run, write the commands you would have run to STEPS.txt, one per line.
