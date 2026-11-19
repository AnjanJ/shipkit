# Intake: misses to checks

> Intake taken on 2026-11-19.

## Request

Sprint 32 of `docs/plans/verifier-sprint-plan.md`, "Misses become checks", approved by the owner
on 2026-11-17 ("yes to all") and amended on 2026-11-18. Four pieces, and one candidate:

1. S32-T1, reviewer cases from real misses: five tuning cases on the shared refunds fixture
   (`helper-only`, `skipped-test`, `comment-cite`, `weakened-req`, `waiver-added`) and two
   held-out cases on a different feature, a notes export (`helper-only`, `skipped-test`), whose
   set in `scripts/evals-map.tsv` is `holdout`.
2. S32-T2, a second round that builds on the first: two reviewer cases, `second-round` and
   `stale-met`, each with an earlier report under `.shipkit/releases/`.
3. S32-T3, checks that a diff triggers: `.shipkit/checks.md`, a new
   `plugins/shipkit/scripts/checks-match.sh` that reads the file from the base ref, its `--lint`,
   four seeded items, one eval case `check-triggered`, and model-free smoke checks.
4. S32-T4, the second escape of a kind becomes a check: one escape case, `second-of-a-kind`.
5. The candidate, from `numbers-as-data/tasks.md`, "Found on the way": CI enforces the number of
   processes the briefing starts on smoke check 30's fixture, and goes on printing the time.

