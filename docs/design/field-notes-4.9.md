# Field notes 4.9 — shipkit's loop, once more, on a Phoenix project

> Sprint 16, S16-T3 (portfolio plan E11). Written 2026-10-10 while running, from the commands
> and their output. One project, one run, one model (`sonnet` headless): anecdote, not
> measurement, in the shape of `field-notes-4.3.md` so the two read side by side. **Nothing was
> fixed in this task**; every awkwardness is a one-line item under the ROADMAP's "Still open after
> Sprint 16", pointing back here. Spec: `.shipkit/specs/portfolio-run/` (REQ-10, REQ-11).

**The repository.** `office_bestie`, the owner's Slack-first work-management product: Elixir
1.17, Phoenix 1.8.1 with LiveView 1.0, Oban, Ecto on PostgreSQL, deployed by Kamal
(`.kamal/`, `deploy/`) with a `fly.toml` beside it; 46 merged pull requests on `main`
(`179f99d`, "Merge pull request #46 … fix/confluence-sync-bounds"). It has a `CLAUDE.md` of its
own (test command `MIX_ENV=test mix test`), an `AGENTS.md`, a tracked `.claude/` with five
project rules under `.claude/rules/` (`dependencies`, `elixir-footguns`, `migrations`,
`security`, `testing`), eight project skills, three agents, a `.claude/lessons.md`, a
`.claude/settings.json`, a root `PROJECT_MAP.md`, a tracked `.shipkit-backup-20260321-082515/`
from an earlier shipkit, and **no `.shipkit/`** — so no product file, no specs, no decisions:
the loop starts from nothing, as the plan asked. The second stack E11 wanted: not Rails.

