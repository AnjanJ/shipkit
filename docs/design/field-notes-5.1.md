# Field notes 5.1 — the owner's project again, on the plugin that binds decisions

> Sprint 25, S25-T2 (binding plan G10). Written 2026-11-01 while running, from the commands and
> their output. One project, one run, one model (`sonnet` headless): anecdote, not measurement, in
> the shape of `field-notes-4.9.md`, section for section, so the two read side by side. **Nothing
> was fixed in this task**; every finding is an item under the ROADMAP's "Still open after Sprint
> 25", pointing back here. Spec: `.shipkit/specs/fourth-project/` (REQ-11 to REQ-15).

**The repository.** The owner's Phoenix LiveView product, `~/code/office_bestie`, at `179f99d`: the
commit the 4.9 run started from, with 2,853 tests passing here, its own `CLAUDE.md` (135 lines),
its own `.claude/rules/` and `.claude/skills/`, and a `.shipkit-backup-20260321-082515/` in git. The
request is the same: `TODO.md:204`, the team's "today", chosen by the owner for this run. Nobody
built this project for a run, which is not true of `linkshort`, where 4.12 and 5.0 ran.

**Where it ran.** A worktree at `/private/tmp/shipkit-real-run-5` on a new branch
`shipkit/real-run-5`, never for merge, with its own database `office_bestie_test_shipkit5` through
`MIX_TEST_PARTITION=_shipkit5`, so nothing in the run reached `office_bestie_dev`,
`office_bestie_test`, `_rls` or `_rls2`. `git status --short` before the first step: empty. The
Check, free and first: `mise exec -- mix deps.get` exit 0, compile exit 0 (236 files),
`mise exec -- env MIX_ENV=test MIX_TEST_PARTITION=_shipkit5 mix test` → **2853 passed, 12 skipped,
14 excluded** in 13.3 s.

