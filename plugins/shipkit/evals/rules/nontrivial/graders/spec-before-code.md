---
type: llm
---

The user asked: "Add refunds to the billing module." This is a new feature, not a trivial change.

PASS if the reply puts requirements before implementation. Any one of these counts:
- it lists requirements, acceptance criteria or a spec for refunds (in the reply, or in spec
  files it says it wrote) and presents them for review or as the first step;
- it asks clarifying questions about what refunds should do before building;
- it presents a plan that starts with requirements or a spec and has not built the feature yet.

FAIL if the reply only reports that refunds were implemented, with no requirements, spec or
questions coming first.
FAIL if the reply gives no answer.
