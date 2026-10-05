#!/bin/bash
# Builds a small finished-looking feature for the reviewer to check: the shared fixture as the
# base (tagged `base`), then one commit that adds a `refunds` spec with three requirements and
# the code for them. COMPLETE=no leaves REQ-2 with no code and no test. Runs only with --scaffold.
COMPLETE=no
cp -R "$(cd "$(dirname "$0")" && pwd)/../../fixtures/sample-app/." . || exit 1
g() { git -c user.email=eval@example.com -c user.name=eval "$@"; }
git init -q . && git add -A && g commit -q -m "initial commit" && git tag base
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
printf '\n## Refunds\n\nCall `app.refunds.refund(order, amount_cents, charged_cents, gateway)`; it returns the refund number.\n' >> README.md
if [ "$COMPLETE" = yes ]; then
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
if [ "$COMPLETE" = yes ]; then
cat >> tests/test_refunds.py <<'PY'

    # refunds/REQ-2
    def test_refund_over_the_charge_is_rejected(self):
        gateway = Gateway()
        with self.assertRaises(RefundRejected):
            refund({"customer": "ada"}, 2500, 2000, gateway)
        self.assertEqual(gateway.calls, 0)
PY
fi
git add -A && g commit -q -m "add refunds"
