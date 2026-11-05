#!/bin/sh
# wait-probe.sh — how long a headless /shipkit:intake stays open after its work is done.
#
# The 5.1 intake wrote its file at 00:19:34 and its session ended at 00:23:52: two Monitor watches
# on an agent that had already finished held it open, and the JSON result's duration_ms said 2,023
# (docs/design/field-notes-5.1.md §4). This script measures that wait on a small fixture before
# any skill says anything about it (users-machine/REQ-7, REQ-8; G7).
#
#   wait-probe.sh --scaffold <dir>
#       Write the fixture, a small git repository with one commit, into <dir> (new or empty).
#       No model call.
#   wait-probe.sh --read <transcript.jsonl>...
#       For each stored session transcript print, tab-separated: its name, the idle seconds from
#       the last write of intake.md to the transcript's last entry ("-" if none was written), the
#       Monitor calls, the Bash calls holding the word sleep, and whether a background agent ran
#       (yes, no, none for no Agent call, "-" when the transcript cannot say). No model call.
#   wait-probe.sh --run [N] [--out <dir>]
#       N headless intakes (5 by default), each on a fresh fixture, run as the 5.1 run's were:
#       --plugin-dir this checkout, --model sonnet, --output-format json, stdin from /dev/null.
#       Each run's result, transcript and subagent logs are kept under <dir> (default
#       ${TMPDIR:-/tmp}/wait-probe-<time>), with table.md: one row per run. COSTS MODEL CALLS
#       (about $0.50 a run): run it only on the owner's yes. Nothing is removed afterwards.
#
# How the wait is counted (users-machine/design.md, "The wait is counted from the session's own
# transcript"): a write of intake.md is a Write, Edit or MultiEdit of it, or a Bash command that
# redirects or tees into it (the 5.1 run wrote it with `cat > … <<EOF`); its time is its tool
# result's. Each tool call is counted once, by its id: a transcript repeats some calls in
# entries of its own. --run also prints the disk's view, the seconds from intake.md's
# modification time to the process's exit, and the gap from the transcript's last entry to the
# exit, which the design's reversal condition reads (more than 10 s on any run).

ROOT=$(cd "$(dirname "$0")/.." && pwd)
PLUGIN="$ROOT/plugins/shipkit"
REQUEST='/shipkit:intake Daily reports count "today" from UTC midnight, so a teammate in Sydney sees yesterday'"'"'s entries until 11am. Make "today" follow each person'"'"'s own time zone. This run is not interactive: nobody will answer questions.'

