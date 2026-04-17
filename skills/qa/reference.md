# QA — Reference Material

## Framework-Specific Test Notes

**RSpec:** Use `let`, `before`, `shared_examples` where appropriate. Prefer `have_attributes` over individual matchers.

**Minitest:** Use `setup`, `test "description"` format. Keep assertions simple.

**ExUnit:** Use `setup`, `describe`, `test` blocks. Use `assert_raise` for error cases.

**Jest/Vitest:** Use `describe`, `it`, `beforeEach`. Use `jest.mock()` for dependencies.

## QA Report Template

### Files Under Test
| File | Tests Added | Coverage |
|------|------------|----------|
| ... | ... | ... |

### Findings
| # | Severity | Description | Status |
|---|----------|-------------|--------|
| 1 | CRITICAL | Missing auth check | FIXED |
| ... | ... | ... | ... |

### Core Values Audit
| Value | Status | Notes |
|-------|--------|-------|
| Security (no injection, XSS, CSRF) | PASS/WARN/FAIL | ... |
| Performance (no N+1, bounded queries) | PASS/WARN/FAIL | ... |
| Error handling (no silent failures) | PASS/WARN/FAIL | ... |
| Data integrity (validations, constraints) | PASS/WARN/FAIL | ... |
| Compatibility (no breaking changes) | PASS/WARN/FAIL | ... |

### Rationalization Check

Before writing a verdict, check yourself against these:

| Excuse | Reality |
|--------|---------|
| "Tests pass, so it's fine" | Tests passing is necessary but not sufficient. Did you check edge cases? |
| "It's a small change, low risk" | Small changes in CRITICAL files are high risk. Check the risk table. |
| "No time for the bizarre/adversarial category" | That's where production bugs live. At least cover CRITICAL files. |
| "Coverage looks good enough" | Did you run the tests and see the output? Or are you guessing? |
| "Ship it, we can fix later" | "Later" means "never." Fix known issues before shipping. |

**Verdict:** SHIP IT / FIX AND RE-TEST / NEEDS REWORK

**Stats:** X files reviewed, Y tests added, Z findings (A critical, B major, C minor)
