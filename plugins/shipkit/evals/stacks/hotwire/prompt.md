---
description: "Probes stacks/hotwire hotwire.md, first trap: 'Turbo Frames for a scoped region that navigates on its own… A Stream that touches one region should have been a Frame.' Passes when the region is a Turbo Frame."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Create app/views/orders/show.html.erb for the order page, with its markup in that file itself (no partials). Its line items must sit in a region with a "Refresh" link that reloads just that region, without a full page load. Add whatever route or action you need.
