# Checks

Asked about when a diff meets the trigger. `plugins/shipkit/scripts/checks-match.sh` reads this
file from the base ref, so an item added on a branch takes effect after it merges.

## C1: A grader's pattern changed
Trigger: path plugins/shipkit/evals/*/graders/*
Check: The pattern is shown both ways through node: a reply it must pass and one it must fail are in scripts/grader-replies/ or in the commit's test plan.
From: docs/design/eval-history.md (Four graders corrected: the old graders failed 15 of 36 correct files)

## C2: A numeric limit in lint.py changed
Trigger: path scripts/lint.py
Check: Where a ceiling or a limit's number changed the commit names the owner's yes or the decision that allowed it.
From: scripts/lint.py (check 17's comment records each raise of the evals ceiling and who allowed it)

## C3: A requirement names its own gate
Trigger: added ^- [*][*]REQ-[0-9]+[.][*][*].*(READY|the tag|the merge)
Check: No requirement asks for its own READY report or the tag or the merge or anything after the gate. Those belong in the release task.
From: docs/design/eval-history.md (Release run 5.1.0: four requirements the spec could not meet at its own gate)

## C4: A text-only smoke check was added
Trigger: added passt "
Check: The requirement it cites is about wording or another assertion proves the behaviour.
From: docs/design/smoke-audit-5.4.md (18 of its 35 text-only assertions are all the proof their requirements have)
