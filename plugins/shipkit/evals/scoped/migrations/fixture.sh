#!/bin/bash
# The rails shape from fixtures/stack-gen.sh (db/migrate/ matches the rule's globs), committed,
# with rules/migrations.md under test (lib/with-rule.sh; the hook delivers it). --scaffold only.
HERE=$(cd "$(dirname "$0")" && pwd)
sh "$HERE/../../fixtures/stack-gen.sh" rails || exit 1
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
sh "$HERE/../../lib/with-rule.sh" migrations
