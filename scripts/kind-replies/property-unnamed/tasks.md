# Tasks: passbook

Written by hand for smoke check 123. The task for REQ-1 names a test and no kind.

- [ ] **T1** Withdrawals → REQ-1
  - Files: passbook/account.py, tests/test_account.py
  - Test: tests/test_account.py::test_a_withdrawal_above_the_balance_is_refused
  - After: none
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T2** Export and import → REQ-2
  - Files: passbook/transfer.py, passbook/cli.py, tests/test_transfer.py
  - Test: tests/test_transfer.py: a property test over generated records, exported and then imported
  - After: T1
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T3** The new parser → REQ-3
  - Files: passbook/statements.py, tests/test_statements.py
  - Test: tests/test_statements.py: the old and new parser on every stored document give one rendering
  - After: T2
  - Done when: `python3 -m unittest -q` → all pass
