#!/bin/bash
# sample-app plus a tests/support.py helper the new test should reuse, committed, with
# rules/testing.md under test (lib/with-rule.sh; the hook delivers it). --scaffold only.
HERE=$(cd "$(dirname "$0")" && pwd)
cp -R "$HERE/../../fixtures/sample-app/." . || exit 1
cat > tests/support.py <<'PY'
"""Shared test helpers. Look here before writing a new one."""
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.orders import create_order  # noqa: E402

MUG = {"sku": "mug", "qty": 2, "price_cents": 1000}


def make_order(region="CA", items=None, path=None):
    """Create and store an order like the ones in test_orders.py; a temp file if no path."""
    if path is None:
        path = Path(tempfile.mkdtemp()) / "orders.json"
    return create_order("ada", items or [MUG], region, path=path)
PY
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
sh "$HERE/../../lib/with-rule.sh" testing
