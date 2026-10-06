---
description: "Five-phase QA pass on recent changes or one file: find the test framework, plan the gaps with the user, write the tests, run them, report. TRIGGER when: the user asks for QA or test coverage of a change, or what is untested. DO NOT TRIGGER when: strict TDD was asked for (use /shipkit-workflows:tdd)."
user-invocable: true
argument-hint: "[<file-or-module>|all]"
---

<!-- Runs INLINE (no context: fork) on purpose: Phase 2's probing questions and the
     Phase 3 plan approval need AskUserQuestion, which forked skills cannot use.
     For large change sets, delegate Phase 1 recon to a read-only explorer agent instead. -->

# /qa — Quality Assurance Workflow

Thorough QA on recent changes or one file. Scope: `$ARGUMENTS` (default: the files below).

## Recently Changed Files
!`f=$(git diff --name-only HEAD~1 2>/dev/null | head -20); [ -n "$f" ] && echo "$f" || echo "no recent changes detected"`

## Phase 1: Reconnaissance

Detect the test framework from the manifests (`Gemfile` → RSpec or Minitest, `mix.exs` →
ExUnit, `package.json` → Jest or Vitest, `playwright.config` → Playwright). Read each changed
file and its existing tests; if more than about five files changed, delegate the reading to
`shipkit:codebase-explorer` (or the built-in `Explore` agent) and work from its summary. Rate
each file CRITICAL (auth, payments, data models, shared utilities, API endpoints), HIGH
(business logic, services, controllers), MEDIUM (views, serializers, helpers, config) or LOW
(docs, formatting), and show the table: file · type · risk · existing tests.

## Phase 2: Interrogation

Before writing a test, ask three to eight risk-focused questions in one AskUserQuestion call —
"this touches the payment flow; test refund edge cases?", "the validation rejects blank input;
what about unicode-only strings?", "this calls an external API; mock it or test integration?".
Never ask what the code does, whether to write tests, or which framework to use.

## Phase 3: Test plan

Present the plan as a table — # · category · test · risk — and wait for approval. Categories:
happy path; edge cases (boundaries, empty, nil, max); error cases (invalid input, timeouts,
permission denied); adversarial (injection strings, script tags, emoji, 10 MB strings,
concurrent access); performance (N+1, unbounded collections — CRITICAL and HIGH only);
integration (only when several files changed together).

## Phase 4: Write the tests

One behaviour per test, named for the behaviour (`returns 404 when the record is missing`, not
`works`); arrange-act-assert; no mystery guests — the data is visible in the test; test
behaviour, not private methods; use the project's factories and fixtures; group with
`describe`/`context`. Tests are code: no helper over ten lines, no test for a state that
cannot happen, clear duplication over clever shared examples. Framework notes in @reference.md.

## Phase 5: Run and report

Run the new tests alone, fix any failure at its root cause, then run the whole suite. Write the
QA report in the shape in @reference.md and end with one verdict: **SHIP IT**, **FIX AND
RE-TEST** or **NEEDS REWORK**.
