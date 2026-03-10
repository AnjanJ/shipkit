# Elixir Conventions
- Use pattern matching over conditional logic
- Let it crash — use supervisors, don't over-rescue
- Pipe operator for data transformations (3+ steps)
- Contexts are the public API — never call Repo directly from controllers
- Use changesets for all data validation
- Prefer `with` for multi-step operations that can fail
- Keep GenServer callbacks short — delegate to helper functions
- Use `@moduledoc` and `@doc` for public modules and functions
