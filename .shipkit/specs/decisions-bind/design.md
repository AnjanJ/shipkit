# Design: What a decision binds (Sprint 23)

## Approach

Six records: G1, G2, G3 and G9 from the plan, one the check-first added, and one T2's numbers added. The order is the
plan's: measure the brief as it is, change it, measure again; then the reviewer, with its cases
written first. `skills/ship/SKILL.md` does not change: step 4 already turns `VERDICT: FAIL` into
`FAIL`, so the whole gate change is one sentence in `agents/reviewer.md`.

---

## Decision: Every live decision reaches every brief, by title   (→ REQ-1, REQ-2, REQ-3)

**Context.** `brief.sh` keeps a `## Decision:` only if its heading cites one of the task's
requirements. On `linkshort`, T1 cited REQ-1 and REQ-2 and the decision on `expires_at` cited REQ-3
and REQ-4, so T1's brief said "None recorded" and the agent built `AwareDatetime`, which that
decision had rejected (`field-notes-5.0.md` §8.1). A decision about a field binds whoever touches
the field. The largest design in this repository has 9 decisions and 477 bytes of titles.

**Alternatives.**
1. Stop selecting: every live decision of the feature, by title.
2. Select through `tasks.md`: a decision reaches a task that shares a file with a task citing the
   decision's requirement. T1 and T2 share `service.py` and `api.py`, so this would have caught it.
3. A `Governs:` line in each record, matched against the task's `Files`.

**Case for (1).** No new format, it works on every existing spec, and nobody can get it wrong: the
failure on record is a selection that left the right decision out, and (1) has no selection. The
titles are what `linkshort`'s agent needed: "Reject bad `expires_at` in the service as a ValueError
subclass". The record's `**Decision.**` line would not have been: it reads "We chose option 1."

**Case against (1).** The section's name stops being strictly true, because a decision about REQ-7
does not bind T1 unless T1 meets it, and an agent may read it as its own work. (2) is more precise
and also needs no new field; it costs a second `awk` pass in a POSIX script. On a large design (1)
adds noise to every brief, and a title alone may not stop an agent the way the rejected
alternative's name would.

