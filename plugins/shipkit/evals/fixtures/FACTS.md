# Planted facts in `sample-app`

The eval cases ask questions whose right answers are fixed here. If you edit the fixture,
update the file and line below in the same commit.

| ID | Fact | Where |
|----|------|-------|
| F1 | A failed charge is retried at most 5 times. | `app/jobs/retry.py:10` — `MAX_RETRIES = 5` |
| F2 | Tax is computed by the function `apply_tax`. | `app/billing.py:20` — `def apply_tax(subtotal_cents, region):` |
| F3 | Orders are stored in a JSON file. **The map says SQLite; the map is wrong on purpose.** | Code: `app/orders.py:11` — `ORDERS_FILE = Path("data/orders.json")`. Wrong claim: `PROJECT_MAP.md:33` |
| F4 | Nothing says which payment provider is used. **There is no answer.** | `app/billing.py:27` — `charge` takes a `gateway` object from its caller; no provider is named in any file |

Also planted, for the `rules/trivial` case: the misspelling `recieve` at `README.md:3`.

Rules for whoever edits the fixture:

- The word for the database in F3 must appear in `PROJECT_MAP.md` and in no other file under
  `sample-app/`. Check with `grep -rn` before committing.
- Name no payment provider anywhere, not even in a comment or a test.
- No file named `prompt.md` or `case.yaml` under `fixtures/` — the eval tool would read the
  folder as a case.
- The fixture's tests must pass: `python3 -m unittest discover -s sample-app/tests`.
- Keep `fixtures/` at 40 KB or less and `sample-app/` at 20 files or fewer.
