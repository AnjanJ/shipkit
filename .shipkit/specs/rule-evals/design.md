# Design: One eval per rule (Sprint 9)

## Approach

One harness, many cases. `with-rule.sh <rule>` is the only thing a rule case's scaffold calls
after its fixture is in place: it runs shipkit's own installers against the workspace so the
rules land as `/shipkit:setup` would land them, then applies the arm — the one file under test
present (with), absent (without) or replaced by its `v3.7.0` text (pre-trim). A small generator
writes the five-file project each stack rule's globs need. Eighteen cases, each a prompt that
walks into the rule's first named trap, with a grader that reads the reply or the file. The
measurement reads traces, fills the trim audit's empty column, and stops at the owner's desk.
Then, and only then, `rules/nontrivial` gets its three bounded attempts.

---

## Decision: One case per rule file, eighteen of them   (→ REQ-10, REQ-11, REQ-14)

**Context.** B5 was approved as "15 files: 5 core + 10 stack". The tree has 18: the `static`
stack has no rule, and `ml`, `rails` and `react` ship two or three each. The trim audit's rows
are files; criterion (c) is "shown by an eval to change the result", per file.

**Alternatives.**
1. One case per rule file: 18 cases, about 150 measurement runs (about $20), 38 cases per
   release run (about $13.50).
2. One case per stack with rules, probing its main rule: 5 + 9 = 14 cases; `ml`'s `data` and
   `notebooks`, `rails`'s `rails`, `react`'s `react` get no number.
3. The plan's count as written: 5 + 10, with a `static` case that installs no rule.

**Case for (1).** It is the only option that gives every trim-audit row a number, which is the
sprint's stated goal; the extra four cases cost about $0.50 a release run; the harness makes a
case about a kilobyte, so eighteen fit once the ceiling moves (next record).

**Case against (1).** Eighteen graders are eighteen judgement calls about what "walked into the
trap" means, and the release run grows past B7's "35 cases" by three. Two of the files
(`rails.md`, `react.md`) are not path-scoped at all, so their cases measure the text, not the
loading — the results say so.

**Decision.** We chose (1), approved by the owner on 2026-10-07 (intake question 1).
**Falsifiability.** We would fold cases back to one per stack if the eighteen rule cases cost
more than $10 in a single release run of `scripts/evals.sh` (their share of the bill, from
`trace-tools.sh`), which would mean the fixtures grew past "three to six files, nothing run".
**Fired-if.** manual

---

## Decision: The eval ceiling moves to 128 KB   (→ REQ-9)

**Context.** Lint check 17 holds `plugins/shipkit/evals/` at 102,400 bytes (A9 of the last
plan); 81,041 are used. Eighteen cases, the harness, the generator and the README's new text
need about 33 KB. The plan's own fifteen would not have fit either.

**Alternatives.**
1. Raise the ceiling to 131,072 bytes (128 KB) in T1, `scripts/lint.py` added to T1's Files
   line with the owner's yes, smoke check 42's expected message updated.
2. Move the evals README's baseline-history sections (about 9 KB) to `docs/design/` and keep
   the ceiling.
3. Exempt `evals/README.md` from the count.

**Case for (1).** The ceiling exists so the plugin stays small to install; 128 KB of evals in
a plugin that ships a 14 KB generator instead of a 400 KB fixture is the same discipline with a
bigger number, and the number is stated. (2) rewrites a shipped document to make room; (3)
changes what a shipped check means and invites the README to grow without limit.

**Case against (1).** A limit that moves when it binds is a weaker limit; the next sprint
could ask again. The generator-not-fixture rule is what keeps it honest, and this record says
the new number is for cases, not fixtures.

**Decision.** We chose (1), approved by the owner on 2026-10-07 (intake question 2).
**Falsifiability.** We would stop raising the ceiling and start cutting cases if a release
ships with `plugins/shipkit/evals/` above 120 KB and no case added since 4.2.0, which would
mean the room went to padding, not cases.
**Fired-if.** manual

---

## Decision: "Without the rule" is setup's install minus one file   (→ REQ-1, REQ-2, REQ-3, REQ-4)

**Context.** A path-scoped rule loads only from a project's `.claude/rules/`. A user who has
one rule has all of them: `/shipkit:setup` runs `install-rules.sh` (every core rule) and
`install-stack.sh` (the overlay). The three always-on rules then load from disk and the hook
stops injecting them (smoke check 2).

**Alternatives.**
1. Install everything setup installs; the arm changes exactly one file (present, absent, or
   the `v3.7.0` text). The installers run from a scratch plugin root the harness builds with
   that one file edited, so the manifest is consistent and nothing is deleted after install.
2. Install only the rule under test; the without arm has no `.claude/rules/` at all, and the
   always-on rules keep arriving through the hook as the `rules/*` cases have them.

**Case for (1).** The number it gives is the rule's marginal value next to the rules a real
project has — `pyproject.md` is measured over `dependencies.md`, which is the question the
trim audit asked when it dropped the lines the two files shared. The arms differ in one file,
so a difference between them is that file's.

**Case against (1).** More context per run (every rule file is on disk, though path-scoped
ones load only on matching paths), and a dependence on the installers working inside the
sandbox — explicit `mktemp` templates, a scratch root under the workspace's own temp
directory, both to be shown by T1's smoke check. The with arm of a core rule also carries the
stack overlay only when the fixture is a stack project.

**Decision.** We chose (1).
**Falsifiability.** We would switch to (2) if, in T4, the without arm of any case shows the
rule under test's first trap line in its trace context (a rule that arrived another way), or
if the installers fail inside the sandbox and the fallback cannot be made to write a manifest.
**Fired-if.** manual

---

