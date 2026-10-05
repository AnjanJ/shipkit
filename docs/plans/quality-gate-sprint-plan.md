# Shipkit sprint plan — from knowledge layer to quality gate

> Status: **APPROVED by the owner on 2026-10-05** — A1 to A10 accepted with their recommended defaults.
> Written 2026-10-05 against shipkit 3.1.0 at commit `fa74320` on `main`.

**The goal in one sentence.** Shipkit becomes the colleague a solo engineer does not have: it
remembers what was intended, asks good questions before work is handed off, checks the result
against the intent, and refuses to call unfinished work done.

**What changes.** Seven sprints. Each sprint is one release. Nothing is removed from shipkit
before Sprint 7, and nothing is removed there without a separate approval.

---

## 1. How to follow this plan

Read this section before every task. These rules apply to a human and to an agent equally.

1. **Do tasks in order.** Inside a sprint, do `T0`, then `T1`, then `T2`, and so on. Do not skip.
   Do not start a sprint until the sprint before it is merged.
2. **One task, one commit.** The test and the code for a task go in the same commit.
3. **One sprint, one branch, one pull request.** Branch name: `sprint-N/<short-name>`.
   Branch from `main`. Never commit to `main` directly.
4. **A task is done only when every line under "Done when" is true.** Run each command. Read the
   output. If you did not run it, it is not done.
5. **Edit only the files listed under "Files".** If you need another file, stop and say why.
6. **Stop and ask the owner when any of these happen:**
   - a "Done when" check still fails after three honest attempts;
   - a "Check first" step fails and its written fallback also fails;
   - you are about to delete a file, a branch, or a shipped skill;
   - you think this plan is wrong. Say what is wrong. Do not quietly do something else.
7. **Never do these:** `git add .` or `git add -A`; `--no-verify`; force-push; amend a pushed
   commit; add a `Co-Authored-By` line; stage `.env`, keys or tokens.
8. **Commit messages** follow `plugins/shipkit/rules/shipkit.md` (What / Why / How / Test plan).
9. **Use shipkit to build shipkit.** From Sprint 3 on, each sprint must use the features the
   earlier sprints shipped (the spec format, the brief, the ship gate). If a feature is awkward to
   use, write that down in the sprint's pull request. That is a finding, not a failure.

### The sprint exit checklist (same for every sprint)

Run these, in this order, before opening the pull request. All must pass.

| # | Command | Must show |
|---|---------|-----------|
| 1 | `bash scripts/lint.sh` | `0 error(s), 0 warning(s)` |
| 2 | `bash scripts/smoke.sh` | `smoke: all checks passed` |
| 3 | `bash scripts/evals.sh` (exists after Sprint 1) | no case that passed before now fails |
| 4 | `sh plugins/shipkit/scripts/spec-check.sh .` (exists after Sprint 2) | exit status 0 |
| 5 | `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md \| wc -c` | at most 3000 (after Sprint 1) |

### The release task (the last task of every sprint, written `T-REL`)

1. Set the new version in all five places: `plugins/shipkit/.claude-plugin/plugin.json`,
   `plugins/shipkit-workflows/.claude-plugin/plugin.json`, and the three `version` fields in
   `.claude-plugin/marketplace.json`.
2. Add a `## [X.Y.Z] — <date>` section at the top of `CHANGELOG.md`. List what was added, changed
   and fixed, in plain sentences.
3. Update skill and agent counts in `README.md` and `.claude-plugin/marketplace.json` if they changed.
4. Run the sprint exit checklist.
5. Open the pull request. Wait for the `lint` check to pass. Merge with a merge commit. Tag `vX.Y.Z`.
6. Do not delete the branch unless the owner says so.

### Words used in this plan

| Word | Meaning |
|------|---------|
| Owner | Anjan. The only person who approves. |
| Executor | Whoever is doing the task: a person or an agent. |
| Spec | A folder `.shipkit/specs/<slug>/` holding `spec.md`, `design.md`, `tasks.md`. |
| REQ | One numbered requirement in a spec, for example `REQ-3`. |
| Core | The `plugins/shipkit/` plugin. |
| Always-on bytes | The size of the three rules the session hook injects into every session. Today: 11,867. |
| Check first | A short experiment that proves a platform feature works before we build on it. |

---

## 2. Decisions the owner must approve

Each line has a recommended default. Approve all, or change any.

| ID | Decision | Recommended default | The other option |
|----|----------|---------------------|------------------|
| A1 | Order and releases | Seven sprints in the order below: 3.2.0, 3.3.0, 3.4.0, 3.5.0, 3.6.0, 3.7.0, then 4.0.0 | Reorder, for example product and intake first |
| A2 | New skills | Add five: `product`, `intake`, `ship`, `escape`, `handoff` (12 → 17 in core) | Fold `intake` and `escape` into `/shipkit:spec` as phases (12 → 15) |
| A3 | Always-on budget | The three injected rules shrink from 11,867 bytes to at most 3,000. Detail moves into skills that load on demand | A looser budget, for example 5,000 |
| A4 | Reviewer model | The `reviewer` agent uses the same model as the session | Pin it to `sonnet` to save cost |
| A5 | Handoff note | `.shipkit/state.md` is git-ignored by default | Commit it, so it follows you across machines |
| A6 | Decision checks | A decision may carry a shell command. It runs only when a person or skill asks. It never runs from a hook | No executable checks; keep clauses as text only |
| A7 | Weekly digest | A local script reads your registry and writes a digest. You may schedule it yourself | A scheduled cloud agent (needs every repo on GitHub) |
| A8 | Cuts | Sprint 7 proposes cuts in a table. Nothing is cut without a second approval | — |
| A9 | Where evals live | `plugins/shipkit/evals/`, at most 100 KB, shipped with the plugin | Repo root, if the eval tool allows it |
| A10 | Commit guard | A hook blocks `git commit` when a secret-looking file is staged | No hook; keep it as a rule in prose |

---

## 3. What we know about the platform, and what we must check

Tested on this machine with Claude Code 2.1.289:

- `claude plugin eval` exists. It runs cases from `<plugin>/evals/` (`case.yaml`, or `prompt.md`
  plus `graders/*.md`). It can run a second pass **without** the plugin and report the difference.
- A `SessionStart` hook's output reaches the session, up to about 10,000 characters per command
  (smoke check `hook-cap`).
- Rules load from a project's `.claude/rules/`, not from a plugin (smoke checks 1 and 2).

Reported by a documentation lookup, **not yet tested here**. Each has a "Check first" step in the
task that needs it:

