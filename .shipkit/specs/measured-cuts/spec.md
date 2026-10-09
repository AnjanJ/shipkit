# Spec: What the numbers allow (Sprint 15, release 4.8.0)

> Spec accepted at commit `ce58c95` on sprint-15/measured-cuts (2026-10-09).
> Status: open
> Paths: plugins/shipkit/rules/, plugins/shipkit/stacks/, plugins/shipkit/skills/intake/, plugins/shipkit/evals/README.md, scripts/, docs/design/, docs/plans/portfolio-sprint-plan.md, .shipkit/decisions/0001-project-map-default.md, .shipkit/releases/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Act on the measurements the rule files carry: a line the model followed unaided on two named
traps, on two days, comes out of the file, and the case that measured it stays as the watch
that brings it back; a file whose whole body is its two measured lines, and the one at the
threshold, stay as a statement of standards by record. Give the intake the sentence its grader
already asks for. Close the elder's step 0 with the numbers already in hand. Remove the two
cache directories the owner named.

Source: `docs/plans/portfolio-sprint-plan.md`, Sprint 15 (S15-T1 to S15-T4), decisions E1, E2,
E3, E12 (F1, F2); `docs/design/eval-results-4.2.md` reading 1; `docs/design/eval-results-4.6.md`
"The three readings" and "The elder's step 1"; `docs/design/eval-history.md` "Release run 4.7.0".

## User stories

- As the owner, I want every line a rule file carries to have earned its bytes on a
  measurement, or to be kept by a record that says why, so that the files are standards and
  not habits.
- As the owner, I want a cut line to come back on its own evidence — a release run where the
  model stops following it — so that a cut is reversible by the same number that justified it.
- As a user of the intake, I want an assumption drawn from a file to name the file and line,
  so that I can check it instead of trusting it.

## Requirements (EARS)

### The cuts, re-measured (S15-T1)

- **REQ-1.** The seven rule files named in the design's table (`hotwire`, `liveview`,
  `mix-deps`, `notebooks`, `pyproject`, `react`, `ui-ux`) shall no longer carry their two
  measured lines, and every other line of each file shall be unchanged.
- **REQ-2.** While a measured line is out of its file, the case that measured it (its trap-1
  case under `scoped/` or `stacks/` and its trap-2 case under `trap2/`) shall remain in the suite
  and run against the trimmed file, so that a release run reports when the model stops following
  the line unaided.
- **REQ-3.** The four files whose two measured lines are their whole body (`migrations`,
  `monorepo`, `testing`, `package-json`) and `rails`, whose second trap sits at the threshold,
  shall keep their lines, recorded as standards in the design. [untested: closed by record]
- **REQ-4.** The evals README shall name the cut files and the watch rule — a case below 2 of 3
  in a release run returns its line. [untested: prose, verified by reading and by smoke check
  58's grep]

### The intake's assumption names its file (S15-T2)

- **REQ-5.** When the intake writes down an assumption because a file already answers the
  question, the assumption shall name that file and the line it comes from. [untested: prose
  in `skills/intake/SKILL.md`, grepped by smoke check 58; the intake group is run once as the
  watch]

### The elder's step 0, closed by record (S15-T3)

- **REQ-6.** Decision 0001 shall carry an appended note that closes the step-0 question with
  the numbers in hand: the read rate and answer rate of 4.6.0's 45 runs, the one case where the
  map decided an answer, and the token cost of a read from the 4.0.0 XL baseline. [untested:
  a record, verified by reading]

## Release steps (not requirements)

- F1 and F2: the `3.1.0` and `4.5.0` directories in `~/.claude/plugins/cache/shipkit/shipkit/`,
  each its own yes, each only after the owner's interactive session reports `4.7.0`; the
  commands and output in the S15-T4 commit message; the ROADMAP records each row.
- The ROADMAP's cut-candidates, elder-step-0 and intake items carry their 4.8.0 notes.
- The gate (`/shipkit:ship measured-cuts`) answers `READY`; the report is committed.
- Release as 4.8.0; the sprint exit checklist holds; the release run is recorded in
  `docs/design/eval-history.md`; the pull request is merged after a green check; tag `v4.8.0`;
  the owner's cache update (F5) is its own yes.

## Out of scope

The six files whose cases separated (`data`, `experiments`, `gemfile`, `go-mod`,
`dependencies`, `jobs`); any grader or fixture; the elders' text; the portfolio fixture and the
second real run; `digest/attention`'s shape under `-j 4`.
