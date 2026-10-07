#!/bin/sh
# Shipkit evals: write the smallest project a stack rule's `paths:` globs match, into the
# current (empty) directory. Nothing is run — the model edits, the grader reads — so no
# toolchain is needed in the eval sandbox. One function per stack, plus two shapes for core
# rules that sample-app cannot exercise: `static` (ui-ux.md) and `monorepo` (monorepo.md);
# `rails` carries db/migrate/ for migrations.md. Deterministic: no clock, no randomness.
#
#   stack-gen.sh <elixir|go|hotwire|liveview|ml|oban|python|rails|react|static|monorepo>
w() { mkdir -p "$(dirname "$1")"; cat > "$1"; }

gen_elixir() {
w mix.exs <<'X'
defmodule Ledger.MixProject do
  use Mix.Project
  def project, do: [app: :ledger, version: "0.4.0", elixir: "~> 1.17", deps: deps()]
  defp deps, do: [{:jason, "~> 1.4"}, {:req, "~> 0.5"}, {:ex_doc, "~> 0.34", only: :dev}]
end
X
w mix.lock <<'X'
%{"jason": {:hex, :jason, "1.4.4"}, "req": {:hex, :req, "0.5.6"}, "ex_doc": {:hex, :ex_doc, "0.34.2"}}
X
w lib/ledger/orders.ex <<'X'
defmodule Ledger.Orders do
  @moduledoc "Create and total orders. Amounts are integer cents."
  def total(lines), do: Enum.reduce(lines, 0, fn {_sku, cents, qty}, acc -> acc + cents * qty end)
end
X
w test/ledger/orders_test.exs <<'X'
defmodule Ledger.OrdersTest do
  use ExUnit.Case
  test "totals lines" do assert Ledger.Orders.total([{"a", 100, 2}]) == 200 end
end
X
}

gen_go() {
w go.mod <<'X'
module example.com/ledger

go 1.23

require github.com/google/uuid v1.6.0
X
w go.sum <<'X'
github.com/google/uuid v1.6.0 h1:NIvaJDMOsjHA8n1jAhLSgzrAzy1Hgr+hNrb57e+94F0=
github.com/google/uuid v1.6.0/go.mod h1:TIyPZe4MgqvfeYDBFedMoGGpEw/LqOeaOT+nhxU+yHo=
X
w cmd/ledger/main.go <<'X'
package main

import "example.com/ledger/internal/orders"

func main() { _ = orders.Total(nil) }
X
w internal/orders/orders.go <<'X'
// Package orders creates and totals orders. Amounts are integer cents.
package orders

type Line struct{ SKU string; Cents, Qty int }

func Total(lines []Line) int { t := 0; for _, l := range lines { t += l.Cents * l.Qty }; return t }
X
w internal/orders/orders_test.go <<'X'
package orders

import "testing"

func TestTotal(t *testing.T) { if Total([]Line{{"a", 100, 2}}) != 200 { t.Fatal("total") } }
X
}

gen_rails_base() {  # shared by rails, hotwire, react
w Gemfile <<'X'
source "https://rubygems.org"
gem "rails", "~> 8.0"
gem "pg", "~> 1.5"
gem "puma", "~> 6.4"
group :development, :test do
  gem "rspec-rails", "~> 7.0"
end
X
w Gemfile.lock <<'X'
GEM
  remote: https://rubygems.org/
  specs:
    rails (8.0.1)
    pg (1.5.9)
    puma (6.4.3)
    rspec-rails (7.1.0)
DEPENDENCIES
  pg (~> 1.5)
  puma (~> 6.4)
  rails (~> 8.0)
  rspec-rails (~> 7.0)
X
w config/routes.rb <<'X'
Rails.application.routes.draw do
  resources :orders, only: %i[index show create]
end
X
w app/models/order.rb <<'X'
class Order < ApplicationRecord
  has_many :line_items
  validates :customer_email, presence: true
  def total_cents = line_items.sum { |l| l.unit_cents * l.quantity }
end
X
w app/controllers/orders_controller.rb <<'X'
class OrdersController < ApplicationController
  def index = @orders = Order.order(created_at: :desc).limit(50)
  def show = @order = Order.find(params[:id])
end
X
w db/migrate/20240101000000_create_orders.rb <<'X'
class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :customer_email, null: false
      t.string :status, null: false, default: "pending"
      t.timestamps
    end
  end
end
X
w spec/models/order_spec.rb <<'X'
require "rails_helper"
RSpec.describe Order do
  it "requires an email" { expect(Order.new).not_to be_valid }
end
X
}

gen_rails() { gen_rails_base; }

