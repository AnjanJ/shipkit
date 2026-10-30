# Intake: The window and a third project

> Intake taken on 2026-10-11.

## Request
Sprint 19 of the second-run plan (`docs/plans/second-run-sprint-plan.md`), the plan's last:
close the harness window every `--plugin-dir` session opens by letting the session put
`plugin-root` back when it ends; capture the one text the evals README quotes from
documentation rather than from a trace; run shipkit's loop a third time, headless, on a
project of the third stack, fixing nothing; write the roadmap the plan after starts from.
Release 4.12.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; no product file.
- **Open specs:** none; all twenty specs are `Status: shipped`. `harness-debts` (REQ-6, REQ-7)
  made the smoke runner save and restore `plugin-root` and named the mid-run window; E15
  closes the window from inside the session and leaves the runner's restore as it is.
  `run-wounds` (REQ-12, REQ-13) owns the "a newer version is installed" line in
  `session-start.sh`; E15 adds a save beside it and changes that line not at all.
  `real-run` (REQ-9 to REQ-11) and `portfolio-run` (REQ-8, REQ-9) wrote the first two real
  runs' notes in the six-part shape E17 copies. `run-debts` (E1 to E7) is what the third run
  reports on, one line each.
- **Decisions:** 0001, 0002, 0003 untouched. E18's F3 is a record in this sprint's
  `design.md` (a deletion, its own yes); E15, E16, E17 are records here.
- **Harness changes:** one new hook script (`session-end.sh`) registered in `hooks.json`
  under `SessionEnd`; `session-start.sh` saves the previous value; smoke check 62; the evals
  README's two paragraphs (the window; the refusal text). No eval case (the evals tree is
  196,289 of 196,608 bytes — E16's probe is a scratch copy, never committed). No rule file,
  skill or agent changes; the three injected rules stay at 2,979 bytes.

## Answers
1. **E17's repository — the plan needs a Python project's path from the owner by this task.
   `find ~/code -maxdepth 4` finds no `pyproject.toml`, `requirements.txt`, `manage.py`,
   `Pipfile` or `setup.py` outside virtualenvs, so no candidate is on this machine under
   `~/code`. Which is it: a path elsewhere, a project to clone first, or E17's other option
   (`office_bestie` again, which measures E1 to E7 on the project that asked for them)?** —
   *the owner said **"approved"** (2026-10-11) without naming it; the spec is written for
   either, the repository and request are still owed before T3 starts, and T3's first step
   records the repository, its stack and its `git status` before anything runs.*
2. **E15's check-first: Claude Code is now 2.1.296 (the plan's facts are at 2.1.291). Does a
   `SessionEnd` hook run at the end of a headless `-p` session, with `${CLAUDE_PLUGIN_ROOT}`
   set, in a plugin's `hooks.json`?** — *half answered at T0 by the `claude-code-guide`
   agent's reading of the documentation (hooks reference, "SessionEnd"; plugin components,
   "Hooks"; the headless page): `SessionEnd` "runs when a Claude Code session ends", with a
   `reason` of `clear`, `resume`, `logout`, `prompt_input_exit` or `other`; a `-p` run ended
   by SIGTERM runs it (exit 143); every hook process gets `CLAUDE_PLUGIN_ROOT`; plugin
   `hooks.json` lists `SessionEnd` with the same shape as `SessionStart`. **Not documented:**
   whether a `-p` run that completes normally runs it, and Ctrl-C. **Documented and
   binding:** `SessionEnd` hooks share a 1.5 s budget, a plugin-provided `timeout` does not
   raise it, stdout goes to the debug log, and the hook cannot block the exit. So the end
   hook is a few file operations and nothing else, and T1's headless probe (one `-p` session
   whose `SessionEnd` hook prints to a file) decides the half the documentation leaves open.
   If it does not fire for `-p`, check 62 runs the two scripts directly, the README says
   which sessions restore, and rule 17's write-back stays for headless runs.*
