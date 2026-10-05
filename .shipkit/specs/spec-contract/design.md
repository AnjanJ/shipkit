# Design: The spec is a contract (Sprint 2, release 3.3.0)

## Approach

One POSIX script, `spec-check.sh`, reads the three files of a spec as plain text and prints one
line per finding. Everything else in the sprint feeds it or uses it: two stamp lines give a spec
a status and a scope, a citation ties a test to a requirement, a task format makes file
ownership readable, the session hook reuses the status and scope to stop nagging about the
wrong specs, and CI runs the script. The formats are additive: a spec written before 3.3, with
none of the new lines, must behave exactly as it does today.

---

## Decision: Status and paths are stamp lines, not YAML frontmatter   (→ REQ-6, REQ-7, REQ-16)

**Context.** A spec needs two new machine-read fields. `spec.md` already carries one: the
`> Spec accepted at commit …` blockquote line, which the session hook reads with `grep` and
`sed`. The readers are POSIX shell scripts on users' machines, with no YAML parser.

**Alternatives.**
1. Two more blockquote lines under the existing stamp: `> Status: open`, `> Paths: a/, b/`.
2. YAML frontmatter at the top of `spec.md` (`status:`, `paths:` as a list).
3. A sidecar file, `.shipkit/specs/<slug>/meta`.

**Case for (1).** One convention, already parsed by code that ships. A line-oriented `grep`
reads it; nothing has to understand YAML lists or quoting. It renders visibly on GitHub, where
frontmatter is hidden or shown as a table. Existing specs gain the lines without restructuring.

**Case against (1).** It is a home-made format: no editor validates it, and a path containing
a comma cannot be written. Frontmatter is what Claude Code's own files use, so two conventions
now exist in one plugin. A long `Paths` line is awkward to read and to diff.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this — move to frontmatter — if a spec needs a fourth
machine-read field, or if any `Paths` line in this repository or a reported user project
exceeds 300 characters.

---

## Decision: Tests cite `<slug>/REQ-N`, not a bare `REQ-N`   (→ REQ-4, REQ-9)

**Context.** `spec-check.sh` must decide whether a requirement has a test by finding a
citation in the code. Every spec numbers its requirements from 1, and this repository already
has three specs with a `REQ-1`.

**Alternatives.**
1. `<slug>/REQ-N`, written anywhere in a test file — a comment or a test name.
2. A bare `REQ-N`, matched only inside the spec's `Paths`.
3. Globally unique requirement ids (`REQ-refunds-3`, or one running number per project).

**Case for (1).** It is unambiguous with one `git grep -F`, needs no knowledge of paths, and a
reader of the test can find the spec from the citation alone. Option 2 fails for specs with no
`Paths` line and for tests kept in one shared file — which is this repository's own case
(`scripts/smoke.sh`). Option 3 would renumber every existing spec.

**Case against (1).** It is longer to type, and renaming a spec folder breaks every citation
to it. Nothing stops a citation from sitting in a comment next to a test that does not really
prove the requirement: the script checks that the string exists, not that it is true.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this if a spec folder in this repository is renamed more
than once in the life of this plan, or if the reviewer agent (Sprint 4) finds, in any one
sprint, more than two citations whose test does not exercise the cited requirement.

---

## Decision: The sharing rule looks at direct `After` names only   (→ REQ-12, REQ-13)

> **Superseded on 2026-10-05** by "The sharing rule follows chains of `After` lines", below.
> Kept as written: it is the record of what was decided first and why it was reversed.

**Context.** Tasks are to be handed to agents, sometimes at the same time. Two tasks that edit
the same file must not run together. The check is done by a POSIX shell script.

**Alternatives.**
1. Direct only: if two tasks list the same file, the later one must name the earlier one on
   its own `After` line.
2. A full dependency graph: the later task may reach the earlier one through any chain of
   `After` lines, and cycles are detected.

**Case for (1).** A reader, or an agent given one task, can see from that task alone which
tasks must be finished first for the files it touches; nothing has to be traced. It is a
nested loop in `sh`, with no graph walk and no cycle handling to get wrong.

**Case against (1).** It is stricter than safety needs: if T3 follows T2 and T2 follows T1,
T3 is already safe, yet must still name T1 when they share a file. `After` lines grow in specs
where many tasks touch one file — this sprint's own tasks all touch `scripts/smoke.sh`. And a
cycle (`T1 After T2`, `T2 After T1`) goes unreported.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this — walk the full graph — if any spec written during
this plan has a task whose `After` line names more than five tasks, or if a cycle between
tasks reaches a merged spec.

---

## Decision: The sharing rule follows chains of `After` lines   (→ REQ-13, REQ-27)

Supersedes "The sharing rule looks at direct `After` names only".

**Context.** The direct-only rule was reversed four tasks after it was decided. S2-T4's smoke
check had `/shipkit:spec` write a real spec for the fixture: eight tasks on two shared files.
`spec-check.sh` passed it, and its last task read `After: T1, T2, T3, T4, T5, T6, T7`. The
earlier record's reversal condition was "a task whose `After` line names more than five
tasks". The spec was a throwaway, not one written for this plan, so the clause had not
strictly fired — but any real feature of that size would fire it, and it showed the cost
plainly: the line that should say "what must be finished first" had become a list of
everything.

**Alternatives.**
1. Keep direct-only and accept long `After` lines.
2. Follow chains: the later task must *come after* the earlier one, by a direct name or
   through any chain of `After` lines; report a cycle.
3. Keep direct-only but exempt test files from the sharing rule.

**Case for (2).** It asks for exactly what safety needs: an order between two tasks that touch
the same file. `After: T2` on T3 is enough when T2 already follows T1, which is how a person
writes it. It also closes the hole the first record admitted, a cycle going unreported.
Option 3 guesses which files are safe to edit at once, and a shared test file is precisely
where two agents collide.

**Case against (2).** One task's lines no longer tell the whole story: to see every task that
must be finished first, a reader follows the chain. The script gains a closure over the task
graph — a triple loop in awk, harmless at tens of tasks, slow at thousands. And "name only
the nearest predecessor" is a habit the skill now has to teach.

**Decision.** We chose (2). `spec-check.sh` closes the `After` relation before checking shared
files and prints `CYCLE <slug> <task>` for a task that reaches itself.
**Falsifiability.** We would reverse this — return to direct names — if a brief built from a
task (Sprint 3's `brief.sh`) leads an agent to start before a task it depends on only through
a chain, in any sprint of this plan; or if `spec-check.sh` takes more than one second on a
real `tasks.md`.

---

## Data / interface changes

- New script `plugins/shipkit/scripts/spec-check.sh <project-dir> [slug]`; output lines
  `MISSING-TASK`, `MISSING-TEST`, `WAIVED`, `SKIPPED`, `MISSING-FIELD`, `BAD-AFTER`,
  `CONFLICT`, `CYCLE`; exit 0, 1 or 64 — REQ-1 to REQ-14, REQ-27.
- `spec.md` gains two optional lines, `> Status:` and `> Paths:` — REQ-6, REQ-7, REQ-16.
- A requirement line may end with `[untested: <reason>]` — REQ-5.
- `tasks.md` tasks gain `Files`, `Test`, `After`, `Done when` sub-lines — REQ-11.
- The session hook's drift line has a second wording for specs with `Paths` — REQ-17.
- `.github/workflows/lint.yml` gains one step — REQ-25.
