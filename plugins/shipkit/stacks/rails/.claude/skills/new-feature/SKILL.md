---
description: "Scaffold a new Rails class with spec — detects project architecture"
user-invocable: true
disable-model-invocation: true
argument-hint: "[<type> <Name>, e.g. service ProcessPayment]"
---

# /new-feature — Scaffold Rails Class + Spec

Scaffold: $ARGUMENTS

## Before Scaffolding — YAGNI + SRP Gate

**YAGNI — is a new class needed at all?**
1. Could the logic live in an existing model, controller, or service?
2. Is a service object justified? If <10 lines and one call site, a private method is simpler.
3. Is a job justified? If the work is fast and doesn't need retries, skip the job.

**SRP — if a new class IS needed, does it have one job?**
4. Does the proposed class have a single reason to change?
5. Is it mixing concerns? (e.g., a service that validates, calls an API, AND sends email — split it.)

If an existing file can handle this, say so. If the class mixes concerns, suggest splitting before scaffolding.

## Architecture Detection

Check CLAUDE.md for the architecture pattern, or auto-detect:
- `app/commands/` or `app/queries/` exists → **CQRS**
- `app/services/` exists → **Service Objects**
- Neither → **Standard MVC**

## Scaffolding by Type

### Model
```
app/models/<name>.rb
spec/models/<name>_spec.rb  (or test/models/<name>_test.rb)
db/migrate/TIMESTAMP_create_<table>.rb
```
- Read an existing model first — match the style exactly
- Include validations placeholder and associations placeholder
- Migration with appropriate column types

### Service
```
app/services/<name>.rb      (e.g., app/services/process_payment.rb)
spec/services/<name>_spec.rb
```
- Class with a `.call` class method or `#call` instance method (match project convention)
- Read an existing service first — match the pattern

### Job
```
app/jobs/<name>_job.rb
spec/jobs/<name>_job_spec.rb
```
- Inherit from `ApplicationJob`
- Include `queue_as` with appropriate queue name

### Controller
```
app/controllers/<name>_controller.rb
spec/requests/<name>_spec.rb  (prefer request specs over controller specs)
```
- RESTful actions only (index, show, new, create, edit, update, destroy)
- Strong params method
- Add route to `config/routes.rb`

### CQRS: Command
```
app/commands/<namespace>/<name>.rb
spec/commands/<namespace>/<name>_spec.rb
```
- Read an existing command first — match module nesting, base class, call pattern

### CQRS: Query
```
app/queries/<namespace>/<name>.rb
spec/queries/<namespace>/<name>_spec.rb
```
- Read an existing query first — match the pattern

## Dependency Verification (mandatory)

If this feature requires a new gem:
1. Read the gem's documentation first (`ri <gem>` or WebFetch its docs)
2. Check the latest stable version: `gem search <gem_name> --remote`
3. Use pessimistic constraint: `gem "<name>", "~> X.Y"` — never `*` or unpinned
4. Run `bundle install && {{TEST_COMMAND}}` — full suite, not just the new spec
5. Run `bundle audit check` for security advisories
6. If the gem is an AI/LLM library, prefer `ruby_llm` unless the project already uses another

## After Scaffolding

1. Run the new spec: `{{TEST_COMMAND}} <spec_path>`
2. Run the linter: `bundle exec rubocop <file_path> <spec_path>`
3. Report what was created and any issues