gen_hotwire() {
gen_rails_base
w app/javascript/controllers/clipboard_controller.js <<'X'
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["source"]
  copy() { navigator.clipboard.writeText(this.sourceTarget.value) }
}
X
w app/frontend/controllers/index.js <<'X'
// vite-rails entry: registers every controller in this directory
X
w app/views/orders/index.html.erb <<'X'
<h1>Orders</h1>
<div id="orders">
  <%= render @orders %>
</div>
X
w app/views/orders/_order.html.erb <<'X'
<div id="<%= dom_id(order) %>" class="order">
  <span><%= order.customer_email %></span> <span><%= order.status %></span>
</div>
X
w app/views/orders/create.turbo_stream.erb <<'X'
<%= turbo_stream.prepend "orders", @order %>
X
w app/components/status_badge_component.rb <<'X'
class StatusBadgeComponent < ViewComponent::Base
  def initialize(status:) = @status = status
end
X
}

gen_react() {
gen_rails_base
w package.json <<'X'
{
  "name": "ledger",
  "private": true,
  "scripts": { "build": "vite build", "test": "vitest run" },
  "dependencies": { "@inertiajs/react": "^2.0.0", "react": "^18.3.1", "react-dom": "^18.3.1" },
  "devDependencies": { "vite": "^5.4.0", "vitest": "^2.1.0" }
}
X
w pnpm-lock.yaml <<'X'
lockfileVersion: '9.0'
importers:
  .:
    dependencies:
      react:
        specifier: ^18.3.1
        version: 18.3.1
X
w vite.config.ts <<'X'
import { defineConfig } from "vite"
import RubyPlugin from "vite-plugin-ruby"
export default defineConfig({ plugins: [RubyPlugin()] })
X
w app/frontend/entrypoints/application.tsx <<'X'
import { createInertiaApp } from "@inertiajs/react"
createInertiaApp({ resolve: (name) => import(`../pages/${name}.tsx`) })
X
w app/frontend/pages/Orders/Index.tsx <<'X'
type Order = { id: number; customer_email: string; status: string }
export default function Index({ orders }: { orders: Order[] }) {
  return <ul>{orders.map((o) => <li key={o.id}>{o.customer_email} — {o.status}</li>)}</ul>
}
X
}

gen_liveview() {
gen_elixir
w lib/ledger_web/live/orders_live.ex <<'X'
defmodule LedgerWeb.OrdersLive do
  use LedgerWeb, :live_view
  def mount(_params, _session, socket), do: {:ok, assign(socket, orders: Ledger.Orders.list())}
  def handle_event("refresh", _p, socket), do: {:noreply, assign(socket, orders: Ledger.Orders.list())}
end
X
w lib/ledger_web/live/orders_live.html.heex <<'X'
<h1>Orders</h1>
<ul id="orders"><li :for={o <- @orders} id={"order-#{o.id}"}><%= o.email %></li></ul>
<button phx-click="refresh">Refresh</button>
X
w lib/ledger_web/components/core_components.ex <<'X'
defmodule LedgerWeb.CoreComponents do
  use Phoenix.Component
  attr :status, :string, required: true
  def badge(assigns), do: ~H"<span class=\"badge\"><%= @status %></span>"
end
X
}

gen_oban() {
gen_elixir
w lib/ledger/workers/charge_worker.ex <<'X'
defmodule Ledger.Workers.ChargeWorker do
  use Oban.Worker, queue: :billing, max_attempts: 5
  @impl true
  def perform(%Oban.Job{args: %{"order_id" => id}}), do: Ledger.Billing.charge(id)
end
X
w lib/ledger/jobs/mail_job.ex <<'X'
defmodule Ledger.Jobs.MailJob do
  use Oban.Worker, queue: :mail
  @impl true
  def perform(%Oban.Job{args: %{"order_id" => id}}), do: Ledger.Mailer.receipt(id)
end
X
w config/config.exs <<'X'
import Config
config :ledger, Oban, repo: Ledger.Repo, queues: [billing: 5, mail: 10, default: 10]
X
}

gen_python() {
w pyproject.toml <<'X'
[project]
name = "ledger"
version = "0.4.0"
requires-python = ">=3.11"
dependencies = ["fastapi>=0.115,<1", "sqlalchemy>=2.0,<3"]

[tool.uv]
dev-dependencies = ["pytest>=8"]
X
w uv.lock <<'X'
version = 1
requires-python = ">=3.11"

[[package]]
name = "fastapi"
version = "0.115.6"
X
w src/ledger/orders.py <<'X'
"""Orders: create, store and total them. Amounts are integer cents."""


def total(lines: list[tuple[str, int, int]]) -> int:
    return sum(cents * qty for _sku, cents, qty in lines)
X
w tests/test_orders.py <<'X'
from ledger.orders import total


def test_total():
    assert total([("a", 100, 2)]) == 200
X
}

