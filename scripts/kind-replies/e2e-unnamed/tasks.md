# Tasks: passbook

Written by hand for smoke check 123. The task for REQ-2 names a test and no kind.

- [ ] **T1** Withdrawals → REQ-1
  - Files: passbook/account.py, tests/test_account.py
  - Test: [property] tests/test_account.py::test_the_balance_is_never_negative
  - After: none
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T2** Export and import → REQ-2
  - Files: passbook/transfer.py, passbook/cli.py, tests/test_transfer.py
  - Test: tests/test_transfer.py::test_export_then_import_gives_the_same_records
  - After: T1
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T3** The new parser → REQ-3
  - Files: passbook/statements.py, tests/test_statements.py
  - Test: [property] tests/test_statements.py::test_parse_v2_reads_any_statement
  - After: T2
  - Done when: `python3 -m unittest -q` → all pass
