# Code Review Standards — Reference Tables

## Anti-Pattern Catalog

| Pattern | Severity | What to Look For |
|---------|----------|-----------------|
| God Object | MAJOR | Class with 10+ public methods or 200+ lines |
| Feature Envy | MAJOR | Method uses another object's data more than its own |
| Shotgun Surgery | MAJOR | One change requires edits in 5+ files |
| Primitive Obsession | MINOR | Using strings/ints where a value object fits |
| Long Parameter List | MINOR | Method takes 4+ parameters |
| Dead Code | MINOR | Unreachable code, unused variables/methods |
| Magic Numbers | NIT | Unexplained numeric literals |
| Boolean Parameter | NIT | Method behavior changes based on a boolean flag |
| Speculative Generality | MAJOR | Abstractions, params, or hooks built for imagined future use |
| Gold Plating | MINOR | Extra features or polish beyond what was requested |
| SRP Violation | MAJOR | Class mixing concerns (e.g., parsing + validation + HTTP calls) |
| Rigid Coupling | MAJOR | Hardcoded class names instead of injected dependencies (DIP) |
| Liskov Violation | CRITICAL | Subclass breaks parent's contract or raises unexpected errors |

## Smell → Pattern Map

Only suggest a pattern when a real smell exists. Never force patterns onto clean code.

| Smell | Pattern | Threshold |
|-------|---------|-----------|
| Type-switching (`case`/`if` on type) | Strategy | 3+ branches and growing |
| Conditional object creation | Factory | 2+ creation paths |
| State change notifications | Observer/Pub-Sub | 3+ listeners |
| Many optional constructor params | Builder | 4+ optional params |
| External API/legacy wrapping | Adapter | Dependency you may swap |
| Composable cross-cutting behavior | Decorator | Logging, caching, auth layers |
| Shared process, varying steps | Template Method | 2+ subclasses with same skeleton |
| Expensive resource creation | Singleton/Pool | DB connections, API clients |

**Key constraint:** if the simple version works and the code won't grow, skip the pattern.

## Severity Definitions

| Level | Meaning | Action |
|-------|---------|--------|
| BLOCKER | Security, data loss, crash | Must fix before merge |
| CRITICAL | Bug, broken feature | Should fix before merge |
| MAJOR | Code quality, maintainability | Fix in this PR or create follow-up |
| MINOR | Style, minor improvement | Nice to have |
| NIT | Personal preference | Optional |
| PRAISE | Excellent work | Highlight and encourage |
