# Verifier plan — what checks the checks

Status: **APPROVED 2026-11-17** by the owner ("yes to all"), every decision at its default; V1, V9,
V12, V20 and V21 settled in the thread the same day · Revised before approval on the owner's word:
**one release, every step that costs money in the last sprint, and the real run kept clear of the
owner's live project** · Written
after shipkit 5.3.0 (tag `v5.3.0`, `main` at `5367060`) from three sources, each read on
2026-11-17: the gate's own code and records; the article "How the Claude Code team thinks about
verification" (Addy Osmani, 2026-11-16,
https://claude.dev/blog/how-the-claude-code-team-thinks-about-verification/), read in full; and the
ROADMAP's "Still open after Sprint 28" (`ROADMAP.md:50-107`) · Seven sprints, **one release:
5.4.0** · Follows `docs/plans/machine-sprint-plan.md`, all three of whose sprints shipped in 5.2.0.

Amended after approval, each on the owner's yes of 2026-11-18:

- The `briefing` timing fix is recorded where it was done: S29-T1, moved from S31-T2.
- S30-T0b is new: the briefing's `> Paths:` trim, found in Sprint 29, is Sprint 30's first task
  after its spec.
- S31-T2 gains subtask 5, the briefing's gap count made cheap, after CI's runner failed check 30.

Shipkit's gate answers one question well: does this branch match its spec, with evidence? The read
behind this plan found that the gate is weaker than it looks in four places. A model runs the
checklist, including the five steps a script could run. A citation counts as a test wherever it
sits, even in a comment or a skipped test. A branch can edit the spec that judges it and nothing
says so. And `READY` reads the same whether fifteen requirements were tested or fifteen were only
read.

The article names the principle that covers all four: treat the verification layer as a system of
its own. Keep it out of reach of the changes it judges, grade it against the bugs that mattered,
write a lesson down when it misses, and prune the lessons. Shipkit already does the last of these
for what loads into a session. This plan does the other three, and extends pruning to the checks
themselves.

**The plan has two parts.**

- **Build, Sprints 29 to 34.** Scripts, checks, eval cases, fixtures and probes. No step in these
  six sprints starts a paid model run, and none changes an existing skill, agent or rule file.
  Where a change to what a model reads is needed, its exact text is written into the sprint's
  design and waits.
- **Switch on, measure and release, Sprint 35.** Every paid step, in an order that puts the
  cheapest and most decisive first: the baselines in one batch and one table, then the waiting
  text applied group by group with its own before and after, then the full smoke suite, the loop
  on a real project, the release run, the gates and the tag.

**Sizes used in this plan.** They describe scope, not time.

| Size | Means |
|---|---|
| **S** | One or two files and a check that needs no model |
| **M** | A new script, or a set of cases or prepared text with its checks |
| **L** | A new script plus several callers, or a set of cases built from real misses |
| **XL** | Several stacks or surfaces, a "check first" that may change the design, and a real run to confirm |

---

## 0. The numbers this plan is about

Measured 2026-11-17 at `5367060`. The command behind each row is in the appendix.

| What | At 5.3.0 | After this plan |
|---|---|---|
| A way to run the smoke suite without starting a model | none (`SMOKE_KEEP` is its only switch) | `--no-model`, and `--only <check>` |
| Paid model runs before the last sprint | not planned for | 0 |
| Requirements in this repository's 31 shipped specs | 493, of which 196 waived as `[untested]` | unchanged; the count is on every report |
| A ship report that says, near its top, how many requirements were tested and how many only read | no | yes, on a fixed line a script can read |
| Files in which a citation counts as a test | any non-Markdown file outside `.shipkit/` and `docs/` | the paths a spec's `> Tests:` line names, when it has one |
| Live citations in this repository that sit in a comment, not a test | 2 (`.github/workflows/lint.yml:31`, `brief-verify.sh:28`) | each named by `spec-check` |
| A check for a citation inside a skipped test | none | an information line, then a gap once a real run shows no false positive |
| A check that lists a requirement edited, or waived, on the branch being judged | none | `spec-diff.sh`, quoted in the report |
| Gate steps a script runs end to end | 0 of 8 (a model runs every command) | steps 1, 2, 3, 7, 8 and step 5's file list |
| Sources a task or the gate may copy the test command from | 2 on the 5.2 run's project (`field-notes-5.2.md` §6) | 1: what setup recorded |
| Shipped specs whose `READY` report is checked against a commit | 0 of 31 | all, in observe mode |
| What judges shipkit's own release gates | the checkout under review (`--plugin-dir`) | the last tagged release |
| Eval results a script can read | none in the repository: prose in `docs/design/eval-history.md` | a ledger, one row per case per run |
| Cases below full score in two release runs running, with no root cause | 2 (`hello`; `intake/limit` since 4.9.0) | 0: each fixed or deleted with its reason |
| How the eval cases for a diff are chosen | by hand (5.3.0 ran none) | by `evals-for-diff.sh` |
| Reviewer cases built from a miss a real run showed | 0 of 4 | 5, and 2 more held out |
| Checks that run because of what a diff touches | none | `.shipkit/checks.md`, read from the base ref |
| A reviewer round that reads the round before | no (`field-notes-5.2.md` §9: one tree, two readings) | yes, for open rows only |
| Guidance on which kind of test proves which requirement | none | measured first; text only where the model misses |
| Property or differential tests on shipkit's own scripts | 0 | 5 properties, in CI |
| A check that a cited test fails without the feature | none | `red-check.sh`, by hand in this plan |
| A way for the gate to run the change, not only its tests | none | `verify-run.sh` and a `verify` overlay skill for three stacks |
| A commit stamped with how it was verified | a prose test plan | a `Verified:` trailer, queryable, including `none` |
| `Fired-if` lines that are `manual` | 130 of 137 | fewer: every clause about an eval count gets a command |
| Smoke assertions that only check a prompt's wording | not counted | counted and labelled in the suite's output |
| Evals directory | 204,747 of 204,800 bytes | at most 204,800, with at least 14,000 of room made first |
| Three always-on rules | 2,999 of 3,000 bytes | unchanged |
| Eval cases | 67 | about 78, less what the flake rule and the prune delete |
| Smoke checks | 1 to 96 | 1 to about 130, less what the prune cuts |

---

## 1. How to follow this plan

The machine plan's twenty-seven rules stand, with rule 22 changed as rule 33 says. Eight are new.
Five come from the read and the article, three from the owner's word of 2026-11-17.

