# Tasks: Measure and slim (Sprint 1, release 3.2.0)

One commit per task, test and code together. The steps, files and "Check first" experiments
for each task are in `docs/plans/quality-gate-sprint-plan.md` under the same task number.

- [x] **T1** (S1-T1) Prove the eval tool works: the `hello` case, `scripts/evals.sh`, and
      `evals/README.md` with the working format and what graders can check
      → REQ-1, REQ-2, REQ-3, REQ-4
- [x] **T2** (S1-T2) Build the fixture project and `FACTS.md` (F1 to F4)
      → REQ-5, REQ-6, REQ-7, REQ-8
- [x] **T3** (S1-T3) Four `grandfather` cases; record the 3.1.0 baseline → REQ-9, REQ-11
      (after T1, T2)
- [x] **T4** (S1-T4) Measure with the map, without the map, and without the plugin; write
      `eval-results-3.2.md` and decision 0001 → REQ-12, REQ-13, REQ-14  (after T3)
- [x] **T5** (S1-T5) Three `rules` cases; record the 3.1.0 baseline → REQ-10, REQ-11
- [x] **T6** (S1-T6) Shrink the three always-on rules; move detail into the commit and spec
      skills; add the lint budget; fix the context-audit numbers
      → REQ-15, REQ-16, REQ-17, REQ-18, REQ-19, REQ-20  (after T5; test first: the lint budget
      check fails on the 11,867-byte rules before the shrink)
- [ ] **T7** (S1-T7) Commit guard hook and its four smoke checks
      → REQ-21, REQ-22, REQ-23, REQ-24, REQ-25, REQ-26  (test first: the smoke checks fail
      while `guard-commit.sh` does not exist)
- [ ] **T-REL** Release 3.2.0: version in five places, changelog, sprint exit checklist, pull
      request → REQ-27, REQ-28

Order tasks so each leaves the build green. Every requirement is covered by a task; every
requirement not marked `[untested: …]` in `spec.md` is covered by an eval case, a smoke check
or a lint check.
