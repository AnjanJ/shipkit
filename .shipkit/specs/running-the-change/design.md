# Design: running the change

## Approach

Three new pieces of software and one audit, all model-free and all new files, except
`hooks.json`, `scripts/smoke.sh`, `GUIDE.md`, the two design notes and the plan, which gain lines.

- `plugins/shipkit/scripts/verify-run.sh` (REQ-1 to REQ-12): POSIX `sh`, `awk` and `curl`. It
  makes one directory with `mktemp -d "${TMPDIR:-/tmp}/shipkit-verify.XXXXXX"`, picks a port,
  starts the start command in its own process group with its output in a file in that
  directory, probes the port, makes the one request, and on every way out stops the group and
  removes the directory. The process pattern is `red-check.sh`'s (`:134-145`: `mktemp -d`, a
  `cleanup` on `EXIT`, `exit 130` on `INT TERM HUP`).
- Two `verify` skills, `plugins/shipkit/stacks/{elixir,static}/.claude/skills/verify/SKILL.md`
  (REQ-13 to REQ-15), a few lines each, text below. They are new overlay files behind
  `--with-skills` (decision 0004), and use no placeholder, so `install-stack.sh` needs no new
  `KEY=value` (`install-stack.sh:88-100` exits 2 on an unfilled one).
- `plugins/shipkit/scripts/commit-gate.sh` (REQ-18 to REQ-27): POSIX `sh` and `sed`, no `jq`, as
  `guard-commit.sh` is. A second command on the `Bash` matcher in `hooks.json`.
- `docs/design/trim-audit-checks.md` (REQ-30 to REQ-34): a table, one row per smoke check label
  and eval case, kept honest by a smoke check.

What the hook documentation says (T2's subtask 1, read on 2026-11-20 at
`https://code.claude.com/docs/en/hooks`): a `PreToolUse` hook for `Bash` gets JSON on stdin
with the fields `session_id`, `prompt_id`, `transcript_path`, `cwd`, `scratchpad_dir`,
`permission_mode`, `hook_event_name`, `tool_name`, `tool_input` (holding `command`,
`description`, `timeout`, `run_in_background`) and `tool_use_id`. "When an event fires, its
matching hooks run in parallel." Exit 2 blocks the call and its standard error is the reason;
exit 0 lets it through and Claude never sees its standard error; any other exit lets it through
with a notice. `timeout` is in seconds, and a timed-out command does not block. The docs do not
say the JSON is compact, and their example is indented. The docs do not say `session_id` is
always present. Sprint 35's captured hook call confirms these.

What Phoenix's generator writes (read on 2026-11-20 from `phoenixframework/phoenix` `main`,
`installer/templates/phx_single/config/`): `test.exs.eex` sets
`http: [ip: {127, 0, 0, 1}, port: 4002]` and `server: false`; `runtime.exs.eex` sets
`http: [port: String.to_integer(System.get_env("PORT", "4000"))]` outside any environment test,
and `server: true` when `PHX_SERVER` is set. `lib/phoenix/endpoint/supervisor.ex:224-228` reads
the endpoint's own `server:` key first and the global flag `mix phx.server` sets only when that
key is absent, so in the test environment `mix phx.server` alone serves nothing and
`PHX_SERVER=true` is what turns the server on. An older generator read `PORT` in `prod` only.
Which generator the owner's project came from is read on the clone in Sprint 35.

## Decision: the port is handed over as `PORT` in the environment   (→ REQ-1)

**Context.** The script picks the port; the application must listen on it. The start command is
the user's or the skill's text, run by `sh -c`.

**Alternatives.**
1. `PORT` exported into the start command's environment; a command that needs the number on its
   command line writes `"$PORT"`, which `sh -c` expands.
2. A placeholder such as `{port}` that the script replaces in the command text before running it.
3. A `--port <n>` flag, so the caller picks the port.

