---
description: "Audit staged changes for Rails security issues, N+1 queries, unsafe migrations"
user-invocable: true
argument-hint: "[<file-path>|all]"
---

# /safety-check — Rails Safety Audit

Audit code changes for common Rails security and safety issues.

## Changed Files
!`git diff --cached --name-only 2>/dev/null || git diff --name-only HEAD~1 2>/dev/null || echo "no changes detected"`

## Process

1. **Get the diff:** If `$ARGUMENTS` is a file path, read that file. Otherwise: `git diff --cached` (staged) or `git diff` (all changes)
2. **Audit each changed file** against the checklist below
3. **Report findings** with severity levels

## Safety Checklist

### Database Safety
- [ ] **N+1 queries** — associations accessed in loops without `includes`/`preload`
- [ ] **Unbounded queries** — `Model.all` or `where()` without `.limit()` in controllers/APIs
- [ ] **Missing indexes** — new `where`/`find_by` columns without corresponding migration index
- [ ] **Unsafe migrations** — removing columns, renaming tables, changing column types on large tables
- [ ] **Missing `disable_ddl_transaction!`** — for concurrent index creation on large tables

### Security
- [ ] **SQL injection** — raw SQL with string interpolation (`where("name = '#{params[:name]}'")`)
- [ ] **XSS** — `raw()` or `html_safe` on user input in views
- [ ] **CSRF** — `skip_before_action :verify_authenticity_token` without good reason
- [ ] **Mass assignment** — missing strong params, or `permit!` used
- [ ] **Secrets in code** — API keys, passwords, tokens hardcoded (not in credentials/env)
- [ ] **Missing authentication** — controller actions without `before_action :authenticate`
- [ ] **Missing authorization** — accessing records without scoping to current user

### Data Integrity
- [ ] **Missing validations** — new model attributes without presence/format/uniqueness validations
- [ ] **Missing null constraints** — migrations adding columns without `null: false` where appropriate
- [ ] **Missing foreign keys** — `references` without `foreign_key: true`
- [ ] **Orphan records** — `has_many` without `dependent:` option

### Error Handling
- [ ] **Silent failures** — empty `rescue` blocks
- [ ] **Bare rescue** — `rescue => e` catching everything (should rescue specific errors)
- [ ] **Missing error handling** — external API calls without timeout/rescue

### Performance
- [ ] **Expensive callbacks** — `after_save`/`after_create` doing heavy work (use jobs instead)
- [ ] **Synchronous external calls** — HTTP requests in the request cycle (use background jobs)
- [ ] **Missing pagination** — index actions returning unbounded collections

## Report

| # | Severity | Category | File:Line | Issue | Fix |
|---|----------|----------|-----------|-------|-----|
| 1 | BLOCKER | Security | app/controllers/api/users_controller.rb:23 | SQL injection via string interpolation | Use parameterized query |
| ... | ... | ... | ... | ... | ... |

**Verdict:** SAFE / NEEDS FIXES / BLOCKED

- **SAFE** — no issues found
- **NEEDS FIXES** — minor/major issues, can proceed after fixing
- **BLOCKED** — blocker found, must fix before merge

## After Fixes

If issues were found and fixed:
1. Run the full test suite: `{{TEST_COMMAND}}`
2. Run security audit: `bundle audit check`
3. Re-run this safety check on the fixed files to confirm resolution
