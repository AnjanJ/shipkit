#!/usr/bin/env python3
"""The portfolio eval fixture for `eve`: three small projects of three stack shapes, a registry,
and a map for the first N of them, written into the CURRENT (empty) directory. Deterministic
(fixed dates, no clock); standard library only; every commit message is "wip", so the log says
nothing. `--maps 3|1|0` (default 3) picks the arm: maps for shopfront, pulse, insight in that
order. Maps are untracked, so every arm shares one git history per project. Facts: ../FACTS-PORTFOLIO.md."""
import os, subprocess, sys

args = sys.argv[1:]
MAPS = int(args[args.index("--maps") + 1]) if "--maps" in args else 3
if MAPS not in (0, 1, 2, 3):
    sys.exit("generate.py: --maps takes 0, 1, 2 or 3")
ORDER = ["shopfront", "pulse", "insight"]
GIT = ["git", "-c", "user.name=dev", "-c", "user.email=dev@example.com", "-c", "commit.gpgsign=false"]


def w(path, text):
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(path, "w") as f:
        f.write(text.lstrip("\n"))


def commit(repo, day, files, remove=()):
    """One "wip" commit: write `files`, delete `remove`, stamp both dates with `day`."""
    for path, text in files.items():
        w(os.path.join(repo, path), text)
    env = dict(os.environ, GIT_AUTHOR_DATE=day + "T09:00:00+00:00", GIT_COMMITTER_DATE=day + "T09:00:00+00:00")
    for path in remove:
        subprocess.run(GIT + ["-C", repo, "rm", "-q", path], check=True, env=env)
    subprocess.run(GIT + ["-C", repo, "add", "-A"], check=True, env=env)
    subprocess.run(GIT + ["-C", repo, "commit", "-q", "-m", "wip"], check=True, env=env)