**Case for 1.** One mechanism serves both kinds of application: Rails' Puma config and
Phoenix's generated `runtime.exs` read `PORT` with no flag, and `python3 -m http.server "$PORT"`
and `npx serve -l "$PORT"` take it on the command line. No text substitution, so no quoting
trap. §5 line 6 forbids assuming a port, which rules out 3 as the way the port is chosen.

**Case against 1.** An application that ignores `PORT` (a Phoenix test environment from an older
generator, a fixed port in config) is never reached and reads `NOT-READY`: honest, but the line
does not say why. The skill has to tell the model to report that and name the config line.

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if Sprint 35's run on the clone reads `NOT-READY`
because the application ignored `PORT` and no `--env` could make it listen on the port.
**Fired-if.** manual

## Decision: a random high port, probed with `curl`   (→ REQ-1, REQ-12)

**Context.** Settled by the intake's answer 2. Recorded here for its reversal condition. No
plugin script uses `python3`, `nc` or `lsof`.

**Alternatives.**
1. A random port in 20000 to 60999, from `awk` seeded with the script's process id and the time;
   `curl --max-time 1` to it must fail with exit 7 (connection refused), else another is tried,
   up to 20.
2. Ask the system for port 0 with `python3` and read what it bound.
3. `lsof` or `nc -z` to test the port.

**Case for 1.** `curl` is the one new tool the script needs anyway, and it is on macOS and on
CI's runners as shipped. Seeding with the process id keeps two runs in the same second apart.

**Case against 1.** Between the probe and the application's bind another process can take the
port. The application then fails to bind (`EXITED`) or another application answers. The second
case reads as `RAN` from the wrong application. The header says so (REQ-12), and the odds are one
in about 41,000 per run on an idle machine.

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if a model-free smoke run, here or on CI, fails
REQ-11's ten runs because of a port taken by something else.
**Fired-if.** manual

## Decision: its processes are one process group, stopped as a group   (→ REQ-7, REQ-11)

**Context.** `sh -c '<command>'` may start the server as a child (`mix` starts `beam.smp`, a
shell runs `python3`), so the process id `$!` alone is not the server. REQ-7 forbids stopping any
other process.

**Alternatives.**
1. `set -m` before starting the command, so it runs in a process group of its own whose id is
   `$!`. To stop it: `kill -TERM -- -<id>`, then `kill -KILL -- -<id>` if a member is left after 3
   seconds.
2. Stop `$!` only.
3. Walk `ps -A -o pid= -o ppid=` from `$!` and stop every descendant.

**Case for 1.** Tried on 2026-11-20 with macOS `/bin/sh` (bash 3.2, Darwin 27.2.1 arm64):
`sh -c 'python3 -m http.server "$PORT" & sleep 300'` started under `set -m` took a group id equal
to its process id, other than the script's own, with all three processes in it. One
`kill -TERM -- -<id>` left none. A group cannot hold the script's own shell or any process it
did not start, so REQ-7's "no other process" holds by construction. A tree walk races with
processes that start or exit while it reads.

**Case against 1.** A process that leaves the group on purpose, through `setsid` or a daemon
mode, escapes it. Linux's `sh` is `dash`, where `set -m` in a script is not tried here, and the
model-free smoke job runs on macOS only, so CI does not show it.

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if a smoke run finds a process of the static fixture
left after a run, or if `dash` refuses `set -m` in a script.
**Fired-if.** manual

As built in T1 (2026-11-20), two details the record did not fix:
- **How `EXITED` is seen.** The start command runs as `( sh -c "$START"; echo $? > code ) &`,
  and the script waits for the file `code`, not on `kill -0`. A shell that has not reaped a
  finished child still answers `kill -0` for it, so the file is the sign that does not depend
  on the shell. The subshell is the group's leader.
- **When no group is made.** After the start, `ps -o pgid= -p <pid>` is read. If it is not the
  process id, the shell made no group (the `dash` risk above), and the processes under that id
  are found through `ps -A -o pid= -o ppid=` and stopped instead: the record's alternative 3, as
  a fallback.

## Decision: readiness is probed on a path of its own   (→ REQ-3, REQ-4)

