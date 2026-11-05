# Tasks: The user's machine (Sprint 27)

One commit each for T1 to T4, test and code together. The steps are in
`docs/plans/machine-sprint-plan.md` under the same task number (S27-T0 to S27-T4, S27-T-MERGE).
**Paid runs, each on the owner's yes (rule 15):** T1's Check first, one headless `claude -p` call on
an `office_bestie` worktree; T3's five intakes (≈ $2.50) and, only on G7's bar, five more
(≈ $2.50); at the merge `--group reviewer` (≈ $1.10), and the group of any skill T3 changes. A smoke
check is run alone while it is written, from an empty scratch directory: the suite's lines up to
`# 1.` with `ROOT=` pinned to the checkout, the block, the suite's last three lines, through `sh`;
a check whose fixture an earlier check builds runs with that check. Every scratch copy is removed
after reading (rule 13).

- [x] **T0** Write the sprint spec (S27-T0) → REQ-1 to REQ-11, the spec itself
  - Files: .shipkit/specs/users-machine/, docs/plans/machine-sprint-plan.md
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . users-machine --as-open` → 0 gaps; `sh plugins/shipkit/scripts/decision-check.sh . --run` → no FIRED or ERROR; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the requirements, of the elixir and go sections in T1, and of the design, in the thread; stamped at the branch-point commit, `Status: open`; the plan's S27-T1 Files amended and its status line noting it, in the same commit
- [x] **T1** A test command for a pinned toolchain (S27-T1, G4) → REQ-1, REQ-2, REQ-3
  - Files: plugins/shipkit/skills/setup/SKILL.md, plugins/shipkit/stacks/elixir/CLAUDE.md.append, plugins/shipkit/stacks/go/CLAUDE.md.append, scripts/smoke.sh, CHANGELOG.md
  - Test: the Check first, on the owner's yes: in a scratch worktree of `~/code/office_bestie` at its `main`, a headless `claude -p` whose one Bash call runs `MIX_ENV=test MIX_TEST_PARTITION=_shipkit7 mise exec -- mix test`, the suite's last lines and exit status kept; then scripts/smoke.sh, written first and run alone, red: check 90 "pinned-toolchain" (Phase 1 step 4 names `.tool-versions`, `mise.toml`, `.mise.toml`, `mise` on the `PATH`, `mise exec --` after any `VAR=value` words, and the command unchanged otherwise, `users-machine/REQ-1`, `REQ-2`; `install-stack.sh` elixir and go without `TEST_COMMAND` exit 2 naming it, and with `TEST_COMMAND='MIX_ENV=test mise exec -- mix test'` the elixir section holds it on both lines and no bare `mix test`, `REQ-3`)
  - After: T0
  - Done when: check 90 PASS alone; checks 68 and 86, and every other check that installs the elixir or go overlay, PASS alone; the Check first's command and output in the commit's test plan; the worktree removed on the owner's yes; lint 0/0
- [x] **T2** Searches no alias can bend (S27-T2, G5) → REQ-4, REQ-5, REQ-6
  - Files: plugins/shipkit/agents/reviewer.md, plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/skills/ship/reference.md, scripts/smoke.sh, CHANGELOG.md
  - Test: scripts/smoke.sh, written first and run alone, red: check 91 "git-grep" (the reviewer's procedure names `git grep -n`, `-E` and "never `\|`", `users-machine/REQ-4`; step 3's command is `git grep -n --untracked`, and run on a scratch repository whose untracked `tasks.md` holds an unticked line it exits 0, `REQ-5`; none of the three files names a search command but `git grep` or holds `\|` in a command, `REQ-6`)
  - After: T1
  - Done when: check 91 PASS alone; checks 74, 76, 77, 83, 85, 88 and 89, which read these files with no claude, PASS alone; lint 0/0
- [ ] **T3** The headless wait, measured (S27-T3, G7) → REQ-7, REQ-8, REQ-9, REQ-10
  - Files: scripts/wait-probe.sh, docs/design/eval-results-5.2.md, scripts/smoke.sh, plugins/shipkit/skills/intake/SKILL.md, plugins/shipkit/skills/ask/SKILL.md, ROADMAP.md, CHANGELOG.md
  - Test: scripts/smoke.sh, written first and run alone, red: check 92 "wait-probe" (`wait-probe.sh --scaffold <dir>` writes the fixture repository with no model call, `users-machine/REQ-7`; given two stored transcripts, one whose `intake.md` write is followed by two `Monitor` calls, a `sleep` and 240 s to its last entry, one with 5 s and neither, `--read` prints those numbers, `REQ-8`); then the five runs, on the owner's yes. **STOP: the owner sees the table** before any sentence goes in. On G7's bar only: check 93, written first, red, holds the sentence in both skills (`REQ-10`), and five runs again
  - After: T2
  - Done when: check 92 PASS alone; `eval-results-5.2.md`'s table has no empty cell; the owner's go in the thread; the sentence and check 93 PASS, or the ROADMAP line, as REQ-10 says; lint 0/0
- [x] **T4** The evals' home, recorded (S27-T4, G8) → REQ-11
  - Files: .shipkit/decisions/0005-evals-home.md, ROADMAP.md
  - Test: `sh plugins/shipkit/scripts/decision-check.sh . --run` reads `0005-evals-home.md` with no FIRED or ERROR line; `bash scripts/lint.sh` → 0/0
  - After: T3
  - Done when: the record has its five parts, cites the loading and plugin-evals pages read at T0, and its reversal condition is an event; the ROADMAP's evals item points to it; lint 0/0
- [ ] **T-MERGE** Merge, untagged (S27-T-MERGE) → the merge steps in `spec.md`
  - Files: .shipkit/specs/users-machine/
  - Test: the sprint exit checklist with `bash scripts/evals.sh --group reviewer -j 4`, and the intake and ask groups if T3 changed those skills, every case that passed before still passing; the full smoke suite (rule 22)
  - After: T4
  - Done when: the checklist holds; the pull request merged after a green check, no tag; the owner's cache untouched
