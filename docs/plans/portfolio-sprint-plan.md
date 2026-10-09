# Portfolio plan — what the numbers allow, and what is still unmeasured

Status: **APPROVED by the owner on 2026-10-09, E1–E13 at their defaults; E11: `~/code/pulse`** (not on disk at approval; checked again at S16-T0) · Written 2026-10-09 after shipkit 4.6.0 ·
Three sprints: **4.7.0**, **4.8.0**, **4.9.0** · Follows `docs/plans/field-sprint-plan.md`,
whose three sprints shipped as 4.4.0, 4.5.0 and 4.6.0.

The field plan ended with twelve open items under ROADMAP's "Still open after Sprint 13",
every one citing its evidence: twelve rule lines with two measurements each and no decision;
two things still unmeasured (`eve`'s loss when fewer projects carry a map, and shipkit on a
second real project); one question the measurements raised (the elder's step 0); and eight
small debts in the harness, the gate and the skills. This plan orders them into three sprints —
pay the harness's debts first, then act on the numbers, then measure the two things that have
no number — and ends with a roadmap for the plan after, seeded by the second real run.

---

## 1. How to follow this plan

Read this section before every task. These rules apply to a human and to an agent equally.
They are the field plan's fifteen rules, kept, with two added from what Sprints 11 to 13 taught.

1. **Do tasks in order.** Inside a sprint, `T0`, then `T1`, then `T2`… Do not start a sprint
   until the one before it is merged.
2. **One task, one commit.** Test and code together. Write the check first; watch it fail.
3. **One sprint, one branch, one pull request.** Branch `sprint-N/<short-name>` from `main`.
   Never commit to `main` directly.
4. **A task is done only when every line under "Done when" is true.** Run each command. Read
   the output.
5. **Edit only the files under "Files".** Need another file: stop and say why; when the owner
   approves, add it to the task's Files line in the same commit. Ticking the task in `tasks.md`
   needs no listing. A branch-not-taken or wording note in `spec.md` is committed on its own,
   before the gate — rule 16 says when; it is no longer the ship commit's edit.
6. **Stop and ask the owner when:** a "Done when" check still fails after three honest attempts;
   a "Check first" and its written fallback both fail; you are about to delete a file, a branch,
   a worktree, a sandbox or a shipped skill; a measurement comes out on the side that changes a
   shipped file (S15-T1) — the owner says go before the change; you think this plan is
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
    Write the table's reading **after** reading the trace, never before (Sprint 13 rewrote four).
11. **Requirements describe the product**, never the gate or the release.
12. **Before `git commit --amend`, run `git log -1 --oneline` and read it.** Sprint 10 amended
    HEAD believing it was the commit before; the tree was right and one title is wrong forever.
13. **Before `rm`, `git branch -d`, `git worktree remove`: look at the target.** Sprint 10 found
    uncommitted files in a worktree and permission-stripped sandboxes; both were handled only
    because the first command refused. Kept sandboxes are the owner's with permission bits
    cleared: `chmod -R u+rwx` before `rm`; every sandbox and scratch copy a task creates, it
    removes after reading.
14. **Run the smoke test before the gate, not only after it.** Sprint 10's gate said READY on
    a tree whose smoke check 30 failed; the fix forced a second gate run. The exit checklist is
    the same list; run lines 1, 4, 5, 6 and the smoke checks a task touched before `/shipkit:ship`.
15. **Measurement runs are budgeted per sprint, in the sprint's section.** A run not in the
    budget needs the owner's yes (Sprint 13's three corrected cases needed a yes for $1.60).
16. **A branch-not-taken or wording note in `spec.md` is committed BEFORE the gate, not with
    the report.** The gate reads the spec first and its reviewer verdict is on the spec as
    committed; a note written into the ship commit was never read by the gate that said READY.
    Sprints 11, 12 and 13 all hit this. Commit spec-text fixes, then run the gate; a fix the
    gate asks for is committed, then the gate is re-run.
17. **Never edit `plugins/` while an eval runs** — the eval tool reads the plugin directory
    live, so an edit mid-run changes the arm under test. The smoke runner copies the tree at
    start, so edits after launch are safe for smoke, not for evals. **The smoke suite rewrites
    `~/.claude/shipkit/plugin-root`** with scratch paths while it runs; restore it after (S14-T3
    makes the runner do this itself — the rule stands for a run that is killed).

### The sprint exit checklist (same for every sprint)

| # | Command | Must show |
|---|---------|-----------|
| 1 | `bash scripts/lint.sh` | `0 error(s), 0 warning(s)` |
| 2 | `sh scripts/smoke.sh </dev/null` | `smoke: all checks passed` (146 checks at 4.6.0; ~6 min; a logged-in `claude`) |
| 3 | `bash scripts/evals.sh -j 4` | no case that passed before now fails; `grandfather-xl/drift` and `digest/attention` below 2 of 3 under `-j 4` are re-run alone with `--keep-temp` first — 3 of 3 alone is their known shape since 4.1.0 and 4.6.0 (`docs/design/eval-history.md`); record the re-run, change neither case |
| 4 | `sh plugins/shipkit/scripts/spec-check.sh .` | exit 0, 0 gaps |
| 5 | `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md \| wc -c` | at most 3000 (2,979 today) |
| 6 | `find plugins/shipkit/evals -type f -print0 \| xargs -0 cat \| wc -c` | at most the ceiling of lint check 17 (163,840 today; E10 moves it in Sprint 16) |

### The release task (`T-REL`, last task of every sprint)

