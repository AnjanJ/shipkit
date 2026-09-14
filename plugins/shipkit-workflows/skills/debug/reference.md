## Defense in Depth

When you find a bug caused by invalid data, don't just add one validation. Validate at
**every layer** data passes through:

| Layer | Purpose | Example |
|-------|---------|---------|
| Entry point | Reject obviously invalid input | Parameter nil check, type check |
| Business logic | Ensure data makes sense for this operation | Domain constraint validation |
| Environment guards | Prevent dangerous operations in specific contexts | Refuse destructive ops in test env |
| Debug instrumentation | Capture context for forensics | Stack trace logging before critical operations |

Single validation: "We fixed the bug." Multiple layers: "We made the bug impossible."

---

## Red Flags & Rationalizations — STOP and Return to Phase 1

| Temptation | Reality |
|------------|---------|
| "Quick fix for now, investigate later" | First fix sets the pattern. Do it right from the start. |
| "Just try changing X and see if it works" | Seeing symptoms is not understanding root cause. |
| "Multiple changes at once, run tests" | Can't isolate what worked. Causes new bugs. |
| "Skip the test, I'll manually verify" | Untested fixes don't stick. Test first proves it. |
| "It's probably X, let me fix that" | Process is fast for simple bugs too. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question the pattern. |

**If you catch yourself in ANY of these: STOP. Return to Phase 1.**

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|-----------------|
| 1. Root Cause | Read errors, reproduce, check changes, trace data | Understand WHAT and WHY |
| 2. Pattern | Find working examples, compare | Identify differences |
| 3. Hypothesis | Form theory, test minimally | Confirmed or new hypothesis |
| 4. Implementation | Create test, fix, verify | Bug resolved, tests pass |
