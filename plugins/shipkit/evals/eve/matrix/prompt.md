---
description: "P5, a version matrix asked in words, with neither --all nor matrix. Passes when eve's answer gives each installed version from its lockfile, the declared constraints, and insight unused. reports.md is the only place that asks for both."
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

/shipkit:ask We're planning a Stripe upgrade. Across all my projects, which version of the Stripe library is each one on?
SHIPKIT_HOME for this run is the `shipkit-home` directory inside the working directory (use its absolute path); the project registry is its `project-registry.md`. This run is not interactive: you cannot ask me anything.