# --- shopfront: a Rails shop (Sidekiq, Stripe, Kamal to Hetzner) --------------------------
SHOPFRONT = [
    ("2024-01-05", {
        "README.md": "# shopfront\n\nA small shop: products, orders, card payments.\n\n    bin/rails test\n",
        ".gitignore": "/log\n/tmp\n/storage\n.env\n",
        "Gemfile": '''
source "https://rubygems.org"
ruby "3.3.1"

gem "rails", "~> 7.2.1"
gem "pg", "~> 1.5"
gem "puma", ">= 6.4"
gem "sidekiq", "~> 7.3"
gem "stripe", "~> 12.0"
gem "turbo-rails"
gem "stimulus-rails"
gem "kamal", require: false

group :development, :test do
  gem "debug"
end
''',
        "Gemfile.lock": "GEM\n  remote: https://rubygems.org/\n  specs:\n    rails (7.2.1)\n    pg (1.5.6)\n    sidekiq (7.3.2)\n    stripe (12.4.0)\n\nRUBY VERSION\n   ruby 3.3.1p55\n",
        "bin/rails": "#!/usr/bin/env ruby\nAPP_PATH = File.expand_path(\"../config/application\", __dir__)\nrequire_relative \"../config/boot\"\nrequire \"rails/commands\"\n",
        "config/application.rb": 'require_relative "boot"\nrequire "rails/all"\n\nmodule Shopfront\n  class Application < Rails::Application\n    config.load_defaults 7.2\n    config.active_job.queue_adapter = :sidekiq\n  end\nend\n',
        "config/boot.rb": 'ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)\nrequire "bundler/setup"\n',
        "config/routes.rb": 'Rails.application.routes.draw do\n  resources :products, only: [:index, :show]\n  resources :orders, only: [:index, :show, :create]\n  namespace :webhooks do\n    post "stripe", to: "stripe#create"\n  end\nend\n',
        "config/database.yml": "default: &default\n  adapter: postgresql\n  pool: 5\n\ndevelopment:\n  <<: *default\n  database: shopfront_development\n\nproduction:\n  <<: *default\n  url: <%= ENV[\"DATABASE_URL\"] %>\n",
        "config/sidekiq.yml": ":concurrency: 5\n:queues:\n  - default\n  - mailers\n",
        "app/models/product.rb": "class Product < ApplicationRecord\n  has_many :line_items\n  validates :name, :price_cents, presence: true\nend\n",
        "app/models/customer.rb": "class Customer < ApplicationRecord\n  has_many :orders\n  validates :email, presence: true, uniqueness: true\nend\n",
        "app/models/order.rb": "class Order < ApplicationRecord\n  belongs_to :customer\n  has_many :line_items\n  enum :status, { pending: 0, paid: 1, shipped: 2 }\n\n  def total_cents\n    line_items.sum(&:subtotal_cents)\n  end\nend\n",
        "app/models/line_item.rb": "class LineItem < ApplicationRecord\n  belongs_to :order\n  belongs_to :product\n\n  def subtotal_cents\n    product.price_cents * quantity\n  end\nend\n",
        "db/migrate/20240105090000_create_products.rb": "class CreateProducts < ActiveRecord::Migration[7.2]\n  def change\n    create_table :products do |t|\n      t.string :name, null: false\n      t.integer :price_cents, null: false\n      t.timestamps\n    end\n  end\nend\n",
        "db/migrate/20240105090100_create_customers.rb": "class CreateCustomers < ActiveRecord::Migration[7.2]\n  def change\n    create_table :customers do |t|\n      t.string :email, null: false, index: { unique: true }\n      t.timestamps\n    end\n  end\nend\n",
        "db/migrate/20240105090200_create_orders.rb": "class CreateOrders < ActiveRecord::Migration[7.2]\n  def change\n    create_table :orders do |t|\n      t.references :customer, null: false, foreign_key: true\n      t.integer :status, null: false, default: 0\n      t.timestamps\n    end\n    create_table :line_items do |t|\n      t.references :order, null: false\n      t.references :product, null: false\n      t.integer :quantity, null: false, default: 1\n    end\n  end\nend\n",
    }),
    ("2024-02-12", {
        "app/controllers/application_controller.rb": "class ApplicationController < ActionController::Base\nend\n",
        "app/controllers/products_controller.rb": "class ProductsController < ApplicationController\n  def index\n    @products = Product.order(:name)\n  end\n\n  def show\n    @product = Product.find(params[:id])\n  end\nend\n",
        "app/controllers/orders_controller.rb": "class OrdersController < ApplicationController\n  def index\n    @orders = Order.where(customer: current_customer)\n  end\n\n  def show\n    @order = Order.find(params[:id])\n  end\n\n  def create\n    order = Order.create!(customer: current_customer, status: :pending)\n    StripeCharge.new(order).call\n    OrderConfirmationJob.perform_later(order.id)\n    redirect_to order\n  end\nend\n",
        "app/views/products/index.html.erb": "<h1>Products</h1>\n<ul>\n  <% @products.each do |p| %>\n    <li><%= link_to p.name, p %></li>\n  <% end %>\n</ul>\n",
        "app/views/orders/show.html.erb": "<h1>Order <%= @order.id %></h1>\n<p>Status: <%= @order.status %></p>\n<p>Total: <%= @order.total_cents %> cents</p>\n",
    }),
    ("2024-03-20", {
        "app/services/stripe_charge.rb": "# Charges an order's total through Stripe. The secret key comes from credentials.\nclass StripeCharge\n  def initialize(order)\n    @order = order\n  end\n\n  def call\n    Stripe.api_key = Rails.application.credentials.stripe_secret_key\n    intent = Stripe::PaymentIntent.create(amount: @order.total_cents, currency: \"eur\")\n    @order.update!(status: :paid, payment_intent_id: intent.id)\n    intent\n  end\nend\n",
        "app/controllers/webhooks/stripe_controller.rb": "module Webhooks\n  class StripeController < ApplicationController\n    skip_forgery_protection\n\n    def create\n      event = Stripe::Webhook.construct_event(request.raw_post, request.headers[\"Stripe-Signature\"],\n                                              Rails.application.credentials.stripe_webhook_secret)\n      RefundSyncJob.perform_later(event.id) if event.type == \"charge.refunded\"\n      head :ok\n    end\n  end\nend\n",
        "app/jobs/application_job.rb": "class ApplicationJob < ActiveJob::Base\nend\n",
        "app/jobs/order_confirmation_job.rb": "class OrderConfirmationJob < ApplicationJob\n  queue_as :mailers\n\n  def perform(order_id)\n    OrderMailer.confirmation(Order.find(order_id)).deliver_now\n  end\nend\n",
        "app/jobs/refund_sync_job.rb": "class RefundSyncJob < ApplicationJob\n  queue_as :default\n\n  def perform(event_id)\n    event = Stripe::Event.retrieve(event_id)\n    Order.find_by(payment_intent_id: event.data.object.payment_intent)&.update!(status: :pending)\n  end\nend\n",
        "app/mailers/order_mailer.rb": "class OrderMailer < ApplicationMailer\n  def confirmation(order)\n    @order = order\n    mail(to: order.customer.email, subject: \"Your order\")\n  end\nend\n",
        "db/migrate/20240320100000_add_payment_intent_to_orders.rb": "class AddPaymentIntentToOrders < ActiveRecord::Migration[7.2]\n  def change\n    add_column :orders, :payment_intent_id, :string\n    add_index :orders, :payment_intent_id\n  end\nend\n",
        "test/services/stripe_charge_test.rb": 'require "test_helper"\n\nclass StripeChargeTest < ActiveSupport::TestCase\n  test "marks the order paid" do\n    skip "needs a Stripe test key"\n  end\nend\n',
        "test/models/order_test.rb": 'require "test_helper"\n\nclass OrderTest < ActiveSupport::TestCase\n  test "total sums line items" do\n    assert_equal 0, Order.new.total_cents\n  end\nend\n',
    }),
    ("2024-06-03", {
        "config/deploy.yml": "service: shopfront\nimage: shopfront/web\nservers:\n  web:\n    - 95.217.10.42\n  job:\n    hosts:\n      - 95.217.10.42\n    cmd: bundle exec sidekiq\nregistry:\n  server: ghcr.io\n  username: shopfront\nenv:\n  secret:\n    - DATABASE_URL\n    - RAILS_MASTER_KEY\naccessories:\n  db:\n    image: postgres:16\n    host: 95.217.10.42\n",
        "Dockerfile": "FROM ruby:3.3.1-slim\nWORKDIR /app\nCOPY Gemfile Gemfile.lock ./\nRUN bundle install\nCOPY . .\nCMD [\"bin/rails\", \"server\"]\n",
        ".kamal/secrets": "RAILS_MASTER_KEY=$RAILS_MASTER_KEY\nDATABASE_URL=$DATABASE_URL\n",
    }),
]