**Context.** REQ-4 says the request is made once. The script must learn that the port answers
without making that request.

**Alternatives.**
1. `curl --max-time 1 -s -o /dev/null` on `/shipkit-verify-probe`, every 0.25 s. Any HTTP status
   counts as an answer: a 404 is an answer.
2. Probe the request path itself.
3. A bare TCP connect (`nc`, or `curl` with the `telnet` scheme).

**Case for 1.** `curl` prints an HTTP status for any response and exits 7 on a refused
connection, so "answers" is exactly REQ-3's term. The request path is left untouched until the
one request.

**Case against 1.** The probe shows as a 404 in the application's log, and a request path of
`/shipkit-verify-probe` would be made more than once. A server that answers 404 before its
routes are loaded is counted as ready too early.

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if a Sprint 35 run reads `RAN` with a status the same
request does not give a second later, the sign of a server probed as ready too early.
**Fired-if.** manual

## Decision: exit 0 on `RAN`, 1 on `NOT-READY` or `EXITED`, 2 on misuse   (→ REQ-4 to REQ-6, REQ-9, REQ-10)

**Context.** Chosen at the requirements gate (the owner, 2026-11-20). `red-check.sh` exits 0 on
any verdict word.

**Alternatives.**
1. 0, 1, 2 as above.
2. 0 on any outcome line, 2 on misuse, as `red-check.sh` does.

**Case for 1.** A task's `Done when` can name the script and its exit code ("`verify-run.sh …`
→ exit 0"), and a `RAN` with any status still means the application ran.

**Case against 1.** Exit 1 reads as "the script failed" to someone who does not read the line,
and the two scripts of the plan differ.

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if, in Sprint 35's three model runs per stack, a run
treats exit 1 as a fault of the script and does not report its line.
**Fired-if.** manual

## Decision: the skill finds the script through the plugin root line   (→ REQ-14)

**Context.** The skill is installed into the project; the script stays in the plugin.

**Alternatives.**
1. The `shipkit: plugin root is …` line the session hook prints, and
   `~/.claude/shipkit/plugin-root` where no such line is in context (`session-start.sh:88-104`),
   as `/shipkit:spec` finds `spec-check.sh`.
2. Copy `verify-run.sh` into the project with the skill.

**Case for 1.** One copy of the script, updated with the plugin. The core skills already find
their scripts this way.

**Case against 1.** A session with the plugin's hooks switched off has no root line, and a
missing `plugin-root` file leaves the model with nothing to run.

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if, in Sprint 35's model runs, one run in three cannot
find the script.
**Fired-if.** manual

## Decision: the start commands the skills name   (→ REQ-14)

**Context.** REQ-14 asks each skill to name its stack's start command. §5 line 5 runs the
owner's Phoenix project in the test environment only.

**Alternatives.**
1. Static: the `Dev server:` line of `CLAUDE.md` where it names a server that takes a port
   (`npx serve -l "$PORT"`, `npx vite --port "$PORT"`), otherwise `python3 -m http.server
   "$PORT"`, run from the site's folder. Elixir: `mix phx.server` with `--env PHX_SERVER=true`
   and `--env MIX_ENV=<the environment the task names, test when it names none>`.
2. One fixed command per stack, with no reading of `CLAUDE.md`.

**Case for 1.** The static overlay already records the dev server
(`stacks/static/CLAUDE.md.append:6`), and `python3` is on every machine CI and the owner use.
For Phoenix, `PHX_SERVER=true` is what serves in the test environment, from the generator's
own text (Approach).

**Case against 1.** The model has to read one line of `CLAUDE.md` and choose. A `Dev server:`
line with a command that takes no port leads to the fallback, which may serve the wrong folder
for a built site (`dist/`).

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if Sprint 35's three static runs use a start command
other than the one this text names in any run.
**Fired-if.** manual

## Decision: the gate reads the hook's JSON with `sed`, allowing white space   (→ REQ-18 to REQ-25)