- **Rule 28 (new). A change does not judge itself.** The gate that decides whether a spec of this
  repository is `READY` runs from the last tagged release: its skill, its reviewer, its scripts.
  A checks file is read from the base ref, never from the branch. The checkout's own gate runs as
  well, as a test of the new gate, and both results go in the record. The 5.1.0 and 5.2.0 release
  gates ran with `--plugin-dir` at the checkout (`docs/design/eval-history.md`, "Release run
  5.1.0" and "Release run 5.2.0"), so a branch that weakened the gate would have been judged by
  the weakened gate.
- **Rule 29 (new). A new check starts in observe mode.** It prints what it would have failed and
  changes no exit status and no verdict. Its decision record names the event that turns it on,
  usually "read on a real run with no false positive". Both 4.0.0 gates failed their first run on a
  check nobody had seen fire (`spec-check.sh:22-23`); observe mode is how a check earns its teeth.
- **Rule 30 (new). No re-run to green.** A failing check or case is read from its kept trace before
  anything runs again. A case or check below full score in two release runs running opens a
  root-cause task, and that task ends in a fix (rule 23, both sides shown) or in a deletion with
  the reason in `eval-history.md`. "Its shape" is not an outcome. This replaces the re-run
  sentences in the exit checklist's lines 2 and 3.
- **Rule 31 (new). Tuning cases and held-out cases are different cases.** Agent or skill text is
  changed against tuning cases only. A held-out case runs at a release run or on the owner's word.
  A held-out failure is written down before any text changes; a case that text was changed in
  response to becomes a tuning case, and a new held-out case is written in its place.
- **Rule 32 (new). A label is spelled out where a file first uses it.** "V7, the gate script", not
  "V7". It applies to the files this plan writes; older files are not rewritten.
- **Rule 33 (new, the owner's word). Paid steps come last.** A paid step is anything that starts a
  model outside the session doing the work: `scripts/evals.sh`, a headless `claude -p` (a gate, a
  probe, the real run), and the smoke suite's model checks. Sprints 29 to 34 run none. Rule 22's
  sentence "an untagged merge runs the full smoke suite" is replaced for this plan: an untagged
  merge runs the model-free smoke checks (`--no-model`, S29-T1), and the full suite runs once, in
  Sprint 35. Two things are not paid steps: the session doing the work, and the goldfish's cold
  read at each spec's design gate, which the spec skill starts inside that session (V26).
- **Rule 34 (new). What a model reads changes only after its baseline.** Sprints 29 to 34 change
  no existing skill, agent or rule file. The exact text of each such change is written into its
  sprint's design, and Sprint 35 applies it after measuring the case that the text is for. A new
  file a model reads may land earlier only when nothing installs or loads it by default.
- **Rule 35 (new, the owner's word). The owner's live project is never touched.** The real run
  works in a clone of its own, with its own dependencies, build output, database and port, and
  starts only when the owner says. §5 holds the ten lines.

Three reminders from the standing rules, because this plan leans on them: every paid run is in
§4's budget or has its own yes (rule 15); a measurement that would change a shipped file stops for
the owner's go first (rule 6); and a claim carried from this plan is read against its source
before it goes into a spec (rule 25).

### The sprint exit checklist

For Sprints 29 to 34 every line is free:

| # | Command | Must show |
|---|---|---|
| 1 | `bash scripts/lint.sh` | `0 error(s), 0 warning(s)` |
| 2 | `sh scripts/smoke.sh --no-model </dev/null` | every model-free check passes; a failing check is read, not re-run (rule 30) |
| 3 | `node`, on every grader the sprint wrote or changed | the pattern passes a reply it must pass and fails one it must fail (rules 18 and 23) |
| 4 | `sh plugins/shipkit/scripts/spec-check.sh .` | exit 0, 0 gaps |
| 5 | `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md \| wc -c` | at most 3,000 |
| 6 | `find plugins/shipkit/evals -type f -print0 \| xargs -0 cat \| wc -c` | at most 204,800 |
| 7 | the rows of §0 the sprint owns | each at its target, or the record says why not |
| 8 (from Sprint 30) | `sh plugins/shipkit/scripts/release-check.sh .` | its lines read; none new since the sprint began |
| 9 (from Sprint 33) | `python3 scripts/prop.py` | every property holds |
| 10 | `git diff --name-only --diff-filter=MD <base> -- plugins/*/skills plugins/*/agents plugins/*/rules plugins/shipkit/stacks` | nothing: no existing skill, agent, rule or overlay file changed or removed (rule 34) |

Sprint 35 runs the same ten, then the full suite (`sh scripts/smoke.sh </dev/null`) and
`bash scripts/evals.sh -j 4`, in the order its tasks give.

### The release task

As the thinning plan wrote it, once, at the end of Sprint 35. The CHANGELOG's entry opens with
"What changed for you" and leads with two lines: the gate's evidence comes from a script and says
how much was tested, and the reviewer is graded on real misses. By rule 28 the gates are judged by
`v5.3.0`.

From 5.4.0 on, every release also makes a prune pass before its paid runs (added 2026-11-20,
`running-the-change` REQ-34): each row of `docs/design/trim-audit-checks.md` is brought up to
date (the last release in which it failed on a real defect, what else covers it, its cost), its
candidates go to the owner as one numbered list, and a check or case is cut only on the owner's
yes, with its citations moved to a check that still proves the requirement.

---

## 2. Decisions the owner must approve

Five were put to the owner on 2026-11-17 and answered "yes to all", with V1 changed in the same
message; they are marked **settled**. The rest have a recommended default: approve all, or change
any by ID.

| ID | Decision | Recommended default | The other option |
|---|---|---|---|
| V1 | The plan's shape | **Settled, the owner's word:** one release, 5.4.0, and every paid step in the last sprint (rule 33). | — |
| V2 | Where the report says how much was tested | **A second `>` line under `> Checked on …`,** in a fixed form. Line 1 stays exactly `READY` or `NOT READY` (`ship/reference.md:3-4`), since scripts read it. | Put it on line 1 |
| V3 | Where a citation counts | **An optional `> Tests:` line in `spec.md`,** written like `> Paths:`. With it, a citation counts only under those paths. Without it, today's rule holds, so no existing spec changes. | Fixed test folders per stack |
| V4 | A citation in a skipped test | **An information line first (rule 29),** a gap once the real run reads it with no false positive. | A gap at once |
| V5 | A requirement edited on its own branch | **Reported, never blocked.** `spec-diff.sh` lists each changed, added or removed requirement and each new waiver against the spec at the gate's base ref; the report quotes it, and the owner's yes to `Status: shipped` covers it. | A content hash in the acceptance stamp |
| V6 | The test command | **Setup records it once and a script prints it.** The spec skill writes it into every `Done when`; the gate script runs it. Nothing reads `CLAUDE.md` for it any more. | A sentence telling the model which line to prefer |
| V7 | The gate script | **`ship-check.sh` runs steps 1, 2, 3, 7, 8 and lists step 5's migration files,** each with its command, exit code and output. The model keeps step 4 (the reviewer), step 5's judgment and step 6. | Leave the skill as it is |
| V8 | A report tied to a commit | **`release-check.sh` in observe mode, shown in CI.** | Blocking in CI from the start |
| V9 | Who judges this repository's gates | **Settled:** the last tag (rule 28). At the release `v5.3.0` judges all seven specs; the checkout's own gate runs on two of them, as the test of the new gate. CI runs the last tag's `spec-check.sh` beside the branch's. | — |
| V10 | The eval ledger | **`docs/design/eval-ledger.tsv`,** appended by `evals.sh`. 5.2.0 is backfilled from its kept result file, 5.1.0 from `eval-history.md`. | No backfill |
| V11 | The flake rule | **Rule 30,** and a root-cause task for `hello`, `intake/limit`, the `agents` and `rules-skip` smoke checks and the `briefing` timing check. Each deletion is its own yes. | Carry them as known shapes |
| V12 | Room for new cases | **Settled:** move the README's case table and its `with-rule.sh` section to `docs/design/eval-cases.md`; the ceiling stays; decision 0005 stands. | — |
| V13 | Held-out cases | **Two reviewer cases held out** under rule 31. | None; every case is a tuning case |
| V14 | The checks file | **`.shipkit/checks.md`, read from the base ref; the reviewer reports each triggered check; the verdict is unchanged** until two real gates read it right (rule 29). | Prose advice in the reviewer only |
| V15 | Reviewer rounds | **The reviewer reads the earlier report's open rows** (`NOT MET`, `CANNOT TELL`) and says what changed. An earlier `MET` is never evidence. | Stay fully fresh each round |
| V16 | Test kinds | **Measure first.** Text goes into `spec/reference.md` only for a kind the model misses in 2 or more of 5 probes, and stays only if the number moves. | Add the text unmeasured |
| V17 | The property-test library | **Hypothesis,** run with `uv run --with hypothesis` and installed in CI beside PyYAML. | A seeded generator on the standard library |
| V18 | Red at base | **A script run by hand in this plan,** not a gate step. | A gate step now |
| V19 | Running the change | **One shared script, `verify-run.sh`, that starts an application, waits, makes a request and stops it; and a thin `verify` overlay skill for elixir, rails and static** behind `--with-skills` (decision 0004). The gate quotes its evidence; the verdict is unchanged. The rails start line is read on a real application only if the owner offers one. | All six stacks, or none |
| V20 | The commit stamp | **Settled:** every commit the commit skill writes ends with one `Verified:` trailer, and a commit gate ships with modes `off` (default), `observe`, `enforce`. | — |
| V21 | The project for the run | **Settled:** `~/code/office_bestie`, which is in active development in another window. The run therefore uses a clone under `~/.cache/`, never a worktree of the live repository, under the ten lines of §5. | — |
| V22 | Version | **5.4.0.** Nothing is renamed or removed; every new check is optional or in observe mode. | — |
| V23 | Budget | **About $55 to $80, all of it in Sprint 35** (§4), every paid run its own yes. | Drop the with-and-without arms for V16 and the two second-round cases: about $10 less |
| V24 | Housekeeping, each its own yes, by rule 26 | The seven sprint branches after their merges; the owner's cache to 5.4.0 after the tag; scratch clones, worktrees and kept traces after they are read. | — |
| V25 | A smoke run with no model | **`smoke.sh --no-model` and `--only`, the plan's first task.** Rule 33 needs it: the suite has no such switch today. | Skip the smoke suite until Sprint 35 |
| V26 | The goldfish at each sprint's spec | **Keep it.** It runs inside the working session, once per spec, and is the cheapest place to catch a requirement nobody can test. | "No goldfish" for these seven specs |

---

## 3. What we know, and what we must check

Known at `5367060`, each read from the source on 2026-11-17:

- `scripts/smoke.sh` takes no argument and reads one switch, `SMOKE_KEEP`. Its `ask` helper
  (`:54-55`) and about a dozen other lines start `claude`; the first is at `:65` and the ship
  gate's is at `:1076`.
- `spec-check.sh:170-179` collects citations with one `git grep` that leaves out only `.shipkit/`,
  `docs/` and `*.md`. A comment in implementation code counts.
- `briefing.sh:81` reads `spec-check`'s last line with a pattern anchored at both ends. Any new
  line must come before the summary, and the summary's form must not change.
- `ship/SKILL.md:41-50` is the eight-step table. Step 5 names no command (`:47`). The test command
  comes "from the project's `CLAUDE.md`" (`:64-67`). The cleanup removes every
  `shipkit-ship-*.out` under one shared directory (`:108-109`).
- `brief-verify.sh:76` and `reviewer.md:46-50` treat the spec's own folder as always allowed, so
  an edit to `spec.md` on the branch is never listed.
- The acceptance stamp names a commit that does not hold the spec. On the 5.2 run the stamp read
  `179f99d` and `spec.md` was first committed in `8f2dbb4` (`field-notes-5.2.md` §7). A diff
  against the stamped commit therefore cannot be the baseline.
- On the same run, T1's tests cited REQ-5 and REQ-6 and passed, `spec-check` stopped listing them
  as pending, and none of the three surfaces called the new function. Only the reviewer's reading
  caught it (§8, §9). On day two the same tree got different marks (§9, "Day two").
- That run used a worktree of the owner's repository. It left a branch and a worktree registration
  inside the live repository (§9, "Day two": "the branch at `ee9b06b`, the worktree's
  registration"). §5 changes that to a clone.
- `reviewer.md` reads the spec, the design, the tasks and the diff. It reads no earlier report.
- `hooks/hooks.json` holds `SessionStart` and one `PreToolUse` command (`:36-47`).
  `guard-commit.sh:23-27` reads the pending call as JSON on stdin and leaves at once for anything
  that is not a `git commit`.
- `scripts/evals.sh:47-49` passes no `--keep-temp`, so a release run keeps no trace. The history
  says so at least five times ("The run kept no traces").
- The 5.2.0 release run's result file is still on this machine, at
  `~/.cache/shipkit-rel-5.2.0/aggregate-result.json`: 65 cases, each with its runs and
  aggregates, and the run's cost. The ledger's fields can be read from it for nothing.
- `plugins/shipkit/evals/` is 204,747 bytes: `fixtures/` 73,906, `README.md` 24,457. A reviewer
  case costs about 1,116 bytes beside the shared `lib/review-fixture.sh` (6,078).
- In that README the `## Cases` section is 10,638 bytes and the `with-rule.sh` section 3,716.
  Smoke checks 54, 57 and 58 read other paragraphs of the file, and two of them use the
  `## Cases` heading as the end of the range they read. The heading has to stay; the table under
  it can move.
- `portfolio-digest.sh:139-141` already tallies escapes by cause for 30 days. This plan adds
  nothing there.
- This repository has no `.shipkit/escapes/`. Its misses are in the field notes and the ROADMAP.
- `commit/SKILL.md:35-48` is the message body: What, Why, How, Test plan. It has no trailer.
- `setup/SKILL.md:138-139` writes `mise exec --` into `TEST_COMMAND`; the elixir append carries it
  on two lines (`stacks/elixir/CLAUDE.md.append:22-23`). `users-machine/design.md`'s second record
  chose that, and it stays.
- `lint.py:585` says the evals ceiling is "192 KB"; the constant at `:600` is 204,800.
- The three always-on rules are 1,742 + 722 + 535 = 2,999 bytes. This plan adds none.

To check first. The first eight are free and belong to the build; the last four need a session or
the owner's project, so Sprint 35 reads them.

| Claim | Needed by | If false |
|---|---|---|
| One `git grep` that also prints file names keeps fifty specs under 1 s (smoke check 30) | S29-T3 | Only specs with a `> Tests:` line pay for the file names |
| `git log` finds, for each of the 31 specs, the commit in which its `Status` first read `open` | S29-T5 | The baseline is the first commit that added `spec.md` |
| `install-stack.sh` receives the test command for every stack that has one | S30-T1 | Setup's skill writes the record itself, after the installer, in Sprint 35 |
| The kept 5.2.0 result file holds passes, runs and cost for each case | S31-T1 | The ledger takes what the file has; the rest is filled from traces by `trace-tools.sh` |
| Eleven new cases fit in the room S31-T4 makes, at about 1,200 bytes a reviewer case | S32-T1 | Move the README's "What graders can check" (2,871 bytes) as well; then fewer cases, the held-out pair kept first |
| Hypothesis runs under `uv run --with hypothesis` and installs in CI | S33-T3 | V17's other option |
| The current hook documentation says what the `PreToolUse` JSON carries | S34-T2 | The gate counts blocks in its own log within thirty minutes; S35-T1 reads a captured call |
| A static site, served from a folder, starts and answers through `verify-run.sh` ten times in ten | S34-T1 | The script is fixed before any skill is written around it |
| The last tag's plugin loads with `--plugin-dir` from a git worktree of that tag | S35-T1 | A plain copy from `git archive` of the tag |
| `--keep-temp` on the full run leaves traces a laptop can hold | S35-T-REL | Traces kept for failing runs only |
| The owner's project builds and tests in a fresh clone, on its pinned toolchain as installed | S35-T5 | The owner's word: another project, or the run on a generated fixture |
| A Phoenix application starts in the test environment on the run's own database and answers a request | S35-T5 | The elixir `verify` block reads "could not run", with the reason |

---

## 4. The seven sprints at a glance

| Sprint | Branch | Name | Sizes | Paid | What the owner gets |
|---|---|---|---|---|---|
| 29 | `sprint-29/honest-evidence` | What the evidence says | S S S M M S | no | A smoke run that costs nothing; the count of tested requirements; citations that count only in tests; skipped tests and edited requirements named |
| 30 | `sprint-30/gate-as-software` | The gate as software | S M L M M | no | Drift counted on paths that start or end with "t"; the gate's commands as one script; one test command; reports tied to commits; a judge the change cannot edit |
| 31 | `sprint-31/numbers-as-data` | Numbers a script can read | M M M S S | no | An eval ledger; the flake rule, and a briefing quick enough for CI's runner; cases chosen by the diff; room for new cases |
| 32 | `sprint-32/misses-to-checks` | Misses become checks | L M L M | no | Eleven cases from real misses, two held out; a checks file; the reviewer's and the escape skill's new text, written and waiting |
| 33 | `sprint-33/tests-worth-having` | Tests worth having | M S M L | no | Probes for test kinds; property tests on shipkit's parsers; a red-at-base script |
| 34 | `sprint-34/running-the-change` | Running the change, and the prune | XL L M | no | A script that starts and checks an application; a commit gate; the checks pruned before anything is paid for |
| 35 | `sprint-35/sixth-run` | Switch on, measure, release 5.4.0 | S L L M L S | **all of it** | The waiting text applied with numbers; the loop on a real project; one release |

Budget, by rule 15, **all in Sprint 35**. These are estimates from the history's own prices:
about $0.10 to $0.17 a reviewer or goldfish run, $0.30 to $0.50 a headless gate, $21.25 for the
65-case run at 5.2.0, $2 for the nine steps of the 5.2 run. The history gives no price for the
smoke suite; the figure below is my estimate from its seven `sonnet` sessions and about fifteen
`haiku` calls.

| Step | Runs | About |
|---|---|---|
| S35-T1 | Two short sessions: the tag's plugin loads; one hook call captured | $0.10 |
| S35-T2 | The baselines, one batch: seven reviewer cases × 5; two second-round cases × 5; one checks case × 5; one escape case × 3; three test-kind probes × 5; one migration probe × 3; `hello` × 10; `intake/limit` × 10; two smoke checks × 10 on `haiku` | $14–18 |
| S35-T3 | The after-runs, only for text that was applied: up to the same reviewer, second-round, checks, escape, test-kind and migration runs; three gates on the fixture; the `verify` skill × 3 on three stacks; five commits through the commit skill | $10–17 |
| S35-T4 | The full smoke suite, once | $3–4 |
| S35-T5 | The run, with the gate on two days | $2–8 |
| S35-T-REL | The release run, about 78 cases less the prune's cuts; nine gates | $27–31 |
| Total | | $56–78, one release |

---

## 5. The owner's project is in use (rule 35)

`~/code/office_bestie` is being developed in another window while this plan runs. Sprints 29 to 34
never go near it. Sprint 35's run does, under these ten lines, each of which the run's notes read
back as held or not held:

1. **A clone, not a worktree.** `git clone --no-hardlinks` from the live repository's path into
   `~/.cache/shipkit-real-run-7`. A clone only reads the source. A worktree writes a registration
   and a branch into the live repository's `.git`, which the 5.2 run did. Before the clone, the
   owner's standing check for phased-out repositories is made.
2. **No way back.** The clone's remote is removed as soon as it exists, so nothing can be pushed
   or fetched into the live repository by mistake. Nothing is pushed anywhere.
3. **No command that writes runs in the live checkout.** The one read the run needs there is the
   clone itself. If a status is ever needed, it is taken with `GIT_OPTIONAL_LOCKS=0`, so git does
   not rewrite the live index.
4. **Its own dependencies and build output.** `deps/` and `_build/` are fetched and compiled
   inside the clone. Nothing is linked to the live checkout's folders: a linked `_build/` would
   let the run's compiler write into the owner's.
5. **Its own database.** Every step runs in the test environment with
   `MIX_TEST_PARTITION=_shipkit7`. The development database is never opened. The `verify` step
   starts the application that way too, or is recorded as "could not run".
6. **Its own port.** `verify-run.sh` asks the system for a free port. It never assumes 4000.
7. **The toolchain as installed.** `mise exec --` runs what the clone's `.tool-versions` pins. If
   that version is not installed, the run stops and asks; it installs nothing.
8. **No change to what the other window loads.** Every session of the run uses `--plugin-dir` at
   the shipkit checkout. The installed plugin stays at 5.3.0 until the owner says (V24), so the
   other window's sessions keep the plugin they started with. `SHIPKIT_COMMIT_GATE` is set only on
   the run's own commands, never in a shell profile.
9. **The owner picks the time.** The run compiles the project and runs its suite several times.
   It starts on the owner's word and can be stopped between any two steps; each step's output is
   copied out as it ends, so a stop loses nothing.
10. **Removal on a yes.** The clone and the `_shipkit7` database are looked at, then removed, each
    on the owner's yes. Nothing else exists to remove.

---

## Sprint 29 — What the evidence says (untagged, no paid step)

**Goal:** the suite can be run for nothing, and everything the gate already knows about how well a
spec is proven is printed by a script.

### S29-T0 — Write the sprint spec
- **Files:** `.shipkit/specs/honest-evidence/`, this plan's status line.
- **Subtasks:**
  1. **Intake and spec with the shipped skills** (rule 9): `/shipkit:intake`, then `/shipkit:spec
     honest-evidence`. The goldfish reads it cold at the design gate (V26).
  2. **Read every `shall` against rules 11 and 27:** no requirement names its own gate, the
     release or anything after it.
  3. **Split the tasks in two.** Build tasks belong to this sprint. Tasks that change what a
     model reads, or that need a paid run, are written now and left unticked for Sprint 35 (rules
     33 and 34). The design holds the exact text each of those will apply.
  4. **Give the spec a `> Tests:` line by hand,** as the first user of S29-T3.
- **Done when:** `spec-check --as-open` 0 gaps on the draft; lint 0/0; the owner's approval of the
  spec in the thread; the approval line at the top of this file, in the same commit.

Every later sprint's T0 follows these four subtasks, with its own folder.

### S29-T1 — A smoke run that starts no model (S, V25)
- **Why:** rule 33. The suite takes ten minutes and makes model calls, and it has no way to leave
  them out. Without this task the build sprints would merge with no smoke run at all. PR #21 once
  merged that way and `main` was red for eight days, on a check that needs no model.
- **Files:** `scripts/smoke.sh`.
- **Subtasks:**
  1. **`--no-model`.** Every check that starts `claude` is skipped and printed as `SKIP  [model]
     <name>`. One guard wraps the `ask` helper and each direct call, so a new model check cannot
     forget it.
  2. **`--only <name>[,<name>]`** runs the named checks and the ones they need (check 2 needs
     check 1). Sprint 35 uses it to run one failed check again after its fix (rule 30).
  3. **The summary counts all three:** `smoke: N passed, M skipped (model), 0 failed`.
  4. **`claude` is required only when a model check will run.** With `--no-model` the suite passes
     on a `PATH` that has no `claude` at all.
  5. **The default run is unchanged.** With no argument every check runs as today; the diff is
     read for that, and Sprint 35's full run confirms it.
  6. **Added while building (recorded 2026-11-18): check 30's timing reads CPU time.** This was
     S31-T2's subtask 2. It moved here because the check failed the first model-free run; S31-T2
     says why and what is left there.
- **Done when:** `sh scripts/smoke.sh --no-model` passes with `claude` taken off the `PATH`; the
  skipped names are in the commit's test plan; the script is clean under `sh -n`.

### S29-T2 — A script counts how much was tested (S)
- **Why:** `READY` hides the mix. At 5.2.0 the `fifth-run` gate read `READY` with every one of 15
  requirements waived and read, not tested (`eval-history.md`, "Release run 5.2.0"). The report
  holds the count, but below the table, as prose.
- **Files:** `plugins/shipkit/scripts/spec-check.sh`, `scripts/smoke.sh`.
- **Subtasks:**
  1. **`spec-check` prints one `EVIDENCE` line per spec,** before its summary line:
     `EVIDENCE <slug> tested=<n> waived=<n> uncited=<n>`. It is information, like `WAIVED`; the
     exit status and the summary's form do not change (`briefing.sh:81` reads the summary).
  2. **Smoke checks, written first, red:** two tested and one waived prints the right line; a
     fully waived fixture prints `tested=0`; the briefing still reads the gap count.
  3. **Waiting for Sprint 35, written into the design:** the report template's second `>` line,
     `> Evidence: 2 of 3 requirements have a cited test; 1 read only ([untested]).`, copied from
     the `EVIDENCE` line; and the skill's closing instruction, which names that line and says in
     words when `tested=0`.
- **Done when:** the checks pass; `spec-check` 0 gaps on every spec here; check 30's timing holds.

### S29-T3 — A citation counts only where the spec says its tests live (S)
- **Why:** any non-Markdown file counts today. Two live citations in this repository are comments
  (§0). In a user's project a comment in `app/` satisfies "every shipped requirement has a cited
  test".
- **Files:** `plugins/shipkit/scripts/spec-check.sh`, `scripts/smoke.sh`, `GUIDE.md`.
- **Subtasks:**
  1. **The check first:** time one `git grep` that keeps file names on the fifty-spec fixture of
     smoke check 30.
  2. **`spec-check` reads an optional `> Tests: a/, b/` line** from `spec.md`, with `> Paths:`'s
     grammar. With it, a citation counts only in a file under one of those paths. Without it,
     today's rule holds, so all 31 specs here read as before.
  3. **A citation outside those paths is named:** `CITED-ELSEWHERE <slug> REQ-N <file>`. The
     requirement is then `MISSING-TEST` or `PENDING-TEST` as if it had no citation.
  4. **Smoke checks, written first, red:** a citation under the named path counts; one only in
     `app/x.py` gives `CITED-ELSEWHERE` and `MISSING-TEST`; a spec with no line behaves as today.
  5. **Waiting for Sprint 35:** the spec skill asks for the line where it asks for `Paths` (Q1,
     step 5), and the reference file documents it as the fourth line scripts read.
- **Done when:** the checks pass; every spec here still reads 0 gaps.

### S29-T4 — A citation in a skipped test is named (M)
- **Why:** a requirement cited in a test that never runs passes `spec-check`, the suite exits 0,
  and the gate says `READY`. The 5.2 run's suite reported 12 skipped and 14 excluded; nothing asked
  whether a cited test was among them.
- **Files:** `plugins/shipkit/scripts/spec-check.sh`, `scripts/smoke.sh`, `GUIDE.md`.
- **Subtasks:**
  1. **One list of skip markers,** in the script, for the stacks shipkit has overlays for: ExUnit
     (`@tag :skip`, `@moduletag :skip`), RSpec and Minitest (`skip`, `pending`, `xit`,
     `xdescribe`), Jest and Vitest (`it.skip`, `test.skip`, `describe.skip`, `xit`), pytest and
     unittest (`@pytest.mark.skip`, `@unittest.skip`, `pytest.skip(`, `xfail`), Go (`t.Skip(`).
  2. **The rule:** a marker on the citation's line, or within three lines either side of it,
     prints `SKIPPED-CITE <slug> REQ-N <file>:<line>`.
  3. **Observe mode (rule 29, V4):** the line is information and no exit status changes. The
     decision record says it becomes a gap when the real run (S35-T5) reads it with no false
     positive, and that a requirement whose every citation is skipped then reads `MISSING-TEST`.
  4. **The limit, said in the header:** a test left out by configuration, such as an ExUnit tag
     excluded in `test_helper.exs`, has no marker near it and is not seen.
  5. **Smoke checks, written first, red:** one fixture per framework with a skipped citing test
     gives the line; the same test not skipped gives none; the word "skip" in an unrelated comment
     ten lines away gives none.
- **Done when:** the checks pass, both sides for each framework; 0 gaps here.

### S29-T5 — A requirement edited on the branch that is judged by it (M)
- **Why:** "If a change can modify the check that judges it, the check is broken" (the article).
  The spec is shipkit's check. A branch can weaken a requirement or add `[untested: …]` to it, and
  neither `brief-verify.sh` nor the reviewer lists the edit (§3). Such an edit is often right, as
  when the goldfish finds a gap or an escape adds a requirement. It must be visible, not blocked.
- **Files:** `plugins/shipkit/scripts/spec-diff.sh` (new), `plugins/shipkit/scripts/brief-verify.sh`,
  `scripts/smoke.sh`, `GUIDE.md`.
- **Subtasks:**
  1. **The check first:** on this repository's 31 specs, find for each the commit in which its
     `Status` first read `open`.
  2. **`spec-diff.sh <project> <slug> [base]`** compares the requirements now with a baseline. The
     baseline is `spec.md` at the base ref when it exists there; otherwise the first commit after
     the base in which the spec's `Status` reads `open`; otherwise the line `NO-BASELINE <slug>`.
     The stamped commit is not used, for the reason in §3.
  3. **Its lines:** `REQ-CHANGED`, `REQ-ADDED`, `REQ-REMOVED`, and `WAIVER-ADDED` for a requirement
     that gained `[untested:` since the baseline. Requirement text is read with the same awk that
     `brief.sh` uses, so the two cannot disagree about what a requirement is. Exit 0 when nothing
     differs, 1 when something does, 64 on wrong usage.
  4. **`brief-verify.sh` prints `SPEC-EDITED <file>`** when the difference from the task's base
     touches its own spec's `spec.md` or `design.md`. Information; the exit status is unchanged,
     and ticking `tasks.md` prints nothing.
  5. **Smoke checks, written first, red:** a weakened requirement; an added waiver; a new
     requirement; a spec first committed on the branch as `open` and then edited; a spec with no
     `open` commit; an untouched spec, which prints nothing.
  6. **Waiting for Sprint 35:** the report's block "Requirements changed on this branch" under
     step 1's evidence, and the question about `Status: shipped` listing them, so the owner's yes
     is given knowing what changed. No step's result depends on it (V5).
- **Done when:** the checks pass; the script is clean under `sh -n`; `spec-diff.sh` on each spec
  here against its own first-`open` commit runs without error.

### S29-T6 — Smoke checks that only read a prompt's wording are labelled (S)
- **Why:** some of this repository's "cited tests" assert that a skill's Markdown contains a
  sentence. Check 76 proves `run-again/REQ-15`, that the gate retries a reviewer with no verdict,
  by finding three phrases in `ship/SKILL.md`. That detects a change of wording, not of behaviour,
  and the suite's total does not tell the two apart.
- **Files:** `scripts/smoke.sh`, `docs/design/smoke-audit-5.4.md` (new).
- **Subtasks:**
  1. **A second pass function,** `passt`, for an assertion that reads only the text of a skill,
     agent or rule. It prints `PASS  [text] …`.
  2. **Every such assertion moves to it.** The comments already name at least four ("the text, no
     claude needed"); the task reads all 236 pass calls and classifies each.
  3. **The summary line counts them** beside the skipped ones.
  4. **The audit file** lists each text-only assertion with the requirement it cites and whether a
     behaviour check or an eval case also covers that requirement. It is S34-T3's input. Nothing is
     cut here.
- **Done when:** the suite's summary prints the count; the audit has a row for every `passt`.

### S29-T-MERGE — Merge, untagged
- The exit checklist's ten free lines. No tag; the owner's cache untouched.

---

## Sprint 30 — The gate as software (untagged, no paid step)

**Goal:** the parts of the gate that are commands exist as one command, tested without a model,
and the judge for this repository's own gates is one a branch cannot edit. The script pays three
open ROADMAP items once Sprint 35 wires it in: step 5 names no command, two gates share one
scratch path, and the gate runs the failing test command first.

### S30-T0 — Write the sprint spec
- As S29-T0, `.shipkit/specs/gate-as-software/`. Decision 0007 is drafted here for T4.

### S30-T0b — The briefing's `> Paths:` trim keeps the letter "t" (S)
- **Why:** found in Sprint 29 and added on the owner's yes of 2026-11-18, as the sprint's first
  task after its spec. `session-start.sh:275` trims each entry of a spec's `> Paths:` line with
  `sed 's/^[ \t]*//; s/[ \t]*$//'`. BSD sed reads `[ \t]` as a space, a backslash or the letter
  t, so an entry that starts or ends with "t" loses it: on macOS `tests/billing/` becomes
  `ests/billing/`. Drift is then counted on a path that does not exist, the count is 0, and the
  spec never reads as stale, against `spec-contract/REQ-16`. Nothing showed it: no spec in this
  repository has such an entry, and check 21's fixture uses `a/, docs/`. It is the only `sed`
  under `plugins/` and `scripts/` with this pattern; the others are `awk`, where `\t` is a tab.
- **Files:** `plugins/shipkit/scripts/session-start.sh`, `scripts/smoke.sh`.
- **Subtasks:**
  1. **A smoke check, written first, red:** beside check 21's cases, an open spec whose
     `> Paths:` entries start and end with "t" (`tests/`, `notes.txt`), twenty commits that touch
     only those paths, and the hook's line "20 commits have touched its paths since it was
     accepted". It cites `spec-contract/REQ-16`, which is already written and which the code does
     not meet. It is red on macOS before the fix; GNU sed reads `\t` as a tab.
  2. **The fix:** `[[:space:]]` in place of `[ \t]` in both expressions, as `spec-check.sh`
     already reads its `> Tests:` line.
  3. **Rule 34 holds:** the file is a script, and nothing a model reads changes.
- **Done when:** the new check fails before the fix and passes after it; check 21's other cases
  and check 30's timing still pass.

### S30-T1 — One test command (M)
- **Why:** on the 5.2 run the project's `CLAUDE.md` held two test commands. The spec skill copied
  the one that exits 1 into every `Done when`, the brief handed it to the agent, and the gate ran
  it first on both days (`field-notes-5.2.md` §6.1, §7.1, §9.1). Setup had written the one that
  works, and nothing that needed it read it.
- **Files:** `plugins/shipkit/scripts/test-command.sh` (new), `plugins/shipkit/scripts/install-stack.sh`,
  `plugins/shipkit/scripts/lib-manifest.sh`, `scripts/smoke.sh`, `GUIDE.md`.
- **Subtasks:**
  1. **The check first:** read how `install-stack.sh` receives `TEST_COMMAND` for each stack, and
     what a project with no stack overlay gets.
  2. **The installer records the command** it substituted, in one line of a file beside the
     manifest under `.claude/rules/shipkit/`. The manifest lists the file, so `/shipkit:setup
     remove` takes it out with the rest.
  3. **`test-command.sh <project>` prints that line.** No record: exit 1 and "no test command
     recorded; run /shipkit:setup, or pass one". It never reads `CLAUDE.md`.
  4. **`users-machine`'s second record stays.** Its two lines in `CLAUDE.md` are for people; this
     task takes the gate and the tasks off them, and the sprint's design says so.
  5. **Smoke checks, written first, red:** an install records the command, prefix included; the
     script prints it; a project with two commands in `CLAUDE.md` still gets the recorded one; no
     record exits 1; `remove` deletes the file.
  6. **Waiting for Sprint 35:** the spec skill writes the script's output into each `Done when`
     (Q3, step 2), and asks once when there is no record.
- **Done when:** the checks pass.

### S30-T2 — `ship-check.sh`: the gate's commands, run by a command (L)
- **Why:** five of the eight steps are commands with an exit code. Today a model runs each one,
  captures it to a file and pastes it back. The skill spends a page on how not to misreport
  (`ship/SKILL.md:54-59`) because that is the risk. The article's point applies: once a check is
  software it runs without tokens and cannot be paraphrased.
- **Files:** `plugins/shipkit/scripts/ship-check.sh` (new), `scripts/smoke.sh`, `GUIDE.md`.
- **Subtasks:**
  1. **Usage:** `ship-check.sh <project> <slug> [base] [--test '<command>']`. It makes its own
     scratch directory with `mktemp -d`, prints that path first, and writes one evidence file
     there.
  2. **It captures the tree first** (`git status --porcelain`), before it runs anything, as the
     skill's "Before step 1" does now.
  3. **Step 1:** `spec-check.sh <slug> --as-shipped`, and `spec-diff.sh` beside it.
  4. **Step 2:** the test command, from `--test` or from `test-command.sh`, run once, its output
     to a file and its exit code recorded. Neither source: `FAIL: no test command known`.
  5. **Step 3:** the unticked tasks, with `git grep -n --untracked`.
  6. **Step 5's list:** the migration files in `git diff --name-only <base>...HEAD`, matched in awk
     against the six patterns the skill names. None: `PASS`. Some: `NEEDS-READING`, and the model
     still judges whether each has a rollback.
  7. **Step 7:** the first capture, less an earlier report for this slug.
  8. **Step 8:** `decision-check.sh --run`. The safety note in that script stands: the commands
     are the repository's, and this script is never called from a hook.
  9. **The evidence form:** for each step the exact command, `exit N`, the last twenty lines of
     output, and `result: PASS | FAIL | NEEDS-READING — <reason>`.
  10. **`ship-check.sh --clean <dir>`** removes a scratch directory, and only one whose name
      matches the template the script itself makes.
  11. **Smoke checks, written first, red, none needing a model:** a complete fixture gives five
      `PASS` results; an unticked task fails step 3; a dirty tree fails step 7; a failing test
      command fails step 2 with its exit code; a migration file is listed; two runs at once get two
      directories and neither removes the other's; `--clean` refuses a path it did not make.
  12. **Waiting for Sprint 35:** the ship skill rewritten around the script. It runs the script;
      starts the reviewer with the slug and the base ref and nothing else, and writes its reply
      into the scratch directory the script printed; judges step 5's rollbacks and step 6; builds
      the report by pasting the script's blocks; cleans up through `--clean`. Check 29 is extended
      there too: each of the five blocks in the model's report equals the script's own block for
      the same tree. Pasted, not retyped.
- **Done when:** the model-free checks pass; the script is clean under `sh -n`.

### S30-T3 — A `READY` report is tied to a commit (M)
- **Why:** "A passing review on an out-of-date commit means nothing" (the article). A report
  records the commit it checked, and nothing reads that again. Work can land after the gate and
  before the spec is called shipped.
- **Files:** `plugins/shipkit/scripts/release-check.sh` (new), `.github/workflows/lint.yml`,
  `scripts/smoke.sh`, `GUIDE.md`.
- **Subtasks:**
  1. **For each spec whose `Status` is `shipped`,** find the newest report for its slug whose
     first line is `READY`, and the commit that report names.
  2. **Three findings:** `NO-REPORT <slug>` when there is none; `ORPHAN-REPORT <slug>` when the
     commit is not an ancestor of `HEAD`; `CHANGED-AFTER-GATE <slug> <n>` when `n` commits touched
     the spec's `Paths` between the report's commit and the commit that set `Status: shipped`.
  3. **Observe mode (rule 29, V8):** it prints and exits 0. `--enforce` exits 1 on any finding.
     The record says it turns on when it has run on two releases with every finding explained.
  4. **CI shows it:** one more step in `lint.yml`, with the full history fetched so ancestry can be
     read.
  5. **The first reading of this repository goes in the sprint's notes:** it has 31 shipped specs
     and 26 reports, so `NO-REPORT` is expected for the five specs that predate the gate (3.5.0).
  6. **Smoke checks, written first, red:** a clean fixture prints nothing; a report on an abandoned
     branch; a commit under `Paths` after the report; a shipped spec with no report.
- **Done when:** the checks pass; CI green with the new step.

### S30-T4 — A change does not judge itself (M, V9)
- **Why:** rule 28. In this repository a branch that changes `ship/SKILL.md`, `reviewer.md` or
  `spec-check.sh` has been gated by its own copies of them, and CI runs the branch's `lint.py` and
  `spec-check.sh` on the branch.
- **Files:** `scripts/judge.sh` (new), `.github/workflows/lint.yml`,
  `.shipkit/decisions/0007-a-change-does-not-judge-itself.md` (new), `scripts/smoke.sh`.
- **Subtasks:**
  1. **`scripts/judge.sh <slug> <base>`** makes a scratch worktree of the last tag
     (`git describe --tags --abbrev=0`) and prints the headless `/shipkit:ship` command that loads
     the plugin from it. It runs that command only with `--yes`, since the run is paid, and it
     removes the worktree it made. The worktree is of this repository, not the owner's project.
  2. **CI runs the last tag's `spec-check.sh`** on the pull request's tree, beside the branch's
     own. Both must exit 0, so a pull request cannot pass by weakening the script.
  3. **Decision 0007,** five parts. The reversal condition is an event: the last tag's gate fails
     a spec at two releases running for a reason that is only the tag's age, such as a line it
     cannot read. The judge then becomes the tip of `main`.
  4. **Smoke checks, written first, red:** `judge.sh` without `--yes` prints the command and runs
     nothing; it names the last tag; a worktree it did not make is not removed.
  5. **Waiting for Sprint 35:** the check that the tag's plugin loads from that worktree, and the
     judge's first use.
- **Done when:** the checks pass; 0007 has its five parts; CI green.

### S30-T-MERGE — Merge, untagged
- The exit checklist, with line 8 for the first time.

---

## Sprint 31 — Numbers a script can read (untagged, no paid step)

**Goal:** an eval result is a row, not a paragraph; the cases for a change are chosen by the
change; and there is room for the cases Sprint 32 writes.

### S31-T0 — Write the sprint spec
- As S29-T0, `.shipkit/specs/numbers-as-data/`.

### S31-T1 — The eval ledger (M)
- **Why:** every release's results are prose. Whether a case has been below full score twice, or
  how often it passes over five releases, is found by reading. No `Fired-if` command can read a
  paragraph, which is one reason 130 of 137 are `manual`.
- **Files:** `scripts/evals.sh`, `scripts/evals-ledger.sh` (new), `docs/design/eval-ledger.tsv`
  (new), `docs/design/eval-history.md`, `scripts/smoke.sh`.
- **Subtasks:**
  1. **The check first, free:** read the kept 5.2.0 result file (§3) for the fields each case
     holds.
  2. **The ledger's columns:** date, version, commit, Claude Code version, model, case, set
     (`tune`, `holdout` or `watch`), passed, runs, threshold, cost, source.
  3. **`evals-ledger.sh <output-dir>`** appends one row per case from a finished run, and refuses a
     row it already holds for the same commit, case and date.
  4. **`evals.sh` stops being a bare `exec`:** it runs the tool, appends the rows, and returns the
     tool's exit status. It keeps traces by default; `EVALS_KEEP=0` turns that off. The change is
     tested with a stand-in for the tool, so no run is paid for here.
  5. **Two queries:** `--below-full <n>` lists cases below full score in the last `n` release
     runs; `--rate <case> [--last <k>]` prints passes over runs across the last `k`. The second
     gives a case fifteen runs of evidence where one release gives three.
  6. **Backfill:** 5.2.0 from its result file, marked `result-file`; 5.1.0 from `eval-history.md`,
     marked `history`, each number read against the page (rule 25).
  7. **Smoke checks, written first, red:** a canned result file yields the right rows; a second
     append adds none; both queries answer on a seeded ledger.
- **Done when:** the checks pass; the ledger holds 5.1.0 and 5.2.0.

### S31-T2 — The flake rule, and what can be fixed for nothing (M)
- **Why:** "If your tests are flaky you'll train the agent to run them again rather than fixing
  the failing code" (the article). The history shows the habit: `hello` at 2 of 3 in 5.1.0 and
  5.2.0, `intake/limit` at 2 of 3 "its shape since 4.9.0", cases re-run alone until they pass, and
  an exit checklist that says to re-run a failing `haiku` check.
- **Files:** `docs/design/eval-history.md`, `scripts/smoke.sh`, and for subtask 5
  `plugins/shipkit/scripts/briefing.sh`, `plugins/shipkit/scripts/spec-check.sh` and
  `.github/workflows/lint.yml`.
- **Subtasks:**
  1. **Rule 30 is written into `eval-history.md`'s head,** where the next release run reads it.
  2. **The `briefing` timing check: fixed in Sprint 29, not here** (S29-T1, commit `18e0596`;
     recorded 2026-11-18). It read 1.02 s on a 1 s limit while the suite's own load was near 3.5
     (`eval-history.md`, "Release run 5.1.0"), and it failed the first model-free run of Sprint 29
     the same way: 1.0 s on three tries on a busy machine. Left for this sprint it would have
     failed every free run of Sprints 29 and 30. It now measures CPU time, not wall clock, so the
     machine's load cannot fail it. What stays here is this task's done-when, the five passes
     under load. The margin is thin: 0.75 to 0.85 s of CPU against the 1 s limit
     (`.shipkit/specs/honest-evidence/tasks.md`, "Found on the way").
  3. **What the records already say** about the other four is collected in one note: `hello`'s
     failing runs "did not hold the pattern" in the last message; `intake/limit`'s grader counts a
     question with parts as several ("Release run 4.7.0"); and each recorded failure of the
     `agents` and `rules-skip` checks.
  4. **A kit for Sprint 35,** one line per case: the command that runs it ten times with traces
     kept, what to look for in the traces, and the outcomes allowed: a corrected grader (rule 23),
     a changed sentence (on the owner's go, rule 6), or the case deleted with its reason.
  5. **The briefing's gap count made cheap** (added 2026-11-18). The one-second limit is tight
     because the briefing runs the whole of `spec-check.sh` to print one number. On fifty open
     specs on the owner's Mac the briefing costs 0.76 s of CPU, of which `spec-check.sh .` is
     0.66 s, about 2,600 shell commands. CI's macOS runner read 0.96 s and then 1.53 s on the
     same scripts (pull request 40), so the limit is not enforced there for now: the job sets
     `SMOKE_TIMING=report` (`honest-evidence` REQ-41 to REQ-43 and its design's seventh record).
     This subtask cuts what the briefing pays for that number; the sprint's design chooses how,
     and `spec-check.sh`'s own output does not change. The check is written first.
- **Done when:** the timing check passes five times in a row under load, and five times running
  on the CI runner with the switch taken out of the workflow; the note and the kit are in the
  sprint's design.

### S31-T3 — The cases for a diff are chosen by the diff (M)
- **Why:** 5.3.0 ran no case, on a hand reading of which cases read the changed files
  (`eval-history.md`, "Release run 5.3.0"). The article's reliability checklist runs only the
  items whose trigger matches the diff. The same idea lets Sprint 35 measure each group of text
  with only the cases that read it.
- **Files:** `scripts/evals-map.tsv` (new), `scripts/evals-for-diff.sh` (new), `scripts/evals.sh`,
  `scripts/lint.py`, `scripts/smoke.sh`.
- **Subtasks:**
  1. **The map,** one row per case: its name, its set, and the plugin paths whose text reaches it:
     the skill its prompt invokes, the agent it starts, the rule `with-rule.sh` installs, the
     scripts that skill runs. It lives under `scripts/`, outside the evals directory's byte
     ceiling.
  2. **Paths every session reaches** (the hook, `rules/shipkit.md`) are marked `always`. A change
     to one selects the `rules` cases and `hello`; the full run stays the release's.
  3. **`evals-for-diff.sh <base>`** prints the cases whose paths meet `git diff --name-only
     <base>`, and `evals.sh --for-diff <base>` runs them.
  4. **Lint check 19:** every case folder has a row, every row names a case that exists, every
     path in a row exists.
  5. **Smoke checks, written first, red:** a diff that touches `agents/reviewer.md` selects the
     reviewer cases and no other; a diff under `docs/` selects none; a case with no row fails
     lint.
- **Done when:** the checks pass; `evals-for-diff.sh` on this sprint's own diff prints no case.

### S31-T4 — Room for new cases, with no raise (S, V12)
- **Why:** the evals directory has 53 bytes of room. The last case made its own by deleting a
  comment and a `git init` from a fixture (`eval-history.md`, "The noise, before the fix"). Sprint
  32 adds eleven cases, about 15,000 bytes.
- **Files:** `plugins/shipkit/evals/README.md`, `docs/design/eval-cases.md` (new), `scripts/lint.py`,
  `scripts/smoke.sh`.
- **Subtasks:**
  1. **Move the case table** (10,638 bytes) to `docs/design/eval-cases.md`, unchanged, with the
     date it moved, as Sprints 11, 13 and 24 moved their sections. The `## Cases` heading stays,
     with one line under it pointing to the new file, because smoke checks 54 and 57 read up to
     that heading.
  2. **Move the `with-rule.sh` section** (3,716 bytes) the same way. Checks 54 and 57 read the
     paragraphs on path-scoped loading and on protected file names, which stay where they are.
  3. **Read checks 54, 57 and 58 against the moved text.** All three need no model, so
     `--no-model` runs them.
  4. **Correct `lint.py:585`,** which says 192 KB where the limit is 204,800.
  5. **Decision 0005 stands.** The sprint's design records one new cost for its "case against":
     the ceiling has begun to shape test fixtures.
- **Done when:** the directory is at most 190,800 bytes; checks 54, 57 and 58 pass.

### S31-T5 — `Fired-if` commands that read the ledger (S)
- **Why:** a reversal condition about an eval count can now be a command. `run-debts`' condition
  was met three times and nothing fired, because its line was `manual`
  (`machine-sprint-plan.md`, intro).
- **Files:** the decision records and `design.md` files whose clauses name a case and a count;
  `scripts/smoke.sh`.
- **Subtasks:**
  1. **The check first:** count the `manual` records whose clause names an eval case and a number.
     The target for §0's row is set from that count, in the spec.
  2. **Each such record gains a command** in place of `manual`, built on `evals-ledger.sh --rate`.
     Nothing else in the record changes.
  3. **Every new command must read `HOLDS` today** (`decision-check.sh --run`, which starts no
     model), as the spec skill already asks of a new record. One that fires is a finding for the
     owner, not something to reword.
- **Done when:** `decision-check.sh --run` shows no `ERROR` and no new `FIRED` without the owner's
  word; the count of `manual` lines is the target.

### S31-T-MERGE — Merge, untagged
- The exit checklist.

---

## Sprint 32 — Misses become checks (untagged, no paid step)

**Goal:** the cases that grade the reviewer on real misses exist and their graders are proven,
the checks file and its script work, and every sentence the reviewer and the escape skill will
gain is written down, waiting for its baseline.

### S32-T0 — Write the sprint spec
- As S29-T0, `.shipkit/specs/misses-to-checks/`. Its design holds the records for V13, V14 and
  V15, each with the event that reverses it, and the waiting text word for word.

### S32-T1 — Reviewer cases from real misses, two of them held out (L)
- **Why:** the reviewer's four cases are synthetic. The article grades its reviewer on real
  incidents with a one-sentence answer key and keeps its tuning set apart from its test set.
  Shipkit tunes on the cases it reports: `goldfish-gap` went from 0 of 5 to 5 of 5 on the case the
  text was written against (`eval-history.md`, "After the fix").
- **Files:** `plugins/shipkit/evals/reviewer/` (seven new case folders),
  `plugins/shipkit/evals/lib/review-fixture.sh`, `scripts/evals-map.tsv`, `scripts/evals.sh` (its
  citation header), `docs/design/eval-cases.md`, `scripts/smoke.sh`.
- **Subtasks:**
  1. **Five tuning cases,** each one switch on the shared fixture, each with the miss it comes
     from and a one-sentence answer key in its `case.yaml` comment:
     - `helper-only`: the tests cite REQ-2 and pass, but call only a helper; the entry point never
       calls it. From the 5.2 run's REQ-5 and REQ-6. Expected: REQ-2 not `MET`, `VERDICT: FAIL`.
     - `skipped-test`: the citing test is skipped. Expected: `NOT MET`, `FAIL`.
     - `comment-cite`: the only citation is a comment in the implementation. Expected: `NOT MET`,
       `FAIL`.
     - `weakened-req`: the branch rewrote REQ-2 to match what was built. Expected: the reply names
       the edit.
     - `waiver-added`: the branch added `[untested: …]` to REQ-2. Expected: the reply names it.
  2. **Two held-out cases** on a different feature, a notes export in place of refunds, so they
     share no wording with the tuning cases: one `helper-only`, one `skipped-test`. Their set in
     the map is `holdout` (rule 31).
  3. **Each fixture is built and read by hand:** the scaffold runs in a scratch directory and the
     tree it leaves is the one the answer key describes.
  4. **Each grader goes through `node`** with a hand-written reply it must pass and one it must
     fail (rules 18 and 23). This is the whole of the proof this sprint can give, and it is free.
  5. **The candidate sentences, written into the design, not into `reviewer.md`:** a skipped,
     pending or excluded test proves nothing; a citation outside a test is not a test; a
     "Requirements changed on this branch" section that reads `spec-diff.sh`.
  6. **Smoke check:** every reviewer case builds from the shared fixture (check 77 extended).
  7. **Waiting for Sprint 35:** the baseline on today's reviewer, the owner's reading of the
     table, a sentence applied only where the baseline misses, and the after-run. A case that
     already passes gets no text and stays as the watch.
- **Done when:** seven fixtures build; seven graders are shown on both sides; the evals directory
  is at most 204,800 bytes; `reviewer.md` is unchanged.

### S32-T2 — One reviewer, a second round that builds on the first (M, V15)
- **Why:** on the 5.2 run one tree got two readings: REQ-5 and REQ-6 `NOT MET` on day one and
  `CANNOT TELL` on day two, and one decision `followed`, then `partly built`
  (`field-notes-5.2.md` §9). The article's answer is to point each round at the round before, not
  to add a second reviewer.
- **Files:** `plugins/shipkit/evals/reviewer/` (two case folders), `scripts/evals-map.tsv`,
  `scripts/smoke.sh`.
- **Subtasks:**
  1. **Two cases, built and their graders shown both ways:** `second-round`, the same tree with an
     earlier report in `.shipkit/releases/`, whose marks the reply must match; and `stale-met`,
     where the earlier report says `MET` and the code has since been removed, which must read
     `NOT MET`.
  2. **The waiting text, in the design:**
     - the reviewer reads the newest earlier report for the slug, when there is one: only its
       `NOT MET` and `CANNOT TELL` rows, and its decisions marked `contradicted`, `partly built` or
       `not built`. It checks those first;
     - an earlier `MET` is never evidence: every requirement is found again in the code and its
       test;
     - one new line under the table: `Changed since the review of <date>: REQ-5 NOT MET →
       CANNOT TELL — <why>`, or "nothing".
  3. **It is still given two things.** The earlier report is a file in the repository, written by
     the gate. The builder's account is still withheld. The design says so, for the reader who
     remembers "fresh eyes".
  4. **The record's reversal condition:** `stale-met` reads `MET` in one or more of five runs at
     a release run. The reviewer then stops reading earlier reports.
  5. **Waiting for Sprint 35:** five runs of each case before and after the text, and smoke check
     70 (`report-shapes`) learning the new line.
- **Done when:** both fixtures build; both graders are shown on both sides.

### S32-T3 — Checks that a diff triggers (L, V14)
- **Why:** the article keeps a checklist in which each item has a trigger readable from a diff, a
  check, and the incident behind it, and runs only the items whose trigger matches. Shipkit's
  closest thing is a path-scoped rule, which steers the builder. Nothing asks the reviewer about a
  past miss when a diff touches the same ground.
- **Files:** `plugins/shipkit/scripts/checks-match.sh` (new), `plugins/shipkit/evals/reviewer/`
  (one case folder), `.shipkit/checks.md` (new, this repository's own), `scripts/evals-map.tsv`,
  `scripts/smoke.sh`, `GUIDE.md`.
- **Subtasks:**
  1. **The file's form,** `.shipkit/checks.md`: one `## C<n>: <title>` per item with three lines.
     `Trigger:` is `path <glob>[, <glob>]` or `added <pattern>`, where the pattern is matched
     against the lines the diff adds. `Check:` is what to verify, or a command. `From:` is the
     escape or the note it came from.
  2. **`checks-match.sh <project> <base>`** reads the file from the base ref
     (`git show <base>:.shipkit/checks.md`), never from the working tree (rule 28). It prints each
     item whose trigger matches `git diff <base>...HEAD`. No file at the base: nothing, exit 0. A
     check added on a branch therefore takes effect after it merges.
  3. **`checks-match.sh --lint`** fails an item with no trigger, check or source, or a source file
     that does not exist.
  4. **Seed this repository's own file** with four items, each read against its source first
     (rule 25): a grader's pattern changes, so both sides go through `node` (rule 23; the old
     graders failed 15 of 36 correct files); a numeric limit in `lint.py` changes, so the owner's
     yes is cited; a requirement in a release spec names its own gate (rule 27); a text-only smoke
     check is added for a requirement about behaviour (S29-T6).
  5. **One eval case,** `check-triggered`, built and its grader shown both ways: the base holds a
     checks file whose trigger the diff meets and whose check the diff breaks. Expected: the item
     appears as `BROKEN`.
  6. **Smoke checks, written first, red, no model:** a path trigger matches; an `added` trigger
     matches an added line and not a removed one; a checks file that exists only on the branch
     gives nothing; `--lint` fails a broken item.
  7. **Waiting for Sprint 35:** the reviewer runs the script and adds a section, "Checks this diff
     triggered", one row per item: `HELD`, `BROKEN` or `CANNOT TELL`, with `path:line`. Observe
     mode (rule 29): the verdict rule is unchanged, and the record turns it on when two real gates
     in a row report a triggered check with no false `BROKEN`. The report template gains the block.
- **Done when:** the model-free checks pass; the case builds; this repository's file passes
  `--lint`.

### S32-T4 — The second escape of a kind becomes a check (M)
- **Why:** `/shipkit:escape` repairs one spec. The article turns a miss into a rule only when it
  has occurred at least twice and can be identified from a diff. That bar fits shipkit's own rule
  of measuring before keeping.
- **Files:** `plugins/shipkit/evals/escape/` (one case folder), `scripts/evals-map.tsv`,
  `scripts/smoke.sh`.
- **Subtasks:**
  1. **One eval case,** `second-of-a-kind`, built and its grader shown both ways: a fixture with
     one recorded escape and a new report of the same kind. Expected: a proposed check item with a
     trigger and both sources.
  2. **The waiting text, in the design,** one new step after the escape record is written: look
     for an earlier escape with the same cause whose spec's `Paths` overlap this one's; at the
     second, draft one check item whose trigger can be read from a diff, with both escapes on its
     `From:` line; show it; write it to `.shipkit/checks.md` only on a yes. If no trigger can be
     read from a diff, say so and write nothing.
  3. **Waiting for Sprint 35:** three runs before and after. The existing `missing-req` case, a
     first escape, must propose no check either time.
- **Done when:** the fixture builds; the grader is shown on both sides.

### S32-T-MERGE — Merge, untagged
- The exit checklist. Line 10 matters most here: no agent or skill file has changed.

---

## Sprint 33 — Tests worth having (untagged, no paid step)

**Goal:** the probes that will say whether the model picks the right kind of test are ready,
shipkit's own parsers are tested with inputs nobody wrote by hand, and there is a way to show that
a cited test fails without the feature.

### S33-T0 — Write the sprint spec
- As S29-T0, `.shipkit/specs/tests-worth-having/`.

### S33-T1 — Which test proves which requirement: the probe (M, V16)
- **Why:** the article names three kinds worth investing in. An end-to-end test is hard to fool. A
  property test brings edge cases "that aren't created with the same bias as the agent". A
  differential test uses the old system as the oracle. The spec skill says only "behavior-focused",
  and no file in either plugin names the other two. As with every rule line since 4.2.0, no text
  goes in without a number behind it.
- **Files:** `scripts/kind-probe.sh` (new), `scripts/smoke.sh`.
- **Subtasks:**
  1. **A probe outside the eval suite,** like `wait-probe.sh`, so it costs no byte of the evals
     directory. It scaffolds a small project with an accepted spec and design, and prints the
     headless `/shipkit:spec <slug> tasks` command for each run. It runs them only with `--yes`.
  2. **Three requirements, one per kind:** "the balance shall never be negative" (an invariant,
     so a property test); "an exported file shall import to the same records" (a round trip);
     "after the move to the new parser, every stored document shall render as before" (a
     differential test).
  3. **A reader, `--read <dir>`,** that classifies each `tasks.md` by the kind of test its `Test:`
     line names. It is tested on six hand-written `tasks.md` files, two per kind, one naming the
     kind and one not.
  4. **The waiting text, in the design:** a short table for `spec/reference.md`, which loads on
     demand, mapping a requirement's shape to a test kind, and an optional tag at the start of a
     `Test:` line: `[e2e]`, `[property]`, `[differential]`.
  5. **Waiting for Sprint 35:** five runs each; the owner sees the table; text only for a kind
     missed in 2 or more of 5; five runs again; a line stays only if its number moved.
- **Done when:** the scaffold builds; the reader classifies the six files correctly; without
  `--yes` nothing runs.

### S33-T2 — A differential step for the migration plan (S)
- **Why:** differential tests are "particularly effective for large-scale migration use cases"
  (the article). `/shipkit-workflows:migration-plan` plans an upgrade from its changelog and names
  no test of unchanged behaviour.
- **Files:** `scripts/kind-probe.sh` (one more fixture).
- **Subtasks:**
  1. **A fourth probe fixture:** a small project and an upgrade request, with a reader that says
     whether the plan holds a task that runs the old and the new on the same inputs.
  2. **The waiting text, in the design:** one step for the skill. Where behaviour must stay the
     same, the plan's first task is such a test; it normalizes differences that do not matter and
     keeps a list of the differences that are meant. The skill's description stays within 300
     characters.
  3. **Waiting for Sprint 35:** three runs before and three after; the step stays only if the
     after number is above the before number.
- **Done when:** the fixture builds and the reader answers on two hand-written plans.

### S33-T3 — Property and differential tests on shipkit's own parsers (M, V17)
- **Why:** `spec-check.sh` and `brief.sh` each parse `tasks.md` with their own awk. Every smoke
  check feeds them inputs a person thought of. Generated inputs are how the edge cases nobody
  thought of get tried.
- **Files:** `scripts/prop.py` (new), `.github/workflows/lint.yml`, `scripts/lint.sh`.
- **Subtasks:**
  1. **The check first:** Hypothesis under `uv run --with hypothesis`, and its current
     documentation read for how to generate text and how a failing example is replayed.
  2. **Five properties, each on generated `spec.md` and `tasks.md` files:**
     - *Agreement.* On a well-formed task list, `brief.sh` and `spec-check.sh` agree on every
       task's id and files.
     - *No side effect.* `spec-check.sh` changes no file, and two runs print the same lines.
     - *Monotone.* Adding a citation for a requirement never increases the gap count.
     - *Exactly one.* Removing the only citation of a shipped, unwaived requirement adds exactly
       one `MISSING-TEST`.
     - *Round trip.* The requirement `brief.sh` prints equals the block in `spec.md`, byte for
       byte.
  3. **CI runs it,** with a fixed seed so a failure repeats. It needs no model.
  4. **A failing property is a bug.** It is fixed in its own commit with the failing input kept as
     a smoke check, or put to the owner if the fix reaches beyond this task's files.
- **Done when:** the five properties hold, or each failure has its fix or the owner's word; CI
  green; the exit checklist gains line 9.

### S33-T4 — Red at base: a cited test fails without the feature (L, V18)
- **Why:** nothing shows that a new test was ever red. The default workflow says "test before
  code", and the gate takes it on trust. A test that passes on the base tree proves nothing about
  the feature.
- **Files:** `plugins/shipkit/scripts/red-check.sh` (new), `scripts/smoke.sh`, `GUIDE.md`.
- **Subtasks:**
  1. **`red-check.sh <project> <slug> <base> --test '<command>' [--link <dirs>]`:**
     - lists the test files that cite the spec and differ from the base;
     - makes a scratch worktree of the base, of the project it was pointed at;
     - runs the suite there once. If it fails: `BASE-NOT-RUNNABLE`, and no judgment is made;
     - copies the listed test files in, and runs it again;
     - prints `RED-AT-BASE` when that run fails, or `GREEN-AT-BASE <files>` when it passes;
     - removes the worktree it made, on every exit path, and never one it did not make.
  2. **`--link`** names untracked folders, such as `deps`, `_build` or `node_modules`, to link
     into the scratch tree from the project it was pointed at. Nothing is linked by default. On
     the real run the project it is pointed at is the clone, never the live checkout (§5, line 4).
  3. **Not a gate step in this plan.** `ship-check.sh` prints the command as a suggestion. The
     record says it becomes an observed step when the real run shows a right answer within five
     minutes.
  4. **Smoke checks, written first, red, no model:** a test that needs the feature gives
     `RED-AT-BASE`; a test that asserts nothing gives `GREEN-AT-BASE`; a broken base gives
     `BASE-NOT-RUNNABLE`; the worktree is gone after each.
  5. **Waiting for Sprint 35:** its reading on the clone of the owner's project.
- **Done when:** the checks pass.

### S33-T-MERGE — Merge, untagged
- The exit checklist, with line 9 for the first time.

---

## Sprint 34 — Running the change, and the prune (untagged, no paid step)

**Goal:** a script can start an application, check it and stop it; a commit gate exists, switched
off; and the checks are pruned before a dollar is spent running them.

### S34-T0 — Write the sprint spec
- As S29-T0, `.shipkit/specs/running-the-change/`.

### S34-T1 — Running the change: one script, three thin skills (XL, V19)
- **Why:** "Running the app end to end matters more than tests" (the article). The gate runs the
  test command and the reviewer reads. Neither starts the application. The 5.2 run's miss, tests
  green and the feature not wired, is the kind a running application shows. The article also says
  to make the harness "rock solid", which is easier for a script than for a page of instructions.
- **Files:** `plugins/shipkit/scripts/verify-run.sh` (new),
  `plugins/shipkit/stacks/elixir/.claude/skills/verify/SKILL.md`,
  `plugins/shipkit/stacks/rails/.claude/skills/verify/SKILL.md`,
  `plugins/shipkit/stacks/static/.claude/skills/verify/SKILL.md` (all new), `scripts/smoke.sh`,
  `docs/design/context-cost.md`, `GUIDE.md`.
- **Subtasks:**
  1. **`verify-run.sh --start '<command>' --request <path> [--env KEY=VALUE …] [--timeout <s>]`**
     does five things: asks the system for a free port and hands it to the start command; starts
     the application in the background and keeps its process id; polls until it answers or the
     time runs out; makes the request and keeps the status line and the first lines of the body;
     stops the process it started, and that process only.
  2. **Its three outcomes, each a line a report can quote:** `RAN <status> <path>` with the
     excerpt; `NOT-READY after <s> s` with the last lines of the application's own output;
     `EXITED <code>` when the application stopped by itself.
  3. **Reliability, by script, for nothing:** against a folder served as a static site, ten runs
     in a row give the same `RAN` line and leave no process behind. A start command that never
     answers gives `NOT-READY` and leaves no process. One that exits gives `EXITED`.
  4. **Three overlay skills, a few lines each.** Each names its stack's start command (a Phoenix
     server, a Rails server, a static file server), says to call the script with the flow the
     task names, and says to report its line as it stands and never a run it did not make. They
     are new files behind `--with-skills` (decision 0004), which rule 34 allows.
  5. **What each costs:** one description per installed skill in every session of that project.
     `context-cost.sh` shows the bytes before and after, and each description stays within 300
     characters.
  6. **What is and is not shown here.** The script is shown on the static stack. The Phoenix start
     line is read on the clone in Sprint 35, in the test environment (§5, line 5). The Rails start
     line is read on a real application only if the owner offers one; otherwise the release notes
     say "not shown".
  7. **Smoke checks, written first, red, no model:** the three outcomes; no process left after
     any of them; the three skills exist and pass lint; an install without `--with-skills`
     installs none.
  8. **Waiting for Sprint 35:** setup's list of overlay skills names it; the report gains a block
     "Ran the change" with the script's line, in observe mode; a task's `Done when` may name the
     script; three runs per stack with a model, to see the skill used as written.
- **Done when:** ten of ten on the static fixture; the model-free checks pass; the context-cost
  rows are in the design.

### S34-T2 — A commit gate, switched off, and the stamp it will ask for (L, V20)
- **Why:** the article stamps every commit with how it was verified, including "none", so
  unverified commits can be found, and starts its commit gate in observe mode. Shipkit's commit
  skill writes a test plan in prose, which no query can read.
- **Files:** `plugins/shipkit/scripts/commit-gate.sh` (new), `plugins/shipkit/hooks/hooks.json`,
  `scripts/smoke.sh`, `scripts/lint.py`, `GUIDE.md`.
- **Subtasks:**
  1. **The check first, free:** the current hook documentation, for what the `PreToolUse` JSON
     holds: the command text, and an id for the session.
  2. **`commit-gate.sh`,** a second `PreToolUse` command beside the secret guard. It leaves at
     once for any call that is not a `git commit`. Its mode comes from `SHIPKIT_COMMIT_GATE`:
     - `off`, the default: it does nothing;
     - `observe`: a commit whose message has no `Verified:` line adds one row to a log under
       `~/.claude/shipkit/` and goes through;
     - `enforce`: that commit is blocked with one line saying how to add the stamp. `Verified:
       none (<reason>)` passes. After two blocks in a session the next commit passes, so a session
       cannot get stuck.
  3. **Its limits, in its header, as the secret guard's are:** it sees only a message given on the
     command line; a commit from a file, an editor or the owner's own terminal is never blocked.
     On any internal error it exits 0.
  4. **Smoke checks, written first, red, no model:** the hook JSON fed on stdin in each mode; a
     stamped message; an unstamped one; `none` with a reason; the third attempt after two blocks;
     a call that is not a commit.
  5. **The waiting text, in the design:** every commit the commit skill writes ends with one line:
     `Verified: tests (<command> → exit 0)`, `gate (<report file>)`, `brief-verify
     (<slug>/<task>)`, `ran (<evidence>)`, or `none (<reason>)`, written after the result is read
     (rule 24). The guide gains the `git log` line that lists each commit with its stamp, and the
     one that lists those stamped `none`.
  6. **No always-on byte.** The rule will live in the commit skill; `rules/shipkit.md` is
     untouched. With the core plugin alone nothing writes the stamp, which is why the default is
     `off`.
  7. **Waiting for Sprint 35:** the text applied; five commits through the commit skill on a
     fixture, the traces read; one captured hook call, to confirm the documentation.
- **Done when:** the model-free checks pass; lint 0/0 with the second hook command; the always-on
  rules are still 2,999 bytes.

### S34-T3 — Prune the checks before paying to run them (M)
- **Why:** "Test suites, verification steps and .md files only grow if you let them" (the
  article). Shipkit prunes what loads into a session; the 4.0 trim audit never mentions the smoke
  suite, which is 3,276 lines. This plan adds about 34 checks and 11 cases. Every check and case
  cut here is one Sprint 35 does not pay to run.
- **Files:** `docs/design/trim-audit-checks.md` (new), `scripts/smoke.sh`, the eval case folders
  the owner cuts, `scripts/evals-map.tsv`, `docs/design/eval-cases.md`.
- **Subtasks:**
  1. **One row per smoke check and per eval case:** the last release in which it failed on a real
     defect ("never" is an answer), what else covers its requirement, and what it costs in seconds
     or dollars. The ledger's two backfilled releases, the CHANGELOG and S29-T6's audit supply it.
  2. **Candidates:** a check that never failed and whose requirement another check covers; a
     text-only assertion with a behaviour check beside it; a case at full score in every ledger
     row whose rule is also held by a script.
  3. **STOP at each cut for the owner's yes,** as the thinning plan did for skills.
  4. **A cut check's citation moves** to the check that still proves the requirement, so
     `spec-check` stays at 0 gaps. If none does, the check is not cut.
  5. **The release task gains a line:** a prune pass at every release from now on.
- **Done when:** the audit has a row for everything; each cut has its yes in the thread; 0 gaps;
  the model-free suite passes.

### S34-T-MERGE — Merge, untagged
- The exit checklist. After this merge `main` holds every script, case and probe of the plan, and
  no model has been paid to run any of it.

---

## Sprint 35 — Switch on, measure, release 5.4.0 (every paid step)

**Goal:** the waiting text goes in with a number beside each piece, the loop is read on a real
project without disturbing it, and one release ships.

The tasks run in this order. Each paid task starts on its own yes (rule 15), and the order is
chosen so that a bad result early stops the spending that follows it.

### S35-T0 — Write the sprint spec
- As S29-T0, `.shipkit/specs/sixth-run/`. By rule 27 no requirement names its own gate's `READY`
  or anything after it.

### S35-T1 — The free pass, and two short checks (S)
- **Subtasks:**
  1. **Everything free, once more, on the tree as merged:** the exit checklist's ten lines.
  2. **The tag's plugin loads from a worktree** of this repository at `v5.3.0`: one short headless
     session that prints the plugin root. If it does not load, the judge uses a plain copy from
     `git archive`.
  3. **One hook call captured,** to confirm what S34-T2 read in the documentation.
- **Done when:** all three have their result in the sprint's notes. About $0.10.

### S35-T2 — The baselines: one batch, one table, one stop (L)
- **Why:** rule 34. Every piece of waiting text is for a case. The case is run on today's text
  first, so the text goes in only where it is needed and its effect can be read.
- **Files:** `docs/design/eval-results-5.4.md` (new), `docs/design/eval-ledger.tsv`.
- **Subtasks:**
  1. **One batch, traces kept:** the seven new reviewer cases, five runs each; `second-round` and
     `stale-met`, five each; `check-triggered`, five; `second-of-a-kind` and `missing-req`, three
     each; the three test-kind probes, five each; the migration probe, three.
  2. **The four root-cause kits of S31-T2,** ten runs each: `hello`, `intake/limit`, and the
     `agents` and `rules-skip` smoke checks alone on `haiku`.
  3. **One table,** every cell read from a trace (rule 10), with the answer key beside each case.
  4. **STOP: the owner reads the table.** For each row the table says what would follow: text
     applied, no text needed, a grader corrected, or a case deleted. Nothing in T3 starts before
     the owner's go.
- **Done when:** the table has no empty cell; the rows are in the ledger; the owner's go is in the
  thread. About $14 to $18.

### S35-T3 — The waiting text, group by group (L)
- **Why:** if every change went in at once and a number fell, nothing would say which change did
  it. Each group is one commit, followed by only the cases that read it
  (`evals.sh --for-diff`, S31-T3).
- **Files:** the skill, agent and reference files each group names; `scripts/smoke.sh`;
  `README.md`, `GUIDE.md`, `docs/staff-guide.md` for the behaviour each group switches on.
- **Subtasks, one per group, in this order:**
  1. **The reviewer** (`agents/reviewer.md`): the sentences S32-T1 wrote, only where the baseline
     missed; the second round (S32-T2); the "Checks this diff triggered" section (S32-T3). After:
     the five tuning cases, the two second-round cases and `check-triggered`, five runs each. The
     held-out pair is not run.
  2. **The ship skill and its report** (`skills/ship/`): the skill rewritten around
     `ship-check.sh`; the evidence line; the blocks for changed requirements, triggered checks and
     "Ran the change"; check 29 extended to compare each block with the script's. After: three
     gates on the fixture.
  3. **The spec skill and its reference** (`skills/spec/`): the `> Tests:` line; the recorded test
     command in each `Done when`; the test-kind table, only for a kind the baseline missed. After:
     the probes for any kind whose text went in.
  4. **The escape skill** (`skills/escape/SKILL.md`): the second-escape step. After:
     `second-of-a-kind` and `missing-req`, three runs each.
  5. **The migration plan** (`shipkit-workflows`): the differential step. After: the probe, three
     runs.
  6. **The commit skill** (`shipkit-workflows`): the `Verified:` trailer. After: five commits on a
     fixture, the traces read; five of five carry exactly one stamp whose value matches what ran.
  7. **Setup** (`skills/setup/SKILL.md`): the `verify` skill in its overlay list, and the recorded
     test command in its reply. After: the `verify` skill, three runs on each of the three
     stacks' fixtures.
  8. **The flake outcomes of T2,** each its own commit: a corrected grader with both sides shown,
     a changed sentence, or a deleted case with its reason in `eval-history.md`.
- **The rule for every group:** text whose after number is not above its before number comes out
  again in the same sitting, and the record says so. Text for a case the baseline already passed
  never goes in.
- **Done when:** each group has its before and after in `eval-results-5.4.md`; every tick in the
  six specs that waited for this sprint is made. About $10 to $17.

### S35-T4 — The full smoke suite, once (M)
- **Subtasks:**
  1. **`sh scripts/smoke.sh </dev/null`,** the first full run since the plan began, on the tree
     with every group applied.
  2. **A failing check is read first** (rule 30). Its fix is one commit, and that check alone runs
     again with `--only`.
  3. **The count goes in the CHANGELOG,** with the text-only number beside it.
- **Done when:** every check passes, or each failure has its reading and its fix. About $3 to $4.

### S35-T5 — The run on a clone of the owner's project (L, V21, rule 35)
- **Files:** `docs/design/field-notes-5.4.md` (new), `ROADMAP.md`.
- **Subtasks:**
  1. **§5's ten lines are read aloud first,** and the owner says when to start.
  2. **The clone,** its remote removed, on a throwaway branch. The check first: it builds and its
     suite passes on the pinned toolchain as installed.
  3. **The nine steps of `field-notes-5.2.md`,** headless, on `sonnet`, `--plugin-dir` at the
     shipkit checkout, with setup run `--with-skills` so the `verify` skill installs.
  4. **Each line of this plan is read as held, not held or not shown:** the evidence line; the
     `> Tests:` line; `SKIPPED-CITE` and its false positives; `spec-diff.sh` on a requirement the
     run edits on purpose; the recorded test command in every `Done when`; the gate's blocks equal
     to the script's; `release-check.sh`; one checks item triggered; `red-check.sh` on T1; the
     `verify` block from a Phoenix server in the test environment; the `Verified:` stamp on each
     commit; the commit gate's log in `observe`.
  5. **The gate on two days,** the first report left in place, to read whether the second round's
     marks hold.
  6. **§5's ten lines are read back,** each as held or not held, with the evidence: `git worktree
     list` and `git branch` in the live repository unchanged from before the run (read with
     optional locks off); the development database untouched; no process left listening.
  7. **Nothing found is fixed.** Every finding becomes a ROADMAP line with its file and section.
  8. **The clone and the database go on the owner's yes,** each looked at first (rule 13).
- **Done when:** every step has its six parts; every line in subtasks 4 and 6 has a reading.
  About $2 to $8.

### S35-T6 — The roadmap for the plan after (S)
- **Files:** `ROADMAP.md`.
- **Done when:** the plan's section has its seven rows and 5.4.0; "Still open after Sprint 35"
  holds the run's findings and what §6 below left; every item cites a file and a section; the
  status line names 5.4.0.

### S35-T-REL — Release 5.4.0 (V22, V24)
- **Files:** the five version lines, `CHANGELOG.md`, `README.md`, `ROADMAP.md`,
  `docs/design/eval-history.md`, `docs/design/eval-ledger.tsv`, `.shipkit/releases/`, and the
  seven specs' `Status` lines.
- **Subtasks:**
  1. **The release run,** `bash scripts/evals.sh -j 4`, traces kept, its rows in the ledger. The
     two held-out cases run here for the first time, and their numbers are written down before
     anything else is read (rule 31).
  2. **The gates.** `/shipkit:ship` on `honest-evidence`, `gate-as-software`, `numbers-as-data`,
     `misses-to-checks`, `tests-worth-having`, `running-the-change` and `sixth-run`, each judged
     by `v5.3.0` through `judge.sh`. The checkout's own gate then runs on `gate-as-software` and
     `misses-to-checks`, as the test of the new gate (rule 28, V9).
  3. **The pull request, the green check, a merge commit, tag `v5.4.0`,** annotated.
  4. **Each of V24's items its own yes,** the owner's cache last, since it changes what the other
     window loads at its next restart.
- **Done when:** all seven `READY` by the judge; the run in `eval-history.md` and the ledger; the
  tag on the remote. About $27 to $31.

---

## 6. What this plan does not do

- **It tags nothing between sprints and pays for nothing before Sprint 35** (rule 33).
- **It adds no second reviewer to the gate.** The article says stacking one on the primary is
  often worse than tuning the primary, and it replays several finders only to measure whether a
  bug is detectable. S32-T2 takes the article's route.
- **It does not raise the evals ceiling or move the evals** (V12; decision 0005 stands).
- **It adds no always-on byte.** The three rules stay at 2,999, and no agent description changes.
- **It makes no new check block anything.** Every one starts in observe mode with a record that
  names what turns it on (rule 29). The one exception is a `> Tests:` line, which binds only a
  spec whose owner wrote it.
- **It ships no `verify` skill for python, go or react.** Three stacks first; the rest wait for
  what the run shows.
- **It does not run the test suite when every session ends.** The article offers a hook for that.
  Here the cost falls on every session of every project, and the commit gate in observe mode asks
  the same question at the moment it matters.
- **It adopts no separate `REVIEW.md`.** The spec is the reviewer's rubric and `.shipkit/checks.md`
  holds what a diff should be asked. Two files would say one thing twice.
- **It does not have agents try to disprove a proposed check,** as the article does with three.
  One orchestrator starts every agent (decision 0006), and the owner's yes is the test here.
- **It does not raise the number of runs per case.** The ledger's rate over several releases is
  the cheaper way to more evidence.
- **It does not rewrite the shorthand in older plans and notes.** Rule 32 covers what this plan
  writes.
- **It leaves the machine plan's §5 list where it was,** except what Sprint 30's scripts pay: why
  the model writes `placeholder`; the singular `Test:` line, the hand-written stamp and setup's
  two clocks; the strict `why` number, the map with no shared word, the four rule files kept on a
  number, the smoke header range, the `-rerun` report and the product skill's contradiction; the
  `eve` trim; the `walkthrough` trigger, a rare wakeup and the stack-skill lines. It also leaves
  the version line on a `--plugin-dir` checkout and the second `## Elixir-Specific` section.
- **It does not fix what the run finds.**

## 7. Risks, and what we do about each

| Risk | What we do |
|---|---|
| Six sprints merge with no model run, and something a model would have shown is found only in Sprint 35 | Nothing a model reads changes before Sprint 35 (rule 34), so the only thing a model run could show is a script's effect, and every script has model-free checks on both sides. Sprint 35 applies text in groups, each with its own cases, so a fall has one cause |
| Sprint 35 is long, and a stop in the middle leaves text half applied | Each group is one commit with its numbers; the tree is whole after any group. Text whose number does not move comes out in the same sitting |
| The model-free smoke run misses what the full run would catch | `--no-model` prints every skipped check by name; S35-T4 runs them all before the release; PR #21's eight days of red were on a check that needs no model, which this mode runs |
| The run disturbs the owner's live work | §5's ten lines, read before and read back after: a clone, no remote, its own dependencies, build, database and port, no install, no change to the loaded plugin, the owner's choice of time |
| The clone cannot build on the toolchain as installed | The run stops and asks; it installs nothing. The other option is a generated fixture, and the notes say what was lost |
| `SKIPPED-CITE` fires on the word "skip" in a comment | Observe mode; a smoke check for the near miss; it becomes a gap only after the real run reads it clean |
| A right edit to a requirement reads as tampering | `spec-diff.sh` reports and blocks nothing; the report says "changed", not "wrong", and the owner's yes covers it |
| The gate script drifts from the skill that pastes it | Check 29 compares every block in the model's report with the script's own |
| The last tag cannot read something a new sprint adds, and fails a good spec | The checkout's gate runs on two specs and both go in the record; 0007 reverses on two releases of that |
| Reading an earlier report anchors the reviewer on a wrong `MET` | Only open rows are carried; an earlier `MET` is never evidence; the `stale-met` case holds it, with a reversal condition |
| A check in `.shipkit/checks.md` is edited on the branch it would catch | The file is read from the base ref; a check added on a branch has no effect until it merges |
| The held-out cases get tuned on anyway | Rule 31; they run once, at the release run, and their numbers are written before anything else is read |
| `red-check.sh` calls a suite red when it only failed to start | The base suite runs first without the new tests; a failure there is `BASE-NOT-RUNNABLE`, not a verdict |
| `red-check.sh`, `judge.sh` or `ship-check.sh --clean` removes something it should not | Each removes only what it made, by the path it printed; smoke checks hold that |
| `verify-run.sh` leaves a server running | It stops the process it started by id; ten runs in a row are read for a leftover process, and so is the real run |
| The commit gate blocks real work | The default is `off`; `observe` blocks nothing; `enforce` lets the third commit through and exits 0 on any error of its own |
| The spend runs past the budget | Every paid run is in §4's table or has its own yes (rule 15); T2's table comes before the larger spends, and the owner can stop after it |

## 8. Approval

The owner approves this plan by writing "approved", with any decision ID changed from its default.
V1, V9, V12, V20 and V21 are settled. The approval line goes at the top of this file in the same
commit as S29-T0's spec. Until then this file is a draft, untracked on `main`, and nothing in it
starts.

---

## Appendix — How each number in §0 was measured

Run from the repository's root on 2026-11-17 at `5367060`. Re-run before a number is carried into
a spec (rule 25).

| Number | Command |
|---|---|
| The smoke suite's switches | `git grep -o -E 'SMOKE_[A-Z_]+' scripts/smoke.sh`; `git grep -n 'claude --plugin-dir' scripts/smoke.sh` |
| 493 requirements | for each `.shipkit/specs/*/spec.md`: `awk '/\*\*REQ-[0-9]+/{c++} END{print c+0}'`, summed |
| 196 waived, 0 gaps, 31 shipped | `sh plugins/shipkit/scripts/spec-check.sh .` → 196 `WAIVED` lines; "31 spec(s) checked, 0 gap(s)" |
| 2 citations in comments | `git grep -I -n -E 'gate-blind-spots/REQ-10\|spec-contract/REQ-23' -- . ':(exclude).shipkit' ':(exclude)docs' ':(exclude)*.md'` |
| 130 of 137 `manual` | `sh plugins/shipkit/scripts/decision-check.sh .`, counting the lines that end `: manual` |
| 26 reports | `git ls-files '.shipkit/releases/*.md' \| wc -l` |
| 204,747 bytes | `find plugins/shipkit/evals -type f -print0 \| xargs -0 cat \| wc -c` |
| 67 cases | `find plugins/shipkit/evals -name prompt.md \| wc -l` |
| 2,999 bytes | `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md \| wc -c` |
| 236 pass calls, checks 1 to 96 | `git grep -c 'pass "' scripts/smoke.sh`; the numbered comments in the same file |
| 3,276 lines | `wc -l scripts/smoke.sh` |
| The kept 5.2.0 result | `~/.cache/shipkit-rel-5.2.0/aggregate-result.json`: 65 cases, $21.25 |
| `hello`, `intake/limit` | `docs/design/eval-history.md`, "Release run 5.2.0" and "Release run 5.1.0" |
| No case run at 5.3.0 | `docs/design/eval-history.md`, "Release run 5.3.0" |
| The judge was the checkout | `docs/design/eval-history.md`, "Release run 5.2.0": "`--plugin-dir` at the checkout" |
