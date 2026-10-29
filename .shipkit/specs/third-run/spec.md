# Spec: The window and a third project (Sprint 19, release 4.12.0)

> Spec accepted at commit `b24cef2` on sprint-19/third-run (2026-10-11).
> Status: open
> Paths: plugins/shipkit/scripts/, plugins/shipkit/hooks/, plugins/shipkit/evals/README.md, scripts/, docs/design/, ROADMAP.md, CHANGELOG.md, README.md, .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json

## Purpose

Close what the second-run plan left for its last sprint. Every session started with
`--plugin-dir` rewrites `~/.claude/shipkit/plugin-root` and nothing puts it back: the smoke
runner restores it from its own trap, and every other such session — an eval, a real run, a
gate — leaves the owner's sessions reading a scratch path until someone writes the cache
path back by hand (rule 17; the 4.10.0 incident, where an older session's hook put back a
directory just removed). The session that opened the window closes it: start saves the value
it is about to overwrite, end puts it back if that root still exists. The evals README quotes
the sandbox's refusal of `.pre-commit-config.yaml` from documentation because no trace of the
refusal survived; one probe captures the text. Then shipkit's loop runs a third time, headless,
on a project of the third stack, with nothing fixed and every awkwardness written down in the
shape the first two runs used, and the roadmap the plan after starts from is written from the
three runs, the three releases and Sprint 18's numbers.

Source: `docs/plans/second-run-sprint-plan.md`, Sprint 19 (S19-T0 to S19-T4), decisions E15
to E18 (F3); `CHANGELOG.md` 4.7.0 and 4.10.0 "What using it for real showed";
`plugins/shipkit/evals/README.md` "What a case cannot ask for (4.7.0)";
`docs/design/field-notes-4.3.md`, `docs/design/field-notes-4.9.md`; `ROADMAP.md` "Still open
after Sprint 16".

## User stories

- As the owner running shipkit from the cache while a sprint runs evals and real runs from a
  checkout, I want each of those sessions to leave `plugin-root` as it found it, so that a
  session I start in the middle of a run reads my plugin, not a scratch copy.
- As someone writing an eval case, I want the README to show me the refusal I would get for
  a protected file name, so that I recognise it in a trace before I blame the case.
- As the owner, I want the loop run end to end on a third project of a third stack with
  nothing patched on the way, so that the next plan starts from what the tool does to a
  project it has never seen, not from what I remember.

## Requirements (EARS)

### A session puts `plugin-root` back (S19-T1)

> Amended 2026-10-30. The four requirements as approved on 2026-10-11 (a `plugin-root.prev`
> saved by start, a `SessionEnd` hook that writes it back, smoke check 62 on the four branches,
> a README note on which sessions restore) were paid the other way before this branch merged:
> PR #21 (`fe02c68`, merged to `main` 2026-10-22) made the start hook write `plugin-root` only
> from the installed root, so nothing is overwritten and nothing needs putting back. The branch
> carried the hook pair at `a690f14`; it is dropped, and these requirements now state the rule
> that shipped. The design record says why.

- **REQ-1.** When `session-start.sh` runs from a root under
  `${CLAUDE_CONFIG_DIR:-~/.claude}/plugins/` (the installed plugin), it shall write that root
  to `~/.claude/shipkit/plugin-root`; when it runs from any other root (a `--plugin-dir`
  checkout, an eval sandbox, a smoke copy) it shall write that root to `plugin-root.dev` and
  to `plugin-root` only while no `plugin-root` exists.
- **REQ-2.** The plugin shall register no `SessionEnd` hook and ship no `session-end.sh`; the
  start hook shall print the plugin's version on its own line (`shipkit: version <ver>`, from
  the root's `plugin.json`) under the unchanged root line.
- **REQ-3.** The smoke suite shall hold a check that runs the start hook directly under a
  scratch `HOME` and asserts: a checkout root with no file yet writes both files; a cache root
  writes `plugin-root`; a checkout root after a cache root leaves `plugin-root` alone and writes
  `plugin-root.dev`; the version line is present; and no `SessionEnd` hook or `session-end.sh`
  exists.
- **REQ-4.** The release's CHANGELOG entry and the ROADMAP's "mid-run `plugin-root` window"
  item shall say that no session overwrites the installed path any more, and that rule 17's
  write-back stays only for a checkout-only user. [untested: prose, verified by reading]

### The refusal text, captured (S19-T2)

- **REQ-5.** The evals README's "What a case cannot ask for" paragraph shall quote the
  `tool_result` text a run receives when it writes `.pre-commit-config.yaml` at the workspace
  root, read from one probe's trace, or shall say the trace held no refusal and what it held
  instead. [untested: prose, verified by reading; smoke check 57 keeps the paragraph]

### The third real run (S19-T3)

- **REQ-6.** `docs/design/field-notes-4.12.md` shall hold the third run on the project the
  owner named — the repository, its stack and its `git status --short` before the first step;
  then the hook, setup, product, intake on the owner's request, spec, one task through
  `brief.sh` from a clean tree and `brief-verify.sh`, and the gate, in order, each written as
  Asked for / Produced / Took / Awkward / Whose fault / Evidence; and one line per decision
  E1 to E7 saying whether it held on this project. [untested: prose, verified by reading]
- **REQ-7.** Nothing the run finds shall be changed in this sprint; the ROADMAP's open list
  shall hold one item per finding, each citing the notes' section, and the fate of branch
  `shipkit/real-run-3` and its worktree shall be recorded. [untested: prose, verified by
  reading]

### The roadmap for the plan after (S19-T4)

- **REQ-8.** `ROADMAP.md` shall mark Sprints 17 to 19 shipped in a table as the portfolio
  plan's, and shall hold a "Still open after Sprint 19" list — the third run's findings,
  Sprint 18's readings that named something, and what the three releases' "What using it for
  real showed" sections name — every item citing a file and a section. [untested: prose;
  lint check 16 holds the status line]

## Release steps (not requirements)

- F3: branch `shipkit/real-run-3` and its worktree, after the notes, its own yes, the log read
  first; F4: this sprint's branch after the tag, its own yes; F5: the owner's cache updated
  to 4.12.0, its own yes; the `4.9.0` and `4.10.0` cache directories offered as rows beside
  F5, each its own yes, only after the interactive session's hook line reads `4.11.0` or
  later.
- The CHANGELOG's entry says which sessions no longer need rule 17's write-back; the plan's
  text is not edited.
- The gate (`/shipkit:ship third-run`) answers `READY`; the report is committed.
- Release as 4.12.0; the sprint exit checklist holds (evals at 59 cases); the release run is
  recorded in `docs/design/eval-history.md`; the pull request is merged after a green check;
  tag `v4.12.0`.

## Out of scope

Fixing anything the third run finds; the three findings that are `office_bestie`'s own;
`agents/eve.md`, `agents/grandfather.md`, `agents/reviewer.md`, every rule file and skill;
the two graders 4.11.0 found narrower than their line; a step-0 sentence for `eve`; a
`SessionEnd` hook that does anything but restore `plugin-root`; the smoke runner's own save
and restore; a new eval case; any deletion E18 does not name, and nothing in E18 without its
own yes.
