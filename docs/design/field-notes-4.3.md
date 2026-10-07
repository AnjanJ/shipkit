# Field notes 4.3 — shipkit's loop, once, on a repository that is not shipkit

> Sprint 10, S10-T3 (B10). Written 2026-10-07 while running, from the commands and their output.
> One project, one run, one model (`sonnet` headless): anecdote, not measurement. Nothing was
> fixed in this task; every awkwardness is a one-line candidate under ROADMAP's "Still open after
> Sprint 10", pointing back here. Spec: `.shipkit/specs/real-run/` (REQ-9 to REQ-11).

**The repository.** `rails_error_dashboard` (RED), the owner's self-hosted error-tracking Rails
Engine: 755 commits, 5,300+ RSpec examples, a `CLAUDE.md` with its own eight-section "Workflow
Orchestration", a root `PROJECT_MAP.md` (generated on `feat/storm-protection`), six specs under
`.shipkit/specs/` written with shipkit ≤ 3.2 (no `Status` line), one decision record, and eleven
project skills under `.claude/skills/` — which the repository's `.gitignore` ignores wholesale
(line 31: `.claude/`). The owner's condition: **no code changes**. So the loop's "build it" step
is replaced by "hand the brief to nobody" and the gate is run on a spec whose code does not exist
— which is also what a gate should refuse.

**Where it ran.** A worktree of RED at `main` (`4fcf366`, "release 0.14.4") on a new branch
`shipkit/real-run`, created by this task and removed by it; the owner's checkout stayed on its
own branch. Because `.claude/` is untracked, the worktree had none of the project's skills or
hooks until they were copied in by hand (untracked there too). *Awkward, the project's:* a
project that keeps its skills out of git loses them in every worktree, including the ones Claude
Code's own agent isolation creates.

**How each skill was run.** `claude --model sonnet --allowedTools Read Glob Grep Bash Write
Skill Agent -p "/shipkit:<skill> … This run is not interactive"` from the worktree, so the
installed 4.2.0 plugin loaded as it would for the owner, with RED's `CLAUDE.md` and skills.
Durations are wall-clock from `date`.

