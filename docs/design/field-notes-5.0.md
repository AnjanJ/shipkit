# Field notes 5.0 — the same loop on the same project, on the thinned plugin

> Sprint 22, S22-T2 (thinning plan W5). Written 2026-10-31 while running, from the commands and
> their output. One project, one run, one model (`sonnet` headless): anecdote, not measurement,
> in the shape of `field-notes-4.12.md`, section for section, so the two read side by side.
> **Nothing was fixed in this task**; every finding is an item under the ROADMAP's "Still open
> after Sprint 22", pointing back here. Spec: `.shipkit/specs/run-again/` (REQ-8 to REQ-11).

**The repository.** `~/code/linkshort`, the Python 3.13 + FastAPI project built for the 4.12 run,
at `main` (`a5f1eb8`): the same tree that run started from, 16 tests, no `CLAUDE.md`, no
`.claude/`, no `.shipkit/`. The request is the same: `TODO.md` item 1, link expiry. The caveat
is 4.12's, and stronger: the project was built for a run, and this is its second. A difference
below is the plugin's or one model's roll, and a single run cannot separate those two.

**Where it ran.** A worktree of `linkshort` at `main` on a new branch `shipkit/real-run-4`, under
the session's scratchpad, never for merge; `uv sync` there. The owner's checkout stayed on `main`,
untouched. `git status --short` before the first step: empty. `uv run pytest` → `16 passed`.

**How each skill was run.** As 4.12: `claude --plugin-dir "<shipkit checkout>/plugins/shipkit"
--model sonnet --allowedTools Read Glob Grep Bash Write Edit Skill Agent --output-format json -p
"/shipkit:<skill> … This run is not interactive"` from the worktree, the checkout at the sprint
branch (`a5ede6a`: 4.12.0 plus Sprints 20 and 21 and W13's four sentences), standard input from
`/dev/null`. Claude Code 2.1.314. Cost is `total_cost_usd`; wall clock is from `date` around the
session, not `duration_ms`, because 4.12 showed that field can describe only the last turn. No
file under `plugins/` was edited while a step ran. `plugin-root` did not move.

Each section answers the same six questions and ends with one line against the 4.12 section of
the same number.

---

## 1. Session start: what the hook says in a project that has nothing

- **Asked for:** nothing — the hook runs on its own, measured as 4.12 measured it.
- **Produced:** 255 bytes in 159 ms, three lines: the root, the version, and a new one:
  "run /shipkit:product or /shipkit:setup to turn on spec-driven work here (the spec-driven and
  decision-record rules load only where a project has opted in)". The whole hook, with the one
  rule still injected, is 2,289 bytes, against 3,951 at 4.12.0.
- **Took:** 159 ms.
- **Awkward:** nothing. 4.12 noted that nothing told a bare project setup exists; the opt-in line
  does, and it pays for itself.
- **Whose fault:** nobody's.
- **Evidence:** `session-start.sh` output above; `scripts/context-cost.sh` row `hook 2289`;
  `cat ~/.claude/shipkit/plugin-root` unchanged, `plugin-root.dev` holds the checkout's path.
- **Against 4.12 §1:** better. 42% less on every session here, and it now says what to do next.

## 2. `/shipkit:setup` — on a project with no `CLAUDE.md` and no `.claude/`

- **Asked for:** the same words as 4.12.
- **Produced:** the `python` overlay (FastAPI, REST, sync, pytest, uv), detected right; eight rules
  plus `python/pyproject.md` and `python/django.md` under `.claude/rules/shipkit/`, with
  `.installed` and `.section-python.sha`; a new `CLAUDE.md` of **58 lines, 2,043 bytes** (88 lines
  at 4.12), its stack section 1,051 bytes; four `.gitignore` lines; `.shipkit-baseline/.captured`;
  an empty `.shipkit-backup-20261031-132323/`. **No `.claude/skills/`**: the reply says the overlay's
  `/new-feature` skill is not installed and how to add it (W6). The reply named every default.
