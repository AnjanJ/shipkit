#!/bin/sh
# trace-tools.sh <eval output dir | directory of sandboxes | trace.jsonl> …
#
# Prints one line per eval run with the numbers the map comparison reads — counted from each
# run's trace.jsonl, never from the eval summary (eval summaries are not evidence):
#
#   case  arm  run  passed  tools  tools_main  agent  in_tokens  in_tokens_main  cost
#
#   tools          tool_use content blocks across every assistant row, deduplicated by block id
#                  (a message split over several rows must not count twice); subagent included
#   tools_main     the same, counting only rows whose parent_tool_use_id is null (main session)
#   agent          Agent calls (the hand-off to grandfather/eve/reviewer)
#   in_tokens      input + cache_creation + cache_read tokens, summed once per message id
#                  (split rows repeat the usage block); every assistant row, so subagent included
#   in_tokens_main the same for main-session rows only — what the elder keeps out of your context
#   cost           total_cost_usd from the last result row
#
# Where runs come from: an output dir with aggregate-result.json (what `scripts/evals.sh`
# writes; --output-dir) maps case → arm → run → tracePath, and `passed` is the grader verdict.
# A directory without one is searched for */out/trace.jsonl (the --keep-temp sandboxes under
# /private/tmp/e-*); then case is "?" and passed is "-". A trace.jsonl path is read directly.
#
# What the trace holds (Claude Code 2.1.289, checked 2026-10-07 on kept sandboxes): tool calls
# are content blocks inside "assistant" rows, not rows of their own; subagent turns appear in
# the same trace with parent_tool_use_id set; one API response may arrive as several assistant
# rows sharing message.id and usage; the result row carries total_cost_usd. POSIX sh + python3.
# Cites: map-on-trial/REQ-10 map-on-trial/REQ-11
[ $# -ge 1 ] || { echo "usage: trace-tools.sh <eval output dir | sandbox dir | trace.jsonl> ..." >&2; exit 2; }
exec python3 - "$@" <<'PY'
import json, os, sys, glob

def count(path):
    tools, tools_main, agent = set(), set(), 0
    tokens, tokens_main, seen = 0, 0, set()
    cost = 0.0
    try:
        rows = [json.loads(l) for l in open(path) if l.strip()]
    except (OSError, ValueError) as exc:
        return None, str(exc)
    for r in rows:
        t = r.get("type")
        if t == "assistant":
            msg = r.get("message") or {}
            main = r.get("parent_tool_use_id") in (None, "")
            for c in msg.get("content") or []:
                if isinstance(c, dict) and c.get("type") == "tool_use":
                    bid = c.get("id") or f"{len(tools)}@{id(c)}"
                    if bid in tools:
                        continue
                    tools.add(bid)
                    if main:
                        tools_main.add(bid)
                    if c.get("name") == "Agent":
                        agent += 1
            mid = msg.get("id") or r.get("request_id") or r.get("uuid")
            if mid not in seen:
                seen.add(mid)
                u = msg.get("usage") or {}
                n = sum(int(u.get(k) or 0) for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
                tokens += n
                if main:
                    tokens_main += n
        elif t == "result" and r.get("total_cost_usd") is not None:
            cost = float(r["total_cost_usd"])
    return (len(tools), len(tools_main), agent, tokens, tokens_main, cost), None

def runs_in(arg):
    agg = os.path.join(arg, "aggregate-result.json") if os.path.isdir(arg) else None
    if agg and os.path.isfile(agg):
        data = json.load(open(agg))
        for case in data.get("cases", []):
            for arm, runs in (case.get("arms") or {}).items():
                for i, run in enumerate(runs, 1):
                    p = run.get("tracePath")
                    if p:
                        yield case.get("name", "?"), arm, i, "pass" if run.get("passed") else "fail", p
    elif os.path.isdir(arg):
        for i, p in enumerate(sorted(glob.glob(os.path.join(arg, "*", "out", "trace.jsonl"))
                                     + glob.glob(os.path.join(arg, "out", "trace.jsonl"))), 1):
            yield "?", os.path.basename(os.path.dirname(os.path.dirname(p))), i, "-", p
    else:
        yield "?", "-", 1, "-", arg

print("case\tarm\trun\tpassed\ttools\ttools_main\tagent\tin_tokens\tin_tokens_main\tcost")
bad = 0
for arg in sys.argv[1:]:
    for case, arm, i, passed, path in runs_in(arg):
        c, err = count(path)
        if err:
            print(f"{case}\t{arm}\t{i}\t{passed}\tERROR\t{path}: {err}", file=sys.stderr); bad = 1; continue
        print(f"{case}\t{arm}\t{i}\t{passed}\t{c[0]}\t{c[1]}\t{c[2]}\t{c[3]}\t{c[4]}\t{c[5]:.4f}")
sys.exit(bad)
PY
