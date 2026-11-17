#!/bin/sh
# Shipkit spec-check: does every requirement in a spec have a task, and — once the spec is
# shipped — a test that cites it?
#
#   spec-check.sh <project-dir> [slug] [--as-shipped | --as-open]
#
#   no slug        every spec under .shipkit/specs/
#   --as-shipped   ask an OPEN spec for what a shipped one owes — a cited test for every
#                  requirement that is not excused. Changes no file. It is how the ship gate
#                  asks "would this pass if it shipped now?" before the status is changed.
#   --as-open      read a DRAFT spec as an open one for this run — the task-format checks,
#                  MISSING-TASK and PENDING-TEST — changing no file. It is how the spec skill
#                  checks a draft before the owner accepts it; without it a draft is SKIPPED
#                  (the real run flipped the status to open for one run to get this; 4.7.0).
#                  Open, shipped and dropped specs are read as without the flag.
#
# Reads the spec files as plain text and prints one line per finding:
#
#   MISSING-TASK <slug> REQ-N   tasks.md never mentions the requirement
#   MISSING-TEST <slug> REQ-N   the spec is shipped and no file cites "<slug>/REQ-N"
#   PENDING-TEST <slug> REQ-N   the spec is OPEN and no file cites it yet — information, not a
#                               gap: the test is owed at ship time (both 4.0.0 gates failed
#                               their first run on exactly this, unseen until the gate ran)
#   WAIVED <slug> REQ-N         the requirement ends with [untested: <reason>]
#   EVIDENCE <slug> tested=<a> waived=<b> uncited=<c>
#                               one for each spec checked — information, not a gap: how many of
#                               its requirements have a waiver (b), have none and are cited (a),
#                               or neither (c). A ship report can then say how much of READY is
#                               tests and how much is reading (honest-evidence/REQ-12)
#   CITED-ELSEWHERE <slug> REQ-N <file>
#                               the spec has a "> Tests:" line and this citation sits in a file
#                               outside its paths, so it does not count — information; the
#                               requirement then reads MISSING-TEST or PENDING-TEST unless
#                               another citation counts (honest-evidence/REQ-16, REQ-18)
#   SKIPPED-CITE <slug> REQ-N <file>:<line>
#                               a counted citation, at that file and line, sits on a line with
#                               a skip marker or within three lines of one (@tag :skip, it.skip,
#                               xit(, @pytest.mark.skip, xfail, t.Skip(, a line that begins
#                               "skip" or "pending", and their like) — information, not a gap:
#                               the test it names may never run (honest-evidence/REQ-19, REQ-20)
#   SKIPPED <slug> (<status>)   the spec is a draft or was dropped; nothing is checked
#   MISSING-FIELD <slug> <task> <field>   a task lacks Files, Test, After or Done-when
#   BAD-AFTER <slug> <task> <name>        a task's After names a task that does not exist
#   CONFLICT <slug> <a> <b> <file>        tasks a and b both list the file, and b (the later
#                                         one) does not come after a
#   CYCLE <slug> <task>                   the task's After lines lead back to itself
#   STRAY-STATUS <slug> <file>            design.md or tasks.md carries a "> Status:" line; only
#                                         spec.md has one, and a second can contradict it (the 5.1
#                                         run's design.md kept "draft" beside an open spec;
#                                         gate-on-setup/REQ-5)
#
# How a spec is read:
#   - Status comes from a "> Status: draft|open|shipped|dropped" line in spec.md. A spec with
#     no such line is treated as open — which is every spec written before 3.3.
#   - A requirement is any line containing **REQ-N. Its text runs to the next requirement,
#     blank line or heading, so an [untested: …] excuse may sit on a wrapped line.
#   - A test cites a requirement by containing "<slug>/REQ-N" anywhere — a comment or a test
#     name. The slug is needed because every spec has its own REQ-1. Citations under .shipkit/,
#     under docs/, or in any *.md file do not count: prose is not a test.
#   - A spec may narrow that with a "> Tests: tests/billing/, scripts/smoke.sh" line in spec.md:
#     comma-separated files or folders, written like "> Paths:". Its citations then count only
#     in a listed file or under a listed folder. No such line: any file that the rule above
#     allows, as before.
#   - Only a shipped spec is asked for tests. An open one still owes them, and is told so by a
#     PENDING-TEST line per uncited requirement (exit status unchanged; --as-shipped turns
#     them into MISSING-TEST).
#   - The three task-format checks apply only to an OPEN spec that carries a Status line —
#     that is, a spec written in the 3.3 format. A task is a line "- [ ] **T3** …" followed by
#     indented "- Files:", "- Test:", "- After:", "- Done when:" lines. Files and After are
#     comma-separated; After may be "none". The sharing rule: of two tasks that list the same
#     file, the later one must come after the earlier one — named on its After line, or
#     reached through a chain of After lines (T3 after T2, T2 after T1). It is what makes it
#     safe to hand tasks to agents working at the same time.
#
# This checks that a citation EXISTS, not that the cited test passes or proves the requirement.
#
# Exit status: 0 no MISSING-, BAD-AFTER, CONFLICT, CYCLE or STRAY-STATUS line; 1 at least one;
# 64 wrong usage.
# POSIX sh + awk + git. No bash-only syntax, no python. Spec: .shipkit/specs/spec-contract/.