**Context.** No `jq` and no `python3` (the intake's answer 2, `guard-commit.sh:20`). The docs do
not promise compact JSON.

**Alternatives.**
1. `sed` patterns of the form `"session_id"[[:space:]]*:[[:space:]]*"…"`, on the whole input with
   its newlines joined. The stamp and the message flags are looked for in the raw text of
   `tool_input.command`, where a newline is `\n` and a quote `\"`.
2. `"cwd":"` with no space, as `guard-commit.sh:30` does.
3. `jq`.

**Case for 1.** It reads compact and indented JSON alike, and a stamp holds no character JSON
escapes (`Verified:`, a word, a space, `(`).

**Case against 1.** A value holding an escaped quote is cut short at it, so a session id with a
quote is misread. Where the read fails, REQ-25 lets the commit through. `git commit` inside a
quoted string of another command (`echo "git commit"`) counts as a commit call, as it does for
the guard.

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if Sprint 35's captured hook call holds a field this
reading gets wrong.
**Fired-if.** manual

How the text is read:
- **A message on the command line:** after `git commit`, a word `-m`, `--message`,
  `--message=…`, or a word of `-` and letters that ends in `m` (`-am`, `-sm`). Anything else
  (`-F`, `--file`, `-C`, `--no-edit`, no flag at all) is unseen (REQ-24).
- **A stamp:** the extended regular expression
  `Verified: (tests|gate|brief-verify|ran|none) \([^)]+\)` on the command text.

Found on the way: `guard-commit.sh:30` reads `cwd` only from compact JSON. With indented JSON it
does not move to the session's directory and checks the hook's own working directory. This is
outside this spec, so it goes to the owner to decide, not into a task.

## Decision: blocks are counted from the log   (→ REQ-22, REQ-23)

**Context.** `enforce` lets the third unstamped commit of a session through. Something must
remember two blocks between calls.

**Alternatives.**
1. Count rows with that session id and the word `blocked` in the log.
2. A state file per session under `$SHIPKIT_HOME`.

**Case for 1.** One file, one truth: the rows the owner reads are the rows the gate counts. No
second file to clean up, and no SessionEnd hook to clean it (smoke `:2575` asserts none).

**Case against 1.** The log grows with every observed commit and is never trimmed, and each
`enforce` decision reads all of it.

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if the log on the owner's machine passes 1 MB.
**Fired-if.** manual <!-- the log lives outside the repository -->

Row form: `<UTC time as %Y-%m-%dT%H:%M:%SZ>\t<session id>\t<mode>\t<word>\t<cwd>`, where the
word is `unstamped`, `blocked`, `passed` or `unseen`. The `$SHIPKIT_HOME` directory is made if
missing. The block line on standard error is:
`shipkit: commit gate (enforce): add a line "Verified: <tests|gate|brief-verify|ran|none> (<what>)", e.g. "Verified: none (docs only)".`

## Decision: a separate script, and what it costs   (→ REQ-26, REQ-28)

**Context.** The intake's answer 3 keeps `commit-gate.sh` apart from `guard-commit.sh`, with the
cost of the extra process measured.

**Alternatives.**
1. A second hook command.
2. Fold the gate into `guard-commit.sh`.

**Case for 1.** The secret guard stays as it is, at 54 lines with its own checks
(smoke `:696-742`). The gate can be switched off and removed alone. Hooks run in parallel, so
the gate's start overlaps the guard's.

**Case against 1.** Every Bash call of every session starts one more process, even with the gate
off. Measured on 2026-11-20 (macOS 27.2.1, arm64, 300 calls each, the hook's JSON for `ls -la`
on stdin): `/usr/bin/true` 2.16 ms, `/bin/sh -c :` 4.12 ms, `guard-commit.sh` 6.54 ms and
6.46 ms. A script of the guard's shape costs about 6.5 ms of process time per call. T2
measures `commit-gate.sh` itself the same way and writes the number here.

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if T2 measures `commit-gate.sh` above 15 ms per call
on a call that is not a commit.
**Fired-if.** manual

## Decision: the audit is a table that a smoke check holds to the registry   (→ REQ-30 to REQ-32)

**Context.** Chosen at the requirements gate (the owner, 2026-11-20). An audit that nothing
checks goes stale at the next new check.

**Alternatives.**
1. A smoke check that compares the audit's rows with `registry()` and `scripts/evals-map.tsv`.
2. The audit as prose, checked by reading at each release.

**Case for 1.** A new check or case without a row fails the model-free suite, so the prune pass
at each release (REQ-34) starts from a complete list.

**Case against 1.** Every new check or case costs a row, Sprint 35's included.

**Decision.** We chose 1.
**Falsifiability.** We would reverse this if, at the next release's prune pass, no row's
"last failed" column has changed since 5.4.0, a sign that nobody uses the audit.
**Fired-if.** manual

The audit's table: `| Kind | Label | Last failed on a real defect | Also covered by | Cost | Candidate | Cut |`.
Kind is `smoke` or `eval`. Label is the registry label or the case as `evals-map.tsv` names
it. The next three cells take the forms `spec.md`'s Terms give (`X.Y.Z` or `never`; labels or
`nothing`; `<n> s` or `$<n>`), and the smoke check holds each to its form. Candidate is `no`, `yes: <which of the plan's three rules>`, or `kept (0008)` for a trap-2 case.
Cut is empty, or `cut <date of the yes>`. The smoke check reads the rows between two marker
lines, `<!-- audit:begin -->` and `<!-- audit:end -->`, and fails on a missing row, a row
without a cut date for a label no longer listed, a trap-2 case marked `yes`, or a cut row whose
label is still listed.

