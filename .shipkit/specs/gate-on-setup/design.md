# Design: What the gate says about setup (Sprint 26)

## Approach

Five records: three for G1's small debts that involve a real choice (the fourth, `walk.md:3`, has
none), one for G2, one for G3. The fourth record **changes G2 from the plan's words**: the plan
said shipkit's section markers tell setup's lines from the project's, and reading the code for this
spec found that they do not on two of the three runs the change is for. Each task writes its smoke
check first and watches it fail.

---

## Decision: The gate prints the review file's path before `Write` gets it   (→ REQ-2)

**Context.** `ship/SKILL.md:68` tells the gate to `Write` the reviewer's reply to
`"${TMPDIR:-/tmp}/shipkit-ship-review.out"`. `Write` takes a literal path, so the 5.1 gate wrote
`/tmp/shipkit-ship-review.out` while every Bash step used `$TMPDIR` (`field-notes-5.1.md` §9.4).
It removed the file after, so nothing was lost; on a machine where the two differ, step 4's paste
and the cleanup at `:103` read a different place than the one written.

**Alternatives.**
1. The gate runs `printf '%s\n' "${TMPDIR:-/tmp}/shipkit-ship-review.out"` and gives `Write` the
   printed path.
2. The gate writes the reply with Bash (`cat > … <<'EOF'`).
3. A fixed path under the project, `.shipkit/tmp/`.

**Case for (1).** One sentence; the path every Bash step uses is the path `Write` gets; `Write`
keeps the reply byte for byte, which `run-debts`' "The gate pastes the reviewer's reply from a
file" record chose it for.

**Case against (1).** It costs one Bash call, and it still asks the model to copy a path from one
call to the next. (2) copies the whole reply through a heredoc, which breaks on a reply holding the
delimiter. (3) puts a scratch file inside the tree the clean-tree step reads.

**Decision.** We chose (1).
**Falsifiability.** We would move to (3) if a gate's transcript shows `Write` given a path other
than the one `printf` printed.
**Fired-if.** manual

---

## Decision: A `Status:` line outside `spec.md` is a gap   (→ REQ-5, REQ-6)

**Context.** The 5.1 spec skill's model wrote `> Status: draft` in `design.md` as well as in
`spec.md`, where `spec/SKILL.md:56` asks for it. The stamp set `spec.md` to `open`; `design.md`
kept `draft`, and no script looked (`field-notes-5.1.md` §6.1, §7.3). Only the gate's model saw it.
No spec in this repository has one (`grep -l '^> Status:'` over every `design.md` and `tasks.md`:
none).

**Alternatives.**
1. `spec-check` prints `STRAY-STATUS <slug> <file>` and exits 1.
2. The same line as information, exit unchanged.
3. A sentence in the spec skill: only `spec.md` carries a Status line.

**Case for (1).** A script reads it every time, the gate's step 1 fails on it, and the fix is
deleting one line. A stray status contradicts the real one, which is the kind of thing a reader
trusts and should not.

**Case against (1).** A gate can now fail on a line that changes nothing the code does. (2) never
fails anything, and a line nobody has to act on is the line this sprint removes elsewhere. (3)
costs skill bytes and is a request, not a check.

**Decision.** We chose (1), G1's default.
**Falsifiability.** We would move to (2) if a real gate reads NOT READY on `STRAY-STATUS` alone
and the owner calls it noise.
**Fired-if.** manual

---

## Decision: The elixir Key Paths take the app's name   (→ REQ-3, REQ-4)

**Context.** `stacks/elixir/CLAUDE.md.append:12-15` write `lib/<app>/`, `lib/<app>_web/`,
`lib/<app>_web/live/` and `lib/<app>/application.ex` into a project's `CLAUDE.md`, beside a
LiveView section that names `test/office_bestie_web/live` (§2.2). The `new-feature` skill's
`<app>` lines are a pattern for any feature and are not in this record.

**Alternatives.**
1. A placeholder, `APP_NAME`, from the `app:` key of `mix.exs`.
2. Drop the table's `<app>` rows and keep only `config/`, `priv/repo/migrations/`, `test/`.

**Case for (1).** The rows are what a reader of a Phoenix project looks for first, and the name is
one line of `mix.exs`. `install-stack.sh` already fails on a placeholder not passed, so a missing
value cannot slip through, and lint check 9 fails one setup's table does not list.

