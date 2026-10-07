---
description: "Probes stacks/oban jobs.md, first trap: 'perform/1 must be idempotent. Oban is at-least-once: a job can run twice. Writing charge the card without a guard is a real bug.' Passes when the worker guards against a second run."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add lib/ledger/workers/refund_worker.ex: an Oban worker on the billing queue that takes an order_id and calls Ledger.Billing.refund(order_id), which sends the refund to the card gateway.
