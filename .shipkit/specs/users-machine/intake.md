# Intake: The user's machine (Sprint 27)

> Intake taken on 2026-11-05, by hand from the approved machine plan.

## Request
What setup writes runs on the user's machine, and the gate reads the same whatever their shell
says: a test command that runs on a pinned toolchain (G4), gate searches no alias can bend (G5),
the headless wait measured before anything is said about it (G7), and the evals' home recorded
(G8) (`docs/plans/machine-sprint-plan.md`, Sprint 27).

## Serves goal
The ROADMAP's north star: shipkit "checks the result against the intent". A test command that does
not run, or a search that prints nothing for a line that is there, is a check that says the wrong
thing. This repository has no `.shipkit/product.md`, so the goal is the plan's §0 table.

## Conflicts found
- **G4 as the plan words it does not reach the elixir or go section.** The plan says
  "`TEST_COMMAND` carries it into `CLAUDE.md`". It reaches setup's own **Test:** line
  (`setup/reference.md:19`, written by the model from the detected command), but the elixir append
  writes `mix test` twice (`stacks/elixir/CLAUDE.md.append:22-23`) and the go append
  `go test ./...` (`stacks/go/CLAUDE.md.append:19`), with no placeholder; only the rails, python and
  react appends take the `TEST_COMMAND` placeholder. On `office_bestie`, G10's project, a prefixed **Test:**
  line would sit above a section saying `mix test`, and the gate's step 2 takes "the project's test
  command" from that file. Found at S26-T1 and noted for this T0. Fixing it adds both appends to
  S27-T1's Files: a change to the plan's T1, for the owner's word.
- **A leading assignment.** `office_bestie`'s own command is `MIX_ENV=test mix test` (its
  `CLAUDE.md:10`). `mise exec -- MIX_ENV=test mix test` runs no program called `MIX_ENV=test`; the
  prefix goes after any `VAR=value` words. G4's sentence has to say so.
- **G5 and an untracked `tasks.md`.** `git grep` reads tracked files only: on a scratch repository,
  `git grep -n -e '^- \[ \]' -- t.md` on an untracked `t.md` with an unticked line exits 1, which
  the gate's step 3 reads as PASS. With `--untracked` it exits 0 and prints the line. A tracked file
  is read from the working tree, so an uncommitted tick counts. Step 3 needs `--untracked`.
- **G5's subject is the model's own searches.** The `fourth-project` reviewer's
  `grep -n "198,837\|198837" ROADMAP.md` was written by the model; `reviewer.md` holds no `\|` and
  one `grep` (`:32`, as the reader's tool for a line number). The sentence instructs; a smoke check
  can hold only the sentence. Setup's own `grep -roh` on the plugin's files met ripgrep too
  (`field-notes-5.1.md` §2, awkward 4): that is outside a repository, not the gate's, and out of
  scope.
- **G8's Check first holds.** Read 2026-11-05: the plugin loading reference says every marketplace
  plugin not loaded in place is copied whole into `cache/<marketplace>/<plugin>/<version>/` and
  names no way to leave a path out (https://code.claude.com/docs/en/plugins/loading.md, "In-place
  and copied plugins"); the evals page says an `--eval-dir` is "a relative path of plain directory
  names … An absolute path or one containing `..` isn't accepted"
  (https://code.claude.com/docs/en/plugin-evals.md, "Use a different eval directory"). The move is
  not a task of this sprint.
- **G7: no skill names a wait.** No `Monitor`, `sleep` or background wait in `skills/` or `agents/`.
  The 5.1 intake idled 253 s after its work: `grandfather` took 53 s in the background, the model
  armed two `Monitor` watches with five-minute expiries, and a headless session does not end while
  they are armed (`field-notes-5.1.md` §4, awkward 1).
- Smoke check 68 caps the elixir append at 1,220 bytes (it is 1,165; the placeholder twice for
  `mix test` add 16) and the go append at 1,270 (1,170; one adds 3).
- No open spec. `gate-on-setup` merged (PR #31).

## Answers
1. Do the elixir and go appends take the `TEST_COMMAND` placeholder, amending S27-T1's Files? —
   Yes (the owner, 2026-11-05, "yes to all"): elixir's two lines; go's "Run all" line, its
   race-detector line left as it is. The plan's S27-T1 amended in T0's commit.
2. The requirements as drafted, REQ-1 to REQ-11. — Approved the same day.

## Assumptions made
- A project that pins with `asdf` but has no `mise` on the `PATH` keeps its command unchanged: G4
  needs both a `mise` file and `mise`.
- The stack skills' own test lines (`stacks/elixir/.claude/skills/new-feature/SKILL.md:58,63`,
  `stacks/go/…:84,90`) stay: installed only with `--with-skills` since 5.0.0, and a ROADMAP line.
- S27-T1's Check first (a headless `claude -p` on an `office_bestie` worktree, its own test
  database) and S27-T3's five intakes are paid; each asks the owner first, as the plan's budget says.

## Out of scope
The run and 5.2.0 (Sprint 28); `--scope project` (G11); setup's own searches of the plugin's files;
the stack skills' test lines; merging two `## Elixir-Specific` sections (G6); moving the evals
(G8); a decision's record in the brief; any new always-on byte.
