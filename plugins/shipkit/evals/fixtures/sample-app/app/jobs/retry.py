"""Retry a charge that failed.

Waits longer after each failure and gives up after MAX_RETRIES attempts.
"""

import time

from app.billing import ChargeFailed, charge

MAX_RETRIES = 5
BASE_DELAY_SECONDS = 2


def retry_charge(order, amount_cents, gateway, sleep=time.sleep):
    """Try the charge up to MAX_RETRIES times. Returns the receipt number.

    Raises ChargeFailed if every attempt fails.
    """
    last_error = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            return charge(order, amount_cents, gateway)
        except ChargeFailed as exc:
            last_error = exc
            if attempt < MAX_RETRIES:
                sleep(BASE_DELAY_SECONDS * attempt)
    raise ChargeFailed(f"gave up after {MAX_RETRIES} attempts: {last_error}")
