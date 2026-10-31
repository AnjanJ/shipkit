# Binding plan — what a decision holds an agent to, and what a number can say

Status: **APPROVED 2026-10-31** by the owner ("approved"), every decision at its default, G10
`~/code/office_bestie` · Written after shipkit 5.0.0 (`6379fd7`, tag `v5.0.0`) from the ROADMAP's
"Still open after Sprint 22", each item read against the code at that commit ·
Three sprints, **one release: 5.1.0** · Follows `docs/plans/thinning-sprint-plan.md`, all three of
whose sprints shipped in 5.0.0.

Shipkit's promise is that it remembers what was intended and checks the result against it. The
run on `linkshort` broke that promise at the first link: T1's agent built the alternative the
design had rejected, because the brief selects a decision by the requirement it cites. Reading
the code for this plan found the second link is open too: the reviewer's "the ship gate weighs
them" is not true, because `skills/ship/SKILL.md` never mentions decisions not followed. A READY
can stand on a contradicted decision. Sprint 23 closes both.

The release run has now exited 1 twice on graders, not rules, so its exit code has stopped saying
anything. Sprint 24 makes the numbers readable. Sprint 25 pays four debts, runs the loop on a
project that has its own `CLAUDE.md` and rules, which no run has done since their fixes shipped,
and releases.

---

## 0. The numbers this plan is about

Measured 2026-10-31 at `6379fd7`.

| What | At 5.0.0 | After this plan |
|---|---|---|
| Decisions reaching T1's brief on `linkshort` | 0 of 3 | 3 of 3 |
| The gate on a live decision the code contradicts | READY is possible (read from the text; S23-T-MERGE forces it) | NOT READY |
| Release run's exit | 1, on two graders | 0, or each failing case named with its trace and the owner's word |
| Graders narrower than their line | 4 (`trap2/rails`, `go-mod`, `experiments`, `package-json`) | 0 |
| `python/django.md` on a FastAPI project | 583 bytes on any `models.py` | not installed |
| Skill templates with a literal date on a stamp line | 6 lines in 5 skills | 0 |
| `reports.md` cases | 0 | 2 |
| Care line measured on | 1 prompt, 1 model | 2 prompts, 2 models |
| E1, E2, E3 exercised on a real project | never, since they shipped in 4.10.0 | 3 |
| Evals directory | 198,837 of 204,800 bytes | at most 204,800 |
| Three always-on rules | 2,999 of 3,000 bytes | unchanged |

---

## 1. How to follow this plan

The thinning plan's twenty-two rules stand, the second-run plan's nineteen among them, with four
new ones:

- **Rule 23 (new). A grader changes only with both sides shown.** The new pattern passes the
  written file it wrongly failed, and fails a seeded violation of the line. Both go through `node`
  (rule 18) before any paid run, and both are in the commit's test plan. A grader that has only
  been shown to pass is a number moved, not a number fixed.
- **Rule 24 (new). A commit's test plan is written after the result is read.** `b99f855` said PASS
  on a FAIL; it was amended before pushing.
- **Rule 25 (new). A claim carried from a handoff, the ROADMAP or a plan is read against its source
  before it goes into a spec, a PR or a report.** Three carried claims were off on 2026-10-31: the
  "Check 45" item named the wrong sprint, the ROADMAP's intake item named the wrong cause (a
  literal date in the template, in six places), and the reviewer's "the ship gate weighs them" is
  false.
- **Rule 26 (new). A cache directory goes only when its `.in_use` names no live process.**
  `.in_use/<pid>` in each version directory lists its holders; `ps` the PID. This replaces reading
  a session's hook line.

### The sprint exit checklist

As the thinning plan's, with three lines changed:

