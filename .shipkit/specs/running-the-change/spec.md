# Spec: running the change

> Spec accepted at commit `49a3284` on sprint-34/running-the-change.
> Status: open
> Paths: plugins/shipkit/scripts/verify-run.sh, plugins/shipkit/scripts/commit-gate.sh, plugins/shipkit/hooks/hooks.json, plugins/shipkit/stacks/elixir/.claude/skills/verify/, plugins/shipkit/stacks/static/.claude/skills/verify/, scripts/smoke.sh, scripts/lint.py, docs/design/context-cost.md, docs/design/trim-audit-checks.md, docs/plans/verifier-sprint-plan.md, scripts/evals-map.tsv, docs/design/eval-cases.md, plugins/shipkit/evals/, GUIDE.md
> Tests: scripts/smoke.sh

## Purpose

The gate runs the test command and the reviewer reads the code; neither starts the application.
The 5.2 run's miss, tests green and the feature not wired, is the kind a running application
shows. Shipkit's commit skill writes how a change was tested in prose, which no query can read.
And the smoke suite and the eval cases only grow. This is Sprint 34 of
`docs/plans/verifier-sprint-plan.md`: a script that starts an application, makes one request and
stops it; `verify` skills for the elixir and static overlays that call it; a commit gate,
switched off by default, that looks for a `Verified:` stamp; and an audit of every smoke check
and eval case, with each cut put to the owner, before Sprint 35 pays to run them. It starts no
model and changes no existing skill, agent, rule or overlay file (the plan's rules 33 and 34).

## User stories

- As the owner, I want a script that starts my application, asks it for one page and stops it,
  so that "it runs" is a line a report can quote, not a claim.
- As the owner of an elixir or static project, I want a `verify` skill that names my stack's
  start command, so that the model runs the change the same way each time.
- As the owner, I want unstamped commits counted before any is blocked, so that I can see how
  many commits say nothing of how they were checked, and switch blocking on only if it pays.
- As the owner, I want every check and case to show what it has caught and what it costs, so
  that I cut the dead ones before Sprint 35 pays to run them.

## Terms

- **The base of this spec.** Commit `49a3284`, `main` when this spec was written.
- **The start command.** The `--start` argument of `verify-run.sh`, run by `sh -c`.
- **The port.** The TCP port `verify-run.sh` picks for one run.
- **Answers.** The port answers when an HTTP request to `127.0.0.1` on it gets a response with
  any status.
- **Its processes.** The process `verify-run.sh` starts for the start command, and every process
  that one starts in turn.
- **The application's output.** What its processes write to standard output and standard error.
- **An outcome line.** `RAN <status> <path>`, `NOT-READY after <s> s` or `EXITED <code>`, where
  `<s>` is the timeout in seconds, as given or 30, not a measured time.
- **A valid name.** A name for `--env` that matches `[A-Za-z_][A-Za-z0-9_]*`.
- **A static fixture.** A folder holding an `index.html`, served by the start command
  `python3 -m http.server "$PORT"` from inside it.
- **SHIPKIT_HOME.** The environment variable of that name, or `~/.claude/shipkit` without it
  (`briefing.sh:26`).
- **The log.** `$SHIPKIT_HOME/commit-gate.log`.
- **The mode.** The value of `SHIPKIT_COMMIT_GATE`: `observe`, `enforce`, or anything else,
  which counts as `off`.
- **A commit call.** A `PreToolUse` call whose command text holds `git commit`.
- **A message on the command line.** A commit call whose command gives the message with `-m`,
  `--message`, or a cluster of short options that ends in `m` (`-am`).
- **The message.** For a message on the command line, the whole command text of the commit
  call. A message given in several `-m` parts is one message, and a stamp in any part counts.
- **A stamp.** The text `Verified: ` followed by `tests (`, `gate (`, `brief-verify (`, `ran (`
  or `none (`, then at least one character that is not `)`, then `)`.
- **The session id.** The id of the session that the hook's JSON carries (its field name is read
  from the current hook documentation in this sprint, not guessed).
- **A row.** One line of the log: the time in UTC, the session id, the mode, an outcome word and
  the project directory, separated by tabs. The project directory is the `cwd` the hook's JSON
  carries, or `-` when it carries none.
- **The audit.** `docs/design/trim-audit-checks.md`.
- **A smoke check's label.** A label that `registry()` in `scripts/smoke.sh` lists.
- **An eval case.** A case that `scripts/evals-map.tsv` lists.
- **Last failed on a real defect.** The newest release, as `X.Y.Z`, in which the check or case
  failed and the failure led to a fix in the product, or `never`. Its sources are the
  `CHANGELOG.md` entries, the `fix` commits of `git log`, `docs/design/eval-ledger.tsv` and
  `docs/design/smoke-audit-5.4.md`.
