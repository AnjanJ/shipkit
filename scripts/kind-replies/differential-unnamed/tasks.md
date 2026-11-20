# Tasks: passbook

Written by hand for smoke check 123. The task for REQ-3 names a test and no kind, and no task cites REQ-1.

- [ ] **T1** Export and import as two commands → REQ-2
  - Files: passbook/transfer.py, passbook/cli.py, tests/test_cli.py
  - Test: [e2e] tests/test_cli.py::test_export_then_import_gives_the_same_records
  - After: none
  - Done when: `python3 -m unittest -q` → all pass
- [ ] **T2** The new parser → REQ-3
  - Files: passbook/statements.py, tests/test_statements.py
  - Test: tests/test_statements.py::test_parse_v2_renders_the_march_statement
  - After: T1
  - Done when: `python3 -m unittest -q` → all pass
