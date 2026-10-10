# Second-run plan — what the second project showed, and what `eve` still owes

Status: **APPROVED by the owner, 2026-10-10 ("approved": every default in §2 stands; E17's repository is named by S19-T0)** · Written 2026-10-10 after shipkit 4.9.0 ·
Three sprints: **4.10.0**, **4.11.0**, **4.12.0** · Follows `docs/plans/portfolio-sprint-plan.md`,
whose three sprints shipped as 4.7.0, 4.8.0 and 4.9.0.

The portfolio plan ended with eighteen items under the ROADMAP's "Still open after Sprint 16",
every one citing its evidence: seven findings from the second real run (`field-notes-4.9.md`),
three of that project's own, three readings the `eve` measurement left (`eval-results-4.9.md`),
and five things the three releases named for the plan after. This plan orders them into three
sprints — fix what the run found first, then act on the graders and on `eve`, then close the
harness window and run the loop a third time on the third stack — and ends, as the last two
plans did, with a roadmap seeded by that run.

---

## 1. How to follow this plan

Read this section before every task. These are the portfolio plan's seventeen rules, kept, with
two added from what Sprint 16 taught.

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
   before the gate (rule 16).
6. **Stop and ask the owner when:** a "Done when" check still fails after three honest attempts;
   a "Check first" and its written fallback both fail; you are about to delete a file, a branch,
   a worktree, a sandbox or a shipped skill; a measurement comes out on the side that changes a
   shipped file — the owner says go before the change; you think this plan is wrong. Say what
   is wrong. Do not quietly do something else.
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
    Write the table's reading **after** reading the trace.
11. **Requirements describe the product**, never the gate or the release. Sprint 16's gate
    said NOT READY on a requirement that said "in a release run"; the clause was reworded
    before the re-run. Read every `shall` for the word "release" before the gate.
12. **Before `git commit --amend`, run `git log -1 --oneline` and read it.**
13. **Before `rm`, `git branch -d`, `git worktree remove`: look at the target.** Kept sandboxes
    are the owner's with permission bits cleared: `chmod -R u+rwx` before `rm`; every sandbox
    and scratch copy a task creates, it removes after reading.
14. **Run the smoke test before the gate, not only after it.** The exit checklist is the same
    list; run lines 1, 4, 5, 6 and the smoke checks a task touched before `/shipkit:ship`.
15. **Measurement runs are budgeted per sprint, in the sprint's section.** A run not in the
    budget needs the owner's yes.
16. **A branch-not-taken or wording note in `spec.md` is committed BEFORE the gate, not with
    the report.** Commit spec-text fixes, then run the gate; a fix the gate asks for is
    committed, then the gate is re-run.
17. **Never edit `plugins/` while an eval runs.** The smoke runner restores
    `~/.claude/shipkit/plugin-root`; a `--plugin-dir` session does not — write the cache path
    back after each one (S19-T1 makes the hook do it; the rule stands until then).
18. **A `regex` grader is a JavaScript `RegExp`.** Before the first run of a new or changed
    regex case, test its pattern with `node -e 'new RegExp(process.argv[1])' '<pattern>'` and
    against one saved reply; a Python inline flag throws and every run fails with no model
    error, and the tool's verdict is then no verdict (Sprint 16 graded eighteen replies from
    their traces because of it).
19. **Hand a brief over from a clean tree.** `git status --short` is empty before `brief.sh`
    runs, and the base ref is noted; `brief-verify.sh` reads every difference from the base,
    and fourteen of Sprint 16's OUTSIDE lines were setup's, not the agent's (S17-T3 makes
    `brief.sh` say so; the rule stands either way).

### The sprint exit checklist (same for every sprint)

| # | Command | Must show |
|---|---------|-----------|
| 1 | `bash scripts/lint.sh` | `0 error(s), 0 warning(s)` |
| 2 | `sh scripts/smoke.sh </dev/null` | `smoke: all checks passed` (161 checks at 4.9.0; ~8 min; a logged-in `claude`); a haiku check that fails once is re-run with its dependencies (check 2 needs check 1), not alone |
| 3 | `bash scripts/evals.sh -j 4` | no case that passed before now fails; `grandfather-xl/drift`, `digest/attention` and now `grandfather/drift` below 2 of 3 under `-j 4` are re-run alone with `--keep-temp` first; record the re-run, change none of them |
| 4 | `sh plugins/shipkit/scripts/spec-check.sh .` | exit 0, 0 gaps |
| 5 | `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md \| wc -c` | at most 3000 (2,979 today) |
| 6 | `find plugins/shipkit/evals -type f -print0 \| xargs -0 cat \| wc -c` | at most 196,608 (191,778 today; E11 adds one probe case, about 1.5 KB) |

### The release task (`T-REL`, last task of every sprint)

