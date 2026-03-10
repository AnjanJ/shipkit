---
description: "Pre-deployment checklist — tests, security, migrations, env vars"
user-invocable: true
disable-model-invocation: true
---

# /deploy-check — Pre-Deployment Checklist

Run through all checks before deploying. Stop on any FAIL.

## Current State
!`git log --oneline -5 2>/dev/null || echo "no git history"`
!`bin/rails db:migrate:status 2>/dev/null | tail -5 || echo "no Rails migration status available"`

## Checks (in order)

### 1. Pending Migrations
```bash
bin/rails db:migrate:status | grep "down"
```
- PASS: No pending migrations
- FAIL: Pending migrations found — run `bin/rails db:migrate` first

### 2. Security Scan
```bash
bundle exec brakeman --no-pager -q
```
- PASS: No warnings
- WARN: Low-confidence warnings — review manually
- FAIL: High-confidence warnings — fix before deploying

### 3. Dependency Audit
```bash
bundle audit check --update
```
- PASS: No known vulnerabilities
- FAIL: Vulnerable gems found — update or acknowledge

### 4. Test Suite
```bash
{{TEST_COMMAND}}
```
- PASS: All tests green
- FAIL: Failing tests — fix before deploying

### 5. Seed Validation (if applicable)
```bash
bin/rails db:seed RAILS_ENV=test 2>&1 | tail -5
```
- PASS: Seeds run without error
- SKIP: No seed file or not applicable

### 6. Asset Compilation
```bash
bin/rails assets:precompile RAILS_ENV=production 2>&1 | tail -5
```
- PASS: Assets compile successfully
- FAIL: Asset compilation error — fix before deploying
- SKIP: API-only app

### 7. Environment Variables
Check that all required env vars referenced in code are set:
```bash
grep -r "ENV\[" app/ config/ --include="*.rb" -h | sort -u
```
- PASS: All env vars documented and set
- WARN: New env vars found — verify they're configured in production

## Report

| # | Check | Status | Details |
|---|-------|--------|---------|
| 1 | Pending Migrations | PASS | None |
| 2 | Security Scan | PASS | 0 warnings |
| 3 | Dependency Audit | PASS | 0 vulnerabilities |
| 4 | Test Suite | PASS | 935 tests, 0 failures |
| 5 | Seed Validation | PASS | Seeds loaded |
| 6 | Asset Compilation | PASS | Compiled |
| 7 | Environment Variables | PASS | All set |

**Verdict:** READY TO DEPLOY / BLOCKED (fix issues above)
