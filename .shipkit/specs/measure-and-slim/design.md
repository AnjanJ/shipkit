# Design: Measure and slim (Sprint 1, release 3.2.0)

## Approach

Measure first, then cut. The eval harness and the fixture land before any rule is touched, and
the 3.1.0 baseline is recorded while the rules are still at full size. The shrink is then one
commit whose proof is the same evals run again. The commit guard is independent of both and
comes last, behind a "Check first" experiment, because it rests on a platform claim nobody has
tested on this machine.

Three choices in this sprint were real forks. The owner settled each when approving the plan
(A9, A3, A10); the records below say why, and what would reverse them.

---

## Decision: Evals live inside the plugin, capped at 100 KB   (→ REQ-1, REQ-8)

**Context.** `claude plugin eval` looks for cases in `<plugin>/evals/`. Everything under a
plugin's directory is copied to every user's machine on install. The cases need a fixture
project to ask questions about, and a fixture is the bulky part.

**Alternatives.**
1. `plugins/shipkit/evals/`, shipped with the plugin, with a size cap.
2. `evals/` at the repository root, outside any plugin — if the eval tool accepts a path there.
3. No eval tool: more `claude -p` checks in `scripts/smoke.sh`.

**Case for (1).** It is where the tool looks, so a case runs with no extra flags and the
documented commands work as written. The cases sit next to the skills and agents they test, and
a user who doubts a claim in the README can run them. Option 3 has no without-the-plugin
comparison, which S1-T4 needs.

**Case against (1).** Every install downloads a fixture app it will never use. The cap limits
how realistic the fixture can be. Files in the fixture (`PROJECT_MAP.md`, a `README.md`) sit
inside the plugin tree, where the lint's shipped-file checks read them and where a careless
directory name could one day be picked up by the plugin loader.

**Decision.** We chose (1), with a 100 KB cap on `evals/` and 40 KB on `fixtures/`.
**Falsifiability.** We would reverse this — move the cases to the repository root — if the
cases planned through Sprint 6 cannot fit in 100 KB, or if any fixture file is observed loading
into a user's session as a skill, agent or rule.

---

## Decision: The always-on rules get a hard budget of 3,000 bytes   (→ REQ-15, REQ-16, REQ-17)

**Context.** The session hook injects three rules into every session of every project:
11,867 bytes today. Most of that is *how* (the commit template, the EARS table, the five-part
detail), which matters only once Claude is already doing the thing. Sprints 2, 3 and 6 each
plan to add a sentence to these rules, so without a ceiling they only grow.

**Alternatives.**
1. At most 3,000 bytes, enforced by the lint as an error. Triggers stay; detail moves into
   skills that load on demand.
2. A looser budget of 5,000 bytes.
3. Leave the rules as they are and rely on `/shipkit:setup` users reading them from disk.
4. Inject nothing; let the skill descriptions carry the triggers.

**Case for (1).** The cost is paid by every session, including the ones that fix a typo. A
trigger ("non-trivial work answers three questions first") is short; the detail it points to
is long and is needed rarely. A hard number in the lint turns "keep it short" from a wish into
a failing check. Option 4 gives up the one mechanism shipkit has for behaviour nobody asked for
by name.

**Case against (1).** A rule that says "use the format in `/shipkit:commit`" works only if the
model then loads that skill; today the format is simply present. Compressed wording can lose
behaviour in ways that three eval cases will not catch. The full list of destructive actions
must stay (REQ-18) and takes a fixed share of the budget. Every later sprint that wants one
more sentence must now remove one.

**Decision.** We chose (1). The lint check counts the core plugin's rules without `paths:`
frontmatter — not the stack overlays' always-on rules, which belong to the project that
installs them and already have their own 2,000-byte warning.
**Falsifiability.** We would reverse this — loosen the budget to 5,000 bytes — if a `rules`
eval case that passed at the 3.1.0 baseline fails at least two of three runs after the shrink
and cannot be recovered inside 3,000 bytes in three attempts.

---

## Decision: A hook blocks commits that stage a secret-looking file   (→ REQ-21 to REQ-26)

**Context.** The `shipkit` rule says "never stage `.env`, credentials, keys or tokens". That is
advice, and after this sprint it is advice inside a much smaller rule. Claude Code is reported
to let a `PreToolUse` hook on the Bash tool block a call by exiting 2; that is untested here.

**Alternatives.**
1. A `PreToolUse` hook, `guard-commit.sh`, that inspects staged file names before a `git commit`.
2. Keep the rule in prose only.
3. Have `/shipkit:setup` install a git `pre-commit` hook into the project.

**Case for (1).** It enforces instead of asking, costs no context, and covers plugin-only users
who never ran setup. Option 3 writes into `.git/hooks`, which other tools also own, and would
need an uninstall path in `/shipkit:unsetup`.

**Case against (1).** The script runs before *every* Bash call, so it must leave at once when
the command is not a commit. It matches on file names: it will stop a harmless test fixture
called `server.key`, and it will miss a token pasted into `config.py`. Matching the text
`git commit` is crude. It guards only commits Claude makes, not the ones typed in a terminal.
And it depends on a platform behaviour we have not yet seen work.

**Decision.** We chose (1), behind the "Check first" experiment in S1-T7. The guard exits 0 on
any internal error: a broken guard must never block a session.
**Falsifiability.** We would reverse this — remove the hook and keep the prose rule — if the
"Check first" experiment cannot make a `PreToolUse` hook block a Bash call, or if the guard
adds more than 100 ms to a Bash call that is not a commit, or if it blocks a legitimate commit
more than twice in any one sprint of this plan.

---

## Data / interface changes

- New directory `plugins/shipkit/evals/` (cases, fixture, README) — REQ-1 to REQ-11.
- New script `scripts/evals.sh`, repository-only, not shipped — REQ-1, REQ-2.
- New lint error: core always-on rules over 3,000 bytes — REQ-16.
- New hook entry in `plugins/shipkit/hooks/hooks.json`: `PreToolUse`, matcher `Bash`, running
  `scripts/guard-commit.sh` — REQ-21 to REQ-26.
- New project-wide decision log `.shipkit/decisions/`, starting at 0001 — REQ-13.
- The commit message template moves from `rules/shipkit.md` to `skills/commit/SKILL.md`; the
  EARS patterns and five-part detail live only in `skills/spec/reference.md` — REQ-19.
