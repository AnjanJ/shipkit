"""Orders: create, store and total them.

All amounts are integer cents. Orders are kept in one JSON file.
"""

import json
from pathlib import Path

from app.billing import apply_tax

ORDERS_FILE = Path("data/orders.json")


def load_orders(path=ORDERS_FILE):
    """Return every stored order, oldest first."""
    path = Path(path)
    if not path.exists():
        return []
    return json.loads(path.read_text())


def save_orders(orders, path=ORDERS_FILE):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(orders, indent=2))


def create_order(customer, items, region, path=ORDERS_FILE):
    """Store a new order and return it.

    `items` is a list of {"sku": str, "qty": int, "price_cents": int}.
    """
    if not items:
        raise ValueError("an order needs at least one item")
    orders = load_orders(path)
    order = {
        "id": len(orders) + 1,
        "customer": customer,
        "items": items,
        "region": region,
        "status": "new",
    }
    orders.append(order)
    save_orders(orders, path)
    return order


def order_subtotal(order):
    return sum(item["qty"] * item["price_cents"] for item in order["items"])


def order_total(order):
    """Subtotal plus tax for the order's region, in cents."""
    return apply_tax(order_subtotal(order), order["region"])
