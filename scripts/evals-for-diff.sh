#!/bin/sh
# The eval cases a change needs, chosen by the change.
#
#   evals-for-diff.sh <base-ref>
#
# Reads `git diff --name-only <base-ref>...HEAD` in the current repository and prints, one a
# line in name order, each eval case whose row in scripts/evals-map.tsv names a path that meets
# a changed file: the file's own path, or a folder (ending in /) that holds it. A diff that
# reaches no case prints nothing and exits 0. `scripts/evals.sh --for-diff <base-ref>` runs
# what this prints.
#
# A held-out case (set `holdout`, the row's second field) is never printed: a run chosen by a
# diff is a tuning run, and a held-out case runs at a release run or on the owner's word (the
# verifier plan's rule 31). When the diff meets one or more, standard error says how many:
# "evals-for-diff: <n> held-out case(s) not listed".
#
# The map names, for each case, its own folder and the plugin files whose text reaches it: the
# skill its prompt invokes, the agent it starts, the rule its fixture installs and the script
# that delivers it, and, for a fixture with a .shipkit/ folder, the briefing and spec-check.sh,
# whose lines the session hook prints there. The hook and the three always-on rules are named
# only by the rules cases and hello; every other case reads them too, which is why the release
# run still runs every case (.shipkit/specs/numbers-as-data/design.md, fifth record). Lint
# check 19 holds the map to the case folders.
#
# Exit status: 0; 2 on usage or when git cannot read the diff. POSIX sh + awk + git.
# Spec: .shipkit/specs/numbers-as-data/ (REQ-20 to REQ-23); .shipkit/specs/misses-to-checks/
# (REQ-17).

ROOT=$(cd "$(dirname "$0")/.." && pwd)
MAP=${EVALS_MAP:-$ROOT/scripts/evals-map.tsv}
[ $# -eq 1 ] && [ -n "$1" ] || { echo "usage: evals-for-diff.sh <base-ref>" >&2; exit 2; }
[ -f "$MAP" ] || { echo "evals-for-diff: no map at $MAP" >&2; exit 2; }
changed=$(git diff --name-only "$1...HEAD" 2>/dev/null) || { echo "evals-for-diff: git cannot read the diff from $1" >&2; exit 2; }
[ -n "$changed" ] || exit 0
printf '%s\n' "$changed" | awk -F '\t' '
  FNR == NR { if ($0 != "") changed[++nc] = $0; next }
  FNR == 1 { next }
  NF >= 3 {
    np = split($3, paths, ",")
    for (i = 1; i <= np; i++) {
      p = paths[i]
      for (k = 1; k <= nc; k++) {
        f = changed[k]
        if (f == p || (p ~ /\/$/ && index(f, p) == 1)) {
          if ($2 == "holdout") held++; else print $1
          next
        }
      }
    }
  }
  END { if (held) print "evals-for-diff: " held " held-out case(s) not listed" | "cat 1>&2" }' - "$MAP" | sort -u
