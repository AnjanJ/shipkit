# Changelog

All notable changes to Shipkit are documented here. Newest first.

## [4.1.0] — 2026-10-07

Sprint 8 of the evidence plan (`docs/plans/evidence-sprint-plan.md`): the re-test decision 0001
asked for in 3.2.0, run at last, and acted on by the record's own clause. Requirements and
decision records in [`.shipkit/specs/map-on-trial/`](.shipkit/specs/map-on-trial/); the numbers in
[`docs/design/eval-results-4.1.md`](docs/design/eval-results-4.1.md).

### Changed

- **The project map is optional.** On a generated 224-file, 27-commit fixture, with five elder
  questions including one only the history answers, the map gave no more correct answers
  (15 of 15 on the fact either way) and 4.6% fewer tool calls — short of the 20% the record set
  as its threshold. So `/shipkit:setup`, the README and the guide now offer `/shipkit:map`
  with that number beside it instead of listing it first; `grandfather` reads a map when one
  exists and goes to the source when none does, without calling the answer slower; `eve` greps
  a registered repository that has no map instead of reporting it as a gap. Nothing is
  removed: the archivist, `/shipkit:map`, the stale-map nag (which only fires on a map that
  exists) and `eve`'s registry are as they were. Build a map for `eve`'s portfolio view, for
  your own orientation, or when the commit log is too thin to carry the project's history.
- Lint check 17 enforces the 100 KB ceiling on `plugins/shipkit/evals/` that decision A9 set
  in 3.2.0 and nothing checked; check 18 keeps the three onboarding documents from presenting
  the map as required again.

### Added

- `plugins/shipkit/evals/fixtures/ledger-gen/generate.py`: the XL eval fixture, generated at
  scaffold time rather than committed (14 KB of generator instead of 400 KB of tree) —
  `ledger`, 224 files across eight domain packages with mirrored tests, routes, adapters,
  twenty migrations, and a 27-commit history with fixed dates so two runs are byte-identical.
  Five planted facts with decoys in `fixtures/FACTS-XL.md`; `--no-map` for the comparison arm.
- Five `grandfather-xl` eval cases (`lookup`, `explain`, `drift`, `gap`, `history`) — 15 → 20
  cases in `scripts/evals.sh`, about $1.60 more per release run.
- `scripts/trace-tools.sh <output-dir>`: tool calls (total and main session), `Agent` calls,
  input tokens (total and main) and cost per run, read from each run's `trace.jsonl` through
  `aggregate-result.json`. Eval summaries are not evidence; this is what the comparison read.
- Smoke checks 38 to 41: the generator's determinism and planted facts, the XL scaffolds, the
  counter against a synthetic trace with known numbers, and the hook's silence about a map in
  a project that has none. 109 → 119 checks.

### What using it for real showed

Two things the nine-file fixture could not show. First, `grandfather` opened the map in nine of
thirty with-map runs although its first instruction was to read it: it greps, the grep finds the
answer, and the map is an afterthought — with the plugin off, Claude read the map more often
(nine of fifteen) because its own grep landed on the map's line. Second, the history question —
the map's strongest case on paper — was answered from `git log` in every run of every arm; the
map, when read, was read after the log. The eval tool turned out not to pass the caller's
environment to scaffold scripts (a nonce in an open spec's slug came back `unset`), so the
no-map arm ran from a scratch copy of the plugin, as 3.2's did; and a kept sandbox keeps its
trace but not its workspace, so a probe has to surface through the trace. The generator's
12 KB limit was raised to 16 KB with the owner's yes after three compaction passes left it at
14 KB: cutting further thinned the generated code, which is the opposite of the fixture's
purpose, and the 100 KB ceiling is the budget that matters. `rules/nontrivial` was not run
this sprint; it is Sprint 9's business.

## [4.0.0] — 2026-10-06

Sprint 7 of the quality-gate plan: less to load, a clear pitch, one worked example. The audit
that decided every row is `docs/design/trim-audit-4.0.md`; the owner approved each cut.
Requirements and decision records in [`.shipkit/specs/trim-and-docs/`](.shipkit/specs/trim-and-docs/).

### Removed

Each was cut because no line in it held a project-specific value or a trap the model gets wrong
unprompted; the model does these things by default.

| Removed | Use instead |
|---|---|
| `rules/security.md` (path-scoped: controllers, routes, api, auth) | Nothing to install. The always-on `shipkit.md` keeps "never stage `.env`, credentials, keys or tokens" and `guard-commit.sh` enforces it; parameterized queries, input validation and auth checks are default behaviour. |
| `stacks/elixir/.claude/rules/elixir.md` | Nothing. `mix-deps.md`, `liveview.md` and `jobs.md` carry the stack's real traps. |
| `stacks/go/.claude/rules/go.md` | Nothing. `go-mod.md` stays. |
| `stacks/python/.claude/rules/python.md` | Nothing. `pyproject.md` stays. |
| `shipkit-workflows` knowledge base `code-review-standards` | Claude Code's built-in `/code-review`. The one lens a built-in lacks, reviewing AI-written code, is a paragraph in `GUIDE.md`. The Rails overlay's `code-review-standards-rails` stays and now says it supplements `/code-review`. |

A project that installed one of the removed rules keeps its copy until the next
`/shipkit:setup`, which removes files shipkit no longer ships (the 3.1 reconciliation).

### Changed

- Sixteen rules trimmed to the lines that name a project value or a non-obvious trap; the
  twenty-two rules went from 505 lines to 384 across the eighteen that remain (frontmatter
  included; `ui-ux.md` alone carries 42 path globs). Every stack rule is now 40 lines or
  fewer, every skill description 300 characters or fewer, and the lint fails when either
  limit is crossed again. `react.md` is now only the "inside a Rails app" rules; `monorepo.md`
  no longer loads for every `apps/` or `packages/` directory.
- `/shipkit-workflows:qa` has a real description with trigger guidance (it had five words);
  its body and `/shipkit-workflows:debug`'s are half their length, same phases.
- Every script calls `mktemp` with a template; the lint forbids a bare one.
- **The README is rewritten around the loop**: what shipkit is in a paragraph, install, the
  nine steps from an idea to a shipped feature with one command each and the file it writes,
  what runs by itself, what you invoke, uninstall — 173 lines, down from 348, with every
  "New in X.Y" paragraph moved here. The lint keeps it at 250 lines or fewer, free of version
  history above Install, and naming only skills that exist.
- **`GUIDE.md` has Playbook 4**, one feature from idea to shipped: the nine steps run for real
  on the eval fixture with the files each produced, including a `NOT READY` from the gate and
  seven `OUTSIDE` lines from `brief-verify.sh` that turned out to be a missing `.gitignore`.
- **`ROADMAP.md`** states the new north star in one sentence, marks the seven sprints shipped
  with their releases, and lists what is still open; the lint checks that its status line names
  the current version.

### What using it for real showed

The audit's rule — a line stays only for a project value or a named trap — cut more than
expected: four of the twenty-two rules had no such line at all, and the owner approved all
five proposed cuts. Criterion (c), "an eval shows it changes the result", could be applied to
no row, because no eval exists per rule file; the audit says so rather than guessing, and the
roadmap carries it as open. Playbook 4's real run produced two findings the invented version
would not have: `brief-verify.sh` flagged seven `__pycache__` files the agent never touched
(the fixture has no `.gitignore`), and the gate's independent reviewer, told only the slug
and the base ref, found the same files committed. The eval `rules/nontrivial` sat at 1 of 3
on this release's runs, its result since 3.1.0; the always-on rules it exercises did not
change in this release.

## [3.7.0] — 2026-10-06

Sprint 6 of the quality-gate plan: decisions that can tell you when they have stopped being
true, and one page a week that says which product needs you. Requirements and decision records
in [`.shipkit/specs/decisions-and-digest/`](.shipkit/specs/decisions-and-digest/); the intake
that shaped them is beside them.

### Added

- **A `Fired-if` line on decision records.** After the falsifiability clause, a record may
  carry one optional line: a shell command that exits 0 once the condition has come true
  (`**Fired-if.** \`test "$(wc -l < config/routes.rb)" -gt 500\``), or `manual` when the
  condition cannot be measured from the repository. `/shipkit:decide` asks "can a command
  check this?" and writes one or the other. The template is in the spec reference; the
  always-on `decisions` rule is unchanged, since it stands at 2,996 of its 3,000 bytes.
- **`decision-check.sh <project-dir> [--run]`** finds every such line in `.shipkit/decisions/`
  and the specs' `design.md` files. By default it lists each command with its record and runs
  nothing. With `--run` it runs them from the project directory and prints `FIRED`, `HOLDS`,
  `MANUAL` (with the clause) or `ERROR` per decision, exiting 1 only if something fired. Its
  header says the commands come from the repository and must be read before `--run` in one
  you do not trust; no hook calls it, and a smoke check keeps it that way.
- **The elders and the gate use it.** `grandfather` and `eve`, asked whether any decision is
  falsified, list the commands first and run them only for a project in your registry.
  `/shipkit:ship` has an eighth step: a `FIRED` decision is `NOT READY` until you write a
  superseding record or say to proceed.
- **`portfolio-digest.sh [registry-file] [--run-checks]`** writes
  `~/.claude/shipkit/digests/<date>.md` — one section per registered project with seven lines:
  top goal and review date, open specs with task progress, spec gaps, decisions, escapes in
  the last 30 days by cause, map age in commits, uncommitted files and unpushed commits. A
  project whose path has moved gets `path not found`. No model; decision commands run only
  with `--run-checks`. `SHIPKIT_HOME` moves the registry and the output directory together.
- **`/shipkit:ask --all digest`** runs the script and has `eve` answer one question from the
  page and `studio.md`: which product needs attention this week, and why — at most three,
  each reason a quoted digest line and the studio priority it bears on.
- The session briefing adds one line when the newest digest is more than seven days old.
- `GUIDE.md` shows how to schedule the digest with `cron` or `launchd`, as an option, and
  records why a scheduled cloud agent cannot produce it: a routine clones GitHub repositories
  and uses the skills committed to them, not your installed plugins or home directory.
- Eval case `digest/attention`, 3 of 3.

### Fixed

- `spec-check.sh`, `decision-check.sh` and `portfolio-digest.sh` call `mktemp` with a
  template. A bare `mktemp` on macOS ignores `TMPDIR` and writes to the system temp directory,
  which a sandbox may deny; the eval found this (below).

### What using it for real showed

The `digest/attention` eval failed 0 of 3 on its first run and the trace said why: the eval
sandbox denies the system temp directory, and the digest script died at `mktemp: Operation not
permitted`. A later single run passed only because the model wrote itself a `mktemp` shim —
a pass that would have hidden the bug. The fix touched two scripts from earlier tasks and one
from Sprint 2, each outside the task's file list; the owner approved and the list was extended
in the same commit. Seven other scripts still use bare `mktemp` and go to Sprint 7's audit.
Run on the real registry, the digest said one project had six unpushed commits and a map 36
commits old — both true, neither known.

## [3.6.0] — 2026-10-06

Sprint 5 of the quality-gate plan: a session starts by knowing where things stand and ends by
leaving a note. Requirements and decision records in
[`.shipkit/specs/briefing-and-handoff/`](.shipkit/specs/briefing-and-handoff/).

### Added

- **A briefing at session start.** The session hook now ends with at most eight lines
  (`scripts/briefing.sh`, 800 bytes at most): each open spec with its tasks done and the next
  one (up to three), a `spec-check` gap count when there is one, the top goal from
  `.shipkit/product.md`, and the last handoff's date, age in commits and next step. Nothing is
  printed for a project without `.shipkit/`. It uses no model and never fails the hook.
- **`/shipkit:handoff`** writes `.shipkit/state.md` — what is in flight and where, what got
  done, exactly one next step, open questions, traps — in at most 30 lines, replacing the
  previous note. `/shipkit:setup` offers to add it to `.gitignore`; it is for the next session
  on this machine, and a user who wants it to travel leaves it out of the ignore list.
- **After a compaction the hook says so:** `shipkit: context was just compacted — run
  /shipkit:handoff if work is in flight.` A reminder *before* compaction was not built: the
  `PreCompact` hook's output does not reach the model (stderr goes to the user, and its
  system message is discarded), while `SessionStart` runs again after compaction with
  `source: "compact"` and its output does. The decision record in the spec says what would
  move it.

