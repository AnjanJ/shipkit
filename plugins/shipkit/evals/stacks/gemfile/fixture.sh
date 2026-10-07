#!/bin/bash
# The rails shape from fixtures/stack-gen.sh, committed, with the gemfile.md stack rule under
# test (lib/with-rule.sh; the hook delivers it — evals/README.md). Runs only with --scaffold.
HERE=$(cd "$(dirname "$0")" && pwd)
sh "$HERE/../../fixtures/stack-gen.sh" rails || exit 1
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
sh "$HERE/../../lib/with-rule.sh" gemfile
