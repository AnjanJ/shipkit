# Design: Eve's portfolio and a second project (Sprint 16)

## Approach

Three records, one per plan decision (E10, E11, E13), and a sprint that is two measurements
and a roadmap. A generator, three cases and a results document give `eve` its first number;
a second real run, written up and fixed nowhere, gives the plan after its seed; the ROADMAP
closes the portfolio plan. The harness moves by one constant (lint check 17), one expected
string (smoke check 42), one new smoke check (59) and one citation comment (`evals.sh`). No
agent, rule or skill changes; no grader of an existing case changes.

---

## Decision: A portfolio fixture and three `eve` cases under three arms   (→ REQ-1 to REQ-9)

**Context.** `eve` reads the registry and each project's `PROJECT_MAP.md` and answers across
repositories without opening them. 4.6.0 measured the elder on one project and found the map
decided one answer in 45 — a history question on a "wip" log — and C11 named `eve`'s loss
when fewer projects carry a map as unmeasured, needing a three-project fixture of about 20 KB
of generator, a sprint of its own. The eval tool gives a case an empty workspace and a
`fixture.sh`; the digest cases already point `SHIPKIT_HOME` at a `shipkit-home/` inside it.
Lint check 17 holds `plugins/shipkit/evals/` at 163,840 bytes and the tree is at 148,311.

**Alternatives.**
1. `evals/fixtures/portfolio-gen/generate.py [--maps 3|1|0]` writes three small projects of
   three stack shapes (`shopfront` Rails-shaped, `pulse` Phoenix-shaped, `insight`
   Python-shaped, about 25 files each, standard library only, fixed dates, every commit "wip"),
   a registry, and a map per mapped project whose Evolution holds one *why* no file or commit
   records; three cases — a sweep (`jobs`), a cross-project where (`payments`), a why (`why`)
   — run under the committed plugin (`--maps 3`) and two scratch copies whose `fixture.sh`
   passes `--maps 1` and `--maps 0`; 27 runs; the ceiling rises to 196,608 at T0 with the
   room stated as "for cases and generators".
2. Two cases (`jobs`, `why`) and no ceiling change: the generator must fit the 15 KB of room
   beside its cases.
3. Hand-written fixture projects committed under `evals/fixtures/`: no generator, no
   determinism check.

**Case for (1).** Three cases separate three shapes of question: a sweep the registry's
`Stack` column can answer alone, a where that a grep over three manifests can answer alone,
and a why that only a map's Evolution can answer — the shape the elder showed on the "wip"
history (3 of 3 with the map, 0 of 3 without). Three arms turn "what `eve` loses" into a
column per map count, which is the question C11 asked. A generator keeps the fixture out of
the tree (check 17's purpose since 4.1.0) and a determinism check (smoke 59) keeps the facts
file true across generations. The ceiling moves once, at T0, by the same step C1 took, and
the comment says what the room is for so the next raise is argued the same way.

**Case against (1).** 27 runs measure `sonnet` on one day, on a fixture whose facts were
written to be found; a registry with `Stack` filled makes `jobs` a table read, so its "no map
needed" reading may say more about the fixture than about `eve`. The ceiling raise is
unrecoverable room: 32 KB that a later sprint will fill. (2) is cheaper and loses the where.
(3) would be found by check 17 on its first commit.

**Decision.** We chose (1), E10's default; the plan's §3 names the check-first — `eve` answers
`why` from `pulse`'s map in the three-map arm and says "not recorded" in the no-map arm —
and its fallback: the fixture's map or the question is corrected on trace evidence (rule 10),
never `agents/eve.md`.
**Falsifiability.** The three-arm design is wrong if `why` passes in the no-map arm by
reading the reason from a file — then the generator leaked the fact and REQ-5's grep in check
59 is what catches it; the `jobs` or `payments` case is rewritten if it passes 3 of 3 in every
arm by the registry's `Stack` column alone (the trace shows no manifest opened), since then
it measures the registry and not `eve`.
**Fired-if.** manual

---

## Decision: The second real run is on a repository of another stack, and fixes nothing   (→ REQ-10, REQ-11)

**Context.** `field-notes-4.3.md` ran shipkit's loop once, end to end, on
`rails_error_dashboard`; six items in three sprints came out of it (4.4.0 to 4.6.0). The field
plan's §5 left a second run for the plan after. Every stack overlay but Rails has been
measured only by evals, never by a user's loop; and every fix since 4.3 was measured on the
project that asked for it.

**Alternatives.**
1. A repository the owner names, of a stack other than Rails (Phoenix/LiveView or Python), on
   a branch `shipkit/real-run-2` never for merge, with `--plugin-dir` on this checkout at the
   sprint branch; the 4.3 notes' steps in order, each headless where the 4.3 run was, each
   written as Asked for / Produced / Took / Awkward / Whose fault / Evidence; **nothing found
   is fixed in this sprint** — the findings seed the plan after.
2. `rails_error_dashboard` again: measures the fixes since 4.3 on the project that asked for
   them.
3. A run that fixes what it finds as it goes, as Sprints 11–13 did after the fact.

**Case for (1).** A second stack exercises rules and skills the first run never loaded
(`liveview`, `mix-deps`, `pyproject`, the stack detection in setup) and separates "shipkit on
Rails" from "shipkit". Fixing nothing keeps the notes a measurement: a finding fixed mid-run
changes the plugin under test (rule 17) and is never seen again by the run that found it.
The 4.3 shape is kept so the two documents read side by side.

**Case against (1).** Another repository's findings may be that repository's (a missing test
command, an odd layout) and not shipkit's — the "Whose fault" column exists for that, and
items it marks as the project's do not reach the ROADMAP as shipkit's debts. (2) would show
whether 4.4.0–4.6.0 held on the project that asked, which this run cannot. (3) ships more and
measures less.

**Decision.** We chose (1), E11's default. The plan's approval line named `~/code/pulse`,
which is not on disk; at T0 the owner named `~/code/office_bestie` instead
(2026-10-10), an Elixir/Phoenix 1.8 project with LiveView — the second stack E11 asked for.
The intake step's request is named at T3.
**Falsifiability.** We would run (2) in the plan after if this run's findings are all marked
the project's fault in "Whose fault" — then a second stack said nothing about shipkit and the
Rails project's fixes are still unmeasured.
**Fired-if.** manual

---

## Decision: The release run grows to 58 cases, every case every release   (→ REQ-7)

**Context.** The release run is the suite's standing measurement (55 cases, $15.48 at 4.8.0).
Three `eve` cases join it. `evals.sh --group` could run only the groups a release changed.

**Alternatives.**
1. Every case, every release: 58 cases, about $17.50.
2. `--group` on changed groups only; the full run on request.

**Case for (1).** The watch cases exist to be run when nothing changed in their group — a
cut line returns on a release run where the model stops following it unaided, and a release
that touches no rule file is exactly where that is learned. The two cases that drop under
`-j 4` (`digest/attention`, `grandfather-xl/drift`) have a known shape only because every
release ran them.

**Case against (1).** $2 more per release for three cases whose fixture is generated and
whose answers the first measurement will already have given; a suite that only grows.

**Decision.** We chose (1), E13's default.
**Falsifiability.** We would move to (2) if a release run passes $25 or if two consecutive
release runs change no count from the run before — then the full run is a receipt, not a
measurement.
**Fired-if.** manual