| # | Command | Must show |
|---|---|---|
| 3 | Sprints 23, 24: `bash scripts/evals.sh --group <g> -j 4` for each group the diff touched; Sprint 25: `bash scripts/evals.sh -j 4` | no case that passed before now fails; **Sprint 25 exits 0**, or each failing case is named with its trace and the owner has said go |
| 6 | `find plugins/shipkit/evals -type f -print0 \| xargs -0 cat \| wc -c` | at most 204,800 (G9: no fourth raise) |
| 7 | the §0 table above | every row at its target, or the record says why not |

### The release task

As the thinning plan wrote it, once, at the end of Sprint 25. The CHANGELOG's entry opens with
"What changed for you", and leads with the gate: a contradicted decision is now NOT READY.

---

## 2. Decisions the owner must approve

Each has a recommended default. Approve all, or change any by ID. **G10 needs your word:** the
project for the run.

| ID | Decision | Recommended default | The other option |
|---|---|---|---|
| G1 | Which decisions reach a task's brief | **Every live decision of the feature, by title.** `brief.sh` stops selecting. No new format, it works on every existing spec, and it cannot be got wrong by whoever writes the design. It costs at most 477 bytes on the largest design in this repository (9 decisions). "(Full text: …)" stays. Would have put `Reject bad expires_at in the service` into T1's brief. | Select by file overlap through `tasks.md` (precise, more `awk`), or a `Governs:` line per decision (a new field whose omission fails silently, as now) |
| G2 | What the reviewer reads in a decision | **The alternatives it turned down too.** Step 5 distinguishes *contradicted* (the code does what the record rejected, or the opposite of its choice) from *not yet built*. Today it called `AwareDatetime` "unimplemented, not contradicted". | Leave step 5, rely on G1 alone |
| G3 | What the gate does with a contradicted decision | **The reviewer's verdict is FAIL.** `VERDICT: PASS` needs every requirement `MET` and no live decision contradicted; not-yet-built stays reported only. The way out already exists: change the code, or mark the decision superseded with a new record. The false sentence goes. | Reported only: correct the sentence to say the gate does not weigh them |
| G4 | The four graders narrower than their line | **Correct all four, by rule 23.** `rails`: forbid `update_column` outside a comment. `go-mod`: the same for `vendor`, and accept what compiled. `experiments`: `log(\.\w+)?\(`, as 4.11.0 named. `package-json`: accept a run-time detector. Reverses the thinning plan's §5 for this plan only. | Correct `rails` alone, and keep explaining exit 1 |
| G5 | `map_read` misses a repo-wide Grep | **Count a Grep whose result lists `PROJECT_MAP.md`.** `map_shell` stays beside it. | Leave it, and read `eve/why` by hand each release |
| G6 | `reports.md` has no case | **Two cases: `eve/matrix`, worded as a person would, and `eve/consolidate`.** About $1.20 per release. | One probe per route, not kept |
| G7 | The Care line on one prompt, one model | **Measure only:** a quieter destructive request with and without the plugin, then both prompts on `haiku`. No rule text changes in this plan; a miss goes to the ROADMAP. | Change the line on a miss, with its own re-run |
| G8 | Four debts, paid before the run so it can read them | **All four, each with a smoke check.** `django.md` installs only where the framework is Django, and setup's "(loads on Django files only)" goes. The six stamp lines take `<YYYY-MM-DD>`, from `date +%F`. A stack section loses its `<!-- a / b -->` alternatives at install, and the async line where `ASYNC_MODE` is no. The spec skill says a `Fired-if` reads tracked files (`git grep`). | Pay `django.md` alone |
| G9 | The evals ceiling | **It stays at 204,800.** The two `reviewer` fixtures are 4,245 bytes each and differ by a few lines: one shared script frees about 4 KB, for about 10 KB of room against about 9 KB of new cases. | A fourth raise |
| G10 | The project for the run | **`~/code/office_bestie`, in a worktree at `179f99d`.** It has all three preconditions: a `## Elixir-Specific` heading (E1), `dependencies.md`, `migrations.md`, `testing.md` in `.claude/rules/` (E2), 14 tracked `.shipkit-backup` files (E3). It is where 4.9 found them, so the run reads like with like. Its main checkout has 29 uncommitted files and is not touched. | `~/code/ZeroCourse` (Rails and Hotwire, active, real specs, but already set up and with no `.claude/rules/`, so E1 to E3 stay unexercised) |
| G11 | Version | **5.1.0.** No name changes; a stricter gate is a behaviour change, and the CHANGELOG says so first. | 6.0.0, if a stricter gate is breaking to you |
| G12 | Housekeeping, each its own yes, by rule 26 | The owner's cache to 5.1.0 after the tag; this plan's three sprint branches; `shipkit/4.12.0` and `shipkit-workflows/4.12.0` once nothing holds them. | — |

