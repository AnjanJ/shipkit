#!/bin/sh
# Shipkit plugin lint — see scripts/lint.py for what is checked and why.
exec python3 "$(dirname "$0")/lint.py" "$@"
