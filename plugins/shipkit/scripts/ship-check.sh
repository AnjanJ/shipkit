#!/bin/sh
# Shipkit ship-check: the ship gate's command steps, run by a command.
#
#   ship-check.sh <project-dir> <slug> [base-ref] [--test '<command>']
#   ship-check.sh --clean <scratch-dir>
#
# /shipkit:ship has eight steps. Five are commands whose result follows from an exit status or
# from their output alone: 1 (spec check, as shipped), 2 (tests), 3 (tasks ticked), 7 (clean
# tree) and 8 (decisions fired). This script runs those five and lists the migration files
# step 5 asks about. Steps 4 and 6, and the judgment in step 5 of whether each migration has a
# rollback written down, stay with whoever runs the gate.
#
# Why a script: a step that a model runs can be skipped, or reported from memory. A command's
# exit status cannot (.shipkit/specs/gate-as-software/design.md, first record).
#
# It makes a scratch directory of its own with mktemp -d, named shipkit-ship.XXXXXX under
# ${TMPDIR:-/tmp}, and prints that path as its first line, so two gates at once never share a
# file. Then one line for each step, "<n> <result>", in the order 1 2 3 5 7 8. Everything else
# is in <scratch-dir>/evidence.md: a first line that names the slug, the commit and the base,
# then a block for each step, written as the ship report writes a step:
#
#   ### 2. Tests
#   `<the exact command>` → exit <N>
#   <the last twenty lines of the command's output>
#   result: PASS — <reason>          (or FAIL — <reason>, or NEEDS-READING — <reason>)
#
# The plugin's location is written <plugin root> in a command, never as a path: the report is
# committed, and one machine's path is noise on every other.
#
#   Step 1  spec-check.sh . <slug> --as-shipped. PASS on exit 0. Under its result line:
#           "evidence: " and spec-check's EVIDENCE line, then "Requirements changed on this
#           branch:" and every line spec-diff.sh printed. Neither changes the result.
#   Step 2  the test command, run once from the project's root: the one given with --test,
#           else the one test-command.sh prints. PASS on exit 0. Neither source: FAIL — no
#           test command known, and nothing is run. It never reads CLAUDE.md for one.
#   Step 3  git grep -n --untracked '^- \[ \]' on the spec's tasks.md. PASS when no line is
#           found (exit 1).
#   Step 5  the migration files in git diff --name-only <base>...HEAD: a changed file under
#           db/migrate/, migrations/, priv/repo/migrations/, alembic/ or prisma/migrations/, or
#           a changed *.sql. None: PASS. Some: NEEDS-READING, and the files are listed.
#   Step 7  git status --porcelain --untracked-files=all, CAPTURED BEFORE ANY STEP RAN: the
#           gate's own test run can leave files behind, and those are not unfinished work. A
#           line that names a report for the same slug under .shipkit/releases/ is set aside;
#           any other line is FAIL. Files that appeared during step 2 are listed as a note.
#   Step 8  decision-check.sh . --run. FAIL when a line of its output starts FIRED. MANUAL and
#           ERROR lines are in the block and do not fail it.
#
# Every step runs, even after one has failed: the report must show the whole picture.
#
# After the last block, one line: "Not run, a suggestion: " and the red-check.sh command for
# the same project, slug and base, with --test when this script was given one. red-check.sh
# shows whether the spec's new tests fail on the tree without the feature. Nothing runs it
# here: it is read by hand until a real run has shown its verdict to be right
# (.shipkit/specs/tests-worth-having/design.md, "run by hand, and every verdict exits 0").
#
# --clean <scratch-dir> removes a scratch directory, and only one this script made: its name
# must fit the template and its evidence.md must start with this script's own first line.
#
# SAFETY: step 2 runs the project's test command and step 8 runs the Fired-if commands of the
# project's decision records, as the gate always has. Both come from the repository you point
# this at. This script is never called from a hook.
#
# Exit status: 0 no step's result is FAIL (NEEDS-READING is not a failure); 1 at least one is,
# or --clean refused; 2 usage, no such spec, not a git repository, or an unknown base ref.
# POSIX sh + awk + git. No model, no network. Spec: .shipkit/specs/gate-as-software/
# (REQ-9 to REQ-23).

usage() {
  echo "usage: ship-check.sh <project-dir> <slug> [base-ref] [--test '<command>']" >&2
  echo "       ship-check.sh --clean <scratch-dir>" >&2
  exit 2
}

MARK="shipkit ship-check: "
HERE=$(cd "$(dirname "$0")" 2>/dev/null && pwd) || exit 2

