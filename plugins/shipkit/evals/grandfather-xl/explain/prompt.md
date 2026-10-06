---
description: XL2. Passes when the answer names apply_vat, app/billing/tax.py and the call in app/orders/checkout.py.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

/shipkit:ask How is VAT applied at checkout?
