# Design: Second traps and the elder's first step (Sprint 13)

## Approach

A measurement sprint with three small edits. Four tasks produce numbers (path-scoped loading,
sixteen trap-2 cases, the elder's read rate, the wip history) and write them where the next
plan reads them (`docs/design/eval-results-4.6.md`, the ROADMAP, decision 0001). Three
tasks change text, each bounded by a record: one rule line (C10), at most one sentence in one
agent (C9), the housekeeping rows the owner approves (C12). T0 makes the room (C1). Every
run is in the sprint's budget table; one not in it needs the owner's yes (rule 15).

---

## Decision: Room comes from moving history out, not from fewer cases   (→ REQ-1, REQ-2)

**Context.** `plugins/shipkit/evals/` was 130,913 of 131,072 bytes at 4.5.0; sixteen trap-2
cases need about 20 KB. The README held 6.3 KB of baselines nobody reads during a run.

**Alternatives.**
1. Move the five baselines to `docs/design/eval-history.md` with a one-paragraph pointer and
   raise lint check 17 to 163,840 — "for cases", said in the check's comment.
2. Build eight trap-2 cases, not sixteen (C7's other option), and leave the ceiling.
3. Raise the ceiling without moving anything.

**Case for (1).** The room is visible (history out, ceiling up, both in one commit), and the
sixteen is what makes the cut list complete. (3) would hide padding; (2) halves the
measurement to save bytes that were never cases.

**Case against (1).** A higher ceiling invites a committed fixture; the check's comment and
smoke check 42 (which still trips on a 60 KB file) are the guard.

**Decision.** We chose (1), C1's default.
**Falsifiability.** We would lower the ceiling back if a release after 4.6.0 commits a fixture
or a file over 20 KB under `evals/` that is not a case.
**Fired-if.** manual

---

## Decision: Sixteen trap-2 cases, with and without; no rule changes on them   (→ REQ-4, REQ-5, REQ-6, REQ-7)

**Context.** `eval-results-4.2.md` reading 1: sixteen of eighteen rule cases pass equally
without the rule, because each probes the rule's *first* named trap and `sonnet` clears that
unaided. Nothing measures the other lines. The ROADMAP carries the sixteen as "a finding, no
cut".

**Alternatives.**
1. One case per rule on its second named line, run with and without (96 runs, about $10
   once); recorded in `eval-results-4.6.md`; a rule that passes without on both traps is a
   named cut candidate for the next plan; no rule text changes in this sprint (C8).
2. The five core rules and the three shortest stack rules only (eight cases).
3. Bounded trims in this sprint on the numbers, as S9-T5 did for `nontrivial`.

**Case for (1).** A cut needs two measurements, and sixteen rows is a list the next plan can act
on; the standing rule since the trim audit — no rule edited on a sprint's own measurement — is
what keeps a measurement from becoming a justification. (3) would make this sprint's numbers
its own evidence; (2) leaves eight rules at one trap.

**Case against (1).** Sixteen cases cost $16 on every release run from here (C13) and 20 KB of
room; a second trap is still one line of a file with many; and a case that passes without the
rule says the model already does it on this day, not that the line is worthless.

**Decision.** We chose (1), C7 and C8 at their defaults.
**Falsifiability.** We would drop to (2) if the sixteen cases take more than 24 KB or the
release run passes $18; we would allow (3) if a trap-2 case fails even with the rule and the
trace shows the rule's own text caused it (as `gemfile` did in 4.2.0).
**Fired-if.** manual

---

## Decision: The elder's step 1 gets at most two measured attempts   (→ REQ-9, REQ-10, REQ-11)

**Context.** `eval-results-4.1.md`: the map changed neither the answers nor the tool count on a
224-file fixture, and the elder reads the map in fewer than one run in three. Decision 0001
made the map optional and named one experiment — a step-1 sentence that makes the elder read
the map on explanation questions.

**Alternatives.**
1. At most two one-sentence changes to step 1, each judged by the read rate over the five
   `grandfather-xl` cases (15 runs) and by every answer still right; keep the first that reads
   in ≥ 10 of 15; otherwise revert and append the rates to record 0001.
2. Record the rate again on the 4.5.0 text and change nothing.
3. Rewrite step 1 freely until the rate moves.

**Case for (1).** Two bounded attempts answer 0001's open question either way; (2) answers
nothing new; (3) is the thing the trim audit forbade — editing an agent on its own run until
the number looks right.

**Case against (1).** $4 per attempt; a sentence that raises the read rate can lower the answer
rate, and both are judged, so an attempt may be reverted for one wrong answer in fifteen.

**Decision.** We chose (1), C9's default; the keep is the owner's go (rule 6).
**Falsifiability.** We would revert a kept sentence if the next release run's `grandfather-xl`
group drops below 2 of 3 on any case.
**Fired-if.** manual

---

## Decision: The Gemfile line is reworded on the 4.2.0 measurement   (→ REQ-8)

**Context.** The first `stacks/gemfile` run in 4.2.0 scored 0 of 3 *with* the rule: the line
"read the `Gemfile.lock` diff after `bundle install`" left the model unwilling to edit where
there is no network. The prompt was corrected then; the line was not.

**Alternatives.**
1. Reword the line so the lock-diff step is conditional on the install having run; re-run
   `stacks-gemfile` 3×; keep under the stack-rule byte limit.
2. Leave the line; note that evals have no network.
3. Delete the clause.

**Case for (1).** A rule that names a network step can halt work where there is none; the
reword keeps the instruction for the case it was written for. The measurement it rests on is
a previous plan's, which the standing rule allows.

**Case against (1).** One more conditional in a one-line rule; the trap-2 case for `gemfile`
may probe this very line, in which case T3 runs it too.

**Decision.** We chose (1), C10's default.
**Falsifiability.** We would revert to (2) if `stacks-gemfile` or `trap2/gemfile` drops below
2 of 3 with the new text.
**Fired-if.** manual

---

## Decision: The history case runs on a "wip" log; eve's loss stays open   (→ REQ-12, REQ-13)

**Context.** `grandfather-xl/history` is answered from `git log` (commit 20 of 27) as well as
from the map's Evolution section; a real log full of "wip" has no such line, and that is where
a map would earn its place. eve's loss when fewer projects carry a map was never measured.

**Alternatives.**
1. The XL generator gains `--wip` (every message "wip", every byte else the same); `history`
   runs with and without the map on that log (6 runs); eve's item is written as open with the
   reason — a multi-project fixture this plan does not build.
2. Build a three-project registry fixture (about 20 KB of generator) and measure eve too.
3. Nothing; record 0001 stands as it is.

**Case for (1).** Six runs answer the one question the 4.1 results left about the map; (2) is
a sprint of its own and 20 KB the room does not have.

**Case against (1).** One fixture, one history question, six runs: a reading, not a proof. The
generator's determinism is a Check first; if `--wip` changes a tree hash the comparison is
between fixtures and says so.

**Decision.** We chose (1), C11's default.
**Falsifiability.** We would build (2) if a user reports eve answering wrong on a project
without a map, or if the next plan has 20 KB of room to spare.
**Fired-if.** manual

---

## Decision: Housekeeping rows are each their own yes   (→ REQ-14)

**Context.** Five rows (C12 D1 to D5): a trial branch in another repository, a stale cache
directory, scratch directories, merged sprint branches, the owner's cache at each release.
Sprint 10 deleted on a blanket-looking yes once and the plan's rule 13 came from it.

**Alternatives.**
1. Each row is asked separately at T6, its command and output go in the commit message, D4
   waits for the tag.
2. One yes for the list.
3. Nothing is deleted; the rows are recorded as kept.

**Case for (1).** A deletion is the one act the plan's rules single out; five yeses cost five
lines of a conversation.

**Case against (1).** Five questions; D4 cannot be done on this branch (the branches are
merged only once `v4.6.0` exists), so the ROADMAP must say who does it and when.

**Decision.** We chose (1), C12's default.
**Falsifiability.** We would move to (2) if the owner, asked five times, says "all of them"
twice in a row.
**Fired-if.** manual

---

## Data / interface changes

- Changed: `scripts/lint.py` (check 17's ceiling), `scripts/smoke.sh` (check 42's message;
  check 47 extended; the generator check gains `--wip`; new checks 54), `evals/README.md`
  (history out, loading paragraph), `stacks/rails/.claude/rules/gemfile.md` (one line),
  `agents/grandfather.md` (at most one sentence, on the owner's go), `scripts/trace-tools.sh`
  (a read-rate column), `evals/fixtures/ledger-gen/generate.py` (`--wip`), decision 0001
  (an appended note), ROADMAP.
- New: `evals/trap2/` (sixteen cases), `docs/design/eval-results-4.6.md`.
- Unchanged: every other rule, skill and agent; the 4.2.0 cases.
