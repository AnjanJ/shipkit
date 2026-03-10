---
description: "Read library documentation before using it. Fetches docs, checks latest version, verifies compatibility."
user-invocable: true
argument-hint: "[library-name]"
allowed-tools: Read, Glob, Grep, Bash, WebFetch
---
# Use Library: $ARGUMENTS

IMPORTANT: Do NOT write implementation code until you have read the documentation.

## Step 1: Detect Stack and Current Dependencies

!`ls Gemfile mix.exs package.json pyproject.toml requirements.txt go.mod Cargo.toml 2>/dev/null`

### For Ruby gems:
!`gem specification $ARGUMENTS 2>/dev/null | grep -E "^(name|version|summary|homepage)" || echo "Gem not found locally — will check remote"`

### For npm packages:
!`npm view $ARGUMENTS version description homepage 2>/dev/null || echo "Package not found in npm registry"`

### For Python packages:
!`pip show $ARGUMENTS 2>/dev/null | grep -E "^(Name|Version|Summary|Home-page)" || echo "Package not installed locally"`

### For Hex packages:
!`mix hex.info $ARGUMENTS 2>/dev/null | head -10 || echo "Package not found in hex"`

## Step 2: Check if Already in Project

Search for existing usage:
- Ruby: check Gemfile for the gem name
- Node: check package.json for the package name
- Python: check pyproject.toml or requirements.txt
- Elixir: check mix.exs

If already present, note the current version and check if an upgrade is needed.

## Step 3: Read Documentation

Use WebFetch to read the library's official documentation or README.
- If a homepage URL was found in Step 1, fetch it
- Otherwise search for: "$ARGUMENTS documentation" or "$ARGUMENTS GitHub README"
- Read at minimum: installation instructions, basic usage, API reference for needed features
- For Ruby AI features: check https://rubyllm.com if using ruby_llm

## Step 4: Check Latest Version

Verify you're using the LATEST stable version:
- Ruby: `gem search -r $ARGUMENTS`
- Node: `npm view $ARGUMENTS version`
- Python: `pip index versions $ARGUMENTS 2>/dev/null || pip install $ARGUMENTS== 2>&1 | head -5`
- Elixir: `mix hex.info $ARGUMENTS`

If the project already uses this library at a different version, check the changelog for breaking changes before upgrading.

## Step 5: Install and Verify

1. Add the dependency with appropriate version constraint
2. Install: `bundle install` / `npm install` / `pip install` / `mix deps.get`
3. Run the full test suite
4. Run security audit: `bundle audit` / `npm audit` / `pip-audit` / `mix hex.audit`
5. Review lockfile diff — no unexpected transitive dependency changes

## Constraint

Documentation first, code second. Never guess at an API — always verify against current docs.
