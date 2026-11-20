---
description: "Run the change: serve this site on a free port, request one page, stop the server, and report the script's line. TRIGGER when: a task or the user asks to check a page in the running site. DO NOT TRIGGER when: only tests or an audit were asked for."
user-invocable: true
argument-hint: "<path, e.g. /index.html>"
---

# /verify — run the change

Path: $ARGUMENTS (the path the task names; `/index.html` when it names none).

1. The script is `<plugin root>/scripts/verify-run.sh`. The root is in this session's
   `shipkit: plugin root is …` line, or in `~/.claude/shipkit/plugin-root`.
2. The start command: the `Dev server:` line of `CLAUDE.md` when it names a server that takes
   a port (`npx serve -l "$PORT"`, `npx vite --port "$PORT"`); otherwise
   `python3 -m http.server "$PORT"`, run from the folder that holds the site, with
   `--timeout 90`: this server looks up the machine's name before it listens, and where that
   is slow (a minute on some build machines) `NOT-READY` can mean only that.
3. Run `sh "<root>/scripts/verify-run.sh" --start '<start command>' --request <path>`, with the
   start command in single quotes so the script sets `PORT`.
4. Report the script's first line as printed, with the lines under it. `RAN` is not a pass:
   read the status and the body. On `NOT-READY` or `EXITED`, report that line and the output
   under it, and do not say the change was checked. Never report a run you did not make.
