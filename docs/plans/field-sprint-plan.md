# Field plan — what the real run and the measurements asked for

Status: **APPROVED by the owner on 2026-10-08, C1–C13 at their defaults** · Written 2026-10-08 after shipkit 4.3.0 ·
Three sprints: **4.4.0**, **4.5.0**, **4.6.0** · Follows `docs/plans/evidence-sprint-plan.md`,
whose three sprints shipped as 4.1.0, 4.2.0 and 4.3.0.

The evidence plan ended with twelve open items under ROADMAP's "Still open after Sprint 10":
six from the real run on `rails_error_dashboard` (`docs/design/field-notes-4.3.md`), six carried
from the eval measurements of 4.1 and 4.2. The owner asked for all of them. This plan orders
them into three sprints — fix what the real run hurt on, close the gate's blind spots, then
measure what the rules and the elders still owe a number for — and ends with the housekeeping
the owner has not yet decided on.

---

## 1. How to follow this plan

Read this section before every task. These rules apply to a human and to an agent equally.
They are the evidence plan's eleven rules, kept, with four added from what Sprint 10 taught.

1. **Do tasks in order.** Inside a sprint, `T0`, then `T1`, then `T2`… Do not start a sprint
   until the one before it is merged.
2. **One task, one commit.** Test and code together. Write the check first; watch it fail.
3. **One sprint, one branch, one pull request.** Branch `sprint-N/<short-name>` from `main`.
   Never commit to `main` directly.
4. **A task is done only when every line under "Done when" is true.** Run each command. Read
   the output.
5. **Edit only the files under "Files".** Need another file: stop and say why; when the owner
   approves, add it to the task's Files line in the same commit. Ticking the task in `tasks.md`
   needs no listing. A branch-not-taken note in `spec.md` is the release step's edit, not the
   task's — write it in the ship commit, where `Status` and `Paths` change anyway.
6. **Stop and ask the owner when:** a "Done when" check still fails after three honest attempts;
   a "Check first" and its written fallback both fail; you are about to delete a file, a branch,
   a worktree, a sandbox or a shipped skill; a measurement comes out on the side that changes a
   shipped file (S13-T2, S13-T4) — the owner says go before the change; you think this plan is
   wrong. Say what is wrong. Do not quietly do something else.
7. **Never:** `git add .` or `-A`; `--no-verify`; force-push; amend a pushed commit; a
   `Co-Authored-By` line; stage `.env`, keys or tokens; push to `main`.
8. **Commit messages** follow `plugins/shipkit/rules/shipkit.md` (What / Why / How / Test plan).
9. **Use shipkit to build shipkit.** Intake and spec with the shipped skills (by hand from their
   `SKILL.md`, or headless), at least one task handed over with `brief.sh`, `/shipkit:ship`
   before release. What is awkward goes in the pull request under "What was awkward".
10. **Eval results are read from traces.** A failing case is re-run with `--runs 1 --keep-temp`
    (`evals.sh` keeps nothing) and its `trace.jsonl` read before anything changes. A pass that
    exists because the model worked around a bug is a failure. Correcting a grader or prompt
    on trace evidence is allowed and written up beside its baseline; bending one to pass is not.
11. **Requirements describe the product**, never the gate or the release.
12. **Before `git commit --amend`, run `git log -1 --oneline` and read it.** Sprint 10 amended
    HEAD believing it was the commit before; the tree was right and one title is wrong forever.
13. **Before `rm`, `git branch -d`, `git worktree remove`: look at the target.** Sprint 10 found
    uncommitted files in a worktree and permission-stripped sandboxes; both were handled only
    because the first command refused.
14. **Run the smoke test before the gate, not only after it.** Sprint 10's gate said READY on
    a tree whose smoke check 30 failed; the fix forced a second gate run. The exit checklist is
    the same list; run lines 1, 4, 5, 6 and the smoke checks a task touched before `/shipkit:ship`.
15. **Measurement runs are budgeted per sprint, in the sprint's section.** A run not in the
    budget needs the owner's yes.

