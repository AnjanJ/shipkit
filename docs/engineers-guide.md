# Shipkit for Software Engineers

A task-by-task guide to working with shipkit day to day. It is organised around what you are
trying to do: set up a repository, build a feature, hand work to an agent, fix a bug that got
out, pick up where yesterday's session stopped. For every skill, agent and script one by one,
see the [reference guide](../GUIDE.md).

Written for shipkit 5.3.0.

---

## Contents

1. [What shipkit is, in one page](#1-what-shipkit-is-in-one-page)
2. [Install and first session](#2-install-and-first-session)
3. [Set up a repository](#3-set-up-a-repository)
4. [What happens without you asking](#4-what-happens-without-you-asking)
5. [Small changes: just ask](#5-small-changes-just-ask)
6. [A feature, from idea to shipped](#6-a-feature-from-idea-to-shipped)
7. [Handing tasks to agents](#7-handing-tasks-to-agents)
8. [Recording decisions](#8-recording-decisions)
9. [Bugs: in development and in production](#9-bugs-in-development-and-in-production)
10. [Understanding a codebase](#10-understanding-a-codebase)
11. [Ending a session, starting the next](#11-ending-a-session-starting-the-next)
12. [Inherited code and big upgrades](#12-inherited-code-and-big-upgrades)
13. [Many projects at once](#13-many-projects-at-once)
14. [The workflows plugin](#14-the-workflows-plugin)
15. [Every command: when, why and how](#15-every-command-when-why-and-how)
16. [Where everything lives](#16-where-everything-lives)
17. [Troubleshooting](#17-troubleshooting)
18. [Cheat sheet](#18-cheat-sheet)

---

## 1. What shipkit is, in one page

Shipkit is a pair of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugins.
They give a solo engineer, or a small team, the habits a good senior colleague brings:

- **It writes intent down.** What the product is for, what a feature must do, and why a design
  choice was made all go into plain Markdown files under `.shipkit/`, which you commit with the
  code. You, a script and next week's session can all read them.
- **It asks before it builds.** A non-trivial request gets checked against your product's
  non-goals, open specs and past decisions, and then you get a few questions whose answers
  change what gets built.
- **It checks work against intent.** Requirements are numbered, each test cites the requirement
  it proves, and a script reports any requirement with no task or no test. At ship time a
  reviewer that never saw your reasoning reads the diff against the spec.
- **It won't call work done without proof.** Tests run, bugs are reproduced before and after
  the fix, and the ship gate pastes the evidence for every check it makes.

The two plugins:

| Plugin | What it gives you | Needs the other? |
|---|---|---|
| `shipkit` | The loop (product, intake, spec, ship, escape), decision records, handoffs, the elders (research agents), the always-on rules, stack overlays | No |
| `shipkit-workflows` | Opinionated engineering workflows: commit, QA, strict TDD, debugging, legacy audits, migration plans, humanizing prose | No |

**What shipkit does not do.** It never deploys, pushes, merges or tags. It doesn't replace
your test runner, CI or code review tool. Most of it is Markdown that Claude reads, plus a few
POSIX shell scripts that need no model and no network.

---

## 2. Install and first session

### Install

Inside Claude Code:

```
/plugin marketplace add https://github.com/AnjanJ/shipkit.git
/plugin install shipkit@shipkit
/plugin install shipkit-workflows@shipkit      # optional
```

**Restart Claude Code.** Plugins and their hooks load when a session starts.

### What the first session shows

The session hook prints a few context lines that start with `shipkit:`. The ones you will see
first:

```
shipkit: plugin root is ~/.claude/plugins/cache/shipkit/shipkit/5.3.0
shipkit: version 5.3.0
shipkit: run /shipkit:product or /shipkit:setup to turn on spec-driven work here (...)
```

- **The plugin root** is where the scripts live. This guide writes it as `<plugin root>`. The
  hook also saves it to `~/.claude/shipkit/plugin-root`, so in a terminal you can do:

  ```sh
  SK="$(cat ~/.claude/shipkit/plugin-root)"
  sh "$SK/scripts/spec-check.sh" .
  ```

- **The opt-in line** shows up in any project that has neither `.shipkit/` nor
  `.claude/rules/shipkit/`. In those projects only the general care-and-commit rule is loaded;
  the spec-driven and decision-record rules wait until the project opts in. That keeps
  shipkit cheap in repositories where you don't use it.

### Updating

Run this in a terminal, then restart Claude Code:

```sh
claude plugin marketplace update shipkit
claude plugin update shipkit@shipkit --scope user
claude plugin update shipkit-workflows@shipkit --scope user
```

If `claude plugin list` shows an install with `Scope: local` or `Scope: project`, run the two
`update` lines again with that scope, from inside that project. When a newer version is
installed but the session you're in still runs the old one, the hook tells you:
`shipkit: 5.4.0 is installed; this session runs 5.3.0 — restart to use it.`

### Running from a checkout

If you're working on shipkit itself, or want an unreleased branch:

```sh
claude --plugin-dir ~/code/shipkit/plugins/shipkit \
       --plugin-dir ~/code/shipkit/plugins/shipkit-workflows
```

---

## 3. Set up a repository

Setup is optional: the skills, agents and hook all work without it. It's worth running once
per repository you'll work in for more than a day, because it is the only way to get:

- the **path-scoped rules** (tests, migrations, dependency files, monorepo manifests, UI
  files), which load only as files under `.claude/rules/`;
- a short **`CLAUDE.md`** of project facts, including the **test command** the ship gate runs;
- the **stack overlay** for your framework;
- a chosen **workflow style**.

### Run it

```
/shipkit:setup
```

Or name the overlays yourself: `/shipkit:setup rails hotwire react`.

Setup goes through these steps:

1. **Detects your stack.** One base (`rails`, `python`, `go`, `elixir`, `react`, `static`)
   plus any add-ons (`hotwire`, `react` inside Rails or Elixir, `liveview`, `oban`, `ml`).
   It also finds your test framework and package manager, then asks you to confirm the whole
   set in one question.
2. **Asks a few questions:** the project's purpose in one line, the workflow style, and
   optionally a branch prefix and how you like PR descriptions.
3. **Backs up before it writes anything:**
   - `.shipkit-baseline/` holds the project as it was before shipkit ever touched it. It is
     written once and never overwritten.
   - `.shipkit-backup-<timestamp>/` holds the state before this particular run.

   It offers to add both, plus `.shipkit-recovery-*/` and `.shipkit/state.md`, to
   `.gitignore`.
4. **Writes `CLAUDE.md`**, facts only: purpose, stack, commands, key paths, workflow style.
   Rules don't go in it.
5. **Installs the eight shipkit rules** to `.claude/rules/shipkit/`. From then on the hook
   stops injecting them, so nothing loads twice.
6. **Installs the overlay's rules** and its section of `CLAUDE.md`. If the overlay ships
   skills (Rails has `/new-feature` and `/release`, for example), setup asks once whether you
   want them, because each one is listed in every session of that project.

### Choose a workflow style

The `Workflow style:` line in `CLAUDE.md` decides how much ceremony Claude applies:

| Style | Tests | Specs for non-trivial work |
|---|---|---|
| `strict-tdd` | A failing test before any production code, every time. With `shipkit-workflows` installed, `/shipkit-workflows:tdd` enforces it. | Files under `.shipkit/specs/` |
| `test-first` (default) | Test before implementation where practical; skipping is fine for config, docs, generated code and prototypes, and Claude says when it skips | Files under `.shipkit/specs/` |
| `lightweight` | Tests where they earn their keep | The three questions are answered inline in the chat. Files are written only when you ask, or when you run `/shipkit:spec` |

Decision records apply in full under every style.

### Re-run after upgrades

When you upgrade the plugin, the hook notices that the rule copies in your project are older:

```
shipkit: installed rules are from shipkit 5.2.0 and the plugin is 5.3.0 — run /shipkit:setup to refresh .claude/rules/shipkit/.
```

Run `/shipkit:setup` again. If you've edited a skill or a `CLAUDE.md` section that shipkit
installed, setup leaves it alone and asks you first.

### Other setup subcommands

| Command | Use it to |
|---|---|
| `/shipkit:setup rules <rule>` | Add, change or remove a project rule in `CLAUDE.md`. Don't edit rules by hand. |
| `/shipkit:setup audit` | See what this project loads into every session, and where the bloat is |
| `/shipkit:setup memory` | Set up MemPalace so the elders can recall past conversations (optional) |
| `/shipkit:setup remove` | Undo setup. It snapshots the current state first, then removes only what shipkit installed |

---

## 4. What happens without you asking

This is the part of shipkit you never invoke.

### The always-on rules

Three short rules, about 3,000 bytes together:

- **`shipkit.md`** (every session):
  - Never say "done" without proof.
  - Fix root causes, and after two or three failed tries stop and rethink.
  - Read the current docs for an unfamiliar API.
  - Change only what the task needs.
  - Stop and ask before anything destructive (deleting files, dropping tables, force-pushing,
    `reset --hard`, major upgrades, paid API calls).
  - One logical change per commit, staged by name, never `--no-verify`.
- **`spec-driven.md`** (projects that opted in): non-trivial work answers three questions
  (what, how, how we'll know it's done) and waits for your yes before any code.
- **`decisions.md`** (projects that opted in): a real choice between alternatives gets a
  five-part record with a concrete reversal condition.

### The path-scoped rules

These load only when Claude touches a matching file, and only after setup:

| Rule | Loads on | Holds |
|---|---|---|
| `testing.md` | `*_test.*`, `*.spec.*`, `test/`, `spec/`, `tests/` | Reuse existing factories and helpers; never add a second test runner |
| `migrations.md` | `migrations/`, `db/migrate/`, … | A heading only; the stack overlays add the migration traps (the Django rule, for example) |
| `dependencies.md` | `Gemfile`, `package.json`, lockfiles, `go.mod`, `mix.exs`, … | No unpinned versions, no bare `bundle update` / `npm update`, explain any downgrade |
| `monorepo.md` | `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `lerna.json` | A shared-package change isn't done until its consumers' tests pass |
| `ui-ux.md` | Components, views, templates, styles, mobile screens | The WCAG 2.2 AA baseline, plus empty, loading and error states |

### The session briefing

In a project with `.shipkit/`, every session starts with at most eight lines on where things
stand. For example:

```
shipkit: refunds: 1 of 3 tasks done, next T2 — Refund a charged order
shipkit: spec-check: 2 gap(s) — run spec-check.sh
shipkit: top goal: Cut failed charges — under 2% by 2026-12-31
shipkit: last handoff (2026-11-07, 3 commits ago): Finish T2's over-refund test, then run the suite
```

It can also warn you that the code has drifted from something written about it:

```
shipkit: refunds: 14 commits have touched its paths since it was accepted — the code may have drifted from the spec.
shipkit: PROJECT_MAP.md is 52 commits behind HEAD — run /shipkit:map refresh so the elders stay accurate.
```

If there's nothing to say, it prints nothing.

### The commit guard

A `PreToolUse` hook blocks a `git commit` from Claude when a staged file looks like a secret:
`.env`, `.env.*` (but not `.env.example`), `*.pem`, `*.key`, `id_rsa*`, `credentials*.json`.
It checks file names only, never contents. It's a seat belt, not a secret scanner, and it
doesn't see commits you type in your own terminal.

### Auto-invoked skills

Each skill's description says when it should and shouldn't trigger, so Claude picks one
without being told. Describe a real architectural choice and `/shipkit:decide` runs. Ask for a
multi-file feature and `/shipkit:spec` runs. A test fails and `/shipkit-workflows:debug` runs.
Type the name to force one.

---

## 5. Small changes: just ask

Most requests are small. A rename, a typo, a config value, a one-liner, or anything you
prefix with "just do it" is **trivial**: no intake, no spec, no plan. Claude does the change
and tells you it skipped the ceremony.

```
> Rename `fetch_usr` to `fetch_user` everywhere.
```

It still follows the care rules: it runs the tests, keeps the change to what you asked, and
when you ask it to commit, it commits that one change, staged by name.

**Where the line is.** A feature, a refactor, an integration or an architecture change is
non-trivial. If you're not sure, ask: "Is this trivial or does it need a spec?" Claude will
say which and why.

---

## 6. A feature, from idea to shipped

This is the core loop. Each step writes a file, so you can stop at any point and pick up
later, in another session or on another machine. The running example is adding refunds to a
small order service.

```
product  →  intake  →  spec  →  build (task by task)  →  ship
 (once)     (per feature, before the spec)                 (the gate)
```

### Step 1: Say what the product is for (once per project)

```
/shipkit:product
```

This writes `.shipkit/product.md`, 60 lines at most:

- a one-line purpose and the users;
- **up to three goals for this quarter**, each with a metric, a target and a date;
- the **non-goals**: what the product deliberately won't do.

Claude reads your README, `CLAUDE.md` and project map first and asks only what they don't
answer, eight questions at most. It never invents a metric. A gap is written as
`metric: none set` so you can see it.

The non-goals matter most. Intake checks every request against them. Revisit the file each
quarter with `/shipkit:product <what changed>`, which updates it instead of starting over.

### Step 2: Intake, the questions before the spec

```
/shipkit:intake Add refunds: a support agent can refund a charged order, in full or in part.
```

Intake does three things, in this order:

1. **Names conflicts first.** A request that hits a non-goal, overlaps an open spec or
   contradicts a decision record is quoted with the file and line it conflicts with. A
   conflict doesn't block you, but if you go ahead, the non-goal or decision has to change
   first.
2. **Asks at most four questions,** and only ones whose answers change what gets built.
   Anything a sensible default can settle is written down as an assumption you can object
   to.
3. **Writes `.shipkit/specs/refunds/intake.md`:** the request, the goal it serves, the
   conflicts, your answers, the assumptions and what's out of scope.

You can skip running it by hand, because `/shipkit:spec` runs intake itself when no
`intake.md` exists.

### Step 3: Spec, the three questions

```
/shipkit:spec refunds
```

This is an interview with two approval gates. It writes three files to
`.shipkit/specs/refunds/`.

**Q1: What are we building? → `spec.md`**

Requirements in EARS form (Easy Approach to Requirements Syntax), numbered, one testable behaviour
each:

```markdown
> Spec accepted at commit `790c2f5` on feature/refunds.
> Status: open
> Paths: app/billing.py, tests/test_refunds.py

- **REQ-3.** When a refund of an amount no larger than the charged amount is requested for a
  charged order, the system shall ask the gateway to refund that amount against the charge
  receipt and store the gateway's refund number on the order.
- **REQ-5.** If the requested refund amount is larger than the charged amount, then the
  system shall refuse the refund with `RefundRefused` without calling the gateway.
```

The five EARS patterns:

| Pattern | Template |
|---|---|
| Ubiquitous | The `<system>` shall `<response>`. |
| State-driven | While `<precondition>`, the `<system>` shall `<response>`. |
| Event-driven | When `<trigger>`, the `<system>` shall `<response>`. |
| Optional | Where `<feature>`, the `<system>` shall `<response>`. |
| Unwanted | If `<trigger>`, then the `<system>` shall `<response>`. |

If a requirement needs "and", split it. A requirement that can only be checked by reading
(README wording, say) ends with `[untested: <reason>]`.

**Gate 1:** you approve the requirements. This is the cheapest place to catch a
misunderstanding. When you approve, Claude stamps the commit, sets `Status: open`, and agrees
`Paths:` with you: the files and folders the feature will live in. Drift warnings count only
commits that touch those paths.

**Q2: How should it work? → `design.md`**

Every real design choice becomes a decision record (see [section 8](#8-recording-decisions)),
citing the requirements it serves.

Before the design gate, the **goldfish** reads the spec cold. It's an agent that gets only the
folder name, as an implementer would. It lists everything a test author would have to guess.
Each finding is either `fixed` (the spec now answers it), `contested` (the answer is already
in a file, cited by path and line) or `escalated` to you. If you accept a gap without fixing
it, that's recorded under `## Goldfish` in `spec.md`. Say "no goldfish" to skip the read; the
skip is recorded too.

**Gate 2:** the design, the goldfish's reply and each finding's disposition come to you in
plan mode for approval.

**Q3: How will we know it's done? → `tasks.md`**

```markdown
- [ ] **T1** Record the charge on the order → REQ-1, REQ-2
  - Files: app/billing.py, tests/test_refunds.py
  - Test: tests/test_refunds.py::ChargeOrderTest::test_a_charge_is_stored_on_the_order
  - After: none
  - Done when: `python3 -m unittest discover -s tests -p "test_refunds.py"` → all pass
- [ ] **T2** Refund a charged order, and refuse bad refunds → REQ-3, REQ-4, REQ-5
  - Files: app/billing.py, tests/test_refunds.py
  - Test: tests/test_refunds.py::RefundOrderTest::test_refund_over_charge_is_refused
  - After: T1
  - Done when: `python3 -m unittest discover -s tests -p "test_refunds.py"` → all pass
```

Every task has four sub-lines:

| Line | Meaning |
|---|---|
| `Files` | The only files this task may change |
| `Test` | The test that fails before the work and passes after |
| `After` | Tasks that must finish first, or `none` |
| `Done when` | The command to run and what it must show |

**The sharing rule:** if two tasks list the same file, the later one must come after the
earlier one. That's what makes parallel work safe (see [section 7](#7-handing-tasks-to-agents)).

Claude then runs `spec-check.sh` on the draft and fixes what it reports before handing the
spec to you.

**Re-run one phase** with `/shipkit:spec refunds requirements`, `... design` or
`... tasks`. An existing spec is refined, not overwritten.

### Step 4: Build, task by task

With the spec accepted, ask Claude to do T1. Under `test-first` or `strict-tdd` it writes the
task's test, watches it fail, writes the code, and watches it pass. Then it ticks the task
(`- [x]`) and commits.

**Every test cites its requirement** in a comment or in the test's name, as
`<spec folder>/REQ-N`:

```python
def test_refund_over_charge_is_refused(self):
    # refunds/REQ-5
    ...
```

The folder name is required because every spec has its own `REQ-1`. A citation inside a `.md`
file, `docs/` or `.shipkit/` doesn't count.

Check traceability whenever you like:

```sh
sh "$SK/scripts/spec-check.sh" . refunds
```

| Line | Means |
|---|---|
| `MISSING-TASK refunds REQ-4` | No task mentions REQ-4 |
| `PENDING-TEST refunds REQ-5` | Open spec, nothing cites REQ-5 yet. Information only: the test is owed at ship time |
| `MISSING-TEST refunds REQ-5` | The spec is shipped and nothing cites REQ-5 |
| `WAIVED refunds REQ-9` | REQ-9 is marked `[untested: …]` |
| `MISSING-FIELD`, `BAD-AFTER`, `CONFLICT`, `CYCLE`, `STRAY-STATUS` | `tasks.md` is malformed: a missing sub-line, an unknown task in `After`, two tasks sharing a file with no order between them, a dependency loop, or a `Status:` line outside `spec.md` |

Add `--as-shipped` to see what the ship gate will demand. The script exits 1 when it finds any
gap.

### Step 5: Ship, the gate

```
/shipkit:ship refunds
```

(Optionally add a base ref. The default is the merge base with `main` or `master`.)

The gate runs eight checks and **runs every one even after a failure**, so you see the whole
picture:

| # | Check | Passes when |
|---|---|---|
| 1 | Spec check, as shipped | Every requirement has a task and a citing test |
| 2 | Tests | The project's test command (from `CLAUDE.md`) exits 0 |
| 3 | Tasks ticked | No `- [ ]` left in `tasks.md` |
| 4 | Independent review | The `reviewer` agent, given only the slug and base ref, ends `VERDICT: PASS` |
| 5 | Migration rollback | No migration in the diff, or its rollback is written down |
| 6 | Decisions | Every live decision has a concrete reversal condition |
| 7 | Clean tree | Nothing uncommitted (judged as the tree was before the gate ran) |
| 8 | Decisions fired | No `Fired-if` command reports that its condition came true |

The report goes to `.shipkit/releases/<date>-refunds.md`. Its first line is exactly `READY` or
`NOT READY`, followed by the table, a `To fix before shipping` list, and the evidence for every
step: the command, its exit code and the last lines of its output.

The reviewer gives one verdict per requirement: `MET` with a file and line, `NOT MET`, or
`CANNOT TELL`. It also lists changes the spec didn't ask for and decisions the code didn't
follow. It's deliberately told nothing about what you built.

After `READY`, Claude asks whether to set the spec's status to `shipped`. The gate never
deploys, pushes, merges, tags or edits code. Merging and releasing are yours to do.

### Spec statuses

| Status | Means | Who sets it |
|---|---|---|
| `draft` | Being written | `/shipkit:spec` |
| `open` | Accepted, work in progress. The briefing tracks it | Gate 1 |
| `shipped` | Done; spec-check now demands a test for every requirement | You, after `READY` |
| `dropped` | Abandoned | You |

---

## 7. Handing tasks to agents

You can have a fresh agent, such as a headless `claude -p` or a worktree session, build a spec
task. Shipkit's rule: **the brief is a script's output, unchanged, and the agent's report is a
claim, not proof.**

### 1. Note where you are, and build the brief

```sh
BASE=$(git rev-parse HEAD)
sh "$SK/scripts/brief.sh" . refunds T1
```

`brief.sh` assembles the brief from the spec files with no model involved, so nothing is
paraphrased:

```markdown
# Brief: refunds / T1 — Record the charge on the order

## Requirement
- **REQ-1.** When an order is charged through `charge_order`, the system shall store ...

## You may edit
- app/billing.py
- tests/test_refunds.py
Nothing else. If the task cannot be done inside these files, stop and report blocked.

## Prove it with
- Test: tests/test_refunds.py::ChargeOrderTest::test_a_charge_is_stored_on_the_order
- Done when: `python3 -m unittest discover -s tests -p "test_refunds.py"` → all pass

## Report back in exactly this form
RESULT: done | blocked
CHANGED: <files>
TEST: <command> → <last lines of output>
NOT VERIFIED: <anything you did not check, or "nothing">
DEVIATIONS: <anything you did differently from this brief, or "none">
```

The full brief also carries the spec's goal, the tasks already done, the titles of the design
decisions that bind the agent, and what's out of scope.

### 2. Hand it over

```sh
claude -p "$(sh "$SK/scripts/brief.sh" . refunds T1)"
```

If the agent needs extra context, put it **below** the brief, never in place of any part of
it.

### 3. Verify, yourself

```sh
sh "$SK/scripts/brief-verify.sh" . refunds T1 "$BASE"
```

This prints an `OUTSIDE <file>` line for each changed or new file that isn't on the task's
`Files` list. Then **run the task's `Done when` command yourself.** An `OUTSIDE` line, or a
`Done when` that doesn't show what it should, means the task isn't done, whatever the report
says.

`OUTSIDE` lines for build artefacts (`__pycache__/`, `coverage/`) usually mean your
`.gitignore` is missing an entry, not that the agent wandered.

### Running tasks in parallel

A task can start once its `After` tasks are finished. Two ready tasks that share no file can
run at the same time, each in its own git worktree. The sharing rule guarantees that tasks
touching the same file are ordered.

Match the team to the work. A trivial change needs no agent. One task needs at most one
implementing agent. A research question goes to the elders. An agent started "just in case"
spends tokens before it has shown it was needed.

---

## 8. Recording decisions

A **decision record** is for a real fork: two or more alternatives you actually considered.
A default or a one-liner doesn't get one.

### Where it goes

| Scope | Home | How |
|---|---|---|
| One feature ("refund via the gateway's API, not a manual payout") | That spec's `design.md` | Written by `/shipkit:spec` |
| Project-wide ("Paddle over Stripe", "monolith over services") | `.shipkit/decisions/NNNN-<slug>.md` | `/shipkit:decide Paddle over Stripe` |

### The five parts

```markdown
## Decision: Postgres advisory locks for the refund queue   (→ REQ-6)

**Context.** Two workers can pick up the same refund; we run one Postgres and no Redis.

**Alternatives.**
1. Postgres advisory locks
2. Redis + Redlock
3. A `locked_by` column with `SELECT … FOR UPDATE SKIP LOCKED`

**Case for advisory locks.** No new infrastructure; the lock dies with the connection.

**Case against advisory locks.** Locks are invisible to most tooling, and a pooler in
transaction mode breaks session-level locks.

**Decision.** We chose Postgres advisory locks.
**Falsifiability.** We would reverse this if we add PgBouncer in transaction mode.
**Fired-if.** `git grep -q 'pool_mode *= *transaction' -- config`
```

- **Case against** is the honest argument against your own choice, and it's the part people
  skip. `/shipkit:decide` pushes for it.
- **Falsifiability** must be a metric, an event or a threshold. "If it doesn't work out" is
  rejected. If there's honestly no such condition, the record says "no clear reversal
  condition identified".
- **Fired-if** is optional: a read-only shell command that **exits 0 once the condition has
  come true** and exits 1 while it still holds. Write `manual` when the condition can't be
  measured from the repository (latency, user counts, cost). Use `git grep` rather than
  `grep -r`, so build output can't trigger it.

A superseded record is marked and points to its replacement. It's never deleted.

### Checking whether a decision has expired

```sh
sh "$SK/scripts/decision-check.sh" .          # lists every Fired-if command; runs nothing
sh "$SK/scripts/decision-check.sh" . --run    # runs them: FIRED / HOLDS / MANUAL / ERROR
```

The commands come from the repository. **Read the list before you use `--run` on code you
don't trust.** No hook ever runs them. The ship gate runs them on the project being shipped,
and `/shipkit:ask are any of our past decisions now falsified?` has `grandfather` run them for
you.

---

## 9. Bugs: in development and in production

### A test fails while you work

With `shipkit-workflows` installed, `/shipkit-workflows:debug` triggers on its own (or type
it). The rule is **no fix without a root cause first**:

1. Read the whole error, reproduce it, check what changed, and trace the bad value to its
   source.
2. Compare with similar code that works.
3. Form one hypothesis and test it with the smallest change.
4. Write a failing test that reproduces the bug, then fix it, then run everything.

After two or three failed fixes, it stops and reconsiders the approach. For a flaky test, ask
for the `test-analyzer` agent: "use the test-analyzer agent on this flaky test". It looks for
leaked state, timing, environment and test-order problems.

### A bug reached users

```
/shipkit:escape A refund of 25.00 was paid out on an order charged 20.00.
```

Fixing it is half the job. The other half is knowing why nothing caught it. Escape finds the
spec that covers the broken code and names **exactly one** cause, the first that's true in
this order:

| Cause | When |
|---|---|
| `no spec` | No spec covers the code |
| `requirement missing` | A spec covers it, but no requirement says what should have happened |
| `requirement wrong` | A requirement covers it and asks for the wrong behaviour |
| `requirement right, no test` | The requirement is right, and no test cites or exercises it |
| `test existed but was wrong` | A test cites the requirement and passed anyway |
| `outside the product (dependency, infrastructure)` | The code did what the spec asks; something else didn't |

It writes `.shipkit/escapes/NNNN-<slug>.md` and, when the spec was at fault, repairs it: it
adds or corrects the requirement, sets the spec back to `open`, and adds a task whose test
**fails now**. Escape doesn't fix the code itself. That task is the fix, done the normal way.

Escapes from the last 30 days show up in the portfolio digest, grouped by cause. If they keep
landing on `requirement right, no test`, you have a pattern worth fixing.

---

## 10. Understanding a codebase

### Ask the elders

The elders are research agents. They read in their own context and return a short answer with
`file:line` citations, so your session doesn't fill up with file dumps.

```
/shipkit:ask how does locale fallback work here?
/shipkit:ask is it safe to drop the legacy_token column?
/shipkit:ask why do we use advisory locks instead of Redis?
```

- **`grandfather`** answers about this project: architecture, where things live, why it was
  built that way, whether something is safe to change. It checks each claim against live
  source before stating it.
- **`eve`** answers across all your registered projects (see
  [section 13](#13-many-projects-at-once)).

**When not to use them:** when you're mid-edit and need one fact to keep typing, just read the
file. A subagent round trip is slower. The elders are also read-only: get the answer, then
make the change.

**Check the citations.** The elders are told to cite and to label uncertainty, but nothing
independently verifies that a citation supports its claim. The files are there for you to
check.

### Trace one feature end to end

```
/shipkit:ask --walk checkout            # or: --walk checkout surface
```

`grandfather` traces it from the trigger through every layer and back, with citations. It
offers to write `docs/code-walkthrough/checkout.md`, and only writes it if you say yes.

### Explain why the system is built this way

```
/shipkit:ask --system quick             # or: full, or: section <name>
```

This proposes a `docs/SYSTEM_DESIGN.md` with a table of claims and a table of opportunities.
Again, it's written only if you say yes.

### The project map (optional)

```
/shipkit:map                 # build, or refresh if one exists
/shipkit:map refresh         # force re-verification
/shipkit:map --register      # also add the project to eve's registry
```

`PROJECT_MAP.md` is an index of stack, structure, data model, how the project evolved, and
gotchas, with every path verified. **You don't need it to ask questions.** On a 224-file
project it changed neither the answers nor the number of tool calls (decision 0001). Build one
when you want `eve`'s portfolio view, or when the commit history is too thin to explain how
the project got here. The hook tells you when it's falling behind.

### Remember past conversations (optional)

`/shipkit:setup memory` sets up [MemPalace](https://github.com/mempalace/mempalace) so the
elders can answer "why did we pick X?" from past sessions. Skip it and they fall back to git
history; nothing breaks.

---

## 11. Ending a session, starting the next

### Leave a note

```
/shipkit:handoff
```

This writes `.shipkit/state.md`, at most 30 lines, replacing any earlier note:

```markdown
# Handoff

> Written 2026-11-07 at commit `a1b2c3d` on feature/refunds.

## In flight
- T2: over-refund test written and failing as it should (tests/test_refunds.py); code not started

## Done this session
- T1 built, verified, committed

## Next step
Make RefundOrderTest.test_refund_over_charge_is_refused pass in app/billing.py

## Open questions
- Should a refund on a disputed charge be refused? (REQ-7 is silent)

## Do not forget
- The gateway sandbox rate-limits at 10 req/s: run the suite with GATEWAY_FAKE=1
```

It builds the note from the conversation, `git status`, `git log` and the open tasks, and asks
you a question only if the next step is unclear. A `## Blocked on` heading appears only when
the next step can't start yet.

### What the next session sees

The briefing quotes the note's next step:

```
shipkit: last handoff (2026-11-07, 0 commits ago): Make RefundOrderTest.test_refund_over_charge_is_refused pass in app/billing.py
```

After a context compaction, the hook says so and suggests a handoff if work is in flight.

`state.md` is git-ignored by default, since it describes uncommitted work. To have it follow
you between machines, remove it from `.gitignore`.

---

## 12. Inherited code and big upgrades

### Taking over a repository

A good first hour:

1. `/shipkit:setup`: rules, overlay, `CLAUDE.md` with the test command.
2. `/shipkit:ask --system quick`: how it's built and why.
3. `/shipkit-workflows:legacy-audit`: dependency age, dead code, complexity hotspots and
   coverage gaps (or one of `deps`, `dead-code`, `complexity`, `coverage`).
4. `/shipkit:product`: write down what it's for and what it won't do, before anyone asks for
   features.
5. `/shipkit:map --register` if you'll want it in the portfolio view.

**Spec only the change.** For a brownfield feature, the spec locks what already exists and
describes only what you're changing.

### Planning a breaking upgrade

```
/shipkit-workflows:migration-plan rails 7.1 8.0
```

It reads the changelog first, analyses the impact on your code, and writes a step-by-step plan.
The `dependencies` rule then keeps the upgrade one named package at a time: no bare
`bundle update`. A major upgrade counts as destructive under the care rule, so Claude asks
before starting one.

---

## 13. Many projects at once

### Register projects

```
/shipkit:map --register
```

This adds a row to `~/.claude/shipkit/project-registry.md`: name, path, stack, where it
deploys, open specs, and the product's top goal.

### Ask across them

```
/shipkit:ask --all which apps deploy to Hetzner?
/shipkit:ask --all everywhere I integrate Stripe
/shipkit:ask --all matrix rails          # version matrix from lockfiles, one row per project
/shipkit:ask --all consolidate           # what exists N times that should exist once
```

`eve` answers some questions straight from the registry and labels those MEDIUM confidence.
They're snapshots, not live reads.

### Rank your products

```
/shipkit:product --studio
```

You rank up to five priorities across every product, and they're written to
`~/.claude/shipkit/studio.md`. The ranking is always yours; it's never inferred.

### The weekly digest

```
/shipkit:ask --all digest
```

This runs `portfolio-digest.sh` (no model) and writes `~/.claude/shipkit/digests/<date>.md`,
seven lines per project:

```
- Top goal: ...
- Open specs: refunds 1 of 3 tasks done, next T2
- Spec gaps: 0
- Decisions: ...
- Escapes (30 days): 1 — requirement right, no test 1
- Map: 12 commits old
- Git: 2 uncommitted file(s), 1 unpushed commit(s)
```

Then `eve` answers one question: **which product needs attention this week, and why?** You get
at most three products, each reason tied to a digest line and a studio priority.

To run it on a schedule, call the script from `cron` or `launchd`:

```sh
sh "$(cat ~/.claude/shipkit/plugin-root)/scripts/portfolio-digest.sh"
```

The [reference guide](../GUIDE.md) has a ready `launchd` plist. A digest more than a week old
gets a line in the session briefing.

---

## 14. The workflows plugin

`shipkit-workflows` works without `shipkit`, and the other way round.

| Skill | Use it when | Notes |
|---|---|---|
| `/shipkit-workflows:commit` | A task or fix is done | One atomic commit. A one-line subject for a trivial change; What / Why / How / Test plan for a substantive one |
| `/shipkit-workflows:qa [file\|all]` | You want coverage on recent changes | Five phases: find the framework, plan the gaps with you, write the tests, run them, report |
| `/shipkit-workflows:tdd [feature\|bugfix\|refactor]` | You want strict red-green-refactor | Iron law: code written before its failing test is deleted, not adapted. Runs automatically under `Workflow style: strict-tdd` |
| `/shipkit-workflows:debug` | A test fails or something is broken | Root cause before any fix (see [section 9](#9-bugs-in-development-and-in-production)) |
| `/shipkit-workflows:legacy-audit` | You've inherited a codebase | `deps`, `dead-code`, `complexity`, `coverage` or `all` |
| `/shipkit-workflows:migration-plan` | A breaking dependency upgrade | Changelog first |
| `/shipkit-workflows:humanize` | Docs, a README or a PR description reads as machine-written | Prose only, never code |
| `test-analyzer` agent | A test is flaky or fails for no obvious reason | Ask for it by name |

Each of these has a full entry in [section 15](#15-every-command-when-why-and-how).

**Code review** isn't in shipkit. Use Claude Code's built-in `/code-review`. The ship gate's
reviewer checks against the spec, which is a different question from code quality.

---

## 15. Every command: when, why and how

This section covers every command shipkit gives you, one entry each. Every entry follows the
same pattern:

- **Why:** the problem the command solves.
- **When:** the moment to reach for it, and when not to.
- **How:** the forms it takes, with real arguments.
- **Writes:** the files it leaves behind. "Nothing" means it only reports.

**Auto** says whether Claude may start the command on its own when your request matches it.
Every command can always be typed by name.

Commands come from three places:

- the `shipkit` plugin, as `/shipkit:<name>`;
- the `shipkit-workflows` plugin, as `/shipkit-workflows:<name>`;
- the stack overlays, as plain `/<name>` in the projects where setup installed them.

Shipkit also ships five scripts you run yourself; they are covered at the end of this
section.

### Quick index

| Command | One line | Auto |
|---|---|---|
| [`/shipkit:setup`](#shipkitsetup) | Install rules, overlay and `CLAUDE.md` in a project | No |
| [`/shipkit:setup remove`](#shipkitsetup-remove) | Undo setup | No |
| [`/shipkit:setup rules`](#shipkitsetup-rules) | Add, change or remove a `CLAUDE.md` rule | Yes |
| [`/shipkit:setup audit`](#shipkitsetup-audit) | What loads into every session | No |
| [`/shipkit:setup memory`](#shipkitsetup-memory) | Set up MemPalace recall for the elders | Yes |
| [`/shipkit:product`](#shipkitproduct) | Purpose, goals, non-goals | Yes |
| [`/shipkit:product --studio`](#shipkitproduct---studio) | Rank priorities across all products | No |
| [`/shipkit:intake`](#shipkitintake) | Conflicts and questions before a spec | Yes |
| [`/shipkit:spec`](#shipkitspec) | Requirements, design, tasks | Yes |
| [`/shipkit:ship`](#shipkitship) | The eight-check ship gate | Yes |
| [`/shipkit:escape`](#shipkitescape) | A bug reached users: which link broke? | Yes |
| [`/shipkit:decide`](#shipkitdecide) | A project-wide decision record | Yes |
| [`/shipkit:handoff`](#shipkithandoff) | A note for the next session | Yes |
| [`/shipkit:ask`](#shipkitask) | Ask about this project | Yes |
| [`/shipkit:ask --walk`](#shipkitask---walk) | Trace one feature end to end | Yes |
| [`/shipkit:ask --system`](#shipkitask---system) | Why the system is built this way | Yes |
| [`/shipkit:ask --all`](#shipkitask---all) | Ask across every registered project | Yes |
| [`/shipkit:ask --all matrix`](#shipkitask---all-matrix) | Version matrix from lockfiles | Yes |
| [`/shipkit:ask --all consolidate`](#shipkitask---all-consolidate) | What exists N times that should exist once | Yes |
| [`/shipkit:ask --all digest`](#shipkitask---all-digest) | Which product needs you this week | Yes |
| [`/shipkit:map`](#shipkitmap) | Build or refresh `PROJECT_MAP.md`; register the project | Yes |
| [`/shipkit-workflows:commit`](#shipkit-workflowscommit) | One atomic commit, message scaled to the change | Yes |
| [`/shipkit-workflows:qa`](#shipkit-workflowsqa) | Five-phase QA pass | Yes |
| [`/shipkit-workflows:tdd`](#shipkit-workflowstdd) | Strict red-green-refactor | Yes |
| [`/shipkit-workflows:debug`](#shipkit-workflowsdebug) | Root cause before any fix | Yes |
| [`/shipkit-workflows:legacy-audit`](#shipkit-workflowslegacy-audit) | Modernization audit of inherited code | Yes |
| [`/shipkit-workflows:migration-plan`](#shipkit-workflowsmigration-plan) | Plan a breaking upgrade | Yes |
| [`/shipkit-workflows:humanize`](#shipkit-workflowshumanize) | Remove AI writing patterns from prose | Yes |
| [`/new-feature`, `/release`, `/component`, `/audit`](#stack-overlay-commands) | Stack overlay commands | `/audit` only |
| [Scripts](#scripts) | `spec-check`, `brief`, `brief-verify`, `decision-check`, `portfolio-digest` | — |

---

### The `shipkit` plugin

#### `/shipkit:setup`

**Why.** Claude Code loads path-scoped rules only from a project's `.claude/rules/`, never
from a plugin. Setup copies them in. It also gives the ship gate a test command to run and
gives Claude the facts about your stack.

**When.**
- Once per repository you'll work in for more than a day.
- Again whenever the session hook says the installed rules are older than the plugin.
- Skip it for a quick look at someone else's repository: the skills work without it.

**How.**

```
/shipkit:setup                          # detect the stack, confirm it with you
/shipkit:setup rails hotwire react      # name the base and add-ons yourself
```

It asks you for:
- the project's purpose, in one line;
- the workflow style (`strict-tdd`, `test-first` or `lightweight`);
- optionally, a branch prefix and how you like PR descriptions;
- whether to install the overlay's skills, where it has any;
- whether to write a `.claude/settings.json` with safe defaults (optional).

**Writes.**
- `CLAUDE.md` (project facts only);
- `.claude/rules/shipkit/` (eight rules plus the overlay's);
- `.shipkit-baseline/` (first run only) and `.shipkit-backup-<ts>/`;
- `.gitignore` entries, if you agree.

#### `/shipkit:setup remove`

**Why.** It takes out exactly what setup put in, and nothing of yours.

**When.** You want shipkit's files out of one project, or a setup went wrong and you want the
earlier state back.

**How.**

```
/shipkit:setup remove
```

Before touching anything, it copies the current `CLAUDE.md` and `.claude/` to
`.shipkit-recovery-<ts>/`. It then shows you what it will restore and asks for your yes. A
file you have edited since setup is reported and kept unless you say otherwise. To remove the
plugin itself, follow this with `/plugin uninstall shipkit@shipkit`.

**Writes.** `.shipkit-recovery-<ts>/`, and restores `CLAUDE.md` and `.claude/` from the backup.

#### `/shipkit:setup rules`

**Why.** Rules edited by hand drift: they get duplicated, land in the wrong section, and the
file grows until it's ignored. This command checks for duplicates, files the rule where it
belongs, and shows you the diff.

**When.** You want Claude to follow a new project convention, or an existing one has changed.

**How.**

```
/shipkit:setup rules Never use puts for debugging; use Rails.logger
/shipkit:setup rules Test command is now bin/rspec, not bundle exec rspec
```

If `CLAUDE.md` passes 200 lines, it suggests what could move into a path-scoped rule instead.

**Writes.** `CLAUDE.md`.

#### `/shipkit:setup audit`

**Why.** Everything that loads into every session costs context before you've typed a word.
This command shows what loads, when it loads, and what could be trimmed.

**When.** Sessions feel slow or cramped, or you've added many rules, skills or plugins.

**How.**

```
/shipkit:setup audit
```

It explains what loads and why, but doesn't estimate percentages. For real token numbers, run
Claude Code's built-in `/context`.

**Writes.** Nothing.

#### `/shipkit:setup memory`

**Why.** Without memory, the elders can answer "why did we pick X?" only from git history.
MemPalace indexes your past Claude Code conversations locally, so the elders can recall what
was decided and when.

**When.**
- Once per machine, to install MemPalace and register it with Claude Code.
- Once per project, to backfill that project's history.
- Skip it if git history and decision records are enough for you; nothing breaks without it.

**How.**

```
/shipkit:setup memory
/shipkit:setup memory --wing billing      # name the project's wing yourself
/shipkit:setup memory --reinstall         # redo install and registration after a broken setup
```

It detects which steps are already done and skips them. It installs MemPalace with `uv` or
`pipx` (about 300 MB including the embedding model), shows a dry run of the backfill before
running it for real, and ends by asking you to restart Claude Code.

**Writes.** The MemPalace store under your home directory, and a user-scope MCP registration.

#### `/shipkit:product`

**Why.** Intake checks every request against your goals and non-goals. Without a product file,
there's nothing to check requests against.

**When.**
- Once per project, before the first spec.
- Again each quarter, or whenever priorities change.

**How.**

```
/shipkit:product
/shipkit:product we dropped the mobile app; refunds is now the top goal
```

It reads `README.md`, `CLAUDE.md` and `PROJECT_MAP.md` first, then asks at most eight
questions. It keeps at most three goals, each with a metric, a target and a date, and writes a
gap such as `metric: none set` rather than inventing a number. An existing file is updated,
never rewritten from scratch.

**Writes.** `.shipkit/product.md`, 60 lines or fewer.

#### `/shipkit:product --studio`

**Why.** One product file says what each product is for. Someone with several products also
has to say which comes first, and the weekly digest ranks against that.

**When.** You maintain more than one product and want `/shipkit:ask --all digest` to rank them
the way you would.

**How.**

```
/shipkit:product --studio
```

You rank at most five priorities across all products. Each priority names a product from the
registry, or `(studio)` for work that belongs to no product ("hire a designer").

**Writes.** `~/.claude/shipkit/studio.md`.

#### `/shipkit:intake`

**Why.** The most expensive bug is building the wrong thing. Intake is the colleague who says
"didn't we decide not to do that?" before the work starts.

**When.**
- A non-trivial feature request arrives and no spec exists yet.
- You can skip typing it: `/shipkit:spec` runs intake itself when `intake.md` is missing.
- It does nothing for trivial changes; it says "Trivial — no intake needed."

**How.**

```
/shipkit:intake Add refunds: a support agent can refund a charged order, in full or in part
```

It names conflicts first, with file and line: non-goals, open specs, past decisions. Then it
asks at most four questions whose answers change what gets built. Anything a sensible default
settles is written down as an assumption you can object to.

**Writes.** `.shipkit/specs/<slug>/intake.md`.

#### `/shipkit:spec`

**Why.** It turns an idea into something an agent can build and a script can check:
- numbered, testable requirements;
- design choices recorded with their alternatives;
- tasks that each name their files, their failing-first test, their order and their done
  condition.

**When.**
- Any feature, refactor, integration or multi-file change.
- Not for trivial work: it will say so and just do the change.

**How.**

```
/shipkit:spec refunds                  # all three questions, end to end
/shipkit:spec refunds requirements     # redo spec.md only
/shipkit:spec refunds design           # redo design.md only
/shipkit:spec refunds tasks            # redo tasks.md from the accepted spec and design
```

The run has two approval gates. The first is the requirements. The second is the design,
shown in plan mode after the goldfish agent has read the spec cold. Before handing the spec
over, Claude runs `spec-check.sh` and `decision-check.sh` on what it wrote and fixes any
findings. An existing spec is refined, not overwritten. Under the `lightweight` style,
non-trivial work gets its three answers inline in the chat, but typing `/shipkit:spec` always
writes the files. The details are in [section 6](#6-a-feature-from-idea-to-shipped).

**Writes.** `.shipkit/specs/<slug>/spec.md`, `design.md` and `tasks.md`.

#### `/shipkit:ship`

**Why.** "Done" is a claim; the gate checks it. It runs eight checks, keeps the evidence for
each, and has a reviewer that has heard none of your reasoning read the diff against the spec.

**When.**
- Before you merge or release a spec'd feature.
- Partway through, to see what is still missing.
- Not for work without a spec: it says so and stops.

**How.**

```
/shipkit:ship refunds                  # base = merge base with main or master
/shipkit:ship refunds 89e540d          # name the commit the work started from
```

It runs all eight checks even after one fails. The steps:

1. spec check, as shipped;
2. tests;
3. tasks ticked;
4. independent review;
5. migration rollback;
6. decisions have concrete reversal conditions;
7. clean tree;
8. no decision has fired.

After a `READY`, it asks whether to set the spec to `shipped`. It never deploys, pushes,
merges, tags or edits code.

**Writes.** `.shipkit/releases/<date>-<slug>.md`. Its first line is `READY` or `NOT READY`.

#### `/shipkit:escape`

**Why.** Fixing a production bug is half the job. The other half is knowing why nothing caught
it, so the same kind of bug is caught next time.

**When.**
- A bug was found by users or in production.
- Not for a test failing during development: that's `/shipkit-workflows:debug`.

**How.**

```
/shipkit:escape A refund of 25.00 was paid out on an order charged 20.00
```

It needs three facts: what users saw, what should have happened, and how it was noticed. It
asks for at most three that the description doesn't give. Then it names one cause from a
fixed list, from `no spec` through to `outside the product`. Where the spec was at fault, it
repairs the spec and adds a task whose test fails now. It doesn't fix the code; that task is
the fix.

**Writes.** `.shipkit/escapes/NNNN-<slug>.md`, and where the spec was at fault: the spec's
`spec.md` (a new or corrected requirement, `Status: open`) and `tasks.md` (the new task).

#### `/shipkit:decide`

**Why.** Six months on, nobody remembers why Postgres beat Redis. A record keeps the
alternatives, the honest case against the choice, and the condition under which you'd
reverse it. That condition can be a command a script runs.

**When.**
- A project-wide choice with two or more real alternatives.
- A choice inside one feature goes in that spec's `design.md` instead.
- A default with no real alternative doesn't get a record.

**How.**

```
/shipkit:decide Paddle over Stripe
/shipkit:decide one Postgres for queues and data, no Redis
```

The interview covers context, alternatives, case for, case against, and the decision with a
concrete reversal condition. It then asks whether a command can check that condition (a
`Fired-if` line), or whether it's `manual`. A record that supersedes an older one marks the
older one rather than deleting it.

**Writes.** `.shipkit/decisions/NNNN-<slug>.md`.

#### `/shipkit:handoff`

**Why.** The next session, tomorrow's or this one after compaction, starts blank. Its first
line of context should be the next thing to do.

**When.**
- You're stopping with work in flight: a half-done task, uncommitted changes, an open
  question.
- The hook says context was just compacted.
- Not when nothing is in flight.

**How.**

```
/shipkit:handoff
/shipkit:handoff the staging DB password rotates on Friday
```

It gathers what it needs from the conversation, `git status`, `git log` and the open tasks. It
asks one question only if it can't tell what the next step is.

**Writes.** `.shipkit/state.md`, replacing the old one, at most 30 lines. The file is
git-ignored by default.

#### `/shipkit:ask`

**Why.** Research floods a session with file dumps. An elder reads in its own context and
hands back a short answer with `file:line` citations, so your session stays lean for the work.

**When.**
- Research-shaped questions: how does X work here, where is Y, why was Z built this way, is it
  safe to change W, have any decisions been falsified.
- Not when you're mid-edit and need one fact: read the file yourself.
- Not to change code: the elders are read-only.

**How.**

```
/shipkit:ask how does locale fallback work here?
/shipkit:ask is it safe to drop the legacy_token column?
/shipkit:ask are any of our past decisions now falsified?
```

`grandfather` answers. It uses `PROJECT_MAP.md` as an index if there is one, and it checks
each claim against live source before stating it.

**Writes.** Nothing.

#### `/shipkit:ask --walk`

**Why.** It answers "how does checkout actually work?" with the whole path in one document:
from the trigger, through every layer, to the datastore and back.

**When.** You're about to change a feature you didn't write, onboarding someone, or debugging
across layers.

**How.**

```
/shipkit:ask --walk checkout                  # deep (default): adds error paths and side effects
/shipkit:ask --walk checkout surface          # happy path and data flow only
/shipkit:ask --walk app/billing.py            # a file works as the target too
```

`grandfather` traces it in trace mode and returns an entry-point table and a proposed
document.

**Writes.** `docs/code-walkthrough/<feature>.md`, only if you say yes. It never overwrites an
existing file.

#### `/shipkit:ask --system`

**Why.** It gives you a verified system-design document: why the system is built this way,
with every claim cited, plus a list of opportunities.

**When.** You've inherited a codebase, someone new is joining, or you're planning an
architectural change.

**How.**

```
/shipkit:ask --system                      # full (default): every phase, claims verified
/shipkit:ask --system quick                # a brief explainer; skips the verification loop
/shipkit:ask --system section decisions    # regenerate one section (decisions, flows, ...)
```

**Writes.** `docs/SYSTEM_DESIGN.md`, only if you say yes.

#### `/shipkit:ask --all`

**Why.** Questions that span your whole portfolio would otherwise mean opening every
repository yourself.

**When.** "Which of my apps…", "everywhere I…", "across all my projects…". You need projects
registered first (`/shipkit:map --register`).

**How.**

```
/shipkit:ask --all which apps deploy to Hetzner?
/shipkit:ask --all everywhere I integrate Stripe
/shipkit:ask --all which projects have an open spec?
```

`eve` answers from the registry and each project's map. Answers that come from the registry
alone are labelled MEDIUM confidence: they're snapshots, not live reads.

**Writes.** Nothing.

#### `/shipkit:ask --all matrix`

**Why.** For an upgrade or a vulnerability sweep, you need every project's real version of a
dependency, taken from its lockfile rather than its manifest.

**When.** A CVE lands, or you're planning a framework upgrade across projects.

**How.**

```
/shipkit:ask --all matrix rails
/shipkit:ask --all matrix "everything major"
```

**Writes.** Nothing. The answer has one row per project.

#### `/shipkit:ask --all consolidate`

**Why.** It finds code you maintain several times over: the same auth helper, retry wrapper
or deploy script in five repositories, each drifting from the others.

**When.** You're planning a shared library, or a fix just had to be made in several places.

**How.**

```
/shipkit:ask --all consolidate
```

**Writes.** Nothing. The answer is a ranked report, with evidence and drift notes for each
copy.

#### `/shipkit:ask --all digest`

**Why.** It answers "which product needs me this week, and why?" from facts on disk, not from
whichever repository you touched last.

**When.** Weekly, say Monday morning, or when the session briefing says the newest digest is
over a week old.

**How.**

```
/shipkit:ask --all digest
```

First `portfolio-digest.sh` writes one page across all registered projects; it uses no model.
Then `eve` ranks at most three products, tying each reason to a digest line and to a priority
in `studio.md`. The decision commands are counted, not run, unless you ask for them to be run.

**Writes.** `~/.claude/shipkit/digests/<date>.md`.

#### `/shipkit:map`

**Why.** `PROJECT_MAP.md` is an index of the project with every path verified: stack, entry
points, structure, data model, how the project evolved, gotchas. `eve`'s portfolio view
needs one. Registering the project is what makes it visible to `eve` at all.

**When.**
- You want the project in `eve`'s view: run it with `--register`.
- The commit history is too thin to explain how the project evolved.
- The hook says the map is behind.
- You don't need it just to ask `grandfather` questions: on a measured 224-file project, a map
  changed neither the answers nor the number of tool calls.

**How.**

```
/shipkit:map                     # build if absent, refresh if present
/shipkit:map refresh             # force re-verification against the source
/shipkit:map section evolution   # regenerate one section
/shipkit:map --register          # map, then add or update the registry row
```

It runs in its own context and can't ask you questions mid-run.

**Writes.** `PROJECT_MAP.md` (at the repo root, or under `docs/`), and with `--register`, a
row in `~/.claude/shipkit/project-registry.md`.

---

### The `shipkit-workflows` plugin

#### `/shipkit-workflows:commit`

**Why.** One logical change per commit, staged by name, with a message as long as the change
deserves. A substantive commit's message records what was rejected and why, so it can be
reviewed and reverted on its own.

**When.** A task or fix is done and verified. Not while you're mid-edit, and not when you've
said you'll commit yourself.

**How.**

```
/shipkit-workflows:commit
/shipkit-workflows:commit emphasise the migration's rollback
```

A trivial change gets a subject line. A substantive one gets What / Why / How / Test plan.
It never uses `git add .`, never `--no-verify`, and never stages secrets.

**Writes.** A git commit.

#### `/shipkit-workflows:qa`

**Why.** It finds what your recent change left untested, guided by risk rather than coverage
percentage, and writes those tests.

**When.** After a change and before the PR, or when you ask "what's untested here?". If you
want strict test-first, use `tdd` instead.

**How.**

```
/shipkit-workflows:qa                    # recently changed files (diff against HEAD~1)
/shipkit-workflows:qa app/billing.py
/shipkit-workflows:qa all
```

It runs five phases:

1. Reconnaissance: rate each file CRITICAL, HIGH, MEDIUM or LOW.
2. Three to eight risk questions for you.
3. A test plan for your approval.
4. Writing and running the tests.
5. A report.

**Writes.** Test files.

#### `/shipkit-workflows:tdd`

**Why.** If you never watched the test fail, you don't know it tests the right thing. This is
red-green-refactor with no exceptions you didn't approve.

**When.**
- You want TDD enforced on a change, or you said "test first".
- It also runs automatically under `Workflow style: strict-tdd`.

**How.**

```
/shipkit-workflows:tdd feature
/shipkit-workflows:tdd bugfix
/shipkit-workflows:tdd refactor
```

The iron law: no production code without a failing test first. Code written before its test
is deleted and redone, not adapted. Exceptions, such as prototypes, generated code or config,
need your say-so.

**Writes.** Tests and code, in that order.

#### `/shipkit-workflows:debug`

**Why.** Random fixes waste time and breed new bugs. This command doesn't allow a fix until
the root cause is known.

**When.** A test fails, a build breaks, or behaviour is wrong, especially when the "quick fix"
looks obvious or two fixes have already failed.

**How.**

```
/shipkit-workflows:debug
/shipkit-workflows:debug "undefined method total for nil" in OrdersController
/shipkit-workflows:debug spec/models/order_spec.rb
```

It works in four phases:

1. Root cause: read the whole error, reproduce it, check what changed, trace the bad value to
   its source.
2. Compare with similar code that works.
3. One hypothesis, tested with the smallest change.
4. The fix, starting with a failing test that reproduces the bug.

For flaky or order-dependent failures, ask for the `test-analyzer` agent by name.

**Writes.** A regression test and the fix.

#### `/shipkit-workflows:legacy-audit`

**Why.** Before modernizing a codebase you inherited, you need facts about it: how old the
dependencies are, what code is dead, where complexity concentrates, and where tests are
missing.

**When.** You've taken over a codebase and are planning its modernization. It's not for one
feature or one bug.

**How.**

```
/shipkit-workflows:legacy-audit all
/shipkit-workflows:legacy-audit deps
/shipkit-workflows:legacy-audit dead-code
/shipkit-workflows:legacy-audit complexity
/shipkit-workflows:legacy-audit coverage
```

**Writes.** An audit report.

#### `/shipkit-workflows:migration-plan`

**Why.** Breaking upgrades fail on the changelog entry nobody read. This command reads the
changelog first, maps each change to your code, and orders the steps.

**When.** A major upgrade such as Rails 7 to 8 or React 18 to 19. Not for adding a dependency,
a minor bump, or an upgrade already under way.

**How.**

```
/shipkit-workflows:migration-plan rails 7.1 8.0
/shipkit-workflows:migration-plan react 18 19
```

The care rule counts a major upgrade as destructive, so Claude still asks before starting the
upgrade itself.

**Writes.** A step-by-step migration plan.

#### `/shipkit-workflows:humanize`

**Why.** Machine-sounding prose in a README or PR description costs you the reader's trust.
This command finds the patterns, which show up in clusters, and rewrites without changing
facts.

**When.** Docs, READMEs, PR descriptions or marketing copy. Never code or code comments.

**How.**

```
/shipkit-workflows:humanize README.md
/shipkit-workflows:humanize analyze      # list the patterns found; rewrite only after you confirm
```

Text over 500 words gets the analysis first, rather than a blind rewrite.

**Writes.** The rewritten text and a summary of the changes.

---

### Stack overlay commands

`/shipkit:setup` installs these into `.claude/skills/` only if you say yes to the overlay's
skills. They're project commands, so they have no `shipkit:` prefix. Except for `/audit`,
Claude never starts them on its own; you type them.

| Command | Overlay | Why and when | How |
|---|---|---|---|
| `/new-feature` | `rails`, `python`, `go`, `elixir` | Scaffold a new class, module, package, context or LiveView *with its test*, following the project's detected layout. Use it when adding a unit that has a conventional shape | `/new-feature service ProcessPayment` · `/new-feature handler UserHandler` · `/new-feature context Accounts` |
| `/release` | `rails` | A two-phase release. Phase 1 is local and safe: clean tree, tests, `bundle audit`, `brakeman`, asset compile, version bump, changelog. Then a mandatory approval before the irreversible steps. If the feature has a spec, run `/shipkit:ship` first | `/release` (patch) · `/release minor` · `/release major` |
| `/component` | `react` | Scaffold a component with TypeScript types, tests and an optional Storybook story | `/component InvoiceTable` |
| `/audit` | `static` | Audit a static site for SEO, accessibility, performance and broken links | `/audit all` · `/audit a11y` · `/audit links` |

The Rails overlay also installs two knowledge bases you never type
(`code-review-standards-rails`, `ai-rails`). Claude reads them when a task calls for them.

---

### Scripts

These are plain POSIX shell scripts with no model and no network, in
`<plugin root>/scripts/`. With `SK="$(cat ~/.claude/shipkit/plugin-root)"`:

#### `spec-check.sh`

**Why.** It checks traceability with a script rather than by eye: every requirement has a
task, every task is well formed, and every requirement of a shipped spec has a citing test.

**When.**
- Any time while building a feature.
- Before `/shipkit:ship`, with `--as-shipped`.
- In CI, if you want specs enforced.

**How.**

```sh
sh "$SK/scripts/spec-check.sh" .                     # every spec
sh "$SK/scripts/spec-check.sh" . refunds             # one spec
sh "$SK/scripts/spec-check.sh" . refunds --as-shipped
sh "$SK/scripts/spec-check.sh" . refunds --as-open   # read a draft as if accepted
```

It exits 1 on any gap. The output lines are explained in
[section 6, step 4](#step-4-build-task-by-task).

#### `brief.sh`

**Why.** Hand an agent the requirement word for word, plus the files it may touch and the
proof it owes. A brief retyped by hand drifts from the spec.

**When.** Before handing one spec task to another agent or session.

**How.**

```sh
sh "$SK/scripts/brief.sh" . refunds T1
claude -p "$(sh "$SK/scripts/brief.sh" . refunds T1)"
```

#### `brief-verify.sh`

**Why.** An agent's report is a claim. This checks which files it actually changed.

**When.** After every delegated task, before you accept it.

**How.**

```sh
sh "$SK/scripts/brief-verify.sh" . refunds T1 <base-sha>
```

It prints an `OUTSIDE <file>` line for each change outside the task's `Files`, and exits 1 if
there's any. Then run the task's `Done when` command yourself.

#### `decision-check.sh`

**Why.** Reversal conditions written as text never get re-read. As `Fired-if` commands, a
script can check them.

**When.**
- Before a release.
- When you wonder whether a decision has expired.
- The ship gate runs it for you.

**How.**

```sh
sh "$SK/scripts/decision-check.sh" .          # list the commands; run nothing
sh "$SK/scripts/decision-check.sh" . --run    # FIRED / HOLDS / MANUAL / ERROR per decision
```

Read the list before using `--run` on a repository you don't trust: the commands come from
that repository.

#### `portfolio-digest.sh`

**Why.** One page of facts across every registered project, cheap enough to run from cron.

**When.** Weekly, from `cron` or `launchd`, or through `/shipkit:ask --all digest`.

**How.**

```sh
sh "$SK/scripts/portfolio-digest.sh"
sh "$SK/scripts/portfolio-digest.sh" --run-checks    # also run each project's Fired-if commands
```

#### Scripts you don't run yourself

The hooks and setup run the rest:
- `session-start.sh`, `briefing.sh` and `inject-rule.sh` at session start;
- `guard-commit.sh` before each Bash call;
- `install-rules.sh`, `install-stack.sh` and `setup-files.sh` from `/shipkit:setup`;
- `unsetup-remove.sh` from `/shipkit:setup remove`.

### Agents behind the commands

You rarely start these yourself. The commands start them:

| Agent | Started by | Can you name it directly? |
|---|---|---|
| `grandfather` | `/shipkit:ask`, `--walk`, intake, escape | Yes: "use the grandfather agent in trace mode to trace checkout" |
| `eve` | `/shipkit:ask --all` | Use `/shipkit:ask --all` |
| `goldfish` | `/shipkit:spec`, at the design gate | No; it exists for that gate |
| `reviewer` | `/shipkit:ship`, step 4 | Use `/shipkit:ship` |
| `test-analyzer` (workflows) | You | Yes: "use the test-analyzer agent on this flaky test" |

---

## 16. Where everything lives

### In your repository

```
CLAUDE.md                          project facts and Workflow style (setup)
PROJECT_MAP.md                     optional index for the elders (/shipkit:map)
.claude/rules/shipkit/             installed rules + overlays (setup) — commit these
.shipkit/
  product.md                       purpose, goals, non-goals (/shipkit:product)
  state.md                         handoff note (/shipkit:handoff) — git-ignored by default
  decisions/NNNN-<slug>.md         project-wide decisions (/shipkit:decide)
  specs/<slug>/
    intake.md                      request, conflicts, answers (/shipkit:intake)
    spec.md                        requirements, Status, Paths (/shipkit:spec)
    design.md                      decision records
    tasks.md                       Files / Test / After / Done when
  releases/<date>-<slug>.md        ship reports (/shipkit:ship)
  escapes/NNNN-<slug>.md           bugs that reached users (/shipkit:escape)
.shipkit-baseline/                 pre-shipkit snapshot, written once — keep out of git
.shipkit-backup-<ts>/              per-setup snapshot — keep out of git
.shipkit-recovery-<ts>/            snapshot before setup remove — keep out of git
```

Commit `.shipkit/` (except `state.md`, unless you want it), `CLAUDE.md` and
`.claude/rules/shipkit/`. Specs branch and merge with the code they describe.

### In your home directory

```
~/.claude/shipkit/
  plugin-root                      where the installed plugin lives (written by the hook)
  project-registry.md              eve's list of projects (/shipkit:map --register)
  studio.md                        cross-product priorities (/shipkit:product --studio)
  digests/<date>.md                weekly digests
```

Set `SHIPKIT_HOME` to move that folder.

### The scripts

All are in `<plugin root>/scripts/`, POSIX `sh`, with no model and no network:

| Script | Purpose |
|---|---|
| `spec-check.sh <dir> [slug] [--as-shipped\|--as-open]` | Requirement → task → test traceability |
| `brief.sh <dir> <slug> <task>` | A task as a brief for an agent |
| `brief-verify.sh <dir> <slug> <task> <base>` | Did the agent stay inside the task's files? |
| `decision-check.sh <dir> [--run]` | List, or run, every `Fired-if` command |
| `portfolio-digest.sh [registry] [--run-checks]` | The weekly page across all projects |

---

## 17. Troubleshooting

| Symptom | Cause and fix |
|---|---|
| No `shipkit:` lines at session start; a skill says the hook hasn't run | The plugin was installed or updated mid-session. Restart Claude Code |
| `installed rules are from shipkit X and the plugin is Y` | The plugin was upgraded. Run `/shipkit:setup` again |
| `N installed file(s) are missing` | Something deleted part of the install. Run `/shipkit:setup` to repair it |
| Claude jumped into code on a feature without a spec | The project hasn't opted in, so only `shipkit.md` loaded. Run `/shipkit:product` or `/shipkit:setup` |
| Claude wrote a spec for something tiny | Say "this is trivial, just do it" |
| `the code may have drifted from the spec` | Commits touched the spec's `Paths` since it was accepted. Re-read the spec against the code, refine it with `/shipkit:spec <slug>`, or ship it. `SHIPKIT_SPEC_STALE_COMMITS` raises the threshold |
| `PROJECT_MAP.md is N commits behind HEAD` | `/shipkit:map refresh`, or ignore it: the map is optional |
| Ship step 2 records `FAIL: no test command known` | Put the test command in `CLAUDE.md` (setup does this) |
| Ship step 1 fails on `MISSING-TEST` | A test exists but doesn't cite `<slug>/REQ-N`. Add the citation in a comment or the test name |
| Ship step 7 fails | Commit or stash your work first. Files the gate's own test run leaves behind don't count |
| Ship step 8 fails with `FIRED` | A decision's reversal condition came true. Write a superseding record with `/shipkit:decide`, or tell the gate to proceed |
| `brief-verify.sh` prints `OUTSIDE` for cache or coverage files | Add them to `.gitignore` |
| `brief-verify.sh` prints `OUTSIDE CLAUDE.md` | `CLAUDE.md` differs from what setup recorded and changed after `BASE`. If the agent changed it, the agent went outside its task. If you changed it, commit that before you note `BASE` |
| A commit was blocked: "looks like a secret" | The commit guard saw a staged `.env`, key or credentials file. Unstage it with `git restore --staged <file>` |
| You want shipkit out of a project | `/shipkit:setup remove`, then `/plugin uninstall shipkit@shipkit` if you want the plugin gone everywhere |

---

## 18. Cheat sheet

```
# once per machine
/plugin marketplace add https://github.com/AnjanJ/shipkit.git
/plugin install shipkit@shipkit
/plugin install shipkit-workflows@shipkit

# once per project
/shipkit:setup                       # rules, overlay, CLAUDE.md, workflow style
/shipkit:product                     # goals and non-goals
/shipkit:map --register              # optional: index + portfolio registry

# per feature
/shipkit:intake <request>            # conflicts, then ≤4 questions
/shipkit:spec <slug>                 # spec.md → design.md (goldfish) → tasks.md
  ... build task by task, tests cite <slug>/REQ-N ...
/shipkit:ship <slug>                 # READY / NOT READY with evidence

# delegating one task
BASE=$(git rev-parse HEAD)
claude -p "$(sh "$SK/scripts/brief.sh" . <slug> T1)"
sh "$SK/scripts/brief-verify.sh" . <slug> T1 "$BASE"   # then run Done when yourself

# along the way
/shipkit:decide <A over B>           # project-wide decision record
/shipkit:ask <question>              # grandfather: this project
/shipkit:ask --walk <feature>        # one feature, end to end
/shipkit:handoff                     # note for the next session
/shipkit:escape <what users saw>     # a bug got out: which link broke?

# across projects
/shipkit:ask --all <question>
/shipkit:ask --all digest            # which product needs you this week

# scripts (SK="$(cat ~/.claude/shipkit/plugin-root)")
sh "$SK/scripts/spec-check.sh" .
sh "$SK/scripts/decision-check.sh" . [--run]
```
