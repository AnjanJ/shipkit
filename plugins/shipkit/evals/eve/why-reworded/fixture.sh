#!/bin/bash
# The same portfolio fixture as eve/why (three projects, the registry, maps for the first N);
# runs only with --scaffold. SHIPKIT_EVAL_MAPS=3|1|0 picks the arm when run by hand — see
# eve/why/fixture.sh. This probe runs on the three-map arm: the question is whether the map is
# reached when the question shares no word with its Evolution line (eval-results-4.11.md §3).
exec python3 "$(cd "$(dirname "$0")" && pwd)/../../fixtures/portfolio-gen/generate.py" --maps "${SHIPKIT_EVAL_MAPS:-3}"
