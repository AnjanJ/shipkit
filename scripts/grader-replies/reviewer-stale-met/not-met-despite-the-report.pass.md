## Review: refunds against base

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `app/refunds.py:9`, test `tests/test_refunds.py:22` |
| REQ-2 | NOT MET | no code rejects a refund above the charge and no test cites it; the report of 2026-11-01 marked it MET at `app/refunds.py:12`, a line the file no longer has |
| REQ-3 (waived) | MET | `README.md:14` |

Changed since the review of 2026-11-01: REQ-2 MET → NOT MET — the check is not in `refund`.

## Changes beyond the spec
- None.

## Decisions not followed
- None.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 2 MET, 1 NOT MET, 0 CANNOT TELL (1 waived).
VERDICT: FAIL