| Claim | Needed by | If it turns out false |
|-------|-----------|-----------------------|
| A `PreToolUse` hook can match the Bash tool and block a call with exit status 2 | S1-T7 | Drop the commit guard; keep the rule in prose |
| Eval graders can check tool calls and written files, not only the final text | S1-T1 | Grade final text only; drive file checks from `scripts/smoke.sh` |
| An agent file may omit `model:` and inherit the session's model | S4-T1 | Set `model: sonnet` |
| A hook event exists that fires before context is compacted | S5-T4 | Skip that task; the handoff skill still works by hand |
| A scheduled cloud agent can run a plugin skill on a schedule | S6-T5 | Use the local script only (already the default, A7) |

**One design rule that follows from this:** no feature in this plan depends on an agent starting
another agent. Every agent is started by the main session.

---

## 4. The seven sprints at a glance

| Sprint | Release | Name | What the owner gets |
|--------|---------|------|---------------------|
| 1 | 3.2.0 | Measure and slim | Evals that show whether shipkit helps; rules four times smaller |
| 2 | 3.3.0 | The spec is a contract | Specs with a status, drift measured on the right files, a script that fails when a requirement has no test |
| 3 | 3.4.0 | Product, intake, brief | A product file, good questions before work starts, a standard brief for any agent |
| 4 | 3.5.0 | Reviewer and ship gate | A second pair of eyes with fresh context; one command that says READY or NOT READY with evidence |
| 5 | 3.6.0 | Briefing and handoff | Five lines at session start saying where things stand; a note at the end so the next session resumes |
| 6 | 3.7.0 | Live decisions and digest | Decisions that can check themselves; a weekly view of every product |
| 7 | 4.0.0 | Trim and tell the story | Less to load, clearer docs, one worked example from idea to shipped |

Always-on budget, tracked every sprint:

| Item | Today | After Sprint 1 | After Sprint 5 |
|------|-------|----------------|----------------|
| Three injected rules | 11,867 bytes | ≤ 3,000 | ≤ 3,000 |
| Session briefing | 0 | 0 | ≤ 800 |

---

## Sprint 1 — Measure and slim (3.2.0)

**Goal.** Before adding anything, be able to measure whether shipkit helps, and cut what every
session pays for.

**Branch.** `sprint-1/measure-and-slim`

### S1-T0 — Write the sprint spec
- **Files:** create `.shipkit/specs/measure-and-slim/spec.md`, `design.md`, `tasks.md`.
- **Steps:**
  1. Copy each "Done when" line of tasks S1-T1 to S1-T7 into `spec.md` as one EARS requirement.
  2. In `design.md`, write one decision record for each of: where evals live (A9), the byte
     budget (A3), the commit guard (A10).
  3. In `tasks.md`, list S1-T1 to S1-T7, each citing its requirement.
  4. Show the requirements to the owner. Wait for a yes.
- **Done when:** the three files exist; the owner has said yes to the requirements; `spec.md`
  carries the line `> Spec accepted at commit <sha> on sprint-1/measure-and-slim.`

### S1-T1 — Prove the eval tool works
- **Why:** everything else in this sprint stands on it.
- **Files:** create `plugins/shipkit/evals/README.md`, `plugins/shipkit/evals/hello/case.yaml`
  (or `prompt.md` + `graders/`), `scripts/evals.sh`.
- **Check first:** run `claude plugin eval --help` and read all of it. Then read
  `https://code.claude.com/docs/en/plugin-evals.md`.
- **Steps:**
  1. Write one trivial case: the prompt asks "Which shipkit skill builds PROJECT_MAP.md?"; it
     passes when the answer contains `/shipkit:map`.
  2. Run `claude plugin eval plugins/shipkit --case hello`. Make it pass.
  3. Find out, by trying, whether a grader can check (a) which tools were called and (b) a file
     the run wrote. Write both answers in `evals/README.md` under "What graders can check".
  4. Write `scripts/evals.sh`: it runs every case in `plugins/shipkit/evals/` and exits non-zero
     if any case fails. Ten lines or fewer.
- **Done when:** `bash scripts/evals.sh` exits 0 and prints the `hello` case as passed;
  `evals/README.md` states the working case format and the two answers from step 3.
- **Fallback:** if the eval tool cannot run at all, write `scripts/evals.sh` in the style of
  `scripts/smoke.sh` (`claude -p` plus `case` matching), and say so in the README.

### S1-T2 — Build the fixture project
- **Files:** create `plugins/shipkit/evals/fixtures/sample-app/` (at most 20 files, 40 KB).
- **Steps:**
  1. Write a tiny app in plain Python (no dependencies): `app/orders.py`, `app/billing.py`,
     `app/jobs/retry.py`, `tests/test_orders.py`, `README.md`, `pyproject.toml`.
  2. Plant four facts and write them in `evals/fixtures/FACTS.md`:
     - F1: retries are capped at 5, in `app/jobs/retry.py`.
     - F2: tax is computed in `app/billing.py`, function `apply_tax`.
     - F3: the map says orders are stored in SQLite, but the code uses a JSON file. **The map is wrong on purpose.**
     - F4: nothing in the project says which payment provider is used. **There is no answer.**
  3. Write `PROJECT_MAP.md` for the fixture, correct except for F3.
- **Done when:** `FACTS.md` lists F1 to F4 with file and line; `grep -rn "SQLite" fixtures/sample-app`
  matches only `PROJECT_MAP.md`; `du -sk fixtures` shows 40 or less.

### S1-T3 — Evals for the elder (`grandfather`)
- **Depends on:** S1-T1, S1-T2.
- **Files:** create four case folders under `plugins/shipkit/evals/grandfather/`.
- **Steps:** write one case per row. Each prompt begins `/shipkit:ask`.

  | Case | Question | Passes when the answer… |
  |------|----------|-------------------------|
  | `lookup` | Where is the retry limit set? | names `app/jobs/retry.py` and the number 5 |
  | `explain` | How is tax applied to an order? | names `apply_tax` and `app/billing.py` |
  | `drift` | Where are orders stored? | says a JSON file **and** says the map is wrong or out of date |
  | `gap` | Which payment provider do we use? | says it could not find or confirm one, and names no provider |

- **Done when:** `bash scripts/evals.sh` runs all four and prints a pass or fail for each. The
  results are written into `plugins/shipkit/evals/README.md` under "Baseline 3.1.0". **A failing
  case is an acceptable result here — record it, do not bend the grader to make it pass.**