## Decision: The pre-trim arm, and how its text is found   (→ REQ-4, REQ-14, REQ-15, REQ-16)

**Context.** B6 approved a third arm per case with the rule's text at `v3.7.0`, so criterion
(c) is measured for the 4.0 trims. Fourteen of the eighteen files changed in 4.0; four
(`ml/data`, `ml/experiments`, `ml/notebooks`, `oban/jobs`) are byte-identical. A scaffold runs
from the plugin's own directory; when that directory is this repository, `git show` reaches
the tag; when it is a scratch copy (how an arm is selected — the eval tool forwards no
environment), it does not.

**Alternatives.**
1. `with-rule.sh` resolves the ref's text with `git -C <repo> show <ref>:<path>`, where
   `<repo>` defaults to the plugin root's grandparent and can be given explicitly; the four
   unchanged files skip the arm and the table says "same text".
2. Keep a copy of the `v3.7.0` rule text under `evals/fixtures/rules-3.7/` for the sprint and
   delete it before release (the plan's §3 fallback).
3. Run the pre-trim arm for all eighteen, including the four whose text did not change.

**Case for (1).** Nothing is copied into the plugin; the ref is a parameter, so a later trim
can be measured against `v4.2.0` the same way; twelve runs that would repeat the with arm are
not bought.

**Case against (1).** The scratch copy for the pre-trim arm needs the repository's path — one
more thing to get right in the arm-selection step; the README gives the exact command. And an
arm that is "skipped because identical" is a reading of `git diff`, which the results document
must show.

**Decision.** We chose (1).
**Falsifiability.** We would move to (2) if `git show` from the scaffold fails inside the eval
sandbox for the repository path in T1's Check first and its explicit `--repo` fallback also
fails.
**Fired-if.** manual

---

## Decision: `--group` exists; the release run still runs everything   (→ REQ-7, REQ-8)

**Context.** B7 approved keeping the full run before every release (20 → 38 cases, about
$13.50). S9-T1 asks for `--group` so an arm can be run one group at a time and T5 can watch
the three always-on cases alone.

**Alternatives.**
1. `--group <name>` maps to the eval tool's `--case '<name>-*'` (cases are named
   `<group>-<case>` already); no flag runs everything. The core group is `scoped/`, not the
   plan's `rules-scoped/`, because `rules-*` would also match it.
2. Run only the groups whose files changed (B7's other option).

**Case for (1).** Three lines in a script that is twelve lines long; the release run keeps its
meaning (every case, every time); T5 gets its regression watch for about $1.

**Case against (1).** A prefix match is loose: `--group grandfather` also runs
`grandfather-xl-*`. That is documented, and no task in this plan needs the narrower set.

**Decision.** We chose (1).
**Falsifiability.** We would adopt (2) if a release run of `scripts/evals.sh` passes $25 at
list price, which is where "run everything" stops being the cheap default.
**Fired-if.** manual

---

## Decision: The stopping rule for `rules/nontrivial`   (→ REQ-17, REQ-18, REQ-19, REQ-20)

**Context.** The case has passed about one run in three since 3.1.0 (1 of 3 at the 4.1.0 exit
run; 1 of 10 and 1 of 9 in the 3.2 series). The always-on rules have 4 bytes of room. B8
approved at most three one-sentence attempts, each paid for within its file.

**Alternatives.**
1. Read three failing traces first; at most three attempts, each one sentence in one always-on
   rule with the bytes cut elsewhere in the same file; each judged by
   `evals.sh --group rules` (all three cases); keep the first attempt at which `nontrivial`
   reaches 2 of 3 and the other two hold; otherwise revert everything and record 0002 accepts
   the range with the clause the plan wrote.
2. Accept now, without the experiment.
3. Open-ended attempts until the case passes.

**Case for (1).** Three runs at about $0.40 each per attempt is cheap; the traces decide what
the sentence says rather than a guess; the budget stops the rules from growing back toward the
11,867 bytes that 3.1.0 had.

**Case against (1).** Three runs cannot tell 1 of 3 from 2 of 3 reliably (the 3.2 series
needed ten); a kept attempt may be luck. The clause in record 0002 is the guard: it reopens
the question on the next release's numbers.

**Decision.** We chose (1). The sentence changed, if any, and the numbers of every attempt
go in record 0002 either way.
**Falsifiability.** We would reopen this if `rules/nontrivial` passes fewer than one run in
ten across three consecutive releases, or if a user reports building without a spec after
asking for one — the clause the plan wrote, carried into 0002.
**Fired-if.** manual

---

## Data / interface changes

- New: `plugins/shipkit/evals/lib/with-rule.sh <rule> [--repo <path>]` (REQ-1 to REQ-4),
  `plugins/shipkit/evals/fixtures/stack-gen.sh <stack|static|monorepo>` (REQ-5, REQ-6),
  eighteen case folders under `evals/scoped/` and `evals/stacks/` (REQ-10 to REQ-13),
  `docs/design/eval-results-4.2.md` (REQ-14, REQ-15), `.shipkit/decisions/0002-spec-first-eval.md`
  (REQ-17).
- Changed: `scripts/evals.sh` gains `--group` (REQ-7, REQ-8); `scripts/lint.py` check 17's
  limit becomes 131,072 (REQ-9); `docs/design/trim-audit-4.0.md` gains an appended section
  (REQ-16); at most one sentence in `plugins/shipkit/rules/{spec-driven,shipkit}.md` (REQ-19).
- Environment: `SHIPKIT_EVAL_NO_RULE` and `SHIPKIT_EVAL_RULE_REF` are read by `with-rule.sh`
  only, when a scaffold is run by hand; an eval arm is selected by a scratch copy of the plugin
  whose `with-rule.sh` sets the variable's default (one `sed`). No shipped script reads them.
