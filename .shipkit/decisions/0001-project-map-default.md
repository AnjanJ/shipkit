# 0001 — Is `PROJECT_MAP.md` the default source for the elders?

> Recorded 2026-10-05 on `sprint-1/measure-and-slim`. Status: **measured, not yet acted on.**
> Evidence: `docs/design/eval-results-3.2.md`.

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