As the portfolio plan wrote it: a full smoke run first (the CHANGELOG names the check count);
the release prep commit — version in five places, CHANGELOG with "What using it for real
showed", the ROADMAP status line naming the version (lint insists) and the table row, T-REL
ticked; the gate headless (`claude --plugin-dir "$PWD/plugins/shipkit" --model sonnet
--allowedTools Read Glob Grep Bash Write Skill Agent -p "/shipkit:ship <slug> …" </dev/null`,
the test command `bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .`); fix
what it finds (rule 16); commit the READY report with `Status: shipped`; the exit checklist on
the final tree, smoke and evals in the background in parallel (the release eval run may start
as soon as `plugins/` is final, which is the release prep commit); record the release run in
`docs/design/eval-history.md`; push (the SSH agent refuses intermittently: one retry with
`GIT_SSH_COMMAND='ssh -o BatchMode=yes'`, then ask — the owner says "try now"); pull request
with "What was awkward", ending with the Claude Code attribution line; `gh pr checks <n>`
polled with an until-loop in the background; merge with a merge commit; tag; push the tag; ask
about the cache update and the branch deletion, each its own yes; the sprint report.

### Words

As the portfolio plan's, plus: **Hand-over** — the moment `brief.sh` prints a task's brief;
the base ref is `HEAD` then. **Probe case** — a case run once or three times to answer one
question and kept in the suite only if its answer is worth a release-run watch.

---

## 2. Decisions the owner must approve

Each has a recommended default. Approve all, or change any by ID. E17 needs one more word from
the owner: the repository.

