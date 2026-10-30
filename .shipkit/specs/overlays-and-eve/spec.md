# Spec: What a set-up project pays (Sprint 21, untagged)

> Spec accepted at commit `0615060` on sprint-21/overlays-and-eve (2026-10-30).
> Status: open
> Paths: plugins/shipkit/scripts/install-stack.sh, plugins/shipkit/scripts/unsetup-remove.sh, plugins/shipkit/skills/setup/, plugins/shipkit/stacks/, plugins/shipkit/agents/eve.md, plugins/shipkit/skills/ask/, .shipkit/decisions/, docs/design/, scripts/smoke.sh, GUIDE.md, README.md, CHANGELOG.md

## Purpose

Sprint 20 cut what every session pays. A project that ran `/shipkit:setup` pays more: on a
Rails project the installer copies six skills into `.claude/skills/` (17,529 bytes on disk,
six listings in every session there), appends a stack section to `CLAUDE.md` that loads whole
every session, and installs two rules with no `paths:` line that load always. And every call
to `eve` carries a 17,010-byte prompt, about a third of which no case exercises. This sprint
makes the set-up project pay for its stack's traps and nothing else — the overlay skills
behind a flag, the appends and the two unscoped rules audited line by line with the owner's
yes per cut, the eleven overlay skills measured against the loop they predate — and trims
`eve`'s prompt by the audit's one arm and its clause.

Source: `docs/plans/thinning-sprint-plan.md` (approved 2026-10-30), §0, W6–W9, Sprint 21;
`docs/design/trim-audit-eve.md`; `.shipkit/decisions/0003-overlay-skills-home.md`;
`docs/design/field-notes-4.12.md` §2.2.

## User stories

- As someone setting up shipkit on a Rails project, I want the rules and the `CLAUDE.md`
  section installed and the six overlay skills offered, not imposed, so that my skill list
  carries what I asked for.
- As the owner, I want every line of a stack section that loads into every session on a
  set-up project to be kept for a reason I can read, so that the appends stop being the
  template with its alternatives left in.
- As a user of `/shipkit:ask --all`, I want `eve` to carry only what her five cases show she
  uses, so that each call costs less and answers no worse.

## Requirements (EARS)

### Overlay skills behind a flag (S21-T1, W6)

- **REQ-1.** When `install-stack.sh <plugin-root> <stack> [project-dir] KEY=value …` runs
  without `--with-skills`, it shall install the overlay's rules and append its `CLAUDE.md`
  section and shall copy no skill into the project's `.claude/skills/`, and the manifest
  shall list no skill.
- **REQ-2.** When `install-stack.sh` runs with `--with-skills` before its positional
  arguments, it shall install the overlay's skills as before, listed in the manifest, and its
  positional contract shall be unchanged.
- **REQ-3.** When `/shipkit:setup` detects an overlay that ships skills, it shall ask once
  whether to install them, naming their count and that they are listed in every session of
  the project, and pass the flag accordingly; in a non-interactive run it shall take the
  default (no skills) and say so.
- **REQ-4.** When `/shipkit:setup remove` runs, it shall remove exactly what the manifest
  lists, whether or not skills were installed.

### The appends and the two unscoped rules, audited (S21-T2, W7)

- **REQ-5.** `docs/design/trim-audit-overlays.md` shall hold one row per line of the ten
  `CLAUDE.md.append` files and of `stacks/rails/.claude/rules/rails.md` and
  `stacks/react/.claude/rules/react.md`, each with a verdict by the 4.0 rule — (a) owner-
  specific value, (b) a trap, (c) measured — and a reason, the python append's rows first
  (`field-notes-4.12.md` §2.2). [untested: prose, verified by reading]
- **REQ-6.** Where a row's verdict is `trim` and the owner has said yes, the line shall be
  out of the shipped file; where the owner has not, it shall stay and the row shall say
  "kept on the owner's word". [untested: the owner's decisions; the file state is read]
- **REQ-7.** Where a glob fits what `rails.md` or `react.md` says, the rule shall carry a
  `paths:` line and load only on a matching edit; otherwise it shall stay unscoped and the
  audit shall say why.

### The eleven overlay skills against the loop (S21-T3, W8)

- **REQ-8.** The audit shall hold, for each of the eleven overlay skills, the core or
  workflows skill or rule it duplicates with the two texts' lines side by side, and a verdict:
  `cut` or `keep behind the flag`. [untested: prose, verified by reading]
- **REQ-9.** Where the owner has said yes to a `cut`, the skill's directory shall be gone
  from `stacks/<overlay>/.claude/skills/` and `install-stack.sh` shall install nothing for it.
- **REQ-10.** `.shipkit/decisions/0004-overlay-skills-flag.md` shall be a five-part record
  with a concrete reversal condition, and `0003-overlay-skills-home.md` shall carry a line
  saying it is amended by 0004 and shall not be deleted. [untested: prose, verified by
  reading and by `decision-check.sh`]

### `eve`'s prompt by the audit's clause (S21-T4, W9)

- **REQ-11.** The five `eve` cases (`eve/jobs`, `eve/payments`, `eve/why`,
  `eve/why-reworded`, `digest/attention`) shall hold their 4.12.0 counts on the trimmed
  `agents/eve.md`, with `map_read` 0 for `jobs` and `payments` and 3 of 3 for `why`, or the
  candidate whose return restores a dropped count shall be back in the file.
- **REQ-12.** `agents/eve.md` shall be at most 12,067 bytes where the arm holds; where it
  does not, the record shall carry the bisection and the file's size.
  > *Amended 2026-10-30 (W9's STOP, the owner's word):* the ceiling was 11,500, the audit's
  > estimate. The arm as measured is 12,067 bytes, 510 of them frontmatter comments the model
  > never receives, and every case held on that exact file (`docs/design/eval-results-5.0.md`
  > §3). Smoke check 70 now reads the size, so the requirement carries no waiver.
- **REQ-13.** When `/shipkit:ask --all matrix <x>` or `/shipkit:ask --all consolidate` is
  invoked, the request handed to `eve` shall carry the report's shape from the `ask` skill's
  `reports.md`, and the reply shall have that shape.
  > *Amended 2026-10-30 (W9's STOP, the owner's word):* this said the `ask` skill's text,
  > meaning `SKILL.md`. There the shapes would load 1,354 bytes into the main session on every
  > `/shipkit:ask`, grandfather questions too; `reports.md` is read on these two routes only.

## Out of scope

The three always-on rules and the hook (Sprint 20); the run again and 5.0.0 (Sprint 22);
`agents/grandfather.md`; `eve.md`'s step 0, step 4's measured sentence and the digest shape;
any grader; a new case for the matrix or consolidation shapes; cutting an overlay skill, an
append line or a rule line without the owner's yes.
