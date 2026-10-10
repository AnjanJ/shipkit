# Spec: Eve's portfolio and a second project (Sprint 16, release 4.9.0)

> Spec accepted at commit `af582b4` on sprint-16/portfolio-run (2026-10-10).
> Status: open
> Paths: plugins/shipkit/evals/, scripts/, docs/design/, .shipkit/decisions/0001-project-map-default.md, .shipkit/releases/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Give the two things that still have no number theirs. A generated portfolio of three small
projects of three stack shapes, with a registry and a map per project whose Evolution holds
one *why* no file and no commit records, lets three `eve` cases run under three arms — three
maps, one, none — so the suite says what `eve` answers without a map and what only a map
answers. Shipkit's loop run once more, end to end, on a second real repository of another
stack says what the three releases since the first run changed on a project they never saw,
and seeds the plan after; nothing it finds is fixed here. The roadmap then names everything
still open, each item with its evidence.

Source: `docs/plans/portfolio-sprint-plan.md`, Sprint 16 (S16-T0 to S16-T4), decisions E10,
E11, E13, E12 (F3, F4, F5); §3's `why` shape claim; `docs/design/eval-results-4.6.md` "The
wip history" (C11); `docs/plans/field-sprint-plan.md` §5; `docs/design/field-notes-4.3.md`;
`.shipkit/decisions/0001-project-map-default.md`, "Step 0, closed".

## User stories

- As the owner, I want to know which of `eve`'s answers need a map and which do not, on a
  fixture built for the question, so that the registry's `Map` column is advice with a number
  behind it and not a habit.
- As the owner, I want shipkit's loop run on a second real project of another stack with
  every step written up the same way as the first, so that the plan after starts from what a
  user sees and not from what the suite passes.
- As a case author, I want the eval budget's room named for what it is for — cases and
  generators — so that a committed fixture is still the first thing the lint catches.

## Requirements (EARS)

### Make room (S16-T0)

- **REQ-1.** The lint's eval-budget check shall accept `plugins/shipkit/evals/` up to 196,608
  bytes and shall name that limit in its error line when the tree exceeds it.

### The portfolio fixture (S16-T1)

- **REQ-2.** When `portfolio-gen/generate.py` is run twice into two empty directories with
  the same `--maps` value, the tree hash of each project's HEAD commit shall be identical
  between the two runs.
- **REQ-3.** `generate.py` shall write three projects under `projects/` — `shopfront` with a
  `Gemfile` naming `sidekiq` and `stripe` and a `config/deploy.yml`; `pulse` with a `mix.exs`
  naming `oban` and `stripity_stripe` and a `fly.toml`; `insight` with a `pyproject.toml`
  naming `celery`, a `Dockerfile` and a `render.yaml` — each a git repository whose every
  commit message is `wip`, using the standard library only.
- **REQ-4.** `generate.py --maps N` shall write a `PROJECT_MAP.md` for the first N projects in
  the order `shopfront`, `pulse`, `insight`, and a `shipkit-home/project-registry.md` whose
  `Map` column names each written map and holds `—` for every project without one, with
  `Stack` and `Deploys To` filled for all three.
- **REQ-5.** When `pulse` is mapped, its `PROJECT_MAP.md` Evolution section shall record why
  sessions moved off the database to a cookie store (the nightly vacuum locked the sessions
  table) and when, and no file under `projects/` and no commit message shall carry that reason.
- **REQ-6.** `evals/fixtures/FACTS-PORTFOLIO.md` shall list every fact a grader checks: the
  three job libraries, the two Stripe projects and the manifest that names each, `insight`'s
  absence of a payment provider, and `pulse`'s session reason with its date. [untested: prose,
  read by smoke check 59's greps]

### Three `eve` cases, three arms (S16-T2)

- **REQ-7.** The suite shall carry `eve/jobs`, `eve/payments` and `eve/why`, each asked
  through `/shipkit:ask --all` with the digest case's two context lines, each scaffolding the
  fixture with `--maps 3`; and in a release run each shall pass at least 2 of 3.
- **REQ-8.** `eve/jobs` shall pass when the reply names all three projects with the right
  library each; `eve/payments` when it names `shopfront` and `pulse` with Stripe, `insight`
  with none, and cites a manifest path; `eve/why` when the reply gives the vacuum-lock reason
  and the move, or, where no map holds it, says plainly that the repository does not record
  why and invents no reason. [untested: the graders themselves; their verdicts are REQ-7's]
- **REQ-9.** `docs/design/eval-results-4.9.md` shall hold a 3 × 3 table (three cases by
  three arms, three runs each, counts from `trace-tools.sh`) with no empty cell and three
  readings written after the traces are read; decision 0001 shall carry an appended note with
  `eve`'s number; the ROADMAP's "`eve`'s loss" item shall be replaced by it. [untested: prose,
  verified by reading]

### The second real run (S16-T3)

- **REQ-10.** `docs/design/field-notes-4.9.md` shall record every step of the loop on the
  repository the owner named — setup, product, intake, spec, one task through `brief.sh` and
  `brief-verify.sh`, ship — each as Asked for / Produced / Took / Awkward / Whose fault /
  Evidence, with `git status` before the first step and the branch's fate at the end.
  [untested: prose, verified by reading]
- **REQ-11.** While Sprint 16 is open, nothing the second run finds shall be fixed; each
  finding shall be an item under the ROADMAP's "Still open after Sprint 16" citing its section
  of the notes. [untested: prose; the ROADMAP is read]

### The roadmap for the plan after (S16-T4)

- **REQ-12.** The ROADMAP shall show Sprints 14–16 as shipped in the portfolio plan's table
  and shall list under "Still open after Sprint 16" the second run's findings, S16-T2's third
  reading, any line S15-T1 returned, and anything the three releases' "What using it for real
  showed" sections name, every item citing a file and a section. [untested: prose; lint
  check 16 reads the status line]

## Release steps (not requirements)

- F3: the `shipkit/real-run-2` branch in the second repository, deleted on its own yes after
  the notes are written, `git log` read first (rule 13); F4: this sprint's branch after the
  tag, its own yes; F5: the owner's cache updated to 4.9.0, its own yes.
- The gate (`/shipkit:ship portfolio-run`) answers `READY`; the report is committed.
- Release as 4.9.0; the sprint exit checklist holds with the new ceiling on line 6; the
  release run (58 cases) is recorded in `docs/design/eval-history.md`; the pull request is
  merged after a green check; tag `v4.9.0`.

## Out of scope

`agents/eve.md`, `agents/grandfather.md`, every rule file and skill; fixing anything the second
run finds; the four kept whole-body files and `rails`; `trap2/notebooks`' grader; the mid-run
plugin-root window; the `.pre-commit-config.yaml` refusal text; the elder's step 0.