# --- pulse: a Phoenix app (Oban, stripity_stripe, Fly.io); sessions moved to a cookie store ---
ENDPOINT = '''
defmodule PulseWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :pulse

  @session_options [
    store: %s,
    key: "_pulse_key",
    signing_salt: "x4Jq2mWz"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]
  plug Plug.Static, at: "/", from: :pulse
  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json], json_decoder: Jason
  plug Plug.Session, @session_options
  plug PulseWeb.Router
end
'''
PULSE = [
    ("2024-01-10", {
        "README.md": "# pulse\n\nTeam check-ins and weekly digests, with paid plans.\n\n    mix test\n",
        ".gitignore": "/_build\n/deps\n/.elixir_ls\n.env\n",
        ".formatter.exs": '[import_deps: [:ecto, :phoenix], inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"]]\n',
        "mix.exs": '''
defmodule Pulse.MixProject do
  use Mix.Project

  def project do
    [app: :pulse, version: "0.4.0", elixir: "~> 1.17", deps: deps()]
  end

  def application do
    [mod: {Pulse.Application, []}, extra_applications: [:logger]]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_ecto, "~> 4.6"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},
      {:oban, "~> 2.18"},
      {:stripity_stripe, "~> 3.2"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.5"}
    ]
  end
end
''',
        "mix.lock": '%{\n  "oban": {:hex, :oban, "2.18.3", "", [:mix], [], "hexpm", ""},\n  "phoenix": {:hex, :phoenix, "1.7.14", "", [:mix], [], "hexpm", ""},\n  "stripity_stripe": {:hex, :stripity_stripe, "3.2.0", "", [:mix], [], "hexpm", ""},\n}\n',
        "config/config.exs": 'import Config\n\nconfig :pulse, ecto_repos: [Pulse.Repo]\nconfig :pulse, Oban, repo: Pulse.Repo, queues: [default: 10, digests: 2]\nconfig :pulse, PulseWeb.Endpoint, adapter: Bandit.PhoenixAdapter, pubsub_server: Pulse.PubSub\n\nimport_config "#{config_env()}.exs"\n',
        "config/dev.exs": 'import Config\n\nconfig :pulse, Pulse.Repo, database: "pulse_dev", hostname: "localhost"\nconfig :pulse, PulseWeb.Endpoint, http: [port: 4000], debug_errors: true\n',
        "config/runtime.exs": 'import Config\n\nif config_env() == :prod do\n  config :pulse, Pulse.Repo, url: System.fetch_env!("DATABASE_URL"), pool_size: 10\n  config :stripity_stripe, api_key: System.fetch_env!("STRIPE_SECRET_KEY")\nend\n',
        "lib/pulse/application.ex": "defmodule Pulse.Application do\n  use Application\n\n  def start(_type, _args) do\n    children = [\n      Pulse.Repo,\n      {Phoenix.PubSub, name: Pulse.PubSub},\n      {Oban, Application.fetch_env!(:pulse, Oban)},\n      PulseWeb.Endpoint\n    ]\n\n    Supervisor.start_link(children, strategy: :one_for_one, name: Pulse.Supervisor)\n  end\nend\n",
        "lib/pulse/repo.ex": "defmodule Pulse.Repo do\n  use Ecto.Repo, otp_app: :pulse, adapter: Ecto.Adapters.Postgres\nend\n",
        "lib/pulse/accounts.ex": "defmodule Pulse.Accounts do\n  import Ecto.Query\n  alias Pulse.{Repo, Accounts.User}\n\n  def get_user!(id), do: Repo.get!(User, id)\n  def list_users, do: Repo.all(from u in User, order_by: u.email)\nend\n",
        "lib/pulse/accounts/user.ex": 'defmodule Pulse.Accounts.User do\n  use Ecto.Schema\n\n  schema "users" do\n    field :email, :string\n    field :plan, :string, default: "free"\n    timestamps()\n  end\nend\n',
        "lib/pulse_web/endpoint.ex": ENDPOINT % "PulseWeb.SessionStore",
        "lib/pulse_web/session_store.ex": '''
defmodule PulseWeb.SessionStore do
  @moduledoc "Plug.Session store backed by the sessions table."
  @behaviour Plug.Session.Store
  alias Pulse.Repo

  def init(opts), do: opts

  def get(_conn, sid, _opts) do
    case Repo.get_by(Pulse.Accounts.Session, sid: sid) do
      nil -> {nil, %{}}
      row -> {sid, row.data}
    end
  end

  def put(_conn, sid, data, _opts) do
    Repo.insert!(%Pulse.Accounts.Session{sid: sid || Ecto.UUID.generate(), data: data},
      on_conflict: :replace_all, conflict_target: :sid).sid
  end

  def delete(_conn, sid, _opts) do
    Repo.delete_all(Ecto.Query.from(s in Pulse.Accounts.Session, where: s.sid == ^sid))
    :ok
  end
end
''',
        "lib/pulse/accounts/session.ex": 'defmodule Pulse.Accounts.Session do\n  use Ecto.Schema\n\n  schema "sessions" do\n    field :sid, :string\n    field :data, :map\n    timestamps()\n  end\nend\n',
        "lib/pulse_web/router.ex": 'defmodule PulseWeb.Router do\n  use Phoenix.Router\n  import Phoenix.LiveView.Router\n\n  pipeline :browser do\n    plug :accepts, ["html"]\n    plug :fetch_session\n    plug :protect_from_forgery\n  end\n\n  scope "/", PulseWeb do\n    pipe_through :browser\n    live "/", DashboardLive\n    post "/webhooks/stripe", WebhookController, :stripe\n  end\nend\n',
        "lib/pulse_web/live/dashboard_live.ex": 'defmodule PulseWeb.DashboardLive do\n  use Phoenix.LiveView\n\n  def mount(_params, _session, socket) do\n    {:ok, assign(socket, users: Pulse.Accounts.list_users())}\n  end\n\n  def render(assigns) do\n    ~H"""\n    <ul><li :for={u <- @users}><%%= u.email %%> (<%%= u.plan %%>)</li></ul>\n    """\n  end\nend\n'.replace("%%", "%"),
        "priv/repo/migrations/20240110000000_create_users.exs": 'defmodule Pulse.Repo.Migrations.CreateUsers do\n  use Ecto.Migration\n\n  def change do\n    create table(:users) do\n      add :email, :string, null: false\n      add :plan, :string, null: false, default: "free"\n      timestamps()\n    end\n\n    create unique_index(:users, [:email])\n  end\nend\n',
        "priv/repo/migrations/20240110000100_create_sessions.exs": "defmodule Pulse.Repo.Migrations.CreateSessions do\n  use Ecto.Migration\n\n  def change do\n    create table(:sessions) do\n      add :sid, :string, null: false\n      add :data, :map, null: false, default: %{}\n      timestamps()\n    end\n\n    create unique_index(:sessions, [:sid])\n  end\nend\n",
    }),
    ("2024-04-22", {
        "lib/pulse/billing.ex": 'defmodule Pulse.Billing do\n  @moduledoc "Plans and subscriptions; the provider calls live in Pulse.Billing.Stripe."\n  alias Pulse.{Accounts, Billing.Stripe}\n\n  def subscribe(user_id, plan) do\n    user = Accounts.get_user!(user_id)\n    {:ok, sub} = Stripe.create_subscription(user.email, plan)\n    Pulse.Repo.update!(Ecto.Changeset.change(user, plan: plan))\n    sub\n  end\nend\n',
        "lib/pulse/billing/stripe.ex": 'defmodule Pulse.Billing.Stripe do\n  @moduledoc "Every call to Stripe goes through here (stripity_stripe)."\n\n  def create_subscription(email, plan) do\n    {:ok, customer} = Stripe.Customer.create(%{email: email})\n    Stripe.Subscription.create(%{customer: customer.id, items: [%{price: price_id(plan)}]})\n  end\n\n  defp price_id("team"), do: System.fetch_env!("STRIPE_PRICE_TEAM")\n  defp price_id(_), do: System.fetch_env!("STRIPE_PRICE_SOLO")\nend\n',
        "lib/pulse_web/controllers/webhook_controller.ex": 'defmodule PulseWeb.WebhookController do\n  use Phoenix.Controller\n\n  def stripe(conn, _params) do\n    {:ok, event} = Stripe.Webhook.construct_event(conn.assigns.raw_body, List.first(get_req_header(conn, "stripe-signature")), System.fetch_env!("STRIPE_WEBHOOK_SECRET"))\n    Oban.insert!(Pulse.Workers.InvoiceWorker.new(%{event_id: event.id}))\n    send_resp(conn, 200, "ok")\n  end\nend\n',
        "lib/pulse/workers/invoice_worker.ex": 'defmodule Pulse.Workers.InvoiceWorker do\n  use Oban.Worker, queue: :default, max_attempts: 5\n\n  @impl Oban.Worker\n  def perform(%Oban.Job{args: %{"event_id" => id}}) do\n    {:ok, _event} = Stripe.Event.retrieve(id)\n    :ok\n  end\nend\n',
        "lib/pulse/workers/digest_worker.ex": 'defmodule Pulse.Workers.DigestWorker do\n  use Oban.Worker, queue: :digests\n\n  @impl Oban.Worker\n  def perform(%Oban.Job{args: %{"user_id" => id}}) do\n    _user = Pulse.Accounts.get_user!(id)\n    :ok\n  end\nend\n',
        "test/test_helper.exs": "ExUnit.start()\n",
        "test/pulse/billing_test.exs": 'defmodule Pulse.BillingTest do\n  use ExUnit.Case\n\n  test "plan names" do\n    assert "team" in ["solo", "team"]\n  end\nend\n',
        "test/pulse_web/live/dashboard_live_test.exs": 'defmodule PulseWeb.DashboardLiveTest do\n  use ExUnit.Case\n\n  test "mounts" do\n    assert true\n  end\nend\n',
    }),
    ("2024-09-02", {
        "fly.toml": 'app = "pulse-app"\nprimary_region = "ams"\n\n[build]\n\n[env]\n  PHX_HOST = "pulse-app.fly.dev"\n  PORT = "8080"\n\n[http_service]\n  internal_port = 8080\n  force_https = true\n\n[[vm]]\n  size = "shared-cpu-1x"\n',
        "Dockerfile": "FROM hexpm/elixir:1.17.2-erlang-27.0-debian-bookworm-slim\nWORKDIR /app\nCOPY mix.exs mix.lock ./\nRUN mix deps.get --only prod\nCOPY . .\nRUN MIX_ENV=prod mix release\nCMD [\"_build/prod/rel/pulse/bin/pulse\", \"start\"]\n",
        "rel/overlays/bin/migrate": "#!/bin/sh\nexec ./pulse eval Pulse.Release.migrate\n",
    }),
    # 2025-03-14: sessions leave the database for a signed cookie. The commit says "wip"; only the
    # map's Evolution section says why (the nightly vacuum locked the sessions table).
    ("2025-03-14", {
        "lib/pulse_web/endpoint.ex": ENDPOINT % ":cookie",
        "priv/repo/migrations/20250314000000_drop_sessions.exs": "defmodule Pulse.Repo.Migrations.DropSessions do\n  use Ecto.Migration\n\n  def up, do: drop table(:sessions)\n\n  def down do\n    create table(:sessions) do\n      add :sid, :string, null: false\n      add :data, :map, null: false, default: %{}\n      timestamps()\n    end\n  end\nend\n",
    }, ["lib/pulse_web/session_store.ex", "lib/pulse/accounts/session.ex"]),
]

