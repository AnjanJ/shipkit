# Trim audit — the overlay `CLAUDE.md` appends and the two unscoped overlay rules

> Thinning plan W7 (S21-T2), 2026-10-30. Spec: `.shipkit/specs/overlays-and-eve/` (REQ-5 to
> REQ-7). The 4.0 rule for a line: it **stays** if it (a) holds a value specific to the
> owner's way of working, (b) names a trap the model gets wrong untold, or (c) is shown by an
> eval to change the result. No case installs an append, so (c) is unavailable here and every
> verdict rests on (a) and (b), and says so. A `trim` row moves only on the owner's yes; a row
> the owner keeps reads "kept on the owner's word". Bytes are the shipped file's.

## What the appends cost, and whom

`install-stack.sh` appends `stacks/<overlay>/CLAUDE.md.append` to the project's `CLAUDE.md`
under a marker, placeholders filled. It loads whole into every session of that project. The
4.12 run (`field-notes-4.12.md` §2.2) showed the python section on a FastAPI project carrying
the template's "or" alternatives and a Django block: lines written for every Python project at
once, which detection cannot resolve, beside a project section setup had already filled.

| Append | Bytes | Loads where |
|---|---:|---|
| `python` | 2,525 | every session of a set-up Python project |
| `go` | 2,150 | Go |
| `rails` | 1,638 | Rails |
| `elixir` | 1,623 | Elixir |
| `react` | 1,532 | React (standalone or in a host) |
| `static` | 885 | static sites |
| `ml` | 606 | Python + ML |
| `hotwire` | 499 | Rails + Hotwire |
| `liveview` | 406 | Elixir + LiveView |
| `oban` | 303 | Elixir + Oban |

Three shapes recur across the big five, and the verdicts below treat each the same way:

- **A placeholder line** (the `FRAMEWORK` placeholder, the `TEST_COMMAND` placeholder …) — **keep**: setup fills it
  from detection; it is (a) by construction.
- **A "Key Paths" table of generic rows** — **trim**: setup already writes a project-specific
  Key Paths table into the project section (`field-notes-4.12.md` §2: the five real files), so
  the append's generic rows (`src/` or `app/`) are a second table that says less. Rows that
  name a convention the stack enforces (Rails' `db/migrate/`, Elixir's `lib/<app>_web/`) are
  (a) and stay.
- **A "Style" line with alternatives** (`Ruff or flake8`) — **trim** where the project section
  already carries a detected Lint line; a line that names one tool the stack has by convention
  (`mix format`, `gofmt`) stays as (a).

## `python` — 2,525 bytes (first, by the 4.12 finding)

