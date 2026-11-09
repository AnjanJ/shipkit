# Shipkit for Staff Engineers and Architects

This guide covers shipkit as an architecture and governance tool. It is about the work that
spans features and repositories: setting intent, recording and re-checking decisions,
reviewing specs, breaking work down for agents, gating releases, learning from incidents, and
keeping a portfolio of systems coherent.

It assumes you know the basic loop. For that, and for one entry per command, read the
[engineer's guide](engineers-guide.md). For every file, flag and script in detail, read the
[reference guide](../GUIDE.md).

Written for shipkit 5.3.0.

---

## Contents

1. [The model: what shipkit enforces and what it only asks for](#1-the-model-what-shipkit-enforces-and-what-it-only-asks-for)
2. [The design principles behind shipkit](#2-the-design-principles-behind-shipkit)
3. [Rolling shipkit out to a team](#3-rolling-shipkit-out-to-a-team)
4. [Intent at the product level](#4-intent-at-the-product-level)
5. [Decision records that check themselves](#5-decision-records-that-check-themselves)
6. [Reviewing a spec as an architect](#6-reviewing-a-spec-as-an-architect)
7. [Breaking work down for agents](#7-breaking-work-down-for-agents)
8. [Gates, CI and the audit trail](#8-gates-ci-and-the-audit-trail)
9. [Learning from escapes](#9-learning-from-escapes)
10. [Understanding and documenting a system](#10-understanding-and-documenting-a-system)
11. [Portfolio architecture](#11-portfolio-architecture)
12. [Modernization and major upgrades](#12-modernization-and-major-upgrades)
13. [Limits and failure modes](#13-limits-and-failure-modes)
14. [Playbooks](#14-playbooks)

---

## 1. The model: what shipkit enforces and what it only asks for

Shipkit separates three things:

- **Intent is written in files.** `.shipkit/product.md`, `specs/<slug>/{spec,design,tasks}.md`,
  `decisions/NNNN-*.md`, `releases/`, `escapes/`. These are plain Markdown, committed with the
  code, and readable by people, scripts and later sessions.
- **Structure is checked by scripts.** POSIX shell and awk, with no model and no network. The
  same input gives the same output.
- **Judgment comes from the model and from you.** Writing requirements, reviewing a diff
  against a spec, tracing a feature, and deciding whether a reversal condition has really
  come true.

Before you rely on any of this, know which of the three is doing each job:

| Concern | Mechanism | Strength |
|---|---|---|
| Every requirement has a task | `spec-check.sh` | **Enforced** by a script; exit 1 in CI |
| Every shipped requirement has a citing test | `spec-check.sh` | **Enforced**, but it checks that a citation *exists*, not that the test passes or really proves the requirement |
| Tasks that share a file are ordered | `spec-check.sh` (`CONFLICT`, `CYCLE`) | **Enforced** |
| A delegated agent changed only its task's files | `brief-verify.sh` | **Enforced** for *which* files changed, not *what* changed in them. Ignored files are invisible to it |
| A decision's reversal condition has come true | `decision-check.sh --run` | **Enforced** where the record has a `Fired-if` command; `manual` records need a person |
| No secret-looking file is committed by Claude | `guard-commit.sh` hook | **Enforced** by file name only. It never reads contents and doesn't see commits made in your terminal |
| Requirements are testable, one behaviour each | `/shipkit:spec`, the goldfish, you at gate 1 | **Instructed**: model behaviour plus your review |
| The code meets each requirement | The `reviewer` agent at the ship gate | **Instructed**: a model reading the diff. Strict by design, but not a proof |
| Answers about the code are correct | `grandfather`, `eve` | **Instructed**: they cite `file:line` and label confidence. Nothing independently validates a citation |
| Non-trivial work is planned before it's coded | Always-on rules | **Instructed**: shipkit's evals measure how often each rule is followed, and none is followed every time. The planning rule's eval once passed about one run in three (decision 0002) |
| The design is good | — | **Yours** |

The practical consequence: **put the enforced checks in CI, and review the instructed ones.**
Shipkit's value at staff level is that it turns intent into files that *can* be checked, and
checks what a script can. It doesn't replace architectural judgment, code review or security
review. The ship gate's reviewer says so in its own output.

---

## 2. The design principles behind shipkit

Shipkit records its own architecture in `.shipkit/decisions/` in this repository. The same
principles are worth applying to how your team uses it:

| Principle | Where it shows | Shipkit's own record |
|---|---|---|
| **Measure before keeping.** A practice that costs every session must show what it buys | The project map went from default to optional after a measured re-test on a 224-file project changed neither answers nor tool calls | `0001-project-map-default.md` |
| **Budget the always-on context** | The three always-on rules are capped at 3,000 bytes by lint. The spec-driven and decision rules load only in projects that opted in. Overlay skills install only on request | `docs/design/context-cost.md`, `0004-overlay-skills-flag.md` |
| **Files over agent memory** | Everything the loop knows is a file you can read and correct. MemPalace recall is optional | README, "What verified means" |
| **Fresh eyes are structural, not polite.** A reviewer is given only the slug and base ref; the goldfish only the slug | Both agent definitions ignore anything else they're told | `agents/reviewer.md`, `agents/goldfish.md` |
| **One orchestrator.** The main session starts every agent; no agent starts another | The spec skill, the ship gate and the elders all follow it | `0006-main-session-starts-every-agent.md` |
| **Knowledge versus workflow.** The core plugin produces, reads or installs knowledge; the workflows plugin says how to do the work | Two plugins, each usable alone | `0003-overlay-skills-home.md`, `docs/design/two-plugin-split.md` |
| **Every decision says what would reverse it** | Each record above carries a falsifiability clause, and some carry a `Fired-if` command | The `decisions` rule |

Read `0001` as a template for an evidence-backed reversal. It states the rule before
measuring, measures, and records the reversal it said it would make.

---

## 3. Rolling shipkit out to a team

### Install at project scope

For a shared repository, install the plugins at project scope from inside the repository:

```sh
claude plugin install shipkit@shipkit --scope project
claude plugin install shipkit-workflows@shipkit --scope project
```

This records both plugins as enabled in the project's `.claude/settings.json` (checked in
`docs/design/field-notes-5.2.md`). Commit that file. Each teammate's machine still needs the
marketplace (`/plugin marketplace add https://github.com/AnjanJ/shipkit.git`). Whether Claude
Code prompts for it on its own depends on the Claude Code version, and hasn't been verified
here.

**Upgrades are per project.** Update from inside each project:

```sh
claude plugin marketplace update shipkit
claude plugin update shipkit@shipkit --scope project
claude plugin update shipkit-workflows@shipkit --scope project
```

Run from outside, a project-scope update reads only the first project it finds and can report
"already at the latest version" while another project stays behind. That was observed in the
same field notes. Treat a shipkit upgrade like any other tooling bump: one PR per repository,
then re-run `/shipkit:setup` to refresh the installed rules.

### Run setup once and commit the result

`/shipkit:setup` writes the following. Commit these:

- `CLAUDE.md`: project facts, the test command and `Workflow style:`;
- `.claude/rules/shipkit/`: the eight shipkit rules plus the stack overlay's rules, with a
  version stamp and a manifest;
- `.gitignore` entries for the snapshot folders and `.shipkit/state.md`.

Keep these out of git: `.shipkit-baseline/`, `.shipkit-backup-*/`, `.shipkit-recovery-*/`.
They can hold a whole `.claude/` folder, including local settings.

### Choose the workflow style by risk, not by taste

| Repository | Style | Why |
|---|---|---|
| Payments, auth, data pipelines, shared libraries | `strict-tdd` | The cost of an escape is highest, and a failing test first is cheap insurance |
| Most product services | `test-first` (default) | Planning and tests for non-trivial work, with sensible exceptions |
| Prototypes, internal tools, docs sites | `lightweight` | The three questions answered inline; spec files only on request |

Decision records apply in full under every style. The style is one line in `CLAUDE.md`;
change it as a repository matures.

### Write team rules the way shipkit writes its own

- **Project facts** (commands, paths, conventions) go in `CLAUDE.md` through
  `/shipkit:setup rules <rule>`. That command checks for duplicates, files the rule in the
  right section, shows the diff, and warns past 200 lines.
- **Conventions that apply to some files only** go in your own path-scoped rule, a file
  under `.claude/rules/` with `paths:` frontmatter. Keep yours **outside**
  `.claude/rules/shipkit/`, which belongs to the installer and is refreshed by setup.
- **Write traps, not essays.** Shipkit's rules hold only "the traps the model gets wrong
  unprompted", and its stack rules are lint-capped at 40 lines. The research the README cites
  says the same: name the specific mistake, describe minimal requirements, and stay well
  under the 150–200-instruction ceiling.

```markdown
---
paths:
  - "app/services/payments/**"
---
# Payments
- Amounts are integer cents everywhere; never a float, never a Decimal crossing the API.
- Every gateway call goes through `Payments::Client`; it owns retries and idempotency keys.
```

### Watch the context budget

Every always-on byte is paid by every session in that repository.

- `/shipkit:setup audit` explains what loads and when.
- Claude Code's `/context` shows the real token numbers.
- From a shipkit checkout, `scripts/context-cost.sh <project>` prints the hook, skill,
  agent, overlay and rule rows for one project.

An opted-in project pays about 340 bytes of hook output once its rules are installed as files
(measured on this repository).

---

## 4. Intent at the product level

### Non-goals are architectural guardrails

`/shipkit:intake` checks every non-trivial request against `.shipkit/product.md`. The
**non-goals** are what it checks hardest, so write the ones that protect the architecture:

```markdown
## Non-goals
- No multi-tenant data isolation this year; one customer per deployment.
- No synchronous calls from the checkout path to services we don't own.
- No second datastore; Postgres covers queues, search and cache until a decision record says otherwise.
```

Intake quotes the conflicting line before it asks anything. The request can still go ahead,
but the non-goal or the decision has to change first, and that change is visible in a diff.
This is cheaper than the same argument in a design review.

### Goals carry a metric, a target and a date

`/shipkit:product` keeps at most three goals per quarter. It writes `metric: none set` rather
than invent one. Every spec's intake records which goal it serves, or `None`, which is
allowed and is itself information. A quarter of specs serving `None` is worth a conversation.

### Ranking across products

If you own several products, `/shipkit:product --studio` writes your ranked priorities to
`~/.claude/shipkit/studio.md`, at most five. The weekly digest ranks products against it (see
[section 11](#11-portfolio-architecture)). The ranking is always yours; shipkit never infers it
from activity.

---

## 5. Decision records that check themselves

### The bar for a record

A record is for a **real fork**: two or more alternatives that were actually considered. It
has five parts:

1. **Context.**
2. **Alternatives.**
3. **Case for.**
4. **Case against your own choice.** The part that makes the record trustworthy.
5. **Decision, with a falsifiability clause.** The clause must be a metric, an event or a
   threshold. "If it turns out wrong" fails the ship gate's step 6. If there's honestly no
   reversal condition, write "no clear reversal condition identified". The gate accepts that,
   and it's better than a fake one.

| Scope | Home |
|---|---|
| One feature | That spec's `design.md`, written by `/shipkit:spec`, each record citing the `REQ-N` it serves |
| Project-wide | `.shipkit/decisions/NNNN-<slug>.md`, written by `/shipkit:decide` |

A superseded record is marked and points to its replacement. It's never deleted, so the log
stays the history of *why*.

### `Fired-if`: turning reversal conditions into fitness functions

A `Fired-if` line holds a read-only shell command that **exits 0 once the reversal condition
has come true**, exits 1 while the decision still holds, and exits above 1 on error.
`decision-check.sh --run` executes each command and prints `FIRED`, `HOLDS`, `MANUAL` or
`ERROR`. In effect, an architecture decision becomes a fitness function that lives beside its
rationale.

Patterns that work:

| Reversal condition | `Fired-if` |
|---|---|
| A module outgrows its boundary | `` `test "$(git ls-files 'app/billing/*.rb' \| wc -l)" -gt 40` `` |
| A banned dependency arrives | `` `git grep -q '"redis"' -- package.json` `` |
| A second consumer of an internal API appears | `` `test "$(git grep -l 'InventoryClient' -- 'services/*/src' \| wc -l)" -ge 2` `` |
| A config switch is flipped | `` `git grep -q 'pool_mode *= *transaction' -- config` `` |
| A file passes a size limit | `` `test "$(wc -l < config/routes.rb)" -gt 500` `` |
| Latency, cost, users or anything outside the repository | `manual` |

Rules that keep these honest:

- **The command must exit 1 on the tree the record is written against.** A condition about
  code that doesn't exist yet errors today and fires the day the file appears, before the
  decision has had a chance to be wrong. `/shipkit:spec` runs `decision-check.sh --run` on
  new records and rewrites any that fire or error.
- **Search tracked files with `git grep`, not `grep -r`.** `grep -r` also reads build output
  and caches.
- **The command is the condition.** Write `test …` or `grep -q …` straight from the
  sentence, without inverting it.
- **Use `manual` honestly.** A clause about p99 latency or monthly cost can't be measured
  from a checkout. Leave it `manual` and review it on a calendar.

### Where decisions get re-checked

| Where | How | Effect |
|---|---|---|
| Ship gate, step 8 | `/shipkit:ship <slug>` runs `decision-check.sh --run` | A `FIRED` line means `NOT READY` until a superseding record is written or the owner says to proceed |
| On demand | `/shipkit:ask are any of our past decisions now falsified?` | `grandfather` runs the check and reads the clauses |
| Across the portfolio | `portfolio-digest.sh --run-checks` | Fired decisions per project on the weekly page |
| CI | See [section 8](#8-gates-ci-and-the-audit-trail) | Listing on every PR; running on trusted repositories |

**Trust boundary.** `Fired-if` commands come from the repository, and anyone with a commit can
write one. `decision-check.sh` without `--run` only lists them. Read the list before running
them in a repository you don't control. No hook ever runs them.

---

## 6. Reviewing a spec as an architect

A spec has two approval gates, and both are cheaper than reviewing code. They are where a
staff engineer's review time does the most good.

### Gate 1: requirements (`spec.md`)

What to look for:

- **One behaviour per requirement, in EARS.** A requirement with "and" is two requirements.
  An event, state, optional or unwanted-behaviour pattern is more precise than "the system
  shall support X".
- **The product, not the process.** "The ship report says READY" isn't a requirement; it
  can't be met before the gate runs. Release steps go under "After the gate" in `tasks.md`.
- **Unwanted behaviour is specified.** Refusals, limits, failure modes and idempotency. Most
  escapes trace to a missing `If <trigger>, then …`.
- **`[untested: …]` waivers carry real reasons.** Each waiver is a requirement the gate will
  accept with no test.
- **`Paths:` is right.** It scopes drift detection, the reviewer's "changes beyond the spec"
  list, and which spec an escape lands on. Too broad hides drift; too narrow makes
  legitimate work look like scope creep.
- **Out of scope is explicit.** It reaches every delegated agent through the brief.
- **Brownfield:** the spec locks what exists and describes only the change.

### Gate 2: design (`design.md`) and the goldfish

Before this gate, the **goldfish** reads `spec.md` and `design.md` cold, given only the folder
name, as an implementer would. It reports what a test author would have to guess. Each finding
gets one disposition:

| Disposition | Means | What to check |
|---|---|---|
| `fixed` | The spec or design was edited to answer it | That edits to *accepted* requirements were named at the gate |
| `contested` | A file the goldfish could have read already answers it, cited by `path:line` | Open the citation. "Everyone knows" is not a valid contest; knowledge outside the files must go into the spec |
| `escalated` | Put to you | Fix it, or accept the gap. An accepted gap is written under `## Goldfish` in `spec.md`, where escape analysis and the reviewer will find it later |

Then review the decisions themselves: real alternatives, an honest case against, a concrete
reversal condition, and a cited `REQ-N` for each. A design decision that serves no
requirement is either a missing requirement or gold-plating.

### Tasks (`tasks.md`)

`spec-check.sh` already proves the structure. Review what a script can't:

- **`Files` lines are ownership boundaries.** They bound what each agent may touch, and they
  set the parallelism (see [section 7](#7-breaking-work-down-for-agents)).
- **`Done when` is a real command with an observable result,** not "works".
- **Each task leaves the build green.**
- **Each `Test` fails before the work.** It is the definition of done, so check it would fail
  today.

### Spec smells

| Smell | Usually means |
|---|---|
| Ten requirements, one task | The task is too large to delegate or review |
| Many `[untested]` waivers | The behaviour is hard to observe; there may be a design problem |
| `Paths:` is the whole repository | The feature has no boundary yet |
| Decisions with no alternatives | Defaults written up as decisions |
| Intake says `Serves goal: None` and nobody discussed it | Work that isn't prioritised |
| Several goldfish findings `contested` on the same term | A domain concept missing from the spec |

Scale the spec to the work. A small but non-trivial change needs a few lines per question; a
full spec folder is for features and multi-file changes. Under `lightweight` the three
questions are answered inline unless someone asks for files.

---

## 7. Breaking work down for agents

With agents doing the build, the task breakdown in `tasks.md` is an architectural artefact. It
decides what can run in parallel, what each agent can touch, and what has to happen in order.

### File-disjoint tasks run in parallel

The **sharing rule**: two tasks that list the same file must be ordered by `After`, directly
or through a chain. `spec-check.sh` reports a `CONFLICT` otherwise. The result is that any two
*ready* tasks (all `After` tasks finished) that share no file can run at the same time, each
in its own git worktree.

So the shape of the `Files` lines decides the shape of the schedule:

```
T1  Files: app/billing/charge.py, tests/billing/test_charge.py        After: none
T2  Files: app/billing/refund.py, tests/billing/test_refund.py        After: T1
T3  Files: app/notifications/refund_mail.py, tests/...                After: none
T4  Files: app/billing/refund.py, app/api/refunds.py, tests/api/...   After: T2
```

T1 and T3 run at once, then T2, then T4. Had T3 also touched `app/billing/charge.py`, it would
have had to wait. To get parallel work, design for it: put new behaviour behind new files and
keep shared files (routers, registries, schema) in their own tasks.

### The handoff contract

1. Note the base: `BASE=$(git rev-parse HEAD)`.
2. Generate the brief with `brief.sh . <slug> <task>` and pass it on **unchanged**. It
   carries:
   - the goal;
   - the requirement, word for word;
   - the allowed files;
   - the test and the `Done when` command;
   - the tasks already done;
   - the titles of the decisions that bind the task;
   - what's out of scope;
   - a fixed report form: `RESULT`, `CHANGED`, `TEST`, `NOT VERIFIED`, `DEVIATIONS`.
3. Extra context goes **below** the brief, never in place of any part of it.
4. When the agent reports, run `brief-verify.sh . <slug> <task> "$BASE"`, then run
   `Done when` yourself. An `OUTSIDE` line or a failing `Done when` means not done,
   whatever the report says.

### The orchestration model

- **The main session starts every agent** (decision 0006). Agents don't start agents. Plan
  for a single orchestrator, not a tree.
- **Match the team to the work.** A trivial change needs no agent. One task needs at most one
  implementing agent. A research question goes to the elders. An agent started "just in case"
  costs tokens before it has shown it was needed.
- **Review agents get no context on purpose.** The reviewer gets the slug and base; the
  goldfish gets the slug. Don't "help" them with a summary; it defeats the point.

---

## 8. Gates, CI and the audit trail

### What `READY` means

`/shipkit:ship <slug> [base]` runs eight checks and writes
`.shipkit/releases/<date>-<slug>.md`. `READY` means all eight passed, with evidence:

1. `spec-check --as-shipped`: every requirement has a task and a citing test.
2. The project's test command exits 0.
3. Every task is ticked.
4. The reviewer's verdict is `PASS`: every requirement `MET` with code and test `path:line`,
   and no decision `contradicted`.
5. Any migration has a written rollback.
6. Every live decision has a concrete reversal condition.
7. The tree was clean before the gate ran.
8. No `Fired-if` has fired.

`READY` **doesn't** mean code-reviewed, secure or fast. The reviewer explicitly leaves out
general bugs, style, performance and security, and points to `/code-review`. The gate also
never deploys, pushes, merges or tags. Treat `READY` as "built to spec, with evidence", and
keep your normal review and release controls.

The reviewer also reports **changes beyond the spec** (files outside `Paths:`) and decisions
that are `partly built` or `not built`. Neither fails the verdict, but both are the first
things an architect should read in the report.

### Put the deterministic checks in CI

The scripts are POSIX `sh` + `awk` + `git` and need no model. Shipkit's own CI runs
`spec-check.sh` on every PR. For your repositories, pin a released tag:

```yaml
name: shipkit
on: pull_request

jobs:
  specs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Fetch shipkit's scripts (pinned)
        run: git clone --quiet --depth 1 --branch v5.3.0 https://github.com/AnjanJ/shipkit.git "$RUNNER_TEMP/shipkit"
      - name: Every requirement has a task; shipped specs have cited tests
        run: sh "$RUNNER_TEMP/shipkit/plugins/shipkit/scripts/spec-check.sh" .
      - name: List decision checks (runs nothing)
        run: sh "$RUNNER_TEMP/shipkit/plugins/shipkit/scripts/decision-check.sh" .
```

Choices to make:

- **`decision-check.sh --run` in CI** runs commands committed to the repository. On a
  repository where only trusted people can merge to the default branch, run it on `main`
  (exit 1 on `FIRED`) as a scheduled job. On pull requests from forks, list only.
- **Blocking or advisory.** Start with `spec-check.sh` blocking (it rarely misfires) and
  `decision-check.sh --run` advisory. A fired decision is a prompt for a superseding record,
  not always a build break.
- **History depth.** A shallow checkout is enough for `spec-check.sh`, which searches the
  working tree. A `Fired-if` that reads history (`git log`, `git rev-list`) needs
  `fetch-depth: 0`.

`brief-verify.sh` belongs in the orchestrating session, not in CI: it needs the base commit a
delegated task started from.

### The audit trail

Commit `.shipkit/`. Together, the files answer the questions an audit or a new staff hire asks:

| Question | File |
|---|---|
| What were we trying to achieve this quarter? | `product.md` (dated review line) |
| Why was this feature built, and what was ruled out? | `specs/<slug>/intake.md`, `spec.md` |
| Why is it built this way? | `specs/<slug>/design.md`, `decisions/` |
| Was it complete when it shipped, and who said so? | `releases/<date>-<slug>.md`, with evidence pasted |
| What got past us, and which link broke? | `escapes/` |

Specs branch and merge with the code they describe, so `git log -- .shipkit/specs/<slug>`
is the feature's design history.

---

## 9. Learning from escapes

`/shipkit:escape <what users saw>` is a blameless post-incident step with a fixed taxonomy. It
names **exactly one** cause, the first that's true reading down this list. Each cause points
at the part of the process that failed:

| Cause | The link that broke | Process response |
|---|---|---|
| `no spec` | The work was never specced | Is the trivial/non-trivial line drawn in the right place? Spec the area |
| `requirement missing` | Intake and the spec missed a case | Check intake's questions and the goldfish's accepted gaps (`## Goldfish` in `spec.md`) |
| `requirement wrong` | The spec asked for the wrong thing | Product understanding. Was the intake answer a guess? |
| `requirement right, no test` | The gate accepted a waiver, or the test was never written | Review `[untested]` waivers; make sure `spec-check` runs as-shipped in CI |
| `test existed but was wrong` | The test cited the requirement and didn't prove it | Test quality. A citation is not proof; review tests against requirements |
| `outside the product (dependency, infrastructure)` | Something we depend on failed | Dependency risk. Decide whether a guard on our side deserves a requirement |

Escape repairs the spec where the spec was at fault. It adds or corrects the requirement,
reopens the spec, and adds a task whose test **fails now**. The fix then follows the normal
loop. The record is never deleted; a wrong diagnosis is corrected with a dated note.

**Use the distribution, not just the incident.** The weekly digest shows each project's
escapes over 30 days, grouped by cause. Over a quarter, the mix tells you where the process
leaks:

- mostly `requirement missing`: invest at intake and in the spec review;
- mostly `requirement right, no test`: tighten the gate;
- mostly `outside the product`: invest in dependency and platform resilience.

---

## 10. Understanding and documenting a system

### System design documents with verified claims

```
/shipkit:ask --system            # full: every phase, with a verification loop
/shipkit:ask --system quick      # problem and exploration only; no verification loop
/shipkit:ask --system section decisions
```

The full run:

1. Writes the problem statement: what the system solves, for whom, the alternatives, and the
   scope boundary.
2. Maps the system at C4 levels: context, containers, components.
3. Writes architectural decisions in ADR form, each with a confidence label: VERIFIED (code
   evidence), INFERRED or UNCERTAIN.
4. **Re-verifies every claim against source.** Anything still UNCERTAIN is cut or moved to
   open questions. No UNCERTAIN claim reaches the document.

It returns a proposed `docs/SYSTEM_DESIGN.md`, plus a claims table showing what was cut or
demoted, so you can audit it. The file is written only on your yes. If `docs/ARCHITECTURE.md`
or `PROJECT_MAP.md` exists, it builds on them.

Use `quick` for orientation. Use the full run for anything you'll hand to someone else.

### Feature traces and targeted questions

- `/shipkit:ask --walk <feature> [surface|deep]` follows one feature from trigger to datastore
  and back, every step `file:line`. `deep` is the default and adds error paths and side
  effects.
- `/shipkit:ask is it safe to drop the legacy_token column?` sends a judgment question to
  `grandfather`. It answers with a confidence label: HIGH (read the code), MEDIUM (map plus a
  partial check) or LOW (inferred).

Keep the confidence labels when you forward an answer. A MEDIUM answer is a lead, not a
finding.

### The project map: when it's worth it

`PROJECT_MAP.md` is optional. Build it with `/shipkit:map --register` when:

- you want the project in `eve`'s portfolio view (registration is the point);
- the commit history is too thin to explain how the project evolved.

Otherwise `grandfather` reads the source directly. The session hook says when a map is behind
HEAD.

### Recalling past decisions

`/shipkit:setup memory` installs MemPalace (local; about 300 MB with its model) so the elders
can answer "what did we settle last month?" from past conversations. The elders prefer
verified records (`decisions/`, specs) over recall. Recall fills gaps; it doesn't replace
writing decisions down.

---

## 11. Portfolio architecture

### Build the registry

Run `/shipkit:map --register` in each repository. Each one gets a row in
`~/.claude/shipkit/project-registry.md` with: project, path, stack, deploy target, open specs,
product, and top goal.

### Questions across repositories

```
/shipkit:ask --all where did we decide against microservices, and do the reasons still hold?
/shipkit:ask --all which services call the inventory API directly?
/shipkit:ask --all matrix rails
/shipkit:ask --all matrix "everything major"
/shipkit:ask --all consolidate
```

- **Matrix:**
  - Versions come from **lockfiles** (installed truth); the declared constraint is shown
    beside them when the two differ.
  - One row per project, with `path:line` evidence.
  - For "everything major", it limits itself to each repository's framework, runtime and the
    three to five heaviest dependencies.
  - It **never invents "latest" or "vulnerable"**: it knows what's in your repositories, not
    upstream. Give it a target version to compare against, or run `npm outdated` and advisory
    databases separately.
- **Consolidate:**
  - Ranked candidates: the same concern implemented in several repositories (auth glue, API
    clients, deploy scripts, CI config, error reporting), version drift of one pattern, and
    copy-paste lineage.
  - Each candidate comes with its copies, the drift between them, and a cost judgement:
    extract a library, pick one winner, or leave it alone.
  - Capped at the top five to seven candidates.
- **Registry-only answers** are labelled MEDIUM confidence: attributed snapshots, not live
  reads.

### The weekly portfolio review

```
/shipkit:ask --all digest
```

`portfolio-digest.sh` (no model) writes seven facts per project:

- top goal;
- open specs and their progress;
- spec gaps;
- decisions (fired ones only with `--run-checks`);
- escapes in the last 30 days by cause;
- map age;
- uncommitted and unpushed work.

Then `eve` answers one question, **which product needs attention this week, and why?**, with
at most three products, each reason tied to a digest line and a studio priority.

Run the script from `cron` or `launchd` for a standing Monday page. The reference guide has a
`launchd` plist. A digest more than a week old shows in the session briefing.

---

## 12. Modernization and major upgrades

### Audit first

```
/shipkit-workflows:legacy-audit all     # or: deps | dead-code | complexity | coverage
```

| Phase | Output |
|---|---|
| Dependencies | Each outdated package rated CRITICAL (two or more majors behind, or known CVEs), STALE, AGING or CURRENT, plus the ecosystem's security scanner (`bundle audit`, `npm audit`, `pip-audit`, `govulncheck`, `mix hex.audit`) |
| Dead code | Unused files, functions, routes and dependencies, and long commented-out blocks, with "safe to remove?" |
| Complexity hotspots | Large files, god classes, long methods, deep nesting, **crossed with six months of churn**. A file that is both complex and often changed is where to start |
| Coverage gaps | Source with no tests, tests stale for six months or more, critical paths without integration tests |

### Plan the migration from the changelog

```
/shipkit-workflows:migration-plan rails 7.1 8.0
```

It reads the official upgrade guide and changelog **before** analysing impact. It then maps
every usage, dependency conflict and risk, and writes steps that are each **atomic, testable
and reversible**. The order:

1. Fix deprecations on the current version.
2. Configuration.
3. The version bump.
4. Breaking changes.
5. Tests.
6. Remove the compatibility shims.

### Turn the plan into governed work

- **Spec the migration.** `/shipkit:spec rails-8`, with the plan's steps as tasks. Each task
  gets its `Files`, `Done when` and rollback, so steps can be delegated and gated like any
  feature.
- **Record the fork.** Upgrade now or later, or big-bang or strangler, goes in a
  `/shipkit:decide` record. A `Fired-if` can watch for the condition that would change the
  answer (for example, an end-of-life date passing, checked manually).
- **The `dependencies` rule** keeps updates named: no bare `bundle update`, no unpinned
  versions, and a reason for any downgrade.
- **The care rule** treats a major upgrade as destructive, so Claude asks before starting one.
- **Across the portfolio:** run `/shipkit:ask --all matrix <framework>` first to size the
  campaign, then plan per repository.

---

## 13. Limits and failure modes

Know where shipkit stops before you rely on it:

- **A citation isn't proof.** `spec-check` checks that `<slug>/REQ-N` appears in a test file,
  not that the test passes or tests the requirement. The ship gate runs the tests and the
  reviewer reads them, but `test existed but was wrong` is a real escape cause for a reason.
- **The reviewer is a model.** It's told to be strict ("probably handled" is `CANNOT TELL`),
  but a wrong `MET` is possible. Read its evidence column.
- **The elders' citations aren't independently validated.** Check the ones you act on.
- **The rules are instructions.** The always-on rules shift behaviour; they don't guarantee
  it. Shipkit measures its rules with evals (`docs/design/eval-history.md`), and no rule
  passes every run.
- **`brief-verify` sees which files changed, not what changed,** and it doesn't see ignored
  files. Run `Done when` yourself.
- **The commit guard checks file names only.** A secret pasted into an ordinary file goes
  through, and so does a commit you type in your own terminal. Keep a real secret scanner in
  CI.
- **`Fired-if` commands are code from the repository.** List them before you run them on a
  repository you don't trust.
- **Drift warnings are heuristic.** They count commits touching a spec's `Paths` since
  acceptance; the threshold is set with `SHIPKIT_SPEC_STALE_COMMITS`. A warning means
  "re-read", not "wrong".
- **Single orchestrator.** Agents don't start agents. Large parallel builds are coordinated
  from one main session.
- **No deploy, no merge, no tag.** Shipkit's gate reports; release controls stay yours.

---

## 14. Playbooks

### A. Adopting shipkit in an established repository (first week)

1. Install at project scope; run `/shipkit:setup`; choose the style by risk. Commit
   `.claude/settings.json`, `CLAUDE.md`, `.claude/rules/shipkit/` and `.gitignore`.
2. `/shipkit:ask --system`: review the claims table and commit `docs/SYSTEM_DESIGN.md`.
3. `/shipkit:product`: three goals with metrics, and the non-goals that protect the
   architecture.
4. Back-fill the three to five decisions that people argue about most with `/shipkit:decide`,
   each with a reversal condition and, where possible, a `Fired-if`.
5. Add `spec-check.sh` (blocking) and `decision-check.sh` (listing) to CI.
6. Run the next real feature through intake, spec, build and ship. Review its two gates
   yourself, then delegate gate review once the team has seen what good looks like.

### B. An architecture review of a proposed feature

1. `/shipkit:intake <the proposal>`. Read the conflicts before the questions.
2. `/shipkit:spec <slug>`. At gate 1, review the requirements against
   [section 6](#6-reviewing-a-spec-as-an-architect).
3. At gate 2, read the goldfish's findings and their dispositions, then each decision's
   alternatives, case against and reversal condition.
4. Check the task graph: are the `Files` boundaries sensible, and is the parallelism real?
5. Approve, or send it back with the specific `REQ-N` or decision to change. The review is
   then in the files, not in a meeting.

### C. A cross-repository upgrade campaign

1. `/shipkit:ask --all matrix <framework>` to see who is on what.
2. Per repository: `/shipkit-workflows:legacy-audit deps`, then
   `/shipkit-workflows:migration-plan <dep> <from> <to>`.
3. A project-wide `/shipkit:decide` record for the campaign's sequencing.
4. Per repository: `/shipkit:spec <dep>-upgrade` from the plan, delegate the tasks, and
   `/shipkit:ship` each one.
5. Re-run the matrix weekly; the digest shows open specs and progress per project.

### D. After an incident

1. Fix forward or roll back first, as you normally would.
2. `/shipkit:escape <what users saw>` names the one cause, records it, and reopens the spec
   with a failing-first task.
3. Ship the fix through the gate.
4. In the quarterly review, look at the escape causes across the portfolio, not just this
   one.

### E. The quarterly architecture review

1. `/shipkit:product <what changed>` in each product, and `/shipkit:product --studio` for the
   ranking.
2. `/shipkit:ask --all are any recorded decisions falsified?`, plus the `manual` clauses
   reviewed by a person.
3. `/shipkit:ask --all consolidate`: pick at most one or two consolidations to fund.
4. Escapes by cause, from the last digests: where did the process leak?
5. Write the outcomes as decision records, superseding the old ones rather than deleting them.
