---
description: "5-phase QA workflow: reconnaissance, probing questions, test plan, spec writing, execution"
user-invocable: true
argument-hint: "[<file-or-module>|all]"
---

# /qa — Quality Assurance Workflow

Run this skill to perform thorough QA on recent changes or a specific file.

## Recently Changed Files
!`git diff --name-only HEAD~1 2>/dev/null | head -20 || echo "no recent changes detected"`

## Phase 1: Reconnaissance

1. **Detect test framework** by checking for:
   - `Gemfile` with rspec/minitest → RSpec or Minitest
   - `mix.exs` → ExUnit
   - `package.json` with jest/vitest → Jest or Vitest
   - `playwright.config` → Playwright
2. **Identify changed files** — if `$ARGUMENTS` is a file path, use that; otherwise run `git diff --name-only HEAD~1`
3. **Classify each file** by risk level:
   - CRITICAL: auth, payments, data models, shared utilities, API endpoints
   - HIGH: business logic, services, controllers
   - MEDIUM: views, serializers, helpers, config
   - LOW: docs, comments, formatting
4. **Read each changed file** and its existing tests (if any)
5. **Build a context table:**

| File | Type | Risk | Existing Tests? |
|------|------|------|----------------|
| ... | ... | ... | ... |

## Phase 2: Interrogation

Before writing any tests, ask 3-8 probing questions using AskUserQuestion.
Group questions — don't ask one at a time.

**Good questions** (risk-focused):
- "This touches the payment flow — should I test refund edge cases?"
- "The new validation rejects blank input. What about unicode-only strings?"
- "This service calls an external API — should I mock it or test integration?"

**Bad questions** (don't ask these):
- "What does this code do?" (read it yourself)
- "Should I write tests?" (yes, always)
- "What test framework should I use?" (detect it)

## Phase 3: Test Plan

Present a structured test plan BEFORE writing any specs.
Organize by category:

### Test Categories

1. **Happy Path** — expected inputs produce expected outputs
2. **Edge Cases** — boundary values, empty inputs, max values, nil/null
3. **Error Cases** — invalid input, network failures, timeouts, permission denied
4. **Bizarre/Adversarial** — SQL injection strings, script tags, emoji, 10MB strings, concurrent access
5. **Performance** — N+1 queries, unbounded collections, slow queries (only for CRITICAL/HIGH risk)
6. **Integration** — interactions between components (only when multiple files changed)

Present as a table:

| # | Category | Test Description | Risk Level |
|---|----------|-----------------|------------|
| 1 | Happy Path | Creates record with valid params | HIGH |
| ... | ... | ... | ... |

Wait for user approval before proceeding.

## Phase 4: Spec Writing

Write specs following these patterns:

- **One assertion per test** (when practical)
- **Descriptive names** — `it "returns 404 when record not found"` not `it "works"`
- **Arrange-Act-Assert** structure
- **No mystery guests** — all test data visible in the test
- **Test behavior, not implementation** — don't test private methods directly
- **Use factories/fixtures** appropriate to the framework
- **Group by behavior** with `describe`/`context` blocks

### Test Code Quality

Tests are code too — apply the same principles:
- **KISS:** No over-engineered test helpers. If setup is >10 lines, simplify the test or the code under test.
- **YAGNI:** Don't test scenarios that can't happen. Don't add tests "just in case" for impossible states.
- **DRY (with restraint):** Prefer clear duplication over clever shared examples. A test should be readable top-to-bottom without jumping to 3 helper files.
- **Clean Code:** Descriptive test names that read like documentation. No mystery guests — all data visible in the test.

### Framework-Specific Notes

**RSpec:** Use `let`, `before`, `shared_examples` where appropriate. Prefer `have_attributes` over individual matchers.

**Minitest:** Use `setup`, `test "description"` format. Keep assertions simple.

**ExUnit:** Use `setup`, `describe`, `test` blocks. Use `assert_raise` for error cases.

**Jest/Vitest:** Use `describe`, `it`, `beforeEach`. Use `jest.mock()` for dependencies.

## Phase 5: Execution & Verification

1. **Run the new specs** — targeted run (just the new file)
2. **Fix any failures** — read error, read source, fix root cause
3. **Run the full suite** — ensure nothing else broke
4. **Produce the QA report:**

### QA Report

**Files Under Test:**
| File | Tests Added | Coverage |
|------|------------|----------|
| ... | ... | ... |

**Findings:**
| # | Severity | Description | Status |
|---|----------|-------------|--------|
| 1 | CRITICAL | Missing auth check | FIXED |
| ... | ... | ... | ... |

**Core Values Audit:**
| Value | Status | Notes |
|-------|--------|-------|
| Security (no injection, XSS, CSRF) | PASS/WARN/FAIL | ... |
| Performance (no N+1, bounded queries) | PASS/WARN/FAIL | ... |
| Error handling (no silent failures) | PASS/WARN/FAIL | ... |
| Data integrity (validations, constraints) | PASS/WARN/FAIL | ... |
| Compatibility (no breaking changes) | PASS/WARN/FAIL | ... |

**Verdict:** SHIP IT / FIX AND RE-TEST / NEEDS REWORK

**Stats:** X files reviewed, Y tests added, Z findings (A critical, B major, C minor)
