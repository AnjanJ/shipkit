#!/bin/bash
# <gap|clean>: a spec, no tasks or code; gap's REQ-3 term is defined nowhere
cp -R "$(cd "$(dirname "$0")" && pwd)/../fixtures/sample-app/." . || exit 1
d=.shipkit/specs/refunds; mkdir -p $d
w='more than 30 days after `order["charged_at"]`'; [ "$1" = gap ] && w='after the grace window'
cat > $d/spec.md <<'EOF'
# Spec: Refunds

> Spec not yet accepted.
> Status: draft

## Purpose
`app/refunds.py`: `refund(order, amount_cents, charged_cents, today, gateway)` and the
exception `RefundRejected`. `today` and `order["charged_at"]` are `datetime.date`s.

## Requirements (EARS)
- **REQ-1.** When `refund` is called, it shall return `gateway.refund(order["customer"], amount_cents)`.
- **REQ-2.** If `amount_cents` is larger than `charged_cents`, then `refund` shall raise `RefundRejected` and not call the gateway.
- **REQ-3.** If `today` is @W@, then `refund` shall raise `RefundRejected` and not call the gateway.
EOF
sed -i.b "s/@W@/$w/" $d/spec.md && rm $d/spec.md.b
printf '# Design: Refunds\n\n## Decision: Refunds live in `app/refunds.py`   (→ REQ-1)\n' > $d/design.md
git init -q . && git add -A && git -c user.email=e@x -c user.name=e commit -qm init
