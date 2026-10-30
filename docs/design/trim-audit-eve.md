# Trim audit for `agents/eve.md` (item 4 of the 2026-10-22 review)

> Written 2026-10-22 against shipkit 4.11.0 at `b24cef2`. **This document proposes and
> changes nothing.** Every `trim` row needs a measurement and the owner's yes before a line
> moves; the runs are deferred past the thinning sprint (no paid run on 2026-10-22). Method:
> `.shipkit/specs/measured-cuts/design.md` (the clause) and `docs/design/trim-audit-4.0.md`
> (the rule for a line). The owner's decisions go at the end.

## What the prompt costs, and whom

`agents/eve.md` is 17,010 bytes; `grandfather.md` is 9,156. The frontmatter is 1,288 of those
bytes and its six comment lines (510) are for a reader, not the model. The body, 15,722 bytes,
is about 4,300 tokens, and it is paid on **every call to `eve`** — a sweep, a where, a why, a
matrix, a digest — inside `eve`'s own context. None of it reaches the main session: the elder's
design already keeps the caller thin (`eval-results-4.9.md`, "The table": main-session input
46k–95k a run, the work in the elder's context). So what a trim buys is per-call cost and
`eve`'s own headroom under `maxTurns: 35`, not main-session thinness. The ceiling on the win is
about a third of the prompt, say 1,400 tokens a call; at the portfolio rate of about $0.13 a
run that is cents per call. The audit is worth doing because the method is cheap and the
answer is durable, not because the saving is large.

## The rule for a line

A line **stays** if it (a) holds a value specific to the owner's way of working, (b) names a
trap the model gets wrong untold, or (c) is shown by an eval to change the result. A section
no case exercises cannot satisfy (c) today; the verdict then rests on (a) and (b) and says so.
The watch for every trim is the five cases that run `eve`: `eve/jobs` (a sweep), `eve/payments`
(a where), `eve/why` and `eve/why-reworded` (a why from one map, "not recorded" without),
`digest/attention` (the digest shape). All five read 3 of 3 in the 4.11.0 release run
(`eval-history.md`, "Release run 4.11.0"); `map_read` and tool calls per run come from the
traces (`scripts/trace-tools.sh`).

## The sections

Bytes are the section's text from its heading to the next, `awk` over the file as shipped.

| Section | Bytes | Case that exercises it | Verdict | Reason |
|---|---|---|---|---|
| frontmatter comments (6 lines) | 510 | — | keep | Not sent to the model; a note for whoever edits the tools list |
| `# Eve Agent` (the identity) | 464 | all | keep | Short; says what she is for and that the caller stays thin |
| `## The registry` | 2,198 | `jobs`, `payments` (registry-only answers), `attention` (`studio.md`) | keep, one `trim` | The columns, `Product`/`Top Goal`, `studio.md` are (a). The "staleness signal" paragraph (about 250 bytes) repeats step 4's "a map can drift" |
| `### 0. Triage` | 1,132 | `jobs`, `payments` (0 map reads in 18 runs, 4.9.0) | keep | The one measured behaviour: single-fact questions read no map |
| `### The cheap path` | 2,523 | `jobs`, `payments` | **trim**: the cheat-sheet table | The four numbered steps are the method. The table (about 1,500 bytes) is seven rows of examples the text itself calls "not exhaustive"; whether a sweep still reads no map without it is exactly what the cases measure |
| `### 1. Read the registry` | 74 | — | keep | Two lines |
| `### 2. Structure vs decision-history` | 2,484 | `why`, `why-reworded` (the map-less "not recorded" path) | keep, one `trim` | `decision-check.sh` and the record paths are (b): a model cannot guess them. The MemPalace paragraph (about 900 bytes) names tools the model cannot guess, but applies only when MemPalace is registered — it can shrink to the tool list and the two rules (status first; recall is a claim), about 400 bytes |
| `### 3. Scope to relevant projects` | 374 | — | keep | Holds the "4-5 maps is cheap, 20 is not" number, (b) |
| `### 4. Verify per project` | 396 | `why` (the 4.11.0 sentence, measured 1 of 3 → 2 of 3) | keep | Measured text lives here |
| `### 5. Answer as a consolidated view` | 403 | all (the graders read the shape) | keep | The answer shape |
| `## Portfolio reports` (lead) | 266 | — | keep | Three lines |
| `### Dependency / version matrix` | 1,275 | **none** | **move** | No case; loaded on every call including a sweep that will never produce a matrix. Belongs in the `ask` skill, which already parses `--all matrix …` and can pass the shape in the prompt |
| `### Consolidation report` | 914 | **none** | **move** | Same: no case, the shape travels with the request |
| `### Attention digest` | 1,632 | `attention` | keep | The one report shape with a case; the digest's seven lines and the "at most three" cap are (a) |
| `## Good questions for you` | 738 | — | **trim** | Ten example questions. Nothing in them is a trap or a value; the triage section already classifies questions by kind. Whether they steer anything is measurable: the five cases |
| `## Constraints` | 829 | — | **trim** to two lines | "Cheapest-read-that-answers", "Selective reading", "Verify hits" and "Name the gaps" restate steps 0, 3, 4 and 5. "Read-only" and "Registry-driven" are the two not said elsewhere, about 250 bytes |

The candidates sum to roughly 5,500 bytes: the table (1,500), the MemPalace paragraph's
excess (500), the two report shapes (2,200, moved not cut), the example questions (740), the
restated constraints (580). A prompt of about 11,500 bytes remains, 3,000 tokens a call.

## The measurement

One arm first, not five. A scratch copy of the plugin with every candidate applied at once —
the table out, the MemPalace paragraph shortened, the two report shapes moved into the `ask`
skill's prompt text, the questions out, the constraints at two lines — against the committed
plugin as the baseline. Five cases, three runs each, `--keep-temp`; `map_read` and tool calls
per run from the traces; the sandboxes removed after reading (rule 13).

| Arm | Runs | Cost |
|---|---|---|
| Baseline, the committed `eve.md` | 15 | about $2 |
| All five candidates at once | 15 | about $2 |
| Bisection, only if the arm drops: one candidate returned at a time, worst case | 75 | about $10 |

The rate is the second-run plan's for E10 (9 runs ≈ $1.20). Total: $4 if the arm holds,
up to $14 if it does not. The matrix and consolidation shapes have no case, so moving them is
not measured by number; the claim is only that the text still reaches `eve` when the request
is a matrix or a consolidation, which one run of each through `/shipkit:ask --all` on the
portfolio fixture shows by the reply's shape (2 runs, about $0.30).

## The clause

A candidate stays out if every one of the five cases holds its 4.11.0 count (3 of 3) on the
trimmed copy, with `map_read` at 0 for `jobs` and `payments` and at 3 of 3 for `why`, as in
4.9.0 and 4.11.0. A candidate whose return restores a dropped count goes back in the same
commit; the record says which. A moved report shape returns to the agent if a matrix or a
consolidation request through `ask` comes back without its shape. **Fired-if.** manual — the
five cases are the watch in every release run after.

## What this audit does not claim

It does not claim the trimmed prompt answers better; the ceiling is "no worse, cheaper". It
does not touch step 4's measured sentence, step 0's triage, or the digest shape. It does not
measure the matrix and consolidation shapes, which have no case; writing one each (about 2 KB
of evals under a ceiling with 34 bytes left) is a separate decision.

## The owner's decisions

2026-10-30, after the table (`docs/design/eval-results-5.0.md` §3; S21-T4, W9):

- **All five candidates stay out.** Every case held 3 of 3 on the arm, `map_read` 0 for `jobs`
  and `payments` and 3 of 3 for `why`; no bisection was needed. The file went from 16,947
  bytes (its size at the branch) to 12,067.
- **12,067 bytes, not 11,500.** The estimate above did not count the sentences the table and
  the shapes left behind. The owner took the arm as measured over a $2 re-run for 567 bytes.
- **The two shapes in `skills/ask/reports.md`, not `SKILL.md`.** "The `ask` skill's prompt
  text" above would have put 1,354 bytes in the main session on every `/shipkit:ask`, the
  cost this audit says the elders' design avoids. `reports.md` is read on those two routes
  only, and takes the text whole.
- **The "no worse, cheaper" ceiling was half met.** No worse, by the clause. Cheaper did not
  show: 15 runs each, input tokens −2.2%, dollars +1.0%, both inside the runs' spread.
- The `## The registry` staleness bullet stays: it was not one of the five, and nothing measured it.
