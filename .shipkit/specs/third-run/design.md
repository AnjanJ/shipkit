# Design: The window and a third project (Sprint 19)

## Approach

Four records, one per plan decision (E15, E16, E17, E18's F3), and a sprint that is one small
hook pair, one probe, one real run and one roadmap. The hook pair is the only code: start
saves, end restores, both silent, both a few file operations — the `SessionEnd` budget is
1.5 s shared and a plugin cannot raise it. The probe and the real run change nothing in the
plugin: the probe writes one quoted sentence into the README, the run writes notes and
roadmap items. No rule file, agent, skill or eval case changes; the three injected rules stay
at 2,979 bytes and the evals tree at 196,289.

---

## Decision: The session that opened the window closes it   (→ REQ-1, REQ-2, REQ-3, REQ-4)

**Context.** `session-start.sh` writes its root to `~/.claude/shipkit/plugin-root` on every
start, because plugin skills have no other way to learn where the plugin lives. A session
started with `--plugin-dir` — every eval sandbox's hook, every gate, every real run — writes a
scratch or checkout path there, and the owner's next interactive session reads it until
something writes the cache path back. The smoke runner saves and restores from its EXIT
trap (4.7.0, `harness-debts` REQ-6); nothing else does; rule 17 is the write-back by hand.
On 2026-10-10 an older session's hook, re-run by a compaction, put back a cache directory
removed minutes before (`CHANGELOG.md` 4.10.0).

**Alternatives.**
1. Start saves the value it overwrites to `plugin-root.prev` — only when the value differs
   and no `.prev` exists, so the oldest saved value survives a session whose end never runs.
   A new `session-end.sh`, registered under `SessionEnd`, writes `.prev` back only if that
   root still has a `rules/` directory, and removes `.prev` either way. Silent, exit 0.
   Check 62 runs the scripts directly for every branch and, if the T1 probe shows `-p`
   sessions fire `SessionEnd`, one headless session too. The smoke runner's own restore
   stays.
2. Leave it to rule 17 and the write-back by hand.

**Case for (1).** The session that knows the previous value is the one that overwrote it,
and `SessionEnd` is the one moment it has to put it back. The two guards are the two
failures seen: an end that never ran (the `.prev` is not overwritten, so the next end
restores the right value) and a root that no longer exists (nothing is restored to a path
that is gone). The runner's trap stays as the guarantee for a killed run.

**Case against (1).** The documentation does not say whether a normally completing `-p`
session runs `SessionEnd` — only that SIGTERM does — so the hook may close the window for
interactive and signalled sessions and not for the eval tool's; the check-first decides, and
the README then says which. A hook on every session end is one more process at exit, inside
a 1.5 s budget shared with any other plugin's end hooks. (2) costs nothing and has worked by
discipline for three sprints, with one slip.

**Decision.** We chose (1), E15's default; the write-back guard is the 4.10.0 incident's
line, as `run-debts` recorded it.
**Falsifiability.** We would remove the end hook (2) if the T1 probe shows `SessionEnd`
does not run for `-p` sessions **and** an interactive session's end shows no restore either —
then the hook closes nothing. We would add a `reason` matcher if a `clear` or `resume`
restores a value an interactive session still needs.
**Fired-if.** manual

---

## Decision: The refusal text comes from one probe's trace   (→ REQ-5)

**Context.** The README's "What a case cannot ask for (4.7.0)" paragraph says what is refused
(a protected file name, `.pre-commit-config.yaml` among them) from the permission-modes
documentation and the effect seen in 4.6.0's `notebooks` runs; the refusal's own text was
never captured — the sandboxes were gone and the 4.7.0 probes wrote files that were not
refused.

**Alternatives.**
1. One probe case on a scratch copy of the plugin, never committed: the prompt asks for
   `.pre-commit-config.yaml` at the workspace root, `--runs 1 --keep-temp`, the `Write`
   call's `tool_result` read from the trace and quoted; the sandbox and the copy removed.
2. Nothing; the paragraph cites the documentation.

**Case for (1).** A case author who meets the refusal in a trace should recognise it from the
README; one run and one quoted sentence do that. The scratch copy keeps the evals tree where
it is (319 bytes of room) and the suite free of a case that exists to be refused.

**Case against (1).** The model may not attempt the write at all (it may ask, or write
elsewhere), and the trace then holds no refusal; a second run spends the budget again.

**Decision.** We chose (1), E16's default; a trace with no attempted write buys one more
run, and the paragraph then says what the trace held.
**Falsifiability.** We would replace the quote if a later Claude Code's trace shows a
different text — the paragraph names the version it was read on.
**Fired-if.** manual

---

## Decision: The loop runs a third time, on the owner's project, and fixes nothing   (→ REQ-6, REQ-7)

**Context.** Two real runs so far: RED (Rails, 4.3.0) and `office_bestie` (Phoenix, 4.9.0),
each written as steps with six parts, each seeding the plan after; neither on the third
stack shipkit ships rules for (Python). Sprint 17 paid the second run's debts (E1 to E7) and
nothing has yet measured whether they hold on a project that has none of 4.9's shapes.

**Alternatives.**
1. The owner names a Python project; a worktree at its default branch on
   `shipkit/real-run-3`, never for merge, headless with `--plugin-dir` at this sprint's
   branch; the 4.9 steps in order; six parts each; one line per E1 to E7; nothing fixed; the
   findings as roadmap items; the branch and worktree deleted on F3's yes.
2. `office_bestie` again: E1 to E7 measured on the project that asked for them; the
   project's own findings are its own to fix.

**Case for (1).** A third stack is the measurement the two runs could not give: the python
stack's rules, a `pyproject.toml`, a test runner shipkit has only seen in fixtures. "Nothing
fixed" keeps the run a measurement of the shipped tool, as the first two were; the record of
E1 to E7 on a project without 4.9's shapes says whether Sprint 17 fixed the shapes or the
project.

**Case against (1).** No Python project with a manifest is under `~/code` on this machine
today (`find` to depth 4), so the owner must name one elsewhere or clone one, and a project
shipkit has never seen costs its first hour in toolchain and layout — 4.9 spent a step on
`mise exec --`. (2) measures E1 to E7 exactly where they were found, at the cost of learning
nothing about the third stack.

**Decision.** We chose (1), E17's default, with the repository the owner names at this spec's
approval; (2) stands if the owner names no Python project.
**Falsifiability.** We would run (2) in addition — in the plan after, not this one — if the
third run shows one of E1 to E7 not holding: then the fix was shaped to one project.
**Fired-if.** manual

---

## Decision: The run's branch and worktree go, on their own yes   (→ REQ-7)

**Context.** The 4.9 run's branch `shipkit/real-run-2` and its worktree under the scratchpad
were deleted on the owner's yes after the notes (F3 of the portfolio plan). The third run
makes a `shipkit/real-run-3` in the owner's repository and a worktree under this session's
scratchpad.

**Alternatives.**
1. After the notes are committed: `git log --oneline` of the branch read and recorded, the
   worktree removed, the branch deleted — the owner's yes first, and the fate written into the
   notes and the ROADMAP item.
2. Keep the branch as the run's evidence.

**Case for (1).** The notes quote every command and every output the run produced; the branch
holds a commit no one will merge in a repository that is the owner's, and a leftover branch
there is a surprise for the owner's next `git branch`. Reading the log first is rule 13.

**Case against (1).** The diff the agent wrote is only in the notes once the branch is gone;
a reader who wants the whole file has the notes' quotes and nothing more.

**Decision.** We chose (1), E18 F3's default; the yes is the owner's, at T3's end.
**Falsifiability.** We would keep the branch (2) if the owner wants the task's change merged
into the project — then it is the project's branch, not the run's.
**Fired-if.** manual
