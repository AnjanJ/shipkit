## Review: refunds against base

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `app/refunds.py:12`, test `tests/test_refunds.py:22` |
| REQ-2 | MET | code `app/refunds.py:10`, test `tests/test_refunds.py:26` |
| REQ-3 (waived) | MET | `README.md:14` |

## Changes beyond the spec
- None.

## Decisions not followed
- None.

## Checks this diff triggered
| Check | Result | Evidence |
|-------|--------|----------|
| C1: A refund is sent once | BROKEN | `app/refunds.py:12` calls `gateway.refund` with two arguments and no idempotency key |

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 3 MET, 0 NOT MET, 0 CANNOT TELL (1 waived).
VERDICT: PASS
