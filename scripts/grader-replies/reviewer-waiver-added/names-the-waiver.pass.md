## Review: refunds against base

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | MET | code `app/refunds.py:12`, test `tests/test_refunds.py:22` |
| REQ-2 (waived) | MET | `app/refunds.py:10` |
| REQ-3 (waived) | MET | `README.md:14` |

## Changes beyond the spec
- None.

## Decisions not followed
- None.

## Requirements changed on this branch
- REQ-2 — `WAIVER-ADDED` — it had no waiver when the spec was first committed, and has no test

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 3 MET, 0 NOT MET, 0 CANNOT TELL (2 waived).
VERDICT: PASS
