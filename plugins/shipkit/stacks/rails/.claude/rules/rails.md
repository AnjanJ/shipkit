# Rails Conventions
- `find_each` for batch processing, never `all.each` — it loads the whole table
- Anything over 100 ms in a request goes to a background job
- Never `update_column` / `update_columns` — they skip validations and callbacks
