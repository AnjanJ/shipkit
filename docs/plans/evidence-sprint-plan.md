# Shipkit sprint plan — from quality gate to evidence

> Status: **APPROVED by the owner on 2026-10-06** — B1 to B13 accepted with their recommended defaults.
> Written 2026-10-06 against shipkit 4.0.0 at commit `598464a` on `main`.
> Follows [`quality-gate-sprint-plan.md`](quality-gate-sprint-plan.md), whose seven sprints
> shipped as 3.2.0 to 4.0.0. Section 1 of that plan is the rulebook; it is repeated here so this
> file stands alone.

**The goal in one sentence.** Every standing claim shipkit makes about itself — "the map is
worth keeping", "this rule line changes what Claude does", "the spec-first habit holds" — gets a
number behind it, and the one claim that has been owed a number since Sprint 1 is settled first.

**What changes.** Three sprints. Each sprint is one release. Nothing is removed from shipkit in
this plan; one default (the project map) may become optional if its own re-test says so, and
nothing is deleted without a separate yes.

**Why this and not more features.** The last plan built a loop (product → intake → spec → brief
→ build → review → ship → escape → digest) and used it seven times on shipkit itself. Its own
field notes name three things it did not measure: what the map buys on a real-sized codebase
(decision 0001), whether any rule line changes the result (trim-audit criterion (c)), and why
the spec-first eval holds one run in ten. Adding features on top of unmeasured claims is how
the 11,867-byte rules happened. Measure first; the measurements tell us what to build next.

---

## 1. How to follow this plan

Read this section before every task. These rules apply to a human and to an agent equally.

1. **Do tasks in order.** Inside a sprint, do `T0`, then `T1`, then `T2`, and so on. Do not skip.
   Do not start a sprint until the sprint before it is merged.
2. **One task, one commit.** The test and the code for a task go in the same commit. Write the
   check first and watch it fail.
3. **One sprint, one branch, one pull request.** Branch name: `sprint-N/<short-name>`.
   Branch from `main`. Never commit to `main` directly.
4. **A task is done only when every line under "Done when" is true.** Run each command. Read the
   output. If you did not run it, it is not done.
5. **Edit only the files listed under "Files".** If you need another file, stop and say why. When
   the owner approves, add it to the task's Files line in `tasks.md` in the same commit.
6. **Stop and ask the owner when any of these happen:**
   - a "Done when" check still fails after three honest attempts;
   - a "Check first" step fails and its written fallback also fails;
   - you are about to delete a file, a branch, a worktree, or a shipped skill;
   - a measurement comes out on the side that changes a shipped file (S8-T3, S9-T4) — the
     owner says go before the change is made;
   - you think this plan is wrong. Say what is wrong. Do not quietly do something else.
7. **Never do these:** `git add .` or `git add -A`; `--no-verify`; force-push; amend a pushed
   commit; add a `Co-Authored-By` line; stage `.env`, keys or tokens; push to `main`.
8. **Commit messages** follow `plugins/shipkit/rules/shipkit.md` (What / Why / How / Test plan).
9. **Use shipkit to build shipkit.** Each sprint writes its intake and spec with the shipped
   skills (by hand from their `SKILL.md`, or headless — the installed plugin may be older than
   the tree), hands at least one task to an agent with `brief.sh`, and passes `/shipkit:ship`
   before release. What is awkward goes in the pull request under "What was awkward".
10. **Eval results are read from traces, not summaries.** A case that fails is re-run with
    `--runs 1 --keep-temp` and its `trace.jsonl` read before anything is changed. A pass that
    exists because the model worked around a bug (it once wrote itself a `mktemp` shim) is a
    failure.
11. **Requirements describe the product.** "The report says READY" and "the version is bumped"
    are release steps, never a `REQ-N`. Both 4.0.0 gates failed first on this.

### The sprint exit checklist (same for every sprint)

Run these, in this order, on the final tree, before opening the pull request. All must pass.

| # | Command | Must show |
|---|---------|-----------|
| 1 | `bash scripts/lint.sh` | `0 error(s), 0 warning(s)` |
| 2 | `sh scripts/smoke.sh </dev/null` | `smoke: all checks passed` (109 checks at 4.0.0; ~10 min; needs a logged-in `claude`) |
| 3 | `bash scripts/evals.sh -j 4` | no case that passed before now fails; `rules/nontrivial` is the accepted known result until S9-T5 settles it |
| 4 | `sh plugins/shipkit/scripts/spec-check.sh .` | exit status 0, 0 gaps |
| 5 | `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md \| wc -c` | at most 3000 (2,996 today; measured on the pristine tree, never a smoke scratch copy) |
| 6 | `find plugins/shipkit/evals -type f -print0 \| xargs -0 cat \| wc -c` | at most 102400 (51,525 today — decision A9 of the last plan) |

### The release task (the last task of every sprint, written `T-REL`)

1. **Before the gate:** set the new version in all five places (`plugins/shipkit/.claude-plugin/plugin.json`,
   `plugins/shipkit-workflows/.claude-plugin/plugin.json`, three `version` fields in
   `.claude-plugin/marketplace.json`); add the `## [X.Y.Z] — <date>` CHANGELOG entry with a
   "What using it for real showed" section; fix the counts in `README.md`; update the ROADMAP's
   `**Status` line (the lint insists). Commit this first — the gate reads the changelog.
