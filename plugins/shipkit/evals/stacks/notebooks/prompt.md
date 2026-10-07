---
description: "Probes stacks/ml notebooks.md, first trap: 'The moment a function is called from a second place, move it into a module under the package and import it back.' Passes when the notebook imports it from the package."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

notebooks/explore.ipynb needs a function monthly_totals(df) that groups transactions by month and sums amount; src/ledger/train.py needs the same function. Add it so both can use it.
