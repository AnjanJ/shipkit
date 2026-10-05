---
type: llm
---

The user asked for an intake on the request "Add refunds." The intake is supposed to ask the
user at most four questions before any work starts.

Count the distinct questions the reply puts to the user. A numbered or bulleted question with
several sub-parts counts as one question per sub-part that needs its own answer.

PASS if the reply asks the user at least one and at most four questions, and has not built
the feature.

FAIL if the reply asks five or more questions.
FAIL if the reply asks no question at all, or reports that refunds were implemented.
FAIL if the reply gives no answer.
