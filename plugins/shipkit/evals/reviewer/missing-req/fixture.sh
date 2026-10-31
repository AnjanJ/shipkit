#!/bin/bash
# reviewer/missing-req: REQ-2 has no code and no test. Runs only with --scaffold.
bash "$(cd "$(dirname "$0")" && pwd)/../../lib/review-fixture.sh" missing
