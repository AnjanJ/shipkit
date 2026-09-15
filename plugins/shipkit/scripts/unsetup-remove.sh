#!/bin/sh
# Shipkit: remove what shipkit installed — and nothing else.
#
#   unsetup-remove.sh <project-dir> [--yes] [--force]
#
#   (no flags)   DRY RUN. Print the removal set and exit 0. Nothing is touched.
#   --yes        Actually remove. Required; there is no way to delete by accident.
#   --force      Also remove owned files the user has edited since installation.
#
# Removal is driven by the INSTALLATION MANIFEST (.claude/rules/shipkit/.installed), so this
# takes out the files shipkit wrote and leaves everything else alone — another plugin's agents,
# the user's settings.local.json, anything added to .claude/ after setup. The old flow deleted
# .claude/ wholesale and restored a snapshot over the top, which discarded all of that.
#
# What this deliberately does NOT do:
#   - touch .shipkit/ (specs and decision records are the user's work product)
#   - remove anything absent from the manifest, ever
#   - act on a pre-3.1 legacy stamp: it records what was SHIPPED, not what landed, so it
#     cannot prove ownership. Exits non-zero and removes nothing.
#
# See .shipkit/specs/unsetup-safety/ (REQ-1..REQ-5, DR-1). The caller (/shipkit:unsetup) is
# responsible for the recovery snapshot and the user confirmation before passing --yes.

PROJ=""; APPLY=0; FORCE=0
for a in "$@"; do
  case "$a" in
    --yes)   APPLY=1 ;;
    --force) FORCE=1 ;;
    -*)      echo "unsetup-remove: unknown option '$a'" >&2; exit 64 ;;
    *)       [ -n "$PROJ" ] && { echo "unsetup-remove: too many arguments" >&2; exit 64; }
             PROJ="$a" ;;
  esac
done
[ -n "$PROJ" ] || { echo "usage: unsetup-remove.sh <project-dir> [--yes] [--force]" >&2; exit 64; }
[ -d "$PROJ" ] || { echo "unsetup-remove: project directory '$PROJ' does not exist" >&2; exit 1; }
PROJ=${PROJ%/}

ROOT=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
. "$ROOT/lib-manifest.sh" || { echo "unsetup-remove: cannot load lib-manifest.sh" >&2; exit 1; }

MF=$(manifest_path "$PROJ")
if [ ! -f "$MF" ]; then
  echo "unsetup-remove: no installation manifest at $MF." >&2
  echo "  Shipkit cannot prove which files it installed here, so it will not remove anything." >&2
  echo "  Restore from a .shipkit-backup-* snapshot instead." >&2
  exit 2
fi
if manifest_is_legacy "$PROJ"; then
  echo "unsetup-remove: this project has a pre-3.1 stamp, not a manifest." >&2
  echo "  It records what shipkit SHIPPED, not what landed, so shipkit cannot prove which" >&2
  echo "  files here are its own — and will not guess when the answer is a deletion." >&2
  echo "  Run /shipkit:setup once to establish ownership, or restore from a snapshot." >&2
  exit 2
fi

# --- classify every owned path ---------------------------------------------------------------
CLEAN=$(mktemp) || exit 1
DIRTY=$(mktemp) || exit 1
ABSENT=$(mktemp) || exit 1
trap 'rm -f "$CLEAN" "$DIRTY" "$ABSENT"' EXIT

manifest_entries "$PROJ" | while IFS="$(printf '\t')" read -r sha rel; do
  [ -n "$rel" ] || continue
  if [ ! -f "$PROJ/$rel" ]; then
    printf '%s\n' "$rel" >> "$ABSENT"
  elif [ "$(file_sha "$PROJ/$rel")" = "$sha" ]; then
    printf '%s\n' "$rel" >> "$CLEAN"
  else
    printf '%s\n' "$rel" >> "$DIRTY"
  fi
done

n_clean=$(wc -l < "$CLEAN" | tr -d ' ')
n_dirty=$(wc -l < "$DIRTY" | tr -d ' ')
n_absent=$(wc -l < "$ABSENT" | tr -d ' ')

# --- report ------------------------------------------------------------------------------------
# The whole report goes out in ONE write. A caller piping this into `head`/`less` closes the
# pipe early, and a shell that reports the resulting SIGPIPE prints "write error: Broken pipe"
# — which, on stderr, from a DESTRUCTIVE command, reads like the removal went wrong. Buffering
# the report into a single printf means there is at most one interrupted write, not one per line.
report() {
  printf '%s' "$1"
}

REPORT="unsetup-remove: $PROJ
"
if [ "$n_clean" -gt 0 ]; then
  REPORT="$REPORT  will remove ($n_clean file(s) shipkit installed, unmodified):
$(sed 's/^/    /' "$CLEAN")
"
fi
if [ "$n_dirty" -gt 0 ]; then
  if [ "$FORCE" -eq 1 ]; then
    REPORT="$REPORT  will ALSO remove ($n_dirty file(s) you edited since installation — --force given):
"
  else
    REPORT="$REPORT  will KEEP ($n_dirty file(s) you edited since installation — pass --force to remove):
"
  fi
  REPORT="$REPORT$(sed 's/^/    /' "$DIRTY")
"
fi
[ "$n_absent" -gt 0 ] && REPORT="$REPORT  already gone: $n_absent file(s) recorded in the manifest but not on disk
"
REPORT="$REPORT  never touched: .shipkit/ (your specs and decision records), and anything not in the manifest
"

if [ "$APPLY" -eq 0 ]; then
  REPORT="$REPORT  DRY RUN — nothing was changed. Re-run with --yes to apply.
"
  report "$REPORT"
  exit 0
fi
report "$REPORT"

# --- remove --------------------------------------------------------------------------------------
removed=0
rm_listed() {
  while read -r rel; do
    [ -n "$rel" ] || continue
    if rm -f "$PROJ/$rel" 2>/dev/null; then removed=$((removed + 1)); fi
  done < "$1"
}
rm_listed "$CLEAN"
[ "$FORCE" -eq 1 ] && rm_listed "$DIRTY"

# Prune directories shipkit emptied — only when genuinely empty, so a directory still holding
# a foreign file (another plugin's agents/, the user's settings) is left exactly as it is.
# Deepest-first so a nested overlay dir is considered before its parent.
{ cat "$CLEAN"; [ "$FORCE" -eq 1 ] && cat "$DIRTY"; } 2>/dev/null \
  | sed 's#/[^/]*$##' | sort -u -r | while read -r d; do
      [ -n "$d" ] || continue
      p="$PROJ/$d"
      while [ -d "$p" ] && [ "$p" != "$PROJ" ]; do
        rmdir "$p" 2>/dev/null || break      # non-empty: stop, and leave it alone
        p=$(dirname "$p")
      done
    done

# The manifest cannot own itself (it is written after the entries are collected), so it is
# removed explicitly, and LAST — an orphan manifest would leave the session hook warning about
# an incomplete install forever, against files that are deliberately gone.
if [ "$n_dirty" -eq 0 ] || [ "$FORCE" -eq 1 ]; then
  rm -f "$MF" 2>/dev/null
  rmdir "$PROJ/.claude/rules/shipkit" 2>/dev/null || true
  rmdir "$PROJ/.claude/rules" 2>/dev/null || true
  echo "unsetup-remove: removed $removed file(s), including the manifest."
else
  echo "unsetup-remove: removed $removed file(s). Kept the manifest — $n_dirty edited file(s)"
  echo "  are still under management. Re-run with --force to remove those too."
fi
exit 0
