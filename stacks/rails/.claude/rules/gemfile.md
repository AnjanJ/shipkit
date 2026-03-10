---
paths:
  - "Gemfile"
  - "*.gemspec"
---
# When Modifying Gemfile / Gemspec
- Use pessimistic version constraint `~>` for all gems
- After ANY change: run `bundle install`, verify `Gemfile.lock` changes make sense, run full test suite
- Run `bundle audit check` to verify no new vulnerabilities introduced
- Check `bundle outdated <gem>` to verify you're adding the latest version
- For Rails AI features: prefer `ruby_llm` gem unless project already uses an alternative (anthropic, ruby-openai, langchainrb)
- Never remove a gem without checking for usages first: `grep -r "GemName\|gem_name" app/ lib/ spec/`