### Changed

- `spec-check.sh` reads `tasks.md` in the same `awk` pass as `spec.md` instead of running a
  `grep` per requirement: the briefing runs it at every session start, and fifty open specs
  now take about half a second.
- The session hook reads the one line of JSON Claude Code sends it, with a half-second limit,
  so a wrapper that gives it a silent pipe cannot hang it.
- The core plugin has 17 skills.

### What using it for real showed

The gate's first run on this sprint answered `NOT READY` on one requirement: the changelog
entry it asked for did not exist yet. The release files were written first and the gate run
again. The handoff loop was closed once for real: a note written by `/shipkit:handoff`, then
a fresh session asked "what should I do next?" that answered from it.

## [3.5.0] — 2026-10-06

Sprint 4 of the quality-gate plan: a second pair of eyes that has not seen the implementer's
reasoning, and one command that says whether a feature is ready, with evidence. Requirements
and decision records in [`.shipkit/specs/review-and-ship/`](.shipkit/specs/review-and-ship/);
the intake that shaped them is beside them.

### Added

- **The `reviewer` agent.** Given only a spec folder name and a base git ref, it reads the
  spec and the diff and gives one verdict per requirement — `MET` with the file and line of
  the code and of the test, `NOT MET`, or `CANNOT TELL` — lists changes beyond the spec's
  `Paths` and decisions the code does not follow, and ends `VERDICT: PASS` or `FAIL`. A
  requirement marked `[untested: …]` is verified by reading. It has read tools and `Bash`
  only; it cannot edit or start agents, and it uses the session's model (`model: inherit`).
- **`/shipkit:ship <slug> [base-ref]`**, the gate: spec-check as shipped, the project's
  tests, every task ticked, the reviewer's verdict, a rollback for any migration, a concrete
  reversal condition on every decision, a clean tree. Each step is `PASS`, `FAIL` or
  `SKIPPED` with its evidence, in `.shipkit/releases/<date>-<slug>.md`, whose first line is
  `READY` or `NOT READY`. It never deploys, pushes, merges, tags or edits code, and it asks
  before marking the spec `shipped`.
- **`/shipkit:escape`** for a bug that reached users: at most three questions, then exactly
  one cause from six (`no spec`, `requirement missing`, `requirement wrong`,
  `requirement right, no test`, `test existed but was wrong`, `outside the product`), a record
  in `.shipkit/escapes/`, and — where the spec was at fault — the requirement added or
  corrected, the spec reopened, and a task whose test fails first.
- **`spec-check.sh --as-shipped`** asks an open spec for what a shipped one owes, without
  changing it.
- The Rails overlay's `deploy-check` and `release` skills say: if this feature has a spec, run
  `/shipkit:ship <slug>` first.
- Eval cases `reviewer/missing-req`, `reviewer/all-met` and `escape/missing-req`, all 3 of 3.

### Changed

- The core plugin has 16 skills and 6 agents.
- The spec reference says requirements describe the product, never the process after the
  gate: "the ship report says READY" cannot be met before the gate runs.

### What using it for real showed

`/shipkit:ship review-and-ship` was run on the sprint's own branch. The first run answered
`NOT READY`: two requirements and two tasks in the spec were about the gate's own result and
the release, which no feature can satisfy before its gate has passed. They became release
notes instead of requirements. The second run answered `READY`; the report is committed at
`.shipkit/releases/2026-10-06-review-and-ship.md`. The gate also caught its own first flaw
during development: its test run left `__pycache__` behind and its clean-tree step then
failed; it now judges the tree as it was before it ran.

## [3.4.0] — 2026-10-06

Sprint 3 of the quality-gate plan: shipkit learns what the product is for, asks a few good
questions before work starts, and turns a spec task into a brief any agent can follow.
Requirements and decision records in
[`.shipkit/specs/product-intake-brief/`](.shipkit/specs/product-intake-brief/).

### Added

- **`/shipkit:product`** writes `.shipkit/product.md`: one line, users, at most three goals
  this quarter (each with a metric, a target and a date), non-goals, the metrics that matter,
  constraints, and now / next / later. It fills in what `README.md`, `CLAUDE.md` and the map
  already answer before asking, and writes `metric: none set` rather than invent a number.
  `--studio` writes `~/.claude/shipkit/studio.md`, at most five ranked priorities across all
  your products.
- **`/shipkit:intake`** checks a request before it becomes a spec. It says "trivial — no
  intake needed" and stops when that is true; otherwise it states any conflict with the
  product's non-goals, an open spec or a past decision **before** asking anything, asks at
  most four questions whose answers change what gets built, and writes
  `.shipkit/specs/<slug>/intake.md`. `/shipkit:spec` runs it first when that file is missing.
