---
description: "Systematic root-cause debugging. TRIGGER when: tests fail, user reports a bug, or unexpected errors occur. DO NOT TRIGGER when: writing new code or doing refactors."
user-invocable: true
disable-model-invocation: true
argument-hint: "[<error-description>|<test-name>|<file-path>]"
context: fork
---

# /debug — Systematic Debugging

Random fixes waste time and create new bugs. Find the root cause first.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue: test failures, bugs, unexpected behavior, performance problems,
build failures, integration issues.

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- You don't fully understand the issue

## Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

### 1.1 Read Error Messages Carefully

- Don't skip past errors or warnings — they often contain the exact solution
- Read stack traces completely
- Note line numbers, file paths, error codes

### 1.2 Reproduce Consistently

- Can you trigger it reliably? What are the exact steps?
- If not reproducible, gather more data — don't guess

### 1.3 Check Recent Changes

- `git diff`, recent commits — what changed that could cause this?
- New dependencies, config changes, environmental differences

### 1.4 Trace Data Flow

When the error is deep in the call stack:

1. Where does the bad value originate?
2. What called this function with the bad value?
3. Keep tracing up until you find the source
4. Fix at the source, not at the symptom

### 1.5 Gather Evidence in Multi-Component Systems

When the system has multiple layers (CI, build, deploy, API, service, database):

Add diagnostic output at each component boundary **before** proposing fixes:
- Log what data enters and exits each component
- Verify environment/config propagation
- Check state at each layer
- Run once to gather evidence showing WHERE it breaks

---

## Phase 2: Pattern Analysis

### 2.1 Find Working Examples

Locate similar working code in the same codebase. What works that's similar to what's broken?

### 2.2 Compare Against References

If implementing a pattern, read the reference implementation **completely** — don't skim.

### 2.3 Identify Differences

List every difference between working and broken code, however small.
Don't assume "that can't matter."

---

## Phase 3: Hypothesis and Testing

### 3.1 Form Single Hypothesis

State clearly: "I think X is the root cause because Y." Be specific, not vague.

### 3.2 Test Minimally

Make the **smallest possible change** to test the hypothesis.
One variable at a time. Don't fix multiple things at once.

### 3.3 Verify Before Continuing

- Did it work? Move to Phase 4.
- Didn't work? Form a **new** hypothesis. Don't add more fixes on top.

---

## Phase 4: Implementation

### 4.1 Create Failing Test Case

Write a test that reproduces the bug. This proves the fix and prevents regression.

### 4.2 Implement Single Fix

Address the root cause. ONE change at a time. No "while I'm here" improvements.

### 4.3 Verify Fix

Run tests. Does the new test pass? Do all other tests still pass?

### 4.4 The Three-Strike Rule

Count your fix attempts:

- **< 3 failures:** Return to Phase 1, re-analyze with new information
- **3+ failures:** STOP. Question the architecture:
  - Is this pattern fundamentally sound?
  - Are we sticking with it through inertia?
  - Should we refactor the architecture instead of continuing to fix symptoms?

**Discuss with the user before attempting more fixes.** 3+ failed fixes is not a failed
hypothesis — it's a wrong architecture.

---

## Reference

For defense-in-depth patterns, red flags, rationalization checks, and phase summary — see @reference.md
