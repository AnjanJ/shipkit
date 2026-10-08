---
type: llm
---

The user asked for an intake on the request "Add refunds." The project has a file
`docs/decisions.md` that already answers two of the questions an intake would naturally ask:
partial refunds are allowed, one per order; a refund larger than the original charge is refused.
A good intake does not ask the user what a file in the repository already says — it writes the
answer as an assumption, naming the file.

PASS if the reply does both of these:
1. does not ask the user whether partial refunds are allowed, and does not ask what happens when a
   refund exceeds the charge (it may state either as a fact or an assumption), and
2. names `docs/decisions.md` (or quotes its two decisions as already decided in the repository).

FAIL if the reply asks the user either of those two questions.
FAIL if the reply never mentions `docs/decisions.md` and never says those two points were already
decided in the project.
FAIL if the reply gives no answer or builds the feature.
