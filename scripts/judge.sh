#!/bin/sh
# Shipkit judge: run this repository's ship gate with the plugin from the last tagged release.
#
#   scripts/judge.sh <slug> <base-ref> [--test '<command>'] [--yes]
#
# Run from this repository. A branch that changes ship/SKILL.md, reviewer.md or spec-check.sh
# was gated by its own copies of them: the 5.1.0 and 5.2.0 release gates ran with --plugin-dir
# at the checkout. A branch that weakened the gate would have been judged by the weakened gate.
# Decision 0007 (.shipkit/decisions/0007-a-change-does-not-judge-itself.md): the last tag judges.
#
# Without --yes it prints the last tag and the headless command, with <worktree> in place of a
# path, and runs nothing: the command starts a model and is paid (the verifier plan's rule 33).
#
# With --yes it makes a directory with mktemp, adds a detached worktree of the tag in it, runs
# the command from this repository's root with the plugin loaded from that worktree, then
# removes that worktree and that directory, however the command ended, and exits with the
# command's status. It removes no worktree it did not make.
#
# Exit status: the command's, with --yes; 0 without; 2 on usage, outside a git repository, or
# when there is no tag. POSIX sh + git. Spec: .shipkit/specs/gate-as-software/ (REQ-32 to
# REQ-35).

usage() { echo "usage: judge.sh <slug> <base-ref> [--test '<command>'] [--yes]" >&2; exit 2; }

[ $# -ge 2 ] || usage
SLUG=$1; BASE=$2; shift 2
TESTCMD=""; YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    --test) [ $# -ge 2 ] && [ -n "$2" ] || usage; TESTCMD=$2; shift ;;
    --yes) YES=1 ;;
    *) usage ;;
  esac
  shift
done
case "$SLUG" in ''|*/*|.*) usage ;; esac

TOP=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "judge: not inside a git repository" >&2; exit 2; }
cd "$TOP" || exit 2
TAG=$(git describe --tags --abbrev=0 2>/dev/null) || { echo "judge: no tag to judge with" >&2; exit 2; }

PROMPT="/shipkit:ship $SLUG $BASE
This run is not interactive and you cannot ask me anything. Do not change the spec's Status line."
[ -z "$TESTCMD" ] || PROMPT="$PROMPT
The project's test command is: $TESTCMD"

echo "judge: the last tag is $TAG"
if [ "$YES" -eq 0 ]; then
  echo "judge: the command, not run (pass --yes to run it; it starts a model):"
  echo "  claude --plugin-dir <worktree>/plugins/shipkit --model sonnet --allowedTools Read Glob Grep Bash Write Skill Agent -p \"$PROMPT\" </dev/null"
  echo "  where <worktree> is a new detached worktree of $TAG, removed after the run"
  exit 0
fi

D=$(mktemp -d "${TMPDIR:-/tmp}/shipkit-judge.XXXXXX") || { echo "judge: mktemp failed" >&2; exit 2; }
WT="$D/wt"
cleanup() {
  git -C "$TOP" worktree remove --force "$WT" >/dev/null 2>&1
  rm -rf "$D"
}
trap 'cleanup; exit 130' INT TERM HUP
if ! git worktree add -q --detach "$WT" "$TAG" >/dev/null 2>&1; then
  echo "judge: could not make a worktree of $TAG" >&2; cleanup; exit 2
fi
echo "judge: the plugin is loaded from $WT/plugins/shipkit"
claude --plugin-dir "$WT/plugins/shipkit" --model sonnet \
  --allowedTools Read Glob Grep Bash Write Skill Agent -p "$PROMPT" </dev/null
rc=$?
cleanup
trap - INT TERM HUP
exit $rc
