#!/bin/sh
# Shipkit test-command: the project's one test command, as setup recorded it.
#
#   test-command.sh <project-dir>                        print the recorded command
#   test-command.sh <project-dir> --record '<command>'   write the record
#
# The record is <project-dir>/.claude/rules/shipkit/.test-command: one line. install-stack.sh
# writes it from its TEST_COMMAND argument, after a successful install. It sits beside the
# installation manifest and outside it, as setup-files.sh's record does, so rewriting it is
# never read as drift, and unsetup-remove.sh deletes it by name with the manifest. It is not a
# Markdown file, so Claude Code does not load it as a rule.
#
# Why: a project's CLAUDE.md can name two test commands. On the 5.2 run setup had written the
# one that works and the spec, the brief and both gates copied the other, which exits 1
# (docs/design/field-notes-5.2.md §6.1, §7.1, §9.1). This script NEVER reads CLAUDE.md: what
# needs the command asks here, and no record is an answer, not a reason to guess.
#
# Exit status: 0 the command was printed, or the record was written; 1 there is no record (the
# message is on standard error), or the record could not be written; 2 usage.
# POSIX sh. No model, no network. Spec: .shipkit/specs/gate-as-software/ (REQ-5 to REQ-8).

usage() { echo "usage: test-command.sh <project-dir> [--record '<command>']" >&2; exit 2; }

[ $# -ge 1 ] || usage
PROJ=$1
REC="${PROJ%/}/.claude/rules/shipkit/.test-command"

case $# in
  1)
    line=$(sed -n 1p "$REC" 2>/dev/null)
    if [ -n "$line" ]; then printf '%s\n' "$line"; exit 0; fi
    echo "no test command recorded; run /shipkit:setup, or pass one" >&2
    exit 1 ;;
  3)
    [ "$2" = --record ] || usage
    cmd=$3
    NL=$(printf '\nx'); NL=${NL%x}   # a literal newline
    case "$cmd" in
      ''|*"$NL"*) usage ;;           # the record is one line, and an empty one is no record
    esac
    [ -d "$PROJ" ] || { echo "test-command: no such directory: $PROJ" >&2; exit 2; }
    mkdir -p "${PROJ%/}/.claude/rules/shipkit" 2>/dev/null \
      && printf '%s\n' "$cmd" > "$REC" 2>/dev/null \
      || { echo "test-command: could not write $REC" >&2; exit 1; }
    exit 0 ;;
  *) usage ;;
esac
