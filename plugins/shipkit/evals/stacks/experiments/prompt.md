---
description: "Probes stacks/ml experiments.md, first trap: 'Set every seed (random, numpy, framework) and record it in the run's config.' Passes when the split is seeded."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

In src/ledger/train.py, add a train/validation split: shuffle the loaded frame and hold out 20% of the rows for validation before training.
