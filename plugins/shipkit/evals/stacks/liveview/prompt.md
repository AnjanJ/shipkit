---
description: "Probes stacks/liveview liveview.md, first trap: 'mount/3 runs twice — guard PubSub subscriptions, timers and registration with if connected?(socket).' Passes when the subscription is guarded."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

In lib/ledger_web/live/orders_live.ex, subscribe the LiveView to the "orders" PubSub topic when it mounts, and handle {:order_created, order} by prepending the order to @orders.
