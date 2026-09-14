---
paths:
  - "lib/**/workers/**"
  - "lib/**/jobs/**"
  - "lib/**/*_worker.ex"
  - "lib/**/*_job.ex"
---
<!-- requires: elixir -->
# Oban Jobs

- **`perform/1` must be idempotent.** Oban is at-least-once: a job can run twice after a node
  restart, a timeout, or a retry. Writing "charge the card" without a guard is a real bug.
- **Args are IDs and primitives only** — they are serialized to JSON in Postgres. Never pass a
  struct; re-fetch inside `perform/1` so the job sees current data.
- **Use `unique:`** for jobs that must not queue twice (period, fields, states). Enqueue-time
  deduplication is cheaper than defensive checks in every job.
- **Return values are the contract:** `:ok` / `{:ok, value}` for success, `{:error, reason}` to
  retry, `{:cancel, reason}` for a permanent failure that must not retry, `{:snooze, seconds}`
  to defer. Do not raise for expected failures.
- **Classify errors.** A 4xx from an upstream API is usually `{:cancel, ...}`; a 5xx or timeout
  is `{:error, ...}`. Bounded `max_attempts` on everything.
- **Queues by priority.** Time-sensitive work must not sit behind a bulk backfill. Set explicit
  concurrency per queue.
- **Testing:** `Oban.Testing` with `:manual` mode. Assert the job was enqueued with the right
  args (`assert_enqueued`), and unit-test `perform/1` directly. Do not sleep on async execution.
- Long-running jobs need checkpointing — a deploy kills and restarts them.
