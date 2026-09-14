# Install Lifecycle — Tasks

> Spec accepted at commit `ce3ec19` on main.

Ordered by risk. Each task cites the requirement it satisfies. One atomic commit per task.

## Tranche 1 — zero design risk

- [ ] **T-1** Quote the four hook commands in `plugins/shipkit/hooks/hooks.json` → REQ-3
- [ ] **T-2** README local-testing command names both plugin roots → REQ-4
- [ ] **T-3** Harden `legacy-audit/SKILL.md:14` bare `ls` → REQ-1
- [ ] **T-4** Harden `stacks/python/.claude/skills/new-feature/SKILL.md:26` bare `ls` → REQ-1
      *(missed by the review; identical defect)*
- [ ] **T-5** Lint guard rejecting bare multi-arg `ls` in `` !` `` injections → REQ-2
      *(regression fixture for T-3/T-4; must fail against pre-T-3 tree)*

## Tranche 2 — low risk, mechanical

- [ ] **T-6** Add lockfiles to the manifest-change expression in `session-start.sh` → REQ-11
- [ ] **T-7** Sort stale specs most-stale-first, rotate offset, report total → REQ-12 (DR-5)

## Tranche 3 — installation ownership (the design work)

- [ ] **T-8** `lib-manifest.sh`: write/read/verify a per-file manifest → REQ-8 (DR-1)
- [ ] **T-9** `install-rules.sh` writes the manifest atomically; reconciles obsolete
      owned files → REQ-7 (DR-1, DR-2)
- [ ] **T-10** `inject-rule.sh` per-rule `-f` check + injection fallback → REQ-5 (DR-3)
- [ ] **T-11** `session-start.sh` completeness warning naming the missing file; legacy
      stamp ⇒ no delete authority → REQ-6 (DR-2, DR-3)
- [ ] **T-12** `install-stack.sh` closing marker + in-region refresh, non-interactive
      warn mode → REQ-9, REQ-10 (DR-4)
- [ ] **T-13** Manifest covers overlay rules and skills → REQ-8

## Tranche 4 — documentation honesty

- [ ] **T-14** MemPalace access claim in `connect-memory/SKILL.md` → REQ-13
- [ ] **T-15** Verification framing (README / `ask` / `eve`) → REQ-14
- [ ] **T-16** Soften `code-review-standards` MUSTs; comment the deliberate asymmetry
      in `tdd/SKILL.md` → REQ-15 (DR-6)

## Verification

- [ ] **T-17** Smoke fixtures for T-3/T-4, T-6, T-7, T-9..T-13 — each must fail against
      the pre-fix tree
- [ ] **T-18** Full `lint.sh` + `smoke.sh` green; CHANGELOG entry; version lockstep across
      `plugin.json` ×2 + `marketplace.json`

## Deferred — not in this spec

- `/unsetup` restore safety → own spec (destructive path, source-verified only)
- Behavioral evaluation suite, net-efficiency benchmarking → separate effort
