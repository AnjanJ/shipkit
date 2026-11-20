# Intake: tests worth having

> Intake taken on 2026-11-20.

## Request

Sprint 33 of `docs/plans/verifier-sprint-plan.md`, "Tests worth having" (lines 910 to 1010),
approved by the owner on 2026-11-17 ("yes to all") and amended on 2026-11-18. Four pieces:

1. S33-T1, which test proves which requirement: `scripts/kind-probe.sh`, a probe outside the eval
   suite. It scaffolds a small project with an accepted spec and design, prints the headless
   command for each run and starts one only with `--yes`. Three requirements, one per kind of
   test. A reader, `--read <dir>`, classifies a `tasks.md` by the kind its `Test:` line names.
   The table for `spec/reference.md` and an optional tag on a `Test:` line (`[e2e]`,
   `[property]`, `[differential]`) are waiting text.
2. S33-T2, a differential step for the migration plan: a fourth probe fixture, a reader for a
   plan, and one waiting step for `/shipkit-workflows:migration-plan`.
3. S33-T3, property tests on shipkit's own parsers: `scripts/prop.py`, five Hypothesis
   properties on `spec-check.sh` and `brief.sh`, run in CI with a fixed seed.
4. S33-T4, red at base: `plugins/shipkit/scripts/red-check.sh <project> <slug> <base> --test
   '<command>' [--link <dirs>]`, which prints `RED-AT-BASE`, `GREEN-AT-BASE <files>` or
   `BASE-NOT-RUNNABLE`. It is run by hand and is not a gate step.

