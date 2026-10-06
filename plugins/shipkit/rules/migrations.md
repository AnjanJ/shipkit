---
paths:
  - "**/migrations/**"
  - "**/migrate/**"
  - "**/priv/repo/migrations/**"
  - "**/db/migrate/**"
---
# Migration Safety
- On a large table, backfill in batches: one `UPDATE` over millions of rows holds a lock for
  the whole run.
- An index on a high-traffic table needs `CONCURRENTLY` (Postgres) or the ORM's equivalent
  (`algorithm: :concurrently`, `disable_ddl_transaction!`), or writes block until it is built.
