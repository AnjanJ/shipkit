# PROJECT_MAP — sample-app

> Map generated at commit `a1b2c3d` on `main`. Refresh with `/shipkit:map`.

## What this project is

A tiny order service: it takes orders, adds tax, and charges the customer.

## Stack

- Python 3.9+, standard library only (`pyproject.toml` lists no dependencies)
- Tests: `unittest`, run with `python3 -m unittest discover -s tests`

## Layout (where things live)

| Path | What it holds |
|------|---------------|
| `app/orders.py` | Create, store, load and total orders |
| `app/billing.py` | Tax (`apply_tax`) and charging (`charge`) |
| `app/jobs/retry.py` | Retries a failed charge; the retry limit is set here |
| `tests/test_orders.py` | Tests for orders, tax and the retry job |

## Core modules / domains

- **Orders** — `app/orders.py`. `create_order` stores an order; `order_total` returns the
  subtotal plus tax.
- **Billing** — `app/billing.py`. `apply_tax` adds the region's tax; `charge` charges the
  customer through a gateway object passed in by the caller.
- **Jobs** — `app/jobs/retry.py`. `retry_charge` repeats a failed charge with a growing delay.

## Data model

Orders are stored in SQLite, in the `orders` table of `data/orders.db`. Each order has an id,
a customer, a list of items, a region and a status. All amounts are integer cents.

## Primary flows

1. `create_order` stores the order.
2. `order_total` computes what to charge: the subtotal, then `apply_tax` for the region.
3. `charge` charges the customer; on failure, `retry_charge` tries again.

## Gotchas

- Tax rates are in basis points, not percent.
- An unknown region pays no tax; it does not raise.
