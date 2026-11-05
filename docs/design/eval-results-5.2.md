# Eval results 5.2.0

The machine plan's measurements (`docs/plans/machine-sprint-plan.md`), each read from the run's
transcript and not from an eval summary (rule 10).

## 1. Does a headless intake wait after its work is done? (G7)

`users-machine/REQ-9`, `REQ-10`. The 5.1 intake wrote its file at 00:19:34 and its session ended
at 00:23:52: two `Monitor` watches on a `grandfather` agent that had already finished held it open,
and the JSON result's `duration_ms` said 2,023 (`field-notes-5.1.md` §4). Read again by
`wait-probe.sh --read`, that transcript gives 260 idle seconds, 2 `Monitor` calls, 1 `sleep` and a
background agent.

**How.** `sh scripts/wait-probe.sh --run 5`: five headless `/shipkit:intake` sessions, each on a fresh
copy of the fixture `--scaffold` writes (`tally`, 13 files, whose "today" is UTC and whose users'
time zones are stored and never read), run as the 5.1 run's were: `--plugin-dir` this checkout,
`--model sonnet`, `--allowedTools Read Glob Grep Bash Write Edit Skill Agent`,
`--output-format json`, standard input from `/dev/null`. Idle seconds are the transcript's: the
last write of `intake.md` to its last entry. The disk's view, `intake.md`'s modification time to
the process's exit, stands beside it, and so does the gap from the last entry to the exit, which
the design's reversal condition reads (over 10 s on any run moves the count to the disk's).

**The bar** (`users-machine/design.md`). If 2 or more of the 5 runs idle over 60 s, a sentence goes
into the intake and ask skills and five more runs are recorded below; otherwise one line in
`ROADMAP.md` names the wait as the platform's and cites these runs.

| Run | Wall s | Idle s (transcript) | Idle s (disk) | Exit − last entry s | Monitor | sleep | Background agent | Cost |
|---:|---:|---:|---:|---:|---:|---:|---|---:|

The five runs are made at the sprint's end, on the owner's yes (rule 15), and the table is filled
from `table.md` in the run's output folder.
