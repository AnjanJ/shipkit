---
type: llm
---

The user ran an intake on a one-line rename: "Rename `apply_tax` to `add_tax`."

PASS if the reply says the request is trivial and that no intake is needed. It may also do the
rename, or leave it to the user; either is fine.

FAIL if the reply asks intake questions about the rename, lists conflicts to resolve, or says
it wrote an intake file or a spec.
FAIL if the reply gives no answer.
