---
paths:
  - "pyproject.toml"
  - "requirements*.txt"
  - "Pipfile"
  - "setup.py"
  - "setup.cfg"
---
# When Modifying Python Dependencies
- Flexible constraints in `pyproject.toml` (`>=1.0,<2.0`); exact pins in `requirements.txt` for deployment
- Run `pip-audit` for known vulnerabilities
- Detect the package manager from the lockfile — `poetry.lock` → poetry, `uv.lock` → uv,
  `Pipfile.lock` → pipenv, else pip — and use that one; never install outside a virtualenv
