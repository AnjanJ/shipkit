#!/bin/sh
# Shipkit: install the plugin's rules into a project, deterministically.
#
#   install-rules.sh <plugin-root> [project-dir]      (project-dir defaults to .)
#
# Copies <plugin-root>/rules/*.md → <project>/.claude/rules/shipkit/ and writes an
# INSTALLATION MANIFEST at <project>/.claude/rules/shipkit/.installed recording every file
# shipkit wrote, with its content digest. The manifest is what lets the session hook tell an
# incomplete install from a complete one, and what authorises removing a rule that upstream
# no longer ships. Claude Code only loads rules from a project's .claude/rules/ (recursively),
# never from a plugin, so this is what makes the path-scoped rules work — and once a rule is
# installed the session hook stops injecting that rule (it loads from disk instead).
#
# Reconciliation: a *.md under .claude/rules/shipkit/ that this manifest owns but upstream no
# longer ships is removed. Files shipkit does not own are never touched, and a pre-3.1 stamp
# owns nothing at all (see lib-manifest.sh / design.md DR-2), so an upgrade from 3.0 deletes
# nothing — it just starts tracking.
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
. "$ROOT/scripts/lib-manifest.sh"  || die "cannot load $ROOT/scripts/lib-manifest.sh"

DEST="$PROJ/.claude/rules/shipkit"

# --- what did we own BEFORE this run? (empty for a legacy stamp: no delete authority) -------
PRIOR=$(mktemp) || die "mktemp failed"
trap 'rm -f "$PRIOR"' EXIT
if manifest_is_legacy "$PROJ"; then
  LEGACY=1
else
  LEGACY=0
  manifest_paths "$PROJ" > "$PRIOR" 2>/dev/null || true
fi

mkdir -p "$DEST" || die "cannot create $DEST"

manifest_begin || die "cannot start manifest"

n=0
for f in "$ROOT"/rules/*.md; do
  [ -f "$f" ] || continue
  cp "$f" "$DEST/" || die "failed to copy $f"
  manifest_add "$PROJ" "$DEST/$(basename "$f")" || die "cannot record $f in the manifest"
  n=$((n + 1))
done
[ "$n" -gt 0 ] || die "no rule files found in $ROOT/rules"

# --- carry forward stack overlay files we already own ---------------------------------------
# install-stack.sh appends its own entries; preserve them across a rules reinstall so a
# /shipkit:setup re-run does not orphan the overlays.
CARRIED=0
if [ "$LEGACY" -eq 0 ] && [ -s "$PRIOR" ]; then
  while read -r rel; do
    [ -n "$rel" ] || continue
    case "$rel" in
      .claude/rules/shipkit/*.md)
        # a core rule — already re-added above if upstream still ships it
        base=${rel##*/}
        [ -f "$ROOT/rules/$base" ] && continue
        # upstream dropped it: reconcile (remove) rather than carry forward
        if [ -f "$PROJ/$rel" ]; then
          rm -f "$PROJ/$rel" && echo "install-rules: removed $rel (no longer shipped by shipkit)"
        fi
        ;;
      *)
        # overlay rules/skills: keep owning them if they are still on disk
        if [ -f "$PROJ/$rel" ]; then
          manifest_add "$PROJ" "$PROJ/$rel" || true
          CARRIED=$((CARRIED + 1))
        fi
        ;;
    esac
  done < "$PRIOR"
fi

VER=$(plugin_version "$ROOT")
STACKS=$(manifest_stacks "$PROJ" 2>/dev/null || true)
manifest_commit "$PROJ" "${VER:-unknown}" "$STACKS" || die "cannot write the manifest"

msg="install-rules: installed $n rule files to $DEST (shipkit ${VER:-unknown}, manifest written)"
[ "$CARRIED" -gt 0 ] && msg="$msg; kept $CARRIED overlay file(s) under management"
[ "$LEGACY" -eq 1 ] && msg="$msg; upgraded a pre-3.1 stamp (nothing removed — ownership starts now)"
echo "$msg"
