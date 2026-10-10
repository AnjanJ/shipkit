# Spec: The run's debts (Sprint 17, release 4.10.0)

> Spec accepted at commit `3d1e73f` on sprint-17/run-debts (2026-10-10).
> Status: open
> Paths: plugins/shipkit/scripts/, plugins/shipkit/skills/setup/, plugins/shipkit/skills/ship/, plugins/shipkit/agents/, scripts/, docs/plans/, docs/design/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Pay what the second real run found. On `office_bestie` (`docs/design/field-notes-4.9.md`),
setup appended a second `## Elixir-Specific` section under a heading the project already had,
said nothing about three rule files of the same name beside its own, and moved a backup git
tracked so the tree showed fourteen deletions; `brief-verify` counted those deletions as the
agent's because nothing said to hand a brief over from a clean tree; the reviewer called
setup's files "beyond the spec" and cited diff positions as file lines; and the gate
condensed the reviewer's reply where its own requirement asks for it pasted. Each is fixed
where it lives — four scripts, two skills, one agent — with a smoke check written first. The
one finding that is the platform's (a wait sentence that leaks into a headless reply) is
closed by record, with the quotes and the condition that reopens it. Two cache directories
the owner no longer runs are removed, each on its own yes.

Source: `docs/plans/second-run-sprint-plan.md`, Sprint 17 (S17-T0 to S17-T5), decisions E1
to E8 and E18 (F1, F2); `docs/design/field-notes-4.9.md` §2.1, §2.2, §2.3, §4.1, §8.1, §9.1,
§9.2, §9.3, §9.4; `ROADMAP.md` "Still open after Sprint 16".

## User stories

- As a user running `/shipkit:setup` on a project that has its own conventions, I want setup
  to tell me when its section, its rules or its backup collide with mine, and to touch none of
  mine, so that one run leaves my `CLAUDE.md`, my rules and my git tree as I can account for.
- As a user handing a task to an agent, I want the brief to warn me when the tree is already
  dirty, and the verifier to ignore the files setup wrote, so that an OUTSIDE line means the
  agent went outside.
- As a user reading a ship report, I want the reviewer's reply as the reviewer wrote it, with
  line numbers I can open, so that the one line I click is the one it meant.

## Requirements (EARS)

### Setup sees the heading (S17-T1)

- **REQ-1.** When `install-stack.sh` appends a stack's `CLAUDE.md` section and the project's
  `CLAUDE.md` already holds a line equal to that section's first `## ` heading outside
  shipkit's own markers, the installer shall write the section under its markers and record
  its sha as it does today, and shall print to stderr one line that names the heading and
  `/shipkit:update-rules`; when no such line exists, it shall print no such line and
  `CLAUDE.md` shall hold the heading once.
- **REQ-2.** The setup skill's stack phase shall tell the model to relay the installer's
  heading line in its reply and show the two sections' diff, and shall not tell it to edit
  either section.

### Setup names a same-named rule and leaves a tracked backup alone (S17-T2)

- **REQ-3.** When `install-rules.sh` finds a `*.md` file directly under `.claude/rules/`
  whose basename matches a rule it installs, it shall print one line naming every such file
  and saying both load on the same paths, and shall not change, move or remove any of them;
  when none matches, it shall print no such line.
- **REQ-4.** The setup skill's backup phase shall tell the model to ask git whether an older
  `.shipkit-backup-*` directory is tracked (`git ls-files --error-unmatch`) before nesting
  it, to leave a tracked one at the project root and name it in the reply, and to nest an
  untracked one as before.

### The brief warns; setup's files are allowed (S17-T3)

- **REQ-5.** When `brief.sh` prints a brief and `git status --short` in the project is not
  empty, it shall print to stderr one line `brief: N file(s) already differ from HEAD;
  brief-verify will count them`, N being that count, and the brief on stdout shall be
  unchanged; when the tree is clean or the project is not a git repository, it shall print no
  such line.
- **REQ-6.** `brief-verify.sh` shall treat every path under `.claude/rules/shipkit/` and
  `.shipkit-baseline/` as inside a task's files, and shall still report a changed `CLAUDE.md`
  or `.gitignore` as OUTSIDE.
- **REQ-7.** The reviewer's "changes beyond the spec" step shall name `.claude/rules/shipkit/`
  and `.shipkit-baseline/` as not beyond the spec, and `CLAUDE.md` and `.gitignore` as
  reported even when setup wrote them.

### The reviewer cites tree lines; the gate pastes its reply (S17-T4)

- **REQ-8.** The reviewer's instructions shall say that a `MET` citation's `path:line` is the
  line in the working tree as `grep -n` prints it, never a position inside a diff hunk.
- **REQ-9.** The ship skill's step 4 shall write the reviewer's reply to
  `${TMPDIR:-/tmp}/shipkit-ship-review.out` and paste the report's review block from that
  file, so that the report holds the reviewer's `## Review:` heading, one row per requirement,
  its `Requirements:` count line and its `VERDICT:` line as written; the file shall be removed
  with the gate's other scratch files.

### Closed by record; the cache (S17-T5)

- **REQ-10.** The sprint's `design.md` shall record the leaked wait sentence as closed by
  record, with the three quotes (`field-notes-4.9.md` §4.1, §9.3; `CHANGELOG.md` 4.9.0) and
  the condition that reopens it, and the ROADMAP's item shall point to the record. [untested:
  prose, verified by reading]
- **REQ-11.** The ROADMAP shall record the fate of the cache directories `4.6.0` and `4.7.0`
  under `~/.claude/plugins/cache/shipkit/shipkit/` — removed on the owner's yes, with the
  command and its output in the commit message, or kept. [untested: prose, verified by
  reading]

## Release steps (not requirements)

- F1, F2: the two cache directories, each its own yes at S17-T5, each only after the owner's
  interactive session's hook line reads `4.9.0`; F4: this sprint's branch after the tag, its
  own yes; F5: the owner's cache updated to 4.10.0, its own yes.
- The gate (`/shipkit:ship run-debts`) answers `READY`; the report is committed.
- Release as 4.10.0; the sprint exit checklist holds; the release run (58 cases) is recorded
  in `docs/design/eval-history.md`; the pull request is merged after a green check; tag
  `v4.10.0`.

## Out of scope

The graders and `eve` (Sprint 18); the `SessionEnd` hook, the refusal text and the third real
run (Sprint 19); `agents/eve.md`, `agents/grandfather.md`, every rule file; the three findings
that are `office_bestie`'s own; `brief-verify.sh --since`; a gate that re-checks `MET`
citations; a "do not narrate waiting" sentence in any skill; overlay rules in E2's comparison;
any deletion F1 and F2 do not name.
