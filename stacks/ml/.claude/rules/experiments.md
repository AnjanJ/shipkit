---
paths:
  - "experiments/**"
  - "configs/**"
  - "**/train*.py"
  - "**/eval*.py"
---
<!-- requires: python -->
# Experiments and Training

## Reproducibility is the whole point
- **Set every seed** (`random`, `numpy`, framework) and record it in the run's config. An
  unseeded run cannot be compared to anything.
- **Log every run** with its full config, the git SHA, and the dataset version. A metric
  without those three is not a result.
- Note that exact reproducibility still needs deterministic kernels and fixed data order —
  say when a run is only statistically reproducible.

## Be explicit
- **Device selection is explicit** (`cuda` / `mps` / `cpu`), configurable, and logged. Never
  silently fall back to CPU for a training run.
- Hyperparameters live in a config file, not in argparse defaults scattered across scripts.
- Anything non-deterministic (augmentation, dropout, sampling) is disabled or fixed at eval.

## Evaluation
- **Never evaluate on training data.** Splits are created once, saved, and reused — not
  re-randomized per run.
- Hold out a test set that is touched only at the end. Tune on validation.
- Save metrics next to the weights they describe, in the same directory, with the config.
- Report the baseline you are comparing against. A number with no baseline says nothing.

## Cost and checkpoints
- Checkpoint on a schedule — a long run that dies at hour six with no checkpoint is lost work.
- Log wall-clock and, for API-backed runs, token and dollar cost.
