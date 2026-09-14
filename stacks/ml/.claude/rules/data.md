---
paths:
  - "data/**"
  - "**/datasets/**"
---
<!-- requires: python -->
# Data and Model Artifacts

- **Never commit raw data or model weights to git.** Use a data directory that is gitignored,
  plus a documented fetch step (script, DVC, object storage, dataset hub). Git is not a blob
  store and a cloned repo should not be 4 GB.
- **Document provenance and licence for every dataset**: where it came from, when it was
  pulled, what the terms permit. "It was in the folder" is not provenance, and licence terms
  decide whether a model can ship.
- **Pin dataset versions** the same way dependencies are pinned. A dataset that silently
  changed invalidates every prior result.
- **Schema-check on load** — column names, dtypes, ranges, null policy. Fail loudly at load
  rather than producing a quietly wrong model.
- **Personal data:** know whether the set contains it before it is used. If it does, it does
  not go into a prompt, a third-party API, or a committed sample without an explicit decision.
- Keep a small, committed fixture sample for tests — real shape, no real records.
