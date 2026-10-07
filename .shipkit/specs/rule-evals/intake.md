# Intake: One eval per rule

> Intake taken on 2026-10-07.

## Request
Sprint 9 of the evidence plan: give every rule file a case that shows whether it changes what
Claude does — a prompt that walks into the trap the rule names, in a fixture whose paths match
the rule's globs, with the rule installed as `/shipkit:setup` would install it — and run each
case in three arms (with the rule, without it, with the rule's pre-trim `v3.7.0` text) so the
trim audit's unmeasured criterion (c) gets its number. Then settle `rules/nontrivial`: read its
failing traces, try at most three one-sentence changes inside the 3,000-byte budget, or accept
the result in decision record 0002. 4.2.0.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; there is no product file.
- **Open specs:** none. All ten specs under `.shipkit/specs/` are `Status: shipped`.
- **Decision 0001** (the map is optional since 4.1.0): not a conflict; no case in this sprint
  reads a map, and the rule cases run in fixtures without one.
- **The plan's counts are wrong, and the sprint must say so before building (rule 6).**
  B5 says "15 rule files without an eval: the 5 path-scoped core rules and the 10 stack
  rules". The tree at `d8c7fb8` has **18**: the five core rules, and thirteen stack rule files
  across **nine** stacks — `elixir/mix-deps`, `go/go-mod`, `hotwire/hotwire`,
  `liveview/liveview`, `ml/data`, `ml/experiments`, `ml/notebooks`, `oban/jobs`,
  `python/pyproject`, `rails/gemfile`, `rails/rails`, `react/package-json`, `react/react`.
  The `static` stack ships no rule file (an overlay skill only), so "one case per stack"
  would measure nothing there. Two of the thirteen (`rails/rails.md`, `react/react.md`) have
  no `paths:` line and load on every file once installed. Question 1 below.
- **The eval byte budget (lint check 17, A9).** `plugins/shipkit/evals/` is 81,041 of
  102,400 bytes. An existing rule case is about 1,260 bytes; eighteen cases at about 1,050
  bytes (a shared harness shortens each scaffold) are about 19 KB, plus the harness
  (`with-rule.sh`, about 2.5 KB), the stack generator (the plan allows 15 KB; the aim is 10)
  and the README's new rows and Check-first answers (about 3 KB): **about 33 KB against
  21 KB of room.** Even the plan's own fifteen cases would not fit. Question 2 below.
- **The byte budget of the always-on rules:** 2,996 of 3,000. Only T5 may touch them, and
  only by paying for every byte inside the same file (B8).
- **The eval tool does not forward the caller's environment to a scaffold** (nonce-tested in
  Sprint 8). The plan's `SHIPKIT_EVAL_NO_RULE=1` and `SHIPKIT_EVAL_RULE_REF=v3.7.0` cannot
  select an arm on the eval command. Not a conflict with what is built — the harness honours
  both variables when run by hand, which is what the smoke checks do — but the arms of T4 are
  selected the way Sprint 8's no-map arm was: a scratch copy of the plugin with one edit (here,
  one line in `with-rule.sh` that sets the variable's default). Recorded in `design.md`.

## Answers
1. **Which rules get a case (B5, corrected count)?** One case per rule **file** — eighteen,
   under `evals/scoped/` (five) and `evals/stacks/` (thirteen) — rather than one per stack.
   The trim audit's rows are files, and criterion (c) needs a number per trimmed file; a
   stack with three rules and one case could not say which rule earned the pass. Cost: about
   150 measurement runs (the four files unchanged since `v3.7.0` skip the pre-trim arm), about
   $20 at the `rules` cases' $0.13 a run; the release run grows from 20 to 38 cases, about
   $6.50 → about $13.50 (B7's ceiling said 35 cases and about $13; the money is the same).
   **Answered yes by the owner on 2026-10-07.**
2. **The eval byte ceiling.** Raise lint check 17 from 102,400 to 131,072 bytes (128 KB) in
   T1, with `scripts/lint.py` added to T1's Files line and smoke check 42's expected message
   updated. The alternative — moving the evals README's history sections out of `evals/` or
   exempting the README from the count — changes a shipped document or a shipped check's
   meaning to make room, which is worse than saying the number grew and why. **Answered yes
   by the owner on 2026-10-07.**

3. **T1's Check first failed, and so did the plan's fallback (asked 2026-10-07, after T0).**
   No file under the workspace's `.claude/` and no workspace `CLAUDE.md` loads in the eval
   sandbox (`CLAUDE_CODE_DISABLE_CLAUDE_MDS=1`; documented under "How runs are isolated").
   The rule under test is delivered by the plugin's own session hook from the installed file,
   behind a marker and the eval tool's `CLAUDE_CODE_EVAL_CONFINED=1`; `with-rule.sh` installs
   only that file. **The owner chose this over `append_system_prompt` on 2026-10-07.** The
   measurement is of the text, delivered always-on, for all eighteen rules.

## Assumptions made
- **"Without the rule" means setup's install minus one file.** The with arm installs every
  core rule and the stack overlay exactly as `/shipkit:setup` would (`install-rules.sh`,
  `install-stack.sh`, manifest written); the without arm installs the same minus the one file
  under test; the pre-trim arm installs the same with that one file's `v3.7.0` text. The three
  arms differ in exactly one file, and the number measured is the rule's value in a set-up
  project, next to the other rules — which is what "dead weight" would mean to a user.
  Decision record in `design.md`.
- **Group directories.** The plan names the core group `rules-scoped/`; the eval tool selects
  cases by a name pattern, and `rules-*` would also match `rules-scoped-*`, so T5's
  `--group rules` (the three always-on cases, watched for regression) would run eight cases.
  The core group is `scoped/` (`scoped-dependencies`, …); the stack group is `stacks/`
  (`stacks-mix-deps`, …). `--group` is a name-prefix match, documented as such.
- **The pre-trim arm is skipped for files unchanged since `v3.7.0`** — `ml/data`,
  `ml/experiments`, `ml/notebooks`, `oban/jobs` are byte-identical at `v3.7.0` and `HEAD`, so
  their pre-trim runs would repeat the with arm. The results table says "same text" in that
  cell and the trim audit's new section lists the fourteen trimmed files only. The four files
  cut in 4.0 (`security`, `elixir`, `go`, `python`) are out of scope: there is no with arm.
- **Stack mini-fixtures are generated**, one function per stack in `stack-gen.sh` (the plan's
  generator-not-fixture rule), three to six files, nothing run. The `static` shape exists for
  the `ui-ux` core case (HTML, CSS) although `static` has no rule; the `rails` shape carries
  `db/migrate/` for the `migrations` core case; a `monorepo` shape (pnpm workspace) exists for
  the `monorepo` core case. `dependencies` and `testing` run in `sample-app`.
- **The probe is the rule's first named trap**, as the plan says; where the first bullet is
  not a trap a prompt can walk into (`ui-ux.md` opens with a preamble; `react.md` with a
  scope note), the first bullet that is. The case's `description:` quotes the line.
- **A pass without the rule is a finding, not a failure** (plan §6); no rule is edited on the
  strength of T4 (plan §5). T5 is the one bounded exception and runs after T4.
- The release is 4.2.0. Nothing is removed; no skill, agent or rule is added.

## Out of scope
- Any change to a rule file other than T5's at-most-three one-sentence attempts to the
  always-on rules; rule edits proposed by the results go to the plan after this one.
- The four rule files cut in 4.0 (no with arm exists); overlay skills (decision 0003, Sprint
  10); the real run; the deletions B11 to B13.
- Measuring context cost as a decision input; tool calls and passes are the numbers read.
