#!/bin/bash
# escape/missing-req's tree, after that escape was handled.
bash "$(cd "$(dirname "$0")" && pwd)/../missing-req/fixture.sh" || exit 1
sed -i.bak '/^- \*\*REQ-2/a\
- **REQ-3.** If the refund amount is larger than the amount charged, then the system shall raise `RefundFailed` and shall not call the gateway.
' .shipkit/specs/refunds/spec.md
sed -i.bak 's|^    try:$|    if amount_cents > charged_cents:\
        raise RefundFailed("refund is larger than the charge")\
&|' app/refunds.py
cat >> tests/test_refunds.py <<'PY'

    # refunds/REQ-3
    def test_a_refund_above_the_charge_raises(self):
        with self.assertRaises(RefundFailed):
            refund({"customer": "ada"}, 2500, 2000, Gateway())
PY
mkdir .shipkit/escapes
cat > .shipkit/escapes/0001-refund-above-charge.md <<'SPEC'
# Escape 0001: A refund above the charge was paid out

> Recorded on 2026-10-20.

## What happened
A refund of 25.00 on a charge of 20.00 was paid out.

## Cause
`requirement missing` — the spec said nothing of a refund above the charge.

## Spec
`.shipkit/specs/refunds/`

## Fix
REQ-3, and the test that cites it.
SPEC
rm -f .shipkit/specs/refunds/*.bak app/*.bak
git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "refuse a refund above the charge"
