# Roadmap

Where shipkit is heading and why. Written 2026-07-03, after a full design review of v1.2.5.
Newest thinking wins — treat this as a living document, not a contract.

**North star:** shipkit is the colleague a solo engineer does not have — it remembers what was
intended, asks before work is handed off, checks the result against the intent, and refuses to
call unfinished work done.

The first north star (2026-07) was to turn a 21-skill methodology bundle into **the project
knowledge layer for Claude Code**: map, elders, registry. That was reached at 3.0. The quality-gate
plan (`docs/plans/quality-gate-sprint-plan.md`, approved 2026-10-05) set the one above and
shipped it in seven sprints.

**Status (as of 2026-10-09, v4.7.0):** Sprints 1 to 7 of the quality-gate plan, 8 to 10 of the
evidence plan and 11 to 13 of the field plan are done; Sprint 14 of the portfolio plan
(`docs/plans/portfolio-sprint-plan.md`, approved 2026-10-09) shipped as 4.7.0 and Sprints 15
and 16 are next; see "The portfolio plan" below. Everything in this document is shipped except
the six items still open under "Still open after Sprint 13", which the portfolio plan carries.

## The quality-gate plan — ✅ Sprints 1–7 SHIPPED 2026-10-05 to 2026-10-06

| Sprint | Release | What the owner got |
|--------|---------|--------------------|
| 1 | 3.2.0 | Evals that show whether shipkit helps; the three always-on rules four times smaller (11,867 → 2,996 bytes); a commit guard |
| 2 | 3.3.0 | The spec is a contract: a `Status` line, drift measured on the spec's own paths, `spec-check.sh` fails when a requirement has no task or no cited test |
| 3 | 3.4.0 | `/shipkit:product`, `/shipkit:intake`, `brief.sh` / `brief-verify.sh` — a product file, good questions before work starts, a standard brief for any agent |
| 4 | 3.5.0 | The `reviewer` agent with fresh context; `/shipkit:ship`, the gate that says `READY` or `NOT READY` with evidence; `/shipkit:escape` |
| 5 | 3.6.0 | A briefing at session start; `/shipkit:handoff` so the next session resumes |
| 6 | 3.7.0 | `Fired-if` commands on decisions and `decision-check.sh`; `portfolio-digest.sh` and `/shipkit:ask --all digest` |
| 7 | 4.0.0 | The trim audit (five cuts, sixteen trims), lint-held limits, the README around the loop, Playbook 4, this roadmap |

## The portfolio plan — Sprint 14 SHIPPED 2026-10-09 as 4.7.0; Sprints 15–16 to come

Full plan: [`docs/plans/portfolio-sprint-plan.md`](docs/plans/portfolio-sprint-plan.md). Pay the
harness's debts (14), act on the numbers the rules carry (15), measure what still has none —
`eve`'s portfolio and a second real project (16).

| Sprint | Release | What the owner got |
|--------|---------|--------------------|
| 14 | 4.7.0 | `spec-check --as-open` for a draft; a gate that removes its scratch files; a smoke runner that restores `plugin-root`; `map_read` counting what its document says and `map_shell` beside it; the sandbox's refusal understood (a protected file name, not a root dotfile); the rule-5 contradiction closed by the rulebook |
| 15 | 4.8.0 | *(next)* the twenty-two measured lines cut or kept by name, each with its watch case; the intake's assumption sentence; the elder's step 0 closed by record; two cache directories |
| 16 | 4.9.0 | *(after)* a three-project fixture and `eve`'s first number; shipkit end to end on `~/code/pulse`; the roadmap for the plan after |

## The field plan — ✅ Sprints 11–13 SHIPPED 2026-10-08 to 2026-10-09 as 4.4.0, 4.5.0, 4.6.0

Full plan: [`docs/plans/field-sprint-plan.md`](docs/plans/field-sprint-plan.md). What the real
run showed, fixed in three sprints: shipkit's own behaviour on a project it had not seen (11),
the gate's blind spots (12), second traps and the elder's first step (13).

