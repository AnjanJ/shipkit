# Eval results 5.1.0

The binding plan's measurements (`docs/plans/binding-sprint-plan.md`), each read from the run's trace
and not from an eval summary (rule 10).

## 1. Does a brief let a rejected alternative through? (G1)

`decisions-bind/REQ-5`. The case is `plugins/shipkit/evals/brief/binds`, `linkshort`'s shape at
`69578a5` cut down: T1 on REQ-1 and REQ-2, three decisions, the third citing only REQ-3 and REQ-4 and
rejecting Pydantic's `AwareDatetime` and a `field_validator`. The fixture writes `BRIEF.md` from
`brief.sh`, and the prompt says to do what it says. `bash scripts/evals.sh --group brief -j 4
--keep-temp`, `sonnet`, Claude Code 2.1.316, 2026-10-31.

The plan said three runs per arm. The owner raised it to ten at T1's STOP: at a miss rate of 1 in 3,
a clean 3 of 3 happens 29.6% of the time with no fix at all, and a clean 10 of 10 1.7%.

**Before: `brief.sh` at `66ceb4f`.** The brief says "None recorded for this task's requirements."

| Run | Read the design | Rejected alternative built | Passed | Tools | Cost |
|---|---|---|---|---:|---:|
| 1 | no | **yes: `AwareDatetime`** | no | 3 | $0.08 |
| 2 | no | no | yes | 14 | $0.10 |
| 3 | yes | no | yes | 4 | $0.09 |
| 4 | no | **yes** | no | 13 | $0.10 |
| 5 | no | **yes** | no | 12 | $0.11 |
| 6 | yes | no | yes | 4 | $0.09 |
| 7 | no | no | yes | 13 | $0.11 |
| 8 | yes | no | yes | 4 | $0.09 |
| 9 | no | no | yes | 3 | $0.08 |
| 10 | no | no | yes | 13 | $0.11 |

**Reading.** 3 of 10 built the rejected alternative, the failure of `field-notes-5.0.md` §8.1, so the
plan's check-first holds. The split is the finding: **0 of the 3 runs that opened the design built
it, and 3 of the 7 that did not.** A run opened it by choosing to `cat` the spec folder; the brief
never pointed there, because its "(Full text: …)" line prints only when a decision is listed. The
other four runs that skipped the design wrote plain `datetime`, which passes without any knowledge
of the decision: those are chance, not the brief working.

Run 1's `AwareDatetime` was read from its code. Runs 4 and 5 are marked by the classifier, which
flags either rejected alternative and did not record which, and their sandboxes were removed before
that was noticed, so the table does not name theirs.

One fixture, one model: 3 of 10 is this fixture's rate. $0.97 for the ten runs.
