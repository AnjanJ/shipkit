#!/bin/sh
# Shipkit plugin lint — see scripts/lint.py for what is checked and why.
# Uses uv (with PyYAML) when available so frontmatter is fully parsed; falls back
# to the system python3 in structural mode otherwise.
if command -v uv >/dev/null 2>&1; then
  exec uv run --quiet --with pyyaml python3 "$(dirname "$0")/lint.py" "$@"
fi
exec python3 "$(dirname "$0")/lint.py" "$@"
