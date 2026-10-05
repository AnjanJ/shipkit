# Spec: Measure and slim (Sprint 1, release 3.2.0)

> Spec accepted at commit `fc15929` on sprint-1/measure-and-slim.

## Purpose

Before shipkit grows into a quality gate, be able to measure whether it helps, and cut what
every session pays for. This sprint adds an eval suite with a fixture project, records a 3.1.0
baseline, shrinks the three always-on rules from 11,867 bytes to at most 3,000 without losing
their behaviour, and adds a hook that stops a commit carrying a secret-looking file.

Source: `docs/plans/quality-gate-sprint-plan.md`, Sprint 1, tasks S1-T1 to S1-T7. Each
requirement is one "Done when" line from that plan.

## User stories

- As the owner, I want a command that tells me whether shipkit's answers got better or worse,
  so that I can change the rules without guessing.
- As a user of the plugin, I want it to cost a quarter of the context it costs today, so that
  trivial sessions do not pay for detail they never use.
- As a user, I want a commit that stages `.env` to be stopped, so that a rule in prose is not
  the only thing between a key and the repository.

## Requirements (EARS)

### Eval harness (S1-T1)

- **REQ-1.** When `bash scripts/evals.sh` is run, the script shall run every case under
  `plugins/shipkit/evals/` and print one pass or fail line per case.
- **REQ-2.** If any eval case fails, then `scripts/evals.sh` shall exit non-zero.
- **REQ-3.** When the `hello` case is run against the 3.1.0 plugin, it shall pass, where passing
  means the answer contains `/shipkit:map`.
- **REQ-4.** `plugins/shipkit/evals/README.md` shall state the case format that works on this
  machine and, under "What graders can check", whether a grader can check (a) which tools were
  called and (b) a file the run wrote — each answer found by trying it.

### Fixture project (S1-T2)

- **REQ-5.** `plugins/shipkit/evals/fixtures/FACTS.md` shall list the planted facts F1 to F4,
  each with its file and line.
- **REQ-6.** The string `SQLite` shall appear in exactly one file under
  `fixtures/sample-app/`: `PROJECT_MAP.md`.
- **REQ-7.** The `fixtures/` directory shall occupy at most 40 KB (`du -sk`) and `sample-app/`
  shall hold at most 20 files.
- **REQ-8.** The `plugins/shipkit/evals/` directory shall occupy at most 100 KB.

### Baselines (S1-T3, S1-T5)

- **REQ-9.** When `bash scripts/evals.sh` is run, it shall run the four `grandfather` cases
  (`lookup`, `explain`, `drift`, `gap`) and print a pass or fail for each.
- **REQ-10.** When `bash scripts/evals.sh` is run, it shall run the three `rules` cases
  (`nontrivial`, `trivial`, `decision`) and print a pass or fail for each.
- **REQ-11.** `plugins/shipkit/evals/README.md` shall record, under "Baseline 3.1.0", the result
  of all seven cases as they came out. A failing case is recorded as failing; no grader is
  loosened to turn it green. [untested: a record of a measurement, verified by reading]

### What the map is worth (S1-T4)

- **REQ-12.** `docs/design/eval-results-3.2.md` shall hold one table with three rows — fixture
  with its map, fixture without its map, plugin switched off — and no empty cell, each row
  giving passes and tool-call counts over three runs of the four `grandfather` cases.
  [untested: a record of a measurement, verified by reading]
- **REQ-13.** `.shipkit/decisions/0001-project-map-default.md` shall carry the five parts and
  state which side of its falsifiability clause the measured numbers fall on.
  [untested: verified by reading]
- **REQ-14.** While S1-T4 is carried out, no shipped file shall change.
  [untested: verified from the commit's file list]

### Smaller always-on rules (S1-T6)

- **REQ-15.** The three always-on rules (`shipkit.md`, `spec-driven.md`, `decisions.md` in
  `plugins/shipkit/rules/`) shall total at most 3,000 bytes.
- **REQ-16.** If the core plugin's rules without `paths:` frontmatter total more than 3,000
  bytes, then the lint shall report an error.
- **REQ-17.** When the three `rules` eval cases are run against the shrunk rules, each shall
  give the same result as its 3.1.0 baseline, or a better one.
- **REQ-18.** The shrunk `shipkit.md` shall name every destructive action the 3.1.0 rule names
  under "Ask before anything destructive". [untested: verified by reading, item by item]
- **REQ-19.** Where a rule now points to a skill for detail (the commit message format, the
  EARS patterns, the five-part record), that skill's files shall contain the detail.
  [untested: verified by reading]
- **REQ-20.** The byte figures in `skills/context-audit/SKILL.md` that describe the always-on
  rules shall match the shrunk files. [untested: verified by reading]

### Commit guard (S1-T7)

- **REQ-21.** When the Bash command in the hook input does not contain `git commit`,
  `guard-commit.sh` shall exit 0 without inspecting the repository.
- **REQ-22.** When the command is a `git commit` and no staged file name looks like a secret,
  `guard-commit.sh` shall exit 0.
- **REQ-23.** If the command is a `git commit` and a staged file name matches `.env`, `.env.*`,
  `*.pem`, `*.key`, `id_rsa*` or `credentials*.json`, then `guard-commit.sh` shall exit 2 and
  print the matching names and "unstage these or ask the owner" on stderr.
- **REQ-24.** When the only staged match is `.env.example`, `guard-commit.sh` shall exit 0.
- **REQ-25.** If `guard-commit.sh` meets an internal error (unreadable input, not a git
  repository), then it shall exit 0.
- **REQ-26.** `guard-commit.sh` shall be POSIX `sh`: `sh -n` reports nothing.

### Sprint exit

- **REQ-27.** When Sprint 1 is complete, `bash scripts/lint.sh` shall report
  `0 error(s), 0 warning(s)` and `bash scripts/smoke.sh` shall report `smoke: all checks passed`.
- **REQ-28.** The 3.2.0 changelog entry shall list, under "Fixed", the three fixes merged in
  pull request #1 (the octal day-of-year abort, the same-named skill overwrite, the edited
  CLAUDE.md section overwrite). [untested: verified by reading]

## Out of scope

- Any new skill or agent. Sprint 1 adds none.
- The six path-scoped rules and every stack overlay rule. They are audited in Sprint 7.
- Renaming or deleting a rule file.
- Acting on decision 0001. This sprint measures and records; it changes no default.
- Running evals in CI. They cost real model calls and run before a release, by hand.
- Scanning file *contents* for secrets. The guard looks at staged file names only.
