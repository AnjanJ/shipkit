#!/bin/sh
# Shipkit: install a stack overlay into a project, deterministically.
#
#   install-stack.sh <plugin-root> <stack> [project-dir] KEY=value ...
#
#   <stack>        one of the directories under <plugin-root>/stacks/ (rails, react, python, ...)
#   [project-dir]  defaults to . (an argument without "=" in third position)
#   KEY=value      one per {{PLACEHOLDER}} used by that stack (TEST_COMMAND=... DATABASE=...).
#                  Values must be single-line. Pass KEY="TODO: <hint>" for anything you could
#                  not detect — nothing is left as braces.
#
# What it does:
#   stacks/<stack>/.claude/rules/*.md   → <project>/.claude/rules/shipkit/<stack>/
#   stacks/<stack>/.claude/skills/*     → <project>/.claude/skills/<name>/
#   stacks/<stack>/CLAUDE.md.append     → appended to <project>/CLAUDE.md, once (guarded by a
#                                         `<!-- shipkit:stack:<stack> -->` marker; re-runs skip it)
# then substitutes every {{KEY}} in what it wrote, and FAILS (exit 2) listing any placeholder
# that was not covered by a KEY=value argument. Prints a manifest of installed paths on success.
# Portable: POSIX sh, no `sed -i` (differs between GNU and BSD).

usage() { echo "usage: install-stack.sh <plugin-root> <stack> [project-dir] KEY=value ..." >&2; exit 64; }
die()   { echo "install-stack: $*" >&2; exit 1; }

ROOT="$1"; STACK="$2"; shift 2 2>/dev/null || usage
[ -n "$ROOT" ] && [ -n "$STACK" ] || usage
PROJ="."
case "$1" in
  ""|*=*) ;;                 # no project dir given
  *) PROJ="$1"; shift ;;
esac

SRC="$ROOT/stacks/$STACK"
[ -d "$SRC" ] || die "no such stack '$STACK' under $ROOT/stacks/"
[ -d "$PROJ" ] || die "project directory '$PROJ' does not exist"

# --- collect substitutions: KEY=value → a sed script -------------------------------------
SEDSCRIPT=$(mktemp) || die "mktemp failed"
trap 'rm -f "$SEDSCRIPT"' EXIT
for kv in "$@"; do
  case "$kv" in
    *=*) ;;
    *) die "argument '$kv' is not KEY=value" ;;
  esac
  key=${kv%%=*}
  val=${kv#*=}
  case "$key" in
    *[!A-Z0-9_]*|"") die "placeholder key '$key' must be UPPER_SNAKE_CASE" ;;
  esac
  NL=$(printf '\nx'); NL=${NL%x}   # a literal newline ($(printf '\n') alone would collapse to "")
  case "$val" in
    *"$NL"*) die "value for $key must be a single line" ;;
  esac
  # escape for sed replacement with '#' delimiter: \ & #
  esc=$(printf '%s' "$val" | sed 's/[\\&#]/\\&/g')
  printf 's#{{%s}}#%s#g\n' "$key" "$esc" >> "$SEDSCRIPT"
done

subst() {  # substitute in place, portably
  _f="$1"
  [ -s "$SEDSCRIPT" ] || return 0
  sed -f "$SEDSCRIPT" "$_f" > "$_f.shipkit-tmp" && mv "$_f.shipkit-tmp" "$_f"
}

# --- pre-check: every placeholder the stack uses must have a value — BEFORE writing anything
# (a half-done install that appended a section full of braces to CLAUDE.md is worse than none)
GIVEN=$(sed -n 's/^s#{{\([A-Z0-9_]*\)}}#.*/\1/p' "$SEDSCRIPT" 2>/dev/null)
NEEDED=$(grep -rho '{{[A-Z_][A-Z0-9_]*}}' "$SRC" 2>/dev/null | sed 's/[{}]//g' | sort -u)
MISSING=""
for n in $NEEDED; do
  case "
$GIVEN
" in *"
$n
"*) ;; *) MISSING="$MISSING $n" ;; esac
done
if [ -n "$MISSING" ]; then
  echo "install-stack: stack '$STACK' uses placeholders you did not provide — nothing was written." >&2
  echo "  missing:$MISSING" >&2
  echo "  pass KEY=value for each (or KEY=\"TODO: <hint>\" when you cannot detect it)" >&2
  exit 2
fi

WRITTEN=""
note() { WRITTEN="$WRITTEN
$1"; }

# --- rules ---------------------------------------------------------------------------------
if [ -d "$SRC/.claude/rules" ]; then
  RDEST="$PROJ/.claude/rules/shipkit/$STACK"
  mkdir -p "$RDEST" || die "cannot create $RDEST"
  for f in "$SRC"/.claude/rules/*.md; do
    [ -f "$f" ] || continue
    cp "$f" "$RDEST/" || die "failed to copy $f"
    subst "$RDEST/$(basename "$f")"
    note "$RDEST/$(basename "$f")"
  done
fi

# --- skills (workflow skills and on-demand knowledge bases alike) -------------------------
if [ -d "$SRC/.claude/skills" ]; then
  for d in "$SRC"/.claude/skills/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    SDEST="$PROJ/.claude/skills/$name"
    mkdir -p "$SDEST" || die "cannot create $SDEST"
    for f in "$d"*; do
      [ -f "$f" ] || continue
      cp "$f" "$SDEST/" || die "failed to copy $f"
      subst "$SDEST/$(basename "$f")"
      note "$SDEST/$(basename "$f")"
    done
  done
fi

# --- CLAUDE.md append (once) --------------------------------------------------------------
MARK="<!-- shipkit:stack:$STACK -->"
if [ -f "$SRC/CLAUDE.md.append" ]; then
  CM="$PROJ/CLAUDE.md"
  if [ -f "$CM" ] && grep -qF "$MARK" "$CM"; then
    note "$CM (stack section already present — skipped)"
  else
    SECTION=$(mktemp) || die "mktemp failed"
    { printf '\n%s\n' "$MARK"; cat "$SRC/CLAUDE.md.append"; } > "$SECTION"
    subst "$SECTION"
    if grep -q '{{[A-Z_][A-Z0-9_]*}}' "$SECTION"; then   # cannot happen after the pre-check; belt and braces
      rm -f "$SECTION"; die "internal: placeholders survived substitution in the CLAUDE.md section"
    fi
    cat "$SECTION" >> "$CM" || die "cannot append to $CM"
    rm -f "$SECTION"
    note "$CM (stack section appended)"
  fi
fi

# --- safety net over the files this run copied (never the user's whole CLAUDE.md) ---------
LEFT=""
for p in $(printf '%s\n' "$WRITTEN" | grep -v '(' | grep -v '^$'); do
  [ -f "$p" ] || continue
  hits=$(grep -o '{{[A-Z_][A-Z0-9_]*}}' "$p" 2>/dev/null | sort -u | tr '\n' ' ')
  [ -n "$hits" ] && LEFT="$LEFT
  $p: $hits"
done
if [ -n "$LEFT" ]; then
  echo "install-stack: internal: placeholders survived substitution:$LEFT" >&2
  exit 2
fi

echo "install-stack: installed stack '$STACK' into $PROJ:$WRITTEN"