**Where it ran.** A worktree of `office_bestie` at `main` (`179f99d`) on a new branch
`shipkit/real-run-2`, created by this task and never for merge; the owner's checkout stayed on
`main` with its 29 untracked files (`docs/*_sprint.md`, archived handoffs, a file named "Is
OfficeBestie production-ready?"), untouched. Because `.claude/` is tracked here, the worktree
had the project's rules, skills and agents from the start — the gap 4.3 §0 found in a project
that ignores `.claude/` does not apply. `git status --short` before the first step: empty.

**How each skill was run.** `claude --plugin-dir "<shipkit checkout>/plugins/shipkit" --model
sonnet --allowedTools Read Glob Grep Bash Write Edit Skill Agent -p "/shipkit:<skill> … This run
is not interactive"` from the worktree, the checkout at the sprint branch (T2's commit
`5a760e5`, the 4.8.0 plugin plus Sprint 16's evals), with `office_bestie`'s `CLAUDE.md`, rules
and skills loading as they would for the owner. `~/.claude/shipkit/plugin-root` is written
back to the owner's cache path after every session (rule 17). Durations are wall-clock from
`date`. No file under `plugins/` was edited while a step ran.

Each section below answers the same six questions as the 4.3 notes: what the step asked for,
what it produced, how long it took, what was awkward, whose fault that is (the tool's or the
project's), and the evidence line.

---

## 1. Session start: what the sprint-branch hook says in `office_bestie`

- **Asked for:** nothing — the hook runs on its own. Measured by running
  `plugins/shipkit/scripts/session-start.sh` from the sprint checkout inside the worktree.
- **Produced** (173 bytes, 179 ms; the three always-on rules are injected by the other three
  hook commands, not by this script):
  ```
  shipkit: plugin root is ~/code/shipkit/plugins/shipkit
  shipkit: PROJECT_MAP.md is 58 commits behind HEAD — run /shipkit:map refresh so the elders stay accurate.
  ```
- **Took:** 179 ms.
- **Awkward:** two lines, both right: a project with no `.shipkit/` gets no spec or decision
  lines, and the stale-map line names the number. Nothing says the project has no product file
  and no spec (4.4.0's briefing is quiet on a project that never used shipkit, by design), and
  nothing mentions the `.claude/lessons.md` the always-on rule says to offer migrating — that
  offer is the rule's job inside a session, so a headless `-p` run never makes it.
- **Whose fault:** nobody's, so far.
- **Evidence:** the two lines above; `git status --short` → empty.

## 2. `/shipkit:setup` — on a project that had shipkit once, and its own rules

- **Asked for:** `/shipkit:setup`, told the run is not interactive: take the skill's defaults
  where it would ask, confirm the overlays as detected, keep any project file it would replace,
  and end with the list of files created or changed.
- **Produced:** the overlays `elixir` + `liveview` + `oban` (detected from `mix.exs`), eight
  core rules and three stack rules under `.claude/rules/shipkit/` with the manifest and version
  stamp, three sections appended to `CLAUDE.md` (135 → 210 lines), four `.gitignore` lines, a
  `.shipkit-baseline/` (`CLAUDE.md`, `.claude/`, `.captured` with `git-sha=179f99d`,
  `shipkit-version=4.8.0`) and a `.shipkit-backup-20261010-173509/` with the tracked
  `.shipkit-backup-20260321-082515/` moved inside it as `previous-backup/`. Workflow style left at
  the default, `test-first`, with no line added to `CLAUDE.md`; `.claude/settings.json` not
  written ("you already have one"); the project's own `new-feature` skill kept. The reply named
  every choice it made and why, and ended with the file list asked for.
- **Took:** 55 s.
- **Awkward:**
  1. **A second `## Elixir-Specific` section.** `CLAUDE.md` already had one (line 76, with the
     project's `MIX_ENV=test mix test`); the installer appended shipkit's generic one at line
     139 (`mix test`, `mix test.watch`), under the `<!-- shipkit:stack:elixir -->` marker. The
     reply saw the duplicate, said the project's section comes first and is more specific, and
     left both rather than edit the managed block. Two sections with one heading and two test
     commands now load into every session. The installer checks its own marker, not the
     heading it is about to add.
  2. **Three rule files with the same name on both sides.** The project keeps
     `dependencies.md`, `migrations.md` and `testing.md` in `.claude/rules/`; shipkit installs
     its own three under `.claude/rules/shipkit/`. Both sets load on the same paths. Setup does
     not look for a same-named rule outside its directory, and the reply did not mention it.
  3. **A tracked backup, moved.** The earlier `.shipkit-backup-20260321-082515/` was committed
     to git (fourteen files, among them a `.claude/settings.local.json` and three skills —
     `test`, `update-rules`, `walkthrough` — that the project no longer carries). The skill
     nests the previous backup inside the new one and removes it from the root; `git status`
     now shows fourteen deletions. The reply said so ("nothing is lost … don't stage those
     deletions if you want them left alone"). A backup made before the `.gitignore` entries
     existed is a backup git knows about, and "move it" becomes "delete it from the tree".
  4. The first line of the reply is Claude Code's own warning about a deny rule in the
     project's `.claude/settings.json` (`Bash(cat */.env:*)` "will likely never match") —
     noise from the project, printed before the skill said a word.
- **Whose fault:** (1) the tool's — `install-stack.sh` should look for the heading, or say
  "you already have an Elixir section; here is the diff"; (2) the tool's — a same-named rule
  beside the shipkit directory is worth one line in the reply; (3) both: the project's for
  tracking a backup, the tool's for moving a tracked directory without checking; (4) the
  project's.
- **Evidence:** `grep -n '^## ' CLAUDE.md` → `76:## Elixir-Specific` and `139:## Elixir-Specific`;
  `comm -12` over the two rule directories' file names → `dependencies.md migrations.md
  testing.md`; `git status --short` → ` M .gitignore`, fourteen ` D .shipkit-backup-20260321-…`,
  ` M CLAUDE.md`, `?? .claude/rules/shipkit/`; `.shipkit-baseline/.captured` quoted above.

## 3. `/shipkit:product` — no product file existed

- **Asked for:** `/shipkit:product`, told the run is not interactive, to write the best file it
  can from `README.md`, `TODO.md`, `docs/` and `CLAUDE.md`, to invent no metric, target or
  date, and to list the questions it would have asked.
- **Produced:** `.shipkit/product.md`, 3,529 bytes, 51 lines, the seven headings, and — new
  since 4.4.0 — the eight questions **written into the file** as a blockquote under the review
  line ("Open questions for the owner"), so the next session sees them. Three goals from
  `TODO.md` §1: go live with tenant isolation proven (metric, target, date "none set"),
  validate AI escalation before the Anthropic key reaches production (metric: page precision
  on a fresh blind batch; target: at least 90%, the bar `TODO.md` states; date none set), land
  the first design-partner workspaces (all none set). Five non-goals inferred from the privacy
  and competitive docs, each marked for confirmation. The sharpest questions: "Is self-hosting
  a real offer? `competitive_analysis.md` says self-hosted; the deploy is a hosted Kamal setup"
  and "Is paid billing a goal this quarter, or does the free-tier launch come first? Dodo code
  is built but switched off."
- **Took:** 38 s.
- **Awkward:** the same line 4.3 §2 wrote: two of three goals read "metric: none set; target:
  none set; by: no date set" — placeholders that are the point (the skill invents nothing) and
  still look broken to a reader who has not read the skill. What 4.3 asked for is here: the
  questions are on disk. One new thing: the second goal's metric came from the project's own
  `TODO.md` ("precision ≥ 90% on a fresh blind batch"), the one place this project had written
  a number down — the skill found it and used it, and said where it came from.
- **Whose fault:** nobody's now; the "none set" shape is the owner's to fill.
- **Evidence:** `.shipkit/product.md:5-13` (the blockquote of eight questions), `:25-27` (the
  three goal lines quoted above); `git status --short` → `?? .shipkit/` beside setup's files.

**The run paused here for the owner's request** — the intake step takes one real change the
owner names (E11).

## 4. `/shipkit:intake` — one small real change: the team's day (TODO.md §4)

- **Asked for:** `/shipkit:intake The team's "today" starts at UTC midnight (TODO.md, section
  4): the team pulse, the team's completed count and /packup's manager section all count from
  UTC midnight, while /packup's own lines use the user's local day (since 2026-10-01). Move
  them to the workspace's (or the manager's) day.` Non-interactive. The owner chose the
  request from the project's own list (`TODO.md:204-207`) when the runner proposed it.
- **Produced:** `.shipkit/specs/team-local-day/intake.md`, 3,811 bytes — **written, with its
  four questions marked *unanswered*** (the 4.4.0 fix for what 4.3 §3 asked). No conflicts:
  the five non-goals checked by line (`product.md:29-34`), no specs, no decisions, the memory
  index searched. Serves goal: none, "a correctness fix". Code research with `file:line`: the
  three surfaces each compute UTC midnight on their own (`team_pulse.ex:18`,
  `manager_briefing.ex:97`, `actions.ex:255`); `count_completed_today_for_team/2` has no user
  or workspace to take a zone from, so its callers must pass the day start; a per-user
  `Accounts.local_day_start/2` already handles DST and the unset-zone fallback; no team-level
  timezone exists, only `users.timezone` and `workspaces.timezone`; no test asserts the UTC
  boundary on these surfaces. Four questions: whose day (workspace's or the viewing manager's);
  whether the Coach's "completed today" (`coach.ex:64`) and the team standup (`standups.ex:13`),
  which share the pattern but were not named, move too — "moving the completed count changes
  the Coach whether you want it or not, because they share the function"; whether the
  scheduled `TeamPulseWorker` post uses the same day as `/team`; which goal.
- **Took:** 97 s.
- **Awkward:**
  1. **The reply opens with "The research agent is still running. I'll stop here until its
     notification arrives"** — and then does not stop: the full intake follows, with the
     agent's findings in it. A sentence written while waiting for the background agent
     survived into the final reply. Harmless, and confusing to a reader who stops at line two.
  2. Question 2 is the one that decides the size of the change, as 4.3's second question was,
     and it found a coupling the request did not know about (the Coach shares the function).
     That is the intake earning its place.
- **Whose fault:** (1) the platform's or the model's — a background-agent wait that leaks into
  the reply; the skill cannot see it; (2) nobody's.
- **Evidence:** `intake.md:18-21`, each ending `— *unanswered*`; the reply's "The intake is
  written to `.shipkit/specs/team-local-day/intake.md`"; `git status --short` → `?? .shipkit/`.

**The run paused here for the answers.** The owner was not asked: the runner answered from
the request's own wording (`TODO.md` names the workspace first) and the smallest consistent
scope, and the notes say so — the 4.3 run's §4 found its answers in the repository the same
way. The answers: (1) the workspace's day; (2) the Coach moves with its shared function, the
team standup is out of scope and noted as follow-up; (3) yes, the same day; (4) none.

## 5. `/shipkit:intake` again, with the answers — it fills the blanks

- **Asked for:** the same request, non-interactive, told the intake file exists with its four
  questions unanswered and given the four answers: "fill them in rather than redoing the
  research".
- **Produced:** the same file, 4,155 bytes: the four `*unanswered*` markers replaced by the
  answers in bold with their reasons; two assumptions rewritten (the zone is the workspace's;
  the three callers pass the workspace's day start; "where no zone is known the day stays UTC
  midnight, so the demo org on `Etc/UTC` behaves as before"); the team standup moved to Out of
  scope as a follow-up, and "the manager's own timezone for team views" added there. The
  research was not redone: `diff` shows only those lines changed.
- **Took:** 21 s.
- **Awkward:** nothing. This is the shape 4.3 §3 asked for ("the rerun would then only fill
  the blanks") — 21 s against 4.3's second intake at 52 s, which rewrote the file from scratch.
- **Whose fault:** —
- **Evidence:** `diff` of the two files: lines 18-21, 25-26 and 31-33 only; the reply's "I kept
  the earlier research and didn't redo it."

## 6. `/shipkit:spec team-local-day` — three drafts, checked on their own output

- **Asked for:** `/shipkit:spec team-local-day`, non-interactive; told the two approval gates
  cannot be passed, so: write the three files as drafts, keep `Spec not yet accepted` and
  `Status: draft`, propose a `Paths` line, show the requirements and decisions at the end, and
  run the checks the skill names on its own output.
- **Produced:** `spec.md` (2,454 B, seven EARS requirements, a `Paths` line of five `lib/`
  files and `test/office_bestie/`), `design.md` (4,020 B, two decision records, one with a
  `Fired-if` command), `tasks.md` (2,916 B, five tasks with the four sub-lines, test first:
  T1 the helper, T2 the count, T3 pulse and worker, T4 `/packup`, T5 the Coach). It read the
  intake and did not re-ask. **Both of 4.3 §6's findings are gone:** the draft was checked
  with `spec-check.sh … --as-open` (4.7.0) — no status flip, and `spec-check.sh . team-local-day`
  without the flag still says `SKIPPED (draft)`; and `decision-check.sh . --run` was run on
  the design (4.5.0): `2 decision(s), 0 fired, 1 hold, 1 manual, 0 error(s)`. The `Fired-if`
  that holds is an event (`grep -q timezone lib/office_bestie/teams/team.ex` — "reverse this
  if a team-level timezone field is added"), not a size the code will have. The reply flagged
  its own calls ("REQ-7 needs no worker change", "no `now` seam in the Coach") and offered
  the `Paths` line for confirmation.
- **Took:** 142 s.
- **Awkward:** one thing, small: the second decision's reversal condition ("if a fourth call
  to `count_completed_today_for_team` in `lib/` is found omitting `since`") is written as
  `manual` because "it is true on today's tree by construction" — the record says so itself,
  which is the honest form of a clause that cannot be a command yet.
- **Whose fault:** nobody's.
- **Evidence:** the reply's "`spec-check` reports 0 gaps (PENDING-TEST on every requirement, as
  expected before any code). `decision-check` reports 0 fired and 0 errors"; the two
  `spec-check` lines and the `decision-check` summary quoted above, re-run by the runner.

## 7. Accepting the spec, committing it, `brief.sh` for T1 — and the test command

- **Asked for:** the owner's "approve" written by hand as the stamp (`Spec accepted at commit
  179f99d on shipkit/real-run-2`, `Status: open`); setup's, product's and the spec's files
  committed on the throwaway branch; `brief.sh . team-local-day T1`; the project's test
  command run once before any agent touched the tree.
- **Produced:**
  - **The commit went through in under a second** — no pre-commit hook in this project (4.3's
    lefthook refusal has no counterpart). Staged by name: `.gitignore`, `CLAUDE.md`,
    `.claude/rules/shipkit/`, `.shipkit/product.md`, the four spec files; the fourteen
    deletions of the moved backup left unstaged, as setup's reply advised.
  - **`brief.sh`**: 48 ms, 2,095 bytes. Goal (the spec's Purpose), REQ-6 word for word, two
    files T1 may edit, the test and the Done-when, "Nothing — this task has no predecessors",
    the one binding decision by title, the five out-of-scope lines, the report-back form.
    Nothing to fault.
  - **The test command as written fails in the worktree, and would in the owner's shell.**
    `MIX_ENV=test mix test test/office_bestie/accounts_test.exs` → "Mix requires the Hex
    package manager … Could not find an SCM for dependency :phoenix": the shell's `mix` is
    Elixir 1.20.4 and `.tool-versions` pins `1.20.2-otp-29`; Hex is installed for the pinned
    one only. In the owner's own checkout `which mix` also gives 1.20.4. Through the pin —
    `mise exec -- env MIX_ENV=test mix test …` — **76 tests pass in 3 s** (the owner's `deps/`
    and `_build/` copied into the worktree first; one module recompiled). The same shape as
    4.3 §8's Ruby finding, on the other stack: `CLAUDE.md`'s command assumes the shell is
    already on the pinned toolchain.
- **Took:** about 2 minutes, of which the first failed test command was 2 s and the passing
  one 3 s.
- **Awkward:**
  1. **(project)** `CLAUDE.md:10` says `MIX_ENV=test mix test`; nothing says "through mise".
     Every headless step below that runs the suite has to be told the working command.
  2. **(tool, as 4.3 §7.4)** the stamp is still written by hand in a headless flow.
  3. **(tool, mild)** `brief-verify.sh` now allows everything under `.shipkit/` (4.5.0), so the
     4.3 §7.3 finding does not recur — checked below, after the build.
- **Whose fault:** as marked.
- **Evidence:** `git log --oneline -1` → `6adcb14 spec: team today follows the workspace day —
  setup, product file, intake and spec (shipkit real run 2, not for merge)`; the Hex error line
  quoted above; `Result: 76 passed` through `mise exec`.

## 8. Build — T1 handed to a headless agent with the brief, checked with `brief-verify.sh`

- **Asked for:** the loop's step 5: `brief.sh`'s output handed over unchanged, with four lines
  of context after it (the working directory; not interactive; run every `mix` command through
  `mise exec --`, so the Done-when is `mise exec -- env MIX_ENV=test mix test
  test/office_bestie/accounts_test.exs`; write the test first and watch it fail; do not
  commit). A `claude --plugin-dir … --model sonnet` session with `Read Glob Grep Bash Write
  Edit`, so the project's rules and shipkit's loaded as they would for anyone. `git rev-parse
  HEAD` noted first (`6adcb14`).
- **Produced:** the report in the brief's fixed form, 1,051 bytes: `RESULT: done`; `CHANGED:
  lib/office_bestie/accounts.ex, test/office_bestie/accounts_test.exs`; `TEST:` the command
  and `Result: 78 passed`, with "before the code change, the 2 new tests failed with
  `workspace_day_start/2 is undefined`" and `mix format --check-formatted` clean; `NOT
  VERIFIED:` "only the accounts test file, not the full suite; nothing calls
  `workspace_day_start/2` yet"; `DEVIATIONS: none`. The diff: `accounts.ex` +17/−2 (a public
  `workspace_day_start/2`, the midnight logic of `local_day_start/2` moved into a private
  `midnight_utc/2`, as the design's first decision says), `accounts_test.exs` +24 (a
  `describe "workspace_day_start/2"` block, each test commented `# team-local-day/REQ-6`).
  **The runner's own run of the Done-when:** `Result: 78 passed`, 1 s.
- **Took:** 37 s for the agent; the runner's checks under a minute.
- **Awkward:**
  1. **`brief-verify.sh` reported 14 files OUTSIDE — none of them the agent's.** They were
     the unstaged deletions setup's "move the old backup" left in the tree (§2.3): the check
     reads every difference from the base ref, committed or not, and cannot tell a change the
     agent made from one that was already there when the brief was handed over. The header
     says so ("every file that differs from it — committed since, or still uncommitted"); the
     consequence is that a brief must be handed over from a clean tree, and nothing says that
     at the moment of handing over. The runner restored the fourteen files (`git checkout --`),
     re-ran: `2 file(s) changed, all inside the Files of team-local-day / T1`, exit 0.
  2. The 4.3 §7.3 finding (the spec's own files reported OUTSIDE) does not recur: everything
     under `.shipkit/` is allowed since 4.5.0, and the ticked `tasks.md` was not reported.
  3. The agent did what the brief said and nothing else, and said what it had not checked.
     The report-back form earned its place: "NOT VERIFIED: nothing calls
     `workspace_day_start/2` yet" is the sentence the next task needs.
- **Whose fault:** (1) the tool's, mildly — `brief.sh` could print `git status --short` is
  not empty as a warning, or `brief-verify.sh` take a `--since` that ignores files already
  differing at hand-over; (2) and (3) nobody's.
- **Evidence:** the report's five lines quoted above; `brief-verify: 16 file(s) changed, 14
  outside …` then `brief-verify: 2 file(s) changed, all inside the Files of team-local-day /
  T1`; `git log --oneline -1` → `61dc902 feat(accounts): workspace_day_start/2 — midnight on
  the workspace's clock, UTC fallback (team-local-day T1; shipkit real run 2, not for merge)`.

## 9. `/shipkit:ship team-local-day` — the gate on a spec one task in

- **Asked for:** `/shipkit:ship team-local-day`, non-interactive, the test command given as
  the one that works here (`mise exec -- env MIX_ENV=test mix test`, §7), "do not change the
  spec's Status line".
- **Produced:** `.shipkit/releases/2026-10-10-team-local-day.md`, 4,035 bytes, first line
  `NOT READY`. Eight steps, every one run, **every exit code captured** (4.3 §8.2's "not
  captured because of a pipe" does not recur): spec-check as shipped **FAIL** (six
  requirements without a test); tests **PASS** — `2855 passed, 12 skipped, 14 excluded` in
  13.4 s; tasks ticked **FAIL** (T2 to T5 listed); independent review **FAIL** (REQ-6 MET,
  six NOT MET, `VERDICT: FAIL`); migration rollback **PASS**; decisions **PASS**; clean tree
  **PASS**; decisions fired **PASS** (one HOLDS, one MANUAL). "To fix": build T2 to T5 with
  their tests, tick them, re-run. The reviewer also listed "changes beyond the spec:
  `.claude/rules/shipkit/*`, `.gitignore`, `CLAUDE.md` (shipkit setup files)". **The gate
  removed its own scratch files** (4.7.0, S14-T2): nothing under `$TMPDIR/shipkit-ship-*`.
- **Took:** 59 s, of which the suite was 13.4 s.
- **Awkward:**
  1. **The reviewer's one MET citation is wrong.** "REQ-6 MET: `lib/office_bestie/accounts.ex:
     18-23`; tests `accounts_test.exs:42` and `:51`." Lines 18-23 of `accounts.ex` are
     `get_session_user/1`; `workspace_day_start/2` is at line 605, and the new tests start at
     line 421. The numbers look like positions inside the `git diff` output, not in the files.
     The verdict is right and the one line a reader would click is not — the thing the ask
     skill's caveat warns about ("no independent validator checking that a citation supports
     the claim"), now seen in the gate's own evidence.
  2. **The reviewer's reply is summarised again**, not pasted: "Reviewer's reply (summarised
     table; full verdict line unchanged)" — the recurrence the 4.8.0 release named for the plan
     after (`gate-blind-spots` REQ-9 asks for the reply pasted). A summary is where (1) hides.
  3. **The reply opens with "Still waiting on the reviewer agent; I'll write the report once its
     verdict arrives"** and then gives the report — the same leaked wait as the intake (§4.1),
     twice in one run.
  4. **Setup's files are "changes beyond the spec".** `.claude/rules/shipkit/`, `.gitignore`
     and `CLAUDE.md` are written by `/shipkit:setup` before any spec exists, as `product.md`
     was in 4.3 §8.3; `product.md` is allowed since 4.5.0, setup's files are not, so every
     first spec on a freshly set-up project will carry this line.
  5. The gate ran 2,855 tests to learn that nothing covers four unchanged files. Right, and
     13 s — the price was lower here than 4.3's two minutes.
- **Whose fault:** (1) the reviewer agent's (model behaviour; the gate could re-check the one
  MET line with `sed -n`); (2) the ship skill's, as already named; (3) the platform's or the
  model's; (4) the tool's — setup's files belong on the always-allowed list beside
  `product.md`; (5) nobody's.
- **Evidence:** the report's first line `NOT READY` and its table; "`mise exec -- env
  MIX_ENV=test mix test` → exit 0 … Result: 2855 passed, 12 skipped, 14 excluded"; the
  reviewer's `VERDICT: FAIL`; `sed -n '18,23p' lib/office_bestie/accounts.ex` → `def
  get_session_user(user_id)…`; `grep -n 'def workspace_day_start'` → `605`; `git status
  --short` → `?? .shipkit/releases/`; `ls $TMPDIR/shipkit-ship-*` → no matches.

---

## What the run showed, in one place

Nine steps, about 12 minutes of model time, eight headless sessions (setup 55 s, product 38 s,
intake 97 s and 21 s, spec 142 s, build 37 s, gate 59 s) and roughly $4 of API spend. The loop
held on the second stack as it did on the first: every step produced the file it is for, and
nothing had to be undone.

**What 4.3 asked for and is now there.** The product's questions are in the file (§3); an
unanswered intake writes itself and the rerun only fills the blanks, 21 s against 52 s (§4,
§5); the spec is checked as a draft with `--as-open` and `decision-check` runs on the design
before anyone approves it (§6); `brief-verify` allows the spec's folder (§8); the gate captures
exit codes and removes its scratch files (§9). Six of 4.3's eleven awkwardnesses, closed by
the three releases and seen closed here.

**What this run found, each a one-line item under the ROADMAP's "Still open after Sprint 16":**

1. `install-stack.sh` appends a stack section under a heading the project already has (§2.1).
2. Setup does not notice a same-named rule in `.claude/rules/` beside its own directory (§2.2).
3. Setup moves a previous backup that git tracks, so `git status` shows deletions (§2.3).
4. A background-agent wait sentence leaks into the final reply, in the intake and the gate
   (§4.1, §9.3).
5. `brief-verify.sh` counts changes that were already in the tree at hand-over; nothing says
   "hand over from a clean tree" (§8.1).
6. The reviewer's MET citation named diff positions, not file lines (§9.1); the gate still
   summarises the reviewer's reply (§9.2).
7. Setup's own files are "changes beyond the spec" on every first spec (§9.4).
8. The project's: `CLAUDE.md`'s test command assumes the pinned toolchain is on `PATH` (§7);
   a tracked backup directory (§2.3); a `settings.json` deny rule that never matches (§2.4).

**The branch.** `shipkit/real-run-2` holds two commits (`6adcb14` the setup, product, intake
and spec files; `61dc902` T1) and one untracked report; never for merge. Its fate is recorded
below once the owner decides (F3).
