# Setup — Reference Material

## CLAUDE.md Template

Write a CLAUDE.md of **project facts only**. Conventions, workflow and review standards live in
shipkit's rules (installed to `.claude/rules/shipkit/` in Phase 4) and its on-demand skills —
do not restate them here. The research shipkit cites (README → Research) found that generic,
LLM-written context files hurt; a short file of things only this project can tell Claude helps.

```markdown
# {project-name}

## Project Info

- **Purpose:** {project purpose or "TODO: describe what this project does"}
- **Stack:** {the full overlay set, e.g. Rails 7.1 + Hotwire + React / PostgreSQL}
- **Language:** {language + version if known}
- **Package manager:** {detected}
- **Test:** `{test command}` ({framework})
- **Lint:** `{lint command}`
- **Build:** `{build command or "n/a"}`

**Workflow style:** {strict-tdd | test-first | lightweight}
{if strict-tdd: "Every change follows /shipkit:tdd — red, green, refactor, no exceptions."}
{if lightweight: "Tests where they earn their keep; spec-driven answers stay inline unless a spec is asked for."}

## Key Paths

| Path | Purpose |
|------|---------|
| {only rows the stack section does not already cover — entry points, config, docs} |

## Conventions

Shipkit's rules apply — see `.claude/rules/shipkit/` (workflow, commit discipline, spec-driven
development, decision records, and path-scoped rules for tests, migrations, security,
dependencies, monorepos and UI). Review diffs against the `code-review-standards` skill or the
built-in `/code-review`. Change this file with `/shipkit:update-rules`, not by hand.
{team conventions if provided: branch prefix, PR description preference}

{stack-specific section — appended by install-stack.sh in Phase 5}
```

Target: **≤ 40 lines** before the stack section. If you find yourself adding a rule ("always
do X"), it belongs in `.claude/rules/` — either a shipkit rule already says it, or the user
should add a project rule via `/shipkit:update-rules`.

## Phase 6: Settings Defaults

Ask the user: "Want me to create `.claude/settings.json` with safe defaults? (allows test/lint/build, denies destructive ops)"

If yes, create `.claude/settings.json` with:
- Allow: test command, lint command, build command, git read commands
- Deny: `rm -rf`, force push, hard reset, clean -f, reading .env files

Also ask: "Enterprise mode? (also blocks curl, docker, cloud CLIs, secrets files)" — if yes, add the extended deny list.
