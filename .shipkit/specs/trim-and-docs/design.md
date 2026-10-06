# Design: Trim and tell the story (Sprint 7)

## Approach

One document that proposes and a stop; then edits that remove or shorten, each guarded by a
lint check so the limits hold after the sprint; then three documents rewritten. No new
behaviour. The lint is where the limits live because it already runs in CI on every push and
already counts skills and agents.

---

## Decision: The repository's own document checks live in the lint, not in smoke or by hand   (→ REQ-6, REQ-9, REQ-12, REQ-13, REQ-17)

**Context.** The plan's "Done when" lines for S7-T3 and S7-T5 are greps a person runs once
(`grep` each skill name against `plugins/*/skills/`, count the README's lines, read the
roadmap's status line). A limit checked once is a limit that drifts.

**Alternatives.**
1. Add the checks to `scripts/lint.py`, which CI runs on every push.
2. Add them to `scripts/smoke.sh`, which runs before a release and needs a logged-in CLI.
3. Run them by hand at release time, as the plan writes them.

**Case for (1).** The lint already owns this kind of check (skill counts in the README and
marketplace, the always-on byte budget) and needs no model and no login; a README that names a
skill that was cut would fail the next push, not the next release. Option 2 ties a text check
to a ten-minute model run; option 3 is what let the 3.6.0 tag point at a red lint.

**Case against (1).** `scripts/lint.py` joins the Files line of three tasks that the plan wrote
as single-document tasks, and a lint that reads the README couples the docs to the build. A
check that counts README lines is also blunt: it says nothing about whether the lines are good.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this — move the checks to a release-time script — if a
documentation-only pull request is blocked by one of these lint checks for a reason that is not
a real defect in the document, twice.
**Fired-if.** manual

---

## Decision: Criterion (c) counts only where an eval exists   (→ REQ-2)

**Context.** The keep rule has three criteria. (a) and (b) are read off the line. (c), "an
eval shows it changes the result", exists for none of the lines under audit: the `rules` eval
cases exercise the always-on rules, not the path-scoped or stack ones.

**Alternatives.**
1. Mark (c) "not measured" for every row and decide on (a) and (b); say so in the table.
2. Write an eval case per rule file before the audit (22 files, three runs each, per audit).
3. Treat the executor's judgement of "would this change the result" as (c).

**Case for (1).** It is honest about what is known and keeps the audit to one task. Option 2
costs more than the rules it would measure and delays the sprint by days; option 3 is the
unmeasured opinion the plan's criterion was written to replace.

**Case against (1).** A line that really does change the result but is neither a project
value nor a named trap will be marked `trim`. The owner sees every such row and can keep it; a
wrongly trimmed line can also come back when an eval later shows the loss.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this — write the eval cases first — if a line trimmed on
(a)/(b) alone is restored within two releases because a regression was traced to it.
**Fired-if.** manual

---

## Decision: The map row waits for decision 0001's re-test   (→ REQ-3)

**Context.** Decision 0001 found the map bought nothing on a nine-file fixture and wrote its
own condition before acting: re-run on a fixture of 200 or more files with one question about
how the project evolved. The plan's Sprint 7 lists the map row but no re-test task. The intake
asks the owner which way to go (question 1); this record holds the executor's default if the
owner does not choose.

**Alternatives.**
1. The row is a proposal marked "pending re-test"; the map's default is not changed this
   sprint; the re-test is a task the owner can add.
2. Add the re-test as S7-T1a: build a 200-file fixture under 100 KB, run the four
   `grandfather` cases plus one history question with and without a map, and let the number
   fill the row.
3. Act on the record as it stands and propose the map as `cut` from the default.

**Case for (1) as the default.** It is the only option that neither skips the record's own
condition (3) nor adds a task the plan did not approve (2). The owner can still choose (2) by
answering the intake.

**Case against (1).** The audit's most consequential row stays undecided for another sprint,
and the map's upkeep cost — a nag line, an archivist run, a README claim — continues.

**Decision.** We chose (1), unless the owner chooses (2) with the intake.
**Falsifiability.** We would reverse this — act on the record without the re-test — if the
owner waives the condition in writing on the audit row.
**Fired-if.** manual

---

## Data / interface changes

- `scripts/lint.py` gains checks: stack rule ≤ 40 lines, skill description ≤ 300 characters,
  no bare `mktemp` under `plugins/shipkit/scripts/` (REQ-9, pending), README skill names exist,
  README ≤ 250 lines and no version history above Install, ROADMAP status names the version —
  REQ-6, REQ-9, REQ-12, REQ-13, REQ-17.
- Files removed only per approved `cut` rows — REQ-8.
- No change to any script's behaviour except the `mktemp` template — REQ-9.
