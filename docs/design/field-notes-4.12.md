# Field notes 4.12 — shipkit's loop on a Python project built for the run

> Sprint 19, S19-T3 (second-run plan E17). Written 2026-10-30 while running, from the commands
> and their output. One project, one run, one model (`sonnet` headless): anecdote, not
> measurement, in the shape of `field-notes-4.9.md` so the three runs read side by side.
> **Nothing was fixed in this task**; every awkwardness is a one-line item under the ROADMAP's
> "Still open after Sprint 19", pointing back here. Spec: `.shipkit/specs/third-run/` (REQ-6,
> REQ-7).

**The repository, and a caveat before anything else.** The spec's default was a Python project
the owner names; none existed under `~/code`, and when asked the owner said "create a demo
python repo for testing of this" and "create a test item to work on". So the runner built one:
`linkshort` (`~/code/linkshort`), a URL shortener in Python 3.13 + FastAPI 0.135 with pytest
and uv — `pyproject.toml` with a `dev` dependency group and a `uv.lock`, `src/linkshort/`
(a `Link` dataclass, an in-memory `LinkStore`, a `LinkService` that creates and resolves codes,
a FastAPI app with `POST /links`, `GET /{code}` → 307, `GET /links/{code}`), 16 tests in two
files, a `README.md`, a `TODO.md` of five items, four commits on `main` (`a5f1eb8`), and **no
`CLAUDE.md`, no `.claude/`, no `.shipkit/`** — the first of the three runs on a project that
has never seen Claude Code or shipkit. The request is `TODO.md` item 1, link expiry, written
by the runner. The caveat: the project was built by the same hand that runs the loop, the day
of the run, with the loop in mind. Its layout is tidy and its test command is one line; the
findings below are about the tool on an easy project, and the project-side findings the 4.3
and 4.9 runs produced (a pinned toolchain the shell does not see, a tracked backup, a deny
rule that never matches) could not occur here. The third stack E17 wanted is here; the third
project's friction is not. `uv run pytest` → `16 passed, 1 warning in 0.02s` (the warning is
Starlette's: `httpx` with `starlette.testclient` is deprecated; install `httpx2` instead).

**Where it ran.** A worktree of `linkshort` at `main` (`a5f1eb8`) on a new branch
`shipkit/real-run-3`, created by this task under the session's scratchpad and never for merge;
`uv sync` in the worktree so `.venv/` (gitignored) exists there. The owner's checkout stayed
on `main`, untouched. `git status --short` before the first step: empty.