Each section below (one per step: the cache update, product, intake, the owner's answers, intake again, spec, acceptance and brief, build, the gate, its review, handoff, a fresh session) answers the same six questions: what the step asked for, what it produced,
how long it took, what was awkward, whose fault that is (the tool's or the project's), and the
evidence line.

---

## 0. Updating the owner's plugin cache (3.1.0 → 4.2.0)

- **Asked for:** the installed plugin to be the released 4.2.0 before the run (plan S10-T3 step 1).
- **Produced:** two commands, both first try:
  ```
  claude plugin marketplace update shipkit      # 22 s: re-cloned git@github.com:AnjanJ/shipkit.git
  claude plugin update shipkit@shipkit          #  1 s: "updated from 3.1.0 to 4.2.0 for scope user. Restart to apply changes."
  ```
  `installed_plugins.json` now points at `cache/shipkit/shipkit/4.2.0` with `gitCommitSha`
  `5085d2f` (the `v4.2.0` tag). The 3.1.0 directory is left beside it.
- **Took:** 23 s.
- **Awkward:** the SSH clone that "usually refuses" in this repository's pushes worked here
  without a prompt. The owner's interactive session keeps 3.1.0 until restarted ("Restart to
  apply"), so during this run the owner's own sessions and the headless runs below disagreed
  about which version was installed. Nothing in shipkit says "you are on 3.1.0; 4.2.0 is out".
- **Whose fault:** the platform's (restart semantics), and shipkit's for not saying so — the
  session hook knows its own version and could print it when the cache holds a newer one.
- **Evidence:** the `plugin update` line above; `python3 -c` over `installed_plugins.json`
  printed `'version': '4.2.0'`.

## 1. Session start: what the 4.2.0 hook says in RED

- **Asked for:** nothing — the hook runs on its own. Measured by running
  `scripts/session-start.sh` from the installed 4.2.0 root inside the worktree.
- **Produced** (603 bytes, 353 ms; the three always-on rules follow it in a real session):
  ```
  shipkit: plugin root is ~/.claude/plugins/cache/shipkit/shipkit/4.2.0
  shipkit: .shipkit/specs/environment-awareness/spec.md is 83 commits behind HEAD — the code may have drifted from the spec.
  shipkit: credential-guard: 6 of 8 tasks done, next T5 — The release notes carry a "this can stop an app booting" section, as 0.9.1 did.
  shipkit: environment-awareness: 17 of 17 tasks done, all ticked
  shipkit: setup-hardening-0-14-3: 6 of 7 tasks done, next T6 — Verification: the full suite on Rails 8.1, the drop spec on PostgreSQL, chaos
  shipkit: spec-check: 23 gap(s) — run spec-check.sh
  ```
- **Took:** 353 ms.
- **Awkward:**
  1. **Every one of RED's six specs is treated as open**, because none has a `Status` line
     (they predate 3.3) — so the briefing reports as "in flight" three features that shipped in
     0.14.x, nags that one has "drifted" 83 commits, and `spec-check` finds **23 gaps**, all
     `MISSING-TASK`: the pre-3.3 `tasks.md` files cite requirements loosely. A project that
     used shipkit before 3.3 gets a briefing that is wrong in every line but the first, every
     session, until someone adds six `Status: shipped` lines by hand. Nothing offers to.
  2. "17 of 17 tasks done, all ticked" is printed as if it were news; a spec with every task
     ticked and no `Status` line is almost certainly shipped, and the hook could say so (or
     say nothing).
  3. The "drifted" line names the spec with the most commits behind, not the one the owner is
     working on.
- **Whose fault:** the tool's. The 3.3 format change was never paired with a migration nudge
  for the specs it orphaned; the eleven specs in shipkit's own repository all got their `Status`
  lines by hand in Sprint 2.
- **Evidence:** the six lines above; `spec-check.sh .` in the worktree → `6 spec(s) checked,
  23 gap(s)`, every line `MISSING-TASK` (none `MISSING-TEST`: open specs are not asked for tests).

## 2. `/shipkit:product` — no product file existed

- **Asked for:** `/shipkit:product`, told the run is not interactive, to write the best file it
  can from README, ROADMAP and CHANGELOG, and to list the questions it would have asked.
- **Produced:** `.shipkit/product.md`, 2,563 bytes, seven headings (One line, Users, Goals this
  quarter, Non-goals, Metrics that matter, Constraints, Now / Next / Later). It read README,
  ROADMAP, CHANGELOG, `PROJECT_MAP.md` and decision 0001. It **invented no metric, target or
  date**: each of the three inferred goals ends "metric: none set; target: none set; by: no
  date set", and the reply says so first: "Nothing in the repo gives a metric, target or date
  for any goal, so I invented none." Non-goals came from the README's own "no APM" stance and
  from decision 0001 ("RED never writes another gem's files"). Eight questions listed, the
  sharpest: "ROADMAP says 'nothing scheduled' and is stale: it was written at v0.14.0, and the
  repo is at v0.14.4" and "Is merge/split grouping a non-goal? The README says 'no merge/split',
  but the roadmap lists it as open."
- **Took:** 47 s.
- **Awkward:** a goal with three "none set" fields is a placeholder, not a goal; the file reads
  well until that line. The skill's own guardrail ("never invent a goal, metric, date") did its
  job, and the visible gaps are the point — but a reader who has not read the skill will think
  the file is broken. The eight questions are good and go nowhere: they live in a headless
  reply, not in the file, so the owner's next session cannot see them.
- **Whose fault:** the tool's (the questions should be written into the file under an
  "Open questions for the owner" heading when no user is present), and the project's (a roadmap
  that says "nothing scheduled" and a README that contradicts it on merge/split).
- **Evidence:** the reply's first line and the three goal lines quoted above;
  `git status --short` → `?? .shipkit/product.md`, nothing else.

## 3. `/shipkit:intake` — one small real change: the health check endpoint (ROADMAP item 14)

- **Asked for:** `/shipkit:intake Add a health check endpoint to the dashboard engine (ROADMAP
  item 14, 'Who watches the watchmen'): a route that reports whether the gem's own capture path,
  storage and notifiers are working, for an external monitor to poll.` Non-interactive.