3. **E15's edge: a session whose end hook never runs (killed, or a harness that does not
   fire it) leaves `plugin-root` at its root and `.prev` holding the value from before. The
   next session's start must not overwrite that `.prev` with the stale root — else the next
   end "restores" the wrong path. Is `.prev` written only when none exists?** — *assumed:
   yes; the oldest saved value wins until an end hook puts it back, and the end hook writes
   it back only if that root still exists (the 4.10.0 incident: an older session's hook
   restored a directory just removed).*
4. **E16's probe asks for `.pre-commit-config.yaml` at the workspace root with `Write`
   allowed. If the tool_result holds no refusal text (the write is silently dropped, or the
   model never attempts it), what does the README say?** — *assumed: the paragraph says what
   the trace held instead, as the plan's Done-when allows; the probe is one run, and a second
   run only if the first never attempted the write (≈ $0.15 each, within E16's budget).*

## Assumptions made
- **The spec's slug is `third-run` and the branch `sprint-19/third-run`**, as the plan
  names them.
- **`session-end.sh` is silent and always exits 0**, as `session-start.sh` is: a hook that
  prints at session end has no reader, and one that fails must never mark a session.
- **The save happens only when the root differs** from what `plugin-root` holds, so an
  interactive session from the cache (the common case) writes no `.prev` and its end hook
  changes nothing.
- **The smoke runner's own save and restore stay** (`harness-debts` REQ-6): the runner's
  sessions each restore themselves now, but the runner's EXIT trap is the guarantee for a
  session killed mid-run.
- **Check 62 tests the scripts directly in every case** (start from a scratch root with a
  previous value whose root exists → end → the previous value is back and `.prev` is gone;
  a previous root that no longer exists → the file keeps the session's root, `.prev` gone;
  no previous file → no `.prev`, end changes nothing; a `.prev` already present → start
  leaves it) and, **only if the check-first says `SessionEnd` fires for `-p`**, runs one
  headless `haiku` session from the scratch root and reads the file after it. The check's
  PASS line says which form ran.
- **The third run's shape is 4.9's**: a worktree at the repository's default branch on
  `shipkit/real-run-3` under this session's scratchpad, never the owner's checkout;
  `claude --plugin-dir "<this checkout>/plugins/shipkit"` at the sprint branch, `--model
  sonnet`, headless; the steps of `field-notes-4.9.md` in order (the hook, setup, product,
  intake on one request the owner names, the intake again with answers if it asks, spec, one
  task through `brief.sh` from a clean tree and `brief-verify.sh`, the gate); each step
  Asked for / Produced / Took / Awkward / Whose fault / Evidence; `git status --short`
  before the first step; whether E1 to E7 held, one line each; **nothing found is fixed**.
  The request the intake takes is the owner's to name with the repository; failing that, the
  project's own TODO or issue list supplies one, as 4.9 took `TODO.md` §4.
- **The run's cost** is E17's ≈ $5–8; a step that must be repeated for the project's own
  reason (a test command that needs a toolchain pin, as 4.9's `mise exec --`) is repeated
  once and the reason recorded under "Whose fault: the project's".
- **T4's "Still open after Sprint 19"** gathers: the third run's findings (one item per
  finding, by section); S18's readings that named something (E10's sentence and its
  number, E11's number, E14's kept lines and the two graders narrower than their line);
  and what the three releases' "What using it for real showed" sections name — every item
  citing a file and section. Items earlier lists already carry are pointed to, not copied.
- **No eval case is added**: the evals tree has 319 bytes of room; E16's probe is a scratch
  copy, and T1's probe is a `-p` session with a hook, not a case.
- **The `4.9.0` and `4.10.0` cache directories** are not in E18's list (F1 and F2 were
  `4.6.0` and `4.7.0`); they are offered as rows at T-REL beside F5, each its own yes, only
  after the owner's interactive session's hook line reads `4.11.0` or later.

## Out of scope
Fixing anything the third run finds (E17; its findings are the plan after's); the three
findings that are `office_bestie`'s own; `agents/eve.md`, `agents/grandfather.md`,
`agents/reviewer.md`, every rule file and skill; the two graders 4.11.0 found narrower than
their line (`trap2/package-json`, `trap2/experiments`); a step-0 sentence for `eve`; a
`SessionEnd` hook that does anything but restore `plugin-root`; the smoke runner's own
restore; any deletion E18 does not name, and nothing in E18 without its own yes.
