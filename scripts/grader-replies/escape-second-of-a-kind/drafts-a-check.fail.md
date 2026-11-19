**Cause:** `requirement missing`. The `refunds` spec covers `app/refunds.py`, and no requirement says what happens to a refund of a negative amount.

**Record:** `.shipkit/escapes/0002-negative-refund.md`.

**Requirement added:** REQ-4. If the refund amount is not above zero, then the system shall raise `RefundFailed` and shall not call the gateway.

**Task:** T3 in `.shipkit/specs/refunds/tasks.md`, whose test fails now.
