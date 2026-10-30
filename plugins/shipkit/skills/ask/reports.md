<!-- Reference body for `/shipkit:ask --all matrix` and `--all consolidate`. The ask skill reads
     this file on those two routes only and hands `eve` the matching section with the question,
     so no other call pays for it. The text was `agents/eve.md`'s until 5.0.0, moved whole
     (thinning plan W9). -->

# /shipkit:ask --all reports — the matrix and consolidation shapes

## Dependency / version matrix (`matrix <target>` or "matrix of everything major")

The question: "where does `<library/framework>` stand across my portfolio?" — for upgrades,
deprecations, and vulnerability responses ("which repos still use lodash < 4.17.21?").

- **Method:** pure cheap-path. Grep the version line in each repo's manifest/lockfile
  (`Gemfile.lock`, `package.json` + lockfile, `mix.lock`, `go.mod`, `pyproject.toml`/`uv.lock`,
  `Cargo.lock`). No map reads. Prefer lockfiles over manifests — installed truth beats declared
  range; note both when they differ.
- **Shape:** one row per project: project | version installed | declared constraint | evidence
  (`path:line`) | flag. Flag = `not used` / `?` (no lockfile found — say which file you looked for).
- **For "everything major":** limit to each repo's framework + runtime + the 3-5 heaviest deps —
  a curated matrix, not a lockfile dump.
- **Never invent "latest" or "vulnerable".** You know versions found in repos, not the upstream
  release state. If asked "is it outdated?", give the found versions and say upstream must be
  checked (name the check: `gem outdated`, `npm outdated`, advisory DBs) — unless the caller
  gave you the target version, in which case compare against that.

## Consolidation report (`consolidate` or "what should I consolidate?")

The question: "what am I maintaining N times that should exist once?"

- **Method:** synthesis-path. Read the registry, then the relevant maps; grep to confirm each
  candidate in at least two repos before naming it.
- **Look for:** the same concern implemented per-repo (auth glue, API clients, deploy scripts,
  CI config, error reporting, pagination/i18n helpers), version drift of the same pattern
  (three JWT strategies), and copy-paste lineage (same file/function names across repos).
- **Shape:** ranked candidates, each with: the pattern | where it lives (project + `path` per
  copy) | drift between copies | consolidation cost — quick judgment: extract a lib / pick one
  winner / leave alone (consolidation has costs; say when it is not worth it).
- Cap it: the top 5-7 candidates with evidence beat an exhaustive inventory.
