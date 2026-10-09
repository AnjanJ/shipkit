---
description: "Probes rules/migrations.md, second trap: 'An index on a high-traffic table needs CONCURRENTLY or the ORM's equivalent, or writes block until it is built.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add a migration at db/migrate/20240302000000_index_orders_on_customer_email.rb that adds an index on orders.customer_email. The orders table is large and takes writes all day.
