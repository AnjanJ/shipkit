---
paths:
  - "**/*.ipynb"
  - "notebooks/**"
---
<!-- requires: python -->
# Notebooks

- **Notebooks are for exploration, not for production.** The moment a function is called from a
  second place, move it into a module under the package and import it back. A notebook that
  defines the training loop is a refactor waiting to break.
- **Clear outputs before committing** (`nbstripout`, or `jupyter nbconvert --clear-output`).
  Committed outputs bloat the repo, leak data samples, and make every diff unreadable.
- **No secrets or credentials in cells**, including in output. Read them from the environment.
- **Assume out-of-order execution.** Anything you rely on must be re-runnable top to bottom;
  say so by restarting and running all before you trust a result.
- Keep data loading in one cell near the top, parameterized by a path or config — never a
  hard-coded absolute path from your machine.
- A notebook that produces a number someone will quote needs the git SHA and the config
  printed in it.
