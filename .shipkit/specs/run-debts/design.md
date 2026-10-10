# Design: The run's debts (Sprint 17)

## Approach

Nine records, one per plan decision (E1 to E8, E18), and a sprint that is seven small fixes
and one record. Each fix lives where the finding did — `install-stack.sh` for the heading,
`install-rules.sh` for the same-named rule, the setup skill for the tracked backup, `brief.sh`
and `brief-verify.sh` for the hand-over, the reviewer and the ship skill for the citation and
the paste — and each has a smoke check written first. No rule file, eval, lint or hook
changes; the three injected rules stay at 2,979 bytes. The behaviour of the two skill-text
changes (E1's relay, E3's backup rule) and of the reviewer's sentence (E6) is model
behaviour: the checks hold the text, and the third real run (Sprint 19, E17) is the measure.

---

## Decision: The installer looks for the heading before it appends   (→ REQ-1, REQ-2)

**Context.** `install-stack.sh` guards its `CLAUDE.md` section with a marker pair and a sha
(`install-lifecycle` DR-4), so a re-run refreshes its own block and never touches the user's
prose. It checks for its marker, not for the heading it is about to add. `office_bestie` had
its own `## Elixir-Specific` at line 76 with the project's test command; setup appended
shipkit's at line 139 with another, and both load into every session (`field-notes-4.9.md`
§2.1).

**Alternatives.**
1. Before appending, the installer looks for the section's first `## ` heading among the
   `CLAUDE.md` lines outside shipkit's markers. Present: the section is still written under
   its markers and its sha recorded, and one stderr line names the heading and
   `/shipkit:update-rules` as the way to merge; the setup skill relays the line and shows the
   two sections' diff. Absent: nothing new.
2. Skip the section when the heading exists.

**Case for (1).** The managed block and its sha stay true, so the next run can still tell
what shipkit wrote; the user learns there are two sections at the moment it happens, with
the diff in front of them, and the merge is theirs to make through the skill that edits
rules. A heading inside an earlier shipkit block is shipkit's own: the comparison skips the
marked region, so a refresh never warns about itself.

