# Design: The owner's project again, and 5.2.0 (Sprint 28)

## Approach

Seven records: two for T1 (where the install runs, and where its answer is written), four for the
run (who runs setup, what the prompts leave out, where the evidence lives, what stops the run), one
for the release (the order). The sprint writes no code under `plugins/` but the version lines, so
no task writes a smoke check first; every requirement is read from a record, and each record is a
file in this repository, written before the gate that reads it. `fourth-project`'s first gate
failed on three requirements whose record had not been written yet (`eval-history.md`, "Release
run 5.1.0"), and a commit message is not a place the reviewer reads.

---

## Decision: T1 runs in a config directory of its own, from a local marketplace one version ahead   (→ REQ-1, REQ-3)

**Context.** `claude plugin install` takes `--scope user|project|local`, and `claude plugin update`
takes `--scope user|project|local|managed`, "default: auto-detect" (Claude Code 2.1.318's help
text, read 2026-11-06). A project-scope install is recorded in the user's own
`~/.claude/plugins/installed_plugins.json`, which today holds 11 installs, 4 of them `user` and 7
`local`. The shipkit marketplace on GitHub offers 5.1.0, the version the owner has, so before the
tag an update has nothing to move to and every outcome reads "already at the latest".

**Alternatives.**
1. `CLAUDE_CONFIG_DIR` set to a scratch folder for every command of T1; the marketplace a local
   copy of this checkout's `.claude-plugin/` and `plugins/` at 5.1.0, added by path; install both
   plugins with `--scope project` in a scratch project; set the copy's five version lines to 5.1.1;
   `claude plugin marketplace update`; then the two updates, outside and inside.
2. The owner's own config and the GitHub marketplace: install now at 5.1.0, update after `v5.2.0`
   is tagged, and write the docs then.
3. The owner's own config with the local marketplace of (1).

**Case for (1).** The update has a version to move to before the release, so the answer is in the
docs that 5.2.0 ships. Nothing of the owner's config is written, and REQ-3's checksums prove it.

**Case against (1).** A scratch config is not the owner's machine: a difference that comes from the
owner's settings or other installs goes unseen. If `claude plugin` does not honour
`CLAUDE_CONFIG_DIR`, the first install writes into the owner's files. (2) is the real path a user
takes, but its answer arrives after the docs have shipped. (3) adds a marketplace and a
project-scope entry to the owner's files for the length of the task.

**Decision.** We chose (1). The checksums of the two files are taken before the first command and
after each, and T1 stops at the first that moves.
**Falsifiability.** We would take (2) if either checksum changes during T1, or if the local
marketplace's 5.1.1 is not offered to `claude plugin update` from either place.
**Fired-if.** manual

---

## Decision: T1's answer is written in the field notes, and the docs say it whatever it is   (→ REQ-1, REQ-2)

**Context.** The plan's S28-T1 puts both outcomes "in the commit's test plan, or in the sprint's
notes if no file changed", and changes `README.md` and `GUIDE.md` "only if the answer differs from
what they say". Both files name `--scope user` and `Scope: local` and say nothing of
`Scope: project` (`README.md:47-52`, `GUIDE.md:51-65`). The plan names `docs/GUIDE.md`; the file is
`GUIDE.md` at the root.

**Alternatives.**
1. The record goes in `docs/design/field-notes-5.2.md` under a section before the run's, which T1
   creates; both docs gain one clause on `Scope: project`, whichever way it went.
2. The plan's: the commit's test plan, and the docs only on a difference.

**Case for (1).** The reviewer reads files, not commit messages, so REQ-1 can be MET at the gate.
The docs say nothing of project scope now, so any answer is new to a reader whose
`claude plugin list` says `Scope: project`.

**Case against (1).** It adds a file to T1's Files that the plan gave to T2, and a clause to two
docs that the plan would have left alone if project scope behaves as local scope does.

**Decision.** We chose (1). The plan's S28-T1 Files line is amended at T0, in the same commit as
this spec's stamp, and its `docs/GUIDE.md` corrected to `GUIDE.md`.
**Falsifiability.** We would drop the docs clause if T1 shows `claude plugin update` with no
`--scope` moves a project-scope install from inside the project, so that the README's lines need no
scope word at all.
**Fired-if.** manual

---

## Decision: The owner runs setup in a session of their own; the runner reads its transcript   (→ REQ-5, REQ-9)

**Context.** G6 keeps the second `## Elixir-Specific` by `run-debts`' first record, which reverses
only if a project ends with both sections "after the user read the line". The 5.1 setup was
headless, so no user read it (`field-notes-5.1.md` §2.1). G10 makes the run "interactive for
setup's reply only". A session's transcript lands in
`~/.claude/projects/-private-tmp-shipkit-real-run-6/`, whoever runs it.

**Alternatives.**
1. The runner gives the owner one command line (`cd` the worktree, `MIX_TEST_PARTITION` exported,
   `claude --plugin-dir <checkout>/plugins/shipkit --model sonnet`); the owner types
   `/shipkit:setup`, answers what it asks, reads the reply, does what they choose with the line
   about the two sections, and ends the session; the runner reads that session's transcript.
2. The runner runs setup headless and pastes the reply to the owner, who answers in this thread;
   anything they choose runs as a second headless session.
3. Headless as at 5.1, the reply read later.

**Case for (1).** Unlike the 4.9 and 5.1 setups, both headless, it has a person at the prompt,
so its questions are asked and answered, not skipped, and G6's condition is read as written: the
user read the line in setup's own session.

**Case against (1).** It is not 5.1 §2's shape, so wall time, turns and the reply do not compare
one to one, and the session has no `total_cost_usd` to read. It costs the owner's time at the
keyboard. (2) keeps the runner's numbers whole and still puts the line in front of the owner.

**Decision.** We chose (1), G10's "setup is the owner's to read".
**Falsifiability.** We would take (2) for any later step if the owner's session leaves no
transcript under `~/.claude/projects/-private-tmp-shipkit-real-run-6/` that holds setup's calls and
its reply.
**Fired-if.** manual

---

## Decision: The prompts name no test command; a missing `mise exec --` stops the run   (→ REQ-6, REQ-9)

**Context.** At 5.1 the runner typed `mise exec --` into every step that ran `mix`, and gave the
gate its test command (`field-notes-5.1.md` §7.1, §8, §9). G4 now has setup write
`MIX_ENV=test mise exec -- mix test` when the project has `.tool-versions` and `mise` is on the
`PATH`; `office_bestie` has `.tool-versions` (`elixir 1.20.2-otp-29`, `erlang 29.0.4`) and the
owner's `mise` is `/opt/homebrew/bin/mise`, behind a shell function. The project's own
`CLAUDE.md:10` still says `MIX_ENV=test mix test`.

**Alternatives.**
1. No word from the runner names `mise` or a test command; `MIX_TEST_PARTITION` is exported in
   the environment, not written in a prompt. If setup's `CLAUDE.md` holds no `mise exec --`, the
   run stops after setup and asks the owner.
2. As (1), but on a missing prefix the run goes on and gives the prefix by hand, as at 5.1.
3. Give the command as setup wrote it in each prompt.

**Case for (1).** G4 is read only if nothing else supplies the prefix. If setup did not write it,
every later step would fail its tests, and the run would be spending money to show one finding
nine times.

**Case against (1).** Where the project's line and setup's line disagree, the spec skill picks
one, and a step can fail on the project's line with setup's right; the run then stops on a finding
that (2) would have walked past to read G1, G2, G3 and G5.

**Decision.** We chose (1). A step that fails its tests on the project's own line is a finding, not
a stop; only setup writing no prefix stops the run.
**Falsifiability.** We would take (2) at the owner's word if setup writes no `mise exec --` on this
project, so that the other four lines are still read.
**Fired-if.** manual

---

## Decision: Each step's evidence is copied out of `/private/tmp` as it ends   (→ REQ-7, REQ-8, REQ-11)

**Context.** A reboot on 2026-11-04 cleared the 5.1 run's worktree, its `run/` folder and the gate's
untracked report before the owner's yes (`field-notes-5.1.md`, "Where the evidence is now"). This
run spans at least two days (REQ-8), and the day-one report is the very file G11's second question
reads. The branch lives in `~/code/office_bestie/.git`, which a reboot does not clear.

**Alternatives.**
1. Each step's output, prompt and the day-one report copied to `~/.cache/shipkit-real-run-6/` as
   the step ends; the notes' section written then; if the worktree is gone on day two, it is
   added again from the branch and the report put back from the copy, and the notes say so.
2. A `run/` folder under `/private/tmp`, as at 5.1.
3. A git-ignored folder inside this checkout.

**Case for (1).** Outside `/private/tmp`, outside both repositories, so no reboot clears it and no
`git status` shows it. The transcripts under `~/.claude/projects/` stay where they are.

**Case against (1).** A folder in the owner's home that this sprint must ask to remove. A report
put back from a copy is not the report the gate left, so day two would read a restored tree. (3)
needs a `.gitignore` line, a file outside every task's Files.

**Decision.** We chose (1).
**Falsifiability.** We would move the copies if anything under `~/.cache/shipkit-real-run-6/` is
missing when it is next read.
**Fired-if.** manual

---

## Decision: The run on the same commit and the same item as 5.1   (→ REQ-4, REQ-5)

**Context.** `~/code/office_bestie`'s `main` is still `179f99d`, the commit the 4.9 and 5.1 runs
started from. The 5.1 request was `TODO.md:204`, "The team's 'today' starts at UTC midnight", the
owner's choice; it is still unticked. G10 names the project and leaves the item open.

**Alternatives.**
1. `TODO.md:204` again, with 5.1's words, the runner answering intake's questions as 5.1 did.
2. A different item from `TODO.md`, chosen by the owner.

**Case for (1).** Each section of the notes reads against 5.1's of the same number, and the four
lines this plan changed meet the same diff shape that showed each of them: the same `CLAUDE.md`, the
same first spec, the same test command.

**Case against (1).** A third run on one request may teach the model nothing new and may hide what
a different change would show; slugs and drafts are a roll either way. (2) reads the lines on new
ground.

**Decision.** We chose (1), unless the owner names another item at T0.
**Falsifiability.** No metric would move this choice on its own: it is the owner's, and the record
says so.
**Fired-if.** manual

---

## Decision: The full eval run on the release prep commit, then the gates, this spec's last   (→ REQ-13, REQ-14, REQ-15)

**Context.** The plan's release task: the exit checklist, `/shipkit:ship` on the three specs one at
a time, the pull request, the tag. 5.1.0's full run was $21.10 for 65 cases. A gate reads only what
is committed when it runs; `fifth-run`'s gate reads REQ-13 and REQ-14 from `eval-history.md`.

**Alternatives.**
1. The version bump and CHANGELOG committed; the full run on that commit; its record committed;
   the gates on `gate-on-setup`, then `users-machine`, each recorded and committed; `fifth-run`'s
   gate last.
2. The gates first, the full run last.

**Case for (1).** The costly run comes once, on what ships. Every record `fifth-run`'s gate needs is
committed before it runs, so its READY does not wait on a second gate.

**Case against (1).** A case that fails on a real bug means a change under `plugins/`, and the run
read a tip that does not ship; the run and any gate already read are then re-run outside the
budget line.

**Decision.** We chose (1), as `fourth-project` did. A change under `plugins/` after the run re-runs
the groups it touches and every gate already read, each named to the owner first.
**Falsifiability.** We would reverse the order if the full run exits 1 on a case that needs a change
under `plugins/`.
**Fired-if.** manual
