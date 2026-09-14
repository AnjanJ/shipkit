# Rails Conventions
- Use strong parameters for all controller inputs
- Prefer scopes over class methods for queries
- Use `find_each` for batch processing, never `all.each`
- Background jobs for anything taking >100ms
- Never use `update_column` — it skips validations and callbacks
- Use `presence` validation over custom blank checks
- Prefer `where.not` over raw SQL negation
- Keep controllers thin — business logic belongs in models or services
