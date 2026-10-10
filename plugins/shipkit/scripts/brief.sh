#!/bin/sh
# Shipkit brief: turn one task of a spec into a brief another agent can follow.
#
#   brief.sh <project-dir> <slug> <task-id>      # prints the brief on stdout
#
# The brief is assembled from the spec's own files — no model, no paraphrase:
#
#   Goal                       the Purpose section of spec.md
#   Requirement                each requirement the task cites, copied word for word
#   You may edit               the task's Files line — and nothing else
#   Prove it with              the task's Test and Done when lines
#   Already done               every task this one comes after, directly or through a chain
#   Decisions that bind you    titles of the design.md decisions that cite the same requirements
#                              (a decision marked "Superseded" is left out)
#   Not in scope               the Out of scope section of spec.md
#   Report back …              the fixed form the agent answers in
#
# Hand the output over UNCHANGED. Context the agent also needs goes below it, never in place
# of it. When the agent reports back, check its work with brief-verify.sh and run the task's
# Done when command yourself: the agent's own claim is not proof.
#
# The spec must be in the 3.3 task format (tasks with Files / Test / After / Done when).
# Exit status: 0 brief printed; 1 no such spec or task, or the task has no Files line;
# 64 wrong usage. POSIX sh + awk. Spec: .shipkit/specs/product-intake-brief/.

