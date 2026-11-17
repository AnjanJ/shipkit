# Intake: honest evidence

> Intake taken on 2026-11-17.

## Request

Sprint 29 of `docs/plans/verifier-sprint-plan.md`, "What the evidence says", approved by the owner
on 2026-11-17 ("yes to all"). Six pieces:

1. `scripts/smoke.sh` gains `--no-model` and `--only`, so the suite can run without starting a
   model.
2. `spec-check.sh` prints one `EVIDENCE` line per spec: how many requirements are tested, waived
   and uncited.
3. An optional `> Tests:` line in `spec.md` narrows where a citation counts, with
   `CITED-ELSEWHERE` for a citation outside it.
4. `SKIPPED-CITE` names a citation that sits in a skipped test, as information only.
5. A new `spec-diff.sh` lists requirements changed, added, removed or waived on the branch, and
   `brief-verify.sh` prints `SPEC-EDITED`.
6. Smoke assertions that only read a prompt's wording are labelled and counted.

The owner's words on how to do it: "lets put things that would cost as for the end of development,
so if we can put all in one release and run the steps that cost us money at the end would be
great", and "do what you think is best". So this sprint starts no paid model run and changes no
existing skill, agent or rule file (the plan's rules 33 and 34).

## Serves goal

None. There is no `.shipkit/product.md` (`.shipkit/` holds `decisions/`, `releases/`, `specs/` and
`state.md`). The ROADMAP's north star is the nearest statement: shipkit "checks the result against
the intent, and refuses to call unfinished work done" (`ROADMAP.md:6-8`).

## Conflicts found

None.

- **Non-goals:** none recorded, since there is no product file.
- **Open specs:** none. All 31 specs under `.shipkit/specs/` read `Status: shipped`.
- **Decisions:** two shipped records are touched, and neither is contradicted.
  - `spec-contract/design.md:40`, "Tests cite `<slug>/REQ-N`, not a bare `REQ-N`", chose a
    citation "written anywhere in a test file". Its own case against says "Nothing stops a
    citation from sitting in a comment". The `> Tests:` line keeps that choice and lets one spec
    say where its test files are. The record turned down matching by `Paths` because it fails for
    a spec with no such line and for tests kept in one shared file; the new line is optional and
    may name a file, so neither failure applies. Its reversal condition (a folder renamed more
    than once, or the reviewer finding more than two citations in one sprint whose test does not
    exercise the requirement) has not come true.
  - `gate-blind-spots/design.md:44`, "Everything under `.shipkit/` is allowed, except another
    spec's folder". `SPEC-EDITED` is information and changes no exit status, so the record stands.

## Answers

No question was asked. Every unknown is answered by the approved plan or by a file, and each is
written below as an assumption for the owner to object to.

## Assumptions made

1. **`--only` takes check numbers, not names.** The plan wrote names. Names repeat in the suite:
   checks 19, 20 and 28 are all called "spec-check".
2. **The design decides how far `--only` reaches, and the smallest form that serves its one use is
   preferred.** That use is Sprint 35 running one failed model check again after its fix (the
   plan's rule 30). Sections lean on each other: checks 20 and 28 reuse helpers that check 19
   defines (`scripts/smoke.sh:629-630`, `:1041-1042`).
3. **A check that has both kinds of assertion keeps its model-free ones under `--no-model`.** Only
   the assertions that need a model are skipped.
4. **No existing spec gains a `> Tests:` line.** Without the line today's rule holds, so
   `spec-contract/REQ-4` (`spec.md:37`) stays true as written.
5. **A `> Tests:` line may name a file as well as a folder.** This repository's tests live in
   shared files (`scripts/smoke.sh`, `scripts/evals.sh`).
6. **`SKIPPED-CITE` uses the plan's marker list and its three-line window, and is information
   only** until a real run reads it with no false positive (the plan's V4).
7. **`spec-diff.sh` compares against `spec.md` at the base ref,** or the first commit in which the
   spec's status reads `open`. The acceptance stamp cannot be the baseline: on the 5.2 run it named
   `179f99d` and the spec was first committed in `8f2dbb4` (`docs/design/field-notes-5.2.md` §7).
8. **The changes to skills and their reference files that belong with these pieces are tasks of
   this spec that wait for Sprint 35.** They are the report's evidence line, the report's block of
   changed requirements, and the spec skill asking for a `> Tests:` line.
9. **Plugin scripts stay POSIX `sh`, awk and git** (`spec-contract/REQ-10`, `spec.md:48`).
   `scripts/smoke.sh` stays `sh` as well.

## Out of scope

- Any change to an existing skill, agent or rule file, and any paid model run.
- The gate script, the single test command, `release-check.sh` and the judge: Sprint 30.
- Making `SKIPPED-CITE` a gap, or making a changed requirement block anything.
- Cutting any smoke check. The labels and the audit are this sprint's; the cuts are Sprint 34's.
- A `> Tests:` line on any of the 31 shipped specs.