2. **Run the gate** headless on the branch:
   ```sh
   claude --plugin-dir "$PWD/plugins/shipkit" --model sonnet \
     --allowedTools Read Glob Grep Bash Write Skill Agent \
     -p "/shipkit:ship <slug>
   This run is not interactive and you cannot ask me anything. This repository's test command
   is: bash scripts/lint.sh && sh plugins/shipkit/scripts/spec-check.sh .
   Do not change the spec's Status line." </dev/null
   ```
   Fix what it finds. Commit the `READY` report with the spec's `Status: shipped`. Check the
   report for absolute paths.
3. Run the sprint exit checklist on the final tree.
4. Push (if the SSH agent refuses, retry once, then ask the owner). Open the pull request with a
   "What was awkward" section. Wait for `gh pr checks <n>` to read pass. Merge with a merge
   commit. Tag `vX.Y.Z`.
5. Do not delete the branch unless the owner says so (B11 covers the old ones).
6. Give the owner a short sprint report: what shipped, what the checks showed, what was awkward,
   what was skipped and why.

### Words used in this plan

| Word | Meaning |
|------|---------|
| Owner | Anjan. The only person who approves. |
| Executor | Whoever is doing the task: a person or an agent. |
| Spec | A folder `.shipkit/specs/<slug>/` holding `spec.md`, `design.md`, `tasks.md`, in the checked format of `skills/spec/reference.md`. |
| REQ | One numbered requirement in a spec, for example `REQ-3`. |
| Core | The `plugins/shipkit/` plugin. |
| Arm | One condition in a comparison: *with the map*, *without the map*, *plugin off*, *with the rule*, *without the rule*. |
| XL fixture | The generated 200+ file project of S8-T1, as opposed to the nine-file `sample-app`. |
| Case | One eval under `plugins/shipkit/evals/<group>/<name>/`. A case passes when 2 of 3 runs pass. |
| Check first | A short experiment that proves a platform feature works before we build on it. |

---

## 2. Decisions the owner must approve

Each line has a recommended default. Approve all, or change any by ID.

| ID | Decision | Recommended default | The other option |
|----|----------|---------------------|------------------|
| B1 | Order and releases | Three sprints: 4.1.0 (map re-test), 4.2.0 (one eval per rule file), 4.3.0 (loose ends and a real run) | Stop after Sprint 8 and re-plan on its numbers |
| B2 | The XL fixture | Generated at scaffold time by one deterministic stdlib-Python script (≤ 12 KB) committed under `evals/fixtures/`; it writes ≥ 200 files and ≥ 25 commits; nothing generated is committed | Commit the generated tree (breaks the 100 KB eval budget, A9) |
| B3 | When to act on 0001 | If the re-test falls on the "optional" side, Sprint 8 makes the map optional in the same release (S8-T4, after the owner's go) | Record the result in 4.1.0; change the default in a later sprint |
| B4 | What "optional" means | The elders use a map when one exists and go to the source when none does; `/shipkit:setup`, README and GUIDE stop presenting `/shipkit:map` as the first step and offer it instead; the stale-map nag stays (it only fires when a map exists). `archivist`, `/shipkit:map` and `eve`'s registry are untouched | Also silence the nag |
| B5 | Which rules get an eval | All 15 rule files without one: the 5 path-scoped core rules and the 10 stack rules. The 3 always-on rules already have `rules/{nontrivial,trivial,decision}` | Only the 5 core rules; stacks later |
| B6 | Criterion (c) for the 4.0 trims | Run each new rule case a third time against the rule's **pre-trim text from `v3.7.0`**, so the trim audit's unmeasured column gets its number (~$8 once) | Skip; criterion (c) applies only to future trims |
| B7 | Eval cost per release | `scripts/evals.sh` keeps running every case before a release: 15 → 35 cases, about $4.80 → about $13 | Add `--group` and run only the groups whose files changed |
| B8 | `rules/nontrivial` | At most three one-sentence changes to the always-on rules, each paid for within the 3,000 bytes and judged by three runs; if none reaches 2 of 3, decision record 0002 accepts the result as the rules' honest range | Accept now without the experiment |
| B9 | Overlay skills (split design §5 item 6) | Decide by record (0003); recommended: they stay in core, because they install knowledge, which is the dividing rule | Move them to `shipkit-workflows` — breaking, so 4.3.0 becomes 5.0.0 |
| B10 | A real run | Sprint 10 runs the whole loop once on a repository the owner names (not shipkit); its field notes seed the plan after this one | Skip; keep dog-fooding on shipkit only |
| B11 | Delete the seven merged `sprint-N/*` branches, local and on GitHub | Yes, in S10-T4, after `v4.1.0` and `v4.2.0` are tagged | Keep them |
| B12 | Delete the 48 sealed eval sandboxes under `/private/tmp/e-*` | Yes, in S10-T4 — but **not before** S8-T2 has used them to check the trace counter (they are the only free traces) | Keep them |
| B13 | Remove the detached worktree `.claude/worktrees/agent-a4a4658de35627a13` (at `d666c27`, merged) | Yes, in S10-T4 (`git worktree remove`) | Keep it |

B11 to B13 are each their own yes, per the last plan's A8: nothing is deleted on a blanket
approval.

---

## 3. What we know about the platform, and what we must check

Known from the last plan (all still true at Claude Code 2.1.289, verified by smoke checks):

- `claude plugin eval` runs cases from `plugins/shipkit/evals/`, each with a scaffold script
  that builds the fixture in the run's empty workspace; `--ablation with-without` adds a
  plugin-off arm; graders can check tool calls and written files; **no custom-code graders**.
- Eval runs start with a temporary `HOME` and deny writes to the system temp dir; a bare
  `mktemp` fails there (lint check 14).
- Rules load from a project's `.claude/rules/`, never from the plugin; the three always-on rules
  arrive through the session hook.
- A run's `out/trace.jsonl` carries `tool_use` rows and per-message `usage` blocks (seen in the
  sealed sandboxes on this machine).

