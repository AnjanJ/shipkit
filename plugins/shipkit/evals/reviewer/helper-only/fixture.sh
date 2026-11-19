#!/bin/bash
# reviewer/helper-only: REQ-2's test calls a helper that `refund` never calls. Runs only with --scaffold.
bash "$(cd "$(dirname "$0")" && pwd)/../../lib/review-fixture.sh" helper
