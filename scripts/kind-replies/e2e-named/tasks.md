# Tasks: passbook

Written by hand for smoke check 123. The task for REQ-2 names its kind with a tag.

- [ ] **T1** Withdrawals → REQ-1
  - Files: passbook/account.py, tests/test_account.py
  - Test: tests/test_account.py::test_the_balance_is_never_negative, written with Hypothesis
  - After: none
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T2** Export and import as two commands → REQ-2
  - Files: passbook/transfer.py, passbook/cli.py, tests/test_cli.py
  - Test: [e2e] tests/test_cli.py::test_export_then_import, which runs both commands; this is not a property test
  - After: T1
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T3** The new parser → REQ-3
  - Files: passbook/statements.py, tests/test_statements.py
  - Test: tests/test_statements.py::test_stored_documents_match_their_golden_renderings
  - After: T2
  - Done when: `python3 -m unittest -q` → all pass