As the field plan wrote it, with the order Sprint 13 settled on: a full smoke run first (the
CHANGELOG names the check count); the release prep **commit** — version in five places
(`plugins/shipkit/.claude-plugin/plugin.json`, `plugins/shipkit-workflows/.claude-plugin/plugin.json`,
three fields in `.claude-plugin/marketplace.json`), CHANGELOG with "What using it for real
showed", README counts, the ROADMAP status line naming the version (lint insists), spec-check
and the two byte lines; then the gate headless:

```sh
claude --plugin-dir "$PWD/plugins/shipkit" --model sonnet \
  --allowedTools Read Glob Grep Bash Write Skill Agent \
  -p "/shipkit:ship <slug>
This run is not interactive and you cannot ask me anything. This repository's test command
is: bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .
Do not change the spec's Status line." </dev/null
```

Fix what it finds (spec-text fixes committed before the re-run, rule 16); remove the NOT READY
report and the gate's `$TMPDIR/shipkit-ship-*.out` files (S14-T2 makes the gate do the latter);
commit the READY report with `Status: shipped` and any file it names added to `Paths`; the exit
checklist on the final tree (smoke and evals in the background, in parallel, never sleep-polled);
record the release run in `docs/design/eval-history.md`; push (the SSH agent usually refuses:
retry once with `GIT_SSH_COMMAND='ssh -o BatchMode=yes'`, then ask — the owner says "try now");
pull request with "What was awkward", ending with the Claude Code attribution line;
`gh pr checks <n>` polled with an until-loop in the background; merge with a merge commit; tag;
push the tag; ask about the cache update (`claude plugin marketplace update shipkit`, then
`claude plugin update shipkit@shipkit`; a restart applies it); the sprint report: what shipped,
what the checks showed, what was awkward, what was skipped and why.

### Words

As the field plan's, plus: **Cut** — the two measured lines of a rule file removed, the file
kept. **Watch case** — an eval case kept after the text it measured is gone, so a release run
says when the model stops following the line unaided. **Arm** — one of the plugin copies a
case runs under (with the rule, without it; three maps, one, none). **Portfolio fixture** —
three generated projects, a registry and their maps, for `eve`.

---

## 2. Decisions the owner must approve

Each has a recommended default. Approve all, or change any by ID. E1 and E11 need one more word
from the owner: E1 the files to keep, if any; E11 the repository.

