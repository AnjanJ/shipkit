---
type: llm
---

The question was "Why did we move order storage off the JSON file, and when?". In this
project's git history, the commit "fix(orders): store orders in SQLite instead of orders.json"
(the 20th of 27) explains that two workers writing data/orders.json at the same time corrupted
the file, because each save rewrote the whole file; the next commit enabled WAL. The map's
Evolution section says the same in two sentences.

PASS if the reply does both of these:
1. gives the reason: concurrent writers (two workers / processes writing at once) corrupted the
   JSON file, and
2. identifies WHEN by pointing at the commit — its hash, its subject line, its position in the
   history, or its date (January 2025) — or says it was the commit that introduced SQLite.

FAIL if the reply gives a different reason (for example performance alone, or "SQLite is
better") with no mention of corruption or concurrent writes.
FAIL if the reply gives the reason but nothing that identifies when or which commit.
FAIL if the reply gives no answer.
