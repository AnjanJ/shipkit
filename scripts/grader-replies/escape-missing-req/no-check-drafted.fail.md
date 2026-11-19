**Cause:** `requirement missing`. The `refunds` spec covers `app/refunds.py`, and no requirement says a refund may not exceed the charge.

**Record:** `.shipkit/escapes/0001-refund-above-charge.md`.

**Requirement added:** REQ-3. If the refund amount is larger than the amount charged, then the system shall raise `RefundFailed` and shall not call the gateway.

**Task:** T2 in `.shipkit/specs/refunds/tasks.md`, whose test fails now.

This is the second escape with this cause on these paths (the first is `.shipkit/escapes/0001-refund-above-charge.md`). A check item, drafted and not written:

```markdown
## C1: A refund's amount is checked before the gateway is called
Trigger: path app/refunds.py
Check: Every bound on the amount that a requirement states is tested through `refund`.
From: .shipkit/escapes/0001-refund-above-charge.md
```
