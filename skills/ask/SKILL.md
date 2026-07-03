---
description: "Ask the project elders — route a question to grandfather (this project) or eve (across all projects). Keeps main context thin: all research happens in a subagent, only the answer comes back."
user-invocable: true
argument-hint: "<question>  |  --all <question>"
---

# /shipkit:ask — Ask the Project Elders

Route a project question to a research subagent so the **main session's context stays thin**.
The subagent reads the map, verifies against source, and returns only a tight answer — the
main context never sees the dozens of file reads behind it.

## Routing

Question: `$ARGUMENTS`

- **Default (single project)** → delegate to the **`grandfather`** agent. Use for questions
  about *this* project: architecture, how something works, where things live, why a decision
  was made, is-it-safe-to-change-X.

- **`--all` prefix** (or the question is clearly cross-project — "which of my projects…",
  "across all my apps…") → delegate to the **`eve`** agent, which reads the project
  registry and answers across the portfolio.

- **Portfolio reports** — two named report shapes eve knows how to produce:
  - `--all matrix <library|framework|"everything major">` → dependency/version matrix across
    all repos (lockfile truth, one row per project). For upgrades and vulnerability sweeps.
  - `--all consolidate` → ranked report of patterns implemented in multiple repos that could
    exist once, with per-copy evidence and drift notes.

## How to run it

1. **Do not research in the main context.** That defeats the purpose. Immediately spawn the
   agent via the Agent tool.
2. Pass the user's question verbatim as the agent prompt. Add one line of context if useful
   (e.g. "the working dir is <path>").
3. For `grandfather`: if there is no `PROJECT_MAP.md`, the agent will answer live and say so —
   suggest the user run `/shipkit:map` afterward so future questions are faster.
4. **Relay the agent's answer to the user as-is** (it is already tight and cited). Add at most
   one line of your own framing. Do not re-verify the agent's findings in the main context —
   that re-pollutes what you just kept clean.

## When NOT to use this

- You are mid-edit and need a fact to *continue coding right now* — a subagent round-trip is
  slower than just reading the one file you need. The elders are for research-shaped questions,
  not for facts you need inline to keep typing.
- The answer requires changing code — the elders are read-only. Get the answer, then act.

## Examples

- `/shipkit:ask how does locale fallback work in this monolith?` → grandfather
- `/shipkit:ask is it safe to remove the legacy_token column?` → grandfather (judgment, high effort)
- `/shipkit:ask --all which of my projects deploy to Hetzner?` → eve
- `/shipkit:ask --all everywhere I integrate Stripe` → eve
- `/shipkit:ask --all matrix rails` → eve (version matrix: every repo's Rails version, from lockfiles)
- `/shipkit:ask --all consolidate` → eve (what am I maintaining N times that should exist once?)
