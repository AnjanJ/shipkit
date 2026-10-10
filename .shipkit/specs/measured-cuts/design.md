# Design: What the numbers allow (Sprint 15)

## Approach

Three records, one per plan decision (E1, E2, E3), and one housekeeping task by the owner's
word. The cuts are the sprint: seven files lose their two measured lines, the fourteen cases
that measured them stay as watches and are run once on the trimmed text before the cut is
kept; four files and `rails` keep theirs by record. One sentence in one skill; one note on one
decision record. No agent, no grader, no fixture, no new script.

---

## Decision: A line followed unaided on both traps comes out; its case stays as the watch   (→ REQ-1, REQ-2, REQ-3, REQ-4)

**Context.** Sixteen rule files passed their first-trap case without their text (4.2.0,
reading 1); twelve of them passed their second-trap case without it too (4.6.0, "The three
readings"). C8 forbade cutting on Sprint 13's own numbers and named the twelve for the plan
after. Every line is a cost: a path-scoped core rule loads into context whenever a matching
file is read, a stack rule into every project that installs the stack. The measurements are
of `sonnet` on two days; a line the model follows unaided today may not be followed by a
later model.

**The eleven candidates at 4.7.0, by line number** (`rails` keeps both lines: its trap-2 was
2 of 3 without, and the two runs that used `update_attribute` skipped validations by a method
the line does not name):

| File | Trap-1 line (4.2.0 case) | Trap-2 line (4.6.0 case) | What remains | Reading |
|------|--------------------------|--------------------------|--------------|---------|
| `rules/migrations.md` | 9–10 backfill in batches | 11–12 `CONCURRENTLY` | the heading | **the whole body — kept** |
| `rules/monorepo.md` | 10–11 consumers' tests | 12–13 `--filter` / `--scope` | the heading | **the whole body — kept** |
| `rules/testing.md` | 12–13 existing factories | 14 one runner | the heading | **the whole body — kept** |
| `rules/ui-ux.md` | 54–55 semantic structure | 56–57 accessible name | the lead paragraph and seven bullets | cut |
| `stacks/hotwire/…/hotwire.md` | 13–16 Frames over Streams | 22–23 no `querySelector` | 34 lines: the Stimulus bullet of "Pick the lightest tool", the rest | cut |
| `stacks/liveview/…/liveview.md` | 11–13 `mount/3` runs twice | 14–15 `handle_params/3` | 35 lines: `push_patch`/`push_navigate`, assigns, events, testing | cut |
| `stacks/elixir/…/mix-deps.md` | 7 `~>` | 9 `only: [:dev, :test]` | the audit bullet | cut |
| `stacks/ml/…/notebooks.md` | 9–11 move it to a module | 12–13 clear outputs | four bullets | cut |
| `stacks/react/…/package-json.md` | 10 frozen lockfile | 11–12 detect the manager | the heading | **the whole body — kept** |
| `stacks/python/…/pyproject.md` | 10 flexible constraints | 12–13 detect the manager | the `pip-audit` bullet | cut |
| `stacks/react/…/react.md` | 5–7 props are the contract | 8–9 routing stays in Rails | the lead line and four bullets | cut |

**Alternatives.**
1. Cut the two measured lines from the seven files whose body is more than those lines; keep
   the four files whose body *is* those lines, and `rails`, whole, as statements of standards;
   every one of the twenty-two cases stays, run on the file as shipped; the clause below brings
   a line back.
2. Cut the measured lines from all eleven, which removes four files outright, and rewrite
   their eight cases to install nothing (`with-rule.sh` would otherwise fail on a missing
   file); update `install-rules.sh`'s count and the README's list of core rules.
3. Keep all twelve as statements of standards, close by one record, change nothing.

**Case for (1).** It is what the evidence supports and no more: a line is removed only where
the file keeps a reason to exist, so a project that installs the stack still gets a rule, and a
path-scoped core rule still fires on its glob. The watch cases turn every cut into a standing
measurement — a release run says the day the model stops following a line, and that day the
line returns by this record's clause, not by argument. The plan's §5 said no file is cut; (2)
would cut four, which is a different decision than the one approved, and it touches the
installer and eight cases to do it.

**Case against (1).** It cuts fourteen lines where the plan said twenty-two, and keeps four
files on the ground that they are short — a file of two followed-unaided lines costs the same
bytes whether or not it is "a whole body". (2) is the consistent reading of "cut what is
followed unaided". (3) spends nothing and learns nothing. A kept-by-record line is a standard
nobody measures again.

**Decision.** We chose (1) — E1's default read against the files as they are; the owner
confirmed "keep" at T0 (2026-10-09).
**Falsifiability.** A cut line returns to its file if its trap-1 or trap-2 case — unchanged,
run on the trimmed file — drops below 2 of 3 in a release run; the restore is the first task
of the next sprint, or the same commit when it happens on this sprint's re-run. A kept file's
lines are cut in a later plan if a third measurement on another model shows the same reading.
**Fired-if.** manual

**Third model (4.11.0, S18-T5, second-run plan E14).** The five kept files' ten cases on
`haiku`, with the rule and without, 3 runs each, 60 runs
(`docs/design/eval-results-4.11.md` §5). `migrations`: 3 of 3 unaided on both traps, as on
`sonnet` — **its two lines are cut by this record's clause, on the owner's go (2026-10-11)**;
its cases `scoped/migrations` and `trap2/migrations` stay as the watch, and the line returns
by the clause above. `monorepo` and `testing`: 2 of 3 unaided on trap 1 (the consumers' tests
skipped; the helper not reused) — kept, now on a number. `rails`: 0 of 3 unaided on trap 2
(`update_column` chosen every time, with a comment) — kept, the rule separating more sharply
than on `sonnet`. `package-json`: trap 2 with the rule 0 of 3 as graded, the line followed in
every trace (a run-time lockfile detector the regex forbids) — kept with the number; the
grader is narrower than the line and is named for the plan after. The reversal condition
above stands for the four files: a third measurement on another model, not this one.

---

## Decision: The elder's step 0 stays; a read that changes no answer is not worth its tokens   (→ REQ-6)

**Context.** Decision 0001 made the map optional (4.1.0) and, at 4.6.0, recorded two attempts
at step 1 that reached 4 and 8 of 15 map reads with every answer right, reverted both, and left
one question: whether step 0 — "try the cheap grep first; escalate to the map if it does not
land" — should itself change, and whether a read that never changes an answer is worth its
tokens (ROADMAP, "The elder reads the map in 8 of 15 runs at best").

**Alternatives.**
1. Close by record, no run: the numbers in hand answer it.
2. One attempt at step 0's triage sentence, 15 runs ≈ $5, the same bar as C9 (≥ 10 of 15 reads
   with every answer right), then the record.