| ID | Decision | Recommended default | The other option |
|----|----------|---------------------|------------------|
| E1 | The twelve cut candidates (`eval-results-4.6.md`, "The three readings") | **Cut the two measured lines from each of the eleven files at 3 of 3 in both arms** — `hotwire`, `liveview`, `migrations`, `mix-deps`, `monorepo`, `notebooks`, `package-json`, `pyproject`, `react`, `testing`, `ui-ux` (22 lines; the trap-1 line each 4.2.0 case walks into and the trap-2 line from 4.6's table). `rails` keeps both lines: 2 of 3 without is the threshold, and the two runs that used `update_attribute` skipped validations by a method the line does not name. One record in the sprint's `design.md` with a per-file table; the 22 cases stay as **watch cases**, run on the trimmed file, with the clause: *a line returns if its case drops below 2 of 3 in a release run*. The eleven files are re-run (22 cases × 3) on the trimmed text before the cut is kept | Keep all twelve as statements of standards, closed by one record; **or** name files to keep by ID ("E1: keep `ui-ux`, `testing`") — each kept file's two lines get the record's "kept as a standard" sentence and no run |
| E2 | The elder's step 0 (`eval-results-4.6.md`, "The elder's step 1"; record 0001's appended note) | **Close by record, no run.** Append to 0001: step 0 stays as written; in 45 runs across three texts a map read changed no answer, the one question the map decided (`history` on a "wip" log) is the exception the record names and the elder read it there 3 of 3, and the 4.0.0 baseline's token columns put a map read at roughly 23k more main-session input tokens per run (the `drift` and `gap` rows that read it against those that did not). A read that never changes an answer is not worth its tokens; the map is read when the grep does not land, which is the triage working | One attempt at step 0's triage sentence (15 runs ≈ $5, the same bar as C9: ≥ 10 of 15 with every answer right), then the record |
| E3 | The intake names the answering file only because the grader asks (`CHANGELOG.md` 4.4.0) | **Step 4 of `skills/intake/SKILL.md` gains one sentence**: an assumption a file answers names the file and line it comes from. Added as a standard, not on a number — the case passed 3 of 3 before any sentence existed, and the record's clause fired first (4.4.0). The intake group runs once as the watch (≈ $1.70); the README says the sentence was not the lever | Strip the grader's file-citation clause so the case measures only what the skill says; **or** leave both and document the gap |
| E4 | `spec-check.sh` cannot check a draft (`field-notes-4.3.md` §6) | **`--as-open`**, the mirror of `--as-shipped`: a `Status: draft` spec is read as open for the run (the task-format checks, `MISSING-TASK`, `PENDING-TEST`); no file changes; the spec skill's Q3 step calls it on the draft and the status flip is gone from the skill's text | Drafts always get the task-format checks and `MISSING-TASK` as information lines (exit unchanged), no flag |
| E5 | The gate leaves `shipkit-ship-*.out` under `$TMPDIR` (`gate-blind-spots/design.md`, "Exit codes are echoed") | **The gate removes its own scratch files** after the report is written — one line at the end of `skills/ship/SKILL.md`; the report keeps every pasted block, so nothing is lost | Keep them and name them in the report as evidence (the owner removes them) |
| E6 | The smoke suite overwrites `~/.claude/shipkit/plugin-root` (`scripts/smoke.sh` header; `CHANGELOG.md` 4.6.0) | **`smoke.sh` saves the file's content (or its absence) at start and restores it in its `EXIT` trap**, `SMOKE_KEEP` or not; a session started mid-run still reads a scratch root for its length, stated in the header | The hook skips the write under `SHIPKIT_SMOKE=1` — a hook change on a test-suite concern, and every check that reads `plugin-root` would need the variable too |
| E7 | `trace-tools.sh`'s `map_read` misses a shell `cat` (`eval-results-4.6.md`, attempt 2) | **`map_read` counts a `Read` or a `Grep` whose input path ends in `PROJECT_MAP.md`** — the 4.6 document's definition, which the code did not implement (it counts `Read` only; checked 2026-10-09) — **and a new `map_shell` column** counts a `Bash` tool_use whose command names `PROJECT_MAP.md`; `map_read` stays separate so 4.6's 1, 4 and 8 of 15 remain comparable, and 4.6's results document gets one appended line saying its counts were by `Read` alone | Fold the shell read into `map_read` and restate 4.6's rates as "at least" |
| E8 | The eval sandbox denies writing a root dotfile (`eval-results-4.6.md`, the `notebooks` row) | **Understand it, then record it**: the tool's documentation first (the `claude-code-guide` agent); then one probe case on a scratch copy of the plugin — `.editorconfig` at the workspace root and `config/.editorconfig` — one run each with `--keep-temp` (≈ $0.30), the refusal text read from the trace; the evals README gains "What a case cannot ask for". If the refusal is policy, nothing else changes; if a form or flag allows it, `trap2/notebooks` goes back to its pre-commit hook target on the owner's yes | Documentation only, no probe |
| E9 | Rule 5 and the gate disagree on when a note lands (`field-sprint-plan.md` §1 rule 5 against `gate-blind-spots/tasks.md`) | **Closed by this plan's rule 16** and the amended rule 5; the ROADMAP item is struck with the pointer; no plugin file changes | One sentence in `skills/ship/reference.md` too ("the gate reads the spec as committed") |
| E10 | `eve`'s loss when fewer projects carry a map (`eval-results-4.6.md`, "The wip history"; C11) | **A portfolio fixture and three `eve` cases, a sprint of its own.** `evals/fixtures/portfolio-gen/`: three small generated projects of different stack shape (a Rails-shaped `shopfront`, a Phoenix-shaped `pulse`, a Python-shaped `insight`, ~25 files each) with "wip" logs, a registry, and a map per project whose Evolution section holds one *why* the log does not; `--maps 3\|1\|0` picks the arm. Cases: a sweep (`jobs`: which projects run background jobs, with what), a cross-project where (`payments`: where the payment provider is handled and which), and a why (`why`: why `pulse` moved sessions off the database, and when). 3 cases × 3 arms × 3 runs = 27 runs ≈ $5. Lint check 17's ceiling rises 163,840 → 196,608 at S16-T0 (as C1 did) for the generator and the cases; the room is stated as "for cases and generators" | Two cases (`jobs`, `why`) and no ceiling change — the generator must fit the 18 KB of room |
| E11 | A second real run on another repository (`field-sprint-plan.md` §5) | **The owner names a repository of another stack than Rails** — named at approval: `~/code/pulse`; (a Phoenix/LiveView or Python project, so a second stack's rules and skills are exercised) at approval; the loop end to end as the 4.3 run — setup, product, intake, spec, one task handed over with `brief.sh`, ship — headless with `--plugin-dir` on the sprint branch, on a branch `shipkit/real-run-2` never for merge; findings in `docs/design/field-notes-4.9.md` in the 4.3 notes' shape (Asked for / Produced / Took / Awkward / Whose fault / Evidence); **nothing found is fixed in this plan** — the findings seed the plan after; ≈ $5–8 | `rails_error_dashboard` again (measures the fixes since 4.3 on the project that asked for them) |
| E12 | Housekeeping, each its own yes at the task that names it | F1 the `3.1.0` directory and F2 the `4.5.0` directory in `~/.claude/plugins/cache/shipkit/shipkit/` (S15-T4; the owner's interactive session must show "plugin root is …/4.6.0" first); F3 the `shipkit/real-run-2` branch after the notes are written (S16-T3); F4 branches `sprint-14` to `sprint-16` after each release's tag; F5 the owner's plugin cache updated to the released version at each `T-REL` | Keep any row |
| E13 | Eval cost per release | Accept the release run growing 55 → 58 cases (E10's three), ≈ $16.70 → ≈ $17.50; every case, every release | `--group` on changed groups only |

---

## 3. What we know, and what we must check

Known at 4.6.0 (Claude Code 2.1.291), from the smoke checks, the traces and Sprints 11 to 13:

- Everything the field plan listed: the eval sandbox loads nothing from the workspace; the rule
  under test arrives through the hook (`inject-rule.sh --eval-rule`); arms are scratch copies of
  the plugin with one `sed`; the tool forwards no environment to a scaffold; `--keep-temp` keeps
  `config/` and `out/trace.jsonl` only; one `--case` per invocation; no custom-code graders; an
  `llm` grader cannot take `target:`; a quote inside a single-quoted YAML pattern breaks the case.
- `trace-tools.sh` counts `map_read` from a `Read` tool_use only (`scripts/trace-tools.sh`, the
  one `map_read = 1` line), although `eval-results-4.6.md` and the 4.6.0 CHANGELOG say "a `Read`
  or a `Grep`". E7 makes the code match the document and says so.
- The session hook writes `~/.claude/shipkit/plugin-root` on every start
  (`plugins/shipkit/scripts/session-start.sh`, the `printf … > plugin-root` line), with no
  condition. Smoke check 3 asserts the root line is in context, so the hook must keep writing
  under smoke; the runner, not the hook, restores (E6).
- The digest case already builds a three-project registry inside the run's workspace and tells
  the skill where it is ("SHIPKIT_HOME for this run is the `shipkit-home` directory inside the
  working directory", `evals/digest/attention/prompt.md`). The `eve` cases take the same path;
  `eve`'s own text names `~/.claude/shipkit/project-registry.md`, so the prompt's line is what
  points her at the fixture.
- Path-scoped rules load when the model reads a matching file, not when the prompt names it
  (smoke check 54). The eval cases edit the matching file, so a trimmed path-scoped rule is
  measured the same way as before.
- `digest/attention` and `grandfather-xl/drift` drop to 1–2 of 3 under `-j 4` and read 3 of 3
  alone — their known shape (`eval-history.md`, 4.6.0 and 4.3.0). Re-run alone with
  `--keep-temp`, record, change neither.
- The owner's plugin cache holds `3.1.0`, `4.5.0`, `4.6.0`; a session started 2026-10-09 after
  the restart reports `plugin root is …/4.6.0`. The interactive session's hook line is the one
  that counts before F1 and F2.
- `eve` has `maxTurns: 35`; the digest case allows 40 turns and 900 s. A three-repo sweep is
  "a handful of tool calls" by her own text.
- zsh does not word-split an unquoted variable: one name per `read` line in a loop. macOS
  `/bin/sh` is bash 3.2: a `case` inside `$( … )` goes in a function. BSD `sed`/`awk`;
  multi-line edits by python assert-and-replace. A double-braced placeholder outside `stacks/`
  trips the lint. Never `py_compile` under `evals/`.

To check first, each in the task that needs it:

| Claim | Needed by | If false |
|-------|-----------|----------|
| `spec-check.sh` keys on the status in one place, so `--as-open` can promote a draft for the run without a second branch reading the literal `draft` | S14-T1 | Fix the second branch in the same task (the script is on its Files line); say so in the commit |
| The sandbox's refusal of a root dotfile is the tool's policy and the same for every dotfile name, and it is written into the trace's tool_result text | S14-T5 | If a form or flag writes one, the README says which, and `trap2/notebooks` returns to its hook target on the owner's yes; if the trace holds no text, the README quotes the tool's documentation instead |
| Each of the eleven files reads as a whole with its two measured lines removed — no heading left over nothing, no sentence that referred to a cut line — under lint checks 14 and the 40-line stack limit | S15-T1 | The file is re-flowed by hand in the same commit (the owner sees the diff before the run) |
| `eve` answers the `why` case from `pulse`'s map in the three-map arm and says the repository records no reason in the no-map arm — the shape `grandfather` showed on the "wip" history | S16-T2 | The fixture's map or the question is wrong, not `eve`: read the traces, correct on that evidence (rule 10), write it up; no change to `agents/eve.md` in this plan |

---

## 4. The three sprints at a glance

| Sprint | Release | Name | What the owner gets |
|--------|---------|------|---------------------|
| 14 | 4.7.0 | The harness pays its debts | A `spec-check` that checks a draft; a gate that cleans up after itself; a smoke suite that restores the plugin root; a `map_read` that counts what the document says and a `map_shell` beside it; the root-dotfile refusal understood and written down; the rule-5 contradiction closed |
| 15 | 4.8.0 | What the numbers allow | Twenty-two measured lines cut from eleven rule files, each with its watch case and its return clause, or kept by name; the intake's assumption sentence; the elder's step 0 closed by record; two cache directories gone |
| 16 | 4.9.0 | Eve's portfolio and a second project | A three-project fixture and `eve`'s first number — what she loses when fewer projects carry a map; shipkit run end to end on a second real project of another stack; a roadmap for the plan after, seeded by that run |

Numbers tracked every sprint:

| Item | Today (4.6.0) | Ceiling |
|------|---------------|---------|
| Three injected rules | 2,979 bytes | 3,000 (no cut file is always-on; unchanged by E1) |
| `plugins/shipkit/evals/` | 145,241 bytes | 163,840 (E10: 196,608 from Sprint 16) |
| Eval cases / cost per release run | 55 / ≈ $16.70 | 58 / ≈ $17.50 (E10, E13) |
| Smoke checks | 146 | — |
| Measurement runs this plan, outside the release runs | — | S14 ≈ $1 (E8 probe + one gate dry run) · S15 ≈ $8.50 (E1 66 runs ≈ $6.50, up to three re-runs alone ≈ $1, E3 ≈ $1.70; +≈ $5 if E2's other option) · S16 ≈ $11–14 (E10 27 runs ≈ $5, up to two re-runs alone ≈ $1, E11 ≈ $5–8) · ≈ $21–24 in all, plus three release runs ≈ $51 |

---

## Sprint 14 — The harness pays its debts (4.7.0)

**Goal.** Close the six small items that make the tools lie or litter, without touching a rule,
an agent or an eval case's prompt: a draft `spec-check` cannot check, a gate that leaves files
behind, a smoke suite that overwrites the plugin root, a trace count that misses two forms of
read, a sandbox refusal nobody has explained, and a rulebook that contradicts the gate.

**Branch.** `sprint-14/harness-debts`

### S14-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/harness-debts/intake.md`, `spec.md`, `design.md`, `tasks.md`;
  add `docs/plans/portfolio-sprint-plan.md` (this file, with its approval line).
- **Steps:** intake by hand; the spec with decision records for E4, E5, E6, E7, E8, E9; the
  owner approves the requirements; stamp at the branch-point commit; `Status: open`.
- **Done when:** `spec-check.sh . harness-debts` → 0 gaps; the owner's approval is in the thread.

### S14-T1 — `spec-check` checks a draft (E4)
- **Why:** field notes §6 — the spec skill flipped a draft's status to `open` for one run and
  back, to get the check it needed; the right instinct, the wrong mechanism.
- **Files:** `plugins/shipkit/scripts/spec-check.sh`, `plugins/shipkit/skills/spec/SKILL.md`,
  `scripts/smoke.sh`.
- **Check first:** the status claim in §3.
- **Steps:** `--as-open` reads a `Status: draft` spec as open for the run — the three
  task-format checks, `MISSING-TASK`, `PENDING-TEST` — and changes no file; a shipped or dropped
  spec is unaffected by the flag; the header documents it beside `--as-shipped`. The spec
  skill's Q3 step runs `spec-check.sh . <slug> --as-open` on the draft; the sentence that set
  the status to `open` for one run is gone. Smoke check 55: a draft whose `tasks.md` has a task
  without a `Files:` line → `SKIPPED` without the flag, `MISSING-FIELD` with it; a draft with a
  requirement no task names → `MISSING-TASK` with the flag; the skill's text has no status flip
  (prose grep, as check 15 does for the README).
- **Done when:** check 55 → PASS; `spec-check.sh .` on this repository → 0 gaps as before;
  lint 0/0.

### S14-T2 — The gate cleans up after itself (E5)
- **Why:** the design record's own case-against, observed on four gate runs since.
- **Files:** `plugins/shipkit/skills/ship/SKILL.md`, `plugins/shipkit/skills/ship/reference.md`.
- **Steps:** after the report is written, the skill removes
  `"${TMPDIR:-/tmp}"/shipkit-ship-*.out`; the How column's commands are unchanged; the reference's
  evidence blocks keep "pasted from the file" and gain "(the file is removed once the report
  holds it)".
- **Done when:** a headless `/shipkit:ship second-traps` on this branch (a shipped spec; a dry
  run whose report is deleted after reading) ends with no `shipkit-ship-*.out` under `$TMPDIR`
  (`/bin/ls` before and after, both in the commit message); the report still quotes every
  step's exit code and pasted output; lint 0/0. One gate run, ≈ $0.50, in the budget.

### S14-T3 — The smoke suite restores the plugin root (E6)
- **Why:** the 4.6.0 CHANGELOG — restored by hand after a run; a session started mid-run reads
  a scratch root.
- **Files:** `scripts/smoke.sh`.
- **Steps:** at start, the runner reads `~/.claude/shipkit/plugin-root` into a variable (or
  notes its absence); the `EXIT` trap writes it back (or removes the file) whether or not
  `SMOKE_KEEP` is set and whatever the exit status; the header's "except that the session hook
  writes…" sentence says the runner restores it, and that a session started during a run reads
  a scratch root until the run ends.
- **Done when:** `cp ~/.claude/shipkit/plugin-root "$TMPDIR/pr.save"; sh scripts/smoke.sh </dev/null;
  cmp ~/.claude/shipkit/plugin-root "$TMPDIR/pr.save"` → identical and `smoke: all checks passed`
  (the full run is this task's test; a second run with a forced early `exit 1` after check 3,
  on a scratch copy of the script, also restores); lint 0/0.

### S14-T4 — `map_read` counts what the document says; `map_shell` beside it (E7)
- **Why:** 4.6's attempt 2 — one run in fifteen read the map through `cat` and is counted as
  not reading it; and the code counts `Read` only where the document says `Read` or `Grep`.
- **Files:** `scripts/trace-tools.sh`, `scripts/smoke.sh` (check 40's synthetic trace),
  `docs/design/eval-results-4.6.md` (one appended line under "The elder's step 1").
- **Steps:** `map_read` = a `Read` or `Grep` tool_use whose input path ends in `PROJECT_MAP.md`;
  `map_shell` = a `Bash` tool_use whose `command` contains `PROJECT_MAP.md`; both main session
  or subagent; the header's column list updated. Check 40's synthetic trace gains a `Grep` row
  on the map and a `Bash` row with `cat PROJECT_MAP.md`, and asserts `map_read 1 map_shell 1`;
  a trace with neither asserts `0 0`. The appended line in the 4.6 document: its 1, 4 and 8 of
  15 were counted by `Read` alone; the 9 of 15 it gives for attempt 2 is the `map_shell` count.
- **Done when:** check 40 → PASS with the new columns; `sh scripts/trace-tools.sh` on the
  synthetic trace prints both; lint 0/0.

### S14-T5 — The root-dotfile refusal, understood (E8)
- **Why:** every `trap2/notebooks` run in both arms wrote the right file and was refused; a
  case that needs a dotfile cannot be written until this is understood.
- **Files:** `plugins/shipkit/evals/README.md`, `ROADMAP.md`.
- **Check first:** the refusal claim in §3 — the tool's documentation through the
  `claude-code-guide` agent before any run.
- **Steps:** a scratch copy of the plugin with one probe case (not committed): prompt A asks
  for `.editorconfig` at the workspace root, prompt B for `config/.editorconfig`; one run each
  with `--keep-temp`; the tool_result text of the `Write` read from each trace. The README's
  "How runs are isolated" gains "What a case cannot ask for": the refusal quoted, the form that
  works named, and the rule for case authors (a dotfile goes in a subdirectory, or the case
  asks for a non-dotfile that does the same job, as `trap2/notebooks` does). The scratch copy
  and the kept sandboxes are removed after reading (rule 13).
- **Done when:** the paragraph quotes the refusal text (or the documentation, with the
  fallback stated); the ROADMAP item is replaced by the pointer; nothing under `$TMPDIR` from
  this task remains; lint 0/0. Two runs, ≈ $0.30, in the budget.

### S14-T6 — Rule 5 and the gate, closed (E9)
- **Files:** `ROADMAP.md`.
- **Steps:** the item is struck with a pointer to this plan's rule 16 and amended rule 5; no
  plugin file changes.
- **Done when:** lint 0/0; the ROADMAP's open list has eleven items left, each still citing
  its evidence.

### S14-T-REL — Release 4.7.0
Follow "The release task". Budget this sprint: S14-T2's one gate dry run (≈ $0.50), S14-T5's
two probe runs (≈ $0.30), the gate itself, the release run (≈ $16.70).

---

## Sprint 15 — What the numbers allow (4.8.0)

**Goal.** Act on the two measurements each of twelve rule lines now carries: cut what the
model follows unaided, keep each cut's case as the watch that brings the line back, keep what
the owner names; add the one intake sentence; close the elder's step 0 by record; remove the
two cache directories the owner has already named.

**Branch.** `sprint-15/measured-cuts`

### S15-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/measured-cuts/intake.md`, `spec.md`, `design.md`, `tasks.md`.
- **Steps:** as S14-T0; decision records for E1 (one record with the per-file table: file,
  trap-1 line, trap-2 line, both measurements, cut or kept, the return clause), E2, E3. The
  owner's yes per file is given at approval of E1; T0 writes it down.
- **Done when:** `spec-check.sh . measured-cuts` → 0 gaps; the design's table has a row for all
  twelve files; the owner's approval is in the thread.

### S15-T1 — The cuts, re-measured (E1)
- **Why:** 4.6's "The three readings" — twelve files pass without their text on both named
  lines; two measurements each is what a cut needs, and C8 forbade cutting on the sprint's own
  numbers.
- **Files:** `plugins/shipkit/rules/migrations.md`, `rules/monorepo.md`, `rules/testing.md`,
  `rules/ui-ux.md`, `plugins/shipkit/stacks/hotwire/.claude/rules/hotwire.md`,
  `stacks/liveview/.claude/rules/liveview.md`, `stacks/elixir/.claude/rules/mix-deps.md`,
  `stacks/ml/.claude/rules/notebooks.md`, `stacks/react/.claude/rules/package-json.md`,
  `stacks/python/.claude/rules/pyproject.md`, `stacks/react/.claude/rules/react.md` (minus any
  file the owner keeps by ID), `plugins/shipkit/evals/README.md`, `docs/design/eval-results-4.8.md`,
  `ROADMAP.md`.
- **Check first:** the well-formedness claim in §3, file by file, with the diff shown to the
  owner before any run.
- **Steps:** remove the two measured lines from each file named in the design's table (the
  trap-1 line as each `scoped/` or `stacks/` case's prompt walks into it, read against
  `eval-results-4.2.md`'s "what the three without-arm runs wrote" rows; the trap-2 line from
  4.6's table); byte and line counts before and after in the results document. Run the 22
  cases on the trimmed text — `scoped/migrations`, `scoped/monorepo`, `scoped/testing`,
  `scoped/ui-ux`, `stacks/hotwire`, `stacks/liveview`, `stacks/mix-deps`, `stacks/notebooks`,
  `stacks/package-json`, `stacks/pyproject`, `stacks/react` and their `trap2/` twins — three runs
  each (66 runs, ≈ $6.50), `--keep-temp`, counts from `trace-tools.sh`. A case at 2 of 3 or
  better: the model follows the line unaided, the cut stands, the case is its watch. A case
  below 2 of 3: the trace is read first (rule 10); if the model did walk into the trap, the
  line returns in the same commit — the record's clause fired on the spot — with the owner's
  yes. The README's cases section names the cut files and the watch rule; the ROADMAP item is
  replaced by the number.
- **Done when:** 22 cases ≥ 2 of 3 on the shipped text (or a returned line named); the
  results document's eleven-row table has no empty cell; lint 0/0 (checks 14 and the 40-line
  stack limit hold); `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md | wc -c`
  unchanged at 2,979; **stop:** the owner sees the table before S15-T2.

### S15-T2 — The intake's assumption names its file (E3)
- **Files:** `plugins/shipkit/skills/intake/SKILL.md`, `plugins/shipkit/evals/README.md`.
- **Steps:** step 4's "write those down as assumptions instead" gains "each with the file and
  line that answers it"; the README's intake paragraph says the sentence is a standard the
  grader already asked for, added without a number behind it. `bash scripts/evals.sh --group
  intake` once (≈ $1.70).
- **Done when:** every intake case ≥ 2 of 3 (`answered` has been 2 or 3 of 3 since 4.4.0;
  below 2 is re-run alone and read); lint 0/0.

### S15-T3 — The elder's step 0, closed by record (E2)
- **Files:** `.shipkit/decisions/0001-project-map-default.md` (an appended note only),
  `ROADMAP.md`.
- **Steps:** the note states what §2 E2 says, with the numbers it cites in place
  (`eval-results-4.6.md` for the 45 runs and the wip history; `eval-history.md`'s 4.0.0 XL
  baseline for the token columns) and the sentence that closes the question: the elder reads
  the map when the grep does not land or the question is about evolution, and nothing in this
  plan or the last changed that. No run. (If the owner picks E2's other option: one attempt,
  S13-T4's method, 15 runs, the same bar, then the note — `agents/grandfather.md` and
  `docs/design/eval-results-4.8.md` join the Files line.)
- **Done when:** the note is appended; the ROADMAP item is struck; lint 0/0.

### S15-T4 — Two cache directories (E12 F1, F2)
- **Files:** `ROADMAP.md`.
- **Steps:** the owner's interactive session's hook line must say `…/4.6.0` or newer before
  either row; each row its own yes, its own command, `/bin/ls` of the target before, the
  command's output in the commit message.
- **Done when:** the ROADMAP records each row as removed or kept, with the date.

### S15-T-REL — Release 4.8.0
Follow "The release task". Budget: S15-T1's 66 runs (≈ $6.50) plus up to three re-runs alone
with `--keep-temp` (≈ $1); S15-T2's intake group (≈ $1.70); the release run (≈ $16.70).

---

## Sprint 16 — Eve's portfolio and a second project (4.9.0)

**Goal.** Give the two things that still have no number theirs: what `eve` loses when fewer
projects carry a map, on a fixture built for the question; and what shipkit does on a second
real project, of another stack, run end to end — then write the roadmap the plan after starts
from.

**Branch.** `sprint-16/portfolio-run`

### S16-T0 — Write the sprint spec; make room (E10, E13)
- **Files:** create `.shipkit/specs/portfolio-run/intake.md`, `spec.md`, `design.md`, `tasks.md`;
  edit `scripts/lint.py` (check 17's number), `scripts/smoke.sh` (check 42's expected message).
- **Steps:** as S14-T0, with records for E10, E11, E13; the ceiling becomes 196,608 and check 42
  expects "the limit is 196,608"; the lint comment says the room is for cases and generators.
- **Done when:** `spec-check.sh . portfolio-run` → 0 gaps; check 42 → PASS; evals bytes reported;
  lint 0/0; the owner's approval, with E11's repository path, is in the thread.

### S16-T1 — The portfolio fixture (E10)
- **Files:** `plugins/shipkit/evals/fixtures/portfolio-gen/generate.py`,
  `plugins/shipkit/evals/fixtures/FACTS-PORTFOLIO.md`, `scripts/smoke.sh`.
- **Steps:** `generate.py [--maps 3|1|0]` writes, into the current empty directory, three
  projects under `projects/` (`shopfront`: `Gemfile` with `sidekiq` and `stripe`,
  `config/deploy.yml`; `pulse`: `mix.exs` with `oban` and `stripity_stripe`, `fly.toml`;
  `insight`: `pyproject.toml` with `celery`, `Dockerfile`, `render.yaml`; ~25 files each,
  standard library only, fixed dates, every commit message "wip"), a `shipkit-home/` with
  `project-registry.md` (`Stack` and `Deploys To` filled, `Map` naming each map or `—`), and
  for the mapped projects a `PROJECT_MAP.md` whose Evolution section holds one *why* that no
  file and no commit records (`pulse`: sessions moved off the database to a cookie store because
  the nightly vacuum locked the sessions table — the fact `why` asks for). `--maps 1` maps
  `shopfront` only; `--maps 0` maps none. `FACTS-PORTFOLIO.md` lists every fact a grader checks.
  Smoke check 56: the generator runs twice into two directories and the tree hash of each
  project's HEAD is identical; `--maps 1` leaves `pulse` and `insight` without a map and the
  registry says `—`; the three signals grep as the facts file says.
- **Done when:** check 56 → PASS; evals bytes ≤ 196,608; lint 0/0.

### S16-T2 — Three `eve` cases, three arms (E10)
- **Depends on:** S16-T1.
- **Files:** `plugins/shipkit/evals/eve/jobs/`, `eve/payments/`, `eve/why/` (each a `case.yaml`,
  `prompt.md`, `fixture.sh`, `graders/`), `scripts/evals.sh` (citation comment),
  `plugins/shipkit/evals/README.md`, `docs/design/eval-results-4.9.md`, `ROADMAP.md`,
  `.shipkit/decisions/0001-project-map-default.md` (an appended note: `eve`'s number).
- **Check first:** the `why` shape claim in §3, on the first three-map run.
- **Steps:** each prompt goes through `/shipkit:ask --all …` with the digest case's line
  ("SHIPKIT_HOME for this run is the `shipkit-home` directory inside the working directory; this
  run is not interactive"); `fixture.sh` runs the generator with `--maps 3`. Graders: `jobs` —
  the reply names all three projects with the right library each (regex on the reply);
  `payments` — names `shopfront` and `pulse` with Stripe and `insight` as none, citing a
  manifest path; `why` — an `llm` grader: the reason (the vacuum lock) and the move, or, where
  no map holds it, a plain "the repository does not record why" with no reason invented. Arms:
  the committed plugin (`--maps 3`), and two scratch copies whose `fixture.sh` passes `--maps 1`
  and `--maps 0`; three runs each (27 runs, ≈ $5), `--keep-temp`, counts from
  `trace-tools.sh` (its `map_read` and `map_shell` columns now cover `eve`). The results
  document: a 3 × 3 table and three readings — a case the maps never change (the sweep and the
  where, if they hold in every arm: `eve`'s cheap path does not need a map); a case only a map
  answers (`why`, if it holds with three maps and fails without); and whatever the traces say
  that neither reading expected. Record 0001 gains the number; the ROADMAP item is replaced by
  it.
- **Done when:** the table has no empty cell; the three readings are written after the traces
  are read (rule 10); every `eve` case ≥ 2 of 3 in the three-map arm; evals bytes ≤ 196,608;
  lint 0/0; **stop:** the owner sees the table before S16-T3.

### S16-T3 — The second real run (E11)
- **Files:** `docs/design/field-notes-4.9.md`, `ROADMAP.md`.
- **Steps:** in the repository the owner named, on a new branch `shipkit/real-run-2` (never
  for merge), with `claude --plugin-dir "<this checkout>/plugins/shipkit"` at this sprint's
  branch: the steps of `field-notes-4.3.md` in order — `/shipkit:setup`, `/shipkit:product`,
  `/shipkit:intake` on one real request the owner names, `/shipkit:spec`, one task handed over
  with `brief.sh` and checked with `brief-verify.sh`, `/shipkit:ship` — each headless where the
  4.3 run was, each written up as Asked for / Produced / Took / Awkward / Whose fault /
  Evidence. Rule 17 holds for the run's length: no edit under `plugins/` while a step runs.
  **Nothing found is fixed in this sprint**; each finding becomes an item under "Still open
  after Sprint 16" with its section number. The branch is deleted after the notes are written,
  on F3's own yes (rule 13: `git log shipkit/real-run-2` read first).
- **Done when:** the notes have every step with its six parts; the ROADMAP's open list has one
  item per finding, each citing a section; the branch's fate is recorded; lint 0/0. ≈ $5–8.

### S16-T4 — The roadmap for the plan after
- **Files:** `ROADMAP.md`.
- **Steps:** Sprints 14–16 marked shipped in a table as the field plan's; "Still open after
  Sprint 16" = the second run's findings, whatever S16-T2's third reading named, any returned
  line from S15-T1, and anything the three releases' "What using it for real showed" sections
  name; every item cites its evidence.
- **Done when:** lint 0/0; every open item names a file and section.

### S16-T-REL — Release 4.9.0
Follow "The release task". Budget: S16-T2's 27 runs (≈ $5) plus up to two re-runs alone
(≈ $1); S16-T3's run (≈ $5–8); the release run at 58 cases (≈ $17.50).

---

## 5. What this plan does not do

- It does not cut a rule **file**, only the two measured lines of each (E1); a file the owner
  names by ID keeps both. It does not touch the four files that separated on trap 2, the two
  that separated on trap 1 (`dependencies`, `jobs`), or `rails`.
- It does not change `agents/grandfather.md` or `agents/eve.md`. Step 0 is closed by record
  (E2's default); `eve` is measured, not edited — what the measurement asks for is the plan
  after's.
- It does not add a skill or an agent. It changes the text of three skills (spec, ship, intake),
  one script in the plugin (`spec-check.sh`), two in the repository (`smoke.sh`,
  `trace-tools.sh`), and eleven rule files.
- It does not fix what the second real run finds (E11). The findings seed the plan after, as
  the first run's seeded the field plan.
- It does not change `digest/attention` or `grandfather-xl/drift`; their shape under `-j 4` is
  recorded, not corrected.
- It does not migrate a user's pre-3.3 specs, build a `--migrate`, or revisit any field-plan
  decision at its default.
- It does not delete anything E12 does not name, and nothing in E12 without its own yes.

## 6. Risks, and what we do about each

| Risk | What we do |
|------|-----------|
| A trimmed file's case fails on the re-run (S15-T1) or in a later release run | That is the clause working: the trace is read, and if the model walked into the trap the line returns, in the same commit with the owner's yes (S15-T1) or as the first task of the next sprint (a release run) |
| A cut line was load-bearing for a line that stayed — the file reads wrong without it | The Check first shows every diff to the owner before a run; a re-flow is a hand edit in the same commit |
| The owner wants a file kept that the default cuts | E1 takes IDs; a kept file's lines are recorded as a standard and its cases stay |
| The portfolio generator does not fit even the raised ceiling | It is written to 20 KB; the three projects are ~25 files each, not 224; the room after S16-T1 is reported in the task |
| `eve` does not find the registry in the sandbox | The digest case already points its skill at `shipkit-home/` by the prompt's line (§3); the `eve` prompts carry the same line; if she still reads `~/.claude/shipkit/`, the trace says so and the case is corrected on that evidence |
| The `why` case passes without a map because `eve` invents a reason | The `llm` grader fails an invented reason by name, as the `grandfather-xl/history` judges did on the "wip" log (0 of 3 without, no reason invented); a run that invents one is a finding about `eve`, written up, not fixed here |
| The second run's repository has uncommitted work or its own `.shipkit/` | The run starts from a clean checkout on its own branch; nothing is committed to the owner's branch; `git status` before the first step goes in the notes |
| The owner's interactive session runs the plugin from the cache while a sprint edits `plugins/` | The cache is a copy (4.6.0 now); the checkout's edits do not reach it until F5 — and rule 17 keeps edits away from a running eval |
| `--as-open` promotes a draft in one place and a second branch still reads `draft` | The Check first; the second branch is fixed in the same task |
| The dotfile probe's trace holds no refusal text | The README quotes the tool's documentation instead and says the trace was silent |
| Three releases at ≈ $17 each plus ≈ $24 of measurement | Stated in §4; every run outside a budget line needs the owner's yes (rule 15) |

## 7. Approval

To approve: reply with "approved", or with the IDs from section 2 you want changed (for example
"approved, but E1: keep `ui-ux` and `testing`; E2: the attempt; E11: ~/code/pulse"). E11 needs
the repository's path either way. Work starts with S14-T0 on the branch `sprint-14/harness-debts`.
