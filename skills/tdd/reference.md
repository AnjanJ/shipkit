## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll write tests after" | Tests passing immediately prove nothing. You test what you built, not what's required. |
| "Already manually tested" | Ad-hoc is not systematic. No record, can't re-run. |
| "Deleting X hours of work is wasteful" | Sunk cost fallacy. Keeping unverified code is technical debt. |
| "Keep it as reference, write tests first" | You'll adapt it. That's testing after. Delete means delete. |
| "Need to explore first" | Fine. Throw away exploration, then start with TDD. |
| "Test is hard = skip TDD" | Hard to test = hard to use. Listen to the test — simplify the design. |
| "TDD will slow me down" | TDD is faster than debugging. Systematic beats ad-hoc. |
| "Existing code has no tests" | You're improving it now. Add tests for the code you're changing. |
| "It's about spirit, not ritual" | Tests-after answer "what does this do?" Tests-first answer "what should this do?" They are different. |

## Red Flags — STOP and Start Over

If you catch yourself doing any of these, delete the code and restart with TDD:

- Writing production code before a test
- Test passes immediately (didn't watch it fail)
- Can't explain why the test failed
- Adding tests "later"
- Saying "just this once"
- "I already manually tested it"
- "Keep as reference" or "adapt existing code"
- "This is different because..."

## Testing Anti-Patterns

When writing tests, avoid these traps:

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Testing mock behavior | You're verifying the mock works, not the code | Test real components or don't assert on mocks |
| Test-only methods in production | Pollutes production code, dangerous if called | Move to test utilities |
| Mocking without understanding | Mock breaks side effects the test depends on | Understand dependencies first, mock minimally |
| Incomplete mocks | Partial mocks hide structural assumptions | Mirror real API structure completely |
| Tests as afterthought | Tests passing immediately prove nothing | TDD — tests first, always |

**Core principle:** Mocks are tools to isolate, not things to test.

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write the wished-for API. Write the assertion first. Ask the user. |
| Test too complicated | Design too complicated. Simplify the interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup is huge | Extract helpers. Still complex? Simplify the design. |
