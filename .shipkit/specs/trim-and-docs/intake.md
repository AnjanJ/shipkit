# Intake: Trim and tell the story

> Intake taken on 2026-10-06.

## Request
Sprint 7 of the quality-gate plan: an audit table that proposes, for every path-scoped rule,
every stack overlay rule, every `shipkit-workflows` skill and the project map as a default,
whether it is kept, trimmed or cut — and changes nothing until the owner decides each `cut`
row (A8). Then the approved trims, a README rewritten around the loop, one worked example in
the guide from idea to shipped, and a roadmap that names the release. 4.0.0 if a cut is
approved, else 3.8.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; there is no product file.
- **Open specs:** none (`decisions-and-digest` shipped in 3.7.0).
- **Decision 0001 (`.shipkit/decisions/0001-project-map-default.md`)** — the request's S7-T1
  row "`PROJECT_MAP.md` as the default (using decision 0001)" rests on this record. The record
  says the map becomes optional on the evidence so far **and** adds its own condition before
  anyone acts: *re-run the comparison on a fixture of at least 200 files with one question
  about how the project evolved; restore the map as the default if, there, it gives one more
  correct answer or 20% fewer tool calls.* The plan's Sprint 7 has no task for that re-test.
  Proposing the map row as `cut` or `trim` without it would act on the record while skipping
  the condition the record wrote for itself. Raised as question 1.
- **The byte budget:** the three always-on rules stand at 2,996 of 3,000 bytes; nothing in
  this sprint may add to them. Trims can only lower the number.

## Answers
Asked of the owner with this intake; written here as unanswered until they are.

1. **The map re-test.** Decision 0001's condition needs a fixture of 200 or more files and one
   question about the project's history. Three ways to meet it: (a) add a task before S7-T1
   that builds the fixture (a copy of a real repository of yours, or a generated one) and
   re-runs the four `grandfather` cases plus one history question with and without a map, so
   the audit row carries the number; (b) carry the row as a proposal marked "pending re-test"
   and make no change to the map in this sprint; (c) act on the record as it stands.
   Recommended: (a) if a 200-file repository can be used as a fixture under 100 KB (A9), else (b).
2. **Bare `mktemp`.** Sprint 6 found that a bare `mktemp` on macOS ignores `TMPDIR`; seven
   scripts still use it (`install-rules.sh`, `install-stack.sh`, `session-start.sh`,
   `lib-manifest.sh`, `unsetup-remove.sh`). Fold the fix into S7-T2 with a lint check that
   forbids a bare `mktemp` in `plugins/shipkit/scripts/`, or leave it for a separate fix?
   Recommended: fold it in; it is a trim of the same kind, and the lint check keeps it out.

## Assumptions made
- The checks the plan asks for by hand in S7-T3's "Done when" (`grep` each skill name in the
  README against `plugins/*/skills/`, 250 lines, no version history above Install) live in
  `scripts/lint.py`, so they run in CI on every push; `scripts/lint.py` is therefore on the
  Files line of S7-T2, S7-T3 and S7-T5. The plan lists only the document for those tasks.
- Criterion (c) of the keep rule — "an eval shows it changes the result" — has evidence for
  no rule line today (the `rules` eval cases test the always-on rules, not these). The audit
  marks (c) as *not measured* rather than inventing a result, and keeps a line on (a) or (b)
  only. A line kept on (c) alone would need a new eval case first.
- "Every stack rule ends at 40 lines or fewer" applies to the 16 overlay rules; two exceed it
  today (`hotwire.md` 42, `liveview.md` 47). "Every skill description 300 characters or fewer"
  applies to all 23 skills across both plugins; eight exceed it today (`spec` at 551 is the
  longest).
- The worked example (S7-T4) reuses the refunds feature of the eval fixture and the files the
  earlier sprints' smoke checks already produce, so its "real output" is output the repository
  can regenerate.
- The release number is settled by the plan and the owner's answers to the `cut` rows; it is
  not a requirement.

## Out of scope
- Cutting anything the owner has not approved row by row (A8).
- Removing or changing the map's archivist, hook nag or `/shipkit:map` beyond what an approved
  row says.
- Any new feature. This sprint removes, shortens and documents.
