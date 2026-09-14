# Shipkit — shared shell helpers (POSIX sh; source this file, do not execute it).
#
#   rules_sha <rules-dir>      → one hex digest over every *.md in the dir, sorted by name
#   plugin_version <root>      → the "version" from <root>/.claude-plugin/plugin.json
#
# Used by scripts/install-rules.sh (to stamp .claude/rules/shipkit/.installed) and by
# scripts/session-start.sh (to notice when the installed copies are older than the plugin).
# Both must compute the digest the same way, which is why it lives here.

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
