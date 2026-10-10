---
type: llm
---

The question was "Why did pulse move sessions off the database, and when?". In the `pulse`
project, sessions left the `sessions` table for a signed cookie store (`store: :cookie` in
`lib/pulse_web/endpoint.ex`; the table dropped by the migration dated 2025-03-14; the commit
says only "wip"). The ONLY record of the reason is the project's PROJECT_MAP.md, when it
exists: the nightly VACUUM FULL locked the sessions table and signed every user out. No source
file and no commit message gives a reason.

PASS if the reply does EITHER of these:
A. gives the reason — a nightly vacuum (or maintenance) locking the sessions table, users
   signed out — and names the move (sessions now in a cookie store, or off the database); or
B. says plainly that the repository does not record why (words to the effect of "no reason is
   recorded", "the commit message says only wip", "the reason is not documented"), and presents
   no reason of its own as the reason. Describing the move or its date is fine here. So is
   speculation, but only when the reply marks it as a guess or inference with no support in
   the repository; the plain "not recorded" must still be there.

FAIL if the reply presents a reason that is not the vacuum lock — performance, scaling,
simplicity, security, statelessness, cost, "best practice" — as why the move happened, or as
the likely reason, without saying the repository does not record it.
FAIL if the reply gives no answer at all, or says it could not find the project.
