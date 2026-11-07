# Field notes 5.2 — the owner's project again, after the machine plan's two sprints

> Sprint 28 (machine plan G10, G11). Written 2026-11-06 while running, from the commands and their
> output. §0 is S28-T1, an install question answered before the run; the run itself (S28-T2)
> follows in the shape of `field-notes-5.1.md`, section for section. **Nothing was fixed in this
> sprint**; every finding is an item under the ROADMAP's "Still open after Sprint 28", pointing
> back here. Spec: `.shipkit/specs/fifth-run/` (REQ-1 to REQ-11).

---

## 0. `--scope project`: which update moves it (S28-T1, G11)

`fifth-run/REQ-1` to `REQ-3`. PR #30's question: an install made with `--scope project`, updated
with `claude plugin update … --scope project` from outside its project and from inside it — which
works? Claude Code 2.1.318, 2026-11-06. No model call.

**How.** Every command ran with `CLAUDE_CONFIG_DIR` set to a scratch folder
(`$TMPDIR/s28c/config`), standard input from `/dev/null`, from one of four scratch folders: three
git repositories (`proj`, `proj2`, `proj3`) and `outside`, which is none of them. The marketplace
was this repository on GitHub, pinned by its tags: `claude plugin marketplace add
'AnjanJ/shipkit#v5.0.0'`, where both plugins read 5.0.0. Moving it to 5.1.0 meant changing
`"ref": "v5.0.0"` to `"v5.1.0"` in the scratch config's `settings.json` and
`plugins/known_marketplaces.json`, then `claude plugin marketplace update shipkit`. Editing those
files by hand is not documented; that it took is shown by the clone's `HEAD` (`73ce5d5`, `v5.1.0`)
and its three `"version": "5.1.0"` lines. Each command's output, exit status and the owner's two
checksums after it were logged to `$TMPDIR/s28c/log/`.

**Two methods that could not answer it,** each tried first under its own scratch config and set
aside (`fifth-run/design.md`, first record, amended):

- A marketplace added by local path (`$TMPDIR/s28`). Install exits 0, and `claude plugin list`
  reads `Read from: …/market/plugins/shipkit`: the plugin loads in place, so a version bump in the
  copy changes the install with no update. The plugin loading reference says so: relative-path
  plugins in a marketplace "you added from a local path" load in place, "whatever its version
  string says" (`code.claude.com/docs/en/plugins/loading.md`, "In-place and copied plugins",
  "Versions and updates").
- A local git repository by `file://` URL (`$TMPDIR/s28b`). `claude plugin marketplace add
  file://…/market` exits 1: "Invalid marketplace source format. Try: owner/repo, https://..., or
  ./path". The install page lists `owner/repo`, an `https://` clone URL and `git@host:path` as the
  git forms (`code.claude.com/docs/en/plugins/install.md`, "Add a marketplace").

**What each command did.** Versions are the ones `installed_plugins.json` in the scratch config
records after the command; it records one entry per plugin per project, with its `projectPath`.

| # | Where | Command | Exit | Output (the line that matters) | After it |
|---:|---|---|---:|---|---|
| 1 | `proj` | `claude plugin install shipkit@shipkit --scope project -y`, and `shipkit-workflows@shipkit` | 0, 0 | `Successfully installed plugin: shipkit@shipkit (scope: project)` | `proj` 5.0.0, copied to `cache/shipkit/<plugin>/5.0.0/`; `proj/.claude/settings.json` enables both |
| 2 | `outside` | `claude plugin list` | 0 | both rows `Version: 5.0.0`, `Scope: project`, `Status: ✘ disabled` | — |
| 3 | `outside` | pin to `v5.1.0`; `claude plugin marketplace update shipkit` | 0 | `Successfully updated marketplace: shipkit` | the catalogue offers 5.1.0; `proj` still 5.0.0 |
| 4 | `outside` | `claude plugin update shipkit@shipkit --scope project -y`, and `shipkit-workflows@shipkit` | 0, 0 | `Plugin "shipkit" updated from 5.0.0 to 5.1.0 for scope project (/private/var/…/s28c/proj)` | `proj` 5.1.0 |
| 5 | `proj2`, `proj3` | pin back to `v5.0.0`, marketplace update; install both in each, `--scope project -y`; pin to `v5.1.0`, marketplace update | 0 each | `Successfully installed plugin: … (scope: project)` | `proj` 5.1.0, `proj2` 5.0.0, `proj3` 5.0.0; catalogue 5.1.0 |
| 6 | `proj2` | `claude plugin update <plugin>@shipkit --scope project -y`, both | 0, 0 | `updated from 5.0.0 to 5.1.0 for scope project (/private/var/…/s28c/proj2)` | `proj2` 5.1.0; **`proj3` still 5.0.0** |
| 7 | `outside` | the same two updates | 0, 0 | **`shipkit is already at the latest version (5.1.0).`** | **`proj3` still 5.0.0** |
| 8 | `proj3` | `claude plugin list` | 0 | six rows, two per project, none naming its project: four `5.1.0`, two `5.0.0`, all `✔ enabled` | — |
| 9 | `proj3` | the same two updates | 0, 0 | `updated from 5.0.0 to 5.1.0 for scope project (/private/var/…/s28c/proj3)` | all three 5.1.0 |

**The owner's files.** `shasum -a 256` of `~/.claude/plugins/installed_plugins.json`
(`b1b8f590…bb604`) and `known_marketplaces.json` (`31b7f56f…342a4`), taken before the first
command and after every one of the three folders' commands: unchanged throughout (`REQ-3`).
`~/.claude/settings.json` was last written 2026-11-05 18:00, before T1 began.

**The answer.**

