---
paths:
  - "go.mod"
  - "go.sum"
---
# When Modifying go.mod / go.sum
- Use `go get <module>@latest` to add or update dependencies — never edit go.mod manually
- After ANY change: run `go mod tidy && go test ./...` to verify
- Run `govulncheck ./...` to check for known vulnerabilities
- Use `go list -m -versions <module>` to check available versions before pinning
- Never vendor unless the project already uses `vendor/` — check for `go.mod`'s `-mod=vendor`
- Review `go.sum` changes — they should only contain entries for the added/updated module