usage() {
  echo "usage: spec-check.sh <project-dir> [slug] [--as-shipped | --as-open]" >&2
  exit 64
}
AS_SHIPPED=0
AS_OPEN=0
PROJ=""
ONLY=""
for arg in "$@"; do
  case "$arg" in
    --as-shipped) AS_SHIPPED=1 ;;
    --as-open) AS_OPEN=1 ;;
    -*) usage ;;
    *) if [ -z "$PROJ" ]; then PROJ=$arg; elif [ -z "$ONLY" ]; then ONLY=$arg; else usage; fi ;;
  esac
done
[ -n "$PROJ" ] || usage
[ -d "$PROJ" ] || { echo "spec-check: no such directory: $PROJ" >&2; exit 64; }
SPECS="$PROJ/.shipkit/specs"
if [ -n "$ONLY" ] && [ ! -f "$SPECS/$ONLY/spec.md" ]; then
  echo "spec-check: no spec at .shipkit/specs/$ONLY/spec.md" >&2
  exit 64
fi

TMP=$(mktemp "${TMPDIR:-/tmp}/shipkit.XXXXXX") || exit 1  # a template: bare mktemp ignores TMPDIR on macOS
CITES="$TMP.cites"
LOCS="$TMP.locs"
trap 'rm -f "$TMP" "$CITES" "$LOCS" "$TMP.cnt" "$TMP.else" "$TMP.skip"' EXIT

# spec_status <spec.md> → draft | open | shipped | dropped  (anything else, or no line: open)
spec_status() {
  _s=$(sed -n 's/^> *Status: *\([a-z]*\).*/\1/p' "$1" | sed -n 1p)
  case "$_s" in
    draft|open|shipped|dropped) echo "$_s" ;;
    *) echo open ;;
  esac
}