- **`brief.sh`** (`scripts/brief.sh <project-dir> <slug> <task-id>`) builds the brief for one
  task from the spec's own files, with no model: the goal, the cited requirements word for
  word, the only files the task may edit, the test and `Done when` command, every task
  already done, the decisions that bind it, what is out of scope, and a fixed report form.
- **`brief-verify.sh`** (`scripts/brief-verify.sh <project-dir> <slug> <task-id> <base-ref>`)
  prints `OUTSIDE <file>` for anything changed since the base ref that the task did not
  list — committed, uncommitted or newly untracked — and exits 1.
- **Two columns in the project registry**, `Product` and `Top Goal`, filled by
  `/shipkit:map --register` from the product file, or `?`. An existing registry gains the
  columns; its other rows are not rewritten. `eve` reads both, and `studio.md`.
- **Three eval cases** for the intake (`intake/nongoal`, `intake/trivial`, `intake/limit`),
  all passing 3 of 3.

### Changed

- **The `spec-driven` rule** says to hand a spec task to an agent as `brief.sh` output,
  unchanged, and to check it with `brief-verify.sh`. The four points in full — the brief
  unchanged, the session verifying and running `Done when` itself, independent tasks in
  parallel worktrees, the team matched to the work — are in `/shipkit:spec` and the guide.
  Seven small wording cuts across the three rules pay for the sentence: 2,996 of 3,000 bytes.
- `/shipkit:map --register` lists only **open** specs under `Active Specs`.
- The core plugin now has 14 skills.

### What using it for real showed

The Sprint 4 spec was written with the intake and the checked format, and one of its tasks was
handed to an agent with `brief.sh`. What was awkward is recorded in the sprint's pull request.

## [3.3.0] — 2026-10-05

Sprint 2 of the quality-gate plan: a spec stops being a document someone promises to follow —
a script checks it. Requirements and decision records in
[`.shipkit/specs/spec-contract/`](.shipkit/specs/spec-contract/).

### Added

- **`spec-check.sh`** (`plugins/shipkit/scripts/spec-check.sh <project-dir> [slug]`). It reads
  the specs under `.shipkit/specs/` as plain text and prints one line per gap: `MISSING-TASK`
  (no task mentions a requirement), `MISSING-TEST` (a shipped spec has a requirement no test
  cites), `MISSING-FIELD`, `BAD-AFTER`, `CONFLICT` and `CYCLE` (the task format, below). It
  exits 1 when there is a gap, so it can run in CI — and now does, in this repository's `lint`
  workflow. POSIX sh, awk and git; no model calls. It checks that a citation exists, not that
  the cited test passes.
- **A status and a scope for every spec.** Two optional lines under the acceptance stamp in
  `spec.md`: `> Status: draft | open | shipped | dropped` and `> Paths: a/, b/`.
- **Tests cite requirements** as `<slug>/REQ-N` (for example `refunds/REQ-3`), in a comment or
  a test name. A requirement that is prose only is excused by ending it with
  `[untested: <reason>]`.
- **A task format a script can read.** Each task in `tasks.md` carries `Files` (the only files
  it may change), `Test`, `After` and `Done when`. Two tasks that list the same file must be
  ordered by `After`, directly or through a chain, so tasks that share nothing can be handed
  to agents at the same time.

### Changed

- **The session hook only nags about open specs, and only for commits that touch them.**
  `shipped`, `dropped` and `draft` specs are silent. With a `Paths` line, drift counts only the
  commits that touch those paths, and the line reads "N commits have touched its paths since
  it was accepted".
- **`/shipkit:spec` writes the new format**: `Status: draft` while the requirements are being
  written, `Status: open` and `Paths` on approval, tasks with the four sub-lines, and then it
  runs `spec-check.sh` and fixes what it reports. The templates in its reference are updated.
- **The `spec-driven` rule** says a requirement's test cites `<feature>/REQ-N`. The three
  always-on rules total 2,990 bytes of their 3,000-byte budget.
- This repository's three finished specs are marked `shipped`, with each requirement either
  cited beside the check that proves it or marked `[untested: …]` with its reason.

### Compatibility

A spec written before 3.3 needs no change. With no `Status` line it is treated as `open`; with
no `Paths` line drift is counted on the whole repository in the old wording; and its one-line
tasks are not asked for the new format. To stop the hook nagging about a finished spec, add
`> Status: shipped` under its stamp.

### Decided, then reversed, in this sprint

The file-sharing rule first required the later task to name the earlier one *directly*. The
first spec `/shipkit:spec` wrote under it ended with `After: T1, T2, T3, T4, T5, T6, T7`,
past the limit that decision had set for itself. The rule now follows chains and reports
cycles; both records are in the spec's `design.md`.

## [3.2.0] — 2026-10-05

Sprint 1 of the quality-gate plan ([`docs/plans/quality-gate-sprint-plan.md`](docs/plans/quality-gate-sprint-plan.md)):
measure whether shipkit helps, then cut what every session pays for. Requirements and decision
records in [`.shipkit/specs/measure-and-slim/`](.shipkit/specs/measure-and-slim/).

### Added

- **An eval suite.** `plugins/shipkit/evals/` holds eight cases run by `claude plugin eval`:
  one harness check, four for the `grandfather` elder (a lookup, an explanation, a map that is
  wrong, a question with no answer) and three for the always-on rules (non-trivial work,
  trivial work, a decision). `bash scripts/evals.sh` runs them all and exits non-zero if a case
  fails. They make real model calls, so they run before a release, not in CI. The README there
  records the case format that works, what graders can and cannot check, and the 3.1.0 baseline.
- **A fixture project** for the cases, `evals/fixtures/sample-app/`: nine files of plain Python
  with four planted facts listed in `fixtures/FACTS.md`.
- **A commit guard.** A `PreToolUse` hook on the Bash tool (`scripts/guard-commit.sh`) blocks a
  `git commit` when a staged file is named `.env`, `.env.*` (not `.env.example`), `*.pem`,
  `*.key`, `id_rsa*` or `credentials*.json`, and tells Claude to unstage it or ask you. It
  checks file names, not contents; it cannot see a file staged and committed in one command
  (`git add .env && git commit`); and it exits 0 on any error, so it never blocks a session by
  breaking.
- **A lint budget for always-on rules.** The core plugin's rules without `paths:` may total at
  most 3,000 bytes; more is an error.
- **The first project-wide decision record**, `.shipkit/decisions/0001-project-map-default.md`,
  and the measurements behind it in `docs/design/eval-results-3.2.md`.

### Changed

- **The three always-on rules shrank from 11,867 bytes to 2,960.** `shipkit.md`,
  `spec-driven.md` and `decisions.md` now say *when* to act; the *how* moved to skills that
  load on demand. The commit message format is in `/shipkit:commit`. The EARS patterns, the
  five-part decision record with its ✅/❌ examples, and the full workflow-style definitions
  are in the `/shipkit:spec` reference. The list of destructive actions to ask about is
  unchanged. If you installed the rules with `/shipkit:setup`, the session hook will tell you
  your copies are stale; run `/shipkit:setup` again to refresh them.
- `/shipkit:context-audit` describes the smaller rules.

### Fixed

Three bugs fixed in pull request #1, merged after 3.1.0 without a release:

- **The session hook aborted on 36 days of the year.** `date +%j` prints a zero-padded day
  (`008`), which shell arithmetic reads as invalid octal; the stale-spec rotation then exited 1
  with an error. Leading zeros are stripped first.
- **`install-stack.sh` overwrote a skill you already had under the same name.** Overlay skill
  names are generic (`new-feature`, `component`). A file under `.claude/skills/` that shipkit
  did not install is now kept and reported, and is replaced only with
  `SHIPKIT_OVERWRITE_SKILLS=1`.
- **`install-stack.sh` overwrote edits inside the managed CLAUDE.md stack section.** A section
  you edited is now left alone with a diff on stderr, and replaced only with
  `SHIPKIT_REFRESH_CLAUDE_MD=1`.

### What the measurements showed

- **The smaller rules behave like the old ones** on the three rules cases: trivial work 3 of 3
  before and after, decisions 3 of 3 before and after.
