---
description: "Rails-specific code review standards: ActiveRecord performance, Sidekiq jobs, Hotwire consistency"
user-invocable: false
---

# Rails Code Review Standards

Supplement to the base `code-review-standards` knowledge base. Only loaded for Rails projects.

## Rails Performance & Scalability

**Database — Rails-Specific:**
- No `find_each` inside one transaction — holds locks on all rows.
- No race conditions on counters — use `update_counters`, not `update!` with `.count`.
- Use `select`/`pluck` on wide tables with TEXT/JSONB.
- Be explicit with `preload` vs `eager_load` — `includes` silently switches strategy.
- Run `ANALYZE` after bulk data migrations — stale planner stats cause sequential scans.

**Memory — Rails-Specific:**
- No class-level unbounded caches (`@@cache = {}`) — use `Rails.cache` with TTL or bounded LRU.
- Don't collect AR objects into arrays during `find_each` — process inside the block.
- Don't serialize full AR objects to cache — cache minimal hashes.
- Use `jemalloc` for Ruby memory allocator — reduces fragmentation.

**I/O — Rails-Specific:**
- Use `deliver_later` / `perform_later` for non-blocking external calls.
- Use persistent HTTP clients with connection pooling.

**Caching — Rails-Specific:**
- Use `race_condition_ttl` on popular cache keys — prevents thundering herd.
- Always set `expires_in` — especially for nil/empty results.
- Cache minimal data, not full AR objects — Marshal deserialization adds 10-50ms.
- Have a cache warming strategy for cold caches after deploy.

**Concurrency — Rails-Specific:**
- No mutable class-level state written during requests — GIL does NOT make Hash writes atomic.
- Clean up `Thread.current` between requests or use `ActiveSupport::CurrentAttributes`.
- Wrap spawned threads in `Rails.application.executor` — prevents connection pool leaks.
- Connection pool size matches thread count (Puma threads + Sidekiq concurrency).

**Background Jobs (Sidekiq/GoodJob):**
- Jobs with side effects (payments, emails) must be idempotent — retries = at-least-once.
- Pass IDs as job arguments, not AR objects — large payloads bloat Redis.
- Bounded retry policies — classify retriable vs permanent errors.
- Separate queues by priority — time-sensitive jobs shouldn't wait behind bulk operations.
- Long jobs use checkpointing/iteration — otherwise deploys kill and restart them.

## Hotwire Consistency (only when project uses Hotwire)

If the project has Turbo/Stimulus, flag code that bypasses Hotwire:

| What You See | What's Wrong | Suggest Instead |
|-------------|-------------|----------------|
| JSON endpoint for in-app UI | Bypasses Turbo | `turbo_stream` response |
| JS adding/removing DOM nodes | Manual DOM manipulation | `turbo_stream.append/remove/replace` |
| `onclick`/`onchange` inline handlers | Bypasses Stimulus | `data-action="click->controller#method"` |
| jQuery or `<script>` tag JS | Unmanaged JS | Stimulus controller |
| `document.querySelector` in JS | Fragile selectors | Stimulus targets |
| `setInterval` polling | Custom polling | Turbo refresh or ActionCable + Turbo Streams |
| Global JS variables for state | Unmanaged state | Stimulus values |
