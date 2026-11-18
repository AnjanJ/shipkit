#!/bin/sh
# The eval ledger: one row per case per eval run, in docs/design/eval-ledger.tsv.
#
#   evals-ledger.sh append <dir> [--commit <sha>] [--source <word>]
#   evals-ledger.sh --below-full <n>
#   evals-ledger.sh --rate <case> [--last <k>]
#   evals-ledger.sh --runs [--last <k>] [--prefix <p>]
#
# append reads <dir>/aggregate-result.json, which `claude plugin eval --output-dir <dir>` writes,
# and adds one row for each case: date, version, commit, claude, model, case, set, passed,
# runs, threshold, cost, source (tab-separated). set is `watch` for a case run five times and
# `tune` otherwise; cost sums the case's runs. The commit is --commit, else HEAD; the source is
# --source, else `run`. A row whose date, commit and case the ledger already holds is not added
# again. It prints "evals-ledger: <a> row(s) added, <s> already held".
#
# An eval run is the rows that share a date and a commit. A release run is one whose rows are
# not marked `partial` (evals.sh marks a run of some cases that way). The three queries read
# release runs only, oldest first, in the order they were appended:
#   --below-full <n>   each case below full score in every one of the last n release runs, in
#                      name order; a case missing from one of them is not printed, and nothing is
#                      printed when the ledger holds fewer than n release runs
#   --rate <case>      "<case> <passed>/<runs> over <m> run(s)", over the last k runs (all
#                      when --last is not given)
#   --runs             "<date> <commit> <cases> <passed>/<runs> <cost>" for each run, over the
#                      cases whose name starts with --prefix; cost is `-` when one is unknown
#
# EVALS_LEDGER names another ledger (the smoke checks use a scratch one). append needs
# python3, to read JSON; the queries need sh and awk only, since Fired-if commands run them.
# Exit status: 0; 1 when append finds no result file or cannot write; 2 on usage.
# Spec: .shipkit/specs/numbers-as-data/ (REQ-1 to REQ-7, REQ-33).

ROOT=$(cd "$(dirname "$0")/.." && pwd)
LEDGER=${EVALS_LEDGER:-$ROOT/docs/design/eval-ledger.tsv}
HEADER='date	version	commit	claude	model	case	set	passed	runs	threshold	cost	source'
usage() {
  echo "usage: evals-ledger.sh append <dir> [--commit <sha>] [--source <word>]" >&2
  echo "       evals-ledger.sh --below-full <n> | --rate <case> [--last <k>] | --runs [--last <k>] [--prefix <p>]" >&2
  exit 2
}
num() { case "$1" in ''|*[!0-9]*) usage ;; esac; }

