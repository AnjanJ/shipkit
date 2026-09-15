# Install Lifecycle — Design

> Spec accepted at commit `ce3ec19` on main.

The approach, as decision records. One fork in the road per record.

---

## DR-1 — Digest the installed tree, per file, not the shipped directory

**Context.** REQ-5..REQ-8 are four symptoms of one defect. `rules_sha` computes a single digest
over `<plugin>/rules/*.md` — the *upstream* side. `.installed` therefore answers "what version
did we ship?" and can never answer "what is actually in this project?". Every ownership question
the review raises needs the second answer.

**Alternatives.**
1. *Keep the single upstream digest, add a separate file list.* Two artifacts to keep in sync.
2. **Per-file manifest recording owned path + source hash, written from the installed side.**
3. *Digest the installed directory as a whole.* Detects that something changed, but not which
   file, so it cannot reconcile a deletion or name the missing rule.

**Case for (2).** One artifact answers all four questions. Completeness = every manifest path
exists. Drift = per-file hash mismatch, and it names the file. Deletion reconciliation = a path
in the manifest but not upstream is shipkit-owned and safe to remove. Coverage extends to
overlays and skills for free, because the manifest records whatever the installer wrote.

**Case against.** The manifest is larger and must be written transactionally — a half-written
manifest is worse than none, since it implies ownership of paths that may not exist. It also
makes the installer the sole writer of a file users might hand-edit, and it cannot distinguish
a user's deliberate deletion from an accident (mitigated by DR-3: shipkit only ever *reports*
a missing file, never re-creates it silently).

**Decision.** Per-file manifest, written atomically (temp file + `mv`) after all copies succeed.
*I would reverse this if* the manifest exceeded ~200 entries for a typical install, at which
point the per-file hashing cost would justify a directory-level digest with a separate path list.

---

## DR-2 — Legacy stamps mean "unknown provenance", never "safe to delete"

**Context.** Existing projects carry the two-line `version=`/`sha=` stamp. Deletion
reconciliation (REQ-7) removes files. Acting on a stamp shipkit didn't write risks deleting a
file it never owned.

**Alternatives.** Auto-migrate treating legacy as unowned; read both formats indefinitely;
hard cutover nagging until re-setup.

**Case for auto-migrate.** Ownership is *claimed*, not assumed. A legacy stamp grants zero
delete authority; the next `/shipkit:setup` writes a real manifest and ownership begins there.
Users mid-upgrade are never surprised by a deletion.

**Case against.** One extra branch in `session-start.sh` and in the installer, carried until the
legacy format is rare. A user who never re-runs setup keeps the weaker guarantees indefinitely.

**Decision.** Auto-migrate; legacy stamp ⇒ no deletions, warn once, full manifest on next setup.
*I would reverse this if* telemetry showed legacy stamps effectively gone, at which point the
branch is dead code and becomes a hard cutover.

---

## DR-3 — Missing files are reported, never silently re-created

**Context.** REQ-5/REQ-6: a rule absent from disk should not vanish from context too. Two ways
to fix it — restore the file, or fall back to injecting it.

**Alternatives.** (a) Installer re-creates any missing owned file at session start.
(b) `inject-rule.sh` checks `-f` on the specific rule and injects when absent; the hook warns
that the install is incomplete.

**Case for (b).** A session hook must not write to the user's project. Injection is already the
documented fallback for un-installed projects, so this reuses a path that works, and the user
keeps authority over their own `.claude/`. A deliberate deletion stays deleted.

**Case against.** The project sits in a degraded state — rule in context, not on disk — until
the user acts, and a deliberately deleted rule keeps being injected, which may be unwanted.
The warning is what closes that gap, so the warning must be specific about which file is missing.

**Decision.** Per-rule `-f` check + injection fallback + a completeness warning naming the file.
*I would reverse this if* users report the injection fallback fighting deliberate deletions —
then add an opt-out marker rather than re-creating files.

---

## DR-4 — Delimit the CLAUDE.md stack section with a closing marker

**Context.** REQ-9/REQ-10. The `<!-- shipkit:stack:X -->` marker makes the append idempotent,
which is exactly why it cannot update. The appended sections have **no terminator** — the python
one runs to EOF — so "the managed region" is currently undefined.

**Alternatives.** Warn-only; always overwrite the marked block; delimit and refresh, prompting
on in-block edits.

**Case for delimit-and-refresh.** A closing `<!-- /shipkit:stack:X -->` defines the region
precisely. Content outside is untouchable by construction. Stale values get fixed, which is the
actual bug.

**Case against.** Existing installs have an opening marker and no closing one; the installer must
handle that (treat "opening marker, no closing" as legacy → append a closing marker at EOF only
when the remainder is unmodified, else warn and leave it alone). Prompting also makes the
installer interactive, which `/shipkit:setup` can do but a bare script invocation cannot — so the
script must support a non-interactive mode that warns instead of prompting.

**Decision.** Closing marker + in-region refresh; diff-and-ask on in-region edits, warn-only when
non-interactive. *I would reverse this if* the legacy unterminated-section case proves
unresolvable without guessing where the section ends — then fall back to warn-only for legacy
sections while new installs get markers.

---

## DR-5 — Rotate stale-spec reporting instead of raising the cap

**Context.** REQ-12. Fixed glob order + a cap of 3 starves specs 4..n permanently.

**Alternatives.** Raise/remove the cap (floods context, the cap exists for a reason); sort by
staleness (most-stale-first still starves a stable tail); rotate by run.

**Case for rotate.** Preserves the context budget the cap protects while guaranteeing every
stale spec surfaces eventually.

**Case against.** Output is no longer deterministic across runs, which makes the smoke assertion
harder to write and could confuse a user who sees a different line each session.

**Decision.** Sort most-stale-first, then rotate the starting offset so the tail is reachable;
report the total ("3 of 7 shown"). The count makes the omission visible, which is the part the
user actually needs. *I would reverse this if* the non-determinism proves confusing in practice —
then sort-only, plus the total.

---

## DR-6 — Soften the always-loaded standards, keep the opt-in enforcer absolute

**Context.** REQ-15. The review asks to soften both `code-review-standards` and `tdd`.

**Alternatives.** Soften both; soften neither; soften only what loads unconditionally.

**Case for the split.** `code-review-standards` loads on every review, so a MUST there is a
blanket rule applied to code it has never seen — "functions under 20 lines" as a MUST produces
unnecessary decomposition. `tdd` is invoked **by name**, and its `DO NOT TRIGGER` clause already
excludes ordinary coding; a user typing `/shipkit-workflows:tdd` is asking for the iron law.
Softening an opt-in enforcer into "contextual signals" removes its reason to exist.

**Case against.** Inconsistent phrasing between two sibling skills invites a future contributor
to "fix" the inconsistency. Mitigated by a comment in `tdd` stating the asymmetry is deliberate.

**Decision.** Soften `code-review-standards` MUST→SHOULD/CONSIDER where contextual; leave `tdd`
absolute and document why. *I would reverse this if* `tdd` began auto-triggering rather than
requiring invocation by name.
