# Design: What the run hurt on (Sprint 11)

## Approach

Four small tasks, each on the file the field notes pointed at. Two scripts (the briefing and the
session hook) learn one more reading of a spec folder and one more line each; two skills (intake,
product) gain sentences that a smoke check reads and an eval case exercises; one skill (handoff)
gains a heading. Nothing under `rules/`, `agents/` or the existing eval cases changes. One eval
case is added, and it needs room the README's history is holding.

---

## Decision: The briefing reads "all ticked, no Status" as closed; spec-check does not   (→ REQ-1, REQ-2, REQ-3, REQ-4, REQ-5)

**Context.** Six of `rails_error_dashboard`'s specs predate 3.3 and have no `Status` line. To
`spec-check.sh` that means open (`spec-contract/REQ-7`, a shipped requirement with a smoke
check), so the briefing reported three of them as in flight, nagged about drift on one, and
counted 23 gaps — every session (field notes §1).

**Alternatives.**
1. The briefing and the drift nag treat a spec with no `Status` line and every task ticked as
   closed, and one line names how many specs have no `Status` line with the fix; `spec-check.sh`
   is untouched.
2. `/shipkit:spec --migrate`, which writes `> Status: shipped` into the user's spec files for
   every all-ticked spec.
3. Change `spec-check.sh` too: no `Status` plus all ticked means shipped, and the gaps count drops.

**Case for (1).** The wrong lines were the briefing's; fixing the reader fixes the symptom
without writing into a user's files or changing a shipped requirement's meaning. The one new
line tells the owner what to do and goes away when they do it.

**Case against (1).** The 23-gap line stays until the owner adds six lines by hand; a spec with
no `Status` and all tasks ticked that is in fact dropped reads as closed (harmless: nothing is
reported for a closed spec anyway). Option 2 is friendlier and is the plan's "other option";
it touches user files and belongs to a sprint that can ask.

**Decision.** We chose (1), C2's default, approved 2026-10-08.
**Falsifiability.** We would build (2) if two users, or the owner twice, report adding `Status`
lines by hand to more than five specs after reading the new line.
**Fired-if.** manual

---

## Decision: The intake searches a fixed list before it asks   (→ REQ-6, REQ-7, REQ-8)

**Context.** On the real run the intake asked four questions; the repository answered three
(ROADMAP item 14 at "half day", `configuration.rb:284`, the business case under
`.shipkit/research/`), one claim of absence was false (`job_queue_stats` existed), and the run
said it had not used `grandfather` (field notes §3–§5). The skill already says "drop anything a
file already answers" and "ask grandfather"; neither happened.

**Alternatives.**
1. Step 2 names the places to search (ROADMAP, `docs/`, `.shipkit/research/`,
   `.shipkit/decisions/`, configuration comments, `git log --grep`), says to run that search
   through `grandfather` for each candidate question, and step 4 turns an answered question into
   an assumption with `file:line`; step 3 says a claim of absence names what was searched. One
   eval case with a fixture whose docs answer two of three natural questions.
2. Leave the skill; record the finding.
3. A script that greps the repository for the question's nouns and prints hits for the model.

**Case for (1).** The instruction the model skipped was general ("a file already answers"); a
list is followed more often than a principle, and the case will say whether it is. (3) would be
a fourth script for a problem of attention, not of tooling.

**Case against (1).** More skill text in every intake run; a list is never complete; and one
case on one model cannot prove the sentence did it — the risk table says so. If the case passes
with the old text too, the lever was not the text.

**Decision.** We chose (1), C3's default.
**Falsifiability.** We would revert the list to the one-line principle if the `intake-answered`
case passes 2 of 3 with the 4.3.0 text in S11-T2's with/without run — the sentence would then be
bytes without effect.
**Fired-if.** manual

---

## Decision: Unanswered questions are written, not spoken   (→ REQ-9, REQ-10, REQ-11)

**Context.** Headless, the intake "states the conflicts, lists the questions, and stops" and
writes nothing; product writes "none set" gaps and lists its questions in the reply. Both
replies vanish with the session; the second intake pass redid two minutes of research to write
a file whose content was already in the first reply (field notes §2, §3).

**Alternatives.**
1. The intake writes `intake.md` with the questions marked *unanswered*; product writes an
   "Open questions for the owner" section; the next pass fills blanks and asks nothing already
   answered.
2. Reply only, as today; the executor relays.
3. A separate `questions.md` file per skill.

**Case for (1).** The file is where the next session looks; the format already has "An
unanswered question is written as unanswered". One file per feature, not two.

**Case against (1).** An `intake.md` with blanks can be mistaken for a finished intake by a
spec run that reads it; the spec skill's step 0 reads `intake.md` and "does not ask those
questions again" — it must treat *unanswered* as unanswered. That is one sentence in the spec
skill, which is not on this sprint's Files line: Sprint 12's spec-skill task carries it, and
until then the risk is a headless spec run on a half-answered intake, which the owner's
interactive run would not do.

**Decision.** We chose (1), C4's default.
**Falsifiability.** We would move to (3) if a spec run is observed treating an *unanswered*
question as answered (a `spec.md` requirement built on a blank) in any real or eval run.
**Fired-if.** manual

---

## Decision: The version line reads directory names, not JSON   (→ REQ-12, REQ-13)

**Context.** The owner's interactive session ran 3.1.0 for a day after 4.2.0 was installed;
nothing said so. The hook knows its root (`…/cache/shipkit/shipkit/<ver>`).

**Alternatives.**
1. List the sibling directories of the root, sort by version, print one line when a higher one
   exists.
2. Read `~/.claude/plugins/installed_plugins.json` with `sed` for the installed version.
3. Nothing; `claude plugin update` already says "restart".

**Case for (1).** POSIX `sh` and `sort -V`-free (a three-field numeric sort in `awk`); no
dependence on a JSON layout Claude Code may change; the Check first in the plan's §3 says what
to do if the cache layout is not as assumed.

**Case against (1).** A stale directory from an older version sits beside the new one (3.1.0
beside 4.2.0 today), so the comparison must be "higher than running", never "different".

**Decision.** We chose (1).
**Falsifiability.** We would move to (2) if the cache layout changes so that the running root's
parent is not the version directory (the smoke check would go red).
**Fired-if.** manual

---

## Data / interface changes

- Changed: `briefing.sh` (REQ-1, REQ-3, REQ-4, REQ-14), `session-start.sh` (REQ-2, REQ-12,
  REQ-13), `skills/intake/SKILL.md` (REQ-6 to REQ-10), `skills/product/SKILL.md` (REQ-11),
  `skills/handoff/SKILL.md` (REQ-15).
- New: `plugins/shipkit/evals/intake/answered/` (REQ-6); `docs/design/eval-history.md` (two
  README sections moved, with the owner's yes); smoke checks 49 to 51.
- Unchanged: `spec-check.sh` (REQ-5), every rule, agent and existing case.