Reported or assumed, **not yet tested here**. Each has a "Check first" step in the task that
needs it:

| Claim | Needed by | If it turns out false |
|-------|-----------|-----------------------|
| An environment variable set on the `claude plugin eval` command reaches the scaffold script | S8-T2 (the no-map arm) | Run the arm from a scratch copy of the plugin whose scaffold passes `--no-map`, as 3.2 did |
| `--ablation with-without` works on a case whose fixture is generated, not copied | S8-T3 | Run the plugin-off arm by hand with `--plugin-dir` omitted and count from traces |
| The trace's `usage` blocks let a script total the **main session's** input tokens separately from the subagent's | S8-T2 | Count tool calls only; say context cost is still unmeasured |
| A path-scoped rule under the fixture's `.claude/rules/shipkit/` loads inside an eval sandbox when the prompt edits a matching path | S9-T1 | Inject the rule's text through a `CLAUDE.md` the scaffold writes, and say the measurement is of the text, not the loading |
| The scaffold script, which runs from the plugin's own directory, can run `git show v3.7.0:…` against this repository | S9-T4 (B6) | Keep a copy of the 3.7.0 rule text under `evals/fixtures/rules-3.7/` for the measurement only, and delete it in the same sprint |

**One design rule that follows from this:** a scaffold script is the only thing that may put
files into a run's workspace. Nothing in a prompt may ask the model to fetch, download or
reconstruct a fixture.

---

## 4. The three sprints at a glance

| Sprint | Release | Name | What the owner gets |
|--------|---------|------|---------------------|
| 8 | 4.1.0 | The map on trial | A 200-file fixture with a history; the re-test decision 0001 asked for; the map's default settled by its own clause |
| 9 | 4.2.0 | One eval per rule | Every rule file has a case that shows whether it changes the result, and the 4.0 trims get their missing number; the spec-first eval is fixed or formally accepted |
| 10 | 4.3.0 | Loose ends and a real run | The gate's first-run misses caught earlier; the overlay-skill question closed; the loop run once on a real repository; the merged branches gone |

Numbers tracked every sprint:

| Item | Today (4.0.0) | Ceiling |
|------|---------------|---------|
| Three injected rules | 2,996 bytes | 3,000 |
| `plugins/shipkit/evals/` | 51,525 bytes | 102,400 |
| Eval cases / cost per release run | 15 / ≈ $4.80 | 35 / ≈ $13 (B7) |
| Smoke checks | 109 | — |

---

## Sprint 8 — The map on trial (4.1.0)

**Goal.** Run the re-test decision 0001 asked for, on a fixture where a map could plausibly
help, and let the record's own clause decide the map's default.

**Branch.** `sprint-8/map-on-trial`

**What the record says.** Measured on nine files, the map bought nothing (12 of 12 correct with
and without; 49 tool calls against 51). The record's addition: *re-run on a fixture of at least
200 files with one question about how the project evolved; restore the map as the default if,
there, it gives at least one more correct answer or at least 20% fewer tool calls.* The map has
stayed the default pending that run. This sprint is that run.

### S8-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/map-on-trial/intake.md`, `spec.md`, `design.md`, `tasks.md`.
- **Steps:**
  1. Write the intake by hand from `plugins/shipkit/skills/intake/SKILL.md`.
  2. Copy each "Done when" line of S8-T1 to S8-T4 into `spec.md` as one EARS requirement. The
     requirements describe the fixture, the cases, the counter and the comparison — never the
     outcome, the gate or the release.
  3. In `design.md`, write one decision record for each of: the generated fixture (B2), acting
     in the same sprint (B3), what optional means (B4).
  4. In `tasks.md`, list S8-T1 to S8-T4 in the checked format, each citing its requirements.
  5. Show the requirements to the owner. Wait for a yes.
- **Done when:** the four files exist; the owner has said yes; `spec.md` carries
  `> Status: open` and `> Spec accepted at commit <sha> on sprint-8/map-on-trial.`;
  `sh plugins/shipkit/scripts/spec-check.sh .` → 0 gaps.

### S8-T1 — The XL fixture generator
- **Why:** the record says the nine-file fixture measures the map where it helps least.
- **Files:** create `plugins/shipkit/evals/fixtures/ledger-gen/generate.py`,
  `plugins/shipkit/evals/fixtures/FACTS-XL.md`; edit `scripts/smoke.sh`,
  `plugins/shipkit/evals/README.md`.
