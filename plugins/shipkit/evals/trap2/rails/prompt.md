---
description: "Probes stacks/rails rails.md, second trap: 'Never update_column / update_columns — they skip validations and callbacks.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add Order#mark_reviewed! in app/models/order.rb that stamps reviewed_at with the current time. Legacy orders have no customer_email, and the presence validation must not stop them from being marked.
