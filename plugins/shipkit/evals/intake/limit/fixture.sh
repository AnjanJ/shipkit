#!/bin/bash
# Copies the shared fixture into the run's empty workspace, gives it a product file with one
# non-goal and a refunds goal, and makes it a git repository. Runs only with --scaffold.
cp -R "$(cd "$(dirname "$0")" && pwd)/../../fixtures/sample-app/." . || exit 1
mkdir -p .shipkit && cat > .shipkit/product.md <<'PRODUCT'
# Product: sample-app

> Product reviewed on 2026-10-01.

## One line
A small order service that takes orders, adds tax and charges the card, for small online shops.

## Users
- Owners of small online shops who take card payments.

## Goals this quarter
- Cut failed charges — metric: share of charges that fail; target: under 2%; by: 2026-12-31
- Ship refunds — metric: share of refunds needing no manual step; target: 95%; by: 2026-11-15

## Non-goals
- No multi-currency support. Prices and charges are in one currency.
- No storefront or cart.

## Metrics that matter
- Charge failure rate

## Constraints
- Python standard library only.

## Now / Next / Later
- **Now:** the retry job.
- **Next:** refunds.
- **Later:** a proper database.
PRODUCT
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