- **Produced:** no file (correct: "If no user is present … state the conflicts, list your
  questions, and stop there"). The reply: **no conflicts** (checked `product.md`'s non-goals by
  line, the six specs by name, decision 0001; noted the request sits in `product.md:40` under
  "Next"); the nearest goal named, with the honest note that it has no metric; **code research
  with file:line evidence** — the roadmap's own sketch (`ROADMAP.md:542-546`: JSON with database
  connectivity, error count, last error, "queue status"), that the engine has no failure counters
  or last-success state anywhere, that every route sits behind auth except `WebhooksController`,
  that "queue status" has no source, and that a live notifier probe "would send real Slack,
  email or other messages, so it isn't safe to poll". **Four questions**, in order: auth (public
  like webhooks, or behind dashboard auth); report configuration-plus-DB only, or record
  last-success/last-failure (new writes inside the capture path, so host-app-safety work);
  response contract (200/503; drop "queue status"); which goal. Three assumptions stated.
- **Took:** 110 s.
- **Awkward:** nothing in the skill — this is the intake doing exactly what it is for, on a
  codebase it had never seen, and the second question is the one that decides whether the
  change is a half day or a week. Two things around it: (1) the reply is the only place the
  questions exist; a headless run leaves nothing on disk, so the owner has to be handed the
  reply by whoever ran it; (2) it ends with "`/shipkit:intake` can be rerun" — the rerun will
  redo the two minutes of research to write a file whose contents are already in this reply.
- **Whose fault:** the tool's, mildly: an unanswered intake could write `intake.md` with the
  answers blank (the skill's own format has "An unanswered question is written as unanswered")
  instead of writing nothing, and the rerun would then only fill the blanks.
- **Evidence:** the reply's "**Conflicts** — No conflicts found" and its four numbered questions;
  `git status --short` → still only `?? .shipkit/product.md`.

**The run paused here for the owner's answers** (the owner was present; the headless run was
not). Answers and the time they took are in the next section.

## 4. The owner's answers — found in the repository, not in the owner's head

- **Asked for:** the four intake questions, put to the owner.
- **Produced:** the owner's reply: "I am not sure whats the answer here, can you dive in to
  commit logs and docs and see if you find any?" So the executor searched the repository
  (ROADMAP, `docs/`, `git log --grep=health`, the controllers, the configuration, the business
  case under `.shipkit/research/`, GitHub issues) for about eight minutes, and found that the
  repository had already answered three of the four and half of the third:
  1. **Auth** — `configuration.rb:285` "Authentication is ALWAYS required"; the base
     controller's comment (a controller is protected unless it opts out visibly, written after
     the locale picker once shipped unauthenticated); the only opt-out, `WebhooksController`,
     verifies HMAC signatures. → Behind the dashboard auth; the monitor supplies credentials.
  2. **Depth** — ROADMAP item 14 lists exactly four fields at "Effort: Half day"; CLAUDE.md
     rule 1 is host-app safety. → No new state, no writes in the capture path.
  3. **Contract** — JSON, as the roadmap says; **"queue status" has a source after all**:
     `services/system_health_snapshot.rb:162 job_queue_stats`, cached and gated by
     `config.system_health_queue_stats`, hardened in commits `2f16b76` and `befc805`. The
     intake's "the roadmap's 'queue status' has no source, because the gem tracks no queue
     state of its own" was **wrong**, and the owner would have accepted it. 200 / 503 is
     nowhere in the repository: the one answer that was actually the owner's to give.
  4. **Goal** — `.shipkit/research/oss-business-case-file.md` §10.4 puts "health endpoint and
     webhook HMAC (procurement questions)" under "Before 1.0" → "Reach 1.0 from beta".
  The owner approved the four ("ok go ahead").
- **Took:** 1 h 36 min wall-clock between the intake's questions (19:09) and the rerun with the
  answers (20:45) — the owner was away for most of it; the executor's search took about eight
  minutes of that, the owner's reading of the findings a few more.
- **Awkward:** two things, both the tool's. (a) The intake asked the owner four questions of
  which three were answerable from files it had just read or could have read — the skill says
  "drop anything a file already answers", and it dropped none, because its code research
  stopped at the controllers and never opened `.shipkit/research/` or the configuration's
  comments. (b) One of its evidence claims was false, stated with the same confidence as the
  true ones. The owner's instinct — "dive into commit logs and docs" — is exactly what
  `grandfather` is for, and the intake skill says to ask `grandfather` for "how does the code do
  X today?"; whether it did is not visible in a headless reply.
