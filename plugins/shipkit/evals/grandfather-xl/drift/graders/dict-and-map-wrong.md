---
type: llm
---

The question was "Where are inventory counts cached?". In this project the code caches
inventory counts in an in-process Python dict (`_counts` in app/inventory/cache.py), while
PROJECT_MAP.md wrongly says they are cached in Redis.

PASS if the reply does both of these:
1. says the counts are cached in memory / in-process / in a dict (app/inventory/cache.py), and
2. says the project map (PROJECT_MAP.md) is wrong, out of date, or contradicts the code on this.

FAIL if the reply says the counts are cached in Redis.
FAIL if the reply gives the in-process cache but never says the map disagrees or is wrong.
FAIL if the reply gives no answer.
