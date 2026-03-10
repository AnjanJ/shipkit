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
- Match existing test patterns and frameworks in this project
- Every test must have a clear arrange/act/assert structure
- Prefer specific assertions over generic truthy checks
- Never skip or disable tests without a comment explaining why
- Test names should describe the behavior, not the implementation
- Test one behavior per test — if you need "and" in the name, split it
- Use factories/fixtures that already exist before creating new ones
