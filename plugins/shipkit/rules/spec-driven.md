# Spec-Driven Development

Non-trivial work answers three questions before code. Trivial work is exempt: never spec a typo, and say so when you skip.

1. **What are we building?** `spec.md`: testable EARS requirements, numbered `REQ-N`.
2. **How should it work?** `design.md`: decision records.
3. **How will we know it's done?** `tasks.md`: each task cites its `REQ-N`; each requirement gets a test, written first, that cites `<feature>/REQ-N`.

Files live in `.shipkit/specs/<feature>/`; `/shipkit:spec` writes them and has the formats. A small change needs only a few lines per question. Under the `lightweight` style, answer inline; write files only when asked.
