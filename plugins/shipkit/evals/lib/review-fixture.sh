#!/bin/bash
# review-fixture.sh <complete|missing|rejected|unbuilt>: a small finished-looking feature for the
# reviewer to check,
# built by each reviewer case's fixture.sh: the shared fixture as the base (tagged `base`), then one
# commit that adds a `refunds` spec with three requirements and the code for them. `missing` leaves
# REQ-2 with no code and no test. `rejected` meets every requirement and does what a live decision
# turned down. `unbuilt` adds a decision a later task will build, and a superseded one the code does
# not follow. Cites: decisions-bind/REQ-13
# From real misses (Sprint 32): `helper` tests REQ-2 on a helper that `refund` never calls.
# `skipped` skips REQ-2's test and `comment` cites REQ-2 in a comment in the code with no test.
# `weakened` rewrites REQ-2 to match the code and `waived` excuses it from a test: both commit
# the spec first, as it was written, so the edit has an earlier form to be compared with.
VARIANT=${1:-complete}
case "$VARIANT" in missing|helper) BARE=1 ;; *) BARE= ;; esac
cp -R "$(cd "$(dirname "$0")" && pwd)/../fixtures/sample-app/." . || exit 1
g() { git -c user.email=eval@example.com -c user.name=eval "$@"; }
git init -q . && git add -A && g commit -q -m "initial commit" && git tag base
# Held out (Sprint 32): `notes-helper` is the helper-only miss on another feature, a notes export,
# so that it shares no word with the variants below. The requirement it breaks is REQ-1.
if [ "${VARIANT#notes-}" != "$VARIANT" ]; then
mkdir -p .shipkit/specs/notes-export
cat > .shipkit/specs/notes-export/spec.md <<'SPEC'
# Spec: Notes export

> Spec accepted at commit `base` on main.
> Status: open
> Paths: app/notes.py, tests/test_notes.py

## Purpose
A user's notes can be exported as lines of text.

## Requirements (EARS)
- **REQ-1.** If a note is marked private, then the export shall leave it out.
- **REQ-2.** When an export is requested, the system shall return one line for each note,
  its title first.
SPEC
cat > .shipkit/specs/notes-export/design.md <<'SPEC'
# Design: Notes export

## Decision: The export is a function in `app/notes.py`   (→ REQ-1, REQ-2)

**Decision.** A function, not a command-line tool.
**Falsifiability.** We would reverse this if a second caller needs a file on disk.
SPEC
cat > .shipkit/specs/notes-export/tasks.md <<'SPEC'
# Tasks: Notes export

- [x] **T1** Export the notes that may be shared → REQ-1, REQ-2
  - Files: app/notes.py, tests/test_notes.py
  - Test: tests/test_notes.py::test_a_private_note_is_left_out
  - After: none
  - Done when: `python3 -m unittest discover -s tests` → all pass
SPEC
cat > app/notes.py <<'PY'
"""Notes: export a user's notes as text."""


def is_shareable(note):
    """A note may be exported unless it is marked private."""
    return not note.get("private")


def export_notes(notes):
    """One line for each note, its title first."""
    return [f'{n["title"]}: {n["body"]}' for n in notes]
PY
cat > tests/test_notes.py <<'PY'
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.notes import export_notes, is_shareable


class NotesExportTest(unittest.TestCase):
    # notes-export/REQ-2
    def test_one_line_for_each_note(self):
        self.assertEqual(export_notes([{"title": "Milk", "body": "two litres"}]), ["Milk: two litres"])

    # notes-export/REQ-1
    def test_a_private_note_is_left_out(self):
        self.assertFalse(is_shareable({"title": "Pin", "body": "1234", "private": True}))
PY
git add -A && g commit -q -m "add the notes export"; exit
fi
mkdir -p .shipkit/specs/refunds
cat > .shipkit/specs/refunds/spec.md <<'SPEC'
# Spec: Refunds

