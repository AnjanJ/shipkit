#!/bin/sh
# Shipkit red-check: does a test that cites a spec fail on the tree without the feature?
#
#   red-check.sh <project-dir> <slug> <base-ref> [--test '<command>'] [--link <dir>[,<dir>...]]
#
# A test that passes before the feature exists proves nothing about the feature. This script
# shows which it is. It lists the test files that cite the spec and differ from the base ref,
# makes a scratch worktree of the base ref outside the project, and runs the project's test
# command there twice: once as the base has it, and once with the listed files copied in.
#
# Standard output: one "TEST <file>" line for each listed file, in path order, then one line:
#
#   RED-AT-BASE               with the new tests the suite fails on the base tree: at least
#                             one of them needs the feature. One suite run for all the files:
#                             a file whose tests pass at the base can hide behind one that fails
#   GREEN-AT-BASE <files>     the suite passes with them: none of them needs the feature
#   BASE-NOT-RUNNABLE         the suite fails on the base tree as it is, so nothing is judged
#                             (untracked folders it needs, such as deps or node_modules, are
#                             not there: name them with --link)
#   NO-TESTS                  no citing test file differs from the base ref; nothing was run
#
# The two runs' own output goes to standard error.
#
# Which files: the search spec-check.sh makes, kept in step with it by smoke check 126. Any
# file that holds "<slug>/REQ-N" for a requirement the spec has, tracked or not, outside
# .shipkit/ and docs/ and not Markdown; under the spec's "> Tests:" paths when it has that
# line. Of those, the ones whose content is not the base ref's, committed or not.
#
#   --test   the test command. Without it, the one test-command.sh prints (what setup recorded).
#            Neither: exit 2. It is run with sh -c, in the scratch tree, standard input empty.
#   --link   folders of the project that git does not track, comma-separated. Each is linked
#            into the scratch tree at the same path. A LINKED FOLDER IS SHARED: a suite that
#            writes there (a build of the base's code into _build) writes into the project.
#            Point this script at a clone when the suite does. Nothing is linked by default.
#
# The project's files, index, branches, stash and HEAD are not touched. The worktree and the
# directory it is in are removed on every way out, an interrupt included; nothing else is.
# The project directory is the top of its repository.
#
# Exit status: 0 one of the four words was printed, whichever it is: this is a reading, not a
# gate. 2 wrong usage, not the top of a git repository, an unknown base ref, no such spec, no
# test command, or a --link name that is not an untracked folder; no word is printed then.
# 130 stopped by a signal. POSIX sh + awk + git. No model, no network.
# Spec: .shipkit/specs/tests-worth-having/ (REQ-32 to REQ-42).

usage() {
  echo "usage: red-check.sh <project-dir> <slug> <base-ref> [--test '<command>'] [--link <dir>[,<dir>...]]" >&2
  exit 2
}
die() { echo "red-check: $1" >&2; exit 2; }

HERE=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
PROJ=""; SLUG=""; BASE=""; TESTCMD=""; LINKS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --test) [ $# -ge 2 ] || usage; TESTCMD=$2; shift 2 ;;
    --link) [ $# -ge 2 ] || usage; LINKS=$2; shift 2 ;;
    -*) usage ;;
    *)
      if [ -z "$PROJ" ]; then PROJ=$1
      elif [ -z "$SLUG" ]; then SLUG=$1
      elif [ -z "$BASE" ]; then BASE=$1
      else usage; fi
      shift ;;
  esac
done
[ -n "$PROJ" ] && [ -n "$SLUG" ] && [ -n "$BASE" ] || usage

cd "$PROJ" 2>/dev/null || die "no such directory: $PROJ"
PROJ=$(pwd -P)
[ "$(git rev-parse --show-toplevel 2>/dev/null)" = "$PROJ" ] || die "not the top of a git repository: $PROJ"
git rev-parse -q --verify "$BASE^{commit}" >/dev/null 2>&1 || die "unknown base ref: $BASE"
SPEC=".shipkit/specs/$SLUG/spec.md"
[ -f "$SPEC" ] || die "no spec at $SPEC"
[ -n "$TESTCMD" ] || TESTCMD=$(sh "$HERE/test-command.sh" . 2>/dev/null)
[ -n "$TESTCMD" ] || die "no test command: none is recorded (run /shipkit:setup), and no --test was given"

