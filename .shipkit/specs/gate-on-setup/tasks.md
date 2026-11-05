# Tasks: What the gate says about setup (Sprint 26)

One commit per debt in T1, one commit each for T2 and T3, test and code together. The steps are in
`docs/plans/machine-sprint-plan.md` under the same task number (S26-T0 to S26-T3, S26-T-MERGE). **The
only paid run is `--group reviewer` at the merge (§4, Sprint 26 ≈ $2); anything else needs the
owner's yes (rule 15).** A smoke check is run alone while it is written: the suite's lines up to
`# 1.` with `ROOT=` pinned to the checkout, the block, the suite's last three lines, through `sh`.
Every scratch copy is removed after reading (rule 13).

- [x] **T0** Write the sprint spec (S26-T0) → REQ-1 to REQ-15, the spec itself
  - Files: .shipkit/specs/gate-on-setup/, docs/plans/machine-sprint-plan.md
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . gate-on-setup --as-open` → 0 gaps on the draft; `sh plugins/shipkit/scripts/decision-check.sh . --run` → no FIRED or ERROR; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the spec, and the word on the fourth record's change to G2, in the thread; stamped at the branch-point commit, `Status: open`; the plan's approval line, and G2 amended if the owner says yes, in the same commit
- [x] **T1** Four small debts (S26-T1, G1) → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6
  - Files: plugins/shipkit/skills/ask/walk.md, plugins/shipkit/skills/ship/SKILL.md, plugins/shipkit/stacks/elixir/CLAUDE.md.append, plugins/shipkit/skills/setup/SKILL.md, plugins/shipkit/scripts/spec-check.sh, plugins/shipkit/skills/spec/SKILL.md, plugins/shipkit/skills/spec/reference.md, scripts/smoke.sh, CHANGELOG.md
  - Test: scripts/smoke.sh, each written first and run alone, red: check 84 "walk-sentence" (no "The agent It" in `walk.md`; cites `gate-on-setup/REQ-1`); check 85 "ship-write-path" (step 4 names `printf` before `Write`, and no line gives `Write` a `${TMPDIR`; cites `gate-on-setup/REQ-2`); check 86 "elixir-app" (an install with no `APP_NAME` exits 2 naming it; one with `APP_NAME=my_app` writes `lib/my_app/` and no `<app>`; cites `gate-on-setup/REQ-3`, `REQ-4`; lint check 9 holds REQ-4's table row); check 87 "stray-status" (a fixture's `design.md` with `> Status: draft` → `STRAY-STATUS`, exit 1; the same spec without it → exit 0; both spec skill lists name it; cites `gate-on-setup/REQ-5`, `REQ-6`)
  - After: T0
  - Done when: checks 84 to 87 PASS alone; check 68 PASS (the elixir append at most 1,220 bytes); `sh plugins/shipkit/scripts/spec-check.sh .` → 0 gaps on every spec; lint 0/0
- [x] **T2** Setup's own files are not the spec's (S26-T2, G2 as amended) → REQ-7, REQ-8, REQ-9, REQ-10, REQ-11, REQ-12, REQ-13
  - Files: plugins/shipkit/scripts/setup-files.sh, plugins/shipkit/scripts/brief-verify.sh, plugins/shipkit/scripts/unsetup-remove.sh, plugins/shipkit/agents/reviewer.md, plugins/shipkit/skills/setup/SKILL.md, scripts/smoke.sh, .shipkit/specs/run-debts/design.md, .shipkit/specs/run-debts/spec.md, CHANGELOG.md
  - Test: scripts/smoke.sh, written first and run alone, red: check 88 "setup-files" on brief-verify's fixture in the 5.1 shape (a new `CLAUDE.md` and a `.gitignore` with five lines): `record` then `check` prints both (`gate-on-setup/REQ-7`, `REQ-8`); brief-verify gives no `OUTSIDE` for either (`REQ-9`); one more line in each → `OUTSIDE` for each (`REQ-9`, the other side); no record → both `OUTSIDE`, as part c2 still asserts; the reviewer's step 4 names `.setup-files` and `git hash-object` (`REQ-10`); setup's Phase 7 runs `record` before the summary (`REQ-11`); `unsetup-remove.sh` on an installed fixture leaves no `.setup-files` (`REQ-12`)
  - After: T1
  - Done when: check 88 PASS alone, both sides; the `brief-verify` and `shipkit-allowed` checks PASS alone; `run-debts`' fifth record marked `Superseded`, so `brief.sh` leaves it out, and REQ-6 and REQ-7 noted; lint 0/0
- [x] **T3** `partly built` (S26-T3, G3) → REQ-14, REQ-15
  - Files: plugins/shipkit/agents/reviewer.md, scripts/smoke.sh, .shipkit/specs/decisions-bind/spec.md, CHANGELOG.md
  - Test: scripts/smoke.sh, written first and run alone, red: check 89 "reviewer-marks" (step 5 names `contradicted`, `partly built` and `not built`, and a part that does what the record turned down is `contradicted`; the reply's shape lists all three; the verdict paragraph says `partly built` does not change it; cites `gate-on-setup/REQ-14`, `REQ-15`); check 77 still PASS
  - After: T2
  - Done when: checks 77 and 89 PASS alone; `decisions-bind/REQ-7` amended in place with its note; lint 0/0
- [x] **T-MERGE** Merge, untagged (S26-T-MERGE) → the merge steps in `spec.md`
  - Files: .shipkit/specs/gate-on-setup/
  - Test: the sprint exit checklist with `bash scripts/evals.sh --group reviewer -j 4`, every case 3 of 3; the full smoke suite (rule 22)
  - After: T3
  - Done when: the checklist holds; the pull request merged after a green check, no tag; the owner's cache untouched
