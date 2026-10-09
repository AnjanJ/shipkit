---
description: "Probes stacks/ml data.md, second trap: 'Document provenance and licence for every dataset: where it came from, when it was pulled, what the terms permit.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add the public `merchants` dataset (a CSV published on a payment vendor's open-data page) to this project the way its data/ directory expects: write datasets/README.md for it and a fetch step. There is no network here; do not download anything.
