---
description: "Scaffold a Python module with tests — detects Django, FastAPI, or plain Python"
user-invocable: true
disable-model-invocation: true
argument-hint: "[<type> <Name>, e.g. service PaymentProcessor]"
---

# /new-feature — Scaffold Python Module + Test

Scaffold: $ARGUMENTS

## Before Scaffolding — YAGNI + SRP Gate

**YAGNI — is a new module needed at all?**
1. Could the logic live in an existing module, view, or service?
2. Is a separate service justified? If <10 lines and one call site, a function in the existing module is simpler.
3. Is a Celery task justified? If the work is fast and doesn't need retries, skip the task.

**SRP — if a new module IS needed, does it have one job?**
4. Does the proposed module have a single reason to change?
5. Is it mixing concerns? (e.g., a service that validates, calls an API, AND sends email — split it.)

If an existing file can handle this, say so.

## Framework Detection
!`ls manage.py pyproject.toml requirements.txt setup.py 2>/dev/null`
!`grep -E "django|fastapi|flask" requirements.txt pyproject.toml 2>/dev/null | head -5 || echo "no framework detected"`

Check CLAUDE.md for the framework, or auto-detect:
- `manage.py` exists → **Django**
- `fastapi` in dependencies → **FastAPI**
- `flask` in dependencies → **Flask**
- Neither → **Plain Python**

## Scaffolding by Type

### Django: Model
```
<app>/models/<name>.py
tests/<app>/test_<name>.py
<app>/migrations/XXXX_auto.py (via makemigrations)
```
- Read an existing model first — match the style exactly
- Include field definitions, `__str__`, Meta class if needed

### Django: View/Serializer (DRF)
```
<app>/views/<name>.py
<app>/serializers/<name>.py (if DRF)
tests/<app>/test_<name>.py
```
- Class-based views preferred unless project uses function-based
- Add URL pattern to `urls.py`

### Django: Service
```
<app>/services/<name>.py
tests/<app>/test_<name>.py
```
- Function or class with a `run()` / `execute()` method (match project convention)

### Django: Celery Task
```
<app>/tasks/<name>.py
tests/<app>/test_<name>.py
```
- Inherit from or use `@shared_task` decorator
- Include `bind=True` for retry support
- Set `max_retries` and `default_retry_delay`

### FastAPI: Router/Endpoint
```
app/routers/<name>.py
tests/test_<name>.py
```
- Define Pydantic request/response models
- Use `Depends()` for dependency injection
- Add router to `app/main.py`

### FastAPI: Service
```
app/services/<name>.py
tests/test_<name>.py
```
- Plain class or function — inject via `Depends()`

### Plain Python: Module
```
src/<package>/<name>.py
tests/test_<name>.py
```
- Read an existing module first — match the project's patterns

## Dependency Verification (mandatory)

If this feature requires a new package:
1. Read the package's documentation first (WebFetch its docs or PyPI page)
2. Check the latest stable version: `pip index versions <package>`
3. Use version constraint: `<name>>=X.Y,<X+1` or `~=X.Y` — never unpinned
4. Run `pip install -e . && {{TEST_COMMAND}}` — full suite, not just the new test
5. Run `pip-audit` or `safety check` for security advisories

## After Scaffolding

1. Run the new test: `{{TEST_COMMAND}} <test_path>`
2. Run the linter: `ruff check <file_path> <test_path>` or `flake8 <file_path>`
3. Run type check: `mypy <file_path>` (if project uses mypy)
4. Report what was created and any issues
