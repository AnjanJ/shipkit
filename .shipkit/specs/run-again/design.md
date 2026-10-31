# Design: The run again, and 5.0.0 (Sprint 22)

## Approach

Nine records: W5, W11, W12, W13 and W14 from the plan, three the tree added since it was written,
and one the release smoke added. The order is the plan's: pay the debts, so the run measures them; settle the wait; run
the loop; write the roadmap; release. T1 changes four sentences and, if the clause says so, one
more. T2 changes nothing it finds. T-REL is the one release of three sprints (rule 22).

---

## Decision: The four debts are paid before the run, one sentence each   (→ REQ-1, REQ-4, REQ-5)

**Context.** The 4.12 run found four one-line debts: the brief never states the citation
convention `spec-check` reads, so the agent's tests cited nothing (`field-notes-4.12.md` §8.1);
setup's stack skill reads as a change beyond the spec (§9.2); the gate's pre-step capture went
to `/tmp`, outside its own cleanup (§9.3); setup says nine rules where eight ship (§2.1).

**Alternatives.**
1. Pay them in T1, each with a smoke check written first, so the run on the same project
   measures them, as Sprint 17 paid 4.9's debts before 4.12 measured them.
2. Leave them for the plan after, as the second-run plan's E17 said of its run's findings.

**Case for (1).** Each is one sentence, each has a concrete check, and paying them now is the
only way the same project can show whether they held.

**Case against (1).** The run stops being a measure of the thinning alone: a difference at §8
could be the brief's line or the cuts. (2) keeps the comparison pure at the price of a release
that ships four known wrong sentences.

**Decision.** We chose (1), W13's default. The capture's file ends `.out`, because the cleanup
removes `shipkit-ship-*.out`, not the plan's `shipkit-ship-…` in general.
**Falsifiability.** We would move REQ-1's line out of the brief and into a `spec-check` hint if
the run's tests still cite no `link-expiry/REQ-N` with the line in the brief.
**Fired-if.** manual

---

## Decision: A stack skill is allowed by the manifest, not by its directory   (→ REQ-2, REQ-3)

**Context.** W13 says `.claude/skills/<stack skill>/` joins the always-allowed list.
`brief-verify.sh` allows `.claude/rules/shipkit/` and `.shipkit-baseline/` because only the
installer writes there. `.claude/skills/` is different: it is where a project keeps its own
skills, and `CLAUDE.md` and `.gitignore` are reported for that same reason, they hold the
project's own content. The manifest lists each skill setup installed by exact path, and
`lib-manifest.sh`'s `manifest_owns` already answers the question.

**Alternatives.**
1. A file the manifest lists is allowed; every other file under `.claude/skills/` is reported.
2. Everything under `.claude/skills/` is allowed, the short reading of W13.

**Case for (1).** It pays the debt the run found without hiding an agent's edit to a project's
own skill, which is what the check exists to show. It is the plan's own word, `<stack skill>`.

**Case against (1).** `brief-verify.sh` gains a dependency on `lib-manifest.sh`, and the reviewer
must read a file to decide a line. An agent's edit to an installed skill still passes unreported,
the same gap the rules directory has.

**Decision.** We chose (1), on the owner's word at the spec's approval.
**Falsifiability.** We would widen to the directory (2) if a run's `brief-verify` or reviewer
reports a skill file setup wrote that the manifest does not list.
**Fired-if.** manual

---

## Decision: The run takes setup's default, so smoke alone proves the skills line   (→ REQ-2, REQ-3, REQ-10)

**Context.** The plan reads W13's skills line on the re-run: "no `.claude/skills/` in the
reviewer's 'beyond the spec'". That was written before W6. A headless setup now installs no
skill, so the reviewer has nothing to list, and the line would read as held having tested
nothing.

**Alternatives.**
1. The run takes the default; the notes say the run could not show the line; smoke checks 72
   and 73 prove it.
2. The run says yes to the skills, as the 4.12 run's setup did by default.

**Case for (1).** It measures what a user gets after W6, and its cost rows read straight against
§0's "0 by default". (2) would pay for a comparison of one line with a project the default no
longer produces.

**Case against (1).** The one real path that found the debt goes unobserved after the fix, and
the run is not like with like in this one respect: 4.12's setup wrote 3,482 bytes this one
will not.

