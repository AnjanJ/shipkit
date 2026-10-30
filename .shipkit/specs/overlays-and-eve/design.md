# Design: What a set-up project pays (Sprint 21)

## Approach

Four records, one per plan decision (W6, W7, W8, W9), two more from W9's STOP, and a sprint that is one flag, two
audits with the owner's yes per row, one amended decision record, and one measured trim.
Nothing in the loop's skills or the hook changes. Every cut has a number or the owner's word
(rule 20): the flag is checked by smoke; the audits are read by the owner before a line
moves; `eve`'s trim is kept only by the five cases' counts read from kept traces.

---

## Decision: Overlay skills install on a flag, not by default   (→ REQ-1, REQ-2, REQ-3, REQ-4)

**Context.** `install-stack.sh` copies every skill under `stacks/<overlay>/.claude/skills/`
into the project; a Rails project gets six (17,529 bytes, six listings every session there).
Decision 0003 (2026-10-07) kept them in core because core installs them and they cost no
plugin context — true, and silent about the project's context, which they do cost.

**Alternatives.**
1. Rules and the `CLAUDE.md` section by default; skills only on `--with-skills` (before the
   positional arguments); setup asks once; `setup remove` reads the manifest as now.
2. Install skills by default as today and cut only the duplicates (W8).
3. Move the skills to `shipkit-workflows` (the 3.0 question 0003 settled).

**Case for (1).** The project's skill list carries what the user asked for. The flag keeps
the skills for the Rails user who wants them and costs the Python user nothing. The manifest
already records what was installed, so removal is unchanged.

**Case against (1).** One more question in setup, and a non-interactive setup (the real runs)
takes the default and must say so. A flag before positional arguments is a contract change if
the parser is strict — the plan's §3 check; the fallback is `SHIPKIT_STACK_SKILLS=1`.

**Decision.** We chose (1).
**Falsifiability.** We would reverse this — skills by default again — if two of the next
three real runs' notes show the user asking for the skills after setup declined them.
**Fired-if.** manual

---

## Decision: The appends and the two unscoped rules are audited by the 4.0 rule, no eval   (→ REQ-5, REQ-6, REQ-7)

**Context.** Ten `CLAUDE.md.append` files (303 to 2,525 bytes) load whole into every session
of a set-up project; the 4.12 run's §2.2 showed the python one carrying "Ruff or flake8",
"`mypy` or `pyright`", `src/` or `app/`, and a Django block on a FastAPI project — the
template with its alternatives left in, which detection cannot resolve. `rails.md` (246
bytes) and `react.md` (701) have no `paths:` line and load always. No eval case installs an
append, so (c) of the 4.0 rule cannot be met; the verdicts rest on (a) and (b).

**Alternatives.**
1. A line-by-line audit in `docs/design/trim-audit-overlays.md`, the python rows first; each
   `trim` needs the owner's yes; `paths:` for the two rules where a glob fits.
2. Leave the appends: 1.6–2.3 KB per stack.
3. Write a case per append and measure (ten cases, about 15 KB of evals, under a ceiling with
   6 KB of room).

**Case for (1).** The 4.0 trim audit's rule is the one this repository already used for the
plugin's own text; the owner reads the table before a line moves. The two rules gaining
`paths:` costs nothing and ends their always-on load.

**Case against (1).** An audit by reading is a judgment, not a number; a line kept by (b) is
a claim the model gets it wrong untold, unmeasured here. (3) would measure it and does not fit
the ceiling.

**Decision.** We chose (1).
**Falsifiability.** We would reverse a trim — returning the line — if a release run's case
for that stack drops below its count after the trim, or a real run's notes show the model
doing what the trimmed line forbade.
**Fired-if.** manual

---

## Decision: The eleven overlay skills are measured against the loop; duplicates go (0004 amends 0003)   (→ REQ-8, REQ-9, REQ-10)

**Context.** The eleven skills predate the loop: `release` and `deploy-check` (Rails) stage a
release the way `/shipkit:ship` now gates one; `new-feature` (four overlays) scaffolds a
feature the way `/shipkit:spec` now specifies one; `code-review-standards-rails` is a Rails
lens the `reviewer` and the built-in `/code-review` cover; `safety-check` audits a diff for
what `shipkit.md`'s Care line and the path-scoped rules now say. Decision 0003 kept all
eleven in core on how they are delivered; it did not ask whether each still earns its place.

**Alternatives.**
1. An audit per skill — the core or workflows text it duplicates, side by side; `cut` or
   `keep behind the flag`; the owner's yes per cut; record 0004 amends 0003 with the flag and
   the cuts, 0003 marked not deleted.
