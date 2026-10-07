# Trim audit for 4.0 (Sprint 7, S7-T1)

> Written 2026-10-06 against shipkit 3.7.0 at `568338e`. **This document proposes and changes
> nothing.** Every `cut` row needs the owner's yes before S7-T2 touches it (A8). Spec:
> `.shipkit/specs/trim-and-docs/` (REQ-1 to REQ-3). The owner's decisions are at the end.

## The rule for a line

A line of a rule **stays** only if it

- **(a)** holds a value specific to the project or to the owner's way of working;
- **(b)** names a specific trap that is not obvious — something the model gets wrong without
  being told (`mount/3` runs twice; a bare `bundle update` moves every gem);
- **(c)** is shown by an eval to change the result.

Everything else is `trim`. **(c) is not measured for any row below.** The `rules` eval cases
exercise the three always-on rules, not these files; no eval exists per path-scoped or stack
rule. The verdicts rest on (a) and (b) alone, and say so (design decision 2). A file in which no
line passes (a) or (b) is proposed as `cut`; a file with some such lines is `trim`, keeping
those lines and dropping the rest; `keep` means most lines already pass.

For the `shipkit-workflows` skills, which are not rules, the test is: does it duplicate a core
skill, a Claude Code built-in, or the model's default behaviour? Duplicated → `cut`
candidate; unique and short → `keep`; unique but padded → `trim`.

Counts are `wc -l` and `wc -c` of the file as shipped, frontmatter included.

## Path-scoped rules (`plugins/shipkit/rules/`, 6)

| File | Lines | Bytes | Verdict | Reason |
|---|---|---|---|---|
| `dependencies.md` | 36 | 1,031 | **trim** | 19 path globs and 8 lines. Keep two (b): never `*`/unpinned versions; never a bare `bundle update` / `npm update`. "Read the docs first" repeats the always-on `shipkit.md`; "run tests after", "check advisories", "latest stable" are repeated by all five overlay dependency rules below. → about 4 body lines. |
| `migrations.md` | 15 | 558 | **trim** | Keep two (b): batched operations on large tables; `CONCURRENTLY` for an index on a high-traffic table. "Never drop without confirming" is in `shipkit.md`; "reversible" and "rollback strategy" are what `/shipkit:ship` step 5 checks; the rest is generic. → 2 body lines. |
| `monorepo.md` | 24 | 900 | **trim** | Keep two (b): a shared-package change runs the tests of every consumer; `--filter` / `--scope` for targeted builds. Hoisting and deprecate→migrate→remove are generic. Also narrow the paths: `apps/**` and `packages/**` match Phoenix umbrellas and Rails engines that are not monorepos, so today the rule loads where it does not apply. → 2 body lines, 2 globs. |
| `security.md` | 20 | 598 | **cut** | No line passes (a) or (b): hardcoded secrets (already in `shipkit.md` and enforced by the commit guard), parameterized queries, validate input, auth on every endpoint, no internal errors to users, HTTPS — all are the model's default behaviour. The 9 globs (`**/api/**`, `**/live/**`, `**/views.py`) load it on most web files. Instead: nothing; the always-on rule and `guard-commit.sh` keep the one line that bites. **Owner's call: a trim to the one line "check authentication and authorization on every endpoint" is the alternative if a security file must exist.** |
| `testing.md` | 18 | 604 | **trim** | Keep two (b): use the factories/fixtures that already exist before creating new ones; match the project's test framework and patterns. Arrange/act/assert, specific assertions, one behaviour per test, descriptive names are defaults. → 2 body lines. |
| `ui-ux.md` | 74 | 2,428 | **trim** | Keep the WCAG baseline list — its numbers are the value (b): 4.5:1 and 3:1 contrast, 24×24 px targets, `prefers-reduced-motion`, errors never by colour alone, no layout shift, "a `div` with a click handler is not a button". Drop the four-line preamble that restates it and the `frontend-design` pointer (belongs in GUIDE). Keep the 42 globs: they are what make it path-scoped. → about 12 body lines. |

## Stack overlay rules (`plugins/shipkit/stacks/*/.claude/rules/`, 16)

