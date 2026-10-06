---
paths:
  - "mix.exs"
  - "mix.lock"
---
# When Modifying mix.exs / mix.lock
- Use the pessimistic constraint `~>` for every hex package
- Run `mix hex.audit` (retired packages) and `mix deps.audit` (CVEs, needs mix_audit)
- Dev and test dependencies take `only: [:dev, :test], runtime: false` — without it they ship
