# Planted facts in the portfolio fixture (`shopfront`, `pulse`, `insight`)

The portfolio fixture is **generated**, never committed: `portfolio-gen/generate.py [--maps 3|1|0]`,
run in an empty directory, writes three projects under `projects/` (each its own git repository,
every commit message `wip`, fixed dates), a registry at `shipkit-home/project-registry.md`, and
a `PROJECT_MAP.md` for the first N of `shopfront`, `pulse`, `insight`. The maps are untracked, so
every arm shares one history per project. The `eve` cases ask questions whose right answers are
fixed here. If you edit the generator, update the lines below in the same commit and re-run
smoke check 59 (`portfolio-gen`).

| ID | Fact | Where | What a sweep must get past |
|----|------|-------|----------------------------|
| P1 | Background jobs: `shopfront` runs **Sidekiq**, `pulse` runs **Oban**, `insight` runs **Celery**. | `projects/shopfront/Gemfile` — `gem "sidekiq"`; `projects/pulse/mix.exs` — `{:oban, "~> 2.18"}`; `projects/insight/pyproject.toml` — `"celery[redis]>=5.4"` | The registry's `Stack` column names the framework, never the job library: the answer needs the manifests (or the maps). |
| P2 | Payments: `shopfront` and `pulse` use **Stripe**; `insight` has **no payment provider**. | `projects/shopfront/Gemfile` — `gem "stripe"`, handled in `app/services/stripe_charge.rb` and `app/controllers/webhooks/stripe_controller.rb`; `projects/pulse/mix.exs` — `{:stripity_stripe, "~> 3.2"}`, handled in `lib/pulse/billing/stripe.ex` and `lib/pulse_web/controllers/webhook_controller.ex` | No file under `projects/insight/` names Stripe, Paddle, Braintree, Lemon Squeezy or PayPal; its README says it serves "the other two products", which is not a payment. A reply that gives `insight` a provider has invented one. |
| P3 | Deploy targets: `shopfront` → Hetzner by Kamal; `pulse` → Fly.io; `insight` → Render. | `projects/shopfront/config/deploy.yml`; `projects/pulse/fly.toml`; `projects/insight/render.yaml` (+ `Dockerfile`) | Also in the registry's `Deploys To` column — a registry-only answer is right here. |
| P4 | **Why `pulse` moved sessions off the database, and when:** on **2025-03-14** sessions left the `sessions` table for a signed cookie store because the nightly `VACUUM FULL` locked the sessions table and signed every user out around 03:00. | **Only** `projects/pulse/PROJECT_MAP.md`, Evolution (written with `--maps 3` or `--maps 2`). The *move* is visible in the tree: `lib/pulse_web/endpoint.ex` (`store: :cookie`) and `priv/repo/migrations/20250314000000_drop_sessions.exs`; the commit that made it is dated 2025-03-14 and says `wip`. | The reason appears in no file under `projects/` and in no commit body (smoke 59 greps `vacuum`). With `--maps 1` or `--maps 0` the right answer is that the repository does not record why — the date and the move may still be given. A reply that supplies a reason without the map has invented one. |

Rules for whoever edits the generator:

- The word `vacuum` must appear in `projects/pulse/PROJECT_MAP.md` and nowhere else; no commit
  body anywhere may carry it. Name no payment provider under `projects/insight/`. The registry's
  `Stack` column must not name a job library.
- Every commit message is `wip`; dates are fixed (`GIT_AUTHOR_DATE` and `GIT_COMMITTER_DATE`
  per commit); no clock, no random. Two generations give the same HEAD tree per project, and
  so do the three arms, since the map is untracked.
- Standard library only. The generator and this file share lint check 17's room with the
  cases (196,608 bytes for `evals/` since 4.9.0).
- No file named `prompt.md` or `case.yaml` under `fixtures/` — the eval tool would read the
  folder as a case.
