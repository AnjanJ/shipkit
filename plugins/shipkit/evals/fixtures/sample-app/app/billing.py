"""Billing: tax and charging.

The payment gateway is passed in by the caller. This module only needs it to have
a `charge(customer, amount_cents)` method that returns a receipt number or raises.
"""

# Tax rates in basis points (1 bp = 0.01%), by region code.
TAX_RATES_BP = {
    "CA": 725,
    "NY": 400,
    "TX": 625,
}
DEFAULT_TAX_BP = 0


class ChargeFailed(Exception):
    """The gateway refused or could not complete the charge."""


def apply_tax(subtotal_cents, region):
    """Return the subtotal with the region's tax added, rounded to the nearest cent."""
    rate_bp = TAX_RATES_BP.get(region, DEFAULT_TAX_BP)
    tax_cents = (subtotal_cents * rate_bp + 5000) // 10000
    return subtotal_cents + tax_cents


def charge(order, amount_cents, gateway):
    """Charge the order's customer. Returns the receipt number."""
    try:
        return gateway.charge(order["customer"], amount_cents)
    except Exception as exc:
        raise ChargeFailed(str(exc)) from exc
