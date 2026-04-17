---
description: "Detect and remove AI-generated writing patterns — make text sound naturally human"
user-invocable: true
argument-hint: "[analyze|<text-or-file-path>]"
context: fork
agent: general-purpose
---

# /humanize — AI Writing Detection & Removal

Detect and remove the hallmarks of AI-generated text. Rewrite content to sound like it
was written by a real, thoughtful human.

## How Strong Human Writing Works

- **Show, don't tell.** Concrete details and strong verbs beat abstract nouns and dramatic adjectives.
- **Asymmetry is authentic.** Perfectly balanced structures (always three examples, alternating sentence lengths) are an AI tell. Human writing is slightly messy.
- **Cut the fluff.** Transitional filler ("Furthermore," "Moreover,") glues weak ideas together. Humans use logical flow.
- **Acknowledge real complexity.** Not everything resolves with a neat, optimistic bow. Mixed feelings are normal.
- **Have a point of view.** Good writing has a subtle perspective, even in professional contexts.

## Two Modes

**Mode:** $ARGUMENTS (default: humanize)

### Default — Humanize

When the user provides text, humanize it. Return:
1. **Rewritten text** (in full)
2. **Summary of changes** (bulleted list of AI patterns removed)

For long text (>500 words), switch to Analyze mode first to avoid massive blind rewrites.

### Analyze

If the user says "analyze" or "check," return ONLY a list of AI patterns found
(pattern name + quoted example from the text). Do NOT rewrite yet. Wait for confirmation.

## The Core Insight: Clustering, Not Single Patterns

Any one of the 40 patterns, used once, can appear in good human writing. A single em-dash,
one "furthermore," an occasional metaphor — humans write this way too.

**The AI tell is clustering.** A model bundles multiple patterns into the same paragraph,
then repeats that density paragraph after paragraph. Three tropes in one sentence, four in
the next — that's the fingerprint.

**Break the clustering, don't exterminate every trope.** If a paragraph has six tells,
removing three usually restores a human cadence. Removing all six produces flat, sanitized
prose that reads just as artificial.

## Core Patterns to Watch For

For the full 40-pattern library, read the file `pattern-library.md` in this skill's directory (only when analyzing or when the 10 patterns above aren't sufficient).

**Key patterns (most common):**

| # | Pattern | What to Look For |
|---|---------|-----------------|
| 1 | AI Glossary | *delve, tapestry, crucial, landscape, intricate, beacon, pivotal, robust, leverage* |
| 2 | Exaggerated Significance | *serves as a testament to, marks a pivotal moment, stands as a beacon* |
| 3 | Rule of Three | Compulsive grouping in threes to sound comprehensive |
| 4 | Transitional Duct Tape | *Furthermore, Moreover, Additionally, Consequently* |
| 5 | Trailing Participles | *...highlighting their commitment, ...underscoring the importance* |
| 6 | "Despite Challenges" Formula | Challenge paragraph that immediately dismisses the challenge |
| 7 | Generic Optimistic Conclusions | *As we look to the horizon, the future remains bright* |
| 8 | Sycophantic Tone | *Great question! That's a fantastic point!* |
| 9 | Em-Dash Overuse | Several em-dashes per paragraph simulating punchy tone |
| 10 | Canned Opening Hooks | *Imagine a world where..., In today's fast-paced world...* |

## Strict Constraints

- **Check for humanity first.** If the text is already casual, contains slang, or has natural imperfections — it's already human. Reply: "This text already sounds naturally human. No changes needed."
- **Preserve facts and meaning.** Never alter statistics, core arguments, or factual claims.
- **Do not dumb it down.** Humanizing does not mean simplifying to a 5th-grade level. Academic text should remain academic, just without AI fluff.
- **Preserve quotes and code.** Leave direct quotes, code blocks, and technical terminology exactly as they are.
- **No sycophancy.** Don't start with "Great text!" or "I'd be happy to help!" Just output the requested format.
