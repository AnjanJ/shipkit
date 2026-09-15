# Unsetup Safety — Design

> Spec accepted at commit `d5db719` on fix/install-lifecycle-and-verified-findings.

The approach, as decision records. One fork in the road per record.

---

## DR-1 — Removal is manifest-driven; snapshot restore becomes the fallback

**Context.** REQ-1/REQ-5. Today `/unsetup` deletes `CLAUDE.md` and all of `.claude/`, then copies
a snapshot back (`unsetup/SKILL.md:43-54`). That was the only option in 3.0, when shipkit had no
record of what it had written. Since 3.1.0 the installation manifest names every owned path, so
"delete everything and hope the snapshot is right" is no longer the best available design — it is
just the old one.

**Alternatives.**
1. *Keep snapshot-restore primary; use the manifest only to narrow the delete set.* Smaller change.
2. **Manifest-driven removal primary; snapshot restore only where ownership is unprovable.**
3. *Manifest only, no snapshot at all.* Simplest, but strands every pre-3.1 install.

**Case for (2).** It removes what shipkit put there and nothing else, which is what the user
actually asked for. It never touches a co-installed tool's files under `.claude/`, never discards
configuration added after `/setup`, and degrades honestly: no manifest means the old path, stated
as such. It also makes `/unsetup` correct on a project where the snapshot is missing or stale —
the common real-world case the current design handles worst.

**Case against.** Two code paths to maintain and test, and the manifest becomes load-bearing for
a *destructive* operation, so a manifest bug now deletes the wrong file rather than merely
mis-reporting freshness. That raises the stakes on `lib-manifest.sh` considerably. Mitigated by
REQ-2 (ask before removing a modified file), REQ-3 (never step outside the manifest) and REQ-6
(recovery snapshot first), but the risk is real and worth naming rather than hiding.

**Decision.** Manifest-driven removal as the primary path; snapshot restore retained for legacy
and no-manifest installs. *I would reverse this if* a manifest defect ever caused a wrong
deletion in practice — at which point removal should require snapshot corroboration (remove only
paths that are both manifest-owned *and* absent from the pre-shipkit snapshot).

---

## DR-2 — Capture the baseline once, immutably, separate from rolling snapshots

**Context.** REQ-9/REQ-10/REQ-11. `/setup` snapshots `.claude/` *as it currently is*. Run it a
second time and the "pre-shipkit baseline" is an already-configured shipkit install. The
`previous-backup/` nesting preserves the older snapshot only if the user picks *preserve*;
picking *delete* destroys the true baseline permanently and silently.

**Alternatives.**
1. *Keep nesting, remove the delete option.* Minimal change, but the baseline is then buried N
   levels deep after N setups and recovering it means walking the chain.
2. **A separate `.shipkit-baseline/`, written once and never overwritten**, alongside the existing
   rolling `.shipkit-backup-<ts>/`.
3. *Detect shipkit-era content and filter it out of the snapshot.* Heuristic, and it would have
   to guess about files shipkit does not own.

**Case for (2).** "The state before shipkit ever touched this project" is a distinct concept from
"the state before this particular setup run", and conflating them is the actual bug. Writing it
once makes it immune to later setups by construction, and its presence or absence answers REQ-11
directly — no inference required.

**Case against.** A second artifact at the project root, which is clutter, and it is only correct
for projects set up *after* this lands: existing users have no true baseline and never will, so
REQ-11's "cannot be established" branch is permanent for them rather than transitional. It also
duplicates data on first setup (baseline and first rolling snapshot are identical), which is
wasteful but cheap.

**Decision.** Immutable `.shipkit-baseline/`, captured on first setup only, never overwritten;
rolling `.shipkit-backup-<ts>/` continues to serve "undo this setup run". *I would reverse this if
the* duplication proves confusing in support — then keep one artifact with an explicit
`baseline: true` marker inside it.

---

## DR-3 — An unsetup must itself be undoable

**Context.** REQ-6. Today the flow is delete-then-restore with no route back: anything added to
`.claude/` since `/setup` is discarded, and if the snapshot turns out to be the wrong one the
user has already lost the current state.

**Alternatives.** Rely on git (many projects gitignore `.claude/` — including this repo, so the
files would be untracked and unrecoverable); write a recovery snapshot before touching anything;
require a clean working tree before proceeding (hostile, and does not help with ignored files).

**Case for the recovery snapshot.** It is the only option that works regardless of what the
project's `.gitignore` says, and `/unsetup` is precisely the moment a user is most likely to
discover they wanted something they are about to delete.

**Case against.** It leaves yet another directory behind after a successful unsetup, which is
mildly absurd for a command whose purpose is removing shipkit's footprint. Needs an explicit
final message telling the user it exists and that deleting it is safe.

**Decision.** Write `.shipkit-recovery-<ts>/` before any destructive step; name it in the summary
and say it is safe to delete. *I would reverse this if* users report the leftover directory as
confusing more often than they use it to recover.

---

## DR-4 — Show the removal set, not a prose summary

**Context.** REQ-7. The current confirmation says `.claude/` "will be restored to its pre-shipkit
state" (`unsetup/SKILL.md:34`) — a description of intent, not of effect. A user cannot evaluate
that. With the manifest, the exact path list is available before anything is touched.

**Alternatives.** Keep prose; list paths; list paths plus a `CLAUDE.md` diff.

**Case for paths + diff.** The paths are the destructive part and the user can check them at a
glance. `CLAUDE.md` is the file most likely to contain hand-written content, so it earns a real
diff rather than a line count. This is the same principle the commit rule applies to destructive
git operations: present the consequence, not the intention.

**Case against.** On a large install the list is long and may bury the important line (a modified
file, per REQ-2). Mitigated by grouping: owned-and-unmodified collapsed to a count, modified files
listed individually and prominently.

**Decision.** Grouped path list + `CLAUDE.md` diff; modified files always listed individually.
*I would reverse this if* the grouped output still exceeds roughly a screen on a typical install —
then write the full set to a file and show the summary plus the path to it.

---

## DR-5 — Fixtures construct and destroy scratch projects only

**Context.** The reviewer explicitly did *not* execute the destructive restore, which is why this
finding is source-verified rather than reproduced. Any fix has to close that gap without ever
running the destructive path against a real project.

**Alternatives.** Manual testing; dry-run mode only; scratch-project fixtures in `smoke.sh`.

**Case for fixtures.** The install-lifecycle work just demonstrated the value concretely — the
fixtures caught two bugs I had introduced myself, including a `case` glob that was deleting
installed overlays. A destructive path deserves at least that much scrutiny, and `smoke.sh`
already has the scratch-project idiom (`mktemp -d`, copy plugin, `git init`).

**Case against.** These fixtures are slower and more elaborate than the existing ones, because
each must build a realistic project, run a removal, and assert on survivors. They also cannot
cover the interactive confirmation, which stays untested by construction.

**Decision.** Scratch-project fixtures in `smoke.sh` for REQ-1, REQ-2, REQ-3, REQ-5 and REQ-6;
the confirmation prompt is verified by reading, and the skill stays inline so it can ask.
*I would reverse this if* the fixtures push `smoke.sh` past a reasonable runtime — then split
the destructive ones into a separate `smoke-unsetup.sh` run before releases.
