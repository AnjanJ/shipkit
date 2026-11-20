#!/bin/sh
# kind-probe.sh — which kind of test does the spec skill name for a requirement?
#
# Three kinds of test are hard for a model to fool: an end-to-end test, a property test, whose
# inputs nobody chose, and a differential test, which uses the old system as the judge. The spec
# skill says "behavior-focused" and names no kind. Before any text says more, this script
# measures what the skill does today (the verifier plan's V16, "measure first"; the spec is
# .shipkit/specs/tests-worth-having/, and its design.md says how the result is read).
#
# It lives outside the eval suite, like wait-probe.sh, so it costs no byte of the evals folder.
#
# Usage:
#   kind-probe.sh --scaffold kinds <dir>
#       Write the kinds fixture into <dir> (new or empty): a small git repository with one
#       commit, whose accepted spec, passbook, holds three requirements of three shapes, a
#       design and no task list. No model call.
#   kind-probe.sh --scaffold migration <dir>
#       Write the migration fixture into <dir> (new or empty): a small git repository with
#       one commit, a program, inkwell, that uses a library kept in its own tree at version
#       1.4, the same library at 2.0, and the changelog between them. No model call.
#   kind-probe.sh --run kinds|migration [N] [--out <dir>] [--yes]
#       Without --yes: print the N headless commands (5 by default for kinds, 3 for
#       migration), one a line, and start nothing. With --yes: N runs, each on a fresh
#       fixture at <dir>/run-<i>/proj. A kinds run is /shipkit:spec passbook tasks, and its
#       tasks.md stays in the fixture. A migration run is /shipkit-workflows:migration-plan
#       textkit 1.4 2.0, and its reply is written to <dir>/run-<i>/plan.md. <dir> defaults
#       to ${TMPDIR:-/tmp}/kind-probe-<fixture>-<time>. --yes COSTS MODEL CALLS: use it only
#       on the owner's yes. Nothing is removed afterwards.

ROOT=$(cd "$(dirname "$0")/.." && pwd)
NOTE='This run is not interactive: you cannot ask me anything.'