3. Leave the question open for a plan with a different fixture.

**Case for (1).** Forty-five runs across three texts gave forty-five right answers, and the
map read in 1, 4 and 8 of 15 changed none of them. The one question the map decided —
`history` on a "wip" log — is the exception the record names, and there the elder read it 3
of 3 without being told. The 4.0.0 XL baseline's token columns put a map read at roughly 23k
more main-session input tokens on the runs that made one (`drift` 68.1k against 44.8k, `gap`
68.1k against 44.8k and 45.0k — `docs/design/eval-history.md`, "Baseline 4.0.0 (XL)"). A sentence
that raised the read rate would raise that cost on every explanation question for an answer
already right. Step 0 is the triage working.

**Case against (1).** The fixture is one where every grep lands; a repository whose greps do
not land is where step 0 escalates to the map, and that path is unmeasured. (2) would spend $5
to learn the read rate of a sentence on the same fixture, which cannot say more than attempts
1 and 2 did.

**Decision.** We chose (1), E2's default.
**Falsifiability.** We would run (2), or change step 0, if an elder case on a fixture where the
grep does *not* land (the portfolio `why` case of Sprint 16 is the first) gives a wrong answer
that the map, when read, gets right.
**Fired-if.** manual

---

## Decision: The intake's assumption names its file; the four-question ceiling counts parts   (→ REQ-5)

**Context.** `intake/answered`'s grader asks that an assumption drawn from a file cite it;
nothing in `skills/intake/SKILL.md` says so, and the case passed 3 of 3 before any sentence
existed (4.4.0), so C3's search list was never added and the record's clause fired first. The
sentence is a standard the grader already enforces and the skill does not state. Separately,
`intake/limit` fell to 0 of 3 in the 4.7.0 release run and 0 of 1 alone: three numbered
questions whose sub-parts the grader counts as five or more; the skill says "at most four
questions" and nothing about parts.

**Alternatives.**
1. Step 4 gains "each with the file and line that answers it" (E3's default) and one more
   sentence: a question with several parts counts as several, and four is the ceiling on
   parts. The intake group runs once as the watch; no claim that either sentence moved a
   number, and `intake/limit`'s count is recorded whichever way it falls.
2. E3's one sentence only; `intake/limit` stays a known failure until a plan takes it up.
3. Strip the grader's citation clause and leave the skill.

**Case for (1).** Both sentences say what the graders already measure and what the owner
wants from an intake: a checkable assumption and a short list of questions. The limit case's
failure is the skill being read literally — four numbered items — and the fix is to say what
"four" counts. It is one sentence in a skill, not a rule file, and the case is already in the
suite as the watch.

**Case against (1).** The second sentence is a skill change on a measurement from a day's
model behaviour, which rule 10 permits for graders and prompts, not for skills; if
`intake/limit` passes afterwards, the sentence will be credited with a pass that the model's
next day might have given anyway. (2) keeps the sprint to what the plan approved. (3) makes the
case measure less than the owner asked for.

**Decision.** We chose (1); the owner said "both sentences" at T0 (2026-10-09).
**Falsifiability.** The second sentence comes out if `intake/limit` is still below 2 of 3 on
the release run after it is added — then the ceiling, not the wording, is the problem, and a
record for the plan after says so.
**Fired-if.** manual