- **Steps:**
  1. Write `generate.py` (Python 3 standard library only, deterministic — no clock, no random
     without a fixed seed). Run in an empty directory it writes a plain-Python service,
     *ledger*, of **at least 200 files** across at least eight packages (for example `app/{api,
     auth,billing,inventory,jobs,notifications,orders,reports}/`, mirrored `tests/`, `docs/`,
     `migrations/`), then builds a git history of **at least 25 commits** whose messages tell a
     story. Each commit must change real files; the generator makes them in order.
  2. Plant five facts and write them in `FACTS-XL.md` with file, line and, for XL5, the commit:
     - **XL1 (lookup):** the job retry cap is 7, set in one place; two other modules mention a
       `MAX_RETRIES` that is dead code or a different limit — decoys a one-shot grep must get past.
     - **XL2 (explain):** VAT is applied by `apply_vat` in `app/billing/tax.py`, called from one
       place in `app/orders/checkout.py`; a similarly named `estimate_vat` in `app/reports/`
       is not on the path.
     - **XL3 (drift):** the map says inventory counts are cached in Redis; the code uses an
       in-process dict in `app/inventory/cache.py`. **The map is wrong on purpose.**
     - **XL4 (gap):** nothing in the project says which email provider sends notifications.
       **There is no answer.** `app/notifications/` talks to an abstract `Mailer`.
     - **XL5 (history):** order storage moved from a JSON file to SQLite; the commit that did it
       says why (concurrent writers corrupted the file), and a later commit added the WAL
       pragma. The map's *Evolution* section records this in two sentences. Without a map, the
       answer is in `git log`, nowhere in the current source.
  3. Write the fixture's `PROJECT_MAP.md` in the archivist's format, correct except for XL3,
     with an *Evolution* section that covers XL5. `generate.py --no-map` writes everything but
     the map (same history; the map is never committed to the fixture's git history, so both
     arms have identical commits).
  4. Add a smoke check `ledger-gen`: generate twice into two scratch directories; `diff -r
     --exclude=.git` is empty; file count ≥ 200; `git rev-list --count HEAD` ≥ 25;
     `grep -rl Redis` matches only `PROJECT_MAP.md`; `grep -rn "email provider\|sendgrid\|
     postmark\|ses" -i` matches nothing; `--no-map` leaves no `PROJECT_MAP.md`. Write the check
     first and watch it fail.
  5. Describe the generator and the five facts in `evals/README.md`.
- **Done when:** the `ledger-gen` smoke check → PASS; `wc -c generate.py` ≤ 12288; the exit
  checklist's line 6 (evals bytes) ≤ 102400; `python3 -m py_compile generate.py` is clean;
  `bash scripts/lint.sh` → 0/0.
- **Do not:** commit anything the generator writes; use any third-party package; make the
  history depend on the current date (fix author dates with `GIT_AUTHOR_DATE`/`GIT_COMMITTER_DATE`).

### S8-T2 — Five XL cases and a trace counter
- **Depends on:** S8-T1.
- **Files:** create `plugins/shipkit/evals/grandfather-xl/{lookup,explain,drift,gap,history}/`
  (`prompt.md`, `case.yaml`, `fixture.sh`, `graders/*.md`), `scripts/trace-tools.sh`; edit
  `scripts/evals.sh` (the citation comment only), `plugins/shipkit/evals/README.md`,
  `scripts/smoke.sh`.
- **Check first (env var):** in one existing case's `fixture.sh`, print `$SHIPKIT_EVAL_PROBE` to
  a file; run `SHIPKIT_EVAL_PROBE=nonce claude plugin eval … --case hello --runs 1 --keep-temp
  --scaffold`; read the file in the kept sandbox. Revert the probe. If the nonce does not
  arrive, use the fallback in section 3 for the no-map arm and say so in the README.
- **Check first (trace):** open a `trace.jsonl` from a sealed sandbox under `/private/tmp/e-*`.
  Confirm `tool_use` rows can be counted and `usage.input_tokens` summed, and whether the
  subagent's messages are distinguishable from the main session's. Record what you find in the
  script's header comment.
- **Steps:**
  1. Write one case per fact, each `fixture.sh` running `generate.py` (with `--no-map` when
     `SHIPKIT_EVAL_NO_MAP=1`) and `git init`-ing nothing — the generator makes the history.
     Prompts begin `/shipkit:ask`. Same grader style as `grandfather/*`:

     | Case | Question | Passes when the answer… |
     |------|----------|-------------------------|
     | `lookup` | Where is the job retry cap set? | names the one live file and the number 7 |
     | `explain` | How is VAT applied at checkout? | names `apply_vat`, `app/billing/tax.py` and the call in `checkout.py` |
     | `drift` | Where are inventory counts cached? | says an in-process dict in `app/inventory/cache.py` **and** says the map is wrong or out of date (**without a map this case cannot pass; that is expected and recorded, as in 3.2**) |
     | `gap` | Which email provider sends our notifications? | says it could not find or confirm one and names no provider |
     | `history` | Why did we move order storage off the JSON file, and when? | names the concurrent-writer corruption and identifies the commit (hash, message or ordinal) |

  2. Write `scripts/trace-tools.sh <output-dir>`: for every run under the directory, print one
     line — case, run, tool calls (total and, if distinguishable, main session alone), input
     tokens (same split), and the `Agent` call count. POSIX `sh` plus `python3` for the JSON.
     Add a smoke check that runs it on a sealed sandbox's trace and compares the tool-call count
     with `grep -c '"type":"tool_use"'` on the same file.
  3. Run `bash scripts/evals.sh --case 'grandfather-xl-*'`. Record passes under "Baseline 4.0.0
     (XL)" in `evals/README.md`. **A failing case is an acceptable result — record it, do not
     bend the grader.**
- **Done when:** `bash scripts/evals.sh --case 'grandfather-xl-*'` runs all five and prints a
  pass or fail for each; the `trace-tools` smoke check → PASS; `sh -n scripts/trace-tools.sh`
  is clean; the README has the baseline row and both Check-first answers.

### S8-T3 — The comparison, and what the record says now
- **Depends on:** S8-T2.
- **Files:** create `docs/design/eval-results-4.1.md`; edit
  `.shipkit/decisions/0001-project-map-default.md`.
- **Check first:** `--ablation with-without` on one XL case with `--runs 1`. If the plugin-off
  arm does not scaffold, use the section 3 fallback.
