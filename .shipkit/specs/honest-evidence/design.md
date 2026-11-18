# Design: honest evidence

## Approach

Three files carry the work. `scripts/smoke.sh` learns to leave its model calls out and to label
the assertions that only read wording. `plugins/shipkit/scripts/spec-check.sh` prints three new
kinds of line and reads one new optional line of `spec.md`. A new script,
`plugins/shipkit/scripts/spec-diff.sh`, compares a spec's requirements with what they were when
the branch began, and `brief-verify.sh` gains one line of output.

Every new line is information. No exit status changes except through a `> Tests:` line, which
binds only a spec that carries one (REQ-15, REQ-18).

The spec has two kinds of task. The build tasks are done in Sprint 29 and start no model. The
tasks for REQ-34 to REQ-38 change what a model reads, so by the plan's rules 33 and 34 they wait
for Sprint 35; the text each will apply is at the end of this file, word for word.

## Decision: Each check that starts a model is wrapped in one guard   (→ REQ-1, REQ-2, REQ-3, REQ-4, REQ-7, REQ-8)

**Context.** `scripts/smoke.sh` is one linear script of 3,276 lines. Sixteen of its numbered
checks start `claude`, through the `ask` helper (`:54-55`) or directly (for example `:137`,
`:1076`). Several of those checks also hold assertions that need no model, and setup that later
checks reuse.

**Alternatives.**
1. A guard function, `model_check <n> <name>`, around the model part of each of the sixteen
   checks. It returns true when the check should run; otherwise it prints the `SKIP` line. The
   numbers live in one variable, and a model-free assertion scans the script itself and fails if
   a numbered check runs `claude` or `ask` without being in that variable.
2. A stand-in `claude` put first on the `PATH` under `--no-model`, so every call fails fast and
   each check reports a skip from the failure.
3. Split the file in two: one script of model-free checks, one of model checks.

**Case for (1).** Only the model part of a check is left out, so its model-free assertions and
its setup still run (REQ-3). The default run's text is untouched outside the sixteen guards. The
self-scan means a new model check cannot be added without its guard.

**Case against (1).** Sixteen hand edits in the one file that tests everything, and the full run
that would confirm them waits for Sprint 35. The self-scan reads the script as text, so a model
call hidden behind a helper with another name would pass it.

**Decision.** We chose (1).
**Falsifiability.** We would move to (3) if CI's `--no-model` job (REQ-11) fails twice, in the
life of the verifier plan, on a model call that had no guard.
**Fired-if.** manual

## Decision: `--only` reaches the checks that start a model, and no others   (→ REQ-5, REQ-6)

**Context.** The plan asked for `--only` so that Sprint 35 can run one failed model check again
after its fix without paying for the other fifteen. Check names repeat (19, 20 and 28 are all
"spec-check"), so the argument has to be a number. Sections lean on each other: checks 20 and 28
reuse helpers check 19 defines (`:629-630`, `:1041-1042`).

**Alternatives.**
1. `--only` names checks that start a model. Every model-free assertion still runs. A model check
   that reads what another model check wrote is listed in one small table of needs, and is run
   with it.
2. Every numbered check can be named, each with its needs declared.
3. No `--only`: a fix is followed by the full suite again.

**Case for (1).** It serves the one use there is, with guards that Decision 1 already puts in
place. Model-free checks cost nothing to run again, so naming them buys nothing.

**Case against (1).** A model-free check cannot be run alone, so reading one failure means
waiting for all of them. If the model-free part of the suite is slow, that wait is paid on every
run.

**Decision.** We chose (1).
**Falsifiability.** We would take (2) if `sh scripts/smoke.sh --no-model` takes more than three
minutes on the owner's machine at the sprint's merge.
**Fired-if.** manual

## Decision: CI runs the model-free suite on a macOS runner   (→ REQ-11)

**Context.** CI runs the lint and `spec-check.sh` on Ubuntu and has never run the smoke suite,
which needed a logged-in `claude`. With `--no-model` it needs none. The suite has only ever been
run on the owner's Mac, where `sh` is bash 3.2 and the tools are BSD's.