---

## 3. What we know, and what we must check

Known at `6379fd7`, each read from the source on 2026-10-31:

- `brief.sh`'s `decisions()` keeps a `## Decision:` only if its heading cites one of the task's
  requirements. `linkshort` T1 cited REQ-1 and REQ-2; the three decisions cite REQ-3 to REQ-7. No
  requirement in any spec fixes the selection rule; smoke's `brief` check does, so G1 amends a
  check and no requirement.
- T1 and T2 share `service.py` and `api.py`, and T2 is the decision's task. The binding was
  derivable from `tasks.md`; that is G1's other option.
- A title carries the choice better than the record's `**Decision.**` line, which for this
  decision reads "We chose option 1."
- `reviewer.md:89` says "the ship gate weighs them". `skills/ship/SKILL.md` has no such
  step: step 4 reads the last line, step 6 checks reversal conditions only.
- `review-and-ship/REQ-6` defines the verdict by requirements alone, and both `reviewer` cases cite
  it, so G3 amends a shipped requirement in place, with a note.
- The grader patterns are in `plugins/shipkit/evals/trap2/*/graders/`. `go-mod`'s forbids the word
  `vendor` anywhere, so a comment trips it the way `rails`' does; the ROADMAP names only its
  `go build`.
- `install-stack.sh` copies every `stacks/<stack>/.claude/rules/*.md`, unconditionally.
- `PYTHON_FRAMEWORK` reaches it as `KEY=value`.
- The stamp lines: `intake/SKILL.md:85`, `escape/SKILL.md:59`, `handoff/SKILL.md:34`,
  `product/SKILL.md:72`, `product/reference.md:9`, `ship/reference.md:11`.
- `office_bestie`'s toolchain is pinned in `.tool-versions` (elixir 1.20.2-otp-29); setup does not
  read it, so `mise exec --` goes in by hand, as in 4.9.
- `linkshort`'s `69578a5` and `cc4619c` are unreachable objects: readable now, gone at the next
  `git gc`. S23-T1 copies what it needs first.

To check first, each in the task that needs it:

| Claim | Needed by | If false |
|---|---|---|
| A fixture reproduces the rejected alternative on today's brief: at least 1 of 3 | S23-T1 | The case cannot show the gain. G1 ships on §8.1's one run, at 477 bytes at most, and the record says the number shows nothing |
| A case can run `brief.sh` inside the eval sandbox | S23-T1 | A headless probe as W14 did; nothing kept in the release run |
| The model tells *contradicted* from *not yet built*: 3 of 3 each way | S23-T3 | G3 falls back to its other option; G2 stays |
| A trace's Grep result carries the matched paths | S24-T2 | `map_read` stays as it is; the ROADMAP says so |
| `office_bestie` builds and tests in a fresh worktree (`deps/` and `_build/` are not in it; `mix deps.get` needs network) | S25-T2, first | The owner's word: fix the setup by hand, or fall back to G10's other option |

---

## 4. The three sprints at a glance

