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

## Tranche 2 — surgical removal

- [ ] **U-5** `/unsetup`: read the manifest; build the removal set from `manifest_paths`
      → REQ-1 (DR-1)
- [ ] **U-6** Compare each owned file's `file_sha` against its recorded digest; list modified
      files individually and ask before removing them → REQ-2 (DR-1)
- [ ] **U-7** Never remove a path outside the manifest; leave `.shipkit/` untouched (already
      correct — preserve it) → REQ-3, REQ-4
- [ ] **U-8** No manifest or a legacy stamp → snapshot-restore fallback, stating plainly that
      ownership cannot be proven → REQ-5 (DR-1)
- [ ] **U-9** Confirmation shows the grouped path list + a `CLAUDE.md` diff; modified files
      always listed individually → REQ-7 (DR-4)
- [ ] **U-10** Keep the mandatory explicit confirmation and the inline (non-forked) skill
      → REQ-8

## Tranche 3 — honest documentation

- [ ] **U-11** `/unsetup` says so explicitly when the true baseline cannot be established,
      rather than presenting a shipkit-era snapshot as the pre-shipkit state → REQ-11 (DR-2)
- [ ] **U-12** Correct the restore promise where it overstates: README:220, README:312,
      README:316 ("goes back to exactly how it was"), GUIDE.md:128, GUIDE.md:149,
      GUIDE.md:170 → REQ-13

## Verification

- [ ] **U-13** Scratch-project fixtures in `smoke.sh`, each asserting on survivors → DR-5:
      - manifest-owned files removed, co-installed files under `.claude/` survive (REQ-1, REQ-3)
      - a modified owned file is reported and not removed without consent (REQ-2)
      - legacy stamp → fallback path, with the honest message (REQ-5)
      - recovery snapshot exists and contains the pre-removal state (REQ-6)
      - `.shipkit/` present before and after (REQ-4)
- [ ] **U-14** `lint.py` green; CHANGELOG entry; version lockstep across `plugin.json` ×2 +
      `marketplace.json`

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
