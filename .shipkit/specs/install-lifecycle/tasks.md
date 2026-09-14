# Install Lifecycle — Tasks

> Spec accepted at commit `ce3ec19` on main.

Ordered by risk. Each task cites the requirement it satisfies. One atomic commit per task.

## Tranche 1 — zero design risk ✅ (commit dc7748c)

- [x] **T-1** Quote the four hook commands in `plugins/shipkit/hooks/hooks.json` → REQ-3
- [x] **T-2** README local-testing command names both plugin roots → REQ-4
- [x] **T-3** Harden `legacy-audit/SKILL.md:14` bare `ls` → REQ-1
- [x] **T-4** Harden `stacks/python/.claude/skills/new-feature/SKILL.md:26` bare `ls` → REQ-1
      *(missed by the review; identical defect)*
- [x] **T-5** Lint guard rejecting bare multi-arg `ls` in `` !` `` injections → REQ-2
      *(verified: 6 errors against the ce3ec19 tree, 0 against the fixed one)*

## Tranche 2 — low risk, mechanical ✅ (commit 177871c)

- [x] **T-6** Add lockfiles to the manifest-change expression in `session-start.sh` → REQ-11
- [x] **T-7** Sort stale specs most-stale-first, rotate offset, report total → REQ-12 (DR-5)
      *(amended DR-5: line 1 is pinned, only the remaining slots rotate — rotating the whole
      window hid the worst offender, trading one starvation bug for a worse one)*

## Tranche 3 — installation ownership (the design work) ✅ (commits 06af9ab + this one)

- [x] **T-8** `lib-manifest.sh`: write/read/verify a per-file manifest → REQ-8 (DR-1)
- [x] **T-9** `install-rules.sh` writes the manifest atomically; reconciles obsolete
      owned files → REQ-7 (DR-1, DR-2)
- [x] **T-10** `inject-rule.sh` per-rule `-f` check + injection fallback → REQ-5 (DR-3)
- [x] **T-11** `session-start.sh` completeness warning naming the missing file; legacy
      stamp ⇒ no delete authority → REQ-6 (DR-2, DR-3)
- [x] **T-12** `install-stack.sh` closing marker + in-region refresh, non-interactive
      warn mode → REQ-9, REQ-10 (DR-4)
- [x] **T-13** Manifest covers overlay rules and skills → REQ-8

## Tranche 4 — documentation honesty ✅ (commit 5439f4c)

- [x] **T-14** MemPalace access claim in `connect-memory/SKILL.md` → REQ-13
- [x] **T-15** Verification framing (README / `ask`) → REQ-14
- [x] **T-16** Soften `code-review-standards` MUSTs; comment the deliberate asymmetry
      in `tdd/SKILL.md` → REQ-15 (DR-6)

## Verification

- [x] **T-17** Smoke fixtures: incomplete-install, reconcile, legacy-stamp, drift,
      claude-md-refresh, manifest-overlays, freshness, spec-staleness. The pre-3.1 `sha=`
      tamper was replaced — a v1 manifest has no `sha=` line, so that assertion had become
      a silent no-op.
- [x] **T-18** `lint.py` 0 errors / 0 warnings; CHANGELOG entry for 3.1.0; version lockstep
      across `plugin.json` ×2 + `marketplace.json`. The 11 pure-shell smoke checks (8, 8b–8e,
      9, 10, 11) all pass when run under `/bin/sh`. The model-dependent checks (1–7) need a
      logged-in `claude` CLI and were **not** run here — `./scripts/smoke.sh` before tagging.

## Note for whoever runs the fixtures

`smoke.sh` is `#!/bin/sh` and must be executed, not sourced into an interactive zsh: zsh does
not word-split unquoted `$pyargs`, so check 9's `install-stack.sh` call receives one argument
instead of five and silently installs nothing. Three "failures" during this work were that,
not the product.

## Deferred — not in this spec

- `/unsetup` restore safety → own spec (destructive path, source-verified only)
- Behavioral evaluation suite, net-efficiency benchmarking → separate effort
