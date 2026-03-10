---
description: "8-lens code review with severity levels and structured report"
user-invocable: true
argument-hint: "[<file-path>|<PR-number>|<branch>]"
---

# /review-my-code — Code Review

Review code changes through 8 lenses and produce a structured report.

## Current Changes
!`git diff --stat HEAD 2>/dev/null || echo "no git diff available"`

## Phase 1: Gather Context

1. **Determine scope** from `$ARGUMENTS`:
   - If a PR number: `gh pr diff $ARGUMENTS`, `gh pr view $ARGUMENTS`
   - If a filepath: `git diff $ARGUMENTS` (staged + unstaged)
   - If empty: `git diff` (all uncommitted changes)
2. **Read every changed file** — full file, not just the diff
3. **Read related tests** — find specs that cover the changed code
4. **Read CLAUDE.md** — check for project-specific conventions

## Phase 2: Apply 8 Lenses

Review each changed file through these lenses:

### The 8 Lenses
1. **Clean Code + SRP** — Functions <20 lines, one responsibility, descriptive names, no dead code
2. **DRY** — Duplicated logic across files? Extract only if repeated 3+ times
3. **KISS** — Simpler way? Over-engineered abstractions? Unnecessary indirection?
4. **YAGNI** — Code not required by current task? Speculative features? One-use abstractions?
5. **Language Idioms** — Idiomatic patterns? Standard library used? Anti-patterns?
6. **Framework Patterns + OCP/DIP** — Correct layer? Framework conventions? Inject dependencies?
7. **Performance** — See `code-review-standards` knowledge base. Key: N+1, unbounded collections, missing timeouts, non-idempotent jobs
8. **Error Handling** — No silent failures, specific error types, helpful messages, timeouts on external calls

## Phase 2.5: Pattern Opportunities (Smell → Pattern)

Check the `code-review-standards` knowledge base for the full Smell → Pattern map.
Only suggest a pattern when the code already smells — never force patterns onto clean code.
If the simple version works and won't grow, skip the pattern.

## Phase 2.6: Stack-Specific Checks (Conditional)

Check stack-specific knowledge bases if available (e.g., `code-review-standards-rails`).
These contain framework-specific performance, consistency, and anti-pattern checks.

## Phase 2.7: PR Reviewability Check

If reviewing a PR (not a single file):
- **Diff size** — flag if >400 lines changed. Suggest splitting into smaller PRs.
- **Commit count vs scope** — flag if one giant commit covers multiple logical changes. Suggest atomic commits.
- **Destructive migrations** — flag any `remove_column`, `drop_table`, or column type changes as BLOCKER. These require explicit human review.

## Phase 3: Project Conventions Check

Read CLAUDE.md and check the diff against any project-specific rules:
- Naming conventions followed?
- Architecture patterns respected?
- Required patterns present? (e.g., tests for new code, migrations have rollback)
- Forbidden patterns absent? (e.g., `puts` debugging, hardcoded secrets)

## Phase 4: Structured Report

### Review Summary

**Scope:** X files changed, Y lines added, Z lines removed

**Findings:**

| # | Severity | Lens | File:Line | Description | Suggestion |
|---|----------|------|-----------|-------------|------------|
| 1 | BLOCKER | Performance | app/models/user.rb:45 | N+1 in `all_orders` | Use `includes(:orders)` |
| 2 | MAJOR | Clean Code | app/services/foo.rb:12 | 60-line method | Extract into 3 methods |
| 3 | MINOR | Idioms | lib/parser.rb:8 | Manual hash build | Use `each_with_object` |
| 4 | PRAISE | DRY | app/models/base.rb | Clean shared concern | Well extracted |

### Convention Compliance
| Convention | Status |
|-----------|--------|
| Tests for new code | YES/NO |
| Naming conventions | YES/NO |
| Architecture patterns | YES/NO |

**Verdict:** APPROVE / REQUEST CHANGES / NEEDS DISCUSSION

**Stats:** X files reviewed, Y findings (A blockers, B critical, C major, D minor, E nits, F praise)