# task_findings <slug> <tasks.md> → MISSING-FIELD / BAD-AFTER / CONFLICT / CYCLE lines
task_findings() {
  awk -v slug="$1" '
    function trim(s) { gsub(/`/, "", s); sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function field(name, key,   v) {
      v = $0; sub(/^[ \t]+- [A-Za-z ]+:/, "", v); val[id, key] = trim(v); has[id, key] = 1
    }
    /^- \[[ xX]\] \*\*[A-Za-z0-9_-]+\*\*/ {
      match($0, /\*\*[A-Za-z0-9_-]+\*\*/); id = substr($0, RSTART + 2, RLENGTH - 4)
      nt++; ids[nt] = id; known[id] = 1; next
    }
    id == "" { next }
    /^[ \t]+- Files:/     { field("Files", "Files"); next }
    /^[ \t]+- Test:/      { field("Test", "Test"); next }
    /^[ \t]+- After:/     { field("After", "After"); next }
    /^[ \t]+- Done when:/ { field("Done when", "Done-when"); next }
    END {
      nf = split("Files Test After Done-when", fields, " ")
      for (i = 1; i <= nt; i++) {
        t = ids[i]
        for (k = 1; k <= nf; k++)
          if (!has[t, fields[k]]) print "MISSING-FIELD", slug, t, fields[k]
        n = split(val[t, "After"], a, ",")
        for (k = 1; k <= n; k++) {
          x = trim(a[k])
          if (x == "" || x == "none") continue
          if (x in known) dep[t, x] = 1; else print "BAD-AFTER", slug, t, x
        }
      }
      # "Comes after" follows chains: close dep[] over itself (tasks are few; n^3 is nothing).
      for (k = 1; k <= nt; k++)
        for (i = 1; i <= nt; i++)
          if (dep[ids[i], ids[k]])
            for (j = 1; j <= nt; j++)
              if (dep[ids[k], ids[j]]) dep[ids[i], ids[j]] = 1
      for (i = 1; i <= nt; i++)
        if (dep[ids[i], ids[i]]) print "CYCLE", slug, ids[i]
      for (i = 1; i <= nt; i++)
        for (j = i + 1; j <= nt; j++) {
          a1 = ids[i]; b1 = ids[j]
          if (dep[b1, a1]) continue
          na = split(val[a1, "Files"], fa, ","); nb = split(val[b1, "Files"], fb, ",")
          for (p = 1; p <= na; p++)
            for (q = 1; q <= nb; q++) {
              f = trim(fa[p])
              if (f != "" && f == trim(fb[q])) print "CONFLICT", slug, a1, b1, f
            }
        }
    }
  ' "$2"
}

# spec_reqs <spec.md> <tasks.md> → one line per requirement, in order:
#   "<N> R T"  required, mentioned in tasks.md      "<N> R -"  required, not mentioned
#   "<N> W T"  waived (and mentioned)               "<N> W -"  waived, not mentioned
# One awk over both files, rather than a grep per requirement: the briefing runs this on
# every session start, and fifty specs must come back in well under a second.
spec_reqs() {
  awk '
    function flush() { if (n != "" && !(n in seen)) { seen[n] = 1; order[++count] = n; kind[n] = (w ? "W" : "R") } n = ""; w = 0 }
    FNR == 1 { file++ }
    file == 1 && (/^[ \t]*$/ || /^#/) { flush(); next }
    file == 1 && /\*\*REQ-[0-9]+/ { flush(); match($0, /\*\*REQ-[0-9]+/); n = substr($0, RSTART + 6, RLENGTH - 6) }
    file == 1 && n != "" && /\[untested:/ { w = 1 }
    file == 2 { t = $0; while (match(t, /REQ-[0-9]+/)) { mentioned[substr(t, RSTART + 4, RLENGTH - 4)] = 1; t = substr(t, RSTART + RLENGTH) } }
    END { flush(); for (i = 1; i <= count; i++) print order[i], kind[order[i]], (order[i] in mentioned ? "T" : "-") }
  ' "$1" "$2"
}

# collect_cites → every "<slug>/REQ-N" that appears in a file that counts as a test, one per
# line, in $CITES. ONE git grep per run: the briefing runs this script at every session start,
# and a grep per requirement made fifty open specs take 2.7 s (smoke check 30's limit is 1 s).
# Still one search, now with -n: each hit is "<file>:<line>:<citation>", kept in $LOCS as
# "<file><TAB><line><TAB><citation>" so that a spec with a "> Tests:" line can ask where a
# citation sits (honest-evidence/REQ-15). $CITES is as before, every citation once, and is what
# a spec with no such line is counted from (honest-evidence/REQ-17).
collect_cites() {
  _pat='[A-Za-z0-9._-]+/REQ-[0-9]+'
  if git -C "$PROJ" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$PROJ" grep -n -I -o --untracked -E -e "$_pat" -- . \
      ':(exclude).shipkit' ':(exclude)docs' ':(exclude)*.md' 2>/dev/null
  else
    (cd "$PROJ" && git grep -n -I -o --no-index -E -e "$_pat" -- . \
      ':(exclude).shipkit' ':(exclude)docs' ':(exclude)*.md' 2>/dev/null)
  fi | awk -F: 'NF >= 3 { f = $1; for (i = 2; i <= NF - 2; i++) f = f ":" $i; print f "\t" $(NF - 1) "\t" $NF }' > "$LOCS"
  cut -f3 "$LOCS" | sort -u > "$CITES"
}
collect_cites

# cited <slug> <N> → exit 0 if a file that counts as a test cites <slug>/REQ-N (whole token:
# alpha/REQ-1 is not satisfied by alpha/REQ-10 or beta/REQ-1). $SPEC_CITES is $CITES, or for a
# spec with a "> Tests:" line the citations found under its paths.
cited() {
  grep -q -x -F "$1/REQ-$2" "$SPEC_CITES"
}

# under(f): is the file one of the Tests paths, or under one that is a folder (written with or
# without its last slash)? The paths come in through the environment, one a line: BSD awk
# rejects a newline in a -v value. Shared by the two awk programs below.
AWK_UNDER='
    function under(f,   i, q) {
      for (i = 1; i <= np; i++) {
        if (paths[i] == "") continue
        if (f == paths[i]) return 1
        q = paths[i]; if (q !~ /\/$/) q = q "/"
        if (index(f, q) == 1) return 1
      }
      return 0
    }'

# skip_scan → $TMP.skip: "<file><TAB><line><TAB><citation>" for each citation that sits on a
# line holding a skip marker, or within three lines above or below one (honest-evidence/REQ-19).
# One awk reads $LOCS and then each citing file once. A marker is a whole word: "exit(" holds
# "xit(" and "--maxfail" holds "xfail", and neither is one. This is a guess from text: a test
# left out by configuration (an ExUnit tag excluded in test_helper.exs) has no marker near it
# and is not seen, and a marker in a comment three lines away is.
skip_scan() {
  : > "$TMP.skip"
  [ -s "$LOCS" ] || return 0
  (cd "$PROJ" && awk -F '\t' '
    function word(line, s,   p, rest, off, c) {   # s is in line, not preceded by a letter, a digit or _
      rest = line; off = 0
      while ((p = index(rest, s)) > 0) {
        c = (off + p > 1) ? substr(line, off + p - 1, 1) : ""
        if (c !~ /[A-Za-z0-9_]/) return 1
        off += p; rest = substr(rest, p + 1)
      }
      return 0
    }
    function marker(line,   i, t) {
      for (i = 1; i <= nm; i++) if (word(line, m[i])) return 1
      t = line; sub(/^[ \t]+/, "", t)
      return (t ~ /^(skip|pending)([^A-Za-z0-9_]|$)/)
    }
    BEGIN { nm = split("@tag :skip|@moduletag :skip|it.skip|test.skip|describe.skip|xit(|xdescribe(|@pytest.mark.skip|@unittest.skip|pytest.skip(|xfail|t.Skip(", m, "|") }
    { if (!($1 in seen)) { seen[$1] = 1; order[++nf] = $1 }
      at[$1] = at[$1] " " $2; what[$1, $2] = what[$1, $2] " " $3 }
    END {
      for (k = 1; k <= nf; k++) {
        f = order[k]; n = 0; split("", mark)
        while ((getline line < f) > 0) { n++; if (marker(line)) mark[n] = 1 }
        close(f)
        c = split(at[f], ln, " "); split("", did)
        for (i = 1; i <= c; i++) {
          l = ln[i] + 0; if (l in did) continue; did[l] = 1
          hit = 0; for (d = -3; d <= 3; d++) if ((l + d) in mark) hit = 1
          if (!hit) continue
          w = split(what[f, ln[i]], cs, " ")
          for (j = 1; j <= w; j++) print f "\t" l "\t" cs[j]
        }
      }
    }' "$LOCS") > "$TMP.skip" 2>/dev/null
}
skip_scan

# skipped_lines <slug> <1 when the spec has a Tests line> <its paths> → the SKIPPED-CITE lines
# for the spec's counted citations: all of its citations, or with a Tests line those under it.
skipped_lines() {
  SC_TESTS="$3" awk -F '\t' -v slug="$1" -v only="$2" "$AWK_UNDER"'
    BEGIN { np = split(ENVIRON["SC_TESTS"], paths, "\n"); pre = slug "/REQ-" }
    index($3, pre) == 1 && substr($3, length(pre) + 1) ~ /^[0-9]+$/ && (only == 0 || under($1)) {
      print "SKIPPED-CITE " slug " REQ-" substr($3, length(pre) + 1) " " $1 ":" $2
    }' "$TMP.skip" | sort -u
}

# tests_filter <slug> <the Tests paths, one a line> → writes to $TMP.cnt the spec's citations
# that sit in a listed file or under a listed folder, and prints one CITED-ELSEWHERE line for
# each requirement and file outside them.
tests_filter() {
  : > "$TMP.cnt"
  SC_TESTS="$2" awk -F '\t' -v slug="$1" -v counted="$TMP.cnt" "$AWK_UNDER"'
    BEGIN { np = split(ENVIRON["SC_TESTS"], paths, "\n"); pre = slug "/REQ-" }
    index($3, pre) == 1 && substr($3, length(pre) + 1) ~ /^[0-9]+$/ {
      if (under($1)) print $3 > counted
      else print "CITED-ELSEWHERE " slug " REQ-" substr($3, length(pre) + 1) " " $1
    }' "$LOCS" | sort -u
}

# One search names the specs that carry a "> Tests:" line, so a spec without one costs no
# process more than it did: the briefing runs this script at every session start, and fifty
# specs must come back within a second (smoke check 30 read 1.24 s when each spec was asked).
TESTS_SPECS=$(grep -l '^> *Tests:' "$SPECS"/*/spec.md 2>/dev/null | tr '\n' '|')

gaps=0
checked=0
for spec in "$SPECS"/*/spec.md; do
  [ -f "$spec" ] || continue
  dir=${spec%/spec.md}
  slug=${dir##*/}
  [ -z "$ONLY" ] || [ "$slug" = "$ONLY" ] || continue
  status=$(spec_status "$spec")
  [ "$AS_OPEN" -eq 1 ] && [ "$status" = draft ] && status=open   # harness-debts/REQ-1
  case "$status" in
    draft|dropped) echo "SKIPPED $slug ($status)"; continue ;;
  esac
  checked=$((checked + 1))
  for f in design.md tasks.md; do
    if [ -f "$dir/$f" ] && grep -q '^> *Status:' "$dir/$f"; then
      echo "STRAY-STATUS $slug $f"
      gaps=$((gaps + 1))
    fi
  done
  # A "> Tests: a/, b/c.sh" line narrows where this spec's citations count; none: as before.
  SPEC_CITES=$CITES; has_tests=0; tests=""
  case "|$TESTS_SPECS" in *"|$spec|"*) has_tests=1 ;; esac
  if [ "$has_tests" -eq 1 ]; then
    tests=$(sed -n 's/^> *Tests: *//p' "$spec" | sed -n 1p | tr ',' '\n' | sed 's/`//g; s/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$')
    tests_filter "$slug" "$tests" > "$TMP.else"
    SPEC_CITES="$TMP.cnt"
  fi
  if [ -f "$dir/tasks.md" ]; then spec_reqs "$spec" "$dir/tasks.md" > "$TMP"; else spec_reqs "$spec" /dev/null > "$TMP"; fi
  ev_t=0; ev_w=0; ev_u=0   # honest-evidence/REQ-12: tested, waived, uncited
  while read -r n kind mentioned; do
    [ -n "$n" ] || continue
    if [ "$kind" = W ]; then
      echo "WAIVED $slug REQ-$n"
      ev_w=$((ev_w + 1))
      continue
    fi
    if [ "$mentioned" != T ]; then
      echo "MISSING-TASK $slug REQ-$n"
      gaps=$((gaps + 1))
    fi
    if cited "$slug" "$n"; then
      ev_t=$((ev_t + 1))
    elif [ "$status" = shipped ] || [ "$AS_SHIPPED" -eq 1 ]; then
      echo "MISSING-TEST $slug REQ-$n"
      gaps=$((gaps + 1))
      ev_u=$((ev_u + 1))
    else
      echo "PENDING-TEST $slug REQ-$n"   # real-run/REQ-1: open spec, shown not enforced
      ev_u=$((ev_u + 1))
    fi
  done < "$TMP"
  echo "EVIDENCE $slug tested=$ev_t waived=$ev_w uncited=$ev_u"
  # CITED-ELSEWHERE lines: information, never a gap by themselves (REQ-18)
  [ "$has_tests" -eq 1 ] && cat "$TMP.else"
  # SKIPPED-CITE lines: information too (REQ-20). No process is spent when nothing was found.
  [ -s "$TMP.skip" ] && skipped_lines "$slug" "$has_tests" "$tests"
  if [ "$status" = open ] && grep -q '^> *Status:' "$spec" && [ -f "$dir/tasks.md" ]; then
    task_findings "$slug" "$dir/tasks.md" > "$TMP"
    if [ -s "$TMP" ]; then
      cat "$TMP"
      gaps=$((gaps + $(wc -l < "$TMP" | tr -d ' ')))
    fi
  fi
done

echo "spec-check: $checked spec(s) checked, $gaps gap(s)"
[ "$gaps" -eq 0 ] || exit 1
exit 0
