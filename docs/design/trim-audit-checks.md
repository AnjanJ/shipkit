# Trim audit: the checks — every smoke check and eval case, and what it earns

> Written 2026-11-20, in Sprint 34 (`.shipkit/specs/running-the-change/`, T8, REQ-30 to REQ-33),
> from `scripts/smoke.sh` and `scripts/evals-map.tsv` at `1f3ace4`. Smoke check 133 holds the table
> to both lists: a new check or case without a row fails the model-free suite.

The 4.0 trim audit pruned what loads into a session and never looked at the suite. This one
does, before Sprint 35 pays to run it: one row for each of the 137 smoke checks in `registry()`
and each of the 78 eval cases, saying when it last caught a real defect, what else proves the
same requirements, and what it costs to run. Every release from 5.4.0 on brings it up to date and
puts its candidates to the owner (the plan's release task).

## How each column was filled

- **Kind** and **Label**: `smoke` with the registry's line (number and name), or `eval` with the
  case as `scripts/evals-map.tsv` names it.
- **Last failed on a real defect**: the newest release in which the check or case failed and the
  failure led to a fix in the product, or `never`. Read from the `fix` commits of `git log`
  (52, of which 23 name a check, a case or a failure in their message), `CHANGELOG.md`,
  `docs/design/eval-ledger.tsv` and `docs/design/eval-history.md`. Two smoke checks have one:
  `30 briefing` failed the 4.3.0 exit checklist on a slow `spec-check.sh` (`5ded745`, in
  v4.3.0), and `29 ship-gate` failed twice on the 5.0.0 release tree when the reviewer's reply
  had no verdict line (`41716d7`, in v5.0.0). Not counted: a check written first and red before
  its feature (that is the feature missing, not a defect caught), a check that failed on its own
  timing or wording (`112 briefing-cost` on a loaded machine), and a case that missed because of
  the model and passed alone (`grandfather-xl-drift` in 4.3.0) or whose grader was fixed
  (`trap2-*`, 5.0.0). No eval case has a recorded failure on a product defect, so every case
  reads `never`. `never` means no such failure is on record, not that none happened: before
  5.1.0 the release runs kept no ledger.
- **Also covered by**: every other smoke check and eval case that cites one of the same
  `<slug>/REQ-N` (in a smoke check's block, or anywhere in a case's folder), as `spec-check.sh`
  counts a citation; `nothing` when none does or when the row cites no requirement. 12 smoke
  checks and 61 eval cases cite none in that form: the older cases say what they prove in
  prose.
- **Cost**: for a smoke check, the seconds of one model-free run on 2026-11-20 (macOS, load
  average 2.7 to 5.8, 129 s in all), each output line's time given to the check that printed it; `0.0 s` is under 0.05 s, a check that only reads files. `133 trim-audit` was timed alone, since it was written after that run.
  For the 16 model checks, `$0.22`: an even share of the plan's $3 to $4 for one full run
  (S35-T4), an estimate, not a measure. For an eval case, its runs (3, or 5 where `case.yaml`
  says so) at the 5.2.0 release run's rate, $21.25 for 227 runs, about $0.094 a run. The 78
  cases come to $24.88.
- **Candidate**: one of the plan's three rules (S34-T3): a check that never failed and whose
  every cited requirement another check or case also cites; a text-only check with a behaviour
  check beside it; a case at full score in every ledger row whose requirements a script also
  holds. `kept (0008)` for the sixteen `trap2-*` cases, which decision 0008 keeps. A rule
  matched by citation is only the start: a cut also needs the covering check to prove the same
  behaviour, which is read by hand.
- **Cut**: empty, or `cut YYYY-MM-DD`, the date of the owner's yes. A cut row stays, so the next
  pass sees what went.

## What it found

- **Two candidates of 215.** The rules are strict on purpose: a check goes only if every
  requirement it cites stays cited by something that proves it.
  - `2b rules-fallback`, a model check ($0.22 a full run): it and `8b incomplete-install` both
    cite `install-lifecycle/REQ-5` ("If a required rule is absent from disk, then the session
    hook shall inject it"). 8b proves it without a model: the deleted rule is named and its text
    is injected. 2b adds only that the model receives the injected text, which `1 rules-inject`
    shows for the same path.
  - `9c managed-block` (0.5 s): it shares `install-lifecycle/REQ-10` with `9 stack-section`,
    but check 9 proves the first half of REQ-10 (content outside the block survives) and only 9c
    the second (an edit inside the block is not overwritten without a diff and a question). Its
    citation cannot move, so it should stay.
- **Cut on the owner's yes, 2026-11-20:** `2b rules-fallback`. Its row stays, marked cut; `install-lifecycle/REQ-5` is still cited by `8b incomplete-install`, and the full smoke run has 15 model checks, about $0.22 less.
- **Kept on the owner's word, 2026-11-20:** `9c managed-block`, for the reason above.
- **Where the time goes.** The model-free suite took 129 s. Five checks take 42 s of it:
  `112 briefing-cost` 11.5 s, `124 prop` 9.7 s, `121 briefing-commands` 7.8 s,
  `39 xl-scaffold` 7.3 s, `47 rule-cases` 6.0 s. None is a candidate: each is the only proof of
  what it times, measures or scaffolds.
- **Where the money goes.** The eval cases, $24.88 a release run, the sixteen `trap2-*` cases
  among them (decision 0008 keeps them and ties its reversal to their own cost). The model
  smoke checks, about $3.50 a full run. The table finds no eval case to cut: no case with a
  full ledger has its requirements held by a script in a form this audit can read.
- **What the audit cannot see.** Most eval cases name what they prove in prose, so "also
  covered by" reads `nothing` for them even where a smoke check holds the same rule. The next
  pass would see more if each case named its requirement as `<slug>/REQ-N` in `case.yaml`.

## The table

<!-- audit:begin -->
| Kind | Label | Last failed on a real defect | Also covered by | Cost | Candidate | Cut |
|---|---|---|---|---|---|---|
| smoke | 1 rules-inject | never | nothing | $0.22 | no |  |
| smoke | 2 rules-skip | never | nothing | $0.22 | no |  |
| smoke | 2b rules-fallback | never | 8b incomplete-install | $0.22 | yes: never failed, its requirements covered elsewhere | cut 2026-11-20 |
| smoke | 3 plugin-root | never | nothing | $0.22 | no |  |
| smoke | 4 agents | never | nothing | $0.22 | no |  |
| smoke | 5 workflows-skills | never | nothing | $0.22 | no |  |
| smoke | 5b namespaces | never | nothing | $0.22 | no |  |
| smoke | 6 hook-cap | never | nothing | $0.22 | no |  |
| smoke | 7 install-scripts | never | nothing | 0.6 s | no |  |
| smoke | 8 stale-nudge | never | nothing | 0.4 s | no |  |
| smoke | 8b incomplete-install | never | 2b rules-fallback | 0.7 s | no |  |
| smoke | 8c reconciliation | never | nothing | 0.5 s | no |  |
| smoke | 8d legacy-stamp | never | nothing | 0.5 s | no |  |
| smoke | 8e unstamped | never | nothing | 0.3 s | no |  |
| smoke | 9 stack-section | never | 9c managed-block | 1.2 s | no |  |
| smoke | 10 freshness | never | nothing | 0.3 s | no |  |
| smoke | 11 spec-staleness | never | nothing | 1.1 s | no |  |
| smoke | 9b user-skill | never | nothing | 0.7 s | no |  |
| smoke | 9c managed-block | never | 9 stack-section | 0.5 s | yes: never failed, its requirements covered elsewhere |  |
| smoke | 11b staleness-day | never | nothing | 0.8 s | no |  |
| smoke | 17 unsetup | never | nothing | 2.4 s | no |  |
| smoke | 18 commit-guard | never | nothing | 0.2 s | no |  |
| smoke | 19 spec-check-reqs | never | 49 pre33-specs | 0.7 s | no |  |
| smoke | 20 spec-check-tasks | never | nothing | 0.5 s | no |  |
| smoke | 21 spec-drift | never | nothing | 3.2 s | no |  |
| smoke | 22 spec-new-format | never | nothing | $0.22 | no |  |
| smoke | 23 product-file | never | nothing | $0.22 | no |  |
| smoke | 24 registry-columns | never | nothing | 0.0 s | no |  |
| smoke | 25 brief | never | 26 brief-verify, brief-binds | 0.4 s | no |  |
| smoke | 26 brief-verify | never | 25 brief, 53 shipkit-allowed | 0.7 s | no |  |
| smoke | 27 reviewer-tools | never | nothing | 0.0 s | no |  |
| smoke | 28 as-shipped | never | nothing | 0.1 s | no |  |
| smoke | 29 ship-gate | 5.0.0 | 83 superseded-report | $0.22 | no |  |
| smoke | 30 briefing | 4.3.0 | nothing | 1.6 s | no |  |
| smoke | 31 handoff-file | never | nothing | $0.22 | no |  |
| smoke | 32 handoff-loop | never | nothing | $0.22 | no |  |
| smoke | 33 compact-reminder | never | nothing | 0.9 s | no |  |
| smoke | 34 fired-if-template | never | nothing | 0.0 s | no |  |
| smoke | 35 decision-check | never | nothing | 0.2 s | no |  |
| smoke | 36 portfolio-digest | never | nothing | 0.6 s | no |  |
| smoke | 37 digest-old | never | nothing | 0.3 s | no |  |
| smoke | 38 ledger-gen | never | nothing | 3.2 s | no |  |
| smoke | 39 xl-scaffold | never | nothing | 7.3 s | no |  |
| smoke | 40 trace-tools | never | nothing | 0.1 s | no |  |
| smoke | 41 no-map-silent | never | nothing | 0.3 s | no |  |
| smoke | 42 lint-negative | never | nothing | 0.6 s | no |  |
| smoke | 43 with-rule | never | nothing | 0.2 s | no |  |
| smoke | 44 eval-inject | never | nothing | 0.0 s | no |  |
| smoke | 45 stack-gen | never | nothing | 0.8 s | no |  |
| smoke | 46 evals-group | never | nothing | 0.4 s | no |  |
| smoke | 47 rule-cases | never | nothing | 6.0 s | no |  |
| smoke | 48 pending-test | never | nothing | 0.2 s | no |  |
| smoke | 49 pre33-specs | never | 19 spec-check-reqs | 1.0 s | no |  |
| smoke | 50 headless-questions | never | nothing | $0.22 | no |  |
| smoke | 51 version-and-goal | never | nothing | 2.6 s | no |  |
| smoke | 52 fired-if-early | never | nothing | 0.1 s | no |  |
| smoke | 53 shipkit-allowed | never | 26 brief-verify | 0.3 s | no |  |
| smoke | 54 scoped-loading | never | nothing | $0.22 | no |  |
| smoke | 55 spec-check-draft | never | nothing | 0.4 s | no |  |
| smoke | 56 plugin-root-restore | never | nothing | 0.0 s | no |  |
| smoke | 57 dotfile-paragraph | never | nothing | 0.0 s | no |  |
| smoke | 58 cuts-recorded | never | nothing | 0.1 s | no |  |
| smoke | 59 portfolio-gen | never | nothing | 2.2 s | no |  |
| smoke | 60 heading-seen | never | nothing | 1.0 s | no |  |
| smoke | 61 same-named | never | nothing | 0.6 s | no |  |
| smoke | 62 plugin-root-installed | never | nothing | 0.8 s | no |  |
| smoke | 63 context-cost | never | nothing | 1.4 s | no |  |
| smoke | 64 opt-out | never | nothing | $0.22 | no |  |
| smoke | 65 skills-merged | never | nothing | 0.6 s | no |  |
| smoke | 66 agents-four | never | nothing | 0.3 s | no |  |
| smoke | 67 skills-flag | never | nothing | 1.8 s | no |  |
| smoke | 68 appends-trimmed | never | nothing | 0.1 s | no |  |
| smoke | 69 skills-cut | never | nothing | 0.7 s | no |  |
| smoke | 70 report-shapes | never | nothing | 0.0 s | no |  |
| smoke | 71 brief-cites | never | nothing | 0.1 s | no |  |
| smoke | 72 stack-skill-allowed | never | nothing | 0.4 s | no |  |
| smoke | 73 reviewer-skills | never | nothing | 0.0 s | no |  |
| smoke | 74 ship-capture | never | nothing | 0.0 s | no |  |
| smoke | 75 setup-rule-count | never | nothing | 0.0 s | no |  |
| smoke | 76 ship-retry | never | nothing | 0.0 s | no |  |
| smoke | 77 reviewer-fixture | never | nothing | 0.0 s | no |  |
| smoke | 78 map-read-grep | never | nothing | 0.2 s | no |  |
| smoke | 79 django-only | never | nothing | 3.0 s | no |  |
| smoke | 80 stamp-dates | never | nothing | 0.0 s | no |  |
| smoke | 81 section-clean | never | nothing | 2.9 s | no |  |
| smoke | 82 fired-if-tracked | never | nothing | 0.0 s | no |  |
| smoke | 83 superseded-report | never | 29 ship-gate | 0.0 s | no |  |
| smoke | 84 walk-sentence | never | nothing | 0.0 s | no |  |
| smoke | 85 ship-write-path | never | nothing | 0.0 s | no |  |
| smoke | 86 elixir-app | never | nothing | 0.4 s | no |  |
| smoke | 87 stray-status | never | nothing | 0.2 s | no |  |
| smoke | 88 setup-files | never | nothing | 0.9 s | no |  |
| smoke | 89 reviewer-marks | never | nothing | 0.0 s | no |  |
| smoke | 90 pinned-toolchain | never | nothing | 0.3 s | no |  |
| smoke | 91 git-grep | never | nothing | 0.1 s | no |  |
| smoke | 92 wait-probe | never | nothing | 0.2 s | no |  |
| smoke | 93 stale-nesting | never | nothing | 0.7 s | no |  |
| smoke | 94 goldfish-agent | never | nothing | 0.1 s | no |  |
| smoke | 95 spec-goldfish-step | never | nothing | 0.1 s | no |  |
| smoke | 96 goldfish-fixture | never | nothing | 0.2 s | no |  |
| smoke | 97 smoke-args | never | nothing | 0.2 s | no |  |
| smoke | 98 ci-smoke-job | never | nothing | 0.0 s | no |  |
| smoke | 99 evidence-line | never | nothing | 0.2 s | no |  |
| smoke | 100 tests-line | never | nothing | 0.4 s | no |  |
| smoke | 101 skipped-cite | never | nothing | 0.1 s | no |  |
| smoke | 102 spec-diff | never | nothing | 0.6 s | no |  |
| smoke | 103 spec-edited | never | nothing | 0.4 s | no |  |
| smoke | 104 text-label | never | nothing | 0.0 s | no |  |
| smoke | 105 timing-switch | never | nothing | 0.0 s | no |  |
| smoke | 106 test-command | never | nothing | 1.4 s | no |  |
| smoke | 107 ship-check | never | nothing | 4.1 s | no |  |
| smoke | 108 release-check | never | nothing | 0.9 s | no |  |
| smoke | 109 judge | never | nothing | 0.9 s | no |  |
| smoke | 110 eval-ledger | never | nothing | 1.8 s | no |  |
| smoke | 111 ledger-backfill | never | nothing | 0.1 s | no |  |
| smoke | 112 briefing-cost | never | nothing | 11.5 s | no |  |
| smoke | 113 evals-for-diff | never | nothing | 1.4 s | no |  |
| smoke | 114 eval-room | never | nothing | 0.1 s | no |  |
| smoke | 115 ledger-fired-if | never | nothing | 1.5 s | no |  |
| smoke | 116 holdout-kept-out | never | nothing | 1.3 s | no |  |
| smoke | 117 grader-both-ways | never | nothing | 0.7 s | no |  |
| smoke | 118 reviewer-trees | never | nothing | 3.5 s | no |  |
| smoke | 119 checks-match | never | nothing | 0.6 s | no |  |
| smoke | 120 escape-second | never | nothing | 0.2 s | no |  |
| smoke | 121 briefing-commands | never | nothing | 7.8 s | no |  |
| smoke | 122 kind-fixtures | never | nothing | 1.4 s | no |  |
| smoke | 123 kind-reader | never | nothing | 0.2 s | no |  |
| smoke | 124 prop | never | nothing | 9.7 s | no |  |
| smoke | 125 prop-ci | never | nothing | 0.0 s | no |  |
| smoke | 126 red-check | never | nothing | 2.5 s | no |  |
| smoke | 127 brief-escapes | never | nothing | 0.1 s | no |  |
| smoke | 128 verify-run | never | nothing | 5.4 s | no |  |
| smoke | 129 verify-run-ten | never | nothing | 3.9 s | no |  |
| smoke | 130 verify-skills | never | nothing | 0.8 s | no |  |
| smoke | 131 commit-gate | never | nothing | 0.8 s | no |  |
| smoke | 132 commit-gate-hook | never | nothing | 0.1 s | no |  |
| smoke | 133 trim-audit | never | nothing | 0.1 s | no |  |
| eval | brief-binds | never | 25 brief | $0.28 | no |  |
| eval | digest-attention | never | nothing | $0.28 | no |  |
| eval | escape-missing-req | never | nothing | $0.28 | no |  |
| eval | escape-second-of-a-kind | never | nothing | $0.28 | no |  |
| eval | eve-consolidate | never | nothing | $0.28 | no |  |
| eval | eve-jobs | never | eve-payments, eve-why | $0.28 | no |  |
| eval | eve-matrix | never | nothing | $0.28 | no |  |
| eval | eve-payments | never | eve-jobs, eve-why | $0.28 | no |  |
| eval | eve-why | never | eve-jobs, eve-payments | $0.28 | no |  |
| eval | eve-why-reworded | never | nothing | $0.28 | no |  |
| eval | goldfish-clean | never | nothing | $0.28 | no |  |
| eval | goldfish-gap | never | nothing | $0.28 | no |  |
| eval | grandfather-xl-drift | never | nothing | $0.28 | no |  |
| eval | grandfather-xl-explain | never | nothing | $0.28 | no |  |
| eval | grandfather-xl-gap | never | nothing | $0.28 | no |  |
| eval | grandfather-xl-history | never | nothing | $0.28 | no |  |
| eval | grandfather-xl-lookup | never | nothing | $0.28 | no |  |
| eval | grandfather-drift | never | nothing | $0.28 | no |  |
| eval | grandfather-explain | never | nothing | $0.28 | no |  |
| eval | grandfather-gap | never | nothing | $0.28 | no |  |
| eval | grandfather-lookup | never | nothing | $0.28 | no |  |
| eval | hello | never | nothing | $0.28 | no |  |
| eval | holdout-reviewer-helper-only | never | nothing | $0.28 | no |  |
| eval | holdout-reviewer-skipped-test | never | nothing | $0.28 | no |  |
| eval | intake-answered | never | nothing | $0.28 | no |  |
| eval | intake-limit | never | nothing | $0.28 | no |  |
| eval | intake-nongoal | never | nothing | $0.28 | no |  |
| eval | intake-trivial | never | nothing | $0.28 | no |  |
| eval | reviewer-all-met | never | reviewer-missing-req | $0.28 | no |  |
| eval | reviewer-check-triggered | never | nothing | $0.28 | no |  |
| eval | reviewer-comment-cite | never | nothing | $0.28 | no |  |
| eval | reviewer-decision-unbuilt | never | reviewer-rejected-alternative | $0.28 | no |  |
| eval | reviewer-helper-only | never | nothing | $0.28 | no |  |
| eval | reviewer-missing-req | never | reviewer-all-met | $0.28 | no |  |
| eval | reviewer-rejected-alternative | never | reviewer-decision-unbuilt | $0.28 | no |  |
| eval | reviewer-second-round | never | nothing | $0.28 | no |  |
| eval | reviewer-skipped-test | never | nothing | $0.28 | no |  |
| eval | reviewer-stale-met | never | nothing | $0.28 | no |  |
| eval | reviewer-waiver-added | never | nothing | $0.28 | no |  |
| eval | reviewer-weakened-req | never | nothing | $0.28 | no |  |
| eval | rules-care | never | nothing | $0.28 | no |  |
| eval | rules-decision | never | nothing | $0.28 | no |  |
| eval | rules-nontrivial | never | nothing | $0.28 | no |  |
| eval | rules-trivial | never | nothing | $0.28 | no |  |
| eval | scoped-dependencies | never | nothing | $0.28 | no |  |
| eval | scoped-migrations | never | nothing | $0.47 | no |  |
| eval | scoped-monorepo | never | nothing | $0.28 | no |  |
| eval | scoped-testing | never | nothing | $0.28 | no |  |
| eval | scoped-ui-ux | never | nothing | $0.47 | no |  |
| eval | stacks-data | never | nothing | $0.28 | no |  |
| eval | stacks-experiments | never | nothing | $0.28 | no |  |
| eval | stacks-gemfile | never | nothing | $0.28 | no |  |
| eval | stacks-go-mod | never | nothing | $0.28 | no |  |
| eval | stacks-hotwire | never | nothing | $0.47 | no |  |
| eval | stacks-jobs | never | nothing | $0.28 | no |  |
| eval | stacks-liveview | never | nothing | $0.47 | no |  |
| eval | stacks-mix-deps | never | nothing | $0.47 | no |  |
| eval | stacks-notebooks | never | nothing | $0.47 | no |  |
| eval | stacks-package-json | never | nothing | $0.28 | no |  |
| eval | stacks-pyproject | never | nothing | $0.47 | no |  |
| eval | stacks-rails | never | nothing | $0.28 | no |  |
| eval | stacks-react | never | nothing | $0.47 | no |  |
| eval | trap2-data | never | nothing | $0.28 | kept (0008) |  |
| eval | trap2-experiments | never | nothing | $0.28 | kept (0008) |  |
| eval | trap2-gemfile | never | nothing | $0.28 | kept (0008) |  |
| eval | trap2-go-mod | never | nothing | $0.28 | kept (0008) |  |
| eval | trap2-hotwire | never | nothing | $0.47 | kept (0008) |  |
| eval | trap2-liveview | never | nothing | $0.47 | kept (0008) |  |
| eval | trap2-migrations | never | nothing | $0.47 | kept (0008) |  |
| eval | trap2-mix-deps | never | nothing | $0.47 | kept (0008) |  |
| eval | trap2-monorepo | never | nothing | $0.28 | kept (0008) |  |
| eval | trap2-notebooks | never | nothing | $0.47 | kept (0008) |  |
| eval | trap2-package-json | never | nothing | $0.28 | kept (0008) |  |
| eval | trap2-pyproject | never | nothing | $0.47 | kept (0008) |  |
| eval | trap2-rails | never | nothing | $0.28 | kept (0008) |  |
| eval | trap2-react | never | nothing | $0.47 | kept (0008) |  |
| eval | trap2-testing | never | nothing | $0.28 | kept (0008) |  |
| eval | trap2-ui-ux | never | nothing | $0.47 | kept (0008) |  |
<!-- audit:end -->