- **The spec-first rule mostly does not fire, at either size.** Asked to "add refunds to the
  billing module", Claude built the feature test-first without stating requirements in most
  runs: 1 of 10 runs put requirements first with the old rules, 1 of 9 with the new. The case
  is recorded as failing. Fixing it is the job of the intake and spec work in later sprints.
- **On a nine-file fixture the project map bought nothing**: the same correct answers with and
  without it, and 4% fewer tool calls. Decision 0001 records this, says how little a fixture
  that small can show, and changes nothing yet.

## [3.1.0] — 2026-09-14

Response to an external review of 3.0.0. Nine findings were raised; eight reproduced against
the tree and are fixed here. The ninth (`/unsetup` restore safety) is deferred to its own spec
rather than batched with one-line edits — redesigning a destructive restore path deserves its
own confirmation. Full requirements and decision records in
[`.shipkit/specs/install-lifecycle/`](.shipkit/specs/install-lifecycle/).

### Fixed — skills that failed before the model ever ran

- **`/legacy-audit` could not render.** Its dependency probe ran `ls` over eight lockfiles;
  `ls` exits **2** if *any* operand is missing, so a normal Rails project with only
  `Gemfile.lock` failed the whole skill — "Shell command failed for pattern", zero model turns.
  The same defect existed uncited in the `python` overlay's `new-feature` skill; both are fixed.
- **Every hook broke on a plugin path containing a space.** The commands interpolated
  `${CLAUDE_PLUGIN_ROOT}` unquoted and exited **127**. All four are quoted.
- **The README's local-test command registered neither plugin.** After the 3.0 split,
  `~/code/shipkit` is the *marketplace* root; the two plugin roots are what `--plugin-dir` wants.

### Fixed — installation ownership

The 3.0 stamp digested the plugin's **own** `rules/` directory, recording what was *shipped*
rather than what *landed*. One digest over the wrong side of the copy cannot say whether an
install is complete, which file drifted, or whether an installed file is now obsolete. Four
findings were that one defect:

- **An incomplete install silently disabled the always-on fallback.** `inject-rule.sh` tested
  for the *directory*, so deleting a rule from a complete install left it absent from disk **and**
  suppressed from context, with the stamp still matching and nothing warning. It now tests for
  the specific rule file, and the hook names any missing file.
- **Reinstalling never removed a rule upstream had dropped.**
- **Overlays and skills were outside the digest entirely.**
- Installation state now lives in a **per-file manifest** (`scripts/lib-manifest.sh`) recording
  every path shipkit wrote with its content digest, written atomically. A **pre-3.1 stamp owns
  nothing** — upgrading from 3.0 deletes nothing and simply starts tracking, because shipkit
  cannot know which files it wrote.

### Fixed — stack reinstalls reconcile

- **A rerun updated the installed skill but left CLAUDE.md asserting the old value**, so two
  files in the same install disagreed about how to run the tests. The `<!-- shipkit:stack:X -->`
  marker made the append idempotent and therefore un-updatable. Sections now have a **closing
  marker** and are refreshed in place; content outside them is never touched. A 3.0-era section
  with no closing marker is left alone with an explanation — its extent cannot be determined
  safely. `SHIPKIT_NONINTERACTIVE=1` warns instead of rewriting.

### Fixed — freshness measures drift, not just age

- **Lockfile-only dependency bumps went unnoticed** — `mix.lock`, `package-lock.json`,
  `yarn.lock`, `pnpm-lock.yaml`, `bun.lockb`, `go.sum`, `Pipfile.lock`, `Cargo.lock` and
  `composer.lock` are now in the manifest-change check.
- **Stale-spec reporting starved the tail.** It iterated in glob order and capped at three, so
  with N equally-stale specs the same three printed every session. Specs are now sorted by
  staleness, the **most-stale is always shown**, the remaining slots rotate between sessions, and
  the total is printed ("3 of 7 shown") so an omission is visible rather than silent.

### Changed — claims match mechanism

- **The MemPalace exclusivity claim was wrong.** A user-scope MCP server is inherited by the main
  session; a subagent `tools:` allowlist grants access to that subagent rather than withholding
  it from others. The accurate claim — *the elders are the agents configured to use it* — replaces it.
- **"Verified memory" now says what it means.** `grandfather` checks the specific claim against
  live source; `eve` answers some questions from the registry and labels them MEDIUM confidence —
  attributed snapshots, not live reads. There is no independent validator confirming a citation
  supports its claim, and the README says so.
- **`code-review-standards` lens 1 softened** from MUST thresholds ("functions under 20 lines")
  to SHOULD/CONSIDER signals: it loads on every review, so a blanket MUST is applied to code it
  has never seen. **`tdd` is deliberately left absolute** — it is invoked by name and its
  `DO NOT TRIGGER` clause excludes ordinary coding, so softening an opt-in enforcer would remove
  its reason to exist. The asymmetry is commented in place so it is not "fixed" later.

### Added — regression coverage

- Two lint rules: bare multi-operand `ls` in a `` !` `` injection, and unquoted
  `${CLAUDE_PLUGIN_ROOT}` in a hook command. Both produce **6 errors against the 3.0.0 tree** and
  0 against this one. `lint.py`'s hook parser now reads `hooks.json` as JSON and splits with
  `shlex` — a regex over a quoted shell string was the underlying weakness in both cases.
- Smoke fixtures for incomplete installs, reconciliation, legacy stamps, rule drift, the
  CLAUDE.md refresh, overlay manifest coverage, lockfile freshness and spec staleness. The old
  `sha=` tamper was replaced: a v1 manifest has no `sha=` line, so that assertion had quietly
  become a no-op.

### Fixed — `/unsetup` removes shipkit's files, not your directory

The ninth review finding, specced in
[`.shipkit/specs/unsetup-safety/`](.shipkit/specs/unsetup-safety/) and implemented here.

`/unsetup` used to delete `CLAUDE.md` and the **entire** `.claude/` directory, then copy a
snapshot back over the top. That discarded everything added since `/setup` — another plugin's
agents, your `settings.local.json`, any configuration you had built up — and it had no undo.

- **Removal is now driven by the installation manifest.** New
  `scripts/unsetup-remove.sh` takes out exactly the paths shipkit recorded installing, prunes
  only the directories it emptied, and never steps outside that list. Dry run is the default;
  `--yes` is required to remove anything.
- **A file you edited since installation is reported and kept**, unless you explicitly pass
  `--force`. Detected by comparing content digests against the manifest.
- **The manifest is removed last** — it cannot own itself, and an orphan would leave the session
  hook reporting an incomplete install forever.
- **Where shipkit cannot prove ownership** (no manifest, or a pre-3.1 version stamp) it exits
  non-zero, removes **nothing**, and the skill asks rather than choosing the destructive option.
- **`/unsetup` takes a recovery snapshot first** (`.shipkit-recovery-<ts>/`), before reading or
  touching anything, and aborts if that copy fails. `.claude/` is commonly git-ignored, so git
  is no safety net for what this removes.
- **It no longer deletes the backup it restored from.** Destroying the record of the state you
  just came from, as a side effect of a command run for another reason, is the same silent loss
  this work exists to remove.
- **`.shipkit/`** — your specs and decision records — remains untouched, as before.

### Fixed — `/setup` stops overwriting the pre-shipkit baseline

`/setup` snapshotted `.claude/` *as it currently was*, so running it a second time captured an
already-configured shipkit install as the "pre-shipkit baseline" — and `/unsetup` then restored
shipkit onto itself and called that your original state. Its preserve-or-delete prompt also let
you destroy the only true baseline permanently, silently, as a side effect of running setup.

- **`.shipkit-baseline/` is captured once and never overwritten.** Separate from the rolling
  `.shipkit-backup-<ts>/`, because "before shipkit ever touched this project" and "before this
  setup run" are different questions.
- Where shipkit was already installed before this version, `.captured` records
  `pre-existing-shipkit=true` so `/unsetup` reports what it actually restored instead of
  overclaiming.
- **The delete branch is gone.** Freeing a directory is not worth an unrecoverable loss.
- `/setup` offers to git-ignore the three snapshot artifacts — they can contain local settings.

### Changed — the project moved to GitHub

Development now happens at **https://github.com/AnjanJ/shipkit**. The Codeberg repository is
archived and its README redirects here; it stopped receiving releases after `v2.7.0`, so anyone
who installed from it is several versions behind.

**If you installed from Codeberg, re-add the marketplace:**

```
/plugin marketplace add https://github.com/AnjanJ/shipkit.git
```

Install instructions, both plugins' `repository` metadata, and the version-pin links now point
at GitHub. Structural lint moved from the Codeberg Woodpecker pipeline (which no longer runs
anywhere) to `.github/workflows/lint.yml`, on every push and PR.

### Known gaps

Not addressed here, and named rather than implied: there is still no behavioral evaluation suite
measuring whether the elders admit gaps instead of answering confidently; and the
net-context-efficiency claim remains unmeasured — moving research into a subagent hides those
reads from the parent context, it does not eliminate their tokens or latency.

The unsetup fixtures assert on the *script*, which is where the deletions happen. The skill's
interactive confirmation is verified by reading, not by test — a forked skill cannot prompt, so
the flow stays inline and untested by construction.

The `namespaces` smoke check is still model self-report and cannot read registration metadata
directly — the weakness the 3.0.0 review named. It now asks about one skill per invocation,
which is the minimum honest improvement, but a failure there means *investigate*, not *proven
broken*.

## [3.0.0] — 2026-09-14

### Changed — BREAKING: shipkit is now two plugins

The repo is a **marketplace** holding two plugins. Install either or both:

```
/plugin marketplace add https://codeberg.org/AnjanJ/shipkit.git
/plugin install shipkit@shipkit                # the knowledge layer
/plugin install shipkit-workflows@shipkit      # optional: the engineering workflows
```

> **Note added in 3.1.0:** the URL above is the one 3.0.0 shipped with, kept as a record. That
> Codeberg repo is now archived — use `https://github.com/AnjanJ/shipkit.git` instead.

