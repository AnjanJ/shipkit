---
description: "Code review standards: 8 lenses, anti-pattern catalog, severity definitions"
user-invocable: false
---

# Code Review Standards

Knowledge base for the `/review-my-code` skill. Provides detailed review criteria.

## 8 Review Lenses

### 1. Clean Code + SRP
- **MUST:** Functions under 20 lines. One responsibility per method.
- **MUST:** Class has one reason to change (Single Responsibility Principle).
- **MUST:** Descriptive names — no abbreviations, no single-letter vars (except block params).
- **MUST:** No dead code, no commented-out code.
- **SHOULD:** No more than 3 parameters per method.
- **CONSIDER:** Early returns over nested conditionals.

### 2. DRY
- **MUST:** No copy-paste code with minor variations.
- **SHOULD:** Extract shared logic — but only if repeated 3+ times (Rule of Three).
- **CONSIDER:** Shared constants for magic numbers/strings used in multiple places.

### 3. KISS
- **MUST:** No unnecessary abstractions or indirection.
- **SHOULD:** Use standard library before custom implementations.
- **SHOULD:** Interfaces should be small and focused — no god interfaces (Interface Segregation).
- **CONSIDER:** Could a junior developer understand this in 5 minutes?

### 4. YAGNI (You Aren't Gonna Need It)
- **MUST:** No code that isn't required by the current task.
- **MUST:** No abstractions or helpers for things only used once.
- **SHOULD:** No speculative parameters, config options, or feature flags for hypothetical futures.
- **SHOULD:** No empty hook methods or extensibility points with no current consumer.
- **CONSIDER:** "Would this code be deleted if the current feature was the only feature?"

### 5. Language Idioms
- **MUST:** Use idiomatic patterns for the language.
- **SHOULD:** Use built-in methods over manual implementations.
- **CONSIDER:** Follow community style guides (RuboCop, ESLint, Credo).

### 6. Framework Patterns + OCP/DIP
- **MUST:** Logic in the correct layer (not business logic in views).
- **SHOULD:** Use framework features over custom solutions.
- **SHOULD:** Open for extension without modifying existing code (Open/Closed Principle).
- **SHOULD:** Depend on abstractions, not concretions — inject dependencies (Dependency Inversion).
- **CONSIDER:** Follow framework conventions for naming and file organization.

### 7. Performance & Scalability

**Database — MUST:**
- No N+1 queries (including hidden ones behind associations, scopes, or GraphQL resolvers).
- No unbounded collections (enforce max page size, use `limit`).
- No transactions wrapping external I/O (API calls, email, file uploads).

**Database — SHOULD:**
- Use cursor-based pagination for APIs and deep pages — offset pagination scans and discards rows.
- Composite indexes for multi-column `where` clauses.
- Select only needed columns on wide tables — don't load large blobs you don't need.

**Memory — MUST:**
- No loading entire files into memory — stream or use chunked reads for large files.
- No unbounded in-memory caches — use TTL or bounded LRU.

**I/O — MUST:**
- All HTTP clients have explicit connect + read timeouts. No infinite waits.
- Circuit breaker for external dependencies — retries without backoff cause cascading failures.
- No synchronous external calls in request path when the response isn't needed.

**I/O — SHOULD:**
- Use persistent HTTP clients with connection pooling.

**Caching — SHOULD:**
- Cache keys include a version/timestamp component — stale caches are security risks.
- Always set cache TTL — especially for nil/empty results.

**Concurrency — MUST:**
- No mutable shared state written during concurrent requests.
- Clean up thread-local state between requests.

**Background Jobs — MUST:**
- Jobs with side effects must be idempotent — retries = at-least-once delivery.
- Pass IDs as job arguments, not serialized objects.

**API — MUST:**
- Enforce max page size on collection endpoints.
- Rate limiting on expensive endpoints.
- Request payload size limits.
- GraphQL: max query depth + complexity limits.

See stack-specific knowledge bases for framework-specific performance checks.

### 8. Error Handling
- **MUST:** No silent failures (empty rescue/catch blocks).
- **MUST:** Specific error types caught (not bare rescue/catch).
- **SHOULD:** External calls have timeouts.
- **CONSIDER:** Retry with backoff for transient failures.

### 9. AI/LLM Integration (conditional — only when AI code is present)
- **MUST:** API keys in environment variables, never hardcoded.
- **MUST:** User input sanitized before sending to LLM (prompt injection prevention).
- **MUST:** LLM output validated/sanitized before rendering to users (XSS prevention).
- **MUST:** Rate limiting on LLM-facing endpoints.
- **MUST:** Cost controls (max tokens, budget limits).
- **SHOULD:** Streaming for long responses.
- **SHOULD:** Retry logic with exponential backoff for transient LLM errors.
- **SHOULD:** Logging of LLM requests for debugging (without logging sensitive user data).
- **SHOULD:** Timeout configuration on all LLM calls.
- **CONSIDER:** Caching identical prompts.
- **CONSIDER:** Fallback provider if primary is down.

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