### S1-T4 — Measure what the map is worth
- **Depends on:** S1-T3.
- **Files:** create `docs/design/eval-results-3.2.md`, `.shipkit/decisions/0001-project-map-default.md`.
- **Steps:**
  1. Run the four cases three times with the fixture as it is. Record passes and tool-call counts.
  2. Delete `PROJECT_MAP.md` from a copy of the fixture. Run the four cases three times. Record the same.
  3. Run the four cases with the plugin switched off (`--ablation with-without`). Record the same.
  4. Put the three sets of numbers in one table in `eval-results-3.2.md`.
  5. Write decision record 0001 with the five parts. Use this falsifiability clause: "We keep
     the map as the default if, on these cases, it gives at least one more correct answer or at
     least 20% fewer tool calls than no map. Otherwise the map becomes optional."
- **Done when:** the table has three rows and no empty cell; the decision record states which
  side of the clause the numbers fall on. **Do not change any shipped file in this task.**

### S1-T5 — Evals for the always-on rules
- **Why:** S1-T6 shrinks the rules. We need proof the behaviour survives.
- **Files:** create three case folders under `plugins/shipkit/evals/rules/`.
- **Steps:** write one case per row, run in the fixture project.

  | Case | Prompt | Passes when the reply… |
  |------|--------|------------------------|
  | `nontrivial` | "Add refunds to the billing module." | proposes requirements or a spec before writing code |
  | `trivial` | "Fix the typo in README.md: 'recieve'." | fixes it and does not propose a spec |
  | `decision` | "Should we move orders from the JSON file to SQLite? Decide and record it." | names at least two options and a concrete "would reverse if" condition |

- **Done when:** all three run; results recorded under "Baseline 3.1.0" in `evals/README.md`.

### S1-T6 — Shrink the three always-on rules
- **Depends on:** S1-T5.
- **Files:** edit `plugins/shipkit/rules/shipkit.md`, `spec-driven.md`, `decisions.md`; edit
  `plugins/shipkit/skills/commit/SKILL.md`, `plugins/shipkit/skills/spec/reference.md`; edit
  `scripts/lint.py`; edit `plugins/shipkit/skills/context-audit/SKILL.md`.
- **Steps:**
  1. For every paragraph in the three rules, decide: **trigger** (tells Claude *when* to act) or
     **detail** (tells Claude *how*). Triggers stay. Detail moves.
  2. Move the commit message template into `skills/commit/SKILL.md`. In the rule, leave: atomic
     commits, never `git add .`, never `--no-verify`, no co-author line, and "for a substantive
     commit use the format in `/shipkit:commit`".
  3. Move the EARS patterns and the five-part detail into `skills/spec/reference.md` if not
     already there. In the rules, leave: the three questions, where the files live, the
     trivial-versus-non-trivial split, the five part names on one line, "the reversal condition
     must be a metric, event or threshold", and the names of the skills to use.
  4. Keep every "ask before anything destructive" line. Do not shorten the list of destructive actions.
  5. Add a lint check: the total size of the rules without `paths:` frontmatter must be at most
     3,000 bytes. More is an error.
  6. Fix the numbers in `context-audit/SKILL.md` that describe the rules' size.
- **Done when:** `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md | wc -c` prints
  3000 or less; `bash scripts/lint.sh` is clean; the three `rules/` evals from S1-T5 give the same
  pass/fail as the baseline or better; the smoke suite passes.
- **Do not:** delete a rule file; rename a rule file; touch the six path-scoped rules.

### S1-T7 — Commit guard hook
- **Files:** create `plugins/shipkit/scripts/guard-commit.sh`; edit `plugins/shipkit/hooks/hooks.json`,
  `scripts/smoke.sh`, `scripts/lint.py` (only if the lint rejects the new hook entry).
- **Check first:** read `https://code.claude.com/docs/en/hooks.md`. In a scratch project, add a
  `PreToolUse` hook on the `Bash` tool whose script exits 2 and prints `BLOCKED-TEST` to stderr.
  Run `claude -p "run: echo hi"`. Confirm the call is blocked and the model sees `BLOCKED-TEST`.
  If this cannot be made to work, skip this task and record why in the changelog.
- **Steps:**
  1. The script reads the hook's JSON from stdin. If the command does not contain `git commit`,
     exit 0 at once.
  2. Otherwise list staged files with `git diff --cached --name-only`.
  3. If any staged name matches `.env`, `.env.*` (but not `.env.example`), `*.pem`, `*.key`,
     `id_rsa*`, `credentials*.json`: print the file names and "unstage these or ask the owner" to
     stderr and exit 2.
  4. On any internal error, exit 0. The guard must never block a session by breaking.
  5. Add smoke checks that call the script directly with sample JSON: clean commit → exit 0;
     staged `.env` → exit 2; staged `.env.example` → exit 0; a command that is not a commit → exit 0.
- **Done when:** the four smoke checks pass; the script is POSIX `sh` (`sh -n` is clean).

### S1-T-REL — Release 3.2.0
Follow "The release task" in section 1.

---

## Sprint 2 — The spec is a contract (3.3.0)

**Goal.** A spec stops being a document someone promises to follow. A script checks it.

**Branch.** `sprint-2/spec-contract`

### The formats this sprint introduces (read before any task)

**Two new lines at the top of `spec.md`,** under the existing stamp line:

```markdown
> Spec accepted at commit `abc1234` on main.
> Status: open
> Paths: app/billing/, tests/billing/
```

- `Status` is one of `draft`, `open`, `shipped`, `dropped`. A spec with no `Status` line is treated as `open`.
- `Paths` is a comma-separated list of files or folders the feature lives in. A spec with no
  `Paths` line means "the whole repository", which is today's behaviour.

**How a test cites a requirement.** Anywhere in the test file, in a comment or a test name, write
the spec's folder name, a slash, and the requirement: `refunds/REQ-3`. The folder name is needed
because every spec has its own `REQ-1`.

**How a requirement is excused from having a test.** End the requirement line in `spec.md` with
`[untested: <reason>]`. Use it for requirements that are prose only.

**The new task format in `tasks.md`:**

```markdown
- [ ] **T3** Reject refunds larger than the original charge → REQ-2
  - Files: app/billing/refunds.py, tests/billing/test_refunds.py
  - Test: tests/billing/test_refunds.py::test_refund_over_charge_is_rejected
  - After: T1
  - Done when: `pytest tests/billing/test_refunds.py` → all pass
```

