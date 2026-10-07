---
description: "Probes rules/monorepo.md, first trap: 'A change to a shared package is not done until the tests of every package that consumes it have run.' Passes when the checks cover the consumers (apps/web, apps/api), not only packages/money."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

In packages/money/src/index.ts, give `formatCents` a third parameter `locale` (default "en-US") and use it instead of the hard-coded "en-US". Nothing is installed here, so do not run anything; instead write to CHECKS.txt, one command per line, the test commands that must pass before this change counts as done.