**Alternatives.**
1. A second job in `.github/workflows/lint.yml` on `macos-latest`.
2. The same job on `ubuntu-latest`, where `sh` is dash and the tools are GNU's.
3. No CI job: the model-free suite is run by hand at each merge.

**Case for (1).** It is the machine the suite was written on, so a red job means a real failure
and not a difference of platform. The runner has no `claude`, so every pull request proves REQ-1
and REQ-4.

**Case against (1).** It says nothing about Linux, where users run the plugin's scripts. (2)
would, at the price of first fixing whatever in a 3,276-line script assumes BSD.

**Decision.** We chose (1).
**Falsifiability.** We would add (2) beside it if a user reports a plugin script failing on
Linux, and drop the job for (3) if its median time over ten runs passes ten minutes.
**Fired-if.** manual

## Decision: One search with file names, filtered for each spec   (→ REQ-15, REQ-16, REQ-17, REQ-19)

**Context.** `spec-check.sh` collects every citation with one `git grep -h -o` (`:170-179`),
because the briefing runs it at every session start and fifty specs must come back within one
second (smoke check 30). A `> Tests:` line and `SKIPPED-CITE` both need to know which file, and
which line, a citation is in.

**Alternatives.**
1. The same single search with `-n` in place of `-h`, giving `file:line:citation`. Each spec then
   filters those lines in awk: by its `> Tests:` paths when it has the line, by nothing when it
   has not. One more awk, over all citing files at once, marks the lines near a skip marker.
2. Keep today's search, and run a second one, limited by pathspec, for each spec that has a
   `> Tests:` line.

**Case for (1).** Still one search however many specs there are, and one pass over the citing
files. A spec with no `> Tests:` line is counted from the same lines as today (REQ-17).

**Case against (1).** Every run now reads the citing files once more for skip markers, including
the briefing's run at session start, which has no use for `SKIPPED-CITE`.

**Decision.** We chose (1).
**Falsifiability.** We would take (2), and print `SKIPPED-CITE` only when a slug is given, if
smoke check 30's fifty specs take more than one second with (1).
**Fired-if.** manual

## Decision: A skipped test is found by a list of markers near the citation   (→ REQ-19, REQ-20)

**Context.** A citation in a test that never runs satisfies `spec-check.sh`. Whether a test runs
is known for certain only to its framework.

