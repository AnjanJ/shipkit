# Tasks: One eval per rule (Sprint 9)

One commit per task, test and code together. The steps for each task are in
`docs/plans/evidence-sprint-plan.md` under the same task number (S9-T1 to S9-T5), as amended
by the intake beside this file (eighteen rule files, `scoped/` for the core group, the
ceiling at 131,072 bytes). **T4 ends with a stop:** the owner sees the eighteen-row table
before T5 starts; T4 changes no file under `plugins/shipkit/rules/` or `stacks/`.

- [x] **T1** The rule harness, the stack mini-fixtures, `--group`, the ceiling (S9-T1) → REQ-1, REQ-2, REQ-3, REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9, REQ-21, REQ-22
  - Files: plugins/shipkit/evals/lib/with-rule.sh, plugins/shipkit/evals/fixtures/stack-gen.sh, plugins/shipkit/scripts/inject-rule.sh, plugins/shipkit/hooks/hooks.json, scripts/evals.sh, scripts/smoke.sh, scripts/lint.py, plugins/shipkit/evals/README.md, .shipkit/specs/rule-evals/spec.md, .shipkit/specs/rule-evals/design.md, .shipkit/specs/rule-evals/tasks.md, .shipkit/specs/rule-evals/intake.md (the hook script, hooks.json and the four spec files added with the owner's yes on 2026-10-07, after the Check first and its fallback both failed)
  - Test: scripts/smoke.sh checks "with-rule" (installs a core rule and a stack rule into scratch workspaces; the file equals the plugin's copy; the manifest names it and the plugin version; the marker names it; SHIPKIT_EVAL_NO_RULE=1 installs nothing; SHIPKIT_EVAL_RULE_REF=v3.7.0 installs the tag's text), "eval-inject" (`inject-rule.sh --eval-rule` prints the marked file with CLAUDE_CODE_EVAL_CONFINED=1 and nothing without the variable or without the marker; hooks.json carries the command), "stack-gen" (each of the nine stacks with rules matches a glob of each of its rule files; `static` matches ui-ux.md; `monorepo` matches monorepo.md; `rails` matches migrations.md), "evals-group" (a stub `claude` on PATH shows `--group stacks` → `--case stacks-*` and no flag → no `--case`), and check 42 (lint-negative) expecting "the limit is 131,072" — all written first, red
  - After: none
  - Done when: the four new smoke checks → PASS; check 42 → PASS; `sh -n` clean on both new scripts; `bash scripts/lint.sh` → 0 error(s), 0 warning(s); `find plugins/shipkit/evals -type f -print0 | xargs -0 cat | wc -c` ≤ 131072; the Check-first answer (no `.claude/` file loads in the sandbox; the hook does) is in evals/README.md
- [x] **T2** Cases for the five path-scoped core rules (S9-T2) → REQ-10, REQ-12, REQ-13
  - Files: plugins/shipkit/evals/scoped/, scripts/smoke.sh, scripts/evals.sh, plugins/shipkit/evals/README.md
  - Test: scripts/smoke.sh check "rule-cases" (each of the five case folders has prompt.md, case.yaml, fixture.sh and one scored grader; `description:` names a rule file that exists under plugins/shipkit/rules/; fixture.sh calls with-rule.sh; the scaffold runs in a scratch directory and the rule lands under .claude/rules/shipkit/) — written first, red
  - After: T1
  - Done when: the "rule-cases" smoke check → PASS; `bash scripts/evals.sh --group scoped` runs five cases and prints a result for each, recorded in evals/README.md under "Baseline 4.1.0 (scoped)"; lint 0/0
- [x] **T3** Cases for the thirteen stack rule files (S9-T3) → REQ-11, REQ-12, REQ-13
  - Files: plugins/shipkit/evals/stacks/, scripts/smoke.sh, scripts/evals.sh, plugins/shipkit/evals/README.md
  - Test: scripts/smoke.sh check "rule-cases" extended to the thirteen stack cases (same assertions; the rule file is under plugins/shipkit/stacks/*/.claude/rules/; the scaffold runs stack-gen.sh then with-rule.sh) — red before the cases exist
  - After: T2
  - Done when: the "rule-cases" smoke check → PASS for all eighteen; `bash scripts/evals.sh --group stacks` runs thirteen cases and prints a result for each, recorded under "Baseline 4.1.0 (stacks)"; evals bytes ≤ 131072; lint 0/0
- [ ] **T4** Measure: with, without, and before the trim (S9-T4) → REQ-14, REQ-15, REQ-16
  - Files: docs/design/eval-results-4.2.md, docs/design/trim-audit-4.0.md, ROADMAP.md
  - Test: reading — the eighteen-row table has no empty cell (the four unchanged files say "same text" in the pre-trim column); every cell has three tool-call counts from scripts/trace-tools.sh; the trim audit's new section has fourteen lines and `git diff main -- docs/design/trim-audit-4.0.md` shows additions only
  - After: T3
  - Done when: the table is shown to the owner; the three readings (passes equally without; pre-trim scores higher; fails even with) are written with the trace evidence; ROADMAP's "Still open" drops criterion (c); `git diff --stat main -- plugins/shipkit/rules plugins/shipkit/stacks` shows nothing
- [ ] **T5** `rules/nontrivial`: fix it or accept it (S9-T5) → REQ-17, REQ-18, REQ-19, REQ-20
  - Files: plugins/shipkit/rules/spec-driven.md, plugins/shipkit/rules/shipkit.md, .shipkit/decisions/0002-spec-first-eval.md, plugins/shipkit/evals/README.md, .shipkit/specs/rule-evals/spec.md
  - Test: `bash scripts/evals.sh --group rules` after each attempt (nontrivial ≥ 2 of 3 and trivial, decision at baseline → keep; else revert); `cat plugins/shipkit/rules/{shipkit,spec-driven,decisions}.md | wc -c` ≤ 3000; the branch of REQ-19/REQ-20 not taken is marked `[untested: the condition did not hold]`
  - After: T4
  - Done when: three failing traces are read before any edit and quoted in record 0002's Context; record 0002 exists with a concrete clause; `bash scripts/lint.sh` → 0/0; the README's known-result note is updated either way

## After the gate

- **Ship:** run `/shipkit:ship rule-evals` on this branch and fix what it finds; the report
  starts with `READY` and is committed.
- **Release 4.2.0:** version in five places, changelog (the field notes name the rule with the
  largest gap between the with and without arms, and the one with the smallest), counts, the
  sprint exit checklist, pull request, merge after a green check, tag `v4.2.0`.
