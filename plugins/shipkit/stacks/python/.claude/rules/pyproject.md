---
paths:
  - "pyproject.toml"
  - "requirements*.txt"
  - "Pipfile"
  - "setup.py"
  - "setup.cfg"
---
# When Modifying Python Dependencies
- Use flexible constraints in pyproject.toml: `>=1.0,<2.0`
- Pin exact versions in requirements.txt for deployment
- After ANY change: install in virtualenv, run full test suite
- Run `pip-audit` or `safety check` for vulnerability scanning
- Detect package manager: poetry.lock=poetry, uv.lock=uv, Pipfile.lock=pipenv, else pip
- Always use a virtual environment — never install globally
