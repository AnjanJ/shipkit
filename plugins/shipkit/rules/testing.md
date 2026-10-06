---
paths:
  - "**/*_test.*"
  - "**/*_spec.*"
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/test/**"
  - "**/spec/**"
  - "**/tests/**"
---
# Testing Rules
- Use the factories, fixtures and helpers that already exist before writing new ones — look in
  the test support directory first; a second `create_user` is how suites rot.
- Match the project's test framework and file layout; do not introduce a second runner.