**Decision.** We chose (1), G1's default. The heading stays (`product-intake-brief/REQ-18`).
~~`brief-verify.sh` still bounds what an agent may change.~~ It does not: T1 and T2 share files, so
later tasks' work stays inside T1's `Files` (T2's measurement; next record). If the baseline in `brief/binds` is 0 of 3,
the change still ships on §8.1's one run, at 477 bytes at most, and the record says the number
shows nothing.
**Falsifiability.** We would print each decision's rejected alternatives if `brief/binds` builds one
in any of ten runs on the new brief (set before those runs; the baseline built one in 3 of 10), and
move to (2) if a brief's decision list passes 1,000 bytes on a
real spec.
**Fired-if.** manual

---

## Decision: The brief says a decision is not extra work   (→ REQ-14, REQ-4)

**Context.** The record above named this: "an agent may read it as its own work". Measured with
REQ-1 alone, ten runs of `brief/binds`: no rejected alternative, and all ten opened the design, but
9 of 10 built later tasks' work inside T1 (injected `now` 9, `InvalidExpiry` 5). The one that did
not said why: "adding them now would be unused code. They belong to later tasks." The score could
not see this, and `brief-verify.sh` could not either. Work built early has no test that failed
first, which is what T2's `Test` line exists for.

**Alternatives.**
1. One sentence above the list: a decision limits how the task is done and is not extra work.
2. Two lists, split by the old citation test: this task's decisions, and the rest as not your work.
3. Back out REQ-1, and leave decisions to the reviewer and the gate.
4. Keep REQ-1 alone, and accept the work built early.

**Case for (1).** The cause is one heading read literally, and the fix is one sentence in the place
the agent reads it. It adds no code path and needs no selection.

**Case against (1).** It adds words to every brief with a decision, and a sentence may lose to a
heading that says "bind": the heading cannot change (`product-intake-brief/REQ-18`). (2) gives the
agent a list it can act on and not a rule it has to apply, at the price of about 12 lines of `awk`.

**Decision.** We chose (1), the owner's word at T2's STOP. `brief/binds` gains a second grader.
**Falsifiability.** We would move to (2) if, on ten runs of the new brief, later tasks' work appears
in more than 1 run, or a rejected alternative in any (set before those runs).
**Fired-if.** manual

---

## Decision: The fixture runs `brief.sh`, and the agent reads its output   (→ REQ-4)

**Context.** The plan's check-first asks whether a case can run `brief.sh` in the eval sandbox.
A case needs the brief; the sandbox has no shipkit path the prompt can name.

**Alternatives.**
1. `fixture.sh` runs `brief.sh` from the plugin and writes `BRIEF.md` into the workspace; the prompt
   says to do the task it describes.
2. The prompt tells the model to run `brief.sh` itself.
3. A headless probe as W14 did, with nothing kept in the release run.

**Case for (1).** A fixture already reaches into the plugin (`lib/with-rule.sh`, `fixtures/`), the
agent gets the script's output unchanged, as `/shipkit:spec` says it must, and the case stays in
every release run as this decision's watch.

**Case against (1).** The case does not exercise the hand-over itself, only what the agent does
with a brief. A fixture that writes the brief at scaffold time measures whichever `brief.sh` is on
the tree, so the before and after are two runs of the suite, not two arms of one run.

**Decision.** We chose (1).
**Falsifiability.** We would fall back to (3) if the fixture cannot reach `scripts/brief.sh` from
the case directory under `bash scripts/evals.sh`.
**Fired-if.** manual

---

## Decision: The reviewer names two states, `contradicted` and `not built`   (→ REQ-6, REQ-7)

**Context.** Step 5 says "check the code follows it". On `linkshort` the reviewer cited
`AwareDatetime` under REQ-3 and called all three decisions "unimplemented, not contradicted"
(`field-notes-5.0.md` §9.2): it read the choice and not what the record turned down. A spec one
task in has many decisions not built yet, and those are not defects.

**Alternatives.**
1. Two named states in step 5 and in the reply's template, and the alternatives named as part of
   what to read.
2. Leave step 5, and rely on the brief.

**Case for (1).** The brief prevents; the reviewer detects. An agent can ignore a title, and work
done without a brief reaches the gate too. The two names let G3 fail one and not the other.

**Case against (1).** A model's judgement of "contradicted" is unmeasured, and the reviewer already
ended itself with `placeholder` 3 times in the last 10 gates. More text in that agent is not
obviously free.

**Decision.** We chose (1), G2's default, with both directions as cases: `rejected-alternative` and
`decision-unbuilt`.
**Falsifiability.** We would drop the two names if either case reads below 3 of 3 after two rewordings.
**Fired-if.** manual

---

## Decision: A contradicted decision fails through the reviewer's verdict   (→ REQ-8, REQ-9, REQ-10, REQ-11, REQ-12)

**Context.** `agents/reviewer.md:89` says decisions not followed "do not change the verdict; the
ship gate weighs them". `skills/ship/SKILL.md` never mentions them: step 4 reads the verdict line
and step 6 checks reversal conditions. So nothing weighs them, and `review-and-ship/REQ-6` defines
the verdict by requirements alone.

**Alternatives.**
1. The reviewer's verdict: `PASS` needs every requirement `MET` and no live decision `contradicted`.
2. A new clause in the gate's step 6 that reads the review's "Decisions not followed" section.
3. Reported only: correct the sentence to say nothing weighs them.

**Case for (1).** One sentence, in the one reader that has seen no one's account of the work.
Step 4 already turns `VERDICT: FAIL` into `FAIL`. The way out already exists and is the right one:
change the code, or mark the decision superseded with a new record, so changing your mind leaves a
trace. (2) makes the gate's model judge a section by its wording, a second judge of the same thing.

**Case against (1).** It amends a shipped requirement. A misread fails a sound feature, and a false
NOT READY is what `ship-gate` already suffers from `placeholder`. A verdict that was one rule
(every requirement `MET`) becomes two. (3) changes no behaviour and keeps the owner as the judge.

**Decision.** We chose (1), G3's default. `review-and-ship/REQ-6` is amended in place with a note.
"Changes beyond the spec" stay reported only, for the owner to read in the report.
**Falsifiability.** We would fall back to (3) if `reviewer/decision-unbuilt` or `reviewer/all-met`
reads below 3 of 3 after REQ-8, or if a real gate says NOT READY on a decision the code follows.
**Fired-if.** manual

---

## Decision: The ceiling stays, and the reviewer fixtures share one script   (→ REQ-13)

**Context.** `plugins/shipkit/evals/` is 198,837 of 204,800 bytes: 5,963 of room against about 9 KB
of new cases across Sprints 23 and 24. `reviewer/all-met/fixture.sh` and `missing-req/fixture.sh`
are 4,245 bytes each and differ in one line, `COMPLETE=yes`. `lint.py`'s comment records three
raises.

**Alternatives.**
1. Move the fixture to `evals/lib/`; each case keeps a few lines that set its variant.
2. A fourth raise.
3. Trim the evals README, 28,687 bytes.

**Case for (1).** It removes real duplication, frees about 4 KB, and makes two new `reviewer` cases
cost a few hundred bytes each instead of 4.9 KB.

**Case against (1).** It touches two passing cases to make room for others, and the margin after
Sprint 24 is about 1 KB, on an estimate.

**Decision.** We chose (1), G9's default. The move is its own commit, with `--group reviewer` read
before anything else changes.
**Falsifiability.** We would drop `eve/consolidate`, by the owner's word, if the directory passes
204,800 bytes in Sprint 24, and would raise the ceiling only on the owner's word.
**Fired-if.** manual

---

## Data / interface changes

- `brief.sh`: `decisions()` stops selecting; `$REQS` no longer reaches it; the "None recorded" line
  says "for this feature"; one sentence above a listed decision.
- `agents/reviewer.md`: step 5, the reply template's "Decisions not followed" line, the verdict
  sentence.
- `evals/lib/`: the shared `reviewer` fixture script. `evals/reviewer/`, `evals/brief/`: new cases.
- `.shipkit/specs/review-and-ship/spec.md`: REQ-6 amended in place with a note.
- No change to `skills/ship/SKILL.md`, to any rule, or to any description.
- No migration: an existing spec works unchanged, and a brief grows by its other decisions' titles.
