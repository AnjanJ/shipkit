---
description: "Audit a legacy codebase for modernization: dependency age, dead code, complexity hotspots, test coverage gaps"
user-invocable: true
argument-hint: "[deps|dead-code|complexity|coverage|all]"
context: fork
---

# /legacy-audit — Legacy Codebase Audit

Audit scope: $ARGUMENTS (default: `all`)

## Phase 1: Dependency Age Audit

!`ls Gemfile.lock package-lock.json yarn.lock pnpm-lock.yaml poetry.lock Pipfile.lock go.sum mix.lock 2>/dev/null`

### Check dependency freshness:
- **Ruby:** `bundle outdated --strict`
- **Node:** `npm outdated` or `yarn outdated`
- **Python:** `pip list --outdated`
- **Go:** `go list -m -u all`
- **Elixir:** `mix hex.outdated`

### Classify each outdated dependency:
| Category | Definition | Action |
|----------|-----------|--------|
| CRITICAL | 2+ major versions behind OR has known CVEs | Upgrade immediately |
| STALE | 1 major version behind | Plan upgrade |
| AGING | Minor/patch versions behind | Upgrade when convenient |
| CURRENT | Up to date | No action |

### Security scan:
- **Ruby:** `bundle audit check`
- **Node:** `npm audit`
- **Python:** `pip-audit` or `safety check`
- **Go:** `govulncheck ./...`
- **Elixir:** `mix hex.audit`

## Phase 2: Dead Code Detection

Search for unused code:
1. **Unused files:** files not imported/required anywhere
2. **Unused functions/methods:** defined but never called (search with Grep)
3. **Commented-out code:** blocks of `#` or `//` commented code longer than 5 lines
4. **Dead routes:** routes pointing to missing controllers/handlers
5. **Unused dependencies:** gems/packages in lockfile but not imported in source

Report as a table: `| File:Line | Type | Evidence | Safe to Remove? |`

## Phase 3: Complexity Hotspots

Identify high-complexity areas:
1. **Large files:** files over 300 lines (sort by size)
2. **God classes:** classes with 10+ public methods
3. **Long methods:** methods/functions over 50 lines
4. **Deep nesting:** code with 4+ levels of indentation
5. **High churn + high complexity:** cross-reference with `git log --format="%H" --since="6 months ago" -- <file> | wc -l`

Report: `| File:Line | Metric | Value | Risk | Suggested Action |`

## Phase 4: Test Coverage Gaps

1. Find source files with no corresponding test file
2. Find test files that haven't been updated in 6+ months (stale tests)
3. Check for integration/system test coverage of critical paths
4. Run coverage tool if available:
   - **Ruby:** `COVERAGE=true bundle exec rspec` (SimpleCov)
   - **Node:** `npx vitest --coverage` or `npx jest --coverage`
   - **Python:** `pytest --cov`
   - **Go:** `go test -coverprofile=coverage.out ./...`

Report: `| Source File | Test File | Last Test Update | Coverage |`

## Summary Report

```
Legacy Audit Report — {{PROJECT_NAME}}
Date: [today]

Dependency Health:  X CRITICAL / Y STALE / Z AGING / W CURRENT
Security Issues:    X vulnerabilities found
Dead Code:          X files / Y functions / Z commented blocks
Complexity:         X hotspots (high churn + high complexity)
Test Coverage:      X source files with no test / Y stale tests

Top 5 Modernization Priorities:
1. [highest impact item]
2. ...

Estimated Effort: [small/medium/large] per priority
```

## Constraint

This is a READ-ONLY audit. Do not modify any files. Present findings and let the user decide what to act on.