- **Whose fault:** the tool's. A question the repository can answer should not reach the owner,
  and a claim of absence ("has no source") should name what was searched.
- **Evidence:** the owner's message quoted above; `grep -rn 'def job_queue_stats'` →
  `system_health_snapshot.rb:162`; `git log --oneline -i --grep=health` → `befc805 fix(health):
  one queue-count refresh in flight…`, `2f16b76 fix(health): cache and gate job-queue depth
  counts…`.

## 5. `/shipkit:intake` again, with the answers — it writes the file and finds a trap

- **Asked for:** the same request, plus the four answers "as the owner's, from the repository's
  own evidence", with the file:line evidence for each; told to write `intake.md`.
- **Produced:** `.shipkit/specs/health-check/intake.md`, 4,791 bytes, in the skill's format
  (Request, Serves goal, Conflicts found, Answers, Assumptions made, Out of scope). It
  **re-checked every cited fact** ("I checked each cited fact against the code myself, and they
  all hold"), corrected one line number (`configuration.rb:284`, not 285), noted that the
  request's word "notifiers" had been narrowed to configuration presence ("a narrowing of the
  request, not a conflict"), and **found a design trap the owner's research had missed**:
  `ApplicationController` has a catch-all `rescue_from StandardError` that renders an HTML error
  page, and that page runs database queries — so a failing database would answer the JSON
  endpoint with HTML, or with a second error. Written into the assumptions as something "the
  spec will need to deal with explicitly". Eight assumptions, five out-of-scope lines. It said
  plainly: "I didn't use the `grandfather` agent."
- **Took:** 52 s.
- **Awkward:** the first intake and this one did the same two minutes of reading; the trap was
  found on the second pass, not the first, with no change in what was available to read. And
  the skill's instruction to delegate code research to `grandfather` was skipped both times,
  by the run's own account — a project with a `PROJECT_MAP.md` and the elder on hand got neither.
- **Whose fault:** the tool's: the skill says "ask the grandfather agent; do not read the
  codebase yourself in this skill" and the model read the codebase itself, twice. Whether that
  cost anything here is unknowable from one run; it cost nothing visible.
- **Evidence:** the reply's "I didn't use the `grandfather` agent; I checked each cited fact
  against the code myself, and they all hold" and its "**Spec issue:**" paragraph; `git status
  --short` → `?? .shipkit/product.md`, `?? .shipkit/specs/health-check/`.

## 6. `/shipkit:spec health-check` — three drafts, the gates left for the owner

- **Asked for:** `/shipkit:spec health-check`, non-interactive; told that the two approval gates
  cannot be passed, so: write all three files as drafts, keep `Spec not yet accepted` and
  `Status: draft`, propose a `Paths` line, show the requirements and decisions at the end, run
  spec-check and fix what it reports.
- **Produced:** `spec.md` (3,691 B, eleven EARS requirements, one excused as prose; a `Paths`
  line of seven files; a "Release steps — not requirements" section), `design.md` (7,873 B,
  five decision records, each with a clause; one with a `Fired-if` command), `tasks.md`
  (3,080 B, seven tasks with the four sub-lines, `After` chains T1→T2→T3→T4→T5 and T2→T6;
  T7 docs). It read the intake and did not re-ask its questions. The reply listed every
  requirement and every decision for approval, flagged its own judgement calls ("I read 'error
  count' as the last 24 hours … This departs from the plain wording … so please check it"), and
  offered to tighten one clause. To run spec-check on a draft it **set the status to `open` for
  one run and restored `draft`** — "it reported 0 gaps (REQ-11 shows as waived)".
- **Took:** 114 s.
- **Awkward:**
  1. **A `Fired-if` that fires on day one.** Decision 2's command is
     `test "$(grep -c . lib/rails_error_dashboard/queries/health_report.rb)" -lt 40` — "reverse
     this if the query object stays under 40 lines". The file does not exist yet, so `grep -c`
     prints nothing and `test "" -lt 40` exits 2: `decision-check.sh . --run` reports
     `ERROR … (exit 2)` — "5 decision(s), 0 fired, 0 hold, 4 manual, 1 error(s)". Once the file
     exists and is short, which every new file is, it will read `FIRED` and the gate's step 8
     fails on a decision that has not had a chance to be wrong. A clause about the *size the
     code will have* is not a reversal condition for a decision taken before the code exists;
     the reference says "a metric, an event, or a threshold", and the model took "threshold"
     literally. The ship skill's step 8 passes on "no `FIRED` line", so an `ERROR` line slips
     through it.
  2. **spec-check cannot check a draft**, so the skill flipped the status to run it. That is the
     right instinct and the wrong mechanism — a `--as-open` (or checking drafts for the three
     task-format findings, which need no status) would make the flip unnecessary.
  3. The design's first decision inherits `ApplicationController` and overrides its
     `rescue_from` — the trap the intake found, handled; the reply says where it is unsure.
- **Whose fault:** (1) the tool's: a Fired-if that can fire before the feature exists should be
  caught when the record is written (the spec skill could run decision-check on its own output,
  as it runs spec-check); (2) the tool's; (3) nobody's.
- **Evidence:** the reply's "I set the status to `open` for one run, and it reported 0 gaps
  (REQ-11 shows as waived). I then restored `draft`"; `spec-check.sh . health-check` →
  `SKIPPED health-check (draft)`; `decision-check.sh . --run` → the `ERROR` line quoted above.

## 7. Accepting the spec, committing it, and `brief.sh` for T1 — "build it" skipped by the owner's rule

- **Asked for:** the owner's "approve" at the Q1 gate (given in the shipkit session, not in the
  headless one); the stamp and `Status: open` written by hand (the skill's "On approval" step
  needs `AskUserQuestion`); the five files committed on the throwaway branch; `brief.sh . health-check
  T1`; `brief-verify.sh` against the commit, with **nothing built** — the owner's condition for
  this run was no code changes, so the brief was produced and handed to nobody.
- **Produced:**
  - **The Fired-if fix broke, then worked.** Replacing the line-count command with
    `manual  <!-- was … -->` on one line left decision-check at `1 error(s)`: it took the HTML
    comment as part of the command. On its own line below, `5 manual, 0 error(s)`.
  - **The project refused the commit.** `git commit` ran RED's lefthook pre-commit; its
    `bundle-audit` step tried to update `~/.local/share/ruby-advisory-db` and died with
    `fatal: couldn't find remote ref master` (the clone tracks `master`; upstream renamed it).
    `rubocop-staged` and `rspec-changed` skipped ("no files for inspection" — only `.md` files
    were staged), three more steps skipped on "broken pipe" after the failure. 14.6 s to refuse
    a commit of five Markdown files. Committed with `LEFTHOOK=0`; the advisory-db clone was not
    touched.
  - **`brief.sh`**: 50 ms, 2,289 bytes. Goal (the spec's Purpose), REQ-1 and REQ-8 word for
    word, the five files T1 may edit ("Nothing else. If the task cannot be done inside these
    files, stop and report blocked."), the test and the Done-when, "Already done: Nothing — this
    task has no predecessors", the two binding decisions by title, the six out-of-scope lines,
    the fixed report-back form. Nothing to fault.
  - **`brief-verify.sh`** before the commit succeeded (base = `4fcf366`, spec files staged):
    `4 outside the Files of health-check / T1` — the spec's own `product.md`, `intake.md`,
    `spec.md`, `design.md` (only `tasks.md` is always allowed). After the commit (base =
    `7c6716e`): `0 file(s) changed, all inside the Files`. Exit 0 with nothing built: correct,
    and also the trivial case.
- **Took:** about 3 minutes, of which 15 s was the hook refusing the commit.
- **Awkward:**
  1. **(project)** A pre-commit hook that needs the network and a correctly named upstream
     branch to commit a Markdown file. The spec files cannot be committed in RED without
     `LEFTHOOK=0` or a repaired advisory clone.
  2. **(tool)** A `Fired-if` line tolerates nothing after the command — the reference does not
     say so; `decision-check.sh` could strip a trailing `<!-- … -->` or say which part it ran.
  3. **(tool)** brief-verify's "always allowed" list is `tasks.md` only. If the spec is written
     and the first task handed out in the same uncommitted stretch — the natural rhythm for a
     half-day change — every spec file shows as OUTSIDE. Allowing the spec's own folder would
     match what "the spec's own tasks.md is always allowed" intends.
  4. **(tool, mild)** The stamp has to be written by hand in a headless flow; the spec skill's
     "On approval" step is the only one that nothing headless can perform.
- **Whose fault:** as marked.
- **Evidence:** lefthook's `fatal: couldn't find remote ref master` / `exit status 1`;
  `decision-check: 5 decision(s), 0 fired, 0 hold, 5 manual, 0 error(s)`; `brief-verify: 0
  file(s) changed, all inside the Files of health-check / T1`; `git log --oneline -1` →
  `7c6716e spec: health check endpoint — product file, intake and spec (shipkit real run, not
  for merge)`.

## 7a. Build — the step the owner struck out

- **Asked for:** the loop's step 5: hand the T1 brief to an agent, let it build, check it with
  `brief-verify.sh` and the task's Done-when. The owner's condition for this run was **no code
  changes** in their repository, so the brief was produced (§7) and handed to nobody.
- **Produced:** nothing — no file under `app/`, `lib/`, `config/`, `spec/` or `docs/` changed;
  `brief-verify.sh . health-check T1 <base>` → `0 file(s) changed, all inside the Files of
  health-check / T1`, exit 0: the trivial case of the check.
- **Took:** 0 s of model time; about a minute to run the verifier and read the brief.
- **Awkward:** nothing in the tool. The brief is complete enough to hand over blind (§7); what
  it would have produced is the one thing this run cannot say. What *can* be said: the gate
  (§8) and the fresh session (§10) both read "nothing built" correctly from the tree, which is
  the state a half-finished real sprint is in most of the time.
- **Whose fault:** nobody's — the owner's decision, recorded in the spec's design record for the
  real run ("notes only, fix nothing") and in the ROADMAP candidate list as a limit of this run.
- **Evidence:** `git diff --stat main -- plugins/` in shipkit → nothing from this task;
  in the worktree, `git diff 4fcf366...HEAD --name-only` → five files, all under `.shipkit/`
  (the gate's step 5 output, §8).

## 8. `/shipkit:ship health-check` — the gate on a spec with no code

- **Asked for:** `/shipkit:ship health-check`, non-interactive, the test command given as
  CLAUDE.md gives it (`bundle exec rspec`), "do not change the spec's Status line".
- **Produced:** `.shipkit/releases/2026-10-07-health-check.md`, 8,442 bytes, first line
  `NOT READY`. Eight steps, every one run: spec-check as shipped **FAIL** (ten `MISSING-TEST`,
  REQ-11 waived); tests **PASS** (see below); tasks ticked **FAIL** (T1 to T7 listed with line
  numbers); independent review **FAIL** ("0 of 11 requirements met", the reviewer's whole reply
  copied in, told only the slug and the base ref); migration rollback **PASS**; decisions
  **PASS**; clean tree **PASS**; decisions fired **PASS** ("0 fired, 5 MANUAL"). "To fix before
  shipping": build T1 to T7, tick them, and — from the reviewer — `.shipkit/product.md` is
  outside the spec's `Paths` line: "widen the paths or move that change to its own commit".
- **Took:** 174 s, of which the test suite was 1 min 57 s (5,542 examples, 0 failures, 1
  pending).
- **Awkward:**
  1. **The test command as written fails on this machine.** `bundle exec rspec` → "can't find
     gem bundler (= 4.0.20)": the shell's Ruby is 4.0.7 and `.ruby-version` pins 3.4.5. The gate
     found that `mise exec -- bundle exec rspec` honours the pin, ran it, and **recorded both
     runs** — the failure as written and the pass through mise. That is the right behaviour
     (the plan's rule 10 worries about a pass that exists because the model worked around a
     bug; this is a pass that exists because the model found the project's own way to run the
     command, and said so). The project's fault: CLAUDE.md's command assumes the shell is
     already on the pinned Ruby.
  2. Twice the report says "exit code not captured because of a pipe" and relies on the
     output text instead — honest, and a sign the skill's `How` column should say
     `; echo "exit $?"` or use `set -o pipefail`.
  3. The reviewer's `Paths` finding is the same one shipkit's own gates raised in 4.0.0 and
     4.2.0: a file the sprint touches that the spec's `Paths` does not name. `product.md` is
     written by `/shipkit:product`, before any spec exists; no spec will ever list it.
  4. The gate ran 5,542 examples to learn that none covers a route that does not exist. Step 2
     is right to run the project's command; two minutes is the price of not trusting a claim.
- **Whose fault:** (1) the project's; (2) the tool's; (3) the tool's — `product.md` and the
  release report belong on an always-allowed list, as the spec's own folder does; (4) nobody's.
- **Evidence:** the report's first line `NOT READY` and its table; "`bundle exec rspec` →
  `can't find gem bundler (= 4.0.20) with executable bundle (Gem::GemNotFoundException)`";
  "5542 examples, 0 failures, 1 pending"; the reviewer's "VERDICT: FAIL"; `git status --short`
  → `?? .shipkit/releases/`.

## 8a. The independent review the gate started

- **Asked for:** the gate's step 4 starts the `reviewer` agent and tells it only the slug and
  the base ref — "Review the spec `health-check` against the base ref `4fcf366…`" — nothing
  about what was built or what the other steps showed.
- **Produced:** a review copied whole into the report: a one-paragraph finding ("The diff
  contains only spec files. There is no implementation: no controller, no query object, no
  route, no specs and no docs change"), an eleven-row table with `NOT MET` and the evidence
  column "no code or test" (REQ-11, waived, still checked: "`docs/PRODUCTION.md` has no
  `/health` section"), a "Changes beyond the spec" section naming `.shipkit/product.md` as
  outside the spec's `Paths`, "Decisions not followed: none can be checked because no code
  exists", a "Not covered" line pointing at `/code-review`, and `VERDICT: FAIL`.
- **Took:** inside the gate's 174 s; the reviewer's own turn is not timed separately in the
  report.
- **Awkward:** the reviewer did its job on a tree with nothing to review, and said so without
  padding. One nit: it marked the waived REQ-11 `NOT MET` as well — a waived requirement that
  is also unmet is two facts, and the table has one column. The `product.md` finding is the
  real one and is counted under §8's third awkwardness.
- **Whose fault:** the tool's, mildly (a waived-and-unmet row could say both).
- **Evidence:** the report's section 4, quoted in §8: "Requirements: 0 MET, 11 NOT MET, 0
  CANNOT TELL (1 waived). VERDICT: FAIL".

## 9. `/shipkit:handoff` — the note for the next session

- **Asked for:** `/shipkit:handoff`, told what the session did (spec accepted and committed,
  nothing built, gate NOT READY with the report uncommitted, the owner's no-code hold).
- **Produced:** `.shipkit/state.md`, 1,530 bytes: In flight ("Nothing is half done … the diff
  against `main` holds only `.shipkit/` files"; the report untracked), Done this session (two
  lines, with the commit and the gate's three failing steps), Next step, Open questions (when
  may code start; widen `Paths` for `product.md` or move it), Do not forget — three lines, the
  first of them the mise finding from the gate ("Plain `bundle exec rspec` fails here … Use
  `mise exec -- bundle exec rspec`; the last run was 5542 examples, 0 failures, 1 pending").
  Nothing staged or committed, as the skill promises.
- **Took:** 19 s.
- **Awkward:** the Next step is written as a choice ("start T1 … once the owner lifts the hold,
  or commit the ship report meanwhile"), and the reply says why: "the request gave no single
  next step and the owner's hold blocks the build". A note whose next step is a fork is honest
  but it is not "the one next step" the skill's description promises; the skill could say
  "blocked on: <the owner's hold>" as its own line. Otherwise the note is exactly what a next
  session needs, and it carried the one hard-won fact of the session (mise) forward.
- **Whose fault:** the tool's, mildly (a "Blocked on" line); the rest is the situation's.
- **Evidence:** the state file's "## Do not forget" block quoted above; `git status --short` →
  `?? .shipkit/releases/`, `?? .shipkit/state.md`.

## 10. A fresh session: "What should I do next in this project?"

- **Asked for:** a new headless session in the worktree, no skill named, tools Read/Glob/Grep/Bash
  only: "What should I do next in this project? Answer in a few lines and say which files told you."
- **Produced:** the right answer in 13 s: "**Next: start T1 of the health-check feature** …
  writing a failing `spec/requests/health_endpoint_spec.rb` first … blocked until the owner lifts
  the no-code-changes hold"; while the hold is on, commit the untracked ship report; the `Paths`
  question; "use `mise exec -- bundle exec rspec`"; every test cites `health-check/REQ-N`; the
  branch is a trial. **Files that told it**, in its own words: `.shipkit/state.md` ("the handoff,
  with the next step, open questions and traps"), the spec folder ("the file listing only, which
  I didn't read"), "the session-start shipkit output: health-check is at 0 of 7 tasks with T1
  next, and the top goal is 'depth before breadth'", and `CLAUDE.md` for the rules T1 must follow.
- **The hook at that session start** (nine lines, about 1 KB): plugin root; **two** drift lines
  now (`environment-awareness` 84 commits, `credential-guard` 15 — the spec commit moved HEAD);
  three "N of M tasks" lines, one of them `health-check: 0 of 7 tasks done, next T1 — Route and
  authenticated skeleton…`; `spec-check: 23 gap(s)`; `top goal: Depth before breadth … metric:
  none set; target: none set; by: no date set`; `last handoff (2026-10-07, 0 commits ago): Decide
  the next step: start T1 …`.
- **Took:** 13 s.
- **Awkward:** the handoff worked end to end — the session that had seen nothing answered as
  the session that had seen everything would. Two things around it: the briefing's "top goal"
  line carries the three "none set" fields into every session start of this project from now
  on, which is a nag with no action attached; and the five stale lines from §1 are still there,
  so the one true line about `health-check` is the sixth of nine.
- **Whose fault:** the tool's (the goal line should be silent, or one word, when the goal has no
  metric; and §1's stale-spec problem is now the larger half of the briefing).
- **Evidence:** the reply's first line and its "Files that told me" list, both quoted above; the
  nine hook lines.

---

## What the run showed, in one place

The loop holds. Product → intake → spec → brief → gate → handoff → fresh session ran end to end
on a 755-commit engine shipkit had never seen, with sonnet headless, in about 9 minutes of
model time (47 + 110 + 52 + 114 + 174 + 19 + 13 s) and about two hours of wall-clock, most of it
the owner's pause. Every file a step wrote was the file the next step needed; the fresh session
answered correctly from the handoff and the briefing alone. The gate refused a spec with no
code, with evidence, and found the project's own way to run a test command that fails as
written.

What it cost the owner: four questions they could not answer from memory, of which the
repository answered three and the intake's research should have; one approval they could give.

The sharpest awkwardnesses, for the ROADMAP (tool's side):

1. **Pre-3.3 specs are "open" forever** and make the briefing wrong in most of its lines (§1).
2. **Intake asked the owner what the repository knew**, stated one absence that was false, and
   skipped `grandfather` both times (§3, §4, §5).
3. **A `Fired-if` that fires before the code exists** passed the spec skill and would fail the
   gate's step 8 the moment the file appears (§6).
4. **Files no spec will ever list** — `product.md`, the release report — are "outside the spec"
   to the reviewer and to `brief-verify` (§7, §8).
5. **Headless runs leave their questions in the reply**, not on disk: product's eight, intake's
   four (§2, §3).
6. Smaller: the version line at session start (§0); `Fired-if` tolerates no trailing comment (§7);
   the gate's uncaptured exit codes (§8); the handoff's missing "Blocked on" line (§9); the goal
   line with "none set" ×3 in every briefing (§10).

Project's side, for RED's own backlog, not shipkit's: `.claude/` untracked, so worktrees have no
skills or hooks; a pre-commit hook that needs the network and a renamed upstream branch to commit
Markdown; a test command that assumes the shell is on the pinned Ruby; a roadmap that says
"nothing scheduled" beside a README that contradicts it.

**GUIDE.md's Playbook 4** was re-read against this run: its steps (product with the answers in the
request; intake stops with questions, then a second pass with the answers; spec with the gates
treated as approved; brief; gate; handoff) are what happened here, step for step. No step proved
wrong; the GUIDE is unchanged (spec `real-run/REQ-11`: the condition did not hold).
