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
