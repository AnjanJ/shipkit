#!/bin/sh
# Shipkit brief-verify: after an agent reports back on a task, did it stay inside the files
# the task was allowed to change?
#
#   brief-verify.sh <project-dir> <slug> <task-id> <base-ref>
#
# <base-ref> is the commit the work started from (note `git rev-parse HEAD` before handing the
# task over). Every file that differs from it — committed since, or still uncommitted — and
# every new untracked file is compared with the task's Files line in
# .shipkit/specs/<slug>/tasks.md. Each one not on the list is printed as:
#
#   OUTSIDE <file>
#
# A Files entry ending in "/" allows everything under that folder. The spec's own tasks.md is
# always allowed, so the task's box can be ticked. Ignored files (.gitignore) are not seen.
#
# This checks WHICH files changed, not WHAT changed in them. Run the task's Done when command
# yourself as well: the agent's own claim is not proof.
#
# Exit status: 0 nothing outside the list; 1 at least one OUTSIDE line, or no such task;
# 64 wrong usage (including a base ref git does not know).
# POSIX sh + awk + git. Spec: .shipkit/specs/product-intake-brief/.

[ $# -eq 4 ] || { echo "usage: brief-verify.sh <project-dir> <slug> <task-id> <base-ref>" >&2; exit 64; }
PROJ=$1; SLUG=$2; TASK=$3; BASE=$4
[ -d "$PROJ" ] || { echo "brief-verify: no such directory: $PROJ" >&2; exit 64; }
git -C "$PROJ" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "brief-verify: $PROJ is not a git repository" >&2; exit 64; }
git -C "$PROJ" rev-parse --verify --quiet "$BASE^{commit}" >/dev/null 2>&1 || {
  echo "brief-verify: git does not know the base ref '$BASE'" >&2; exit 64; }

# The task's allowed files come from brief.sh's own reading of tasks.md, so the two scripts
# cannot disagree about what a task may edit.
HERE=$(cd "$(dirname "$0")" && pwd)
ALLOWED=$(sh "$HERE/brief.sh" "$PROJ" "$SLUG" "$TASK" 2>/dev/null \
  | awk '/^## You may edit/ { on = 1; next } /^## / { on = 0 } on && /^- / { print substr($0, 3) }')
if [ -z "$ALLOWED" ]; then
  sh "$HERE/brief.sh" "$PROJ" "$SLUG" "$TASK" >/dev/null   # prints the reason on stderr
  exit 1
fi

TASKS_FILE=".shipkit/specs/$SLUG/tasks.md"
CHANGED=$( { git -C "$PROJ" diff --name-only "$BASE" --; git -C "$PROJ" ls-files --others --exclude-standard; } | sort -u)

# The list goes in through the environment: BSD awk (macOS) rejects a newline in a -v value.
OUT=$(printf '%s\n' "$CHANGED" | BV_ALLOWED="$ALLOWED" awk -v tasks="$TASKS_FILE" '
  BEGIN { n = split(ENVIRON["BV_ALLOWED"], a, "\n") }
  $0 == "" { next }
  {
    ok = ($0 == tasks)
    for (i = 1; i <= n && !ok; i++) {
      if ($0 == a[i]) ok = 1
      else if (a[i] ~ /\/$/ && index($0, a[i]) == 1) ok = 1
    }
    if (!ok) print "OUTSIDE " $0
  }')

total=$(printf '%s\n' "$CHANGED" | grep -c .)
if [ -n "$OUT" ]; then
  printf '%s\n' "$OUT"
  echo "brief-verify: $total file(s) changed, $(printf '%s\n' "$OUT" | grep -c .) outside the Files of $SLUG / $TASK"
  exit 1
fi
echo "brief-verify: $total file(s) changed, all inside the Files of $SLUG / $TASK"
exit 0
