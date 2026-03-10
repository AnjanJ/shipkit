---
description: "Scaffold an AI/LLM feature: chat, embeddings, RAG, agents, structured output. Detects stack and recommends the right library."
user-invocable: true
disable-model-invocation: true
argument-hint: "[chat|embeddings|rag|agent|structured-output]"
---
# AI Feature: $ARGUMENTS

## Step 1: Detect Stack and Existing AI Libraries
!`ls Gemfile mix.exs package.json pyproject.toml requirements.txt go.mod 2>/dev/null`
!`grep -rE "ruby_llm|langchain|openai|anthropic|ollama|instructor" Gemfile package.json pyproject.toml requirements.txt mix.exs 2>/dev/null | head -10 || echo "no AI libraries detected"`

## Step 2: Library Selection

### Ruby/Rails
- **Default: `ruby_llm`** — 3,700+ stars, 13+ providers, 3 deps, deep Rails integration
- Use `ruby_llm` UNLESS the project already uses:
  - `anthropic` gem (official SDK) — keep if Claude-only
  - `ruby-openai` — keep if OpenAI-only
  - `langchainrb` — keep if using LangChain patterns (RAG, vector stores)
- Read docs at https://rubyllm.com before implementing

### JavaScript/TypeScript
- `@anthropic-ai/sdk` for Claude
- `openai` for OpenAI
- `@langchain/core` for complex workflows
- Prefer the official SDK for the primary provider

### Python
- `anthropic` (official SDK) for Claude
- `openai` for OpenAI
- `langchain` for complex workflows, RAG, agents
- `llama-index` for document-heavy RAG

### Elixir
- `instructor_ex` for structured LLM output
- Direct HTTP via `Req` for simple API calls

## Step 3: Read Documentation
IMPORTANT: Use WebFetch to read the chosen library's docs BEFORE writing code.
- For ruby_llm: https://rubyllm.com
- For official Anthropic SDKs: use the /claude-api skill if available

## Step 4: Scaffold Based on Feature Type

### Chat
- Model configuration (provider, model name, temperature)
- Message history management (persist in DB for production)
- Streaming response support
- Error handling with retries and exponential backoff
- Token usage tracking

### Embeddings
- Embedding model selection
- Vector storage (pgvector, Qdrant, Pinecone, or in-memory for dev)
- Similarity search function with configurable threshold
- Batch embedding for existing data

### RAG (Retrieval-Augmented Generation)
- Document ingestion pipeline
- Chunking strategy (size, overlap)
- Embedding + storage
- Retrieval + prompt construction
- Citation/source tracking in responses

### Agent / Tool Use
- Tool definitions with clear schemas
- Agent loop (call -> tool -> result -> call)
- Safety limits (max iterations, timeout)
- Logging and observability

### Structured Output
- Output schema definition (JSON Schema or language types)
- Validation of LLM response against schema
- Retry on validation failure
- Type-safe result handling

## Step 5: Dependency Verification (mandatory)

Before committing, verify the new dependency is safe and compatible:

**Ruby:** `gem search <name> --remote` → `bundle install && bundle exec rspec` → `bundle audit check`
**Node:** `npm view <name> version` → `npm install && npm test` → `npm audit`
**Python:** `pip index versions <name>` → `pip install <name> && pytest` → `pip-audit`
**Elixir:** `mix hex.info <name>` → `mix deps.get && mix test` → `mix hex.audit`

- Use the latest stable version unless incompatible with the project's runtime
- Use version constraints (`~>`, `^`) — never `*` or unpinned
- For Ruby AI features: prefer `ruby_llm` unless the project already uses another library

## Step 6: Final Verification
1. Run the full test suite
2. Verify API keys are in environment variables, NOT in code
3. Verify no secrets in committed files
4. Verify error handling for: rate limits, timeouts, invalid responses