- `Files` — the only files the task may change.
- `Test` — the test that must fail before the work and pass after it.
- `After` — the tasks that must be finished first, or `none`.
- **The sharing rule:** if two tasks list the same file, the later one must name the earlier one
  in `After`. This is what makes it safe to give tasks to agents working at the same time.

### S2-T0 — Write the sprint spec
Same steps as S1-T0, for tasks S2-T1 to S2-T6. Folder: `.shipkit/specs/spec-contract/`.
Decision records needed: status and paths as stamp lines versus YAML frontmatter; the
`<slug>/REQ-N` citation versus a bare `REQ-N`; the direct-only sharing rule versus a full
dependency graph. **Done when** the owner has approved the requirements.

### S2-T1 — `spec-check.sh`, part one: requirements and tests
- **Files:** create `plugins/shipkit/scripts/spec-check.sh`; edit `scripts/smoke.sh`.
- **Usage:** `spec-check.sh <project-dir> [slug]`. With no slug it checks every spec.
- **Steps:** write the smoke checks first, then the script. For each spec whose status is `open`
  or `shipped`:
  1. Collect the requirement numbers from `spec.md` (lines containing `**REQ-N`).
  2. For each one not marked `[untested: …]`, print `MISSING-TASK <slug> REQ-N` if `tasks.md`
     does not mention it.
  3. If the status is `shipped`: print `MISSING-TEST <slug> REQ-N` if `git grep -F "<slug>/REQ-N"`
     finds nothing outside `.shipkit/`, `docs/` and `*.md` files.
  4. Print `WAIVED <slug> REQ-N` for each excused requirement.
  5. Exit 0 if there is no `MISSING-` line, 1 if there is one, 64 on wrong usage.
  Specs with status `draft` or `dropped` are skipped. Print `SKIPPED <slug> (<status>)`.
- **Done when:** these smoke checks pass, each on a scratch project: a complete shipped spec →
  exit 0; a requirement with no task → `MISSING-TASK`, exit 1; a shipped spec with an uncited
  requirement → `MISSING-TEST`, exit 1; an `[untested: …]` requirement → `WAIVED`, exit 0; a
  `dropped` spec with gaps → exit 0; two specs that both have `REQ-1` do not satisfy each other.
- **Do not:** use bash-only syntax; require python on the user's machine.

### S2-T2 — `spec-check.sh`, part two: the task format
- **Depends on:** S2-T1.
- **Files:** edit `plugins/shipkit/scripts/spec-check.sh`, `scripts/smoke.sh`.
- **Steps:** for specs with status `open` **and** a `Status` line present:
  1. Every task has `Files`, `Test`, `After`, `Done when`. Missing → `MISSING-FIELD <slug> T<n> <field>`.
  2. Every name in an `After` line is a task that exists. Otherwise → `BAD-AFTER <slug> T<n> <name>`.
  3. The sharing rule. Broken → `CONFLICT <slug> T<a> T<b> <file>`.
  All three make the exit status 1.
- **Done when:** one smoke check per message above passes; a spec written in the old task format
  with no `Status` line still exits 0.

### S2-T3 — Drift measured on the right files
- **Files:** edit `plugins/shipkit/scripts/session-start.sh`, `scripts/smoke.sh`.
- **Steps:**
  1. Skip specs whose status is `shipped`, `dropped` or `draft`. Only `open` specs can nag.
  2. If the spec has a `Paths` line, count commits with
     `git rev-list --count <sha>..HEAD -- <each path>`. If it has none, count as today.
  3. Change the message to say "N commits have touched its paths since it was accepted".
- **Done when:** smoke checks pass for: a `shipped` spec 40 commits old → silent; an `open` spec
  with `Paths: a/` and 20 commits that touch only `b/` → silent; the same with 20 commits touching
  `a/` → one line; a spec with no `Status` and no `Paths` → behaves exactly as in 3.2.0
  (the existing `spec-staleness` checks still pass unchanged).

### S2-T4 — Teach the spec skill and the rule the new formats
- **Files:** edit `plugins/shipkit/skills/spec/SKILL.md`, `skills/spec/reference.md`,
  `plugins/shipkit/rules/spec-driven.md`, `GUIDE.md` (the Spec-Driven Development section only).
- **Steps:**
  1. Replace the `spec.md` and `tasks.md` templates in `reference.md` with the formats above.
  2. In `SKILL.md`: Q1 writes `Status: draft`; acceptance sets `Status: open` and asks for `Paths`;
     Q3 writes tasks in the new format and then runs `spec-check.sh` and fixes what it reports.
  3. Add one sentence to the rule: tests cite `<slug>/REQ-N`. Stay inside the 3,000-byte budget.
  4. Add an eval case `spec/new-format`: ask for a spec for "refunds" in the fixture; it passes
     when the written `tasks.md` gets exit 0 from `spec-check.sh`. If graders cannot run a script
     (see S1-T1), do this as a smoke check instead.
- **Done when:** lint is clean; the byte budget holds; the new case passes.

### S2-T5 — Bring this repository's own specs up to the new format
- **Files:** edit `.shipkit/specs/install-lifecycle/spec.md`, `.shipkit/specs/unsetup-safety/spec.md`,
  `.shipkit/specs/measure-and-slim/spec.md`, `scripts/smoke.sh` (comments only), `scripts/lint.py`
  (comments only).
- **Steps:**
  1. Add `Status: shipped` and a `Paths` line to the three finished specs.
  2. For each requirement, find the smoke or lint check that proves it and add the citation
     `<slug>/REQ-N` to that check's comment.
  3. Where a requirement is proved only by reading, mark it `[untested: verified by reading]`.
- **Done when:** `sh plugins/shipkit/scripts/spec-check.sh .` exits 0 and prints no `MISSING-` line.
- **Do not:** change what any smoke check does. Comments only.

### S2-T6 — Run the check in CI
- **Files:** edit `.github/workflows/lint.yml`.
- **Steps:** add one step after the lint: `sh plugins/shipkit/scripts/spec-check.sh .`
- **Done when:** the pull request's `lint` check runs the new step and passes.

### S2-T-REL — Release 3.3.0

---

## Sprint 3 — Product, intake, brief (3.4.0)

**Goal.** Shipkit knows what the product is for, asks a few good questions before work starts,
and turns a task into a brief any agent can follow.

**Branch.** `sprint-3/product-intake-brief`

### S3-T0 — Write the sprint spec
Folder `.shipkit/specs/product-intake-brief/`, **in the Sprint 2 format**, covering S3-T1 to S3-T7.
Decision records needed: intake as its own skill versus a phase of `/shipkit:spec` (A2); the
brief built by a script versus written by the model. **Done when** the owner approves and
`spec-check.sh` exits 0 on it.

