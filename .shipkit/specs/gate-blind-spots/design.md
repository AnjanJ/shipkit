# Design: The gate's blind spots (Sprint 12)

## Approach

Four tasks on the three surfaces the field notes blamed: one script learns to ignore a trailing
comment and to say why a command failed, and the spec skill runs it on its own output; one
script and one agent share an allow-list for the files no spec will ever name; one skill's
command table captures exit codes and its report template says the output is pasted; one
question is closed by a record and a header sentence. No rule, no eval case, no new script.

---

## Decision: A trailing HTML comment is stripped, not rejected   (→ REQ-1, REQ-2)

**Context.** On the real run the fix for a day-one `Fired-if` was `manual  <!-- was … -->` on one
line; `decision-check.sh` ran the comment as part of the command and reported an error (field
notes §7). The reference never said what may follow the command. The same run showed an `ERROR`
line that named the exit code and nothing else, so the reader had to re-run the command to learn
that the file did not exist (§6).

**Alternatives.**
1. Strip one trailing `<!-- … -->` before running; put the first line of stderr on the `ERROR`
   line.
2. Reject any `Fired-if` line with anything after the command, as `ERROR`, and say so in the
   reference.
3. Leave the parser; the reference says "nothing after the command".

**Case for (1).** A comment beside a changed line is how people record *what it was*; the
reference already shows a comment-free form, and the one thing a reader needs from a failed
command is its stderr. The result words stay the same four, so the ship skill and smoke check
35 read the output as before.

**Case against (1).** A comment that is not at the end of the line is still run; a command
whose own text contains `<!--` is cut. Both are unlikely in a one-line shell test and (2)
would catch them at the cost of refusing the form the real run reached for.

**Decision.** We chose (1).
**Falsifiability.** We would move to (2) if a `Fired-if` command is found cut short by the strip
in any real or eval run.
**Fired-if.** manual

---

## Decision: Everything under `.shipkit/` is allowed, except another spec's folder   (→ REQ-5, REQ-6, REQ-7)

**Context.** The reviewer called `.shipkit/product.md` "outside the spec's `Paths`" on the real
run (§8) and `brief-verify.sh` called the spec's own `intake.md`, `spec.md` and `design.md`
`OUTSIDE` before they were committed (§7). Both checks exist to catch a task that wanders into
code it was not given; neither was written with the files shipkit's own loop writes in mind.
Shipkit's own 4.0.0 and 4.2.0 gates raised the same finding.

**Alternatives.**
1. Both checks allow everything under `.shipkit/` that is not inside another spec's folder:
   `product.md`, `state.md`, `releases/`, `decisions/`, the spec's own folder, and whatever a
   later release adds there.
2. Allow only the four named paths (`product.md`, `state.md`, `releases/`, `decisions/`) plus
   the spec's own folder; anything new under `.shipkit/` is `OUTSIDE` until named.
3. Leave the checks; the spec skill writes `.shipkit/` into every `Paths` line.

**Case for (1).** The folder is shipkit's, written by shipkit's skills, and a new artifact
there (a digest, a research note) should not reopen this question in a later sprint. The one
thing under `.shipkit/` a task must not touch — another feature's spec — is still caught.

**Case against (1).** An agent that writes a stray file under `.shipkit/` is not reported;
(2) would report it. The cost is a finding that is right once in a sprint against one that
is wrong every sprint. (3) puts the burden on every spec forever.

**Decision.** We chose (1), C5's default.
**Falsifiability.** We would move to (2) if an agent is observed writing a file under
`.shipkit/` (outside any spec folder) that a task did not ask for, in any real or eval run.
**Fired-if.** manual

---

## Decision: Exit codes are echoed on the command line, output is read from a file   (→ REQ-8, REQ-9)

**Context.** The 4.3.0 gate report twice says "exit code not captured because of a pipe" and
reads the result from the output text instead (§8). A report that infers a PASS from text is a
report that can be wrong when the text is.

**Alternatives.**
1. Each How command ends `; echo "exit $?"` where its output is short, and writes to
   `"${TMPDIR:-/tmp}/shipkit-ship-<step>.out"` which the skill then reads where it is long (the
   test suite); the template's evidence blocks say "pasted from the file".
2. `set -o pipefail` at the top of every How command.
3. Leave the table; the notes say "capture the exit code".

**Case for (1).** `echo "exit $?"` works in every shell the gate runs in and survives a pipe
placed before it; a file holds the suite's output whole, so the last twenty lines are the
last twenty lines and not what the model remembers. (2) is not POSIX `sh` and still loses the
code once the model pipes to `tail`.

**Case against (1).** A scratch file left behind per step; a model can still type output
instead of reading the file. The template's wording and the dry run are the only check.

**Decision.** We chose (1).
**Falsifiability.** We would move to (2) or add a script if a ship report after 4.5.0 is found
to say an exit code was not captured, or to carry evidence that differs from the command's
output on the same tree.
**Fired-if.** manual

---

## Decision: Ignored files are invisible to `brief-verify.sh`, by design   (→ REQ-10)

**Context.** Playbook 4 (4.0.0) noted that an agent writing `__pycache__/` or another ignored
path is not seen by `brief-verify.sh`, which reads `git diff` and untracked files. The question
has sat in the roadmap since; the real run did not hit it (§7a).

**Alternatives.**
1. Close by record: the check sees what git sees, on purpose; one header sentence says so and
   points at the task's Done-when output, which is where a build artifact shows.
2. A smoke case that bites: a task whose agent writes an ignored file, asserting `OUTSIDE`, and
   the script extended to walk `git status --ignored`.
3. Leave it open.

**Case for (1).** An ignored file is one the project has said does not matter to the tree; a
check that reported it would report every build on every task. The Done-when command is the
check that already sees a build's effect.

**Case against (1).** An agent that hides work in an ignored path is not caught; the real run
cannot say how often that happens because it built nothing.

**Decision.** We chose (1), C6's default.
**Falsifiability.** We would build (2) if an agent is observed, in a real run, writing a file
into an ignored path that the task's Done-when did not catch.
**Fired-if.** manual

---

## Data / interface changes

- Changed: `decision-check.sh` (REQ-1, REQ-2), `skills/spec/SKILL.md` (REQ-3),
  `skills/spec/reference.md` (REQ-4), `agents/reviewer.md` (REQ-5), `brief-verify.sh`
  (REQ-6, REQ-7, REQ-10), `skills/ship/SKILL.md` and `skills/ship/reference.md` (REQ-8, REQ-9).
- New: smoke checks 52 and 53.
- Unchanged: `spec-check.sh`, every rule, every eval case, the four result words of
  `decision-check.sh` and its summary line.
