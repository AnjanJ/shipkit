## Review: refunds against base

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `app/refunds.py:12`, test `tests/test_refunds.py:22` |
| REQ-2 | NOT MET | the code rejects it (`app/refunds.py:10`), and the only test that cites it, `tests/test_refunds.py:27`, is skipped (`@unittest.skip`), so nothing proves it |
| REQ-3 (waived) | MET | `README.md:14` |

## Changes beyond the spec
- None.

## Decisions not followed
- None.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 2 MET, 1 NOT MET, 0 CANNOT TELL (1 waived).
VERDICT: FAIL