gen_ml() {
gen_python
w data/README.md <<'X'
# data/

Raw files live here and are gitignored; `make fetch` pulls them. Source and licence per set
are listed in `datasets/README.md`.
X
w src/ledger/datasets/loader.py <<'X'
"""Load the transactions dataset from data/ into a DataFrame."""
import pandas as pd


def load(path="data/transactions.parquet"):
    return pd.read_parquet(path)
X
w configs/train.yaml <<'X'
model: gbt
learning_rate: 0.05
n_estimators: 400
X
w experiments/baseline/README.md <<'X'
Baseline: gradient-boosted trees on transactions, validation AUC 0.81.
X
w src/ledger/train.py <<'X'
"""Train the fraud classifier from configs/train.yaml."""
from ledger.datasets.loader import load


def main():
    df = load()
    return df.shape
X
w src/ledger/eval.py <<'X'
"""Evaluate a saved model on the held-out split."""


def main(model_path):
    return {"auc": 0.0}
X
w notebooks/explore.ipynb <<'X'
{"cells": [{"cell_type": "code", "execution_count": null, "metadata": {}, "outputs": [], "source": ["from ledger.datasets.loader import load\n", "df = load()\n", "df.head()"]}], "metadata": {}, "nbformat": 4, "nbformat_minor": 5}
X
}

gen_static() {
w index.html <<'X'
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>Ledger</title><link rel="stylesheet" href="styles/site.css"></head>
<body>
<header><a href="index.html">Ledger</a> <a href="pricing.html">Pricing</a></header>
<main>
<h1>Books that balance</h1><p>Simple invoicing for small teams.</p>
<h2>Recent orders</h2>
<ul class="orders">
  <li class="order" data-id="1041">#1041 — ada@example.com — $21.45</li>
  <li class="order" data-id="1042">#1042 — grace@example.com — $9.99</li>
  <li class="order" data-id="1043">#1043 — linus@example.com — $120.00</li>
</ul>
</main>
<script src="scripts/site.js"></script>
</body>
</html>
X
w pricing.html <<'X'
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>Pricing — Ledger</title><link rel="stylesheet" href="styles/site.css"></head>
<body><main><h1>Pricing</h1><p>Free for one user.</p></main></body>
</html>
X
w styles/site.css <<'X'
:root { --ink: #1a1a1a; --paper: #fafafa; --accent: #2a6; }
body { font: 16px/1.5 system-ui, sans-serif; color: var(--ink); background: var(--paper); margin: 0 auto; max-width: 48rem; padding: 1rem; }
X
w scripts/site.js <<'X'
document.querySelectorAll("a").forEach((a) => a.addEventListener("click", () => {}));
X
}

gen_monorepo() {
w pnpm-workspace.yaml <<'X'
packages:
  - "apps/*"
  - "packages/*"
X
w turbo.json <<'X'
{ "$schema": "https://turbo.build/schema.json", "tasks": { "build": { "dependsOn": ["^build"] }, "test": { "dependsOn": ["build"] } } }
X
w package.json <<'X'
{ "name": "ledger-monorepo", "private": true, "scripts": { "build": "turbo run build", "test": "turbo run test" }, "devDependencies": { "turbo": "^2.3.0" } }
X
w packages/money/package.json <<'X'
{ "name": "@ledger/money", "version": "1.2.0", "main": "src/index.ts", "scripts": { "test": "vitest run" } }
X
w packages/money/src/index.ts <<'X'
export function formatCents(cents: number, currency = "USD"): string {
  return new Intl.NumberFormat("en-US", { style: "currency", currency }).format(cents / 100)
}
X
w apps/web/package.json <<'X'
{ "name": "web", "private": true, "dependencies": { "@ledger/money": "workspace:*" }, "scripts": { "test": "vitest run" } }
X
w apps/web/src/total.ts <<'X'
import { formatCents } from "@ledger/money"
export const show = (cents: number) => formatCents(cents)
X
w apps/api/package.json <<'X'
{ "name": "api", "private": true, "dependencies": { "@ledger/money": "workspace:*" }, "scripts": { "test": "vitest run" } }
X
w apps/api/src/invoice.ts <<'X'
import { formatCents } from "@ledger/money"
export const line = (cents: number) => `Total ${formatCents(cents)}`
X
}

case "$1" in
  elixir|go|hotwire|liveview|ml|oban|python|rails|react|static|monorepo) "gen_$1" ;;
  *) echo "stack-gen: usage: stack-gen.sh <elixir|go|hotwire|liveview|ml|oban|python|rails|react|static|monorepo>" >&2; exit 64 ;;
esac
