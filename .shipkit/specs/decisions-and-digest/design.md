# Design: Live decisions and the studio digest (Sprint 6, release 3.7.0)

## Approach

Two scripts that read files already on disk and one line added to a format. `decision-check.sh`
finds `Fired-if` commands and, only on request, runs them. `portfolio-digest.sh` walks the
registry and, for each project, runs the scripts the earlier sprints shipped (`spec-check.sh`,
`decision-check.sh`, the progress count the briefing already does) and writes one page.
Nothing here runs from a hook; the briefing only says when the page is old.

---

## Decision: A decision may carry a command, run only on request   (→ REQ-4 to REQ-9)

**Context.** A falsifiability clause is text: "if the routes file passes 500 lines". Nobody
re-reads old records to check. Many clauses could be a one-line command. The owner settled
this as A6: commands allowed, run only when a person or a skill asks, never from a hook.

**Alternatives.**
1. An optional `**Fired-if.**` line holding a shell command (or `manual`); a script lists them
   by default and runs them only with `--run`.
2. No commands: clauses stay text, and an elder reasons about each when asked.
3. Commands that run from the session hook, so a fired decision is announced at start.

**Case for (1).** A command is checkable and cheap; the record states its own test. Listing by
default means a reader sees what would run before anything runs. Option 2 leaves the check to
a model's reading of a sentence, which is what fails today. Option 3 runs repository-supplied
commands on every session start of every clone, which is how a malicious record becomes code
execution.

**Case against (1).** Most clauses cannot be measured from the repository (users, latency,
cost), so most lines will say `manual` and the script answers little for them. A command
written once rots with the layout it measures. `--run` on an untrusted repository is a risk
the header comment can only warn about.

**Decision.** We chose (1). `decision-check.sh` is never called from a hook, lists by default,
and its header says to read the commands before `--run` in a repository you do not trust.
**Falsifiability.** We would reverse this — remove `--run` and keep the line as documentation —
if a `Fired-if` command in any project the owner registers does something other than read
files or run a read-only command, or if fewer than one in five records written during this
plan carries a command rather than `manual`.

---

## Decision: Exit status 0 means "fired"   (→ REQ-6, REQ-7)

**Context.** A `Fired-if` command answers a yes/no question with its exit status. The script
has to map that to `FIRED` or `HOLDS`.

**Alternatives.**
1. Exit 0 means the condition has come true (`FIRED`); 1 means it holds; above 1 is an error.
2. Exit 0 means all is well (`HOLDS`), like a test.

**Case for (1).** It reads as the record does: "Fired-if: `test $(wc -l < routes.rb) -gt 500`"
— the command is the condition, and `test` exits 0 when the condition is true. Writers compose
the command from the clause without inverting it. Exit 1 from `test`, `grep -q` and friends
is "no", which is `HOLDS`; anything above 1 is those tools saying something went wrong, which
is `ERROR` rather than a silent `HOLDS`.

**Case against (1).** It is the opposite of a test suite's convention, so a `Fired-if` that
simply runs the tests would report `FIRED` when they pass. The three-way split on exit status
is a convention writers have to know.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this if, in this plan's own records, more than one
`Fired-if` command is written inverted by mistake.

---

## Decision: A local script writes the digest, not a scheduled cloud agent   (→ REQ-12 to REQ-18)

**Context.** A weekly page across every registered project needs each project's files. The
owner settled this as A7: a local script, which the user may schedule.

**Alternatives.**
1. `portfolio-digest.sh`, run by hand or from `cron`/`launchd`, writing under `~/.claude/shipkit/`.
2. A scheduled cloud agent that checks out each repository and runs the plugin.

**Case for (1).** Every project is already on the machine the registry lives on; the script
reads them in seconds with no model and no credentials. It works for projects that are not on
GitHub. Scheduling it is one line the guide shows. Option 2 needs every repository hosted and
reachable, costs a model run per week, and the plan's own rule is that nothing depends on it.

**Case against (1).** It runs only when the machine is on and the schedule fires; a laptop
asleep on Monday morning has no digest. The output is local; nothing reads it but the user
and `eve`.

**Decision.** We chose (1). The guide records what a scheduled cloud agent could do, so the
option is written down, and nothing is built on it.
**Falsifiability.** We would reverse this — build the cloud version — if every project in the
owner's registry is on GitHub and the local digest is missed in two consecutive weeks because
the machine was off.

---

## Data / interface changes

- One optional line in decision records: `**Fired-if.** <command>` or `**Fired-if.** manual` — REQ-1.
- New scripts `decision-check.sh <project-dir> [--run]` and
  `portfolio-digest.sh [registry-file] [--run-checks]`, with `SHIPKIT_HOME` — REQ-4 to REQ-15.
- New files under `$SHIPKIT_HOME/digests/<date>.md` — REQ-12.
- Step 8 in the ship gate; one more line the briefing may print — REQ-11, REQ-17.
- `/shipkit:ask --all digest` — REQ-16.
