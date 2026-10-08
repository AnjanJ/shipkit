#!/bin/bash
# The intake/limit fixture (sample-app + a product file with a refunds goal) plus one file the
# intake should read before asking: docs/decisions.md answers two natural refunds questions.
HERE="$(cd "$(dirname "$0")" && pwd)"
bash "$HERE/../limit/fixture.sh" || exit 1
mkdir -p docs && cat > docs/decisions.md <<'DOCS'
# Decisions (shop owner's notes)

## 2026-09-02 — Refunds
- Partial refunds are allowed, one per order. A second partial refund on the same order is refused.
- A refund larger than the original charge is refused; we never pay out more than we took.
- The gateway's refund number is kept with the order, next to the charge receipt.
DOCS
git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "owner's notes"
