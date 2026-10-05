# Decision Records

A non-trivial choice between two or more real alternatives gets a record.

Five parts: **Context, Alternatives, Case for, Case against (your own choice), Decision + "I would reverse this if ___"**.

The reversal condition must be a metric, event or threshold ("if p99 exceeds 200ms"), never a hedge. If none exists, say so; never fake one.

A feature's decisions go in its spec's `design.md`; project-wide ones in `.shipkit/decisions/NNNN-<slug>.md` (`/shipkit:decide`). A superseded record is marked, not deleted.
