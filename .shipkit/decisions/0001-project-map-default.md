# 0001 — Is `PROJECT_MAP.md` the default source for the elders?

> Recorded 2026-10-05 on `sprint-1/measure-and-slim`.
> Status: **re-tested on 2026-10-07 — the map becomes optional (S8-T4).**
> Evidence: `docs/design/eval-results-3.2.md` (nine files), `docs/design/eval-results-4.1.md`
> (224 files, one history question — the re-test this record asked for).

**Context.** Since 1.x shipkit has told every project to build and keep a `PROJECT_MAP.md`: the
archivist writes it, a session hook nags when it goes stale, and `grandfather` and `eve` read
it first. That is a standing cost — a file to refresh, a line of nagging, and a claim in the
README — and until this sprint nothing measured what it buys. Sprint 1 built four eval cases
against a fixture with known answers so the question could be put to numbers.

**Alternatives.**
1. Keep the map as the default: the elders read it first, setup recommends it, the hook nags.
2. Make the map optional: the elders go straight to the source, and use a map when one exists.
   Nothing recommends building one by default.
3. Drop the map altogether.

**Case for keeping it (1).** A map is the only place that can hold what the source cannot:
how the project evolved, why it is shaped this way, the traps. `eve` answers cross-project
questions from maps without opening each repository. On a large codebase an index should save
searching. And a map that disagrees with the code is itself a signal, which the `drift` case
shows the elder catches.

**Case against keeping it (1).** On the four cases measured, the map bought nothing: the same
12 of 12 correct answers with and without it, and 49 tool calls against 51. A map goes stale,
and a stale map is a wrong answer waiting to be trusted — the fixture's own map is wrong about
where orders are stored. Every project pays to keep it fresh whether or not it is ever read.

**Decision.** We chose the rule below when planning the sprint, before measuring, and the
numbers fall on its "otherwise" side: **the map becomes optional.** This sprint changes no
shipped file. The change is carried to the Sprint 7 trim audit (S7-T1), where the owner
approves or rejects it.

**Falsifiability.** We keep the map as the default if, on these cases, it gives at least one
more correct answer or at least 20% fewer tool calls than no map. Otherwise the map becomes
optional.

Where the numbers fall:

- *One more correct answer?* **No.** By the graders, the map scores 4 cases against 3. The
  difference is `drift`, which fails without a map only because it requires the reply to say
  the map is wrong. All three of those replies gave the right answer. Counting a pass that
  exists only because the map contains a planted error would be circular, so it is not counted.
- *At least 20% fewer tool calls?* **No.** 49 against 51 is 4% fewer.

**How far to trust this.** The fixture has nine files and every answer sits in one of them; a
single search finds it. The cases never ask about history or reasons. So this measures the map
where a map helps least. Before Sprint 7 acts on this record, re-run the comparison on a
fixture of at least 200 files with one question about how the project evolved. We would restore
the map as the default if, there, it gives at least one more correct answer or at least 20%
fewer tool calls. That re-test is this record's addition; the owner's plan asked only for the
clause above.

## Re-test (4.1.0)

Run 2026-10-07 on `sprint-8/map-on-trial` (spec `map-on-trial`), on the generated `ledger`
fixture: 224 files, 27 commits, the four questions again with decoys, and `history` — why order
storage left the JSON file and when — whose answer is in commit 20's message and the map's
Evolution section, not in the current source. Three arms, five cases, three runs each, counted
from traces by `scripts/trace-tools.sh`. Full tables: `docs/design/eval-results-4.1.md`.

The clause asked two questions. The counting rule for `drift` was fixed in the spec's design
before any run: a pass that exists only because the map contains the planted error is not one
more correct answer.

- *One more correct answer?* **No.** By the graders, 14 of 15 runs with the map against 12 of
  15 without; the gap is `drift`, which needs the reply to call the map wrong, and all nine
  `drift` replies in every arm got the fact right (an in-process dict, `app/inventory/cache.py:2`).
  On the questions asked: 15 of 15 with the map, 15 of 15 without. `history` passed 3 of 3 in
  both arms — every run read `git log`, with the map or without.
- *At least 20% fewer tool calls?* **No.** 62 against 65 is 4.6% fewer; with the baseline run
  counted too, 4.23 against 4.33 calls per run, 2.3% fewer.

Both fall on the "otherwise" side, as they did on nine files. Two things the larger fixture
added: the elder opened the map in nine of thirty with-map runs although its instructions say
to read it first — it greps, the grep finds the answer, and the map is an afterthought; and the
history question, the map's strongest case on paper, was answered from the commit log every
time, with the map read afterwards if at all.

