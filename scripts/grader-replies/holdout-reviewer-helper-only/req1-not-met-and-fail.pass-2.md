## Review: notes-export against base

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | CANNOT TELL | the test at `tests/test_notes.py:17` covers `is_shareable` only; I would need to see the export use it |
| REQ-2 | MET | code `app/notes.py:11`, test `tests/test_notes.py:13` |

## Changes beyond the spec
- None.

## Decisions not followed
- None.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 1 MET, 0 NOT MET, 1 CANNOT TELL (0 waived).
VERDICT: FAIL