1. **From inside the project, `--scope project` moves that project's install and only that one**
   (rows 6, 9). This always worked.
2. **From outside, it moves an install only when it happens to pick the right one.** With one
   project-scope install it moved it and named the project (row 4). With three, it read the first
   recorded one (`proj`, current), said "already at the latest version" and exited 0, while
   `proj3` stayed on 5.0.0 (row 7). A user reading that line would think the update had worked.
3. **`claude plugin list` cannot tell a reader which project is behind** (row 8): it lists every
   project's install, with no path, and from `outside` marks each row `disabled` (row 2).

So the README's and the guide's rule for `Scope: local`, "the same two lines with that scope, from
inside that project", is the one that works for `Scope: project` too, and both now say so, with
what goes wrong from outside. Not tried here: whether `--scope local` from outside has the same
first-install shape; the 5.1.0 release saw local installs move only from inside
(`CHANGELOG.md`, `[Unreleased]`, Docs).

**Left in place, for the owner's yes:** `$TMPDIR/s28`, `$TMPDIR/s28b`, `$TMPDIR/s28c` (configs,
marketplace copies, scratch projects, logs).

---

## The run (S28-T2)

**The repository.** `~/code/office_bestie` at `179f99d`, the commit the 4.9 and 5.1 runs started
from; its `main` has not moved. The request is the same as 5.1's, `TODO.md:204`, the team's
"today" (`fifth-run/design.md`, sixth record). Its main checkout held 29 untracked entries before
the run, as after 5.1's.

**Where it ran.** A worktree at `/private/tmp/shipkit-real-run-6` on a new branch
`shipkit/real-run-6`, never for merge and never pushed, with its own database
`office_bestie_test_shipkit6` through `MIX_TEST_PARTITION=_shipkit6`. `git status --short` before
the first step: empty. Each step's prompt and output are copied to `~/.cache/shipkit-real-run-6/run/`
as it ends (the `run/` the sections below cite), and its section here is written before the next
step starts (`fifth-run/REQ-7`).

**The Check, free and first** (`fifth-run/REQ-4`; `run/00-check.log`), at 2026-11-05T21:21Z
(02:51 on 2026-11-06 in the owner's zone, IST): `mise exec -- mix deps.get` exit 0;
`MIX_ENV=test mise exec -- mix compile` exit 0 (236 files);
`MIX_ENV=test MIX_TEST_PARTITION=_shipkit6 mise exec -- mix test` → **2853 passed, 12 skipped, 14
excluded** in 10.5 s, exit 0: 5.1's count. The suite's log carries a test's `PAID GRANT` warning
telling a reader to record a date in `TODO.md`; nothing in the run acted on it. `mise` 2026.11.1.

**How each step is run.** As 5.1, but for two things this plan changed. Headless steps:
`claude --plugin-dir "<shipkit checkout>/plugins/shipkit" --model sonnet --allowedTools Read Glob
Grep Bash Write Edit Skill Agent --output-format json -p "/shipkit:<skill> … This run is not
interactive"` from the worktree, standard input from `/dev/null`, `MIX_TEST_PARTITION=_shipkit6`
exported. **No word of the runner's names `mise` or a test command** (`fifth-run/REQ-6`, G4).
**Setup is the owner's**, in a session of their own, read from its transcript afterwards (G6;
`fifth-run/design.md`, third record). The checkout is the sprint branch, `d6e6a00`: 5.1.0 plus
Sprints 26 and 27; `git log f138e94..d6e6a00 -- plugins/` is empty. Claude Code 2.1.318.

## 1. Session start: what the hook says in `office_bestie`

- **Asked for:** nothing — the hook runs on its own, measured as 5.1 measured it:
  `plugins/shipkit/scripts/session-start.sh` from the checkout inside the worktree, with
  `CLAUDE_PLUGIN_ROOT` set to the checkout's plugin.
