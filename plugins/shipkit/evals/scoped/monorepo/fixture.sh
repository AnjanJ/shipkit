#!/bin/bash
# The monorepo shape from fixtures/stack-gen.sh (pnpm-workspace.yaml, turbo.json; one shared
# package, two apps that consume it), committed, with rules/monorepo.md under test. --scaffold only.
HERE=$(cd "$(dirname "$0")" && pwd)
sh "$HERE/../../fixtures/stack-gen.sh" monorepo || exit 1
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
sh "$HERE/../../lib/with-rule.sh" monorepo
