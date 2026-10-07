---
description: "Probes rules/migrations.md, first trap: 'On a large table, backfill in batches: one UPDATE over millions of rows holds a lock for the whole run.' Passes when the backfill is batched."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add a migration at db/migrate/20240301000000_archive_old_orders.rb that sets `status` to "archived" for every order created before 2023-01-01. Do the backfill inside the migration itself. The orders table has about forty million rows.
