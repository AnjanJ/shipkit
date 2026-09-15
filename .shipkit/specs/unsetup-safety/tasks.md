# Unsetup Safety — Tasks

> Spec accepted at commit `d5db719` on fix/install-lifecycle-and-verified-findings.

Ordered so that nothing destructive ships before the thing that makes it recoverable.
Each task cites the requirement it satisfies. One atomic commit per task.

## Tranche 1 — recoverability first ✅

Nothing in later tranches is safe to land without these.

- [x] **U-1** Write `.shipkit-recovery-<ts>/` (current `CLAUDE.md` + `.claude/`) before any
      destructive step; name it in the summary and state it is safe to delete → REQ-6 (DR-3)
      *(added as `/unsetup` Step 0 — before reading backups or asking anything; aborts if the
      copy fails rather than proceeding unrecoverably)*
- [x] **U-2** `/setup`: capture an immutable `.shipkit-baseline/` on first setup only; never
      overwrite it on later runs → REQ-9 (DR-2)
      *(records `pre-existing-shipkit=true` in `.captured` when `.claude/rules/shipkit/` already
      exists, so REQ-11 can say so instead of overclaiming)*
- [x] **U-3** `/setup`: remove the *delete* branch that destroys the only true baseline;
      keep rolling snapshots nesting as they do → REQ-10 (DR-2)
- [x] **U-4** `/setup`: ensure `.shipkit-backup-*`, `.shipkit-baseline/` and
      `.shipkit-recovery-*` are git-ignored, or warn that they are not → REQ-12
      *(offers to add them; never creates a `.gitignore` uninvited)*

**Verification note.** These are skill-prose changes with no executable path, so they are
verified by lint plus review of the documented steps — not by fixtures. The destructive
fixtures (U-13) belong with Tranche 2, where surgical removal actually lands and there is
something to assert on.

## Tranche 2 — surgical removal ✅

Implemented as `plugins/shipkit/scripts/unsetup-remove.sh`, written **after** the fixtures so
the contract was fixed first.

- [x] **U-5** Removal set built from `manifest_paths`; `/unsetup` Step 3 now calls the script
      instead of deleting `.claude/` by hand → REQ-1 (DR-1)
- [x] **U-6** `file_sha` vs the recorded digest splits owned files into clean/modified;
      modified files are listed individually and **kept** unless `--force` → REQ-2 (DR-1)
- [x] **U-7** Never steps outside the manifest; `.shipkit/` untouched → REQ-3, REQ-4
- [x] **U-8** No manifest or a legacy stamp → exit 2, remove nothing, say plainly that
      ownership cannot be proven; the skill falls back to the snapshot path and asks rather
      than choosing the destructive option → REQ-5 (DR-1)
- [x] **U-9** Dry run is the **default**: the script prints the grouped removal set and changes
      nothing unless `--yes` is passed → REQ-7 (DR-4)
- [x] **U-10** Mandatory confirmation and the inline (non-forked) skill preserved → REQ-8

## Tranche 3 — honest documentation ✅

- [x] **U-11** `/unsetup` reports which state it actually restored, keyed on
      `pre-existing-shipkit=true` in `.shipkit-baseline/.captured` → REQ-11 (DR-2)
      *(landed with Tranche 1)*
- [x] **U-12** Corrected the overstated restore promise: README:316 ("goes back to exactly how
      it was"), README:312, GUIDE.md:128, the "How backups work" block (which still described
      the removed preserve-or-delete prompt), and the `/unsetup` step list (which still said it
      deletes `.claude/` wholesale and deletes the backup afterwards) → REQ-13

## Verification

- [x] **U-13** Scratch-project fixtures in `smoke.sh` (check 17), written **before** the
      implementation so the contract is fixed first → DR-5. Each builds a project and asserts
      on survivors:
      - 17a owned files removed, foreign files under `.claude/` survive (REQ-1, REQ-3);
        the manifest itself removed last (it cannot own itself — an orphan would make the
        session hook warn "incomplete install" forever); empty dirs pruned, populated ones kept
      - 17b `.shipkit/` untouched (REQ-4)
      - 17c a locally modified owned file is reported and kept; `--force` removes it (REQ-2)
      - 17d legacy stamp → refuse, non-zero exit, remove nothing, say why (REQ-5)
      - 17e dry run is the default; `--yes` is required to remove (REQ-7)

      **Contract these fix for `scripts/unsetup-remove.sh`:** `unsetup-remove.sh <proj>
      [--yes] [--force]`, dry-run by default, non-zero exit on a legacy stamp, manifest
      deleted last, prune only genuinely-empty directories.

      *Verified failing first:* run against the current tree, check 17 reports
      "scripts/unsetup-remove.sh does not exist (fixtures written first, by design)".
- [x] **U-14** `lint.py` 0 errors / 0 warnings; CHANGELOG sections added to the (unreleased)
      3.1.0 entry — no new version invented, nothing is tagged yet — and its "Known gaps"
      paragraph corrected, since it claimed `/unsetup` still deletes `.claude/`. Version
      lockstep unchanged at 3.1.0 across `plugin.json` ×2 + `marketplace.json`.
      `unsetup-remove.sh` added to lint's required-scripts list so a missing executable bit
      cannot ship silently.

## Gap found and closed during implementation

`/unsetup` referenced `"<root>/scripts/unsetup-remove.sh"` but had no way to resolve `<root>` —
unlike `/setup`, it has no "locate the plugin" phase, so the skill was telling Claude to run a
path it could not construct. Added Step 0a with the same three-step resolution `/setup` Phase 0
uses (hook context line → `~/.claude/shipkit/plugin-root` → stop, do not guess), sanity-checked
against `unsetup-remove.sh` so an older installed plugin falls back to the snapshot path.

## Risk note

DR-1 makes the manifest load-bearing for a destructive operation: a manifest defect now deletes
the wrong file rather than mis-reporting freshness. U-1 (recovery snapshot) is sequenced first
for exactly that reason, and U-6/U-7 are the guards. If U-13's fixtures cannot be made to pass
convincingly, the correct outcome is to keep snapshot-restore primary and narrow it with the
manifest (DR-1 alternative 1) rather than ship surgical removal on unproven ownership.

## Deferred

- Migrating existing `.shipkit-backup-*` directories to the new layout — user data, already
  documented; the fallback path keeps reading them.
- Anything touching what `/setup` installs. This spec is backup/restore semantics only.
