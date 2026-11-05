# Tasks: The owner's project again, and 5.2.0 (Sprint 28)

One commit per task. The steps are in `docs/plans/machine-sprint-plan.md` under the same task
number (S28-T0 to S28-T-REL). No task writes a smoke check: nothing under `plugins/` changes but
the two version lines. **Paid runs, each on the owner's yes (rule 15):** the run's headless steps
(≈ $2 to $8), the gate twice on two days and the three release gates (≈ $2.50), the full eval run
(≈ $21). T1 makes no model call. Nothing under `plugins/` is edited while a smoke run, an eval run
or a step of the run is in progress. Every scratch copy is removed on the owner's yes, after it is
read (rule 13).

- [x] **T0** Write the sprint spec (S28-T0) → REQ-1 to REQ-15, the spec itself
  - Files: .shipkit/specs/fifth-run/, docs/plans/machine-sprint-plan.md
  - Test: `sh plugins/shipkit/scripts/spec-check.sh . fifth-run --as-open` → 0 gaps; `sh plugins/shipkit/scripts/decision-check.sh . --run` → no FIRED or ERROR; `bash scripts/lint.sh` → 0/0; the spec read against rule 27
  - After: none
  - Done when: 0 gaps; lint 0/0; the owner's approval of the requirements, the design and the run's item in the thread; stamped at the branch-point commit `f138e94`, `Status: open`; the plan's S28-T1 and S28-T-REL Files lines amended and its status line noting it, in the same commit
- [x] **T1** `--scope project` (S28-T1, G11) → REQ-1, REQ-2, REQ-3
  - Files: docs/design/field-notes-5.2.md, README.md, GUIDE.md
  - Test: the checksums of `~/.claude/plugins/installed_plugins.json` and `known_marketplaces.json` first; then, every command under `CLAUDE_CONFIG_DIR` set to a scratch folder: the local marketplace at 5.1.0 added by path, both plugins installed with `--scope project` in a scratch project, the copy's five version lines set to 5.1.1, `claude plugin marketplace update`, `claude plugin update <plugin> --scope project` from outside the project and from inside it, `claude plugin list` after each; the checksums again after each command
  - After: T0
  - Done when: each command, its output, exit status and the versions after it in `field-notes-5.2.md`'s T1 section; both docs say how a `Scope: project` install is updated; both checksums unchanged; the scratch folders removed on the owner's yes; lint 0/0
- [ ] **T2** The run (S28-T2, G6, G10, G11) → REQ-4, REQ-5, REQ-6, REQ-7, REQ-8, REQ-9, REQ-10, REQ-11
  - Files: docs/design/field-notes-5.2.md, ROADMAP.md
  - Test: the Check first, free and before any paid step: the worktree at `/private/tmp/shipkit-real-run-6` on `shipkit/real-run-6` from `179f99d`, `mise exec -- mix deps.get`, compile, `MIX_ENV=test MIX_TEST_PARTITION=_shipkit6 mise exec -- mix test`, the count recorded; then the nine steps of `field-notes-5.1.md`, each but setup by `claude --plugin-dir <checkout>/plugins/shipkit --model sonnet --allowedTools Read Glob Grep Bash Write Edit Skill Agent --output-format json -p`, standard input from `/dev/null`, `MIX_TEST_PARTITION=_shipkit6` exported; setup by the owner in their own session; each step's prompt and output copied to `~/.cache/shipkit-real-run-6/` as it ends; the gate on day one, its report left untracked, and again on a later day
  - After: T1
  - Done when: every step has its six parts; G1 to G7 each read as held or not shown; REQ-20's sentence read on day two; `~/code/office_bestie` holds nothing from the run but the worktree and the branch; those, the run's database and the copies removed on the owner's yes, the notes read first; lint 0/0
- [ ] **T3** The roadmap for the plan after (S28-T3) → REQ-12
  - Files: ROADMAP.md
  - Test: `bash scripts/lint.sh` → 0/0; every new item read for a file and a section
  - After: T2
  - Done when: the plan's section has its three rows and 5.2.0; "Still open after Sprint 28" holds the run's findings and what §5 left; lint 0/0
- [ ] **T-REL** Release 5.2.0 (S28-T-REL, G12, G13) → REQ-13, REQ-14, REQ-15, and the release steps in `spec.md`
  - Files: .claude-plugin/marketplace.json, plugins/shipkit/.claude-plugin/plugin.json, plugins/shipkit-workflows/.claude-plugin/plugin.json, CHANGELOG.md, README.md, ROADMAP.md, docs/design/eval-history.md, .shipkit/releases/, .shipkit/specs/gate-on-setup/spec.md, .shipkit/specs/users-machine/spec.md, .shipkit/specs/fifth-run/spec.md, .shipkit/specs/fifth-run/tasks.md
  - Test: the plan's exit checklist in full, one run at a time: `bash scripts/lint.sh`, `sh scripts/smoke.sh </dev/null`, `bash scripts/evals.sh -j 4` on the release prep commit, `spec-check`, the three rules' bytes, the evals' bytes, the §0 table; then `/shipkit:ship` headless on `gate-on-setup` against `03e87eb`, `users-machine` against `9b32e36`, each recorded and committed, and `fifth-run` against its acceptance commit last
  - After: T3
  - Done when: all three READY; each spec `shipped` on the owner's yes; the run and the gates in `eval-history.md`; the pull request with "What was awkward", a green check on its head sha and a merge commit; `git ls-remote` shows `v5.2.0`, annotated; each of G13 done on its own yes or left, and said so
