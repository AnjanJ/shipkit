---
description: "Run the change: start this Phoenix app on a free port, make one request, stop it, and report the script's line. TRIGGER when: a task or the user asks to check a change in the running app. DO NOT TRIGGER when: only tests were asked for, or the project has no Phoenix endpoint."
user-invocable: true
argument-hint: "<path, e.g. /health>"
---

# /verify — run the change

Path: $ARGUMENTS (the path the task names).

1. The script is `<plugin root>/scripts/verify-run.sh`. The root is in this session's
   `shipkit: plugin root is …` line, or in `~/.claude/shipkit/plugin-root`.
2. Run `sh "<root>/scripts/verify-run.sh" --start 'mix phx.server' --request <path>
   --env PHX_SERVER=true --env MIX_ENV=<env> --timeout 120`, where `<env>` is the environment
   the task names, `test` when it names none. Add any other `--env` the task names (a
   `MIX_TEST_PARTITION`, for one).
3. Phoenix's generated `config/runtime.exs` reads `PORT`; a project whose config fixes the port
   reads `NOT-READY`. Then report that line and the config line that fixes the port. Do not
   edit config to make it run.
4. Report the script's first line as printed, with the lines under it. `RAN` is not a pass:
   read the status and the body. On `NOT-READY` or `EXITED`, report that line and the output
   under it, and do not say the change was checked. Never report a run you did not make.
