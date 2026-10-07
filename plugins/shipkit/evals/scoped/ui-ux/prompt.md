---
description: "Probes rules/ui-ux.md, first trap: 'Semantic structure first — a div with a click handler is not a button.' Passes when the rows link with <a href>, not a click handler on a list item."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

In index.html, make each row of the recent-orders list open its order page at orders/<id>.html when the user activates it.
