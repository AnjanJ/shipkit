**Cause:** `requirement missing`. The `refunds` spec covers `app/refunds.py`, and no requirement says a refund may not exceed the charge.

**Record:** `.shipkit/escapes/0001-refund-above-charge.md`.

**Requirement added:** REQ-3. If the refund amount is larger than the amount charged, then the system shall raise `RefundFailed` and shall not call the gateway.

**Task:** T2 in `.shipkit/specs/refunds/tasks.md`, whose test fails now.
