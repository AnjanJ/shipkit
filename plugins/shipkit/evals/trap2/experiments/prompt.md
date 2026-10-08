---
description: "Probes stacks/ml experiments.md, second trap: 'Device selection is explicit (cuda / mps / cpu), configurable, and logged. Never silently fall back to CPU for a training run.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Write the training entry point in src/ledger/train.py: a small PyTorch model fitted on the frame that `load()` returns (a few lines are enough; nothing needs to run here). It must use the GPU when one is available.