### The sprint exit checklist (same for every sprint)

| # | Command | Must show |
|---|---------|-----------|
| 1 | `bash scripts/lint.sh` | `0 error(s), 0 warning(s)` |
| 2 | `sh scripts/smoke.sh </dev/null` | `smoke: all checks passed` (127 checks at 4.3.0; ~5 min; a logged-in `claude`) |
| 3 | `bash scripts/evals.sh -j 4` | no case that passed before now fails; `grandfather-xl/drift` below 2 of 3 is re-run alone first (its 4.1 shape, record in the README) |
| 4 | `sh plugins/shipkit/scripts/spec-check.sh .` | exit 0, 0 gaps |
| 5 | `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md \| wc -c` | at most 3000 (2,979 today) |
| 6 | `find plugins/shipkit/evals -type f -print0 \| xargs -0 cat \| wc -c` | at most the ceiling of lint check 17 (131,072 today; C1 moves it in Sprint 13) |

### The release task (`T-REL`, last task of every sprint)

As the evidence plan wrote it: version in five places, CHANGELOG with "What using it for real
showed", README counts, ROADMAP status line, **commit**; smoke lines per rule 14; the gate
headless (`/shipkit:ship <slug>` with the test command `bash scripts/lint.sh && sh
plugins/shipkit/scripts/spec-check.sh .`); fix what it finds; commit the READY report with
`Status: shipped` and any file it names added to `Paths`; the exit checklist on the final tree
(smoke and evals in the background, in parallel); push; pull request with "What was awkward";
`gh pr checks` until pass; merge with a merge commit; tag; the sprint report.

### Words

As the evidence plan's table, plus: **Trap 2** — the second line of a rule file a case can walk
into, after the first line the 4.2 cases probe. **Read rate** — of N elder runs, how many carry
a `Read` of `PROJECT_MAP.md` in their trace.

---

## 2. Decisions the owner must approve

Each has a recommended default. Approve all, or change any by ID.