**What this does not settle** (carried in the results document): a map on a repository whose
commit log is uninformative; `eve`'s portfolio answers, which read maps without opening
repositories; a stale map's cost. None of these is measured, and none is changed by S8-T4.

**Decision, as the clause reads it: the map becomes optional.** Per the plan's B4: the elders
read a map when one exists and go to the source when none does; `/shipkit:setup`, the README
and the guide offer the map with this number beside it instead of presenting it as the first
step; the archivist, `/shipkit:map`, the stale-map nag and `eve`'s registry stay as they are.

**What changed (4.1.0, S8-T4).** `/shipkit:setup`, the README and the guide offer the map
instead of listing it first; `grandfather` reads it when present and goes to the source
otherwise, without calling the answer slower; `eve` greps a registered repo that has no map
rather than reporting it as a gap; `/shipkit:map`'s description says when a map earns its keep.
Lint check 18 keeps the three documents from presenting the map as required again. The
archivist, `/shipkit:map`, the stale-map nag and the registry are unchanged. **Closed.**

**The elder's step 1, measured (4.6.0, S13-T4, field plan C9).** The one experiment this record
left open — a step-1 sentence that makes `grandfather` read the map on explanation questions —
was tried twice on the five `grandfather-xl` cases, 15 runs each, read rate counted from the
traces (`trace-tools.sh --map_read`: a tool_use whose input path ends in `PROJECT_MAP.md`,
main session or subagent), answers judged as before. Baseline, the 4.5.0 text: 15 of 15 right,
the map read in **1 of 15**. Attempt 1 (step 1's first bullet: "`Read` it as your first tool
call, before any grep"): 15 of 15 right, **4 of 15**. Attempt 2 (step 1's heading: "for every
question but a one-fact lookup — 'where is X cached', 'what is missing', 'why' and 'how does X
work' all read it"): 15 of 15 right, **8 of 15** (`history` 3, `explain` 3, `drift` 2, `gap` 0,
`lookup` 0). Neither reached 10 of 15; both reverted, the agent is unchanged. What the traces
say: step 0's "try the cheap grep first" wins whenever the grep lands, and on this fixture it
lands; the one question where the map changed the answer is `history` on a "wip" log
(`eval-results-4.6.md`, S13-T5), which is the exception this record already names. **Still
closed; the map is optional.**

**Step 0, closed (4.8.0, S15-T3, portfolio plan E2).** The question 4.6.0 left — should step 0's
triage itself change, and is a read that never changes an answer worth its tokens — is answered
by the numbers already in hand, with no new run. Across the baseline and the two attempts, 45
runs on three texts gave 45 right answers while the map was read in 1, 4 and 8 of 15; no read
changed an answer. The one question the map decided, `history` on a "wip" log, is the exception
this record names, and there the elder read it 3 of 3 without a sentence telling it to
(`eval-results-4.6.md`, S13-T5). The cost of a read is visible in the 4.0.0 XL baseline's token
columns (`docs/design/eval-history.md`, "Baseline 4.0.0 (XL)"): the `drift` and `gap` runs whose
main session read the map carried 68.1k input tokens against 44.7k–45.0k for those that did not
— about 23k more per run for an answer the grep had already found. So step 0 stays as written:
the cheap grep first, the map when the grep does not land or the question is about evolution.
**Reversal:** we would run one attempt at step 0, or change it, if an elder case on a fixture
where the grep does *not* land (Sprint 16's portfolio `why` case is the first such) gives a
wrong answer that the map, when read, gets right. **Still closed; the map is optional.**

**`eve`'s number (4.9.0, S16-T2, portfolio plan E10).** The loss C11 left unmeasured, measured on a
generated three-project portfolio under three arms (three maps, one, none), 27 runs
(`docs/design/eval-results-4.9.md`): the sweep (`jobs`) and the cross-project where
(`payments`) held the same counts in every arm — 3 of 3 and 2 of 3 — and read no map in any
of their 18 runs; the why (`why`: a reason no file and no commit records) came back 3 of 3
from `pulse`'s map and was "not recorded" 6 of 6 without it. The map was reached by the grep
landing on its Evolution lines, which is step 0 as written. So `eve` is the same as the elder:
the map's worth is its Evolution section, for the question nothing else records; a registry
row without a map is answered by a grep at no loss for a sweep or a where. **Still closed; the
map is optional — and `--register` should keep saying the map is for the why.**
