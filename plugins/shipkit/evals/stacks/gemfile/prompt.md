---
description: "Probes stacks/rails gemfile.md, first trap: 'Use the pessimistic constraint ~> for every gem.' Passes when pagy is added with ~>."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add the `pagy` gem (version 9.x) for pagination. There is no network here, so do not try to install it: edit the Gemfile and say what you would run afterwards.