| Line | Text | Verdict | Reason |
|---|---|---|---|
| 2 | `## Python-Specific` | keep | the section heading; the marker's anchor |
| 4–8 | Architecture: Framework, API style, Async placeholders | keep | (a) filled from detection |
| 10–18 | Key Paths: `src/` or `app/`; `tests/`; `migrations/` or `alembic/`; `requirements.txt` or `pyproject.toml`; `config/` or `settings.py` | **trim** (the table) | the project section already has the real Key Paths; four of five rows are unresolved alternatives, none a trap |
| 20–24 | Testing: framework placeholder; run all / specific / coverage from the `TEST_COMMAND` placeholder | keep | (a); the coverage line assumes `pytest-cov` — kept as the common case, said here |
| 26 | `### Style` | see below | |
| 27 | Linter: Ruff (`ruff check .`) or flake8 | **trim** | the project section carries the detected Lint line (`n/a` on the 4.12 project); this is the template's "or" |
| 28 | Formatter: Ruff (`ruff format .`) or Black (`black .`) | **trim** | same |
| 29 | Type check: `mypy .` or `pyright` | **trim** | same |
| 31–37 | Python Conventions: type hints; absolute imports grouped; never bare `except:`; `with` for handles; dataclasses/Pydantic over dicts; `async/await` for I/O in async frameworks | keep 34, 35, 36; **trim** 32, 33, 37 | 34 (bare `except:`), 35 (unclosed handles) and 36 (dicts as structures) are (b): the model does them untold. 32 and 33 are style the formatter and linter own; 37 restates what an async framework forces |
| 39–44 | Django Gotchas (if applicable): N+1 `select_related`; never remove a field in the deploy that removes its code; forms/serializers validate input; `django-environ` for secrets; no `post_save` side effects | **trim** on a non-Django project; keep the five lines where the `PYTHON_FRAMEWORK` placeholder is Django | all five are (b) for Django and noise for FastAPI/Flask (the 4.12 project loaded them every session). The honest shape is a conditional block: the installer substitutes placeholders, not sections, so the verdict asks for a `python/django.md` rule with `paths: ["**/models.py", "**/views.py", "**/migrations/**"]` carrying the five lines, and the block out of the append |
| 46–50 | FastAPI Gotchas (if applicable): `Depends()`; Pydantic schemas, never raw dicts; `BackgroundTasks` or Celery; async ORM with async endpoints | keep 48, 50; **trim** 47, 49 | 48 (raw dicts from endpoints) and 50 (a sync ORM behind `async def`) are (b). 47 and 49 are FastAPI's own documentation, not traps |
| 52–55 | Database: ORM placeholder; Migrate `python manage.py migrate` or `alembic upgrade head`; Rollback | keep 53; **trim** 54, 55 | the ORM line is (a); the two "or" command lines are unresolved alternatives — on the 4.12 project (no database) they were false |

Trims, if all yes: lines 10–18, 27–29, 32–33, 37, 39–44, 47, 49, 54–55 ≈ 1,450 bytes of 2,525;
the five Django lines return as a path-scoped rule (≈ 450 bytes, loaded only on Django files).

## `rails` — 1,638 bytes

| Line | Text | Verdict | Reason |
|---|---|---|---|
| 4–8 | Architecture placeholders (Pattern, API mode, Frontend) | keep | (a) |
| 10–20 | Key Paths: `app/models/`, `app/controllers/`, `app/services/` (if service objects), `app/jobs/`, `db/migrate/`, `spec/` or `test/`, `config/routes.rb` | keep 14–15, 17–18, 20; **trim** 16, 19 | Rails' layout is a convention (a); `app/services/ (if using service objects)` is conditional on the Pattern placeholder, and `spec/ or test/` is answered by the `TEST_FRAMEWORK` placeholder two lines down |
| 22–26 | Testing placeholders + System tests line | keep | (a) |
| 28–31 | Style: RuboCop, `.rubocop.yml`, auto-fix | keep 29; **trim** 30, 31 | RuboCop is Rails' convention (a); the config path and `-a` are what the tool prints when asked |
| 33–38 | Rails Gotchas: N+1 `includes`/`preload`; `ignored_columns` before removing a column; strong params; no `after_save` side effects; scopes over class methods | keep 34–37; **trim** 38 | 34–37 are (b) — the four the model gets wrong untold (the `trap2/*` cases measure their rule-file cousins). 38 is a style preference |
| 40–44 | Database placeholder + migrate/rollback/seed | keep 41–43; **trim** 44 | `db:seed` is not a trap and not a value |

Trims, if all yes: ≈ 230 bytes of 1,638.

## `react` — 1,532 bytes

