# Unsetup Safety — Requirements

> Spec accepted at commit `d5db719` on fix/install-lifecycle-and-verified-findings.

Scope: the ninth finding from the 3.0.0 external review, deferred from the
[`install-lifecycle`](../install-lifecycle/spec.md) spec because redesigning a destructive
restore path deserves its own confirmation rather than a slot beside one-line edits.

## Context

`/shipkit:unsetup` restores a project to its pre-shipkit state. Today it does that by deleting
`CLAUDE.md` and the **entire** `.claude/` directory, then copying a snapshot back over the top.
The reviewer flagged this as source-verified but unexecuted; they did not run it against a real
project, and neither did I. The claims below are verified by reading `unsetup/SKILL.md` and the
`/setup` backup contract it depends on — not by destroying a project to watch it happen.

Three facts make the current design worse than it looks:

1. **`/setup` snapshots `.claude/` as it currently is** (`setup/SKILL.md:152-154`), not as it was
   before shipkit ever touched it. On a second `/setup`, the "pre-shipkit baseline" captured is
   an already-configured shipkit install.
2. **The nesting escape hatch is optional.** `setup/SKILL.md:141-144` asks preserve-or-delete.
   Choosing *delete* destroys the only true baseline, permanently and silently.
3. **Ownership data now exists.** Since 3.1.0 the installation manifest records exactly which
   paths shipkit wrote (`lib-manifest.sh`, `manifest_paths`/`manifest_owns`). `/unsetup` ignores
   it completely and still reaches for the sledgehammer.

That third fact reframes the fix. This is not "make the restore safer" — it is **remove what we
own, and keep the snapshot only as a fallback for what we cannot prove we own.**

## Requirements

### Removal scope

- **REQ-1** — Where an installation manifest exists and is not legacy, `/unsetup` shall remove
  only the paths that manifest owns, and shall not delete `.claude/` wholesale.
  *Source:* `unsetup/SKILL.md:45` deletes the directory entirely; `manifest_paths` has named the
  owned files since 3.1.0.
- **REQ-2** — If a file shipkit owns has been modified since installation, then `/unsetup` shall
  report it and ask before removing it. A user's edit to an installed rule is their work, not
  shipkit's. *(`file_sha` vs the manifest's recorded digest makes this checkable.)*
- **REQ-3** — `/unsetup` shall never remove a path outside the manifest, including anything under
  `.claude/` that another tool, another plugin, or the user created.
- **REQ-4** — `/unsetup` shall continue to leave `.shipkit/` untouched (specs and decision records
  are the user's work product). This is already correct at `unsetup/SKILL.md:47-49` — preserve it.
- **REQ-5** — Where no manifest exists, or it is a pre-3.1 legacy stamp, `/unsetup` shall fall
  back to snapshot restoration, and shall say plainly that it cannot prove which files are
  shipkit's.

### Recoverability

- **REQ-6** — Before removing or overwriting anything, `/unsetup` shall write a recovery snapshot
  of the **current** `CLAUDE.md` and `.claude/`, so an unsetup can itself be undone.
  *Source:* today's flow has no undo; configuration added since `/setup` is discarded with no
  route back.
- **REQ-7** — `/unsetup` shall show the actual removal set — the concrete list of paths, and a
  diff for `CLAUDE.md` — before asking for confirmation, rather than the current prose summary
  ("`.claude/` directory will be restored to its pre-shipkit state").
- **REQ-8** — `/unsetup` shall require explicit confirmation before any destructive step. Already
  true (`unsetup/SKILL.md:39`); preserve it, and keep the skill inline (a forked skill cannot ask).

### Baseline integrity

- **REQ-9** — When `/setup` runs on a project that already has a shipkit install, it shall
  preserve the **original** pre-shipkit baseline rather than snapshotting shipkit's own output
  over it. A baseline, once captured, is not overwritten by a later setup.
- **REQ-10** — `/setup` shall not offer an option whose effect is the silent, permanent
  destruction of the only true baseline. *Source:* the *delete* branch at `setup/SKILL.md:144`.
- **REQ-11** — Where the true baseline cannot be established (shipkit installed before this
  spec landed, baseline deleted), `/unsetup` shall say so explicitly instead of presenting a
  shipkit-era snapshot as "your pre-shipkit state".

### Hygiene

- **REQ-12** — `/setup` shall ensure `.shipkit-backup-*` is git-ignored in the project, or warn
  that it is not. *Observed:* nothing in `setup/` or `unsetup/` mentions gitignore, so a snapshot
  containing an entire `.claude/` directory — potentially including local settings — can be
  committed. This repo's own `.gitignore` covers `/.claude/` but says nothing about backups.
- **REQ-13** — The documented promise shall match the behaviour. README:316 currently says
  "your project goes back to exactly how it was", which REQ-9/REQ-11 make conditional.
  *Also:* README:220, README:312, GUIDE.md:128, GUIDE.md:149, GUIDE.md:170.

## Out of scope

- Uninstalling the plugin itself (`/plugin uninstall`) — not shipkit's to do.
- Any change to what `/setup` installs. This spec touches only backup/restore semantics.
- Migrating existing `.shipkit-backup-*` directories into a new layout: they are the user's
  data and their format is already documented. New runs adopt the new layout; old snapshots stay
  readable by the fallback path (REQ-5).

## Verification

Every requirement needs a fixture that runs against a scratch project, never a real one. The
destructive paths (REQ-1, REQ-2, REQ-6) must be proven by constructing a project, running the
removal, and asserting on what survives — the gap the reviewer correctly left open, and the
reason this spec exists rather than a patch.