**Case against (1).** The project gets two sections for the length of one reply, and a
non-interactive setup (the real run's shape) leaves them both. (2) leaves one section and no
record of what shipkit would have written; the next `setup` cannot refresh what it never
wrote, and the manifest's `stacks=` says the overlay is installed when its section is not.

**Decision.** We chose (1), E1's default.
**Falsifiability.** We would move to (2) if the third real run (E17) shows a project that
already carries the heading ending with both sections after the user read the line — then
the line is not enough and the installer must choose.
**Fired-if.** manual

---

## Decision: A same-named rule beside shipkit's is named, not merged   (→ REQ-3)

**Context.** Claude Code loads every `*.md` under `.claude/rules/` recursively. `office_bestie`
keeps `dependencies.md`, `migrations.md` and `testing.md` at `.claude/rules/`; shipkit installs
its own three under `.claude/rules/shipkit/`; both sets load on the same paths and the setup
reply did not say so (§2.2).

**Alternatives.**
1. `install-rules.sh` compares the basenames at `.claude/rules/` top level with the rules it
   installs and prints one line naming every match and saying both load on the same paths.
   It changes, moves and removes nothing.
2. Nothing: the project's rules are the project's.

**Case for (1).** One line, from the script that knows what it installed, at the moment the
duplicate appears; the user decides. The script already owns a manifest of its own files and
never touches a file it does not own (`install-lifecycle` DR-2), so naming is the most it may
do.

**Case against (1).** A same-named file is not always a duplicate (a project's `testing.md`
may say something shipkit's does not), so the line can be noise; overlay rules under
`.claude/rules/shipkit/<stack>/` are not compared, so a project's `rails.md` beside shipkit's
goes unnamed. (2) is what 4.9 did, and the run read it as a miss.

**Decision.** We chose (1), E2's default; core rules only, top level only — the run's shape.
**Falsifiability.** We would extend the comparison to overlay rules if a real run shows a
same-named overlay rule beside shipkit's that the line missed.
**Fired-if.** manual

---

## Decision: A tracked backup stays where it is   (→ REQ-4)

**Context.** Setup nests the previous `.shipkit-backup-*` inside the new one and removes it
from the root, so one backup directory stands at a time. `office_bestie`'s earlier backup was
committed before the `.gitignore` lines existed; the move became fourteen deletions in
`git status` (§2.3). The field notes call it both the project's fault and the tool's.

**Alternatives.**
1. Before nesting, the skill asks `git ls-files --error-unmatch <dir>`; tracked → the
   directory is left at the root and named in the reply ("… is tracked; left as is — remove it
   from git yourself if you want it gone"); untracked, or no repository → nested as now.
2. Move it as now and say so.

**Case for (1).** Setup never turns into a `git rm`: a tracked directory is the user's to
delete, deliberately, as the skill's own "never offer to delete an existing backup" rule says
of untracked ones. The question is one git command and its exit code.

**Case against (1).** Two backups then stand at the root until the user acts, and a project
that tracks every backup accumulates them. (2) is what 4.9 did and left the owner with
fourteen deletions to decide about, each one a file they might not have wanted gone.

**Decision.** We chose (1), E3's default. The check is skill text (smoke check 61 greps the
command and the sentence); the behaviour is measured on the third real run.
**Falsifiability.** We would move the backup phase into a script if the third real run shows
the model nesting a tracked backup with the sentence in front of it.
**Fired-if.** manual

---

## Decision: The brief warns on a dirty tree; the verifier is unchanged   (→ REQ-5)

**Context.** `brief-verify.sh` reads every difference from the base ref, committed or not,
and cannot tell the agent's change from one already in the tree at hand-over. In the real run
fourteen OUTSIDE lines were setup's deletions, none the agent's (§8.1). Plan rule 19 now says
to hand over from a clean tree.

**Alternatives.**
1. `brief.sh` counts `git status --short` and, when non-zero, prints one line to stderr —
   `brief: N file(s) already differ from HEAD; brief-verify will count them` — with the
   brief on stdout unchanged.
2. `brief-verify.sh --since <ref>` that ignores files already differing at the base.

**Case for (1).** The warning lands at the moment the rule applies, on the channel the brief
does not use, so a caller that captures stdout for an agent sees nothing new and a human at
the terminal sees the line. Rule 19 is the discipline; the line is the reminder, and one `wc`.

**Case against (1).** A warning is not a guard: a runner that ignores stderr hands over
anyway. (2) is more machinery — a second snapshot to keep and pass — for a case the rule
already prevents, and it hides a dirty tree instead of naming it.

**Decision.** We chose (1), E4's default.
**Falsifiability.** We would build (2) if a later real run hands over from a dirty tree with
the line printed — then the reminder is not read and the verifier must cope.
**Fired-if.** manual

---

## Decision: Setup's two directories join the always-allowed list   (→ REQ-6, REQ-7)

**Context.** Since 4.5.0 everything under `.shipkit/` is inside every task's files, for
`brief-verify` by code and the reviewer by its step 4, because shipkit's own loop writes them
and no Files or Paths line will name them (`gate-blind-spots` REQ-5 to REQ-7). Setup's files
— `.claude/rules/shipkit/`, `.shipkit-baseline/`, `CLAUDE.md`, `.gitignore` — were not on the
list, so the first spec on a freshly set-up project carries them as "beyond the spec" (§9.4).

**Alternatives.**
1. `.claude/rules/shipkit/` and `.shipkit-baseline/` join the list in both places; `CLAUDE.md`
   and `.gitignore` stay reported.
2. All four allowed when the install manifest's sha matches what setup appended.

**Case for (1).** The two directories are written only by the installer and hold only its
copies; a change there is never the agent's work. `CLAUDE.md` and `.gitignore` hold the
project's own content: a line there is worth a reviewer's sentence even when setup wrote it,
and a reader can tell setup's section (under its marker) from an agent's edit.

**Case against (1).** Every first spec after setup still reports `CLAUDE.md` and
`.gitignore`, two lines the user learns to skip. (2) would silence them only when the manifest
agrees, a check the reviewer agent cannot run cheaply and `brief-verify` would have to learn.

**Decision.** We chose (1), E5's default.
**Falsifiability.** We would add (2) if two consecutive real runs report `CLAUDE.md` and
`.gitignore` as beyond the spec with no change in them but setup's.
**Fired-if.** manual

---

## Decision: One sentence tells the reviewer where a line number comes from   (→ REQ-8)

**Context.** The reviewer cited `accounts.ex:18-23` for a function at line 605 and tests at
line 421; the numbers were positions inside the diff it read (§9.1). The verdict was right and
the one line a reader would open was not.

**Alternatives.**
1. One sentence in `agents/reviewer.md`: a `MET` citation's `path:line` is the line in the
   working tree as `grep -n` prints it, never a position inside a diff hunk. The gate pastes
   the reply whole (E7), so a wrong number is visible.
2. The gate re-checks every `MET` citation with `sed -n` and reports a mismatch.

**Case for (1).** The agent reads diffs and files both; it needs to be told which numbering a
citation uses, and `grep -n` is the command it already runs. No cost on the gate.

**Case against (1).** It is model behaviour: a sentence changes the odds, not the outcome,
and no eval measures it — the third real run is the measure. (2) is certain and costs a loop
over every citation on every gate run, for a mistake seen once.

**Decision.** We chose (1), E6's default.
**Falsifiability.** We would build (2) if the third real run's reviewer cites a diff position
with the sentence in place.
**Fired-if.** manual

---

## Decision: The gate pastes the reviewer's reply from a file   (→ REQ-9)

**Context.** `gate-blind-spots` REQ-9 asks for the reviewer's reply pasted; the skill says
"copy its whole reply into the report". The gate condensed it in 4.7.0's run, in 4.9's real
run ("summarised table; full verdict line unchanged", §9.2) and in the 4.9.0 release gate.
Step 2 has pasted test output from a file since 4.5.0 and has not condensed it since.

**Alternatives.**
1. Step 4 writes the reviewer's reply to `${TMPDIR:-/tmp}/shipkit-ship-review.out` and pastes
   the report's review block from that file, as step 2 does for tests; the file goes with the
   other scratch files at the end.
2. A sentence only: "paste the whole reply, every line".

**Case for (1).** The model summarises what it holds in context and pastes what it reads
from a file; the mechanism is the one that fixed step 2. The file is removed by the line that
already removes `shipkit-ship-*.out`, so nothing new is left behind.

**Case against (1).** One more `Write` per gate run, and a reply held in context is written
out and read back for no reason but the model's habit. (2) was tried in 4.5.0's wording and
read as "condense" twice since.

**Decision.** We chose (1), E7's default. Check 29's READY run is the measure: the report's
review block holds the reviewer's heading, a row per requirement, the count line and the
verdict line.
**Falsifiability.** We would reverse to a sentence-only approach if check 29 shows the block
pasted from the file still condensed in two consecutive smoke runs — then the file is not the
mechanism.
**Fired-if.** manual

---

## Decision: The leaked wait sentence is closed by record   (→ REQ-10)

**Context.** Three headless replies on 2026-10-10 opened with a sentence written while the
skill waited on a background `Agent` call, then gave the full answer anyway:

- the intake (`field-notes-4.9.md` §4.1): "The research agent is still running. I'll stop here
  until its notification arrives";
- the gate on `office_bestie` (§9.3): "Still waiting on the reviewer agent; I'll write the
  report once its verdict arrives";
- the 4.9.0 release gate (`CHANGELOG.md` 4.9.0): "The reviewer is still running. I'll write
  the report once its notification arrives".

Each is the harness's shape when a skill waits on an `Agent` result in a `-p` run: the model
writes a turn, the notification arrives, the model continues, and both turns are the final
reply. No skill text asked for the sentence.

**Alternatives.**
1. Closed by record: no skill change; this record holds the quotes; reopened on a condition.
2. A "do not narrate waiting" sentence in `ask`, `intake` and `ship`.

**Case for (1).** The sentence is harmless to the file each skill writes (the intake, the
report) and confusing only to a reader who stops at line two. A sentence in three skills
costs bytes in every session for a behaviour the platform produces, with no eval to say it
works.

**Case against (1).** A user who reads only the reply's first lines is told the skill
stopped when it did not. If an interactive session shows it, the harness is not the cause.

**Decision.** We chose (1), E8's default.
**Falsifiability.** We would add the sentence (2) if an interactive session's reply opens with
a wait sentence and continues — then it is the skill's shape, not the harness's.
**Fired-if.** manual

---

## Decision: Two cache directories go, each on its own yes   (→ REQ-11)

**Context.** `~/.claude/plugins/cache/shipkit/shipkit/` holds `4.6.0`, `4.7.0` and `4.9.0`;
the owner's sessions run from `4.9.0` (the hook line at this session's start). The older two
are copies the cache update left behind.

**Alternatives.**
1. Remove `4.6.0` (F1) and `4.7.0` (F2), each on its own yes, each after `/bin/ls` of the
   target and the interactive session's hook line reading `4.9.0`; the command and its output
   in the commit message; the ROADMAP records each row.
2. Keep any row.

**Case for (1).** Nothing reads them; a session that ever did would say so in its hook line.
Each is looked at before removal (rule 13) and recorded.

**Case against (1).** A cache directory is cheap to keep and the plugin manager may expect
one it listed; removal is the owner's call, not the sprint's.

**Decision.** We chose (1), E18's default, F1 and F2 only; each row is a separate yes at T5.
**Falsifiability.** We would stop at F1 if `claude plugin list` or the next session's hook line
names `4.6.0` after its removal — then the manager still wanted it.
**Fired-if.** manual