| Line | Text | Verdict | Reason |
|---|---|---|---|
| 4–8 | Architecture placeholders (Pattern, State, Styling, Router) | keep | (a) |
| 10–19 | Key Paths: `src/components/`, `src/screens/` or `src/pages/`, `src/hooks/`, `src/services/` or `src/api/`, `src/stores/` or `src/state/`, `src/types/` | **trim** (the table) | a React project has no enforced layout; three of six rows are "or"; the project section's own Key Paths say where things are |
| 21–25 | Testing placeholders; Testing Library line | keep | (a); Testing Library is the convention the `TEST_FRAMEWORK` placeholder implies |
| 27–30 | Style: ESLint, Prettier, `tsc --noEmit` | **trim** 28, 29; keep 30 | ESLint and Prettier are assumptions, not detections, and the project section carries Lint; `tsc --noEmit` is the type check a TS project needs and nobody runs untold — (b) |
| 32–38 | React Conventions: functional components; TS interfaces for props; colocate state; minimise `useEffect`; never array index as key; memoise only on a measured issue | keep 36, 37, 38; **trim** 33, 34, 35 | 36 (effects), 37 (index keys), 38 (premature memoisation) are (b). 33–35 are the defaults any current React code already follows |

Trims, if all yes: ≈ 650 bytes of 1,532.

## `elixir` — 1,623 bytes

| Line | Text | Verdict | Reason |
|---|---|---|---|
| 4–7 | Architecture placeholders; "OTP patterns: GenServer, Supervisor trees as needed" | keep 5–6; **trim** 7 | 7 says nothing a project needs told |
| 9–19 | Key Paths: `lib/<app>/`, `lib/<app>_web/`, `lib/<app>_web/live/`, `application.ex`, `priv/repo/migrations/`, `test/`, `config/` | keep | Phoenix's generator fixes this layout (a); the `_web` split is the one newcomers break |
| 21–26 | Testing: ExUnit, `mix test`, specific, `--cover`, watch (if dep installed) | keep 22–24; **trim** 25, 26 | coverage and watch mode are conditional conveniences |
| 28–31 | Style: `mix format`; `mix credo` (if installed); `mix dialyzer` (if installed) | keep 29; **trim** 30, 31 | `mix format` is the convention (a); the two "if installed" lines are not known to be true |
| 33–40 | Elixir Conventions: contexts not schemas; lean schemas; pattern matching; pipes; `with`; GenServer only for state/messages; `{:ok, _}`/`{:error, _}` tuples | keep 34, 35, 39, 40; **trim** 36, 37, 38 | 34–35 (logic in schemas) and 39 (GenServer by reflex) are (b); 40 is the error contract (a). 36–38 are the language's idioms, followed untold |
| 42–46 | Database: Ecto; migrate/rollback/seed | keep 43–45; **trim** 46 | as rails 44 |

Trims, if all yes: ≈ 420 bytes of 1,623.

## `go` — 2,150 bytes

| Line | Text | Verdict | Reason |
|---|---|---|---|
| 4–8 | Architecture placeholders (Framework, API style, Module path) | keep | (a) |
| 10–19 | Key Paths: `cmd/`, `internal/`, `pkg/` (if used), `api/`, `migrations/`, `config/` | keep 14, 15; **trim** 16–19 | `cmd/` and `internal/` are the Go layout the compiler enforces (a); the rest are "if used" or generic |
| 21–27 | Testing: stdlib, run all, specific, coverage, race, bench | keep 22–23, 26; **trim** 24, 25, 27 | `go test ./...` and `-race` (b: races go unseen untold); the rest are `go help test` |
| 29–32 | Style: `gofmt`/`goimports`, `golangci-lint`, `go vet` | keep 30, 32; **trim** 31 | gofmt and vet are the toolchain (a); golangci-lint is an assumption |
| 34–43 | Go Conventions: check every error; accept interfaces return structs; naming; package names; channels vs mutexes; `context.Context` first; goroutine exit / `errgroup`; `%w` wrapping; struct literals with names | keep 35, 40, 41, 42; **trim** 36, 37, 38, 39, 43 | 35 (`_ = err`), 40 (no context), 41 (leaked goroutines), 42 (lost error chains) are (b). The others are Effective Go, followed untold |
| 45–48 | Database (if applicable): placeholder; `migrate … up` or `goose up`; down | keep 46; **trim** 47, 48 | the two "or" command lines, as python 54–55 |

Trims, if all yes: ≈ 900 bytes of 2,150.

## `static` — 885 bytes

