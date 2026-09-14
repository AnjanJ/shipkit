# Shipkit — installation manifest helpers (POSIX sh; source this file, do not execute it).
#
# The manifest records what shipkit ACTUALLY WROTE into a project, one line per file:
#
#   <sha256-of-content-as-installed><TAB><path relative to the project root>
#
# preceded by a small header:
#
#   #shipkit-manifest v1
#   version=<plugin version that wrote it>
#   stacks=<space-separated overlay names, or empty>
#
# Why per-file, installed-side: the 3.0 stamp digested the plugin's OWN rules/ directory, so
# it recorded what was *shipped*, never what *landed*. That single digest cannot answer the
# three questions ownership needs — is the install complete (is every owned path present?),
# has a file drifted (which one?), and is an installed file now obsolete (is it still shipped
# upstream?). A per-file manifest answers all three, and extends to overlays and skills for
# free because it records whatever the installer wrote. See
# .shipkit/specs/install-lifecycle/design.md DR-1.
#
#   manifest_path <proj>                     → path to the manifest file
#   file_sha <file>                          → content digest (same algorithm everywhere)
#   manifest_begin                           → start a manifest in $MANIFEST_TMP
#   manifest_add <proj> <file>               → record one written file
#   manifest_commit <proj> <version> <stacks> → write it atomically
#   manifest_owns <proj> <relpath>           → is this path shipkit-owned?
#   manifest_paths <proj>                    → every owned path, one per line
#   manifest_missing <proj>                  → owned paths that no longer exist on disk
#   manifest_is_legacy <proj>                → true for a pre-3.1 stamp (no delete authority)

MANIFEST_NAME=".claude/rules/shipkit/.installed"

manifest_path() { echo "${1%/}/$MANIFEST_NAME"; }

file_sha() {
  [ -f "$1" ] || return 1
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d' ' -f1
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    cksum "$1" | cut -d' ' -f1
  fi
}

manifest_begin() {
  MANIFEST_TMP=$(mktemp) || return 1
  export MANIFEST_TMP
}

# manifest_add <proj> <absolute-or-relative path to the installed file>
manifest_add() {
  _mp="${1%/}"; _f="$2"
  [ -f "$_f" ] || return 0
  _rel=${_f#"$_mp"/}
  _sha=$(file_sha "$_f") || return 1
  printf '%s\t%s\n' "$_sha" "$_rel" >> "$MANIFEST_TMP"
}

# manifest_commit <proj> <version> <stacks>
# Atomic on purpose: a half-written manifest claims ownership of paths that may not exist,
# which is worse than no manifest at all, because ownership is what authorises deletion.
manifest_commit() {
  _mp="${1%/}"; _ver="$2"; _stacks="$3"
  _dest=$(manifest_path "$_mp")
  _dir=$(dirname "$_dest")
  mkdir -p "$_dir" || return 1
  _out=$(mktemp) || return 1
  {
    echo "#shipkit-manifest v1"
    printf 'version=%s\n' "${_ver:-unknown}"
    printf 'stacks=%s\n' "$_stacks"
    sort -t"$(printf '\t')" -k2,2 "$MANIFEST_TMP" 2>/dev/null
  } > "$_out" || { rm -f "$_out"; return 1; }
  mv "$_out" "$_dest" || { rm -f "$_out"; return 1; }
  rm -f "$MANIFEST_TMP"
  unset MANIFEST_TMP
}

# A pre-3.1 stamp is `version=`/`sha=` with no manifest header. It records what was shipped,
# not what landed, so it grants NO authority to delete anything — we cannot tell which files
# shipkit wrote. Treated as unknown provenance until the next /shipkit:setup. See DR-2.
manifest_is_legacy() {
  _f=$(manifest_path "$1")
  [ -f "$_f" ] || return 1
  head -1 "$_f" 2>/dev/null | grep -q '^#shipkit-manifest' && return 1
  return 0
}

manifest_entries() {
  _f=$(manifest_path "$1")
  [ -f "$_f" ] || return 1
  grep -v '^#' "$_f" 2>/dev/null | grep -v '^version=' | grep -v '^stacks='
}

manifest_paths() {
  manifest_entries "$1" | while IFS="$(printf '\t')" read -r _sha _rel; do
    [ -n "$_rel" ] && echo "$_rel"
  done
}

manifest_owns() {
  _target="$2"
  manifest_paths "$1" | grep -qxF "$_target"
}

# Owned paths that are gone from disk — an incomplete or damaged install.
manifest_missing() {
  _mp="${1%/}"
  manifest_paths "$_mp" | while read -r _rel; do
    [ -f "$_mp/$_rel" ] || echo "$_rel"
  done
}

manifest_version() {
  _f=$(manifest_path "$1")
  [ -f "$_f" ] || return 1
  sed -n 's/^version=//p' "$_f" 2>/dev/null | head -1
}

manifest_stacks() {
  _f=$(manifest_path "$1")
  [ -f "$_f" ] || return 1
  sed -n 's/^stacks=//p' "$_f" 2>/dev/null | head -1
}
