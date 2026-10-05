import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.billing import ChargeFailed, apply_tax
from app.jobs.retry import MAX_RETRIES, retry_charge
from app.orders import create_order, load_orders, order_total


class OrdersTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.TemporaryDirectory()
        self.path = Path(self.dir.name) / "orders.json"

    def tearDown(self):
        self.dir.cleanup()

    def test_a_created_order_can_be_loaded_again(self):
        items = [{"sku": "mug", "qty": 2, "price_cents": 1000}]
        order = create_order("ada", items, "CA", path=self.path)
        self.assertEqual(load_orders(self.path), [order])

    def test_an_order_with_no_items_is_rejected(self):
        with self.assertRaises(ValueError):
            create_order("ada", [], "CA", path=self.path)

    def test_total_includes_the_regions_tax(self):
        items = [{"sku": "mug", "qty": 2, "price_cents": 1000}]
        order = create_order("ada", items, "CA", path=self.path)
        self.assertEqual(order_total(order), 2145)

    def test_an_unknown_region_pays_no_tax(self):
        self.assertEqual(apply_tax(2000, "ZZ"), 2000)


class AlwaysFails:
    def __init__(self):
        self.calls = 0

    def charge(self, customer, amount_cents):
        self.calls += 1
        raise RuntimeError("declined")


class RetryTest(unittest.TestCase):
    def test_a_failing_charge_is_tried_a_limited_number_of_times(self):
        gateway = AlwaysFails()
        with self.assertRaises(ChargeFailed):
            retry_charge({"customer": "ada"}, 2145, gateway, sleep=lambda s: None)
        self.assertEqual(gateway.calls, MAX_RETRIES)


if __name__ == "__main__":
    unittest.main()