- **Took:** 38 s wall clock; $0.20; 8 turns.
- **Awkward:**
  1. **A Django rule on a FastAPI project.** Sprint 21 moved the python append's Django block
     into a path-scoped `python/django.md`, and setup installs it whatever the framework. Its
     globs (`**/models.py`, `**/views.py`) are Django's names but not only Django's, and this
     project has a `src/linkshort/models.py`. The cost shows at §8.2.
  2. The stack section still reads as a template: `- **Framework:** FastAPI <!-- Django / FastAPI
     / Flask / None -->`, "FastAPI Gotchas (if applicable)", and "Use async ORM … with async
     endpoints" on a project the same section calls sync. 4.12 §2.2's "or" lines are gone; the
     alternatives survive as comments.
  3. Setup's two clocks are still two: `.captured` reads `07:53:23Z`, the backup directory
     `132323`, local time (4.12 §2.3).
- **Whose fault:** (1) the tool's, a consequence of W7; (2) the tool's; (3) the tool's.
- **Evidence:** `git status --short` → ` M .gitignore`, `?? .claude/`, `?? CLAUDE.md`; `wc -c CLAUDE.md`
  → 2,043; `sed -n 2,8p .claude/rules/shipkit/python/django.md` → the five globs; the reply's
  "the eight shipkit rules".
- **Against 4.12 §2:** better. 30 fewer lines, 3,482 bytes of skill not installed, and the reply no
  longer catches the skill out on "nine". Awkward (1) is new and the thinning caused it.

## 3. `/shipkit:product` — no product file existed, and the project has no goals

- **Asked for:** the same words as 4.12.
- **Produced:** `.shipkit/product.md`, 1,667 bytes. Goals "Not decided yet", no metric, target or date
  invented, six questions in a blockquote. The non-goal reads "No database, auth or deployment
  (README: 'deliberately small'). **Conflicts with the SQLite item in TODO.md; see question 3.**"
- **Took:** 19 s wall clock; $0.11; 3 turns.
- **Awkward:** nothing.
- **Whose fault:** —
- **Evidence:** `.shipkit/product.md`, the Non-goals section and question 3.
- **Against 4.12 §3:** better. 4.12 resolved that contradiction silently; this one names it and asks.
  The `product` skill's text did not change between the runs, so this is one model's roll until a
  second run repeats it.

## 4. `/shipkit:intake` — one small change: link expiry (TODO.md item 1)

- **Asked for:** the same request and the same "questions marked unanswered" as 4.12.
- **Produced:** `.shipkit/specs/link-expiry/intake.md`, 2,456 bytes, two questions marked unanswered
  (which goal; a past `expires_at`, 422 or born expired). 4.12's third question, a naive
  `expires_at`, became a stated assumption with a citation. Eight assumptions tied to files, four
  out-of-scope lines, one `grandfather` subagent.
- **Took:** **52 s wall clock** for 58 s of API time; $0.24; 2 turns.
- **Awkward:**
  1. **The stamp is wrong: "Intake taken on 2026-10-05."** Today is 2026-10-31, and step 3's file
     has the right date. Nothing in the intake skill says where the date comes from.
  2. The model waited with `sleep 45; echo waiting`, as two of W14's three runs did
     (`eval-results-5.0.md` §4). It costs a turn and nothing more: the file was on disk 40 s after
     the agent started.
- **Whose fault:** (1) the tool's, for asking for a date and giving no source; (2) nobody's.
- **Evidence:** the file's second line; `date`; the session transcript: `Agent` at 07:54:16,
  `sleep 45` at 07:54:22, `Write` at 07:54:56, reply at 07:55:00, no `ScheduleWakeup`.
- **Against 4.12 §4:** better. **No wakeup and no hold: 52 s against 20 min 50 s**, the same project
  and request with no sentence added (W14). One run; the wakeup was one run too.

## 5. `/shipkit:intake` again, with the answers — it fills the blanks

- **Asked for:** the same request, told the file exists with its two questions unanswered, given
  the two answers ("None; no goal applies"; "Reject with 422"): "fill them in rather than redoing
  the research".
- **Produced:** the same file, 2,594 bytes: the two answers in place and one added assumption
  saying how answer 2 is checked (`expires_at <= now`, on the same injectable clock).
- **Took:** 15 s wall clock; $0.11; 4 turns; no agent.
- **Awkward:** nothing.
- **Whose fault:** —
- **Evidence:** `diff` of the two files: lines 15–16 and one added line.
- **Against 4.12 §5:** same.

