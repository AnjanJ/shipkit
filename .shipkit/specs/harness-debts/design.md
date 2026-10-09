# Design: The harness pays its debts (Sprint 14)

## Approach

Six small tasks on six surfaces, each one the plan's E4 to E9 at its default: one script
gains a flag that mirrors one it already has, and the skill that flipped a status to get
around its absence stops; one skill gains a last line that removes what it wrote; one test
runner saves and restores one file; one script's count matches its own document and gains a
column; one paragraph records what a sandbox refuses; one roadmap item is closed by the
rulebook. No rule, no agent, no eval prompt, no new script.

---

## Decision: A draft is checked by a flag, not by a status flip   (→ REQ-1, REQ-2, REQ-3)

**Context.** On the real run the spec skill set a draft's `Status` to `open` for one run of
`spec-check.sh` and restored `draft` afterwards (field notes §6) — the right instinct, the wrong
mechanism: a skill that edits a status line to run a check can leave it edited, and a reader of
the transcript cannot tell a check of the draft from a check of an accepted spec.
`spec-check.sh` already has `--as-shipped`, which asks an open spec for what a shipped one owes
without changing a file.

**Alternatives.**
1. `--as-open`: a `draft` is read as `open` for the run; nothing else changes; the spec skill
   calls it on the draft.
2. Drafts always get the task-format checks and `MISSING-TASK` as information lines, no flag,
   exit status unchanged.
3. Leave the script; the skill keeps flipping the status.

**Case for (1).** It is the shape the script already has, so the header explains both flags in
one breath; the default reading of a draft (`SKIPPED`, nothing counted) stays for every other
caller — the briefing, the gate, the digest — none of which should count a draft's gaps; and
the skill's call says what it is doing.

**Case against (1).** A caller who forgets the flag still gets `SKIPPED` and may read it as
"nothing wrong". (2) would show a draft's gaps unasked, at the cost of every other caller
seeing lines about specs nobody has accepted, and of a draft's `MISSING-TASK` counting toward
the exit status it should not affect.

**Decision.** We chose (1), E4's default.
**Falsifiability.** We would move to (2) if a spec is found accepted (stamped `open`) with a
task-format gap that `--as-open` would have reported, in any real or eval run after 4.7.0 —
that is, if the flag goes unused where it was needed.
**Fired-if.** manual

---

## Decision: The gate removes its own scratch files   (→ REQ-4, REQ-5)

**Context.** The `gate-blind-spots` record chose scratch files under `$TMPDIR` so the gate's
step 2 and step 8 keep whole output and real exit codes; its case-against was "a scratch file
left behind per step", now observed on four gate runs (the 4.4.0, 4.5.0 and 4.6.0 releases and
the S12-T3 dry run), removed by hand each time.

**Alternatives.**
1. The skill removes `"${TMPDIR:-/tmp}"/shipkit-ship-*.out` after the report is written; the
   report's pasted blocks are the record.
2. Keep the files and name them in the report as evidence the owner may inspect, then remove.
3. Write under a per-run `mktemp -d` and remove the directory.

**Case for (1).** The report already holds every line the files held, pasted (REQ-9 of
`gate-blind-spots`); a file the report has copied is litter. One line at the end of the skill,
no new path for the How column to get wrong. (3) adds a directory the How column must thread
through every command, and `mktemp` without a template ignores `TMPDIR` on this platform.

**Case against (1).** If the skill is interrupted between writing a scratch file and the
report, the file stays — as today. A report whose pasted block was typed, not read, now has no
file to check against; the template's "pasted from the file" sentence and the dry run are the
only check, as the earlier record said.

**Decision.** We chose (1), E5's default.
**Falsifiability.** We would move to (2) if a ship report after 4.7.0 is found to carry an
evidence block that differs from what its command printed on the same tree — the file would
then be worth keeping until the owner has compared them.
**Fired-if.** manual

---

## Decision: The runner restores `plugin-root`; the hook keeps writing it   (→ REQ-6, REQ-7)

**Context.** The session hook writes `~/.claude/shipkit/plugin-root` on every start, with no
condition, because plugin skills and agents have no other way to learn where the plugin lives.
The smoke suite starts dozens of sessions against a scratch copy, so by its end the file names
a path under `$TMPDIR` — restored by luck of ordering, or by hand (4.6.0's CHANGELOG). A
session started mid-run reads a scratch root.

**Alternatives.**
1. `smoke.sh` reads the file (or notes its absence) into a variable at start and writes it
   back in its `EXIT` trap, on every exit path; the header says so, and says a session started
   during a run reads a scratch root until the run ends.
2. The hook skips the write when `SHIPKIT_SMOKE=1` is in the environment; the runner sets it.
3. Leave it; the header already says the hook writes the file.

**Case for (1).** The suite made the mess, so the suite cleans it; the hook, which every user
runs, is not changed for a concern only this repository has. Check 3 asserts the root line is
in context and several checks run skills and scripts that read `plugin-root` from the scratch
copy; (2) would have to thread the variable through them and some would then read the owner's
real root, which is the wrong plugin for a check of the scratch copy.

**Case against (1).** The mid-run window stays open: an interactive session started during the
six minutes reads a scratch root and keeps it until restarted. (2) closes the window and (1)
only names it. A runner killed with `SIGKILL` runs no trap and leaves the scratch path — the
plan's rule 17 covers that case by hand.

**Decision.** We chose (1), E6's default.
**Falsifiability.** We would move to (2) if an interactive session is found running on a
scratch root after a smoke run has *ended* — that is, if the trap did not restore it — or if
the mid-run window bites the owner twice.
**Fired-if.** manual

---

## Decision: `map_read` matches its document; `map_shell` is a second column   (→ REQ-8, REQ-9)

**Context.** `eval-results-4.6.md` and the 4.6.0 CHANGELOG define `map_read` as "a `Read` or a
`Grep` whose input path ends in `PROJECT_MAP.md`"; the code counts `Read` only (checked
2026-10-09, the one `map_read = 1` line in `scripts/trace-tools.sh`). The same document counts
"a shell `cat` or `grep` on the map as well" by hand to reach 9 of 15 for attempt 2 and says the
plan's definition does not include it. Two gaps between the number and its definition.

