# /shipkit:product — Reference

The shape of `.shipkit/product.md`. Seven headings, in this order, all present. At most 60
lines. Other skills read it by heading, so keep the heading text exactly as written here.

```markdown
# Product: <name>

> Product reviewed on 2026-10-05.

## One line
<what it is and who it is for, in one sentence>

## Users
- <who uses it, and what they come to it to do>

## Goals this quarter
- <goal> — metric: <what is measured>; target: <the number>; by: <YYYY-MM-DD>
- <goal> — metric: <what is measured>; target: <the number>; by: <YYYY-MM-DD>

## Non-goals
- <something this product deliberately does not do>

## Metrics that matter
- <the few numbers that say whether the product is healthy>

## Constraints
- <budget, stack, legal, time>

## Now / Next / Later
- **Now:** <what is being worked on>
- **Next:** <what follows>
- **Later:** <what is wanted but not yet planned>
```

## Rules for each section

- **One line** — one sentence. If it needs "and" twice, it is two products or it is not yet clear.
- **Users** — people, not "customers" in general. Two or three lines.
- **Goals this quarter** — **at most three**, one bullet each, each with a metric, a target
  and a date. A goal without one of them is written with the gap showing:
  `- Faster checkout — metric: none set; target: none set; by: 2026-12-31`.
  Anything beyond three goes to `Next` or `Later`.
- **Non-goals** — things someone might reasonably ask for that the answer to is "no, on
  purpose". `/shipkit:intake` checks every request against this list, so write them as plain
  statements: "No multi-currency support."
- **Metrics that matter** — the standing health numbers, which may differ from this quarter's
  goal metrics.
- **Constraints** — only real ones: a budget, a stack that is fixed, a law, a deadline.
- **Now / Next / Later** — three bullets. Not a backlog.

## Good and bad goals

- ✅ "Cut failed charges — metric: share of charges that fail; target: under 2%; by: 2026-12-31"
- ❌ "Improve reliability" — no metric, no target, no date. Ask once; then write the gaps.
