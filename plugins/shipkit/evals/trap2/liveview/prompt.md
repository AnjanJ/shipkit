---
description: "Probes stacks/liveview liveview.md, second trap: 'Put URL-derived state in handle_params/3, not mount/3 — it is what runs on push_patch/live_patch.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

In lib/ledger_web/live/orders_live.ex, let the orders list be filtered by status through the URL (for example ?status=paid), so the filter survives a reload and can be changed with push_patch.
