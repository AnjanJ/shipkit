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

## 2. A contradicted decision fails the review (G2, G3)

`bash scripts/evals.sh --group reviewer -j 4 --keep-temp`, three runs per case, `sonnet`, Claude Code
2.1.316, 2026-10-31. `rejected-alternative` meets every requirement and catches a gateway failure
the record turned down. `decision-unbuilt` holds a decision a later task builds and a superseded one
the code does not follow.

| Case | `reviewer.md` before | After |
|---|---:|---:|
| `reviewer-rejected-alternative` | 0 of 3 | 3 of 3 |
| `reviewer-decision-unbuilt` | 0 of 3 | 3 of 3 |
| `reviewer-all-met` | 3 of 3 | 3 of 3 |
| `reviewer-missing-req` | 3 of 3 | 3 of 3 |

**Reading.** Before, all three `rejected-alternative` runs found the contradiction, described it
correctly, and still ended `VERDICT: PASS`. That is the gap read from the text in the plan's §3,
observed: sight was never the problem, the rule was. After, all three end `VERDICT: FAIL` with no
requirement `NOT MET`, so the decision alone fails the review. `decision-unbuilt`'s 0 of 3 before says
less: the old reviewer could not use the words `not built`, and its verdict was already right.

The new grader was wrong first. It read 0 of 3 after the change, on replies that were correct: "is
superseded, so I did not weigh it". It forbade `app/billing.py` on a bullet where the defect is
marking that decision, the same mistake as `trap2/rails`' grader. It was corrected under rule 23, with
the real replies passing and two seeded markings failing, and the group re-run.

No reviewer ended itself with `placeholder` in the 30 of this section's 36 runs whose traces were
read for it; the other six passed their grader, so each reply held a verdict. $3.34: the shared
fixture's regression $0.57, the red $0.55, two groups at $1.12 and $1.10.

## 3. The gate on a contradicted decision, forced (`decisions-bind/REQ-11`)

`/shipkit:ship refunds base`, headless as smoke check 29 runs it, on `rejected-alternative`'s fixture,
`sonnet`, at `0bbd950`, 2026-10-31.

| Run | The fixture | First line | Step 4 | The failing step |
|---|---|---:|---|---|
| 1 | The code contradicts a live decision | `NOT READY` | `FAIL`, naming "A gateway error reaches the caller" | 4 |
| 2 | The decision superseded by a record the code follows, committed | `NOT READY` | `PASS` | 7, three `__pycache__/` directories |
| 3 | The same, those directories removed | `READY` | `PASS` | none |

Run 2 is the runner's error and not the gate's: run 1's test command left the directories behind, the
fixture has no `.gitignore`, and they were not cleared before the run. The gate was right to count
them. Run 3 is the requirement's second half. `skills/ship/SKILL.md` did not change. $0.66.

## 4. `map_read` and a repo-wide Grep (G5, S24-T2)

`readable-numbers/REQ-7`, `REQ-8`. **The plan's check-first holds:** on the 18 traces T1 kept, every
one of the 9 Grep calls has its result in a `tool_result` block of a `user` row, tied by `tool_use_id`,
and its `content` is a string that starts each line with a path: `Found 1 file\napp/models/order.rb` in
files mode, `app/models/order.rb:5:…` in content mode. Claude Code 2.1.316, 2026-10-31.

The count reads the path at the start of a result line and does not search the text, a thing the plan
did not say: a content-mode line from another file can name the map (`README.md:3:see PROJECT_MAP.md`),
and that is not a read of it. A files-mode hit does count though none of the map's lines reached the
model, which is the record's case against, so `map_read` is read beside the reply.

Smoke check 78 holds both, on stored two-line traces: red on the old script, three listing cases
reading 0, then PASS; check 40 still PASS. Whether this was `eve/why`'s third run in Sprint 21 is
still not shown; that sandbox is gone. `--group eve` at the merge reads it.

## 5. `reports.md` watched (G6, S24-T3)

`readable-numbers/REQ-11`. `eve/matrix` asks through `/shipkit:ask` in plain words, with neither `--all`
nor `matrix`; `eve/consolidate` runs `/shipkit:ask --all consolidate`. Three runs each, `sonnet`, Claude
Code 2.1.316, 2026-10-31, each row read from its trace.

| Case | Run | Passed | Read `reports.md` | `map_read` | `map_shell` | Tools | Cost |
|---|---:|---:|---:|---:|---:|---:|---:|
| `eve/matrix` | 1 | yes | yes | 0 | 0 | 6 | $0.15 |
| `eve/matrix` | 2 | yes | yes | 0 | 0 | 5 | $0.13 |
| `eve/matrix` | 3 | yes | yes | 0 | 0 | 5 | $0.13 |
| `eve/consolidate` | 1 | yes | yes | 0 | 1 | 8 | $0.18 |
| `eve/consolidate` | 2 | yes | yes | 0 | 1 | 7 | $0.18 |
| `eve/consolidate` | 3 | yes | yes | 1 | 1 | 8 | $0.17 |

**Reading.** The gap `eval-results-5.0.md` §3 named is closed: a matrix asked in words, with no flag,
reached `eve` with the report's shape in all three runs, and each reply gave lockfile versions, the
declared constraints and `path:line` evidence, with no map read, as `reports.md` says. A pass could
not prove the route; the traces do, 6 of 6. Three clean runs happen 29.6% of the time at a 1-in-3 miss
rate, so this says the route works, not how often. No miss, so no ROADMAP item. $0.93.

`eve/consolidate` run 3 is the first real sighting of T2's count: a repo-wide Grep with no map in its
path, whose result lists `PROJECT_MAP.md`, reads `map_read` 1, and the old script read 0. It is also the
record's case against in small: the same run had already `cat` the maps by shell. Run 1's `map_shell` 1
is a `wc -l`, and its reply says it read no map, so that column counts a mention, as it documents.

The grader was wrong first, in the wide direction this time. It took `[Ss]hared` as a judgment, so a
reply saying "could become a shared module" and judging nothing would pass. All three replies pass
without it, so it came out before the case was committed, with that reply as a seed.
