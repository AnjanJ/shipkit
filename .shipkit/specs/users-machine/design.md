# Design: The user's machine (Sprint 27)

## Approach

Six records: two for G4 (where the prefix goes, and the two stack sections the plan missed), one for
G5, three for G7 (how the wait is counted, the fixture, the bar). G8's choice is project-wide, so its
record is `.shipkit/decisions/0005-evals-home.md`, written by T4, and is not repeated here. Each task
writes its smoke check first and watches it fail. T1 and T3 start with a Check first that costs
model calls, each on the owner's yes.

---

## Decision: `mise exec --` goes before the program, only when the project pins with mise   (→ REQ-1, REQ-2)

**Context.** `office_bestie` pins Elixir and Erlang in `.tool-versions`; in a headless shell
nothing activates `mise`, so the plain test command finds no `mix`, and the 5.1 runner typed
`mise exec --` by hand at every step. Its command is `MIX_ENV=test mix test` (`CLAUDE.md:10`), and
`mise exec -- MIX_ENV=test mix test` runs no program called `MIX_ENV=test`. `mise` 2026.11.1 is on
the owner's `PATH`. Nothing under `plugins/shipkit/` names `mise` today.

**Alternatives.**
1. Setup's Phase 1 step 4 writes the detected command with `mise exec --` after any leading
   `VAR=value` words, when the project has `.tool-versions`, `mise.toml` or `.mise.toml` and `mise` is
   on the `PATH`, and says so in its reply.
2. Setup only prints a hint: "this project pins its toolchain; a headless shell may need
   `mise exec --`".
3. `mise exec -- env MIX_ENV=test mix test`: the prefix always first, `env` carrying the assignments.

**Case for (1).** The prefix reaches every place that reads the command: the **Test:** line, the
stack sections (next record), a task's Done-when, `brief.sh`, the gate's step 2. A hint reaches the
person reading setup's reply once, and no headless step reads it. (1) keeps the user's own words,
where (3) rewrites them.

**Case against (1).** In an interactive shell where `mise` is activated, the prefix is redundant:
harmless, one process more. A project with `.tool-versions` read by `asdf`, and `mise` installed
but unused, gets a prefix it did not ask for, where `mise` reads the same file. (2) touches nothing.

**Decision.** We chose (1), G4's default, with the placement rule.
**Falsifiability.** We would revert to (2) if S27-T1's Check first, `MIX_ENV=test mise exec --
mix test` in a headless `claude -p` Bash call on an `office_bestie` worktree, does not run the
suite; or if a real run's setup on a pinned project writes a command its own gate's step 2 cannot
run.
**Fired-if.** manual

---

## Decision: The elixir and go sections take the test command setup detected   (→ REQ-3)

**Context.** Setup's template writes **Test:** from the detected command (`setup/reference.md:19`).
The elixir append then writes `mix test` twice (`stacks/elixir/CLAUDE.md.append:22-23`) and the go
append `go test ./...` (`stacks/go/CLAUDE.md.append:19`); rails, python and react take the
placeholder. With G4, an elixir project's `CLAUDE.md` would name two commands, one of which does not
run headless, and the gate's step 2 takes "the project's test command" from that file.

**Alternatives.**
1. The elixir run-all and run-one lines and the go run-all line take the `TEST_COMMAND`
   placeholder; go's race-detector line stays.
2. Drop the Testing lines from both appends, leaving setup's **Test:** line alone.
3. Leave them; G4 reaches the **Test:** line only.

**Case for (1).** One command, said the same way in both places, as three stacks already do; an
install without `TEST_COMMAND` exits 2, as for every placeholder. 16 and 3 bytes, inside check 68's
caps.

**Case against (1).** Go's race-detector line still says `go test -race ./...` without the prefix,
on a pinned go project. (2) is fewer bytes, but the "run one" line is the one the W7 audit kept as
useful (`docs/design/trim-audit-overlays.md`).

**Decision.** We chose (1), the owner's yes of 2026-11-05.
**Falsifiability.** We would take (2) if a real run's `CLAUDE.md` names two different test
commands again, from any stack.
**Fired-if.** manual

---

## Decision: The gate searches with `git grep`, and step 3 reads an untracked `tasks.md`   (→ REQ-4, REQ-5, REQ-6)

**Context.** The `fourth-project` reviewer's `grep -n "198,837\|198837" ROADMAP.md` printed nothing
for line 87, twice, where Claude Code's shell snapshot holds the owner's `alias -- grep=rg` beside
its own `grep` function; its Grep tool found the line (`eval-history.md`, "Release run 5.1.0").
The search was the model's own: `reviewer.md` holds no `\|`. Step 3's `grep -n '^- \[ \]'` is the
skill's. Plain `git grep` reads tracked files only: on an untracked `tasks.md` with an unticked
line it exits 1, which step 3 reads as PASS (scratch repository, 2026-11-05).

**Alternatives.**
1. Bash searches are `git grep -n`, `-E` for alternation, never `\|`; step 3 adds `--untracked`.
   The Grep tool, which no shell alias reaches, stays allowed.
2. `command grep`, which skips aliases and functions.
3. The Grep tool only, no Bash search.

**Case for (1).** `git grep` is a git subcommand: no alias, function or `PATH` order changes it,
and its regex is git's on every machine. The reviewer's subject is `git diff <base>...HEAD`, tracked
files, which is what `git grep` reads; `--untracked` covers the one file step 3 must read either
way. `-E` with `|` reads the same in every engine that takes it.

**Case against (1).** `command grep` is one word shorter to say, and finds untracked files without
a flag; BSD and GNU `grep` still differ on `\|`, so (2) leaves half the problem. (3) gives step 3
no exit code to quote, and the gate's report quotes every command with its exit status.

**Decision.** We chose (1), G5's default, with `--untracked` for step 3.
**Falsifiability.** We would revisit if a gate's reviewer marks a requirement NOT MET, or a step
reads PASS, on a search that printed nothing for a line `git grep -n` finds at the same commit.
**Fired-if.** manual

---

## Decision: The wait is counted from the session's own transcript   (→ REQ-7, REQ-8)

**Context.** The 5.1 intake's file was on disk at 00:19:34 and its session ended at 00:23:52; the
JSON result's `duration_ms` said 2,023, which counts neither (`field-notes-5.1.md` §4). A session
transcript under `~/.claude/projects/<the fixture's path>/<session id>.jsonl` carries an ISO
`timestamp` on every entry, and each tool call's name and input.

