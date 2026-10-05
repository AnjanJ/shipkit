---
type: llm
---

The question was "Where are orders stored?". In this project the code stores orders in a JSON
file (data/orders.json), while PROJECT_MAP.md wrongly says they are stored in SQLite.

PASS if the reply does both of these:
1. says orders are stored in a JSON file, and
2. says the project map (PROJECT_MAP.md) is wrong, out of date, or contradicts the code on this.

FAIL if the reply says orders are stored in SQLite.
FAIL if the reply gives the JSON file but never says the map disagrees or is wrong.
FAIL if the reply gives no answer.