**Decision.** We chose (1), on the owner's word at the spec's approval; REQ-10 lets the notes
say a line could not be shown.
**Falsifiability.** We would run the flag path if, after 5.0.0, a user or a run reports an
installed stack skill as `OUTSIDE` or beyond the spec.
**Fired-if.** manual

---

## Decision: The headless wait is measured, then one sentence, then measured   (→ REQ-6, REQ-7)

**Context.** A headless intake on `linkshort` scheduled a 1,200-second `ScheduleWakeup` for a
notification that came in 20 s, and the `-p` session held open twenty minutes for 65 s of API
time (`field-notes-4.12.md` §4.1). The 4.10.0 record closed the leaked wait sentence on the
condition of an interactive session, and this is the same wait with a timer on it.

**Alternatives.**
1. W14: three headless intakes on the `sample-app` fixture, then one sentence in `intake` and
   `ship`, then three more; the sentence stays only if no run schedules a wakeup with it and at
   least one did without. Otherwise it comes out and the record is reopened.
2. Reopen the record with the new condition and change no skill.

**Case for (1).** The evidence is one run. Three runs say whether it is a habit, and a sentence
in two skills earns its bytes only by a number (rule 20). About $1.50.

**Case against (1).** Three against three cannot separate a rare wakeup from none: one in four
would be missed nearly half the time, and a clean arm proves little. The sentence is measured
on `intake` and ships to `ship` unmeasured.

**Decision.** We chose (1). A baseline with no wakeup ends it there: the clause cannot keep the
sentence, so the second arm is not paid and the record is reopened. A run must hand work to an
agent to count. The owner sees the table before the sentence stays (rule 6).
**Falsifiability.** We would reopen this if the sentence stays and any headless run after it
schedules a wakeup, or if it goes and a headless session holds open more than 120 s past its
last API call in the release run or the re-run.
**Fired-if.** manual

**Outcome (2026-10-31).** The baseline scheduled no wakeup in three runs, so the sentence was not
tried, no skill changed, and the 4.10.0 record is reopened with the headless condition written
in (`docs/design/eval-results-5.0.md` §4). The owner confirmed at the table.

---

## Decision: The loop runs again on `linkshort`, same request, and fixes nothing   (→ REQ-8, REQ-9, REQ-11)

**Context.** Three real runs so far, each on a project new to shipkit. The thinning changes
what the loop loads and not what it does, so the question is the same loop before and after.
`~/code/linkshort` is clean at `a5f1eb8` with no run branch left.

**Alternatives.**
1. A worktree of `linkshort` at `main` on `shipkit/real-run-4`, `claude --plugin-dir` at this
   sprint's branch, `sonnet`, headless, the same nine steps and the same request, each section
   ending with one line against its 4.12 section; `context-cost.sh` three times; nothing fixed.
2. A Python project not yet seen.

**Case for (1).** Like with like: any difference is the plugin's, not the project's. A new
project would measure the project. "Nothing fixed" keeps it a measurement, as all three were.

**Case against (1).** The same small project cannot show what the cuts cost on a real codebase:
`walkthrough` and `explain-system` have no job on a project this size, and the fourth run on a
project built for the third teaches less each time.

**Decision.** We chose (1), W5, on the owner's approval of the plan.
**Falsifiability.** We would use a project not yet seen for the next run if this one's sections
show none better and none worse: then the like-with-like run has stopped teaching.
**Fired-if.** manual

---

## Decision: 5.0.0, with a migration table and no stubs   (→ REQ-13)

**Context.** W3 merged and renamed skills, W4 removed agents and W6 changed what setup installs.
A user with `/shipkit:walkthrough` in their habits or a Rails overlay in their project sees a
different product.

**Alternatives.**
1. 5.0.0, with the Migration table the CHANGELOG already carries under `[Unreleased]`.
2. 4.13.0 with the old names kept as stubs.

**Case for (1).** It says what happened, and a stub's description is exactly the per-session cost
Sprint 20 cut (rule 21).

**Case against (1).** A user who updates without reading gets "unknown skill" with no pointer,
where a stub would have told them.

**Decision.** We chose (1), W11.
**Falsifiability.** No reversal condition exists: the renames are on `main`, so the version can
only follow them. A name a user cannot find adds a row to the table, not a stub.
**Fired-if.** manual