| File | Lines | Bytes | Verdict | Reason |
|---|---|---|---|---|
| `elixir/elixir.md` | 9 | 475 | **cut** | Generic Elixir conventions (pattern matching, let it crash, pipes, `with`, `@moduledoc`) — defaults. "Contexts are the public API" is the Phoenix generator's own convention. No (a) or (b) line. `mix-deps.md`, `liveview.md` and `jobs.md` carry the stack's real traps. |
| `elixir/mix-deps.md` | 11 | 455 | **trim** | Keep (b): `~>` constraints; `mix hex.audit` / `mix deps.audit`; `only: [:dev, :test], runtime: false`. Drop "after ANY change run deps.get && test" (generic, in `dependencies.md`). → 3 lines. |
| `go/go-mod.md` | 12 | 561 | **trim** | Keep (b): `go get @latest`, never edit by hand; `govulncheck`; vendor only if `vendor/` exists; review `go.sum` for stray entries. Drop the generic test-after line. → 4 lines. |
| `go/go.md` | 11 | 627 | **cut** | Generic Go conventions (check errors, small interfaces, `%w`, table-driven tests, `defer`) — defaults the model already follows. No (a) or (b). |
| `hotwire/hotwire.md` | 42 | 2,205 | **trim** (to ≤ 40) | Dense in (b): Turbo caches pages so a leaked listener fires twice; morph needs stable ids; `turbo_stream_from` on every page is a connection leak; a Stream that touches one region should be a Frame; Turbo flows need a system test. Keep all of those. Drop "Turbo Drive handles navigation — don't reimplement it" (default) and "a Stimulus controller with logic worth testing belongs on the server" (opinion). → 38 lines, meets REQ-4. |
| `liveview/liveview.md` | 47 | 2,395 | **trim** (to ≤ 40) | The plan's own example trap lives here: `mount/3` runs twice. Also (b): URL state in `handle_params/3`; `push_patch` vs `push_navigate`; `stream/4` for collections; `assign_new/3`; `handle_info/2` tolerates late messages; test the disconnected render. Drop "declare `attr`/`slot` with types" and "keep `.heex` free of business logic" (defaults), and "prefer `phx-*` over hooks" (default). → 39 lines, meets REQ-4. |
| `ml/data.md` | 21 | 1,098 | **keep** | Every bullet is (b): raw data and weights out of git with a fetch step; provenance and licence; pinned dataset versions; schema check on load; personal data decision; committed fixture sample. |
| `ml/experiments.md` | 34 | 1,507 | **keep** | (b) throughout: seed everything and record it; log config + SHA + dataset version; deterministic kernels caveat; explicit device, never silent CPU; splits saved once; test set touched once; baseline named; checkpoints; token cost. One generic line ("hyperparameters in a config file") may go. |
| `ml/notebooks.md` | 20 | 1,015 | **keep** | (b): clear outputs (data leak, unreadable diffs); out-of-order execution; move reused functions to a module; no absolute paths; SHA and config printed next to a quoted number. |
| `oban/jobs.md` | 26 | 1,437 | **keep** | (b) throughout: at-least-once so `perform/1` is idempotent; args are IDs, re-fetch; `unique:`; the return-value contract; 4xx cancel vs 5xx retry; queues by priority; `Oban.Testing` manual mode; checkpoint long jobs. |
| `python/pyproject.md` | 15 | 533 | **trim** | Keep (b): flexible constraints in `pyproject.toml`, exact pins for deployment; `pip-audit`; detect the package manager from the lockfile; always a virtualenv. Drop the generic test-after line. → 4 lines. |
| `python/python.md` | 11 | 696 | **cut** | Generic Python conventions (type hints, no bare `except`, `with`, `pathlib`, f-strings, `logging`) — defaults. No (a) or (b). |
| `rails/gemfile.md` | 12 | 615 | **trim** | Keep (a): prefer `ruby_llm` for Rails AI features unless the project uses another — the owner's own value. Keep (b): `bundle audit`; grep for usages before removing a gem; `~>`. Drop the generic test-after line and `bundle outdated` (default). → 4 lines. |
| `rails/rails.md` | 9 | 455 | **trim** | Keep (a): background jobs for anything over 100 ms — the owner's threshold. Keep (b): `find_each`, never `all.each`; never `update_column` (skips validations and callbacks). Drop strong params, scopes, `presence`, `where.not`, thin controllers (defaults). → 3 lines. |
| `react/package-json.md` | 15 | 601 | **trim** | Keep (b): frozen-lockfile install; never hand-edit lockfiles; detect the package manager from the lockfile and do not mix. Drop caret default, audit, generic test-after. → 3 lines. |
| `react/react.md` | 23 | 1,397 | **trim** | Drop the eight generic React lines (functional components, no index keys, minimize `useEffect`…). Keep the whole "Inside a Rails app" section, which is (b) and is the reason this overlay exists in shipkit: Inertia props are the API contract; routing stays in Rails; auth and flash come from the server; a green test run with a stale bundle proves nothing; one frontend root. → about 13 lines. |

