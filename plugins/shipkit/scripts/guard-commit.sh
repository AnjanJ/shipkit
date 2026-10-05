#!/bin/sh
# Shipkit PreToolUse hook (matcher: Bash): stop a `git commit` that would include a file that
# looks like a secret.
#
# Claude Code sends the pending tool call as JSON on stdin. Exit 2 blocks the call and shows
# this script's stderr to Claude; exit 0 lets it through. The always-on rule says "never stage
# .env, credentials, keys or tokens" — this makes that one line enforced instead of advised.
#
# What it checks: the NAMES of the files already staged (git diff --cached --name-only) when
# the command contains `git commit`. Blocked names: .env, .env.* (but not .env.example),
# *.pem, *.key, id_rsa*, credentials*.json — matched on the file name, in any directory.
#
# What it does not catch, on purpose (it is a seat belt, not a scanner):
#   - a secret pasted into an ordinary file — it never reads contents;
#   - `git add .env && git commit` in ONE command — nothing is staged yet when the hook runs;
#   - `git -C dir commit`, or a commit typed in your own terminal.
#
# Runs before EVERY Bash call, so a command that is not a commit leaves on the first test,
# without touching the repository. On any internal error it exits 0: a broken guard must
# never block a session. POSIX sh only; no jq, no python.
# Spec: .shipkit/specs/measure-and-slim/ (REQ-21..REQ-26).

input=$(cat 2>/dev/null) || exit 0
case "$input" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# The hook's JSON names the session's working directory; look at that repository.
dir=$(printf '%s' "$input" | sed -n 's/.*"cwd":"\([^"]*\)".*/\1/p' 2>/dev/null)
if [ -n "$dir" ] && [ -d "$dir" ]; then cd "$dir" 2>/dev/null || exit 0; fi

staged=$(git diff --cached --name-only 2>/dev/null) || exit 0
[ -n "$staged" ] || exit 0

# A function, not an inline $( … case … ): older shells (macOS /bin/sh is bash 3.2) misparse
# a case pattern's closing parenthesis inside a command substitution.
secret_names() {
  while IFS= read -r f; do
    case "${f##*/}" in
      .env.example) ;;
      .env|.env.*|*.pem|*.key|id_rsa*|credentials*.json) printf '  %s\n' "$f" ;;
    esac
  done
}
bad=$(printf '%s\n' "$staged" | secret_names)
[ -n "$bad" ] || exit 0

{
  echo "shipkit: commit blocked. These staged files look like secrets:"
  printf '%s\n' "$bad"
  echo "Do not commit them: unstage these or ask the owner (git restore --staged <file>)."
} >&2
exit 2
