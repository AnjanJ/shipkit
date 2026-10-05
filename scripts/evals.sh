#!/bin/sh
# Run every shipkit eval case (plugins/shipkit/evals/). Real model calls: run before a release,
# not on every push. Extra arguments go to `claude plugin eval`, e.g. `--case hello`.
# Exits non-zero if any case scores below 2 runs out of 3. See plugins/shipkit/evals/README.md.
ROOT=$(cd "$(dirname "$0")/.." && pwd)
exec claude plugin eval "$ROOT/plugins/shipkit" --trust-plugin --ablation none --no-publish \
  --model "${EVALS_MODEL:-sonnet}" --threshold 0.66 \
  --output-dir "${EVALS_OUT:-${TMPDIR:-/tmp}/shipkit-evals}" "$@" --scaffold --allow-tools Bash