After these trims every stack rule is 40 lines or fewer (REQ-4); today `hotwire.md` (42) and
`liveview.md` (47) exceed it.

## `shipkit-workflows` skills (7)

Each skill's description is loaded into every session where the plugin is installed; its body
loads when invoked. Sizes are all `.md` files in the skill's folder.

| Skill | Lines | Bytes | Verdict | Reason |
|---|---|---|---|---|
| `code-review-standards` (knowledge base) | 165 | 8,476 | **cut** | Duplicates Claude Code's built-in `/code-review`, which the skill's own description defers to. The one part a built-in lacks — the AI/LLM-code lens — is a paragraph that fits in `GUIDE.md`. Its sibling `ui-ux-standards` was already removed in 3.0 for the same reason. Instead: `/code-review`; the lens paragraph in the guide. |
| `debug` | 178 | 5,967 | **trim** | Unique in shape (iron law, phases) but the core `shipkit.md` already says "when tests fail, investigate first", and the body restates one idea for 178 lines. Keep the phases and the "root cause before any fix" rule; cut `reference.md` to the checklist. → about 60 lines. |
| `humanize` | 293 | 13,514 | **keep** | Nothing else in shipkit or Claude Code does this; the pattern library is the value. The description already carries TRIGGER guidance. |
| `legacy-audit` | 94 | 3,599 | **keep** | Unique: dependency age, dead code, hotspots, coverage gaps in one pass. Overlaps `/shipkit:explain-system` only in spirit. Short enough. |
| `migration-plan` | 89 | 2,942 | **keep** | Unique and short; the "read the changelog first" step is a real trap (b) for upgrades. |
| `qa` | 157 | 6,677 | **trim** | Its description is five words with no TRIGGER guidance — the only skill without it — so it is either never or wrongly chosen. Rewrite the description; cut the five phases to the recon → plan → write → run → report skeleton. → about 80 lines. |
| `tdd` | 183 | 7,081 | **keep** | Referenced by the core: `shipkit.md`'s `strict-tdd` workflow style and `/shipkit:setup` point at it. Self-contained by design. Could lose 30 lines of restated iron law; not required. |

## `PROJECT_MAP.md` as the default (1)

