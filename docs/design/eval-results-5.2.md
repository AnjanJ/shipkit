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
| 1 | 74 | 24 | 25 | 1 | 0 | 2 | yes | $0.20 |
| 2 | 74 | 9 | 10 | 1 | 0 | 1 | yes | $0.16 |
| 3 | 57 | 8 | 8 | 1 | 0 | 1 | yes | $0.14 |
| 4 | 81 | 6 | 7 | 1 | 0 | 0 | yes | $0.13 |
| 5 | 55 | 7 | 7 | 1 | 0 | 1 | yes | $0.14 |

Run on 2026-11-06 at `4bae74a`, Claude Code 2.1.318, `sonnet`; $0.77 for the five. Each run's
result, transcript and subagent logs were kept in the output folder until the sprint's end.

**Reading.** No run idled over 60 s: 6 to 24 s from the write of `intake.md` to the session's last
entry, against 260 s on the 5.1 transcript. Every run started `grandfather` in the background, the
shape that waited at 5.1, so the fixture held (the design's fixture record does not fire). No run
armed a `Monitor`. Four of five reached for `sleep` while `grandfather` ran, all before the file was
written: `sleep 60`, `sleep 45` and `sleep 45` were blocked with the platform's "use Monitor"
message, run 1's later bare `sleep 45` went to the background, and run 2's `sleep 1` ran. None of
them armed the watch the 5.1 run armed instead. The gap from the last entry to the process's exit
was 1 s on every run, so the transcript's count stands (the design's 10 s condition does not fire).
