---
description: "Remove shipkit setup — restore your project to its pre-shipkit state"
user-invocable: true
argument-hint: ""
---

<!-- Runs INLINE (no context: fork) on purpose: this skill DELETES CLAUDE.md and
     .claude/ behind a mandatory yes/no confirmation, and forked skills cannot ask
     the user anything. A destructive confirmation must reach the user. -->

# /unsetup — Remove Shipkit Setup

Reverses what `/setup` did. Restores your project's CLAUDE.md and `.claude/` directory to their pre-shipkit state from the backup snapshot.

**This only undoes `/setup`.** Uninstalling the plugin itself is done via `/plugin uninstall shipkit@shipkit`.

## Step 1: Find the Backup

Look for a `.shipkit-backup-*` directory at the project root.

If none exists, tell the user:
> "No shipkit backup found. Either `/setup` was never run, or the backup was manually deleted. I can't safely restore without a backup. You can manually revert changes or run `/plugin uninstall shipkit@shipkit` to remove the plugin."

Stop here if no backup found.

If multiple `.shipkit-backup-*` directories exist (shouldn't happen, but be safe), use the most recent one (latest timestamp).

## Step 2: Show What Will Happen

Read the backup contents and tell the user exactly what will be restored:

> **Restoring from `.shipkit-backup-<ts>/`:**
> - CLAUDE.md will be restored (if backup contains one) / deleted (if backup has none)
> - .claude/ directory will be restored to its pre-shipkit state
> - [If backup contains `previous-backup/`:] An older shipkit backup will also be restored to the project root
>
> **Continue? (yes/no)**

**Do NOT proceed without explicit "yes" confirmation.**

## Step 3: Restore

1. **Remove current shipkit files:**
   - Delete `CLAUDE.md`
   - Delete the `.claude/` directory entirely
   - **Never touch `.shipkit/`** — specs and decision records are your project's own work
     product (they version with the code, not with shipkit config). `/unsetup` removes shipkit's
     configuration, not the knowledge you built with it. Leave `.shipkit/` exactly as it is.

2. **Restore from backup:**
   - If backup contains `CLAUDE.md`, copy it to project root
   - If backup contains `.claude/`, copy it to project root
   - (Files that didn't exist before `/setup` simply won't be in the backup, so they get removed cleanly)

3. **Restore nested backup (if present):**
   - If the backup contains a `previous-backup/` directory, move it back to the project root with its original name (`.shipkit-backup-<original-ts>/`)

4. **Delete the backup directory** (`.shipkit-backup-<ts>/`) — it's been fully restored.

## Step 4: Summary

Report what was done:
- Files restored (CLAUDE.md, .claude/ contents)
- Whether an older backup was also restored
- Current state: "Your project is back to its pre-shipkit state."

Remind the user:
> "To fully remove shipkit, also run `/plugin uninstall shipkit@shipkit`."
> "If you want to use shipkit again, run `/setup` — it will create a fresh backup."