**Alternatives.**
1. `map_read` counts `Read` or `Grep` on the map's path, as documented; a new `map_shell`
   column counts a `Bash` tool_use whose command names the map; 4.6's rates stand, with one
   appended line saying they were counted by `Read` alone.
2. Fold every form into `map_read` and restate 4.6's 1, 4 and 8 of 15 as "at least".
3. Leave the code; correct the document to say `Read` only.

**Case for (1).** The document is the definition the owner approved (C9) and the code is what
drifted; a second column keeps a tool-mediated read apart from a shell read, which is a
different act (the elder's own instructions say `Read` it), so a future rate can be compared
with 4.6's by its first column alone. (2) makes 4.6's three rates uncomparable with anything
after; (3) makes the definition fit the defect.

**Case against (1).** Two columns to read where one would do; a `Grep` on the map's path now
counts as a read of it, which a `Grep` for one word is only barely. The appended line is the
third note on 4.6's results document.

**Decision.** We chose (1), E7's default.
**Falsifiability.** We would move to (2) if a future elder measurement is judged on the sum of
the two columns rather than on `map_read` — at that point the split has stopped earning its
column.
**Fired-if.** manual

---

## Decision: The dotfile refusal is probed once, then recorded   (→ REQ-10)

**Context.** Every `trap2/notebooks` run in both arms wrote the right `.pre-commit-config.yaml`
at the workspace root and was refused; the case was corrected to ask for a Makefile target
(`eval-results-4.6.md`, the `notebooks` row). Nobody has read the refusal or the tool's
documentation to say whether it is policy, a permission the headless run could not grant, or
a quirk of that name.

**Alternatives.**
1. The tool's documentation first (through the `claude-code-guide` agent), then one probe case
   on a scratch copy of the plugin — `.editorconfig` at the root, `config/.editorconfig` in a
   subdirectory — one run each with `--keep-temp`, the `Write` tool_result text read from the
   traces; the README records the refusal, the form that works, and the rule for case authors.
2. Documentation only; no run.
3. A committed probe case that stays as a regression watch on the sandbox.

**Case for (1).** Two runs (≈ $0.30) turn a guess into a quoted refusal, and a subdirectory
dotfile answers the question an author actually has ("can my case want a dotfile at all?").
(2) leaves the sandbox's behaviour where the documentation's wording puts it, which is what
nobody has checked. (3) spends the directory's bytes on a case that measures the tool, not
shipkit.

**Case against (1).** The trace may hold no refusal text (a denied `Write` may surface as a
permission prompt with nothing in the tool_result), in which case the run bought only "it
still refuses"; the documentation then carries the paragraph, and the plan's §3 says so.

**Decision.** We chose (1), E8's default.
**Falsifiability.** We would move to (3) if the sandbox's rule is found changed by a Claude
Code release — a case under `trap2/` that passes or fails on a dotfile where it did not
before — since then the README's paragraph is stale and a watch is cheaper than a re-probe.
**Fired-if.** manual

---

## Decision: Rule 5 and the gate are reconciled by the rulebook, not the skill   (→ release step)

**Context.** The field plan's rule 5 said a branch-not-taken note in `spec.md` is the ship
commit's edit; the gate reads the spec before that commit, so three gates said READY on a spec
whose note they never read (Sprints 11, 12, 13). The portfolio plan's rule 16 says the note is
committed before the gate, and its rule 5 points there.

**Alternatives.**
1. Closed by the plan's rule 16 and amended rule 5; the ROADMAP item is struck with the
   pointer; no plugin file changes.
2. (1) plus one sentence in `skills/ship/reference.md`: "the gate reads the spec as committed".
3. The gate's step 7 (clean tree) fails on an uncommitted `spec.md`.

**Case for (1).** The gate already requires a clean tree (step 7) and reads the spec as
committed; the mistake was in the rule that told the author when to commit the note, and that
rule is this plan's to fix. A user's gate run is not wrong; a sprint's order of operations was.

**Case against (1).** A user following their own release habit can repeat the mistake, and the
ship skill says nothing to stop them. (2) costs a sentence; (3) already holds, since an
uncommitted note is an unclean tree — it was the committed-with-the-report order that slipped
past, not an uncommitted file.

**Decision.** We chose (1), E9's default.
**Falsifiability.** We would add (2)'s sentence if a gate after 4.7.0, in this repository or a
real run, says READY on a spec whose wording note was committed after the report.
**Fired-if.** manual
