# Tasks: What a set-up project pays (Sprint 21)

One commit per task, test and code together. The steps for each task are in
`docs/plans/thinning-sprint-plan.md` under the same task number (S21-T0 to S21-T4, S21-T-MERGE).
**Measurement runs are in the plan's budget line (§4, Sprint 21 ≈ $6–16): W9 baseline 15 +
arm 15 runs (≈ $4), bisection only on a drop (up to $10, the owner says go first), two shape
runs (≈ $0.30), the `--group` runs at merge. Anything else needs the owner's yes (rule 15).
T2, T3 and T4 STOP for the owner's word before anything shipped moves (rule 6).**

- [x] **T0** Write the sprint spec (S21-T0) → REQ-1 to REQ-13, the spec itself
  - Files: .shipkit/specs/overlays-and-eve/
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . overlays-and-eve --as-open` → 0 gaps on the draft; `sh plugins/shipkit/scripts/decision-check.sh .` → no FIRED; `bash scripts/lint.sh` → 0/0
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the spec in the thread; stamped at the branch-point commit, `Status: open`
- [x] **T1** Overlay skills behind a flag (S21-T1, W6) → REQ-1, REQ-2, REQ-3, REQ-4
  - Files: plugins/shipkit/scripts/install-stack.sh, plugins/shipkit/skills/setup/SKILL.md, plugins/shipkit/scripts/unsetup-remove.sh, scripts/smoke.sh, GUIDE.md
  - Test: Check first: `install-stack.sh --with-skills <root> rails <dir> KEY=…` parses with the positional contract intact (else `SHIPKIT_STACK_SKILLS=1`). scripts/smoke.sh check 67 "skills-flag" (a Rails install without the flag leaves `.claude/skills/` untouched and the manifest lists no skill — cites `overlays-and-eve/REQ-1`; with the flag, the six skills and manifest rows as today — `overlays-and-eve/REQ-2`; `unsetup-remove.sh` removes exactly the installed set in each case — `overlays-and-eve/REQ-4`; the setup skill's text asks once and names the count — `overlays-and-eve/REQ-3`) — written first, red
  - After: T0
  - Done when: check 67 → PASS; the field-notes form of setup on a scratch Rails project shows the question once; lint 0/0
- [ ] **T2** The overlay appends and the two unscoped rules, audited (S21-T2, W7) → REQ-5, REQ-6, REQ-7
  - Files: docs/design/trim-audit-overlays.md, plugins/shipkit/stacks/*/CLAUDE.md.append, plugins/shipkit/stacks/rails/.claude/rules/rails.md, plugins/shipkit/stacks/react/.claude/rules/react.md, scripts/smoke.sh
  - Test: the audit's table read by the owner (**STOP**); after the cuts, scripts/smoke.sh check 58's kept list if a measured line moved, and a check that `rails.md`/`react.md` carry `paths:` or the audit says why not (cites `overlays-and-eve/REQ-7`); `scripts/context-cost.sh` on a scratch Rails and a scratch Python project before and after (the `overlay-appends` row)
  - After: T1
  - Done when: every row has a verdict and a reason; the cuts the owner approved are out and no other; the appends' bytes in `context-cost.md`; lint 0/0
- [ ] **T3** The eleven overlay skills against the loop (S21-T3, W8) → REQ-8, REQ-9, REQ-10
  - Files: docs/design/trim-audit-overlays.md, plugins/shipkit/stacks/*/.claude/skills/, .shipkit/decisions/0004-overlay-skills-flag.md, .shipkit/decisions/0003-overlay-skills-home.md, plugins/shipkit/scripts/install-stack.sh, scripts/smoke.sh, GUIDE.md
  - Test: the side-by-side read by the owner (**STOP**, a yes per cut); `sh plugins/shipkit/scripts/decision-check.sh .` lists 0004 and no FIRED (cites `overlays-and-eve/REQ-10`); scripts/smoke.sh: the checks that count overlay skills follow; a check that no cut skill's directory exists and `install-stack.sh --with-skills` installs only the kept set (cites `overlays-and-eve/REQ-9`)
  - After: T2
  - Done when: 0004 is a five-part record with a concrete reversal condition; 0003 is marked, not deleted; every cut has its yes in the thread; lint 0/0
- [ ] **T4** `eve`'s prompt by the audit's clause (S21-T4, W9) → REQ-11, REQ-12, REQ-13
  - Files: plugins/shipkit/agents/eve.md, plugins/shipkit/skills/ask/SKILL.md, docs/design/trim-audit-eve.md, docs/design/eval-results-5.0.md, .shipkit/decisions/0001-project-map-default.md
  - Test: baseline 15 runs and the arm 15 runs (`--keep-temp`; `map_read` and tool calls from the traces, cites `overlays-and-eve/REQ-11` in `scripts/evals.sh`'s citation comment); **STOP: the owner sees the table**; bisection only on a drop; two shape runs through `/shipkit:ask --all matrix rails` and `--all consolidate` on the portfolio fixture, the replies read for the shape (cites `overlays-and-eve/REQ-13`); `wc -c plugins/shipkit/agents/eve.md` ≤ 11,500 if the arm held
  - After: T3
  - Done when: the table has no empty cell; every candidate kept out holds its 4.12.0 count by the audit's clause, or is back with the record saying why; `eve.md` ≤ 11,500 bytes if the arm held; the sandboxes removed; lint 0/0
- [ ] **T-MERGE** Merge, untagged (S21-T-MERGE, rule 22)
  - Files: docs/design/context-cost.md
  - Test: the exit checklist: lint; the full smoke suite; `--group eve`, `--group digest`, `--group stacks`; spec-check 0 gaps; the two byte lines; the §0 table re-measured into context-cost.md (a scratch Rails project's `overlay-skills` and `overlay-appends` rows before and after)
  - After: T4
  - Done when: every line true; pull request with "What was awkward"; merged with a merge commit; no tag; the owner's cache untouched
