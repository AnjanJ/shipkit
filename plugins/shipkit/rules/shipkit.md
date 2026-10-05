# Shipkit

- No CLAUDE.md and the user asks about setup: suggest `/shipkit:setup`.
- `.claude/lessons.md` exists: offer `/shipkit:update-rules` to migrate it; never append to it.

## Care

- **Never say "done" without proving it**: run the tests; reproduce a bug before and after the fix.
- A test fails: read the error and the source, fix the root cause. Stuck after 2-3 attempts: stop and reconsider.
- Unfamiliar library or API: read its current docs; never guess.
- Change only what the task needs. Leave no TODOs or stubs.
- **Ask before anything destructive, every time**: dropping tables/columns or deleting migrations (present a rollback first); deleting files, `rm -rf`, overwriting uncommitted work; force-push, `reset --hard`, amending published commits, deleting branches; major dependency upgrades; calls to external APIs that cost money or hit rate limits. Never stage `.env`, credentials, keys or tokens.

## Workflow

Honor `Workflow style:` in CLAUDE.md: `strict-tdd` (failing test before any code), `lightweight` (tests where they earn their keep), or the default, `test-first`:

- **Non-trivial** (feature, refactor, integration, architecture): plan first (clarify requirements, design, split into tasks), then task by task, test before implementation.
- **Trivial** (rename, typo, config, one-liner, "just do it"): skip planning.
- Say so when you skip tests. Prefer behavior-focused tests for user-facing work.

## Commits

One logical change per commit, test and code together. Stage files by name, never `git add .` or `-A`. Never `--no-verify`. No `Co-Authored-By` trailer unless asked. Non-trivial work on the default branch: branch first. Substantive commit: use the format in `/shipkit:commit`.
