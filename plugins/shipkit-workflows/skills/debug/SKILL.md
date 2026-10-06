---
description: "Systematic root-cause debugging. TRIGGER when: tests fail, user reports a bug, or unexpected errors occur. DO NOT TRIGGER when: writing new code or doing refactors."
user-invocable: true
argument-hint: "[<error-description>|<test-name>|<file-path>]"
context: fork
---

# /debug — Systematic Debugging

Random fixes waste time and create new bugs. **No fix without a root cause first.** If Phase 1
is not done, you cannot propose a fix. Use this for any technical issue — a failing test, a
bug, a build or integration failure — and especially when a "quick fix" looks obvious, when
several fixes have already been tried, or when you do not yet understand the issue.

## Phase 1: Root cause

1. **Read the error completely** — the whole stack trace, line numbers, paths, codes. The
   answer is often in the part people skip.
2. **Reproduce it reliably.** Exact steps. If it cannot be reproduced, gather more data; do
   not guess.
3. **Check what changed** — `git diff`, recent commits, new dependencies, config, environment.
4. **Trace the bad value to its source.** Where did it originate, what passed it on? Fix at the
   source, not where it surfaced.
5. **In a multi-layer system** (CI, build, API, service, database), log what enters and
   leaves each boundary and run once to see *where* it breaks, before proposing anything.

## Phase 2: Compare with what works

Find similar code in the same codebase that works, read any reference implementation
completely, and list every difference between working and broken, however small. "That can't
matter" is how the cause hides.

## Phase 3: One hypothesis, one test

State it: "I think X is the root cause because Y." Make the **smallest change** that tests it,
one variable at a time. If it did not work, form a *new* hypothesis — do not stack fixes.

## Phase 4: Fix

1. Write a failing test that reproduces the bug.
2. Make one fix, at the root cause. No "while I'm here" changes.
3. Run the suite: the new test passes, nothing else broke.

**Three strikes.** After three failed fixes, stop and talk to the user: three failures is not a
wrong hypothesis, it is a wrong design. Ask whether the pattern is sound before trying a fourth.

The red flags that mean "go back to Phase 1" and the defense-in-depth patterns are in
@reference.md.