- **Steps:**
  1. Three arms, five cases, three runs each: with the map (plugin on); without the map (plugin
     on, `SHIPKIT_EVAL_NO_MAP=1` or the fallback); plugin off (map present). `--keep-temp`
     on every run. Budget: about 45 runs, roughly $12 at list price — say the real figure.
  2. Count with `scripts/trace-tools.sh`, never from the eval summary.
  3. Write `eval-results-4.1.md` in the shape of `eval-results-3.2.md`: what was run, the
     three-row table (cases passed, runs passed, tool calls, tool calls per run, input tokens if
     measured, cost), the per-case table, "How to read these numbers", "What this does not
     show", "Reproduce".
  4. Append a section **"Re-test (4.1.0)"** to decision 0001: the two numbers the clause asks for
     (one more correct answer? ≥ 20% fewer tool calls?), which side they fall on, and the new
     status line at the top: `Status: re-tested on 2026-10-NN — the map stays the default` or
     `… — the map becomes optional (S8-T4)`. The `drift` case counts as in 3.2: a pass that
     exists only because the map contains a planted error is not counted as "one more correct
     answer"; `history` is counted at face value, because the answer exists in the history
     either way.
  5. **Stop and show the owner the two tables and the status line.** The clause decides; the
     owner says go on S8-T4's branch.
- **Done when:** the three-row table has no empty cell; every per-case cell has three
  tool-call counts; the record's status line names a side; **no shipped file changed in this
  task** (`git diff --stat main -- plugins/` shows nothing from this task).

### S8-T4 — Act on the outcome
Two written branches. Only the one the clause and the owner selected is executed; the other is
noted as not taken in `tasks.md`.

**Branch A — the map stays the default.**
- **Files:** edit `README.md`, `ROADMAP.md`, `.shipkit/decisions/0001-project-map-default.md`.
- **Steps:** remove the "pending re-test" language; the ROADMAP's "Still open" list drops the
  item; the record is marked closed with the date.
- **Done when:** `grep -rn "re-test\|not yet acted" README.md ROADMAP.md` matches nothing;
  lint 0/0.

**Branch B — the map becomes optional (B4).**
- **Files:** edit `plugins/shipkit/skills/setup/SKILL.md`, `plugins/shipkit/agents/grandfather.md`,
  `plugins/shipkit/agents/eve.md`, `plugins/shipkit/skills/map/SKILL.md`, `README.md`,
  `GUIDE.md`, `ROADMAP.md`, `.shipkit/decisions/0001-project-map-default.md`, `scripts/smoke.sh`,
  `scripts/lint.py`. Anything else → stop and ask.
- **Steps:**
  1. Lint check 17, written first: no file under `plugins/shipkit/skills/setup/`, `README.md` or
     `GUIDE.md` tells the user to build a map as a required or first step (a short list of
     phrases, maintained in the check; "optional" and "when you have one" are fine). Watch it
     fail on the current tree.
  2. `setup`: the map step becomes an offer with the trade-off in one sentence (what it costs to
     keep fresh; when it is worth it — large or old codebases, portfolio questions via `eve`).
  3. `grandfather` and `eve`: the first step reads "if `PROJECT_MAP.md` exists, read it as an
     index; otherwise go to the source". Keep "verify against live source" exactly as it is.
  4. `map` skill: unchanged in behaviour; its description says when a map earns its keep.
  5. README and GUIDE: the map is described as an option with the number from
     `eval-results-4.1.md` beside it. ROADMAP's "Still open" drops the item.
  6. Smoke check: the session hook in a project with no map and an open spec prints no map
     line and still prints the briefing. (If a check with this shape exists, extend it.)
  7. Record 0001: status closed; a one-line "What changed" pointing at this release.
- **Done when:** lint check 17 passes on the new tree and is shown failing on the old one in the
  commit's test plan; smoke → all pass; `bash scripts/evals.sh --case 'grandfather*'` passes
  every case that passed in S8-T2 (`drift` excepted when run without a map); the always-on
  bytes are unchanged (this task does not touch the three rules).