- **`shipkit`** — the project knowledge layer: `map`, `ask`, `setup`, `unsetup`,
  `connect-memory`, `commit`, `update-rules`, `context-audit`, `spec`, `decide`,
  `explain-system`, `walkthrough`; the `grandfather`, `eve`, `archivist`,
  `codebase-explorer` and `tracer` agents; all 9 rules; all 10 stack overlays; the session hook.
- **`shipkit-workflows`** — the opinionated workflows: `qa`, `tdd`, `debug`, `humanize`,
  `legacy-audit`, `migration-plan`, the `code-review-standards` knowledge base, and the
  `test-analyzer` agent.

The line between them: **core produces, reads or installs knowledge artifacts; workflows tell
Claude how to do the work.** Core's per-session description tax drops by a third, and its pitch
is one sentence again.

**Each half works alone.** No plugin dependency is declared (Claude Code supports one, but its
install-time semantics are not yet nonce-tested here): the eight places where one half
referenced the other became soft references or self-contained fallbacks. `/shipkit-workflows:qa`
delegates to `shipkit:codebase-explorer` when present and the built-in `Explore` agent
otherwise; `/shipkit-workflows:tdd` states its whole discipline itself; the always-on `shipkit`
rule spells out the `strict-tdd` iron law rather than deferring to a skill that may not be
installed.

### Removed

- **`/shipkit:ui-ux` and the `ui-ux-standards` knowledge base.** The official
  [`frontend-design`](https://github.com/anthropics/claude-code) plugin covers design direction,
  and the platform should own what the platform ships — the same reasoning that cut five skills
  in 2.0. **The `ui-ux` path-scoped rule stays** and now carries a self-contained WCAG 2.2 AA
  baseline inline (semantic structure, accessible names, keyboard reach, contrast, target size,
  reduced motion, errors in text, no layout shift), so accessibility still applies automatically
  when you edit a UI file.
- **`/shipkit:ai-feature`.** The built-in `claude-api` skill covers the Anthropic SDK properly
  and stays current; the stack-specific AI knowledge that shipkit uniquely had (`ai-rails` —
  RubyLLM, Turbo Streams for streaming, jobs for every LLM call) **stays** in the Rails overlay.

### Migration

- `shipkit@shipkit` keeps its name, so `/plugin update` keeps the knowledge layer working.
  Install `shipkit-workflows@shipkit` to get the workflow skills back.
- Namespaces changed for six skills: `/shipkit:qa` → `/shipkit-workflows:qa`, and likewise
  `tdd`, `debug`, `humanize`, `legacy-audit`, `migration-plan`.
- `.claude/rules/shipkit/` installs are unaffected (rules did not move), but the rules digest
  changed, so the session hook nudges once — run `/shipkit:setup` to refresh.
- Pin [`v2.10.0`](https://github.com/AnjanJ/shipkit/releases/tag/v2.10.0) for the single-plugin
  layout, or `v2.9.0` for the layout before composable stacks.

### Internal

- `scripts/lint.py` derives the plugin roots from `marketplace.json` and runs every per-plugin
  check against each, so a third plugin needs no lint change. Version lockstep is enforced
  across both `plugin.json` files; the skill/agent counts in each marketplace description are
  checked against that plugin's own directory.
- `scripts/smoke.sh` runs against `plugins/shipkit` and gained a **namespace check**: both
  plugins registering together under distinct prefixes with no collision.

## [2.10.0] — 2026-09-14

### Added — composable stacks: Hotwire, LiveView, Oban, ML

- **Overlays are now composable.** A project has one **base** stack and any number of
  **add-ons**; `/shipkit:setup` detects the whole set, confirms it in one question, and runs
  `install-stack.sh` once per overlay. A Rails + Hotwire + React app now installs all three
  instead of whichever one matched first. No script change was needed: rules already land in
  `.claude/rules/shipkit/<overlay>/` and each overlay's `CLAUDE.md` section has its own marker,
  so sibling overlays and re-runs never collide.
- **`hotwire` overlay** (add-on to `rails`) — the missing half of every Rails app the author
  ships. Drive by default, Frames for scoped navigation, Streams only for multi-region or
  broadcast updates; Stimulus with `values`/`targets`/`outlets` instead of `querySelector`,
  cleanup in `disconnect()`, no inline handlers; Turbo cache and morphing safety (stable ids,
  `data-turbo-cache="false"` for transient UI); a system test for every Turbo flow.
- **`liveview` overlay** (add-on to `elixir`) — the lifecycle traps that cause most LiveView
  bugs: `mount/3` running twice (guard with `connected?/1`), `stream/4` for collections instead
  of a list in an assign, `handle_params/3` for URL state, `push_patch` vs `push_navigate`,
  scoped PubSub topics, function components over nested LiveViews, and `LiveViewTest` for every
  interaction including the disconnected render.
- **`oban` overlay** (add-on to `elixir`) — at-least-once means idempotent `perform/1`; args are
  IDs and primitives, never structs; `unique:` to deduplicate at enqueue time; the return-value
  contract (`{:cancel, _}` for permanent failures vs `{:error, _}` to retry); queues by priority.
- **`ml` overlay** (add-on to `python`) — three rules for the work that was previously
  unaddressed. `notebooks`: exploration only, promote reused code to modules, clear outputs,
  no secrets in cells, assume out-of-order execution. `experiments`: seeds set and logged, every
  run recorded with its config and git SHA, explicit device selection, never evaluate on
  training data, metrics saved beside the weights they describe, a named baseline.
  `data`: raw data and weights stay out of git, provenance and licence documented, dataset
  versions pinned, schema checks on load, personal data identified before use.
- **`react` is now an add-on** whose primary pairing is Rails (it still installs alone for a
  standalone SPA). Its rule gained a Rails-integration section: one component root, Inertia
  props as the API contract, routing stays in `config/routes.rb`, server-owned auth and flash,
  and the asset build running before the suite.

### Changed

- **The elders learned the new signals.** `archivist` detects the frontend interaction model
  (Hotwire / LiveView / Inertia / SPA) and ML signals, and `PROJECT_MAP.md` gained two optional
  sections — *Frontend interaction model* (where UI state lives, how updates reach the browser)
  and *Data & models* (datasets, pipelines, training entry points, artifacts, tracker) — written
  only when those signals are present. `eve`'s cheat-sheet gained matching rows so portfolio
  sweeps like "which apps use LiveView?" answer from one grep.
- **Path-scoped rules widened**: `security` now covers Django (`views.py`, `serializers.py`) and
  LiveView (`**/live/**`); `dependencies` covers `uv.lock`, `poetry.lock` and `importmap.rb`.
  The session hook's dependency-change nudge watches the same three new manifests.
- **Lint** gained an overlay check: an add-on must name an existing base with
  `<!-- requires: <base> -->`, and an overlay rule with no `paths:` (which loads in every
  session of the installed project) warns past a 2,000-byte budget.

## [2.9.0] — 2026-09-14

### Added — deterministic installs, a smoke test, and a stale-rules nudge

- **`scripts/install-rules.sh` and `scripts/install-stack.sh`** now do the copying for
  `/shipkit:setup`. The rules install stamps `.claude/rules/shipkit/.installed` with the plugin
  version and a digest of the rules; the stack install copies rules/skills, appends the stack
  section to `CLAUDE.md` once (marker-guarded, so re-runs are safe), substitutes every
  `{{…}}` placeholder from `KEY=value` arguments, and **fails before writing anything** if a placeholder you did
  not pass. Setup still does the detection and the interview; the result on disk is now the
  same every time.
- **`scripts/smoke.sh`** — the platform-assumption harness from the 2.7.0 audit, scripted:
  eight checks (rules inject, no double-inject, plugin-root line, exact agent set, knowledge-base
  skills registered, the ~10K per-hook cap, the install scripts, the stale-rules nudge) against
  a scratch copy in a fresh `claude --plugin-dir` session. Needs a logged-in `claude`; run it
  after `./scripts/lint.sh` before tagging.
- **Stale installed-rules nudge.** The session hook compares the installed stamp with the
  plugin's current rules and prints one line when they differ (or when the directory has no
  stamp — a 2.8 install): "run /shipkit:setup to refresh". Same closed-loop treatment the map
  and specs already get.
- **`tracer` agent** — a Sonnet, read-only, 40-turn agent for deep single-feature traces.
  `/shipkit:walkthrough` runs on it; `codebase-explorer` returns to its 25-turn / 20-file
  budget (the 2.8 bump was a stopgap). 6 agents.

### Changed

- **`spec-driven` honours the workflow style.** `lightweight` projects answer the three
  questions inline and write `.shipkit/specs/` only when asked (or via `/shipkit:spec`); the
  `decisions` rule still applies in full. `strict-tdd` / `test-first` unchanged.
- **Setup's CLAUDE.md is project facts only** (purpose, stack, commands, key paths, workflow
  style, team conventions; ≤ 40 lines before the stack section). The generic workflow
  boilerplate it used to carry — verification-before-done, investigate-before-fixing,
  docs-first for unfamiliar libraries, minimal impact, ask-before-destructive-operations —
  moved into the always-on `shipkit` rule, so every project gets it whether injected or
  installed and no LLM-written context file restates it. This is what the research the README
  cites recommends.
