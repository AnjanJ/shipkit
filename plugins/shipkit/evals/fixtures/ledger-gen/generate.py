#!/usr/bin/env python3
"""The XL eval fixture: `ledger`, 200+ files and 25+ commits, written into the CURRENT (empty)
directory. Deterministic (fixed dates, no clock); standard library only. `--wip` makes every
commit message "wip" (same files, same trees); `--no-map` omits
PROJECT_MAP.md, which is left untracked so both arms share one git history. Facts: ../FACTS-XL.md."""
import os, subprocess, sys

NO_MAP = "--no-map" in sys.argv[1:]
WIP = "--wip" in sys.argv[1:]  # every commit message "wip": the same trees, a log that says nothing (second-traps/REQ-12)
PKGS = [("api", "Request"), ("auth", "Session"), ("billing", "Invoice"), ("inventory", "Stock"),
        ("jobs", "Job"), ("notifications", "Message"), ("orders", "Order"), ("reports", "Report")]
GIT = ["git", "-c", "user.name=ledger", "-c", "user.email=dev@ledger.example", "-c", "commit.gpgsign=false"]
n_commits = 0


def w(path, text):
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(path, "w") as f:
        f.write(text.lstrip("\n"))


def commit(msg):
    global n_commits
    n_commits += 1
    day = f"2025-01-{6 + n_commits // 4:02d}T{9 + n_commits % 4 * 3:02d}:00:00+00:00"
    env = dict(os.environ, GIT_AUTHOR_DATE=day, GIT_COMMITTER_DATE=day)
    subprocess.run(GIT + ["add", "-A"], check=True, env=env)
    subprocess.run(GIT + ["commit", "-q", "-m", "wip" if WIP else msg], check=True, env=env)


# --- module templates: {p} package, {e} entity, {l} entity lower-cased -------------------
MODS = {
    "models": '''
from dataclasses import dataclass, field

@dataclass
class {e}:
    id: str
    account_id: str
    status: str = "new"
    attributes: dict = field(default_factory=dict)
''',
    "errors": '''
class {e}Error(Exception):
    """Base error for the {p} package."""

class {e}NotFound({e}Error):
    pass

class Invalid{e}({e}Error):
    pass
''',
    "schemas": '''
from .models import {e}

def to_dict({l}):
    return {{"id": {l}.id, "account_id": {l}.account_id, "status": {l}.status, **{l}.attributes}}

def from_dict(data):
    extra = {{k: v for k, v in data.items() if k not in ("id", "account_id", "status")}}
    return {e}(data["id"], data["account_id"], data.get("status", "new"), extra)
''',
    "validators": '''
from .errors import Invalid{e}

def validate_{l}({l}):
    if not {l}.id or not {l}.account_id:
        raise Invalid{e}("id and account_id are required")
    return {l}
''',
    "repository": '''
import json
from app.db import connect
from .errors import {e}NotFound
from .schemas import to_dict, from_dict

class {e}Repository:
    table = "{p}"

    def get(self, id):
        row = connect().execute(f"select body from {{self.table}} where id = ?", (id,)).fetchone()
        if row is None:
            raise {e}NotFound(id)
        return from_dict(json.loads(row[0]))

    def save(self, {l}):
        connect().execute(f"insert or replace into {{self.table}} (id, body) values (?, ?)",
                          ({l}.id, json.dumps(to_dict({l})))).connection.commit()
        return {l}
''',
    "service": '''
from .repository import {e}Repository
from .validators import validate_{l}
from .models import {e}

class {e}Service:
    def __init__(self, repo=None):
        self.repo = repo or {e}Repository()

    def create(self, id, account_id, **attributes):
        return self.repo.save(validate_{l}({e}(id, account_id, attributes=attributes)))
''',
    "handlers": '''
from .service import {e}Service
from .schemas import to_dict
from .errors import {e}Error

def handle_create(payload, service=None):
    try:
        return 201, to_dict((service or {e}Service()).create(**payload))
    except {e}Error as exc:
        return 400, {{"error": str(exc)}}
''',
    "utils": '''
def chunked(items, size):
    for i in range(0, len(items), size):
        yield items[i:i + size]
''',
}
TEST = '''
import unittest
from app.{p} import {m}

class Test{M}(unittest.TestCase):
    def test_module_imports(self):
        self.assertTrue(hasattr({m}, "__name__"))
'''

# --- the files that carry the planted facts (see ../FACTS-XL.md) ---------------------
STORE_JSON = '''
"""Orders: one JSON file, rewritten on every save."""
import json
from pathlib import Path

ORDERS_FILE = Path("data/orders.json")

def load_all():
    return json.loads(ORDERS_FILE.read_text()) if ORDERS_FILE.exists() else {}

def save(order):
    orders = load_all()
    orders[order["id"]] = order
    ORDERS_FILE.write_text(json.dumps(orders, indent=2))
'''
STORE_SQLITE = '''
"""Orders: the `orders` table in data/ledger.db (see app/db.py)."""
import json
from app.db import connect

def load_all():
    return {r[0]: json.loads(r[1]) for r in connect().execute("select id, body from orders")}

def save(order):
    connect().execute("insert or replace into orders (id, body) values (?, ?)",
                      (order["id"], json.dumps(order))).connection.commit()
'''
DB = '''
"""One SQLite connection per process; every repository uses connect()."""
import sqlite3
from pathlib import Path

DB_FILE = Path("data/ledger.db")
_con = None

def connect():
    global _con
    if _con is None:
        DB_FILE.parent.mkdir(exist_ok=True)
        _con = sqlite3.connect(DB_FILE)%s
    return _con
'''
WAL = '''
        _con.execute("pragma journal_mode=wal")  # readers no longer block the writer'''