# --- --clean ---------------------------------------------------------------------------
if [ "${1:-}" = --clean ]; then
  [ $# -eq 2 ] && [ -n "$2" ] || usage
  d=${2%/}
  refuse() { echo "ship-check: not a scratch directory this script made, nothing removed: $d" >&2; exit 1; }
  case "${d##*/}" in shipkit-ship.??????) ;; *) refuse ;; esac
  [ -d "$d" ] && [ ! -L "$d" ] && [ -f "$d/evidence.md" ] || refuse
  case "$(sed -n 1p "$d/evidence.md" 2>/dev/null)" in "$MARK"*) ;; *) refuse ;; esac
  rm -rf "$d" || { echo "ship-check: could not remove $d" >&2; exit 1; }
  exit 0
fi

# --- arguments -------------------------------------------------------------------------
[ $# -ge 2 ] || usage
PROJ=$1; SLUG=$2; shift 2
BASE=""; TESTCMD=""; HAVE_TEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --test) [ $# -ge 2 ] || usage; TESTCMD=$2; HAVE_TEST=1; shift ;;
    --*) usage ;;
    *) [ -z "$BASE" ] || usage; BASE=$1 ;;
  esac
  shift
done
case "$SLUG" in ''|*/*|.*) usage ;; esac
[ "$HAVE_TEST" -eq 0 ] || [ -n "$TESTCMD" ] || usage

cd "$PROJ" 2>/dev/null || { echo "ship-check: no such directory: $PROJ" >&2; exit 2; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo "ship-check: not a git repository: $PROJ" >&2; exit 2; }
SPECDIR=".shipkit/specs/$SLUG"
[ -f "$SPECDIR/spec.md" ] || { echo "ship-check: no spec at $SPECDIR/spec.md" >&2; exit 2; }

if [ -z "$BASE" ]; then
  for b in main master; do
    if git rev-parse --verify -q "$b^{commit}" >/dev/null 2>&1; then
      BASE=$(git merge-base HEAD "$b" 2>/dev/null); break
    fi
  done
fi
[ -n "$BASE" ] && git rev-parse --verify -q "$BASE^{commit}" >/dev/null 2>&1 \
  || { echo "ship-check: unknown base ref: ${BASE:-none given, and no main or master branch}" >&2; exit 2; }

# --- the tree as it is now, before anything runs (step 7 reads this) ---------------------
STATUS_BEFORE=$(git status --porcelain --untracked-files=all 2>/dev/null)

T=${TMPDIR:-/tmp}; T=${T%/}
S=$(mktemp -d "$T/shipkit-ship.XXXXXX" 2>/dev/null) || { echo "ship-check: mktemp failed under $T" >&2; exit 2; }
echo "$S"
EV="$S/evidence.md"
printf '%s%s at %s against %s\n' "$MARK" "$SLUG" \
  "$(git rev-parse --short HEAD 2>/dev/null)" "$(git rev-parse --short "$BASE^{commit}" 2>/dev/null)" > "$EV"
printf '%s\n' "$STATUS_BEFORE" | grep -v '^$' > "$S/status.out"

fail=0
# block <n> <name> <command line, or ""> <file with the output> <words when it is empty> <result> <reason>
block() {
  { printf '\n### %s. %s\n' "$1" "$2"
    [ -z "$3" ] || printf '%s\n' "$3"
    if [ -s "$4" ]; then tail -20 "$4"; else printf '%s\n' "$5"; fi
    printf 'result: %s — %s\n' "$6" "$7"
  } >> "$EV"
  printf '%s %s\n' "$1" "$6"
  [ "$6" != FAIL ] || fail=1
}

# --- step 1: spec check, as shipped ------------------------------------------------------
sh "$HERE/spec-check.sh" . "$SLUG" --as-shipped > "$S/spec-check.out" 2>&1; rc=$?
if [ "$rc" -eq 0 ]; then r=PASS; else r=FAIL; fi
block 1 "Spec check, as shipped" "\`sh <plugin root>/scripts/spec-check.sh . $SLUG --as-shipped\` → exit $rc" \
  "$S/spec-check.out" "(no output)" "$r" "exit $rc"
ev_line=$(grep '^EVIDENCE ' "$S/spec-check.out" 2>/dev/null | sed -n 1p)
sh "$HERE/spec-diff.sh" . "$SLUG" "$BASE" > "$S/spec-diff.out" 2>&1
{ printf 'evidence: %s\n' "${ev_line:-none printed}"
  echo "Requirements changed on this branch:"
  if [ -s "$S/spec-diff.out" ]; then cat "$S/spec-diff.out"; else echo "none"; fi
} >> "$EV"

# --- step 2: tests -----------------------------------------------------------------------
if [ "$HAVE_TEST" -eq 0 ]; then TESTCMD=$(sh "$HERE/test-command.sh" . 2>/dev/null); fi
if [ -z "$TESTCMD" ]; then
  : > "$S/tests.out"
  block 2 "Tests" "" "$S/tests.out" "(no command was run)" FAIL "no test command known"
else
  ( sh -c "$TESTCMD" ) > "$S/tests.out" 2>&1 </dev/null; rc=$?
  if [ "$rc" -eq 0 ]; then r=PASS; else r=FAIL; fi
  block 2 "Tests" "\`$TESTCMD\` → exit $rc" "$S/tests.out" "(no output)" "$r" "exit $rc"
fi
# what the test run left behind, for the note under step 7
git status --porcelain --untracked-files=all 2>/dev/null | grep -v '^$' > "$S/status-after.out"

# --- step 3: tasks ticked ----------------------------------------------------------------
if [ -f "$SPECDIR/tasks.md" ]; then
  git grep -n --untracked '^- \[ \]' -- "$SPECDIR/tasks.md" > "$S/tasks.out" 2>&1; rc=$?
  case "$rc" in
    1) r=PASS; why="no task is unticked" ;;
    0) r=FAIL; why="$(grep -c . "$S/tasks.out") task(s) not ticked" ;;
    *) r=FAIL; why="git grep exit $rc" ;;
  esac
  block 3 "Tasks ticked" "\`git grep -n --untracked '^- \\[ \\]' $SPECDIR/tasks.md\` → exit $rc" \
    "$S/tasks.out" "no line found" "$r" "$why"
else
  : > "$S/tasks.out"
  block 3 "Tasks ticked" "" "$S/tasks.out" "(no command was run)" FAIL "no $SPECDIR/tasks.md"
fi

# --- step 5: the migration files, for a person to read -------------------------------------
git diff --name-only "$BASE"...HEAD > "$S/diff.out" 2>/dev/null; rc=$?
awk '/(^|\/)db\/migrate\// || /(^|\/)migrations\// || /(^|\/)alembic\// || /\.sql$/' "$S/diff.out" > "$S/migrations.out"
n=$(grep -c . "$S/migrations.out")
if [ "$rc" -ne 0 ]; then r=FAIL; why="git diff exit $rc"
elif [ "$n" -eq 0 ]; then r=PASS; why="no migration in the diff"
else r=NEEDS-READING; why="$n migration file(s): is the way to roll each one back written down?"; fi
block 5 "Migration rollback" "\`git diff --name-only $BASE...HEAD\` → exit $rc" \
  "$S/migrations.out" "no migration in the diff" "$r" "$why"

# --- step 7: the tree, as captured before step 1 -------------------------------------------
# A porcelain line is two status letters, a space and the path. A report for this slug is
# .shipkit/releases/<YYYY-MM-DD>-<slug>.md; a renamed path ("a -> b") never matches, on purpose.
awk -v slug="$SLUG" '
  { p = substr($0, 4)
    rep = ".shipkit/releases/"
    if (substr(p, 1, length(rep)) == rep) {
      f = substr(p, length(rep) + 1)
      if (f ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-/ && substr(f, 12) == slug ".md") next
    }
    print }' "$S/status.out" > "$S/status-left.out"
n=$(grep -c . "$S/status-left.out")
if [ "$n" -eq 0 ]; then
  r=PASS
  if [ -s "$S/status.out" ]; then why="nothing uncommitted but an earlier report for this slug"; else why="nothing uncommitted"; fi
else r=FAIL; why="$n uncommitted path(s)"; fi
block 7 "Clean tree" "\`git status --porcelain --untracked-files=all\`, captured before step 1" \
  "$S/status.out" "empty" "$r" "$why"
if [ -s "$S/status.out" ]; then grep -F -x -v -f "$S/status.out" "$S/status-after.out" > "$S/status-new.out" 2>/dev/null
else cp "$S/status-after.out" "$S/status-new.out"; fi
if [ -s "$S/status-new.out" ]; then
  { echo "note: step 2's own run left these behind; they do not count against the tree:"
    sed -n '1,20p' "$S/status-new.out"; } >> "$EV"
fi

# --- step 8: decisions fired ---------------------------------------------------------------
sh "$HERE/decision-check.sh" . --run > "$S/decisions.out" 2>&1; rc=$?
n=$(grep -c '^FIRED' "$S/decisions.out")
if [ "$n" -gt 0 ]; then r=FAIL; why="$n decision(s) fired; the first: $(grep '^FIRED' "$S/decisions.out" | sed -n 1p | cut -c1-200)"
else r=PASS; why="no FIRED line"; fi
block 8 "Decisions fired" "\`sh <plugin root>/scripts/decision-check.sh . --run\` → exit $rc" \
  "$S/decisions.out" "(no output)" "$r" "$why"

# --- not a step: the red-check.sh command, named and not run ------------------------------
# One line after the last block. It starts with neither "### " nor "result:", so the blocks
# are counted as before, and standard output is not touched. A test command is written inside
# single quotes, with a quote of its own as '\'', so that the line can be pasted.
sug="Not run, a suggestion: sh \"<plugin root>/scripts/red-check.sh\" . $SLUG $BASE"
if [ "$HAVE_TEST" -eq 1 ]; then
  sug="$sug --test '$(printf '%s' "$TESTCMD" | sed "s/'/'\\\\''/g")'"
fi
printf '\n%s\n' "$sug" >> "$EV"

exit $fail