| ID | Decision | Recommended default | The other option |
|----|----------|---------------------|------------------|
| E1 | `install-stack.sh` appends a stack section under a heading the project already has (`field-notes-4.9.md` §2.1) | **The installer looks for the heading before it appends.** If `CLAUDE.md` already has the section's `## <heading>`, the shipkit block is still written under its marker (so the manifest and `.section-<stack>.sha` stay true) but the reply says "you already have a `## Elixir-Specific` section; shipkit's is below it under the marker — here is the diff", and `/shipkit:update-rules` is named as the way to merge. Smoke check: a `CLAUDE.md` with the heading present → the reply line and both sections; absent → one section | Skip the shipkit section when the heading exists (loses the managed block and its sha; the next `setup` cannot tell what it wrote) |
| E2 | Setup does not notice a same-named rule in `.claude/rules/` beside `.claude/rules/shipkit/` (§2.2) | **One line in setup's reply**, from `install-rules.sh`: "your `.claude/rules/` has `dependencies.md`, `migrations.md`, `testing.md` beside shipkit's; both load on the same paths" — the names only, no merge, no deletion. Smoke check on a fixture with one same-named rule | Nothing: the project's rules are the project's |
| E3 | Setup moves a previous backup that git tracks, so `git status` shows deletions (§2.3) | **A tracked backup stays where it is.** Before nesting `.shipkit-backup-*` into the new backup, `git ls-files --error-unmatch <dir>` is asked; tracked → left in place and named in the reply ("`.shipkit-backup-20260321-…` is tracked; left as is — remove it from git yourself if you want it gone"); untracked → nested as now. Smoke check: a tracked old backup → still at the root, clean `git status` | Move it as now and say so (what 4.9 did; the owner then has fourteen deletions to decide about) |
| E4 | `brief-verify.sh` counts changes already in the tree at hand-over; nothing says "hand over from a clean tree" (§8.1) | **`brief.sh` prints a warning line** to stderr when `git status --short` is not empty at hand-over — `brief: N file(s) already differ from HEAD; brief-verify will count them` — and the brief itself is unchanged. Rule 19 is the discipline; the line is the reminder. Smoke check: a dirty tree → the line; clean → none | `brief-verify.sh --since <ref>` that ignores files already differing at the base (more machinery for a case rule 19 already prevents) |
| E5 | Setup's files are "changes beyond the spec" to the reviewer and to `brief-verify` on every first spec (§9.4) | **`.claude/rules/shipkit/` and `.shipkit-baseline/` join the always-allowed list** in `brief-verify.sh` and in the reviewer's text, as `.shipkit/` did in 4.5.0 — they are written only by the installer. `CLAUDE.md` and `.gitignore` stay reported: they hold the project's own content, and a change there is worth a reviewer's line even when setup made it. Smoke check 26 extended | Allow all four when the install manifest's sha matches the appended section (a check the reviewer agent cannot run cheaply) |
| E6 | The reviewer's one MET citation named diff positions, not file lines (§9.1) | **One sentence in `agents/reviewer.md`**: a MET line cites `path:line` as `grep -n` prints it in the working tree, never a position inside a diff hunk; and the gate's step 4 pastes the reply, not a summary (E7), so a wrong line is visible. Smoke check greps the sentence; the measure is the next real run (S19-T4) — model behaviour, no eval | The gate re-checks every MET citation with `sed -n` (the ship skill grows a loop over the reviewer's lines; the cost lands on every gate run) |
| E7 | The gate summarises the reviewer's reply where `gate-blind-spots` REQ-9 asks for it pasted (§9.2; named at 4.7.0 and 4.8.0) | **Step 4 writes the reviewer's reply to a file and pastes from the file**, the mechanism step 2 uses for test output since 4.5.0 (the model summarises what it holds in context and pastes what it reads from a file). Smoke check: the report holds the reviewer's `VERDICT:` line and its per-requirement lines verbatim, on the headless gate dry run | A sentence only ("paste the whole reply") — tried in 4.5.0's wording and read as "condense" twice since |
| E8 | A background-agent wait sentence leaks into the final reply ("I'll stop here until its notification arrives", then the answer) — intake and the gate, three times in one day (§4.1, §9.3) | **Closed by record.** It is the harness's shape when a skill waits on an Agent call in a headless run, not the skill's text; a "do not narrate waiting" sentence in three skills costs bytes for a behaviour the platform produces. Recorded in the sprint's `design.md` with the three quotes; reopened if an interactive session shows it | The sentence in `ask`, `intake` and `ship` |
| E9 | `eve/payments`' manifest clause measures a citation habit: one reply per arm cites the handling file and the gem, not the manifest, 2 of 3 in every arm (`eval-results-4.9.md`, reading 3) | **Correct the grader on the trace evidence**: the citation may be a manifest (`Gemfile`, `mix.exs`) **or** a file that handles the provider (`stripe_charge.rb`, `billing/stripe.ex`) — the question asked "where do I handle payments". Re-run the three arms once (9 runs ≈ $1.10); the 4.9 counts stay in the table beside the new ones | Keep the clause; the case stays at the threshold as a watch on citation habits |
| E10 | `eve` speculates after saying "not recorded": five of six map-less `why` replies add motives marked as guesses (reading 3) | **Measure, then one sentence, then measure again.** The no-map `why` arm is re-run (3 runs ≈ $0.40) under the **first** grader wording from S16-T2 ("a labelled guess is still a reason offered") as the strict measure — expected 0 of 3, the baseline. Then one sentence in `agents/eve.md`'s "Verify per project" step: *a why that no map, record or commit holds is answered "not recorded"; offer no motives of your own.* Re-run the same arm (3 runs); the sentence stays only if the strict grader reads ≥ 2 of 3 and the three-map arm (3 runs) still reads 3 of 3. The shipped `why` grader (REQ-8's wording) is unchanged | Closed by record: a labelled guess is honest and the user can ignore it |
| E11 | `eve` reached `pulse`'s map because `Grep session` landed on its Evolution lines; a map in other words would not have been read (reading 3; decision 0001's `eve` note) | **One probe case, `eve/why-reworded`**: the same question in words the map's Evolution line does not use ("Why do pulse's users no longer get signed out overnight, and since when?" — no "session", no "database"), three-map arm, 3 runs ≈ $0.45. ≥ 2 of 3 → the grep-first path is robust enough and the probe is kept as a watch; below → the number a step-0 sentence for `eve` would need, recorded, no sentence in this plan (0001's clause names the condition: a wrong answer the map, when read, gets right) | Nothing; the reading stands as a caveat |
| E12 | `trap2/notebooks`' grader is narrower than its line: a standard-library output-clearing script is not matched (`eval-results-4.8.md`, "The two runs below 3 of 3") | **Widen the regex on the trace's own evidence**: the failing run's script set every cell's `outputs` to `[]` and `execution_count` to `null` through `json`; the pattern gains that form beside `nbstripout` and `nbconvert --clear-output`. One re-run alone (3 runs ≈ $0.30); the 4.6/4.8 counts stay beside | An `llm` grader ("outputs are cleared before commit by any means") — three judge calls per run where one regex did |
| E13 | A headless run that follows the spec-driven rule builds nothing, and a file grader fails it (`trap2/react`, one run; 4.8.0) | **Closed by record.** The case was 3 of 3 in the 4.8.0 and 4.9.0 release runs; the one run was the always-on rule working as written on a prompt that reads as non-trivial. A prompt line "this is a trivial change" would measure less. Recorded; reopened if the case drops below 2 of 3 in a release run | The prompt line |
| E14 | The four kept whole-body files (`migrations`, `monorepo`, `testing`, `package-json`) and `rails` are cut only on a third model's measurement (`measured-cuts/design.md`) | **The ten cases on `haiku`** (`EVALS_MODEL=haiku`, five files × trap-1 and trap-2 cases, with and without the rule, 3 runs each = 60 runs ≈ $3): a line `haiku` follows unaided too is cut by the same record and clause; a line it does not follow is kept with that number. Results in `eval-results-4.11.md`; the owner sees the table before any cut (rule 6) | `opus` (≈ $10) — a stronger model following a line unaided says less about the line's worth to a weaker one |
| E15 | The mid-run `plugin-root` window: every `--plugin-dir` session rewrites `~/.claude/shipkit/plugin-root`; the smoke runner restores it, nothing else does (4.7.0; rule 17) | **A `SessionEnd` hook restores it.** `session-start.sh` saves the previous value to `plugin-root.prev` before writing; a new `session-end.sh` (registered in `hooks.json`) writes `.prev` back when the session's root was not the cache's. A `--plugin-dir` session then leaves the owner's path as it found it. Smoke check: start then end from a scratch root → the file holds the saved value. Check first: Claude Code 2.1.291 runs `SessionEnd` hooks for a headless `-p` session (the `claude-code-guide` agent, then one probe) | Leave it to rule 17 and the write-back by hand |
| E16 | The exact refusal text of `.pre-commit-config.yaml` was never captured (`evals/README.md`, "What a case cannot ask for") | **One probe run** on a scratch copy: a case whose prompt asks for `.pre-commit-config.yaml`, `--runs 1 --keep-temp` (≈ $0.15), the `tool_result` text read from the trace and quoted in the README's paragraph; the sandbox removed after | Nothing; the paragraph cites the documentation |
| E17 | A third real run, on the third stack (`field-sprint-plan.md` §5; E11's pattern) | **The owner names a Python project** (the stack `insight` stands for: Celery or FastAPI or Django, a `pyproject.toml`); the loop as the 4.3 and 4.9 runs — setup, product, intake on a request the owner names, spec, one task through `brief.sh` and `brief-verify.sh`, the gate — headless with `--plugin-dir` at the sprint branch, on `shipkit/real-run-3` never for merge; the notes in the 4.3 shape; **nothing found is fixed in this plan**; ≈ $5–8. The run also says whether E1–E7 held on a project that has none of 4.9's shapes | `office_bestie` again (measures E1–E7 on the project that asked for them; the project's own three findings are its own to fix) |
| E18 | Housekeeping, each its own yes at the task that names it | F1 the `4.6.0` and F2 the `4.7.0` directories in `~/.claude/plugins/cache/shipkit/shipkit/` (S17-T5; the owner's interactive session must show "plugin root is …/4.9.0" first); F3 the `shipkit/real-run-3` branch after the notes (S19-T4); F4 branches `sprint-17` to `sprint-19` after each tag; F5 the cache at each `T-REL` | Keep any row |
| E19 | Eval cost per release | Accept 58 → 59 cases (E11's probe, if kept), ≈ $17.50 → ≈ $17.80; every case, every release | `--group` on changed groups only |

---

## 3. What we know, and what we must check

Known at 4.9.0 (Claude Code 2.1.291), from the smoke checks, the traces and Sprint 16:

- Everything the portfolio plan listed, plus: **the `regex` grader is a JavaScript `RegExp`**
  (rule 18); the eval tool grades live and keeps no verdict for a run whose grader threw; a
  regex applied offline through `node` to a trace's `result` row gives the verdict the tool
  gives (the 4.9.0 release run confirmed 18 of 18).
- `eve` finds the registry from the prompt's `SHIPKIT_HOME` line and reads it first in every
  run (27 of 27 traces); she reaches a map only when a grep lands on it; `map_read` counts a
  subagent's `Read` or `Grep` of `PROJECT_MAP.md` and was 1 in exactly the three runs that
  read one.
- The `why` case's map was found by `Grep session` over `projects/pulse` returning the map's
  Evolution lines among the hits (E11 is the question this raises).
- `office_bestie`'s shapes: a tracked `.claude/`, its own five rules beside shipkit's, a
  `CLAUDE.md` with its own `## Elixir-Specific`, a tracked old backup, a test command that
  needs `mise exec --`; 2,855 tests in 13 s through the pin. A clean worktree at `main` on a
  throwaway branch is the right place for a real run; the owner's dirty checkout is never
  touched.
- The gate reads a requirement's "in a release run" as a record it must find (rule 11).
- The reviewer cited `accounts.ex:18-23` for a function at line 605 — the numbers were
  positions inside the diff it read.
- A headless skill that waits on an Agent call can leave "I'll stop here until its
  notification arrives" in its final reply (three of eight sessions on 2026-10-10).
- A smoke check run alone needs its dependencies: check 2 needs check 1's codeword; the
  handoff's runner recipe lists the known ones (19, 20, 25, 26, 30, 35, 39) and now 1 → 2.
- `grandfather/drift` read 2 of 3 in the 4.9.0 release run, 3 of 3 in 4.8.0; the nine-file
  fixture and the elder are unchanged. A watch, with `digest/attention` and `grandfather-xl/drift`.
- The owner's cache holds `4.6.0`, `4.7.0`, `4.9.0`; a session started after the restart
  reports the 4.9.0 root. The interactive session's hook line is the one that counts before
  F1 and F2.
- The room under the eval ceiling is 4,830 bytes: one probe case fits; a second generator
  does not.

To check first, each in the task that needs it:

| Claim | Needed by | If false |
|-------|-----------|----------|
| `install-stack.sh` can see the project's `CLAUDE.md` headings before it appends (it reads the file to find its marker) | S17-T1 | The check moves to `/shipkit:setup`'s SKILL.md text and the installer only prints the headings it found |
| `git ls-files --error-unmatch` on the old backup directory answers tracked/untracked without a git repository error on a project that is not a repository | S17-T2 | No repository → nested as now; the reply says so |
| The ship skill's step 4 can write the reviewer's reply to a file the way step 2 writes test output (the Agent tool's result reaches the skill as text it can `Write`) | S17-T4 | The step pastes from the Agent result directly with "verbatim, every line" and the smoke check holds the gate to it |
| Claude Code 2.1.291 runs a `SessionEnd` hook at the end of a headless `-p` session | S19-T1 | The hook runs on interactive sessions only; the README says so and rule 17's write-back stays for headless runs |
| The reworded `why` question shares no word with the map's Evolution line that `Grep` would land on (checked by `grep -ci` of each noun against the map) | S18-T3 | Reword until it does not; the probe measures what its words allow |

---

## 4. The three sprints at a glance

| Sprint | Release | Name | What the owner gets |
|--------|---------|------|---------------------|
| 17 | 4.10.0 | The run's debts | A setup that sees an existing heading, names a same-named rule and leaves a tracked backup alone; a brief that warns on a dirty tree; setup's files on the always-allowed list; a reviewer that cites file lines and a gate that pastes its reply; the wait sentence closed by record; two cache directories gone |
| 18 | 4.11.0 | Graders and `eve` | `payments` graded on what the question asked; `eve` measured on her guesses, with one sentence if the number says so; the reworded `why` probe; `notebooks` widened on its trace; `react` closed by record; the five kept files measured on a third model, cut or kept by the clause |
| 19 | 4.12.0 | The window and a third project | A session that puts `plugin-root` back; the refusal text captured; shipkit end to end on a Python project; the roadmap for the plan after |

Numbers tracked every sprint:

| Item | Today (4.9.0) | Ceiling |
|------|---------------|---------|
| Three injected rules | 2,979 bytes | 3,000 (E10's sentence is in an agent, not a rule) |
| `plugins/shipkit/evals/` | 191,778 bytes | 196,608 (E11's probe ≈ 1.5 KB; E12 changes no size) |
| Eval cases / cost per release run | 58 / $16.52 | 59 / ≈ $17.80 (E11, E19) |
| Smoke checks | 161 | — |
| Measurement runs this plan, outside the release runs | — | S17 ≈ $1 (two gate dry runs) · S18 ≈ $6 (E9 9 runs ≈ $1.10, E10 9 runs ≈ $1.20, E11 3 runs ≈ $0.45, E12 3 runs ≈ $0.30, E14 60 haiku runs ≈ $3) · S19 ≈ $6–9 (E15 one probe, E16 ≈ $0.15, E17 ≈ $5–8) · ≈ $13–16 in all, plus three release runs ≈ $53 |

---

## Sprint 17 — The run's debts (4.10.0)

**Goal.** Fix what the second real run found in setup, the brief and the gate, each with a
smoke check written first; close the one finding that is the platform's by record; remove the
two cache directories the owner names.

**Branch.** `sprint-17/run-debts`

### S17-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/run-debts/intake.md`, `spec.md`, `design.md`, `tasks.md`;
  add `docs/plans/second-run-sprint-plan.md` (this file, with its approval line).
- **Steps:** intake by hand; the spec with decision records for E1 to E8 and E18 (F1, F2);
  `spec-check.sh . run-debts --as-open` on the draft; the owner approves; stamp at the
  branch-point commit; `Status: open`.
- **Done when:** 0 gaps; the owner's approval is in the thread.

### S17-T1 — The installer sees the heading (E1)
- **Files:** `plugins/shipkit/scripts/install-stack.sh`, `plugins/shipkit/skills/setup/SKILL.md`,
  `scripts/smoke.sh`.
- **Check first:** §3's first claim.
- **Steps:** before appending a stack section, the installer greps `CLAUDE.md` for the
  section's `## ` heading; present → the block is still written under its marker and a line
  is printed for the reply (`install-stack: CLAUDE.md already has "## Elixir-Specific"; the
  shipkit section is below it under its marker — review with /shipkit:update-rules`); the
  setup skill relays the line and shows the diff of the two sections. Smoke check 60: a
  `CLAUDE.md` with the heading → the line, both sections, the marker and sha intact; without
  → one section, no line.
- **Done when:** check 60 → PASS; lint 0/0 (check 14's line limits on the skill).

### S17-T2 — Same-named rules named; a tracked backup left alone (E2, E3)
- **Files:** `plugins/shipkit/scripts/install-rules.sh`, `plugins/shipkit/skills/setup/SKILL.md`,
  `scripts/smoke.sh`.
- **Check first:** §3's second claim.
- **Steps:** `install-rules.sh` lists any `.claude/rules/*.md` whose basename matches a file it
  installs and prints one line naming them; the setup skill's backup phase asks git whether
  the previous backup is tracked before nesting it, and leaves a tracked one in place with
  one line in the reply. Smoke check 61: a project with a same-named rule → the line; with a
  tracked old backup → it stays at the root and `git status --short` is empty after setup;
  with an untracked one → nested as before.
- **Done when:** check 61 → PASS; lint 0/0.

### S17-T3 — The brief warns on a dirty tree; setup's files always allowed (E4, E5)
- **Files:** `plugins/shipkit/scripts/brief.sh`, `plugins/shipkit/scripts/brief-verify.sh`,
  `plugins/shipkit/agents/reviewer.md`, `scripts/smoke.sh`.
- **Steps:** `brief.sh` counts `git status --short` lines and prints the warning to stderr
  when non-zero (stdout, the brief, unchanged); `brief-verify.sh` and the reviewer's text add
  `.claude/rules/shipkit/` and `.shipkit-baseline/` to the always-allowed list, `CLAUDE.md`
  and `.gitignore` still reported. Smoke checks 25 and 26 extended: a dirty tree → the stderr
  line and an unchanged brief on stdout; a change under `.claude/rules/shipkit/` → not
  OUTSIDE; a change to `CLAUDE.md` → OUTSIDE still.
- **Done when:** checks 25 and 26 → PASS; lint 0/0.

### S17-T4 — The reviewer cites file lines; the gate pastes its reply (E6, E7)
- **Files:** `plugins/shipkit/agents/reviewer.md`, `plugins/shipkit/skills/ship/SKILL.md`,
  `plugins/shipkit/skills/ship/reference.md`, `scripts/smoke.sh`.
- **Check first:** §3's third claim.
- **Steps:** one sentence in the reviewer (a MET line cites `path:line` as `grep -n` prints it
  in the tree, never a diff position); step 4 of the ship skill writes the reviewer's reply to
  `$TMPDIR/shipkit-ship-review.out` and pastes it from the file, whole, into the report (the
  file removed with the others at the end, S14-T2). Smoke check: the texts carry both
  sentences; the headless gate dry run on a shipped spec (≈ $0.50, budget S17) produces a
  report whose step 4 holds the reviewer's `VERDICT:` line and every `REQ-N:` line verbatim —
  compared against the review file captured before the gate removed it (`SMOKE_KEEP`-style
  flag on the dry run, or the gate told to keep the file for this run).
- **Done when:** the smoke check → PASS; the dry run's report pastes the reply; lint 0/0
  (check 14's line limits); the `-rerun` report the dry run writes is deleted after reading.

### S17-T5 — The wait sentence, closed by record; two cache directories (E8, E18 F1 F2)
- **Files:** `ROADMAP.md` (and the sprint's `design.md`, which T0 creates).
- **Steps:** the record in `design.md` with the three quotes and the reopen condition; the
  ROADMAP item carries the pointer. F1 and F2 each on the owner's own yes, each only after the
  owner's interactive session's hook line reads `4.9.0`; the commands and their output in the
  commit message; the ROADMAP records each row.
- **Done when:** the record exists; the ROADMAP rows are written; lint 0/0.

### S17-T-REL — Release 4.10.0
Follow "The release task". Budget: two gate dry runs (S17-T4 and the release gate) ≈ $1; the
release run ≈ $16.50.

---

## Sprint 18 — Graders and `eve` (4.11.0)

**Goal.** Act on the three readings the portfolio measurement left and the two grader notes
the releases carried, each on its trace; measure the five kept files on a third model.

**Branch.** `sprint-18/graders-and-eve`

### S18-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/graders-and-eve/` (the four files).
- **Steps:** as S17-T0, with records for E9 to E14 and E19.
- **Done when:** 0 gaps; the owner's approval is in the thread.

### S18-T1 — `payments` graded on what the question asked (E9)
- **Files:** `plugins/shipkit/evals/eve/payments/graders/stripe-twice-insight-none.md`,
  `plugins/shipkit/evals/README.md`, `docs/design/eval-results-4.11.md`.
- **Steps:** the pattern's last lookahead becomes `(Gemfile|mix\.exs|stripe_charge\.rb|billing/stripe\.ex)`,
  checked with `node` against the three 4.9 failing replies quoted in `eval-results-4.9.md`
  (rule 18); the three arms once (the committed plugin and two scratch copies, 9 runs,
  `--keep-temp`); the results document's first table: 4.9's counts beside the new.
- **Done when:** the table has no empty cell; the reading is written after the traces; lint 0/0.

### S18-T2 — `eve` on her guesses: measure, one sentence, measure (E10)
- **Depends on:** S18-T1 (the scratch copies exist).
- **Files:** `plugins/shipkit/agents/eve.md`, `plugins/shipkit/evals/eve/why/graders/`
  (a second, strict grader file kept **unscored** — or the strict wording kept in the results
  document and applied through the scratch copy only, whichever keeps the shipped case at one
  scored grader), `docs/design/eval-results-4.11.md`, `.shipkit/decisions/0001-project-map-default.md`.
- **Steps:** the no-map arm under the strict wording, 3 runs: the baseline (expected 0 of 3);
  the sentence in `agents/eve.md`; the same arm, 3 runs, and the three-map arm, 3 runs. The
  sentence stays if strict ≥ 2 of 3 and three-map 3 of 3; otherwise it comes out in the same
  commit and the record says so. Record 0001's `eve` note gains the line.
- **Done when:** the three cells are filled; the sentence's fate is in the design record; the
  shipped `why` grader is byte-identical to 4.9.0; lint 0/0; **stop:** the owner sees the
  table before the sentence is kept.

### S18-T3 — The reworded `why` probe (E11)
- **Files:** `plugins/shipkit/evals/eve/why-reworded/` (case.yaml, prompt.md, fixture.sh,
  graders/), `plugins/shipkit/evals/README.md`, `docs/design/eval-results-4.11.md`,
  `scripts/evals.sh` (citation comment).
- **Check first:** §3's fifth claim.
- **Steps:** the case on the three-map arm, 3 runs, `--keep-temp`; `map_read` per run; the
  reading says whether the grep-first path found the map without the shared word. Kept as a
  watch if ≥ 2 of 3; otherwise kept too, as the number the plan after starts from, and the
  README says what it watches.
- **Done when:** the cell is filled; evals bytes ≤ 196,608; lint 0/0.

### S18-T4 — `notebooks` widened on its trace; `react` closed by record (E12, E13)
- **Files:** `plugins/shipkit/evals/trap2/notebooks/graders/` (the one regex),
  `plugins/shipkit/evals/README.md`, `docs/design/eval-results-4.11.md`.
- **Steps:** the pattern gains the `json`-script form the 4.8 trace showed (quoted in
  `eval-results-4.8.md`), tested with `node` against that reply's text; one re-run alone (3
  runs); `react` closed in the design record with the two release-run counts.
- **Done when:** `notebooks` ≥ 2 of 3 on the widened pattern with the 4.6 and 4.8 counts
  beside; the record exists; lint 0/0.

### S18-T5 — The five kept files on a third model (E14)
- **Files:** `docs/design/eval-results-4.11.md`, `.shipkit/specs/measured-cuts/design.md`
  (an appended note), and — only on the owner's go — the five rule files and `scripts/smoke.sh`
  (check 58's kept list).
- **Steps:** `EVALS_MODEL=haiku bash scripts/evals.sh --case <name> -j 3 --keep-temp` for the
  ten cases, with the rule (the committed plugin) and without (the 4.6 scratch copy's `sed`),
  60 runs; the table per file; **stop: the owner sees the table before any cut** (rule 6). A
  file whose two lines `haiku` follows unaided 3 of 3 in both arms is cut by the measured-cuts
  record's own clause, in a second commit on the owner's go, its cases staying as the watch;
  a file it does not follow keeps its lines with the number.
- **Done when:** the table has no empty cell; the note is appended to the measured-cuts record;
  any cut has the owner's go in the thread; lint 0/0.

### S18-T-REL — Release 4.11.0
Follow "The release task". Budget: E9 9 runs ≈ $1.10, E10 9 runs ≈ $1.20, E11 3 runs ≈ $0.45,
E12 3 runs ≈ $0.30, E14 60 `haiku` runs ≈ $3, up to two re-runs alone ≈ $1; the release run
at 59 cases ≈ $17.80.

---

## Sprint 19 — The window and a third project (4.12.0)

**Goal.** Close the harness window every `--plugin-dir` session opens; capture the one text the
README quotes from documentation; run the loop a third time, on the third stack; write the
roadmap the plan after starts from.

**Branch.** `sprint-19/third-run`

### S19-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/third-run/` (the four files).
- **Steps:** as S17-T0, with records for E15, E16, E17 and E18 (F3).
- **Done when:** 0 gaps; the owner's approval, with E17's repository path, is in the thread.

### S19-T1 — A session puts `plugin-root` back (E15)
- **Files:** `plugins/shipkit/scripts/session-start.sh`, `plugins/shipkit/scripts/session-end.sh`
  (new), `plugins/shipkit/hooks/hooks.json`, `scripts/smoke.sh`, `plugins/shipkit/evals/README.md`.
- **Check first:** §3's fourth claim (the `claude-code-guide` agent, then one headless probe
  that prints to a file from a `SessionEnd` hook).
- **Steps:** start saves the previous value to `plugin-root.prev` when the root it writes
  differs; end writes `.prev` back and removes it. Smoke check 62: a headless session from a
  scratch root → after it, the file holds the value from before; the smoke runner's own
  restore (S14-T3) stays. Rule 17's write-back line is struck from the plan's text in the
  CHANGELOG, not here.
- **Done when:** check 62 → PASS; lint 0/0.

### S19-T2 — The refusal text, captured (E16)
- **Files:** `plugins/shipkit/evals/README.md`, `docs/design/eval-results-4.12.md`.
- **Steps:** a probe case on a scratch copy (never committed) asks for `.pre-commit-config.yaml`
  at the workspace root; `--runs 1 --keep-temp`; the `tool_result` text read from the trace and
  quoted in "What a case cannot ask for"; the sandbox and the scratch copy removed.
- **Done when:** the README quotes the text (or says the trace held none, and what it held
  instead); lint 0/0.

### S19-T3 — The third real run (E17)
- **Files:** `docs/design/field-notes-4.12.md`, `ROADMAP.md`.
- **Steps:** in the repository the owner named, a worktree at its default branch on
  `shipkit/real-run-3` (never for merge), with `claude --plugin-dir "<this checkout>/plugins/shipkit"`
  at this sprint's branch: the steps of `field-notes-4.9.md` in order — the hook, setup,
  product, intake on one real request the owner names, spec, one task through `brief.sh`
  (rule 19: a clean tree at hand-over) and `brief-verify.sh`, the gate — each written as
  Asked for / Produced / Took / Awkward / Whose fault / Evidence; `git status` before the
  first step; whether E1 to E7 held, one line each. **Nothing found is fixed in this plan.**
  The branch and worktree deleted after the notes, on F3's own yes, the log read first.
- **Done when:** the notes have every step with its six parts; the ROADMAP's open list has one
  item per finding, each citing a section; the branch's fate is recorded; lint 0/0. ≈ $5–8.

### S19-T4 — The roadmap for the plan after
- **Files:** `ROADMAP.md`.
- **Steps:** Sprints 17–19 marked shipped in a table as the portfolio plan's; "Still open after
  Sprint 19" = the third run's findings, S18's readings that named something (E10's sentence
  fate, E11's number, E14's kept lines), and anything the three releases' "What using it for
  real showed" sections name; every item cites a file and section.
- **Done when:** lint 0/0; every open item names a file and section.

### S19-T-REL — Release 4.12.0
Follow "The release task". Budget: E15 one probe ≈ $0.10, E16 ≈ $0.15, E17 ≈ $5–8; the
release run at 59 cases ≈ $17.80.

---

## 5. What this plan does not do

- It does not change `agents/grandfather.md`, step 0 or decision 0001's standing (the map is
  optional). It changes `agents/eve.md` by one sentence and only if E10's number says so, and
  `agents/reviewer.md` by one sentence (E6).
- It does not add a skill. It changes the text of three skills (`setup`, `ship`, and `ask`
  only if E8's other option is chosen), four scripts in the plugin (`install-stack.sh`,
  `install-rules.sh`, `brief.sh`, `brief-verify.sh`), two hooks (E15), and two graders (E9,
  E12).
- It does not cut a rule line without a third measurement (E14) and the owner's go; it does
  not touch the six files whose cases separated.
- It does not fix what the third real run finds (E17), nor the three findings that are
  `office_bestie`'s own.
- It does not change `digest/attention`, `grandfather-xl/drift` or `grandfather/drift`; their
  shape under `-j 4` is recorded.
- It does not delete anything E18 does not name, and nothing in E18 without its own yes.

## 6. Risks, and what we do about each

| Risk | What we do |
|------|-----------|
| The installer cannot tell the project's heading from one shipkit wrote in an earlier run (E1) | The marker and `.section-<stack>.sha` identify shipkit's own; a heading without the marker is the project's |
| `SessionEnd` does not fire for headless sessions (E15) | The Check first; the README records which sessions restore and rule 17 stays for the rest |
| The gate's pasted reviewer reply makes the report long (E7) | The report is evidence, not prose; `gate-blind-spots` REQ-9 asked for twenty lines pasted and got one — long is the fix |
| E10's sentence lowers the three-map `why` (eve says "not recorded" with the map in hand) | The three-map arm is re-run with the sentence; a drop below 3 of 3 removes it in the same commit |
| The reworded probe fails because the map was never read, not because `eve` answered wrong (E11) | That is the finding; `map_read` per run says which, and the reading says so; no sentence in this plan |
| `haiku` follows the five kept files' lines unaided and the owner does not want them cut (E14) | The stop before any cut; the record can say "kept as a standard on the owner's word" as E1 did in 4.8.0 |
| The third project's test command, toolchain or layout costs the run its time (E17) | As 4.3 and 4.9: the project's own way is found, recorded under "Whose fault: the project's", and the Done-when is given to every headless step as the command that works |
| The owner's interactive session runs the plugin from the cache while a sprint edits `plugins/` | The cache is a copy (4.9.0 now); the checkout's edits do not reach it until F5 |
| Three releases at ≈ $17.50 each plus ≈ $16 of measurement | Stated in §4; every run outside a budget line needs the owner's yes (rule 15) |

## 7. Approval

To approve: reply with "approved", or with the IDs from section 2 you want changed (for example
"approved, but E8: the sentence; E14: opus; E17: ~/code/<project>"). E17 needs the repository's
path either way, by S19-T0 at the latest. Work starts with S17-T0 on the branch
`sprint-17/run-debts`.
