# Design: What every session pays (Sprint 20)

## Approach

Six records, one per plan decision this sprint carries (W0, W1, W2, W3, W4, W10), and a sprint
that is one measuring script, one hook branch, one probe, two merges and one ceiling. Nothing
in the loop's skills' bodies changes; the merged skills keep their bodies as reference files
read on an argument, the way `setup` already reads `reference.md`. Every cut is measured
before it is kept: the opt-in by the `rules` group at its 4.12.0 counts and smoke check 64,
the merges by one headless auto-invoke probe per merged trigger, the agents by the
`grandfather` group, the Care lines by a probe with and without the plugin and the owner's
word before anything moves.

---

## Decision: Sprint 19 ran as written, and this plan starts from 4.12.0   (→ REQ-3)

**Context.** The plan's draft (2026-10-22) folded Sprint 19 into Sprint 22 (W0). The owner
chose on 2026-10-30 to complete Sprint 19 as written; it shipped as 4.12.0 the same day
(PR #23). The plan was approved after that, so its baselines, its Sprint 22 and its budget
had to be re-read against a tree the draft never saw.

**Alternatives.**
1. Amend the plan in place: W0 "ran as written", baselines to 4.12.0's release run, Sprint 22
   as a run again on the same project with the thinned plugin, W13 and W14 for what the 4.12
   run found, the §0 table re-measured.
2. Leave the draft's text and let each sprint's spec restate what changed.

**Case for (1).** One document says what is true; a reader of Sprint 22's spec in a month
does not need the thread. The re-measured table shows the draft's numbers within a few bytes,
so the plan's argument stands and only its history changes.

**Case against (1).** The plan now carries an amendments section and strikethrough text —
longer, and a reader must know which lines are the draft's and which the approval's.

**Decision.** We chose (1): `docs/plans/thinning-sprint-plan.md`, "Amendments of 2026-10-30".
**Falsifiability.** We would reverse this — splitting the amendments into a second file — if
the amendments section grows past the decision table it amends (more than about 60 lines).
**Fired-if.** manual

---

## Decision: The two loop rules are injected only where a project opted in   (→ REQ-4, REQ-5, REQ-6, REQ-7)

**Context.** `inject-rule.sh` injects each of the three always-on rules into every session on
every project unless the rule's own file is installed under `.claude/rules/shipkit/`. On a
project that never ran shipkit this is 3,861 bytes of spec-driven and decision-record
discipline for a loop the project is not using; the 4.12 run's §1 showed the same hook saying
nothing about how to opt in. The eval sandboxes have no `.shipkit/` and reach their rule only
through the hook (`CLAUDE_CODE_DISABLE_CLAUDE_MDS=1`).

**Alternatives.**
1. Inject `spec-driven` and `decisions` only when `.shipkit/` exists in the working directory
   (a product file, a spec or setup has been run); keep `shipkit.md` universal pending W2;
   under `CLAUDE_CODE_EVAL_CONFINED=1` inject all three as today; on a project with neither
   `.shipkit/` nor installed rules print one opt-in line, once.
2. Measure first and keep everything universal whatever the number (the 2.8 "automatic tier").
3. Make all three opt-in now, including `shipkit.md`.

**Case for (1).** The two rules describe how to work inside shipkit's loop; a project without
`.shipkit/` has no loop to work inside. The eval branch keeps the three `rules/*` cases
measuring the rules and not the opt-out. The opt-in line answers the 4.12 §1 finding in the
place a user would read it.

**Case against (1).** A project that never opts in loses the spec-first nudge entirely —
`rules/nontrivial` showed that nudge turning 0 of 6 into 6 of 6 on a non-trivial request
(4.2.0) — so the discipline reaches fewer projects by default. Smoke checks 1 and 2 assume
injection in a bare `$PROJ` and must be given a `.shipkit/` or a sibling check. (3) would cut
the Care lines before their number exists.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this — injecting the two rules universally again — if a
`rules/*` case drops below 2 of 3 in a release run with the injected header present in its
trace (the rule reached the sandbox and still failed), or if an opted-out project's session is
seen building a non-trivial change with no spec in a real run's notes twice.
**Fired-if.** `! grep -q 'CLAUDE_CODE_EVAL_CONFINED' plugins/shipkit/scripts/inject-rule.sh`

---

## Decision: The Care lines move only by their number   (→ REQ-8, REQ-9)

**Context.** `shipkit.md`'s `## Care` section (753 bytes as shipped) is the one rule a project
that never opted in would still carry under W1: never say done unproven, ask before anything
destructive, no secrets staged. No case exercises it. Whether the model follows it unaided
decides whether the hook on such a project is three lines or one rule.

**Alternatives.**
1. One probe case `rules/care` — a request destructive on its face in `sample-app` — three
   runs with the plugin and three in the plugin-off arm; followed unaided 3 of 3 in both →
   `shipkit.md` joins the opt-in set; otherwise it stays universal with the number in this
   record. The owner sees the table before anything moves.
2. Keep `shipkit.md` universal by the owner's word, no probe.
3. Cut it to the opt-in set now on the 2026-10-22 review's reading.

**Case for (1).** Rule 20: an always-on byte has a number or a word. The measured-cuts sprint
(4.8.0) showed lines the model follows unaided and lines it does not, and the two cannot be
told apart by reading. One probe is about $1.

**Case against (1).** "Asked before acting" has many shapes; a regex cannot read it and an
`llm` grader costs three judge calls per run. Three runs is a small number for a decision
about every session on every project; the owner's word (2) is cheaper and the plan allows it.

**Decision.** We chose (1).

**The table (2026-10-30, `docs/design/eval-results-5.0.md` §1).** `rules/care`, `sonnet`,
`--ablation with-without`, three runs an arm, $0.40: **with the rule 0 of 3, without 0 of 3.**
Every run deleted `tests/` and `app/jobs/` with `git rm`, committed, and asked only about the
force-push the fixture made impossible (no remote). The grader read right; the prompt is the
case the Care line names. A third outcome the clause did not name: the line is not followed in
either arm. By the clause's letter `shipkit.md` stays universal; the Care lines' own number is
0 of 3 on this request, and the wording that would change that is outside this plan (§5).
**The owner's word (2026-10-30): reword the line now and re-measure.** Reworded to "Stop
before anything destructive and ask first; never do it and ask after … A request to delete is
not the yes: end the turn on the question", the same case with the plugin read **3 of 3**
(every run ended its turn on the question, nothing deleted, nothing committed; one run lost to
the API's five-hour limit was excluded and re-run alone). `shipkit.md` stays universal on that
number; `rules/care` is its watch at `runs: 3`; the three rules are exactly 3,000 bytes after
seven wording trims that drop no clause. The plan's §5 ("no line of the three rules changes")
is amended for this one line, on the owner's word after the table.
**Falsifiability.** We would reverse this — returning the original wording, or moving
`shipkit.md` to the opt-in set — if the `rules/care` watch reads below 2 of 3 in a release run
(the reworded line no longer earns its bytes), or if a real run's notes show a session deleting
or force-pushing with the rule in context.
**Fired-if.** manual

---

## Decision: Ten core skills, the merged bodies as reference files   (→ REQ-10, REQ-11, REQ-12, REQ-13, REQ-14, REQ-15)

**Context.** Seventeen core skill descriptions load into every session (3,969 bytes). Six of
them are modes of two others — `walkthrough` and `explain-system` are `ask` with a shape;
`unsetup`, `update-rules`, `context-audit` and `connect-memory` are maintenance of what `setup`
installed — and `commit` tells Claude how to work, which the 3.0 sorting rule puts in
`shipkit-workflows`. A skill's body loads only when invoked; its description loads always.

**Alternatives.**
1. Ten: `walkthrough` and `explain-system` become `ask --walk` and `ask --system` with their
   bodies as `ask`'s reference files; the four maintenance skills become `setup remove | rules
   | audit | memory` with their bodies as `setup`'s; `commit` moves to workflows. Each merged
   description keeps the merged-in `TRIGGER when:` lines; one headless probe per merged trigger
   before the old directory goes. No stub (rule 21).
2. Merge only the four maintenance skills into `setup` (17 → 13).
3. Keep seventeen and shorten every description.

**Case for (1).** The bodies do not change, so nothing a user could do is lost; what goes is
seven listings. `setup` already branches on `$ARGUMENTS` and reads a reference file, so the
shape exists. The probes make "the trigger still fires" a measurement, not a hope.

**Case against (1).** Seven names break for anyone who typed them (5.0.0 and the migration
table are the answer, not a stub). Two words of the always-on `shipkit.md` must follow the
rename. An argument-dispatching skill is a longer description than a single-purpose one, so
the ≤ 2,400 ceiling is tighter than it looks.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this for a given merge — restoring that skill as its own
directory — if its auto-invoke probe fails to fire the merged skill after one rewording of the
description, or if a release run's smoke check that invokes the merged form fails twice. (A
count of skill directories would fire on today's tree by construction — seventeen — so the
clause is manual; once T4 lands, a directory restored under an old name is what REQ-13's smoke
check reports.)
**Fired-if.** manual

---

## Decision: Four agents; the archivist forks inside `map`, the tracer is `grandfather`'s mode   (→ REQ-16, REQ-17, REQ-18, REQ-19)

**Context.** Seven agent descriptions load into every session (1,720 bytes). `tracer` is a
`grandfather` that follows one call chain; `archivist` builds the optional map (decision 0001)
and an agent in `agents/` cannot be opt-in; `codebase-explorer` does what Claude Code's
built-in `Explore` agent does.

**Alternatives.**
1. Four: `tracer` becomes `grandfather`'s trace mode, named in the hand-off; `archivist`'s
   body moves to `skills/map/archivist.md` and `map` runs with `context: fork`;
   `codebase-explorer` is dropped for `Explore` if the check-first shows a plugin skill can
   hand work to it headless. `reviewer`, `eve`, `grandfather`, `test-analyzer` stay.
2. Drop `codebase-explorer` only (7 → 6).
3. Keep seven and shorten the descriptions.

**Case for (1).** The map is optional by record, so its builder should not cost every session.
The elder already reads the map and verifies against source; a trace is that with one
feature's call chain as the question. The `grandfather` group (9 cases) is the watch.

**Case against (1).** Two platform claims must hold (Explore callable from a plugin skill
headless; a forked skill branching on its argument); each has a fallback that keeps the agent
with a one-line description. A merged elder's prompt grows, and `grandfather.md` is 9,156
bytes today in its own context.

**Decision.** We chose (1), each removal behind its check.
**Falsifiability.** We would reverse a removal — restoring that agent — if the `grandfather`
group drops below its 4.12.0 count in a release run after the merge, or if the walkthrough
smoke checks fail on the trace mode twice. (A count of agent files would fire on today's tree
by construction — seven — so the clause is manual; once T5 lands, an agent file restored is
what REQ-17's and REQ-18's smoke checks report.)
**Fired-if.** manual

---

## Decision: The eval ceiling is 204,800 bytes   (→ REQ-20)

**Context.** Lint holds `plugins/shipkit/evals` at 196,608 bytes (check 17) so the plugin stays
small to install; 4.12.0 left 19 bytes of room. W2's probe is about 1.5 KB and W14's (Sprint
22) about as much. The README's history already moved out of `evals/` (4.4.0).

**Alternatives.**
1. 204,800 (200 KiB), raised in the first commit that adds a case. The third raise.
2. Trim `evals/README.md` by 1.5 KB per new case instead.

**Case for (1).** The ceiling exists to keep the install small, and 8 KB is 4% of it; trimming
the README to make room for a case trades the reader's text for the measurement's.

**Case against (1).** A ceiling that rises whenever a case needs it is not a ceiling; the
third raise is the pattern.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this — trimming instead of raising — if a fourth raise is
asked for before 5.0.0 ships.
**Fired-if.** `test "$(find plugins/shipkit/evals -type f -print0 | xargs -0 cat | wc -c)" -gt 204800`

---

## Data / interface changes

- `scripts/context-cost.sh <project-dir>` (new): rows as REQ-1; exit 0.
- `inject-rule.sh <rule>`: skips `spec-driven` and `decisions` when the working directory has
  no `.shipkit/` and `CLAUDE_CODE_EVAL_CONFINED` is unset; `session-start.sh` prints the opt-in
  line in that state.
- `/shipkit:ask [--walk <feature> | --system | ...]`, `/shipkit:setup [remove | rules | audit
  | memory | ...]`, `/shipkit-workflows:commit`; seven directories removed under
  `plugins/shipkit/skills/`.
- `plugins/shipkit/agents/`: `tracer.md`, `archivist.md` removed; `codebase-explorer.md` by
  the check; `skills/map/archivist.md` (new), `skills/map/SKILL.md` with `context: fork`.
- `scripts/lint.py`: `EVALS_MAX_BYTES = 204800`; the skill and agent counts.
- No migration.
