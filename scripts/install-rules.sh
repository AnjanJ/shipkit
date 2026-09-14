#!/bin/sh
# Shipkit: install the plugin's rules into a project, deterministically.
#
#   install-rules.sh <plugin-root> [project-dir]      (project-dir defaults to .)
#
# Copies <plugin-root>/rules/*.md → <project>/.claude/rules/shipkit/ and writes
# <project>/.claude/rules/shipkit/.installed with the plugin version and a digest of the
# rules as shipped, so the session hook can tell when the copies are older than the plugin.
# Claude Code only loads rules from a project's .claude/rules/ (recursively), never from a
# plugin, so this is what makes the path-scoped rules work — and once the directory exists
# the session hook stops injecting the always-on rules (they load from disk instead).
#
# Fails loudly (non-zero exit + message) — this is an install step, not a session hook.

ROOT="$1"
PROJ="${2:-.}"

usage() { echo "usage: install-rules.sh <plugin-root> [project-dir]" >&2; exit 64; }
die()   { echo "install-rules: $*" >&2; exit 1; }

[ -n "$ROOT" ] || usage
[ -d "$ROOT/rules" ] || die "no rules/ directory under '$ROOT' — is this the shipkit plugin root?"
[ -d "$PROJ" ] || die "project directory '$PROJ' does not exist"
. "$ROOT/scripts/lib-rules-sha.sh" || die "cannot load $ROOT/scripts/lib-rules-sha.sh"

DEST="$PROJ/.claude/rules/shipkit"
mkdir -p "$DEST" || die "cannot create $DEST"

n=0
for f in "$ROOT"/rules/*.md; do
  [ -f "$f" ] || continue
  cp "$f" "$DEST/" || die "failed to copy $f"
  n=$((n + 1))
done
[ "$n" -gt 0 ] || die "no rule files found in $ROOT/rules"

VER=$(plugin_version "$ROOT")
SHA=$(rules_sha "$ROOT/rules") || die "cannot compute rules digest"
printf 'version=%s\nsha=%s\n' "${VER:-unknown}" "$SHA" > "$DEST/.installed" || die "cannot write $DEST/.installed"

echo "install-rules: installed $n rule files to $DEST (shipkit ${VER:-unknown}, stamp .installed written)"