- **Also covered by.** The other smoke checks' labels and eval cases that cite the same
  `<slug>/REQ-N`, comma-separated, or `nothing`.
- **A cost.** Seconds for a smoke check, as `<n> s`, measured in one model-free run; dollars for
  an eval case, as `$<n>`, at the 5.2.0 ledger's rate.
- **A trap-2 case.** One of the sixteen cases decision 0008 keeps.
- **Waiting text.** Text for a file a model reads, written word for word into `design.md` and
  applied in Sprint 35.

## Requirements (EARS)

Running the change, `plugins/shipkit/scripts/verify-run.sh`:

- **REQ-1.** When `verify-run.sh --start '<command>' --request <path>` is run, it shall pick a
  port above 1023 that does not answer, and start the start command in the background with
  `PORT` set to that port in its environment.
- **REQ-2.** Where `--env KEY=VALUE` is given, once or more, the start command's environment
  shall hold each such variable.
- **REQ-3.** While its processes run and the port does not answer, `verify-run.sh` shall keep
  trying the port until it answers or `--timeout` seconds have passed, 30 when it is not given.
- **REQ-4.** When the port answers, `verify-run.sh` shall make one GET request, and only one, to
  `<path>` on it, and print `RAN <status> <path>`, then the response's status line, then at
  most the first 10 lines of its body, and exit 0.
- **REQ-5.** If the start command's process ends before the port answers, then `verify-run.sh`
  shall print `EXITED <code>` with that process's exit code, then at most the last 20 lines of
  the application's output, and exit 1.
- **REQ-6.** If the port has not answered when the timeout runs out, then `verify-run.sh` shall
  print `NOT-READY after <s> s`, then at most the last 20 lines of the application's output, and
  exit 1.
- **REQ-7.** On every way out, an interrupt included, `verify-run.sh` shall stop its processes,
  shall stop no other process, and shall remove every file and directory it made.
- **REQ-8.** The first line `verify-run.sh` prints on standard output shall be its outcome line,
  and the application's output shall reach standard output only in the lines REQ-5 and REQ-6
  name.
- **REQ-9.** If `--start` or `--request` is missing, the path does not start with `/`, the
  timeout is not a whole number above 0, or an `--env` value is not `NAME=value` with a valid
  name, then `verify-run.sh` shall print its usage on standard error, start nothing and exit 2.
- **REQ-10.** If `curl` cannot be found, then `verify-run.sh` shall say so on standard error,
  start nothing and exit 2.
- **REQ-11.** Ten runs in a row of `verify-run.sh` against one static fixture with
  `--request /index.html` shall each print `RAN 200 /index.html` as their first line and leave
  none of their processes running.
- **REQ-12.** The header of `verify-run.sh` shall say that it needs `curl`, POSIX `sh`, `awk`
  and nothing else, and that a port taken between the pick and the start shows as `NOT-READY`
  or `EXITED`. [untested: prose, verified by reading]

The `verify` skills:

- **REQ-13.** The elixir and static overlays shall each ship
  `.claude/skills/verify/SKILL.md`, and `scripts/lint.py` shall report no error and no warning
  on either.
- **REQ-14.** Each `verify` skill shall name its stack's start command, say to run
  `verify-run.sh` from the plugin root with the path the task names, and say to report the
  script's outcome line as printed and never a run it did not make. [untested: prose, verified
  by reading; Sprint 35's model runs show whether it is followed]
- **REQ-15.** When `install-stack.sh` installs the elixir or static overlay without
  `--with-skills`, it shall install no `verify` skill; with `--with-skills` it shall install it,
  given only the `KEY=value` arguments that overlay needed at the base of this spec.
- **REQ-16.** This spec's `design.md` shall hold the Rails `verify` skill as waiting text,
  together with the change to `setup/SKILL.md:262` and to smoke checks 67 and 69 that Sprint 35
  makes with it. [untested: prose, verified by reading]
- **REQ-17.** `docs/design/context-cost.md` shall give the bytes each `verify` skill adds to a
  project that installs it, and shall give the Rails overlay's skill count as 4. [untested:
  prose, verified by reading]

The commit gate, `plugins/shipkit/scripts/commit-gate.sh`:

- **REQ-18.** When the hook's JSON is not a commit call, `commit-gate.sh` shall print nothing,
  write nothing and exit 0, in every mode.