- **`lessons.md` retired.** Claude Code's own per-project memory covers corrections; shipkit's
  durable knowledge is the map, specs and decision records. Setup no longer creates
  `.claude/lessons.md`; if one exists the rule offers to migrate it into CLAUDE.md rules.
- **Agent `memory:` fields removed** from `archivist`, `grandfather`, `eve` and
  `codebase-explorer`. The field auto-loads a private `MEMORY.md` into the agent prompt, which
  contradicted "each call you start blank", "read-only" and "one write only", and runs against
  shipkit's verified-over-recalled stance. An existing `.claude/agent-memory/` directory is
  harmless and can be deleted.

### Fixed

- `.gitignore` ignored `.claude/` at every depth, which also hid `stacks/*/.claude/**` from
  `git add`. Now `/.claude/` (repo root only).

## [2.8.0] — 2026-09-14

### Fixed — the "automatic" tier now actually runs

An audit of 2.7.0 against Claude Code 2.1.270 found that several documented behaviours were not
wired to anything Claude Code loads. This release fixes every finding; the mechanisms shipkit
now relies on were each verified with a nonce test in a fresh session.

- **Rules never loaded.** Claude Code does not load a plugin's `rules/` directory (its plugin
  loaders are agents, commands, hooks, skills, settings, themes, monitors, output styles,
  workflows — no rules, no knowledge). So the 6 path-scoped rules, the `spec-driven` and
  `decisions` rules, commit discipline and lessons memory were inert for every user. Now:
  - the **session hooks inject the three always-on rules** (`shipkit.md`, `spec-driven.md`,
    `decisions.md`) at session start unless the project has them installed as files;
  - **`/shipkit:setup` installs all 9 rules** into `.claude/rules/shipkit/` (path-scoped rules
    can only work this way — a hook has no path semantics). Once installed, the hook stops
    injecting, so nothing loads twice.
- **Knowledge bases were unreachable.** `knowledge/` is not a plugin directory, so
  `code-review-standards` and `ui-ux-standards` never registered and the `ui-ux` rule pointed
  at a name Claude could not resolve. They now live under `skills/` as `user-invocable: false`
  skills (description always, body on demand — what "loaded on demand" was meant to mean). The
  Rails stack KBs moved to `stacks/rails/.claude/skills/` and install into `.claude/skills/`.
- **A template registered as an agent.** Claude Code scans `agents/` recursively, so
  `agents/templates/reference-map.md` became a seventh agent (`shipkit:templates:reference-map`,
  all tools, no frontmatter). The template is now inlined in `archivist.md`, which also fixes
  the archivist finding it only by searching the filesystem (the `@path` syntax is not expanded
  in agent bodies).
- **`/shipkit:connect-memory` derived the wrong transcript directory** for any project path
  containing `_`, `.` or a space — Claude replaces every non-alphanumeric character with `-`,
  not just `/` — and then silently skipped the backfill. Fixed (`sed 's/[^A-Za-z0-9]/-/g'`).
- **`/shipkit:setup` could not find the stack overlays** and never substituted
  `{{…}}` placeholders (the overlays referenced a `setup.sh` that never existed). The session
  hook now prints `shipkit: plugin root is <path>` and writes it to
  `~/.claude/shipkit/plugin-root`; setup has explicit source→destination paths and a full
  substitution table, and ends with a `grep '{{'` that must be empty.
- **Freshness hook regex** missed a map stamp written without backticks and a 7-char SHA.
- **Dead `|| echo` fallbacks** in the `!`…`` injections of `qa`, `ai-feature`,
  `safety-check`, `deploy-check`, `component` never fired (`git diff` exits 0 on empty output;
  after a pipe `||` tests `head`). Rewritten to guard on empty output.
- **`explain-system`** told a forked skill to delegate to `codebase-explorer` (subagents cannot
  spawn subagents) and its reference file waited for user feedback mid-run. Now reads directly
  and self-verifies.
- **`context-audit`** reasoned from a wrong model (knowledge bases "always loaded",
  `user-invocable: false` "loaded as context", invented "% of budget"). Rewritten around what
  Claude Code actually loads; points to native `/context` for numbers.
- **Removed plugin-root `settings.json`** — its `agent` key means "run this agent as the main
  thread" and the value was prose.
- **Docs drift:** agent count, "rules auto-load" wording, arXiv citation year, `/ui-ux audit`
  mode was advertised but undefined (now defined), Rails `release` pushed to `main` inside the
  "no side effects" phase (moved after the approval gate), `deploy-check` now cleans up the
  `assets:precompile` output, and the "use `/clear` between skills" tip is gone.

### Added

- `scripts/session-start.sh` replaces `check-map-freshness.sh` (plugin-root discovery + the existing
  drift nudges) and `scripts/inject-rule.sh` injects one always-on rule per hook command — Claude
  Code caps each hook's context contribution at ~10K chars, so the three rules ship as three
  commands; the lint enforces the size.
- `/shipkit:setup` Phase 4 (install shipkit rules) and an explicit Phase 5 with source paths
  and the placeholder substitution table.
- `/shipkit:ui-ux audit` — the review checklist across the whole UI surface, top-10 findings.
- `codebase-explorer` gets 40 turns (was 25) so a deep `/shipkit:walkthrough` can finish.
- Lint: recursive `agents/` purity, no `knowledge/` or plugin `settings.json`, hook scripts must
  exist and be executable, `{{…}}` placeholders only under `stacks/` and only if setup's table
  covers them, fork-interactivity scan over every `.md` in a forked skill, no subagent
  delegation from a fork, marketplace counts must match reality, dead-fallback warning.
  `./scripts/lint.sh` runs under `uv run --with pyyaml` when `uv` is present.

## [2.7.0] — 2026-07-08

### Added — one-command episodic memory setup

- **`/shipkit:connect-memory`** — sets up MemPalace end-to-end so `grandfather`/`eve` can recall
  *why* past decisions were made. It detects what's already done, installs MemPalace if missing
  (`uv`/`pipx`), registers it at user scope, **auto-derives your transcript directory** (the fiddly
  `~/.claude/projects/-Users-...` path users previously hand-built), splits concatenated
  transcripts, backfills this project's history (dry-run first, then for real), and reminds you to
  restart Claude Code. Safe to re-run — it skips completed steps. Optional as ever: skip it and the
  elders fall back to git history. Once per machine to install/register, once per project to
  backfill.
