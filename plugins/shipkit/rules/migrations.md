---
paths:
  - "**/migrations/**"
  - "**/migrate/**"
  - "**/priv/repo/migrations/**"
  - "**/db/migrate/**"
---
# Migration Safety
- Never drop columns or tables without confirming with the user
- Always make migrations reversible when possible
- For large tables, consider batched operations
- Check for index additions on high-traffic tables — may need CONCURRENTLY
- Verify foreign key constraints won't break existing data
- Test migrations against a copy of production data when available
- Always add a rollback strategy for destructive migrations
