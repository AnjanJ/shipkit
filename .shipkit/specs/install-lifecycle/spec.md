# Install Lifecycle & Verified Review Findings — Requirements

> Spec accepted at commit `ce3ec19` on main.

Scope: the eight findings from the 3.0.0 external review that were reproduced against this
working tree. Each requirement below has an observed failure behind it, not a reported one.

## Context

An external review of 3.0.0 raised nine findings. Eight were reproduced here; the ninth
(`/unsetup` restore safety) was source-verified only by the reviewer and is deliberately
deferred to its own spec — redesigning a destructive restore path does not belong in a batch
with one-line edits.

Four findings (REQ-5..REQ-8) share a single root cause: `rules_sha` digests the **upstream**
`rules/` directory, so `.installed` records what was *shipped*, never what *landed*. A stamp
that cannot describe the installed tree cannot detect an incomplete install, cannot reconcile
a deletion, and cannot cover overlays or skills.

## Requirements

### Injection robustness

- **REQ-1** — When a dynamic-context `` !` `` injection probes for files that may be absent, the
  skill shall render successfully and report an empty result deliberately.
  *Observed:* `ls` over 8 lockfiles with 1 present exits **2**; the skill fails to render before
  any model turn.
- **REQ-2** — The linter shall reject a bare multi-argument `ls` inside a `` !` `` injection.
  *Observed:* `lint.py`'s `DEAD_FALLBACK` matches only `|| echo` fallbacks and passes both
  offending lines.

### Hook and documentation correctness

- **REQ-3** — When the plugin path contains spaces, every hook command shall execute.
  *Observed:* unquoted `${CLAUDE_PLUGIN_ROOT}/...` exits **127**; quoted exits **0**.
- **REQ-4** — The README's local-testing command shall register both plugins.
  *Observed:* `~/code/shipkit` is the marketplace root; it registers neither plugin.

### Installation ownership

- **REQ-5** — If a required rule is absent from disk, then the session hook shall inject it.
  *Observed:* `inject-rule.sh` tests `-d` on the directory, never `-f` on the rule; a deleted
  `shipkit.md` is absent from disk **and** suppressed from context, with zero warnings.
- **REQ-6** — Where an install is incomplete, the hook shall warn.
  *Observed:* a full install minus one rule, stamp intact, produces no warning — the stamp
  matches because it digests upstream.
- **REQ-7** — When upstream stops shipping a rule, a reinstall shall not leave the obsolete
  copy behind. *Observed:* `monorepo.md` survives, and the post-reinstall hook is silent.
- **REQ-8** — The freshness digest shall cover installed overlays and skills, not only the
  nine core rules. *Observed:* `rules_sha` globs one directory's `*.md`.

### Stack reinstall reconciliation

- **REQ-9** — When a stack is reinstalled with a changed substitution value, the CLAUDE.md stack
  section shall reflect the new value. *Observed:* the skill updates to `uv run pytest` while
  CLAUDE.md keeps `pytest` on four lines; the `<!-- shipkit:stack:X -->` marker makes the append
  idempotent and therefore un-updatable.
- **REQ-10** — While refreshing that section, the installer shall preserve content outside the
  managed block, and shall not overwrite edits inside it without showing a diff and asking.
  *(Design decision: confirmed with the user.)*

### Freshness semantics

- **REQ-11** — When a dependency lockfile changes, the map-drift check shall notice.
  *Observed:* a commit touching only `mix.lock` and `package-lock.json` produces no warning;
  neither filename is in the manifest expression.
- **REQ-12** — Where more stale specs exist than the output cap, the hook shall not starve the
  same specs on every run. *Observed:* 5 equally-stale specs, capped at 3, fixed glob order —
  specs 4 and 5 are never reported.

### Documentation honesty

- **REQ-13** — The MemPalace setup text shall distinguish "these agents are configured to use
  it" from "only these agents can access it". A user-scope MCP server is inherited by the main
  session; a subagent `tools:` allowlist restricts that subagent, it does not isolate the server.
- **REQ-14** — Claims of "verified memory" shall state what is verified against live source and
  what is an attributed snapshot (eve's registry-only answers are explicitly MEDIUM confidence).

## Out of scope

- `/unsetup` restore safety — deferred, its own spec.
- `tdd/SKILL.md` absolutist wording — **intentionally retained.** The iron-law phrasing is
  correct inside a skill users opt into by name, whose `DO NOT TRIGGER` clause already excludes
  ordinary coding. `code-review-standards` (REQ-15) loads on every review and is softened instead.
- **REQ-15** — Review standards phrased as unconditional MUSTs where they are contextual
  signals shall be re-phrased. Applies to `code-review-standards` only.
- Net-efficiency benchmarking and a behavioral evaluation suite — real, but a separate effort.