# --- insight: a Python analytics service (Celery, Docker on Render); no payments at all -------
INSIGHT = [
    ("2024-02-01", {
        "README.md": "# insight\n\nEvent ingest and weekly rollups for the other two products.\n\n    make test\n",
        ".gitignore": "__pycache__/\n.venv/\n.env\n",
        "pyproject.toml": '''
[project]
name = "insight"
version = "0.3.0"
requires-python = ">=3.12"
dependencies = [
  "fastapi>=0.115",
  "uvicorn>=0.30",
  "sqlalchemy>=2.0",
  "psycopg[binary]>=3.2",
  "celery[redis]>=5.4",
  "pydantic>=2.8",
]

[project.optional-dependencies]
dev = ["pytest>=8.3", "ruff>=0.6"]
''',
        "Makefile": "test:\n\tpytest -q\n\nworker:\n\tcelery -A insight.celery_app worker -B\n",
        "insight/__init__.py": "",
        "insight/config.py": 'import os\n\nDATABASE_URL = os.environ.get("DATABASE_URL", "postgresql://localhost/insight")\nREDIS_URL = os.environ.get("REDIS_URL", "redis://localhost:6379/0")\n',
        "insight/db.py": "from sqlalchemy import create_engine\nfrom sqlalchemy.orm import sessionmaker\nfrom .config import DATABASE_URL\n\nengine = create_engine(DATABASE_URL)\nSession = sessionmaker(bind=engine)\n",
        "insight/models/__init__.py": "from .event import Event\nfrom .report import Report\n",
        "insight/models/event.py": 'from sqlalchemy import Column, DateTime, Integer, String, JSON\nfrom sqlalchemy.orm import declarative_base\n\nBase = declarative_base()\n\n\nclass Event(Base):\n    __tablename__ = "events"\n    id = Column(Integer, primary_key=True)\n    source = Column(String, nullable=False)\n    name = Column(String, nullable=False)\n    at = Column(DateTime, nullable=False)\n    payload = Column(JSON, default=dict)\n',
        "insight/models/report.py": 'from sqlalchemy import Column, Date, Integer, String, JSON\nfrom .event import Base\n\n\nclass Report(Base):\n    __tablename__ = "reports"\n    id = Column(Integer, primary_key=True)\n    source = Column(String, nullable=False)\n    week = Column(Date, nullable=False)\n    totals = Column(JSON, default=dict)\n',
        "migrations/0001_events.sql": "create table if not exists events (id serial primary key, source text not null, name text not null, at timestamp not null, payload jsonb default '{}');\n",
        "migrations/0002_reports.sql": "create table if not exists reports (id serial primary key, source text not null, week date not null, totals jsonb default '{}');\n",
    }),
    ("2024-03-18", {
        "insight/celery_app.py": 'from celery import Celery\nfrom .config import REDIS_URL\n\napp = Celery("insight", broker=REDIS_URL, backend=REDIS_URL)\napp.conf.beat_schedule = {\n    "weekly-rollup": {"task": "insight.tasks.rollup.run", "schedule": 7 * 24 * 3600},\n}\napp.autodiscover_tasks(["insight.tasks"])\n',
        "insight/tasks/__init__.py": "",
        "insight/tasks/ingest.py": 'from ..celery_app import app\nfrom ..db import Session\nfrom ..models import Event\n\n\n@app.task(name="insight.tasks.ingest.run")\ndef run(batch):\n    with Session() as s:\n        s.add_all(Event(**row) for row in batch)\n        s.commit()\n    return len(batch)\n',
        "insight/tasks/rollup.py": 'from datetime import date\nfrom ..celery_app import app\nfrom ..db import Session\nfrom ..models import Event, Report\n\n\n@app.task(name="insight.tasks.rollup.run")\ndef run():\n    with Session() as s:\n        totals = {}\n        for e in s.query(Event):\n            totals[e.name] = totals.get(e.name, 0) + 1\n        s.add(Report(source="all", week=date.today(), totals=totals))\n        s.commit()\n    return totals\n',
        "insight/api/__init__.py": "from fastapi import FastAPI\nfrom .events import router as events\nfrom .reports import router as reports\n\napp = FastAPI(title=\"insight\")\napp.include_router(events)\napp.include_router(reports)\n",
        "insight/api/events.py": 'from fastapi import APIRouter\nfrom ..tasks.ingest import run\n\nrouter = APIRouter()\n\n\n@router.post("/events")\ndef post_events(batch: list[dict]):\n    run.delay(batch)\n    return {"queued": len(batch)}\n',
        "insight/api/reports.py": 'from fastapi import APIRouter\nfrom ..db import Session\nfrom ..models import Report\n\nrouter = APIRouter()\n\n\n@router.get("/reports")\ndef list_reports():\n    with Session() as s:\n        return [{"week": str(r.week), "totals": r.totals} for r in s.query(Report)]\n',
        "scripts/backfill.py": '"""Re-run the rollup for every past week."""\nfrom insight.tasks.rollup import run\n\nif __name__ == "__main__":\n    run.delay()\n',
        "tests/__init__.py": "",
        "tests/test_ingest.py": "def test_ingest_counts():\n    assert 3 == len([1, 2, 3])\n",
        "tests/test_rollup.py": "def test_rollup_shape():\n    assert isinstance({}, dict)\n",
        "tests/test_api.py": "def test_routes_exist():\n    assert True\n",
    }),
    ("2024-07-15", {
        "Dockerfile": 'FROM python:3.12-slim\nWORKDIR /app\nCOPY pyproject.toml .\nRUN pip install .\nCOPY . .\nCMD ["uvicorn", "insight.api:app", "--host", "0.0.0.0", "--port", "10000"]\n',
        "render.yaml": "services:\n  - type: web\n    name: insight-api\n    runtime: docker\n    plan: starter\n    envVars:\n      - key: DATABASE_URL\n        fromDatabase:\n          name: insight-db\n          property: connectionString\n  - type: worker\n    name: insight-worker\n    runtime: docker\n    dockerCommand: celery -A insight.celery_app worker -B\ndatabases:\n  - name: insight-db\n    plan: starter\n",
        ".dockerignore": ".venv\n__pycache__\n",
    }),
]

