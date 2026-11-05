#!/bin/sh
# Shipkit setup-files: are CLAUDE.md and .gitignore still exactly as /shipkit:setup left them?
#
#   setup-files.sh <project-dir> record   write .claude/rules/shipkit/.setup-files
#   setup-files.sh <project-dir> check    print each file that still matches its record
#
# `record` runs last in setup, after its final write to either file. It writes one line per
# file that exists — its git blob id (`git hash-object`), a space, its path. `check` prints the
# path of each recorded file whose blob id in the working tree is the recorded one, and prints
# nothing when there is no record.
#
# Why: a first spec after setup carries setup's CLAUDE.md and .gitignore in its diff, and on
# three real runs in a row (4.12, 5.0, 5.1) the gate listed both as changes beyond the spec with
# nothing in them but setup's. brief-verify.sh asks `check`; the reviewer compares the record
# with `git hash-object` itself. A file that differs at all is reported, setup's lines with it:
# all or nothing, never a guess about which line is whose. No record — a setup from before
# 5.2.0, or one that skipped this step — means both are reported, as before
# (gate-on-setup/REQ-7 to REQ-12; the design's fourth record says why not the section markers).
#
# The record lives beside the manifest but is not in it: unsetup-remove.sh removes it with the
# manifest.
#
# Exit status: 0 done; 1 the record could not be written; 64 wrong usage.
# POSIX sh + git.

[ $# -eq 2 ] || { echo "usage: setup-files.sh <project-dir> record|check" >&2; exit 64; }
PROJ=${1%/}; MODE=$2
[ -d "$PROJ" ] || { echo "setup-files: no such directory: $PROJ" >&2; exit 64; }
REC="$PROJ/.claude/rules/shipkit/.setup-files"
FILES="CLAUDE.md .gitignore"

case "$MODE" in
  record)
    mkdir -p "${REC%/*}" || exit 1
    : > "$REC" || exit 1
    for f in $FILES; do
      [ -f "$PROJ/$f" ] || continue
      id=$(git hash-object "$PROJ/$f") || exit 1
      printf '%s %s\n' "$id" "$f" >> "$REC" || exit 1
    done
    ;;
  check)
    [ -f "$REC" ] || exit 0
    while read -r id f; do
      [ -n "$f" ] && [ -f "$PROJ/$f" ] || continue
      [ "$(git hash-object "$PROJ/$f")" = "$id" ] && echo "$f"
    done < "$REC"
    ;;
  *) echo "usage: setup-files.sh <project-dir> record|check" >&2; exit 64 ;;
esac
exit 0
