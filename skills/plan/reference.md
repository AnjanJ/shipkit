# Plan — Reference Templates

## PRD Template

Present the PRD in this format:

```
## PRD: [Feature Name]

### Purpose
[One paragraph: what problem this solves and why it matters]

### Users
[Who uses this, their context, and their goals]

### Behaviors
1. User can [action] so that [outcome]
2. User can [action] so that [outcome]
...

### Acceptance Criteria
For each behavior:
- Given [context], when [action], then [expected result]
- Given [context], when [action], then [expected result]

### Edge Cases
- What happens when [X is empty/missing/invalid]?
- What happens when [concurrent access/race condition]?
- What happens when [external service fails]?
- What happens when [user lacks permission]?

### Out of Scope
- [Thing this deliberately does NOT do]
- [Future enhancement deferred]

### Constraints
- [Performance requirement]
- [Compatibility requirement]
- [Dependency on other work]
```

## Tech Spec Template

```
## Tech Spec: [Feature Name]

### Architecture Overview
[How this fits into the existing system — which layers it touches]

### Data Model
[New tables/columns/indexes, schema changes, migrations needed]
[Relationships to existing models]

### API / Interface Design
[Endpoints, method signatures, component props, CLI commands]
[Request/response shapes, error responses]

### Component Structure
[New files to create, existing files to modify]
[Which layer each component lives in]

### Design Decisions
For each non-obvious choice:
- **Decision:** [what we chose]
- **Why:** [reason — scale, simplicity, consistency with existing patterns]
- **Trade-off:** [what we gave up]

### Dependencies
[Libraries needed, external services, other features required first]

### Risks
[What could go wrong, what we're unsure about, where we need user input]

### Quality Checklist
- [ ] Scales to 10x current load?
- [ ] Fails gracefully? User sees helpful error?
- [ ] New developer can understand in 5 minutes?
- [ ] Requirements change = localized code change?
- [ ] Inputs validated? Authorization checked? No injection risk?
```

## Task Breakdown Template

```
## Sprint Plan: [Feature Name]

### Foundation
[ ] Task 1: [description] (S/M/L)
    Acceptance: [criteria]
    Test: "[BDD-style test description]"

### Core Logic
[ ] Task 2: [description] (S/M/L)
    Acceptance: [criteria]
    Test: "[BDD-style test description]"

### Interface
[ ] Task 3: [description] (S/M/L)
    Acceptance: [criteria]
    Test: "[BDD-style test description]"

### Integration
[ ] Task 4: [description] (S/M/L)
    Acceptance: [criteria]
    Test: "[BDD-style test description]"

### Edge Cases
[ ] Task 5: [description] (S/M/L)
    Acceptance: [criteria]
    Test: "[BDD-style test description]"

Total: X tasks (Y small, Z medium, W large)
```

## Design Principles Checklist

When evaluating technical design in Phase 2, verify:

### Scalability
- Will database queries perform at 10x data volume? (indexes, pagination, no N+1)
- Are expensive operations async/background? (jobs, queues, caching)
- Are external API calls bounded? (timeouts, circuit breakers, rate limits)

### Fault Tolerance
- What happens when the database is slow? (timeouts, retries with backoff)
- What happens when an external service is down? (graceful degradation, fallbacks)
- Are operations idempotent? (safe to retry on failure)
- Is data integrity protected? (transactions, constraints, validations)

### Readability
- Does the code follow existing project conventions?
- Are names descriptive? Can you understand the code without comments?
- Is the logic linear? (minimal nesting, early returns, no clever tricks)
- Is each function/method focused on one thing?

### Maintainability
- If requirements change, how many files need to change? (minimize blast radius)
- Are dependencies explicit? (injection over global state)
- Is the test suite sufficient to catch regressions?
- Are abstractions justified by real duplication? (Rule of Three)

### Security
- Is all user input validated at system boundaries?
- Is authorization checked on every endpoint/action?
- Are secrets in environment variables, never in code?
- Is sensitive data excluded from logs and error messages?