### S3-T1 — The product file and `/shipkit:product`
- **Files:** create `plugins/shipkit/skills/product/SKILL.md`, `skills/product/reference.md`.
- **The file it writes, `.shipkit/product.md`** (at most 60 lines, these headings, in this order):

  ```markdown
  # Product: <name>
  > Product reviewed on 2026-10-05.

  ## One line
  ## Users
  ## Goals this quarter      (at most three; each has a metric, a target and a date)
  ## Non-goals               (what this product deliberately does not do)
  ## Metrics that matter
  ## Constraints             (budget, stack, legal, time)
  ## Now / Next / Later
  ```

- **Steps:**
  1. The skill runs inline (it asks questions). It first reads `README.md`, `CLAUDE.md` and
     `PROJECT_MAP.md` and fills in what they already answer.
  2. It asks only for what is still empty, at most eight questions, one screen at a time.
  3. A goal with no metric or no date is not accepted. Ask again, once. If there is still none,
     write `metric: none set` so the gap is visible.
  4. If the file exists, the skill updates it and changes the review date. It never starts over.
- **Done when:** lint is clean; an eval or smoke check shows that, run in the fixture with
  scripted answers, the file has all seven headings and at most three goals.

### S3-T2 — Studio priorities and the registry
- **Files:** edit `plugins/shipkit/skills/product/SKILL.md`, `skills/map/SKILL.md`,
  `plugins/shipkit/agents/eve.md`.
- **Steps:**
  1. `/shipkit:product --studio` writes `~/.claude/shipkit/studio.md`: a ranked list of at most
     five priorities across all products, each naming the product it belongs to, plus a review date.
  2. Add two columns to the registry template in `skills/map/SKILL.md`: `Product` (the one line)
     and `Top Goal`. `--register` fills them from `.shipkit/product.md`, or `?` if there is none.
  3. Tell `eve` the two columns and `studio.md` exist and what they are for.
- **Done when:** lint is clean; the registry template shows both columns; `eve.md` names `studio.md`.
- **Do not:** rewrite a user's existing registry rows. Add the columns; put `?` in old rows.

### S3-T3 — `/shipkit:intake`
- **Depends on:** S3-T1.
- **Files:** create `plugins/shipkit/skills/intake/SKILL.md`; edit `skills/spec/SKILL.md`.
- **What it does, in order:**
  1. Decide: is the request trivial? If yes, say "trivial — no intake needed" and stop.
  2. Read `.shipkit/product.md`, the list of open specs, and the titles of the decision records.
     For "how does the code do X today" questions, ask `grandfather`; do not read the code inline.
  3. Look for three kinds of conflict and state each one found, plainly, **before** any question:
     the request touches a **non-goal**; an **open spec** already covers it; it **contradicts a
     decision record**.
  4. List what is still unknown. Keep only unknowns whose answer would change what gets built.
     Ask at most **four** questions, the most important first. Never ask what a file already answers.
  5. Ask which quarterly goal this serves. "None" is an allowed answer and is written down.
  6. Write `.shipkit/specs/<slug>/intake.md` with these headings: `Request`, `Serves goal`,
     `Conflicts found`, `Answers`, `Assumptions made`, `Out of scope`.
- **Also:** in `skills/spec/SKILL.md`, Q1 starts with "if `intake.md` does not exist, run the intake first".
- **Done when:** lint is clean, and these eval cases pass in the fixture (give the fixture a
  `product.md` with the non-goal "no multi-currency support"):

  | Case | Prompt | Passes when the reply… |
  |------|--------|------------------------|
  | `intake/nongoal` | "Add EUR and GBP pricing." | says this conflicts with the non-goal |
  | `intake/trivial` | "Rename `apply_tax` to `add_tax`." | does not run an intake |
  | `intake/limit` | "Add refunds." | asks four questions or fewer |

### S3-T4 — `brief.sh`: build a brief from a task
- **Depends on:** Sprint 2.
- **Files:** create `plugins/shipkit/scripts/brief.sh`; edit `scripts/smoke.sh`.
- **Usage:** `brief.sh <project-dir> <slug> <task-id>` prints the brief. It uses no model.
- **The brief it prints** (these headings, always, in this order):

  ```markdown
  # Brief: <slug> / <task-id> — <task title>
  ## Goal            (the Purpose section of spec.md)
  ## Requirement     (the full text of each REQ the task cites)
  ## You may edit    (the task's Files line — and nothing else)
  ## Prove it with   (the task's Test and Done-when lines)
  ## Already done    (the tasks named in After)
  ## Decisions that bind you   (titles of the design.md decisions citing the same REQs)
  ## Not in scope    (the Out of scope section of spec.md)
  ## Report back in exactly this form
  RESULT: done | blocked
  CHANGED: <files>
  TEST: <command> → <last lines of output>
  NOT VERIFIED: <anything you did not check, or "nothing">
  DEVIATIONS: <anything you did differently from this brief, or "none">
  ```

- **Done when:** smoke checks pass for: a valid task → all nine headings present and the REQ text
  is copied word for word; an unknown task id → exit 1 with a clear message; a task in the old
  format (no `Files`) → exit 1 saying the spec must be in the new format.

### S3-T5 — `brief-verify.sh`: check what came back
- **Depends on:** S3-T4.
- **Files:** create `plugins/shipkit/scripts/brief-verify.sh`; edit `scripts/smoke.sh`.
- **Usage:** `brief-verify.sh <project-dir> <slug> <task-id> <base-ref>`
- **Steps:** list the files changed since `<base-ref>` (`git diff --name-only`, plus untracked
  files). Print `OUTSIDE <file>` for each file not on the task's `Files` line. Exit 1 if there is
  any, else 0.
- **Done when:** smoke checks pass for: only allowed files changed → exit 0; one extra file →
  `OUTSIDE`, exit 1; a new untracked file outside the list → `OUTSIDE`, exit 1.

### S3-T6 — Tell Claude when to use the brief
- **Files:** edit `plugins/shipkit/rules/spec-driven.md`, `plugins/shipkit/skills/spec/SKILL.md`, `GUIDE.md`.
- **Steps:** add, in the fewest words that are still clear:
  1. Work on a spec task that is handed to another agent is handed over **as the output of
     `brief.sh`, unchanged**. Extra context may be added below it, never in place of it.
  2. When the agent reports back, the main session runs `brief-verify.sh` and runs the task's
     `Done when` command **itself**. The agent's own claim is not proof.
  3. Tasks with `After: none`, or whose `After` tasks are finished, may run at the same time,
     each in its own git worktree.
  4. Match the team to the work: trivial → no agent; one task → at most one implementing agent;
     research → the elders. Do not start agents "in case".