2. Keep all eleven behind the flag, cut nothing.
3. Move the seven "how-to-work" ones to `shipkit-workflows` (0003's rejected option).

**Case for (1).** A skill that says what the loop already says is two voices on one question;
behind a flag it costs the user who asks for it a listing for nothing new. The side-by-side
makes the duplication a thing the owner can read, not a claim.

**Case against (1).** "Duplicates the loop" is a reading, and a Rails user who never runs the
loop may want `release` as it is. (2) keeps the choice theirs at the price of eleven listings
when the flag is on.

**Decision.** We chose (1).
**Falsifiability.** We would reverse a cut — restoring the skill behind the flag — if a user
asks for it by name in an issue or a real run's notes within two releases.
**Fired-if.** manual

The draft of `.shipkit/decisions/0004-overlay-skills-flag.md` (written in T3):

> **Context.** 0003 kept the overlay skills in core because core installs them and they cost
> no plugin context. They cost the project's: six listings on a Rails project, every session.
> **Alternatives.** (1) in core, installed on `--with-skills`, duplicates of the loop cut;
> (2) in core, installed by default, as 0003; (3) in workflows. **Case for (1)** and **Case
> against (1)** as above. **Decision.** (1); 0003's "stay in core" stands, its "installed by
> default" does not. **Falsifiability.** as above. **Fired-if.** manual.

---

## Decision: `eve`'s prompt is trimmed by the audit's one arm and its clause   (→ REQ-11, REQ-12, REQ-13)

**Context.** `agents/eve.md` is 17,010 bytes, about 4,300 tokens in `eve`'s own context per
call. `docs/design/trim-audit-eve.md` (PR #21) named about 5,500 bytes in five candidates no
case exercises or that repeat an earlier section — the cheap-path cheat-sheet table, the
MemPalace paragraph's excess, the matrix and consolidation report shapes (moved to `ask`, not
cut), the example questions, the restated constraints — and the arm that measures them all
at once.

**Alternatives.**
1. The audit as written: baseline 15 runs, the arm with all five candidates applied 15 runs,
   `--keep-temp`, `map_read` and tool calls from the traces; bisection only on a drop; the two
   report shapes checked by one `ask --all matrix` and one `--all consolidate` run each.
2. Defer again.
3. Cut by reading, no runs.

**Case for (1).** The audit already wrote the arm, the clause and the budget ($4 if the arm
holds, up to $14); the five cases are the watch in every release run after. One arm first is
cheap; bisection is paid only by a drop.

**Case against (1).** Fifteen runs is a small number for five cases at once, and the two
moved report shapes have no case — their check is one run each, read by the reply's shape.
(3) saves $4 and loses the number.

**Decision.** We chose (1).
**Falsifiability.** We would reverse a candidate — returning it to `eve.md` — if its case
drops below 2 of 3 in a release run after the trim, or a matrix or consolidation request
through `ask` comes back without its shape.
**Fired-if.** manual

## Decision: `eve.md` ships at the measured size, not the audit's estimate   (→ REQ-12)

**Context.** The audit's 11,500 was 17,010 less about 5,500 bytes of candidates. The measured
arm took 16,947 to 12,067: the table and the two shapes each left a sentence behind them, and
the estimate had not counted those. Every case held, so only the number missed.

**Alternatives.**
1. Ship the arm as measured and amend REQ-12 to 12,067.
2. Cut about 570 more bytes of glue (the staleness bullet, the two-line step 1, the report
   lead) and re-run the 15-run arm, about $2.

**Case for (1).** Every number in the table then describes the file that ships. The 567 bytes
are about 155 tokens a call, and the whole 4,880-byte trim moved the 15 runs' totals by less
than their run-to-run spread (input tokens −2.2%, dollars +1.0%). 510 of the bytes are comments
the model never receives.

**Case against (1).** A ceiling moved to fit its result is a ceiling that did nothing, and the
glue is still there to cut.

**Decision.** We chose (1), on the owner's word at W9's STOP.
**Falsifiability.** We would reopen the size if a release run's five `eve` cases average more
than $0.15 a run (0.126 on the arm) or any of them hits `maxTurns`.
**Fired-if.** manual

## Decision: The matrix and consolidation shapes live in `skills/ask/reports.md`   (→ REQ-13)

**Context.** The audit moved the two shapes from `eve.md` to the `ask` skill's text, which the
arm did in `SKILL.md`. That body loads into the main session on every `/shipkit:ask` and stays
there, so a grandfather question pays 1,354 more bytes for nothing, where `eve`'s prompt ended
with the subagent. The five cases cannot show it: none of them is a grandfather question.

**Alternatives.**
1. A reference file, `skills/ask/reports.md`, read on those two routes only.
2. `SKILL.md` as measured.
3. Back in `eve.md`, as the audit's clause allows on a lost shape.

**Case for (1).** `--walk` and `--system` already work this way, and the probes' session logs
show `@walk.md` stays literal, its body unloaded, so the file costs nothing off its route.
`ask` grows 161 bytes, not 1,354, and the text moves whole, not compressed.

**Case against (1).** It adds a step the main session can skip: if it does not read the file,
`eve` gets no shape and no case catches it. Only the two probes and check 70's text check watch
that route, and the file was measured after the 15-run arm, not in it.

**Decision.** We chose (1), on the owner's word at W9's STOP. `eve.md` is unchanged by this.
**Falsifiability.** We would move the shapes back to `agents/eve.md` if a `--all matrix` or
`--all consolidate` request comes back without its shape because `reports.md` was not read.
**Fired-if.** manual

---

## Data / interface changes

- `install-stack.sh [--with-skills] <plugin-root> <stack> [project-dir] KEY=value …`; without
  the flag no `.claude/skills/` entry is written or recorded.
- `skills/setup/SKILL.md` Phase 5: one question when the overlay ships skills; the default in
  a non-interactive run is no skills.
- `stacks/*/CLAUDE.md.append`, `stacks/rails/.claude/rules/rails.md`,
  `stacks/react/.claude/rules/react.md`: lines out on the owner's yes; `paths:` where a glob
  fits.
- `stacks/<overlay>/.claude/skills/<skill>/` directories removed on the owner's yes.
- `.shipkit/decisions/0004-overlay-skills-flag.md` (new); 0003's status line amended.
- `agents/eve.md` ≤ 12,067 bytes (amended from 11,500 at W9's STOP); `skills/ask/reports.md`
  (new) carries the matrix and consolidation shapes, read on those two routes only.
- No migration.
