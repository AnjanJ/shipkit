# 0008 — The sixteen trap-2 cases stay; their own cost is the limit

> Status: **decided on 2026-11-18, on the owner's yes** (Sprint 31, `numbers-as-data`).
> Supersedes "Sixteen trap-2 cases, with and without" in `.shipkit/specs/second-traps/design.md`,
> which is marked and kept.

## Context

The second-traps record kept sixteen trap-2 cases, one per rule on its second named trap, and
said it would drop to eight "if the sixteen cases take more than 24 KB or the release run passes
$18". The release run passed $18 at both releases since: 5.1.0 cost $21.10 and 5.2.0 $21.25
(`docs/design/eval-history.md`). So the clause has been true for two releases, and nobody acted
on it.

The whole run's cost is the wrong measure for these cases. In 5.2.0 the sixteen trap-2 cases
were 64 of 227 runs and cost $5.29, passing 62 of 64
(`sh scripts/evals-ledger.sh --runs --last 1 --prefix trap2-`). The other $15.94 is spent by
cases this record does not govern. The release run also grew because cases were added elsewhere,
and dropping eight trap-2 cases would save about $2.65 a release. Their files take 18,726 bytes of
the 24 KB the old clause allows.

## Alternatives

1. **Keep all sixteen.** Tie the reversal to the trap-2 cases' own cost and size, and read both
   with a command.
2. Do what the old clause says: drop to the five core rules and the three shortest stack rules,
   eight cases.
3. Keep all sixteen and leave the old clause in place, still true and still ignored.

## Case for (1)

A condition that a case's own cost can trip says something about that case. The ledger records
the trap-2 cases' cost per release, so the condition can be checked by a command and not by
memory. Sixteen rows is what a later plan needs to name a rule line as a cut candidate. With
eight, eight rules go back to one measured trap.

## Case against (1)

The money is still spent: about $5.30 a release on cases that mostly pass with or without the
rule, which says only that the model does this unaided today. (2) saves about $2.65 a release and
does what the record promised. (3) costs nothing to write, and it leaves a record whose clause has
fired and that does not bind, which is what decision-check is meant to catch.

## Decision

We chose (1). All sixteen trap-2 cases stay in the release run.

**Falsifiability.** We would drop to the eight cases of (2) if the trap-2 cases cost more than $8
in the last release run, or their files under `plugins/shipkit/evals/trap2/` take more than
24 KB (24,576 bytes).
**Fired-if.** `o=$(sh scripts/evals-ledger.sh --runs --last 1 --prefix trap2-) && b=$(git ls-files -z plugins/shipkit/evals/trap2 | xargs -0 cat | wc -c) || exit 2; printf '%s %s\n' "$o" "$b" | awk '($5 != "-" && $5 + 0 > 8) || $6 + 0 > 24576 { f = 1 } END { exit !f }'` <!-- covers: the trap-2 cases above $8 in the last release run, or their files above 24 KB -->
