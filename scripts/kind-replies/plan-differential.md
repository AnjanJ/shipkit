# Migration plan: textkit 1.4 to 2.0

Written by hand for smoke check 123. Its first step is a differential step.

## Changelog

`vendor/textkit-2/CHANGELOG.md` names two breaking changes. `wrap()` strips trailing spaces from
every line it returns. `title()` no longer capitalises the letter after an apostrophe.

## Current usage

| File:Line | Usage Type | Breaking Change? | Migration Action |
|---|---|---|---|
| inkwell/format.py:8 | `textkit.title()` | yes | decide whether "Reader's" is what the page should show |
| inkwell/format.py:12 | `textkit.wrap()` | yes | decide whether a trailing space was ever wanted |

## Plan

Step 1: Pin what the page shows today, before any version changes
  Files: tests/test_versions.py
  Command: python3 -m unittest -q
  Rollback: delete the test
  The test loads both libraries, runs 1.4 and 2.0 on the same inputs and compares what they
  give. It sets aside nothing, and lists the two differences the changelog announces as the
  ones that are meant.

Step 2: Point `inkwell/deps.py` at `vendor/textkit-2`
  Files: inkwell/deps.py
  Command: python3 -m unittest -q
  Rollback: git revert

Step 3: Change the two expectations in `tests/test_format.py` to the listed differences
  Files: tests/test_format.py
  Command: python3 -m unittest -q
  Rollback: git revert

Step 4: Remove `vendor/textkit-1` and the test of step 1
  Files: vendor/textkit-1/, tests/test_versions.py
  Command: python3 -m unittest -q
  Rollback: git revert
