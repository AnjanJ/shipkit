#!/bin/sh
# Shipkit: run the change. Start an application on a free port, wait until it answers, make one
# GET request, and stop what it started.
#
#   verify-run.sh --start '<command>' --request <path> [--env KEY=VALUE ...] [--timeout <s>]
#
#   --start    run by `sh -c` in the current directory with PORT set to the port this script
#              picked; write "$PORT" in it, and single-quote the whole command so that your own
#              shell leaves it alone: --start 'python3 -m http.server "$PORT"'
#   --request  a path that starts with /, asked once, with GET, on 127.0.0.1:<port>
#   --env      NAME=value for the application's environment; may be given more than once
#   --timeout  whole seconds to wait for the port to answer, and for the request; 30 by default
#
# Standard output starts with one line, then what that line promises:
#   RAN <status> <path>     the response's status line, then at most its first 10 body lines; exit 0
#   EXITED <code>           the start command ended before the port answered; then at most the
#                           last 20 lines of the application's output; exit 1
#   NOT-READY after <s> s   the port did not answer in <s> seconds (the timeout, not a measured
#                           time), or the request got no response; then at most the last 20
#                           lines of the application's output; exit 1
# Wrong usage, or no curl: a line on standard error, nothing started, exit 2.
#
# "Answers" means any HTTP response, a 404 included, to a probe on /shipkit-verify-probe, so the
# path asked for is fetched once only. The application's own output goes to a file, and reaches
# standard output only after EXITED or NOT-READY.
#
# What it stops: the start command runs in a process group of its own (`set -m`), and on every
# way out, an interrupt included, that group is sent TERM, then KILL after 3 s, and the one
# directory this script made under TMPDIR is removed. Nothing else is stopped. Where a shell
# gives the command no group of its own, the processes it started are found by parent id and
# stopped instead. A process that leaves on purpose (setsid, a daemon mode) is not stopped.
#
# Needs curl, POSIX sh and awk, and nothing else beyond the utilities every POSIX system has
# (mktemp, sleep, kill, ps, tail). The port is a random one from 20000 to 60999 that nothing
# answered on a moment before. Another process can take it between that probe and the
# application's start: that shows as EXITED (the bind failed) or NOT-READY, and, if the other
# process speaks HTTP, as a RAN line that is not the application's. (running-the-change/REQ-12)
# Spec: .shipkit/specs/running-the-change/ (REQ-1 to REQ-12).

usage() {
  echo "usage: verify-run.sh --start '<command>' --request <path> [--env KEY=VALUE ...] [--timeout <s>]" >&2
  [ -n "$1" ] && echo "verify-run: $1" >&2
  exit 2
}

NL='
'
START=""; HAVE_START=0; REQ=""; HAVE_REQ=0; TIMEOUT=30; ENVS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --start)
      [ $# -ge 2 ] || usage "--start needs a command"
      START=$2; HAVE_START=1; shift 2 ;;
    --request)
      [ $# -ge 2 ] || usage "--request needs a path"
      REQ=$2; HAVE_REQ=1; shift 2 ;;
    --env)
      [ $# -ge 2 ] || usage "--env needs NAME=value"
      case "$2" in *=*) ;; *) usage "--env wants NAME=value, not: $2" ;; esac
      name=${2%%=*}
      case "$name" in ''|[!A-Za-z_]*|*[!A-Za-z0-9_]*) usage "--env: not a valid name: $name" ;; esac
      ENVS="$ENVS$2$NL"; shift 2 ;;
    --timeout)
      [ $# -ge 2 ] || usage "--timeout needs whole seconds"
      case "$2" in ''|*[!0-9]*) usage "--timeout wants whole seconds above 0, not: $2" ;; esac
      TIMEOUT=$(awk -v t="$2" 'BEGIN { print t + 0 }')
      [ "$TIMEOUT" -gt 0 ] || usage "--timeout wants whole seconds above 0, not: $2"
      shift 2 ;;
    *) usage "unknown argument: $1" ;;
  esac
