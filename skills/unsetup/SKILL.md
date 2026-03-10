---
description: "Remove shipkit setup — restore your project to its pre-shipkit state"
user-invocable: true
argument-hint: ""
---

# /unsetup — Remove Shipkit Setup

Reverses what `/setup` did. Restores your project's `.claude/` directory and CLAUDE.md to their pre-shipkit state.

**This only undoes `/setup`.** Uninstalling the plugin itself is done via `/plugin uninstall shipkit@shipkit`.

## Step 1: Read the Manifest

Read `.claude/shipkit-manifest.json`. If it doesn't exist, tell the user:
> "No shipkit manifest found. Either `/setup` was never run, or the manifest was deleted. I can't safely determine which files to remove. You can manually delete files or run `/plugin uninstall shipkit@shipkit` to remove the plugin."

Stop here if no manifest.

## Step 2: Confirm with User

Show the user what will happen:
- List all files in `files_created` that will be **deleted**
- List all files in `files_modified` that will be **restored from backup**
- Note whether CLAUDE.md will be restored from `CLAUDE.md.pre-shipkit` or deleted

Ask: "This will remove all shipkit setup files and restore backups. Continue? (yes/no)"

**Do NOT proceed without explicit confirmation.**

## Step 3: Restore Backups

1. If `CLAUDE.md.pre-shipkit` exists, restore it to `CLAUDE.md`
2. If `.claude/settings.json.pre-shipkit` exists, restore it to `.claude/settings.json`

## Step 4: Remove Created Files

Delete every file listed in `files_created` from the manifest. These are files that didn't exist before `/setup`:
- Stack-specific rules (e.g., `.claude/rules/rails.md`, `.claude/rules/gemfile.md`)
- Stack-specific skills (e.g., `.claude/skills/new-feature/SKILL.md`)
- Stack-specific knowledge bases
- `.claude/lessons.md` (only if in `files_created`)

**Never delete files that aren't in the manifest.** The user may have added their own files to `.claude/`.

## Step 5: Clean Up

1. Remove empty directories left behind (e.g., `.claude/skills/new-feature/` if now empty)
2. Delete the manifest itself (`.claude/shipkit-manifest.json`)
3. Delete backup files (`CLAUDE.md.pre-shipkit`, `.claude/settings.json.pre-shipkit`)

## Step 6: Summary

Report what was done:
- Files deleted (count)
- Files restored from backup (count)
- What remains (plugin skills/rules still active until plugin is uninstalled)

Remind the user: "To fully remove shipkit, also run `/plugin uninstall shipkit@shipkit`."
