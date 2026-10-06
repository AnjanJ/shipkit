#!/bin/bash
# A shipped refunds feature whose spec never said a refund may not exceed the charge — and
# whose code, faithfully, does not check. Runs only with --scaffold.
cp -R "$(cd "$(dirname "$0")" && pwd)/../../fixtures/sample-app/." . || exit 1
mkdir -p .shipkit/specs/refunds
cat > .shipkit/specs/refunds/spec.md <<'SPEC'
# Spec: Refunds

> Spec accepted at commit `a1b2c3d` on main.
> Status: shipped
> Paths: app/refunds.py, tests/test_refunds.py

## Purpose
A charged order can be refunded through the payment gateway.

## Requirements (EARS)
- **REQ-1.** When a refund is requested, the system shall ask the gateway to refund the
  amount and return the gateway's refund number.
- **REQ-2.** If the gateway refuses the refund, then the system shall raise `RefundFailed`.

## Out of scope
- Partial-refund history.
SPEC
cat > .shipkit/specs/refunds/tasks.md <<'SPEC'
# Tasks: Refunds

- [x] **T1** Refund through the gateway → REQ-1, REQ-2
  - Files: app/refunds.py, tests/test_refunds.py
  - Test: tests/test_refunds.py::test_refund_returns_the_gateways_refund_number
  - After: none
  - Done when: `python3 -m unittest discover -s tests` → all pass
SPEC
cat > app/refunds.py <<'PY'
"""Refunds: give money back for a charged order."""


class RefundFailed(Exception):
    """The gateway refused or could not complete the refund."""


def refund(order, amount_cents, charged_cents, gateway):
    """Refund part or all of a charge. Returns the gateway's refund number."""
    try:
        return gateway.refund(order["customer"], amount_cents)
    except Exception as exc:
        raise RefundFailed(str(exc)) from exc
PY
cat > tests/test_refunds.py <<'PY'
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.refunds import RefundFailed, refund


class Gateway:
    def __init__(self, fail=False):
        self.fail = fail

    def refund(self, customer, amount_cents):
        if self.fail:
            raise RuntimeError("refused")
        return "rf_1"


class RefundTest(unittest.TestCase):
    # refunds/REQ-1
    def test_refund_returns_the_gateways_refund_number(self):
        self.assertEqual(refund({"customer": "ada"}, 500, 2000, Gateway()), "rf_1")

    # refunds/REQ-2
    def test_a_refused_refund_raises(self):
        with self.assertRaises(RefundFailed):
            refund({"customer": "ada"}, 500, 2000, Gateway(fail=True))
PY
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