usage() { sed -n '/^# Usage:/,/^$/p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

fresh() {  # fresh <dir>: the directory a fixture goes into is missing or empty
  if [ -e "$1" ] && [ -n "$(ls -A "$1" 2>/dev/null)" ]; then
    echo "kind-probe: $1 is not empty" >&2; return 2
  fi
}

commit() {  # commit <dir> <message>: one commit, the same on every machine
  (cd "$1" && git init -q && git symbolic-ref HEAD refs/heads/main && git add -A \
    && GIT_AUTHOR_DATE=2026-11-05T09:00:00Z GIT_COMMITTER_DATE=2026-11-05T09:00:00Z \
       git -c user.email=probe@example.com -c user.name=kind-probe -c commit.gpgsign=false \
       commit -q -m "$2") || return 1
}

# The kinds fixture. What exists: an account that takes deposits, three stored statements and
# the parser that reads them. What its spec asks for: withdrawals (a balance that never goes
# below zero), an export and an import (a round trip), and a new parser (a replacement that
# behaves as before). Writing the task list is the run.
scaffold_kinds() {
  sd=$1
  fresh "$sd" || return 2
  mkdir -p "$sd/passbook" "$sd/tests" "$sd/data/statements" "$sd/.claude/rules/shipkit" \
    "$sd/.shipkit/specs/passbook" || return 1
  cat > "$sd/README.md" <<'EOF'
# passbook

Keeps one account, stores each month's statement as a document and renders it.

    python3 -m passbook balance 500 250
    python3 -m passbook list
    python3 -m passbook render 2026-01.txt

Run the tests with `python3 -m unittest -q`.
EOF
  printf '__pycache__/\n' > "$sd/.gitignore"
  printf 'python3 -m unittest -q\n' > "$sd/.claude/rules/shipkit/.test-command"
  : > "$sd/passbook/__init__.py"
  : > "$sd/tests/__init__.py"
  cat > "$sd/passbook/account.py" <<'EOF'
"""An account and its balance, in whole pence."""


class Account:
    def __init__(self, opening=0):
        if opening < 0:
            raise ValueError("an account cannot open below zero")
        self.balance = opening
        self.records = []

    def deposit(self, amount, note=""):
        if amount <= 0:
            raise ValueError("a deposit is more than zero")
        self.balance += amount
        self.records.append(("deposit", amount, note))
        return self.balance
EOF
  cat > "$sd/passbook/statements.py" <<'EOF'
"""Stored statements, and the parser that reads them.

A statement is a text document. Its first line is "statement <account> <month>". Each line
after it is one entry: "<day> <kind> <pence> <note>".
"""
import os

DATA = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data", "statements")


def parse_v1(text):
    lines = [line for line in text.splitlines() if line.strip()]
    head = lines[0].split()
    entries = []
    for line in lines[1:]:
        day, kind, pence, *note = line.split()
        entries.append({"day": int(day), "kind": kind, "pence": int(pence), "note": " ".join(note)})
    return {"account": head[1], "month": head[2], "entries": entries}


def render(statement):
    out = ["Statement for %s, %s" % (statement["account"], statement["month"])]
    total = 0
    for entry in statement["entries"]:
        sign = 1 if entry["kind"] == "deposit" else -1
        total += sign * entry["pence"]
        out.append("%2d  %-10s %8.2f  %s" % (entry["day"], entry["kind"], entry["pence"] / 100, entry["note"]))
    out.append("Closing balance: %.2f" % (total / 100))
    return "\n".join(out) + "\n"


def stored():
    return sorted(name for name in os.listdir(DATA) if name.endswith(".txt"))


def render_file(name, parse=parse_v1):
    with open(os.path.join(DATA, name)) as f:
        return render(parse(f.read()))
EOF
  cat > "$sd/passbook/cli.py" <<'EOF'
"""python3 -m passbook balance <pence>... | list | render <file>"""
import sys

from .account import Account
from .statements import render_file, stored


def main(argv):
    if argv and argv[0] == "balance":
        account = Account()
        for amount in argv[1:]:
            account.deposit(int(amount))
        print(account.balance)
        return 0
    if argv == ["list"]:
        print("\n".join(stored()))
        return 0
    if len(argv) == 2 and argv[0] == "render":
        sys.stdout.write(render_file(argv[1]))
        return 0
    print(__doc__, file=sys.stderr)
    return 2
EOF
  cat > "$sd/passbook/__main__.py" <<'EOF'
import sys

from .cli import main

sys.exit(main(sys.argv[1:]))
EOF
  cat > "$sd/data/statements/2026-01.txt" <<'EOF'
statement ACC-1 2026-01
3 deposit 120000 salary
9 withdrawal 45500 rent share
21 deposit 300 refund from the cafe
EOF
  cat > "$sd/data/statements/2026-02.txt" <<'EOF'
statement ACC-1 2026-02
3 deposit 120000 salary
9 withdrawal 45500 rent share

17 withdrawal 1999 train ticket
EOF
  cat > "$sd/data/statements/2026-03.txt" <<'EOF'
statement ACC-1 2026-03
3 deposit 120000 salary
EOF
  cat > "$sd/tests/test_account.py" <<'EOF'
import unittest

from passbook.account import Account


class AccountTest(unittest.TestCase):
    def test_a_deposit_raises_the_balance(self):
        self.assertEqual(Account().deposit(500), 500)

    def test_a_deposit_of_nothing_is_refused(self):
        with self.assertRaises(ValueError):
            Account().deposit(0)
EOF
  cat > "$sd/tests/test_statements.py" <<'EOF'
import unittest

from passbook.statements import parse_v1, render, render_file, stored


class StatementsTest(unittest.TestCase):
    def test_three_documents_are_stored(self):
        self.assertEqual(len(stored()), 3)

    def test_a_statement_renders_its_closing_balance(self):
        text = "statement ACC-9 2026-04\n1 deposit 1000 a\n2 withdrawal 250 b\n"
        self.assertIn("Closing balance: 7.50", render(parse_v1(text)))

    def test_every_stored_document_renders(self):
        for name in stored():
            self.assertTrue(render_file(name).startswith("Statement for "))
EOF
  cat > "$sd/.shipkit/specs/passbook/intake.md" <<'EOF'
# Intake: passbook

> Intake taken on 2026-11-05.

## Request
Add withdrawals, an export and an import of records, and a new statement parser.

## Serves goal
None.

## Conflicts found
None.

## Answers
1. May the balance go below zero for a moment inside one withdrawal? **No, never.**
2. Does the old parser go away with this work? **No. It stays until the move is proven.**

## Assumptions made
- Amounts are whole pence.

## Out of scope
- Interest, currencies and more than one account.
EOF
  cat > "$sd/.shipkit/specs/passbook/spec.md" <<'EOF'
# Spec: passbook

> Spec accepted at commit `a1b2c3d` on main.
> Status: open
> Paths: passbook/, tests/

## Purpose
Passbook keeps an account, stores each month's statement as a document and renders it. Money
cannot be taken out, records cannot leave or enter the program, and the statement parser cannot
read the entries the bank sends from next year. This spec adds withdrawals, an export and an
import, and a new parser.

## User stories
- As an account holder, I want to withdraw money and never go below zero.
- As an account holder, I want to move my records to another machine.
- As the maintainer, I want to replace the parser without changing what a stored statement shows.

## Requirements (EARS)
- **REQ-1.** For every sequence of deposits and withdrawals, the balance shall never be negative: a withdrawal of more than the balance shall be refused and shall change nothing.
- **REQ-2.** When records are written with `python3 -m passbook export <file>` and read back with `python3 -m passbook import <file>`, an exported file shall import to the same records, in the same order.
- **REQ-3.** `parse_v2` shall replace `parse_v1` in `render_file`, and after the move to the new parser, every stored document shall render as before.

## Out of scope
- Interest, currencies and more than one account.
- Removing `parse_v1`: it stays until the move is proven.
EOF
  cat > "$sd/.shipkit/specs/passbook/design.md" <<'EOF'
# Design: passbook

## Approach
Withdrawals go into `passbook/account.py` beside `deposit`. Export and import are two commands in
`passbook/cli.py` over a new `passbook/transfer.py`; the file holds one record a line. The new
parser is `parse_v2` in `passbook/statements.py`.

## Decision: The new parser takes over in one step, and the old one stays in the tree   (→ REQ-3)

**Context.** `render_file` calls `parse_v1`. The bank's entries will carry a currency code that
`parse_v1` cannot read. Three statements are stored under `data/statements/`, and what they
render to is what the account holder has already seen.

**Alternatives.**
1. Write `parse_v2`, switch `render_file` to it, and keep `parse_v1` in the tree.
2. Change `parse_v1` in place.
3. Keep both in use and choose by the statement's month.

**Case for (1).** `parse_v1` stays as the record of what every stored statement rendered to.

**Case against (1).** Two parsers to read until the old one is removed. (2) loses the old
behaviour the day it changes. (3) keeps two code paths for good.

**Decision.** We chose (1).
**Falsifiability.** We would keep both in use, as (3), if a stored statement renders differently
under `parse_v2` and the difference cannot be removed.
**Fired-if.** manual

## Data / interface changes
- `Account.withdraw(amount, note="")` (REQ-1).
- `python3 -m passbook export <file>` and `import <file>`; the file holds one record a line
  (REQ-2).
- `parse_v2(text)`, with the result shape of `parse_v1` (REQ-3).
EOF
  commit "$sd" "passbook: an account and its statements"
}

# The migration fixture. inkwell formats a note with textkit, a library it keeps in vendor/ at
# version 1.4. Version 2.0 is beside it with its changelog, which names two changes of behaviour
# in the two functions inkwell calls. inkwell's tests pass on 1.4 and fail on 2.0.
scaffold_migration() {
  sd=$1
  fresh "$sd" || return 2
  mkdir -p "$sd/inkwell" "$sd/tests" "$sd/vendor/textkit-1" "$sd/vendor/textkit-2" \
    "$sd/.claude/rules/shipkit" || return 1
  cat > "$sd/README.md" <<'EOF'
# inkwell

Formats a note for the printed page: a title-cased heading, a rule, and the body wrapped to a
width.

    python3 -c 'from inkwell.format import page; print(page("the reader'"'"'s notes", "one two three"))'

The text helpers come from `textkit`, kept under `vendor/`. `inkwell/deps.py` says which
version is in use. Run the tests with `python3 -m unittest -q`.
EOF
  printf '__pycache__/\n' > "$sd/.gitignore"
  printf 'python3 -m unittest -q\n' > "$sd/.claude/rules/shipkit/.test-command"
  : > "$sd/inkwell/__init__.py"
  : > "$sd/tests/__init__.py"
  cat > "$sd/inkwell/deps.py" <<'EOF'
"""The one place that says which textkit is in use."""
import os
import sys

VENDOR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "vendor")
sys.path.insert(0, os.path.join(VENDOR, "textkit-1"))
EOF
  cat > "$sd/inkwell/format.py" <<'EOF'
"""Formats a note for the printed page."""
from . import deps  # noqa: F401, it puts the vendored textkit on the path

import textkit


def heading(text):
    return textkit.title(text)


def body(text, width=24):
    return textkit.wrap(text, width)


def page(title, text, width=24):
    return heading(title) + "\n" + "-" * width + "\n" + body(text, width) + "\n"
EOF
  cat > "$sd/vendor/textkit-1/textkit.py" <<'EOF'
"""textkit 1.4: small helpers for plain text."""
__version__ = "1.4"


def wrap(text, width):
    """Break text into lines of at most width characters, at single spaces."""
    lines, line = [], ""
    for word in text.split(" "):
        if line and len(line) + 1 + len(word) > width:
            lines.append(line)
            line = word
        else:
            line = word if not line else line + " " + word
    lines.append(line)
    return "\n".join(lines)


def title(text):
    """Capitalise the first letter of each word."""
    return text.title()
EOF
  cat > "$sd/vendor/textkit-2/textkit.py" <<'EOF'
"""textkit 2.0: small helpers for plain text."""
__version__ = "2.0"


def wrap(text, width):
    """Break text into lines of at most width characters, at single spaces."""
    lines, line = [], ""
    for word in text.split(" "):
        if line and len(line) + 1 + len(word) > width:
            lines.append(line)
            line = word
        else:
            line = word if not line else line + " " + word
    lines.append(line)
    return "\n".join(each.rstrip(" ") for each in lines)


def title(text):
    """Capitalise the first letter of each word, and no letter after an apostrophe."""
    return " ".join(word[:1].upper() + word[1:].lower() for word in text.split(" "))
EOF
  cat > "$sd/vendor/textkit-2/CHANGELOG.md" <<'EOF'
# Changelog

## 2.0

Breaking changes from 1.4:

- `wrap()` strips trailing spaces from every line it returns. In 1.4 a line could end with a
  space when the text had two spaces in a row.
- `title()` no longer capitalises the letter after an apostrophe: "reader's" gives "Reader's",
  where 1.4 gave "Reader'S".

Nothing else changes: both functions take the arguments they took.

## 1.4

- `wrap()` and `title()`.
EOF
  cat > "$sd/tests/test_format.py" <<'EOF'
import unittest

from inkwell.format import body, heading, page


class FormatTest(unittest.TestCase):
    def test_a_heading_is_title_cased(self):
        self.assertEqual(heading("the reader's notes"), "The Reader'S Notes")

    def test_a_body_is_wrapped_at_the_width(self):
        self.assertEqual(body("one two  three four", 8), "one two \nthree\nfour")

    def test_a_page_has_a_heading_a_rule_and_a_body(self):
        self.assertEqual(page("notes", "one two", 8), "Notes\n--------\none two\n")
EOF
  commit "$sd" "inkwell: a page formatter on textkit 1.4"
}

