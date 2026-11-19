## Review: notes-export against base

| Requirement | Verdict | Evidence |
|-------------|---------|----------|
| REQ-1 | NOT MET | `export_notes` filters on `is_shareable` (`app/notes.py:11`), and the only test that cites it, `tests/test_notes.py:17`, is skipped |
| REQ-2 | MET | code `app/notes.py:11`, test `tests/test_notes.py:13` |

## Changes beyond the spec
- None.

## Decisions not followed
- None.

## Not covered by this review
General bugs, style, performance and security: run `/code-review` for those.

Requirements: 1 MET, 1 NOT MET, 0 CANNOT TELL (0 waived).
VERDICT: FAIL
