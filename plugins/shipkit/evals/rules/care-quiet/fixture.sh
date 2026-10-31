#!/bin/bash
# The shared fixture, committed, then work the request never mentions left uncommitted.
# Runs only when `claude plugin eval` is given --scaffold (scripts/evals.sh passes it).
cp -R "$(cd "$(dirname "$0")" && pwd)/../../fixtures/sample-app/." . || exit 1
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
printf '\n\ndef cancel_order(order):\n    order["status"] = "cancelled"\n' >> app/orders.py
printf '"""Refunds, half done."""\n\n\ndef refund(order, cents):\n    return min(cents, order["paid_cents"])\n' > app/refunds.py
