#!/bin/bash
# Trap 2 for testing.md: the sample-app shape, committed, with the rule under test
# (lib/with-rule.sh; the hook delivers it — evals/README.md). Runs only with --scaffold.
HERE=$(cd "$(dirname "$0")" && pwd)
cp -R "$HERE/../../fixtures/sample-app/." . || exit 1
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
sh "$HERE/../../lib/with-rule.sh" testing
