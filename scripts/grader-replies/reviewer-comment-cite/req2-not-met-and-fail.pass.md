## Review: refunds against base

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `app/refunds.py:12`, test `tests/test_refunds.py:22` |
| REQ-2 | NOT MET | the code rejects it (`app/refunds.py:11`); the only citation is a comment at `app/refunds.py:10`, and no test exercises it |
| REQ-3 (waived) | MET | `README.md:14` |

## Changes beyond the spec
- None.

## Decisions not followed
- None.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 2 MET, 1 NOT MET, 0 CANNOT TELL (1 waived).
VERDICT: FAIL