| Line | Text | Verdict | Reason |
|---|---|---|---|
| 4–12 | Structure table with "or" rows | **trim** (the table) | three of five rows are alternatives; the project section's Key Paths say where things are |
| 14–16 | Build placeholders | keep | (a) |
| 18–24 | Conventions: semantic HTML; mobile-first + custom properties; vanilla JS; optimised lazy images; a11y (alt, labels, keyboard); SEO (meta, OG, JSON-LD, sitemap) | keep 23, 24; **trim** 19–22 | 23 and 24 are checklists the model skips untold (b) — and the `ui-ux` path-scoped rule carries the a11y baseline, so 23 may read "see `ui-ux.md`"; 19–22 are preferences |

Trims, if all yes: ≈ 480 bytes of 885.

## `hotwire` (499), `liveview` (406), `oban` (303), `ml` (606)

| Append | Lines | Verdict | Reason |
|---|---|---|---|
| `hotwire` | placeholders; "Drive by default, Frames for scoped navigation, Streams for multi-region …; Stimulus for no-round-trip only; full rules in `.claude/rules/shipkit/hotwire/`" | keep | each line is (b) — the Turbo-layer choice is the trap — and the file already points at the rule for the rest |
| `liveview` | placeholders; "`mount/3` runs twice, `stream/4`, `handle_params/3`, function components over nested LiveViews" | keep | all (b); `mount/3` twice is the LiveView trap |
| `oban` | placeholders; "idempotent `perform/1`, args are IDs, `unique:`, `{:cancel, _}`" | keep | all (b) |
| `ml` | seven placeholders; "seeds set and logged, runs recorded with config + SHA, never evaluate on training data, raw data and weights out of git" | keep | all (b); the shortest of the appends already written to this audit's rule |

## The two unscoped overlay rules

| File | Bytes | Lines | Verdict | Reason |
|---|---:|---|---|---|
| `stacks/rails/.claude/rules/rails.md` | 246 | `find_each` not `all.each`; > 100 ms to a job; never `update_column(s)` | keep all three; **add `paths:`** `["app/**/*.rb", "lib/**/*.rb", "config/**/*.rb"]` | all three are (b) and the `trap2/rails` case measures the third (0 of 3 unaided on `haiku`, 3 of 3 with — `eval-results-4.11.md` §5). The lines are about Ruby code; a glob fits, and the rule stops loading on a `.erb` or `.yml` edit |
| `stacks/react/.claude/rules/react.md` | 701 | components under `app/frontend/` or `app/javascript/`; auth and flash from the server; the asset build runs before tests; server-driven state | keep all four; **add `paths:`** `["app/frontend/**", "app/javascript/**", "**/*.tsx", "**/*.jsx"]` | the first line says the two roots itself, so the glob is the rule's own; all four are (b) for React inside a host app |

## What this audit does not claim

It does not claim a trimmed line is one the model never needed: no case installs an append,
so (c) was unavailable, and a kept line is kept by reading. The watch after any trim is a
real run's notes on that stack (Sprint 22's re-run on a Python project reads the python
section first) and the stack's `trap2/*` cases, which measure the rule files the appends point
at, not the appends. The owner's decisions are recorded below; a trim without a yes here did
not happen.

## The owner's decisions

2026-10-30, all four groups **yes**: the python trims with the Django block as a path-scoped
`stacks/python/.claude/rules/django.md` (`**/models.py`, `**/views.py`, `**/serializers.py`,
`**/migrations/**`, `**/settings*.py`); the rails, elixir and go trims; the react and static
trims; `paths:` on `rails.md` and `react.md`. Applied in S21-T2's commit. The appends after:
python 2,525 → 1,030 bytes, rails 1,638 → 1,375, react 1,532 → 883, elixir 1,623 → 1,137,
go 2,150 → 1,170, static 885 → 395 (the four small ones unchanged); `django.md` 583 bytes,
loaded on Django files only. Smoke check 68 holds each append at or under its size and the two
rules' `paths:`.
