# Intake: running the change

> Intake taken on 2026-11-20.

## Request

Sprint 34 of `docs/plans/verifier-sprint-plan.md`, "Running the change, and the prune" (lines
1014 to 1125), approved by the owner on 2026-11-17 and amended on 2026-11-18. Three pieces:

1. S34-T1, running the change (V19): `plugins/shipkit/scripts/verify-run.sh --start '<command>'
   --request <path> [--env KEY=VALUE …] [--timeout <s>]` starts an application on a free port,
   waits until it answers, makes one request, and stops the process it started. It prints `RAN
   <status> <path>`, `NOT-READY after <s> s` or `EXITED <code>`. Thin `verify` overlay skills
   behind `--with-skills` (decision 0004).
2. S34-T2, a commit gate, switched off (V20): `plugins/shipkit/scripts/commit-gate.sh`, a
   `PreToolUse` command with modes `off` (the default), `observe` and `enforce`, read from
   `SHIPKIT_COMMIT_GATE`, looking for a `Verified:` line. The commit skill's text for the stamp
   is waiting text.
3. S34-T3, the prune: one row per smoke check and eval case in
   `docs/design/trim-audit-checks.md`, the candidates for a cut, and a stop for the owner's yes
   at each cut.

The owner's words on how to do it, from 2026-11-17: "lets put things that would cost as for the
end of development", and "do what you think is best". So this sprint starts no paid model run
and changes no existing skill, agent or rule file (the plan's rules 33 and 34). The owner said
"go" to this intake on 2026-11-20, after Sprint 33 merged at `49a3284`.

## Serves goal

None. There is no `.shipkit/product.md` (`.shipkit/` holds `checks.md`, `decisions/`,
`releases/`, `specs/` and `state.md`). The plan's goal for the sprint is the nearest statement:
"a script can start an application, check it and stop it; a commit gate exists, switched off;
and the checks are pruned before a dollar is spent running them."

## Conflicts found

- **Rule 34 and a Rails `verify` skill.** `install-stack.sh` copies every folder under
  `stacks/<stack>/.claude/skills/` on `--with-skills` (`install-stack.sh:129-160`). A `verify`
  skill in the Rails overlay makes five skills where smoke checks 67 and 69 assert four
  (`scripts/smoke.sh:2717`, `:2778`), and `plugins/shipkit/skills/setup/SKILL.md:262` says "The
  `rails` overlay ships 4 skills". Correcting that line edits an existing skill file, which rule
  34 holds until Sprint 35 (plan, line 128). Nothing counts the elixir or static overlay's
  skills. The owner decided: answer 1.
- **Decision 0008 and the prune.** `.shipkit/decisions/0008-trap2-cases-stay.md` keeps all
  sixteen trap-2 cases, and smoke check 47 expects them (`scripts/smoke.sh:2014`). They are not
  prune candidates while 0008 stands (assumption 1).

Non-goals: none recorded, since there is no product file.

Open specs: none covers this work. `git grep -i` over `.shipkit/` for `verify-run`, `Verified:`,
"commit gate", "commit stamp" and "Ran the change" finds only `tests-worth-having`, whose out of
scope says "`verify-run.sh`, the commit gate and the prune: Sprint 34"
(`.shipkit/specs/tests-worth-having/spec.md:267`).

Decisions touched and not contradicted:

- `0004-overlay-skills-flag.md`: the `verify` skills are new overlay files behind
  `--with-skills`, so nothing installs them by default, which rule 34 allows.
- `0005-evals-home.md`: the prune may free room under the 204,800-byte ceiling; it does not move
  the evals or raise the ceiling.
- `0008-trap2-cases-stay.md`: above.

## Answers

1. A `verify` skill for Rails breaks smoke checks 67 and 69 and makes setup's text say 4 skills
   where 5 install; elixir and static are clear. Ship elixir and static now, and write the Rails
   skill into `design.md` as waiting text for Sprint 35, which adds the file, setup's count and
   checks 67 and 69 together? — **Yes** (owner, 2026-11-20). This sprint ships two `verify`
   skills, elixir and static; the Rails one is written and held back.
2. `verify-run.sh` must find a free port and make an HTTP request. No script under `plugins/`
   uses `python3`, `curl`, `nc` or `lsof` today (`git grep` over `plugins/` and `scripts/`); the
   plugin's scripts are POSIX sh, awk and git (`install-stack.sh:22`, `spec-check.sh:79`,
   `guard-commit.sh:20`). Require `curl`, and pick a port by trying a random high one that
   nothing answers on, with the small race shown by `NOT-READY` or `EXITED`? — **Yes** (owner,
   2026-11-20). `verify-run.sh` needs `curl` and nothing else new, and its header says so.
3. The plan adds `commit-gate.sh` as a second command on the `Bash` matcher of `PreToolUse`,
   beside `guard-commit.sh` (`plugins/shipkit/hooks/hooks.json`). Once released, every Bash call
   of every session starts one more short process, even with the gate off. `guard-commit.sh`
   already reads the same JSON and leaves at once unless it sees `git commit` (`:24-27`). Keep a
   separate script as the plan says, and measure the extra start in the design? — **Yes**
   (owner, 2026-11-20). Two hook commands; the cost of the second is measured in `design.md`.

## Assumptions made

1. The prune leaves out the sixteen trap-2 cases: decision 0008 stands.
2. The prune's cuts come to the owner as one numbered list in the owner's usual form (what it
   is, what was checked, the recommendation, what "yes" does), one item per cut, ending "reply
   'yes to all', or tell me which to skip".
3. The commit gate's log goes under `~/.claude/shipkit/`, where `session-start.sh:88-104`
   already writes `plugin-root`; `SHIPKIT_HOME` is the existing override (`briefing.sh:26`).
4. The commit skill's `Verified:` line (`plugins/shipkit-workflows/skills/commit/SKILL.md`)
   stays waiting text until Sprint 35: it is an existing skill file. `Verified:` appears nowhere
   under `plugins/` or `.shipkit/` today (`git grep`).
5. `docs/design/context-cost.md:21` says the Rails overlay has "6 skills, 17,529 bytes"; it has
   four (`/bin/ls plugins/shipkit/stacks/rails/.claude/skills/`). T1 corrects it, since T1
   writes that file's new rows.
6. The input for the prune: `docs/design/smoke-audit-5.4.md` (S29-T6's 35 text-only rows),
   `docs/design/eval-ledger.tsv` (130 rows, releases 5.1.0 and 5.2.0), `scripts/evals-map.tsv`
   (78 cases), the CHANGELOG and `git log`. A requirement counts as cited wherever its
   `<slug>/REQ-N` text appears (`spec-check.sh:182-194`), so a cut check's citation moves to a
   check that still proves it, or the check is not cut.
7. Whether the owner has a real Rails application for Sprint 35 is asked then, not now.

## Out of scope

- Any paid model run, including the three runs per stack of the `verify` skill and the five
  commits through the commit skill (Sprint 35).
- A change to an existing skill, agent or rule file: setup's overlay list and its Rails count,
  the commit skill's `Verified:` line, the ship report's "Ran the change" block (Sprint 35).
- The Rails `verify` skill file (answer 1), and `verify` skills for python, go and react (plan,
  §6).
- Cutting a trap-2 case (decision 0008).
- Raising the evals ceiling or moving the evals (decision 0005).
- Switching the commit gate on anywhere: its default is `off`, and `SHIPKIT_COMMIT_GATE` is never
  set in a shell profile (plan, §5 line 8).
