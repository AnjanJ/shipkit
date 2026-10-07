---
description: "Probes stacks/rails rails.md, first trap: 'find_each for batch processing, never all.each — it loads the whole table.' Passes when the task iterates in batches."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add lib/tasks/statements.rake with a task statements:send that, for every order whose status is "paid", calls StatementMailer.with(order: order).monthly.deliver_later.
