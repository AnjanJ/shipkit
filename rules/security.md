---
paths:
  - "**/controllers/**"
  - "**/routes/**"
  - "**/api/**"
  - "**/auth/**"
  - "**/middleware/**"
  - "**/lib/*_web/**"
---
# Security Rules
- Never hardcode secrets, API keys, or credentials
- Always validate and sanitize user input at system boundaries
- Use parameterized queries — never string-concatenate SQL
- Check authentication and authorization on every endpoint
- Avoid exposing internal errors to end users
- Log security-relevant events (failed logins, permission denials)
- Use HTTPS for all external API calls