POLICY = '''
"""Retry policy for background jobs; the runner enforces RETRY_CAP."""
RETRY_CAP = %d
BASE_DELAY_SECONDS = 2

def should_retry(attempt):
    return attempt < RETRY_CAP
'''
LEGACY = '''
"""Pre-policy constants. Only scripts/migrate_jobs.py reads this, for rows older than the policy module."""
MAX_RETRIES = 3  # the old cap; superseded by app.jobs.policy.RETRY_CAP
LEGACY_QUEUE = "jobs_v1"
'''
CLIENT = '''
"""Outbound HTTP to partners. Unrelated to background-job retries."""
MAX_RETRIES = 2  # a partner call is retried once; the job runner has its own cap
TIMEOUT_SECONDS = 10
'''
TAX = '''
"""VAT. Rates are in basis points: 2000 is 20%."""
RATES_BP = {"GB": 2000, "DE": 1900, "FR": 2000, "IE": 2300}

def apply_vat(net_cents, country):
    return net_cents + net_cents * RATES_BP.get(country, 0) // 10000
'''
CHECKOUT = '''
from app.billing.tax import apply_vat
from .store import save

def checkout(order):
    subtotal = sum(line["cents"] * line["qty"] for line in order["lines"])
    order["total_cents"] = apply_vat(subtotal, order["country"])
    order["status"] = "placed"
    save(order)
    return order
'''
FORECAST = '''
"""Quarterly forecasts. estimate_vat projects; it never charges."""
def estimate_vat(projected_net_cents, blended_rate_bp=1950):
    return projected_net_cents * blended_rate_bp // 10000
'''
CACHE = '''
"""Inventory counts, cached in-process: one dict per worker, emptied by a restart."""
_counts = {}

def get_count(sku):
    return _counts.get(sku)

def set_count(sku, count):
    _counts[sku] = count
'''
MAILER = '''
"""Outbound email. The concrete mailer is injected at deploy time and never named here."""
class Mailer:
    def send(self, to, subject, body):
        raise NotImplementedError
'''
MAP = '''
# PROJECT_MAP — ledger

> Map generated at commit `%s` on `main`. Refresh with `/shipkit:map`.

## What this project is

A ledger service: orders, invoices with VAT, stock, background jobs with retries, quarterly
reports. Plain Python, standard library only.

## Layout (where things live)

| Path | What it holds |
|------|---------------|
| `app/db.py` | The SQLite connection every repository uses |
| `app/<package>/` | One package per domain: models, repository, service, validators, handlers |
| `app/jobs/policy.py` | The retry policy the job runner enforces |
| `app/billing/tax.py` | VAT (`apply_vat`), rates in basis points |
| `app/inventory/` | Stock, import adapters, the count cache |
| `app/notifications/mailer.py` | The abstract `Mailer`; the concrete one is injected at deploy time |
| `migrations/`, `tests/` | Numbered SQL migrations; `unittest` tests mirroring `app/` |

## Data model

Every domain stores JSON bodies in its own SQLite table, keyed by id, through `app.db.connect()`.
Inventory counts are cached in Redis, keyed by SKU, so that every worker sees the same number.

## Evolution

Orders were first a JSON file rewritten whole on every save; two workers writing at once
corrupted it twice in one week, so orders moved to SQLite, and WAL was enabled soon after so
readers stop blocking the writer. The job retry cap went from 5 to 7 for the partner-timeout
tail; retries then moved to their own policy module, and the old `MAX_RETRIES` stays only for
the jobs migration script.

## Gotchas

- VAT rates are basis points, not percent; an unknown country pays no VAT and does not raise.
- `app/api/client.py` has its own `MAX_RETRIES`, for partner calls, not jobs.
- The mailer is abstract on purpose: no provider is named anywhere in this repository.
'''
SPECIAL = {"api": [("client", CLIENT)], "jobs": [("policy", POLICY % 5)], "billing": [("tax", TAX)],
           "orders": [("store", STORE_JSON), ("checkout", CHECKOUT)], "reports": [("forecast", FORECAST)],
           "inventory": [("cache", CACHE)], "notifications": [("mailer", MAILER)]}


def many(pattern, names, body):
    for n in names.split():
        w(pattern % n, body % n)