**Case against (1).** Every elixir install now needs one more value, so an older caller that does
not pass it gets exit 2. (2) needs no value and loses the four rows a reader wants.

**Decision.** We chose (1), G1's default.
**Falsifiability.** We would move to (2) if a real setup run on a Phoenix project passes an
`APP_NAME` that is not its `app:` key.
**Fired-if.** manual

---

## Decision: Setup's files are setup's while they are as setup left them   (→ REQ-7 to REQ-13)

> Supersedes `run-debts`' "Setup's two directories join the always-allowed list" (its
> Falsifiability met: 4.12, 5.0 and 5.1 all reported `CLAUDE.md` and `.gitignore` with nothing in
> them but setup's).

**Context.** `brief-verify.sh` and the reviewer report `CLAUDE.md` and `.gitignore` even when only
setup changed them (`run-debts/REQ-6`, `REQ-7`). Three runs in a row did exactly that
(`field-notes-4.12.md:379`, `field-notes-5.0.md:203`, `field-notes-5.1.md` §9.1). The plan's G2
said: setup's when every changed line is inside shipkit's section markers, or is a `.gitignore`
line setup writes. But on `linkshort` setup *created* `CLAUDE.md` (`?? CLAUDE.md`,
`field-notes-5.0.md:69`): the project-facts half is written by the setup skill's model from
`reference.md`, outside every marker. And setup's `.gitignore` lines are the model's too: four are
named (`setup/SKILL.md:198-205`), five were written on the 5.1 run.

**Alternatives.**
1. **A digest when setup ends.** `setup-files.sh . record` writes each file's git blob id to
   `.claude/rules/shipkit/.setup-files`; a file whose blob id still matches is setup's, and
   anything else, setup's lines plus one more, is reported.
2. The plan's words: markers for `CLAUDE.md`, a fixed list of lines for `.gitignore`.
3. Keep reporting both, and lower the old record's bar to a later run.

**Case for (1).** It covers all three runs' shapes: a new `CLAUDE.md`, an appended one, and a
`.gitignore` with whatever lines setup wrote. It needs nothing from the model's wording, only that
setup runs one command last. `git hash-object` is git's, so the reviewer can check it with no
script and no plugin root. A missing record (an older setup, or a headless one that skipped the
step) means the old behaviour: reported, never a silent pass.

**Case against (1).** It is all or nothing: a user who adds one line to setup's `CLAUDE.md` before
the first spec gets both setup's lines and theirs reported, where (2) would report only theirs. It
adds a file to `.claude/rules/shipkit/` that is not in the manifest, so `unsetup-remove.sh` has to
name it. It depends on the setup skill running the step, which a model can skip. (2) is what the
owner approved, and catches the appended case with no new file.

**Decision.** We chose (1). It changes the plan's G2; the owner said yes on 2026-11-05, and the
plan's G2 is amended to match.
**Falsifiability.** We would add (2)'s marker reading beside (1) if a real run reports
`CLAUDE.md` because the user edited it between setup and the first spec, and we would revisit (1)
if a real setup run ends with no `.setup-files` written.
**Fired-if.** manual

---

## Decision: A third mark, `partly built`   (→ REQ-14, REQ-15)

**Context.** The 5.1 reviewer marked the third decision `not built` "for the workspace path",
naming the fallback that does exist. Its words were right and the mark was not (§9.2).
`reviewer.md:57-59` has two marks; `:94-95` says `not built` does not change the verdict.

**Alternatives.**
1. `partly built`: the part that exists and the part that does not, each with `path:line` or the
   file it would be in; reported, verdict unchanged.
2. Leave the two marks; the reviewer's words carry it.

**Case for (1).** The mark is what a reader scans; the words are what they read after. It changes
no verdict, so no case can move, and the `decision-unbuilt` grader matches `not built` on a
decision with no code at all, which stays `not built`.

**Case against (1).** A third mark is one more thing a model can pick wrongly, and a `partly built`
that hides a contradicted half would hide a FAIL. (2) costs nothing.

**Decision.** We chose (1), G3's default. The sentence says a part that does what the record turned
down is `contradicted`, whatever else exists.
**Falsifiability.** We would revert to (2) if a `reviewer` case reads `partly built` where its
grader wants `contradicted` in any run at the merge's `--group reviewer`.
**Fired-if.** manual
