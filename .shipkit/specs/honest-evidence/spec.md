# Spec: honest evidence

> Spec accepted at commit `5367060` on sprint-29/honest-evidence.
> Status: open
> Paths: scripts/smoke.sh, plugins/shipkit/scripts/, plugins/shipkit/skills/ship/, plugins/shipkit/skills/spec/, .github/workflows/, GUIDE.md, docs/design/smoke-audit-5.4.md
> Tests: scripts/, .github/workflows/

## Purpose

Make what shipkit already knows about how well a spec is proven visible, and make the smoke suite
runnable without paying for a model. Today `READY` reads the same whether every requirement has a
test or none has; a citation counts in any file, even a comment or a skipped test; a branch can
edit the spec that judges it and nothing says so; and the suite cannot run without starting
`claude`. This is Sprint 29 of `docs/plans/verifier-sprint-plan.md`.

## User stories

- As the owner, I want to run the smoke suite for nothing while I build, so that paid runs can
  wait for the end.
- As the owner reading a ship report, I want to see how many requirements were tested and how
  many were only read, so that `READY` on reading alone does not look like `READY` on tests.
- As a reviewer of a branch, I want to be told when the branch changed its own requirements, so
  that a weakened requirement is seen and not just met.

## Terms

- **A numbered check.** A section of `scripts/smoke.sh` whose first line is a comment
  `# <label>. …`, where the label is a number with an optional letter. At 5.3.0 there are 100, in
  the file's order: 1, 2, 2b, 3, 4, 5, 5b, 6, 7, 8, 8b, 8c, 8d, 8e, 9, 10, 11, 9b, 9c, 11b, and
  17 to 96. Line 1944, `# 26. No claude needed`, is a wrapped sentence and not a check. `<n>` in
  a requirement is a check's label, and `<name>` the one short name the script gives that label.
- **A check that starts a model.** A numbered check in `scripts/smoke.sh` that runs `claude`. At
  5.3.0 these are checks 1, 2, 2b, 3, 4, 5, 5b, 6, 22, 23, 29, 31, 32, 50, 54 and 64.
- **A check needs another** when it reads a file that the other's model session wrote. At 5.3.0
  there is one such pair: check 32 needs check 31.
- **A counted citation.** A `<slug>/REQ-N` string that `spec-check.sh` counts toward that
  requirement. At 5.3.0 that is one in any file outside `.shipkit/`, `docs/` and `*.md`.
- **A skip marker.** One of these strings: `@tag :skip`, `@moduletag :skip`, `it.skip`,
  `test.skip`, `describe.skip`, `xit(`, `xdescribe(`, `@pytest.mark.skip`, `@unittest.skip`,
  `pytest.skip(`, `xfail`, `t.Skip(`, or a line whose first word is `skip` or `pending`.
- **A waiver.** The `untested` note, with its reason, that excuses a requirement from having a
  test, as `spec/reference.md` describes it.
- **The base ref.** The commit a branch's work started from. When none is given: the merge base
  of `HEAD` and the default branch (`main`, or `master`).
- **A text-only assertion.** A smoke assertion whose result depends only on the text of a skill,
  agent or rule file, read with `grep`, `sed` or `awk`. An assertion that runs a script or starts
  a model is not one. At 5.3.0 check 76, `ship-retry`, is one: it looks for three phrases in
  `plugins/shipkit/skills/ship/SKILL.md`.

## Requirements (EARS)

The smoke suite without a model:

- **REQ-1.** When `scripts/smoke.sh` is run with `--no-model`, it shall start no `claude` process.
- **REQ-2.** When run with `--no-model`, it shall print `SKIP  [model] <n> <name>` once for each
  check that starts a model.
- **REQ-3.** While run with `--no-model`, the suite shall still run every assertion that needs no
  model, including one that sits in a check that starts a model.
- **REQ-4.** If `claude` is not on the `PATH` and `--no-model` is given, then the suite shall run
  and exit 0 when no assertion fails.
- **REQ-5.** When run with `--only <n>[,<n>]`, the suite shall run, of the checks that start a
  model, only the ones named and the ones they need, and shall still run every assertion that
  needs no model.
- **REQ-6.** If `--only` names a number that is not a check that starts a model, then the suite
  shall run nothing, print the numbers it accepts, and exit 64.
- **REQ-7.** When run with `--list`, alone or with `--no-model` or `--only`, the suite shall run
  no check and print one line for each numbered check: `RUN <n> <name>` for a check that would
  run, `SKIP <n> <name>` for a check that starts a model and would be skipped. A check that
  starts no model is always `RUN`.
- **REQ-8.** When run with `--list` and no other argument, the suite shall print every numbered
  check as `RUN`.
- **REQ-9.** The suite shall print, before its last line, `smoke: <p> passed (<t> text-only),
  <s> skipped (model), <f> failed`.
- **REQ-10.** While no assertion failed and a check was skipped, the suite's last line shall be
  `smoke: all checks run passed; <s> skipped (model)`, and its exit status 0.
- **REQ-11.** The repository's CI shall run `scripts/smoke.sh --no-model` on every pull request.

How much was tested:

- **REQ-12.** When `spec-check.sh` checks a spec, it shall print `EVIDENCE <slug> tested=<a>
  waived=<b> uncited=<c>`, where `b` is the number of its requirements with a waiver, `a` the
  number with no waiver and a counted citation, and `c` the rest.
- **REQ-13.** `spec-check.sh` shall print every `EVIDENCE` line before its summary line, and the
  summary line shall keep the form `spec-check: <n> spec(s) checked, <g> gap(s)`.
- **REQ-14.** An `EVIDENCE` line shall not change `spec-check.sh`'s exit status.

