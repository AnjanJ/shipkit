# Intake: The harness pays its debts

> Intake taken on 2026-10-09.

## Request
Sprint 14 of the portfolio plan (`docs/plans/portfolio-sprint-plan.md`): close the six small
items under ROADMAP's "Still open after Sprint 13" that make the tools lie or litter — a draft
`spec-check.sh` cannot check, a gate that leaves `shipkit-ship-*.out` under `$TMPDIR`, a smoke
suite that overwrites `~/.claude/shipkit/plugin-root`, a `map_read` that counts `Read` only where
its document says `Read` or `Grep` and misses a shell `cat`, a sandbox refusal of a root dotfile
nobody has explained, and a rulebook rule that contradicts the gate. No rule, agent or eval
prompt changes. Release 4.7.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; no product file.
- **Open specs:** none; all fifteen specs are `Status: shipped`. `gate-blind-spots` listed "a
  draft-tolerant `spec-check`" as out of scope by the owner's answer (its intake, question 2) —
  it is this sprint's E4. `second-traps` shipped `trace-tools.sh`'s `map_read` column (REQ-9);
  this sprint changes what the column counts to what that spec's results document said it
  counted, and adds a column beside it.
- **Decisions:** 0001 (map optional), 0002 (`nontrivial` sentence), 0003 (overlay skills in
  core) — none is touched. `gate-blind-spots`'s record "Exit codes are echoed on the command
  line, output is read from a file" named the scratch files as its case-against; E5 removes
  them after the report holds their content and leaves the record standing.
- **No agent file changes.** The skills `spec` and `ship` change by a sentence each; the
  reviewer and the elders are not touched.

## Answers
1. **S14-T2's Done-when is a headless `/shipkit:ship second-traps` dry run (≈ $0.50) and
   S14-T5 runs two probe cases on a scratch copy (≈ $0.30). Both are in the plan's §4 budget
   line for Sprint 14. Confirmed as in the budget (rule 15)?** — **Yes**, the owner, 2026-10-09,
   by approving the plan with E1–E13 at their defaults.
2. **E7 found that `trace-tools.sh` counts `Read` only while `eval-results-4.6.md` and the 4.6.0
   CHANGELOG say `Read` or `Grep`. Make the code match the document and append one line to the
   4.6 document (the plan's default), or restate the 4.6 rates?** — **The default**, the owner,
   2026-10-09, with the plan's approval.

## Assumptions made
- `--as-open` promotes only a `draft` status for the run; `dropped` stays `SKIPPED`, `open` and
  `shipped` are unchanged by the flag. The check-first in the plan's §3 holds: `spec-check.sh`
  reads the status into one variable (`status=$(spec_status "$spec")`) and every later branch
  keys on that variable, so the flag changes it in one place.
- The gate removes only its own files, `"${TMPDIR:-/tmp}"/shipkit-ship-*.out`, after the
  report is written; the How column's commands and the report's pasted blocks are unchanged.
- The smoke runner restores `plugin-root` from a variable in its `EXIT` trap; the hook keeps
  writing the file during a run (check 3 asserts the root line), so a session started mid-run
  reads a scratch root until the run ends. That is stated in the header, not fixed.
- `map_read` stays one column (now `Read` or `Grep` on the map's path) and `map_shell` is a
  second (`Bash` whose command contains `PROJECT_MAP.md`); 4.6's 1, 4 and 8 of 15 are not
  restated, one appended line in `eval-results-4.6.md` says they were counted by `Read` alone.
- The dotfile probe runs on a scratch copy of the plugin; no probe case is committed. The
  finding lives in the evals README under "How runs are isolated".
- E9 changes no plugin file: the ROADMAP item is struck with a pointer to the plan's rule 16
  and amended rule 5.

## Out of scope
Rule text and the cut candidates (Sprint 15); the elder's step 0 (Sprint 15); the intake's
sentence (Sprint 15); the portfolio fixture, `eve`'s cases and the second real run (Sprint 16);
the cache directories (Sprint 15, F1 and F2); `digest/attention` and `grandfather-xl/drift`'s
shape under `-j 4`; a hook change for the smoke suite (E6's other option).
