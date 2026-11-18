# Intake: gate as software

> Intake taken on 2026-11-18.

## Request

Sprint 30 of `docs/plans/verifier-sprint-plan.md`, "The gate as software", approved by the owner
on 2026-11-17 ("yes to all") and amended on 2026-11-18. Five pieces:

1. S30-T0b: `session-start.sh:275` trims a spec's `> Paths:` entries with sed's `[ \t]`, which BSD
   sed reads as a space, a backslash or the letter t. `tests/billing/` becomes `ests/billing/` and
   drift is counted on a path that does not exist.
2. S30-T1: setup records the test command once, and `test-command.sh` prints it. Nothing that
   needs the command reads `CLAUDE.md` for it.
3. S30-T2: `ship-check.sh` runs the gate's command steps (1, 2, 3, 7, 8) and lists step 5's
   migration files, each with its command, exit code and output.
4. S30-T3: `release-check.sh` ties a shipped spec's `READY` report to a commit, in observe mode,
   and CI shows it.
5. S30-T4: `scripts/judge.sh`, the last tag's `spec-check.sh` in CI beside the branch's, and
   decision 0007, "a change does not judge itself".

The owner's words on how to do it, from 2026-11-17: "lets put things that would cost as for the
end of development", and "do what you think is best". So this sprint starts no paid model run and
changes no existing skill, agent or rule file (the plan's rules 33 and 34). The text a model reads
is written into `design.md` and waits for Sprint 35.

## Serves goal

None. There is no `.shipkit/product.md` (`.shipkit/` holds `decisions/`, `releases/`, `specs/` and
`state.md`). The ROADMAP's north star is the nearest statement: shipkit "checks the result against
the intent, and refuses to call unfinished work done" (`ROADMAP.md:6-8`).

## Conflicts found

One, with a shipped decision. The owner decided on 2026-11-18 to go ahead.

- **Decision: "The gate is a skill, not a script"** (`review-and-ship/design.md:78`). It chose a
  skill that calls the scripts, and turned down its option 3: "a script for the five mechanical
  steps plus a skill that wraps it and adds the two". Piece 3 is that option. The record's reversal
  condition is "a gate report in this plan records `PASS` for a step whose evidence is missing or
  does not match a re-run, even once". No record of that was found in `docs/design/`,
  `.shipkit/releases/`, `ROADMAP.md` or `CHANGELOG.md` (searched 2026-11-18), so the condition has
  not fired, and the approved plan's V7 chose the script without naming the record.
  **The owner's answer: go ahead, and mark the old record superseded.** This spec's design carries
  the record that takes option 3, and the old record is marked, not deleted.

Nothing else conflicts.

- **Non-goals:** none recorded, since there is no product file.
- **Open specs:** one, `honest-evidence`. Its "Out of scope" hands pieces 2 to 5 to this sprint
  (`honest-evidence/spec.md`, last line of the list), and piece 1 is in its "Found on the way". Its
  T10 and this spec's waiting text both change the ship skill, in Sprint 35; each waits in its own
  `design.md`.
- **Decisions touched and not contradicted:**
  - `users-machine/design.md:47`, "The elixir and go sections take the test command setup
    detected". Its reversal condition is a real run's `CLAUDE.md` naming two different test
    commands again. The ROADMAP reads it as not fired (`ROADMAP.md:59-63`): shipkit's lines agree
    with each other and the second command is the project's. Piece 2 leaves those lines alone
    and takes the gate and the tasks off them.
  - `harness-debts/design.md:48`, "The gate removes its own scratch files". `ship-check.sh` makes
    its scratch directory and `--clean` removes it, so the gate still does.
  - `review-and-ship/design.md:107`, "An earlier day's report is named, not removed". Step 7 in the
    script still sets an earlier report for the slug aside and removes nothing.
  - `decisions-and-digest/design.md:13`, "A decision may carry a command, run only on request".
    `ship-check.sh` runs `decision-check.sh --run` as the gate does today, and is never called
    from a hook.
  - `run-debts/design.md:200`, "The gate pastes the reviewer's reply from a file". The reviewer's
    step stays the model's; the waiting text keeps the file.
  - `.shipkit/decisions/0006`, "The main session starts every agent". No script here starts an
    agent. `judge.sh` prints a headless command, which is a main session of its own.

## Answers

1. **Go ahead with `ship-check.sh` although "The gate is a skill, not a script" turned it down?**
   Yes (the owner, 2026-11-18): go ahead and mark the old record superseded.

No other question was asked. Every other unknown is answered by the approved plan or by a file,
and each is written below as an assumption for the owner to object to.

## Assumptions made

1. **Piece 1 gets a requirement of its own in this spec,** and its smoke check also cites
   `spec-contract/REQ-16` (`spec-contract/spec.md:70`), which is already written and which the
   code does not meet. It does not go through `/shipkit:escape`: no user reported it.
2. **The recorded test command is not a Markdown file.** It sits beside the manifest under
   `.claude/rules/shipkit/`, where Claude Code loads every `.md` file as a rule. Rule 34 lets a
   new file land before Sprint 35 only when nothing loads it by default.
3. **A project set up before this change has no record** until setup runs again. There
   `test-command.sh` exits 1 and says so; it never falls back to `CLAUDE.md`.
4. **`release-check.sh` blocks nothing.** It prints and exits 0; `--enforce` exists and nothing
   passes it in this plan (the plan's V8 and rule 29).
5. **`judge.sh` starts nothing paid in this sprint.** Without `--yes` it prints the command and
   runs nothing, and no task here passes `--yes` (rule 33).
6. **CI's second `spec-check` is `v5.3.0`'s.** Read on 2026-11-18: that script exits 0 on today's
   tree, 32 specs and 0 gaps, so the step can land as the plan wrote it.
7. **Decision 0007 is a project-wide record** in `.shipkit/decisions/`, drafted with this spec and
   landed with piece 5.
8. **Plugin scripts stay POSIX `sh`, awk and git** (`spec-contract/REQ-10`,
   `spec-contract/spec.md:48`). `scripts/judge.sh` and `scripts/smoke.sh` stay `sh` as well.
9. **The changes to skills that belong with these pieces are tasks of this spec that wait for
   Sprint 35:** the ship skill rewritten around `ship-check.sh`, check 29 comparing the report's
   blocks with the script's, the spec skill writing the recorded command into each `Done when`,
   and the judge's first use.
10. **This spec has a `> Tests:` line,** written by hand as `honest-evidence` did.

## Out of scope

- Any change to an existing skill, agent or rule file, and any paid model run.
- Making the briefing's gap count cheap: the plan's S31-T2. Check 30's limit and CI's
  `SMOKE_TIMING=report` stay as they are.
- A `> Tests:` line on `spec-contract` or `gate-blind-spots`, so that the two citations in
  comments are named (`honest-evidence/tasks.md`, "Found on the way"). Not in the plan's Sprint 30;
  it needs the owner's word.
- Turning `release-check.sh` or any new check from observe to enforce.
- The eval ledger, the flake rule and the cases chosen by a diff: Sprint 31.
