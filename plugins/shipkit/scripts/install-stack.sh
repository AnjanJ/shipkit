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

# Manifest support is optional here on purpose: install-stack.sh must keep working when
# invoked against a project that has not had install-rules.sh run yet.
HAVE_MANIFEST=0
if [ -f "$ROOT/scripts/lib-manifest.sh" ] && . "$ROOT/scripts/lib-manifest.sh" 2>/dev/null; then
  HAVE_MANIFEST=1
fi
# SHIPKIT_NONINTERACTIVE=1 suppresses the prompt on an edited CLAUDE.md section and warns
# instead. /shipkit:setup drives this interactively; a bare script call cannot ask.
NONINTERACTIVE="${SHIPKIT_NONINTERACTIVE:-0}"

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

# --- CLAUDE.md managed section (append once, refresh thereafter) ---------------------------
# 3.0 appended behind a `<!-- shipkit:stack:X -->` marker and skipped on re-run. That made
# the append idempotent and therefore UN-UPDATABLE: re-running with a corrected value updated
# the installed skill but left CLAUDE.md asserting the old one, so two files in the same
# install disagreed about how to run the tests. The section now has a closing marker too, so
# the managed region is defined and can be replaced in place. Content outside the markers is
# never touched. See .shipkit/specs/install-lifecycle/design.md DR-4.
MARK="<!-- shipkit:stack:$STACK -->"
ENDMARK="<!-- /shipkit:stack:$STACK -->"
if [ -f "$SRC/CLAUDE.md.append" ]; then
  CM="$PROJ/CLAUDE.md"
  SECTION=$(mktemp) || die "mktemp failed"
  { printf '\n%s\n' "$MARK"; cat "$SRC/CLAUDE.md.append"; printf '%s\n' "$ENDMARK"; } > "$SECTION"
  subst "$SECTION"
  if grep -q '{{[A-Z_][A-Z0-9_]*}}' "$SECTION"; then   # cannot happen after the pre-check; belt and braces
    rm -f "$SECTION"; die "internal: placeholders survived substitution in the CLAUDE.md section"
  fi

  if [ ! -f "$CM" ] || ! grep -qF "$MARK" "$CM"; then
    cat "$SECTION" >> "$CM" || die "cannot append to $CM"
    note "$CM (stack section appended)"
  elif ! grep -qF "$ENDMARK" "$CM"; then
    # A 3.0-era section: opening marker, no terminator, so its extent is unknown — it may run
    # to EOF or stop wherever the user began writing. Guessing risks eating their prose.
    echo "install-stack: $CM has a pre-3.1 '$MARK' section with no closing marker." >&2
    echo "  Its extent cannot be determined safely, so it was left unchanged." >&2
    echo "  Add '$ENDMARK' after the stack section to let shipkit refresh it in place." >&2
    note "$CM (legacy unterminated section — left unchanged)"
  else
    # Replace between the markers, preserving everything outside them.
    CUR=$(mktemp) || die "mktemp failed"
    awk -v s="$MARK" -v e="$ENDMARK" '
      index($0,s){inb=1; next} index($0,e){inb=0; next} inb{print}
    ' "$CM" > "$CUR"
    NEW=$(mktemp) || die "mktemp failed"
    awk -v s="$MARK" -v e="$ENDMARK" '
      index($0,s){inb=1; next} index($0,e){inb=0; next} inb{print}
    ' "$SECTION" > "$NEW"
    if cmp -s "$CUR" "$NEW"; then
      note "$CM (stack section already current — unchanged)"
      rm -f "$CUR" "$NEW"
    else
      # Did the user edit inside the managed block? Compare against what WE would have
      # written at install time; if it differs from both, their edits are at stake.
      if [ "$NONINTERACTIVE" = "1" ]; then
        echo "install-stack: $CM's '$STACK' section is out of date." >&2
        echo "  Re-run through /shipkit:setup to refresh it (it will show the diff first)," >&2
        echo "  or set SHIPKIT_REFRESH_CLAUDE_MD=1 to replace the section now." >&2
        if [ "${SHIPKIT_REFRESH_CLAUDE_MD:-0}" = "1" ]; then
          OUT=$(mktemp) || die "mktemp failed"
          awk -v s="$MARK" -v e="$ENDMARK" -v f="$SECTION" '
            index($0,s){inb=1; while((getline l < f)>0) print l; next}
            index($0,e){inb=0; next}
            !inb{print}
          ' "$CM" > "$OUT" && mv "$OUT" "$CM" || die "cannot refresh $CM"
          note "$CM (stack section refreshed)"
        else
          note "$CM (stack section stale — not refreshed; see the warning above)"
        fi
      else
        OUT=$(mktemp) || die "mktemp failed"
        awk -v s="$MARK" -v e="$ENDMARK" -v f="$SECTION" '
          index($0,s){inb=1; while((getline l < f)>0) print l; next}
          index($0,e){inb=0; next}
          !inb{print}
        ' "$CM" > "$OUT" && mv "$OUT" "$CM" || die "cannot refresh $CM"
        note "$CM (stack section refreshed)"
      fi
      rm -f "$CUR" "$NEW"
    fi
  fi
  rm -f "$SECTION"
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

# --- record the overlay's files in the installation manifest --------------------------------
# REQ-8: the manifest must cover overlays and skills, not just the nine core rules — otherwise
# an overlay file that upstream drops is never reconciled and a missing one is never noticed.
# Appends to the existing manifest (seeded from it) rather than replacing it, so the core rules
# install-rules.sh recorded survive. A legacy pre-3.1 stamp owns nothing, so leave it alone and
# let the next /shipkit:setup establish ownership (DR-2).
if [ "$HAVE_MANIFEST" = "1" ] && [ -f "$(manifest_path "$PROJ")" ] && ! manifest_is_legacy "$PROJ"; then
  if manifest_begin; then
    manifest_entries "$PROJ" > "$MANIFEST_TMP" 2>/dev/null || true
    added=0
    for p in $(printf '%s\n' "$WRITTEN" | grep -v '(' | grep -v '^$'); do
      [ -f "$p" ] || continue
      rel=${p#"${PROJ%/}"/}
      # drop any stale entry for this path, then re-add with the current digest
      grep -v "$(printf '\t')$rel\$" "$MANIFEST_TMP" > "$MANIFEST_TMP.new" 2>/dev/null \
        && mv "$MANIFEST_TMP.new" "$MANIFEST_TMP"
      manifest_add "$PROJ" "$p" && added=$((added + 1))
    done
    # record this stack in the stacks= header, deduped
    prior_stacks=$(manifest_stacks "$PROJ" 2>/dev/null)
    case " $prior_stacks " in
      *" $STACK "*) new_stacks="$prior_stacks" ;;
      *) new_stacks=$(printf '%s %s' "$prior_stacks" "$STACK" | sed 's/^ *//; s/  */ /g') ;;
    esac
    ver=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -1)
    if manifest_commit "$PROJ" "${ver:-unknown}" "$new_stacks"; then
      note "manifest updated ($added file(s) now owned under stack '$STACK')"
    fi
  fi
fi

echo "install-stack: installed stack '$STACK' into $PROJ:$WRITTEN"