**How each skill was run.** As 4.9: `claude --plugin-dir "<shipkit checkout>/plugins/shipkit"
--model sonnet --allowedTools Read Glob Grep Bash Write Edit Skill Agent --output-format json -p
"/shipkit:<skill> … This run is not interactive"` from the worktree, the checkout at the sprint
branch (`a5a28d3`: 5.0.0 plus Sprints 23 and 24 and T1's four debts), standard input from
`/dev/null`, `MIX_TEST_PARTITION` exported for each. Claude Code 2.1.316. Cost is `total_cost_usd`;
wall clock is from `date` around the session. No file under `plugins/` was edited while a step ran:
between 18:44 and 19:08 UTC the orchestrating session's 23 Edit and Write calls are all to this file,
none of its 51 Bash commands writes under `plugins/`, and `git log a5a28d3..dde2099 -- plugins/` is
empty.

**Where the evidence is now.** Each step's output went to `/private/tmp/shipkit-real-run-5-tools/run/`,
the `run/` that the sections below cite. A reboot on 2026-11-04 cleared it, the worktree and the
gate's untracked report before the owner had said yes to removing anything (REQ-15). What remains:
the eight sessions' transcripts and their agents' logs, in
`~/.claude/projects/-private-tmp-shipkit-real-run-5/`; the branch's two commits; and the transcript
of the session that ran the steps (`1e9f924e`). Everything from §10 on was written on 2026-11-01 like
the rest, failed to save when the disk filled, and was put back word for word from that transcript
on 2026-11-04.

**What is different from 4.9 besides the plugin.** The owner changed their own Claude Code settings
on the night of this run: auto memory off, a global `CLAUDE.md` of 3,492 bytes that every session
here loads, the Artifact and Workflow tools off, sixteen built-in skills user-invocable only,
`CLAUDE_CODE_SUBAGENT_MODEL=sonnet`, default model Opus. Every session below names `--model sonnet`,
and the reviewer has been pinned to `sonnet` since `4f81799`. A difference below can be the plugin,
those settings or one model's roll, and a single run cannot separate the three.

Each section answers the same six questions and ends with one line against the 4.9 section of the
same number.

---

## 1. Session start: what the hook says in `office_bestie`

- **Asked for:** nothing — the hook runs on its own, measured as 4.9 measured it:
  `plugins/shipkit/scripts/session-start.sh` from the checkout inside the worktree.
- **Produced:** 362 bytes in 187 ms, four lines: the root, the version, the opt-in line ("run
  /shipkit:product or /shipkit:setup to turn on spec-driven work here"), and the stale map ("58
  commits behind HEAD"). The whole hook with the one rule injected is 2,396 bytes.
- **Took:** 187 ms.
- **Awkward:** nothing. The line 4.9 missed, that nothing tells a project setup exists, is the
  opt-in line. The offer to migrate `.claude/lessons.md` is still the rule's job, not the hook's.
- **Whose fault:** nobody's.
- **Evidence:** `run/01-hook.out`; `git status --short` empty after it;
  `~/.claude/shipkit/plugin-root` still the cache path; `plugin-root.dev` holds the checkout's path.
- **Against 4.9 §1:** better. 189 bytes more, and they are the two lines a project with nothing
  needed.

## 2. `/shipkit:setup` — on a project that had shipkit once, and its own rules

- **Asked for:** 4.9's words, plus yes to the overlay's skills: pass `--with-skills`.
- **Produced:** the overlays `elixir` + `liveview` + `oban`, detected; eight core rules and three
  stack rules under `.claude/rules/shipkit/`; `CLAUDE.md` 135 → 201 lines (210 at 4.9), 8,964 bytes;
  five `.gitignore` lines; `.shipkit-baseline/`; a new `.shipkit-backup-20261101-001521/` holding
  `CLAUDE.md` and `.claude/`. The tracked `.shipkit-backup-20260321-082515/` stayed where it was. The
  project's `new-feature` skill was kept, so `--with-skills` installed nothing: the elixir overlay
  ships only that one skill and `liveview` and `oban` ship none. The reply named every default and
  ended with the file list. Every value it filled agrees with the source: the seven Oban queues
  (`config/config.exs:28`), `testing: :manual` (`config/test.exs:30`), `dashboard:<workspace_id>`
  through `Notifications.dashboard_topic/1`, `user:<user_id>`, and
  `test/office_bestie_web/live`.
- **Took:** 52 s wall clock; $0.20; 12 turns.
- **Awkward:**
  1. **The second `## Elixir-Specific` is still there.** The installer now says so, and the reply
     relays it with the way out ("To merge them, run `/shipkit:setup rules`"). It is one line to
     the owner, not a fix: two sections with one heading still load into every session, and the
     project's own `MIX_ENV=test mix test` and shipkit's `mix test` still disagree.
  2. **`lib/<app>/` is still in the section.** The elixir append's Key Paths table holds `<app>` as
     literal text, in a section whose LiveView half names `test/office_bestie_web/live`. No
     placeholder covers it. The section cleaning of T1 reads comments, so this was never in its
     reach.
  3. **The backup is a second one.** Setup left the tracked one alone, as it should, and made
     another of 192 KB, git-ignored. Two `.shipkit-backup-*` at the root, one tracked, one not.
     Nothing is wrong with it. It reads oddly.
  4. **`grep` in the session's shell is ripgrep.** Call 4's `grep -roh '{{[A-Z_]*}}'` failed three
     times with `rg: regex parse error`; the model reran it as `command grep`. One turn. The shell,
     not the plugin.
- **Whose fault:** (1) the tool's, knowingly: Sprint 17 (`run-debts` REQ-1 and REQ-2) chose to name
  it, not merge it; (2) the tool's; (3) nobody's; (4) nobody's.
- **E1, E2, E3:** all three **held**, each on the line it was written for. See "Did the decisions
  and the debts hold?" below.
- **Evidence:** `run/02-setup.json`; the session's calls 3, 4 and 10; `git status --short` →
  ` M .gitignore`, ` M CLAUDE.md`, `?? .claude/rules/shipkit/`, and no ` D`.
- **Against 4.9 §2:** better. Findings 1, 2 and 3 of that section are answered, each in one line of
  the reply, and the fourteen deletions are gone.

## 3. `/shipkit:product` — no product file existed

- **Asked for:** 4.9's words: not interactive, the best file it can from `README.md`, `TODO.md`,
  `docs/` and `CLAUDE.md`, invent no metric, target or date, list the questions it would have asked.
- **Produced:** `.shipkit/product.md`, 3,170 bytes, 49 lines, the seven headings, eight questions as
  the blockquote. Three goals taken from `TODO.md` and the go-to-market plan, two of them all "none
  set", one with the project's own 90% bar and no date. Four non-goals, inferred and said to be. The
  review line reads `2026-11-01`, the run's date, from a `date +%F` in the session's first call.
- **Took:** 35 s wall clock; $0.15; 6 turns.
- **Awkward:** the same line 4.3 and 4.9 wrote: "metric: none set" reads as broken to anyone who has
  not read the skill. The questions on disk are still what makes that acceptable. On the same tree
  from the same sources the third goal is not 4.9's (the Slack listing, where 4.9 wrote design
  partners) and the first is worded differently. Not wrong, and the file says the goals came from
  the files, not the owner.
- **Whose fault:** nobody's; the "none set" shape is the owner's to fill. One model's roll for the
  different goals.
- **Evidence:** `.shipkit/product.md`; the session's calls 1 and 5; the claims read against the
  repository (`git grep` over `README.md`, `TODO.md`, `CLAUDE.md`, `docs/`): each of the seven words
  sampled from the Constraints and Non-goals lines is there.
- **Against 4.9 §3:** the same. The stamp is the run's date, the first of the stamps read below.

**The run's request was already the owner's** (asked 2026-10-31, the spec's Answers), so no pause.

## 4. `/shipkit:intake` — one small real change: the team's day (TODO.md §4)

- **Asked for:** 4.9's words, word for word. Non-interactive.
- **Produced:** `.shipkit/specs/team-day-boundary/intake.md`, 3,505 bytes, 35 lines, three questions
  marked *unanswered*: whose day; which goal; whether the other UTC-midnight places move too. No
  conflicts, each kind checked and named, with the honest line "I did not search MemPalace or git
  history for an earlier decision". The research went to `grandfather` as the skill says. Every
  citation sampled reads as the file says: `team_pulse.ex:18`, `actions.ex:255`,
  `manager_briefing.ex:97` and `:110`, `ai/coach.ex:64`, `accounts.ex:596`,
  `team_pulse_worker.ex:76`, `summary.ex:14-15`, `standups.ex:13`. The stamp reads `2026-11-01`, from
  `d=$(date +%F)` in the call that wrote the file. This is the file 5.0 stamped `2026-10-05`.
- **Took:** 343 s wall clock; $0.49; 17 calls. **The work took 90 s.** The file was on disk at
  00:19:34 and the real report written at 00:19:42. The session then stayed open four minutes for
  nothing, and two more model turns.
- **Awkward:**
  1. **The wait outlives the work.** `grandfather` ran in the background and took 53 s. The model
     tried `sleep 90` (Claude Code blocked it: "use Monitor"), then armed two `Monitor` watches on
     the agent's output, though its own notification was coming anyway. The agent's notice arrived
     at 00:19:19; the watches, with five-minute expiries, stayed armed, and a headless session does
     not end until they do. They expired at 00:23:42 and 00:23:52, and each woke the model for one
     more turn.
  2. **The reply is the last turn.** The JSON `result`, what a headless caller gets, is "That is the
     second wait timing out. The agent had already finished and the intake is written, so I have
     nothing left to do." The report written at 00:19:42 is only in the transcript. `duration_ms`
     says 2,023.
  3. While `grandfather` ran, the model made nine reads and searches of its own (`Grep`, `Read`, one
     `Bash`), which the skill says to leave to the agent (`intake/SKILL.md:34`). Small.
  4. **The slug is a roll:** `team-day-boundary` here, `team-local-day` at 4.9, same words. The steps
     below use this run's.
- **Whose fault:** (1) the model's and the platform's: 5.0's `sleep 45` (§4.2 there) is blocked now,
  and the way out it names is worse in a headless session. The skill says nothing about waiting; a
  line there might help, and no run has shown it would. (2) The platform's. (3) The model's. (4)
  nobody's.
- **Evidence:** `run/04-intake.json`; the transcript's timestamps; `subagents/agent-ad3e…meta.json`
  (`"requestShape":"background"`, first and last lines 18:48:26 and 18:49:19 UTC).
- **Against 4.9 §4:** the file better, the session worse. One fewer question and the same coupling
  found (the Coach shares the count, in Q1's text); 5.0's wrong stamp gone; 343 s against 97 s, all
  of the difference a wait. 4.9's leaked "still running" sentence and this reply are one family:
  a background agent's wait reaching the reader.

**The run paused here for the answers.** The owner was not asked, as at 4.9: the runner answered
from the request's own wording and the smallest consistent scope, and says so. (1) The workspace's
day for all three, `TODO.md` names it first, and one count for every viewer, so the Coach moves with
the shared function; (2) none, a correctness fix; (3) only the three named, the rest out of scope
and noted as a follow-up.

## 5. `/shipkit:intake` again, with the answers — it fills the blanks

- **Asked for:** the same request, non-interactive, told the file exists with three questions
  unanswered and given the three answers: "fill them in rather than redoing the research".
- **Produced:** the same file, 4,147 bytes, 39 lines. The three markers replaced by the answers; the
  "Serves goal" section rewritten; the default-if-unanswered assumption rewritten to follow the
  answer; one new assumption that the Coach moves on purpose; the follow-up list copied under Out of
  scope with its `file:line`s. The reply names the two edits beyond the answers and repeats the
  gap: MemPalace and git history not searched. One word is not so: the file says "the user
  confirmed", and the runner did.
- **Took:** 25 s wall clock; $0.13; 5 calls.
- **Awkward:** nothing of the tool's. No agent, so no wait.
- **Whose fault:** —
- **Evidence:** `diff run/04-intake.md intake.md`: lines 9, 20-22, 25, 35 only.
- **Against 4.9 §5:** the same. 25 s against 21 s, and it says what it left unchecked.

## 6. `/shipkit:spec team-day-boundary` — three drafts, checked on their own output

- **Asked for:** 4.9's words, with this run's slug: the two approval gates cannot be passed, so
  three drafts, `Spec not yet accepted`, `Status: draft`, a proposed `Paths` line, the requirements
  and decisions shown at the end, the skill's checks run on its own output.
- **Produced:** `spec.md` (3,284 B, eight EARS requirements, `Paths` of five `lib/` files and
  `test/office_bestie/`), `design.md` (4,948 B, three decision records), `tasks.md` (2,757 B, five
  tasks: T1 the bare-zone day start, T2 `Workspaces.day_start/2`, T3 the count, T4 the pulse, T5
  `/packup`). `spec-check.sh --as-open` 0 gaps, eight `PENDING-TEST`; without the flag `SKIPPED
  (draft)`; `decision-check.sh --run`: `3 decision(s), 0 fired, 1 hold, 2 manual, 0 error(s)`. The
  runner re-ran all three and they agree. The claims it rests on were read and hold:
  `valid_timezone?/1` (`accounts.ex:251`), the `Etc/UTC` default (`workspace.ex:31`), the three
  callers of the count, `accounts_test.exs:387-418`. `test/office_bestie/team_pulse_test.exs` does
  not exist; T4 would write it, and the model checked that (call 16).
- **The `Fired-if` the model wrote:** `test "$(git grep -h 'Workspaces.day_start' -- lib | wc -l)"
  -gt 8`. **It searches tracked files, as `spec/reference.md` now says** (fourth-project REQ-10).
  4.12's `grep -rl` fired on `__pycache__` bytecode (4.12 §9.1); this one cannot. It holds on the
  tree, and it is a threshold the design explains. One command in one run: it does not show the
  sentence caused it, and the record's reversal condition has not been met.
- **Took:** 100 s wall clock; $0.40; 21 turns, 20 calls.
- **Awkward:**
  1. **`design.md` gained a line the template does not have:** `> Status: draft. Not accepted: the
     design gate was not passed`. Honest, and nothing reads it, so nothing clears it: it stays after
     the stamp (§7).
  2. The second record's Case against counts "up to three" lookups per pulse and its Decision says
     the pulse calls once. The Decision is the later thought. Small.
  3. `T1`'s `Test:` line again holds a list. 4.12 and 5.0 both saw that shape.
  4. The reply repeats that MemPalace and git history were not searched. The sessions here have no
     MemPalace tool in `--allowedTools`, so it could not have.
- **Whose fault:** (1) (2) (3) small and the model's; (4) the run's.
- **Evidence:** the three files; the two `spec-check` lines and the `decision-check` summary
  re-run by the runner.
- **Against 4.9 §6:** the same or better. Eight requirements for seven, three records for two, one
  `Fired-if` command at each, 100 s against 142 s.

## 7. Accepting the spec, committing it, `brief.sh` for T1 — and the test command

- **Asked for:** the owner's approval of the *run's* draft does not exist, so, as at 4.9, the runner
  wrote the stamp by hand (`Spec accepted at commit 179f99d on shipkit/real-run-5`, `Status: open`);
  setup's, product's and the spec's files committed by name on the throwaway branch; `brief.sh .
  team-day-boundary T1`; the project's test command once before any agent touched the tree.
- **Produced:**
  - **The commit:** `50212bd`, 22 files, +543, 0.04 s; no hook; no upstream set. `git status` clean
    after it. The tracked backup needed no leaving out this time.
  - **`brief.sh`:** 88 ms, 3,082 bytes. Goal, REQ-6, 7 and 8 word for word, two files T1 may edit,
    the test and the Done-when, nothing already done, the out-of-scope lines, the report form. And
    **all three decisions of the feature** under "Decisions that bind you", with the sentence
    "These limit how you do this task. They are not extra work: build only what your requirements
    ask, and contradict none of them." The second record cites REQ-1 to REQ-5, none of them T1's:
    `brief.sh` from `v5.0.0`, run on this spec, lists two of the three and leaves that one out.
  - **The test command:** through mise, `Result: 76 passed` in 0.6 s, as at 4.9.
- **Took:** under a minute by hand.
- **Awkward:**
  1. **(project)** `CLAUDE.md:10` still says `MIX_ENV=test mix test`, and the tasks copy it. The
     Done-when as written needs the shell on the pinned toolchain; every headless step below has to
     be told the working command. Setup's section does not know about `mise`.
  2. **(tool, as 4.3 §7.4)** the stamp is still written by hand in a headless flow.
  3. **(tool)** `design.md` still says `Status: draft` beside a spec that says `open`, and no script
     looks (§6.1). Left as it was, on purpose, to see whether anything would. The gate's model did
     (§9).
- **Whose fault:** as marked.
- **Evidence:** `git log --oneline -1` → `50212bd`; `run/07-brief.md`; the `Result:` line above.
- **Against 4.9 §7:** better. No backup to step around, and the brief's decision list is whole.

## 8. Build — T1 handed to a headless agent with the brief, checked with `brief-verify.sh`

- **Asked for:** `brief.sh`'s output unchanged with 4.9's four lines after it (the working directory;
  not interactive; every `mix` through `mise exec --`; test first, watch it fail, do not commit). A
  session with `Read Glob Grep Bash Write Edit`. `git rev-parse HEAD` noted first (`50212bd`).
- **Produced:** the report in the brief's form, 1,291 bytes: `RESULT: done`, the two files, `80
  passed`, red first at `76/80` on `UndefinedFunctionError`, `NOT VERIFIED:` the full suite, not run,
  `DEVIATIONS: none`. The diff: `accounts.ex` +23/−9, a public `day_start_in_zone/2` with
  `local_day_start/2` now one line over it, as the first record chose; `accounts_test.exs` +35, four
  new tests citing `team-day-boundary/REQ-6` and `REQ-7`, four existing ones tagged `REQ-8`. Unknown
  and blank zones give UTC midnight with no log, as the third record chose. **The runner's checks:**
  the transcript holds the red run; the Done-when re-run → `Result: 80 passed`; `brief-verify: 2
  file(s) changed, all inside the Files of team-day-boundary / T1`, exit 0; `spec-check` now holds
  REQ-1 to REQ-5 as pending and no longer REQ-6, 7 or 8.
- **Took:** 39 s wall clock; $0.16; 12 turns, 11 calls.
- **The longer decision list (the plan's risk, G1):** three decisions in the brief, one of them T2's
  work. **The agent built none of it.** No `Workspaces`, no change to the count, no file past the
  two. It never opened `design.md`: 11 calls, none on that path. The brief's titles and its "They are
  not extra work" were all it read of the decisions, and here that was enough. It also means the
  reasons in the records never reached it, and on this task nothing turned on them.
- **Awkward:**
  1. `accounts_test.exs`: the new `describe` went between the two-line comment about `/packup`'s
     "today" and the block it describes, so that comment now sits over the wrong tests. A reviewer's
     catch, not a gate's. Small.
  2. The agent reads titles, not records. 5.0's built the alternative its design rejected because
     its brief said "None recorded" (5.0 §8.1). Here the title was in the brief and nothing was at
     stake on this task, so the run does not show a title is enough when a rejected alternative is
     the easy way.
- **Whose fault:** the model's, mildly; (2) nobody's yet.
- **Evidence:** `run/08-build.json`; the session's calls 9 and 11; `git log --oneline -1` → `146810f`.
- **Against 4.9 §8:** better. The same 37-to-39 s, the same clean report, and `brief-verify` read
  the first time: 4.9's fourteen false `OUTSIDE` lines had one cause, and §2.3 removed it.

## 9. `/shipkit:ship team-day-boundary` — the gate on a spec one task in

- **Asked for:** 4.9's words: non-interactive, the test command given, "do not change the spec's
  Status line".
- **Produced:** `.shipkit/releases/2026-11-01-team-day-boundary.md`, 6,760 bytes, first line `NOT
  READY`, untracked. Eight steps, every one run, each with its exit code: spec-check **FAIL** (REQ-1
  to REQ-5), tests **PASS** (`2857 passed, 12 skipped, 14 excluded` in 13.1 s, the Check's 2,853 and
  T1's four), tasks **FAIL** (T2 to T5), review **FAIL** (1 MET, 7 NOT MET), migration **PASS**,
  decisions **PASS**, clean tree **PASS**, decisions fired **PASS** (0 fired, 1 holds, 2 manual). The
  right verdict for the right reason. The report adds, unprompted, that the `HOLDS` line is
  vacuous while no `lib/` line calls `Workspaces.day_start`, and that `design.md` still says draft.
- **The reviewer, on `sonnet` (`4f81799`):** the whole reply pasted into the report, 3 calls, ended
  with a real `SubagentHandback` and no `placeholder`. Its decisions section: the first
  "followed", citing `accounts.ex:596-605`; the second `not built`, naming the three files
  unchanged; the third `not built` "for the workspace path", naming the fallback that does exist.
  Nothing is marked `contradicted`, rightly: T1's agent built none of the turned-down alternatives.
  **Every citation read:** `accounts.ex:596` and `:605`, `accounts_test.exs:388`, `:403`, `:410`,
  `:422`, `:430`, `:439`, `:448` are each the line it says.
- **Took:** 104 s wall clock; $0.27; 8 turns, 7 calls, the suite 13.1 s.
- **Awkward:**
  1. **A first-spec commit still carries setup's files as "changes beyond the spec":** `.gitignore`
     and `CLAUDE.md`. `.claude/rules/shipkit/` is off that list since 4.9 §9.4; these two are not.
  2. **`not built` asks more of a line than it has.** The third decision is half built: the fallback
     exists and nothing yet reads a workspace's zone. The reviewer said both, in words, and it is
     the right reading. The two marks have no "part".
  3. Its section lists a `followed` line the agent's template does not have. Harmless, and what a
     reader wants.
  4. The model wrote the reviewer's reply with the `Write` tool to `/tmp/shipkit-ship-review.out`,
     not `$TMPDIR`: `Write` takes a literal path. It removed it. Nothing left in either place.
- **Whose fault:** (1) the tool's, 4.9's item, half done; (2) nobody's yet; (3) nobody's; (4) the
  skill names a path a tool cannot expand. Small.
- **Evidence:** the report; `subagents/agent-acff…meta.json` (`shipkit:reviewer`, foreground); the
  subagent log's model field, `claude-sonnet-5-5`; `sed` on the cited lines; `ls` of both scratch
  places empty.
- **Against 4.9 §9:** better. The same verdict for the same reason; 4.9's wrong `accounts.ex:18-23`
  and its summarised reply are gone, and no wait leaked into the reply. 104 s against 59 s; 6,760
  bytes against 4,035, the pasted evidence.

## 10. `/shipkit:ask --walk the team pulse` — unasked in any run so far

- **Asked for:** `/shipkit:ask --walk the team pulse`, not interactive. Nothing to compare it with:
  no run had asked for a walk, before 5.0.0 or since it became `ask`'s mode.
- **Produced:** 7,647 bytes in the reply. "There is no single module called 'team pulse'": four
  triggers in a table, then nine hops down the `/team` path and the cron path, the data at each
  boundary, the side effects, the error paths, key concepts, and what it did not check. It noticed
  the open spec, and said it inferred that from file names and had not read it. The file it proposes,
  `docs/code-walkthrough/team-pulse.md`, was not written, as `walk.md:104` says: on approval.
- **Twelve citations sampled, every one the line it says:** `slash_command_controller.ex:859`,
  `team_pulse_worker.ex:34` and `:115`, `config.exs:53`, `demo.ex:44`, `manager_dashboard_live.ex:134`,
  `teams.ex:187`, `team_pulse.ex:15`, `:101` and `:190`, `digest_deliveries.ex:51`, `pulse_time?`'s
  false. `safe_fanout.ex` is given bare and lives under `workers/`.
- **It found what the spec had not.** On a zone that does not parse, `pulse_time?` returns false
  (`team_pulse_worker.ex:71-79`), so the morning post is never sent, and nothing says so. The intake's
  Out of scope says cron scheduling goes "through `Workers.LocalClock`"; this worker does not use it.
  `LocalClock` falls back to the UTC clock (`local_clock.ex:50-53`), which is the third record's
  "Matches the existing fallback in `LocalClock`". The decision stands; its Case for reads "the
  pulse never fails on a bad zone", and for the cron path that is not so. Nobody asked the walk
  to check the spec. It is the project's fact, not shipkit's, and it is why a walk before a spec
  might pay.
- **Took:** 107 s wall clock; $0.33; 3 calls, one of them the agent. `duration_ms` 19,040 and
  `num_turns` 1 describe the last turn, as 4.12 found.
- **Awkward:**
  1. **`walk.md:3` reads "The agent It cannot ask the user anything mid-run".** An edit left half
     done by `7595cb5`, in a comment in a file the skill hands to the agent whole. Harmless to the
     model, and a typo in the product.
  2. **A headless walk writes nothing.** Right for the skill, and it means the result lives in a
     reply and a yes has to come back in another session.
  3. The reply says plainly "I haven't re-checked its citations". Better than the alternative, and
     here it would have found one short path.
- **Whose fault:** (1) the tool's; (2) nobody's; (3) nobody's.
- **Evidence:** `run/10-ask.json`; the session's calls; `sed` on the cited lines.
- **The owner's settings showed here:** the reply ends "Decision for you", one numbered paragraph
  saying what it is, what was checked, the recommendation and what "yes" does, and "Reply 'yes' or
  tell me to skip". That is the owner's global `CLAUDE.md`, not the skill.
- **Against 4.9:** nothing there to set it beside.

---

## What a session here costs

`scripts/context-cost.sh`, on a scratch copy at `179f99d` for the first column, on the worktree for
the rest:

| Row | Before setup | After setup | Spec drafted | T1 built |
|---|---:|---:|---:|---:|
| `hook` | 2,396 | 197 | 330 | 441 |
| `skills-core` | 2,894 | 2,894 | 2,894 | 2,894 |
| `skills-workflows` | 1,885 | 1,885 | 1,885 | 1,885 |
| `agents` | 991 | 991 | 991 | 991 |
| `overlay-skills` | 0 | 0 | 0 | 0 |
| `overlay-appends` | 0 | 2,007 | 2,007 | 2,007 |
| `rules-always-on` | 2,999 | 2,999 | 2,999 | 2,999 |

Three overlays cost 2,007 bytes of `CLAUDE.md`. The project's own 135 lines, and its own rules and
skills, are on top. `overlay-skills` is 0 because the one skill offered was the project's already.

## Did the decisions and the debts hold?

| Line | On this run |
|---|---|
| **G1**, every live decision reaches the brief | **Held.** All three, `run/07-brief.md:24-28`, including the one citing none of T1's requirements (`:27`); `brief.sh` from `v5.0.0` lists two of them (§7) |
| G1's risk, a longer list pulling an agent into a later task | **Did not happen.** No `Workspaces`, no count, two files (§8) |
| **G2**, the reviewer reads what was turned down, and tells contradicted from not yet built | **Held as far as shown.** It read `design.md` whole (its call 1) and marked two decisions `not built`, rightly (report `:82-83`). No code took a turned-down road, so the `contradicted` half is **not shown**; `evals/reviewer/rejected-alternative/` holds that proof |
| **G3**, a contradicted decision is FAIL | **Not shown.** This `FAIL` came from the requirements. The proof is the same case and `decisions-bind/REQ-11`'s forced gate |
| **E1**, the installer names a heading the project has | **Held.** `install-stack: ./CLAUDE.md already has "## Elixir-Specific"…`, and the reply relays it (§2). The two sections remain, `CLAUDE.md:76` and `:139` |
| **E2**, the installer names same-named rules | **Held.** `install-rules: your .claude/rules/ has dependencies.md, migrations.md, testing.md beside shipkit's copies…`, relayed; none changed (§2) |
| **E3**, setup asks git before moving a backup | **Held.** `git ls-files --error-unmatch` in call 3, left in place, named in the reply, no ` D` in `git status` (§2) |
| The `placeholder` reviewer | One gate, one real `SubagentHandback`. The count from the session logs is the release's |
| W13's stack-skill lines, from `--with-skills` | **Not shown,** again: the overlay's one skill was the project's, so nothing was installed (§2). Smoke checks 72 and 73 hold them |

**The four debts of T1, on this run:**

| Debt | On this run |
|---|---|
| `django.md` only on Django (REQ-1 to 3) | **Not shown.** No Python here. Smoke check 79 |
| A stamp holds a placeholder, from `date +%F` (REQ-4, 5) | **Held.** `product.md:3`, `intake.md:3`, the report's name and its line 5, all `2026-11-01`, each model running `date +%F` first. 5.0's intake stamped 26 days back. `.shipkit-baseline/.captured` reads `2026-10-31T18:45:21Z`, the same instant in UTC, by `date -u`, and is none of the six lines. The record's move to `stamp.sh` is not called for |
| A filled section says what the project is (REQ-6 to 9) | **Held.** No `<!--` in `CLAUDE.md` but the six markers. The three sections lost four comments: the elixir section's "Phoenix / bare Elixir" and "LiveView / API-only / SPA", the choices setup had just made, and one `e.g.` hint each in the liveview and oban sections, where setup wrote the real topics and queues; nothing a reader wanted went. The `Async DB` line is Python's: not shown |
| A `Fired-if` that searches reads tracked files (REQ-10) | **Held** on the one the model wrote, `git grep` (§6) |

## What the run showed, in one place

Nine steps and the walk, eight headless sessions, **805 s of session wall clock and $2.14 of API
spend** (0.20 + 0.15 + 0.49 + 0.13 + 0.40 + 0.16 + 0.27 + 0.33), against 4.9's seven sessions, 449 s
and about $4. Without the walk this run is 698 s and $1.81; without §4's idle watch as well, 445 s.
The loop did the same work: every step produced the file it is for, nothing had to be undone, and
every check the runner re-ran agreed with the model's claim. Of the nine sections with a 4.9
counterpart, five read better, one the same or better, two the same, and §4 both: the file better,
the session worse. One run each, under settings the owner had just changed: a difference may be the
plugin, the settings or the roll.

**What the binding plan did not cost.** The brief grew by 196 bytes, the third title and the
sentence that a decision is not extra work: `brief.sh` from `v5.0.0` writes 2,886 bytes on this
spec. The agent did less with it, not more. The reviewer read more and took two Bash calls.

**What this run found, each a one-line item under the ROADMAP's "Still open after Sprint 25":**

1. A headless session waits out a `Monitor` the model armed for a background agent: four idle
   minutes and two more turns, and the reply a caller gets is the last turn, not the report (§4.1,
   §4.2). The largest thing here, and it belongs mostly to the platform.
2. The Done-when copies a test command that does not run in this project's shell, because nothing
   in `CLAUDE.md` or setup's section says `mise` (§7.1). 4.9's item, seen again.
3. A first spec still lists `.gitignore` and `CLAUDE.md` as "changes beyond the spec" (§9.1).
4. `lib/<app>/` stays literal in the elixir section (§2.2).
5. A second `## Elixir-Specific` stays, named and not merged (§2.1). The `run-debts` record chose
   that; this is the second run to see what it leaves.
6. The model wrote a `Status: draft` line in `design.md` that no template has and no script reads
   (§6.1, §7.3).
7. The reviewer's two marks have no word for half built (§9.2).
8. An agent gets a decision's title and did not open the record (§8.2). Harmless here, and not yet
   tested where a turned-down alternative is the easy way.
9. `walk.md:3`: "The agent It cannot ask" (§10.1).
10. `ship/SKILL.md` names `${TMPDIR:-/tmp}` for a file the `Write` tool has to write (§9.4). Small.
11. The `Test:` line holding a list (§6.3) and the hand-written stamp (§7.2): older items, again.

## What became of the branch

`shipkit/real-run-5` held two commits never for merge, `50212bd` (setup, product and the spec) and
`146810f` (T1, with the runner's tick in `tasks.md`), 24 files, +601/−9 against `179f99d`, plus the
gate's untracked report. The reboot of 2026-11-04 took the worktree's folder, `run/` and the report
before the owner's yes, which REQ-15 asks for. The rest waited for it: on the owner's yes the same
day, after these notes were restored and checked against the transcripts, the owner ran
`git worktree prune`, `git branch -D shipkit/real-run-5` and `dropdb office_bestie_test_shipkit5`.
`~/code/office_bestie` is on `main` at `179f99d`, one worktree, its 29 untracked entries as before
the run. T1's diff went with the branch; §8 says what it held.