# --- the maps: one per mapped project; Evolution holds the why the log does not -------------
MAPS_TEXT = {
    "shopfront": '''
# PROJECT_MAP — shopfront

> Map generated at commit `%s` on `main`. Refresh with `/shipkit:map`.
> This is a navigational index. Claims here are verified at write time but source is truth.

## What this project is

A small web shop: a product list, orders with line items, card payments, a confirmation email.

## Stack
- **Language/framework:** Rails 7.2 (Ruby 3.3)
- **Datastore:** PostgreSQL  **Cache/queue:** Sidekiq (`config/sidekiq.yml`, queues `default`, `mailers`)
- **Deploy:** Hetzner, one host, by Kamal (`config/deploy.yml`)
- **Test:** minitest — run with `bin/rails test`

## Layout (where things live)
| Path | Purpose |
|------|---------|
| `app/models/` | Product, Customer, Order, LineItem |
| `app/services/stripe_charge.rb` | the one place a card is charged |
| `app/controllers/webhooks/stripe_controller.rb` | Stripe webhooks (refunds) |
| `app/jobs/` | Sidekiq jobs: confirmation mail, refund sync |

## Primary flows
1. **Checkout** — `OrdersController#create` → `StripeCharge#call` → `OrderConfirmationJob` (mailers queue).
2. **Refund** — Stripe webhook → `RefundSyncJob` → the order back to pending.

## Evolution
- **Origin:** started 2024-01 as a product list with no checkout.
- **Major shifts:** 2024-03 card payments through Stripe; 2024-06 the move from a shared
  Heroku dyno to one Hetzner host with Kamal, because the dyno slept between orders and the
  first request of every morning timed out — nothing in the tree records that reason.
- **Heading toward:** a second host for the Sidekiq process.

## Gotchas
- `Order#total_cents` sums line items in Ruby; an order with no items totals 0, not nil.
''',
    "pulse": '''
# PROJECT_MAP — pulse

> Map generated at commit `%s` on `main`. Refresh with `/shipkit:map`.
> This is a navigational index. Claims here are verified at write time but source is truth.

## What this project is

Team check-ins with a weekly digest, on paid plans. One LiveView dashboard, two Oban workers.

## Stack
- **Language/framework:** Phoenix 1.7 with LiveView 1.0 (Elixir 1.17)
- **Datastore:** PostgreSQL  **Cache/queue:** Oban (`config/config.exs`, queues `default`, `digests`)
- **Deploy:** Fly.io, region `ams` (`fly.toml`), a release built by the `Dockerfile`
- **Test:** ExUnit — run with `mix test`

## Frontend interaction model
- **Model:** LiveView; UI state lives in socket assigns; updates reach the browser as diffs over `/live`.
- **Entry points:** `lib/pulse_web/live/dashboard_live.ex`

## Layout (where things live)
| Path | Purpose |
|------|---------|
| `lib/pulse/accounts.ex` | users and plans |
| `lib/pulse/billing/stripe.ex` | every call to Stripe (`stripity_stripe`) |
| `lib/pulse/workers/` | Oban workers: invoice sync, weekly digest |
| `lib/pulse_web/endpoint.ex` | the session configuration |

## Primary flows
1. **Subscribe** — `Pulse.Billing.subscribe/2` → `Pulse.Billing.Stripe.create_subscription/2` → the user's plan updated.
2. **Webhook** — `POST /webhooks/stripe` → `InvoiceWorker` on the `default` queue.

## Evolution
- **Origin:** started 2024-01 with a users table and a sessions table of its own.
- **Major shifts:** 2024-04 paid plans through Stripe; 2024-09 Fly.io. **2025-03-14: sessions
  moved off the database to a signed cookie store** (`Plug.Session` `store: :cookie` in
  `lib/pulse_web/endpoint.ex`; the `sessions` table dropped by `20250314000000_drop_sessions.exs`)
  **because the nightly `VACUUM FULL` on the production database locked the sessions table for
  several minutes and every user was signed out around 03:00.** The commit says "wip"; this is
  the only record of the reason.
- **Heading toward:** a second Oban queue for webhook retries.

## Gotchas
- `DashboardLive.mount/3` lists every user; there is no pagination yet.
''',
    "insight": '''
# PROJECT_MAP — insight

> Map generated at commit `%s` on `main`. Refresh with `/shipkit:map`.
> This is a navigational index. Claims here are verified at write time but source is truth.

## What this project is

An analytics service: the other products post events, Celery rolls them up weekly, FastAPI
serves the reports. It takes no payments and knows no customer.

## Stack
- **Language/framework:** Python 3.12, FastAPI
- **Datastore:** PostgreSQL  **Cache/queue:** Celery with a Redis broker (`insight/celery_app.py`)
- **Deploy:** Render, a web service and a worker from one `Dockerfile` (`render.yaml`)
- **Test:** pytest — run with `make test`

## Layout (where things live)
| Path | Purpose |
|------|---------|
| `insight/api/` | FastAPI routers: events in, reports out |
| `insight/tasks/` | Celery tasks: ingest, weekly rollup (beat) |
| `insight/models/` | Event, Report |

## Primary flows
1. **Ingest** — `POST /events` → `ingest.run.delay` → rows in `events`.
2. **Rollup** — Celery beat weekly → `rollup.run` → one `reports` row.

## Evolution
- **Origin:** started 2024-02 as a script run by cron on a shared box.
- **Major shifts:** 2024-03 Celery with beat replaced the cron entry because the shared box
  was retired and nobody wanted to own another one — not recorded anywhere in the tree.
- **Heading toward:** per-source rollups.

## Gotchas
- `rollup.run` reads every event each week; it is O(events), not O(week).
''',
}

