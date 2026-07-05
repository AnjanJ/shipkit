---
description: "Plan a major dependency upgrade or framework migration with impact analysis and a step-by-step execution plan. TRIGGER when: user asks to plan a major/breaking upgrade or framework migration (e.g. Rails 7→8, React 18→19). DO NOT TRIGGER when: adding a new dependency, doing a minor/patch bump, or already mid-migration."
user-invocable: true
argument-hint: "[<dependency> <from-version> <to-version>, e.g. rails 7.1 8.0]"
context: fork
---

# /migration-plan — Dependency/Framework Migration Plan

Migration: $ARGUMENTS

## Step 1: Read the Changelog

IMPORTANT: Read the official migration/upgrade guide BEFORE analyzing impact.

Use WebFetch to read:
1. The official upgrade guide (if one exists)
2. The CHANGELOG between current and target versions
3. Known breaking changes and deprecation notices

Do NOT proceed until the changelog has been read.

## Step 2: Current Usage Analysis

Scan the codebase for all usage of the dependency being upgraded:
1. Direct imports/requires
2. Configuration files
3. API calls that may have changed
4. Deprecated features currently in use
5. Monkey-patches or extensions

Report: `| File:Line | Usage Type | Breaking Change? | Migration Action |`

## Step 3: Dependency Chain Impact

Check what else depends on or is affected by this upgrade:
1. **Direct dependencies** that pin to the current version
2. **Transitive dependencies** that may conflict
3. **Plugins/extensions** that need compatible versions
4. **Test infrastructure** (factories, helpers, mocks) that use deprecated APIs

For each conflict:
`| Dependency | Current Version | Required Version | Compatible? | Action |`

## Step 4: Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| Breaking API changes | HIGH/MEDIUM/LOW | HIGH/MEDIUM/LOW | [specific action] |
| Data migration needed | ... | ... | ... |
| Performance regression | ... | ... | ... |
| Plugin incompatibility | ... | ... | ... |

## Step 5: Migration Plan

Generate a step-by-step plan. Each step must be:
- **Atomic** — can be merged independently
- **Testable** — has a verification command
- **Reversible** — can be rolled back

```
Step 1: [description]
  Files: [list of files to change]
  Command: [verification command]
  Rollback: [how to undo]

Step 2: ...
```

### Ordering principles:
1. Fix deprecation warnings first (while still on current version)
2. Update configuration
3. Update dependency version
4. Fix breaking changes
5. Update tests
6. Remove compatibility shims

## Step 6: Pre-Migration Checklist

Before starting:
- [ ] All tests passing on current version
- [ ] Git working directory clean
- [ ] Migration branch created from main
- [ ] Changelog and upgrade guide read
- [ ] Team notified (if applicable)

## Constraint

This skill produces a PLAN only. It does not execute the migration. The user decides when to start and can use the plan as a checklist.