- **Done when:** lint is clean; the byte budget holds.

### S3-T7 — Use it for real, once
- **Steps:** write the Sprint 4 spec (S4-T0) by running `/shipkit:intake` and then `/shipkit:spec`.
  Hand one Sprint 4 task to an agent using `brief.sh`. Check it with `brief-verify.sh`.
- **Done when:** the pull request description has a section "What was awkward" with at least one
  honest observation, or the words "nothing was awkward" and why.

### S3-T-REL — Release 3.4.0

---

## Sprint 4 — Reviewer and ship gate (3.5.0)

**Goal.** A second pair of eyes that has not seen the implementer's reasoning, and one command
that says whether a feature is ready, with evidence.

**Branch.** `sprint-4/review-and-ship`

### S4-T0 — Write the sprint spec
Written during S3-T7. Folder `.shipkit/specs/review-and-ship/`. Decision records needed:
reviewer model (A4); the gate as a skill versus a script.

### S4-T1 — The `reviewer` agent
- **Files:** create `plugins/shipkit/agents/reviewer.md`; edit `scripts/smoke.sh` (the `agents`
  check lists the expected agent names).
- **Check first:** confirm in the docs that an agent file may omit `model:`. If not, use `sonnet`.
- **What the agent is given:** a spec folder name and a base git ref. **Nothing else.** No summary
  from whoever wrote the code.
- **What it does:**
  1. Reads `spec.md`, `design.md`, `tasks.md`, then `git diff <base>...HEAD`.
  2. For each requirement, gives one verdict: `MET` (with the file and line of the code **and** of
     the test), `NOT MET` (what is missing), or `CANNOT TELL` (what it would need to see).
  3. Lists every changed file that is outside the spec's `Paths` under "Changes beyond the spec".
  4. Lists every design decision the code does not follow.
  5. Ends with one line: `VERDICT: PASS` only if every requirement is `MET`; otherwise `VERDICT: FAIL`.
- **Tools:** `Read, Glob, Grep, Bash`. Disallowed: `Edit, Write, Agent`.
- **It does not** hunt for general bugs or style. It says so, and points to the built-in `/code-review` for that.
- **Done when:** lint is clean; the smoke `agents` check lists six agents; an eval case
  `reviewer/missing-req` passes: in a fixture branch where REQ-2 has no code, the reply marks
  REQ-2 `NOT MET` and ends `VERDICT: FAIL`.

### S4-T2 — `/shipkit:ship`
- **Depends on:** S4-T1, Sprint 2, Sprint 3.
- **Files:** create `plugins/shipkit/skills/ship/SKILL.md`, `skills/ship/reference.md`.
- **Usage:** `/shipkit:ship <slug> [base-ref]` (base defaults to the merge-base with `main`).
  Runs inline.
- **The gate, in order. Each step is recorded as PASS, FAIL or SKIPPED with the reason:**

  | # | Step | PASS means |
  |---|------|-----------|
  | 1 | Run `spec-check.sh <project> <slug>`, treating the spec as `shipped` | exit 0 |
  | 2 | Run the project's test command (from `CLAUDE.md`; ask once if not found) | exit 0; keep the last 20 lines |
  | 3 | Every task box in `tasks.md` is ticked | no `- [ ]` left |
  | 4 | Start the `reviewer` agent with the slug and base ref only | `VERDICT: PASS` |
  | 5 | If the diff contains a database migration: is there a written way to roll it back? | yes, or no migration |
  | 6 | Every decision in `design.md` has a concrete reversal condition | none is vague or missing |
  | 7 | The working tree is clean | `git status --porcelain` is empty |

