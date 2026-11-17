# Smoke audit 5.4 — the assertions that only read wording

> Written 2026-11-17, in Sprint 29 (`.shipkit/specs/honest-evidence/`, task T8, REQ-33), from
> `scripts/smoke.sh` as it stood then.

Some of the smoke suite's assertions run a script and read what it did. Others start a model and
read the file it wrote. A third kind only reads the wording of a skill, an agent or a rule: it
looks for a sentence with `grep`, `sed` or `awk`, and passes when the sentence is there. That
shows the words have not been lost. It does not show that a model follows them.

Since this sprint the third kind passes through `passt` and prints as `PASS  [text]`, and the
suite's count line says how many there were. This file lists each one, so that a reader can see
which requirements rest on wording alone.

## How to read the table

- **Check** and **Name** are the smoke check's label and its name in the script's registry.
- **What it asserts** is the opening of the assertion's own message.
- **Reads** is the skill, agent or rule text the assertion looks at.
- **Cites** is every requirement the check's header cites. A check with several assertions cites
  them together, so a requirement in this column belongs to the check, not always to this one
  assertion.
- **What else stands behind those requirements** names the check's other assertions, when it has
  some that run a script or read a model's work, and every other place that cites one of the same
  requirements: another smoke check, an eval case, `scripts/evals.sh`, `scripts/lint.py` or CI.
  **Nothing else** means the requirement is held by wording alone.

## What is not in the table

- An assertion that reads wording in another kind of file: the README, the guide, a script's
  header, the evals README. Those are checks on documents, and the label is for what a model
  reads as instructions.
- An assertion about which files exist, or how many bytes a file has. Those are proven in full
  by looking.
- Anything inside a check that starts a model.

## The 35 assertions

