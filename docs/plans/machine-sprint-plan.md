# Machine plan — what the user's machine does to the loop, and what the gate says about setup

Status: **APPROVED 2026-11-05** by the owner ("approved"), every decision at its default, G10
`~/code/office_bestie`; G2 amended at S26-T0 on the owner's word · Written after shipkit 5.1.0 (tag `v5.1.0`) and PR #30
(`03e87eb`, untagged) from the ROADMAP's "Still open after Sprint 25", each item read against the
code at `03e87eb` · Three sprints, **one release: 5.2.0** · Follows
`docs/plans/binding-sprint-plan.md`, all three of whose sprints shipped in 5.1.0.

The fourth real run did its work: every step produced its file and no check the runner re-ran
disagreed. What went wrong came from the machine it ran on, not the loop. The project's toolchain
is pinned, so the Done-when's test command does not run in a headless shell. The owner's `grep` is
ripgrep, so the release gate's reviewer called a line missing that is there. A headless intake
waited four minutes on a `Monitor` the model set for an agent that was already done. And the
`Write` tool cannot expand the `${TMPDIR:-/tmp}` the ship skill gives it. A user's machine is
never shipkit's test fixture, and Sprint 27 makes the loop survive one.

Sprint 26 pays what the gate says wrongly about setup. Reading the code for this plan found that
"a first spec still lists setup's `.gitignore` and `CLAUDE.md`" is not the half-done 4.9 item the
ROADMAP calls it. It is `run-debts`' fifth decision, chosen on purpose, and its reversal condition
("two consecutive real runs report `CLAUDE.md` and `.gitignore` … with no change in them but
setup's") has been met three times, at 4.12, 5.0 and 5.1. Nothing fired, because its `Fired-if` is
`manual`. Sprint 28 runs the loop on a real project again and releases.

---

## 0. The numbers this plan is about

Measured 2026-11-05 at `03e87eb`.

| What | At 5.1.0 + PR #30 | After this plan |
|---|---|---|
| Setup's files a first spec reports as beyond the spec, with only setup's lines in them | 2 (`CLAUDE.md`, `.gitignore`), three runs running | 0; an edit outside setup's lines still reported |
| A decision record whose reversal condition is met and not marked | 1 (`run-debts`, "Setup's two directories join the always-allowed list") | 0 |
| The reviewer's marks for a decision | 2 (`contradicted`, `not built`) | 3, with `partly built`; the verdict rule unchanged |
| Literal `<app>` in a `CLAUDE.md` setup writes | 4 lines (`stacks/elixir/CLAUDE.md.append:12-15`) | 0 |
| A `Write` told to write to `${TMPDIR:-/tmp}/…` | 1 (`ship/SKILL.md:68`) | 0 |
| A test command setup writes that runs in a headless shell on a pinned toolchain | not on `office_bestie` (`mise`, `.tool-versions`) | yes |
| Gate searches that depend on what `grep` is in the user's shell | the reviewer's (`fourth-project` gate, REQ-16 misread) | 0: `git grep` |
| Idle seconds after the work in a headless intake on the run's fixture | 253 (one run, `field-notes-5.1.md` §4) | measured on five runs, then read against the bar in G7 |
| `walk.md:3` | "The agent It cannot ask" | the sentence whole |
| Evals directory | 202,547 of 204,800 bytes | at most 204,800 |
| Three always-on rules | 2,999 of 3,000 bytes | unchanged |
| Smoke checks | 1 to 83 | 1 to about 92 |

---

## 1. How to follow this plan

The thinning plan's twenty-two rules stand, the binding plan's four with them (23 to 26), and one
is new:

- **Rule 27 (new). A release spec holds no requirement its own gate cannot meet.** Its own READY,
  the tag, the merge and anything after the gate belong in the plan's release task, not in a
  `REQ-N`. `fourth-project`'s REQ-18, REQ-21 and REQ-22 made its first gate read NOT READY on
  requirements that could not be met at that point (`docs/design/eval-history.md`, "Release run
  5.1.0").

Rule 22 holds as the binding plan kept it: an untagged merge runs the full smoke suite as well.

### The sprint exit checklist

As the binding plan's, with line 3 changed:

| # | Command | Must show |
|---|---|---|
| 3 | Sprints 26, 27: `bash scripts/evals.sh --group <g> -j 4` for each group the diff touched; Sprint 28: `bash scripts/evals.sh -j 4` | no case that passed before now fails; Sprint 28 exits 0, or each failing case is named with its trace and the owner has said go |
| 6 | `find plugins/shipkit/evals -type f -print0 \| xargs -0 cat \| wc -c` | at most 204,800 |
| 7 | the §0 table above | every row at its target, or the record says why not |

### The release task

As the thinning plan wrote it, once, at the end of Sprint 28. The CHANGELOG's `[Unreleased] — after
5.1.0` entry becomes 5.2.0's and leads with "What changed for you": setup's own lines no longer
count against a first spec, and the test command setup writes runs on a pinned toolchain.

---

## 2. Decisions the owner must approve

Each has a recommended default. Approve all, or change any by ID. **G10 needs your word:** the
project for the run.

| ID | Decision | Recommended default | The other option |
|---|---|---|---|
| G1 | The four small debts | **All four, each with a smoke check, written first.** `walk.md:3` whole. `ship/SKILL.md:68`: the gate prints `"${TMPDIR:-/tmp}/shipkit-ship-review.out"` with `printf` first and gives `Write` the path it printed. `elixir/CLAUDE.md.append:12-15`: a new placeholder, `APP_NAME`, the `app:` atom of `mix.exs`, so a missing value fails the install, as every placeholder does. A `Status:` line in `design.md` or `tasks.md` is a `spec-check` gap: only `spec.md` carries one (`spec/SKILL.md:56`). | Fix the three text debts and leave the `Status:` line to the reader |
| G2 | Setup's `CLAUDE.md` and `.gitignore` in a first spec | **Supersede `run-debts`' fifth record with its own alternative (2), narrowed:** ~~a new `setup-lines.sh <base>` names `CLAUDE.md` as setup's when every changed line is inside shipkit's section markers, and `.gitignore` when every added line is one setup writes.~~ *Amended at S26-T0, the owner's word:* setup ends by recording each file's git blob id in `.claude/rules/shipkit/.setup-files` (`setup-files.sh . record`), and a file whose blob id still matches is setup's; markers alone miss a `CLAUDE.md` setup created, as on `linkshort` (`.shipkit/specs/gate-on-setup/design.md`, fourth record). `brief-verify.sh` and the reviewer's step 4 read it; anything else in either file is still reported. The old record is marked superseded, not deleted, citing the three runs. | Mark the condition met, keep the behaviour, and lower the record's bar to a later run |
| G3 | Half built | **A third mark, `partly built`: the part that exists and the part that does not, each with `path:line`.** Reported, like `not built`; `VERDICT` is unchanged (`contradicted` still fails). Text and a smoke check; no new eval case, since the verdict cannot move. | Leave the two marks; the reviewer's words already say it |
| G4 | The test command on a pinned toolchain | **Setup prefixes the detected command with `mise exec --` when the project has `.tool-versions`, `mise.toml` or `.mise.toml` and `mise` is on the `PATH`,** and says so in the reply. `TEST_COMMAND` carries it into `CLAUDE.md`, so the Done-when, `brief.sh` and the gate get it unchanged. A smoke check holds the sentence. | Detect it and only print a hint |
| G5 | The gate's searches and the user's aliases | **The reviewer and the ship skill search with `git grep -n` (`-E` for alternation, never `\|`).** `git grep` is git's, never an alias, and reads only tracked files, which is the reviewer's subject. One sentence in each and a smoke check. Nothing else of the owner's shell is touched. | Tell the gate to write `command grep` |
| G6 | `CLAUDE.md`'s second `## Elixir-Specific` | **Leave it, by record.** `run-debts`' first record reverses only if a project ends with both sections "after the user read the line"; the 5.1 run was headless and no user read it, so the condition is untested, not met. The run in G10 is interactive for setup's reply only, so the line is read at last. | Skip the section when the heading exists (that record's (2)) |
| G7 | The headless wait | **Measure first.** Five headless intakes on a fixture whose `grandfather` call takes under a minute; count the seconds between the file's last write and the session's end. **Only if 2 or more of 5 idle over 60 s:** one sentence in `intake` and `ask`, "wait for the agent's own notification; arm no `Monitor` and no `sleep`", and five runs again. Otherwise a ROADMAP line says it is the platform's. | Add the sentence now, unmeasured |
| G8 | The evals ship inside every install | **Keep them there, by record.** `claude plugin eval --eval-dir` takes "a directory name below the plugin" (Claude Code 2.1.318's help text, read 2026-11-05), so moving them breaks `scripts/evals.sh`. They cost 1,184 of the plugin's 1,716 KB on disk and no byte of context: no skill, agent, hook or rule reads them. S27-T0 reads the current plugin docs for a way to leave a path out of an install; if one exists, the record says so and the move becomes its own item. | Move them out now, and run the evals from a copy |
| G9 | The evals ceiling | **It stays at 204,800.** G7's fixture is a scaffold script, not stored files; G3 and G5 add no case. | A raise |
| G10 | The project for the run | **`~/code/office_bestie` again, in a fresh worktree at its `main`,** never pushed, with its own test database. It is the project with all four lines this plan changes: `mise` (G4), an Elixir app name (G1), its own `## Elixir-Specific` (G6) and a first spec after setup (G2). | `~/code/ZeroCourse` (Rails; G1's `APP_NAME` and G6 go unread) |
| G11 | The two questions PR #30 left | **Answer both in the run.** The gate twice, on two days, the first report left untracked: does REQ-20's sentence name it? And an install with `--scope project` in a scratch directory, updated from outside it and from inside it: which works? Neither costs a model call beyond the gates. | Leave both open |
| G12 | Version | **5.2.0.** No name changes; one new mark, one new script, one new gap kind. | 5.1.1 |
| G13 | Housekeeping, each its own yes, by rule 26 | The three sprint branches after the merge; the owner's cache to 5.2.0 after the tag; `5.1.0` once its `.in_use` names no live process. | — |

---

## 3. What we know, and what we must check

Known at `03e87eb`, each read from the source on 2026-11-05:

- `agents/reviewer.md:51-52`: "`CLAUDE.md` and `.gitignore` are listed even when setup changed them
  — they hold the project's own content." It is `run-debts/REQ-7` and that spec's fifth decision
  (`design.md:139`). Its Falsifiability: "We would add (2) if two consecutive real runs report
  `CLAUDE.md` and `.gitignore` as beyond the spec with no change in them but setup's." Reported at
  4.12 (`field-notes-4.12.md:379`), 5.0 (`field-notes-5.0.md:203`) and 5.1 (§9.1). G2 amends
  `run-debts/REQ-6` and `REQ-7` in place, with a note.
- `reviewer.md:57-59` defines the two marks; `:94-95` the verdict rule G3 leaves alone.
- `ship/SKILL.md:68` gives `Write` `"${TMPDIR:-/tmp}/shipkit-ship-review.out"`. Lines 31, 44, 50
  and 103 give the same form to Bash, which expands it; they stay.
- `stacks/elixir/CLAUDE.md.append:12-15` hold `lib/<app>/`, `lib/<app>_web/`,
  `lib/<app>_web/live/`, `lib/<app>/application.ex`. The `new-feature` skill's `<app>` lines are a
  pattern for any feature and stay.
- `spec/SKILL.md:56` asks for `> Status: draft` in `spec.md`; the template for `design.md` has none
  (`spec/reference.md`). `spec-check.sh` is the only script that reads a `Status:` line.
- `brief.sh` prints every live decision's title and "(Full text: …)" (`:105`, `:171`). On
  `brief/binds` 20 of 20 runs opened the design (`eval-results-5.1.md`); the real run's agent did
  not (§8.2). That is §5's, not this plan's.
- Nothing under `plugins/shipkit/` names `mise` or `.tool-versions` except `setup/remove.md`.
- No skill names `Monitor` or a background wait.
- `scripts/evals.sh:43` runs `claude plugin eval "$ROOT/plugins/shipkit"`; `lint.py` check 17 holds
  the ceiling.

To check first, each in the task that needs it:

| Claim | Needed by | If false |
|---|---|---|
| ~~Setup's `CLAUDE.md` lines can be told from the project's by its markers alone, on the 5.1 run's diff shape~~ Read at S26-T0: false on `linkshort`, where setup created `CLAUDE.md`; G2 amended | S26-T2 | — |
| `mise exec -- <cmd>` runs the test command in a headless `claude -p` Bash call on `office_bestie` | S27-T1 | G4 prints a hint only |
| A fixture reproduces the idle wait at least once in five | S27-T3 | No sentence; the ROADMAP line names the platform and the run that showed it |
| The plugin docs name no way to leave a path out of an install | S27-T0 | G8's move becomes a task of S27, on the owner's word |
| `office_bestie` builds and tests in a fresh worktree at today's `main` | S28-T2, first | The owner's word: fix the setup by hand, or G10's other option |

---

## 4. The three sprints at a glance

| Sprint | Branch | Name | What the owner gets |
|---|---|---|---|
| 26 | `sprint-26/gate-on-setup` | What the gate says about setup | Setup's lines no longer count against a first spec; a mark for half built; four small debts paid |
| 27 | `sprint-27/users-machine` | The user's machine | A test command that runs on a pinned toolchain; gate searches no alias can bend; the headless wait measured; the evals' home recorded |
| 28 | `sprint-28/fifth-run` | The owner's project again, and 5.2.0 | The four lines read on a real project; PR #30's two questions answered; release 5.2.0 |

Budget, by rule 15:

| Sprint | Runs | About |
|---|---|---|
| 26 | `--group reviewer` at merge (four cases × 3) ≈ $2 | $2 |
| 27 | Five intakes ≈ $2.50, five more only if the sentence goes in ≈ $2.50; `--group reviewer` at merge ≈ $2 | $4.50–7 |
| 28 | The run ≈ $2–8; two gates on two days and three release gates ≈ $2.50; the release run, about 5.1.0's 65 cases at $21.10 | $26–32 |
| Total | | $32–41, one release |

---

## Sprint 26 — What the gate says about setup (untagged)

**Goal:** a first spec after setup is reviewed on its own work, and the reviewer has a word for
what it sees.

### S26-T0 — Write the sprint spec
- **Files:** `.shipkit/specs/gate-on-setup/`, this plan's status line.
- **Done when:** spec-check 0 gaps on the draft; lint 0/0; the owner's approval of the spec in the
  thread; the approval line at the top of this file, same commit.

### S26-T1 — Four small debts (G1)
- **Files:** `plugins/shipkit/skills/ask/walk.md`, `plugins/shipkit/skills/ship/SKILL.md`,
  `plugins/shipkit/stacks/elixir/CLAUDE.md.append`, `plugins/shipkit/skills/setup/SKILL.md` (the
  placeholder table), `plugins/shipkit/scripts/spec-check.sh`, `scripts/smoke.sh`.
- **Steps:** smoke checks 84 to 87, each written first, red: no "It cannot" after "The agent" in
  `walk.md`; no `Write` sentence beside `${TMPDIR`; an elixir install without `APP_NAME` exits 2
  and one with it leaves no `<app>`; a `Status:` line in a fixture's `design.md` is a gap. One
  debt per commit.
- **Done when:** checks 84 to 87 PASS; spec-check 0 gaps on every spec in this repository; lint 0/0.

### S26-T2 — Setup's own lines are not the spec's (G2)
- **Files:** *(amended at S26-T0)* as `.shipkit/specs/gate-on-setup/tasks.md` T2 lists them:
  `plugins/shipkit/scripts/setup-files.sh` (new), `brief-verify.sh`, `unsetup-remove.sh`,
  `agents/reviewer.md`, `skills/setup/SKILL.md`, `scripts/smoke.sh`, `.shipkit/specs/run-debts/`,
  `CHANGELOG.md`.
- **Steps:** smoke check 88, written first, red, on a fixture with a new `CLAUDE.md` and a
  five-line `.gitignore`: recorded and unchanged, no `OUTSIDE` for either; one more line in each,
  `OUTSIDE` for each; no record, both `OUTSIDE`. Then the script, then the callers, then the
  superseding record.
- **Done when:** check 88 PASS, both sides; the old record marked `Superseded`, so `brief.sh` leaves it out; lint
  0/0.

### S26-T3 — `partly built` (G3)
- **Files:** `plugins/shipkit/agents/reviewer.md`, `scripts/smoke.sh`.
- **Steps:** smoke check 89, written first, red: the three marks, and the verdict line unchanged.
- **Done when:** check 89 PASS; lint 0/0.

### S26-T-MERGE — Merge, untagged
- The exit checklist with `--group reviewer`; the full smoke suite (rule 22). No tag; the owner's
  cache untouched.

---

## Sprint 27 — The user's machine (untagged)

**Goal:** what setup writes runs on the user's machine, and the gate reads the same whatever their
shell says.

### S27-T0 — Write the sprint spec
- As S26-T0, `.shipkit/specs/users-machine/`. The plugin docs read for G8's Check first.

### S27-T1 — A test command for a pinned toolchain (G4)
- **Files:** `plugins/shipkit/skills/setup/SKILL.md`, `scripts/smoke.sh`.
- **Steps:** the Check first, by hand, on `office_bestie` in a scratch worktree. Smoke check 90,
  written first, red: Phase 1 step 4 names the three files and `mise exec --`.
- **Done when:** check 90 PASS; the Check first's command and output in the commit's test plan;
  lint 0/0.

### S27-T2 — Searches no alias can bend (G5)
- **Files:** `plugins/shipkit/agents/reviewer.md`, `plugins/shipkit/skills/ship/SKILL.md`,
  `scripts/smoke.sh`.
- **Steps:** smoke check 91, written first, red: both files name `git grep`, and neither holds a
  `\|` in a command.
- **Done when:** check 91 PASS; lint 0/0.

### S27-T3 — The headless wait, measured (G7)
- **Files:** `scripts/wait-probe.sh` (new, the fixture's scaffold and the five runs),
  `docs/design/eval-results-5.2.md` (new); on G7's bar only, `plugins/shipkit/skills/intake/SKILL.md`
  and `plugins/shipkit/skills/ask/SKILL.md`.
- **Steps:** five headless intakes, the idle seconds read from each transcript's timestamps. **STOP:
  the owner sees the number** before any sentence goes in.
- **Done when:** the table has no empty cell; the owner's go in the thread; lint 0/0.

### S27-T4 — The evals' home, recorded (G8)
- **Files:** `.shipkit/decisions/0005-evals-home.md` (new), `ROADMAP.md`.
- **Done when:** the record has its five parts and a reversal condition that is an event; lint 0/0.

### S27-T-MERGE — Merge, untagged
- The exit checklist with `--group reviewer`; the full smoke suite (rule 22).

---

## Sprint 28 — The owner's project again, and 5.2.0

**Goal:** the plan's lines read on a real project, and one release.

### S28-T0 — Write the sprint spec
- As S26-T0, `.shipkit/specs/fifth-run/`. By rule 27, no requirement names its own gate's READY or
  anything after it.

### S28-T1 — `--scope project` (G11)
- **Files:** `README.md`, `docs/GUIDE.md` ("Updating"), only if the answer differs from what they say.
- **Steps:** in a scratch directory, install both plugins with `--scope project`, then
  `claude plugin update … --scope project` from outside it and from inside it. The scratch directory
  removed on the owner's yes.
- **Done when:** both outcomes in the commit's test plan, or in the sprint's notes if no file changed.

### S28-T2 — The run (G10, G11)
- **Files:** `docs/design/field-notes-5.2.md` (new), `ROADMAP.md`.
- **Steps:** the Check first. A worktree of `~/code/office_bestie` at its `main` under
  `/private/tmp/shipkit-real-run-6`, on throwaway `shipkit/real-run-6`, never pushed; its own test
  database by `MIX_TEST_PARTITION=_shipkit6`. The nine steps of `field-notes-5.1.md`, `--plugin-dir`,
  `sonnet`, headless, **except setup, which the owner reads** (G6). This time no `mise exec --` is
  given by hand: G4 has to supply it. The gate on day one, its report left untracked; the gate again
  on a later day (G11). Each step's log goes into the notes as it ends. Nothing found is fixed.
- **Done when:** every step has its six parts; G1 to G7 each read as held or not shown; REQ-20's
  sentence read; the worktree, the branch and the database removed on the owner's yes; lint 0/0.

### S28-T3 — The roadmap for the plan after
- **Files:** `ROADMAP.md`.
- **Done when:** the plan's section has its three rows and 5.2.0; "Still open after Sprint 28" holds
  the run's findings and what §5 below left; every item cites a file and a section; lint 0/0.

### S28-T-REL — Release 5.2.0 (G12, G13)
- **Files:** the five version lines, `CHANGELOG.md`, `README.md`, `ROADMAP.md`,
  `docs/design/eval-history.md`, `.shipkit/releases/`.
- **Steps:** the exit checklist in full; `/shipkit:ship` on the three specs, one at a time; the pull
  request, the green check, a merge commit; tag `v5.2.0`, annotated. Each of G13 its own yes.
- **Done when:** all three READY; the run in `eval-history.md`; the tag on the remote.

---

## 5. What this plan does not do

- It does not put a decision's record in the brief. `brief/binds` read 20 of 20 opening the design;
  the real run's agent read titles only and nothing turned on it (`field-notes-5.1.md` §8.2). It
  waits for a run where it does.
- It does not merge two `## Elixir-Specific` sections (G6).
- It does not move the evals (G8), unless the docs show a way.
- It adds no always-on byte: the three rules and every skill and agent description stay as they
  are.
- It leaves the binding plan's §5 list where it was: why the model writes `placeholder`; the
  singular `Test:` line, the hand-written stamp and setup's two clocks; the `agents` and
  `rules-skip` smoke flakes; the strict `why` number, the map with no shared word, the four rule
  files kept on a number, the smoke header range, the `-rerun` report and the product skill's
  contradiction; the `eve` trim; the `walkthrough` trigger, a rare wakeup and the stack-skill lines.
- It does not fix what the run finds.

## 6. Risks, and what we do about each

| Risk | What we do |
|---|---|
| An agent's edit to setup's `CLAUDE.md` passes as setup's | Any change moves the blob id, so the file is reported; check 88's second side holds it. A setup that skips `record` leaves today's behaviour, never a silent pass |
| `git grep` misses an untracked file the reviewer should see | The reviewer's subject is `git diff <base>...HEAD`, tracked by definition; an untracked file is the clean-tree step's, not the reviewer's |
| `mise exec --` on a machine where `mise` is installed but not used by the project | G4 needs both a `mise` file in the project and `mise` on the `PATH` |
| The wait does not reproduce on a fixture | The Check first; the ROADMAP line names the platform, and the real run reads it again |
| A sentence about waiting changes nothing the model does | Five runs again, by G7's bar; no sentence stays on a number that did not move |
| The run writes into the owner's product repository | A worktree under `/private/tmp`, never pushed, removed on the owner's yes; each step's log saved as it ends, since a reboot cleared the last run's |
| The run's tests migrate the owner's test database | `MIX_TEST_PARTITION=_shipkit6` for every step; the database goes on the owner's yes |
| A release spec asks for its own READY again | Rule 27, and S28-T0's spec read against it before the owner sees it |

## 7. Approval

The owner approves this plan by writing "approved", with any decision ID changed from its default,
and confirms G10's project. The approval line goes at the top of this file in the same commit as
S26-T0's spec. Nothing in this plan starts before that.
