#!/bin/bash
# Builds the XL fixture (`ledger`, 224 files, 27 commits) in the run's empty workspace by running
# the generator; runs only when `claude plugin eval` is given --scaffold. SHIPKIT_EVAL_NO_MAP=1
# omits PROJECT_MAP.md — honoured when this script is run by hand (the eval tool does not pass
# the caller's environment to a scaffold; the no-map ARM runs from a scratch copy whose
# scaffolds pass --no-map, see evals/README.md).
flags=""; [ "${SHIPKIT_EVAL_NO_MAP:-}" = "1" ] && flags="--no-map"
exec python3 "$(cd "$(dirname "$0")" && pwd)/../../fixtures/ledger-gen/generate.py" $flags