## 6. `/shipkit:spec link-expiry` — three drafts, checked on their own output

- **Asked for:** the same words as 4.12.
- **Produced:** `spec.md` (1,903 B, eight EARS requirements, `> Paths: src/linkshort/, tests/`),
  `design.md` (4,562 B, three five-part records), `tasks.md` (1,477 B, T1 to T4 chained). The
  runner's own `spec-check --as-open` → 8 `PENDING-TEST`, 0 gaps; `decision-check --run` → 0 fired.
- **Took:** 54 s wall clock; $0.23; 8 turns; no agent.
- **Awkward:**
  1. **`Test:` is still singular.** T1 cites REQ-1 and REQ-2 and names one test (4.12 §6.1). The
     agent wrote the second and reported it under DEVIATIONS (§8), which is the right shape for a
     thing the format has no room for.
  2. T4 is a characterization test that "cannot fail first", and `tasks.md` says so in the Test
     line. That is honest, and it is one more shape the "test fails first" field does not fit.
- **Whose fault:** (1) the tool's; (2) nobody's.
- **Evidence:** `tasks.md`; the reply's "it can't fail first".
- **Against 4.12 §6:** better on one point, same otherwise. Both `Fired-if` commands read one named
  file or count one pattern in one file, so neither can fire on bytecode as 4.12's did at §9.1. The
  spec skill changed only in naming `Explore`, so that is one model's roll. T1 now holds the API file, so 4.12 §7.2's
  mismatch did not recur.

## 7. Accepting the spec, committing it, `brief.sh` for T1 — and the test command

- **Asked for:** the owner's "approve" written by hand as the stamp; setup's, product's and the
  spec's files committed on the throwaway branch; `brief.sh` once on the dirty tree, then from
  the clean one; the test command once before any agent.
- **Produced:** `brief: 19 file(s) already differ from HEAD; brief-verify will count them` on the
  dirty tree. The commit: 19 files, 450 insertions, 33 ms, staged by name. `spec-check` on the
  open spec: 0 gaps. The session hook now says "link-expiry: 0 of 4 tasks done, next T1". The brief
  from the clean tree: 1,726 bytes, 68 ms, nothing on stderr, and under "Prove it with" the new
  line: "Each test cites the requirement it proves as `link-expiry/REQ-N`; `spec-check` reads
  exactly that." `uv run pytest` → `16 passed`.
- **Took:** about a minute, by hand.
- **Awkward:**
  1. The stamp is written by hand in a headless flow: the fourth run to say so.
  2. "Decisions that bind you: None recorded for this task's requirements." True by the rule the
     script follows, and the source of §8.1.
- **Whose fault:** (1) the tool's; (2) the tool's.
- **Evidence:** `brief.sh . link-expiry T1`; the commit `69578a5`; `git status --short` empty after.
- **Against 4.12 §7:** same, one line longer, for the reason W13 gave it.

## 8. Build — T1 handed to a headless agent with the brief, checked with `brief-verify.sh`

- **Asked for:** `brief.sh`'s output unchanged, with the same four lines of context as 4.12 (the
  working directory and uv; not interactive; write the test first and watch it fail; do not
  commit). `Read Glob Grep Bash Write Edit`. `git rev-parse HEAD` noted first (`69578a5`).
- **Produced:** the report in the fixed form: `RESULT: done`; four files `CHANGED`; `TEST: uv run
  pytest → 18 passed`, "the two new tests failed with KeyError on `expires_at`: 2 failed, 5 passed"
  before the code. **Both tests cite their requirement: `# link-expiry/REQ-1`, `# link-expiry/REQ-2`.**
  `DEVIATIONS` named the second test, the `AwareDatetime` type, and that a past `expires_at` is still
  accepted. `brief-verify.sh . link-expiry T1 69578a5` → `4 file(s) changed, all inside the Files`,
  exit 0, first try. The runner's Done-when: `7 passed`; the suite: `18 passed`. `spec-check` after
  the build: REQ-1 and REQ-2 gone from `PENDING-TEST`.
