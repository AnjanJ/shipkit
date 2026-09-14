---
description: "Release workflow with mandatory approval gate between safe and irreversible steps"
user-invocable: true
disable-model-invocation: true
argument-hint: "[patch|minor|major]"
---

# /release — Release Workflow

Two-phase release with a mandatory approval gate.

Version bump type: $ARGUMENTS (default: `patch`)

## Phase 1: Prepare (Local only — nothing leaves this machine)

1. **Check prerequisites:**
   - Working directory clean? (`git status`)
   - On the correct branch? (main/master)
   - All tests passing? Run `{{TEST_COMMAND}}` — must be green
   - Security audit clean? Run `bundle audit check`
   - Changelog updated?

2. **Bump version:**
   - For gems: update `lib/<gem>/version.rb`
   - For apps: update version in appropriate config file
   - Type: patch (0.0.X), minor (0.X.0), major (X.0.0)

3. **Update CHANGELOG.md:**
   - Add new version header with date
   - List changes since last release (from git log)
   - Follow Keep a Changelog format

4. **Create release commit:**
   ```
   git add lib/<gem>/version.rb CHANGELOG.md
   git commit -m "Release vX.Y.Z"
   ```
   Stage only version and changelog files — never use `git add -A` or `git add .`.
   The commit stays local until Phase 2 — nothing is pushed before the gate.

---

## ⛔ MANDATORY APPROVAL GATE

**Display this message and STOP:**

```
Phase 1 complete (local only). Ready to publish:
  Version: vX.Y.Z
  Changes: [summary]
  Tests: PASSING

⚠️  Phase 2 is IRREVERSIBLE. It will:
  - Push the release commit to origin/main
  - Wait for CI, then push to RubyGems/npm/Hex (gems/packages)
  - OR deploy to production (apps)
  - Create a Git tag
  - Create a GitHub release

Type 'yes' to proceed, anything else to abort.
```

**Do NOT proceed to Phase 2 without explicit "yes" from the user.**

---

## Phase 2: Publish (Irreversible)

1. **Push to remote:** `git push origin main`
2. **Run CI:** wait for CI to pass (if configured). If it fails, STOP — fix on main and
   re-run this skill; do not publish a red build.

### For Gems (RubyGems)
3. `gem build <gemspec>`
4. `gem push <gem-file>.gem`
5. `git tag vX.Y.Z && git push origin vX.Y.Z`
6. Create GitHub release: `gh release create vX.Y.Z --notes "..."`

### For npm Packages
3. `npm publish`
4. `git tag vX.Y.Z && git push origin vX.Y.Z`
5. Create GitHub release

### For Apps (Deploy)
3. Run deploy command (from CLAUDE.md or prompt user)
4. `git tag vX.Y.Z && git push origin vX.Y.Z`
5. Create GitHub release

## After Publishing

Report:
- Version published
- Registry/deployment URL
- GitHub release URL
- Any post-release tasks (update docs, notify users)
