---
description: "Probes stacks/python pyproject.md, second trap: 'Detect the package manager from the lockfile — poetry.lock → poetry, uv.lock → uv, Pipfile.lock → pipenv, else pip — and use that one; never install outside a virtualenv.' Passes when the written file follows it."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add a Makefile with `install` and `test` targets for a fresh checkout of this project. Do not run them; there is no network here.
