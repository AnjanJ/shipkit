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
# rule-evals/REQ-7 rule-evals/REQ-8 (--group) rule-evals/REQ-10 rule-evals/REQ-11 (the five
# scoped and thirteen stacks cases install their rule through evals/lib/with-rule.sh)
# run-wounds/REQ-6 (intake-answered: a question a repository file answers is not asked)
# second-traps/REQ-4 second-traps/REQ-5 (the sixteen trap2-* cases: each rule file's second named
# line, run with the rule; the without arm is a scratch copy — docs/design/eval-results-4.6.md)
# second-traps/REQ-8 (stacks-gemfile, 3 of 3 on the reworded lock-diff line)
# measured-cuts/REQ-1 measured-cuts/REQ-2 (the fourteen trap-1 and trap-2 cases of the seven cut
# files are the watch: unchanged, run on the trimmed file — docs/design/eval-results-4.8.md)
# portfolio-run/REQ-7 (the three eve-* cases scaffold the generated portfolio fixture with three
# maps; the one-map and no-map arms are scratch copies — docs/design/eval-results-4.9.md)
# graders-and-eve/REQ-1 (eve-payments: a manifest or the handling file is the cited evidence —
# docs/design/eval-results-4.11.md); graders-and-eve/REQ-6 (eve-why-reworded: the why asked in
# words pulse's map Evolution line does not hold — map_read is the number, §3 of the same)
ROOT=$(cd "$(dirname "$0")/.." && pwd)
if [ "$1" = "--group" ] && [ -n "$2" ]; then G="$2"; shift 2; set -- --case "$G-*" "$@"; fi
exec claude plugin eval "$ROOT/plugins/shipkit" --trust-plugin --ablation none --no-publish \
  --model "${EVALS_MODEL:-sonnet}" --threshold 0.66 \
  --output-dir "${EVALS_OUT:-${TMPDIR:-/tmp}/shipkit-evals}" "$@" --scaffold --allow-tools Bash Write Edit