[ $# -ge 1 ] || usage

if [ "$1" = append ]; then
  [ $# -ge 2 ] || usage
  DIR=$2; shift 2; COMMIT=""; SOURCE=run
  while [ $# -gt 0 ]; do
    case "$1" in
      --commit) [ $# -ge 2 ] && [ -n "$2" ] || usage; COMMIT=$2; shift ;;
      --source) [ $# -ge 2 ] && [ -n "$2" ] || usage; SOURCE=$2; shift ;;
      *) usage ;;
    esac
    shift
  done
  RES="${DIR%/}/aggregate-result.json"
  [ -f "$RES" ] || { echo "evals-ledger: no result file in $DIR" >&2; exit 1; }
  [ -n "$COMMIT" ] || COMMIT=$(git rev-parse --short HEAD 2>/dev/null) || COMMIT=-
  [ -n "$COMMIT" ] || COMMIT=-
  if [ ! -s "$LEDGER" ]; then
    mkdir -p "$(dirname "$LEDGER")" && printf '%s\n' "$HEADER" > "$LEDGER" \
      || { echo "evals-ledger: cannot write $LEDGER" >&2; exit 1; }
  fi
  python3 -I - "$RES" "$LEDGER" "$COMMIT" "$SOURCE" <<'PY'
import json, sys
res, ledger, commit, source = sys.argv[1:5]
d = json.load(open(res))
suite = d.get("suite") or {}
version = next((p.get("version") for p in suite.get("plugins") or [] if p.get("name") == "shipkit"), None)
f = lambda v: "-" if v in (None, "") else str(v)
date = f((d.get("startedAt") or "")[:10])
held = set()
for line in open(ledger).read().splitlines()[1:]:
    c = line.split("\t")
    if len(c) == 12:
        held.add((c[0], c[2], c[5]))
added = skipped = 0
rows = []
for case in d.get("cases") or []:
    name = case.get("name")
    if not name:
        continue
    key = (date, commit, name)
    if key in held:
        skipped += 1
        continue
    runs = (case.get("arms") or {}).get("with") or []
    passed = sum(1 for r in runs if r.get("passed"))
    costs = [r.get("costUsd") for r in runs]
    cost = "-" if (not runs or any(c is None for c in costs)) else "%.2f" % sum(costs)
    per = case.get("runsPerCase") or len(runs)
    rows.append("\t".join([date, f(version), commit, f(d.get("claudeVersion")), f(suite.get("modelOverride")),
                           name, "watch" if per == 5 else "tune", str(passed), str(len(runs)),
                           f(suite.get("threshold")), cost, source]))
    held.add(key)
    added += 1
with open(ledger, "a") as out:
    for r in rows:
        out.write(r + "\n")
print("evals-ledger: %d row(s) added, %d already held" % (added, skipped))
PY
  exit $?
fi

# --- the queries: sh and awk only -----------------------------------------------------------
MODE=$1; shift
ARG=""; LAST=0; PREFIX=""
case "$MODE" in
  --below-full) [ $# -ge 1 ] || usage; num "$1"; ARG=$1; shift ;;
  --rate) [ $# -ge 1 ] && [ -n "$1" ] || usage; ARG=$1; shift ;;
  --runs) ;;
  *) usage ;;
esac
while [ $# -gt 0 ]; do
  case "$1" in
    --last) [ "$MODE" != --below-full ] && [ $# -ge 2 ] || usage; num "$2"; LAST=$2; shift ;;
    --prefix) [ "$MODE" = --runs ] && [ $# -ge 2 ] || usage; PREFIX=$2; shift ;;
    *) usage ;;
  esac
  shift
done
[ -f "$LEDGER" ] || exit 0

awk -F '\t' -v mode="$MODE" -v arg="$ARG" -v last="$LAST" -v prefix="$PREFIX" '
  NR == 1 || NF != 12 || $12 == "partial" { next }
  {
    id = $1 SUBSEP $3
    if (!(id in seen)) { seen[id] = 1; order[++nr] = id; rdate[id] = $1; rcommit[id] = $3 }
    p[id, $6] = $8; r[id, $6] = $9; c[id, $6] = $11; has[id, $6] = 1
    if (!($6 in known)) { known[$6] = 1; cases[++nc] = $6 }
  }
  END {
    if (mode == "--below-full") {
      if (arg + 0 < 1 || nr < arg + 0) exit
      for (k = 1; k <= nc; k++) {
        name = cases[k]; all = 1
        for (i = nr - arg + 1; i <= nr; i++) {
          id = order[i]
          if (!has[id, name] || p[id, name] + 0 >= r[id, name] + 0) { all = 0; break }
        }
        if (all) print name
      }
      exit
    }
    from = (last + 0 > 0 && last + 0 < nr) ? nr - last + 1 : 1
    if (mode == "--rate") {
      sp = sr = m = 0
      for (i = from; i <= nr; i++) { id = order[i]; if (has[id, arg]) { sp += p[id, arg]; sr += r[id, arg]; m++ } }
      printf "%s %d/%d over %d run(s)\n", arg, sp, sr, m
      exit
    }
    for (i = from; i <= nr; i++) {
      id = order[i]; n = sp = sr = 0; cost = 0; unknown = 0
      for (k = 1; k <= nc; k++) {
        name = cases[k]
        if (!has[id, name] || index(name, prefix) != 1) continue
        n++; sp += p[id, name]; sr += r[id, name]
        if (c[id, name] == "-") unknown = 1; else cost += c[id, name]
      }
      printf "%s %s %d %d/%d %s\n", rdate[id], rcommit[id], n, sp, sr, (unknown ? "-" : sprintf("%.2f", cost))
    }
  }' "$LEDGER" | { if [ "$MODE" = --below-full ]; then sort; else cat; fi; }
