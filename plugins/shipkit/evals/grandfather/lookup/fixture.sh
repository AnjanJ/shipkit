#!/bin/bash
# Copies the shared fixture into the run's empty workspace and makes it a git repository.
# Runs only when `claude plugin eval` is given --scaffold (scripts/evals.sh passes it).
cp -R "$(cd "$(dirname "$0")" && pwd)/../../fixtures/sample-app/." . || exit 1
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