usage() { sed -n '9,22p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

py() {  # py <mode> <args>...: the reader, from a quoted heredoc so no shell touches it
  python3 -I - "$@" <<'PYEOF'
import glob, json, os, re, shutil, sys, time
from datetime import datetime

WRITE_TOOLS = {"Write", "Edit", "MultiEdit"}
REDIRECT = re.compile(r"""(?:>>?|\btee\b(?:\s+-a)?)\s*["']?[^\s;&|<>"']*intake\.md""")
SLEEP = re.compile(r"\bsleep\b")

def stamp(s):
    return datetime.fromisoformat(s.replace("Z", "+00:00")).timestamp()

def read(path):
    """-> (idle seconds or None, monitor calls, sleep calls, background, last entry, write time)"""
    uses, results, last = {}, {}, None
    with open(path) as f:
        for line in f:
            try:
                r = json.loads(line)
            except ValueError:
                continue
            t = r.get("timestamp")
            if t:
                last = stamp(t) if last is None else max(last, stamp(t))
            content = (r.get("message") or {}).get("content")
            if not isinstance(content, list):
                continue
            for b in content:
                if not isinstance(b, dict):
                    continue
                if r.get("type") == "assistant" and b.get("type") == "tool_use":
                    uses.setdefault(b.get("id"), (b.get("name"), b.get("input") or {}))
                elif r.get("type") == "user" and b.get("type") == "tool_result" and t:
                    results.setdefault(b.get("tool_use_id"), stamp(t))

    def writes(name, inp):
        if name in WRITE_TOOLS:
            return str(inp.get("file_path", "")).endswith("intake.md")
        return name == "Bash" and bool(REDIRECT.search(str(inp.get("command", ""))))

    written = [results[i] for i, (n, inp) in uses.items() if writes(n, inp) and i in results]
    wrote = max(written) if written else None
    idle = round(last - wrote) if wrote is not None and last is not None else None
    monitor = sum(1 for n, _ in uses.values() if n == "Monitor")
    sleep = sum(1 for n, inp in uses.values()
                if n == "Bash" and SLEEP.search(str(inp.get("command", ""))))
    agents = [inp for n, inp in uses.values() if n == "Agent"]
    metas = glob.glob(os.path.join(path[:-len(".jsonl")], "subagents", "*.meta.json"))
    shapes = []
    for m in metas:
        try:
            shapes.append(json.load(open(m)).get("requestShape"))
        except (OSError, ValueError):
            pass
    if not agents:
        background = "none"
    elif any(a.get("run_in_background") is True for a in agents) or "background" in shapes:
        background = "yes"
    elif shapes:
        background = "no"
    else:
        background = "-"
    return idle, monitor, sleep, background, last, wrote

def show(v):
    return "-" if v is None else str(v)

mode = sys.argv[1]
if mode == "read":
    print("transcript\tidle_s\tmonitor\tsleep\tbackground")
    for p in sys.argv[2:]:
        idle, monitor, sleep, background, _, _ = read(p)
        print("\t".join([os.path.basename(p), show(idle), str(monitor), str(sleep), background]))
elif mode == "row":
    # row <n> <run dir> <start epoch> <end epoch> <exit status>
    n, d, t0, t1, rc = sys.argv[2], sys.argv[3], float(sys.argv[4]), float(sys.argv[5]), sys.argv[6]
    try:
        res = json.load(open(os.path.join(d, "result.json")))
    except (OSError, ValueError):
        res = {}
    sid, cost = res.get("session_id"), res.get("total_cost_usd")
    found = glob.glob(os.path.expanduser("~/.claude/projects/*/%s.jsonl" % sid)) if sid else []
    idle = monitor = sleep = last = None
    background = "-"
    if found:
        shutil.copy2(found[0], os.path.join(d, "transcript.jsonl"))
        sub = os.path.join(found[0][:-len(".jsonl")], "subagents")
        if os.path.isdir(sub):
            shutil.copytree(sub, os.path.join(d, "transcript", "subagents"), dirs_exist_ok=True)
        idle, monitor, sleep, background, last, _ = read(os.path.join(d, "transcript.jsonl"))
    intake = glob.glob(os.path.join(d, "proj", ".shipkit", "specs", "*", "intake.md"))
    disk = round(t1 - os.path.getmtime(intake[0])) if intake else None
    gap = round(t1 - last) if last is not None else None
    if rc != "0" or not found:
        print("wait-probe: run %s: exit %s, session %s, transcript %s"
              % (n, rc, sid, found[0] if found else "not found"), file=sys.stderr)
    print("| %s | %d | %s | %s | %s | %s | %s | %s | %s |" % (
        n, round(t1 - t0), show(idle), show(disk), show(gap), show(monitor), show(sleep),
        background, "-" if cost is None else "$%.2f" % cost))
PYEOF
}

scaffold() {  # scaffold <dir>: a work-log CLI whose "today" is UTC; tz is stored and never read
  sd=$1
  if [ -e "$sd" ] && [ -n "$(ls -A "$sd" 2>/dev/null)" ]; then
    echo "wait-probe: $sd is not empty" >&2; return 2
  fi
  mkdir -p "$sd/tally" "$sd/tests" "$sd/.shipkit" || return 1
  cat > "$sd/README.md" <<'EOF'
# tally

A command-line work log for small teams. Each person logs what they did; `tally report` counts
today's entries for each teammate.

    python -m tally add "fixed the invoice export"
    python -m tally report

Run the tests with `python -m unittest discover -s tests`.
EOF
  cat > "$sd/pyproject.toml" <<'EOF'
[project]
name = "tally"
version = "0.3.0"
requires-python = ">=3.10"
EOF
  printf '.venv/\n__pycache__/\n*.pyc\n' > "$sd/.gitignore"
  cat > "$sd/.shipkit/product.md" <<'EOF'
# Product: tally

> Product reviewed on 2026-11-05.

## One line
A work log a small remote team keeps from the command line, with a daily count per person.

## Users
Teams of 3 to 15 people, spread over several time zones.

## Goals this quarter
1. A team trusts the daily report: every count matches what each person logged that day.

## Non-goals
- A web interface.
- Billing, invoices or timesheets.
EOF
  printf '"""tally: a team work log."""\n' > "$sd/tally/__init__.py"
  cat > "$sd/tally/__main__.py" <<'EOF'
from tally.cli import main

raise SystemExit(main())
EOF
  cat > "$sd/tally/clock.py" <<'EOF'
"""Where tally gets the time. Every "today" in the app comes from here."""
from datetime import date, datetime, time, timedelta, timezone


def now() -> datetime:
    return datetime.now(timezone.utc)


def today() -> date:
    return now().date()


def day_bounds(day: date) -> tuple[datetime, datetime]:
    """The start and end of a day, as UTC midnights."""
    start = datetime.combine(day, time.min, tzinfo=timezone.utc)
    return start, start + timedelta(days=1)
EOF
  cat > "$sd/tally/users.py" <<'EOF'
"""Teammates. `tz` is an IANA zone name, set at sign-up; nothing reads it yet."""
from dataclasses import dataclass


@dataclass(frozen=True)
class User:
    handle: str
    name: str
    tz: str = "UTC"


TEAM = [
    User("ana", "Ana", "Europe/Lisbon"),
    User("raj", "Raj", "Asia/Kolkata"),
    User("mei", "Mei", "Australia/Sydney"),
]


def find(handle: str) -> User | None:
    return next((u for u in TEAM if u.handle == handle), None)
EOF
  cat > "$sd/tally/store.py" <<'EOF'
"""Entries live in one JSON-lines file; each has a handle, a text and a UTC timestamp."""
import json
from datetime import datetime
from pathlib import Path

from tally import clock

PATH = Path.home() / ".tally.jsonl"


def add(handle: str, text: str, path: Path = PATH) -> None:
    entry = {"handle": handle, "text": text, "at": clock.now().isoformat()}
    with path.open("a") as f:
        f.write(json.dumps(entry) + "\n")


def entries(path: Path = PATH) -> list[dict]:
    if not path.exists():
        return []
    rows = [json.loads(line) for line in path.read_text().splitlines() if line.strip()]
    for r in rows:
        r["at"] = datetime.fromisoformat(r["at"])
    return rows
EOF
  cat > "$sd/tally/report.py" <<'EOF'
"""The daily report: how many entries each teammate logged today."""
from datetime import date

from tally import clock, users


def count_for_day(rows: list[dict], handle: str, day: date) -> int:
    start, end = clock.day_bounds(day)
    return sum(1 for r in rows if r["handle"] == handle and start <= r["at"] < end)


def daily(rows: list[dict], day: date | None = None) -> dict[str, int]:
    day = day or clock.today()
    return {u.handle: count_for_day(rows, u.handle, day) for u in users.TEAM}
EOF
  cat > "$sd/tally/cli.py" <<'EOF'
import argparse
import getpass

from tally import report, store


def main(argv=None) -> int:
    p = argparse.ArgumentParser(prog="tally")
    sub = p.add_subparsers(dest="cmd", required=True)
    add = sub.add_parser("add")
    add.add_argument("text")
    sub.add_parser("report")
    args = p.parse_args(argv)
    if args.cmd == "add":
        store.add(getpass.getuser(), args.text)
    else:
        for handle, n in report.daily(store.entries()).items():
            print(f"{handle:8} {n}")
    return 0
EOF
  cat > "$sd/tests/test_clock.py" <<'EOF'
import unittest
from datetime import date, datetime, timezone

from tally import clock


class DayBounds(unittest.TestCase):
    def test_a_day_runs_from_utc_midnight_to_utc_midnight(self):
        start, end = clock.day_bounds(date(2026, 11, 5))
        self.assertEqual(start, datetime(2026, 11, 5, tzinfo=timezone.utc))
        self.assertEqual(end, datetime(2026, 11, 6, tzinfo=timezone.utc))
EOF
  cat > "$sd/tests/test_report.py" <<'EOF'
import unittest
from datetime import date, datetime, timezone

from tally import report


def at(h):
    return datetime(2026, 11, 5, h, tzinfo=timezone.utc)


class Daily(unittest.TestCase):
    def test_counts_each_teammates_entries_for_the_day(self):
        rows = [{"handle": "ana", "at": at(9)}, {"handle": "ana", "at": at(17)},
                {"handle": "mei", "at": at(23)}]
        self.assertEqual(report.daily(rows, date(2026, 11, 5)), {"ana": 2, "raj": 0, "mei": 1})
EOF
  (cd "$sd" && git init -q && git add -A \
    && GIT_AUTHOR_DATE=2026-11-05T09:00:00Z GIT_COMMITTER_DATE=2026-11-05T09:00:00Z \
       git -c user.email=probe@example.com -c user.name=wait-probe commit -q -m "tally 0.3.0") || return 1
}

case "$1" in
  --scaffold)
    [ $# -eq 2 ] || usage
    scaffold "$2" ;;
  --read)
    shift; [ $# -ge 1 ] || usage
    for t in "$@"; do [ -f "$t" ] || { echo "wait-probe: no such transcript: $t" >&2; exit 2; }; done
    py read "$@" ;;
  --run)
    shift; n=5; out=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --out) [ $# -ge 2 ] || usage; out=$2; shift 2 ;;
        *[!0-9]*|'') usage ;;
        *) n=$1; shift ;;
      esac
    done
    command -v claude >/dev/null 2>&1 || { echo "wait-probe: claude not on PATH" >&2; exit 1; }
    [ -n "$out" ] || out="${TMPDIR:-/tmp}/wait-probe-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$out" || exit 1
    {
      echo "| Run | Wall s | Idle s (transcript) | Idle s (disk) | Exit − last entry s | Monitor | sleep | Background agent | Cost |"
      echo "|---:|---:|---:|---:|---:|---:|---:|---|---:|"
    } > "$out/table.md"
    cat "$out/table.md"
    i=1; bad=0
    while [ "$i" -le "$n" ]; do
      d="$out/run-$i"
      scaffold "$d/proj" || exit 1
      t0=$(python3 -I -c 'import time; print(time.time())')
      (cd "$d/proj" && claude --plugin-dir "$PLUGIN" --model sonnet \
        --allowedTools Read Glob Grep Bash Write Edit Skill Agent --output-format json \
        -p "$REQUEST" < /dev/null > "$d/result.json" 2> "$d/stderr.txt")
      rc=$?
      [ "$rc" -eq 0 ] || bad=1
      t1=$(python3 -I -c 'import time; print(time.time())')
      py row "$i" "$d" "$t0" "$t1" "$rc" | tee -a "$out/table.md"
      i=$((i + 1))
    done
    echo "wait-probe: $n run(s) kept in $out"
    exit "$bad" ;;
  *) usage ;;
esac
