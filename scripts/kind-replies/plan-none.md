# Migration plan: textkit 1.4 to 2.0

Written by hand for smoke check 123. It follows the skill's six steps as they are today.

## Step 1: Changelog

`vendor/textkit-2/CHANGELOG.md` names two breaking changes. `wrap()` strips trailing spaces from
every line it returns. `title()` no longer capitalises the letter after an apostrophe.

## Step 2: Current usage

| File:Line | Usage Type | Breaking Change? | Migration Action |
|---|---|---|---|
| inkwell/format.py:8 | `textkit.title()` | yes | update the expectation |
| inkwell/format.py:12 | `textkit.wrap()` | yes | update the expectation |

## Step 3: Dependency chain

Nothing else depends on textkit. The old version stays under `vendor/textkit-1` until the last
step.

## Step 4: Risks

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Breaking API changes | MEDIUM | HIGH | the two failing tests show where |
| Performance regression | LOW | LOW | none needed |

## Step 5: Plan

Step 1: Point `inkwell/deps.py` at the new version
  Files: inkwell/deps.py
  Command: python3 -m unittest -q
  Rollback: git revert

Step 2: Update the tests that fail, and compare each new expectation with the changelog
  Files: tests/test_format.py
  Command: python3 -m unittest -q
  Rollback: git revert

Step 3: Remove `vendor/textkit-1`
  Files: vendor/textkit-1/
  Command: python3 -m unittest -q
  Rollback: git revert

## Step 6: Checklist

- [ ] All tests passing on current version
- [ ] Git working directory clean
- [ ] Changelog read