[ $# -eq 3 ] || { echo "usage: brief.sh <project-dir> <slug> <task-id>" >&2; exit 64; }
PROJ=$1; SLUG=$2; TASK=$3
[ -d "$PROJ" ] || { echo "brief: no such directory: $PROJ" >&2; exit 64; }
DIR="$PROJ/.shipkit/specs/$SLUG"
SPEC="$DIR/spec.md"; DESIGN="$DIR/design.md"; TASKS="$DIR/tasks.md"
[ -f "$SPEC" ] && [ -f "$TASKS" ] || {
  echo "brief: no spec '$SLUG' (need .shipkit/specs/$SLUG/spec.md and tasks.md)" >&2; exit 1; }

# task <what> → one fact about $TASK, read from tasks.md.
#   exists | title | reqs | files | test | done | after (the closure: "id<TAB>title" per line)
task() {
  awk -v want="$1" -v task="$TASK" '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function field(key,   v) { v = $0; sub(/^[ \t]+- [A-Za-z ]+:/, "", v); val[id, key] = trim(v); has[id, key] = 1; inhdr = 0 }
    /^- \[[ xX]\] \*\*[A-Za-z0-9_-]+\*\*/ {
      match($0, /\*\*[A-Za-z0-9_-]+\*\*/); id = substr($0, RSTART + 2, RLENGTH - 4)
      nt++; ids[nt] = id; known[id] = 1; hdr[id] = substr($0, RSTART + RLENGTH); inhdr = 1; next
    }
    id == "" { next }
    /^[ \t]+- Files:/     { field("files"); next }
    /^[ \t]+- Test:/      { field("test"); next }
    /^[ \t]+- After:/     { field("after"); next }
    /^[ \t]+- Done when:/ { field("done"); next }
    /^[ \t]*$/ { inhdr = 0; next }
    inhdr { hdr[id] = hdr[id] " " trim($0) }
    END {
      if (want == "exists") { exit(known[task] ? 0 : 1) }
      if (want == "title") {
        t = hdr[task]; p = index(t, "→"); if (p) t = substr(t, 1, p - 1)
        print trim(t); exit
      }
      if (want == "reqs") {
        t = hdr[task]
        while (match(t, /REQ-[0-9]+/)) { print substr(t, RSTART + 4, RLENGTH - 4); t = substr(t, RSTART + RLENGTH) }
        exit
      }
      if (want == "files") {
        if (!has[task, "files"]) exit 1
        n = split(val[task, "files"], f, ","); for (i = 1; i <= n; i++) { x = trim(f[i]); gsub(/`/, "", x); if (x != "") print x }
        exit
      }
      if (want == "test") { print val[task, "test"]; exit }
      if (want == "done") { print val[task, "done"]; exit }
      if (want == "after") {
        for (i = 1; i <= nt; i++) {
          n = split(val[ids[i], "after"], a, ",")
          for (k = 1; k <= n; k++) { x = trim(a[k]); if (x in known) dep[ids[i], x] = 1 }
        }
        for (k = 1; k <= nt; k++) for (i = 1; i <= nt; i++) if (dep[ids[i], ids[k]])
          for (j = 1; j <= nt; j++) if (dep[ids[k], ids[j]]) dep[ids[i], ids[j]] = 1
        for (i = 1; i <= nt; i++) if (dep[task, ids[i]] && ids[i] != task) {
          t = hdr[ids[i]]; p = index(t, "→"); if (p) t = substr(t, 1, p - 1)
          print ids[i] "\t" trim(t)
        }
      }
    }
  ' "$TASKS"
}

# section <file> <heading-prefix> → the body of the first "## <heading-prefix>…" section
section() {
  awk -v h="$2" '
    /^## / { if (on) exit; if (index($0, "## " h) == 1) { on = 1; next } }
    on { print }
  ' "$1" | awk 'NF { seen = 1 } seen { buf[++n] = $0 } END { while (n > 0 && buf[n] ~ /^[ \t]*$/) n--; for (i = 1; i <= n; i++) print buf[i] }'
}

# requirement <N> → the requirement, exactly as written in spec.md
requirement() {
  awk -v n="$1" '
    /^[ \t]*$/ || /^#/ { on = 0; next }
    /\*\*REQ-[0-9]+/ { match($0, /\*\*REQ-[0-9]+/); on = (substr($0, RSTART + 6, RLENGTH - 6) == n) }
    on { print }
  ' "$SPEC"
}

# decisions <reqs…> → titles of live decisions in design.md whose heading cites one of them.
# A heading may cite a range: "(→ REQ-11 to REQ-17)".
decisions() {
  [ -f "$DESIGN" ] || return 0
  awk -v reqs="$*" '
    function cites(h,   t, a, b, i) {
      t = h
      while (match(t, /REQ-[0-9]+ to REQ-[0-9]+/)) {
        s = substr(t, RSTART, RLENGTH); a = s; sub(/^REQ-/, "", a); sub(/ to .*/, "", a); b = s; sub(/.*REQ-/, "", b)
        for (i = a + 0; i <= b + 0; i++) if (i in want) return 1
        t = substr(t, RSTART + RLENGTH)
      }
      t = h
      while (match(t, /REQ-[0-9]+/)) { if (substr(t, RSTART + 4, RLENGTH - 4) in want) return 1; t = substr(t, RSTART + RLENGTH) }
      return 0
    }
    function flush() { if (title != "" && !dead) print "- " title; title = "" }
    BEGIN { n = split(reqs, r, " "); for (i = 1; i <= n; i++) want[r[i]] = 1 }
    /^## Decision:/ {
      flush(); dead = 0
      if (cites($0)) { title = $0; sub(/^## Decision:[ \t]*/, "", title); sub(/[ \t]*\(→.*$/, "", title) }
      next
    }
    /^## / { flush(); next }
    title != "" && /Superseded/ { dead = 1 }
    END { flush() }
  ' "$DESIGN"
}

task exists || { echo "brief: no task '$TASK' in spec '$SLUG' (.shipkit/specs/$SLUG/tasks.md)" >&2; exit 1; }
FILES=$(task files) || {
  echo "brief: task '$TASK' in spec '$SLUG' has no Files line — the spec must be in the 3.3 task format (Files / Test / After / Done when)" >&2
  exit 1
}
REQS=$(task reqs)

# Hand over from a clean tree. brief-verify.sh reads every difference from the base ref,
# committed or not, and cannot tell the agent's change from one already there at hand-over:
# the second real run counted fourteen of setup's deletions as the agent's (field-notes-4.9.md
# §8.1). One line on stderr when the tree is dirty; the brief on stdout is unchanged (run-debts
# REQ-5). Not a repository: nothing to count, no line.
if git -C "$PROJ" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  DIRTY=$(git -C "$PROJ" status --short --untracked-files=all 2>/dev/null | grep -c .)
  [ "$DIRTY" -gt 0 ] && echo "brief: $DIRTY file(s) already differ from HEAD; brief-verify will count them" >&2
fi

echo "# Brief: $SLUG / $TASK — $(task title)"
echo
echo "## Goal"
section "$SPEC" "Purpose"
echo
echo "## Requirement"
if [ -n "$REQS" ]; then
  for n in $REQS; do requirement "$n"; done
else
  echo "This task cites no requirement."
fi
echo
echo "## You may edit"
printf '%s\n' "$FILES" | sed 's/^/- /'
echo "Nothing else. If the task cannot be done inside these files, stop and report blocked."
echo
echo "## Prove it with"
echo "- Test: $(task test)"
echo "- Done when: $(task done)"
echo
echo "## Already done"
AFTER=$(task after)
if [ -n "$AFTER" ]; then
  printf '%s\n' "$AFTER" | awk -F '\t' '{ print "- " $1 " — " $2 }'
else
  echo "Nothing — this task has no predecessors."
fi
echo
echo "## Decisions that bind you"
# shellcheck disable=SC2086
DEC=$(decisions $REQS)
if [ -n "$DEC" ]; then
  printf '%s\n' "$DEC"
  echo "(Full text: .shipkit/specs/$SLUG/design.md)"
else
  echo "None recorded for this task's requirements."
fi
echo
echo "## Not in scope"
OOS=$(section "$SPEC" "Out of scope")
if [ -n "$OOS" ]; then printf '%s\n' "$OOS"; else echo "Nothing listed."; fi
echo
echo "## Report back in exactly this form"
echo "RESULT: done | blocked"
echo "CHANGED: <files>"
echo "TEST: <command> → <last lines of output>"
echo "NOT VERIFIED: <anything you did not check, or \"nothing\">"
echo "DEVIATIONS: <anything you did differently from this brief, or \"none\">"
