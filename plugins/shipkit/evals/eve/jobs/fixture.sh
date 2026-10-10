#!/bin/bash
# Builds the portfolio fixture (three projects under projects/, the registry under shipkit-home/,
# maps for the first N projects) in the run's empty workspace; runs only with --scaffold.
# SHIPKIT_EVAL_MAPS=3|1|0 picks the arm when run by hand (the eval tool passes no environment to
# a scaffold; the one-map and no-map ARMS run from scratch copies whose default below is edited —
# see evals/README.md and docs/design/eval-results-4.9.md).
exec python3 "$(cd "$(dirname "$0")" && pwd)/../../fixtures/portfolio-gen/generate.py" --maps "${SHIPKIT_EVAL_MAPS:-3}"
