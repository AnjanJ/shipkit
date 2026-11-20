#!/bin/sh
# Shipkit PreToolUse hook (matcher: Bash): the commit gate. It looks for a stamp that says how a
# commit was checked, on a `git commit` whose message is on the command line.
#
# A stamp is `Verified: <kind> (<what>)`, where <kind> is tests, gate, brief-verify, ran or none,
# and <what> is not empty: `Verified: none (docs only)` is a stamp; `Verified: none ()` is not.
# A message given in several -m parts is one message, and a stamp in any part counts.
#
# Its mode is SHIPKIT_COMMIT_GATE:
#   off (the default, and any value but the two below): it does nothing, and reads nothing but
#        its input, with the shell's own `read`, so no process starts beyond this one.
#   observe: an unstamped commit adds a row to $SHIPKIT_HOME/commit-gate.log and goes through.
#   enforce: an unstamped commit is blocked (exit 2) with one line on how to stamp it. After two
#        blocks in one session the next unstamped commit goes through, so a session cannot get
#        stuck. Blocks are counted from the log's rows.
# SHIPKIT_HOME is ~/.claude/shipkit unless set. A row: the time in UTC, the session id, the mode,
# unstamped / blocked / passed / unseen, and the hook's cwd (or -), separated by tabs.
#
# Its limits (running-the-change/REQ-27):
#   - it sees only a message given on the command line (-m, --message, or a cluster of short
#     options ending in m, such as -am). A commit from a file (-F), an editor, --no-edit, or the
#     owner's own terminal is never blocked; in observe and enforce it adds an `unseen` row;
#   - it reads the command text as the hook's JSON carries it, so `git commit` inside a quoted
#     string of another command counts as a commit call, as it does for guard-commit.sh;
#   - on any error of its own (no input, no session id, a log it cannot write) it exits 0: a
#     broken gate must never block a session.
# POSIX sh, sed and awk; no jq, no python. Compact and indented JSON alike.
# Spec: .shipkit/specs/running-the-change/ (REQ-18 to REQ-27).

mode=${SHIPKIT_COMMIT_GATE:-off}
case "$mode" in
  observe|enforce) ;;
  *) while IFS= read -r _l || [ -n "$_l" ]; do :; done 2>/dev/null; exit 0 ;;
esac

input=$(cat 2>/dev/null) || exit 0
case "$input" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# The first value of a string field, white space allowed around the colon.
field() {
  printf '%s\n' "$input" | sed -n -E "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\".*/\\1/p" 2>/dev/null | head -n 1
}
cmd=$(field command)
case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac
sid=$(field session_id)
[ -n "$sid" ] || exit 0
cwd=$(field cwd)
[ -n "$cwd" ] || cwd=-

home=${SHIPKIT_HOME:-$HOME/.claude/shipkit}
log="$home/commit-gate.log"
row() {  # row <word>: one line on the log, or exit 0 when it cannot be written
  mkdir -p "$home" 2>/dev/null || exit 0
  printf '%s\t%s\t%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$sid" "$mode" "$1" "$cwd" >> "$log" 2>/dev/null || exit 0
}

after=${cmd#*git commit}
if ! printf '%s\n' "$after" | grep -Eq '(^|[[:space:]])(--message|-[A-Za-z]*m)([[:space:]=]|\\?"|$)'; then
  row unseen; exit 0
fi
if printf '%s\n' "$cmd" | grep -Eq 'Verified: (tests|gate|brief-verify|ran|none) \([^)]+\)'; then
  exit 0
fi

if [ "$mode" = observe ]; then row unstamped; exit 0; fi

blocks=$(awk -F'\t' -v s="$sid" '$2 == s && $4 == "blocked" { n++ } END { print n + 0 }' "$log" 2>/dev/null)
if [ "${blocks:-0}" -ge 2 ]; then row passed; exit 0; fi
row blocked
echo "shipkit: commit gate (enforce): this commit has no stamp. Add a line \"Verified: <tests|gate|brief-verify|ran|none> (<what>)\"; with nothing to show, \"Verified: none (<reason>)\"." >&2
exit 2
