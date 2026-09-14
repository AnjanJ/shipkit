---
description: "Scaffold Elixir context, schema, or LiveView with tests"
user-invocable: true
disable-model-invocation: true
argument-hint: "[<type> <Name>, e.g. context Accounts]"
---

# /new-feature — Scaffold Elixir Module + Test

Scaffold: $ARGUMENTS

## Types

### Context
```
lib/<app>/<name>.ex          (e.g., lib/my_app/accounts.ex)
test/<app>/<name>_test.exs
```
- Public API functions: `list_*`, `get_*`, `create_*`, `update_*`, `delete_*`
- Delegates to Ecto.Repo
- Read an existing context first — match the style exactly

### Schema
```
lib/<app>/<context>/<name>.ex    (e.g., lib/my_app/accounts/user.ex)
test/<app>/<context>/<name>_test.exs
priv/repo/migrations/TIMESTAMP_create_<table>.exs
```
- Ecto schema with changeset function
- Include relevant validations (presence, format, uniqueness)
- Migration with appropriate column types

### LiveView
```
lib/<app>_web/live/<name>_live.ex         (e.g., lib/my_app_web/live/user_settings_live.ex)
lib/<app>_web/live/<name>_live.html.heex  (template)
test/<app>_web/live/<name>_live_test.exs
```
- Mount, handle_event, handle_info callbacks
- Read an existing LiveView first — match the project's patterns
- Add route to `router.ex`

### GenServer
```
lib/<app>/<name>.ex
test/<app>/<name>_test.exs
```
- `use GenServer` with init, handle_call, handle_cast, handle_info
- Client API functions wrapping GenServer.call/cast
- Add to supervision tree in `application.ex`

## Dependency Verification (mandatory)

If this feature requires a new dependency:
1. Read the library's documentation first (WebFetch hex.pm docs or README)
2. Check the latest stable version: `mix hex.info <package>`
3. Use version constraint: `{:name, "~> X.Y"}` — never unconstrained
4. Run `mix deps.get && mix test` — full suite, not just the new test
5. Run `mix hex.audit && mix deps.audit` for security advisories

## After Scaffolding

1. Run the new test: `mix test <test_path>`
2. Run the formatter: `mix format <file_path> <test_path>`
3. Run Credo (if installed): `mix credo <file_path>`
4. Report what was created
