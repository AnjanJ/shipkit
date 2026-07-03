---
description: "Strict TDD enforcer — iron-law red-green-refactor with delete-and-restart. TRIGGER when: user explicitly asks for TDD, says 'test first', or wants strict red-green-refactor enforcement. DO NOT TRIGGER when: normal coding (the default workflow already does test-first)."
user-invocable: true
argument-hint: "[feature|bugfix|refactor]"
---

<!-- Runs INLINE (no context: fork) on purpose: TDD IS the main coding loop —
     the user must see each red/green step, and the skill asks about exceptions.
     Forked skills cannot interact with the user. -->

# /tdd — Test-Driven Development

This is the **opt-in strict mode** of the shipkit Default Coding Workflow rule — the
`strict-tdd` workflow style. Invoked explicitly, or automatically when the project's
CLAUDE.md declares `Workflow style: strict-tdd`.

Write the test first. Watch it fail. Write minimal code to pass. Refactor.

**If you didn't watch the test fail, you don't know if it tests the right thing.**

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? Delete it. Start over. No "reference," no "adapting." Delete means delete.

## When to Use

**Always:** new features, bug fixes, refactoring, behavior changes.

**Exceptions (ask the user):** throwaway prototypes, generated code, config files.

Thinking "skip TDD just this once"? Stop. That's rationalization.

## Red-Green-Refactor Cycle

### 1. RED — Write Failing Test

Write one minimal test showing what should happen.

**Good test:**
- One behavior per test
- Clear name describing expected behavior
- Tests real code, not mocks (mocks only when unavoidable)

**Bad test:**
- Vague name (`test('it works')`)
- Tests mock behavior instead of real behavior
- Multiple assertions testing different behaviors

### 2. Verify RED — Watch It Fail

**MANDATORY. Never skip.**

Run the test. Confirm:
- Test **fails** (not errors — a syntax error is not a red test)
- Failure message matches what you expect
- Fails because the feature is missing, not because of typos

Test passes immediately? You're testing existing behavior. Fix the test.

### 3. GREEN — Minimal Code

Write the **simplest** code to make the test pass.

- Don't add features beyond what the test requires
- Don't refactor other code
- Don't "improve" beyond the test
- Don't add options, config, or extensibility (YAGNI)

### 4. Verify GREEN — Watch It Pass

**MANDATORY.**

Run the test. Confirm:
- New test passes
- All other tests still pass
- Output is clean (no errors, no warnings)

Test fails? Fix the code, not the test.

### 5. REFACTOR — Clean Up

Only after green:
- Remove duplication
- Improve names
- Extract helpers

Keep tests green throughout. Don't add new behavior during refactor.

### 6. Repeat

Next failing test for the next behavior.

## Bug Fix Flow

Bug found? TDD applies:
1. Write a failing test that reproduces the bug
2. Watch it fail (confirms the test catches the bug)
3. Fix the bug with minimal code
4. Watch it pass
5. Never fix bugs without a test — the test prevents regression

## Reference

When rationalizing, hitting red flags, writing bad tests, or stuck — see @reference.md

## Verification Checklist

Before claiming work is complete:

- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass (run the actual command, check the output)
- [ ] Output is clean (no errors, no warnings)
- [ ] Tests use real code (mocks only when unavoidable)
- [ ] Edge cases and error paths covered

Can't check all boxes? You skipped TDD. Start over.
