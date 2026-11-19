## Review: refunds against base

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `app/refunds.py:9`, test `tests/test_refunds.py:22` |
| REQ-2 | CANNOT TELL | the earlier review marked it NOT MET; only the helper `check_amount` is covered, so I can't mark it met |
| REQ-3 (waived) | MET | `README.md:14` |

## Changes beyond the spec
- None.

## Decisions not followed
- None.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 2 MET, 0 NOT MET, 1 CANNOT TELL (1 waived).
VERDICT: FAIL