**Alternatives.**
1. From the transcript: the timestamp of the last tool result for a `Write` or `Edit` of
   `intake.md`, to the timestamp of the transcript's last entry; `Monitor` calls by tool name,
   `sleep` by a Bash command holding the word.
2. From the disk and the clock: `intake.md`'s modification time, to the moment `claude -p` exits.
3. The JSON result's `duration_ms`.

**Case for (1).** It can be read again from a stored transcript, so a smoke check holds the
arithmetic with no model call (REQ-8), and it counts what the model did, which (2) cannot.

**Case against (1).** The session's last entry may come before the process exits, if the platform
holds a session open with nothing written. (2) sees that and (1) does not. (3) was already wrong
once.

**Decision.** We chose (1); the script prints (2)'s wall time beside it for every run.
**Falsifiability.** We would count by (2) if, on any of the five runs, the transcript's last entry
and the process's exit differ by more than 10 s.
**Fired-if.** manual

---

## Decision: The fixture is scaffolded by the script, small enough for research under a minute   (→ REQ-7)

**Context.** G7 asks for "a fixture whose `grandfather` call takes under a minute"; the 5.1
intake's took 53 s on `office_bestie`. The evals ceiling has 2,253 bytes left, and G9 keeps it.
`intake/SKILL.md:34` sends "how does the code do X today?" to `grandfather`.

**Alternatives.**
1. `wait-probe.sh` writes a small git repository (a dozen files, one module the request touches) to
   a scratch directory, with a request that needs one research question answered.
2. Stored fixture files under `evals/` or `scripts/`.
3. A copy of `office_bestie`.

**Case for (1).** No stored bytes; each run starts from the same tree; the research is small, so
the wait, not the work, is what the numbers show.

**Case against (1).** A small fixture may not make the model start `grandfather` in the
background, the shape the 5.1 wait needed; (3) is the shape that showed it, at more cost and with
the owner's product code in the run.

**Decision.** We chose (1).
**Falsifiability.** We would move to (3) if none of the five runs starts `grandfather` in the
background (`"requestShape":"background"` in its meta file, or a background agent call in the
transcript).
**Fired-if.** manual

---

## Decision: A sentence goes in only if 2 of 5 runs idle over 60 s, and stays only if the number moves   (→ REQ-9, REQ-10)

**Context.** One run showed 253 idle seconds (`field-notes-5.1.md` §4). The platform blocked
`sleep 90` and named `Monitor`, and a headless session does not end while a watch is armed. No
skill says anything about waiting.

**Alternatives.**
1. Five runs; the sentence only if 2 or more idle over 60 s; then five runs again, and the sentence
   stays only if fewer than 2 of those idle over 60 s.
2. The sentence now, unmeasured (G7's other option).
3. One idle run in five is enough.

**Case for (1).** A sentence in two skills is read in every intake and every question; it should
show it changes something, and one run is an anecdote. The second five runs are what tell a
sentence that works from one that is only true.

**Case against (1).** Ten runs cost about $5 to learn what one run may already have shown, and a
wait that happens one time in five still costs a headless user four minutes when it does. (3)
would act on that.

**Decision.** We chose (1), G7's default.
**Falsifiability.** We would take (3) if the five runs show a wait over 60 s exactly once and a
real headless run in Sprint 28 shows it again.
**Fired-if.** manual
