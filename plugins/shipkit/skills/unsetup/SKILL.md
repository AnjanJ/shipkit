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

## Step 0a: Locate the plugin

Step 3 runs a script shipped with the plugin, so find its directory first — same order as
`/shipkit:setup`:

1. The context line `shipkit: plugin root is <path>` printed by the shipkit session hook at the
   start of this session. Use that path.
2. Else read `~/.claude/shipkit/plugin-root` (the hook also writes it there).
3. Else stop and tell the user: "The shipkit session hook has not run yet — restart Claude Code
   (or start a new session) and run `/shipkit:unsetup` again." Do not guess a path.

Call it `<root>` below, and sanity-check it: `<root>/scripts/unsetup-remove.sh` must exist. If
it does not, the installed plugin predates this version — fall back to the snapshot path in
Step 3 and say so.

## Step 0b: Take a recovery snapshot — before anything else

**Do this before reading backups, before asking anything, before touching a single file.**

Copy the **current** `CLAUDE.md` and `.claude/` to `.shipkit-recovery-<YYYYMMDD-HHMMSS>/`.

Why first: everything below removes or overwrites files, and `.claude/` is commonly
git-ignored — so git is not a safety net here. Without this, configuration added since
`/setup`, or a wrong-snapshot restore, is gone with no route back. `/unsetup` is precisely the
moment a user discovers they wanted something they just deleted.

Tell them it exists, and that deleting it is safe once they are happy:
> "Recovery snapshot written to `.shipkit-recovery-<ts>/` — if this goes wrong, everything you
> had a moment ago is in there. Safe to delete once you're happy."

If the copy fails, **stop**. Do not proceed with an unrecoverable removal.

## Step 1: Find the Backup

Look for a `.shipkit-backup-*` directory at the project root.

If none exists, tell the user:
> "No shipkit backup found. Either `/setup` was never run, or the backup was manually deleted. I can't safely restore without a backup. You can manually revert changes or run `/plugin uninstall shipkit@shipkit` to remove the plugin."

Stop here if no backup found.

If multiple `.shipkit-backup-*` directories exist (shouldn't happen, but be safe), use the most recent one (latest timestamp).

## Step 2: Show What Will Happen

Read the backup contents and tell the user exactly what will be restored:

> **Restoring from `.shipkit-backup-<ts>/`** (snapshot taken `<date>`):
> - CLAUDE.md will be restored (if the backup contains one) / deleted (if it does not)
> - `.claude/` will be replaced with the contents of that snapshot — **anything added to it
>   since then is removed**, including files shipkit never installed
> - `.shipkit/` is untouched (your specs and decision records)
> - [If backup contains `previous-backup/`:] An older shipkit backup will also be restored to the project root
>
> Already saved to `.shipkit-recovery-<ts>/`, and kept afterwards: everything you have right now.
>
> **Continue? (yes/no)**

Say plainly what the snapshot *is*, rather than calling it "pre-shipkit": if
`.shipkit-baseline/.captured` records `pre-existing-shipkit=true`, or there is no baseline,
add: "Note: shipkit may already have been set up when this snapshot was taken, so it is not
necessarily a pristine pre-shipkit state."

**Do NOT proceed without explicit "yes" confirmation.**

## Step 3: Restore

1. **Remove shipkit's files — and only those.** Run the shipped script; do not delete
   `.claude/` by hand:

   ```bash
   "<root>/scripts/unsetup-remove.sh" . --yes
   ```

   It reads the installation manifest and removes exactly the paths shipkit installed, then
   prunes the directories it emptied. Anything else under `.claude/` — another plugin's agents,
   your `settings.local.json`, whatever you added after `/setup` — is left untouched, which the
   old "delete the whole directory and restore a snapshot over it" flow could not promise.

   - Run it **without** `--yes` first and show the user the removal set (that is Step 2).
   - A file you edited since installation is **kept** and reported. Only pass `--force` if the
     user explicitly says to remove their edits too.
   - Exit code 2 means shipkit could not prove ownership (no manifest, or a pre-3.1 stamp).
     Do not fall back to deleting `.claude/` — go to the snapshot path below and say plainly
     that ownership could not be established.
   - **Never touch `.shipkit/`** — specs and decision records are your project's own work
     product (they version with the code, not with shipkit config). The script already excludes
     it; do not remove it by hand either.

   Once the rules are gone the session hook resumes injecting the always-on rules.

2. **Delete `CLAUDE.md`**, then restore from the backup:
   - If the backup contains `CLAUDE.md`, copy it to the project root
   - If the backup contains a `.claude/` directory, restore **only** files that are missing
     after step 1 — do not copy the whole tree back over what survived, or you will resurrect
     shipkit's own files and undo the removal you just did.
   - (Files that did not exist before `/setup` simply are not in the backup.)

   **Fallback — no manifest (exit code 2).** Shipkit cannot tell which files are its own here.
   Say so, show the user what the snapshot contains, and let them choose: restore the snapshot
   wholesale (the old behaviour — it will discard anything added since), or stop and remove
   files by hand. Do not pick the destructive option on their behalf.

3. **Restore nested backup (if present):**
   - If the backup contains a `previous-backup/` directory, move it back to the project root with its original name (`.shipkit-backup-<original-ts>/`)

4. **Keep the backup directory.** Do not delete `.shipkit-backup-<ts>/` — it is the only record
   of the state you just restored from, and removing it as a side effect of a command the user
   ran for a different reason is exactly the silent, unrecoverable loss this flow is meant to
   avoid. Tell them it is there and that deleting it is safe once they are happy.

## Step 4: Summary

Report what was done:
- Files restored (CLAUDE.md, .claude/ contents)
- Whether an older backup was also restored
- **The two directories still on disk**, and that both are safe to delete:
  `.shipkit-recovery-<ts>/` (everything you had before this command ran) and
  `.shipkit-backup-<ts>/` (what you restored from)
- Current state — and be accurate about which state it is:
  - If `.shipkit-baseline/.captured` exists **without** `pre-existing-shipkit=true`:
    "Your project is back to its pre-shipkit state."
  - If it records `pre-existing-shipkit=true`, or there is no baseline at all: say what you
    actually did — "Restored from the snapshot taken at `<ts>`." — and add: "Shipkit was already
    set up in this project before the baseline was captured, so this is that earlier configured
    state, not a pristine pre-shipkit one." Do not claim more than the artifacts support.

Remind the user:
> "To fully remove shipkit, also run `/plugin uninstall shipkit@shipkit`."
> "If you want to use shipkit again, run `/setup` — it will create a fresh backup."
