---
paths:
  - "Gemfile"
  - "*.gemspec"
---
# When Modifying Gemfile / Gemspec
- Use the pessimistic constraint `~>` for every gem; read the `Gemfile.lock` diff after `bundle install`
- Run `bundle audit check` for known vulnerabilities
- For Rails AI features prefer `ruby_llm` unless the project already uses another (anthropic, ruby-openai, langchainrb)
- Never remove a gem without grepping for its usages first: `grep -r "GemName\|gem_name" app/ lib/ spec/`
