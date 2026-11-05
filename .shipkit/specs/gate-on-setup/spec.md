# Spec: What the gate says about setup (Sprint 26)

> Spec accepted at commit `03e87eb` on sprint-26/gate-on-setup (2026-11-05).
> Status: open
> Paths: plugins/shipkit/skills/ask/walk.md, plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/stacks/elixir/CLAUDE.md.append, plugins/shipkit/skills/setup/SKILL.md, plugins/shipkit/scripts/spec-check.sh, plugins/shipkit/skills/spec/SKILL.md, plugins/shipkit/skills/spec/reference.md, plugins/shipkit/scripts/setup-files.sh, plugins/shipkit/scripts/brief-verify.sh, plugins/shipkit/scripts/unsetup-remove.sh, plugins/shipkit/agents/reviewer.md, scripts/smoke.sh, docs/plans/machine-sprint-plan.md, CHANGELOG.md

## Purpose

The gate should report what the work did. On three real runs in a row, a first spec after setup
listed `CLAUDE.md` and `.gitignore` as changes beyond the spec, with nothing in them but setup's
lines: a line the user learns to skip. The record that chose this said when to stop, and that has
happened. The reviewer also has no word for a decision whose fallback exists and whose main path
does not (`field-notes-5.1.md` §9.2), and four small things the last run found are still wrong in
the product.

Source: `docs/plans/machine-sprint-plan.md` (approved 2026-11-05), G1, G2, G3, Sprint 26;
`docs/design/field-notes-5.1.md` §2.2, §6.1, §9.1, §9.2, §9.4, §10.1.

## User stories

- As the owner reading a gate report on my first spec after setup, I want setup's own lines left off
  "changes beyond the spec", so that every line there is about the work.
- As the owner, I want a decision that is half built called that, so that the mark says what the
  reviewer's words already do.
- As a user of an Elixir project, I want the Key Paths in my `CLAUDE.md` to name my app.

## Requirements (EARS)

### Four small debts (G1, S26-T1)

- **REQ-1.** The comment that opens `skills/ask/walk.md` shall say the agent cannot ask the user
  anything mid-run and cannot write files, in one sentence with one subject.
- **REQ-2.** Where `skills/ship/SKILL.md` tells the gate to `Write` the reviewer's reply, it shall
  first have the gate print the file's path with `printf`, and give `Write` the path printed; no
  sentence shall give the `Write` tool a path holding `${TMPDIR`.
- **REQ-3.** The elixir overlay's `CLAUDE.md` section shall write its Key Paths with the project's
  app name, through an `APP_NAME` placeholder: `install-stack.sh elixir` without `APP_NAME` shall
  exit 2 naming it, and with it shall leave no `<app>` in `CLAUDE.md`.
- **REQ-4.** Setup's placeholder table shall list `APP_NAME`, taken from the `app:` key of
  `mix.exs`'s `project/0`.
- **REQ-5.** When `spec-check.sh` checks a spec whose `design.md` or `tasks.md` carries a
  `> Status:` line, it shall print `STRAY-STATUS <slug> <file>` and exit 1.
- **REQ-6.** The spec skill's two lists of the findings that are gaps (`SKILL.md`, `reference.md`)
  shall name `STRAY-STATUS`.

### Setup's own lines (G2, S26-T2)

- **REQ-7.** `setup-files.sh <project-dir> record` shall write `.claude/rules/shipkit/.setup-files`,
  one line per file of `CLAUDE.md` and `.gitignore` that exists: its git blob id
  (`git hash-object`), a space, its path.
- **REQ-8.** `setup-files.sh <project-dir> check` shall print the path of each file whose blob id
  in the working tree equals its recorded one, and print nothing when no record exists.
- **REQ-9.** `brief-verify.sh` shall not report `CLAUDE.md` or `.gitignore` as `OUTSIDE` when
  `setup-files.sh check` prints it, and shall report it otherwise.
- **REQ-10.** The reviewer's "changes beyond the spec" step shall leave out `CLAUDE.md` or
  `.gitignore` when `.claude/rules/shipkit/.setup-files` lists it with the blob id
  `git hash-object <file>` prints, and shall list it otherwise.
- **REQ-11.** The setup skill shall run `setup-files.sh . record` after its last write to
  `CLAUDE.md` or `.gitignore` and before its summary.
- **REQ-12.** When `unsetup-remove.sh` removes the manifest, it shall remove `.setup-files` too.
- **REQ-13.** `run-debts`' fifth decision shall be marked superseded by this spec's record, and
  `run-debts/REQ-6` and `REQ-7` shall carry a note saying what changed.
  [untested: a record, verified by reading]

### Half built (G3, S26-T3)

- **REQ-14.** Under "Decisions not followed", the reviewer shall mark a decision `partly built`
  where some of the code it governs exists and some does not, naming each part with `path:line` or
  the file it would be in.
  > *Amends `decisions-bind/REQ-7` in place.*
- **REQ-15.** A decision marked `partly built` shall not change the verdict.

## Merge steps (not requirements)

- The sprint exit checklist with `--group reviewer`, and the full smoke suite (rule 22).
- No gate on this spec at the merge: `/shipkit:ship` runs on it at 5.2.0's release (rule 27).
- Merged untagged after a green check. The owner's cache is not touched.

## Out of scope

The test command on a pinned toolchain, the gate's searches, the headless wait and the evals' home
(Sprint 27); the run and 5.2.0 (Sprint 28); merging two `## Elixir-Specific` sections (G6); a
decision's record in the brief; telling setup's lines from the user's inside a changed `CLAUDE.md`;
any new always-on byte.
