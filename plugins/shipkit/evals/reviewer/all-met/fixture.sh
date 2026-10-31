#!/bin/bash
# reviewer/all-met: every requirement satisfied. Runs only with --scaffold.
bash "$(cd "$(dirname "$0")" && pwd)/../../lib/review-fixture.sh" complete