- **`/shipkit:setup` now points to it** — the setup summary suggests `/shipkit:connect-memory` as a
  next step for decision recall, so users discover the option instead of having to read the GUIDE.

MemPalace stays opt-in and unbundled (a separate package + ~300 MB model); this skill only
automates the setup the docs already described by hand. Docs (README + GUIDE) now lead with the
command and keep the manual steps as a collapsible fallback.

## [2.6.0] — 2026-07-07

### Added — decision capture + portfolio spec visibility

Completes the spec-driven development work from 2.5.0.

- **`/shipkit:decide`** — an inline, auto-invocable skill that interviews the five-part decision
  record (Context, Alternatives, Case-for, Case-against, Decision + a concrete falsifiability
  clause) and appends `.shipkit/decisions/NNNN-<slug>.md`. For deliberate, project-wide decisions;
  feature-scoped ones still go inline in a spec's `design.md` via `/shipkit:spec`. (2.5.0 deferred
  this to the always-on `decisions` rule; the guided skill earns its place for decisions made
  outside plan mode.)
- **Registry `Active Specs` column** — `/shipkit:map --register` now records the feature slugs
  with an open spec under `.shipkit/specs/*/`, so `eve` can answer "which projects have an open
  spec?" / "what's in flight across the portfolio?" from the registry alone — zero repo reads.

### Fixed

- **`/unsetup` never deletes `.shipkit/`** — made explicit that unsetup removes shipkit config
  (`CLAUDE.md`, `.claude/`) but never your specs and decision records, which version with the code
  as project work product. Previously correct but only implicit.

## [2.5.0] — 2026-07-07

### Added — Spec-Driven Development

The knowledge layer now looks **forward**. `PROJECT_MAP.md` indexes what exists; specs and
decision records capture what you're building next and *why* — durable, verified artifacts the
elders read. Everything lives under one root, `.shipkit/`, so humans, the elders, and MemPalace
share one canonical place to look.