- **REQ-19.** While the mode is `off`, `commit-gate.sh` shall print nothing, write nothing and
  exit 0.
- **REQ-20.** While the mode is `observe`, when a commit call gives a message on the command
  line without a stamp, `commit-gate.sh` shall add one row with the outcome word `unstamped` to
  the log, print nothing and exit 0.
- **REQ-21.** While the mode is `observe` or `enforce`, when a commit call's message holds a
  stamp, `commit-gate.sh` shall print nothing, write nothing and exit 0.
- **REQ-22.** While the mode is `enforce`, when a commit call gives a message on the command
  line without a stamp and the log holds fewer than two `blocked` rows for that session id,
  `commit-gate.sh` shall add a row with the outcome word `blocked`, print one line on standard
  error that shows the stamp's form and `Verified: none (<reason>)`, and exit 2.
- **REQ-23.** While the mode is `enforce`, when a commit call gives a message on the command
  line without a stamp and the log holds two `blocked` rows for that session id,
  `commit-gate.sh` shall add a row with the outcome word `passed`, print nothing and exit 0.
- **REQ-24.** While the mode is `observe` or `enforce`, when a commit call gives no message on
  the command line, `commit-gate.sh` shall add a row with the outcome word `unseen`, print
  nothing and exit 0.
- **REQ-25.** If `commit-gate.sh` cannot read its input, finds no session id in it, or cannot
  write the log, then it shall exit 0.
- **REQ-26.** `plugins/shipkit/hooks/hooks.json` shall run `commit-gate.sh` as a second command
  of the `PreToolUse` entry whose matcher is `Bash`, beside `guard-commit.sh`, with a timeout of
  5 seconds, and `scripts/lint.py` shall report no error and no warning on it.
- **REQ-27.** The header of `commit-gate.sh` shall say that it sees only a message given on the
  command line, that a commit from a file, an editor or the owner's own terminal is never
  blocked, and that it exits 0 on any error of its own. [untested: prose, verified by reading]
- **REQ-28.** This spec's `design.md` shall hold the waiting text for the commit skill's
  `Verified:` line, and the measured cost of the second hook command on a Bash call that is not
  a commit. [untested: prose, verified by reading]
- **REQ-29.** `GUIDE.md` shall have a section on the commit gate: its three modes, where the
  log is, and the `git log` lines that list each commit with its stamp and those stamped
  `none`. [untested: prose, verified by reading]

The prune:

- **REQ-30.** The audit shall have one row for each smoke check's label and each eval case, and
  a row for nothing else that is not marked cut. Each row shall give when it last failed on a
  real defect, what else covers it and its cost, each in the form the Terms give. (A test checks
  the rows and their forms; whether a cell is true is read at the gate from the sources the
  Terms name.)
- **REQ-31.** The audit shall mark no trap-2 case as a candidate for a cut.
- **REQ-32.** A row marked cut shall give the date of the owner's yes as `cut YYYY-MM-DD`, and the check or case it
  names shall no longer be in `scripts/smoke.sh` or `scripts/evals-map.tsv`.
- **REQ-33.** A requirement cited by a check or case that is cut shall still be cited by a check
  that proves it. [untested: held by `spec-check.sh` at 0 gaps in the exit checklist]
- **REQ-34.** The release task in `docs/plans/verifier-sprint-plan.md` shall hold a line that
  makes a prune pass part of every release. [untested: prose, verified by reading]

## How the prune runs

The audit lists candidates. Each cut comes to the owner as one item of a numbered list in the
owner's usual form, ending "reply 'yes to all', or tell me which to skip". Nothing is removed
without its yes. A check whose citations cannot move to another check that proves the same
requirement is not cut.

## Out of scope

- Any paid model run, including the three runs per stack of a `verify` skill, the five commits
  through the commit skill and the captured hook call (Sprint 35).
- A change to an existing skill, agent, rule or overlay file: setup's list of overlay skills and
  its Rails count, the commit skill's `Verified:` line, the ship report's "Ran the change"
  block (Sprint 35).
- The Rails `verify` skill file, and `verify` skills for python, go, react and the other
  overlays (the intake's answer 1; the plan's §6).
- Any start command for a real project, and anything near the owner's project in use (§5).
- Switching the commit gate on anywhere, or setting `SHIPKIT_COMMIT_GATE` in a shell profile.
- A request other than one GET, a request body, headers, or more than one path per run.
- Cutting a trap-2 case (decision 0008), and raising the evals ceiling or moving the evals
  (decision 0005).