done
[ "$HAVE_START" = 1 ] && [ -n "$START" ] || usage "--start is missing"
[ "$HAVE_REQ" = 1 ] || usage "--request is missing"
case "$REQ" in /*) ;; *) usage "the path must start with /, not: $REQ" ;; esac
command -v curl >/dev/null 2>&1 \
  || { echo "verify-run: curl is not on the PATH; it is the one tool this script needs beyond sh and awk" >&2; exit 2; }

now() { awk 'BEGIN { srand(); print srand() }'; }   # seconds since the epoch, in POSIX awk

D=$(mktemp -d "${TMPDIR:-/tmp}/shipkit-verify.XXXXXX" 2>/dev/null) \
  || { echo "verify-run: cannot make a directory under ${TMPDIR:-/tmp}" >&2; exit 2; }
pid=""; group=0

# The processes under <pid>, <pid> included, found by parent id (the fallback when no group).
tree() {
  ps -A -o pid= -o ppid= 2>/dev/null | awk -v root="$1" '
    { par[$1] = $2 }
    END { for (p in par) { q = p; n = 0
            while (q != root && (q in par) && q > 1 && n < 100) { q = par[q]; n++ }
            if (q == root) print p } }'
}
stop_app() {
  [ -n "$pid" ] || return 0
  if [ "$group" = 1 ]; then
    kill -TERM -- "-$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    n=0
    while kill -0 -- "-$pid" 2>/dev/null && [ "$n" -lt 30 ]; do sleep 0.1; n=$((n + 1)); done
    kill -KILL -- "-$pid" 2>/dev/null
  else
    left=$(tree "$pid")
    [ -n "$left" ] && kill -TERM $left 2>/dev/null
    wait "$pid" 2>/dev/null
    n=0
    while [ "$n" -lt 30 ]; do
      alive=""; for p in $left; do kill -0 "$p" 2>/dev/null && alive="$alive $p"; done
      [ -z "$alive" ] && break
      sleep 0.1; n=$((n + 1))
    done
    [ -n "$alive" ] && kill -KILL $alive 2>/dev/null
  fi
  pid=""
}
cleanup() { stop_app; rm -rf "$D"; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

finish() {  # finish <first line>: that line, the application's last 20 lines, exit 1
  printf '%s\n' "$1"
  tail -n 20 "$D/out" 2>/dev/null
  exit 1
}

# A port nothing answers on: curl exits 7 when the connection is refused.
port=""; try=0
while [ "$try" -lt 20 ]; do
  cand=$(awk -v p="$$" -v t="$try" 'BEGIN { srand(); s = srand(); srand(s + p * 7919 + t * 104729); print 20000 + int(rand() * 41000) }')
  curl -s -o /dev/null --max-time 1 "http://127.0.0.1:$cand/" >/dev/null 2>&1
  if [ $? -eq 7 ]; then port=$cand; break; fi
  try=$((try + 1))
done
[ -n "$port" ] || { : > "$D/out"; echo "verify-run: no free port found in 20 tries" >> "$D/out"; finish "NOT-READY after $TIMEOUT s"; }

set -f
old_ifs=$IFS; IFS=$NL
for kv in $ENVS; do export "$kv"; done
IFS=$old_ifs
set +f
PORT=$port; export PORT

# The start command in a group of its own, its exit code written when it ends: a shell that has
# not yet reaped a finished child still answers kill -0 for it, so the file is the sign.
set -m
( sh -c "$START"; echo $? > "$D/code" ) >"$D/out" 2>&1 </dev/null &
pid=$!
set +m
pg=$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ')
[ "$pg" = "$pid" ] && group=1

deadline=$(( $(now) + TIMEOUT ))
while :; do
  if [ -f "$D/code" ]; then read -r code < "$D/code"; finish "EXITED ${code:-?}"; fi
  curl -s -o /dev/null --max-time 1 "http://127.0.0.1:$port/shipkit-verify-probe" >/dev/null 2>&1 && break
  [ "$(now)" -ge "$deadline" ] && finish "NOT-READY after $TIMEOUT s"
  sleep 0.25
done

if ! curl -s -S --max-time "$TIMEOUT" -D "$D/head" -o "$D/body" "http://127.0.0.1:$port$REQ" 2>>"$D/out"; then
  if [ -f "$D/code" ]; then read -r code < "$D/code"; finish "EXITED ${code:-?}"; fi
  finish "NOT-READY after $TIMEOUT s"
fi
status_line=$(sed -n 1p "$D/head" | tr -d '\r')
status=$(printf '%s\n' "$status_line" | awk '{ print $2 }')
printf 'RAN %s %s\n' "$status" "$REQ"
printf '%s\n' "$status_line"
awk 'NR <= 10' "$D/body"
exit 0