**Alternatives.**
1. A fixed list of skip markers (the spec's Terms), looked for on the citation's line and the
   three lines either side. The finding is information only.
2. Ask each framework which tests it skips, through its own command.
3. Leave it to the reviewer's reading.

**Case for (1).** It needs no framework installed and no test run, and stays inside POSIX `sh`
and awk (REQ-29's rule for these scripts). Information only, so a false positive costs a line of
output and nothing more.

**Case against (1).** It is a guess from text. A marker in a comment three lines away is a false
positive; a test left out by configuration is missed. (2) would be exact, and would need every
framework's command, its output format and a working toolchain.

**Decision.** We chose (1).
**Falsifiability.** We would make it a gap when Sprint 35's real run reads it with no false
positive, and drop the line if it prints a false positive on two of the next three real runs.
**Fired-if.** manual

## Decision: The baseline for a changed requirement is the spec as the branch found it   (→ REQ-21, REQ-22)

**Context.** To say a requirement changed, `spec-diff.sh` needs the version the owner accepted.
The acceptance stamp names a commit, but the spec is committed after it: on the 5.2 run the stamp
read `179f99d` and `spec.md` first appeared in `8f2dbb4` (`docs/design/field-notes-5.2.md` §7).

**Alternatives.**
1. `spec.md` at the base ref when it exists there; otherwise at the first commit after the base
   ref in which its `> Status:` line reads `open`; otherwise `NO-BASELINE`.
2. A hash of the requirements written into the stamp at acceptance, and checked later.
3. `spec.md` at the stamped commit.

**Case for (1).** It needs nothing new written at acceptance, so it works on every spec that
exists today. The base ref is the one the gate already uses. An edit made by the branch that is
being judged cannot move a baseline that lies in history before it.

**Case against (1).** A spec written on its own branch has no version at the base ref, and its
first `open` commit already holds any edit made between acceptance and that commit. (2) would
catch those, but the branch that edits a requirement could rewrite the hash beside it.

**Decision.** We chose (1).
**Falsifiability.** We would add (2) if, on a real run or a fixture, the branch's history shows
an edit to a requirement that `spec-diff.sh` did not print.
**Fired-if.** manual

## Decision: On CI the briefing's time is printed, not enforced   (→ REQ-41, REQ-42, REQ-43)

**Context.** Smoke check 30 holds the briefing on fifty open specs to one second of CPU
(`briefing-and-handoff/REQ-8`). The owner's Mac reads 0.75 to 0.85 s. The CI job this spec added
read 0.96 s on its first run and 1.53 s, the best of three tries, on its second. The scripts were
the same: the commit between the two runs changed one note in `tasks.md`. So the limit was set
on one machine, and the shared runner is slower and uneven. Of the 0.76 s measured here on
2026-11-18, `spec-check.sh .` is 0.66 s, about 2,600 shell commands run for one number.

**Alternatives.**
1. A switch, `SMOKE_TIMING=report`, that the CI job sets. The time is printed in the `PASS` line
   and not failed; the line and byte limits still fail; without the switch the limit stands.
2. A higher limit on CI, such as three seconds.
3. Make the briefing cheap enough to pass on the runner, in this pull request.
4. Run the job again until it passes.

**Case for (1).** The job goes red only for what a pull request can break. The limit still holds
where it was measured, at every free run on the owner's machine, and CI prints the number on
every pull request, so a slow-down can be read in the log.

**Case against (1).** CI no longer fails a briefing that became slow; only a run on the owner's
machine does. (2) would keep a failure on CI, but any number is a guess from two readings, and a
slower runner breaks it again. (3) is the real fix, and it reworks `spec-check.sh`, the script
every gate rests on, inside a pull request that is otherwise finished. (4) is what the verifier
plan's rule 30 forbids: a pass would say only that the runner was quick that time.

**Decision.** We chose (1), and (3) goes to the verifier plan's S31-T2.
**Falsifiability.** We would take the switch out of the workflow once, after S31-T2's fix, check
30 passes five times running on the CI runner without it.
**Fired-if.** manual

## Data / interface changes

`scripts/smoke.sh` (REQ-1 to REQ-10, REQ-32):

- Arguments: `--no-model`, `--only <n>[,<n>]`, `--list`. Any other argument: usage, exit 64.
  `--no-model` with `--only` is a usage error too (REQ-40). `--list` may go with either.
- Arguments are read before any scratch directory is made. `claude` is looked for only when a
  check that starts a model will run.
- **The registry.** One table near the top of the script holds, for each numbered check, its
  label and one short name (`29 ship-gate`), in the file's order. `--list` and the `SKIP` lines
  print from it. A model-free assertion fails if a `# <label>. …` comment line has no entry, so
  the wrapped sentence at line 1944 is re-wrapped to stop looking like one.
- **The needs.** One line beside the registry: check 32 needs check 31, because it reads the
  handoff note that check 31's session wrote. `--only 32` therefore runs 31 and 32. No other
  check that starts a model reads what another's session wrote; each of the rest builds its own
  fixture.
- `pass` counts a pass; a new `passt` counts a pass and a text-only pass and prints
  `PASS  [text] <name>`; `failc` counts a failure; `model_check` counts a skip.
- Output: the `SKIP` lines, the count line of REQ-9, and the last line. The last line is
  `smoke: all checks passed` when nothing failed and nothing was skipped, as today;
  `smoke: all checks run passed; <s> skipped (model)` when something was skipped (REQ-10);
  `smoke: FAILURES above` otherwise.

`plugins/shipkit/scripts/spec-check.sh` (REQ-12 to REQ-20):

- Reads `> Tests: a/, b/c.sh` from `spec.md`: comma-separated, a file or a folder, with the
  grammar of `> Paths:`. A folder may be written with or without its trailing slash.
- Prints, for each checked spec and before the summary line: `EVIDENCE`, then any
  `CITED-ELSEWHERE` and `SKIPPED-CITE` lines. None of the three adds to the gap count.
- `tested` counts requirements with no waiver and a counted citation; `waived` counts requirements
  with a waiver, cited or not; `uncited` counts the rest.

`plugins/shipkit/scripts/spec-diff.sh` (REQ-21 to REQ-29), new:

- A requirement is read as `brief.sh` reads it: from a line holding `**REQ-N` to the next
  requirement, blank line or heading. Its words are compared after its lines are joined and each
  run of spaces is made one space (REQ-24).
- Output: one line for each finding, then `spec-diff: <n> requirement(s) differ from <ref>`.

`plugins/shipkit/scripts/brief-verify.sh` (REQ-30, REQ-31):

- `SPEC-EDITED <file>` lines are printed before the summary line. The exit status is decided by
  `OUTSIDE` lines alone, as today.

`.github/workflows/lint.yml` (REQ-11): one more job, on `macos-latest`, that runs
`sh scripts/smoke.sh --no-model </dev/null`.

## Text that waits for Sprint 35

By the plan's rule 34 these are applied after the baseline, not before. Sprint 30 rewrites the
ship skill around a script; where the two meet, Sprint 35 applies them together.

**`plugins/shipkit/skills/ship/reference.md`** (REQ-34, REQ-36). In the template, under the
`> Checked on …` line:

```markdown
> Evidence: 2 of 3 requirements have a cited test; 1 read only.
```

Under `### 1. Spec check, as shipped`, after the script's output:

```markdown
Requirements changed on this branch:
<every line spec-diff.sh printed, or "none">
```

One more rule in the list: "The `> Evidence:` line is copied from step 1's `EVIDENCE` line:
`tested` of `tested + waived + uncited`, and `waived` read only. It is never counted by hand."

**`plugins/shipkit/skills/ship/SKILL.md`** (REQ-34, REQ-35, REQ-36). Step 1's row runs
`spec-diff.sh . <slug> <base>` after `spec-check.sh`, with its own `echo "exit $?"`; a note
says: "Step 1's result is `spec-check`'s exit code alone. `spec-diff.sh` exiting 1 means
requirements changed on this branch; paste its lines, and do not fail the step for them."

In "The report", the sentence that asks for the count of requirements becomes: "Then the
`> Evidence:` line, copied from step 1's `EVIDENCE` line."

The closing instruction becomes: "Then tell the user, in a few lines: the first line of the
report, the evidence line, each step that did not pass and what would fix it, and where the
report is. When the `EVIDENCE` line reads `tested=0`, say plainly that the result rests on
reading alone: no requirement has a test."

In "After a READY result", one sentence is added: "Name each requirement the report lists under
'Requirements changed on this branch' in the question, so the yes is given knowing what changed."

**`plugins/shipkit/skills/spec/SKILL.md`** (REQ-37). Q1, step 5, gains: "Ask where the
feature's tests live as well, and write the answer as `> Tests: a/, b/`: a citation counts only
in a file there. If the user does not know yet, propose the project's test folder from the
codebase research and confirm it."

**`plugins/shipkit/skills/spec/reference.md`** (REQ-38). The `spec.md` template gains
`> Tests: tests/billing/` under `> Paths:`. "The three lines under the title" becomes "The four
lines", with one more item:

```markdown
- **`Tests`** — a comma-separated list of the files or folders the feature's tests live in. A
  citation counts only in a file there. No `Tests` line means any file outside `.shipkit/`,
  `docs/` and `*.md`, as before.
```

The list of lines `spec-check.sh` prints gains `EVIDENCE`, `CITED-ELSEWHERE` and `SKIPPED-CITE`,
named as information, not gaps.
