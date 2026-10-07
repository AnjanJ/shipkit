#!/bin/bash
# The static shape from fixtures/stack-gen.sh (index.html with a recent-orders list), committed,
# with rules/ui-ux.md under test (lib/with-rule.sh; the hook delivers it). --scaffold only.
HERE=$(cd "$(dirname "$0")" && pwd)
sh "$HERE/../../fixtures/stack-gen.sh" static || exit 1
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
sh "$HERE/../../lib/with-rule.sh" ui-ux