| Item | Lines | Bytes | Verdict | Reason |
|---|---|---|---|---|
| The map as the default source for the elders (`archivist.md` 186 lines / 9,140 bytes; `skills/map/SKILL.md` 95 / 5,747; the hook's staleness nag; 8 mentions in the README) | 281 | 14,887 | **keep — pending re-test** | Decision 0001 (`.shipkit/decisions/0001-project-map-default.md`) found that on a nine-file fixture the map bought nothing (12 of 12 correct with and without it; 49 tool calls against 51) and wrote its own condition before acting: re-run on a fixture of at least 200 files with one question about how the project evolved. **That re-test has not been run.** The owner chose on 2026-10-06 to carry the row as pending; nothing about the map changes in this sprint. The row becomes `cut` (from the default, not from the plugin) only if the re-test confirms the record. |

## Totals

| Verdict | Rows | Files |
|---|---|---|
| **cut** | 5 | `rules/security.md`, `stacks/elixir/elixir.md`, `stacks/go/go.md`, `stacks/python/python.md`, `shipkit-workflows/skills/code-review-standards/` |
| **trim** | 16 | `dependencies`, `migrations`, `monorepo`, `testing`, `ui-ux`, `mix-deps`, `go-mod`, `hotwire`, `liveview`, `pyproject`, `gemfile`, `rails`, `package-json`, `react`, `debug`, `qa` |
| **keep** | 9 | `data`, `experiments`, `notebooks`, `jobs`, `humanize`, `legacy-audit`, `migration-plan`, `tdd`, the map (pending) |

30 rows. The 22 rules total 505 lines / 22,191 bytes today; after the proposed trims and cuts,
about 190 lines. Every row's `trim` is applied in S7-T2 regardless; **only a `cut` row with the
owner's yes is removed.** If none is approved, the release is 3.8.0.

## The owner's decisions (2026-10-06)

Every `cut` row was shown to the owner and answered the same day:

| Row | Decision |
|---|---|
| `rules/security.md` | **yes, cut** |
| `stacks/elixir/elixir.md` | **yes, cut** |
| `stacks/go/go.md` | **yes, cut** |
| `stacks/python/python.md` | **yes, cut** |
| `shipkit-workflows/skills/code-review-standards/` | **yes, cut**; the AI/LLM-code lens moves to `GUIDE.md` |
| the map as the default | not a cut this sprint; pending decision 0001's re-test |

Five cuts approved, so Sprint 7 releases as **4.0.0**. S7-T2 applies these five and the
sixteen trims, and nothing else.

## What this audit did not measure

- Criterion (c), for every row. An eval per rule file would cost more than the rules weigh.
- Whether any user besides the owner relies on a `cut` file. Shipkit has one user.
- The always-on rules: they are under their own 3,000-byte budget and were trimmed in Sprint 1.

## Criterion (c), measured in 4.2.0

Appended 2026-10-07 by sprint task S9-T4 (spec `rule-evals`, REQ-16); nothing above this line
was changed. One case per trimmed rule file, its prompt walking into the file's first named
trap, three runs with the 4.0 text and three with the `v3.7.0` text (`git show`), the rule
delivered as always-on text by the hook because the eval sandbox loads no project file.
Method, per-run counts and the readings: `eval-results-4.2.md`. Runs passed, then tool calls
per run.

| File | 4.0 text | `v3.7.0` text |
|---|---|---|
| `rules/dependencies.md` | 3 of 3; 4, 4, 5 | 3 of 3; 7, 8, 8 |
| `rules/migrations.md` | 3 of 3; 4, 4, 3 | 3 of 3; 5, 4, 5 |
| `rules/monorepo.md` | 3 of 3; 10, 8, 7 | 3 of 3; 9, 9, 9 |
| `rules/testing.md` | 3 of 3; 9, 9, 12 | 3 of 3; 9, 9, 9 |
| `rules/ui-ux.md` | 3 of 3; 4, 4, 4 | 3 of 3; 4, 4, 5 |
| `elixir/mix-deps.md` | 3 of 3; 5, 4, 4 | 3 of 3; 4, 5, 4 |
| `go/go-mod.md` | 3 of 3; 2, 2, 2 | 3 of 3; 3, 2, 2 |
| `hotwire/hotwire.md` | 3 of 3; 6, 3, 5 | 3 of 3; 6, 3, 5 |
| `liveview/liveview.md` | 3 of 3; 3, 3, 3 | 3 of 3; 3, 3, 3 |
| `python/pyproject.md` | 3 of 3; 6, 5, 5 | 3 of 3; 6, 6, 5 |
| `rails/gemfile.md` | 3 of 3; 2, 2, 2 | 3 of 3; 2, 2, 2 |
| `rails/rails.md` | 3 of 3; 3, 3, 3 | 3 of 3; 3, 3, 3 |
| `react/package-json.md` | 3 of 3; 3, 3, 3 | 3 of 3; 3, 5, 3 |
| `react/react.md` | 3 of 3; 8, 6, 5 | 3 of 3; 10, 9, 6 |

No trimmed file scores lower with its 4.0 text than with its `v3.7.0` text: 42 of 42 runs
each way. The one visible cost ran against the old text — `dependencies.md` at `v3.7.0` took
seven to eight tool calls where the trimmed text took four or five, because the model obeyed
the generic lines the trim removed. The same sprint also ran each file without any text
(`eval-results-4.2.md`): `dependencies.md` is the one trimmed file whose case fails without
it (0 of 3); the other thirteen pass without it, which says the first trap is one this model
clears unaided, not that the file is dead weight. The five cut files have no with arm and
were not measured.
