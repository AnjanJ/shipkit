# Intake: Live decisions and the studio digest

> Intake taken on 2026-10-06.

## Request
Sprint 6 of the quality-gate plan: a decision record may carry a command that says whether its
reversal condition has come true; a script lists or runs those commands; the elders and the
ship gate use it; a local script writes a weekly digest across every registered project; and
`/shipkit:ask --all digest` has `eve` say which product needs attention.

## Serves goal
None — this repository has no `.shipkit/product.md`.

## Conflicts found
- **Non-goals:** could not be checked; there is no product file.
- **Open specs:** none.
- **Decision records:** none contradicts it. Decision A6 (commands run only on request, never
  from a hook) and A7 (a local script, not a cloud agent) are the request's own constraints.
- **The always-on budget:** S6-T1 says to edit `rules/decisions.md` "inside the byte budget".
  The three rules stand at 2,996 of 3,000 bytes. A new line about `Fired-if` cannot fit
  without removing something, and the template and the `/shipkit:decide` skill already carry
  the format. The intake proposes leaving the rule unchanged (see Assumptions).
- **Writing outside the project in tests:** `portfolio-digest.sh` writes to
  `~/.claude/shipkit/digests/`. A smoke check must not write into the owner's home directory,
  so the script takes an override for where it writes.

## Answers
No question was asked: the plan fixes the formats, the safety rules and both decisions (A6,
A7). The two points above are resolved by the assumptions below; the owner approves them with
the requirements.

## Assumptions made
- `rules/decisions.md` is not edited in S6-T1. The `Fired-if` line is taught by the template
  in the spec reference and by `/shipkit:decide`, which every decision record goes through.
- `portfolio-digest.sh` honours `SHIPKIT_HOME` (default `~/.claude/shipkit`) for the registry
  and the digests directory, so the smoke check runs against a scratch directory.
- The elders' and the gate's new behaviour are prose; the eval for `eve`'s digest answer runs
  against a scratch registry and digest built by the case's scaffold.
- The "Check first, optional" on a scheduled cloud agent is answered from the documentation
  and written in `GUIDE.md`; nothing is built on it either way (A7).

## Out of scope
- Running any decision command from a hook, the briefing, or the digest by default.
- Judging whether a reversal condition is a good one; `decision-check.sh` runs what is written.