- **Took:** 22 s wall clock; $0.13; 8 turns; the runner's checks under a minute.
- **Awkward:**
  1. **The agent built the alternative the design rejected, because nothing told it.** Decision 3
     chose `InvalidExpiry` in the service over "Pydantic's `AwareDatetime` type for the naive check";
     T1's `CreateLink` declares `expires_at: AwareDatetime | None`. `brief.sh` selects a decision by
     the requirements it cites, and this one cites REQ-3 and REQ-4, so T1's brief said "None
     recorded". The agent did what a good agent does: T1 touches that field, the type fits, and it
     said so under DEVIATIONS. T2 now has to undo it or the spec has to change.
  2. **A Django rule loaded into a FastAPI agent.** Reading `src/linkshort/models.py` matched
     `**/models.py`, and "# Django Gotchas" arrived in the agent's context: `select_related`,
     `post_save`, `django-environ`. It changed nothing in the result; it is 583 bytes on a
     project with no Django in it, on the file any change to the data has to read.
- **Whose fault:** (1) the tool's: the brief binds by requirement, and a decision about a field binds
  whoever touches the field; (2) the tool's, from W7.
- **Evidence:** `git diff a5f1eb8 cc4619c -- src/linkshort/api.py`; `design.md` lines 40–54; the
  report's `DEVIATIONS` line; `grep -rn 'link-expiry/REQ-' tests`; the session transcript holds the
  rule's text and `django.md` by path.
- **Against 4.12 §8:** better on what W13 paid: 4.12's agent cited nothing and this one cited both,
  in 22 s against 27 s. Awkward (1) is a finding 4.12's run could not have made: its T1 cited a
  requirement its decision did, so the brief named it.

## 9. `/shipkit:ship link-expiry` — the gate on a spec one task in

- **Asked for:** the same words as 4.12. T1 committed first with `tasks.md` ticked (`cc4619c`).
- **Produced:** `.shipkit/releases/2026-10-31-link-expiry.md`, 6,415 bytes, first line `NOT READY`.
  Spec-check as shipped **FAIL** (REQ-3 to REQ-8), tests **PASS** (18), tasks ticked **FAIL** (T2 to
  T4), independent review **FAIL** (2 MET, 6 NOT MET), migration rollback **PASS**, decisions **PASS**,
  clean tree **PASS**, decisions fired **PASS**. The pre-step ran `git status --porcelain >
  "${TMPDIR:-/tmp}/shipkit-ship-status.out"`. The reviewer's reply is in the report whole. "Changes
  beyond the spec" lists `CLAUDE.md` and `.gitignore`. The spec's Status line was left alone.
  `$TMPDIR/shipkit-ship-*`: none left; nothing in `/tmp`.
- **Took:** 62 s wall clock; $0.26; 8 turns; one `reviewer` subagent; no wakeup.
- **Awkward:**
  1. **The reviewer's reply came through `SubagentHandback`.** The `Agent` tool result was only "This
     agent's report was delivered to you as a message from … Read it there; it is not repeated
     here", and the report arrived as a queued message; the model noticed and said so. So the gate
     pastes whatever text the reviewer gave that call. **That is the cause of `ship-gate`'s failures,
     shown from the session logs after this run:** three times the reviewer's last call was
     `SubagentHandback {"message": "placeholder"}`, once beside a last `grep` and twice alone. The
     tool answered "Report delivered to your caller", the agent ended, and the review was never sent.
     Why the model writes that word is not known. 3 of the 74 gate sessions in the logs, all three in
     the last ten and all on the complete-feature run, two of them in the last four, on Claude Code
     2.1.316. The gate failed closed each time: a false NOT READY, never a false READY.
  2. **The reviewer missed §8.1.** Its REQ-3 row cites `AwareDatetime` at `api.py:16`, and its
     decisions section says all three are "unimplemented, not contradicted". The code does
     contradict one, by the alternative that record rejected.
- **Whose fault:** (1) nobody's, a platform shape the gate does not name; (2) the tool's: the reviewer
  checks a decision's choice, not the alternatives it turned down.
- **Evidence:** the report; the session's `Agent` tool result and its `queued_command` attachment;
  the subagent log's `SubagentHandback` call; the transcript's `git status --porcelain >` line.
- **Against 4.12 §9:** better. The same cost and verdict for the same reason (one task of several),
  decisions fired PASS where 4.12's FIRED on bytecode, no stray file, and a report naming what to do.

---

## What a session here costs