**How each skill was run.** `claude --plugin-dir "<shipkit checkout>/plugins/shipkit" --model
sonnet --allowedTools Read Glob Grep Bash Write Edit Skill Agent --output-format json -p
"/shipkit:<skill> … This run is not interactive"` from the worktree, the checkout at the
sprint branch (`7f27bc8`, the 4.11.0 plugin plus Sprint 19's spec and README line), standard
input from `/dev/null`. Cost and duration are the `total_cost_usd` and `duration_ms` fields
of the JSON result, so they are the API's numbers, not `date` arithmetic. New since 4.9: a
`--plugin-dir` session writes `~/.claude/shipkit/plugin-root.dev`, not `plugin-root` (PR #21,
the installed-root rule this sprint's T1 was paid by), so the rule-17 write-back after every
session is gone — checked after the first step below. No file under `plugins/` was edited
while a step ran.

Each section below answers the same six questions as the 4.3 and 4.9 notes: what the step
asked for, what it produced, how long it took, what was awkward, whose fault that is (the
tool's or the project's), and the evidence line.

---

## 1. Session start: what the sprint-branch hook says in a project that has nothing

- **Asked for:** nothing — the hook runs on its own. Measured by running
  `plugins/shipkit/scripts/session-start.sh` from the sprint checkout inside the worktree with
  `CLAUDE_PLUGIN_ROOT` set to the checkout's plugin, before any `claude` session.
- **Produced** (89 bytes, 158 ms; the three always-on rules are injected by the other hook
  commands — 2,014, 1,018 and 829 bytes — not by this script):
  ```
  shipkit: plugin root is ~/code/shipkit/plugins/shipkit
  shipkit: version 4.11.0
  ```
- **Took:** 158 ms.
- **Awkward:** two lines, both right, and the second is new (PR #21: the version on its own
  line). A project with no `PROJECT_MAP.md`, no `.shipkit/` and no installed rules gets no
  drift line, no spec line and no "installed rules are from" line — there is nothing to be
  stale. Nothing says "this project has no `CLAUDE.md`; run `/shipkit:setup`" — the always-on
  rule says to suggest setup when the user asks about setup, so a headless run never hears
  it. **The window is closed:** `~/.claude/shipkit/plugin-root` read
  `…/plugins/cache/shipkit/shipkit/4.11.0` before and after; `plugin-root.dev` did not exist
  before and holds the checkout's path after. Rule 17's write-back was not needed once in this
  run.
- **Whose fault:** nobody's.
- **Evidence:** the two lines above; `cat ~/.claude/shipkit/plugin-root` → the cache path,
  unchanged; `cat ~/.claude/shipkit/plugin-root.dev` → `~/code/shipkit/plugins/shipkit`;
  `git status --short` → empty.

## 2. `/shipkit:setup` — on a project with no `CLAUDE.md` and no `.claude/`

- **Asked for:** `/shipkit:setup`, told the run is not interactive: take the skill's defaults
  where it would ask, confirm the overlays as detected, keep any project file it would replace,
  and end with the list of files created or changed.
- **Produced:** the overlay `python` (FastAPI, REST, sync, pytest, uv — from `pyproject.toml`),
  no add-on (no ML deps, no notebooks); eight rules and `python/pyproject.md` under
  `.claude/rules/shipkit/` with `.installed` (`version=4.11.0`, `stacks=python`, a sha per
  file) and `.section-python.sha`; a **new `CLAUDE.md`** of 88 lines — a 30-line project
  section (purpose from `pyproject.toml`'s description, stack, `uv run pytest`, `uv build`,
  Lint `n/a`, `Workflow style: test-first`, a Key Paths table naming the five real files and
  `TODO.md`) and the python stack section under `<!-- shipkit:stack:python -->`; a project
  skill `.claude/skills/new-feature/SKILL.md` (3,482 bytes); four `.gitignore` lines;
  `.shipkit-baseline/.captured` only (`git-sha=a5f1eb8`, `shipkit-version=4.11.0` — "the
  project had no `CLAUDE.md` or `.claude/`, so only the metadata file was written") and a
  `.shipkit-backup-20261030-115000/NOTHING_TO_BACK_UP` marker. `.claude/settings.json` skipped.
  The reply named every default it took and ended with the file list asked for.
- **Took:** 33 s; $0.20; 7 turns.
- **Awkward:**
  1. **The reply caught the skill's text out: "The script reported 8, but the skill text says
     'nine'; I didn't check which is right."** `skills/setup/SKILL.md:224` says "It copies all
     nine rules"; `plugins/shipkit/rules/` holds eight `.md` files. A stale count in the skill,
     read aloud by the model that followed it.
  2. **The stack section is the template with its alternatives left in.** Under
     `## Python-Specific`: a second Key Paths table of generic rows (`src/` or `app/`,
     `migrations/` or `alembic/`, `config/` or `settings.py`) below the project's own
     resolved one; `Style` lists "Ruff (`ruff check .`) or flake8" and "`mypy .` or `pyright`"
     for a project the same file says has no linter; `### Django Gotchas (if applicable)`
     for a FastAPI project; `### Database` with `alembic upgrade head` for a project with no
     database. The placeholders the installer knows about were filled (`FastAPI`, `REST`,
     `no`, `pytest`, `uv run pytest`); the ORM placeholder became `TODO: none yet (in-memory
     store; SQLite planned in TODO.md)`, which is the honest value. The rest of the section is
     not placeholders, so detection cannot touch it: it is prose written for every Python
     project at once, and every session on this one loads the Django block.
  3. The baseline's `captured=` is UTC (`06:20:00Z` at 11:50 local); the backup directory's
     name is local time (`20261030-115000`). Two clocks in two files written by one step.
- **Whose fault:** (1) the tool's — one word; (2) the tool's — the stack template for
  `python` carries "or" lines and an "if applicable" block where `rails`'s does not; (3) the
  tool's, cosmetic.
- **Evidence:** `grep -n '^## ' CLAUDE.md` → `3:## Project Info`, `15:## Key Paths`,
  `25:## Conventions`, `34:## Python-Specific`; `sed -n '34,88p' CLAUDE.md | grep -c ' or '` → `14`;
  `grep -n nine plugins/shipkit/skills/setup/SKILL.md` → `224`; `ls plugins/shipkit/rules/*.md
  | wc -l` → `8`; `git status --short` → ` M .gitignore`, `?? .claude/`, `?? CLAUDE.md`.

## 3. `/shipkit:product` — no product file existed, and the project has no goals

- **Asked for:** `/shipkit:product`, told the run is not interactive, to write the best file it
  can from `README.md`, `TODO.md` and `CLAUDE.md`, to invent no metric, target or date, and to
  list the questions it would have asked.
- **Produced:** `.shipkit/product.md`, 1,793 bytes, 39 lines, the seven headings, seven
  questions in the blockquote under the review line. Goals this quarter: "Not decided yet. No
  goal, metric, target or date appears in README.md, TODO.md or CLAUDE.md." — the same for
  Metrics and Now. Two non-goals from the README ("deliberately has no … auth or deployment").
  Next/Later split the five TODO items ("TODO.md says 'in no order'", so the split is the
  model's, and it said so). The reply was five lines and said what the file does not have.
- **Took:** 18 s; $0.12; 3 turns.
- **Awkward:** the README's one sentence of non-goals is "no database, auth or deployment";
  the file kept auth and deployment and dropped database, because `TODO.md` item 2 plans
  SQLite. The project's two files disagree and the skill picked the side that let both stand,
  without a question about it among the seven. On a project with no goals, "Not decided yet"
  three times is the right output and reads as an empty file; 4.3 §2 and 4.9 §3 said the same
  of "none set".
- **Whose fault:** the project's for the contradiction; the tool's, mildly, for not naming it.
- **Evidence:** `.shipkit/product.md:5-12` (the seven questions), `:22` ("Not decided yet"),
  `:24-26` (two non-goals); `grep -n 'no database' README.md` → one line; `git status --short`
  → `?? .shipkit/` beside setup's files.

**The run paused here for the owner's request** — the intake step takes one real change. The
owner's word was "create a test item to work on"; the runner took `TODO.md` item 1.

## 4. `/shipkit:intake` — one small change: link expiry (TODO.md item 1); a 21-minute session

- **Asked for:** `/shipkit:intake Link expiry (TODO.md, item 1): a link can be created with an
  optional expires_at; following an expired link answers 410 Gone instead of redirecting, and
  GET /links/{code} shows the expiry.` Non-interactive, "write the intake file with any
  questions marked unanswered".
- **Produced:** `.shipkit/specs/link-expiry/intake.md`, 2,507 bytes, **written 28 s in, with
  its three questions marked *unanswered*.** No conflicts: the two non-goals checked, no specs,
  no decisions ("the last two don't exist"). Serves goal: none stated. Seven assumptions, each
  tied to a file: `None` means never expires; `GET /links/{code}` on an expired link still
  answers 200 and shows the expiry — "the request … gives no 410 for it"; an expired redirect
  does not count a visit ("a refused redirect is not a visit"); the code stays taken (409 on
  reuse; no `DELETE` yet); expired when `now >= expires_at` on the UTC clock; ISO 8601 or
  null in the response; 404 and 410 stay distinct. Five out-of-scope lines (SQLite, `DELETE`
  and sweeps, changing the expiry, `ttl_seconds`, items 4 and 5). Three questions: which goal
  (none exists; "None" allowed); a past `expires_at` — 422 or born expired; a naive
  `expires_at` — 422 or read as UTC, "`created_at` is timezone-aware UTC
  (`src/linkshort/models.py:5-6,12`), so a naive value can't be compared with it". The third
  question is the one the request did not know it was asking.
- **Took:** **20 min 50 s wall-clock** (11:51:17 → 12:12:07) for 65 s of API time; $0.28; one
  `grandfather` subagent.
- **Awkward:**
  1. **The session held itself open for twenty minutes after the work was done.** The
     transcript: at 06:21:24Z the skill spawned `shipkit:grandfather` for the code facts (the
     agent started in the background); at 06:21:28Z the model called **`ScheduleWakeup` with
     `delaySeconds: 1200`**, reason "Fallback in case grandfather agent notification never
     arrives", prompt = the whole `/shipkit:intake …` command again; by 06:21:47Z the agent had
     finished and at 06:21:50Z the intake was on disk and the reply written ("The intake is
     written to … with all three questions marked unanswered"); the hand-back and the task
     notification arrived at 06:21:50–55Z and the model said the report "matches what I read
     myself and doesn't change the intake". Then nothing until **06:42:00Z**, when the wakeup
     fired, the `/shipkit:intake` prompt ran again, and the model answered "`intake.md` already
     exists, and this request is the same text as before … I left the file unchanged. The user
     hasn't replied to the three questions either. The notification above is only the
     background agent finishing, not an answer." That last paragraph is the `result` field the
     runner got, and `duration_ms` (6,074) and `num_turns` (1) describe only that final turn;
     `total_cost_usd` covers the whole session. A headless `-p` session honours a scheduled
     wakeup and does not exit until it fires. 4.9's E8 ("a wait sentence leaks into the
     reply", closed by record in 4.10.0 as the harness's shape) has grown a body: the same
     wait, now with a timer on it, and a 1,200-second floor on the step.
  2. The first reply — the one a user would have read at 06:21:50Z — was right and complete;
     the runner never saw it in `result`, only in the transcript. In the 4.9 shape of the
     finding, the "wait" text came first and the answer followed; here the answer came first
     and a non-answer followed it twenty minutes later.
  3. Nothing in the skill asks for an agent to be awaited with a timer; the skill says the
     research runs in `grandfather` and the intake is written from it. Model behaviour on the
     harness's tools, not the skill's text — but the skill is what pays.
- **Whose fault:** (1) and (2) the platform's and the model's — a scheduled fallback for a
  notification the harness guarantees, in a session that cannot be interrupted; (3) nobody's.
- **Evidence:** the session's `.jsonl` (`b402a613…`): the `ScheduleWakeup` input
  `{"delaySeconds":1200,"reason":"Fallback in case grandfather agent notification never
  arrives", …,"noop":true}`; the subagent transcript's first and last timestamps
  `06:21:24.690Z` and `06:21:47.241Z`; `stat intake.md` → `11:51:45`; the `.start`/`.end`
  stamps `11:51:17` / `12:12:07`; `subagent_stats.spawned: 1, started_in_background: 1,
  completed: 1`; `intake.md:15-17`, each ending `— *unanswered*`; `git status --short` →
  `?? .shipkit/`.

**The run paused here for the answers.** The owner's word was "create a test item"; the runner
answered from the request's own wording and the smallest consistent scope, as 4.3 §4 and 4.9 §4
did: (1) none; (2) reject with 422, like an invalid target; (3) reject with 422 — `expires_at`
must be timezone-aware ISO 8601.

## 5. `/shipkit:intake` again, with the answers — it fills the blanks

- **Asked for:** the same request, non-interactive, told the intake file exists with its
  three questions unanswered and given the three answers: "fill them in rather than redoing
  the research".
- **Produced:** the same file, 2,618 bytes: the three `*unanswered*` markers replaced by the
  answers, and the Serves-goal line reworded ("None. … the user confirmed none applies").
  `diff` shows four lines changed and nothing else; assumptions and out-of-scope untouched.
  No agent spawned, no wakeup scheduled.
- **Took:** 15 s; $0.12; 5 turns.
- **Awkward:** nothing. 15 s against 4.9's 21 s and 4.3's 52 s. Once the questions are
  answered the step is the cheapest in the loop.
- **Whose fault:** —
- **Evidence:** `diff` of the two files: lines 9 and 15–17 only; the reply's "The assumptions
  and out-of-scope sections are unchanged"; `subagent_stats.spawned: 0`.

## 6. `/shipkit:spec link-expiry` — three drafts, checked on their own output

- **Asked for:** `/shipkit:spec link-expiry`, non-interactive; told the two approval gates
  cannot be passed, so: write the three files as drafts, keep `Spec not yet accepted` and
  `Status: draft`, propose a `Paths` line, show the requirements and decisions at the end, and
  run the checks the skill names on its own output.
- **Produced:** `spec.md` (1,706 B, eight EARS requirements, `> Paths: src/linkshort/,
  tests/`), `design.md` (3,085 B, an Approach paragraph, two decision records each with a
  `Fired-if` command, a Data / interface changes list), `tasks.md` (1,562 B, five tasks with
  the four sub-lines, `After` chaining the tasks that share files: T1 → T2, T1 → T3 → T4,
  T4 + T2 → T5). It read the intake and did not re-ask. The eight requirements are the seven
  assumptions and three answers of §4–5 turned into `shall` lines — REQ-3 and REQ-4 are the
  two 422 answers, REQ-6 is "a refused redirect is not a visit", REQ-8 is "the code stays
  taken". The first decision puts the expiry check in `LinkService.resolve` before the
  increment, "so no caller can count a visit on an expired link"; the second injects a clock
  (`LinkService(store, clock=utcnow)`) so the boundary `now == expires_at` is testable without
  sleeping or monkeypatching — both with a real alternative list and a case against the choice.
  The Approach names Pydantic's `AwareDatetime` for the request field, so REQ-4's 422 comes
  from the schema. The checks, run by the model and again by the runner: `spec-check.sh .
  link-expiry --as-open` → eight `PENDING-TEST`, `0 gap(s)`, exit 0; without the flag →
  `SKIPPED link-expiry (draft)`; `decision-check.sh . --run` → `2 decision(s), 0 fired, 2
  hold, 0 manual, 0 error(s)`. The reply ended with the requirements and decisions, and "To
  accept the draft: confirm the requirements and the design."
- **Took:** 58 s; $0.23; 5 turns; no agent.
- **Awkward:**
  1. **One test for two requirements.** T1 → REQ-2, REQ-3 names a single `Test:`
     (`test_create_rejects_expiry_not_in_the_future`), which is REQ-3's; REQ-2 ("without
     `expires_at` … null and never expire") has no test named anywhere in `tasks.md`. T3 →
     four requirements, one test name. The spec-driven rule says each requirement gets a test
     that cites it; the task list's `Test:` line is written as one name per task, so the rule
     is left to the builder. `spec-check` does not see it: it reports `PENDING-TEST` for all
     eight until code exists.
  2. The first decision's `Fired-if` (`grep -rl expires_at src | wc -l` greater than 3) sits
     exactly at the edge its own design draws — model, service, API are three files — so the
     first refactor that adds a fourth fires it. A threshold, as the rule asks, and a tight one.
- **Whose fault:** (1) the tool's, mildly — the `tasks.md` template's `Test:` line is singular;
  (2) nobody's.
- **Evidence:** the three check lines quoted above, re-run by the runner (`exit 0` each);
  `tasks.md:3-7`; `design.md:23-24`; `git status --short` → unchanged (`?? .shipkit/`).

## 7. Accepting the spec, committing it, `brief.sh` for T1 — and the test command

- **Asked for:** the owner's "approve" written by hand as the stamp (`Spec accepted at commit
  a5f1eb8 on shipkit/real-run-3 (2026-10-30)`, `Status: open`); setup's, product's and the
  spec's files committed on the throwaway branch; `brief.sh . link-expiry T1` — once before
  the commit, on purpose, to see E4's line; then from the clean tree (rule 19); the project's
  test command run once before any agent touched the tree.
- **Produced:**
  - **E4's warning, on the dirty tree:** `brief: 19 file(s) already differ from HEAD;
    brief-verify will count them` on stderr, the brief itself unchanged on stdout, exit 0. Four
    `git status --short` lines (one modified, three untracked directories) are nineteen files
    to the count — the number `brief-verify` would have reported, which is the point.
  - **The commit went through in 31 ms** — no pre-commit hook in this project. Staged by
    name: `.gitignore`, `CLAUDE.md`, `.claude/rules/shipkit/` (eleven files, `.installed` and
    `.section-python.sha` among them), `.claude/skills/new-feature/SKILL.md`,
    `.shipkit/product.md`, the four spec files. 19 files, 568 insertions. `git status --short`
    after: empty.
  - **`spec-check.sh . link-expiry`** on the now-open spec: eight `PENDING-TEST`, `0 gap(s)`,
    exit 0 — a requirement with no test yet is pending, not a gap, until code lands.
  - **`brief.sh` from the clean tree:** 65 ms, 1,639 bytes, nothing on stderr. Goal (the
    Purpose), REQ-2 and REQ-3 word for word, three files, the test and the Done-when, "Nothing
    — this task has no predecessors", one binding decision by title ("Inject the clock into
    `LinkService`" — the other decision cites REQ-5 and REQ-6, so it is rightly left out), the
    five out-of-scope lines, the report-back form.
  - **The test command as written works in the worktree, first try:** `uv run pytest
    tests/test_service.py` → `11 passed, 1 warning in 0.01s`, 454 ms wall. No toolchain to
    find, nothing to copy in. This is the easy-project caveat from the top of these notes
    made concrete: 4.3 §8 and 4.9 §7 each lost minutes here to a pinned toolchain the shell
    could not see.
- **Took:** about a minute, of which the test command was half a second.
- **Awkward:**
  1. **(tool, as 4.3 §7.4 and 4.9 §7.2)** the stamp is still written by hand in a headless
     flow — the third run to say so.
  2. **(spec, written by the model)** T1 carries REQ-3, "`POST /links` shall answer 422 and
     create no link", and may edit only `models.py`, `service.py` and `test_service.py` — an
     API requirement handed to a service-only task. The brief faithfully says "If the task
     cannot be done inside these files, stop and report blocked." Whether the agent notices
     is §8's question.
  3. E4 held: the line printed on the dirty tree and not on the clean one. E5 is checked in
     §8 and §9 (setup's files are now committed, so the question is whether `CLAUDE.md` and
     `.gitignore` are reported there).
- **Whose fault:** as marked.
- **Evidence:** `git log --oneline -1` → `ba2b59a spec: link expiry — setup, product file,
  intake and spec (shipkit real run 3, not for merge)`; the `brief:` stderr line quoted above,
  then `stderr: 0` bytes from the clean tree; `11 passed`; `git status --short` → empty.

## 8. Build — T1 handed to a headless agent with the brief, checked with `brief-verify.sh`

- **Asked for:** the loop's step 5: `brief.sh`'s output handed over unchanged, with four lines
  of context after it (the working directory and "the project uses uv — run tests with `uv run
  pytest`"; not interactive; write the test first and watch it fail; do not commit). A `claude
  --plugin-dir … --model sonnet` session with `Read Glob Grep Bash Write Edit`, so the
  project's new `CLAUDE.md`, the installed rules and shipkit's always-on rules loaded as they
  would for anyone. `git rev-parse HEAD` noted first (`ba2b59a`).
- **Produced:** the report in the brief's fixed form: `RESULT: done`; `CHANGED:
  src/linkshort/models.py, src/linkshort/service.py, tests/test_service.py`; `TEST: uv run
  pytest → 20 passed, 1 warning in 0.03s`, with "Before the implementation, the new tests
  failed at collection with an ImportError on `InvalidExpiry`"; **`NOT VERIFIED: The API
  layer (the REQ-2 JSON expires_at: null and the REQ-3 422 on POST /links) is outside this
  task's file list and was not touched`** — the agent saw §7.2's mismatch and said exactly
  what it had not done, instead of reaching for `api.py` or reporting blocked; `DEVIATIONS:
  none`, with "the brief's test name is parametrized over equal-to-now and past expiries. I
  also added two supporting tests." The diff: `models.py` +1 (`expires_at: datetime | None =
  None`), `service.py` +21/−4 (an `InvalidExpiry(ValueError)`, `clock: Callable[[], datetime]
  = utcnow` on the constructor as the second decision says, `expires_at <= self.clock()` →
  raise, the link stored with its expiry), `test_service.py` +33/−1 (a fixed `NOW`, three
  tests, the named one parametrized over `timedelta(0)` and `-1 s`, asserting the code is not
  in the store afterwards). **`brief-verify.sh . link-expiry T1 ba2b59a`** → `3 file(s)
  changed, all inside the Files of link-expiry / T1`, exit 0, first try — no OUTSIDE lines,
  because the tree was clean at hand-over (rule 19) and setup's files were committed in §7.
  **The runner's own run of the Done-when:** `uv run pytest tests/test_service.py` → `15
  passed`; the full suite `20 passed`.
- **Took:** 27 s for the agent ($0.15, 13 turns); the runner's checks under a minute.
- **Awkward:**
  1. **No test cites `link-expiry/REQ-N`.** `grep -rn 'REQ-' tests/` → nothing. The
     spec-driven rule (installed in §2 as `.claude/rules/shipkit/spec-driven.md`, and injected
     by the hook) says each requirement gets a test that cites `<feature>/REQ-N`; the brief
     says nothing about citing; the 4.9 agent did it unasked (`# team-local-day/REQ-6` on each
     test) and this one did not. `spec-check.sh . link-expiry` after the build therefore still
     reads `PENDING-TEST` for REQ-2 and REQ-3, the two the task was for, and the gate below
     will count them with the six that really have no test. The brief carries the Test and
     Done-when lines but not the citation convention the checker reads — the one line the
     agent needed from the rule, left to the rule.
  2. The agent's `TEST:` line reports the full suite (`uv run pytest`), not the Done-when's
     `tests/test_service.py`; a superset, and it said so.
  3. §7.2's mismatch (an API requirement on a service-only task) was handled the best way a
     brief allows: done inside the files, named under NOT VERIFIED. The report-back form earned
     its place again.
- **Whose fault:** (1) the tool's — `brief.sh`'s "Prove it with" could carry one line, "each
  test cites `<slug>/REQ-N`", since `spec-check` reads exactly that; (2) nobody's; (3) the
  spec's, which is to say the model's that wrote it, and the brief's form caught it.
- **Evidence:** the report's five lines quoted above; `brief-verify: 3 file(s) changed, all
  inside the Files of link-expiry / T1`; `grep -rc 'REQ-' tests/` → 0; the eight
  `PENDING-TEST` lines after the build; `git log --oneline -1` → `b608543 feat(service):
  expires_at on Link; create rejects an expiry not in the future, clock injected (link-expiry
  T1; shipkit real run 3, not for merge)` — `tasks.md` T1 ticked in the same commit.

## 9. `/shipkit:ship link-expiry` — the gate on a spec one task in

- **Asked for:** `/shipkit:ship link-expiry`, non-interactive, the test command given as
  `uv run pytest`, "do not change the spec's Status line".
- **Produced:** `.shipkit/releases/2026-10-30-link-expiry.md`, 6,596 bytes, first line
  `NOT READY`. Eight steps, every one run, every exit code captured: spec-check as shipped
  **FAIL** (`exit 1`, eight `MISSING-TEST` — "no test cites any REQ"); tests **PASS** (`uv run
  pytest` → `exit 0`, `20 passed`, the whole pytest output pasted); tasks ticked **FAIL** (T2
  to T5, by line number); independent review **FAIL** (`0 MET, 8 NOT MET`, `VERDICT: FAIL`);
  migration rollback **PASS**; decisions **PASS**; clean tree **PASS** (`git status
  --porcelain` captured before step 1, empty); **decisions fired FAIL** — `FIRED … test
  "$(grep -rl expires_at src | wc -l)" -gt 3`. "To fix before shipping" names the four. The
  reviewer's reply is in the report **line for line**: `diff` of the report's section 4
  against the reply in the subagent's transcript → identical. Every one of its seven
  `path:line` citations is right (`service.py:49-50` is the `InvalidExpiry` raise,
  `models.py:15` the field, `test_service.py:65` and `:77` the two test functions,
  `service.py:38-42` the constructor with the clock). The reviewer also read `.claude/rules/
  shipkit/` and `.shipkit-baseline/` as allowed (neither is listed) and listed `CLAUDE.md`
  and `.gitignore` "even though setup wrote it" — E5 as designed — and said REQ-3's test "has
  no `link-expiry/REQ-3` citation" (§8.1, seen from the other side). The spec's Status line
  was left alone. `$TMPDIR/shipkit-ship-*`: none left.
- **Took:** 51 s wall-clock ($0.27, 4 turns, one `reviewer` subagent started in the
  background — and the session ended when the work did, unlike §4).
- **Awkward:**
  1. **The decision fired on bytecode.** `grep -rl expires_at src` from `sh -c` is BSD grep,
     which lists a binary file that matches; after the first `pytest`, `src/linkshort/
     __pycache__/models.cpython-313.pyc` and `service.cpython-313.pyc` hold the string, so the
     count is 4 (`grep -rl --binary-files=text` → 4; `--include='*.py'` → 2). The record's
     own clause ("more than 3 source files") was true of two. `decision-check.sh` ran the
     command as written and reported what it said — right — and the gate told the owner to
     write a superseding record for a condition that has not come true. The command was
     written by the model in §6 against a tree that had no `__pycache__` yet; nothing in the
     spec skill says "a `Fired-if` that greps a source tree should name the file type", and
     nothing in `decision-check` confines a command to tracked files.
  2. **E5's always-allowed list misses the stack's project skill.** `.claude/skills/
     new-feature/SKILL.md` is written by `/shipkit:setup` (§2) as surely as the rules are, and
     the reviewer listed it as a change beyond the spec — "not under `.shipkit/`,
     `.claude/rules/shipkit/` or `.shipkit-baseline/`", quoting the list it was given. The
     4.10.0 list named the two directories 4.9 §9.4 saw; this project's first spec shows the
     third.
  3. **One stray scratch file.** The skill says "run `git status --porcelain` and keep its
     output" without saying where; the model kept it at `/tmp/ship-pre-status.txt` (0 bytes,
     12:17), outside the `${TMPDIR}/shipkit-ship-*` pattern the skill's own cleanup removes.
     The test and review outputs went to `shipkit-ship-tests.out` and `shipkit-ship-review.out`
     under `$TMPDIR` and were removed.
  4. The review file was written by heredoc from the model's context (`cat >
     "$TMPDIR/shipkit-ship-review.out" <<'EOF'`) and then pasted with `cat` — E7's mechanism,
     and it was verbatim this time; the file is still a transcription, not the agent's own
     stdout, so E7 holds on the model's care rather than on plumbing.
  5. The gate ran 20 tests to learn that nothing covers six unchanged requirements, in 20 ms.
- **Whose fault:** (1) the spec-writing model's for the command, the tool's for giving it no
  guard; (2) the tool's — the list wants `.claude/skills/<stack skill>/` beside the two
  directories, or setup's manifest read; (3) the tool's, mildly — one word ("under
  `$TMPDIR/shipkit-ship-…`") in the skill; (4) and (5) nobody's.
- **Evidence:** the report's first line `NOT READY` and its table; `decision-check: 2
  decision(s), 1 fired, 1 hold`; `grep -rl --binary-files=text expires_at src | wc -l` → `4`,
  `grep -rl --include='*.py' expires_at src | wc -l` → `2`; `ls src/linkshort/__pycache__/`
  → five `.pyc`; `ls -la /tmp/ship-pre-status.txt` → `0` bytes, `12:17`; `ls
  $TMPDIR/shipkit-ship-*` → no matches; the `diff` of section 4 against the subagent transcript
  → no differences; `sed -n '49,50p' src/linkshort/service.py` → the `InvalidExpiry` raise;
  `git status --short` → `?? .shipkit/releases/`.

---

## Did E1 to E7 hold on this project?

The seven debts Sprint 17 paid (second-run plan §2), one line each. Three could not be
exercised: this project had no `CLAUDE.md`, no `.claude/rules/` and no earlier backup, so the
shapes E1–E3 fix never arose — that is the cost of a project built for the run, said plainly.

- **E1** (the installer looks for an existing `## <Stack>-Specific` heading before appending):
  **not exercised** — no `CLAUDE.md` existed; the section was written into a new file under
  its marker (§2).
- **E2** (setup names a same-named rule in `.claude/rules/` beside its own): **not exercised**
  — no `.claude/rules/` existed (§2).
- **E3** (a tracked previous backup is left in place): **not exercised** — no previous backup;
  setup wrote a `NOTHING_TO_BACK_UP` marker (§2).
- **E4** (`brief.sh` warns on a dirty tree): **held** — `brief: 19 file(s) already differ
  from HEAD; brief-verify will count them` on the dirty tree, silence on the clean one (§7).
- **E5** (`.claude/rules/shipkit/` and `.shipkit-baseline/` always allowed; `CLAUDE.md` and
  `.gitignore` still reported): **held as written, and the list is one entry short** — the
  reviewer allowed the two directories and reported the two files, and also reported
  `.claude/skills/new-feature/SKILL.md`, which setup wrote too (§9.2).
- **E6** (a MET line cites `path:line` as `grep -n` prints it): **held** — no MET line to
  check, but all seven citations in the NOT MET lines point at the lines they describe (§9).
- **E7** (the gate writes the reviewer's reply to a file and pastes from the file): **held** —
  the report's section 4 is the reply line for line, through a heredoc the model typed (§9.4).
- **E8** (the wait sentence, closed by record in 4.10.0 as the harness's shape): **the shape
  changed.** No sentence leaked into any reply this run; instead the intake session scheduled
  a 1,200 s wakeup as a fallback for a notification that arrived twenty seconds later, and
  held the headless session open until it fired (§4.1). The record said "reopened if an
  interactive session shows it"; a headless one showed something costlier.

---

## What the run showed, in one place

Nine steps, about 4½ minutes of API time, seven headless sessions (setup 33 s, product 18 s,
intake 65 s API inside 20 min 50 s of wall-clock, intake again 15 s, spec 58 s, build 27 s,
gate 51 s), **$1.37 of API spend** (0.20 + 0.12 + 0.28 + 0.12 + 0.23 + 0.15 + 0.27) against
the ≈ $5–8 budgeted, and about 25 minutes of wall-clock, twenty of them §4's wait. The loop
held on the third stack as it did on the first two: every step produced the file it is for,
nothing had to be undone, and every check the runner re-ran agreed with the model's claim.

**What 4.9 asked for and is now there.** The brief warns on a dirty tree (§7, E4); the gate
pastes the reviewer's reply, and the reviewer's lines are file lines (§9, E6, E7); setup's two
directories are allowed (§9, E5); `brief-verify` reported nothing that was not the agent's,
first try (§8). Four of 4.9's eight items, seen closed here; three (E1–E3) could not be seen
either way on this project; one (E8) came back in a new body.

**What this run found, each a one-line item under the ROADMAP's "Still open after Sprint 19":**

1. `skills/setup/SKILL.md:224` says "all nine rules"; the plugin ships eight (§2.1).
2. The `python` stack section keeps the template's "or" lines (Ruff or flake8, `mypy` or
   `pyright`, `src/` or `app/`) and a Django block on a FastAPI project (§2.2).
3. Setup's two timestamps use two clocks: `.captured` in UTC, the backup directory's name in
   local time (§2.3).
4. `/shipkit:product` resolved a README-vs-TODO contradiction (no database vs SQLite planned)
   silently instead of asking (§3).
5. **A headless `/shipkit:intake` session held itself open for 20 minutes** on a
   `ScheduleWakeup` fallback (1,200 s) for a subagent notification that arrived in 20 s; the
   JSON `result` was the wakeup's non-answer, not the intake's reply (§4.1). E8's record needs
   reopening.
6. `tasks.md`'s `Test:` line is singular, so a task for two or four requirements names one
   test (§6.1).
7. The stamp is written by hand in a headless flow — third run to say so (§7.1).
8. `brief.sh` does not carry the `<slug>/REQ-N` citation convention `spec-check` reads; the
   agent's tests cited nothing and REQ-2/REQ-3 stayed `PENDING-TEST` after the build (§8.1).
9. A model-written `Fired-if` (`grep -rl expires_at src`) fired on `__pycache__` bytecode;
   the spec skill gives no guidance on grepping a source tree and `decision-check` runs the
   command over untracked files (§9.1).
10. E5's always-allowed list misses the stack's project skill, `.claude/skills/<skill>/`,
    which setup writes (§9.2).
11. The gate's pre-step `git status --porcelain` capture went to `/tmp/ship-pre-status.txt`,
    outside the `shipkit-ship-*` cleanup (§9.3).
12. The project's (and the spec's, written by the model): T1 carried an API requirement on a
    service-only file list, caught by the agent's NOT VERIFIED line (§7.2, §8.3); Starlette's
    `httpx` deprecation warning on every test run (top); the README's "no database" against
    TODO's SQLite (§3).

**The branch.** `shipkit/real-run-3` holds two commits (`ba2b59a` the setup, product, intake
and spec files; `b608543` T1 with `tasks.md` ticked) and one untracked report
(`.shipkit/releases/2026-10-30-link-expiry.md`); never for merge. **Deleted 2026-10-30 on the
owner's yes (F3)**, the log read first (rule 13): `git worktree remove --force` on the scratchpad
worktree, `git branch -D shipkit/real-run-3` ("was b608543"). The stray
`/tmp/ship-pre-status.txt` (§9.3) removed on the same yes. **The demo repository
`~/code/linkshort` is kept**, on the owner's word, at `main` (`a5f1eb8`) with a clean tree — the
owner's to reuse; the run's setup, product file, spec and T1 went with the branch.
