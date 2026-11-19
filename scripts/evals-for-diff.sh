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
# The map names, for each case, its own folder and the plugin files whose text reaches it: the
# skill its prompt invokes, the agent it starts, the rule its fixture installs and the script
# that delivers it, and, for a fixture with a .shipkit/ folder, the briefing and spec-check.sh,
# whose lines the session hook prints there. The hook and the three always-on rules are named
# only by the rules cases and hello; every other case reads them too, which is why the release
# run still runs every case (.shipkit/specs/numbers-as-data/design.md, fifth record). Lint
# check 19 holds the map to the case folders.
#
# Exit status: 0; 2 on usage or when git cannot read the diff. POSIX sh + awk + git.
# Spec: .shipkit/specs/numbers-as-data/ (REQ-20 to REQ-23).

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
        if (f == p || (p ~ /\/$/ && index(f, p) == 1)) { print $1; next }
      }
    }
  }' - "$MAP" | sort -u
