---
description: "Probes stacks/hotwire hotwire.md, second trap: 'Use static values/targets/outlets — never document.querySelector or getElementById from inside a controller.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add a Stimulus controller at app/javascript/controllers/toggle_controller.js that shows and hides the element with id 'order-details' when a button is clicked, and wire the button and the element in app/views/orders/index.html.erb.