- **Produced:** 362 bytes, four lines: the root, `version 5.1.0`, the opt-in line ("run
  /shipkit:product or /shipkit:setup to turn on spec-driven work here …"), and the stale map ("58
  commits behind HEAD"). `scripts/context-cost.sh` on the worktree: `hook` 2,396, `skills-core`
  2,894, `skills-workflows` 1,885, `agents` 991, `overlay-skills` 0, `overlay-appends` 0,
  `rules-always-on` 2,999.
- **Took:** 0.15 to 0.16 s, three runs (`/usr/bin/time -p`).
- **Awkward:** the version line reads 5.1.0 on a checkout that holds two sprints more: the version
  moves at the release, so a `--plugin-dir` session cannot tell 5.1.0 from this branch. Known, and
  the same at every run.
- **Whose fault:** nobody's.
- **Evidence:** `run/01-hook.out`, `run/01-context-cost.tsv`; `git status --short` empty after it.
- **Against 5.1 §1:** the same, byte for byte: 362 bytes and every `context-cost` row equal.

## 2. `/shipkit:setup` — headless, on the owner's word

- **Asked for:** 5.1's words, word for word: not interactive, the skill's defaults, the overlays as
  detected, keep any project file, yes to `--with-skills`, end with the file list. The plan had the
  owner run setup and read it (G6, G10); before it ran, the owner said "you do all these steps",
  so it ran headless like the rest (`fifth-run/REQ-5` and `design.md`'s third record, amended).
- **Produced:** the overlays `elixir` + `liveview` + `oban`, detected; eight core rules and three
  stack rules under `.claude/rules/shipkit/`; `CLAUDE.md` 135 → 201 lines, 9,039 bytes (8,964 at
  5.1); four `.gitignore` lines after a blank one; `.shipkit-baseline/`; a new
  `.shipkit-backup-20261106-030912/`, git-ignored; the tracked `.shipkit-backup-20260321-082515/`
  left where it was. `new-feature` was the project's, so `--with-skills` installed nothing. **The
  record G2 reads:** `.claude/rules/shipkit/.setup-files` holds `CLAUDE.md fcce4ad…` and
  `.gitignore d74dc15…`, each the blob id `git hash-object` prints for the file as setup left it.
  The reply names every default and ends with the file list; it does not name `.setup-files`.
- **The test command (G4):** the reply says "`.tool-versions` is present and `mise` is on the
  PATH, so I wrote the test command as `MIX_ENV=test mise exec -- mix test`", and shipkit's
  sections hold it: `CLAUDE.md:159` (run all), `:160` (run one), `:183` (the LiveView tests). Call 6
  passed `TEST_COMMAND="MIX_ENV=test mise exec -- mix test"` to the installer. **The project's own
  lines did not change:** `CLAUDE.md:10` (`**Test command:** MIX_ENV=test mix test`) and `:109-111`
  under the project's own `### Testing`. The file now names two test commands, one of which does
  not run in a headless shell. Which one the spec copies is §6's to read.
- **Took:** 55 s wall clock; $0.20; 7 turns, 6 calls.
- **Awkward:**
  1. **Two test commands in one `CLAUDE.md`.** Setup keeps the project's file and appends; the
     prefix reaches only shipkit's lines. `users-machine/design.md`'s second record turned on this:
     "We would take (2) if a real run's `CLAUDE.md` names two different test commands again, from
     any stack." It does here, though the second command is the project's, not a stack's.
  2. **The second `## Elixir-Specific` is still there** (`CLAUDE.md:76` and `:139`), named by the
     installer and relayed ("`/shipkit:setup rules` can merge the two"). No person read it in
     setup's session; the line is quoted to the owner in the thread.
  3. **`grep` in the session's shell is ripgrep again.** Call 2's search printed
     `".shipkit-baseline": No such file or directory (os error 2)`, ripgrep's form; call 3 ran
     `/usr/bin/grep`. One call. The shell, not the plugin.
- **Whose fault:** (1) the tool's: setup does not touch the project's own lines, by design, and
  nothing says the two now differ; (2) the tool's, knowingly (`run-debts`' first record); (3)
  nobody's.
- **G1, G2, G4, G6:** G1 (`APP_NAME`) **held**: `CLAUDE.md:149` and `:152` read
  `lib/office_bestie/`, and no `<app>` is left (`grep -c '<app>' CLAUDE.md` → 0). G4 **held in
  shipkit's sections**, with awkward (1). G2's record written; the gate reads it (§9). G6 **not
  shown**: no person read the line in setup's own session.
- **Evidence:** `run/02-setup.json`, `run/02-setup.jsonl` (the transcript, session `02f2d32a`),
  `run/02-setup.status` → ` M .gitignore`, ` M CLAUDE.md`, `?? .claude/rules/shipkit/`, no ` D`.
- **Against 5.1 §2:** better. 5.1's (2), `lib/<app>/`, is gone; the test command is in shipkit's
  section with the prefix, where 5.1's had none. The same two sections, the same ripgrep turn.

## 3. `/shipkit:product` — no product file existed

- **Asked for:** 5.1's words, word for word.
- **Produced:** `.shipkit/product.md`, 3,147 bytes, 50 lines, the seven headings, seven questions
  as the blockquote. Three goals from `TODO.md`, none with a date; two "none set", the third with
  the project's own 90% precision bar. Four non-goals (no issue tracking, no async standups, no
  surveillance, no manager view of an engineer's unshared data), each word found in the sources
  (`git grep -l -i` over `README.md`, `TODO.md`, `CLAUDE.md`, `docs/`: `docs/go_to_market.md`,
  `docs/competitive_analysis.md`, `README.md`); the pitch deck's "4.2 hrs/week" and "72%" are in
  `docs/pitch/officebestie-pitch-deck.md` and asked about, not adopted. The review line reads
  `2026-11-06`, from a `date +%F` in the session's first call: the owner's date (IST), where UTC
  was still 2026-11-05.
- **Took:** 32 s wall clock; $0.14; 7 turns.
- **Awkward:** the same "metric: none set" shape as 4.3, 4.9 and 5.1, made acceptable by the
  questions on disk. One question fewer than 5.1's eight. The reply adds that the map is 58
  commits behind and was not refreshed: the hook's line, relayed.
- **Whose fault:** nobody's.
- **Evidence:** `run/03-product.json`, `run/03-product.md`, `run/03-product.jsonl`.
- **Against 5.1 §3:** the same. 32 s against 35 s, $0.14 against $0.15.

## 4. `/shipkit:intake` — the team's day (TODO.md §4)

- **Asked for:** 5.1's words, word for word. Non-interactive.
- **Produced:** `.shipkit/specs/team-day-boundary/intake.md` (the same slug as 5.1's), 4,001 bytes,
  36 lines, three questions marked *unanswered*: whose day for each surface; whether the other
  UTC-midnight places move too; which goal (it wrote "None"). No conflicts, each kind checked and
  named (no open specs, no decisions, no `design.md`). The research went to `grandfather`, in the
  background. Citations sampled: `team_pulse.ex:18`, `actions.ex:246-258` (`today_start/0` at
  `:255-257`), `manager_briefing.ex:97` each the line it says; `summary.ex:16` is the
  `today_start =` whose call is on `:17`. The stamp reads `2026-11-06`.
- **Took:** 102 s wall clock; $0.38; 6 calls. **The wait (G7):** `wait-probe.sh --read` on the
  transcript → **8 idle seconds, 0 `Monitor`, 1 `sleep`, a background agent.** The agent ran from
  21:41:37 to 21:42:45 UTC (68 s); `intake.md` was written at 21:43:00 and the session ended at
  21:43:08. The one `sleep` was `sleep 1; ls .shipkit/specs .shipkit/decisions`, while the agent
  ran. No watch was armed.
- **Awkward:** while `grandfather` ran, the model made one call of its own, the `ls` above (nine at
  5.1, `intake/SKILL.md:34`). Nothing else.
- **Whose fault:** —
- **Evidence:** `run/04-intake.json`, `run/04-intake.md`, `run/04-intake.jsonl`,
  `run/agent-a425600b3ca66907b.meta.json` (`shipkit:grandfather`, `"requestShape":"background"`).
- **Against 5.1 §4:** better. 102 s against 343 s, with the same background agent and the same
  three-question file; the four-minute watch is gone, and the reply is the report, not "the second
  wait timing out". Read beside `eval-results-5.2.md` §1's five runs (6 to 24 s), the 5.1 wait
  has not come back.

## 5. `/shipkit:intake` again, with the answers — it fills the blanks

- **Asked for:** the same request, non-interactive, the file named with its three questions
  unanswered, and 5.1's three answers, put in this intake's order (its Q2 is 5.1's Q3, its Q3 5.1's
  Q2): the workspace's day for all three, the Coach moving with the shared function (it calls
  `count_completed_today_for_team/2`, `intake.md:26`); only the three named; none, a correctness
  fix. "Fill them in rather than redoing the research."
- **Produced:** the same file, 4,903 bytes, 41 lines; no "unanswered" left. `diff` against the
  first: lines 9, 19-21, 23, 36 only — the goal line, the three answers, one assumption added (one
  shared workspace-day start), one out-of-scope line added (a per-manager day boundary).
- **Took:** 23 s wall clock; $0.11; 7 turns. No agent, so no wait.
- **Awkward:** the reply opens "I filled in the three answers … and made no other changes", then
  lists "three edits to keep the file consistent". The edits are right; the first sentence is not.
- **Whose fault:** the model's. Small.
- **Evidence:** `diff run/04-intake.md run/05-intake.md`; `run/05-intake-answers.json`.
- **Against 5.1 §5:** the same. 23 s against 25 s, the same shape of edits beyond the answers.

## 6. `/shipkit:spec team-day-boundary` — three drafts, checked on their own output

- **Asked for:** 5.1's words, word for word.
- **Produced:** `spec.md` (3,125 B, seven EARS requirements, `Paths` of five `lib/` files and
  `test/office_bestie/`), `design.md` (5,198 B, three decision records), `tasks.md` (2,968 B, six
  tasks: T1 `Accounts.workspace_day_start/2`, T2 a `since` argument for the count, T3 to T5 the
  pulse, `/packup` and the Coach, T6 the temporary default removed). `spec-check --as-open` 0
  gaps, seven `PENDING-TEST`; without the flag the draft is skipped; `decision-check --run`: `3
  decision(s), 0 fired, 2 hold, 1 manual, 0 error(s)`. The runner re-ran all three and they agree.
- **The test command (G4): not carried.** `tasks.md:3` says "Run with `MIX_ENV=test mix test`",
  and every Done-when copies it, `:9` to `:34`. That is the project's own line,
  `CLAUDE.md:10`, not shipkit's `CLAUDE.md:159`. The prefix setup wrote reaches no task.
- **The `Fired-if` lines:** two commands, both `git grep` over tracked files (`design.md:33`,
  `:58`), and one `manual`. Both hold on the tree.
- **No `Status:` line in `design.md` or `tasks.md`** (G1's fourth debt): the model wrote none this
  time, so `STRAY-STATUS` had nothing to catch. Not shown; smoke check 87 holds it.
- **Took:** 133 s wall clock; $0.41; 19 turns.
- **Awkward:**
  1. **The Done-when copies the line that does not carry the prefix** (above). The next steps
     read it.
  2. REQ-2 and half of REQ-3 move the check-ins, PRs and deploys windows too, past the intake's
     "completed count". The reply says so and asks; the code builds one `today_start` for all of
     them, so it is a reading, not a drift.
  3. The reply says the `Paths` line "is unconfirmed even though it looks final": honest, and the
     skill has no draft form for it.
- **Whose fault:** (1) the tool's: two test commands in `CLAUDE.md` (§2.1) and nothing says which
  one a task copies; (2) nobody's; (3) the tool's, small.
- **Evidence:** `run/06-spec.md`, `run/06-design.md`, `run/06-tasks.md`, `run/06-spec.json`; the
  two `spec-check` lines and the `decision-check` summary re-run by the runner.
- **Against 5.1 §6:** the same, with one line worse to read: 5.1's tasks copied
  `MIX_ENV=test mix test` too, when no other command existed; here a working one sat in the same
  file. Seven requirements for eight, six tasks for five, 133 s against 100 s.

## 7. Accepting the spec, committing it, `brief.sh` for T1 — and the test command

- **Asked for:** as 5.1: the runner wrote the stamp by hand (`Spec accepted at commit 179f99d on
  shipkit/real-run-6`, `Status: open`); setup's, product's and the spec's files committed by name
  on the throwaway branch; `brief.sh . team-day-boundary T1`; the test command once by hand before
  any agent touched the tree — this time both of the commands `CLAUDE.md` names.
- **Produced:**
  - **The commit:** `8f2dbb4`, 23 files, +592, 0.05 s; no hook; no upstream set. `git status`
    clean after it.
  - **`brief.sh`:** 0.05 s, 2,869 bytes. Goal, REQ-5 and REQ-6 word for word, two files T1 may edit,
    the test and the Done-when as `tasks.md:9` has it — `MIX_ENV=test mix test …` — nothing already
    done, the three decisions' titles under "Decisions that bind you" with "They are not extra
    work", the out-of-scope lines, the report form.
  - **The test command, both ways** (`run/07-test-command.log`), on the existing
    `accounts_test.exs`: the project's line, `MIX_ENV=test mix test`, runs the machine's global
    Elixir 1.20.5 (`elixir --version`) and **exits 1** in 1 s: "Mix requires the Hex package
    manager … Could not find an SCM for dependency :phoenix". Setup's line,
    `MIX_ENV=test mise exec -- mix test`, runs the pinned 1.20.2: **`Result: 76 passed`**, exit 0.
- **Took:** under a minute by hand.
- **Awkward:**
  1. **(tool)** the brief hands the agent the command that fails here (§6.1). Setup wrote the
     working one; the spec skill copied the other. The plan's §0 row, "a test command setup writes
     that runs in a headless shell on a pinned toolchain", is true of the line setup wrote and of
     no line a task reads.
  2. **(tool, as 4.3 §7.4)** the stamp is still written by hand in a headless flow.
- **Whose fault:** as marked.
- **Evidence:** `git log --oneline -1` → `8f2dbb4`; `run/07-brief.md`; `run/07-test-command.log`.
- **Against 5.1 §7:** the same and worse in one line. 5.1's Done-when did not run either and
  nothing in the file did; here the file holds the command that runs, and the brief carries the one
  that does not.

## 8. Build — T1 handed to a headless agent with the brief, checked with `brief-verify.sh`

- **Asked for:** `brief.sh`'s output unchanged with three of 5.1's four lines after it (the working
  directory; not interactive; test first, watch it fail, do not commit). **5.1's fourth line, "Run
  every `mix` command through `mise exec --`", is gone** (`fifth-run/REQ-6`). A session with
  `Read Glob Grep Bash Write Edit`. `git rev-parse HEAD` noted first (`8f2dbb4`).
- **Produced:** the report in the brief's form: `RESULT: done`, the two files, `4 passed` and
  `76 passed`, red first at 0 of 4 on an undefined function, `NOT VERIFIED:` the full suite and the
  callers. Its `DEVIATIONS` opens: **"I ran the tests through `mise exec --`, because plain
  `MIX_ENV=test mix test` failed with a Hex/SCM error in this shell."** The transcript shows it:
  call 8 ran the brief's Done-when and got 5.1's failure; call 9 ran it with the prefix, red, 4
  failed. The diff: `accounts.ex` +20/−1, a public `workspace_day_start/2` and a private
  `day_start_in/2` that `local_day_start/2` now calls, as the first record chose; a new test file of
  four tests, three citing `team-day-boundary/REQ-5` or `REQ-6`, one (Kolkata) citing none, as the
  report says. **The runner's checks** (`run/08-runner-checks.log`): the Done-when with the prefix →
  `Result: 80 passed`; `brief-verify: 2 file(s) changed, all inside the Files of team-day-boundary
  / T1`, exit 0; `spec-check` no longer lists REQ-5 or REQ-6 as pending. Committed by the runner
  with T1's tick: `ee9b06b`.
- **Took:** 40 s wall clock; $0.17; 12 turns, 11 calls.
- **The decisions:** the agent **opened `design.md`** (call 2), which 5.1's agent did not (5.1 §8.2),
  and built none of T2's to T6's work: no `since` argument, no caller changed.
- **Awkward:**
  1. **The agent found the prefix, the brief did not give it.** One failed call and a sentence in
     `DEVIATIONS`. Where `.tool-versions` is less plain, or the model less curious, the same brief
     reads as `blocked`, or the agent installs Hex with `mix local.hex --force`, as the error tells
     it to.
  2. Two tests beyond the brief, one with no requirement cited. Said so in the report.
- **Whose fault:** (1) the tool's (§6.1, §7.1); (2) the model's, and declared.
- **Evidence:** `run/08-build.json`, `run/08-build.jsonl`, `run/08-runner-checks.log`;
  `git log --oneline -1` → `ee9b06b`.
- **Against 5.1 §8:** the same, for a different reason. 40 s against 39 s, the same clean report.
  5.1's agent was handed the prefix; this one found it after a failure the brief walked it into.

## 9. `/shipkit:ship team-day-boundary` — day one, the report left untracked

- **Asked for:** 5.1's words **without its test command** (`fifth-run/REQ-6`): non-interactive,
  "do not change the spec's Status line". The report is left untracked for day two (REQ-8).
- **Produced:** `.shipkit/releases/2026-11-06-team-day-boundary.md`, 6,907 bytes, first line `NOT
  READY`, untracked, checked at `ee9b06b` against `179f99d`. Eight steps, each with its exit code:
  spec-check **FAIL** (REQ-1 to REQ-4, REQ-7), tests **PASS**, tasks **FAIL** (T2 to T6), review
  **FAIL** (0 of 7 MET), migration **PASS**, decisions **PASS**, clean tree **PASS**, decisions
  fired **PASS** (0 fired, 2 hold, 1 manual). The right verdict for the right reason.
- **The test step (G4):** the gate took the command from `CLAUDE.md`, as the skill says, and took
  the project's line first: `( MIX_ENV=test mix test )` → exit 1, the Hex error; then
  `MIX_ENV=test mise exec -- mix test`, "the one `CLAUDE.md` lists under Elixir-Specific Testing"
  (report `:47`) → `2857 passed, 12 skipped, 14 excluded`, the Check's 2,853 and T1's four. Both
  are in the report.
- **The reviewer:** `shipkit:reviewer` on `claude-sonnet-5-5`, in the background, 3 calls, a real
  `SubagentHandback` (no `placeholder`). REQ-5 and REQ-6 are NOT MET although T1's tests cite them:
  "REQ-5 and REQ-6 are written about the three surfaces, and none of the three calls the new
  function" (report `:68`). Strict, and what the requirements say ("the day shall start…" for a
  team's surfaces). **Every citation read:** `accounts.ex:606`, `actions.ex:246`,
  `team_pulse.ex:87`, `manager_briefing.ex:110`, `coach.ex:64`, the test file's `:11`, `:19`,
  `:28` are each the line they say; `accounts.ex:615`, given for `day_start_in/2`, is the comment
  above it.
- **G2, setup's two files:** **held.** "Changes beyond the spec: None. (`CLAUDE.md` and
  `.gitignore` match the blob ids in `.setup-files` …)" (report `:81`). The first real gate not
  to list them, after three runs in a row did (4.12, 5.0, 5.1; the plan's §3).
- **G3, `partly built`:** **not shown.** The second and third decisions are `not built`, rightly:
  nothing of either exists. The first is `followed`. No decision was half there.
- **G5, `git grep`:** **held, with one `\|`.** The reviewer's searches were `git grep -n`, but one
  was `git grep -n "count_completed_today_for_team\|workspace_day_start"`, which its procedure
  says never to write. Under `git grep` 2.56.0 it prints the same lines as `-E` with `|` (six), so
  nothing turned on it; under the owner's ripgrep alias it would not have.
- **G1, the review file:** **held.** The gate ran `printf '%s\n' "${TMPDIR:-/tmp}/shipkit-ship-review.out"`
  first and gave `Write` the path it printed (`/var/folders/…/T//shipkit-ship-review.out`); nothing
  is left under `$TMPDIR` named `shipkit-ship-*`.
- **G7, the wait:** the reviewer ran in the background; the gate tried `sleep 60`, which Claude
  Code blocked ("use Monitor with an until-loop"). It armed no `Monitor`, read `ship/reference.md`
  and waited for the agent's notification. No idle tail.
- **Took:** 73 s wall clock; $0.29; 10 turns; the suite about 13 s each way.
- **Awkward:**
  1. **The gate runs the failing command first, every time** (§2.1). One wasted suite start, and a
     report that quotes an exit 1 in its PASS step.
  2. The reviewer's REQ-5 and REQ-6 reading leaves T1's work unmarked; a `partly built` for a
     requirement, not only a decision, would have fit. Not this plan's mark.
  3. One `\|` in a reviewer search (above).
- **Whose fault:** (1) the tool's (§6.1); (2) nobody's; (3) the model's, harmless here.
- **Evidence:** `run/09-report-day1.md` (a copy, the original left untracked), `run/09-ship.json`,
  `run/09-ship.jsonl`, `run/agent-abe96fe82db9b685b.jsonl` and its meta file; `sed` on the cited
  lines.
- **Against 5.1 §9:** better. The same verdict for the same reason in 73 s against 104 s; setup's
  two files are off the list; the test command came from `CLAUDE.md`, not the prompt; no `Write`
  went to a path it could not expand.

**Day two** (REQ-8, G11), on 2026-11-08 in the owner's zone, from 2026-11-07T19:30Z.

**First, a reboot.** The machine restarted at 00:29 IST on 2026-11-07 (`sysctl kern.boottime`), and
`/private/tmp` went with it: the worktree's folder, the untracked report, `deps/`, `_build/` and
setup's git-ignored `.shipkit-baseline/`. What stayed: the branch at `ee9b06b`, the worktree's
registration (`git worktree list` → `prunable`), the database `office_bestie_test_shipkit6`, and
everything under `~/.cache/shipkit-real-run-6/`, because each step's output was copied there as it
ended (REQ-7; `design.md`, fifth record). It is the second reboot to take a run's tree: 5.1's, on
2026-11-04, took its report and `run/` as well.

**Rebuilt, on the owner's yes (2026-11-08).** `git worktree add -f /private/tmp/shipkit-real-run-6
shipkit/real-run-6` re-attached the registered path; nothing was pruned. The report was restored
from `run/09-report-day1.md` under its own name, sha256 `e23b1ba1…fd7fcd91a`. `git status --short`
→ `?? .shipkit/releases/`, as day one's `run/09-ship.status`. The Check again
(`run/00b-check-day2.log`, 2026-11-07T19:30Z): `deps.get` exit 0, compile exit 0 (236 files), the
suite → **2857 passed, 12 skipped, 14 excluded**, exit 0, day one's gate count at `ee9b06b`; `mise`
2026.11.3 (day one 2026.11.1). So "the same tree" reads: the same commit and the same untracked
report, byte for byte, in a rebuilt folder. Nothing the gate reads was in what was lost: the
reviewer tells setup's files by `.claude/rules/shipkit/.setup-files`, which is committed
(`reviewer.md:51-55`), not by the baseline.

- **Asked for:** day one's words, the same file (`tools/09-ship.txt`; `run/09b-ship-day2.prompt`).
- **Produced:** `.shipkit/releases/2026-11-08-team-day-boundary.md`, 7,022 bytes, first line `NOT
  READY`, untracked, at `ee9b06b` against `179f99d`. Day one's eight results, each again: spec-check
  **FAIL** (REQ-1 to REQ-4, REQ-7), tests **PASS** (2857), tasks **FAIL** (T2 to T6), review
  **FAIL**, migration **PASS**, decisions **PASS**, clean tree **PASS**, decisions fired **PASS**
  (2 hold, 1 manual).
- **REQ-20: held.** The reply: "`.shipkit/releases/2026-11-06-team-day-boundary.md` is untracked
  and now superseded by the new report. I left it in place, so keeping it or deleting it is your
  call." The report says it too (`:101`). The earlier file is where it was, its sha256 unchanged.
  The first gate where the sentence could be read on a real project.
- **The reviewer:** `shipkit:reviewer` on `claude-sonnet-5-5`, in the background, spawn depth 1,
  two Bash calls, a real `SubagentHandback`. **0 MET, 5 NOT MET, 2 CANNOT TELL**: REQ-5 and REQ-6
  are now CANNOT TELL where day one said NOT MET, on the same tree: "Only the helper is covered, so
  I can't mark it met" (report `:67`). **Every citation read:** `accounts.ex:606`,
  `team_pulse.ex:87`, `manager_briefing.ex:110`, `coach.ex:64`, `actions.ex:246`, the test file's
  `:10`, `:19`, `:28` are each the line they say.
- **G3, `partly built`:** **held.** "Where the workspace day start comes from — `partly built` —
  The new function and shared helper exist at `lib/office_bestie/accounts.ex:606` … No surface
  (`team_pulse.ex`, `manager_briefing.ex`, `ai/coach.ex`) calls `workspace_day_start` yet" (report
  `:78`). Day one marked the same decision `followed`; the other two are `not built` both days.
- **G2:** **held** again: `.gitignore` and `CLAUDE.md` named as "left exactly as installed", the
  result "None." (report `:71-75`).
- **G5:** **held**, with no `\|` this time: `git grep -n` three times, `-E` once.
- **G1, the review file:** **held.** `printf` first, then `Write` to the path it printed
  (`/var/folders/…/T//shipkit-ship-review.out`); nothing under `$TMPDIR` named `shipkit-ship-*`.
- **G7, the wait:** no `sleep` and no `Monitor`. The last turn ended at 19:32:28.4Z, the session at
  19:32:29Z.
- **G4:** as day one: `( MIX_ENV=test mix test )` first → exit 1, then the `mise exec --` form.
- **Took:** 59 s wall clock; $0.31; 10 turns.
- **Awkward:**
  1. **The failing command first, again** (§9.1).
  2. **One tree, two readings.** REQ-5 and REQ-6 are NOT MET on day one and CANNOT TELL on day
     two; one decision is `followed` on day one and `partly built` on day two. The verdict did not
     move; the marks did.
  3. The count line miscounts, then corrects itself: "Requirements: 0 MET, 4 NOT MET, 2 CANNOT TELL
     (0 waived). REQ-7 is also NOT MET, so the totals are 0 MET, 5 NOT MET, 2 CANNOT TELL" (`:85`).
  4. **The run's tree lived in `/private/tmp` across two days,** and a reboot took it. The copies
     held; the tree had to be rebuilt by hand, on a yes.
- **Whose fault:** (1) the tool's (§6.1); (2) the model's, within marks that allow both; (3) the
  model's; (4) the run's: REQ-4 put the tree in `/private/tmp`, and a run spread over days should not.
- **Evidence:** `run/00b-check-day2.log`; `run/09b-ship-day2.prompt`, `.json`, `.jsonl` (session
  `60204b46`), `.status`, `.wall`; `run/09b-report-day2.md` (a copy, the original left untracked);
  `run/agent-a97ed92f8e9898d74.jsonl` and its meta file; `sed` on the cited lines.
- **Against day one:** the same verdict for the same reasons, 59 s against 73 s, $0.31 against
  $0.29. It adds REQ-20 read and held, and G3 shown.

**G6, read in the thread.** Setup's line on the two sections was quoted to the owner after day one:
"`CLAUDE.md`: I did not rewrite it. It already had a `## Elixir-Specific` section, so shipkit's
elixir block sits below it under its marker. `/shipkit:setup rules` can merge the two." On
2026-11-06 the owner chose to leave both (`CLAUDE.md:76`, `:139`), so the day-two gate reads the
same tree. `run-debts`' first record reverses if a project "ends with both sections after the user
read the line": read here in the thread, not in setup's own session, so the condition is met by
the owner's reading, with that difference. Nothing was changed; the ROADMAP carries it (S28-T3).

## What a session here costs

`scripts/context-cost.sh` on the worktree, before setup (`run/01-context-cost.tsv`, 2026-11-06)
and with T1 built (`run/09c-context-cost-day2.tsv`, 2026-11-08, the rebuilt tree). The two middle
columns of 5.1's table were not measured on this run.

| Row | Before setup | T1 built | 5.1, T1 built |
|---|---:|---:|---:|
| `hook` | 2,396 | 456 | 441 |
| `skills-core` | 2,894 | 2,894 | 2,894 |
| `skills-workflows` | 1,885 | 1,885 | 1,885 |
| `agents` | 991 | 991 | 991 |
| `overlay-skills` | 0 | 0 | 0 |
| `overlay-appends` | 0 | 2,082 | 2,007 |
| `rules-always-on` | 2,999 | 2,999 | 2,999 |

`overlay-appends` is 75 bytes more than 5.1's: the `mise exec --` prefix (G4) and the app's name in
place of `<app>` (G1).

**What the run cost**, from each step's `.json` and `.wall`:

| Step | Wall clock | API spend | Turns |
|---|---:|---:|---:|
| §2 setup | 55 s | $0.20 | 7 |
| §3 product | 32 s | $0.14 | 7 |
| §4 intake | 102 s | $0.38 | — |
| §5 intake, answers | 23 s | $0.11 | 7 |
| §6 spec | 133 s | $0.41 | 19 |
| §8 build | 40 s | $0.17 | 12 |
| §9 gate, day one | 73 s | $0.29 | 10 |
| §9 gate, day two | 59 s | $0.31 | 10 |
| **Total** | **517 s** | **$2.01** | |

§4's `.json` reports 2 turns for a session of 6 calls; the turns column is left blank there. Day
one alone is 458 s and $1.70, against 5.1's nine steps without the walk, 698 s and $1.81.

## Did the decisions hold?

| Line | On this run |
|---|---|
| **G1**, four small debts | `APP_NAME` **held**: `CLAUDE.md:149`, `:152` read `lib/office_bestie/`, no `<app>` left (§2). The review file **held** both days: `printf` first, `Write` to the printed path, nothing left under `$TMPDIR` (§9). A `Status:` line in `design.md` **not shown**: the model wrote none (§6); smoke check 87 holds it. `walk.md:3` **not shown**: no step of this run hands the walk to an agent; smoke check 84 holds it |
| **G2**, setup's two files are setup's | **Held**, both days: "Changes beyond the spec: None" (day one report `:81`; day two `:71-75`). The first real gates not to list them, after 4.12, 5.0 and 5.1 did |
| **G3**, `partly built` | **Held on day two**: the first decision `partly built`, each part with its path (day two report `:78`). Not shown on day one, which marked the same decision `followed` (§9) |
| **G4**, the test command on a pinned toolchain | **Held where setup writes**: `CLAUDE.md:159` carries `MIX_ENV=test mise exec -- mix test`, and setup's reply says why (§2). **Not carried further**: the spec copied the project's own `CLAUDE.md:10` into every Done-when (`tasks.md:3`, `:9` to `:34`; §6), so the brief handed on a command that exits 1 (§7). The agent (§8) and the gate (§9, both days) found the prefix themselves |
| **G5**, `git grep -n`, `-E`, never `\|` | **Held.** Every reviewer search was `git grep`; one `\|` on day one, harmless under git 2.56.0 (§9); none on day two |
| **G6**, the second `## Elixir-Specific` | **Not shown in setup's session**: setup ran headless on the owner's word (REQ-5 as amended; `design.md`, third record). Read in the thread, and the owner left both (§9, "G6, read in the thread") |
| **G7**, the headless wait | **Held, under the bar**: the intake idled 8 s after its file, with no `Monitor` (§4, `wait-probe.sh --read`). The day-one gate's `sleep 60` was blocked by Claude Code and it waited for the notification; the day-two gate armed neither |
| `fifth-run/design.md`, fifth record: copies outside `/private/tmp` | **Held, and tested.** The clause reverses it "if anything under `~/.cache/shipkit-real-run-6/` is missing when it is next read". Nothing was, after a reboot took the tree (§9, Day two) |
| `review-and-ship/REQ-20`, the earlier report named superseded | **Held** on day two: named in the reply and the report (`:101`), left in place, unchanged |

## What the run showed, in one place

Eight headless sessions over two days, **517 s and $2.01**. Every step produced the file it is for;
every check the runner re-ran agreed with the model's claim; nothing had to be undone. The gate gave
the same verdict for the same reasons on both days. Of the plan's seven lines, G2, G5 and G7 held
everywhere they were read, G3 held on its second chance, G1 held where it could be read, G4 held
only where setup writes, and G6 was read by the owner in the thread, not in setup's session.

**What this run found, each a one-line item for the ROADMAP's "Still open after Sprint 28" (S28-T3):**

1. **The spec copies the project's test command, not setup's** (§6.1, §7.1, §8.1). Every Done-when
   and the brief carry a line that exits 1 here; the agent and the gate found the prefix on their
   own. G4 fixed what setup writes and nothing that reads it.
2. **Two test commands in one `CLAUDE.md`** (§2.1), the cause of (1). `users-machine/design.md`'s
   second record turns on "a real run's `CLAUDE.md` names two different test commands again, from
   any stack": here the second is the project's, not a stack's. T3 says which way that reads.
3. **The gate runs the failing command first,** on both days (§9.1; Day two, 1).
4. **One tree, two readings by the reviewer**: REQ-5 and REQ-6 NOT MET, then CANNOT TELL; one
   decision `followed`, then `partly built` (Day two, 2). The verdict held; the marks did not.
5. **A run spread over days keeps its tree in `/private/tmp`,** and a reboot took it, as at 5.1
   (Day two, 4). The next real run's worktree goes under `~/.cache/`.
6. **The second `## Elixir-Specific` stays,** and the owner, having read the line, left both
   (§2.2; G6). `run-debts`' first record turns on exactly that reading.
7. The version line reads 5.1.0 on a `--plugin-dir` checkout two sprints on (§1). Known.
8. Small, the model's: a reply that says "no other changes" and lists three (§5); a reviewer count
   line that corrects itself (Day two, 3); one `\|` (§9.3). Older, again: the hand-written stamp in
   a headless flow (§7.2); ripgrep in the session's shell (§2.3).

## What became of the branch

`shipkit/real-run-6` held two commits never for merge, `8f2dbb4` (setup, product and the spec) and
`ee9b06b` (T1), 25 files, +655/−1 against `179f99d`, plus the two gates' untracked reports. On the
owner's yes of 2026-11-08, after these notes were written and their citations read, at
2026-11-07T20:05Z: `git worktree remove --force /private/tmp/shipkit-real-run-6`,
`git branch -D shipkit/real-run-6` (was `ee9b06b`), `dropdb office_bestie_test_shipkit6`, and
`~/.cache/shipkit-real-run-6/` removed, so the `run/` files cited above are gone; what they showed
is quoted here. `~/code/office_bestie` is on `main` at `179f99d`, one worktree, no `shipkit/`
branch, its 29 untracked entries as before the run. T1's diff went with the branch; §8 says what it
held.
