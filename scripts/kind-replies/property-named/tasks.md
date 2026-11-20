# Tasks: passbook

Written by hand for smoke check 123. The task for REQ-1 names its kind with a tag.

- [ ] **T1** Withdrawals that never take the balance below zero → REQ-1
  - Files: passbook/account.py, tests/test_account.py
  - Test: [property] tests/test_account.py::test_no_run_of_deposits_and_withdrawals_goes_below_zero
  - After: none
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T2** Export and import as two commands → REQ-2
  - Files: passbook/transfer.py, passbook/cli.py, tests/test_cli.py
  - Test: [e2e] tests/test_cli.py::test_export_then_import_gives_the_same_records
  - After: T1
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T3** Any records survive the round trip → REQ-2
  - Files: passbook/transfer.py, tests/test_transfer.py
  - Test: [property] tests/test_transfer.py::test_any_records_export_and_import_unchanged
  - After: T2
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T4** `parse_v2` takes over from `parse_v1` → REQ-3
  - Files: passbook/statements.py, tests/test_statements.py
  - Test: [differential] tests/test_statements.py::test_every_stored_document_renders_the_same
  - After: T3
  - Done when: `python3 -m unittest -q` → all pass
