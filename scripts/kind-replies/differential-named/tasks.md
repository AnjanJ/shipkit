# Tasks: passbook

Written by hand for smoke check 123. The task for REQ-3 names its kind in words.

- [ ] **T1** Withdrawals → REQ-1
  - Files: passbook/account.py, tests/test_account.py
  - Test: [property] tests/test_account.py::test_the_balance_is_never_negative
  - After: none
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T2** Export and import → REQ-2
  - Files: passbook/transfer.py, passbook/cli.py, tests/test_transfer.py
  - Test: [property] tests/test_transfer.py::test_any_records_export_and_import_unchanged
  - After: T1
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T3** The new parser → REQ-3
  - Files: passbook/statements.py, tests/test_statements.py
  - Test: tests/test_statements.py: a differential test, both parsers on each stored document
  - After: T2
  - Done when: `python3 -m unittest -q` → all pass