| ID | Decision | Recommended default | The other option |
|----|----------|---------------------|------------------|
| C1 | Eval room | Sprint 13 moves the evals README's seven history sections (about 8.1 KB: baselines 3.1.0, 3.2.0, 4.0.0, 4.1.0 ×2, 4.2.0, 4.3.0) to `docs/design/eval-history.md`, and lint check 17's ceiling rises 131,072 → 163,840 for the sixteen trap-2 cases | Fewer cases (C7's other option) and no ceiling change |
| C2 | Pre-3.3 specs | The briefing reads a spec with **no `Status` line and every task ticked** as closed (silent, no drift nag) and prints one line — "N specs predate 3.3 and have no Status line; add `> Status: shipped` to each" — when any such spec exists; `spec-check.sh`'s reading (no Status = open, `spec-contract/REQ-7`) does not change | A `/shipkit:spec --migrate` that writes the Status lines into the user's files |
| C3 | Intake asks only what the repository cannot answer | Step 2 of the intake gains a fixed search — ROADMAP, `docs/`, `.shipkit/research/`, `.shipkit/decisions/`, configuration comments, `git log --grep` — run by `grandfather`; a question a file answers becomes an assumption with its `file:line`; a claim of absence names what was searched | Leave the skill; document the finding |
| C4 | Headless runs leave their questions on disk | An unanswered intake writes `intake.md` with the questions under "Answers" marked *unanswered*; a non-interactive product run writes "## Open questions for the owner"; the second pass fills the blanks and re-asks nothing | Reply only, as today |
| C5 | Files no spec will list | The reviewer's "changes beyond the spec" and `brief-verify.sh` both allow everything under `.shipkit/` that is not another spec's folder: `product.md`, `releases/`, `state.md`, `decisions/`, and the spec's own folder | Allow only the four named paths |
| C6 | `brief-verify.sh` and ignored files (Playbook 4's `__pycache__`) | Close by record: ignored files are not seen, by design, and the real run did not hit it; one sentence in the script's header | Build a smoke case that bites |
| C7 | Trap-2 cases | All sixteen rules that pass their trap-1 case without the rule get a trap-2 case under `evals/trap2/`, run with and without the rule, three runs each (96 runs, about $10 once); the release run grows 38 → 54 cases, about $16 | The five core rules and the three stack rules with the shortest text only |
| C8 | Acting on trap-2 numbers | Recorded in `docs/design/eval-results-4.6.md`; a rule whose both traps pass without it is a **named cut candidate for the next plan**; no rule text changes in Sprint 13 on its own measurement (the standing rule since the trim audit) | Bounded trims in Sprint 13, as S9-T5 did for `nontrivial` |
| C9 | The elder's step 1 | At most **two** one-sentence changes to `agents/grandfather.md`'s step 1, each judged by the read rate over the five `grandfather-xl` cases (15 runs, about $4 per attempt) and by the answers holding; keep the first attempt that reads the map in ≥ 10 of 15 runs with every answer still right; otherwise record 0001 gains a note and nothing changes | Record the rate again; change nothing |
| C10 | A rule that names a network step | `stacks/rails/.claude/rules/gemfile.md`'s "read the lock diff after `bundle install`" is reworded so the step is conditional on the install having run (a rule edit on a previous plan's measurement, which the standing rule allows); `stacks-gemfile` re-run 3× with and without | Leave the line; note that evals have no network |
| C11 | The map on a "wip" log; eve's portfolio reads | The XL generator gains `--wip` (every commit message "wip"); `grandfather-xl/history` runs with and without the map on that history (6 runs, about $1.50); eve's loss when fewer projects have a map stays **unmeasured and open** — it needs a multi-project fixture this plan does not build | Build a three-project registry fixture (about 20 KB of generator, a sprint of its own) |
| C12 | Housekeeping, each its own yes at S13-T6 | D1 the `shipkit/real-run` branch in `rails_error_dashboard`; D2 the `3.1.0` directory in the owner's plugin cache; D3 the scratch directories under `$TMPDIR` (`xl-*`, `t4-*`, `t5-*`, `s9-*`, `exit-4.2.0`, `shipkit-nomap`, `shipkit-norule`, `shipkit-pretrim`, `arm-*`, `shipkit-evals`); D4 branches `sprint-8` to `sprint-13` after `v4.6.0` is tagged; D5 the owner's plugin cache updated to the released version at each `T-REL` | Keep any row |
| C13 | Eval cost per release | Accept the release run growing to about $16 (C7); every case, every release | `--group` on changed groups only |

---

## 3. What we know, and what we must check

Known at 4.3.0 (Claude Code 2.1.291), from the smoke checks and Sprint 10:

- Everything the evidence plan listed: the eval sandbox loads nothing from the workspace; the
  rule under test arrives through the hook (`inject-rule.sh --eval-rule`); arms are selected by
  a scratch copy of the plugin with one `sed`; traces carry tool calls, usage and cost;
  `trace-tools.sh` counts them.
- `evals.sh` keeps no sandbox: a failing release-run case has no trace to read until it is
  re-run with `--keep-temp` (rule 10). Kept sandboxes are owned by the user with permission
  bits cleared (`d---------`): `chmod -R u+rwx` before `rm`.
- A headless skill run that cannot ask stops at its questions and writes nothing (intake) or
  writes the file with "none set" gaps (product); the owner's interactive session keeps the old
  plugin until restarted after `claude plugin update`.
- `git grep` per requirement is too slow for the briefing at fifty specs (smoke check 30's 1 s);
  one grep per run is fine (0.6 s).
- zsh does not word-split an unquoted variable: one name per command in a loop.

To check first, each in the task that needs it:

| Claim | Needed by | If false |
|-------|-----------|----------|
| The session hook can tell the running plugin version from the newest directory in the plugin cache (`<cache>/shipkit/shipkit/<ver>/`) without reading `installed_plugins.json` | S11-T4 | Read `installed_plugins.json` with `sed`; if that is not stable either, drop the line and record why |
| A path-scoped rule under `.claude/rules/shipkit/` loads in a normal headless session when the prompt names a matching file, and not when it names a non-matching one | S13-T1 | The check records what did load; the ROADMAP item stays open with the evidence |
| `trace-tools.sh` can count a `Read` of `PROJECT_MAP.md` per run (a tool_use block whose input path ends in `PROJECT_MAP.md`, main session or subagent) | S13-T4 | Add the column to `trace-tools.sh` first (its Files line allows it) |
| The XL generator can take `--wip` without changing any other byte of the fixture (same files, same tree hash per commit, only messages differ) | S13-T5 | Generate a second fixture directory; say the comparison is between fixtures, not messages |

---

## 4. The three sprints at a glance

| Sprint | Release | Name | What the owner gets |
|--------|---------|------|---------------------|
| 11 | 4.4.0 | What the run hurt on | A briefing that is right on a project with pre-3.3 specs; an intake that searches before it asks and says what it searched; headless runs that leave their questions on disk; a version line, a quiet goal line, a "Blocked on" line |
| 12 | 4.5.0 | The gate's blind spots | A `Fired-if` that cannot fire before the code exists; the reviewer and `brief-verify` stop calling `.shipkit/` files "outside the spec"; the gate keeps its exit codes and its output; the ignored-files question closed by record |
| 13 | 4.6.0 | Second traps and the elder's first step | Path-scoped loading measured for the first time; sixteen trap-2 cases with their with/without numbers; the elder's map-read rate, with a kept sentence or a recorded no; the gemfile line fixed; the "wip" history run; the housekeeping the owner approves; a roadmap for the plan after |

Numbers tracked every sprint:

| Item | Today (4.3.0) | Ceiling |
|------|---------------|---------|
| Three injected rules | 2,979 bytes | 3,000 |
| `plugins/shipkit/evals/` | 130,093 bytes | 131,072 (C1: 163,840 from Sprint 13) |
| Eval cases / cost per release run | 38 / ≈ $11.57 | 54 / ≈ $16 (C7, C13) |
| Smoke checks | 127 | — |
| Measurement runs this plan | — | S13: ≈ $10 (C7) + ≈ $8 (C9, two attempts) + ≈ $1 (C10) + ≈ $1.50 (C11) ≈ $21 |

---

## Sprint 11 — What the run hurt on (4.4.0)

**Goal.** Fix the five things the real run showed about shipkit's own behaviour on a project
it had not seen, without touching a rule, an agent or an eval case.

**Branch.** `sprint-11/run-wounds`

### S11-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/run-wounds/intake.md`, `spec.md`, `design.md`, `tasks.md`;
  add `docs/plans/field-sprint-plan.md` (this file, with its approval line).
- **Steps:** intake by hand; the spec with decision records for C2, C3, C4; the owner approves
  the requirements; stamp at the branch-point commit; `Status: open`.
- **Done when:** `spec-check.sh . run-wounds` → 0 gaps; the owner's approval is in the thread.

### S11-T1 — The briefing on a project with pre-3.3 specs (C2)
- **Why:** field notes §1 — six shipped specs with no `Status` line made every briefing line but
  the first wrong, every session, and no line said why.
- **Files:** `plugins/shipkit/scripts/briefing.sh`, `plugins/shipkit/scripts/session-start.sh`
  (the drift nag only), `scripts/smoke.sh`.
- **Steps:** a spec with no `Status` line whose `tasks.md` has every box ticked is *closed* to
  the briefing and to the drift nag; the briefing prints one line naming how many specs have no
  `Status` line, with the fix in the line. `spec-check.sh` is not touched. Smoke check 49:
  three such specs (all ticked, no Status) → no progress line, no drift line, one "predate 3.3"
  line; one spec with no Status and one unticked task → still reported as open; `Status: open`
  with every task ticked → "all ticked" as today.
- **Done when:** check 49 → PASS; check 30 (50 specs under 1 s) → PASS; `bash scripts/lint.sh`
  → 0/0; the three `rails_error_dashboard` lines from field notes §1 would not print (reasoned
  from the check's fixture, which mirrors them).

### S11-T2 — The intake searches before it asks (C3)
- **Why:** field notes §3–§5 — three of four questions were answerable from files; one claim of
  absence was false; `grandfather` was skipped both passes.
- **Files:** `plugins/shipkit/skills/intake/SKILL.md`, `plugins/shipkit/evals/intake/answered/`
  (new case), `scripts/evals.sh` (the citation comment), `plugins/shipkit/evals/README.md`.
- **Check first:** the evals directory has 979 bytes of room; a case is about 1.2 KB. Before
  writing it, move the README's "Release run 4.3.0" and "After the spec-first sentence (4.2.0)"
  sections (1,813 bytes) to `docs/design/eval-history.md` — the first part of C1, brought
  forward with the owner's yes at S11-T0 — or stop and ask.
- **Steps:** step 2 of the skill gains the fixed search list and "ask `grandfather` for each
  candidate question before writing it"; step 4 gains "a question a file answers is an
  assumption with its `file:line`, not a question"; step 3 gains "a claim that something does
  not exist names what was searched". Case `intake-answered`: `sample-app` plus a
  `docs/decisions.md` that answers two of the three natural questions about a refunds request;
  grader: the reply asks at most one question and cites the file for the other two.
- **Done when:** the case passes 2 of 3 with the new text and fails 2 of 3 with the 4.3.0 text
  (a scratch copy of the plugin with the old `SKILL.md`; 6 runs, about $1); `intake-limit`,
  `intake-nongoal`, `intake-trivial` still 3 of 3; evals bytes ≤ 131,072; lint 0/0.

### S11-T3 — Headless runs leave their questions on disk (C4)
- **Files:** `plugins/shipkit/skills/intake/SKILL.md`, `plugins/shipkit/skills/product/SKILL.md`,
  `scripts/smoke.sh`.
- **Steps:** intake, when no user is present: write `intake.md` with each question under
  "Answers" as `— *unanswered*`, and say so; a later pass fills them and asks nothing already
  answered. Product, when no user is present: a "## Open questions for the owner" section
  holding what it would have asked. Smoke check 50 reads both skills for the sentences (prose
  checks, as check 15 does for the README) — the behaviour itself is proven by S11-T2's case
  and the existing `intake-*` cases, whose graders gain one assertion: the file exists after a
  non-interactive first pass.
- **Done when:** check 50 → PASS; `bash scripts/evals.sh --group intake` → every case ≥ 2 of 3;
  lint 0/0.

### S11-T4 — Three one-line fixes from the notes (§0, §9, §10)
- **Files:** `plugins/shipkit/scripts/session-start.sh`, `plugins/shipkit/scripts/briefing.sh`,
  `plugins/shipkit/skills/handoff/SKILL.md`, `scripts/smoke.sh`.
- **Check first:** the version claim in §3 (the newest sibling directory in the plugin cache).
- **Steps:** (a) the hook prints `shipkit: <newer> is installed; this session runs <ver> — restart
  to use it` when a newer sibling exists; (b) the briefing's "top goal" line omits the "metric /
  target / by" tail when all three are "none set" and says "(no metric set)" instead; (c) the
  handoff gains a "## Blocked on" heading, present only when the next step cannot start, with
  one line. Smoke check 51 for (a) and (b); (c) is prose plus one assertion in check 30's
  state.md fixture.
- **Done when:** check 51 → PASS; check 30 → PASS; lint 0/0; `sh plugins/shipkit/scripts/session-start.sh`
  in this repository prints no version line (the running root is the newest).

### S11-T-REL — Release 4.4.0
Follow "The release task". Budget this sprint: S11-T2's 6 arm runs + the intake group twice
(about $3) + the release run (about $11.60).

---

## Sprint 12 — The gate's blind spots (4.5.0)

**Goal.** Close the four findings about the gate, the reviewer and the briefs: a reversal
condition that fires before the code exists, `.shipkit/` files called "outside the spec", exit
codes lost to pipes and output typed by hand, and the ignored-files question left since 4.0.

**Branch.** `sprint-12/gate-blind-spots`

### S12-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/gate-blind-spots/intake.md`, `spec.md`, `design.md`, `tasks.md`.
- **Steps:** as S11-T0; decision records for C5 and C6.
- **Done when:** as S11-T0.

### S12-T1 — A `Fired-if` that cannot fire before the code exists (§6, §7)
- **Files:** `plugins/shipkit/scripts/decision-check.sh`, `plugins/shipkit/skills/spec/SKILL.md`,
  `plugins/shipkit/skills/spec/reference.md`, `scripts/smoke.sh`.
- **Steps:** `decision-check.sh` strips a trailing `<!-- … -->` from a `Fired-if` line before
  running it, and reports `ERROR` with the command's stderr first line. The spec skill's Q3 step
  3 runs `decision-check.sh . --run` on the new `design.md` as it runs `spec-check.sh`, and a
  `FIRED` or `ERROR` on a record just written is a defect to fix before handing over; the
  reference gains one sentence under "The `Fired-if` line": a command must exit 1 on the tree
  the record is written against. Smoke check 52: a design.md whose Fired-if names a missing file
  → `ERROR` naming the file; the same line with a trailing comment → parsed, same result; after
  `touch` of the file with 10 lines → `FIRED`.
- **Done when:** check 52 → PASS; `decision-check.sh . --run` on this repository → 0 error(s);
  lint 0/0.

### S12-T2 — `.shipkit/` is never "outside the spec" (C5, §7, §8)
- **Files:** `plugins/shipkit/agents/reviewer.md`, `plugins/shipkit/scripts/brief-verify.sh`,
  `scripts/smoke.sh`.
- **Steps:** the reviewer's step 4 excludes every path under `.shipkit/` except another spec's
  folder; `brief-verify.sh` allows `.shipkit/product.md`, `.shipkit/state.md`, `.shipkit/releases/`,
  `.shipkit/decisions/` and the spec's own folder (its header says so). Smoke check 53: a task
  whose run wrote `product.md`, the release report and `state.md` → exit 0, nothing OUTSIDE; a
  write to `.shipkit/specs/other/spec.md` → OUTSIDE.
- **Done when:** check 53 → PASS; the `reviewer-all-met` and `reviewer-missing-req` cases 3 of 3;
  lint 0/0.

### S12-T3 — The gate keeps its exit codes and its output (§8)
- **Files:** `plugins/shipkit/skills/ship/SKILL.md`, `plugins/shipkit/skills/ship/reference.md`.
- **Steps:** the How column's commands end `; echo "exit $?"` or write to a scratch file the
  skill reads back (`"${TMPDIR:-/tmp}/shipkit-ship-<step>.out"`), so a report never says "exit
  code not captured because of a pipe" and never carries output typed from memory; the report
  template's evidence blocks say "pasted from the file". The 4.3.0 gate reports are left as
  they are.
- **Done when:** a headless `/shipkit:ship real-run` on this branch (the shipped spec; a dry
  run, its report deleted after reading) quotes every step's exit code; lint 0/0.

### S12-T4 — `brief-verify.sh` and ignored files, closed by record (C6)
- **Files:** `plugins/shipkit/scripts/brief-verify.sh` (header, one sentence), `ROADMAP.md`.
- **Steps:** the record is in this spec's `design.md` (C6); the header sentence says that an
  ignored file an agent writes is invisible to the check by design and that a project whose
  `.gitignore` hides build output should read the task's Done-when output instead.
- **Done when:** the ROADMAP item is gone; lint 0/0.

### S12-T-REL — Release 4.5.0
Follow "The release task". Budget: the reviewer group once (about $1), the release run.

---

## Sprint 13 — Second traps and the elder's first step (4.6.0)

**Goal.** Give the two biggest unmeasured claims their numbers — path-scoped loading, and the
sixteen rules that pass without their text — try the one experiment 4.1 named (the elder's
step 1), fix the one rule line that stopped work, run the "wip" history, and do the housekeeping.

**Branch.** `sprint-13/second-traps`

### S13-T0 — Write the sprint spec; make room (C1)
- **Files:** create `.shipkit/specs/second-traps/intake.md`, `spec.md`, `design.md`, `tasks.md`;
  edit `plugins/shipkit/evals/README.md`, create or extend `docs/design/eval-history.md`,
  `scripts/lint.py` (check 17's number), `scripts/smoke.sh` (check 42's expected message).
- **Steps:** as S11-T0, with records for C7, C8, C9, C10, C11; the README's remaining history
  sections move to `docs/design/eval-history.md` with a one-line pointer each; the ceiling
  becomes 163,840 and check 42 expects "the limit is 163,840".
- **Done when:** `spec-check.sh . second-traps` → 0 gaps; check 42 → PASS; evals bytes
  reported; lint 0/0.

### S13-T1 — Path-scoped loading, measured (§ROADMAP "measured by nothing")
- **Files:** `scripts/smoke.sh`, `plugins/shipkit/evals/README.md` (one paragraph under "How
  runs are isolated").
- **Check first:** the loading claim in §3.
- **Steps:** smoke check 54, headless with `haiku` in a scratch project: install `dependencies.md`
  through `install-rules.sh` with a nonce appended; ask the codeword question while the prompt
  names `pyproject.toml` → nonce seen; ask it naming `README.md` → nonce not seen; repeat for
  one stack rule (`rails/gemfile.md`, `Gemfile`). The README paragraph states the result.
- **Done when:** check 54 → PASS with both halves; the ROADMAP item is replaced by the number.

### S13-T2 — Sixteen trap-2 cases, with and without (C7, C8)
- **Depends on:** S13-T0.
- **Files:** `plugins/shipkit/evals/trap2/` (sixteen case folders), `scripts/evals.sh` (citation
  comment), `scripts/smoke.sh` (check 47 extended to `trap2/*`), `plugins/shipkit/evals/README.md`,
  `docs/design/eval-results-4.6.md`, `ROADMAP.md`.
- **Steps:** for each of the sixteen rules (`eval-results-4.2.md`'s "passes equally without"
  rows), the prompt walks into the rule's **second** named line; the grader is a regex on the
  written file; scaffold = the 4.2 fixture + `with-rule.sh <rule>`. Run with and without (a
  scratch copy with `NO_RULE` defaulted), three runs each; counts from `trace-tools.sh`. The
  results doc has sixteen rows and three readings (passes equally without on both traps → cut
  candidate; separates on trap 2 → the line earns its bytes; fails even with → grader or prompt
  read from traces). **No rule text changes in this task** (C8); candidates are named in the
  ROADMAP for the next plan.
- **Done when:** check 47 → PASS for 34 cases; `evals.sh --group trap2` → every case ≥ 2 of 3
  with the rule; the sixteen-row table has no empty cell; evals bytes ≤ 163,840; lint 0/0;
  **stop:** the owner sees the table before S13-T3.

### S13-T3 — The gemfile line that stopped work (C10)
- **Files:** `plugins/shipkit/stacks/rails/.claude/rules/gemfile.md`, `plugins/shipkit/evals/README.md`.
- **Steps:** reword the one line so the lock-diff step is conditional on `bundle install` having
  run; byte count stays under the stack-rule limits (lint check 14); `stacks-gemfile` run 3× with
  the new text (and the trap-2 case, if its line is this one).
- **Done when:** `evals.sh --case stacks-gemfile` → 3 of 3, no run halted on the network; lint 0/0.

### S13-T4 — The elder's step 1 (C9)
- **Files:** `plugins/shipkit/agents/grandfather.md`, `scripts/trace-tools.sh` (the read-rate
  column, if the Check first needs it), `docs/design/eval-results-4.6.md`,
  `.shipkit/decisions/0001-project-map-default.md` (an appended note only).
- **Check first:** the read-rate claim in §3; then the baseline: the five `grandfather-xl` cases
  on the 4.5.0 text, read rate from traces (15 runs, about $4).
- **Steps:** at most two one-sentence changes to step 1, each run the same way; keep the first
  that reads the map in ≥ 10 of 15 with every answer still right; otherwise revert and append the
  rates to record 0001. **Stop before keeping**: the owner says go (rule 6).
- **Done when:** the results doc has the baseline and each attempt's rate and answers; the kept
  text (or the revert) is in the commit; `evals.sh --group grandfather` ≥ 2 of 3 per case.

### S13-T5 — The "wip" history (C11)
- **Files:** `plugins/shipkit/evals/fixtures/ledger-gen/` (the XL generator; a `--wip` flag),
  `scripts/smoke.sh` (the generator check gains `--wip`: same tree hashes, messages differ),
  `docs/design/eval-results-4.6.md`, `ROADMAP.md`.
- **Check first:** the generator claim in §3.
- **Steps:** `grandfather-xl/history` with and without the map on the `--wip` history (a scratch
  copy whose scaffold passes `--wip`; 6 runs); the eve item is written as open with the reason.
- **Done when:** the smoke check → PASS; the results doc has the six runs; the ROADMAP names
  what eve still owes.

### S13-T6 — Housekeeping the owner approves (C12)
- **Files:** `ROADMAP.md`.
- **Steps:** each row D1 to D5 its own yes, its own command, output in the commit message; D4
  only after `v4.6.0` is tagged — so D4 is a commit on `main`'s next branch, or the owner does
  it by hand; say which.
- **Done when:** the ROADMAP records each row as removed or kept, with the date.

### S13-T7 — The roadmap for the plan after
- **Files:** `ROADMAP.md`.
- **Steps:** Sprints 11–13 marked shipped; "Still open after Sprint 13" = the cut candidates
  from S13-T2, eve's unmeasured loss, whatever S13-T4 could not settle, and anything the three
  releases' "What using it for real showed" sections name; every item cites its evidence.
- **Done when:** lint 0/0; every open item names a file and section.

### S13-T-REL — Release 4.6.0
Follow "The release task". Budget: about $21 of measurement (table in §4) plus the release
run at about $16.

---

## 5. What this plan does not do

- It does not cut or trim a rule. Cut candidates from S13-T2 are named for the next plan (C8).
- It does not add a skill or an agent. It changes the text of four skills (intake, product,
  handoff, spec, ship) and one agent (grandfather, under C9's bound) and one rule line (C10).
- It does not build a multi-project fixture for eve (C11).
- It does not migrate a user's pre-3.3 specs for them (C2 default).
- It does not run the loop on another repository. The next real run belongs to the plan after
  this one, on a second project, so the field notes stop being one anecdote.
- It does not delete anything C12 does not name, and nothing in C12 without its own yes.

## 6. Risks, and what we do about each

| Risk | What we do |
|------|-----------|
| The intake case (S11-T2) passes with the old text too — the model already searches | That is a finding; the case stays as the regression watch and the ROADMAP says the skill text was not the lever |
| Trap-2 lines are as easy as trap-1 lines and sixteen more cases say "passes without" | Then the sixteen are named cut candidates with two measurements each, which is what a cut needs (C8) |
| The elder's step-1 sentence raises the read rate and lowers the answer rate | Both are judged; an attempt that costs one right answer is reverted (C9) |
| The ceiling raise (C1) invites padding | Check 17's new number is stated as "for cases"; the README history is out of the directory, so the room is visible |
| Path-scoped loading turns out not to fire in a headless session either | The ROADMAP item becomes a platform finding with the smoke output; the rule evals' "text delivered always-on" caveat stays |
| `--wip` changes the fixture's tree hashes | Check first; fall back to a second fixture and say so |
| The owner's cache lags the release again | D5 at every `T-REL`, its own yes |

## 7. Approval

To approve: reply with "approved", or with the IDs from section 2 you want changed (for example
"approved, but C7: the eight short rules only, and C12 D2: keep"). Work starts with S11-T0 on
the branch `sprint-11/run-wounds`.