scaffold() {  # scaffold <fixture> <dir>
  case "$1" in
    kinds) scaffold_kinds "$2" ;;
    migration) scaffold_migration "$2" ;;
    *) usage ;;
  esac
}

run() {  # run <fixture> [N] [--out <dir>] [--yes]
  fx=$1; shift
  case "$fx" in
    kinds) n=5; plugin="$ROOT/plugins/shipkit"; request="/shipkit:spec passbook tasks $NOTE" ;;
    migration) n=3; plugin="$ROOT/plugins/shipkit-workflows"
      request="/shipkit-workflows:migration-plan textkit 1.4 2.0. The changelog is vendor/textkit-2/CHANGELOG.md, in this repository. $NOTE" ;;
    *) usage ;;
  esac
  out=""; yes=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --out) [ $# -ge 2 ] || usage; out=$2; shift 2 ;;
      --yes) yes=1; shift ;;
      *[!0-9]*|'') usage ;;
      *) n=$1; shift ;;
    esac
  done
  if [ "$yes" -eq 0 ]; then
    i=1
    while [ "$i" -le "$n" ]; do
      printf 'cd %s/run-%s/proj && claude --plugin-dir %s --model sonnet --allowedTools Read Glob Grep Bash Write Edit Skill Agent --output-format json -p "%s" < /dev/null\n' \
        "${out:-<out>}" "$i" "$plugin" "$request"
      i=$((i + 1))
    done
    echo "kind-probe: $n command(s), not run. --yes runs them, each on a fresh fixture, and each starts a model." >&2
    return 0
  fi
  command -v claude >/dev/null 2>&1 || { echo "kind-probe: claude not on PATH" >&2; return 1; }
  [ -n "$out" ] || out="${TMPDIR:-/tmp}/kind-probe-$fx-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$out" || return 1
  i=1; bad=0
  while [ "$i" -le "$n" ]; do
    d="$out/run-$i"
    scaffold "$fx" "$d/proj" || return 1
    (cd "$d/proj" && claude --plugin-dir "$plugin" --model sonnet \
      --allowedTools Read Glob Grep Bash Write Edit Skill Agent --output-format json \
      -p "$request" < /dev/null > "$d/result.json" 2> "$d/stderr.txt") || bad=1
    if [ "$fx" = migration ]; then  # the plan is the session's reply: the JSON result's text
      python3 -I -c 'import json, sys
text = json.load(open(sys.argv[1])).get("result")
if not isinstance(text, str): sys.exit(1)
sys.stdout.write(text if text.endswith("\n") else text + "\n")' "$d/result.json" > "$d/plan.md" 2>/dev/null \
        || { rm -f "$d/plan.md"; echo "kind-probe: run $i: no reply text in $d/result.json, so no plan.md" >&2; bad=1; }
    fi
    i=$((i + 1))
  done
  echo "kind-probe: $n run(s) kept in $out" >&2
  return "$bad"
}

case "${1:-}" in
  --scaffold)
    [ $# -eq 3 ] || usage
    scaffold "$2" "$3" ;;
  --run)
    [ $# -ge 2 ] || usage
    shift; run "$@" ;;
  *) usage ;;
esac
