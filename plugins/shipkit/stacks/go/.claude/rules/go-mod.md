---
paths:
  - "go.mod"
  - "go.sum"
---
# When Modifying go.mod / go.sum
- Use `go get <module>@latest` to add or update — never edit go.mod by hand; then `go mod tidy`
- Run `govulncheck ./...` for known vulnerabilities
- Never vendor unless the project already has `vendor/` (check `-mod=vendor`)
- Review the `go.sum` diff: it should hold only entries for the module you touched