Where a citation counts:

- **REQ-15.** Where a spec's `spec.md` has a `> Tests:` line, `spec-check.sh` shall count a
  citation of that spec's requirements only in a file that is one of the paths listed or lies
  under a folder listed.
- **REQ-16.** Where a spec has a `> Tests:` line and a citation of one of its requirements sits
  in a file outside the paths listed, `spec-check.sh` shall print `CITED-ELSEWHERE <slug> REQ-N
  <file>`.
- **REQ-17.** While a spec has no `> Tests:` line, `spec-check.sh` shall count its citations as
  it does at 5.3.0.
- **REQ-18.** A `CITED-ELSEWHERE` line shall not by itself change `spec-check.sh`'s exit status.

A citation in a skipped test:

- **REQ-19.** When a counted citation sits on a line that holds a skip marker, or within three
  lines above or below such a line, `spec-check.sh` shall print `SKIPPED-CITE <slug> REQ-N
  <file>:<line>`, where `<line>` is the citation's line.
- **REQ-20.** A `SKIPPED-CITE` line shall not change `spec-check.sh`'s exit status.

A requirement edited on its own branch:

- **REQ-21.** `spec-diff.sh <project> <slug> [base]` shall compare the spec's requirements in the
  working tree with a baseline: `spec.md` at the base ref when the file exists there, otherwise
  `spec.md` at the first commit after the base ref in which its `> Status:` line reads `open`.
- **REQ-22.** If the spec has neither baseline, then `spec-diff.sh` shall print `NO-BASELINE
  <slug>` and exit 0.
- **REQ-23.** When a requirement's words differ from the baseline's, `spec-diff.sh` shall print
  `REQ-CHANGED <slug> REQ-N`.
- **REQ-24.** While a requirement's words are the same as the baseline's and only its line breaks
  or spacing differ, `spec-diff.sh` shall print nothing for it.
- **REQ-25.** When a requirement is in the working tree's spec and not in the baseline,
  `spec-diff.sh` shall print `REQ-ADDED <slug> REQ-N`.
- **REQ-26.** When a requirement is in the baseline and not in the working tree's spec,
  `spec-diff.sh` shall print `REQ-REMOVED <slug> REQ-N`.
- **REQ-27.** When a requirement has a waiver in the working tree and had none in the baseline,
  `spec-diff.sh` shall print `WAIVER-ADDED <slug> REQ-N`, as well as its `REQ-CHANGED` line.
- **REQ-28.** `spec-diff.sh` shall exit 0 when it prints none of those four kinds of line, 1 when
  it prints at least one, and 64 on wrong usage, an unknown spec or an unknown base ref.
- **REQ-29.** `spec-diff.sh` shall change no file, and shall be POSIX `sh` with awk and git only.
- **REQ-30.** When the difference between the base ref and the working tree includes the task's
  own spec's `spec.md` or `design.md`, `brief-verify.sh` shall print `SPEC-EDITED <file>`.
- **REQ-31.** A `SPEC-EDITED` line shall not change `brief-verify.sh`'s exit status, and a change
  to the spec's `tasks.md` shall print no such line.

Assertions that only read wording:

- **REQ-32.** When a text-only assertion passes, `scripts/smoke.sh` shall print it as
  `PASS  [text] <name>`.
- **REQ-33.** `docs/design/smoke-audit-5.4.md` shall list each text-only assertion with the
  requirement it cites and what else, if anything, proves that requirement. [untested: a record,
  verified by reading]

What a model reads (applied in Sprint 35, after its baseline):

- **REQ-34.** The ship report shall carry, under its `> Checked on` line, the line `> Evidence:
  <a> of <n> requirements have a cited test; <b> read only.`, with the numbers of the spec's
  `EVIDENCE` line.
- **REQ-35.** When the spec's `EVIDENCE` line reads `tested=0`, the gate's reply to the owner
  shall say that the result rests on reading alone.
- **REQ-36.** The ship report shall quote, under step 1's evidence and the heading "Requirements
  changed on this branch", every line `spec-diff.sh` printed for the spec.
- **REQ-37.** When `/shipkit:spec` accepts a spec's requirements, it shall ask where the
  feature's tests live and write the answer as a `> Tests:` line. [untested: a run, read from the
  record of Sprint 35's real run]
- **REQ-38.** `spec/reference.md` shall describe the `> Tests:` line among the lines scripts
  read. [untested: prose, verified by reading]
- **REQ-39.** `GUIDE.md` shall name `--no-model`, `--only`, the `> Tests:` line, `spec-diff.sh`
  and the four new kinds of line (`EVIDENCE`, `CITED-ELSEWHERE`, `SKIPPED-CITE`, `SPEC-EDITED`).
  [untested: prose, verified by reading]

Added after the goldfish's read:

- **REQ-40.** If `--no-model` and `--only` are given together, then the suite shall run nothing
  and exit 64.

## Out of scope

- Any paid model run in this sprint, and any change to an existing skill, agent or rule file
  before Sprint 35 (the plan's rules 33 and 34). REQ-34 to REQ-38 are this spec's, and their
  tasks wait for that sprint.
- `--only` for a check that starts no model. Those always run, and they cost nothing.
- Making `SKIPPED-CITE` or `CITED-ELSEWHERE` a gap by itself, or making a changed requirement
  block anything.
- A test left out by configuration, such as an ExUnit tag excluded in `test_helper.exs`. It has
  no skip marker near it and is not seen.
- A `> Tests:` line on any of the 31 specs shipped before this one.
- Cutting any smoke check. The labels and the audit are this sprint's; the cuts are Sprint 34's.
- The gate script, the single test command, `release-check.sh` and the judge: Sprint 30.