def main():
    if os.listdir("."):
        sys.exit("generate.py: the current directory must be empty")
    subprocess.run(GIT + ["init", "-q", "-b", "main", "."], check=True)
    w("README.md", "# ledger\n\nOrders, invoices, stock, jobs, reports. Standard library only.\n\n    make test\n")
    w("pyproject.toml", '[project]\nname = "ledger"\nversion = "0.9.0"\nrequires-python = ">=3.9"\ndependencies = []\n')
    w(".gitignore", "data/\n__pycache__/\n")
    w("Makefile", "test:\n\tpython3 -m unittest discover -s tests\n")
    w("app/__init__.py", "")
    w("app/config.py", 'import os\n\nDATA_DIR = os.environ.get("LEDGER_DATA", "data")\n')
    w("app/db.py", DB % "")
    commit("chore: scaffold the ledger service")
    for p, e in PKGS:
        w(f"app/{p}/__init__.py", f'"""The {p} package."""\n')
        for m, body in MODS.items():
            w(f"app/{p}/{m}.py", body.format(p=p, e=e, l=e.lower()))
        for name, text in SPECIAL.get(p, ()):
            w(f"app/{p}/{name}.py", text)
        commit(f"feat({p}): add the {p} package")
    for p, e in PKGS:
        w(f"tests/{p}/__init__.py", "")
        for m in list(MODS) + [s for s, _ in SPECIAL.get(p, ())]:
            w(f"tests/{p}/test_{m}.py", TEST.format(p=p, m=m, M=m.title()))
        commit(f"test({p}): cover every module")
    w("app/api/routes/__init__.py", "from importlib import import_module\n\ndef dispatch(resource, *args):\n"
                                    "    return import_module(f\"app.api.routes.{resource}\").handle(*args)\n")
    many("app/api/routes/%s.py", "orders billing inventory auth reports jobs notifications health admin metrics",
         '"""HTTP handlers for /%s."""\n\ndef handle(method, path, payload=None):\n    return 200, {"path": path}\n')
    commit("feat(api): split routes into one module per resource")
    w("app/inventory/adapters/__init__.py", "")
    many("app/inventory/adapters/%s.py", "csv_import xlsx_import api_sync barcode audit",
         '"""Stock import: %s."""\n\ndef run(source):\n    return []\n')
    commit("feat(inventory): import adapters for stock files and partner feeds")
    w("app/orders/store.py", STORE_SQLITE)
    w("migrations/0001_orders_table.sql", "create table if not exists orders (id text primary key, body text not null);\n")
    commit("fix(orders): store orders in SQLite instead of orders.json\n\nTwo workers writing data/orders.json at "
           "once corrupted it twice this week: each save rewrote the whole file and the second writer clobbered "
           "the first. Orders now live in the orders table of data/ledger.db via app.db.connect().")
    w("app/db.py", DB % WAL)
    commit("perf(orders): enable WAL on the orders database\n\nA long report query blocked every checkout under "
           "the rollback journal; WAL lets readers proceed while one writer commits.")
    w("app/jobs/policy.py", POLICY % 7)
    commit("chore(jobs): raise the retry cap from 5 to 7\n\nPartner timeouts clear by the fifth attempt only half "
           "the time; two more attempts with exponential delay cover the tail.")
    w("app/jobs/legacy.py", LEGACY)
    w("scripts/migrate_jobs.py", "from app.jobs.legacy import MAX_RETRIES, LEGACY_QUEUE\n\nprint(MAX_RETRIES, LEGACY_QUEUE)\n")
    commit("refactor(jobs): keep the pre-policy constants for the jobs migration script")
    tables = ("accounts invoices stock jobs messages reports sessions audit_log stock_moves invoice_lines job_attempts "
              "report_rows account_tags sku_aliases message_log session_tokens report_schedules invoice_credits stock_counts")
    for i, t in enumerate(tables.split(), 2):
        w(f"migrations/{i:04d}_{t}_table.sql", f"create table if not exists {t} (id text primary key, body text not null);\n")
    commit("chore(db): one table per domain, as numbered migrations")
    many("docs/adr/%s.md", "0001-sqlite-over-json 0002-basis-point-rates 0003-abstract-mailer 0004-retry-policy-module "
         "0005-in-process-stock-cache 0006-one-table-per-domain", "# ADR %s\n\nSee the commit that introduced it.\n")
    many("docs/guides/%s.md", "getting-started running-tests adding-a-domain writing-a-migration deploying on-call",
         "# %s\n\nSteps live in the Makefile.\n")
    commit("docs: ADRs and guides")
    many("scripts/%s.py", "backfill_vat rebuild_stock_counts requeue_failed_jobs export_reports",
         '"""%s."""\n\nif __name__ == "__main__":\n    pass\n')
    commit("chore: operational scripts")
    w("CHANGELOG.md", "# Changelog\n\n## 0.9.0\n\n- Orders in SQLite with WAL; retry cap 7; one table per domain.\n")
    commit("docs: changelog for 0.9.0")
    if not NO_MAP:
        sha = subprocess.run(GIT + ["rev-parse", "--short", "HEAD"], check=True, capture_output=True, text=True).stdout.strip()
        w("PROJECT_MAP.md", MAP % sha)  # untracked on purpose: both arms share one git history
    print(f"ledger: {n_commits} commits" + ("" if NO_MAP else ", PROJECT_MAP.md written (untracked)"))


if __name__ == "__main__":
    main()
