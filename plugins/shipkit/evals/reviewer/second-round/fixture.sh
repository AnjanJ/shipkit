#!/bin/bash
# Runs only with --scaffold.
bash "$(cd "$(dirname "$0")" && pwd)/../../lib/review-fixture.sh" round2