> Spec accepted at commit `base` on main.
> Status: open
> Paths: app/refunds.py, tests/test_refunds.py, README.md

## Purpose
A charged order can be refunded through the payment gateway.

## Requirements (EARS)
- **REQ-1.** When a refund is requested, the system shall ask the gateway to refund the
  amount and return the gateway's refund number.
- **REQ-2.** If the refund amount is larger than the amount charged, then the system shall
  raise `RefundRejected` and shall not call the gateway.
- **REQ-3.** The README shall say how to refund an order. [untested: prose, verified by reading]

## Out of scope
- Partial-refund history.
SPEC
cat > .shipkit/specs/refunds/design.md <<'SPEC'
# Design: Refunds

## Decision: Refunds live in their own module   (→ REQ-1, REQ-2)

**Decision.** `app/refunds.py`, not `app/billing.py`.
**Falsifiability.** We would reverse this if the module stays under 20 lines for a year.
SPEC
[ "$VARIANT" = rejected ] && cat >> .shipkit/specs/refunds/design.md <<'SPEC'

## Decision: A gateway error reaches the caller   (→ REQ-1)

**Alternatives.**
1. Let the gateway's exception propagate from `refund`.
2. Catch it in `refund` and return `None`.

**Decision.** We chose option 1: a swallowed failure looks like a refund that happened.
**Falsifiability.** We would reverse this if callers retry more often than they report.
SPEC
[ "$VARIANT" = unbuilt ] && cat >> .shipkit/specs/refunds/design.md <<'SPEC'

## Decision: A refund writes an audit line through `app/audit.py`   (→ REQ-1)

**Alternatives.**
1. `app/audit.py`, called from `refund`.
2. A log line in the gateway adapter.

**Decision.** We chose option 1. T4 builds it.
**Falsifiability.** We would reverse this if a second caller needs no audit line.

## Decision: Refunds live in `app/billing.py`   (→ REQ-1)

> **Superseded on 2026-10-05** by "Refunds live in their own module".

**Decision.** `app/billing.py`.
SPEC
cat > .shipkit/specs/refunds/tasks.md <<'SPEC'
# Tasks: Refunds

- [x] **T1** Refund through the gateway → REQ-1
  - Files: app/refunds.py, tests/test_refunds.py
  - Test: tests/test_refunds.py::test_refund_returns_the_gateways_refund_number
  - After: none
  - Done when: `python3 -m unittest discover -s tests` → all pass
- [x] **T2** Reject a refund larger than the charge → REQ-2
  - Files: app/refunds.py, tests/test_refunds.py
  - Test: tests/test_refunds.py::test_refund_over_the_charge_is_rejected
  - After: T1
  - Done when: `python3 -m unittest discover -s tests` → all pass
- [x] **T3** Say how to refund in the README → REQ-3
  - Files: README.md
  - Test: none (prose)
  - After: none
  - Done when: the README has a Refunds section
SPEC
[ "$VARIANT" = unbuilt ] && cat >> .shipkit/specs/refunds/tasks.md <<'SPEC'
- [ ] **T4** Write the audit line → REQ-1
  - Files: app/audit.py, app/refunds.py
  - Test: tests/test_refunds.py::test_refund_writes_an_audit_line
  - After: T1
  - Done when: `python3 -m unittest discover -s tests` → all pass
SPEC
case "$VARIANT" in weakened|waived) git add -A && g commit -q -m "spec the refunds" ;; esac
printf '\n## Refunds\n\nCall `app.refunds.refund(order, amount_cents, charged_cents, gateway)`; it returns the refund number.\n' >> README.md
if [ -z "$BARE" ]; then
cat > app/refunds.py <<'PY'
"""Refunds: give money back for a charged order."""


class RefundRejected(Exception):
    """The refund is not allowed."""


def refund(order, amount_cents, charged_cents, gateway):
    """Refund part or all of a charge. Returns the gateway's refund number."""
    if amount_cents > charged_cents:
        raise RefundRejected("refund is larger than the charge")
    return gateway.refund(order["customer"], amount_cents)