The owner's words on how to do it, from 2026-11-17: "lets put things that would cost as for the
end of development", and "do what you think is best". So this sprint starts no paid model run
and changes no existing skill, agent or rule file (the plan's rules 33 and 34). The owner said
yes to starting this intake on 2026-11-20, after Sprint 32 merged at `6fea503`.

## Serves goal

None. There is no `.shipkit/product.md` (`.shipkit/` holds `checks.md`, `decisions/`,
`releases/`, `specs/` and `state.md`). The plan's goal for the sprint is the nearest statement:
"the probes that will say whether the model picks the right kind of test are ready, shipkit's
own parsers are tested with inputs nobody wrote by hand, and there is a way to show that a cited
test fails without the feature."

## Conflicts found

None that stops the work. Four findings come first, because each changes what has to be built.

- **`ship-check.sh` cannot print a suggestion where the plan implies.** S33-T4's third subtask
  says "`ship-check.sh` prints the command as a suggestion", and its file list does not name
  that script. Its standard output is the scratch path (`ship-check.sh:118`) and one line per
  step (`:132`). Smoke check 107 holds the rest of that output to "1 PASS 2 PASS 3 PASS 5 PASS 7
  PASS 8 PASS" (`scripts/smoke.sh:3964`) and the headings of `evidence.md` to the six steps
  (`:3966`). The script is the open spec `gate-as-software`'s: REQ-9 fixes its first line and
  REQ-11 its blocks (`gate-as-software/spec.md:88`, `:92`). A suggestion can go at the end of
  `evidence.md`, on a line that starts with neither `### ` nor `result:`, or on standard error.
  This is the first question below.
- **Hypothesis is not where the exit checklist's line 9 looks.** The plan's line 9 is `python3
  scripts/prop.py` (plan, line 155). On this machine `python3` is 3.15.2 and cannot import
  `hypothesis`; `uv` 0.13.9 is installed. CI has no `uv` (`git grep` over `.github/` finds
  neither word): both jobs pin Python 3.12 and install PyYAML with `pip`
  (`.github/workflows/lint.yml:27-29`, `:77-79`). The `lint` job runs on `ubuntu-latest` (`:19`)
  and `smoke-no-model` on `macos-latest` (`:64`). The plan says "CI runs it" and does not say in
  which job. The two runners have different `awk` programs, and the properties are about two
  `awk` parsers. This is the second question below; see also assumption 3.
- **The second probe requirement has no stated kind.** S33-T1 lists "three requirements, one
  per kind" and the tags `[e2e]`, `[property]` and `[differential]`. It calls the first an
  invariant "so a property test" and the third a differential test. The second, "an exported
  file shall import to the same records", is called "a round trip" and no more. A round trip is
  as often written as a property test over generated records as an end-to-end test. Sprint 35
  adds text for "a kind missed in 2 or more of 5", so what counts as a miss here decides whether
  text goes in. This is the third question below.
- **The agreement property has nothing to read on one side.** S33-T3 asks that `brief.sh` and
  `spec-check.sh` "agree on every task's id and files". `brief.sh` prints a task's files
  (`brief.sh:36-83`, `:154`). `spec-check.sh` prints findings only; its modes are a slug,
  `--as-shipped` and `--as-open` (`spec-check.sh:5`, `:82`), and none lists tasks. See
  assumption 4.

Non-goals: none recorded, since there is no product file.

Open specs, four, each touched and none contradicted:

- `gate-as-software`. Its `> Paths:` holds `plugins/shipkit/scripts/`, where `red-check.sh` is a
  new file. Its third record, "Each run of `ship-check.sh` has a scratch directory of its own",
  is the pattern `red-check.sh` follows: it removes only what it made. Its first record and
  REQ-9, REQ-11 are what the first question is about. T7, where the ship skill pastes the
  script's blocks, waits for Sprint 35.
- `honest-evidence`. Its fourth record, "One search with file names, filtered for each spec",
  is the search that says which files cite a spec, under a spec's `> Tests:` paths.
  `red-check.sh` "lists the test files that cite the spec"; see assumption 6.
- `numbers-as-data`. Smoke check 112 holds `spec-check.sh`'s output on fifty specs to its copy
  at `398d1c9`, and check 121 holds the briefing to 229 commands. A fix that a property asks of
  `spec-check.sh` must keep both, or is put to the owner (S33-T3's fourth subtask says so of any
  fix beyond the task's files).
- `misses-to-checks`. `.shipkit/checks.md` is on `main` since `6fea503`, so this is the first
  branch its four items apply to. `checks-match.sh . main` is read before the pull request;
  nothing calls it yet. The evals folder is at 204,629 of 204,800 bytes; this sprint adds no
  eval case, since both probes live under `scripts/`.

Decisions touched and not contradicted:

- `.shipkit/decisions/0005-evals-home.md`: the probes are outside the evals folder, so check
  17's ceiling is not approached.
- `.shipkit/decisions/0007-a-change-does-not-judge-itself.md`: `red-check.sh` runs the suite on
  a tree of the base ref, which the branch cannot edit.
- `.shipkit/decisions/0006-main-session-starts-every-agent.md`: no agent is added or started.

Three statements in the plan's text that the code does not bear out, none a conflict:

- "like `wait-probe.sh` … only with `--yes`". `scripts/wait-probe.sh` has no `--yes`; its model
  runs sit behind a `--run` mode. The flag is `scripts/judge.sh`'s (`judge.sh:31`, `:49`). See
  assumption 2.
- "`spec-check.sh` changes no file". It writes temporary files under `TMPDIR` and removes them
  on exit (`spec-check.sh:105`, `:108`). The property is about the project's folder.
- "no file in either plugin names the other two" kinds of test. This holds: `git grep` over
  `plugins/` for property, differential, end-to-end, e2e and round trip finds only "round-trip"
  in two unrelated senses (`skills/ask/SKILL.md:79`, the hotwire rule).

Nothing outside the plan and the out-of-scope lines of `misses-to-checks` mentions
`kind-probe.sh`, `prop.py`, `red-check.sh` or `tests-worth-having` (`git grep` over the whole
tree). No script under `plugins/` uses `git worktree`; `scripts/judge.sh:58-62` is the only one
in the repository.

## Answers

1. Does `ship-check.sh` gain the suggestion in this sprint, as one line at the end of
   `evidence.md` that names the `red-check.sh` command, with a dated note on
   `gate-as-software/REQ-11`? Or is `ship-check.sh` left as it is until Sprint 35, with the line
   written into this spec's design as waiting?
   **In this sprint** (the owner, 2026-11-20, "yes to all"). `ship-check.sh` joins S33-T4's
   files. The line goes at the end of `evidence.md`, starts with neither `### ` nor `result:`,
   and leaves standard output as smoke check 107 reads it. `gate-as-software/REQ-11` gets a
   dated note.
2. In which CI job do the five properties run: `smoke-no-model` on macOS, `lint` on Ubuntu, or
   both?
   **Both** (the owner, 2026-11-20, "yes to all"). Each job installs Hypothesis with `pip`
   beside PyYAML and runs `scripts/prop.py` with a fixed seed. A property that fails on one
   runner only is put to the owner before any fix. The repository is public, so the minutes
   cost nothing.
3. For the probe's second requirement, "an exported file shall import to the same records",
   which kind is the right one: end-to-end only, or either end-to-end or property?
   **Either** (the owner, 2026-11-20, "yes to all"). The reader marks that requirement missed
   only when the task names neither kind. It still prints which of the two each run chose, so
   Sprint 35's table shows both counts.

## Assumptions made

1. **No paid run, and no existing skill, agent, rule or overlay file changes** (rules 33 and
   34). `spec/reference.md` and `migration-plan/SKILL.md` stay byte for byte; their new text
   goes into `design.md` as waiting text. Both probes are run in this sprint without `--yes`
   only.
2. **`kind-probe.sh` takes `judge.sh`'s `--yes`,** as the plan says: without it the script
   prints each command and starts nothing. Its smoke check puts a stand-in `claude` first on
   the `PATH`, as check 92 does, and never writes "claude" followed by two dashes, which check
   97 reads as a model call (`scripts/smoke.sh:3576`).
3. **`prop.py` is a command of its own, and `lint.sh` stays as quick as it is.** On this machine
   line 9 is run as `uv run --with hypothesis python3 scripts/prop.py`; CI installs Hypothesis
   with `pip` beside PyYAML, as V17 says. The plan's file list names `scripts/lint.sh` and does
   not say what changes there; the design says, and the default is nothing.
4. **Agreement is read from what the two scripts print today,** with no new mode in
   `spec-check.sh`: a generated task list is made to trigger `CONFLICT` or `BAD-AFTER`, whose
   lines name task ids and files, and those are compared with `brief.sh`'s.
5. **A failing property stops for the owner before any fix to `spec-check.sh` or `brief.sh`.**
   Both are outside S33-T3's file list, so the plan's fourth subtask already asks for this.
6. **`red-check.sh` takes the citing files from the search `spec-check.sh` already makes,** and
   holds no third parser. How it reads them is the design's choice.
7. **`red-check.sh` takes its command as `ship-check.sh` does:** `--test`, or the record
   `test-command.sh` prints; with neither it says so and judges nothing
   (`test-command.sh:32-33`).
8. **`red-check.sh` is POSIX `sh` with git, makes its worktree under a directory from `mktemp`
   with a template, and removes only that,** on every exit path, as `judge.sh:57-62` does. Lint
   rejects a bare `mktemp` in `plugins/shipkit/scripts/` (`scripts/lint.py:525-531`).
9. **The migration fixture's dependency and its changelog are in the fixture's own tree,** so
   that a probe run in Sprint 35 depends on no web page. The skill's first step fetches the
   changelog; the design records the other option, a real library.
10. **The waiting step keeps the migration skill's description as it is.** It is 293 characters
    of the 300 the plan allows.
11. **The reader's hand-written files, six `tasks.md` and two plans, live under `scripts/`,**
    beside `scripts/grader-replies/`, and cost no byte of the evals folder.
12. **New smoke checks are numbered from 122,** each written first and shown red, each with a
    line in `registry()`, none starting a model.
13. **`GUIDE.md` gains one section for `red-check.sh`,** after "Checks that a diff triggers"
    (`GUIDE.md:954`).
14. **This spec has a `> Tests:` line,** written by hand: `scripts/smoke.sh` and
    `scripts/prop.py`.
15. **The work is on the branch `sprint-33/tests-worth-having`,** cut from `6fea503`.

## Out of scope

- Any paid model run: the five runs of each test-kind probe, the three of the migration probe,
  and `red-check.sh`'s reading on the clone of the owner's project are Sprint 35's.
- Any change to an existing skill, agent, rule or overlay file, the tag on a `Test:` line
  included.
- Making `red-check.sh` a gate step, observed or enforced (V18).
- A new mode or flag in `spec-check.sh` or `brief.sh`.
- Property tests on any script other than `spec-check.sh` and `brief.sh`.
- Adding an eval case, or making room in the evals folder.
- `verify-run.sh`, the commit gate and the prune: Sprint 34.