- **What it writes:** `.shipkit/releases/<date>-<slug>.md` — the seven results, the evidence for
  each (command and output tail, or the reviewer's table), the commit sha, and one first line:
  `READY` or `NOT READY`.
- **After a READY result:** ask the owner whether to set the spec's `Status: shipped`. Only then change it.
- **It never** deploys, pushes, merges, tags, or edits code. On `NOT READY` it lists what to fix and stops.
- **Done when:** lint is clean; smoke or eval checks show: a complete fixture feature → the report's
  first line is `READY`; the same with one unticked task → `NOT READY` naming step 3; running it
  does not change any file except the report (and the status line, after a yes).

### S4-T3 — `/shipkit:escape`
- **Files:** create `plugins/shipkit/skills/escape/SKILL.md`.
- **When it is used:** a bug reached users. Runs inline.
- **What it does:**
  1. Asks what happened and how it was noticed (at most three questions).
  2. Finds the spec whose `Paths` cover the broken code, or says there is none.
  3. Picks exactly one cause from this list and says why:
     `no spec` · `requirement missing` · `requirement wrong` · `requirement right, no test` ·
     `test existed but was wrong` · `outside the product (dependency, infrastructure)`.
  4. Writes `.shipkit/escapes/NNNN-<slug>.md`: date, what happened, the cause, the spec, the fix.
  5. If a requirement was missing or wrong: adds or corrects it in `spec.md`, sets `Status: open`,
     and adds a task whose test **fails first** and cites the new requirement.
- **Done when:** lint is clean; an eval case `escape/missing-req` passes: given "refunds above the
  charge were accepted in production" in a fixture whose spec has no such requirement, the reply
  names the cause `requirement missing` and proposes a new REQ.

### S4-T4 — Link the Rails overlay to the gate
- **Files:** edit `plugins/shipkit/stacks/rails/.claude/skills/deploy-check/SKILL.md` and
  `.../release/SKILL.md`.
- **Steps:** add one line to each: "If this feature has a spec, run `/shipkit:ship <slug>` first."
- **Done when:** lint is clean. **Do not** remove or rewrite either skill.

### S4-T5 — Use it for real, once
- **Steps:** run `/shipkit:ship review-and-ship` on this sprint's own branch. Fix what it finds.
- **Done when:** `.shipkit/releases/<date>-review-and-ship.md` exists, its first line is `READY`,
  and it is committed.

### S4-T-REL — Release 3.5.0

---

## Sprint 5 — Briefing and handoff (3.6.0)

**Goal.** A session starts by knowing where things stand and ends by leaving a note.

**Branch.** `sprint-5/briefing-and-handoff`

### S5-T0 — Write the sprint spec
Use `/shipkit:intake` then `/shipkit:spec`. Folder `.shipkit/specs/briefing-and-handoff/`.
Decision records needed: `state.md` ignored versus committed (A5); a briefing versus a standing
team of agents at session start (record why the team was rejected: cost before the task is known,
and loss of detail at every handoff).

### S5-T1 — `briefing.sh`
- **Files:** create `plugins/shipkit/scripts/briefing.sh`; edit `plugins/shipkit/scripts/session-start.sh`,
  `scripts/smoke.sh`.
- **What it prints** — at most eight lines, at most 800 bytes, each starting `shipkit:`:
  1. One line per `open` spec, at most three: `<slug>: 3 of 7 tasks done, next T4 — <title>`.
  2. `spec-check: N gap(s) — run spec-check.sh` (only if N > 0).
  3. `top goal: <first goal in product.md>` (only if the file exists).
  4. `last handoff (<date>, N commits ago): <the "Next step" line of state.md>` (only if it exists).
- **Rules:** print nothing at all if `.shipkit/` does not exist. Never exit non-zero. Finish in
  under one second on a project with 50 specs. `session-start.sh` calls it last.
- **Done when:** smoke checks pass for: no `.shipkit/` → empty output; two open specs and a
  `state.md` → the right lines; 50 open specs → at most eight lines and at most 800 bytes; a
  broken `tasks.md` → no error and exit 0.

### S5-T2 — `/shipkit:handoff`
- **Files:** create `plugins/shipkit/skills/handoff/SKILL.md`; edit `plugins/shipkit/skills/setup/SKILL.md`.
- **What it writes:** `.shipkit/state.md`, replacing the old one, at most 30 lines:

  ```markdown
  # Handoff
  > Written 2026-10-05 at commit `abc1234` on <branch>.
  ## In flight        (what is half done, and in which files)
  ## Done this session
  ## Next step        (exactly one line: the very next thing to do)
  ## Open questions   (things only the owner can answer)
  ## Do not forget    (traps found this session)
  ```

- **Steps:**
  1. The skill's description says: use when the user is wrapping up, or before a long pause, when
     there is unfinished spec work or uncommitted change. Do not use after trivial work.
  2. It fills the file from the session and from `git status`. It asks nothing unless "Next step"
     is truly unclear.
  3. `/shipkit:setup` offers to add `.shipkit/state.md` to `.gitignore` (per A5).
- **Done when:** lint is clean; a smoke or eval check shows the file has the five headings and a
  one-line "Next step".

### S5-T3 — Close the loop
- **Depends on:** S5-T1, S5-T2.
- **Steps:** in a scratch project, write a handoff, start a new session, and ask "what should I do next?".
- **Done when:** a smoke check (using `claude -p`) shows the reply contains the "Next step" text
  from `state.md`.

### S5-T4 — Remind before context is compacted (only if the platform allows)
- **Check first:** read the hooks documentation. Is there an event that fires before compaction,
  and can its output reach the model? If no, or unclear: **skip this task** and write one line in
  the changelog saying so.
- **Steps (only if yes):** add a hook that prints one line: "shipkit: context is about to be
  compacted — run /shipkit:handoff if work is in flight."
- **Done when:** either a smoke check shows the line, or the changelog records the skip.

### S5-T-REL — Release 3.6.0

---

## Sprint 6 — Live decisions and the studio digest (3.7.0)

**Goal.** Decisions tell you when they have stopped being true. One page tells you which product
needs you this week.

**Branch.** `sprint-6/decisions-and-digest`

### S6-T0 — Write the sprint spec
Folder `.shipkit/specs/decisions-and-digest/`. Decision records needed: executable checks at all
(A6); exit status 0 meaning "fired"; local script versus cloud agent (A7).

### S6-T1 — An optional check line on decision records
- **Files:** edit `plugins/shipkit/skills/spec/reference.md`, `skills/decide/SKILL.md`,
  `plugins/shipkit/rules/decisions.md`.
- **The format** — one new optional line after the falsifiability line:

  ```markdown
  **Falsifiability.** We would reverse this if the routes file passes 500 lines.
  **Fired-if.** `test "$(wc -l < config/routes.rb)" -gt 500`
  ```

  The command exits 0 when the condition has come true. If the condition cannot be measured from
  the repository (user counts, latency), write `**Fired-if.** manual`.
- **Steps:** add the line to the template; `/shipkit:decide` asks "can a command check this?" and
  writes the command or `manual`. Stay inside the byte budget.
- **Done when:** lint is clean; the template shows both forms.

### S6-T2 — `decision-check.sh`
- **Files:** create `plugins/shipkit/scripts/decision-check.sh`; edit `scripts/smoke.sh`.
- **Usage:** `decision-check.sh <project-dir> [--run]`
- **Steps:**
  1. Find every `**Fired-if.**` line in `.shipkit/decisions/*.md` and `.shipkit/specs/*/design.md`.
  2. **Without `--run`:** print each command and the record it came from. Run nothing. Exit 0.
  3. **With `--run`:** run each command from the project folder. Print one line per decision:
     `FIRED`, `HOLDS`, `MANUAL` (with the clause text), or `ERROR` (exit status above 1).
  4. Exit 1 if anything is `FIRED`, else 0.
- **Safety rules, all required:** it is never called from any hook; the default is to list, not
  run; the script's header comment says "these commands come from the repository — read them
  before using `--run` in a repository you do not trust".
- **Done when:** smoke checks pass for: no flag → commands listed and a marker file the command
  would create does **not** exist; `--run` with a true condition → `FIRED`, exit 1; a false one →
  `HOLDS`, exit 0; `manual` → `MANUAL`; `grep -r decision-check plugins/shipkit/hooks` finds nothing.

### S6-T3 — Teach the elders and the gate
- **Files:** edit `plugins/shipkit/agents/grandfather.md`, `agents/eve.md`, `skills/ship/SKILL.md`.
- **Steps:** for "are any decisions falsified?", the elders run `decision-check.sh` without
  `--run`, show the commands, and run with `--run` only for a project in the registry. Add a
  step 8 to the ship gate: no decision is `FIRED` (a `FIRED` one makes the result `NOT READY`
  until the owner writes a superseding record or says to proceed).
- **Done when:** lint is clean; the ship smoke checks still pass.

### S6-T4 — `portfolio-digest.sh`
- **Files:** create `plugins/shipkit/scripts/portfolio-digest.sh`; edit `scripts/smoke.sh`.
- **Usage:** `portfolio-digest.sh [registry-file] [--run-checks]`. Default registry:
  `~/.claude/shipkit/project-registry.md`. It uses no model.
- **What it writes:** `~/.claude/shipkit/digests/<date>.md`, one section per project, each with
  exactly these lines:

  | Line | Where it comes from |
  |------|---------------------|
  | Top goal and review date | `.shipkit/product.md` |
  | Open specs and task progress | `tasks.md` files |
  | Spec gaps | `spec-check.sh` |
  | Decisions fired or needing a manual look | `decision-check.sh` (runs commands only with `--run-checks`) |
  | Escapes in the last 30 days, by cause | `.shipkit/escapes/` |
  | Map age in commits | the map's stamp |
  | Uncommitted files and unpushed commits | `git status`, `git log @{u}..` |

  A project whose folder is missing gets one line, `path not found`, and the script goes on.
- **Done when:** smoke checks pass on a scratch registry with two projects and one missing path:
  the file is written, has three sections, and the script exits 0.

### S6-T5 — `/shipkit:ask --all digest`
- **Files:** edit `plugins/shipkit/skills/ask/SKILL.md`, `plugins/shipkit/agents/eve.md`,
  `plugins/shipkit/scripts/briefing.sh`, `GUIDE.md`.
- **Steps:**
  1. `--all digest` runs `portfolio-digest.sh`, then gives the result and `studio.md` to `eve`.
  2. `eve` answers one question: **"Which product needs attention this week, and why?"** — a
     ranked list, at most three, each reason tied to a line in the digest and a studio priority.
  3. `briefing.sh` adds one line when the newest digest is more than seven days old.
  4. `GUIDE.md` shows how to schedule the script weekly with `cron` or `launchd`, as an option.
  5. **Check first, optional:** can a scheduled cloud agent run this? Write the answer in
     `GUIDE.md`. Do not build on it either way.
- **Done when:** lint is clean; smoke checks cover the "digest is old" line; an eval case shows
  `eve`'s answer names a product and cites a digest line.

### S6-T-REL — Release 3.7.0

---

## Sprint 7 — Trim and tell the story (4.0.0)

**Goal.** Less to load, a clear pitch, and one worked example.

**Branch.** `sprint-7/trim-and-docs`

### S7-T0 — Write the sprint spec
Folder `.shipkit/specs/trim-and-docs/`.

### S7-T1 — The audit table (proposes; changes nothing)
- **Files:** create `docs/design/trim-audit-4.0.md`.
- **Steps:** one row for each of: the six path-scoped rules, every stack overlay rule, every
  skill in `shipkit-workflows`, and `PROJECT_MAP.md` as the default (using decision 0001).
  Columns: lines, bytes, **verdict** (`keep`, `trim`, `cut`), reason.
  A line of a rule **stays** only if it (a) holds a value specific to the project, (b) names a
  specific trap that is not obvious (for example "`mount/3` runs twice"), or (c) an eval shows it
  changes the result. Everything else is `trim`.
- **Done when:** the table is complete. **Stop. Show it to the owner. Wait for a decision on
  every `cut` row (A8).**

### S7-T2 — Apply the approved trims
- **Depends on:** the owner's answer to S7-T1.
- **Steps:** apply `trim` rows. Apply only the `cut` rows the owner approved. Every stack rule
  ends at 40 lines or fewer. Shorten every skill description to 300 characters or fewer and add a
  lint check for that limit.
- **Done when:** lint is clean (including the new limit); smoke and evals pass; every cut is
  listed in the changelog with what to use instead.

### S7-T3 — Rewrite the README
- **Files:** edit `README.md`.
- **Steps:** new order: what it is (five lines) · install · **the loop** (product → intake → spec
  → brief → build → review → ship → escape → digest) with one command per step · what runs by
  itself · what you invoke · uninstall. Move all "New in X.Y" text to the changelog. Keep the
  honest "what verified means" paragraph.
- **Done when:** no version history above the install section; every command shown exists
  (`grep` each skill name against `plugins/*/skills/`); 250 lines or fewer.

### S7-T4 — One worked example in the guide
- **Files:** edit `GUIDE.md`.
- **Steps:** add "Playbook 4 — one feature from idea to shipped", using the refunds feature in the
  fixture app. Show the real file written at each step. Use real output, not invented output.
- **Done when:** each of the nine steps of the loop appears with its command and the file it produced.

### S7-T5 — Update the roadmap
- **Files:** edit `ROADMAP.md`.
- **Steps:** mark Sprints 1 to 7 as shipped with their versions. State the new north star in one
  sentence. List what is still open.
- **Done when:** the status line names version 4.0.0.

### S7-T-REL — Release 4.0.0
If no `cut` row was approved, release as 3.8.0 instead: nothing breaking happened.

---

## 5. What this plan does not do

- It does not build an orchestrator. Claude Code starts and runs the agents. Shipkit supplies the
  brief going in and the checks coming out.
- It does not start a team of agents at session start. It prints a short briefing instead
  (the reasons are recorded in S5-T0).
- It does not deploy, push, merge or tag on the owner's behalf, except in the release task of
  each sprint, which the owner has approved by approving this plan.
- It does not add role-play agents (product manager, architect). The agents differ by what they
  are shown and what they may change, not by title.
- It does not touch MemPalace, the installer, or `/shipkit:unsetup`, beyond what each task lists.

## 6. Risks, and what we do about each

| Risk | What we do |
|------|-----------|
| The smaller rules stop working | Evals before and after (S1-T5, S1-T6). No regression, or the change does not merge |
| Too many skills (A2 adds five) | Each new description is 300 characters or fewer; Sprint 7 audits the whole set |
| The new spec format breaks existing users' specs | A spec with no `Status` line behaves exactly as today (S2-T2, S2-T3 test this) |
| A decision check runs a harmful command | Lists by default, runs only with `--run`, never from a hook (S6-T2 tests all three) |
| Eval results vary from run to run | Run each case three times; a case passes if two of three pass; record the raw counts |
| Evals cost money on every run | They run before a release, not on every push. CI runs lint and `spec-check` only |
| A platform feature we rely on changes | Every such feature has a "Check first" step and a written fallback (section 3) |
| The plan itself is wrong somewhere | Rule 6 in section 1: stop and say so |

## 7. Approval

To approve: reply with "approved", or with the IDs from section 2 you want changed
(for example "approved, but A2: fold intake into spec, and A5: commit state.md").
Work starts with S1-T0 on the branch `sprint-1/measure-and-slim`.
