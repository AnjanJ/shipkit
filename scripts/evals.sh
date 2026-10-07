#!/bin/sh
# Run every shipkit eval case (plugins/shipkit/evals/). Real model calls: run before a release,
# not on every push. Extra arguments go to `claude plugin eval`, e.g. `--case hello`.
# Exits non-zero if any case scores below 2 runs out of 3. See plugins/shipkit/evals/README.md.
# `--group <name>` (first argument) runs only the cases named <name>-* — every case is named
# after its folder (rules-trivial, scoped-dependencies, stacks-gemfile), so a group is a name
# prefix; `--group grandfather` also runs grandfather-xl-*. No flag still runs every case (B7).
# The eval cases are Markdown and cannot carry a citation that spec-check counts, so the
# requirements they prove are cited here: measure-and-slim/REQ-1 measure-and-slim/REQ-2
# measure-and-slim/REQ-3 measure-and-slim/REQ-9 measure-and-slim/REQ-10 measure-and-slim/REQ-17
# map-on-trial/REQ-8 (the five grandfather-xl cases scaffold the generated XL fixture)
# rule-evals/REQ-7 rule-evals/REQ-8 (--group)
ROOT=$(cd "$(dirname "$0")/.." && pwd)
if [ "$1" = "--group" ] && [ -n "$2" ]; then G="$2"; shift 2; set -- --case "$G-*" "$@"; fi
exec claude plugin eval "$ROOT/plugins/shipkit" --trust-plugin --ablation none --no-publish \
  --model "${EVALS_MODEL:-sonnet}" --threshold 0.66 \
  --output-dir "${EVALS_OUT:-${TMPDIR:-/tmp}/shipkit-evals}" "$@" --scaffold --allow-tools Bash Write Edit