| Check | Name | What it asserts | Reads | Cites | What else stands behind those requirements |
|---|---|---|---|---|---|
| 22 | `spec-new-format` | the spec-driven rule names the <feature>/REQ-N citation; rules within 3,000 bytes | `rules/decisions.md`, `rules/shipkit.md`, `rules/spec-driven.md` | product-intake-brief/REQ-28, spec-contract/REQ-21, spec-contract/REQ-22 | 1 assertion(s) of this check that run something |
| 24 | `registry-columns` | registry template has Product and Top Goal | `skills/map/SKILL.md` | product-intake-brief/REQ-8, product-intake-brief/REQ-10 | **nothing else** |
| 24 | `registry-columns` | eve names studio.md and both columns | `agents/eve.md` | product-intake-brief/REQ-8, product-intake-brief/REQ-10 | **nothing else** |
| 27 | `reviewer-tools` | tools = Read, Glob, Grep, Bash; Edit, Write and Agent denied | `agents/reviewer.md` | review-and-ship/REQ-7, run-debts/REQ-8 | 1 assertion(s) of this check that run something |
| 30 | `briefing` | handoff skill: a Blocked on heading only when the next step cannot start; the Next step line still stands… | `skills/handoff/SKILL.md` | briefing-and-handoff/REQ-1, briefing-and-handoff/REQ-2, briefing-and-handoff/REQ-3, briefing-and-handoff/REQ-4, briefing-and-handoff/REQ-5, briefing-and-handoff/REQ-6, briefing-and-handoff/REQ-7, briefing-and-handoff/REQ-8, briefing-and-handoff/REQ-9, run-wounds/REQ-15 | 7 assertion(s) of this check that run something |
| 34 | `fired-if-template` | reference.md shows a command form after a Falsifiability line, and the manual form | `skills/spec/reference.md` | decisions-and-digest/REQ-1, decisions-and-digest/REQ-3 | 1 assertion(s) of this check that run something |
| 52 | `fired-if-early` | the spec skill runs decision-check --run on its own design.md and treats FIRED or ERROR as a defect; the… | `skills/spec/SKILL.md`, `skills/spec/reference.md` | gate-blind-spots/REQ-1, gate-blind-spots/REQ-2, gate-blind-spots/REQ-3, gate-blind-spots/REQ-4 | 2 assertion(s) of this check that run something |
| 55 | `spec-check-draft` | the spec skill runs spec-check --as-open on the draft; no status flip in its text | `skills/spec/SKILL.md` | harness-debts/REQ-1, harness-debts/REQ-2, harness-debts/REQ-3 | 3 assertion(s) of this check that run something |
| 58 | `cuts-recorded` | the sixteen measured lines are out of their eight files; the four kept files still carry theirs | `rules/migrations.md`, `rules/monorepo.md`, `rules/testing.md`, `rules/ui-ux.md`, `stacks/elixir/.claude/rules/mix-deps.md`, `stacks/hotwire/.claude/rules/hotwire.md`, `stacks/liveview/.claude/rules/liveview.md`, `stacks/ml/.claude/rules/notebooks.md`, `stacks/python/.claude/rules/pyproject.md`, `stacks/rails/.claude/rules/rails.md`, `stacks/react/.claude/rules/package-json.md`, `stacks/react/.claude/rules/react.md` | graders-and-eve/REQ-10, measured-cuts/REQ-1, measured-cuts/REQ-3, measured-cuts/REQ-4, measured-cuts/REQ-5 | 1 assertion(s) of this check that run something; evals.sh |
| 58 | `cuts-recorded` | the intake's step 4: an assumption names its file and line; a question's parts count | `evals/README.md`, `skills/intake/SKILL.md` | graders-and-eve/REQ-10, measured-cuts/REQ-1, measured-cuts/REQ-3, measured-cuts/REQ-4, measured-cuts/REQ-5 | 1 assertion(s) of this check that run something; evals.sh |
| 60 | `heading-seen` | the setup skill relays the line, shows the diff, names /shipkit:setup rules and edits neither section | `skills/setup/SKILL.md` | run-debts/REQ-1, run-debts/REQ-2 | 2 assertion(s) of this check that run something |
| 61 | `same-named` | the setup skill's backup phase asks git whether the old backup is tracked and leaves a tracked one at the root | `skills/setup/SKILL.md` | run-debts/REQ-3, run-debts/REQ-4 | 2 assertion(s) of this check that run something |
| 65 | `skills-merged` | ask dispatches --walk and --system, setup dispatches remove/rules/audit/memory, each to a reference file… | `skills/commit/SKILL.md` | always-on/REQ-10, always-on/REQ-11, always-on/REQ-12, always-on/REQ-13, always-on/REQ-14 | 2 assertion(s) of this check that run something |
| 66 | `agents-four` | grandfather carries a Trace mode section and ask --walk hands it the brief | `agents/grandfather.md`, `skills/ask/SKILL.md` | always-on/REQ-16, always-on/REQ-17, always-on/REQ-18, always-on/REQ-19, spec-goldfish/REQ-16 | 2 assertion(s) of this check that run something |
| 66 | `agents-four` | map runs forked and carries the archivist's body as archivist.md | `skills/map/SKILL.md`, `skills/map/archivist.md` | always-on/REQ-16, always-on/REQ-17, always-on/REQ-18, always-on/REQ-19, spec-goldfish/REQ-16 | 2 assertion(s) of this check that run something |
| 66 | `agents-four` | no skill or agent names codebase-explorer; Explore is the built-in | `skills/map/SKILL.md`, `skills/map/archivist.md` | always-on/REQ-16, always-on/REQ-17, always-on/REQ-18, always-on/REQ-19, spec-goldfish/REQ-16 | 2 assertion(s) of this check that run something |
| 67 | `skills-flag` | the setup skill asks once about the overlay's skills, says they are listed every session, and defaults to… | `skills/setup/SKILL.md` | overlays-and-eve/REQ-1, overlays-and-eve/REQ-2, overlays-and-eve/REQ-3, overlays-and-eve/REQ-4 | 3 assertion(s) of this check that run something |
| 68 | `appends-trimmed` | the six big appends carry only the kept lines, each at or under its post-trim size | `stacks/python/.claude/rules/django.md` | overlays-and-eve/REQ-6, overlays-and-eve/REQ-7 | **nothing else** |
| 68 | `appends-trimmed` | the five Django lines live in a path-scoped stacks/python/.claude/rules/django.md | `stacks/python/.claude/rules/django.md` | overlays-and-eve/REQ-6, overlays-and-eve/REQ-7 | **nothing else** |
| 68 | `appends-trimmed` | rails.md and react.md carry paths: and load only on a matching edit | `stacks/python/.claude/rules/django.md`, `stacks/rails/.claude/rules/rails.md`, `stacks/react/.claude/rules/react.md` | overlays-and-eve/REQ-6, overlays-and-eve/REQ-7 | **nothing else** |
| 70 | `report-shapes` | the matrix and consolidation shapes are in ask's reports.md, read on those two routes only; eve.md rs_b… | `agents/eve.md`, `skills/ask/SKILL.md`, `skills/ask/reports.md` | overlays-and-eve/REQ-12, overlays-and-eve/REQ-13 | **nothing else** |
| 73 | `reviewer-skills` | step 4 reads a stack skill by the manifest; a project's own skill is still listed | `agents/reviewer.md` | run-again/REQ-3 | **nothing else** |
| 74 | `ship-capture` | the pre-step writes shipkit-ship-status.out, step 7 reads it, the cleanup's pattern covers it | `skills/ship/SKILL.md` | run-again/REQ-4 | **nothing else** |
| 75 | `setup-rule-count` | setup says all sr_w rules; sr_n files under rules/ | `skills/setup/SKILL.md` | run-again/REQ-5 | **nothing else** |
| 76 | `ship-retry` | a reply with no verdict line starts the reviewer once more; a second miss is FAIL | `skills/ship/SKILL.md` | run-again/REQ-15 | **nothing else** |
| 77 | `reviewer-fixture` | two states named; a contradicted decision fails the verdict; no claim about the gate | `agents/reviewer.md` | decisions-bind/REQ-12, decisions-bind/REQ-13 | 1 assertion(s) of this check that run something; an eval case |
| 80 | `stamp-dates` | no literal date on a stamp line in any skill; all six hold <YYYY-MM-DD>, and each file names date +%F | the files the check names | fourth-project/REQ-4, fourth-project/REQ-5 | **nothing else** |
| 82 | `fired-if-tracked` | the Fired-if section says a command reads tracked files, and names git grep | `skills/spec/reference.md` | fourth-project/REQ-10 | **nothing else** |
| 83 | `superseded-report` | the report section names an earlier day's untracked report as superseded and leaves it | `skills/ship/SKILL.md` | review-and-ship/REQ-14, review-and-ship/REQ-20 | check 29 |
| 84 | `walk-sentence` | walk.md's opening comment says the agent cannot ask or write, in one sentence | `skills/ask/walk.md` | gate-on-setup/REQ-1 | **nothing else** |
| 85 | `ship-write-path` | step 4 prints the review file's path, then gives Write the path it printed | `skills/ship/SKILL.md` | gate-on-setup/REQ-2 | **nothing else** |
| 89 | `reviewer-marks` | three marks; a turned-down part is contradicted; partly built keeps the verdict | `agents/reviewer.md` | gate-on-setup/REQ-14, gate-on-setup/REQ-15 | **nothing else** |
| 91 | `git-grep` | the gate searches with git grep -n, -E, never \\/; step 3 reads an untracked tasks.md | `agents/reviewer.md`, `skills/ship/SKILL.md`, `skills/ship/reference.md` | users-machine/REQ-4, users-machine/REQ-5, users-machine/REQ-6 | **nothing else** |
| 94 | `goldfish-agent` | sonnet, read-only, no Agent; reads spec and design only, ignores all but the slug; TESTABLE/UNCLEAR rows,… | `agents/goldfish.md` | spec-goldfish/REQ-1, spec-goldfish/REQ-2, spec-goldfish/REQ-3, spec-goldfish/REQ-4, spec-goldfish/REQ-5, spec-goldfish/REQ-6, spec-goldfish/REQ-7, spec-goldfish/REQ-21 | **nothing else** |
| 95 | `spec-goldfish-step` | Q2 starts shipkit:goldfish with the slug before the Plan Mode gate; reply to a file, whole; dispositions;… | `skills/spec/SKILL.md`, `skills/spec/reference.md` | spec-goldfish/REQ-8, spec-goldfish/REQ-9, spec-goldfish/REQ-10, spec-goldfish/REQ-11, spec-goldfish/REQ-12, spec-goldfish/REQ-13, spec-goldfish/REQ-14, spec-goldfish/REQ-15 | **nothing else** |

## What the table says

35 of the 247 assertions in the script only read wording. 18 of them belong to a
check that has no assertion of another kind and whose requirements nothing else cites: for those,
the wording is all the proof there is. They are the first candidates for a behaviour check or an
eval case, and Sprint 34's prune reads this file for that (`docs/plans/verifier-sprint-plan.md`,
S34-T3). Nothing is cut or added here.
