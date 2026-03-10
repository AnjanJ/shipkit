---
description: "AI/LLM patterns for Rails using RubyLLM: chat, embeddings, tool use, streaming, Rails integration"
user-invocable: false
---

# AI/LLM Patterns for Rails

Reference for building AI features in Rails. Default library: **RubyLLM** (https://rubyllm.com).

## RubyLLM Setup

```ruby
# Gemfile
gem "ruby_llm", "~> 1.13"

# config/initializers/ruby_llm.rb
RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
end
```

## Common Patterns

### Chat with Persistence (ActsAsChat)
- Use `acts_as_chat` on a model for automatic message persistence
- Messages stored in DB — survives server restarts
- Supports streaming via ActionCable or Turbo Streams

### Embeddings
- Use `ruby_llm` embeddings with `pgvector` for PostgreSQL vector storage
- Batch embed with background jobs to avoid blocking requests

### Streaming Responses
- Use Turbo Streams for real-time response display
- Background job streams tokens via ActionCable
- Never stream in a synchronous controller action

### Tool Use / Agents
- Define tools as Ruby classes with `#description` and `#execute` methods
- RubyLLM handles the tool call loop automatically
- Set max iterations to prevent runaway loops

### Background Processing
- ALL LLM calls should be in background jobs (Sidekiq/GoodJob)
- Jobs must be idempotent — LLM retries may produce different responses
- Track token usage per job for cost monitoring
- Set timeouts: LLM calls can hang if the provider is degraded

## Testing Patterns
- Use VCR cassettes or WebMock to record LLM responses
- For unit tests: mock the LLM client, assert on prompts and tool calls
- For integration tests: use recorded responses, not live API calls
- Test error paths: rate limits, timeouts, malformed responses

## Security
- API keys in `credentials.yml.enc` or ENV vars — never in code
- Sanitize user input before including in prompts (prompt injection prevention)
- Sanitize LLM output before rendering in views (XSS prevention)
- Rate limit user-facing LLM endpoints
- Log prompts and responses for debugging (exclude PII)

## Cost Management
- Track token usage per user/request
- Set budget limits per user or organization
- Use cheaper models (Haiku) for simple tasks, expensive models (Opus) for complex ones
- Cache identical prompts when appropriate