The plan's three candidate rules (S34-T3, subtask 2): a check that never failed and whose
requirement another check covers; a text-only assertion with a behaviour check beside it; a case
at full score in every ledger row whose rule a script also holds.

## Data / interface changes

- `verify-run.sh --start '<command>' --request <path> [--env KEY=VALUE …] [--timeout <s>]`;
  standard output as REQ-4 to REQ-8; exit 0, 1 or 2.
- `commit-gate.sh` reads the hook's JSON on stdin; `SHIPKIT_COMMIT_GATE`, `SHIPKIT_HOME`; the
  log `$SHIPKIT_HOME/commit-gate.log`.
- `hooks.json`: the `Bash` entry's `hooks` list gains
  `{"type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}/scripts/commit-gate.sh\"", "timeout": 5}`
  after the guard's, and the file's `description` gains one sentence on the gate.

## The two `verify` skills (new files, T1)

Static, `plugins/shipkit/stacks/static/.claude/skills/verify/SKILL.md`:

```markdown
---
description: "Run the change: serve this site on a free port, request one page, stop the server, and report the script's line. TRIGGER when: a task or the user asks to check a page in the running site. DO NOT TRIGGER when: only tests or an audit were asked for."
user-invocable: true
argument-hint: "<path, e.g. /index.html>"
---

# /verify — run the change

Path: $ARGUMENTS (the path the task names; `/index.html` when it names none).

1. The script is `<plugin root>/scripts/verify-run.sh`. The root is in this session's
   `shipkit: plugin root is …` line, or in `~/.claude/shipkit/plugin-root`.
2. The start command: the `Dev server:` line of `CLAUDE.md` when it names a server that takes
   a port (`npx serve -l "$PORT"`, `npx vite --port "$PORT"`); otherwise
   `python3 -m http.server "$PORT"`, run from the folder that holds the site.
3. Run `sh "<root>/scripts/verify-run.sh" --start '<start command>' --request <path>`, with the
   start command in single quotes so the script sets `PORT`.
4. Report the script's first line as printed, with the lines under it. `RAN` is not a pass:
   read the status and the body. On `NOT-READY` or `EXITED`, report that line and the output
   under it, and do not say the change was checked. Never report a run you did not make.
```

Elixir, `plugins/shipkit/stacks/elixir/.claude/skills/verify/SKILL.md`:

