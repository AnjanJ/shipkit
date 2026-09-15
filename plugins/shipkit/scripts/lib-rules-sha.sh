# Shipkit — shared shell helpers (POSIX sh; source this file, do not execute it).
#
#   rules_sha <rules-dir>      → one hex digest over every *.md in the dir, sorted by name
#   plugin_version <root>      → the "version" from <root>/.claude-plugin/plugin.json
#
# `plugin_version` is used by install-rules.sh, install-stack.sh and session-start.sh.
#
# `rules_sha` is LEGACY and describes the plugin's own rules/ directory — what was *shipped*,
# never what landed in a project. That is precisely why it could not detect an incomplete
# install, reconcile a rule upstream had dropped, or cover overlays and skills: one digest
# over the wrong side of the copy. Installation state now lives in a per-file manifest (see
# lib-manifest.sh). `rules_sha` is kept only to read pre-3.1 `.installed` stamps during the
# upgrade window — do not use it for new checks.

rules_sha() {
  _d="$1"
  [ -d "$_d" ] || return 1
  # Shell glob expansion is sorted, so `cat "$_d"/*.md` is deterministic.
  if command -v shasum >/dev/null 2>&1; then
    cat "$_d"/*.md | shasum -a 256 | cut -d' ' -f1
  elif command -v sha256sum >/dev/null 2>&1; then
    cat "$_d"/*.md | sha256sum | cut -d' ' -f1
  else
    cat "$_d"/*.md | cksum | cut -d' ' -f1
  fi
}

plugin_version() {
  sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$1/.claude-plugin/plugin.json" 2>/dev/null | head -1
}