Every sentence the reviewer and the escape skill will gain is written into this spec's design,
word for word, and waits for Sprint 35. The owner's words on how to do it, from 2026-11-17:
"lets put things that would cost as for the end of development", and "do what you think is
best". So this sprint starts no paid model run and changes no existing skill, agent or rule file
(the plan's rules 33 and 34).

## Serves goal

None. There is no `.shipkit/product.md` (`.shipkit/` holds `decisions/`, `releases/`, `specs/`
and `state.md`). The plan's goal for the sprint is the nearest statement: "the cases that grade
the reviewer on real misses exist and their graders are proven, the checks file and its script
work, and every sentence the reviewer and the escape skill will gain is written down, waiting
for its baseline."

## Conflicts found

None that stops the work. Two findings come first, because each changes what has to be built.

- **`holdout` is a label nothing reads.** The plan's rule 31 says a held-out case runs at a
  release run or on the owner's word, and S32-T1 says only that the two cases' set in the map is
  `holdout`. No script names the word (`git grep holdout` over `scripts/` and
  `plugins/shipkit/scripts/` finds nothing). `scripts/evals-for-diff.sh:29-38` reads the case and
  the paths and never the set, so it would pick a held-out case for any diff that touches the
  reviewer. `scripts/evals.sh:53` runs every case named `reviewer-*` under `--group reviewer`.
  `scripts/lint.py:654-657` accepts any word in the column. `scripts/evals-ledger.sh:93` writes
  `watch` or `tune` from the runs per case, so a held-out row would be logged as one of those.
  This is the second question below.
- **The eleven cases may not fit.** `plugins/shipkit/evals/` is 190,556 of 204,800 bytes: 14,244
  of room. Today's reviewer cases are 820 to 1,116 bytes each, `escape/missing-req` is 3,388, and
  `lib/review-fixture.sh` is 6,078 and writes the refunds feature only (lines 13 to 90). A rough
  sum for eleven cases, five new variants, a second feature, two earlier reports and a checks
  file is 16,700 to 20,500 bytes. It is an estimate from sizes, not a measurement. The ceiling
  does not rise in this plan (decision 0005; the plan's S31-T4, "with no raise"); see
  assumption 2.

Non-goals: none recorded, since there is no product file.

Open specs, three, each touched and none contradicted:

- `honest-evidence`. Its REQ-36 (task T10, waiting for Sprint 35) puts every line `spec-diff.sh`
  prints into the ship report under the heading "Requirements changed on this branch". S32-T1's
  waiting text gives the reviewer a section of the same name that reads the same script. Both
  land in one report in Sprint 35; see assumption 4. Its out-of-scope line, "making
  `SKIPPED-CITE` or `CITED-ELSEWHERE` a gap by itself", is about its scripts; the cases here
  grade the reviewer's verdict and change no script's exit status. Its seventh record, "On CI
  the briefing's time is printed, not enforced", stands again since 2026-11-19; the candidate
  enforces a count and leaves the time printed, so it does not reverse that record.
- `numbers-as-data`. It says "`holdout` is Sprint 32's and is not written here" and lists the
  eleven cases as out of its scope, so both are this spec's. Its REQ-16 (half a second on the
  owner's machine) and REQ-18 (CI sets `SMOKE_TIMING` to `report`) are left as they are.
- `gate-as-software`. Its `> Paths:` holds `plugins/shipkit/scripts/`, where `checks-match.sh`
  is a new file. Its fifth record, "The last tag judges this repository's gates", and decision
  0007 are followed: the checks file is read from the base ref.

Decisions touched and not contradicted:

- `.shipkit/decisions/0005-evals-home.md`: the evals stay inside the plugin and check 17's
  ceiling stays the limit. Its reversal condition has not come true.
- `.shipkit/decisions/0006-main-session-starts-every-agent.md`: no second reviewer is added, and
  the reviewer will run a script, not start an agent.
- `.shipkit/decisions/0008-trap2-cases-stay.md`: no trap-2 case is added, so its 24 KB limit is
  not approached by this sprint.
- `decisions-bind/design.md`, "The ceiling stays, and the reviewer fixtures share one script":
  the held-out feature goes into the shared script unless a measurement says otherwise
  (assumption 3).
- `review-and-ship/design.md`, "An earlier day's report is named, not removed": it is why an
  earlier report can be on disk for a second round. All 26 files in `.shipkit/releases/` read
  `READY`; a `NOT READY` report is left untracked, so the fixtures' earlier reports are written
  by hand.

Nothing outside the plan mentions `.shipkit/checks.md` or `checks-match.sh` (`git grep` over the
whole tree), and nothing today counts the processes the briefing starts (searched `scripts/`,
`plugins/shipkit/scripts/` and `docs/`; smoke checks 30 and 112 measure CPU time only).

## Answers

1. Does Sprint 32 take the candidate, a smoke check that counts the processes the briefing
   starts on check 30's fixture and that CI enforces, as a fifth task done last, or does it wait
   for a later sprint?
   **Yes, it joins** (the owner, 2026-11-19, "yes to all"). It is the sprint's fifth task and is
   done last. If the sprint runs long it moves, unchanged, to the start of Sprint 33.
2. Does Sprint 32 make `holdout` do something, beyond the label in the map:
   `evals-for-diff.sh` and `evals.sh --group` leave a held-out case out unless asked, the ledger
   writes `holdout`, and lint accepts only `tune`, `watch` and `holdout`?
   **Yes** (the owner, 2026-11-19, "yes to all"). It is added to S32-T1, and reaches three files
   beyond the plan's list: `scripts/evals-for-diff.sh`, `scripts/evals-ledger.sh` and
   `scripts/lint.py`.

## Assumptions made

1. **No paid run, and no existing skill, agent, rule or overlay file changes** (rules 33 and
   34). `agents/reviewer.md` and the escape skill stay byte for byte; their new sentences go
   into `design.md` as waiting text. `scripts/evals.sh` runs only with a stand-in for the tool.
2. **The ceiling stays at 204,800 bytes.** How the fixtures are made small is the design's
   choice. The first tuning case and the first held-out case are built and measured before the
   rest are written; if the projection passes the ceiling, the work stops and the owner gets the
   measured numbers before any case is cut.
3. **The held-out feature is a second body in `lib/review-fixture.sh`,** chosen by an argument,
   as the four variants are today (`VARIANT=${1:-complete}`, line 9), not a second script.
4. **The reviewer's "Requirements changed on this branch" section stays in the waiting text,**
   as the plan has it, and the design says how it differs from the ship report's block of the
   same name (`honest-evidence/REQ-36`). `weakened-req` and `waiver-added` stay as cases.
5. **The escape fixture's earlier record is written by hand** in the shape the escape skill
   writes, `.shipkit/escapes/NNNN-<slug>.md` (`skills/escape/SKILL.md:54`). This repository
   holds no escape record.
6. **Each real miss is read against its source before it becomes a case or a check item** (rule
   25): `field-notes-5.2.md` §9 for the second round, the 5.2 run's REQ-5 and REQ-6 for
   `helper-only`, and the four sources of the seeded check items.
7. **`checks-match.sh` is POSIX `sh` with awk and git only and changes no file,** as
   `honest-evidence/REQ-29` asks of `spec-diff.sh`.
8. **New smoke checks are numbered from 116,** each written first and shown red, each with a
   line in `registry()`, none starting a model.
9. **Every new case gets a row in `scripts/evals-map.tsv` and a line in
   `docs/design/eval-cases.md`,** and its grader goes through `node` with one reply it must pass
   and one it must fail (rules 18 and 23).
10. **This spec has a `> Tests:` line,** written by hand: `scripts/smoke.sh`.
11. **The work is on a branch, `sprint-32/misses-to-checks`,** made when the spec starts.

## Out of scope

- Any paid model run, and any change to an existing skill, agent, rule or overlay file. The
  baselines, the after-runs and the reviewer's "Checks this diff triggered" section are Sprint
  35's.
- Raising check 17's ceiling, or moving an eval case out of the plugin.
- A second reviewer.
- Changing the briefing's half-second limit, or taking `SMOKE_TIMING` out of the CI job again.
- Writing a check item into `.shipkit/checks.md` from an escape: that is the escape skill's
  waiting text, applied in Sprint 35.
- The probes, the property tests and `red-check.sh`: Sprint 33.