STACK = {"shopfront": ("Rails 7.2 / Postgres", "Hetzner (Kamal)", "A small web shop with card payments"),
         "pulse": ("Phoenix 1.7 LiveView / Postgres", "Fly.io", "Team check-ins and weekly digests on paid plans"),
         "insight": ("Python 3.12 FastAPI / Postgres", "Render", "Event ingest and weekly rollups")}


def main():
    if os.listdir("."):
        sys.exit("generate.py: the current directory must be empty")
    root = os.getcwd()
    rows = []
    for name, commits in (("shopfront", SHOPFRONT), ("pulse", PULSE), ("insight", INSIGHT)):
        repo = os.path.join(root, "projects", name)
        os.makedirs(repo)
        subprocess.run(GIT + ["init", "-q", "-b", "main", repo], check=True)
        for entry in commits:
            commit(repo, entry[0], entry[1], entry[2] if len(entry) > 2 else ())
        sha = subprocess.run(GIT + ["-C", repo, "rev-parse", "--short", "HEAD"], check=True,
                             capture_output=True, text=True).stdout.strip()
        mapped = ORDER.index(name) < MAPS
        if mapped:
            w(os.path.join(repo, "PROJECT_MAP.md"), MAPS_TEXT[name] % sha)  # untracked: every arm shares one history
        stack, deploy, summary = STACK[name]
        rows.append("| %s | %s | %s | %s | %s | %s | — | ? | ? | %s |" % (
            name, repo, "PROJECT_MAP.md" if mapped else "—", sha if mapped else "?", stack, deploy, summary))
    w(os.path.join(root, "shipkit-home", "project-registry.md"),
      "# Shipkit Project Registry\n> Portfolio index for `eve`. One row per project. Update via `/shipkit:map --register`.\n\n"
      "| Project | Path | Map | Mapped At | Stack | Deploys To | Active Specs | Product | Top Goal | Summary |\n"
      "|---------|------|-----|-----------|-------|------------|--------------|---------|----------|---------|\n"
      + "\n".join(rows) + "\n")
    print("portfolio: shopfront, pulse, insight under projects/; %d of 3 mapped; registry at shipkit-home/" % MAPS)


if __name__ == "__main__":
    main()