NL='
'
# --link: each name is a folder of the project, and nothing git tracks at the base ref.
links=""
old_ifs=$IFS; IFS=,
for l in $LINKS; do
  IFS=$old_ifs
  l=${l%/}
  [ -n "$l" ] || continue
  case "/$l/" in /*/../*|//*) die "--link takes a folder inside the project: $l" ;; esac
  [ -d "$l" ] && [ ! -L "$l" ] || die "--link: not a folder of the project: $l"
  [ -z "$(git ls-tree -r --name-only "$BASE" -- "$l" 2>/dev/null | sed -n 1p)" ] \
    || die "--link: git tracks $l at $BASE, so the scratch tree has its own"
  links="$links$l$NL"
done
IFS=$old_ifs

# The citing test files: spec-check.sh's search (its collect_cites, under() and tests_filter).
tests=$(sed -n 's/^> *Tests: *//p' "$SPEC" | sed -n 1p | tr ',' '\n' | sed 's/`//g; s/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$')
only=0; grep -q '^> *Tests:' "$SPEC" && only=1
reqs=$(awk '/\*\*REQ-[0-9]+/ { match($0, /\*\*REQ-[0-9]+/); printf " %s", substr($0, RSTART + 6, RLENGTH - 6) } END { print " " }' "$SPEC")
citing=$(git grep -n -I -o --untracked -E -e '[A-Za-z0-9._-]+/REQ-[0-9]+' -- . \
    ':(exclude).shipkit' ':(exclude)docs' ':(exclude)*.md' 2>/dev/null \
  | awk -F: 'NF >= 3 { f = $1; for (i = 2; i <= NF - 2; i++) f = f ":" $i; print f "\t" $NF }' \
  | RC_TESTS="$tests" awk -F '\t' -v slug="$SLUG" -v only="$only" -v reqs="$reqs" '
      function under(f,   i, q) {
        for (i = 1; i <= np; i++) {
          if (paths[i] == "") continue
          if (f == paths[i]) return 1
          q = paths[i]; if (q !~ /\/$/) q = q "/"
          if (index(f, q) == 1) return 1
        }
        return 0
      }
      BEGIN { np = split(ENVIRON["RC_TESTS"], paths, "\n"); pre = slug "/REQ-" }
      index($2, pre) == 1 {
        n = substr($2, length(pre) + 1)
        if (n ~ /^[0-9]+$/ && index(reqs, " " n " ") && (only == 0 || under($1))) print $1
      }' \
  | sort -u)

# Of those, the files that differ from the base ref: not there at the base, or not the same.
listed=""
old_ifs=$IFS; IFS=$NL
for f in $citing; do
  IFS=$old_ifs
  [ -f "$f" ] || continue
  if ! git cat-file -e "$BASE:./$f" 2>/dev/null || ! git diff --quiet "$BASE" -- "$f" 2>/dev/null; then
    listed="$listed$f$NL"
    printf 'TEST %s\n' "$f"
  fi
done
IFS=$old_ifs
if [ -z "$listed" ]; then echo "NO-TESTS"; exit 0; fi

# The scratch tree. Everything from here on is removed on every way out.
D=$(mktemp -d "${TMPDIR:-/tmp}/shipkit-red.XXXXXX" 2>/dev/null) || die "mktemp failed under ${TMPDIR:-/tmp}"
WT="$D/tree"; child=""
cleanup() {
  if [ -n "$child" ]; then kill "$child" 2>/dev/null; wait "$child" 2>/dev/null; fi
  old_ifs=$IFS; IFS=$NL
  for l in $links; do rm -f "$WT/$l" 2>/dev/null; done   # the link, never what it points to
  IFS=$old_ifs
  git -C "$PROJ" worktree remove --force "$WT" >/dev/null 2>&1
  rm -rf "$D"
}
trap cleanup EXIT
trap 'exit 130' INT TERM HUP
git worktree add -q --detach "$WT" "$BASE" >/dev/null 2>&1 || die "could not make a worktree of $BASE"

old_ifs=$IFS; IFS=$NL
for l in $links; do
  IFS=$old_ifs
  mkdir -p "$(dirname "$WT/$l")" && ln -s "$PROJ/$l" "$WT/$l" || die "could not link $l into the scratch tree"
done
IFS=$old_ifs

# The suite runs as a child this script waits for, so that a signal reaches the script while
# the suite is still running; the script then stops the child and removes what it made.
suite() {
  ( cd "$WT" && exec sh -c "$TESTCMD" ) </dev/null >&2 &
  child=$!
  wait "$child"; suite_rc=$?
  child=""
  return "$suite_rc"
}

echo "red-check: the suite on $BASE as it is" >&2
if ! suite; then echo "BASE-NOT-RUNNABLE"; exit 0; fi

old_ifs=$IFS; IFS=$NL
for f in $listed; do
  IFS=$old_ifs
  mkdir -p "$(dirname "$WT/$f")" && cp "$f" "$WT/$f" || die "could not copy $f into the scratch tree"
done
IFS=$old_ifs
echo "red-check: the suite on $BASE with the listed tests" >&2
if suite; then
  printf 'GREEN-AT-BASE %s\n' "$(printf '%s' "$listed" | tr '\n' ' ' | sed 's/ $//')"
else
  echo "RED-AT-BASE"
fi
exit 0
