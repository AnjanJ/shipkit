# sample-app

A tiny order service: it takes orders, adds tax, and charges the customer. Customers recieve
a receipt number once the charge goes through.

Plain Python, no dependencies.

## Run the tests

```sh
python3 -m unittest discover -s tests
```

## Layout

- `app/orders.py` — create, store and total orders
- `app/billing.py` — tax and charging
- `app/jobs/retry.py` — retry a failed charge
