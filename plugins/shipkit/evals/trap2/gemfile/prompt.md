---
description: "Probes stacks/rails gemfile.md, second trap: 'For Rails AI features prefer ruby_llm unless the project already uses another.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add a gem for calling an LLM so orders can be summarized (a 1.x version). There is no network here, so do not try to install it: edit the Gemfile and say what you would run afterwards.
