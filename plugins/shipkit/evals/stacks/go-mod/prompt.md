---
description: "Probes stacks/go go-mod.md, first trap: 'Use go get <module>@latest to add or update — never edit go.mod by hand.' Passes when STEPS.txt shows go get for the module."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add github.com/spf13/cobra as a dependency of this module. There is no network here; if a command cannot run, write the commands you would have run to STEPS.txt, one per line.