PY
[ "$VARIANT" = rejected ] && sed -i.bak 's/^    return gateway\.refund(.*$/    try:\
        return gateway.refund(order["customer"], amount_cents)\
    except Exception:\
        return None/' app/refunds.py && rm app/refunds.py.bak
else
cat > app/refunds.py <<'PY'
"""Refunds: give money back for a charged order."""


class RefundRejected(Exception):
    """The refund is not allowed."""


def refund(order, amount_cents, charged_cents, gateway):
    """Refund part or all of a charge. Returns the gateway's refund number."""
    return gateway.refund(order["customer"], amount_cents)
PY
fi
[ "$VARIANT" = helper ] && cat >> app/refunds.py <<'PY'


def check_amount(amount_cents, charged_cents):
    """Raise RefundRejected when a refund is larger than the charge."""
    if amount_cents > charged_cents:
        raise RefundRejected("refund is larger than the charge")
PY
cat > tests/test_refunds.py <<'PY'
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.refunds import RefundRejected, refund


class Gateway:
    def __init__(self):
        self.calls = 0

    def refund(self, customer, amount_cents):
        self.calls += 1
        return "rf_1"


class RefundTest(unittest.TestCase):
    # refunds/REQ-1
    def test_refund_returns_the_gateways_refund_number(self):
        self.assertEqual(refund({"customer": "ada"}, 500, 2000, Gateway()), "rf_1")
PY
if [ "$VARIANT" = helper ]; then
sed -i.bak 's/RefundRejected, refund/RefundRejected, check_amount, refund/' tests/test_refunds.py && rm tests/test_refunds.py.bak
cat >> tests/test_refunds.py <<'PY'

    # refunds/REQ-2
    def test_refund_over_the_charge_is_rejected(self):
        with self.assertRaises(RefundRejected):
            check_amount(2500, 2000)
PY
elif [ "$VARIANT" = weakened ]; then
cat >> tests/test_refunds.py <<'PY'

    # refunds/REQ-2
    def test_refund_over_the_charge_is_cut_to_the_charge(self):
        sent = []

        class Recorder(Gateway):
            def refund(self, customer, amount_cents):
                sent.append(amount_cents)

        refund({"customer": "ada"}, 2500, 2000, Recorder())
        self.assertEqual(sent, [2000])
PY
elif [ -z "$BARE" ] && [ "$VARIANT" != comment ] && [ "$VARIANT" != waived ]; then
cat >> tests/test_refunds.py <<'PY'

    # refunds/REQ-2
    def test_refund_over_the_charge_is_rejected(self):
        gateway = Gateway()
        with self.assertRaises(RefundRejected):
            refund({"customer": "ada"}, 2500, 2000, gateway)
        self.assertEqual(gateway.calls, 0)
PY
fi
S=.shipkit/specs/refunds/spec.md
case "$VARIANT" in
skipped) sed -i.bak 's|^    # refunds/REQ-2$|&\
    @unittest.skip("flaky on CI")|' tests/test_refunds.py ;;
comment) sed -i.bak 's|^    if amount_cents > charged_cents:$|    # refunds/REQ-2\
&|' app/refunds.py ;;
weakened) sed -i.bak 's|^  raise `RefundRejected` and shall not call the gateway\.$|  refund the amount charged.|' $S
  sed -i.bak -e '/^    if amount_cents > charged_cents:$/d' -e 's|^        raise RefundRejected(.*$|    amount_cents = min(amount_cents, charged_cents)|' app/refunds.py ;;
waived) sed -i.bak 's|^  raise `RefundRejected` and shall not call the gateway\.$|& [untested: the gateway refuses it too]|' $S ;;
esac
rm -f app/*.bak tests/*.bak .shipkit/specs/refunds/*.bak
git add -A && g commit -q -m "add refunds"