- **Do not:** delete or rename the archivist, `/shipkit:map`, the hook's map nag, or any
  registry column; silence the nag (B4's other option).

### S8-T-REL — Release 4.1.0
Follow "The release task" in section 1. The CHANGELOG's "What using it for real showed" must
say in one paragraph what the XL fixture showed that the nine-file one could not.

---

## Sprint 9 — One eval per rule (4.2.0)

**Goal.** Give every rule file a case that shows whether it changes what Claude does, measure
the 4.0 trims against the pre-trim text, and settle the one eval that has sat at one run in ten
since 3.1.0.

**Branch.** `sprint-9/rule-evals`

**The design in one paragraph.** A rule's case is a prompt that walks into the trap the rule
names, inside a fixture whose paths match the rule's `paths:` globs, with a grader that checks
the trap was avoided. The scaffold installs the rule into the fixture's `.claude/rules/shipkit/`
exactly as `/shipkit:setup` would (`install-rules.sh` / `install-stack.sh`), or omits it when
`SHIPKIT_EVAL_NO_RULE=1`, or installs the `v3.7.0` text when `SHIPKIT_EVAL_RULE_REF=v3.7.0`.
Three arms per case; the with-rule arm is what `scripts/evals.sh` runs before every release.

### S9-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/rule-evals/intake.md`, `spec.md`, `design.md`, `tasks.md`.
- **Steps:** as S8-T0. Decision records for: which rules (B5), the pre-trim arm (B6), cost per
  release (B7), the nontrivial experiment's stopping rule (B8).
- **Done when:** as S8-T0, on `sprint-9/rule-evals`.

### S9-T1 — The rule harness and the stack mini-fixtures
- **Files:** create `plugins/shipkit/evals/lib/with-rule.sh`,
  `plugins/shipkit/evals/fixtures/stack-gen.sh`; edit `scripts/evals.sh`, `scripts/smoke.sh`,
  `plugins/shipkit/evals/README.md`.
- **Check first (rule loads in the sandbox):** scaffold `sample-app` plus a one-line path-scoped
  rule under `.claude/rules/shipkit/probe.md` (`paths: ["app/**"]`) whose body says "begin
  every reply with the word NONCE-7". Prompt: "add a comment to app/orders.py". If the reply
  does not begin with the nonce, use the section 3 fallback (the rule text goes into a
  scaffold-written `CLAUDE.md`) and say in the README that the measurement is of the text.
- **Steps:**
  1. `with-rule.sh <rule-name>`: called by a case's `fixture.sh` after the fixture is in place.
     Resolves the rule file (`rules/<name>.md` or `stacks/<stack>/…`), copies it through the
     same substitution the installer uses, honours `SHIPKIT_EVAL_NO_RULE` and
     `SHIPKIT_EVAL_RULE_REF` (`git -C <repo> show <ref>:<path>`; **Check first** that the
     scaffold's working directory lets it find the repo — else the section 3 fallback).
     Explicit `mktemp` templates only.
  2. `stack-gen.sh <stack>`: writes the smallest project that matches the stack rule's `paths:`
     globs — three to six files, no toolchain needed (nothing is run; the model edits, the
     grader reads). One function per stack; ≤ 15 KB in all.
  3. `scripts/evals.sh --group <name>`: runs only `evals/<name>/`. Keep the script short; the
     default (no flag) still runs everything (B7).
  4. Smoke checks: `with-rule` installs a rule and the file carries the installer's version
     stamp; `SHIPKIT_EVAL_NO_RULE=1` installs nothing; `stack-gen.sh rails` produces files
     matching every glob in the Rails rule's `paths:` (loop over the ten stacks).
- **Done when:** the three smoke checks → PASS for all ten stacks; `sh -n` clean on both
  scripts; lint 0/0; evals bytes ≤ 102400; the Check-first answer is in the README.

### S9-T2 — Cases for the five path-scoped core rules
- **Depends on:** S9-T1.
- **Files:** create `plugins/shipkit/evals/rules-scoped/{dependencies,migrations,monorepo,
  testing,ui-ux}/`; edit `plugins/shipkit/evals/README.md`, `scripts/evals.sh` (citation comment).
- **Steps:** for each rule, read the file, take its **first named trap** as the probe, and write
  the case so the prompt walks into exactly that trap in `sample-app` (or a stack-gen project
  when the rule's globs need one). Put the trap and the rule line it comes from in the case's
  `description:`. Graders: `regex`/`llm` on the reply and, where the trap is about a file,
  `target: { source: file }` on the file written. Run each case three times with the rule
  installed; record under "Baseline 4.0.0 (rules-scoped)".
- **Done when:** `bash scripts/evals.sh --group rules-scoped` runs five cases and prints a
  result for each; every case's `description:` names the rule file and the line it probes.

### S9-T3 — Cases for the ten stack rules
- **Depends on:** S9-T1.
- **Files:** create `plugins/shipkit/evals/stacks/{elixir,go,hotwire,liveview,ml,oban,python,
  rails,react,static}/`; edit `plugins/shipkit/evals/README.md`, `scripts/evals.sh`.
- **Steps:** as S9-T2, one case per stack rule, fixture from `stack-gen.sh`. Record the
  baseline.
- **Done when:** `bash scripts/evals.sh --group stacks` runs ten cases and prints a result for
  each; evals bytes ≤ 102400.

### S9-T4 — Measure: with, without, and before the trim
- **Depends on:** S9-T2, S9-T3.
- **Files:** create `docs/design/eval-results-4.2.md`; edit `docs/design/trim-audit-4.0.md`
  (append-only: a new section, the approved rows are not rewritten), `ROADMAP.md`.
- **Steps:**
  1. Fifteen cases × three runs × three arms (with the rule; `SHIPKIT_EVAL_NO_RULE=1`;
     `SHIPKIT_EVAL_RULE_REF=v3.7.0`, B6). About 135 runs, roughly $20 — say the real figure.
     `--keep-temp`; counts from `scripts/trace-tools.sh`.
  2. `eval-results-4.2.md`: a fifteen-row table — rule, runs passed with / without / pre-trim,
     tool calls per run for each. Below it, the three readings that matter: rules whose case
     passes equally without them (the rule may be dead weight or the case too easy — say which
     you believe and why, from the traces); rules whose pre-trim text scores higher than the
     4.0 text (a trim that cost something); rules whose case fails even with the rule installed
     (the rule does not do what it says).
  3. Append "Criterion (c), measured in 4.2.0" to `trim-audit-4.0.md`: one line per trimmed
     file with its two numbers. ROADMAP's "Still open" drops criterion (c).
  4. **Stop and show the owner the table.** Any proposed rule change goes to the plan after
     this one — this sprint measures, it does not edit rules (except S9-T5, within its budget).
- **Done when:** the fifteen-row table has no empty cell; the trim audit's new section has a
  line for every trimmed file; no file under `plugins/shipkit/rules/` or `stacks/` changed in
  this task.

### S9-T5 — `rules/nontrivial`: fix it or accept it
- **Depends on:** S9-T4 (so the experiment does not disturb the measurement).
- **Files:** edit `plugins/shipkit/rules/spec-driven.md` and/or `plugins/shipkit/rules/shipkit.md`
  (only if an attempt is kept); create `.shipkit/decisions/0002-spec-first-eval.md`; edit
  `plugins/shipkit/evals/README.md`.
- **Steps:**
  1. Read the kept traces of three failing runs **first**. Write down, in the decision's
     Context, what the model did instead (built straight away? asked and then built? wrote a
     spec it did not show?). The attempts below must answer what the traces show, not a guess.
  2. At most three attempts (B8). Each: one sentence changed in an always-on rule, with the
     bytes paid for by a cut elsewhere in the same file; `bash scripts/evals.sh --group rules`
     (all three rules cases, so `trivial` and `decision` are watched for regression);
     `rules/nontrivial` must reach 2 of 3 **and** the other two must not drop. Keep the first
     attempt that does; revert the others completely.
  3. If no attempt is kept, record 0002 accepts the result: Context (the traces), Alternatives
     (the three attempts, with their numbers), Case for accepting, Case against, Decision, and
     the clause "we would reopen this if the case passes fewer than 1 run in 10 across three
     consecutive releases, or if a user reports building without a spec after asking for one."
     If an attempt is kept, record 0002 says which sentence and why it worked, with the same
     clause shape.
- **Done when:** the exit checklist's line 5 ≤ 3000; `bash scripts/evals.sh --group rules`
  shows `trivial` and `decision` at their baseline or better; record 0002 exists with a
  concrete clause; the README's known-result note is updated either way.

### S9-T-REL — Release 4.2.0
Follow "The release task". The changelog's field notes name the rule with the largest gap
between the with and without arms, and the one with the smallest.

---

## Sprint 10 — Loose ends and a real run (4.3.0)

**Goal.** Close the small findings the last plan's field notes left, settle the one design
question open since 3.0, run the loop once on a repository that is not shipkit, and clean up
what the owner has approved deleting.

**Branch.** `sprint-10/real-run`

### S10-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/real-run/intake.md`, `spec.md`, `design.md`, `tasks.md`.
- **Steps:** as S8-T0. Decision records for: the overlay skills (B9), the real run (B10).
- **Done when:** as S8-T0, on `sprint-10/real-run`.

### S10-T1 — Catch missing requirement citations before the gate
- **Why:** both 4.0.0 gates failed their first run on a requirement with no citing test. The
  gate is a ten-minute headless run; the lint is two seconds.
- **Files:** edit `plugins/shipkit/scripts/spec-check.sh`, `scripts/smoke.sh`,
  `plugins/shipkit/skills/ship/SKILL.md` (one sentence, only if the check moves there).
- **Check first:** check out `sprint-7/trim-and-docs` at the commit **before** the gate fix
  (`ceef7f5^`) in a scratch worktree and run `sh plugins/shipkit/scripts/spec-check.sh .`
  there. If it already exits non-zero on the citation the gate caught, this task is a
  one-sentence doc note in the ship skill ("run spec-check before the gate") and nothing else.
- **Steps (only if spec-check passed where the gate failed):** find why — most likely the
  citation lived in a file spec-check does not scan, or the check applies to open specs only
  and the spec was already stamped. Extend the smallest thing: the scan set, or the status set.
  Smoke check with a spec whose REQ is cited nowhere → exit non-zero and the REQ named.
- **Done when:** the smoke check → PASS; the Check-first scratch worktree is removed (it was
  created by this task, so removing it needs no separate yes — say so in the commit); the
  repository's own specs still give 0 gaps.

### S10-T2 — Where the overlay skills live (decision 0003)
- **Files:** create `.shipkit/decisions/0003-overlay-skills-home.md`; edit
  `docs/design/two-plugin-split.md` (§5 item 6 only), `ROADMAP.md`.
- **Steps:** write the five-part record. Context: the dividing rule from 3.0 (core produces,
  reads or installs knowledge; workflows tell Claude how to work) and what the overlay skills
  actually do today — list them from `plugins/shipkit/stacks/*/.claude/skills/*/SKILL.md`
  (eleven at 4.0.0: Rails ships five, Go, Python and Elixir a `new-feature` each, React a
  `component`, static an `audit`) and say for each whether it installs knowledge or tells
  Claude how to work.
  Alternatives: core; workflows; a `workflow-skills/` subfolder. Decision per B9. Clause: a
  countable condition (for example "we would move them if two overlays gain a skill that only
  makes sense with `/shipkit-workflows:tdd` installed").
- **Done when:** the record has a concrete clause; §5 item 6 reads "settled, see 0003"; the
  ROADMAP's "From 3.0" line is gone. If B9's other option was chosen, this task also performs
  the move and the sprint becomes 5.0.0 — stop and re-plan the Files line with the owner first.

### S10-T3 — The real run
- **Depends on:** S10-T1. **Needs:** the owner names a repository (B10) before this task starts.
- **Files (in this repository):** create `docs/design/field-notes-4.3.md`; edit `ROADMAP.md`,
  `GUIDE.md` (only if a playbook step proves wrong).
- **Steps:**
  1. In the named repository, on a branch the owner approves, run the loop once with the
     installed 4.2.0 plugin (update the owner's plugin cache first — it was at 3.1.0 on
     2026-10-06 — and note how that went): `/shipkit:product` if no product file exists,
     `/shipkit:intake` on one small real change, `/shipkit:spec`, `brief.sh` for one task,
     build it, `/shipkit:ship`, `/shipkit:handoff`, then a fresh session's "what should I do
     next?". **Do not merge anything there without the owner.**
  2. For every step, write in `field-notes-4.3.md`: what the step asked for, what it produced,
     how long it took, what was awkward, and whether the awkwardness is the tool's fault or the
     project's. Quote the exact prompt or output where it matters. No step may be summarised as
     "worked fine" without the evidence line.
  3. Turn every awkwardness into a one-line candidate in ROADMAP's "Still open" (renamed
     "Still open after Sprint 10"). Fix nothing in this task — the notes are the deliverable.
- **Done when:** the notes have an entry for each of the eight steps and the fresh-session
  check; the ROADMAP lists the candidates; nothing under `plugins/` changed in this task.

### S10-T4 — Housekeeping the owner approved
- **Files:** none in the tree (branches, sandboxes and a worktree); edit `ROADMAP.md` to record
  what was removed and when.
- **Steps:** only the rows of B11 to B13 the owner approved, each as its own command with its
  output pasted in the commit message:
  - B11: `git branch -d sprint-{1..7}/…` (plain `-d`, which refuses an unmerged branch) and
    `git push origin --delete …` for each. Tags are untouched.
  - B12: `rm -rf /private/tmp/e-*` — after confirming S8-T2's smoke check no longer reads them
    (it must have been pointed at a committed trace excerpt or a fresh run by then; if it still
    reads a sandbox, stop).
  - B13: `git worktree remove .claude/worktrees/agent-a4a4658de35627a13` then
    `git worktree prune`.
- **Done when:** `git branch --list 'sprint-*'` and `git ls-remote --heads origin 'sprint-*'`
  list only this plan's branches; `git worktree list` shows one line; `ls -d /private/tmp/e-*`
  matches nothing (if B12 approved); ROADMAP records it.

### S10-T5 — Update the roadmap
- **Files:** edit `ROADMAP.md`.
- **Steps:** mark Sprints 8 to 10 shipped with their releases; the "Still open" list is what
  S10-T3 produced plus anything S9-T4 proposed; the north-star paragraph is re-read and changed
  only if the real run contradicted it — say so if it did.
- **Done when:** lint 0/0 (the status line); every item in "Still open" points at the evidence
  that put it there (a field-notes section or an eval-results table).

### S10-T-REL — Release 4.3.0 (or 5.0.0 under B9's other option)
Follow "The release task".

---

## 5. What this plan does not do

- It does not add a skill, an agent or a rule. Thirty-four skills, seven agents and eighteen
  rules is the count at the end as at the start (S8-T4 branch B changes what `setup` says, not
  what exists).
- It does not change a rule on the strength of a measurement in the same sprint the
  measurement was taken (S9-T5 is the one bounded exception, and it is paid for within the
  byte budget). Rule edits proposed by `eval-results-4.2.md` go to the next plan.
- It does not build a fixture by hand. The XL fixture is generated, so it costs 12 KB in the
  plugin, not 400.
- It does not fix `brief-verify.sh`'s `__pycache__` finding from Playbook 4. The script
  documents that ignored files are not seen, and the finding was correct: the fixture had no
  `.gitignore`. A real run (S10-T3) will say whether this bites on a real project.
- It does not touch the spec-stale hook. The eight "stale" shipped specs reported on
  2026-10-06 came from the 3.1.0 plugin in the owner's cache; the 4.0.0 hook already skips
  shipped, dropped and draft specs (`spec_is_closed` in `session-start.sh`).
- It does not merge, push or tag in any repository but this one, and here only in `T-REL`.
- It does not delete anything B11 to B13 do not name.

## 6. Risks, and what we do about each

| Risk | What we do |
|------|-----------|
| The XL fixture is still too easy — one grep finds every answer | XL1 and XL2 carry decoys; XL5 is answerable only from history; S8-T3's "What this does not show" says plainly if the fixture failed to separate the arms |
| The generated history is unrealistic and the map's Evolution section is the only "narrative", biasing `history` toward the map | The commit messages carry the full reason; the map's two sentences add nothing the log lacks. If the no-map arm cannot find it, that is the map earning its keep, which is the question |
| The re-test says "optional" and the change is bigger than B4's Files line | Rule 6: stop and ask. The lint check is written first so the scope is visible before any skill text changes |
| A rule case passes without the rule because the model already knows the trap | That is a finding, not a failure: record it in `eval-results-4.2.md` as "rule may be dead weight or case too easy" and leave the rule alone until the next plan |
| 135 eval runs cost more than estimated | `--group` lets arms be run one group at a time; the real cost goes in the results doc; the owner may drop the pre-trim arm (B6) after seeing the first group's bill |
| The nontrivial experiment regresses `trivial` or `decision` | Each attempt runs all three rules cases; a drop reverts the attempt |
| The real run (S10-T3) stalls on the other repository's state | The task writes notes, not fixes; a stall is itself a note. Nothing in this repository depends on the other repository's outcome |
| A deletion in S10-T4 removes something still referenced | `-d` not `-D` for branches; the sandbox removal is gated on the smoke check no longer reading them; the worktree is removed with git, not `rm` |
| Eval results vary from run to run | Three runs per arm, 2 of 3 to pass, raw counts recorded — as before |

## 7. Approval

To approve: reply with "approved", or with the IDs from section 2 you want changed (for
example "approved, but B6: skip the pre-trim arm, and B12: keep the sandboxes"). Work starts
with S8-T0 on the branch `sprint-8/map-on-trial`.
