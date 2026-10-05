---
type: llm
---

The user asked: "Should we move orders from the JSON file to SQLite? Decide and record it."

PASS if the reply does both of these:
1. names at least two real options that were considered (for example: stay on the JSON file,
   move to SQLite), and
2. states a concrete condition under which the decision would be reversed — a number, an
   event or a threshold (for example "if the orders file passes 10,000 orders" or "if a second
   process needs to write orders").

FAIL if only one option is discussed.
FAIL if there is no reversal condition, or it is vague ("if it turns out to be wrong", "if
requirements change", "if it stops working well").
FAIL if the reply gives no answer.