`scripts/context-cost.sh` on the worktree, three times:

| Row | Before setup | After setup | After the first spec | 4.12.0, for comparison |
|---|---:|---:|---:|---:|
| `hook` | 2,289 | 90 | 90 | 3,951 before setup |
| `skills-core` | 2,894 | 2,894 | 2,894 | 3,969 |
| `skills-workflows` | 1,885 | 1,885 | 1,885 | 1,598 |
| `agents` | 991 | 991 | 991 | 1,720 |
| `overlay-skills` | 0 | 0 | 0 | 3,482 |
| `overlay-appends` | 0 | 1,051 | 1,051 | 2,507 |
| `rules-always-on` | 2,999 | 2,999 | 2,999 | 2,979 |

Before setup, the hook and the three description rows come to **8,059 bytes against 11,238, −28%**.
`rules-always-on` is the size of the three files as shipped, not an extra row to add: before setup
one of them reaches the session through `hook`, and after setup all three load from
`.claude/rules/shipkit/`. The first spec adds nothing here: it is files on disk. The briefing adds
one line once the spec is open.

## Did W13's four lines hold?

| Line | On this run |
|---|---|
| REQ-1, the brief's citation | **Held.** `# link-expiry/REQ-1` and `REQ-2` in the agent's tests (§8) |
| REQ-2, `brief-verify` and stack skills | **Not shown.** No skill was installed (§2); smoke check 72 proves it |
| REQ-3, the reviewer and stack skills | **Not shown,** for the same reason; smoke check 73 |
| REQ-4, the gate's capture | **Held.** The named file, cleaned up; nothing in `/tmp` (§9) |
| REQ-5, setup's rule count | **Held.** "the eight shipkit rules"; the reply did not catch it out (§2) |

The design's record for REQ-1 does not fire: the tests cite with the line in the brief.

## What the run showed, in one place

Nine steps, seven headless sessions, **262 s of session wall clock and $1.29 of API spend** (0.20 +
0.11 + 0.24 + 0.11 + 0.23 + 0.13 + 0.26), against 4.12's $1.37 and about 25 minutes, twenty of them
§4's wait. The thinned loop did the same work: every step produced the file it is for, nothing had
to be undone, and every check the runner re-ran agreed with the model's claim. No section reads
worse than its 4.12 section; seven read better, two the same. One run each: the better ones W13 or
W6 paid are the plugin's, and §3, §4's missing wakeup and §6's `Fired-if` may be one model's roll.

**What the cuts did not cost.** Ten skills, four agents and an overlay with no skill did not change
a step, and the session logs hold no call to a removed skill or agent.

**What this run found, each a one-line item under the ROADMAP's "Still open after Sprint 22":**

1. A decision binds by the requirement it cites, not the code it governs: T1's agent built the
   alternative the design rejected, and said so (§8.1).
2. The reviewer reads a decision's choice, not the alternatives it rejected, and called that
   "unimplemented, not contradicted" (§9.2).
3. `python/django.md` installs on any Python project and its globs match a FastAPI `models.py`, so
   a Django rule loads into a FastAPI agent. Sprint 21's W7 caused this (§2.1, §8.2).
4. `intake.md` stamped 2026-10-05 on 2026-10-31; the skill names no source for the date (§4.1).
5. A reviewer can end itself with `SubagentHandback {"message": "placeholder"}`, so its review is
   never sent: `ship-gate`'s failures, shown, cause in the model unknown. It fails closed (§9.1).
6. The stack section's alternatives survive as comments, and "async ORM" sits on a sync project
   (§2.2).
7. A model waits on an agent with `sleep 45`: a turn, and nothing worse (§4.2).
8. Setup's two clocks (§2.3), the singular `Test:` line (§6.1), the hand-written stamp (§7.1):
   4.12's items, seen again.

## What became of the branch

`shipkit/real-run-4` held two commits never for merge, `69578a5` (setup, product and the spec) and
`cc4619c` (T1), 23 files, +478/−4, plus the gate's untracked report. The log was read, and on the
owner's yes on 2026-10-31 the worktree and the branch were removed. `~/code/linkshort` is on `main`
at `a5f1eb8`, clean, one worktree, as it was before the run. T1's diff went with the branch; §8
quotes the line the top finding turns on.