```markdown
---
description: "Run the change: start this Phoenix app on a free port, make one request, stop it, and report the script's line. TRIGGER when: a task or the user asks to check a change in the running app. DO NOT TRIGGER when: only tests were asked for, or the project has no Phoenix endpoint."
user-invocable: true
argument-hint: "<path, e.g. /health>"
---

# /verify — run the change

Path: $ARGUMENTS (the path the task names).

1. The script is `<plugin root>/scripts/verify-run.sh`. The root is in this session's
   `shipkit: plugin root is …` line, or in `~/.claude/shipkit/plugin-root`.
2. Run `sh "<root>/scripts/verify-run.sh" --start 'mix phx.server' --request <path>
   --env PHX_SERVER=true --env MIX_ENV=<env> --timeout 120`, where `<env>` is the environment
   the task names, `test` when it names none. Add any other `--env` the task names (a
   `MIX_TEST_PARTITION`, for one).
3. Phoenix's generated `config/runtime.exs` reads `PORT`; a project whose config fixes the port
   reads `NOT-READY`. Then report that line and the config line that fixes the port. Do not
   edit config to make it run.
4. Report the script's first line as printed, with the lines under it. `RAN` is not a pass:
   read the status and the body. On `NOT-READY` or `EXITED`, report that line and the output
   under it, and do not say the change was checked. Never report a run you did not make.
```

## Waiting text for Sprint 35

**The Rails `verify` skill** (REQ-16), `plugins/shipkit/stacks/rails/.claude/skills/verify/SKILL.md`,
the elixir text with these changes: description "…start this Rails app…"; step 2's command
`sh "<root>/scripts/verify-run.sh" --start 'bin/rails server -b 127.0.0.1 -p "$PORT"'
--request <path> --env RAILS_ENV=<env> --timeout 60`; step 3 "Rails takes the port from `-p`;
a project whose `config/puma.rb` binds a fixed port reads `NOT-READY` or `EXITED`. Report that
line and the config line." The same commit changes:
- `plugins/shipkit/skills/setup/SKILL.md:262`: "ships 4 skills (`/new-feature`, `/release`, two
  knowledge bases)" becomes "ships 5 skills (`/new-feature`, `/release`, `/verify`, two
  knowledge bases)"; the table at `:302-310` adds `/verify` to the rails, elixir and static
  rows (elixir and static are stale from this sprint until then);
- smoke check 67 (`scripts/smoke.sh:2717`) and 69 (`:2778`) assert 5 and `ships 5 skills`.

**The commit skill's stamp** (REQ-28), for `plugins/shipkit-workflows/skills/commit/SKILL.md`,
after the Test plan step:

> End every message with one paragraph of its own, a single line, written after you read the
> result: `Verified: tests (<command> → exit 0)`, `Verified: gate (<report file>)`,
> `Verified: brief-verify (<slug>/<task>)`, `Verified: ran (<the verify-run.sh line>)`, or
> `Verified: none (<reason>)`. Put a blank line before it. git reads it as a trailer only when
> it stands alone.

Checked on 2026-11-20 in a scratch repository: a `Verified:` line in a paragraph of its own is
read by `git log --format='%(trailers:key=Verified,valueonly)'`. On the line after a `Refs …`
line it is not read. `git log --grep='^Verified: none ('` finds it either way.

**The `GUIDE.md` lines** (REQ-29, written in T2):
`git log --format='%h %s%x09%(trailers:key=Verified,valueonly)'` lists each commit with its
stamp; `git log --format='%h %s' --grep='^Verified: none ('` lists those stamped `none`.

## Context cost (REQ-17, measured in T1)

T1 writes rows to `docs/design/context-cost.md`: for each `verify` skill, the bytes of its
`description:` line (listed in every session of a project that installs it) and of the whole
file (read when used). The drafts' descriptions are under 300 characters. T1 also corrects
`context-cost.md:21`: the Rails overlay ships 4 skills, not 6 (`/bin/ls
plugins/shipkit/stacks/rails/.claude/skills/`), with their bytes re-measured.
