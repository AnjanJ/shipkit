---
description: "The ship gate: eight checks on one spec'd feature (spec-check, tests, tasks, an independent reviewer, migration rollback, decisions, clean tree, no decision fired) and a report that starts READY or NOT READY. TRIGGER when: the user asks if a feature is ready. DO NOT TRIGGER when: it has no spec."
user-invocable: true
argument-hint: "<feature-slug> [base-ref]"
---

<!-- Runs INLINE (no context: fork) on purpose: it starts the `reviewer` agent, which only the
     main session can do (an agent cannot start an agent), and it may ask the user for the
     test command and for permission to mark the spec shipped. -->

# /shipkit:ship — Is It Ready? With Evidence

Run the gate on one feature and write down what you found. The answer is `READY` or
`NOT READY`, and every step carries the evidence a reader needs to check it without trusting
you. This skill **never** deploys, pushes, merges, tags, or edits code. On `NOT READY` it
lists what to fix and stops.

Arguments: $ARGUMENTS — `<feature-slug> [base-ref]`

- `<feature-slug>` — the spec at `.shipkit/specs/<feature-slug>/`. No such spec: say so and stop.
- `[base-ref]` — where the feature's work started. Default: `git merge-base HEAD <default branch>`
  (`main`, or `master`). State the base you used.

`<plugin root>` below is in the `shipkit: plugin root is …` context line.

## Before step 1

Before the gate, run `sh "<plugin root>/scripts/spec-check.sh" . <slug> --as-shipped` yourself and
cite every requirement it names — both 4.0.0 gates failed their first run on this two-second check.

Run `git status --porcelain` and keep its output. Step 7 judges the tree **as it was before
the gate ran**: the gate's own test run can leave files behind (caches, coverage output), and
those are not the user's unfinished work.

## The gate — eight steps, in this order

Do **every** step even after one fails: the report must show the whole picture. Record each as
`PASS`, `FAIL` or `SKIPPED`, with the reason, and keep the evidence: the exact command and the
last lines of its output. **Never record a result for a command you did not run.**

| # | Step | How | PASS means |
|---|------|-----|-----------|
| 1 | Spec check, as shipped | `sh "<plugin root>/scripts/spec-check.sh" . <slug> --as-shipped; echo "exit $?"` | exit 0 |
| 2 | Tests | `( <the project's test command> ) > "${TMPDIR:-/tmp}/shipkit-ship-tests.out" 2>&1; echo "exit $?"`, then read the file's last 20 lines | exit 0 |
| 3 | Tasks ticked | `grep -n '^- \[ \]' .shipkit/specs/<slug>/tasks.md; echo "exit $?"` | exit 1 (no line found) |
| 4 | Independent review | Start the **`reviewer`** agent (below) | its last line is `VERDICT: PASS` |
| 5 | Migration rollback | Is there a database migration in `git diff <base>...HEAD --name-only`? If so, is the way to roll it back written down? | no migration, or a written rollback |
| 6 | Decisions | Every live decision in `design.md` has a concrete reversal condition | none is vague or missing |
| 7 | Clean tree | The `git status --porcelain` you captured before step 1 | empty, apart from an earlier report for this slug |
| 8 | Decisions fired | `sh "<plugin root>/scripts/decision-check.sh" . --run > "${TMPDIR:-/tmp}/shipkit-ship-decisions.out" 2>&1; echo "exit $?"`, then read the file | no `FIRED` line |

Notes on the steps:

- **Exit codes and output.** The number `echo "exit $?"` prints *is* the step's exit code:
  quote it, and never infer one from the output or pipe the command into anything before the
  `echo`. Long output goes to the file the row names — the parentheses matter when the command
  is `a && b`, or only `b` is captured; read the file (`tail -20`) and paste from it.
  A report that says "exit code not captured" or carries output typed from memory is a defect
  in the run, not a result.
- **Step 2 — the test command.** Take it from the project's `CLAUDE.md` (its test or commands
  section). If it names none, ask the user once and use the answer. If no user is present and
  none was given in the request, record `FAIL: no test command known` — do not guess one and
  do not skip the step.
- **Step 4 — the reviewer.** Start the `reviewer` agent (`shipkit:reviewer`) and give it
  **only** the slug and the base ref — for example: "Review the spec `refunds` against the base
  ref `a1b2c3d`." Do not tell it what was built, what you think of it, or what the other steps
  showed: its value is that it has not heard any of that. Copy its whole reply into the report.
  `VERDICT: FAIL`, or no verdict line, is `FAIL`.
- **Step 5 — migrations.** A migration is a changed file under `db/migrate/`, `migrations/`,
  `priv/repo/migrations/`, `alembic/`, `prisma/migrations/`, or a changed `*.sql`. "Written
  down" means a `down`/reverse in the migration itself, or a rollback note in the spec or the
  pull request. A migration with neither is `FAIL`.
- **Step 6 — decisions.** Read each `## Decision:` in `design.md` that is not marked
  superseded. Its reversal condition must be a metric, an event or a threshold. "If it turns
  out wrong" or no clause at all is `FAIL`; name the decision. An honest "no clear reversal
  condition identified" is `PASS`. No `design.md`, or no decisions: `PASS — none recorded`.
- **Step 7 — the tree.** Uncommitted work is not shipped work. Use the capture from before
  step 1, not a fresh `git status`. An earlier report for the same slug under
  `.shipkit/releases/` does not count against it. If the test run left new untracked files,
  mention them under the evidence as a note — a missing `.gitignore` entry is worth knowing
  about — but they do not fail the step.
- **Step 8 — decisions fired.** `decision-check.sh` runs every `**Fired-if.**` command in
  `.shipkit/decisions/` and the specs' `design.md` files, from the project directory. They
  come from this repository — the one whose tests step 2 just ran — so running them here adds
  no trust that step 2 did not already extend. A `FIRED` line is `FAIL`; name the decision. The
  result stays `NOT READY` until the owner writes a superseding record (`/shipkit:decide`) or
  says to proceed — then record `PASS — owner said to proceed` with the `FIRED` line quoted. If
  no user is present, it stays `FAIL`. Quote `MANUAL` and `ERROR` lines under the evidence; they
  do not fail the step. No records, or none with the line: `PASS — none recorded`.

## The report

Write `.shipkit/releases/<YYYY-MM-DD>-<slug>.md` in the shape in @reference.md. Its **first
line is exactly `READY` or `NOT READY`** — `READY` only if all eight steps are `PASS`. A
`SKIPPED` step makes it `NOT READY`. Then the table of eight results, the count of
requirements and how many are waived as `[untested]` (from step 1's `WAIVED` lines), the
commit sha, and the evidence for every step. Writing this file is the only change you make.

Then tell the user, in a few lines: the first line of the report, each step that did not pass
and what would fix it, and where the report is.

## After a READY result

Ask the user whether to set the spec's `> Status:` to `shipped`. Change that one line **only**
after a yes. If no user is present, do not change it; say that it is still `open`.

## What this skill never does

- Deploy, push, merge, tag, or open a pull request.
- Edit code, tests, the spec's requirements, or `tasks.md` — not even to tick a box or fix a
  finding. It reports; the fixing is separate work.
- Record `PASS` without the evidence in the report.
- Let the reviewer hear anything but the slug and the base ref.
