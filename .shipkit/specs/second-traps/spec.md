# Spec: Second traps and the elder's first step (Sprint 13, release 4.6.0)

> Spec accepted at commit `c1c7b18` on sprint-13/second-traps (2026-10-08).
> Status: shipped
> Paths: plugins/shipkit/evals/, plugins/shipkit/agents/grandfather.md, plugins/shipkit/stacks/rails/.claude/rules/gemfile.md, scripts/, docs/design/, docs/plans/field-sprint-plan.md, .shipkit/decisions/0001-project-map-default.md, .shipkit/releases/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Put a number behind the two standing claims shipkit still makes without one — that path-scoped
rules load when a matching file is named, and that sixteen rule files earn their bytes — try
the one change to the elder that 4.1 named and keep it only if it measures better, reword the
one rule line that stopped an edit, run the history case on a log that says nothing, and leave
the roadmap for the plan after with every open item citing its evidence.

Source: `docs/plans/field-sprint-plan.md`, Sprint 13 (S13-T0 to S13-T7), decisions C1, C7 to
C13; `docs/design/eval-results-4.2.md` readings 1 and 3; `docs/design/eval-results-4.1.md`;
ROADMAP "Path-scoped loading is measured by nothing".

## User stories

- As the owner, I want each rule line I keep to have a measurement behind it, so that the next
  plan's cuts are decided on numbers and not on taste.
- As the owner, I want the elder to read the map when the map would help, or a record saying
  why it does not, so that decision 0001 stays honest.
- As a Rails user of the stack rules, I want the Gemfile rule not to stop an edit where there is
  no network, so that the rule helps and never halts.

## Requirements (EARS)

### Room (S13-T0)

- **REQ-1.** Lint check 17 shall hold `plugins/shipkit/evals/` at or under 163,840 bytes.
- **REQ-2.** The evals README shall point, in one paragraph, to `docs/design/eval-history.md`
  for the baselines it no longer holds. [untested: prose, verified by reading]

### Path-scoped loading, measured (S13-T1)

- **REQ-3.** The evals README shall state, under "How a case gets the fixture", the measured
  result of path-scoped loading in a headless session — loads when the prompt names a matching
  file, not when it names a non-matching one, or what did load — naming the smoke check that
  produced it. [untested: prose; smoke check 54 is the measurement, the paragraph its record]

### Sixteen trap-2 cases (S13-T2)

- **REQ-4.** For each of the sixteen rule files whose 4.2.0 case passed without the rule,
  `plugins/shipkit/evals/trap2/<rule>/` shall hold a case whose prompt walks into the rule's
  second named line and whose grader is a regex on the written file.
- **REQ-5.** Each trap-2 case shall pass at least 2 of 3 runs with its rule installed.
- **REQ-6.** `docs/design/eval-results-4.6.md` shall hold one row per trap-2 rule with the
  with-arm and without-arm counts and one of three readings: passes without on both traps,
  separates on trap 2, or fails even with. [untested: prose, verified by reading]
- **REQ-7.** The sprint shall change no rule text on its trap-2 numbers; a rule whose both traps
  pass without it shall be named in the ROADMAP as a cut candidate for the next plan. [untested:
  by record C8, verified by reading the diff]

### The Gemfile line (S13-T3)

- **REQ-8.** `stacks/rails/.claude/rules/gemfile.md` shall make its lock-diff step conditional
  on `bundle install` having run, within lint check 14's byte limit.

### The elder's step 1 (S13-T4)

- **REQ-9.** `scripts/trace-tools.sh` shall print, per run, whether the trace carries a `Read`
  of `PROJECT_MAP.md` in the main session or a subagent. [untested: verified against the kept
  baseline traces, counted by hand once]
- **REQ-10.** While an attempted step-1 sentence reads the map in fewer than 10 of 15 runs, or
  costs one right answer, `agents/grandfather.md` shall be unchanged and decision 0001 shall
  carry the attempt's rates. [untested: the results doc holds the rates; the owner's go is
  rule 6]
- **REQ-11.** When an attempted step-1 sentence reads the map in at least 10 of 15 runs with
  every answer still right and the owner says go, `agents/grandfather.md` shall carry that
  sentence and no other change. [untested: as REQ-10]

### The "wip" history (S13-T5)

- **REQ-12.** When run with `--wip`, the XL generator shall write the same files with the same
  tree hash per commit as without it, with every commit message "wip".
- **REQ-13.** The ROADMAP shall record eve's loss when fewer projects carry a map as open, with
  the reason that no multi-project fixture exists. [untested: prose, verified by reading]

### Housekeeping and the roadmap after (S13-T6, S13-T7)

- **REQ-14.** The ROADMAP shall record each of C12's rows D1 to D5 as removed or kept, with the
  date, each on the owner's own yes. [untested: prose, verified by reading]
- **REQ-15.** The ROADMAP's "Still open after Sprint 13" shall list the cut candidates, eve's
  unmeasured loss, what S13-T4 could not settle and what the three releases' "What using it
  for real showed" sections name, each item citing a file and section. [untested: prose,
  verified by reading]

## Release steps (not requirements)

- T2 stops after its table for the owner to read before T3 starts.
- T4's keep, and each T6 row, are the owner's own yes.
- The gate (`/shipkit:ship second-traps`) answers `READY`; the report is committed.
- Release as 4.6.0; the sprint exit checklist holds (the release run about $16, C13); the pull
  request is merged after a green check; tag `v4.6.0`; the owner's cache update (C12 D5) is its
  own yes; D4 after the tag.

## Out of scope

Cutting or trimming a rule; a multi-project fixture; a second real run; a draft-tolerant
`spec-check`; a new skill or agent; anything C12 does not name.
