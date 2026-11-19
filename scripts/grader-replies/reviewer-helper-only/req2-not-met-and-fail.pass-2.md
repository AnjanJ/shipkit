## Review: refunds against base

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `app/refunds.py:15`, test `tests/test_refunds.py:22` |
| REQ-2 | CANNOT TELL | only the helper `check_amount` is covered (`tests/test_refunds.py:27`); I would need to see `refund` call it |
| REQ-3 (waived) | MET | `README.md:14` |

## Changes beyond the spec
- None.

## Decisions not followed
- None.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 2 MET, 0 NOT MET, 1 CANNOT TELL (1 waived).
VERDICT: FAIL
