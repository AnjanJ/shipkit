# Design: The map on trial (Sprint 8)

## Approach

A generator, not a fixture: one standard-library Python script writes a 200-file service with a
25-commit history into the eval run's empty workspace, so the plugin carries 14 KB instead of
400 and both arms of the comparison share identical commits. Five cases ask the elder the four
old questions, made harder by decoys, plus one the source cannot answer without history. A
small script counts tool calls and tokens from the traces. The record's clause then reads the
numbers, and the sprint acts on the side they fall on — one lint check written first, a handful
of prose edits, nothing removed.

---

## Decision: The XL fixture is generated at scaffold time, never committed   (→ REQ-1, REQ-2, REQ-6, REQ-7)

**Context.** Decision 0001 asks for a fixture of at least 200 files. The eval budget (A9) is
100 KB for all of `plugins/shipkit/evals/`, of which 51.5 KB is used; every eval run starts in
an empty workspace and gets its files only from a scaffold script that runs from the plugin's
own directory.

**Alternatives.**
1. A deterministic generator (`generate.py`, standard library only, ≤ 16 KB) that the scaffold
   runs; nothing generated is committed.
2. Commit the generated tree under `evals/fixtures/` (several hundred KB).
3. Copy a real repository of the owner's at scaffold time (needs network or a path outside the
   plugin; not reproducible on another machine).

**Case for (1).** It fits the budget with room for Sprint 9, the fixture is identical on every
machine and in every run, the `--no-map` arm is a flag rather than a second copy of the plugin,
and the history — the part the re-test exists to measure — is built by the same script, so the
commits are the same with and without a map.

**Case against (1).** A generated project is less varied than a real one, and the executor
decides what the decoys are; a fixture that is too regular lets a single grep find every answer
and the arms do not separate. The generator is also one more script to keep deterministic
(no clock, fixed author dates).

**Decision.** We chose (1). The lint gains the 100 KB check so the budget the choice protects is
enforced from now on.
**Falsifiability.** We would reverse this — commit a real-repository fixture and raise the
budget — if, on the generated fixture, every one of the five cases is answered in two tool
calls or fewer in all three arms, which would mean the generator failed to make a codebase
that needs searching.
**Fired-if.** manual

---

## Decision: The comparison acts in the same release   (→ REQ-15, REQ-16, REQ-17)

**Context.** The record has been "measured, not yet acted on" since 3.2.0 and was carried as
pending through the 4.0 trim audit. B3 of the plan asks that this sprint settle it.

**Alternatives.**
1. Measure in S8-T3 and change the shipped files in S8-T4, after a stop where the owner sees
   the numbers.
2. Measure only; change the default in a later sprint.

**Case for (1).** The clause is already written and concrete; nothing is learned by waiting,
and a pending default is a claim the README makes without evidence for a third release. The
change on the optional side is prose in three places plus one agent sentence, guarded by a lint
check written first, so its scope is visible before any skill text moves.

**Case against (1).** A sprint whose last task is decided by its third task cannot be fully
planned up front; the two branches of S8-T4 are both written and one is discarded. If the
numbers are close, the owner decides under time pressure.

**Decision.** We chose (1), with the stop in S8-T3 so the decision is the owner's, not the
executor's. The two branches are EARS "Where" requirements; the branch not taken is marked
`[untested: the condition did not hold]`.
**Falsifiability.** We would reverse this — split the change into its own sprint — if S8-T4's
Files line has to grow beyond the eleven files it names, which would mean "optional" is a
bigger change than B4 describes.
**Fired-if.** manual

---

## Decision: What "optional" means, if it comes to that   (→ REQ-15, REQ-16)

**Context.** The record's option 2 reads "the elders go straight to the source, and use a map
when one exists; nothing recommends building one by default". Several shipped surfaces present
the map as step one: `setup`'s steps, the README's opening, the GUIDE's playbooks, the elders'
first instruction.

**Alternatives.**
1. Offer, do not require: `setup`, README and GUIDE describe the map as an option with its
   trade-off and the measured number; the elders read it when present and otherwise go to the
   source; the archivist, `/shipkit:map`, the stale-map nag and `eve`'s registry are untouched.
2. Also silence the stale-map nag.
3. Remove the map: archivist, skill, nag, registry column.

**Case for (1).** It is the smallest change that makes the record's words true. A project that
chose a map keeps every tool for it, including the nag, which only fires when a map exists and
is stale — a stale map is a wrong answer waiting to be trusted, which the nag prevents. `eve`'s
portfolio answers still come from maps where there are maps.

**Case against (1).** A map that is merely offered will be built less often, and `eve` answers
cross-project questions from maps; a thinner portfolio of maps makes `eve` slower. The README
loses a simple opening line ("build a map first") for a more honest, longer one.

**Decision.** We chose (1).
**Falsifiability.** We would move to (2) if, in the six months after 4.1.0, the nag is reported
as noise by a project that deliberately keeps no map (it should be impossible — the nag needs a
map — so a report would mean a bug, not a policy change). We would revisit (3) only on a new
measurement, never on this one.
**Fired-if.** manual

---

## Decision: What counts as a correct answer, settled before the run   (→ REQ-14)

**Context.** In 3.2 the `drift` case failed without a map only because the case requires the
reply to say the map is wrong; the record declined to count that as the map's "one more correct
answer". The XL `drift` case has the same shape. The XL `history` case is new and could be read
either way: the map's Evolution section states the answer, but so do the commit messages.

**Alternatives.**
1. `drift` is not counted when its pass exists only because of the planted error (as 3.2);
   `history` is counted at face value.
2. Count every grader pass as given.
3. Drop `drift` from the XL set.

**Case for (1).** It is the rule the record already applied, so the two measurements are
comparable; `history` is a fair test because the no-map arm has the answer in `git log`, so a
map win there is a cost win, which is exactly what the clause's second number measures.

**Case against (1).** It leaves the executor one judgement call per `drift` run (did the reply
get the fact right?), which must be shown in the results document, not asserted.

**Decision.** We chose (1), and the rule is written here before any run so it cannot be fitted
to the numbers.
**Falsifiability.** We would reverse this — count `drift` as given — if the no-map `drift` runs
get the underlying fact wrong (an in-process dict in `app/inventory/cache.py`), because then the
failure would be a wrong answer, not a missing accusation.
**Fired-if.** manual

---

## Data / interface changes

- New: `plugins/shipkit/evals/fixtures/ledger-gen/generate.py [--no-map]` (REQ-1 to REQ-6),
  `plugins/shipkit/evals/fixtures/FACTS-XL.md` (REQ-5), five case folders under
  `plugins/shipkit/evals/grandfather-xl/` (REQ-8, REQ-9), `scripts/trace-tools.sh <dir>`
  (REQ-10, REQ-11), `docs/design/eval-results-4.1.md` (REQ-12).
- Changed: `scripts/lint.py` gains the 100 KB eval check (REQ-7) and, on the optional side,
  the "map is offered, not required" check (REQ-15); decision 0001 gains its re-test section
  and a new status line (REQ-13).
- Environment: `SHIPKIT_EVAL_NO_MAP=1` is read by the XL scaffolds only (REQ-9). No shipped
  script reads it.
