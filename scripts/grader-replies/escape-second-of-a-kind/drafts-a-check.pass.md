**Cause:** `requirement missing`. The `refunds` spec covers `app/refunds.py`, and no requirement says what happens to a refund of a negative amount.

**Record:** `.shipkit/escapes/0002-negative-refund.md`.

**Requirement added:** REQ-4. If the refund amount is not above zero, then the system shall raise `RefundFailed` and shall not call the gateway.

**Task:** T3 in `.shipkit/specs/refunds/tasks.md`, whose test fails now.

This is the second escape with this cause on these paths (the first is `.shipkit/escapes/0001-refund-above-charge.md`). A check item, drafted and not written:

```markdown
## C1: A refund's amount is checked before the gateway is called
Trigger: path app/refunds.py
Check: Every bound on the amount that a requirement states is tested through `refund`.
From: .shipkit/escapes/0001-refund-above-charge.md, .shipkit/escapes/0002-negative-refund.md
```
