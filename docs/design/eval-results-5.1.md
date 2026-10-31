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

**After REQ-1 alone: every live decision, by title.** Ten runs at `be2ac61` plus `brief.sh`'s change.
The bar, set before these runs, was no rejected alternative in any of ten.

| Run | Opened the design | Rejected alternative built | Later tasks' work | Tools | Cost |
|---|---|---|---|---:|---:|
| 11 | yes | no | **`now`** | 4 | $0.10 |
| 12 | yes | no | **`now`, `InvalidExpiry`** | 7 | $0.10 |
| 13 | yes | no | **`now`, `InvalidExpiry`** | 4 | $0.10 |
| 14 | yes | no | **`now`, `InvalidExpiry`** | 4 | $0.10 |
| 15 | yes | no | **`now`, `InvalidExpiry`** | 4 | $0.09 |
| 16 | yes | no | **`now`** | 3 | $0.09 |
| 17 | yes | no | **`now`** | 3 | $0.09 |
| 18 | yes | no | **`now`** | 4 | $0.10 |
| 19 | yes | no | **`now`, `InvalidExpiry`** | 4 | $0.10 |
| 20 | yes | no | no | 4 | $0.09 |

$0.96. The bar held, and the score read 10 of 10, and the result was not good: **9 of 10 runs built
later tasks' work inside T1.** The list reads as work under a heading that says "bind": one run added
it "to follow the binding decisions". The score could not see this and `brief-verify.sh` could not
either, because T1 and T2 share files, so the design's and the plan's reassurance on that point was
wrong. Work built early has no test that failed first. The one run that stayed in scope said why:
"adding them now would be unused code. They belong to later tasks." The owner stopped here.

The later-work column cannot be filled for runs 1 to 10: those sandboxes were removed after reading,
before anyone was looking for it.

**After REQ-14 as well: the sentence above the list, and the second grader.** Ten runs. The bar, set
in `68ce5fa` before these runs: no rejected alternative, later tasks' work in at most 1 of 10.

| Run | Opened the design | Rejected alternative built | Later tasks' work | Tools | Cost |
|---|---|---|---|---:|---:|
| 21 | yes | no | **`InvalidExpiry`** | 4 | $0.10 |
| 22 | yes | no | no | 3 | $0.09 |
| 23 | yes | no | no | 3 | $0.09 |
| 24 | yes | no | no | 3 | $0.09 |
| 25 | yes | no | no | 12 | $0.10 |
| 26 | yes | no | no | 5 | $0.09 |
| 27 | yes | no | no | 3 | $0.09 |
| 28 | yes | no | no | 3 | $0.09 |
| 29 | yes | no | no | 3 | $0.09 |
| 30 | yes | no | no | 3 | $0.09 |

$0.92. The bar holds. A passing run says the listed decisions "belong to later requirements" and
quotes the sentence. Run 21 is the one miss, and it is argued and disclosed: "Parsing the string
needs this, so I added it even though REQ-3 isn't mine."

| | Before | REQ-1 alone | REQ-1 and REQ-14 |
|---|---:|---:|---:|
| Rejected alternative built | 3 of 10 | 0 of 10 | 0 of 10 |
| Opened the design | 3 of 10 | 10 of 10 | 10 of 10 |
| Later tasks' work in T1 | not counted | 9 of 10 | 1 of 10 |

**Reading.** Two-sided Fisher: rejected alternative 3 of 10 against 0 of 20, p = 0.03; opened the
design 3 of 10 against 20 of 20, p < 0.001; later tasks' work 9 of 10 against 1 of 10, p = 0.001. The
first comparison alone, 3 of 10 against 0 of 10, is p = 0.21, so REQ-14's runs are part of the reason
the claim stands. What changed the agent's behaviour is mostly that it now opens the design: the
"(Full text: …)" line used to print only when a decision was listed, and T1's brief listed none.

One fixture, one model. The brief grows by 233 to 422 bytes on three real specs, plus the sentence.