| Sprint | Branch | Name | What the owner gets |
|---|---|---|---|
| 23 | `sprint-23/decisions-bind` | What a decision binds | Every live decision in every brief, measured; a reviewer that reads what was rejected; a gate that fails on a contradicted decision |
| 24 | `sprint-24/readable-numbers` | What a number can say | Four graders corrected on both sides; `map_read` that sees a repo-wide Grep; `reports.md` watched; the Care line read on a second prompt and model |
| 25 | `sprint-25/fourth-project` | The owner's project, and 5.1.0 | Four debts paid; the loop on a project with its own rules, E1 to E3 read at last; release 5.1.0 with an exit code that means something |

Budget, by rule 15:

| Sprint | Runs | About |
|---|---|---|
| 23 | Brief case 3 runs × 2 arms ≈ $0.80; four `reviewer` cases × 3 ≈ $2; the forced gate twice ≈ $0.60; `--group` at merge ≈ $2 | $5–6 |
| 24 | `--group trap2` once ≈ $5; two `reports` cases × 3 ≈ $1.20; Care 2 prompts × 3 × 2 arms, then `haiku` ≈ $1; `--group eve`, `--group rules` ≈ $3 | $10 |
| 25 | The run ≈ $2–8 (a larger project than `linkshort`'s $1.29); three gates ≈ $1.50; the release run at about 65 cases ≈ $21–23 | $25–33 |
| Total | | $40–49, one release |

---

## Sprint 23 — What a decision binds (untagged)

**Goal:** an agent is told about every decision of its feature, and a gate will not say READY on
one the code contradicts.

### S23-T0 — Write the sprint spec
- **Files:** `.shipkit/specs/decisions-bind/`, this plan's status line.
- **Done when:** spec-check 0 gaps on the draft; lint 0/0; the owner's approval of the spec in the
  thread; the approval line at the top of this file, same commit.

### S23-T1 — The case first (G1)
- **Files:** `plugins/shipkit/evals/brief/binds/` (new), `docs/design/eval-results-5.1.md` (new).
- **Steps:** a small Python service and a spec folder in `linkshort`'s shape: three decisions, the
  third "Reject bad `expires_at` in the service" with `AwareDatetime` among its alternatives and
  citing REQ-3 and REQ-4; T1 on REQ-1 and REQ-2 sharing two files with T2. The prompt runs
  `brief.sh` for T1 and does what it says. The grader: the field exists and `AwareDatetime` does
  not. Three runs on today's `brief.sh`. **STOP: the owner sees the number.**
- **Done when:** the table has no empty cell; the owner's go in the thread; lint 0/0.

### S23-T2 — Every live decision reaches every task (G1)
- **Files:** `plugins/shipkit/scripts/brief.sh`, `scripts/smoke.sh`, `docs/design/eval-results-5.1.md`.
- **Steps:** `decisions()` prints every live title; the header comment and the "None recorded"
  line follow. Smoke's `brief` check, written first, red: a decision citing another task's
  requirement is listed, a superseded one is still left out. Three runs of the case again.
- **Done when:** the check PASS; both rows in the table; lint 0/0.

### S23-T3 — A contradicted decision fails the gate (G2, G3, G9)
- **Files:** `plugins/shipkit/agents/reviewer.md`, `plugins/shipkit/evals/lib/` (the shared script),
  `plugins/shipkit/evals/reviewer/`, `scripts/smoke.sh`.
- **Steps:** one commit moves the two fixtures onto the shared script, and `--group reviewer`
  still reads 3 of 3 each. Then, written first, red: `reviewer/rejected-alternative` (every
  requirement met, the code uses what the record rejected: FAIL, naming the decision) and
  `reviewer/decision-unbuilt` (a live decision a later task will build: not FAIL). Then the two
  sentences. Smoke check 77 holds them, and that "the ship gate weighs them" is gone.
- **Done when:** four `reviewer` cases, each 3 of 3; check 77 PASS; line 6 at most 204,800; lint
  0/0.

### S23-T-MERGE — Merge, untagged
- The exit checklist with `--group brief`, `--group reviewer`. `/shipkit:ship` forced twice on a
  fixture: contradicted → NOT READY; the decision marked superseded with a new record → READY.
  Both reports read and kept. No tag; the owner's cache untouched.

---

## Sprint 24 — What a number can say (untagged)

**Goal:** a release run whose exit code can be believed.

### S24-T0 — Write the sprint spec
- As S23-T0, `.shipkit/specs/readable-numbers/`.

### S24-T1 — Four graders, both sides (G4, rule 23)
- **Files:** the four `graders/*.md`, `docs/design/eval-history.md`.
- **Steps:** one grader per commit. For each: the written file it wrongly failed, taken from the
  session logs under `~/.claude/projects/`; a seeded violation (`order.update_column(:x, 1)`, `go
  mod vendor`, a silent fallback with no device logged, an unconditional `npm install`); both
  through `node` first. A trailing comment after a real call must still fail. Then `--group trap2`.
- **Done when:** both sides in each commit's test plan; `--group trap2` read from the traces; lint
  0/0.

### S24-T2 — `map_read` sees a repo-wide Grep (G5)
- **Files:** `scripts/trace-tools.sh`, `scripts/smoke.sh`.
- **Steps:** smoke check 78, written first, red, on a stored two-line trace: a Grep over the repo
  whose result lists `PROJECT_MAP.md` counts, one that does not list it does not.
- **Done when:** check 78 PASS; the Check first's result recorded; lint 0/0.

### S24-T3 — `reports.md` watched (G6)
- **Files:** `plugins/shipkit/evals/eve/matrix/`, `plugins/shipkit/evals/eve/consolidate/`.
- **Steps:** both on the portfolio fixture, three runs each; `matrix` asked for in words, which
  has never been run; graders from the shapes in `skills/ask/reports.md`.
- **Done when:** both read, a miss recorded by trace; line 6 at most 204,800; lint 0/0.

### S24-T4 — The Care line, read twice more (G7)
- **Files:** `plugins/shipkit/evals/rules/care-quiet/`, `docs/design/eval-results-5.1.md`.
- **Steps:** `rules/care-quiet`, a request destructive only in what it implies, with and without
  the plugin; then it and `rules/care` on `haiku`. **No rule text changes.**
- **Done when:** the table has no empty cell; a miss is a ROADMAP item; lint 0/0.

### S24-T-MERGE — Merge, untagged
- The exit checklist with `--group trap2`, `--group eve`, `--group rules`.

---

## Sprint 25 — The owner's project, and 5.1.0

**Goal:** the fixes read on a real project, and one release.

### S25-T0 — Write the sprint spec
- As S23-T0, `.shipkit/specs/fourth-project/`.

### S25-T1 — Four debts, each with a check (G8)
- **Files:** `plugins/shipkit/scripts/install-stack.sh`, `plugins/shipkit/skills/setup/SKILL.md`,
  the six stamp lines' files, `plugins/shipkit/skills/spec/SKILL.md`, `scripts/smoke.sh`.
- **Steps:** smoke checks 79 to 82, each written first, red: `django.md` on `PYTHON_FRAMEWORK=Django`
  and not on `FastAPI`; no literal date on a stamp line in any skill; a filled section with no
  `<!--` alternative and a sync project with no async line, `.section-<stack>.sha` taken after
  both; the spec skill's `Fired-if` sentence.
- **Done when:** checks 79 to 82 PASS; lint 0/0.

### S25-T2 — The run (G10)
- **Files:** `docs/design/field-notes-5.1.md` (new), `ROADMAP.md`.
- **Steps:** the Check first. A worktree of `~/code/office_bestie` at `179f99d` under the
  scratchpad, on throwaway `shipkit/real-run-5`, never pushed. `--plugin-dir`, `sonnet`, headless,
  the nine steps of `field-notes-5.0.md`, a real item the owner names from the project's backlog.
  Setup says yes to `--with-skills`, so a real run sees the stack-skill lines at last. One
  `/shipkit:ask --walk <feature>`, unasked in any run so far. `mise exec --` by hand, noted. No file
  under `plugins/` edited while a step runs. Nothing found is fixed.
- **Done when:** every step has its six parts; G1, G2, G3, E1, E2, E3 each read as held or not
  shown; the worktree and branch removed on the owner's yes, the log read first; lint 0/0.

### S25-T3 — The roadmap for the plan after
- **Files:** `ROADMAP.md`.
- **Done when:** the plan's section has its three rows and 5.1.0; "Still open after Sprint 25" holds
  the run's findings and what §5 below left; every item cites a file and a section; lint 0/0.

### S25-T-REL — Release 5.1.0 (G11, G12)
- **Files:** the five version lines, `CHANGELOG.md`, `README.md`, `ROADMAP.md`,
  `docs/design/eval-history.md`, `.shipkit/releases/`.
- **Steps:** the exit checklist in full; `/shipkit:ship` on the three specs, one at a time; the
  reviewer's `placeholder` counted again from the session logs against 3 of 74; the pull request,
  the green check, a merge commit; tag `v5.1.0`, annotated. Each of G12 its own yes.
- **Done when:** all three READY; the run in `eval-history.md`; the tag on the remote.

---

## 5. What this plan does not do

- It does not look for why the model writes `placeholder`. REQ-15's retry stands, the release
  counts it, and that decision's reversal condition stands.
- It adds no always-on byte: the three rules and every skill and agent description stay as they
  are, Care included (G7 measures only).
- It does not fix `Test:` being singular, the hand-written stamp, setup's two clocks or `sleep 45`.
  Each has been seen on real runs and none has cost a result: the agent reports the extra test
  under DEVIATIONS, and the stamp's flow is headless, not a person's.
- It does not fix the pinned toolchain. The run will meet it, as 4.9 did; that is one more reading
  for the plan after.
- It does not touch the `agents` or `rules-skip` smoke flakes: both pass alone, so no fix could be
  shown.
- It leaves the strict `why` number, the map with no shared word, the four rule files kept on a
  number, the smoke header range, the `-rerun` report and the product skill's contradiction open.
- It does not re-measure the `eve` trim.
- It does not fix what the run finds (the second-run plan's E17).

## 6. Risks, and what we do about each

| Risk | What we do |
|---|---|
| The reviewer over-reads and fails a sound feature on a decision it misunderstands | `reviewer/decision-unbuilt` and `all-met` must hold 3 of 3; otherwise G3 falls back to its other option |
| A longer list of decisions pulls an agent into a later task's work | **It did: 9 of 10 runs at S23-T2.** `brief-verify.sh` did not bound it, as this row first said: T1 and T2 share files. REQ-14's sentence and a second grader answer it, on the owner's word; the run in S25-T2 reads for it |
| A grader corrected to pass hides a real failure | Rule 23: nothing runs until the seeded violation fails |
| One more clause in the reviewer raises the `placeholder` rate, already 3 of the last 10 | The retry stands; the release counts it; a gate with two replies and no verdict fires that decision's record |
| The ceiling: about 1 KB of margin rests on an estimate | Measured at S23-T3. If it does not fit, `eve/consolidate` is the first case dropped, by the owner's word; no raise |
| A project set up on 5.0.0 keeps `django.md` | Nothing deletes it. The CHANGELOG names the file; its cost is 583 bytes on a matching read |
| `office_bestie` will not build in a worktree | The Check first, before any paid step |
| The run writes into the owner's product repository | A worktree under the scratchpad, never pushed, its removal the owner's yes |
| The fixture's text is lost to a `git gc` in `linkshort` | S23-T1 copies it first; §3 records the shape either way |

## 7. Approval

The owner approves this plan by writing "approved", with any decision ID changed from its default,
and confirms G10's project. The approval line goes at the top of this file in the same commit as
S23-T0's spec. Nothing in this plan starts before that.
