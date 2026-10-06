#!/bin/bash
# Three small products in the run's workspace, a registry that points at them and the user's
# studio priorities, all under shipkit-home/ so the digest script writes there and not under
# the run's home. `ledger` has an escape recorded today and uncommitted work; `notes` has a
# nearly finished spec; `brochure` has nothing going on. Runs only with --scaffold.
set -e
HOME_DIR="$PWD/shipkit-home"
mkdir -p "$HOME_DIR"
TODAY=$(date +%Y-%m-%d)
mkproj() {  # mkproj <name> → an empty git repository
  mkdir -p "$1" && (cd "$1" && git init -q . && git -c user.email=eval@example.com -c user.name=eval commit -q --allow-empty -m init)
}
spec() {  # spec <proj> <slug> <done> <total>
  local d="$1/.shipkit/specs/$2"; mkdir -p "$d"
  printf '# Spec: %s\n\n> Spec accepted at commit `abc1234` on main.\n> Status: open\n\n## Requirements (EARS)\n\n- **REQ-1.** The system shall %s.\n' "$2" "$2" > "$d/spec.md"
  : > "$d/tasks.md"
  for ((i = 1; i <= $4; i++)); do
    local box=' '; (( i <= $3 )) && box='x'
    local after=none; (( i > 1 )) && after="T$((i - 1))"
    printf -- '- [%s] **T%d** Step %d of %s → REQ-1\n  - Files: app/%s.py\n  - Test: tests/test_%s.py\n  - After: %s\n  - Done when: tests pass\n' "$box" "$i" "$i" "$2" "$2" "$2" "$after" >> "$d/tasks.md"
  done
  mkdir -p "$1/tests"; printf '# %s/REQ-1\n' "$2" > "$1/tests/test_$2.py"
}

mkproj ledger
mkdir -p ledger/.shipkit/escapes
cat > ledger/.shipkit/product.md <<'MD'
# Product: ledger

> Product reviewed on 2026-10-01.

## One line
Invoicing and card charges for small shops.

## Users
- Shop owners who send invoices and take card payments.

## Goals this quarter
- Cut failed charges — metric: share of charges that fail; target: under 2%; by: 2026-12-31

## Non-goals
- No multi-currency support.

## Metrics that matter
- Failed-charge rate.

## Constraints
- One engineer.

## Now / Next / Later
- **Now:** refunds
- **Next:** retries
- **Later:** statements
MD
spec ledger refunds 1 3
cat > ledger/.shipkit/escapes/0001-over-refund.md <<MD
# Escape 0001: refund above the charge accepted

> Recorded on $TODAY.

## What happened
A refund of 25.00 on a 20.00 charge was paid out.

## Cause
\`requirement missing\` — no requirement said a refund may not exceed the charge.

## Spec
\`.shipkit/specs/refunds/\`

## Fix
REQ-2 added; T3 carries the check.
MD
(cd ledger && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "spec and escape")
printf 'def refund():\n    pass\n' > ledger/app_refunds_wip.py
printf 'notes\n' > ledger/NOTES.txt

mkproj notes
mkdir -p notes/.shipkit
cat > notes/.shipkit/product.md <<'MD'
# Product: notes

> Product reviewed on 2026-09-20.

## One line
Shared notes for small teams.

## Users
- Teams of two to ten.

## Goals this quarter
- Ship sharing — metric: notes shared per week; target: 50; by: 2026-11-30

## Non-goals
- No real-time editing.

## Metrics that matter
- Weekly active teams.

## Constraints
- None.

## Now / Next / Later
- **Now:** sharing
- **Next:** search
- **Later:** export
MD
spec notes sharing 3 4
(cd notes && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "spec")

mkproj brochure

cat > "$HOME_DIR/project-registry.md" <<MD
# Shipkit Project Registry
> Portfolio index for \`eve\`. One row per project. Update via \`/shipkit:map --register\`.

| Project | Path | Map | Mapped At | Stack | Deploys To | Active Specs | Product | Top Goal | Summary |
|---------|------|-----|-----------|-------|------------|--------------|---------|----------|---------|
| ledger | $PWD/ledger | — | ? | Python | Fly.io | refunds | Invoicing and card charges for small shops | Cut failed charges under 2% by 2026-12-31 | Invoicing service |
| notes | $PWD/notes | — | ? | Python | Vercel | sharing | Shared notes for small teams | Ship sharing, 50 per week by 2026-11-30 | Notes app |
| brochure | $PWD/brochure | — | ? | HTML | Netlify | — | ? | ? | Static marketing site |
MD
cat > "$HOME_DIR/studio.md" <<'MD'
# Studio priorities

> Studio reviewed on 2026-10-05.

1. **ledger** — Failed charges under 2% before the holiday season.
2. **notes** — Ship sharing to the first ten teams.
3. **brochure** — Keep it running; nothing new this quarter.
MD