---

## Decision: The release gates all three open specs   (→ REQ-14)

**Context.** `always-on` and `overlays-and-eve` merged untagged and stay `Status: open` until
5.0.0. `always-on`'s T-MERGE is unticked though merged at `0615060`, so the session hook has named
it as the next task ever since, and step 3 of its gate would fail on it. The plan's release task
names one gate.

**Alternatives.**
1. Tick that box in the release prep commit and run `/shipkit:ship` on all three specs.
2. Gate `run-again` only and set the other two to `shipped` by hand.

**Case for (1).** `Status: shipped` then means what it means on every other spec: a READY report
says so. Neither untagged spec has been through the gate, whose reviewer has fresh eyes.

**Case against (1).** Two more gates, about $1, for sprints whose merges already ran the exit
checklist; each is another chance of a reply like `ship-gate`'s unexplained `placeholder`.

**Decision.** We chose (1).
**Falsifiability.** We would gate only the last spec of a one-release plan next time if both
extra gates answer READY first time with no reviewer finding.
**Fired-if.** manual

---

## Decision: The gate starts a silent reviewer once more   (→ REQ-15)

**Context.** Three times in 74 logged gate sessions, all in the last ten, the reviewer's last call
was `SubagentHandback {"message": "placeholder"}`. The tool answered "Report delivered to your
caller", the agent ended, and the review was never sent, so the gate answered NOT READY on a
complete feature. Why the model writes that word is not known; it is one ordinary turn, with no
error. Smoke's `ship-gate` failed twice in a row on the release tree, and re-running until it
passes would have hidden that.

**Alternatives.**
1. One sentence in `ship`'s step 4: a reply with no `VERDICT:` line is not a review, so start the
   reviewer once more; a second miss is `FAIL`.
2. A sentence in `reviewer.md` telling it never to hand back a stub.
3. Release as it is, on the owner's word, smoke not fully green.

**Case for (1).** It works whatever the cause, which we do not know. It stays fail-closed: no reply
can produce READY that did not say `VERDICT: PASS`. It costs a second reviewer only on a miss.

**Case against (1).** It treats the symptom and leaves the model's habit unexplained, and at about
one miss in three the retry still leaves a smoke run failing roughly one time in ten. A sentence
added on the last day is measured less than anything else in this release. (2) aims at the cause,
but it cannot be measured at this rate, and rule 20 wants a number.

**Decision.** We chose (1), on the owner's word at T-REL. The path was forced once with a reviewer
that only replies `placeholder`, to see it start twice and still answer NOT READY.
**Falsifiability.** We would add (2), or drop the agent's hand-back for a file it writes itself, if a
gate in the release run or after it answers NOT READY with two replies that have no verdict line.
**Fired-if.** manual

---

## Decision: Each deletion is its own yes   (→ REQ-11)

**Context.** W12 names F3, the merged branch `claude/wizardly-fermi-u6f5w2`, and F4, the owner's
cache to 5.0.0. The run adds `shipkit/real-run-4` and its worktree, and the release adds this
sprint's branch.

**Alternatives.**
1. One yes each, at its moment; the run's log read and recorded before its branch goes.
2. One yes for all of them at the release.

**Case for (1).** It is the owner's standing rule, and the run's branch lives in the owner's own
repository, where a surprise is the owner's to find.

**Case against (1).** Four small questions at the end of a long release.

**Decision.** We chose (1), W12.
**Falsifiability.** No reversal condition exists: this is the owner's rule, not a measured
choice, and it changes on the owner's word.
**Fired-if.** manual

---

## Data / interface changes

- `brief.sh`: one line under "## Prove it with".
- `brief-verify.sh`: a manifest-listed file is allowed; the header says why; `lib-manifest.sh`
  is sourced, and with no manifest nothing changes.
- `agents/reviewer.md` step 4: one clause.
- `skills/ship/SKILL.md`: the pre-step names `shipkit-ship-status.out`; step 7 reads it; step 4
  starts a reviewer with no verdict line once more.
- `skills/setup/SKILL.md`: "eight".
- `skills/intake/SKILL.md`, `skills/ship/SKILL.md`: one sentence, only if the clause keeps it.
- No migration beyond 5.0.0's table.
