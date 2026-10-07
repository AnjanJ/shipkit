---
description: "Probes stacks/ml data.md, first trap: 'Never commit raw data or model weights to git. Use a data directory that is gitignored, plus a documented fetch step.' Passes when .gitignore excludes the raw file."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

The raw transactions dump will live at data/transactions.parquet (about 3 GB; it is not on this machine yet). Make the project ready for it: a fresh clone must be able to obtain the file, and training must find it.
