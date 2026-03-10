---
description: "Scaffold a Go package with tests — detects project layout and framework"
user-invocable: true
disable-model-invocation: true
argument-hint: "[<type> <Name>, e.g. handler UserHandler]"
---

# /new-feature — Scaffold Go Package + Test

Scaffold: $ARGUMENTS

## Before Scaffolding — YAGNI + SRP Gate

**YAGNI — is a new package needed at all?**
1. Could the logic live in an existing package?
2. Is a separate package justified? If it's one function with one caller, keep it where it's used.
3. Would this be better as a method on an existing type?

**SRP — if a new package IS needed, does it have one job?**
4. Does the proposed package have a single reason to change?
5. Is it mixing concerns? (e.g., HTTP handling + business logic + database access — split it.)

If an existing package can handle this, say so.

## Project Detection
!`cat go.mod 2>/dev/null | head -3 || echo "no go.mod found"`
!`ls cmd/ internal/ pkg/ 2>/dev/null || echo "flat layout"`

Check CLAUDE.md for the project layout, or auto-detect:
- `cmd/` + `internal/` exists → **Standard Go layout**
- `cmd/` only → **Simple CLI**
- Flat layout → **Single package / microservice**

## Scaffolding by Type

### Handler (HTTP)
```
internal/handler/<name>.go
internal/handler/<name>_test.go
```
- Read an existing handler first — match the framework (stdlib, Chi, Gin, Echo)
- Accept dependencies via constructor injection
- Request validation, response serialization
- Add route registration

### Service (Business Logic)
```
internal/service/<name>.go
internal/service/<name>_test.go
```
- Define an interface for the service
- Constructor returns concrete type: `func NewXxx(deps) *Xxx`
- Methods accept `context.Context` as first param

### Repository (Data Access)
```
internal/repository/<name>.go
internal/repository/<name>_test.go
```
- Define a repository interface in the service package (consumer defines interface)
- Implement against the specific DB driver
- Use `sqlx`, `database/sql`, or the project's ORM

### CLI Command
```
cmd/<name>/main.go
```
- Parse flags with `flag` package or cobra (match project convention)
- Keep `main()` thin — delegate to internal packages

### Middleware
```
internal/middleware/<name>.go
internal/middleware/<name>_test.go
```
- Match the framework's middleware signature
- Read an existing middleware first

## Dependency Verification (mandatory)

If this feature requires a new module:
1. Read the module's documentation first (WebFetch its README or pkg.go.dev page)
2. Check the latest stable version: `go list -m -versions <module>`
3. Run `go get <module>@latest && go test ./...` — full suite
4. Run `govulncheck ./...` for security advisories
5. Verify `go.sum` changes are from the expected module only

## After Scaffolding

1. Run the new test: `go test -v ./<package_path>`
2. Run the linter: `golangci-lint run ./<package_path>`
3. Run vet: `go vet ./<package_path>`
4. Report what was created and any issues
