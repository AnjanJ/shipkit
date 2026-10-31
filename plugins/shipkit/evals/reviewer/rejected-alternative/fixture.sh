#!/bin/bash
# reviewer/rejected-alternative: every requirement met and a gateway failure swallowed, which the record rejected. Runs only with --scaffold.
bash "$(cd "$(dirname "$0")" && pwd)/../../lib/review-fixture.sh" rejected
