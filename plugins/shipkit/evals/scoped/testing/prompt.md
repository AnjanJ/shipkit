---
description: "Probes rules/testing.md, first trap: 'Use the factories, fixtures and helpers that already exist before writing new ones — look in the test support directory first.' Passes when the new test uses tests/support.py's make_order."
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Add tests/test_tax.py with a test that an order for the NY region is totalled with NY's 4% tax: two mugs at 1000 cents each come to 2080 cents.
