#!/bin/bash
# holdout/reviewer-helper-only: REQ-1's test calls a helper that `export_notes` never calls. Runs only with --scaffold.
bash "$(cd "$(dirname "$0")" && pwd)/../../lib/review-fixture.sh" notes-helper
