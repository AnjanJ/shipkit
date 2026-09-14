---
paths:
  - "mix.exs"
  - "mix.lock"
---
# When Modifying mix.exs / mix.lock
- Use pessimistic constraint `~>` for all hex packages
- After ANY change: run `mix deps.get && mix test`
- Run `mix hex.audit` (retired packages) and `mix deps.audit` (CVEs) if mix_audit is available
- Run `mix hex.outdated` to verify you're adding the latest version
- Use `:only` option for dev/test dependencies: `{:credo, "~> 1.7", only: [:dev, :test], runtime: false}`