| Sprint | Release | What the owner got |
|--------|---------|--------------------|
| 11 | 4.4.0 | A briefing that is right on a project with pre-3.3 specs; an intake whose claims of absence name what it searched (the fixed search list was not added — its case passed 3 of 3 before the sentence existed, and the record's clause fired first); headless intake and product runs that leave their questions on disk; a version line in the hook, a quiet top-goal line, a "Blocked on" heading in the handoff |
| 12 | 4.5.0 | A `Fired-if` that cannot fire before the code exists (`decision-check.sh` strips a trailing comment, its `ERROR` line says why; the spec skill runs it on its own output); everything under `.shipkit/` but another spec's folder allowed by `brief-verify.sh` and the reviewer; the gate's How column echoes exit codes and pastes output from files; ignored files closed by record (C6) |
| 13 | 4.6.0 | Path-scoped loading measured (the globs fire on a read, not a mention); sixteen trap-2 cases with and without — four lines separate, twelve are named cut candidates; the Gemfile lock-diff line conditional on the install; the elder's step 1 tried twice (1 → 4 → 8 of 15 map reads, both reverted, record 0001 unchanged); the history case on a "wip" log (3 of 3 with the map, 0 of 3 without); housekeeping rows D1–D3 done; this section |

**Still open after Sprint 13** (every item names its evidence; these seed the plan after):

- **Twelve rule files pass without their text on both named traps** — `hotwire`, `liveview`,
  `migrations`, `mix-deps`, `monorepo`, `notebooks`, `package-json`, `pyproject`, `react`,
  `testing`, `ui-ux`, and `rails` at the threshold: named cut candidates with two measurements
  each (`docs/design/eval-results-4.6.md`, "The three readings"; C8 forbade cutting on the
  sprint's own numbers). The plan after decides which lines are kept as a statement of standards.
  *4.8.0 (S15-T1, E1): seven files lost their two measured lines (`ui-ux`, `hotwire`, `liveview`,
  `mix-deps`, `notebooks`, `pyproject`, `react`; 2,342 bytes) and their fourteen cases hold on the
  trimmed text, 12 at 3 of 3 and 2 at 2 of 3 with neither failing run in its trap; the cases
  stay as the watch and a release run below 2 of 3 returns the line. `migrations`, `monorepo`,
  `testing` and `package-json` — whose whole body is the two lines — and `rails` are kept by
  record on the owner's word (`docs/design/eval-results-4.8.md`; smoke check 58).*
- **`eve`'s loss when fewer projects carry a map is unmeasured** — needs a three-project
  registry fixture, about 20 KB of generator, a sprint of its own (`eval-results-4.6.md`,
  "The wip history"; C11).
- **The elder reads the map in 8 of 15 runs at best from step 1 alone** — step 0's "cheap grep
  first" wins whenever the grep lands, and a sentence in step 1 cannot override a triage that
  happens before it (`eval-results-4.6.md`, "The elder's step 1"; decision 0001's appended
  note). Whether step 0 itself should change, and whether a read that never changes an answer
  is worth its tokens, is the next plan's question.
  *4.8.0 (S15-T3, E2): closed by record, no run — 45 of 45 answers right while the map was
  read in 1, 4 and 8 of 15, a read costing about 23k more main-session tokens on the 4.0.0 XL
  baseline's `drift` and `gap` rows; step 0 stays, and the record names the fixture where the
  grep does not land (Sprint 16's `why` case) as the thing that would reopen it
  (`.shipkit/decisions/0001-project-map-default.md`, "Step 0, closed").*
- **The intake names the answering file only because the grader asks** — nothing in
  `skills/intake/SKILL.md` says to; the 4.4.0 case passed 3 of 3 before any sentence existed
  (`CHANGELOG.md` 4.4.0 "What using it for real showed"; the reviewer's note in
  `.shipkit/releases/2026-10-08-run-wounds.md`, section 4).
- **`spec-check.sh` cannot check a draft spec** — the spec skill flips the status to run it
  (`docs/design/field-notes-4.3.md` §6; left out of Sprint 12 by the owner's answer).
  *4.7.0 (S14-T1, E4): `--as-open` reads a draft as open for one run, changing no file; the
  spec skill asks for it and never flips the status (smoke check 55).*
- **The gate leaves `shipkit-ship-*.out` files under `$TMPDIR` after every run** — the design
  record's case-against (`.shipkit/specs/gate-blind-spots/design.md`, "Exit codes are echoed on
  the command line"), now observed on four gate runs. *4.7.0 (S14-T2, E5): the gate removes
  them once the report holds their content; a dry run on `second-traps` left none.*
- **The eval sandbox denies writing a dotfile at the workspace root** — *4.7.0 (S14-T5): it
  does not; it denies a file whose name is on Claude Code's protected list
  (`.pre-commit-config.yaml` is), in the mode the eval tool runs under. Two probe runs wrote
  `.editorconfig` at the root and below it. The rule for case authors is in
  `plugins/shipkit/evals/README.md`, "What a case cannot ask for" (smoke check 57).*
- **`trace-tools.sh`'s `map_read` counts a `Read` or a `Grep` with the map's path, not a shell
  `cat`** — one run in fifteen read the map through Bash and is counted as not reading it
  (`eval-results-4.6.md`, "The elder's step 1", attempt 2). *4.7.0 (S14-T4, E7): the code
  counted `Read` only, not `Read` or `Grep` as documented; it now counts both as `map_read`
  and a `Bash` command naming the map as `map_shell`; 4.6's rates stand as `Read`-only counts
  (the appended note in `eval-results-4.6.md`; smoke check 40).*
- **The smoke suite overwrites `~/.claude/shipkit/plugin-root`** with scratch paths while it
  runs; the last hook run restores it only by luck of ordering, and a session started mid-run
  reads a scratch root (`scripts/smoke.sh` header, "except that the session hook writes
  ~/.claude/shipkit/plugin-root"; `CHANGELOG.md` 4.6.0 "What using it for real showed").
  *4.7.0 (S14-T3, E6): the runner saves the file before its first session and restores it
  from its EXIT trap, on every exit path; the mid-run window stays and the header names it
  (smoke check 56).*
- **Rule 5 and the gate disagree on when a branch-not-taken note lands** — the rule says the
  ship commit, the gate reads the spec before it; the note must be committed before the gate
  (`docs/plans/field-sprint-plan.md` §1 rule 5 against `.shipkit/specs/gate-blind-spots/tasks.md`
  "After the gate"; the 4.4.0 gate's first run in `CHANGELOG.md` 4.4.0 "What using it for real
  showed"). *4.7.0 (S14-T6, E9): closed by the portfolio plan's rule 16 — the note is committed
  before the gate — and its rule 5, which points there (`docs/plans/portfolio-sprint-plan.md`
  §1); no plugin file changed.*
- **The `3.1.0` cache directory** waits for the owner's restart (D2 above). *4.8.0 (S15-T4,
  E12 F1 and F2): `3.1.0` and `4.5.0` removed from `~/.claude/plugins/cache/shipkit/shipkit/` on
  2026-10-10, each its own yes ("both"), neither the running version (the session's hook said
  `4.6.0`; `4.7.0` installed beside it awaits the restart); the commands are in the S15-T4 commit.*
- **A second real run on another repository** — the field notes are one project, one run
  (`docs/plans/field-sprint-plan.md` §5).


## The evidence plan — ✅ Sprints 8–10 SHIPPED 2026-10-07 as 4.1.0, 4.2.0, 4.3.0

Full plan: [`docs/plans/evidence-sprint-plan.md`](docs/plans/evidence-sprint-plan.md). Every
standing claim shipkit makes about itself gets a number behind it, starting with the one owed
since Sprint 1.

| Sprint | Release | What the owner got |
|--------|---------|--------------------|
| 8 | 4.1.0 | The map on trial: a generated 224-file, 27-commit fixture; five XL elder cases including a history question; `trace-tools.sh`; the re-test decision 0001 asked for — and, by its own clause, **the map is now optional** (`docs/design/eval-results-4.1.md`) |
| 9 | 4.2.0 | One eval per rule file (the 5 path-scoped and 13 stack rule files), measured with, without and against the pre-trim 3.7.0 text; `rules/nontrivial` fixed within the byte budget or accepted by record |
| 10 | 4.3.0 | `spec-check` shows an open spec's uncited requirements (`PENDING-TEST`) so the gate's first-run misses are seen two seconds in; the overlay skills stay in core by record 0003; the loop run once, end to end, on `rails_error_dashboard` (`docs/design/field-notes-4.3.md` — it held; six candidates below came out of it); seven merged branches, 354 eval sandboxes and one stale worktree gone |

**Still open after Sprint 10.**

From the real run (`docs/design/field-notes-4.3.md`, Sprint 10, one project, one run; the §
numbers are its sections):

- **Pre-3.3 specs with no `Status` line are treated as open forever** (§1): the briefing reports
  shipped features as in flight, nags about drift on them and counts 23 `MISSING-TASK` gaps in a
  project whose six specs all shipped. A migration nudge, or "all tasks ticked and no Status"
  read as shipped, belongs to the next plan. *Shipped in 4.4.0 (S11-T1).*
- **The intake asked the owner what the repository already knew** (§3, §4): three of its four
  questions were answerable from files it had read or could have read; one claim of absence
  ("queue status has no source") was false; `grandfather` was not used in either pass (§5).
  *4.4.0 (S11-T2): a claim of absence names what was searched; the search list was not added,
  by the record's clause (`docs/design/eval-history.md`).*
- **A `Fired-if` that fires before the code exists** passed the spec skill (§6): a line-count on
  a file not yet written. The spec skill could run `decision-check.sh` on its own output as it
  runs `spec-check.sh`; `spec-check` cannot check a draft, so the skill flipped the status to run it.
  *4.5.0 (S12-T1): the skill runs it; a draft-tolerant `spec-check` stays open for Sprint 13.*
- **Files no spec will ever list are "outside the spec"** (§7, §8): `.shipkit/product.md` and the
  release report, to the reviewer and to `brief-verify.sh`, which allows only the spec's `tasks.md`.
  *4.5.0 (S12-T2): everything under `.shipkit/` except another spec's folder is allowed, by both.
  The ignored-files question beside it (Playbook 4's `__pycache__`, open since 4.0.0) is closed by
  record (S12-T4, `gate-blind-spots/design.md`, C6): `brief-verify.sh` sees what git sees, on
  purpose; a build artifact shows in the task's Done-when output.*
- **Headless runs leave their questions in the reply, not on disk** (§2, §3): product's eight
  and intake's four questions vanish with the session; an unanswered intake writes nothing.
  *Shipped in 4.4.0 (S11-T3).*
- Smaller (§0, §7, §8, §9, §10): the session hook could say when the cache holds a newer version
  than the running one; a `Fired-if` line tolerates nothing after the command; the gate's `How`
  column loses exit codes to pipes; the handoff has no "Blocked on" line; the briefing's "top
  goal" line repeats "metric: none set; target: none set; by: no date set" every session.
  *4.4.0 (S11-T4): the version line, the "Blocked on" heading and the quiet goal line.
  4.5.0 (S12-T1, S12-T3): the `Fired-if` tolerance and the exit codes.*

Housekeeping done in Sprint 10 (S10-T4, 2026-10-07, each row its own yes from the owner; the
commands and their output are in that task's commit message):

- **B11** — the seven merged branches `sprint-1/measure-and-slim` … `sprint-7/trim-and-docs`
  deleted locally with plain `git branch -d` (each reported "Deleted branch … (was <sha>)") and
  on GitHub with `git push origin --delete` (each "- [deleted]"); `git ls-remote --heads origin 'sprint-*'`
  now lists only `sprint-8` and `sprint-9`. Tags `v3.2.0` … `v4.0.0` untouched.
- **B12** — the 354 sealed eval sandboxes under `/private/tmp/e-*` (84.8 MB) removed. They were
  owned by the owner with their permission bits cleared by the eval tool (`d---------`), so
  `chmod -R u+rwx` came first; no smoke check read them (check 40 uses a synthetic trace).
- **B13** — the detached worktree `.claude/worktrees/agent-a4a4658de35627a13` (at `d666c27`,
  merged) removed with `git worktree remove --force` and pruned. It held three uncommitted
  changes, all already on `main` (two overlay skills byte-identical; `lint.py`'s addition is
  main's check 13), so the force discarded nothing unmerged. `git worktree list` shows one line.

Housekeeping done in Sprint 13 (S13-T6, 2026-10-09, field plan C12, each row its own yes from
the owner; the commands and their output are in that task's commit message):

- **D1** — `~/code/RED/rails_error_dashboard`'s branch `shipkit/real-run` (two commits of
  shipkit artifacts from the real run, never for merge) deleted with `git branch -D`
  ("Deleted branch shipkit/real-run (was 14771c1)"); the owner's checkout stayed on
  `docs/http-reference`. What the run showed is in `docs/design/field-notes-4.3.md`.
- **D2** — the unused `4.2.0` and `4.4.0` directories beside `4.5.0` in
  `~/.claude/plugins/cache/shipkit/shipkit/` removed. **`3.1.0` is kept until the owner's next
  restart:** the session that did the housekeeping was running it (`plugin-root`), and deleting
  it from inside that session would have broken its skills. Delete it by hand after restarting.
- **D3** — the 25 scratch directories and one log under `$TMPDIR` from Sprints 8 to 10
  (`xl-*`, `t4-*`, `t5-*`, `s9-*`, `exit-4.2.0`, `shipkit-nomap`, `shipkit-norule`,
  `shipkit-pretrim`, `shipkit-evals`; about 14 MB) removed, one per `read` line — the first
  attempt looped once over the whole list because zsh does not word-split an unquoted variable,
  and removed nothing.
- **D4** — the merged branches `sprint-8/map-on-trial` … `sprint-12/gate-blind-spots`, local
  and on GitHub, are deleted by the release step **after `v4.6.0` is tagged** (the owner's yes
  given at T6); `sprint-13/second-traps` stays until the owner says.
- **D5** — the owner's cache was updated to 4.4.0 and 4.5.0 at their releases (each its own
  yes); 4.6.0 is asked at its release.

Carried from Sprint 9:

- **The map on a project with an uninformative commit log, and `eve`'s portfolio reads.** The
  re-test's history question was answered from `git log` every time because the fixture's
  commit messages are clean; a repository whose log says "wip" would test the map's Evolution
  section properly. `eve` reads maps across repositories without opening them; nothing has
  measured what she loses when fewer projects have one. Neither changes the 4.1.0 default.
  (`docs/design/eval-results-4.1.md`, the history question's rows.)
  *4.6.0 (S13-T5): the XL generator takes `--wip` (same trees, every message "wip") and
  `grandfather-xl/history` on that log reads 3 of 3 with the map, 0 of 3 without — the one
  question in two releases where the map changed the answer, and the exception decision 0001
  names (`docs/design/eval-results-4.6.md`). `eve`'s loss when fewer projects carry a map stays
  **unmeasured and open**: it needs a multi-project registry fixture (about 20 KB of generator,
  a sprint of its own — C11), which no plan has built.*
- **The elder reads the map in fewer than one run in three** even when its instructions said
  to read it first (9 of 30 runs). If a map is to be worth building for the elders at all, the
  agent's step 1 is where the next experiment is, not the map's content.
  (`docs/design/eval-results-4.1.md`, "did the elder read the map" column.)

- **Sixteen of eighteen rules pass their case without the rule** (`docs/design/eval-results-4.2.md`):
  `sonnet` clears each file's first named trap unaided. One line per file was probed, one
  model. A second-trap case for the doubted files, or a decision that a line the model already
  follows still earns its bytes, belongs to the next plan.
  *4.6.0 (S13-T2): the second trap measured (`docs/design/eval-results-4.6.md`). Four files
  separate on it — `ml/data`, `rails/gemfile`, `go/go-mod`, `ml/experiments` — and twelve pass
  without on both traps: **named cut candidates for the next plan** (C8, no rule text changed
  on these numbers): `hotwire`, `liveview`, `migrations`, `mix-deps`, `monorepo`, `notebooks`,
  `package-json`, `pyproject`, `react`, `testing`, `ui-ux`, and `rails` at the threshold.*
- **Path-scoped loading, measured** (4.6.0, S13-T1, smoke check 54): in a normal headless
  session the `paths:` rules installed under `.claude/rules/shipkit/` load when the model
  *reads* a matching file (`pyproject.toml` → `dependencies.md`, `Gemfile` → `gemfile.md`), not
  when the prompt only names it, and not for a non-matching file (`README.md`). 2 of 2 matches
  and 0 of 1 non-match, `haiku`, 2026-10-08. The eval sandbox still loads no `.claude/` file, so
  rule evals deliver the text through the hook (`evals/README.md`, "Path-scoped loading,
  measured").
- **A rule that names a network step can stop work where there is none** — `gemfile.md`'s
  "read the lock diff after `bundle install`" halted three runs in a sandbox with no network
  (`docs/design/eval-results-4.2.md`, the `gemfile` row and its reading).
- **`rules/nontrivial`** passes 6 of 6 with the 4.2.0 sentence (record 0002); the record's
  clause says when the sentence comes out (`.shipkit/decisions/0002-spec-first-eval.md`;
  `docs/design/eval-results-4.2.md`, the `rules/*` table). Watch it on every release run.

Platform facts that shaped this plan, each verified against the official Claude Code docs and,
since 2.8, by a nonce test in a fresh session (docs and behaviour have disagreed before):

1. **Plugins can ship hooks** — `hooks/hooks.json` at plugin root, `${CLAUDE_PLUGIN_ROOT}`
   for bundled scripts; `SessionStart` fires on startup/resume/clear/post-compaction, and its
   plain stdout is added to Claude's context — capped at ~10,000 characters **per hook
   command** (larger output is persisted with a 2 KB preview), which is why each always-on
   rule is its own hook command.
   ✅ Realized: the map-freshness hook shipped in 1.3.0, gained spec-drift nudges in 2.5.0, and
   in 2.8.0 became the carrier for the always-on rules and the plugin-root line.
2. **Forked skills cannot use AskUserQuestion** — it is explicitly blocked in subagents, and a
   subagent cannot spawn subagents either.
   ✅ Realized: the fork-interactivity audit (1.3.0) fixed the affected skills; new interactive
   skills (`/shipkit:spec`, `/shipkit:decide`, `/shipkit:connect-memory`) all run inline for this
   reason; 2.8.0 removed the last fork-delegates-to-subagent instruction.
3. **Plugins cannot ship `rules/` or `knowledge/`** — the plugin loader handles agents,
   commands, hooks, skills, settings, themes, monitors, output styles and workflows, nothing
   else. Rules only load from a project's `.claude/rules/` (recursively). `agents/` is scanned
   recursively, so nothing but agents may live under it.
   ✅ Realized (2.8.0): always-on rules are injected by the hook and installed as files by
   `/shipkit:setup`; knowledge bases are `user-invocable: false` skills; the map template is
   inlined in the archivist.

---

## 1.3 — Hardening (non-breaking) — ✅ SHIPPED 2026-07-04 as 1.3.0

All five items below landed (the fork-interactivity audit found **nine** affected skills, not
three — including `/unsetup`, whose destructive-restore confirmation ran where the user could
never see it). Remaining from the review: the 2.0 items, plus the 1.3 deprecation notices for
the cut-bucket skills, which are deferred until the cut-vs-split decision (see 2.0 item 6).

Ordered; each item was small and independently shippable with its own changelog entry.

### 1. Fix fork-interactivity bugs (live bugs — first)

At least three skills run in `context: fork` but assume interactive checkpoints, which
subagents cannot do:

- **`/setup`** — asks project purpose, branch prefix, PR preference, backup preserve/delete.
  Fix: drop `context: fork`. One-time operation; inline context cost is acceptable and its
  questions must reach the user.
- **`/plan`** — three AskUserQuestion approval checkpoints (PRD → spec → tasks).
  Fix: run inline, delegate Phase-2 codebase research to `codebase-explorer`. Interactive
  checkpoints stay where they belong; context-thinness stays where it matters.
- **`/qa`** — "probing questions before writing tests."
  Fix: same split — interactive phases inline, research delegated.

Audit all remaining forked skills for the same assumption. Add a lint rule (below): a skill
with `context: fork` must not mention AskUserQuestion, checkpoints, or "ask the user."

### 2. Plugin lint + CI (second — everything after it gets caught by it)

Dependency-free `scripts/lint.sh` (bash + small python for YAML). Checks:

- Frontmatter parses and has required fields for every skill/agent.
- Every `@reference.md` / `@templates/...` reference resolves.
- `agents/` contains only real agents (the actual 1.2.1 template-as-bogus-agent bug class).
- `plugin.json` / `marketplace.json` versions match; CHANGELOG has an entry for the version.
- No machine-specific absolute paths (`/Users/...`).
- Rule `paths:` globs are valid.
- Fork-interactivity rule from item 1.

Wire into CI (`.github/workflows/lint.yml`); document `./scripts/lint.sh` as the
pre-release step.

### 3. Map-freshness hook

`hooks/hooks.json` with a `SessionStart` hook running `scripts/check-map-freshness.sh`:

- Extract the SHA stamp from `PROJECT_MAP.md`.
- `git rev-list <sha>..HEAD --count` — if the map is ≥ N commits stale (default ~20), **or**
  a dependency manifest changed since the stamp, print one line:
  `PROJECT_MAP.md is N commits stale — /shipkit:map refresh`.
- Milliseconds of cost, no dependencies, silent when fresh.

Also: add a `mapped-at` SHA column to the project registry so `eve` can flag stale rows per
project in portfolio answers.

### 4. Genericize the examples

`eve.md`'s grep examples reflect one specific portfolio (Hetzner/Kamal/Oban/LiveView) and can
mislead other users' sweeps. Replace with a multi-ecosystem **signal cheat-sheet**, explicitly
labeled non-exhaustive:

- Deploy: `fly.toml`, `vercel.json`, `render.yaml`, `wrangler.toml`, `config/deploy.yml`,
  Dockerfile + CI configs.
- Background jobs: sidekiq / oban / celery / bullmq / river.
- …same pattern for framework versions, payment providers, etc.

Generic project names in the registry template. The lint's absolute-path check prevents
regressions.

### 5. Soften and single-source the workflow

- `rules/shipkit.md` becomes the **only** place the default workflow is defined; `/plan` and
  `/tdd` reference it instead of restating it.
- Reword "BDD is not optional" → "prefer behavior-focused tests for user-facing features."
  Prescriptive LLM rules degrade over long sessions and alienate users who don't share the
  conviction.
- Make intensity a **setup choice**: `/setup` asks "workflow style: strict TDD / test-first
  default / lightweight" and writes the matching CLAUDE.md section. Strict TDD stays fully
  available (the `/tdd` skill and setup option) — it just stops being installed into
  strangers' projects as law.

---

## 2.0 — Repositioning (breaking) — ✅ SHIPPED 2026-07-04 as 2.0.0

Decision made: **hard cut**, not a two-plugin split. The five cut skills point to native
equivalents in the CHANGELOG; `v1.3.0` is tagged for anyone who relied on them. Registry v2
landed with `Stack` / `Deploys To` columns. The portfolio version/dependency matrix and
consolidation report shipped as **2.1.0** (`/shipkit:ask --all matrix <target>` and
`--all consolidate`) — the review's seven findings are now fully addressed.

Resolved in 3.1.0: the project moved to GitHub (the Codeberg repo is archived and redirects),
so the invite-gated Woodpecker plan is moot. Structural lint now runs on every push and PR via
`.github/workflows/lint.yml`. The behavioural suite (`./scripts/smoke.sh`) needs a logged-in
`claude` CLI and real model calls, so it remains a pre-release step run by hand.

### 6. Triage the 21 skills

Three buckets:

| Bucket | Skills | Action |
|--------|--------|--------|
| **Core** (headline, model-invocable) | `ask`, `map`, `setup`, `unsetup`, `update-rules`, `context-audit` | Keep — the knowledge layer + its hygiene tools |
| **Demote** | `debug`, `tdd`, `qa`, `ui-ux`, `humanize`, `ai-feature`, `legacy-audit`, `migration-plan`, `explain-system`, `walkthrough` | `disable-model-invocation: true` — removes the description from context until invoked, cutting the per-session context tax and stopping auto-trigger surprises |
| **Cut** (deprecation pointers) | `plan` (→ native plan mode), `review-my-code` (→ native `/code-review`; keep the 8-lens KB), `test`, `use-library`, `onboard` (→ `/init` + Explore agents) | Deprecate in 1.3 docs, remove in 2.0 |

Preferred structure: `marketplace.json` supports multiple plugins from one repo. Split into
**`shipkit`** (the knowledge layer) and **`shipkit-workflows`** (the methodology skills).
Nothing is deleted; users opt into the opinionated half; the core plugin's pitch becomes one
sentence.

### 7. Double down on eve (the moat)

Eve lives *outside* any single repo — native project memory can't easily replicate a
portfolio view. Invest there:

- **Registry v2:** add stack, deploy-target, and mapped-at-SHA columns so many single-fact
  sweeps are answered from the registry alone — zero repo reads, cheaper than the current
  grep fast path.
- **New portfolio capabilities:** version/dependency matrix ("which repos are on Rails
  < 7.1?", vulnerable-dependency sweeps), consolidation report (duplicated patterns across
  repos).
- **Hedge platform risk deliberately:** keep `PROJECT_MAP.md` and the registry as plain,
  documented markdown artifacts. If Claude Code ships native cross-session memory, shipkit's
  artifacts become its best-structured input rather than roadkill — say so in the README.

### Migration

- 1.3 marks the cut-bucket skills deprecated in README/GUIDE with pointers to native
  equivalents.
- 2.0 performs the split/cut in one release, with a migration note surfaced by `/setup` and a
  README rewritten around the knowledge-layer pitch.

---

## 2.5 — Spec-Driven Development + Decision Records — ✅ SHIPPED 2026-07-07 (2.5.0 + 2.6.0)

Full design: [`docs/design/spec-driven-development.md`](docs/design/spec-driven-development.md).
Written 2026-07-07. **Shipped across two releases:** 2.5.0 (the SDD core) and 2.6.0 (completion).
All four design open-questions are now settled (see the design doc §7). What landed:

- **2.5.0** — the always-on `spec-driven` + `decisions` rules; `/shipkit:spec` (the three
  questions → `.shipkit/specs/<feature>/`, EARS requirements, design-as-decision-records);
  `grandfather`/`eve`/`archivist` taught to read `.shipkit/`; the spec-drift freshness hook.
- **2.6.0** — `/shipkit:decide` (standalone five-part decision capture with a concrete
  falsifiability clause); the registry `Active Specs` column so `eve` sees open specs across the
  portfolio; an explicit guard that `/unsetup` never deletes `.shipkit/`; and narrated capability
  playbooks (new-repo / legacy-repo / elders) plus a "How Shipkit Works" automatic-vs-invoked
  section in the docs.

The original proposal follows, kept for the rationale.

**The gap.** `PROJECT_MAP.md` looks backward (what exists, where). Shipkit has no forward-looking
artifact (what we're *about* to build) and no durable **narrative of decisions** (the "why" the
README's Episodic-memory section explicitly calls out as missing). This item adds both, as new
classes of verified, elder-readable artifact — **extending the knowledge layer forward in time,
not re-adding a methodology bundle.**

**Positioning guardrail.** 2.0 deliberately cut the old `/plan` skill to stop being a methodology
bundle. This must NOT walk that back: no port of Spec Kit's seven `/speckit.*` commands, no
workflow that overlaps native Plan Mode. Specs and decisions are *artifacts the elders read*, and
the discipline is carried by always-on **rules** that ride the existing trivial-vs-non-trivial
split — not by a command chain.

### The model — three questions (user-facing)

1. **What are we building?** → `spec.md`, requirements in **EARS notation** (default, prose-escapable).
2. **How should it work?** → `design.md`, written **as decision records** (below).
3. **How will we know it's done?** → acceptance criteria as **tests** (TDD/BDD-first). Each EARS
   `shall` maps 1:1 to a behavior-focused test. SDD sits *above* TDD: the spec says what to test.

Artifacts live under a single dotted root, `.shipkit/specs/<feature-slug>/`, one folder per
feature, SHA-stamped like the map so drift is detectable. `.shipkit/` is the canonical home for
all shipkit-generated docs — one place humans, the elders, and MemPalace all reference.

### Decision records — the five-part format (the spine)

Every "how" answer is a decision. Records use five parts, in order: **Context · Alternatives (≥2
real) · Case for · Case against (the honest cost of your own choice) · Decision + falsifiability
clause.** The **falsifiability clause** — a concrete, checkable "I'd reverse this if ___" — is the
novel piece: it makes decisions *queryable for staleness* ("chose SQLite because <10k users; now
at 40k" → fired). Hard rule: the clause must be a metric/event/threshold, never a vague hedge —
the guard against LLM-generated hollow honesty, enforced like `explain-system`'s zero-UNCERTAIN
gate. Lives inline in a spec's `design.md` (feature-scoped) or standalone
`.shipkit/decisions/NNNN-*.md` (project-wide). The standalone log is the map's counterpart:
map = *what/where*, log = *why*.

### Reuse (minimal new surface)

- **Rules** (the "effortless" property): `rules/spec-driven.md` + `rules/decisions.md` fire the
  discipline automatically on non-trivial work — no command to memorize; a typo never gets specced.
- **Skills:** one thin `/shipkit:spec` (inline, interviews Q1→Q2→Q3, delegates research to
  `codebase-explorer`, native Plan Mode as the review gate). `/shipkit:decide` optional — ship the
  rule first, add the skill only if capture proves unreliable.
- **Agents:** teach `grandfather`/`eve` that `specs/` + the decision log are first-class sources
  (enables "what's next?", "why X?", and "which decisions are now falsified?"); `archivist` links
  active specs/decisions from the map. Structured records are preferred over fuzzy MemPalace recall
  for "why" questions (verified > recalled) — complementary, not competing.
- **Hook:** extend `check-map-freshness.sh` (one proven mechanism) to flag specs whose code has
  drifted and, cheaply, surface fired falsifiability clauses at session start.

### Build order (each independently shippable)

Rules → agent reads → `/shipkit:spec` → hook extension → `/shipkit:decide` (if needed) → docs.
See the design doc §7 for the open decisions (record home, skill-vs-rule, one-hook-vs-two, EARS
strictness — the last settled as *default, escapable*).

---

## 2.7 — One-command episodic-memory setup — ✅ SHIPPED 2026-07-08 as 2.7.0

**The gap.** MemPalace (the optional decision-recall store the elders use) had thorough but fully
**manual** onboarding — install, register, restart, backfill — and `/shipkit:setup` never
mentioned it. The worst friction was hand-deriving the `~/.claude/projects/-Users-...` transcript
path, which users got wrong.

**What shipped.** `/shipkit:connect-memory` — an inline skill that sets it up end-to-end: detects
what's already done and skips it, installs via `uv`/`pipx` if missing, registers at user scope,
**auto-derives the transcript directory**, splits concatenated transcripts, backfills this
project's history (dry-run first, then real), and reminds you to restart Claude Code. `/shipkit:setup`
now points users to it; README/GUIDE lead with the command and keep the manual steps as a fallback.

**Positioning held.** MemPalace stays opt-in and **unbundled** (a separate package + ~300 MB
model) — the base plugin remains dependency-free. This only automates the setup the docs already
described by hand; skip it and the elders fall back to git history, nothing breaks.

---

## 2.8 — Make the automatic tier real — ✅ SHIPPED 2026-09-14 as 2.8.0

**The gap.** A full audit of 2.7.0 against Claude Code 2.1.270 (binary loader list, nonce tests
with `--plugin-dir`, two live archivist runs) found that the plugin-root `rules/` and
`knowledge/` directories are not plugin components, so the 9 rules and 2 knowledge bases never
entered a session; that `agents/templates/` registered as a bogus agent; that `connect-memory`
derived the wrong transcript path for `_`/`.` paths; and that `/setup` had no way to find
`stacks/` or fill its placeholders.

**What shipped.** The session hook (`scripts/session-start.sh`) now carries the plugin root and
the three always-on rules; `/shipkit:setup` installs all 9 rules as files under
`.claude/rules/shipkit/` (the only way path-scoped rules can work); knowledge bases became
on-demand skills; the template moved into `archivist.md`; the transcript-path, hook-regex,
dead-fallback, `explain-system`, `context-audit` and doc-drift findings were fixed; and the
lint gained checks for every bug class the audit found. Full list in the CHANGELOG.

**Positioning held.** Nothing was added to the skill surface. The audit's scope recommendations
(the methodology skills that dilute the knowledge-layer identity; the two-plugin split from
item 6) remain open and are the natural next release.

---

## 2.9 — Deterministic installs, smoke test, lighter discipline — ✅ SHIPPED 2026-09-14 as 2.9.0

**The gap.** After 2.8 the installs still depended on the model following a 20-row table by
hand; the platform assumptions the plugin rests on (10K per-hook cap, recursive `agents/`,
`.claude/rules/` loading) were checked only by one-off nonce tests in a chat; installed rule
copies rotted after a plugin upgrade; spec-driven ceremony fired at full strength even for
`lightweight` projects; setup's CLAUDE.md was mostly generic boilerplate the rules already
carried; and four small inconsistencies remained (agent `memory:` fields, `.gitignore`,
`lessons.md` duplicating native memory, walkthrough on the Haiku explorer).

**What shipped.** `install-rules.sh` / `install-stack.sh` (copy + substitute + fail on leftover
placeholders + version stamp); `scripts/smoke.sh` (eight live checks, run before tagging); the
stale-installed-rules nudge in the session hook; `spec-driven` honours `Workflow style:
lightweight`; a project-facts-only CLAUDE.md template with the generic guidance moved into the
always-on `shipkit` rule; `lessons.md` retired in favour of Claude Code's native memory; agent
`memory:` fields dropped; the `tracer` agent for `/shipkit:walkthrough`; `.gitignore` scoped to
the repo root.

**Still open.** The two-plugin split (item 6) and the methodology-skill scope question. The
commit rule's no-trailer stance was deliberately left as is.

---

## 2.10 — Composable stacks — ✅ SHIPPED 2026-09-14 as 2.10.0

Full design: [`docs/design/two-plugin-split.md`](docs/design/two-plugin-split.md) §3, written
2026-09-14 alongside the split plan and shipped first because it is non-breaking.

**The gap.** `/shipkit:setup` assumed a project had exactly **one** stack, and the overlays were
web-framework shaped. A Rails + Hotwire + React app got whichever overlay matched first. Worse,
the three stacks doing the most work in practice had no rules at all: **Hotwire** (no rule fired
when editing a Stimulus controller or a Turbo Stream template), **LiveView** (nothing on `.heex`
or `lib/*_web/live/**`, so the lifecycle traps went unmentioned), and **ML/AI in Python** (no
notebook, experiment, or data-handling rules whatsoever).

**What shipped.** Overlays became composable — one base plus any number of add-ons, detected as
a set and installed with one `install-stack.sh` run each (no script change was needed). Four new
overlays: `hotwire`, `liveview`, `oban`, `ml`. `react` became an add-on whose primary pairing is
Rails, with an Inertia/Vite integration section. The elders learned the matching signals and the
map gained two optional sections (*Frontend interaction model*, *Data & models*). Full list in
the CHANGELOG.

**Positioning held.** No new skills, no new agents, no learning content — system design and
DS&A theory belong to the separate `bodhikit` tutor plugin, while shipkit's contribution is
verified explanations of *real* systems via `/shipkit:explain-system` and `/shipkit:walkthrough`.

**Next.** 3.0 — the two-plugin split (item 6), per the same design doc §1–2 and §4.

---

## 3.0 — The two-plugin split — ✅ SHIPPED 2026-09-14 as 3.0.0

Full design: [`docs/design/two-plugin-split.md`](docs/design/two-plugin-split.md) §1–2, §4.
**This closes item 6**, open since the 2.0 repositioning chose a hard cut over a split.

**What shipped.** The repo became a marketplace of two plugins: `shipkit` (12 skills, 5 agents,
9 rules, 10 stack overlays, the session hook) and `shipkit-workflows` (6 skills, 1 knowledge
base, 1 agent). The dividing rule is *core produces, reads or installs knowledge artifacts;
workflows tell Claude how to do the work* — sharper than "how opinionated is it", which every
reviewer draws differently. Each half stands alone: the eight cross-references became soft
references or self-contained fallbacks, and no plugin dependency is declared.

**Also cut**, for the reason 2.0 cut five skills — do not ship what the platform ships:
`/shipkit:ui-ux` and `ui-ux-standards` (the official `frontend-design` plugin covers it; the
path-scoped rule stays with an inline WCAG 2.2 AA baseline) and `/shipkit:ai-feature` (the
built-in `claude-api` skill covers the SDK; `ai-rails` stays in the Rails overlay).

**Still open.** Whether the nine rules belong wholly in core (recommended, with a falsifiability
clause in the design doc §1) and where the stack overlay skills should live (design doc §5).
Both are reversible and neither blocks anything.

---

## Origin

This roadmap came out of an honest design review (2026-07-03) whose seven findings map to the
items above: (1) skill breadth dilutes identity → item 6; (2) thin moat → item 7; (3) map
staleness → item 3; (4) over-prescriptive workflow → item 5; (5) author-specific examples →
item 4; (6) no plugin validation → item 2; (7) fork/interactivity mismatch → item 1.
