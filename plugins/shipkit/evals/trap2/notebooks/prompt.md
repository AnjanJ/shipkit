---
description: "Probes stacks/ml notebooks.md, second trap: 'Clear outputs before committing (nbstripout, or jupyter nbconvert --clear-output).' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Set the repository up so the notebooks under notebooks/ can be committed without their outputs: add a Makefile with a `notebooks-clean` target that does it for every notebook, to run before each commit. Do not install or run anything; there is no network here.