- **Two always-on rules** — `spec-driven.md` (the three questions: *what are we building / how
  should it work / how will we know it's done*, EARS requirements, TDD/BDD-first) and
  `decisions.md` (the five-part decision record: Context, Alternatives, Case-for, Case-against,
  Decision + a **concrete falsifiability clause**). Both ride the existing trivial-vs-non-trivial
  split — a typo never gets specced.
- **`/shipkit:spec <feature>`** — an inline, auto-invocable skill that interviews a feature
  through the three questions and writes `.shipkit/specs/<feature>/{spec,design,tasks}.md`, with
  an approval gate on requirements and native Plan Mode before tasks. Requirements in EARS,
  design as decision records, done-criteria as tests with requirement → task → code traceability.
- **Elders read `.shipkit/`** — `grandfather` and `eve` now treat specs and decision records as
  first-class sources (preferring these verified records over `git log`/MemPalace for "why"),
  and can answer *"which past decisions are now falsified?"* by checking each record's
  falsifiability clause against current reality. `archivist` links active specs and decisions
  from `PROJECT_MAP.md`.
- **Spec-drift freshness** — the `SessionStart` hook now also nudges once per accepted spec whose
  code has moved ≥15 commits past its acceptance SHA (`SHIPKIT_SPEC_STALE_COMMITS`). Silent when
  fresh; always exits 0.

Design: `docs/design/spec-driven-development.md`. `/shipkit:decide` (standalone decision capture)
is intentionally deferred — the always-on `decisions` rule captures records during plan mode; the
skill will be added only if rule-driven capture proves insufficient.

## [2.4.0] — 2026-07-05

### Changed — all skills are auto-invocable

- **Removed `disable-model-invocation` from all 10 workflow skills** (`debug`, `tdd`, `qa`,
  `ui-ux`, `humanize`, `ai-feature`, `legacy-audit`, `migration-plan`, `explain-system`,
  `walkthrough`). Every shipkit skill is now model-invocable — Claude reaches for the right one
  when the work calls for it, in addition to explicit `/shipkit:<name>` invocation. This
  reverses the 2.0 decision to gate them behind manual invocation.
- **Added `TRIGGER when: / DO NOT TRIGGER when:` guidance** to the five skills that lacked it
  (`explain-system`, `humanize`, `legacy-audit`, `migration-plan`, `walkthrough`), so
  auto-invocation fires at the right moment instead of guessing from a bare description.
- **Trade-off to know:** these skills' descriptions are back in every session's context (the
  cost 2.0 removed), and Claude may trigger them on its own judgment. `tdd` stays bounded by
  its own "DO NOT TRIGGER when: normal coding" clause. To make any single skill user-only
  again, add `disable-model-invocation: true` to its frontmatter.

## [2.3.0] — 2026-07-05

### Added — Commit discipline

- **`/shipkit:commit`** — an auto-invocable skill that builds one atomic commit whose message
  scales to the change: a clean subject line for trivial commits, and **What / Why / How-and-
  decisions / Test plan** (plus Risk/Rollback, Follow-ups, Refs where they apply) for
  substantive ones. It splits or questions tangled changes instead of bundling them, stages
  specific files, and won't fabricate a test plan or add a co-author trailer.
- **Commit Discipline rule** — a new always-on section in `rules/shipkit.md` defines the
  format, so Claude follows it on *any* commit it makes, not only when the skill is invoked by
  name. The `/setup` CLAUDE.md template now points at this rule as the single source of truth
  instead of carrying its own commit list.

## [2.2.0] — 2026-07-04

### Docs

- **Doc audit against 2.1.0 code.** Fixed two stale claims found by auditing every count and
  cross-reference: the `code-review-standards` knowledge base has 9 review lenses (a 9th,
  AI/LLM integration, engages only when AI code is present), but the README and GUIDE still
  said "8 lenses"; and the README what's-new banner still led with 2.0, omitting eve's
  `matrix`/`consolidate` reports. Everything else — 16 skills, 5 agents, 6 path-scoped rules,
  stack tables, version strings — verified accurate.

## [2.1.0] — 2026-07-04

### Added — Portfolio reports

Two named report shapes for `eve`, completing the roadmap's "double down on eve" item:

- **`/shipkit:ask --all matrix <target>`** — dependency/version matrix across every registered
  repo, read from lockfiles (installed truth over declared ranges), one evidenced row per
  project. Built for upgrade planning and vulnerability sweeps ("which repos still ship
  lodash < 4.17.21?"). Eve reports what's found in the repos and never invents upstream
  "latest"/"vulnerable" claims — it names the check to run instead.
- **`/shipkit:ask --all consolidate`** — ranked report of patterns implemented in multiple
  repos that could exist once (auth glue, API clients, deploy scripts…), with per-copy
  `path` evidence, drift notes, and an honest "not worth consolidating" verdict where that's
  the right call. Capped at the top 5-7 candidates.

## [2.0.0] — 2026-07-04

Shipkit is now **the project knowledge layer for Claude Code**: project maps, the elders,
the cross-project registry, and freshness automation. The generic workflow skills that
duplicated what Claude Code does natively are gone; the remaining workflow skills are
opt-in. If you relied on a removed skill, pin the [`v1.3.0`](https://github.com/AnjanJ/shipkit/releases/tag/v1.3.0) tag.

### Removed (use the native equivalent)

| Removed skill | Use instead |
|---------------|-------------|
| `/shipkit:plan` | Claude Code's built-in **plan mode** (the shipkit workflow rule tells Claude to delegate plan research to `codebase-explorer`) |
| `/shipkit:review-my-code` | Built-in **`/code-review`** — the `code-review-standards` knowledge base (8 lenses, anti-patterns, severities) is kept and can back any review |
| `/shipkit:test` | Just ask Claude to run the tests — it detects the framework; the `test-analyzer` agent is kept for diagnosing failures |
| `/shipkit:use-library` | Claude reads docs before using unfamiliar libraries; the dependencies rule still enforces docs-first on dependency files |
| `/shipkit:onboard` | `/shipkit:map` + `/shipkit:ask` (the elders ARE the onboarding), or built-in `/init` for a CLAUDE.md |

### Changed

- **Ten workflow skills no longer auto-trigger** (`debug`, `tdd`, `qa`, `ui-ux`, `humanize`,
  `ai-feature`, `legacy-audit`, `migration-plan`, `explain-system`, `walkthrough`): they are
  `disable-model-invocation: true`, so they cost your context nothing and never fire
  unexpectedly — invoke them when you want them.
- **Registry v2.** The project registry gains `Stack` and `Deploys To` columns (pulled from
  each verified map at `--register`/`refresh` time), so `eve` answers common portfolio sweeps
  ("which are Rails?", "which deploy to Vercel?") from the registry alone — zero repo reads.
- README, GUIDE, and marketplace metadata rewritten around the knowledge-layer positioning.

## [1.3.0] — 2026-07-04

### Changed

- **The coding workflow is softer, configurable, and defined once.** The workflow used to be
  restated in three places (`rules/shipkit.md`, the `/setup` CLAUDE.md template, `/plan`) and
  installed strict TDD + "BDD is not optional" into every project. Now `rules/shipkit.md` is
  the single source of truth, `/plan` and `/tdd` point at it, and `/shipkit:setup` asks for a
  **workflow style** — `strict-tdd` (the old iron law, now opt-in via `/shipkit:tdd`),
  `test-first` (the new default: prefer test-before-implementation, pragmatic exceptions), or
  `lightweight` (tests where they earn their keep). Prescriptions you didn't choose degrade
  over long sessions anyway; a declared style is honored better than an imposed law.

- **`eve`'s grep guidance is now stack-agnostic.** Her fast-path examples were hardcoded to one
  specific portfolio (Hetzner/Kamal, Oban vs Sidekiq, Rails versions) and could aim another
  user's sweep at the wrong signals entirely. Replaced with a multi-ecosystem signal
  cheat-sheet (deploy, background jobs, framework versions, payments, datastores across
  Ruby/JS/Python/Go/Elixir/Rust/PHP), explicitly labeled as examples to extend, not an
  exhaustive registry.

### Added

- **Map-freshness hook.** A `SessionStart` hook (`hooks/hooks.json` +
  `scripts/check-map-freshness.sh`) compares `PROJECT_MAP.md`'s SHA stamp to HEAD and prints a
  one-line reminder when the map is ≥20 commits behind (tune with `SHIPKIT_MAP_STALE_COMMITS`)
  or when a dependency manifest changed since it was built. Silent otherwise; never fails a
  session. Maps used to rot until an elder happened to flag drift — now staleness announces
  itself. The project registry also gains a `Mapped At` SHA column so `eve` can spot stale
  rows without opening each map.

- **Plugin lint + CI.** `./scripts/lint.sh` validates everything the plugin ships: frontmatter
  parses with required fields, `@reference` links resolve, files directly under `agents/` are
  real agents (the 1.2.1 bogus-agent bug class), plugin/marketplace/CHANGELOG versions agree,
  no machine-specific absolute paths, rule `paths:` globs are well-formed, and — new bug class
  from this release — forked skills contain no interactive checkpoints. Runs in Woodpecker CI
  on every push (`.woodpecker.yml`). The path check immediately caught two real leaks of the
  author's home directory in the `/shipkit:map` registry template; those examples are now
  generic.

### Fixed

- **Interactive skills no longer run in forked contexts.** Forked skills cannot use
  AskUserQuestion (blocked in subagents), so every mid-run question or approval checkpoint in a
  `context: fork` skill silently never reached the user. Nine skills were affected:
  - `/setup`, `/unsetup`, `/plan`, `/qa`, `/tdd` now run **inline** — their interviews,
    approval checkpoints, and (for unsetup) the destructive-restore confirmation actually reach
    you. `/plan` and `/qa` keep context thin by delegating heavy code reading to
    `codebase-explorer` instead.
  - `/onboard`, `/walkthrough`, `/explain-system` stay forked but are now **fire-and-forget**:
    all choices come from arguments, they run end-to-end, and they RETURN their drafted docs as
    proposals — the main session writes files only after you approve. This also fixes
    `/onboard` and `/walkthrough` promising file writes while running as the read-only
    `codebase-explorer` agent, which has no Write tool.

## [1.2.5] — 2026-06-14

- **`grandfather` triages reads too.** Same cheap-path idea as eve, applied to single-project
  questions: a direct lookup ("where do background jobs live?", "what Ruby version?") now greps
  the signal directly instead of reading the whole `PROJECT_MAP.md` first. The map is read for
  explanation/judgment/orientation questions, where it earns its cost. Smaller win than eve (one
  map, not 19) but trims the reflexive full-map read on quick lookups.

## [1.2.4] — 2026-06-14

- **`eve` is cheaper for single-fact questions.** Added a triage step: portfolio questions that
  ask for one attribute per project ("which deploy to Hetzner?", "Oban vs Sidekiq?", "Rails 7?")
  now take a grep-the-signal fast path instead of full-reading every `PROJECT_MAP.md`. A
  single-fact sweep over ~20 repos drops from ~50k tokens (20 full map reads) to a handful of
  grep calls. Synthesis/360° questions still read the relevant maps in full.

## [1.2.3] — 2026-06-14

- **Docs:** documented `/shipkit:plan` in the README and GUIDE (it shipped but was undocumented),
  added this changelog, and added a "what's new" pointer to the README.

## [1.2.0 – 1.2.2] — 2026-06-13

The headline of the 1.2 line: **the project elders** — subagents that answer questions
about your code without polluting your main session's context — plus optional
**episodic memory** so they can recall *why* you decided things, not just how the code looks today.

### Added — The Project Elders

- **`grandfather` agent** — answers "how/where/why" questions about **one** project. Reads that
  project's `PROJECT_MAP.md`, verifies the specific claim against live source, and returns a tight,
  cited answer. All the file reading happens in its own context, so your main session stays thin.
- **`eve` agent** — the cross-project (360°) elder. Answers questions across **all** your registered
  projects by reading the registry plus each project's map ("which apps deploy to Hetzner?",
  "everywhere I integrate Stripe").
- **`archivist` agent** — builds and refreshes `PROJECT_MAP.md`: a verified, ~150-line index of a
  project (architecture, where-things-live, data model, evolution, gotchas), stamped with the git
  SHA it was built at. Verifies every cited path exists before writing.
- **`/shipkit:ask`** — route a question to an elder. `/shipkit:ask <q>` → grandfather (this project);
  `/shipkit:ask --all <q>` → eve (all projects).
- **`/shipkit:map`** — build/refresh a project's map. `--register` also adds it to
  `~/.claude/shipkit/project-registry.md` so eve can include it in cross-project answers.
  `refresh` re-verifies; `section <name>` regenerates one section.

### Added — Episodic memory (optional)

- `grandfather` and `eve` now allowlist the `mcp__mempalace__*` tools. If you install and register
  [MemPalace](https://github.com/mempalace/mempalace) at user scope, the elders use it to recall
  **decision history** ("why did we choose Paddle over Stripe?") from your past conversations —
  the narrative a structural map cannot hold. **Entirely opt-in; nothing breaks without it.**
- Because Claude Code defers tool schemas by default, the ~30 MemPalace tools cost your **main
  session almost nothing** until an elder actually calls one. See the README and GUIDE for the
  two-line install + the recall-is-a-claim caveat.

### Added — `/shipkit:plan`

- Plan-before-code workflow: PRD → tech spec → atomic task breakdown, each with a checkpoint.
  Runs in a forked context so the planning research does not weigh down your main session.

### Fixed

- **MemPalace wiring (1.2.2):** plugin subagents silently ignore inline `mcpServers` frontmatter
  (Claude Code strips it for security). Switched to user-scope MCP registration + a `tools:`
  allowlist on the elders, then verified recall end-to-end against a live project.
- Removed a machine-specific absolute path from the shipped agents (1.2.1) so MemPalace works for
  any user via `PATH`.
- Moved the PROJECT_MAP template under `agents/templates/` so it no longer registers as a bogus
  agent.

### Docs

- README and GUIDE document the elders, the episodic-memory add-on, and `/shipkit:plan`, including
  when **not** to use the elders (do not round-trip a subagent mid-edit for a fact you need inline).

## [1.1.0] — earlier

- Added `/shipkit:tdd`, `/shipkit:debug`, and `/shipkit:humanize` skills.
- Reduced context pollution; introduced progressive disclosure and auto-invocable skills.

## [1.0.0] — initial

- Core skills (setup/unsetup, qa, review-my-code, test, onboard, explain-system, walkthrough,
  update-rules, context-audit, use-library, ai-feature, legacy-audit, migration-plan, ui-ux),
  knowledge bases, and path-scoped rules. Stack detection via `/shipkit:setup`.
