#!/bin/bash
# The portfolio fixture, as eve/jobs/fixture.sh explains; runs only with --scaffold.
exec python3 "$(cd "$(dirname "$0")" && pwd)/../../fixtures/portfolio-gen/generate.py" --maps "${SHIPKIT_EVAL_MAPS:-3}"
