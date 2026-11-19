## Review: refunds against base

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `app/refunds.py:15`, test `tests/test_refunds.py:22` |
| REQ-2 | NOT MET | `tests/test_refunds.py:27` cites it and calls only `check_amount`; `refund` (`app/refunds.py:15`) never calls `check_amount`, so a refund above the charge reaches the gateway |
| REQ-3 (waived) | MET | `README.md:14` |

## Changes beyond the spec
- None.

## Decisions not followed
- None.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 2 MET, 1 NOT MET, 0 CANNOT TELL (1 waived).
VERDICT: FAIL
